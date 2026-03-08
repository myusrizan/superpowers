# Flaws and Caveats — What to Be Aware Of

> Sources: `investigation-report/03-critical-flaws.md`, `investigation-report/05-missing-skills-and-gaps.md`, `investigation-report/07-post-expansion-audit.md`, `scripts/build-skills.sh`

---

## Current Open Issues

**None.** As of 2026-03-08, all 23 historical flaws tracked in `investigation-report/03-critical-flaws.md` have been resolved.

---

## Structural Caveats (By Design — Not Bugs)

### 1. Cognitive Load Threshold at 60 Skills

The build script (`scripts/build-skills.sh`) emits a warning when the skill count reaches 60. The system is currently at **39 skills** — 21 slots of headroom. At 60, the catalog becomes too large for reliable automatic skill selection — Claude may begin selecting the wrong skill or no skill for a given task.

**What this means for you:** If you add custom skills frequently, monitor the count. The system will need redesign (splitting into sub-catalogs or tiered activation) before reaching 60. The `--code` / `--no-code` build profiles can also reduce the active catalog if needed.

**Source:** `scripts/build-skills.sh` (warning block near end of script)

---

### 2. Skills Are Coding-Centric

17 of 39 skills (44%) are in the `coding/` category. The `qol/` skills (drafting, researching, explaining) exist but are not as deeply developed. If your primary use case is non-coding work, the system provides less structured value. The `--no-code` build profile (meta + qol + thinking, 13 skills) can be used to install only the non-coding subset.

**Source:** `investigation-report/05-missing-skills-and-gaps.md`

---

### 3. Session-Start Hook Scope

The hook (`hooks/session-start`) fires on `startup | resume | clear | compact` events. It injects the `using-superpowers` skill and recent session logs.

However, if the most recent log exceeds 150 lines, it is skipped (not injected). Long sessions can lose continuity if not captured before context compaction.

**Mitigation:** Use the `session-memory` skill (Mode B: Save) proactively at natural breakpoints. Mode A (Proactive Observation) writes small tagged entries to `logs/observations.md` throughout the session as a lightweight safety net.

**Source:** `hooks/session-start` (line limit logic), `custom-skills/meta/session-memory/SKILL.md`

---

### 5. Tier 1 Tools Are Not Auto-Installed

Superpowers does not install `gh`, `rg`, or the Context7 MCP for you. If these are missing, the skills that depend on them (`search-first`, `github-cli`, `finishing-a-development-branch`, etc.) will reference tools that don't exist without surfacing a clear error to the user.

**Mitigation:** Follow `prerequisites.md` in this folder and run the verification commands before your first session.

**Source:** `investigation-report/06-required-tools-checklist.md`

---

### 6. Windows Hook Execution Is More Fragile

The hook system uses a polyglot wrapper (`hooks/run-hook.cmd`) on Windows to reliably find bash (Git Bash or WSL). This was fixed in v4.3.1 but the setup requires bash to be available on PATH.

**Mitigation:** Ensure Git Bash or WSL is installed and `bash` is on PATH before installing. See `docs/windows/` for detailed setup.

**Source:** `docs/windows/`, `hooks/run-hook.cmd`

---

### 7. Legacy Skills Directory Warning

If you previously used Superpowers and have `~/.config/superpowers/skills` on your machine (deprecated path), the hook will warn about it every session start. You must manually move skills to `~/.claude/skills` to clear the warning.

**Source:** `hooks/session-start` (legacy check block)

---

### 8. No Automated Testing of Skills

Skills are prose-based instruction files (Markdown). The `skill-management` skill applies TDD concepts to skill creation (RED → GREEN → REFACTOR with subagent pressure tests), but skill files are not automatically tested for correctness on each build. A skill could contain conflicting instructions or stale references and only be discovered through use.

The audit history in `investigation-report/` represents human-driven quality control, not automated CI.

**Source:** `investigation-report/02-per-skill-analysis.md`, `scripts/build-skills.sh`

---

### 9. Skill Invocation Depends on Claude's Judgment

Skills trigger based on Claude's interpretation of frontmatter descriptions and the `using-superpowers` catalog. If the task description is ambiguous or the skill description doesn't closely match how you phrase a request, the wrong skill (or no skill) may trigger.

This is a fundamental limitation of instruction-based skill routing vs. code-based dispatch.

**Mitigation:** The `using-superpowers` skill instructs Claude to check the catalog before acting. You can also explicitly invoke a skill: `/skill superpowers:feature-workflow`.

**Source:** `custom-skills/meta/using-superpowers/SKILL.md`

---

## Historical Flaws (All Resolved)

For the full list of 23 resolved flaws (FLAW-01 through FLAW-23), see:

- `investigation-report/03-critical-flaws.md` — all resolutions documented
- `investigation-report/07-post-expansion-audit.md` — post-expansion audit confirming GREEN status

Notable resolved flaws:

| FLAW | Description | Resolution |
|------|-------------|------------|
| FLAW-01 | Ghost skills in catalog not in `custom-skills/` | Removed ghost entries |
| FLAW-09 | `autonomous-loops` missing termination conditions | Added termination checklist + circuit breaker |
| FLAW-17 | `writing-skills` too verbose for session context | Split into lean SKILL.md + `detail.md` |
| FLAW-22 | `session-resume` referencing stale hook tag | Removed; now reads `logs/` directly |
| FLAW-23 | `mcp-server` missing Context7 reference | Added Context7 reference for FastMCP |
