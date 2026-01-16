# frozen_string_literal: true

module Mcp
  module Handlers
    class InitializeHandler
      def call(params:)
        client_info = params.fetch("clientInfo", {})
        protocol_version = params["protocolVersion"]
        raise Errors::InvalidParams, "protocolVersion is required" if protocol_version.blank?

        negotiated_version = Mcp::Server::PROTOCOL_VERSION
        {
          "protocolVersion" => negotiated_version,
          "serverInfo" => {
            "name" => "quicksilver-mcp",
            "version" => "0.1.0"
          },
          "clientInfo" => {
            "name" => client_info["name"],
            "version" => client_info["version"]
          }.compact,
          "capabilities" => {
            "resources" => {},
            "tools" => {}
          }
        }
      end
    end
  end
end
