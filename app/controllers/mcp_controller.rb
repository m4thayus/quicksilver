# frozen_string_literal: true

class McpController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    return render_streamable_http_error unless valid_accept_header?

    token = request.headers["Authorization"].to_s.delete_prefix("Bearer ").strip
    return render json: { error: "Unauthorized" }, status: :unauthorized unless token.present? && token == ENV.fetch("MCP_AUTH_TOKEN", nil)

    payload = parse_payload
    validate_protocol_version!(payload)
    server = Mcp::Server.new
    response = server.handle(payload)
    return head :accepted if response.nil?

    render json: response, status: response_status(response)
  rescue Mcp::Errors::ParseError => e
    render json: jsonrpc_error_response(nil, e), status: :bad_request
  rescue Mcp::Errors::InvalidRequest, Mcp::Errors::InvalidParams => e
    render json: jsonrpc_error_response(payload_id(payload), e), status: :bad_request
  rescue Mcp::Errors::ResourceNotFound => e
    render json: jsonrpc_error_response(payload_id(payload), e), status: :not_found
  end

  def show
    head :method_not_allowed
  end

  private

  def parse_payload
    raw_body = request.body.read
    JSON.parse(raw_body)
  rescue JSON::ParserError
    raise Mcp::Errors::ParseError
  end

  def validate_protocol_version!(payload)
    return if payload["method"] == "initialize"

    protocol_version = request.headers["MCP-Protocol-Version"].to_s
    raise Mcp::Errors::InvalidRequest, "MCP-Protocol-Version header is required" if protocol_version.blank?

    return if protocol_version == Mcp::Server::PROTOCOL_VERSION

    raise Mcp::Errors::InvalidRequest, "Unsupported MCP protocol version"
  end

  def valid_accept_header?
    header = request.headers["Accept"].to_s
    header.include?("application/json") && header.include?("text/event-stream")
  end

  def render_streamable_http_error
    error = Mcp::Errors::InvalidRequest.new("Accept header must include application/json and text/event-stream")
    render json: jsonrpc_error_response(nil, error), status: :bad_request
  end

  def response_status(response)
    error_code = response.dig("error", "code")
    return :bad_request if [-32_700, -32_600, -32_602].include?(error_code)
    return :not_found if error_code == -32_002

    :ok
  end

  def payload_id(payload)
    payload.is_a?(Hash) ? payload["id"] : nil
  end

  def jsonrpc_error_response(id, error)
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
