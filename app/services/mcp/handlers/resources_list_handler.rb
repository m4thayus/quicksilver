# frozen_string_literal: true

module Mcp
  module Handlers
    class ResourcesListHandler
      def call(_params:)
        resources = task_resources + board_resources
        {
          "resources" => resources,
          "nextCursor" => nil
        }
      end

      private

      def task_resources
        Task.order(:id).map do |task|
          {
            "uri" => "quicksilver://tasks/#{task.id}",
            "name" => "Task #{task.id}: #{task.title}",
            "mimeType" => "application/json",
            "description" => task.description.to_s
          }
        end
      end

      def board_resources
        Board.order(:id).map do |board|
          {
            "uri" => "quicksilver://boards/#{board.id}",
            "name" => "Board #{board.id}: #{board.name}",
            "mimeType" => "application/json",
            "description" => "Board #{board.name}"
          }
        end
      end
    end
  end
end
