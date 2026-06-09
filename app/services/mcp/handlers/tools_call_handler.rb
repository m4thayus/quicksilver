# frozen_string_literal: true

module Mcp
  module Handlers
    class ToolsCallHandler
      MUTATING_TOOLS = %w[create_task update_task complete_task claim_task accept_task].freeze
      DEFAULT_LIST_LIMIT = 50

      def call(params:, current_user: nil)
        name = params["name"]
        arguments = params.fetch("arguments", {})
        raise Errors::InvalidParams, "name is required" if name.blank?
        raise Errors::InvalidParams, "arguments must be an object" unless arguments.is_a?(Hash)

        authorize_mutation!(name, current_user)
        result = execute_tool(name, arguments, current_user)
        build_response(result)
      end

      private

      def authorize_mutation!(name, current_user)
        return unless MUTATING_TOOLS.include?(name)
        raise Errors::Forbidden.new(data: "identity required") unless current_user&.resolved?
        raise Errors::Forbidden.new(data: "not authorized") unless current_user.engineer_or_admin?
      end

      def execute_tool(name, arguments, current_user)
        case name
        when "create_task" then create_task(arguments)
        when "update_task" then update_task(arguments)
        when "complete_task" then complete_task(arguments)
        when "claim_task" then claim_task(arguments, current_user)
        when "accept_task" then accept_task(arguments)
        else read_only_tool(name, arguments, current_user)
        end
      end

      def read_only_tool(name, arguments, current_user)
        case name
        when "available_work" then available_work
        when "proposed_work" then proposed_work
        when "list_tasks" then list_tasks(arguments, current_user)
        else raise Errors::InvalidParams, "Unknown tool #{name}"
        end
      end

      def list_tasks(arguments, current_user)
        scope = Task.all
        scope = filter_by_board(scope, arguments)
        scope = filter_by_status(scope, arguments["status"])
        scope = filter_by_owner(scope, arguments["owner"], current_user)
        tasks_response(scope.limit(list_limit(arguments["limit"])))
      end

      def filter_by_board(scope, arguments)
        return scope unless arguments.key?("board")

        name = arguments["board"]
        return scope.backlog if name.blank?

        board = Board.find_by(name:)
        raise Errors::InvalidParams, "Unknown board: #{name}" if board.nil?

        scope.where(board:)
      end

      def filter_by_status(scope, status)
        return scope if status.blank?

        case status
        when "available" then scope.available
        when "active" then scope.active
        when "recently_completed" then scope.recently_completed
        else raise Errors::InvalidParams, "Unknown status: #{status}"
        end
      end

      def filter_by_owner(scope, owner, current_user)
        return scope if owner.blank?

        if owner == "me"
          raise Errors::InvalidParams, "owner: me requires an identified user" unless current_user&.resolved?

          return scope.where(owner: current_user.user)
        end

        user = User.find_by(email: owner)
        user ? scope.where(owner: user) : scope.none
      end

      def list_limit(value)
        limit = value.to_i
        limit.positive? ? limit : DEFAULT_LIST_LIMIT
      end

      def accept_task(arguments)
        task = find_task(arguments)
        task.board_id = nil
        task.approved = false
        persist_task(task)
      end

      def claim_task(arguments, current_user)
        task = find_task(arguments)
        raise Errors::InvalidParams, "Task is already started" if task.started_at.present?
        raise Errors::InvalidParams, "Task is owned by another user" if task.owner_id.present? && task.owner_id != current_user.user.id

        task.owner = current_user.user
        task.started_at = Date.current
        persist_task(task)
      end

      def find_task(arguments)
        id = arguments["id"]
        raise Errors::InvalidParams, "id is required" if id.blank?

        Task.find(id)
      rescue ActiveRecord::RecordNotFound
        raise Errors::ResourceNotFound, "Task not found: #{id}"
      end

      def available_work
        tasks_response(Task.backlog.available.sort)
      end

      def proposed_work
        tasks_response(Task.wishlist.approved.highest_priority)
      end

      def tasks_response(tasks)
        { "tasks" => tasks.map { |task| task_payload(task) } }
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
        task = find_task(arguments)
        task.assign_attributes(permitted_task_attributes(arguments))
        persist_task(task)
      end

      def complete_task(arguments)
        task = find_task(arguments)
        task.completed_at = parse_completed_at(arguments["completed_at"])
        persist_task(task)
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
