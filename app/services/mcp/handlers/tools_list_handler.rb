# frozen_string_literal: true

module Mcp
  module Handlers
    class ToolsListHandler
      def call(params:, current_user: nil) # rubocop:disable Lint/UnusedMethodArgument
        {
          "tools" => [
            create_task_tool,
            update_task_tool,
            complete_task_tool,
            available_work_tool,
            proposed_work_tool,
            claim_task_tool,
            accept_task_tool,
            list_tasks_tool
          ]
        }
      end

      private

      def available_work_tool
        {
          "name" => "available_work",
          "description" => "List available work on the engineering backlog (unstarted, unassigned), in size order.",
          "inputSchema" => { "type" => "object", "properties" => {} }
        }
      end

      def proposed_work_tool
        {
          "name" => "proposed_work",
          "description" => "List approved tasks proposed for the backlog (the wishlist inbound queue), highest priority first.",
          "inputSchema" => { "type" => "object", "properties" => {} }
        }
      end

      def claim_task_tool
        {
          "name" => "claim_task",
          "description" => "Claim a backlog task for yourself: assigns it to you and starts it (sets owner and started_at). Requires an engineer identity.",
          "inputSchema" => {
            "type" => "object",
            "properties" => {
              "id" => { "type" => "integer" }
            },
            "required" => ["id"]
          }
        }
      end

      def accept_task_tool
        {
          "name" => "accept_task",
          "description" => "Accept a proposed task onto the backlog: removes its board and clears approved. Requires an engineer identity.",
          "inputSchema" => {
            "type" => "object",
            "properties" => {
              "id" => { "type" => "integer" }
            },
            "required" => ["id"]
          }
        }
      end

      def list_tasks_tool
        {
          "name" => "list_tasks",
          "description" => "Query tasks by board, status, and owner.",
          "inputSchema" => {
            "type" => "object",
            "properties" => {
              "board" => { "type" => "string", "description" => "Board name (wishlist/suggestions/bizdev); null or empty for the backlog. Omit to span all boards." },
              "status" => { "type" => "string", "description" => "One of available, active, recently_completed." },
              "owner" => { "type" => "string", "description" => "Owner email, or 'me' for the identified user." },
              "limit" => { "type" => "integer", "description" => "Maximum number of tasks (default 50)." }
            }
          }
        }
      end

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
