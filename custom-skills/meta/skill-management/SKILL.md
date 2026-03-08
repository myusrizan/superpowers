---
name: skill-management
description: Use when creating a new skill, improving or testing an existing skill, or optimizing a skill's description for better triggering (creation phase), or when auditing the current skill system to evaluate quality, find overlaps, or plan improvements (stocktake phase). Invoke after adding 5+ new skills, after a major workflow change, or when a skill seems to fire in the wrong context.
---

# Skill Management

Two phases in the skill lifecycle. Use the phase that matches your situation.

```
New skill needed → Phase 1: Create & Write (design → draft → TDD test → iterate → optimize)
System drift     → Phase 2: Stocktake     (inventory → evaluate → detect overlaps → report)
```

---

## Phase 1: Create & Write a Skill

### How Skill Triggering Works

Before writing, understand how Claude decides to invoke a skill:

- Skills appear with `name` and `description` in context
- Claude invokes a skill when the description matches the task **and** the task is complex enough to benefit from specialized guidance
- **Claude undertriggers by default** — it avoids invoking skills when it could handle tasks directly. Combat this with "pushy" descriptions
- **Simple, one-step queries won't trigger skills** — multi-step specialized workflows reliably trigger when the description matches

**Implication:** Descriptions must cover what the skill does AND specific contexts where it applies — including adjacent phrasings users might use without knowing the skill name.

---

### Step 1: Capture Intent

If the current conversation already contains a workflow to capture, extract the steps from history first.

Answer before drafting:
1. What should this skill enable Claude to do?
2. When should it trigger? What would a user actually say?
3. What's the expected output format?
4. Are outputs objectively verifiable (code generated, file created) or subjective (writing quality)? — Verifiable → write test cases. Subjective → qualitative review.

**Interview:** Ask about edge cases, input constraints, success criteria, failure modes. Don't write until the interview is complete.

---

### Step 2: Write the SKILL.md (TDD — GREEN phase)

**File structure:**
```
skill-name/
├── SKILL.md          ← Required: frontmatter + instructions
└── references/       ← Optional: large docs loaded on demand
    └── details.md
```

**Frontmatter:**
```yaml
---
name: skill-name
description: Use when [specific triggering conditions — NOT a summary of what the skill does]
---
```

**Description writing rules:**

| Too passive | Pushy (better) |
|-------------|---------------|
| "How to design REST APIs" | "Use when designing or reviewing REST APIs. Invoke whenever someone asks about endpoint naming, HTTP methods, response formats, or versioning — even if they don't say 'API design'." |

**Critical — description = when to use, NOT what the skill does:**
```yaml
# ❌ BAD: Summarizes workflow — Claude may follow the description instead of reading the full skill
description: Use when executing plans - dispatches subagent per task with code review between tasks

# ✅ GOOD: Just triggering conditions
description: Use when executing implementation plans with independent tasks in the current session
```

**Include in description:** trigger conditions · adjacent phrasings · "Even if the user doesn't say X" for common skip scenarios. **Keep under ~100 words.**

**Body guidelines:**
- Imperative form: "Write the test first." not "The test should be written first."
- Explain the why — Claude follows reasoning better than mandates
- Examples over prose — show good vs. bad examples
- Progressive disclosure: metadata (100 words) → body (<500 lines) → references/ (unlimited, on demand)
- No multi-language dilution — pick one language, note others apply by analogy

**SKILL.md structure:**
```markdown
## Overview
What is this? Core principle in 1–2 sentences.

## When to Use
Bullet list with symptoms and use cases. When NOT to use.

## Core Pattern
Before/after comparison.

## Quick Reference
Table or bullets for scanning common operations.

## Common Mistakes
What goes wrong + fixes.
```

---

### Step 3: Test with TDD (RED → GREEN → REFACTOR)

**Writing skills IS TDD applied to process documentation.**

| TDD Concept | Skill Creation |
|-------------|----------------|
| Test case | Pressure scenario with subagent |
| Production code | Skill document (SKILL.md) |
| Test fails (RED) | Agent violates rule without skill (baseline) |
| Test passes (GREEN) | Agent complies with skill present |
| Refactor | Close loopholes while maintaining compliance |

**The Iron Law:** No skill without watching a subagent fail without it first.

**Write 2–3 realistic test prompts** — what a real user would actually say. Include context: file paths, background, specifics.

```
Bad:  "Design a REST API"
Good: "I'm building a task management app in Next.js. I need endpoints for tasks,
       projects, and user assignments. The frontend uses React Query.
       Can you design the API structure?"
```

For each prompt:
1. Run Claude WITHOUT the skill (baseline) — document failures verbatim
2. Run Claude WITH the skill — verify compliance
3. Compare outputs

Save test prompts for future iterations.

See `skill-management/testing-skills-with-subagents.md` and `skill-management/detail.md` for the full TDD methodology.

---

### Step 4: Evaluate

| Dimension | Questions |
|-----------|-----------|
| **Triggered correctly?** | Did the skill fire for the prompt? Did it fire for prompts it shouldn't? |
| **Followed the skill?** | Did Claude follow the steps, or improvise? |
| **Output quality** | Is the output better than without the skill? |
| **Missing steps** | Did Claude skip steps that should have run? |
| **Over-engineering** | Did the skill cause unnecessary work? |

---

### Step 5: Iterate

