# frozen_string_literal: true

module Mcp
  module Handlers
    class ResourcesReadHandler
      def call(params:)
        uri = params["uri"]
        raise Errors::InvalidParams, "uri is required" if uri.blank?

        resolved = ResourceResolver.resolve(uri)
        {
          "contents" => [
            {
              "uri" => uri,
              "mimeType" => "application/json",
              "text" => JSON.generate(payload_for(resolved))
            }
          ]
        }
      end

      private

      def payload_for(resolved)
        case resolved[:type]
        when "task"
          task_payload(resolved[:record])
        when "board"
          board_payload(resolved[:record])
        else
          {}
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

      def board_payload(board)
        {
          id: board.id,
          name: board.name,
          task_ids: board.tasks.order(:id).pluck(:id),
          created_at: board.created_at,
          updated_at: board.updated_at
        }
      end
    end
  end
end
