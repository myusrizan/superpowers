---
name: autonomous-loops
description: Use when designing Claude to run autonomously in loops — automated pipelines, continuous PR workflows, or multi-agent orchestration. Invoke when designing automated scripts, batch processing, recurring tasks, or any workflow that loops without user input.
---

# Autonomous Loops

## Overview

Claude can run non-interactively in loops — executing tasks repeatedly, chaining outputs as inputs, and persisting state across iterations. The right loop pattern depends on the task complexity and the degree of autonomy required.

**Core principle:** Separate concerns across different agent processes rather than constraining a single agent with competing instructions. Use the filesystem for state persistence across iterations.

---

## Pattern 1: Sequential Pipeline

The simplest loop. Break a daily workflow into a sequence of non-interactive `claude -p` calls.

```bash
#!/bin/bash
# daily-dev-pipeline.sh

# Step 1: Analyze current state
claude -p "Review open issues and prioritize top 3 for today. Write to docs/today-plan.md" \
  --output-format stream-json > /dev/null

# Step 2: Implement based on analysis
claude -p "Read docs/today-plan.md and implement the highest priority item" \
  --output-format stream-json > /dev/null

# Step 3: Verify implementation
claude -p "Run tests, check for regressions, write summary to docs/session-summary.md" \
  --output-format stream-json > /dev/null
```

**When to use:** Predictable multi-step workflows where each step's input is the previous step's output.

**State passing:** Each process reads from and writes to known files. The filesystem is the message bus.

---

## Pattern 2: De-Sloppify Pass

A cleanup agent that runs after the implementation agent to remove over-engineering.

```bash
# Implement first
claude -p "Implement the feature described in TASK.md"

# Then clean up
claude -p "Review the code just written. Remove:
- Tests that verify language/framework behavior (not our logic)
- Over-defensive error handling for impossible cases
- Unnecessary abstractions for single-use code
- Comments that restate what the code does
Do not change functionality. Output diff summary to CLEANUP_LOG.md"
```

**Why it works:** The implementation agent and the cleanup agent have different objectives. One maximizes correctness, the other minimizes complexity. A single agent trying to do both compromises both.

**When to use:** After any implementation pass. Especially useful for AI-generated code, which tends toward over-engineering.

---

## Pattern 3: Infinite Agentic Loop

An orchestrator that continuously spawns subagents, each working on a unique creative direction.

```bash
# orchestrator.sh
SPEC=$(cat SPEC.md)
ITERATION=0

while true; do
  ITERATION=$((ITERATION + 1))
  DIRECTION=$(claude -p "Generate a unique creative direction for iteration $ITERATION that hasn't been tried yet. Read COMPLETED_DIRECTIONS.md for history.")

  claude -p "
  Spec: $SPEC
  Direction: $DIRECTION
  Implement this variation. Save to output/iteration-$ITERATION/
  Append direction to COMPLETED_DIRECTIONS.md
  " &

  # Rate limit: max 3 concurrent agents
  if (( ITERATION % 3 == 0 )); then
    wait
  fi
done
```

**Key feature:** Each subagent receives the full spec plus a unique direction to prevent duplication. The `COMPLETED_DIRECTIONS.md` file prevents the orchestrator from assigning the same direction twice.

**When to use:** Creative generation tasks where multiple independent variations are valuable (UI designs, test scenarios, approach exploration).

---

## Pattern 4: Continuous PR Loop

An automated workflow that creates PRs, waits for CI, and iterates.

```bash
# pr-loop.sh
TASK_NOTES="SHARED_TASK_NOTES.md"

while true; do
  # Read current state from shared notes
  CONTEXT=$(cat "$TASK_NOTES" 2>/dev/null || echo "Fresh start")

  # Implement next iteration
  claude -p "
  Context from previous iterations:
  $CONTEXT

  Task: Continue working on the feature.
  After implementing: append summary of changes and blockers to $TASK_NOTES
  Create a PR if changes are ready for review.
  "

  # Check if PR was created
  PR_NUMBER=$(gh pr list --json number --jq '.[0].number' 2>/dev/null)
  if [ -n "$PR_NUMBER" ]; then
    # Wait for CI
    gh pr checks "$PR_NUMBER" --watch

    # Check CI status
    CI_STATUS=$(gh pr checks "$PR_NUMBER" --json state --jq '.[0].state')
    if [ "$CI_STATUS" = "SUCCESS" ]; then
      gh pr merge "$PR_NUMBER" --auto
      break
    fi
    # If CI failed, next iteration will read the notes and fix
  fi

  sleep 60
done
```

**Critical component: `SHARED_TASK_NOTES.md`**

This file is the bridge between loop iterations. Each iteration:
1. Reads what happened before
2. Does its work
3. Writes what it did and what's blocked

Without it, each iteration starts blind.

