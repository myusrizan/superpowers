---
name: mcp-builder
description: Use when building a new MCP server — to design tools, implement handlers, and register the server with Claude Code, Desktop, or Cursor. Invoke when the user wants to "build an MCP server", "create MCP tools", or "expose X as an MCP tool".
---

# MCP Builder

## Overview

Build custom MCP (Model Context Protocol) servers that expose tools to Claude. This skill covers the full lifecycle: design → implement → test → register.

**Core principle:** Each MCP tool does one thing and reports clearly. Tools that do too much are tools that fail unpredictably.

---

## Tool Design

Before writing code, define each tool:

```markdown
Tool: <name>
Description: <one sentence — what it does and when to use it>
Input schema:
  - param1 (string, required): what it is
  - param2 (integer, optional, default: 10): what it is
Returns: <what success looks like>
Errors: <what failure looks like and why>
```

**Rules:**
- Tool names: `verb_noun` format (`get_user`, `create_post`, `search_files`)
- Descriptions are how Claude decides to call the tool — be specific about conditions
- Every tool returns structured JSON — never raw strings
- Every tool handles errors and returns a typed error object

---

## Implementation with FastMCP

```python
# server.py
from fastmcp import FastMCP
import json

mcp = FastMCP("my-server")

@mcp.tool()
def get_user(user_id: str) -> dict:
    """
    Fetch a user's profile by ID.
    Returns the user's name, email, and role.
    Use when you need user details for a given ID.
    """
    # Implementation
    user = db.get_user(user_id)
    if not user:
        return {"error": "not_found", "message": f"User {user_id} not found"}
    return {"id": user.id, "name": user.name, "email": user.email}

@mcp.tool()
def search_files(query: str, max_results: int = 10) -> dict:
    """
    Search project files for a query string.
    Returns matching files with line numbers and snippets.
    """
    results = search(query, limit=max_results)
    return {
        "query": query,
        "count": len(results),
        "results": [{"file": r.path, "line": r.line, "snippet": r.text} for r in results]
    }

if __name__ == "__main__":
    mcp.run()
```

---

## Implementation with TypeScript SDK

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js"
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js"
import { z } from "zod"

const server = new McpServer({ name: "my-server", version: "1.0.0" })

server.tool(
  "get_user",
  "Fetch a user profile by ID. Returns name, email, and role.",
  { user_id: z.string().describe("The user's unique identifier") },
  async ({ user_id }) => {
    const user = await db.getUser(user_id)
    if (!user) {
      return { content: [{ type: "text", text: JSON.stringify({ error: "not_found" }) }] }
    }
    return {
      content: [{ type: "text", text: JSON.stringify({ id: user.id, name: user.name }) }]
    }
  }
)

const transport = new StdioServerTransport()
await server.connect(transport)
```

---

## Testing

Test each tool in isolation before registering:

```bash
# Python — run the server and call tools via stdin
echo '{"tool": "get_user", "params": {"user_id": "123"}}' | python server.py

# Or use MCP inspector
npx @modelcontextprotocol/inspector python server.py
```

**Test checklist:**
- [ ] Each tool returns expected output for valid input
- [ ] Each tool returns a typed error for invalid input
- [ ] Tools handle missing optional parameters (use defaults)
- [ ] Tools handle empty results (return empty array, not null)
- [ ] Server starts without errors

---

## Registration

### Claude Code

```json
// ~/.claude/claude_code_config.json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["/absolute/path/to/server.py"],
      "env": {
        "MY_API_KEY": "..."
      }
    }
  }
}
```

### Claude Desktop

```json
// ~/Library/Application Support/Claude/claude_desktop_config.json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["/absolute/path/to/server.py"]
    }
  }
}
```

### Verify registration

After adding config, restart Claude and ask:
> "What MCP tools are available?" or "List your tools"

---

## Differences from `agents/mcp-server`

This skill focuses on the **building workflow**: design → implement → test → register.
The `mcp-server` skill in `agents/` covers the **reference architecture** and patterns.

Use this skill when **actively building** a new MCP server.
Use `agents/mcp-server` when **reviewing patterns** or understanding MCP architecture.

---

## Hard Rules

- **One tool, one responsibility.** Tools that do multiple things fail confusingly.
- **Return JSON, not text.** Structured output lets Claude parse and act reliably.
- **Handle all error cases explicitly.** Never let a tool raise an unhandled exception.
- **Absolute paths in registration config.** Relative paths break when Claude starts from a different directory.
- **Test before registering.** A broken MCP server that's registered will fail silently in production.
