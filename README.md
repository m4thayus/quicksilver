# Quicksilver

A task management system with MCP (Model Context Protocol) interface support.

## Features

- Task and board management
- MCP server interface for AI agent integration
- RESTful web interface

## MCP Interface

Quicksilver provides an MCP server endpoint for programmatic access to tasks and boards. See the [MCP Documentation](docs/MCP.md) for detailed information about:

- Authentication setup
- Available methods and endpoints
- Request/response examples
- Error codes

## Development Setup

```bash
# Install dependencies
bin/setup

# Start the development server
bin/dev

# Run tests
bin/rspec
```

## Configuration

Set the MCP authentication token:

```bash
export MCP_AUTH_TOKEN="your-secret-token"
```

## Documentation

- [MCP Interface Documentation](docs/MCP.md)
