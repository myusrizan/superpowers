---
name: mcp-server
description: Use when building a custom MCP (Model Context Protocol) server to expose tools, data, or APIs to Claude or other MCP clients. Invoke when someone asks to "expose X as an MCP", "make Claude access my database", "build an MCP server", or wants to create custom tools accessible to Claude.
---

# MCP Server

## Overview

An MCP (Model Context Protocol) server exposes tools that Claude can call — just like the built-in file, bash, and web tools. Building one lets you give Claude structured access to your own data sources, APIs, or systems without modifying Claude itself.

**Core principle:** Build → expose → register. Once registered, Claude discovers tools automatically via the protocol.

**Before building:** Check `search-first` — an existing MCP server may already do what you need. See the MCP server registry and `claude mcp list`.

---

## When to Build vs. Use Existing

| Build a custom MCP server when | Use an existing MCP server when |
|-------------------------------|--------------------------------|
| You have proprietary data (database, internal API) | Need standard capabilities (web search, file access) |
| You need domain-specific tool logic | Public MCPs already cover the use case |
| You want Claude to access systems behind auth | No auth or specialized logic required |
| Wrapping an existing REST API for Claude | The API already has an MCP server published |

---

## Pre-Implementation: Design Each Tool

Before writing code, define every tool in a table:

```markdown
Tool: <name>
Description: <one sentence — what it does and when Claude should call it>
Input schema:
  - param1 (string, required): what it is
  - param2 (integer, optional, default: 10): what it is
Returns: <what success looks like>
Errors: <what failure looks like and why>
```

**Naming:** `verb_noun` format — `get_user`, `search_files`, `create_post`. Never vague names like `process` or `handle`.

---

## The FastMCP Pattern

> **FastMCP evolves rapidly.** Before implementing, fetch current docs via Context7:
> `mcp__context7__resolve-library-id` → search "fastmcp" → `mcp__context7__query-docs` with the library ID.

### Install

```bash
pip install fastmcp
# or
uv add fastmcp
```

### Minimal server (server.py)

```python
from fastmcp import FastMCP

mcp = FastMCP("my-server", host="127.0.0.1", port=8080)

@mcp.tool()
def search_documents(query: str) -> str:
    """Search the internal knowledge base for documents matching the query.

    Use this when the user asks about company-specific information,
    internal processes, or proprietary documentation.
    """
    results = vector_db.search(query, top_k=5)
    return format_results(results)

@mcp.tool()
def get_customer(customer_id: str) -> dict:
    """Fetch customer details by ID from the CRM.

    Returns customer name, email, account status, and recent orders.
    """
    return crm.get_customer(customer_id)

if __name__ == "__main__":
    print(f"MCP server running on {mcp.host}:{mcp.port}")
    mcp.run()
```

---

## Tool Design Principles

### Docstrings are the tool description

Claude uses the docstring to decide when to call a tool. Write it for Claude, not for Python developers:

```python
# Bad — Claude doesn't know when to use this
def get_data(id: str) -> dict:
    """Get data by ID."""
    ...

# Good — Claude understands the use case
def get_customer_order_history(customer_id: str) -> list[dict]:
    """Retrieve the full order history for a customer from the orders database.

    Use this when the user asks about past purchases, order status,
    spending history, or wants to review what a specific customer has bought.

    Returns a list of orders with date, items, total, and status.
    """
    ...
```

### Type everything

FastMCP uses type annotations to validate inputs and describe parameters to the client:

```python
@mcp.tool()
def search_with_filters(
    query: str,
    max_results: int = 10,
    date_from: str | None = None,  # ISO format: YYYY-MM-DD
    category: str | None = None
) -> list[dict]:
    """..."""
    ...
```

### Return structured data where possible

```python
# Good — Claude can reason over structure
return {
    "customer_id": "cust_123",
    "name": "Jane Doe",
    "status": "active",
    "orders_last_90_days": 4
}

# Less good — Claude has to parse text
return "Customer Jane Doe (cust_123) is active with 4 orders in last 90 days."
```

