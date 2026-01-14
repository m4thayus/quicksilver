# frozen_string_literal: true

module Mcp
  module Handlers
    class ToolsListHandler
      def call(_params:)
        {
          "tools" => [
            create_task_tool,
            update_task_tool,
            complete_task_tool
          ]
        }
      end

      private

      def create_task_tool
        {
          "name" => "create_task",
          "description" => "Create a new task.",
          "inputSchema" => {
            "type" => "object",
            "properties" => {
              "title" => { "type" => "string" },
              "description" => { "type" => "string" },
              "board_id" => { "type" => "integer" },
              "owner_id" => { "type" => "integer" },
              "size" => { "type" => "string" },
              "priority" => { "type" => "integer" }
            },
            "required" => ["title"]
          }
        }
      end

      def update_task_tool
        {
          "name" => "update_task",
          "description" => "Update an existing task.",
          "inputSchema" => {
            "type" => "object",
            "properties" => {
              "id" => { "type" => "integer" },
              "title" => { "type" => "string" },
              "description" => { "type" => "string" },
              "board_id" => { "type" => "integer" },
              "owner_id" => { "type" => "integer" },
              "size" => { "type" => "string" },
              "priority" => { "type" => "integer" },
              "status" => { "type" => "string" },
              "approved" => { "type" => "boolean" }
            },
            "required" => ["id"]
          }
        }
      end

      def complete_task_tool
        {
          "name" => "complete_task",
          "description" => "Mark a task as completed (sets completed_at).",
          "inputSchema" => {
            "type" => "object",
            "properties" => {
              "id" => { "type" => "integer" },
              "completed_at" => { "type" => "string", "description" => "ISO8601 date (optional)." }
            },
            "required" => ["id"]
          }
        }
      end
    end
  end
end
