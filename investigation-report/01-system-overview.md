# Custom Skills System — Part 1: System Overview

> Updated: 2026-03-10 (Session 6)

---

## Architecture

```
custom-skills/              Source of truth — edit here
  chat/                     → dist/*.zip  (upload to Claude)
    meta/
    qol/
    thinking/
  plugin/                   → skills/  (Claude Code plugin)
    agents/
    coding/
    git/
    meta/

scripts/
  build-skills.sh           Builds both outputs; auto-regenerates catalog

skills/                     Built output — Claude Code reads at runtime
  agents/
  coding/
  git/
  meta/

dist/                       Built output — upload .zip files to Claude
  *.zip

hooks/
  hooks.json                session-start hook: injects using-superpowers context
```

**Key invariant:** Never edit `skills/` or `dist/` directly. Always edit `custom-skills/`, then run `bash scripts/build-skills.sh`.

**Build commands:**
```bash
bash scripts/build-skills.sh           # build both chat and plugin (default)
bash scripts/build-skills.sh --chat    # rebuild dist/ only (after editing a chat skill)
bash scripts/build-skills.sh --plugin  # rebuild skills/ only (after editing a plugin skill)
```

---

## Skill Inventory — 51 skills total

### CHAT SKILLS (15) — `custom-skills/chat/` → `dist/`

Behavioral skills. Always-on. Upload each `dist/*.zip` to Claude directly.

#### chat/meta/ (6 skills)

| Skill | Notes |
|-------|-------|
| `md-improver` | 5-phase CLAUDE.md audit; auto-generate from codebase |
| `prompting` | Efficiency (8 patterns) + generation (save to `prompts/`) modes |
| `sensitive-data-guard` | Credential/PII detection; mandatory revocation warning |
| `session-memory` | 4 modes: observe, save, restore, consolidate |
| `skill-management` | Create + stocktake phases; absorbed `skill-creator` |
| `using-superpowers` | Catalog bootstrap; auto-generated on every build |

#### chat/qol/ (6 skills)

| Skill | Notes |
|-------|-------|
| `documenting` | READMEs, ADRs, CHANGELOG; absorbed `doc-coauthoring` |
| `documents` | PDF read/extract + Office file creation; absorbed `pdf` + `office-documents` |
| `drafting` | Messages, emails, Slack posts — point-first, tone-calibrated |
| `explaining` | Audience-calibrated explanations with layered complexity |
| `researching` | Multi-source synthesis — direct answer first, evidence, caveats |
| `summarizing` | Bullet / narrative / executive / tldr |

#### chat/thinking/ (3 skills)

| Skill | Notes |
|-------|-------|
| `decision-making` | Structured scoring: options → criteria → pre-mortem → score → commit |
| `reasoning` | First principles, pre-mortem, assumption mapping, inversion |
| `thinking-partner` | 4 modes: Opinion / Ideation / Challenge / Sounding Board |

---

### PLUGIN SKILLS (36) — `custom-skills/plugin/` → `skills/`

Task-specific workflows. On-demand. Loaded automatically by Claude Code.

#### plugin/coding/ (23 skills)

