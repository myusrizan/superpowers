---
name: planning-sessions
description: Use when facing multiple candidate features or tasks and needing to decide what order to tackle them — produces a prioritized backlog or sprint plan from a pool of work items. Also use to adversarially stress-test a plan before executing it — invoke when asked to "stress test this plan", "find the holes in this", or "what could go wrong?".
---

# Planning Sessions

## Overview

Turn a pool of candidate work items into an ordered, executable backlog with clear priorities and milestones.

**Core principle:** Prioritization is a decision, not a feeling. Make the criteria explicit, apply them consistently, and commit to the order.

**Distinction from related skills:**
- `brainstorming` — design a single feature before implementing it
- `writing-plans` — write an implementation plan for a specific approved feature
- `planning-sessions` — decide which features to work on and in what order

---

## When to Use

Use when:
- You have 3+ candidate features/tasks and need to decide order
- Starting a new sprint or work cycle and need a prioritized queue
- A backlog has grown and needs to be rationalized
- The user says "what should we tackle first?", "how do we prioritize this?", "help me plan the next sprint"

Don't use for:
- Designing a single feature → `brainstorming`
- Executing an already-planned list → `executing-plans`

---

## The Process

### Step 1: Capture All Candidates

Get every item on the table. Don't evaluate yet. Don't prune yet.

Sources to check:
- What the user listed explicitly
- Open issues or tasks in the project
- Unresolved items from previous session logs (if present)
- Things mentioned in conversation but never formalized

Output: a numbered flat list. Nothing ranked yet.

### Step 2: Classify Each Item

For each candidate:

| Dimension | Question |
|-----------|----------|
| **Type** | Bug fix / Feature / Debt / Infrastructure / Research |
| **Dependencies** | Does anything else need to happen first? |
| **Impact** | Who benefits and how much? (high / medium / low) |
| **Effort** | How long roughly? (days / week / weeks) |
| **Risk** | What breaks if we get it wrong? (high / medium / low) |
| **Reversibility** | Can we undo this if it goes wrong? |

Don't over-engineer the estimates. Relative ordering matters more than absolute accuracy.

### Step 3: Apply Prioritization Rules

