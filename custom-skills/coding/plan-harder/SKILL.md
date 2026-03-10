---
name: plan-harder
description: Use when a plan needs adversarial stress-testing before execution — to identify hidden assumptions, failure modes, and unexamined risks. Invoke before committing to a plan for a high-stakes task, or when asked to "stress test this plan", "find the holes in this", or "what could go wrong?".
---

# Plan Harder

## Overview

Adversarial deep-planning mode. Put a plan through structured challenges before executing it.

**Core principle:** The cheapest time to find a flaw is before writing code. The most expensive is after deployment.

---

## When to Use

- Before implementing a significant architectural decision
- When a plan "feels right" but the stakes are high
- After `coding/planning-sessions` produces a plan — use this to challenge it
- When the user says "are we sure about this approach?"

---

## The Adversarial Process

### Step 1: Restate the Plan

Write the plan's core assumption in one sentence:

> "We will [do X] because [Y], expecting [Z]."

This is the target. The rest of the process attacks it.

### Step 2: Assumption Mapping

List every assumption the plan relies on being true:

| # | Assumption | If wrong, what happens? | Confidence |
|---|-----------|------------------------|-----------|
| 1 | The database can handle 10K concurrent writes | System degrades or crashes | Medium |
| 2 | Auth token format won't change for 6 months | All clients break on token refresh | High |
| 3 | The third-party API has 99.9% uptime | Feature is unavailable when it's down | Low |

**Rule:** If the consequence of being wrong is catastrophic, that assumption needs validation before the plan proceeds.

### Step 3: Failure Mode Analysis

For each major step in the plan, ask: "What does failure look like here?"

```
Step: Migrate existing users to new auth system
Failure modes:
- Partial migration: some users migrated, some not → split state, hard to debug
- Token invalidation: existing sessions fail silently → logged-out users
- Rollback needed: no rollback path designed → stuck in broken state
```

### Step 4: Pre-Mortem

Imagine it's 6 months later and the plan has **failed badly**. Write the post-mortem:

> "The plan failed because we didn't account for [X]. We noticed it when [Y happened]. The root cause was [Z]. We could have caught it earlier by [action]."

Fill in X, Y, Z. If you can write a convincing post-mortem, the plan has a real risk.

### Step 5: Devil's Advocate Pass

Argue the strongest case against the plan:

- "There's a simpler approach: [alternative] — why aren't we doing that?"
- "This plan requires N things to go right. Historically, N-thing plans fail at step N/2."
- "The biggest risk isn't technical — it's [organizational/timing/dependency] risk."

### Step 6: Revised Plan

After the adversarial pass, produce a revised plan that:
- Validates the highest-risk assumptions before committing resources
- Adds explicit rollback steps for irreversible actions
- Identifies the earliest possible checkpoint to verify the plan is working

---

## Output Format

```markdown
## Plan Harder Analysis — [Plan Name]

### Core Assumption
[One sentence: We will X because Y, expecting Z]

### Risky Assumptions (sorted by risk)
1. [Highest risk assumption] — Risk: if wrong, [consequence] — Action: [how to validate]
2. ...

### Top 3 Failure Modes
1. [Failure mode] — [How to detect] — [Mitigation]

### Pre-Mortem
"Failed because: [X]. Could have caught it by: [Y]."

### Recommended Changes to the Plan
- Add: [what to add]
- Remove: [what to remove as unnecessary complexity]
- Validate first: [what must be confirmed before execution begins]
- Add rollback: [what irreversible steps need an undo path]
```

---

## Hard Rules

- **Don't soften the adversarial pass.** Be genuinely harsh — a real failure will be harsher.
- **Assumptions must be falsifiable.** "We assume this works" is not an assumption — it's a wish.
- **Every irreversible step needs a rollback.** If there's no rollback, it must be explicitly accepted as a risk.
- **Validation over assumption.** Any high-risk assumption that can be tested cheaply must be tested before the full plan executes.