| Skill | Notes |
|-------|-------|
| `advanced-testing` | Absorbed `webapp-testing`; 3 modes: live interactive, automated E2E (Playwright POM), AI eval harness |
| `api-design` | REST: URL structure, HTTP semantics, pagination (offset vs cursor), versioning |
| `architecture-patterns` | Layered, modular monolith, hexagonal, event-driven; pattern selection guide |
| `audit-website` | Perf (Core Web Vitals), a11y (WCAG AA), SEO, code quality; graded report |
| `better-auth` | bcrypt, session cookies, JWT, OAuth 2.0, vulnerability checklist |
| `ci-cd-pipeline` | Pipeline design, caching, secrets management, deployment strategies |
| `code-review` | 3 roles: request (dispatch subagent), perform (spec + quality + excellence), receive |
| `codebase-analysis` | 2 modes: onboarding (6-layer reading order + context map), investigating (findings report) |
| `database-migrations` | Expand-contract, CONCURRENTLY indexes, batch updates, SKIP LOCKED queues |
| `dependency-management` | Add vs build decisions, pinning, lock files, vulnerability audits |
| `diagnosing` | 2 modes: systematic debugging (4-phase root cause), performance profiling |
| `feature-workflow` | 3 phases: brainstorm (design gate) → plan (bite-sized tasks) → execute (batch + checkpoints) |
| `observability` | Structured logging, metrics (counter/gauge/histogram), distributed tracing, SLO alerting |
| `planning-sessions` | Backlog prioritization + absorbed `plan-harder` adversarial mode (pre-mortem, failure analysis, devil's advocate) |
| `refactoring` | Plan first, characterization tests, one type at a time, undo on red |
| `search-first` | Research before building — rg + Context7 before writing any code |
| `security` | OWASP vulnerability review + silent failure review (empty catches, swallowed exceptions) |
| `supabase-postgres` | Schema, RLS policies, query optimization, indexing, Edge Function patterns |
| `tailwind-design-system` | Token config, CVA variant pattern, cn() helper, avoiding class sprawl |
| `test-driven-development` | RED-GREEN-REFACTOR strictly enforced |
| `typescript-advanced-types` | Generics, conditional/mapped types, template literals, discriminated unions |
| `ui-ux-design` | Absorbed `frontend-design`; industry patterns (30) + component architecture + design tokens + anti-generic-AI checklist |
| `verification-before-completion` | Evidence before claims — run it, read output, then report |

#### plugin/agents/ (7 skills)

| Skill | Notes |
|-------|-------|
| `autonomous-loops` | 5 patterns + circuit breaker + termination conditions; absorbed from ralph-claude-code |
| `dispatching-parallel-agents` | Wave-based parallel dispatch for independent tasks |
| `iterative-retrieval` | Broad dispatch → score (0–1) → refine → max 3 cycles |
| `llm-council` | Advocate + devil's advocate + neutral analyst → consensus synthesis |
| `mcp-server` | Python FastMCP + TypeScript SDK; absorbed `mcp-builder`; tool design template |
| `subagent-driven-development` | Per-task dispatch with 2-stage review (spec compliance + code quality) |
| `swarm-planner` | Large swarm coordination: AWU decomposition, wave execution, context packages |

#### plugin/git/ (4 skills)

| Skill | Notes |
|-------|-------|
| `finishing-a-development-branch` | Tests → 4 options (merge/PR/keep/discard) → worktree cleanup |
| `github-cli` | gh issue, run, release, search, repo operations; JSON output, scripting |
| `history-archaeology` | git blame, bisect, log -S pickaxe, show — read history before hypotheses |
| `using-git-worktrees` | Isolated worktrees with smart directory selection and safety verification |

#### plugin/meta/ (2 skills)

| Skill | Notes |
|-------|-------|
| `context7` | Context7 MCP: resolve library ID → query docs → apply to implementation |
| `find-skills` | skills.sh marketplace: evaluate by install count, inspect before installing |

---

## Category Balance

### Chat (15 total)

| Category | Count | Cap status |
|----------|-------|-----------|
| meta | 6 | ✅ |
| qol | 6 | ✅ |
| thinking | 3 | ✅ |

### Plugin (36 total)

| Category | Count | Cap status |
|----------|-------|-----------|
| coding | 23 | ✅ |
| agents | 7 | ✅ |
| git | 4 | ✅ |
| meta | 2 | ✅ |

Both chat (15) and plugin (36) are well under the 50-skill cap. They count against separate limits — combined total does not matter.

---

## System-Level Strengths

1. **Chat/plugin split** — Behavioral skills (always-on) separated from task workflows (on-demand); each system under 50-skill cap with headroom
2. **Catalog auto-generation** — `build-skills.sh` regenerates catalog on every build; no manual drift possible
3. **"Pushy" descriptions** — Skills have adjacent trigger phrases to compensate for Claude's undertriggering tendency
4. **Session continuity** — `session-memory` covers observe → save → restore → consolidate
5. **Meta-skills for system maintenance** — `skill-management` covers creation + stocktake; system is self-maintaining

## System-Level Risks

1. **Plugin at 36/50** — Growing toward the ceiling. Monitor before acquiring more plugin skills; build script warns at 60 (consider lowering to 50)
2. **Uneven pressure testing** — Several skills acquired in bulk; not all have been exercised in production use

## Key Invariants

- Never edit `skills/` or `dist/` directly — always edit `custom-skills/`
- Run `bash scripts/build-skills.sh` after any skill edit
- Chat skills go in `custom-skills/chat/` → output to `dist/`
- Plugin skills go in `custom-skills/plugin/` → output to `skills/`