**When to use:** Automated issue resolution, repetitive maintenance tasks, continuous improvement workflows.

---

## Pattern 5: RFC-Driven DAG (Advanced)

For complex multi-agent workflows requiring dependency management.

```
RFC → Decomposition → DAG of work units
                           ↓
              ┌────────────┼────────────┐
              │            │            │
           Agent A      Agent B      Agent C
        (auth module) (data layer) (API layer)
              │            │            │
              └────────────┼────────────┘
                     Merge Queue
                     (dependency-ordered)
```

**Structure:**
1. An RFC (Request for Comments) document defines the full scope
2. A decomposition agent breaks the RFC into work units with dependencies
3. Work units form a directed acyclic graph (DAG) — units with no dependencies run first
4. A merge queue processes completed units in dependency order
5. An eviction/recovery system handles failed units

**When to use:** Large feature implementations with well-defined module boundaries. Requires investment in orchestration infrastructure.

---

## State Persistence Patterns

### File-based state (simple)
```bash
echo "Last completed: step 3" >> .pipeline-state
LAST=$(tail -1 .pipeline-state)
```

### Structured state (recommended for long loops)
```json
// .pipeline-state.json
{
  "iteration": 7,
  "last_completed": "implement-auth",
  "blockers": ["missing test for edge case"],
  "next_action": "write test for empty token case"
}
```

### State passing via task notes
```
SHARED_TASK_NOTES.md:
---
Iteration 1: Implemented basic auth flow. Tests pass.
Iteration 2: Added token refresh. CI failed on Firefox.
Iteration 3: Fixed Firefox issue. PR #45 created.
Blocker: Awaiting code review.
```

---

## Error Handling in Loops

When an iteration fails, capture context — don't retry blindly:

```bash
if ! claude -p "Execute task. On failure, write error details to ERROR_LOG.md"; then
  ERROR=$(cat ERROR_LOG.md)
  claude -p "Previous iteration failed with: $ERROR. Diagnose and fix before retrying."
fi
```

**Rule:** Blind retries amplify errors. Diagnosis before retry.

### Stagnation Detection

A loop can fail silently — Claude appears to work but nothing actually changes. Detect this proactively:

**Signals of stagnation (check between iterations):**
- No file modifications since the previous iteration (`git diff --stat` returns nothing)
- Identical or near-identical error message repeated across 2+ consecutive iterations
- Claude output declining in length/substance (summaries replacing actions)

**Response to stagnation:**
1. Do NOT continue — a stagnating loop compounds the problem
2. Log the detected stagnation signal to the state file
3. Transition to HALF_OPEN (reduce scope, try a simpler subtask) or escalate to the user

```bash
# Check for file changes as a progress signal
FILES_CHANGED=$(git diff --stat HEAD 2>/dev/null | wc -l)
if (( FILES_CHANGED == 0 && ITERATION > 1 )); then
  echo "STAGNATION: No file changes detected at iteration $ITERATION. Halting." >> .pipeline-state
  exit 1
fi
```

---

## Circuit Breaker Pattern

For long-running loops, implement a circuit breaker to prevent runaway failures and enable recovery without manual intervention.

**Three states:**

| State | Meaning | Behavior |
|-------|---------|----------|
| CLOSED | Normal operation | Loop runs; progress detected |
| HALF_OPEN | Cautious recovery | Loop runs with reduced scope; testing if progress resumes |
| OPEN | Failure mode | Loop halts; wait for cooldown or manual reset |

**Transition triggers:**
- CLOSED → HALF_OPEN: N consecutive iterations with no progress (default: 2–3)
- HALF_OPEN → CLOSED: Progress detected again
- HALF_OPEN → OPEN: Progress still absent after probe iteration
- OPEN → HALF_OPEN: Cooldown timer elapsed (e.g., 30 min) or manual reset

**Why this matters over a simple retry:** A plain retry loop can amplify errors (repeated bad writes, repeated API calls hitting the same wall). The circuit breaker introduces a recovery pause and probes with reduced scope before resuming full operation.

```bash
CB_STATE="CLOSED"
NO_PROGRESS_COUNT=0
CB_NO_PROGRESS_THRESHOLD=3

after_each_iteration() {
  if (( FILES_CHANGED == 0 )); then
    NO_PROGRESS_COUNT=$((NO_PROGRESS_COUNT + 1))
  else
    NO_PROGRESS_COUNT=0
    CB_STATE="CLOSED"
  fi

  if (( NO_PROGRESS_COUNT >= CB_NO_PROGRESS_THRESHOLD )); then
    if [ "$CB_STATE" = "CLOSED" ]; then
      CB_STATE="HALF_OPEN"
    elif [ "$CB_STATE" = "HALF_OPEN" ]; then
      CB_STATE="OPEN"
      echo "Circuit OPEN. Halting loop." >> .pipeline-state
      exit 1
    fi
  fi
}
```

