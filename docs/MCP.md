# MCP (Model Context Protocol) Interface

Quicksilver provides an MCP server interface for programmatic access to tasks and boards. The MCP protocol is a JSON-RPC 2.0 based protocol for AI agents and tools to interact with application data.

## Table of Contents

- [Authentication](#authentication)
- [Required Headers](#required-headers)
- [Protocol Version](#protocol-version)
- [Endpoints](#endpoints)
- [Methods](#methods)
  - [Initialize](#initialize)
  - [Initialized Notification](#initialized-notification)
  - [List Resources](#list-resources)
  - [Read Resource](#read-resource)
  - [List Tools](#list-tools)
  - [Call Tool](#call-tool)
- [Error Codes](#error-codes)

## Authentication

The MCP interface requires bearer token authentication. Configure the authentication token in Rails credentials:

```bash
# Edit credentials (use EDITOR=vim or your preferred editor)
EDITOR=nano bin/rails credentials:edit
```

Add the MCP auth token to your credentials file:

```yaml
mcp_auth_token: your-secret-token
```

All requests must include this token in the `Authorization` header:

```
Authorization: Bearer your-secret-token
```

## Required Headers

Every MCP request must include the following headers:

```
Authorization: Bearer <token>
Accept: application/json, text/event-stream
Content-Type: application/json
```

For all methods except `initialize`, you must also include:

```
MCP-Protocol-Version: 2025-06-18
```

## Protocol Version

Quicksilver implements MCP protocol version `2025-06-18`. This version must be specified in the `MCP-Protocol-Version` header for all requests except the initial `initialize` handshake.

## Endpoints

- **POST /mcp** - All MCP JSON-RPC requests
- **GET /mcp** - Returns 405 Method Not Allowed

## Methods

### Initialize

Establishes a connection with the MCP server. This is the first method that should be called.

**Request:**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "initialize",
    "id": 1,
    "params": {
      "protocolVersion": "2025-06-18",
      "capabilities": {},
      "clientInfo": {
        "name": "my-client",
        "version": "1.0.0"
      }
    }
  }'
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2025-06-18",
    "serverInfo": {
      "name": "quicksilver-mcp",
      "version": "0.1.0"
    },
    "capabilities": {
      "resources": {},
      "tools": {}
    }
  }
}
```

### Initialized Notification

Sent by the client after receiving the initialize response. This is a notification (no `id` field) and receives no response.

**Request:**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "notifications/initialized",
    "params": {}
  }'
```

**Response:**

HTTP 202 Accepted (empty body)

### List Resources

Returns a list of all available resources (tasks and boards).

**Request:**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "resources/list",
    "id": 2
  }'
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "resources": [
      {
        "uri": "quicksilver://tasks/1",
        "name": "Task 1: Fix bug in login",
        "mimeType": "application/json",
        "description": "Users cannot log in with special characters"
      },
      {
        "uri": "quicksilver://boards/1",
        "name": "Board 1: Development",
        "mimeType": "application/json",
        "description": "Board Development"
      }
    ],
    "nextCursor": null
  }
}
```

### Read Resource

Retrieves detailed information about a specific resource by URI.

**Request (Task):**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "resources/read",
    "id": 3,
    "params": {
      "uri": "quicksilver://tasks/1"
    }
  }'
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "contents": [
      {
        "uri": "quicksilver://tasks/1",
        "mimeType": "application/json",
        "text": "{\"id\":1,\"title\":\"Fix bug in login\",\"description\":\"Users cannot log in\",\"status\":\"open\",\"size\":\"medium\",\"priority\":2,\"board_id\":1,\"owner_id\":1,\"approved\":false,\"started_at\":null,\"expected_at\":null,\"completed_at\":null,\"created_at\":\"2025-01-14T10:00:00Z\",\"updated_at\":\"2025-01-14T10:00:00Z\"}"
      }
    ]
  }
}
```

**Request (Board):**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "resources/read",
    "id": 4,
    "params": {
      "uri": "quicksilver://boards/1"
    }
  }'
```

**URI Format:**

- Tasks: `quicksilver://tasks/{id}`
- Boards: `quicksilver://boards/{id}`

### List Tools

Returns a list of all available tools (actions) that can be performed.

**Request:**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/list",
    "id": 5
  }'
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "result": {
    "tools": [
      {
        "name": "create_task",
        "description": "Create a new task.",
        "inputSchema": {
          "type": "object",
          "properties": {
            "title": { "type": "string" },
            "description": { "type": "string" },
            "board_id": { "type": "integer" },
            "owner_id": { "type": "integer" },
            "size": { "type": "string" },
            "priority": { "type": "integer" }
          },
          "required": ["title"]
        }
      },
      {
        "name": "update_task",
        "description": "Update an existing task.",
        "inputSchema": {
          "type": "object",
          "properties": {
            "id": { "type": "integer" },
            "title": { "type": "string" },
            "description": { "type": "string" },
            "board_id": { "type": "integer" },
            "owner_id": { "type": "integer" },
            "size": { "type": "string" },
            "priority": { "type": "integer" },
            "status": { "type": "string" },
            "approved": { "type": "boolean" }
          },
          "required": ["id"]
        }
      },
      {
        "name": "complete_task",
        "description": "Mark a task as completed (sets completed_at).",
        "inputSchema": {
          "type": "object",
          "properties": {
            "id": { "type": "integer" },
            "completed_at": {
              "type": "string",
              "description": "ISO8601 date (optional)."
            }
          },
          "required": ["id"]
        }
      }
    ]
  }
}
```

### Call Tool

Executes a tool with the specified arguments.

#### Create Task

**Request:**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 6,
    "params": {
      "name": "create_task",
      "arguments": {
        "title": "Implement new feature",
        "description": "Add dark mode support",
        "board_id": 1,
        "priority": 2
      }
    }
  }'
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"uri\":\"quicksilver://tasks/42\",\"task\":{\"id\":42,\"title\":\"Implement new feature\",\"description\":\"Add dark mode support\",\"status\":null,\"size\":null,\"priority\":2,\"board_id\":1,\"owner_id\":null,\"approved\":false,\"started_at\":null,\"expected_at\":null,\"completed_at\":null,\"created_at\":\"2025-01-14T10:30:00Z\",\"updated_at\":\"2025-01-14T10:30:00Z\"}}"
      }
    ]
  }
}
```

#### Update Task

**Request:**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 7,
    "params": {
      "name": "update_task",
      "arguments": {
        "id": 42,
        "status": "in_progress",
        "owner_id": 1
      }
    }
  }'
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 7,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"uri\":\"quicksilver://tasks/42\",\"task\":{...}}"
      }
    ]
  }
}
```

#### Complete Task

**Request:**

```bash
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 8,
    "params": {
      "name": "complete_task",
      "arguments": {
        "id": 42,
        "completed_at": "2025-01-14"
      }
    }
  }'
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 8,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"uri\":\"quicksilver://tasks/42\",\"task\":{...\"completed_at\":\"2025-01-14\"}}"
      }
    ]
  }
}
```

## Error Codes

The MCP interface uses standard JSON-RPC 2.0 error codes:

| Code    | Name                | Description                                           | HTTP Status |
|---------|---------------------|-------------------------------------------------------|-------------|
| -32700  | Parse Error         | Invalid JSON was received                             | 400         |
| -32600  | Invalid Request     | The JSON-RPC request is invalid                       | 400         |
| -32601  | Method Not Found    | The requested method does not exist                   | 200*        |
| -32602  | Invalid Params      | Invalid method parameters                             | 400         |
| -32002  | Resource Not Found  | The requested resource does not exist (MCP-specific)  | 404         |

*Note: Method Not Found returns HTTP 200 with an error in the JSON-RPC response body per the JSON-RPC 2.0 specification.

**Error Response Format:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32602,
    "message": "Invalid params",
    "data": "title is required"
  }
}
```

