# frozen_string_literal: true

module Mcp
  class Server
    PROTOCOL_VERSION = "2025-06-18"

    def initialize
      @handlers = {
        "initialize" => Handlers::InitializeHandler.new,
        "resources/list" => Handlers::ResourcesListHandler.new,
        "resources/read" => Handlers::ResourcesReadHandler.new,
        "tools/list" => Handlers::ToolsListHandler.new,
        "tools/call" => Handlers::ToolsCallHandler.new,
        "notifications/initialized" => Handlers::InitializedHandler.new
      }
    end

    def handle(payload)
      validate_payload!(payload)
      handler = @handlers.fetch(payload["method"]) { raise Errors::MethodNotFound }
      result = handler.call(params: payload.fetch("params", {}))
      return nil if payload["id"].nil?

      build_result(payload["id"], result)
    rescue Errors::Base => e
      build_error(payload.is_a?(Hash) ? payload["id"] : nil, e)
    end

    private

    def validate_payload!(payload)
      raise Errors::InvalidRequest unless payload.is_a?(Hash)
      raise Errors::InvalidRequest unless payload["jsonrpc"] == "2.0"
      raise Errors::InvalidRequest if payload["method"].blank?
    end

    def build_result(id, result)
      {
        "jsonrpc" => "2.0",
        "id" => id,
        "result" => result
      }
    end

    def build_error(id, error)
      {
        "jsonrpc" => "2.0",
        "id" => id,
        "error" => {
          "code" => error.code,
          "message" => error.message,
          "data" => error.data
        }.compact
      }
    end
  end
end
