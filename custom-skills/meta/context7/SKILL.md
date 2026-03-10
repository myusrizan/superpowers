---
name: context7
description: Use when you need up-to-date documentation for a library, framework, or API before implementing or troubleshooting. Invoke before using any external library — to fetch current docs instead of relying on training data, which may be outdated.
---

# Context7 — Library Documentation Fetching

## Overview

Fetch current, accurate documentation for any library or framework via the Context7 MCP server.

**Core principle:** Training data goes stale. Fetch docs before implementing — especially for APIs that change frequently.

---

## When to Use

- About to use a library you're not certain about
- Implementation is failing and you suspect an API change
- User asks "how does X work in [library]?"
- Before choosing between two libraries — fetch docs for both

---

## Process

### Step 1: Resolve the library ID

```
Use mcp__context7__resolve-library-id with:
  libraryName: "react" (or "nextjs", "supabase", "tailwind", etc.)
```

This returns the library's Context7 ID (e.g., `/facebook/react`).

### Step 2: Fetch the documentation

```
Use mcp__context7__query-docs with:
  context7CompatibleLibraryID: "/facebook/react"
  query: "useEffect dependencies array"
  tokens: 5000
```

Adjust `tokens` based on need:
- Narrow question: 2000–3000 tokens
- Broad overview: 5000–10000 tokens

### Step 3: Apply the documentation

Read the returned docs. Extract:
- The exact API signature
- Required vs. optional parameters
- Common patterns and examples
- Deprecation notices or version-specific behavior

Then implement using the documented API — not from memory.

---

## Common Libraries

| Library | Search name |
|---------|------------|
| React | "react" |
| Next.js | "nextjs" |
| Supabase | "supabase" |
| Tailwind CSS | "tailwind" |
| Prisma | "prisma" |
| tRPC | "trpc" |
| Zod | "zod" |
| Playwright | "playwright" |
| FastMCP | "fastmcp" |
| Anthropic SDK | "anthropic" |

---

## Hard Rules

- **Fetch before implementing** — especially for libraries updated frequently (Supabase, Next.js, LangChain)
- **Use the query parameter** — "fetch all docs" is too broad; query for what you actually need
- **Note the version in the docs** — if docs show a version different from what's installed, flag it
- **Don't fetch for stable, well-known primitives** — `Array.map()` doesn't need a doc fetch; `supabase.auth.signInWithOtp()` does