**Authentication Errors:**

Unauthorized requests (missing or invalid token) return:

```json
{
  "error": "Unauthorized"
}
```

HTTP Status: 401

**Accept Header Errors:**

Requests without the proper Accept header return:

```json
{
  "jsonrpc": "2.0",
  "id": null,
  "error": {
    "code": -32600,
    "message": "Invalid Request",
    "data": "Accept header must include application/json and text/event-stream"
  }
}
```

HTTP Status: 400

## Example Workflow

Here's a complete example of connecting to the MCP server and creating a task:

```bash
# 1. Initialize connection
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "initialize",
    "id": 1,
    "params": {
      "protocolVersion": "2025-06-18",
      "capabilities": {},
      "clientInfo": {"name": "example-client", "version": "1.0.0"}
    }
  }'

# 2. Send initialized notification
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "notifications/initialized",
    "params": {}
  }'

# 3. List available resources
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "resources/list",
    "id": 2
  }'

# 4. Create a new task
curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer your-secret-token" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 3,
    "params": {
      "name": "create_task",
      "arguments": {
        "title": "New Feature",
        "description": "Implement MCP interface"
      }
    }
  }'
```

## Development

To run the MCP server locally:

```bash
# Configure authentication token in credentials
EDITOR=nano bin/rails credentials:edit
# Add: mcp_auth_token: dev-token-123

# Start the Rails server
bin/rails server

# Server will be available at http://localhost:3000/mcp
```

## Testing

Run the MCP request specs:

```bash
RAILS_ENV=test bin/rspec spec/requests/mcp_spec.rb
```