| Problem | Fix |
|---------|-----|
| Skill didn't trigger | Description too narrow — add adjacent phrasings, make it pushier |
| Skill triggered for wrong prompts | Description too broad — narrow the trigger condition |
| Claude skipped steps | Body too long or unclear — break into smaller explicit instructions |
| Output worse than baseline | Skill adds friction — simplify or remove steps that don't improve outcomes |
| Claude over-engineers | Too many requirements — remove steps that don't pull their weight |

Repeat evaluate → iterate until: triggers reliably · outputs consistently better · no false triggers.

---

### Step 6: Optimize Description (Optional)

For skills where triggering accuracy matters most, generate 20 eval queries (10 should-trigger, 10 should-not-trigger) and test each:

- **Should-trigger:** Different phrasings, casual speech, context-heavy prompts, cases where user doesn't name the skill
- **Should-not-trigger:** Near-misses — adjacent domains, shared keywords, contexts where another skill is more appropriate

Update description to close gaps found.

---

### Placing the Skill

```
custom-skills/
├── coding/      ← development workflow: tdd, debugging, security, etc.
├── agents/      ← agent patterns: parallel dispatch, loops, retrieval
├── git/         ← version control workflows
├── thinking/    ← reasoning, decisions, ideation
├── qol/         ← output: docs, drafts, summaries, explanations
└── meta/        ← skill system itself, context, prompts
```

After placing, rebuild the catalog:
```bash
bash scripts/build-skills.sh
# → "Catalog regenerated"
```

---

### Hard Rules (Creation)

- **Write the description last.** Draft the body first, understand what the skill does, then write the trigger.
- **Test before declaring done.** A skill that hasn't been tested with real prompts is a guess.
- **Explain the why.** Claude follows reasoning better than mandates.
- **Keep body under 500 lines.** Use `references/` for large docs.
- **Run the build after every change.** The catalog won't update otherwise.

---

## Phase 2: Skill Stocktake (System Audit)

**When to run:** After adding 5+ new skills in a batch · after a major workflow change · when a skill triggers in the wrong context · periodically to catch gradual drift · before a large skill acquisition from an external source.

**Core principle:** A skill that doesn't trigger reliably, or triggers for the wrong task, is worse than no skill. It adds noise without value.

---

### Evaluation Criteria

Score each skill on 4 dimensions:

**1. Actionability** — Does the skill give concrete, executable guidance, or would Claude do the same thing without it?
- High: specific steps, decision rules, hard constraints that change behavior
- Medium: useful framing but some generic steps
- Low: principles only, no specific guidance on what to do differently

**2. Scope Fit** — Is the trigger specific enough to be meaningful, but broad enough to fire often enough to justify the skill?
- High: fires for a real, distinct workflow; not too broad, not too narrow
- Medium: trigger has some ambiguity or overlaps with another skill
- Low: never fires, fires for everything, or conflicts with another skill

**3. Uniqueness** — Does this skill cover ground not already covered by another skill?
- High: distinct focus, no overlap
- Medium: some overlap but meaningful additional ground
- Low: substantial overlap — the other skill covers most of this

**4. Currency** — Is the content still accurate and up to date?
- High: reflects current tools, versions, and best practices
- Medium: mostly current with minor outdated sections
- Low: significantly outdated

---

### Verdicts

| Verdict | Criteria | Action |
|---------|----------|--------|
| **Keep** | High on 3+ dimensions | No changes |
| **Improve** | Medium actionability or currency | Rewrite weak sections |
| **Update** | Low currency only | Update outdated facts |
| **Retire** | Low scope fit or actionability | Remove from system |
| **Merge into [X]** | Low uniqueness | Fold into better-covering skill |

---

### Stocktake Process

**Phase 1 — Inventory:** List all skills with categories and trigger conditions. Flag skills where trigger is ambiguous, very similar to another, very broad, or the category seems wrong.

**Phase 2 — Evaluate:** For each skill, score all 4 criteria with a specific reason — not just "seems fine."

**Phase 3 — Overlap Detection:** For any two skills with similar triggers, compare directly:
```markdown
## potential overlap: researching vs search-first

researching: "starting research on an unknown topic"
search-first: "about to implement functionality without having searched first"

Overlap: both involve searching before acting
Difference: researching = information for decisions; search-first = finding libraries before coding

Verdict: Distinct — both Keep. Update descriptions to clarify the difference.
```

**Phase 4 — Summary Report:**
```markdown
# Skill Stocktake — [Date]

## Summary
- Total skills audited: N
- Keep: N | Improve: N | Update: N | Retire: N | Merge: N

## Actions Required
1. [Skill]: [what to improve]
2. [Skill]: Retire — [reason]
3. [Skill] → [Target]: Merge — [what to move]
```

Save to `investigation-report/NN-post-stocktake-audit.md` (increment prefix). **Not** in `findings/` — that's for external repo investigations only.

---

### Retirement Criteria

Retire when: never triggered in months · superceded by a better skill · only applies to a project that no longer exists · so outdated a rewrite would be faster.

**Do not retire just because rarely triggered.** Some skills are rare but critical (e.g., `sensitive-data-guard`).

---

### Hard Rules (Stocktake)

- **Reasons must be self-contained.** "Unchanged" or "seems fine" is not acceptable evidence.
- **Retire requires confirmation.** Flag for retirement during the audit; confirm before removing.
- **Fix descriptions, don't just merge.** If two skills overlap due to ambiguous descriptions, fixing the description is often better than merging.
- **Keep the report.** It's a record of decisions made.
