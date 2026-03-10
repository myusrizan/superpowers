---
name: feature-workflow
description: Use when starting any new feature, component, or behavior change before writing any code (brainstorming phase), when you have a spec or requirements for a multi-step task before touching code (planning phase), or when you have a written implementation plan to execute (execution phase). Required gate before ANY implementation.
---

# Feature Workflow

Three sequential phases: **Brainstorm → Plan → Execute**. Always start from the earliest phase appropriate to where you are. Never jump into planning or execution without completing earlier phases.

```
Idea/request ──► BRAINSTORM ──► PLAN ──► EXECUTE ──► finishing-a-development-branch
```

---

## Phase 1: Brainstorm

**When:** Starting any new feature, component, behavior change, or modification.

**Hard gate:** Do NOT write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to every project regardless of perceived simplicity.

### Process

**Checklist — complete in order:**
1. Explore project context (files, docs, recent commits)
2. Ask clarifying questions — one at a time, multiple choice when possible
3. Propose 2–3 approaches with trade-offs and your recommendation
4. Present design section by section, get user approval after each
5. Write design doc to `docs/plans/YYYY-MM-DD-<topic>-design.md` and commit
6. Transition to Phase 2 (Planning)

**One question at a time.** Never ask multiple questions in one message. Only one question per message — if a topic needs more exploration, break it into multiple turns.

**Propose alternatives always.** Lead with your recommended option and explain why.

**YAGNI ruthlessly.** Remove unnecessary features from all proposed designs.

**Terminal state:** Invoking Phase 2 (Planning). Do NOT invoke any other implementation action.

---

## Phase 2: Plan

**When:** You have an approved design or spec and need a detailed implementation plan before touching code. Invoke before starting any multi-file change, even if the user says "just do it."

**Announce:** "I'm using the feature-workflow skill (planning phase) to create the implementation plan."

**Context:** Run in a dedicated worktree (created by `using-git-worktrees` skill).

**Save to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

### Plan Document Header

Every plan MUST start with:

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:feature-workflow (execution phase) to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2–3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

### Task Granularity

Each step is one action (2–5 minutes):

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**
```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**
Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**
```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**
Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**
```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

Rules: exact file paths always · complete code (not "add validation") · exact commands with expected output · DRY, YAGNI, TDD, frequent commits.

### Plan Verification

After saving the plan, dispatch a plan-checker subagent (via Task tool, general-purpose):

```
You are a plan verifier. Review this implementation plan and identify structural issues only.

Check for:
1. Atomicity — each task is one committable unit. Flag tasks bundling multiple independent features.
2. Dependency ordering — if Task N depends on Task M, M must come first.
3. Completeness — do tasks cover the stated goal? Flag obvious missing tasks.
4. TDD compliance — each task must have: write failing test → run to confirm fail → implement → run to confirm pass → commit.

For each issue: state the task number, the problem, and a specific fix.
If no issues: respond "Plan verified. No structural issues found."

<plan>
[full plan text]
</plan>
```

If issues found: fix them in the saved plan file. Then offer execution choice:

**"Plan complete and saved. Two execution options:**
**1. Subagent-Driven (this session)** — dispatch fresh subagent per task, review between tasks
**2. Parallel Session** — open new session with execution phase, batch execution with checkpoints
**Which approach?"**

---

## Phase 3: Execute

**When:** You have a written implementation plan to execute — either continuing from Phase 2 or in a separate session.

**Announce:** "I'm using the feature-workflow skill (execution phase) to implement this plan."

### Process

**Step 1: Load and Review Plan**
1. Read the plan file
2. Review critically — identify questions or concerns
3. If concerns: raise them before starting
4. If no concerns: create TodoWrite tasks and proceed

**Step 2: Execute in Batches**

| Task complexity | Batch size |
|-----------------|-----------|
| Quick (< 30 min) | 3 tasks |
| Medium (30–60 min) | 2 tasks |
| Complex (> 60 min) | 1 task |
| External dependencies | 1 task |

When uncertain, default to 1 task to get earlier feedback.

For each task: mark in_progress → follow steps exactly → run verifications → mark completed.

**Step 3: Report After Each Batch**
- Show what was implemented
- Show verification output
- Say: "Ready for feedback."

**Step 4: Complete**

After all tasks verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use `superpowers:finishing-a-development-branch`

### When to Stop

**STOP immediately when:**
- Blocker mid-batch (missing dependency, failing test, unclear instruction)
- Plan has critical gaps
- Verification fails repeatedly

Ask for clarification rather than guessing. Never start on main/master without explicit user consent.
