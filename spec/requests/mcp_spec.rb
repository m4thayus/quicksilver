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
  let(:engineer) { create(:engineer_user) }

  before do
    allow(Rails.application.credentials).to receive(:mcp_auth_token).and_return(valid_token)
  end

  def engineer_headers
    valid_headers.merge("X-Quicksilver-User-Email" => engineer.email)
  end

  def post_tool_call(name, arguments: {}, headers: valid_headers, id: 1)
    post "/mcp",
         params: { jsonrpc: "2.0", method: "tools/call", id:, params: { name:, arguments: } }.to_json,
         headers:
  end

  def tool_result
    JSON.parse(JSON.parse(response.body).dig("result", "content", 0, "text"))
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

      it "lists the workflow tools" do
        post "/mcp",
             params: { jsonrpc: "2.0", method: "tools/list", id: 4 }.to_json,
             headers: valid_headers

        names = JSON.parse(response.body).dig("result", "tools").map { |t| t["name"] }
        expect(names).to include(
          "available_work", "proposed_work", "claim_task", "accept_task", "list_tasks"
        )
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
             headers: engineer_headers

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
             headers: engineer_headers

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
             headers: engineer_headers

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
             headers: engineer_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to include("title is required")
      end
    end

    context "with identity-gated mutations" do
      it "rejects create_task without an identity header" do
        post_tool_call("create_task", arguments: { title: "X" }, headers: valid_headers)

        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_003)
        expect(body["error"]["data"]).to eq("identity required")
      end

      it "rejects mutations from an unknown email as identity required" do
        task = create(:task)
        post_tool_call("update_task",
                       arguments: { id: task.id, title: "X" },
                       headers: valid_headers.merge("X-Quicksilver-User-Email" => "ghost@example.test"))

        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_003)
        expect(body["error"]["data"]).to eq("identity required")
      end

      it "rejects mutations from a resolved non-engineer as not authorized" do
        guest = create(:guest_user)
        task = create(:task)
        post_tool_call("complete_task",
                       arguments: { id: task.id },
                       headers: valid_headers.merge("X-Quicksilver-User-Email" => guest.email))

        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_003)
        expect(body["error"]["data"]).to eq("not authorized")
      end

      it "allows mutations from a resolved engineer" do
        post_tool_call("create_task", arguments: { title: "Engineer task" }, headers: engineer_headers)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["result"]["content"]).to be_an(Array)
      end

      it "allows mutations from a resolved admin" do
        admin = create(:admin_user)
        post_tool_call("create_task",
                       arguments: { title: "Admin task" },
                       headers: valid_headers.merge("X-Quicksilver-User-Email" => admin.email))

        expect(response).to have_http_status(:ok)
      end
    end

    context "with available_work tool" do
      it "returns backlog available tasks in size order without requiring identity" do
        medium = create(:task, board: nil, size: "medium", started_at: nil, completed_at: nil)
        small = create(:task, board: nil, size: "small", started_at: nil, completed_at: nil)
        unsized = create(:task, board: nil, size: nil, started_at: nil, completed_at: nil)
        large = create(:task, board: nil, size: "large", started_at: nil, completed_at: nil)
        create(:task, board: create(:board), size: "small", started_at: nil, completed_at: nil)
        create(:task, board: nil, size: "small", started_at: 1.day.ago, completed_at: nil)
        create(:task, board: nil, size: "small", started_at: nil, completed_at: 1.day.ago)

        post_tool_call("available_work", headers: valid_headers)

        expect(response).to have_http_status(:ok)
        tasks = JSON.parse(JSON.parse(response.body).dig("result", "content", 0, "text"))["tasks"]
        expect(tasks.map { |t| t["id"] }).to eq([unsized.id, small.id, medium.id, large.id])
        expect(tasks.first).to include("title", "description", "priority", "size", "expected_at")
      end
    end

    context "with proposed_work tool" do
      it "returns approved wishlist tasks in priority order without requiring identity" do
        wishlist = create(:wishlist)
        high = create(:task, board: wishlist, approved: true, priority: 9)
        low = create(:task, board: wishlist, approved: true, priority: 1)
        create(:task, board: wishlist, approved: false, priority: 10)
        create(:task, board: nil, approved: true, priority: 5)

        post_tool_call("proposed_work", headers: valid_headers)

        expect(response).to have_http_status(:ok)
        tasks = JSON.parse(JSON.parse(response.body).dig("result", "content", 0, "text"))["tasks"]
        expect(tasks.map { |t| t["id"] }).to eq([high.id, low.id])
        expect(tasks.first).to include("title", "description", "priority", "size")
      end
    end

    context "with claim_task tool" do
      it "claims an available task by setting owner and started_at atomically" do
        task = create(:task, owner: nil, started_at: nil, completed_at: nil)

        post_tool_call("claim_task", arguments: { id: task.id }, headers: engineer_headers)

        expect(response).to have_http_status(:ok)
        payload = JSON.parse(JSON.parse(response.body).dig("result", "content", 0, "text"))
        expect(payload["uri"]).to eq("quicksilver://tasks/#{task.id}")
        expect(payload["task"]["owner_id"]).to eq(engineer.id)
        expect(payload["task"]["started_at"]).to eq(Date.current.iso8601)
        expect(task.reload.owner_id).to eq(engineer.id)
        expect(task.started_at).to eq(Date.current)
      end

      it "rejects claiming a task that is already started" do
        task = create(:task, owner: nil, started_at: 1.day.ago, completed_at: nil)

        post_tool_call("claim_task", arguments: { id: task.id }, headers: engineer_headers)

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to match(/already started/i)
      end

      it "rejects claiming a task owned by another user" do
        task = create(:task, owner: create(:user), started_at: nil, completed_at: nil)

        post_tool_call("claim_task", arguments: { id: task.id }, headers: engineer_headers)

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq(-32_602)
        expect(body["error"]["message"]).to match(/another user/i)
      end

      it "returns not found when claiming a nonexistent task" do
        post_tool_call("claim_task", arguments: { id: 999_999 }, headers: engineer_headers)

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body).dig("error", "code")).to eq(-32_002)
      end

      it "rejects claim_task from a resolved non-engineer" do
        guest = create(:guest_user)
        task = create(:task, owner: nil, started_at: nil, completed_at: nil)

        post_tool_call("claim_task",
                       arguments: { id: task.id },
                       headers: valid_headers.merge("X-Quicksilver-User-Email" => guest.email))

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body).dig("error", "code")).to eq(-32_003)
      end
    end

    context "with accept_task tool" do
      it "moves a proposed task onto the backlog and clears approved" do
        wishlist = create(:wishlist)
        task = create(:task, board: wishlist, approved: true)

        post_tool_call("accept_task", arguments: { id: task.id }, headers: engineer_headers)

        expect(response).to have_http_status(:ok)
        payload = JSON.parse(JSON.parse(response.body).dig("result", "content", 0, "text"))
        expect(payload["uri"]).to eq("quicksilver://tasks/#{task.id}")
        expect(payload["task"]["board_id"]).to be_nil
        expect(payload["task"]["approved"]).to be(false)
        task.reload
        expect(task.board_id).to be_nil
        expect(task.approved).to be(false)
      end

      it "rejects accept_task from a resolved non-engineer" do
        guest = create(:guest_user)
        task = create(:task, board: create(:wishlist), approved: true)

        post_tool_call("accept_task",
                       arguments: { id: task.id },
                       headers: valid_headers.merge("X-Quicksilver-User-Email" => guest.email))

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body).dig("error", "code")).to eq(-32_003)
      end
    end

    context "with list_tasks tool" do
      it "answers 'what am I working on' via owner: me and status: active" do
        mine = create(:task, owner: engineer, started_at: 1.day.ago, completed_at: nil)
        create(:task, owner: engineer, started_at: 1.day.ago, completed_at: 1.day.ago)
        create(:task, owner: create(:user), started_at: 1.day.ago, completed_at: nil)

        post_tool_call("list_tasks", arguments: { owner: "me", status: "active" }, headers: engineer_headers)

        expect(response).to have_http_status(:ok)
        expect(tool_result["tasks"].map { |t| t["id"] }).to contain_exactly(mine.id)
      end

      it "filters by board name" do
        on_wishlist = create(:task, board: create(:wishlist))
        create(:task, board: nil)

        post_tool_call("list_tasks", arguments: { board: "wishlist" }, headers: valid_headers)

        expect(tool_result["tasks"].map { |t| t["id"] }).to contain_exactly(on_wishlist.id)
      end

      it "filters to the backlog when board is null" do
        backlog_task = create(:task, board: nil)
        create(:task, board: create(:wishlist))

        post_tool_call("list_tasks", arguments: { board: nil }, headers: valid_headers)

        expect(tool_result["tasks"].map { |t| t["id"] }).to contain_exactly(backlog_task.id)
      end

      it "filters by owner email" do
        owner = create(:user)
        theirs = create(:task, owner:)
        create(:task, owner: create(:user))

        post_tool_call("list_tasks", arguments: { owner: owner.email }, headers: valid_headers)

        expect(tool_result["tasks"].map { |t| t["id"] }).to contain_exactly(theirs.id)
      end

      it "respects the limit argument" do
        create_list(:task, 3, board: nil)

        post_tool_call("list_tasks", arguments: { board: nil, limit: 1 }, headers: valid_headers)

        expect(tool_result["tasks"].size).to eq(1)
      end

      it "rejects owner: me without an identified user" do
        post_tool_call("list_tasks", arguments: { owner: "me" }, headers: valid_headers)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body).dig("error", "code")).to eq(-32_602)
      end

      it "rejects an unknown status" do
        post_tool_call("list_tasks", arguments: { status: "bogus" }, headers: valid_headers)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body).dig("error", "code")).to eq(-32_602)
      end

      it "rejects an unknown board name" do
        post_tool_call("list_tasks", arguments: { board: "nonexistent" }, headers: valid_headers)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body).dig("error", "code")).to eq(-32_602)
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
