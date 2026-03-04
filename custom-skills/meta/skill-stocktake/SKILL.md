---
name: skill-stocktake
description: Use when auditing the current skill system — evaluating skill quality, identifying overlaps or gaps, retiring outdated skills, or planning the next round of skill improvements
---

# Skill Stocktake

## Overview

Skills accumulate. Over time, some become outdated, some overlap, some are never used, and some should be merged. A stocktake is a systematic audit of the entire skill system to keep it sharp.

**Core principle:** A skill that doesn't trigger reliably, or triggers for the wrong task, is worse than no skill. It adds noise without adding value.

---

## When to Run a Stocktake

- After adding 5+ new skills in a batch (check for overlaps)
- After a major workflow change (some skills may no longer apply)
- When a skill seems to be triggering in the wrong context
- Periodically (every 2-3 months) to catch gradual drift
- Before a large skill acquisition from an external source

---

## Evaluation Criteria

Score each skill against these four dimensions:

### 1. Actionability
Does the skill give concrete, executable guidance — or is it vague enough that Claude would do the same thing without it?

| Score | Meaning |
|-------|---------|
| High | Specific steps, decision rules, hard constraints that would change behavior |
| Medium | Useful framing but some steps are generic |
| Low | Principles only — no specific guidance on what to do differently |

### 2. Scope Fit
Is the trigger condition specific enough to be meaningful, but broad enough to fire often enough to justify the skill?

| Score | Meaning |
|-------|---------|
| High | Fires for a real, distinct workflow; not too broad, not too narrow |
| Medium | Trigger has some ambiguity or overlaps with another skill |
| Low | Never fires, or fires for everything (too broad), or conflicts with another skill |

### 3. Uniqueness
Does this skill cover ground not already covered by another skill?

| Score | Meaning |
|-------|---------|
| High | Distinct focus — no overlap with other skills |
| Medium | Some overlap but covers meaningful additional ground |
| Low | Substantial overlap — the other skill covers most of this |

### 4. Currency
Is the content still accurate and up to date?

| Score | Meaning |
|-------|---------|
| High | Reflects current tools, versions, and best practices |
| Medium | Mostly current with minor outdated sections |
| Low | Significantly outdated — tools, APIs, or patterns have changed |

---

## Verdicts

| Verdict | Criteria | Action |
|---------|----------|--------|
| **Keep** | High on 3+ dimensions | No changes needed |
| **Improve** | Medium actionability or currency | Rewrite weak sections |
| **Update** | Low currency only | Update outdated facts/versions |
| **Retire** | Low scope fit or actionability | Remove from the system |
| **Merge into [X]** | Low uniqueness | Fold content into the better-covering skill |

---

## The Stocktake Process

### Phase 1: Inventory

List all skills with their categories and trigger conditions.

```markdown
| Skill | Category | Trigger condition (summary) |
|-------|----------|-----------------------------|
| api-design | coding | Designing or reviewing REST API endpoints |
| refactoring | coding | Improving structure of working code |
| ...
```

Flag any skills where:
- The trigger condition is ambiguous or very similar to another skill
- The trigger condition is very broad ("any coding task")
- The category seems wrong

### Phase 2: Quality Evaluation

For each skill, evaluate against the 4 criteria. Write a brief reason — not just a score.

```markdown
## refactoring
- Actionability: High — concrete steps, one-type-at-a-time rule, undo-not-fix-forward
- Scope Fit: High — distinct workflow, not triggered by debugging or feature work
- Uniqueness: High — no overlap with systematic-debugging or test-driven-development
- Currency: High — patterns are language-agnostic and stable

Verdict: Keep
```

### Phase 3: Overlap Detection

For any two skills with similar triggers, compare them directly:

```markdown
## potential overlap: researching vs search-first

researching: "starting research on an unknown topic"
search-first: "about to implement functionality without having searched first"

Overlap: Both involve searching before acting
Difference: researching = information gathering for decisions; search-first = finding libraries/tools before coding

Verdict: Distinct — both Keep. Update both trigger descriptions to make the distinction clear.
```

### Phase 4: Summary Report

```markdown
# Skill Stocktake — [Date]

## Summary
- Total skills audited: N
- Keep: N
- Improve: N (list)
- Update: N (list)
- Retire: N (list)
- Merge: N (list with targets)

## Actions Required
1. [Skill]: [what to improve]
2. [Skill]: Retire — [reason]
3. [Skill] → [Target]: Merge — [what to move]
```

---

## Retirement Criteria

A skill should be retired when:

- **Never triggered in practice.** If a skill has been in the system for months and hasn't been used, it's not addressing a real workflow.
- **Superceded.** A newer, better skill covers the same ground.
- **Too narrow.** Only applies to one specific project or task that no longer exists.
- **Outdated and not worth updating.** The domain has changed enough that a rewrite would be faster than an update.

**Do not retire a skill just because it's rarely triggered.** Some skills are rare but critical (e.g., `sensitive-data-guard`). Retirement is about whether the skill adds value when it does trigger.

---

## Merge Criteria

Merge when two skills substantially overlap and separating them creates confusion about which to use:

```markdown
# Example merge: capturing-context + session-resume

These two skills both address context continuity across sessions.
capturing-context: saving context at session end
session-resume: using saved context at session start

Decision: Keep both as separate skills — they trigger at different times (end vs start).
Do NOT merge — they serve distinct trigger moments.
```

vs.

```markdown
# Example merge: verification-loop + verification-before-completion

Both: "verify work is complete before saying done"
verification-loop: focus on structured report format
verification-before-completion: focus on the discipline of not skipping verification

Decision: Merge verification-loop concepts into verification-before-completion.
The structured report format can be added as an output option.
Retire verification-loop.
```

---

## Hard Rules

- **Reasons must be self-contained.** A verdict reason of "unchanged" or "seems fine" is not acceptable. State the specific evidence.
- **Retire requires confirmation.** Don't delete a skill during the audit — flag it for retirement, then confirm before removing.
- **Update trigger conditions when fixing overlaps.** If two skills overlap due to ambiguous descriptions, fixing the description is better than merging.
- **Keep the stocktake report.** Save the report in `findings/` or `logs/` — it's a record of decisions made.
