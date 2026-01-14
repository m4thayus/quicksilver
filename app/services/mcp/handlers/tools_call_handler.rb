# frozen_string_literal: true

module Mcp
  module Handlers
    class ToolsCallHandler
      def call(params:)
        name = params["name"]
        arguments = params.fetch("arguments", {})
        raise Errors::InvalidParams, "name is required" if name.blank?
        raise Errors::InvalidParams, "arguments must be an object" unless arguments.is_a?(Hash)

        result = execute_tool(name, arguments)
        build_response(result)
      end

      private

      def execute_tool(name, arguments)
        case name
        when "create_task"
          create_task(arguments)
        when "update_task"
          update_task(arguments)
        when "complete_task"
          complete_task(arguments)
        else
          raise Errors::InvalidParams, "Unknown tool #{name}"
        end
      end

      def build_response(result)
        response = {
          "content" => [
            {
              "type" => "text",
              "text" => JSON.generate(result)
            }.tap { |c| c["isError"] = true if result[:isError] }
          ]
        }
        response["isError"] = true if result[:isError]
        response
      end

      def create_task(arguments)
        title = arguments["title"]
        raise Errors::InvalidParams, "title is required" if title.blank?

        task = Task.new(permitted_task_attributes(arguments))
        task.title = title
        persist_task(task)
      end

      def update_task(arguments)
        id = arguments["id"]
        raise Errors::InvalidParams, "id is required" if id.blank?

        task = Task.find(id)
        task.assign_attributes(permitted_task_attributes(arguments))
        persist_task(task)
      rescue ActiveRecord::RecordNotFound
        raise Errors::ResourceNotFound, "Task not found: #{id}"
      end

      def complete_task(arguments)
        id = arguments["id"]
        raise Errors::InvalidParams, "id is required" if id.blank?

        task = Task.find(id)
        task.completed_at = parse_completed_at(arguments["completed_at"])
        persist_task(task)
      rescue ActiveRecord::RecordNotFound
        raise Errors::ResourceNotFound, "Task not found: #{id}"
      end

      def permitted_task_attributes(arguments)
        arguments.slice(
          "title",
          "description",
          "board_id",
          "owner_id",
          "size",
          "priority",
          "status",
          "approved"
        )
      end

      def parse_completed_at(value)
        return Date.current if value.blank?

        Date.iso8601(value)
      rescue ArgumentError
        raise Errors::InvalidParams, "completed_at must be an ISO8601 date"
      end

      def persist_task(task)
        if task.save
          {
            "uri" => "quicksilver://tasks/#{task.id}",
            "task" => task_payload(task)
          }
        else
          # Return error as tool response content per MCP spec
          {
            "isError" => true,
            "error" => "Task validation failed",
            "details" => task.errors.full_messages
          }
        end
      end

      def task_payload(task)
        {
          id: task.id,
          title: task.title,
          description: task.description,
          status: task.status,
          size: task.size,
          priority: task.priority,
          board_id: task.board_id,
          owner_id: task.owner_id,
          approved: task.approved,
          started_at: task.started_at,
          expected_at: task.expected_at,
          completed_at: task.completed_at,
          created_at: task.created_at,
          updated_at: task.updated_at
        }
      end
    end
  end
end
