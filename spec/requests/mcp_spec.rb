# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MCP", type: :request do
  let(:valid_headers) do
    {
      "Authorization" => "Bearer test-token",
      "Accept" => "application/json, text/event-stream",
      "Content-Type" => "application/json",
      "MCP-Protocol-Version" => "2025-06-18"
    }
  end

  let(:valid_token) { "test-token" }

  before do
    allow(ENV).to receive(:fetch).with("MCP_AUTH_TOKEN", nil).and_return(valid_token)
  end

  describe "GET /mcp" do
    it "returns method not allowed" do
      get "/mcp"
      expect(response).to have_http_status(:method_not_allowed)
    end
  end

  describe "POST /mcp" do
    context "with authentication" do
      it "rejects requests without Authorization header" do
        post "/mcp",
             params: { jsonrpc: "2.0", method: "initialize", id: 1 }.to_json,
             headers: valid_headers.except("Authorization")

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "Unauthorized" })
      end

      it "rejects requests with invalid token" do
        post "/mcp",
             params: { jsonrpc: "2.0", method: "initialize", id: 1 }.to_json,
             headers: valid_headers.merge("Authorization" => "Bearer wrong-token")

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "Unauthorized" })
      end

      it "rejects requests with malformed Authorization header" do
        post "/mcp",
             params: { jsonrpc: "2.0", method: "initialize", id: 1 }.to_json,
             headers: valid_headers.merge("Authorization" => "InvalidFormat")

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "Unauthorized" })
      end

      it "accepts requests with valid token" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "initialize",
               id: 1,
               params: {
                 protocolVersion: "2025-06-18"
               }
             }.to_json,
             headers: valid_headers.except("MCP-Protocol-Version")

        expect(response).to have_http_status(:ok)
      end
    end

    context "when validating Accept header" do
      it "rejects requests without proper Accept header" do
        post "/mcp",
             params: { jsonrpc: "2.0", method: "initialize", id: 1 }.to_json,
             headers: valid_headers.merge("Accept" => "application/json")

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_600)
        expect(body["error"]["message"]).to include("Accept header")
      end

      it "accepts requests with both application/json and text/event-stream" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "initialize",
               id: 1,
               params: {
                 protocolVersion: "2025-06-18"
               }
             }.to_json,
             headers: valid_headers.except("MCP-Protocol-Version")

        expect(response).to have_http_status(:ok)
      end
    end

    context "when validating protocol version" do
      it "allows initialize without MCP-Protocol-Version header" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "initialize",
               id: 1,
               params: {
                 protocolVersion: "2025-06-18"
               }
             }.to_json,
             headers: valid_headers.except("MCP-Protocol-Version")

        expect(response).to have_http_status(:ok)
      end

      it "rejects non-initialize requests without MCP-Protocol-Version header" do
        post "/mcp",
             params: { jsonrpc: "2.0", method: "resources/list", id: 1 }.to_json,
             headers: valid_headers.except("MCP-Protocol-Version")

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_600)
        expect(body["error"]["message"]).to include("MCP-Protocol-Version header is required")
      end

      it "rejects requests with unsupported protocol version" do
        post "/mcp",
             params: { jsonrpc: "2.0", method: "resources/list", id: 1 }.to_json,
             headers: valid_headers.merge("MCP-Protocol-Version" => "2024-01-01")

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_600)
        expect(body["error"]["message"]).to include("Unsupported MCP protocol version")
      end

      it "accepts requests with correct protocol version" do
        post "/mcp",
             params: { jsonrpc: "2.0", method: "resources/list", id: 1 }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:ok)
      end
    end

    context "with JSON-RPC parse errors" do
      it "returns parse error for invalid JSON" do
        post "/mcp",
             params: "invalid json{",
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_700)
        expect(body["error"]["message"]).to eq("Parse error")
      end
    end

    context "with JSON-RPC validation errors" do
      it "returns error for missing jsonrpc field" do
        post "/mcp",
             params: { method: "initialize", id: 1 }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_600)
        expect(body["error"]["message"]).to eq("Invalid Request")
      end

      it "returns error for invalid jsonrpc version" do
        post "/mcp",
             params: { jsonrpc: "1.0", method: "initialize", id: 1 }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_600)
      end

      it "returns error for missing method field" do
        post "/mcp",
             params: { jsonrpc: "2.0", id: 1 }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_600)
      end
    end

    context "with initialize flow" do
      it "successfully handles initialize request" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "initialize",
               id: 1,
               params: {
                 protocolVersion: "2025-06-18",
                 capabilities: {},
                 clientInfo: {
                   name: "test-client",
                   version: "1.0.0"
                 }
               }
             }.to_json,
             headers: valid_headers.except("MCP-Protocol-Version")

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["jsonrpc"]).to eq("2.0")
        expect(body["id"]).to eq(1)
        expect(body["result"]).to be_a(Hash)
        expect(body["result"]["protocolVersion"]).to eq("2025-06-18")
        expect(body["result"]["serverInfo"]).to be_a(Hash)
        expect(body["result"]["capabilities"]).to be_a(Hash)
      end

      it "returns error when protocolVersion is missing" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "initialize",
               id: 1,
               params: {}
             }.to_json,
             headers: valid_headers.except("MCP-Protocol-Version")

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to include("protocolVersion is required")
      end
    end

    context "with initialized notification" do
      it "successfully handles initialized notification" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "notifications/initialized",
               params: {}
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:accepted)
        expect(response.body).to be_empty
      end
    end

    context "with resources/list" do
      it "successfully lists resources" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "resources/list",
               id: 2
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["jsonrpc"]).to eq("2.0")
        expect(body["id"]).to eq(2)
        expect(body["result"]).to be_a(Hash)
        expect(body["result"]["resources"]).to be_an(Array)
      end
    end

    context "with resources/read" do
      let!(:task) { create(:task) }

      it "successfully reads a task resource" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "resources/read",
               id: 3,
               params: {
                 uri: "quicksilver://tasks/#{task.id}"
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["jsonrpc"]).to eq("2.0")
        expect(body["id"]).to eq(3)
        expect(body["result"]).to be_a(Hash)
        expect(body["result"]["contents"]).to be_an(Array)
        expect(body["result"]["contents"].first["uri"]).to eq("quicksilver://tasks/#{task.id}")
        expect(body["result"]["contents"].first["mimeType"]).to eq("application/json")
      end

      it "returns error for missing uri parameter" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "resources/read",
               id: 3,
               params: {}
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to include("uri is required")
      end

      it "returns error for invalid URI format" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "resources/read",
               id: 3,
               params: {
                 uri: "quicksilver://nonexistent"
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to include("Unknown resource URI")
      end

      it "returns not found for nonexistent task ID" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "resources/read",
               id: 3,
               params: {
                 uri: "quicksilver://tasks/99999"
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_002)
        expect(body["error"]["message"]).to include("Resource not found")
      end
    end

    context "with tools/list" do
      it "successfully lists tools" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "tools/list",
               id: 4
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["jsonrpc"]).to eq("2.0")
        expect(body["id"]).to eq(4)
        expect(body["result"]).to be_a(Hash)
        expect(body["result"]["tools"]).to be_an(Array)
      end
    end

    context "with tools/call" do
      it "successfully calls create_task tool" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "tools/call",
               id: 5,
               params: {
                 name: "create_task",
                 arguments: {
                   title: "Test Task"
                 }
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["jsonrpc"]).to eq("2.0")
        expect(body["id"]).to eq(5)
        expect(body["result"]).to be_a(Hash)
        expect(body["result"]["content"]).to be_an(Array)
        expect(body["result"]["content"].first["type"]).to eq("text")
      end

      it "successfully calls update_task tool" do
        task = create(:task)

        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "tools/call",
               id: 5,
               params: {
                 name: "update_task",
                 arguments: {
                   id: task.id.to_s,
                   title: "Updated Title"
                 }
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["result"]["content"]).to be_an(Array)
      end

      it "successfully calls complete_task tool" do
        task = create(:task)

        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "tools/call",
               id: 5,
               params: {
                 name: "complete_task",
                 arguments: {
                   id: task.id.to_s
                 }
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["result"]["content"]).to be_an(Array)
      end

      it "returns error for missing tool name" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "tools/call",
               id: 5,
               params: {
                 arguments: {}
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to include("name is required")
      end

      it "returns error for unknown tool" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "tools/call",
               id: 5,
               params: {
                 name: "unknown_tool",
                 arguments: {}
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to include("Unknown tool")
      end

      it "returns error for missing required tool arguments" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "tools/call",
               id: 5,
               params: {
                 name: "create_task",
                 arguments: {}
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to include("title is required")
      end
    end

    context "when method not found" do
      it "returns error for unknown method" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "unknown/method",
               id: 6
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_601)
        expect(body["error"]["message"]).to eq("Method not found")
      end
    end

    context "with error code mapping" do
      it "maps parse error (-32700) to bad_request status" do
        post "/mcp",
             params: "invalid json",
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_700)
      end

      it "maps invalid request (-32600) to bad_request status" do
        post "/mcp",
             params: { method: "test" }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_600)
      end

      it "maps invalid params (-32602) to bad_request status" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "resources/read",
               id: 1,
               params: {}
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
      end

      it "maps resource not found (-32002) to not_found status" do
        post "/mcp",
             params: {
               jsonrpc: "2.0",
               method: "resources/read",
               id: 1,
               params: {
                 uri: "quicksilver://tasks/99999"
               }
             }.to_json,
             headers: valid_headers

        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_002)
      end
    end
  end
end