**Hard constraints first** (eliminate, don't rank):
- Any item that blocks other items → must come before what it blocks
- Any security vulnerability → top priority, no exceptions
- Any production outage risk → top priority

**Then sort by value/effort ratio:**
- High impact + low effort → do first
- High impact + high effort → plan carefully, do next
- Low impact + low effort → do when convenient
- Low impact + high effort → deprioritize or drop

**Break ties by:**
- Risk: higher-risk items earlier (learn sooner if it's broken)
- Reversibility: do irreversible things later when you know more
- User/stakeholder urgency: if someone's waiting, weight that explicitly

### Step 4: Define Milestones

Group the ordered list into milestones — coherent chunks that deliver something complete.

```
Milestone 1: [Name] — [What's deliverable after this]
- Item A (1-2 days)
- Item B (3 days)

Milestone 2: [Name] — [What's deliverable after this]
- Item C (1 week)
...
```

Milestone = something that could ship, demo, or be reviewed in isolation.

### Step 5: Flag Ambiguities

For items where you're uncertain:
- "Item D: I'm unsure whether this needs to happen before or after Item E — depends on whether X. Clarify?"
- "Item F: Not clear if this is in scope. Do you want to include it?"

Surface these before finalizing.

### Step 6: Present and Confirm

Present the prioritized backlog. State:
- The ordering rationale (2-3 sentences)
- The first milestone
- Any open questions

Wait for user confirmation before treating it as settled.

---

## Output Format

```markdown
# Work Backlog — [Date]

## Prioritization Rationale
[2-3 sentences explaining what drove the ordering]

## Milestone 1: [Name]
Goal: [What this milestone delivers]

1. [Item name] — [type] — [effort estimate]
   Why now: [one sentence]
2. [Item name] — [type] — [effort estimate]
   Why now: [one sentence]

## Milestone 2: [Name]
Goal: [What this milestone delivers]

3. ...

## Deferred / Not Now
- [Item] — [why deferred]

## Open Questions
- [Question that needs answering before X can be planned]
```

---

## Common Failures

| Failure | What it looks like | Fix |
|---------|--------------------|-----|
| **Prioritizing by gut** | Items ranked with no stated reason | State the rationale for each top item |
| **Missing dependencies** | Starting Item B when Item A must go first | Explicit dependency check before ordering |
| **Undefined milestones** | One giant flat list with no natural checkpoints | Group into deliverable chunks |
| **Not dropping items** | Everything is priority 1 | If everything is urgent, nothing is — force-rank and drop the bottom tier |
| **Skipping confirmation** | Treating the first draft as final | Present and confirm before executing |

---

## Adversarial Planning Mode

Use when the stakes are high and you want to stress-test the plan before executing it.

**Core principle:** The cheapest time to find a flaw is before writing code. The most expensive is after deployment.

**Trigger:** Plan is draft-complete. Before confirming, run all steps below.

### Step A: Restate the Plan

Write the plan's core assumption in one sentence:

> "We will [do X] because [Y], expecting [Z]."

This is the target. The rest of the process attacks it.

### Step B: Assumption Mapping

List every assumption the plan relies on being true:

| # | Assumption | If wrong, what happens? | Confidence |
|---|-----------|------------------------|-----------|
| 1 | The database can handle 10K concurrent writes | System degrades or crashes | Medium |
| 2 | Auth token format won't change for 6 months | All clients break on token refresh | High |
| 3 | The third-party API has 99.9% uptime | Feature unavailable when it's down | Low |

**Rule:** If the consequence of being wrong is catastrophic, that assumption needs validation before the plan proceeds.

### Step C: Failure Mode Analysis

For each major step in the plan, ask: "What does failure look like here?"

```
Step: Migrate existing users to new auth system
Failure modes:
- Partial migration: some users migrated, some not → split state, hard to debug
- Token invalidation: existing sessions fail silently → logged-out users
- Rollback needed: no rollback path designed → stuck in broken state
```

### Step D: Pre-Mortem

Imagine it's 6 months later and the plan has **failed badly**. Write the post-mortem:

> "The plan failed because we didn't account for [X]. We noticed it when [Y happened]. The root cause was [Z]. We could have caught it earlier by [action]."

Fill in X, Y, Z. If you can write a convincing post-mortem, the plan has a real risk.

### Step E: Devil's Advocate Pass

Argue the strongest case against the plan:

- "There's a simpler approach: [alternative] — why aren't we doing that?"
- "This plan requires N things to go right. Historically, N-thing plans fail at step N/2."
- "The biggest risk isn't technical — it's [organizational/timing/dependency] risk."
- For each dependency: what happens if it's late or wrong? Is there a parallel path?
- Read the plan cold: what files, commands, or decisions are assumed but not stated?
- For each milestone: "Is there a simpler path to the same outcome?"

### Step F: Revised Plan

After the adversarial pass, produce a revised plan that:
- Validates the highest-risk assumptions before committing resources
- Adds explicit rollback steps for irreversible actions
- Identifies the earliest possible checkpoint to verify the plan is working

```markdown
## Plan Stress-Test — [Plan Name]

### Core Assumption
We will [X] because [Y], expecting [Z].

### Risky Assumptions (sorted by risk)
1. [Highest risk] — if wrong: [consequence] — validate by: [action]

### Top Failure Modes
1. [Failure mode] — detect via: [signal] — mitigation: [action]

### Pre-Mortem
"Failed because: [X]. Could have caught it by: [Y]."

### Recommended Changes
- Add: [what to add]
- Remove: [unnecessary complexity]
- Validate first: [what must be confirmed before execution]
- Add rollback: [which irreversible steps need an undo path]
```

**Hard rules:**
- Don't soften the adversarial pass — a real failure will be harsher
- Assumptions must be falsifiable — "we assume this works" is a wish, not an assumption
- Every irreversible step needs a rollback or explicit acceptance of the risk
- High-risk assumptions that can be tested cheaply must be tested before the full plan executes

After adversarial review: revise the plan and re-present. Only proceed after the adversarial pass is complete.

---

## Integration

**Commonly followed by:**
- `brainstorming` — design each feature in order before implementing
- `writing-plans` — create implementation plans for prioritized items

**Inputs that improve output:**
- Previous session logs from `capturing-context`
- Open issues or ticket lists
- User's stated constraints (deadline, team size, dependencies)
