---
name: search-first
description: Use when about to implement new functionality, add a dependency, or create a utility — before writing any code. Invoke before implementing ANY new functionality, even trivial utilities. Check if a library already does this before writing a single line.
---

# Search First

## Overview

The fastest code to write is code you don't write. Before implementing anything, spend 5-10 minutes searching for existing solutions. Most "new" problems have been solved: as a library, an MCP server, a Claude skill, or a reference implementation.

**Core principle:** Define the need → search in parallel → evaluate candidates → decide (adopt / extend / compose / build) → only then implement.

---

## When to Trigger This Skill

Trigger search-first when you are about to:
- Start a new feature that likely has existing solutions
- Add a new dependency or integration point
- Create a utility function, helper, or abstraction
- Implement a data format, protocol, or algorithm
- Respond to "add X functionality" without having searched first

**Do NOT wait to be asked.** If you're about to write non-trivial code, search first.

---

## The Workflow

```
1. NEED ANALYSIS
   Define what is needed precisely
   Identify language/framework constraints
          ↓
2. PARALLEL SEARCH
   ┌──────────────┬──────────────┬──────────────┐
   │  Package     │  MCP /       │  GitHub /    │
   │  Registry    │  Skills      │  Web         │
   │  (npm/PyPI)  │  Catalog     │  Search      │
   └──────────────┴──────────────┴──────────────┘
          ↓
3. EVALUATE
   Score each candidate:
   - Functionality match (does it do what's needed?)
   - Maintenance status (last commit, open issues)
   - Community (downloads/week, stars)
   - Documentation quality
   - License (MIT/Apache = free, GPL = careful)
   - Dependency count (heavy dependencies = risk)
          ↓
4. DECIDE
   Adopt / Extend / Compose / Build
          ↓
5. IMPLEMENT
   Minimal integration, not from scratch
```

---

## Decision Matrix

| Signal | Action |
|--------|--------|
| Exact match, well-maintained, MIT/Apache license | **Adopt** — install and use directly |
| Partial match, good foundation | **Extend** — install + thin wrapper |
| Multiple partial matches | **Compose** — combine 2-3 small packages |
| Nothing suitable found | **Build** — informed by research, document why |

### Adopt criteria
- Does at least 80% of what you need
- Active maintenance (commit within 6 months)
- Weekly downloads > 10k (npm) or 100k (PyPI) — community pressure keeps it maintained
- Permissive license (MIT, Apache, BSD)

### When to Build
Only build custom when:
- No suitable library exists (documented search confirms this)
- The requirement is so specific that any library would need to be rewritten anyway
- The dependency would be larger than the code you'd write
- Security requirements prohibit external dependencies

---

## Search Checklist (Quick Mode)

Before writing any utility or adding functionality, run through this sequence:

1. **Does this already exist in the repo?**
   ```bash
   # Search for existing implementations
   rg "parseDate\|formatDate\|DateUtils" src/
   ```

2. **Is this a common problem?**
   - npm: `npm search <keywords>`
   - PyPI: `pip search <keywords>` or search pypi.org
   - Cargo: `cargo search <keywords>`

3. **Is there an MCP for this?**
   - Check active MCPs in your environment
   - Search MCP registries for the capability

4. **Is there a Claude skill for this?**
   - Check `~/.claude/skills/` catalog

5. **Is there a GitHub implementation?**
   - Search GitHub for the pattern
   - Look for maintained OSS before writing net-new code

---

## Search Shortcuts by Category

### Development Tooling
| Need | Search term |
|------|-------------|
| Linting | `eslint`, `ruff`, `markdownlint` |
| Formatting | `prettier`, `black`, `gofmt` |
| Pre-commit hooks | `husky`, `lint-staged`, `pre-commit` |
| Build tools | `vite`, `esbuild`, `turbo` |

### AI / LLM Integration
| Need | Search term |
|------|-------------|
| Claude SDK | Check Context7 for latest docs |
| Prompt management | MCP servers first |
| Document processing | `unstructured`, `pdfplumber`, `mammoth` |
| Embeddings | `sentence-transformers`, `langchain` |

### Data & APIs
| Need | Search term |
|------|-------------|
| HTTP client | `httpx` (Python), `ky`/`got` (Node) |
| Validation | `zod` (TS), `pydantic` (Python) |
| Date handling | `date-fns`, `dayjs` (Node), `arrow` (Python) |
| Database | Check for MCP server first |

### Content Processing
| Need | Search term |
|------|-------------|
| Markdown | `remark`, `unified`, `markdown-it` |
| PDF | `pdf-parse`, `pdfplumber` |
| CSV/Excel | `papaparse`, `openpyxl` |
| Image | `sharp` (Node), `Pillow` (Python) |

---

## Full Mode (Researcher Agent)

For non-trivial decisions, delegate to a researcher subagent:

```
Task(
  subagent_type="general-purpose",
  prompt="""
  Research existing tools for: [DESCRIPTION]
  Language/framework: [LANG]
  Constraints: [ANY CONSTRAINTS]

  Search these sources:
  - npm/PyPI/Cargo registry
  - MCP server registries
  - GitHub (maintained OSS)
  - Claude Code skills catalog

  Return a structured comparison:
  - Top 3 candidates with scores (functionality, maintenance, license, deps)
  - Recommendation: Adopt / Extend / Compose / Build
  - Reasoning for recommendation
  """
)
```

---

## Documenting the Decision

When you decide to Build (no existing solution), document it:

```markdown
## Why we built custom instead of adopting a library

**Need:** [Description of requirement]
**Date searched:** [Date]
**Candidates evaluated:**
- [Library A] — [reason rejected]
- [Library B] — [reason rejected]

**Decision:** Build custom because [reason].
```

This prevents future developers (or future you) from repeating the same research.

---

## Anti-Patterns

- **Jumping to code:** Starting to implement before searching. The most common and most expensive mistake.
- **Ignoring MCP:** Not checking if an MCP server already provides the exact capability needed.
- **Search theater:** Running one search with poor keywords, finding nothing, declaring "nothing exists." A valid search checks: existing project code, stdlib, and the package registry. All three.
- **Ignoring your own findings:** Completing the search workflow, discovering a better option, then silently proceeding with the original plan anyway. The search result is the input to the decision — not a formality to get past.
- **Over-customizing:** Wrapping a library so heavily that it loses its benefits and becomes harder to upgrade.
- **Dependency bloat:** Installing a 500kb library for one 20-line function.
- **Ignoring license:** Using GPL code in a commercial project without checking implications.

---

## Hard Rules

- **Search before writing.** This is the rule, not a suggestion.
- **Search the project first, then the ecosystem.** Always check existing dependencies and utilities before searching external registries. Adding a duplicate of what's already installed is worse than not searching at all.
- **A valid search covers all three:** (1) existing project dependencies/utilities, (2) the language standard library, (3) the primary package registry. One weak query with no results is not a valid search — it's search theater.
- **Surface findings before proceeding.** If search reveals a recommended solution is deprecated, has known issues, or is superseded by a better option, report this before adopting. Do not silently install a library the workflow flagged as suboptimal.
- **Document "build" decisions.** If you searched and found nothing, record what you searched for and why you built.
- **Check the license.** Before adopting, confirm the license is compatible with the project.
- **Prefer small, focused packages.** A package that does one thing well beats a large framework for a small need.
