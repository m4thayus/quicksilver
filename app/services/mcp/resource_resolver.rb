# frozen_string_literal: true

module Mcp
  class ResourceResolver
    def self.resolve(uri)
      match = uri.to_s.match(%r{\Aquicksilver://(?<type>tasks|boards)/(?<id>\d+)\z})
      raise Errors::InvalidParams, "Unknown resource URI" unless match

      id = match[:id].to_i
      case match[:type]
      when "tasks"
        { type: "task", record: Task.find(id) }
      when "boards"
        { type: "board", record: Board.find(id) }
      else
        raise Errors::InvalidParams, "Unsupported resource type"
      end
    rescue ActiveRecord::RecordNotFound
      raise Errors::ResourceNotFound, "Resource not found: #{uri}"
    end
  end
end
