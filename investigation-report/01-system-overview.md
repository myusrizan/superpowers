# Custom Skills System — Part 1: System Overview

> Updated: 2026-03-07

---

## Architecture (Unchanged)

```
custom-skills/          Source of truth — edit here
  <category>/
    <skill-name>/
      SKILL.md          YAML frontmatter + markdown instructions
      [supporting files]

scripts/
  build-skills.sh       Copies custom-skills/ → skills/, auto-regenerates catalog

skills/                 Built output — what Claude Code reads at runtime
  <category>/
    <skill-name>/
      SKILL.md

hooks/
  hooks.json            session-start hook: injects using-superpowers context
```

**Key invariant:** Never edit `skills/` directly. Always edit `custom-skills/`, then run `bash scripts/build-skills.sh`.

---

## Skill Inventory (48 skills as of 2026-03-07)

### coding/ (17 skills)

| Skill | Added | Notes |
|-------|-------|-------|
| `brainstorming` | original | Description fixed (CSO), dead refs removed (2026-02-28) |
| `investigating` | 2026-02-28 | |
| `planning-sessions` | original | |
| `writing-plans` | original | |
| `executing-plans` | original | |
| `test-driven-development` | original | Updated: user journey Step 0 added |
| `systematic-debugging` | original | |
| `security-review` | 2026-02-28 | |
| `verification-before-completion` | original | Updated: 5-phase structured report |
| `requesting-code-review` | original | Fixed: ghost skill reference removed |
| `code-reviewer` | original | ⚠️ Prompt template file, not registered skill |
| `receiving-code-review` | original | |
| `api-design` | 2026-03-07 | From affaan-m/everything-claude-code |
| `database-migrations` | 2026-03-07 | From affaan-m/everything-claude-code; updated with advanced patterns |
| `e2e-testing` | 2026-03-07 | From affaan-m/everything-claude-code |
| `eval-harness` | 2026-03-07 | From affaan-m/everything-claude-code |
| `dependency-management` | 2026-03-07 | New (gap fill) |
| `observability` | 2026-03-07 | New (gap fill) |
| `ci-cd-pipeline` | 2026-03-07 | New (gap fill) |
| `silent-failure-hunter` | 2026-03-07 | From anthropics/claude-plugins-official |
| `search-first` | 2026-03-07 | From affaan-m/everything-claude-code |
| `ui-ux-design` | 2026-03-07 (today) | From nextlevelbuilder/ui-ux-pro-max-skill (MIT) |

### agents/ (4 skills)

| Skill | Added | Notes |
|-------|-------|-------|
| `subagent-driven-development` | original | |
| `dispatching-parallel-agents` | original | |
| `autonomous-loops` | 2026-03-07 | From affaan-m/everything-claude-code |
| `iterative-retrieval` | 2026-03-07 | From affaan-m/everything-claude-code |

### git/ (2 skills)

| Skill | Added | Notes |
|-------|-------|-------|
| `using-git-worktrees` | original | Fixed: cd persistence (2026-02-28) |
| `finishing-a-development-branch` | original | |

### thinking/ (3 skills)

| Skill | Added | Notes |
|-------|-------|-------|
| `thinking-partner` | original | |
| `decision-making` | original | |
| `reasoning` | original | |

### qol/ (5 skills)

| Skill | Added | Notes |
|-------|-------|-------|
| `researching` | original | |
| `summarizing` | original | |
| `explaining` | original | |
| `drafting` | original | |
| `documenting` | original | |

### meta/ (9 skills)

| Skill | Added | Notes |
|-------|-------|-------|
| `using-superpowers` | original | Catalog now auto-generated |
| `writing-skills` | original | ⚠️ Very verbose (FLAW-17) |
| `capturing-context` | original | Updated: Context Compaction section |
| `session-resume` | 2026-02-28 | Closes capture→resume loop |
| `prompt-efficiency` | 2026-02-28 | |
| `prompt-generator` | 2026-02-28 | |
| `sensitive-data-guard` | original | |
| `skill-stocktake` | 2026-03-07 | From affaan-m/everything-claude-code |
| `claude-md-improver` | 2026-03-07 | From anthropics/claude-plugins-official |
| `skill-creator` | 2026-03-07 | From anthropics/claude-plugins-official |

---

## Category Balance

| Category | Count | Coverage |
|----------|-------|----------|
| coding | 22 | Full development lifecycle + UI/UX |
| agents | 4 | Multi-agent patterns |
| git | 2 | Branch + worktree workflows |
| thinking | 3 | Reasoning + decisions |
| qol | 5 | Writing + research |
| meta | 9 | System + skill management |
| **Total** | **48** | |

**Observation:** coding/ now has 22 skills — significantly heavier than other categories. Consider whether any belong in a different category or could be merged.

---

## System-Level Strengths

1. **Catalog auto-generation** — `build-skills.sh` regenerates catalog on every build; no manual drift possible
2. **"Pushy" descriptions** — 30+ skills have adjacent trigger phrases; Claude undertriggers by default
3. **Session continuity** — `capturing-context` → `session-resume` closes the capture→resume loop
4. **Iron Laws enforced** — verification-before-completion + TDD gates prevent shipping without checking
5. **Meta-skills for system maintenance** — `skill-stocktake`, `claude-md-improver`, `skill-creator` make the system self-maintaining

## System-Level Risks

1. **48 skills = heavy catalog** — `using-superpowers` now describes 48 skills at session start. As the catalog grows, there's risk of context load becoming unwieldy or Claude missing descriptions.
2. **Uneven pressure testing** — 19 skills added in the last 5 weeks without full TDD pressure testing from `writing-skills`
3. **`code-reviewer` architecture confusion** — still a template file, not a skill; `requesting-code-review` references it in a way that could confuse
