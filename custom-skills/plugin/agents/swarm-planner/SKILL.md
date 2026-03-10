---
name: swarm-planner
description: Use when a large task can be broken into many independent work units that can execute in parallel — to design and coordinate a swarm of agents working concurrently. Invoke when implementing a large feature with separable modules, processing many items in parallel, or when dispatching-parallel-agents isn't enough structure for complex dependency management.
---

# Swarm Planner

## Overview

Plan and coordinate a swarm of parallel agents for large tasks with complex dependencies.

**Core principle:** Maximize parallelism within dependency constraints. Agents that can run simultaneously should run simultaneously.

---

## When to Use vs. Alternatives

| Situation | Use |
|-----------|-----|
| 2–5 independent tasks | `dispatching-parallel-agents` |
| Many tasks, complex dependencies, need coordination | `swarm-planner` (this skill) |
| Sequential pipeline | `autonomous-loops` Pattern 1 |
| Ongoing loop with no fixed end | `autonomous-loops` Pattern 3 |

---

## Phase 1: Decompose the Work

Break the goal into atomic work units (AWUs):

**AWU requirements:**
- Can be completed by one agent in one session
- Has clear inputs (files, data, context)
- Has clear outputs (files written, state changed)
- Has defined success criteria

**Dependency mapping:**

```
AWU-1: Design database schema
AWU-2: Implement auth module       [depends on: AWU-1]
AWU-3: Implement user API          [depends on: AWU-1, AWU-2]
AWU-4: Write auth tests            [depends on: AWU-2]
AWU-5: Write API tests             [depends on: AWU-3]
AWU-6: Integration test suite      [depends on: AWU-4, AWU-5]
```

---

## Phase 2: Build the Execution Wave Plan

Group AWUs into waves where each wave contains only items whose dependencies are complete:

```
Wave 1 (parallel): AWU-1
Wave 2 (parallel): AWU-2, AWU-3      ← AWU-1 complete
Wave 3 (parallel): AWU-4, AWU-5      ← AWU-2, AWU-3 complete
Wave 4 (parallel): AWU-6             ← AWU-4, AWU-5 complete
```

---

## Phase 3: Context Package per Agent

Each agent needs a self-contained context package:

```markdown
# Agent Task: [AWU-N] [Name]

## Your Specific Task
[Exactly what this agent must do]

## Inputs Available
- File: [path] — [what it contains]
- Data: [description]

## Expected Outputs
- File: [path] — [what to write]
- State change: [what should be different when done]

## Success Criteria
- [ ] [specific verifiable condition]
- [ ] [specific verifiable condition]

## Constraints
- Do NOT: [what to avoid]
- Use: [tools, patterns, conventions]

## Completion Signal
When done, write a one-line summary to `swarm-log/AWU-N.done`:
"AWU-N: [what was completed]"
```

---

## Phase 4: Orchestrate

```bash
# Wave 1: No dependencies
claude -p "$(cat agents/awu-1-prompt.md)" &

# Wait for wave 1
wait

# Wave 2: Parallel, AWU-1 complete
claude -p "$(cat agents/awu-2-prompt.md)" &
claude -p "$(cat agents/awu-3-prompt.md)" &
wait

# Continue wave by wave
```

### Status tracking

```bash
# Check completion
ls swarm-log/*.done
cat swarm-log/*.done
```

---

## Phase 5: Merge and Verify

After all waves complete:
1. Run the full test suite
2. Check for conflicts between agent outputs (files modified by multiple agents)
3. Verify all AWU success criteria
4. Report: which AWUs passed, which need rework

---

## Hard Rules

- **One AWU per agent.** Don't give one agent two AWUs — it creates hidden dependencies.
- **Context packages are self-contained.** An agent that needs to ask questions is missing context.
- **Completion signals are mandatory.** Without them, the orchestrator can't know when to advance.
- **Validate dependencies before dispatching each wave.** A wave starting with incomplete inputs produces cascading failures.
- **Rate-limit concurrency.** Max 5 agents per wave unless you're certain the API limits allow more.
