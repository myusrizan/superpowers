# Custom Skills System — Part 3: Critical Flaws

> Updated: 2026-03-07
> Historical context: 18 flaws identified in 2026-02-28 audit. All resolved except FLAW-17. FLAW-18 through FLAW-20 from the 2026-03-07 audit are all resolved. FLAW-17 resolved in session 4.

---

## Open Flaws

None. All flaws resolved.

---

## Resolved Flaws (Session 4 — 2026-03-07)

### FLAW-17: `writing-skills` verbosity
**Severity:** Low
**Status:** RESOLVED
**Skill:** `meta/writing-skills`

**Problem:** `writing-skills` was the longest skill in the system (656 lines). Loaded at session start via `using-superpowers`, it added context load every session even when no skill-writing work was planned.

**Fix applied:** Split into two files:
- `SKILL.md` — lean reference (~140 lines): overview, TDD mapping, when to create, SKILL.md structure template, CSO critical rules (description = When to Use), Iron Law, summary checklist, reference to `detail.md`
- `detail.md` — full methodology (~300 lines): detailed CSO guidelines, testing by skill type, bulletproofing, rationalization tables, RED-GREEN-REFACTOR cycle, anti-patterns, full checklist, discovery workflow

`detail.md` is loaded on demand only when actively writing or testing a skill. Session-start context load is now minimal.

---

## Resolved Flaws (Historical Reference)

All 17 flaws from the 2026-02-28 audit were resolved in the 2026-02-28 sessions. Key fixes:

| Flaw | Fix |
|------|-----|
| FLAW-01: requesting-code-review ghost skill | Task tool + template pattern |
| FLAW-02: brainstorming dead references | Dead refs removed, description fixed |
| FLAW-03: using-git-worktrees cd persistence | WORKTREE_PATH variable pattern |
| FLAW-04: catalog drift | build-skills.sh auto-generation implemented |
| FLAW-05: logs/ directory missing | mkdir -p logs added |
| FLAW-06: capturing-context missing trigger phrases | "save progress", "checkpoint" added |
| FLAW-07: subagent review loop termination | Max 3 cycles rule added |
| FLAW-08 through FLAW-16 | Fixed in 2026-02-28 sessions |
| FLAW-18: New skills not pressure-tested | `search-first` and `ui-ux-design` tested and patched (YELLOW → GREEN). Reference skills exempt per `writing-skills` guidance. `database-migrations` deferred (low-use). |
| FLAW-19: `code-reviewer` architecture confusion | Stale — `code-reviewer` was already a proper registered skill with full frontmatter and two-phase workflow. No action needed. |
| FLAW-20: `ui-ux-design` description clarity | Description updated to explicitly exclude general code quality review; boundary with `code-reviewer` made explicit. |
