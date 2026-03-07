# Custom Skills System — Part 2: Per-Skill Analysis

> Updated: 2026-03-07
> Focus: Skills added/modified since the 2026-02-28 audit. Original 29 skills were audited then; notes here cover health of new skills only.

---

## Skills Added 2026-03-07 (from external repos)

### `coding/api-design`
**Source:** affaan-m/everything-claude-code
**Content:** REST URL patterns, HTTP semantics, pagination (offset vs cursor), versioning strategy.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Solid patterns. No known issues. Low risk — reference skill with no HARD-GATEs.

---

### `coding/database-migrations`
**Source:** affaan-m/everything-claude-code (then extended)
**Content:** Expand-contract pattern, CONCURRENTLY indexes, batch updates, UPSERT with ON CONFLICT, FOR UPDATE SKIP LOCKED, RLS enforcement.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Two layers: base patterns from source + advanced PostgreSQL patterns added in same session. Verify the two layers integrate coherently.

---

### `coding/e2e-testing`
**Source:** affaan-m/everything-claude-code
**Content:** Page Object Model, flaky test quarantine, condition-based waits, CI artifact collection.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Blockchain-specific parts were removed before acquisition. No known issues.

---

### `coding/eval-harness`
**Source:** affaan-m/everything-claude-code
**Content:** Eval-driven development, pass@k/pass^k metrics, capability vs regression evals.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Novel content (AI eval patterns). Original had a prompt injection risk (model-based grader fed code without sanitization) — verify this was addressed or not present in the acquired version.

---

### `coding/dependency-management`
**Content:** Add vs build decisions, pinning strategy, lock file discipline, vulnerability audits.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Gap-fill skill. Content authored fresh. Needs validation that it triggers on "should I add this package?" type requests.

---

### `coding/observability`
**Content:** Structured JSON logging, metrics (counter/gauge/histogram), distributed tracing, SLO-based alerting.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Gap-fill skill. Broad domain — verify it doesn't overlap with `systematic-debugging` or `ci-cd-pipeline` in ways that cause confusion.

---

### `coding/ci-cd-pipeline`
**Content:** Stage ordering, caching, secrets management, rolling/blue-green/canary deployment strategies.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Gap-fill skill. Check that `observability` and `ci-cd-pipeline` don't have overlapping trigger conditions (both touch deployment concerns).

---

### `coding/silent-failure-hunter`
**Source:** anthropics/claude-plugins-official
**Content:** CRITICAL (empty catch), HIGH (poor error message/unjustified fallback), MEDIUM (missing context); TS/Python/Go patterns.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** High-quality Anthropic-sourced skill. Check that it doesn't overlap with `security-review` (both look at error handling).

---

### `coding/search-first`
**Source:** affaan-m/everything-claude-code
**Content:** Need analysis → parallel search → evaluate → adopt/extend/compose/build.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Meta-coding pattern. Watch for conflicts with `brainstorming` (both gate implementation). Their roles differ: `search-first` is about finding existing solutions; `brainstorming` is about design decisions.

---

### `coding/ui-ux-design` *(added today)*
**Source:** Adapted from nextlevelbuilder/ui-ux-pro-max-skill (MIT)
**Content:** 4-step design workflow, industry → design system lookup (30 categories), 68 style taxonomy, 35 HIGH-severity UX rules, non-negotiable standards, design system persistence, stack quick reference, anti-pattern checklist.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** First UI/UX skill in the system. Standalone (no Python dependency). Test with: "build me a landing page for a SaaS product" — should trigger. Also test "add a dashboard component" and "fix the button styling."

---

### `agents/autonomous-loops`
**Source:** affaan-m/everything-claude-code
**Content:** 5 patterns: sequential pipeline, de-sloppify, infinite loop, continuous PR loop, RFC-driven DAG.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Important architectural skill. Verify it doesn't conflict with `dispatching-parallel-agents` on trigger conditions (both handle multi-agent work).

---

### `agents/iterative-retrieval`
**Source:** affaan-m/everything-claude-code
**Content:** Broad dispatch → score (0–1.0) → refine → max 3 cycles.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Narrow scope (search/retrieval loops). Low trigger confusion risk.

---

### `meta/skill-stocktake`
**Source:** affaan-m/everything-claude-code
**Content:** 4 criteria, 5 verdicts (Keep/Improve/Update/Retire/Merge), overlap detection.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Useful for system maintenance. Complements `investigating`.

---

### `meta/claude-md-improver`
**Source:** anthropics/claude-plugins-official
**Content:** 5-phase: discover → assess (6 criteria A–F) → report → propose → apply.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Anthropic-sourced, high quality. Narrow scope, low risk.

---

### `meta/skill-creator`
**Source:** anthropics/claude-plugins-official
**Content:** 7-phase process, description writing guide, "pushy" principle, install via `/plugins install skill-creator`.
**Description quality:** Pushy ✅
**Pressure tested:** No ⚠️
**Notes:** Anthropic-sourced. This is the skill that taught us the pushy principle — it should embody it.

---

## Skills Updated 2026-03-07

### `coding/test-driven-development`
**Change:** Added Step 0 user journey format ("As a [role], I want [action], so that [benefit]"), pushy description.
**Status:** ✅ No new issues introduced.

### `coding/verification-before-completion`
**Change:** Added 5-phase structured report (Build/Types/Lint/Tests/Diff), pushy description.
**Status:** ✅ Improves output consistency.

### `meta/capturing-context`
**Change:** Added Context Compaction section: `/compact` (mid-session) vs log saving (end of session).
**Status:** ✅ Closes a missing guidance gap.

---

## Previously Audited Skills (2026-02-28)

See the 2026-02-28 session logs for full per-skill analysis of the original 29 skills. All critical flaws were resolved. Only FLAW-17 (`writing-skills` verbosity) remains open.

| Original Skills Fixed | Fix Applied |
|----------------------|-------------|
| `requesting-code-review` | Ghost skill reference replaced with Task + template pattern |
| `brainstorming` | Dead references removed, CSO description fixed |
| `using-git-worktrees` | cd persistence fixed with WORKTREE_PATH variable pattern |
| All skills | Catalog drift fixed via build-skills.sh auto-generation |
| `capturing-context` | mkdir -p logs, trigger phrases added |
| `subagent-driven-development` | Loop termination rule added (max cycles) |