---

## Termination Conditions

**Every loop MUST define when to stop before it starts.** Without explicit termination conditions, automated pipelines can run indefinitely, exhaust API credits, or corrupt state via repeated failed writes.

### Dual-condition exit verification

A common failure mode: Claude outputs language like "done", "complete", or "finished" during productive work — triggering false-positive termination. Require **both** conditions to be true before stopping:

1. **Heuristic signal** — output contains a completion phrase, a sentinel file exists, exit code is 0
2. **Explicit confirmation** — Claude is asked directly "Is the task fully complete? Reply YES or NO only" and answers YES

```bash
# After Claude runs, check heuristic first
if echo "$OUTPUT" | grep -qi "task complete"; then
  # Then verify explicitly before trusting it
  CONFIRM=$(claude -p "The previous step reported completion. Is the task truly done? Reply YES or NO only.")
  if [ "$CONFIRM" = "YES" ]; then
    break
  fi
fi
```

**Why both:** Heuristics catch the common case cheaply. Explicit confirmation catches false positives from mid-task progress narration.

### Termination checklist — define BEFORE starting any loop

**Success condition (primary exit):**
- [ ] What state means "done"? (PR merged, all items processed, N iterations complete)
- [ ] How does the loop detect it? (file exists, command exit code, API response field)
- [ ] Is dual-condition verification needed? (yes for any loop running unattended)

**Failure / escalation condition (force stop):**
- [ ] Max iteration limit set? (default: 10 for open-ended loops)
- [ ] Max elapsed time defined? (default: 30 minutes for automated pipelines)
- [ ] Stuck-state detection? (same error repeating across 2+ consecutive iterations → stop and escalate)
- [ ] Circuit breaker configured? (for loops expected to run >5 iterations unattended)

**User escalation triggers — surface instead of continuing:**
- Iteration limit reached with task still incomplete
- Same blocker in 2+ consecutive iteration logs
- Error requiring external action (permissions, credentials, merge conflict requiring judgment)
- Tests keep failing after 3+ fix attempts
- Circuit breaker reached OPEN state

### In code

```bash
MAX_ITERATIONS=10
ITERATION=0

while true; do
  ITERATION=$((ITERATION + 1))

  # Termination: hard ceiling
  if (( ITERATION > MAX_ITERATIONS )); then
    echo "MAX_ITERATIONS ($MAX_ITERATIONS) reached. Task incomplete. Review pipeline state."
    exit 1
  fi

  # ... do work, write results to state file ...

  # Termination: success condition (dual-condition)
  if echo "$OUTPUT" | grep -qi "complete\|done\|finished"; then
    CONFIRM=$(claude -p "Is the task truly done? Reply YES or NO only.")
    if [ "$CONFIRM" = "YES" ]; then
      echo "Done at iteration $ITERATION."
      break
    fi
  fi
done
```

**Rule:** `while true` with no max-iteration guard is a bug. Always set a ceiling.

---

## Context Injection per Iteration

Each Claude invocation in a loop starts with a blank slate. Inject current loop state explicitly into every prompt so Claude can make informed decisions:

```bash
claude -p "
Loop context:
- Iteration: $ITERATION of $MAX_ITERATIONS
- Tasks remaining: $(wc -l < TASK_QUEUE.md)
- Last iteration result: $(tail -5 .pipeline-state)
- Circuit breaker state: $CB_STATE

Task: Continue working on the next item in TASK_QUEUE.md.
On completion, remove the item from TASK_QUEUE.md and append a summary to .pipeline-state.
"
```

**What to inject:**
- Current iteration number and ceiling
- Remaining work (task count, queue file)
- Summary of the previous iteration's outcome
- Any active failure state (circuit breaker, blockers)

**What NOT to inject:** Full history of all iterations — this bloats the prompt and dilutes focus. Summarize instead.

---

## Hard Rules

- **One concern per agent.** Don't ask one agent to implement and clean up and test. Separate agents.
- **Filesystem is the state.** Don't rely on conversation history across process boundaries — it doesn't persist.
- **Shared task notes for context.** Any loop longer than 1 iteration needs a state file.
- **Rate-limit concurrent agents.** Unbounded concurrent launches exhaust API rate limits.
- **Capture error context.** Failed iterations must write diagnostics before the next iteration runs.
- **Set termination conditions first.** Max iterations, max time, and escalation triggers defined before the loop starts.
- **Detect stagnation, not just errors.** A loop producing no file changes is failing even if it returns exit 0.
- **Use dual-condition exit for unattended loops.** Heuristic signals alone produce false-positive termination.
- **Circuit breaker for long loops.** Any loop expected to run >5 iterations unattended needs CLOSED/HALF_OPEN/OPEN state management.