### Validate inputs inside the tool

```python
@mcp.tool()
def get_report(report_id: str, format: str = "json") -> dict:
    """..."""
    if format not in ("json", "csv", "markdown"):
        return {"error": f"Invalid format '{format}'. Use: json, csv, markdown"}
    ...
```

---

## TypeScript SDK Alternative

For TypeScript/Node.js projects:

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

## Common MCP Server Patterns

### Pattern 1: RAG search tool

```python
@mcp.tool()
def search_knowledge_base(query: str, top_k: int = 5) -> list[dict]:
    """Search the internal knowledge base using semantic similarity.

    Returns the most relevant document chunks with source metadata.
    Use this before answering questions about company-specific topics.
    """
    embedding = embed(query)
    results = vector_db.search(embedding, top_k=top_k)
    return [{"content": r.content, "source": r.source, "score": r.score} for r in results]
```

### Pattern 2: Database query wrapper

```python
@mcp.tool()
def run_safe_query(table: str, filters: dict) -> list[dict]:
    """Query the analytics database for business metrics.

    Supported tables: 'daily_sales', 'user_activity', 'product_inventory'.
    Filters are key-value pairs applied as WHERE conditions.
    """
    allowed_tables = {"daily_sales", "user_activity", "product_inventory"}
    if table not in allowed_tables:
        return {"error": f"Table '{table}' not allowed. Use: {allowed_tables}"}
    return db.query(table, filters)
```

### Pattern 3: API wrapper with error handling

```python
@mcp.tool()
def get_weather(city: str, units: str = "celsius") -> dict:
    """Get current weather conditions for a city.

    Units: 'celsius' or 'fahrenheit'.
    Returns temperature, humidity, conditions, and wind speed.
    """
    try:
        response = weather_api.get(city=city, units=units)
        return response.json()
    except WeatherAPIError as e:
        return {"error": str(e), "city": city}
```

---

## Registering with Claude

### Claude Desktop (stdio transport)

Add to `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["/absolute/path/to/server.py"]
    }
  }
}
```

### Claude Code (http transport)

```bash
claude mcp add --transport http my-server http://127.0.0.1:8080/mcp
```

For stdio:
```bash
claude mcp add my-server python /absolute/path/to/server.py
```

### Cursor IDE (http transport)

Add to Cursor MCP config:
```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["/absolute/path/to/server.py"],
      "host": "127.0.0.1",
      "port": 8080,
      "timeout": 30000
    }
  }
}
```

---

## Testing Your Server

Before registering with a client:

```bash
# Test function logic directly
python -c "from server import search_documents; print(search_documents('test query'))"

# Use the MCP inspector for protocol-level testing
npx @modelcontextprotocol/inspector python server.py
```

**Tool test checklist:**
- [ ] Each tool returns expected output for valid input
- [ ] Each tool returns a typed error for invalid input (not an exception)
- [ ] Optional parameters use their defaults when omitted
- [ ] Empty results return empty array, not null
- [ ] Server starts without errors

After registering:
1. Start a new Claude session (to reload the MCP list)
2. Ask Claude: "What tools do you have available?" — it should list your tools
3. Ask Claude to use one: "Search the knowledge base for X" — verify it calls and returns correctly

---

## Hard Rules

- **Docstrings are the API contract.** Claude's tool-calling decisions are driven entirely by docstrings. Write them for the model, not the developer.
- **Validate inputs — return errors, don't raise exceptions.** Return structured error messages instead of stack traces. Claude can handle a `{"error": "..."}` response; an exception crashes the tool call.
- **Absolute paths in config.** Relative paths in MCP config fail silently when the client starts from a different working directory.
- **One concern per tool.** A tool that does many things has a docstring that describes many things — Claude will misuse it. Split complex behavior into focused tools.
- **Never expose destructive operations without confirmation.** A tool like `delete_customer(id)` will be called when Claude thinks it's appropriate. Add a `dry_run=True` default or require explicit confirmation flags.
