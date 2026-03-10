---
name: planning-sessions
description: Use when facing multiple candidate features or tasks and needing to decide what order to tackle them — produces a prioritized backlog or sprint plan from a pool of work items
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

**Trigger:** Plan is draft-complete. Before confirming, run the plan through these challenges.

### Challenge 1: Assumption Audit
List every assumption the plan relies on:
- "The API is available" — what if it's not?
- "This will take 2 days" — what if it takes 6?
- "Users will understand X" — what if they don't?

For each assumption: **If this is wrong, does the plan fail?** If yes → validate or add a contingency.

### Challenge 2: Dependency Risk
For each item with dependencies:
- What happens if the dependency is late or wrong?
- Is there a parallel path that doesn't block on this?

### Challenge 3: What's Missing?
Read the plan from the perspective of someone who will execute it cold:
- What files are not mentioned that they'll need to find?
- What commands are assumed but not listed?
- What decisions are left unresolved?

### Challenge 4: Simplification Pass
For each milestone: "Is there a simpler path to the same outcome?"
- Remove steps that exist "just in case"
- Merge steps that don't need to be separate
- Defer steps that belong in a later milestone

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
