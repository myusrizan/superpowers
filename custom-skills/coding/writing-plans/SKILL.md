---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code. Invoke before starting any multi-file change, even if the user says "just do it".
---

# Writing Plans

## Overview

Write comprehensive implementation plans for the AI agent or model that will execute them. Assume zero codebase context and no familiarity with the project's toolset or conventions. Document everything needed: which files to touch, exact code, exact commands, expected outputs. Give the full plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume a skilled executor, but with no project context and limited test design knowledge. Write explicitly — never say "add validation" when you can show the exact code.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
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
````

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits

## Plan Verification

After saving the plan, dispatch a plan-checker subagent to verify it before presenting to the user. The controller passes the full plan text — the checker does not read the file.

**Checker prompt:**
```
You are a plan verifier. Review this implementation plan and identify structural issues only — not style preferences.

Check for:
1. **Atomicity** — each task is one committable unit (write test → verify fail → implement → verify pass → commit). Flag tasks that bundle multiple independent features.
2. **Dependency ordering** — if Task N depends on Task M, M must come first. Flag any out-of-order tasks.
3. **Completeness** — do the tasks cover the stated goal and architecture? Flag obvious missing tasks (e.g., goal says "with auth" but no auth task exists).
4. **TDD compliance** — each task must have: write failing test → run to confirm fail → implement → run to confirm pass → commit. Flag tasks missing these steps.

For each issue: state the task number, the problem, and a specific fix.
If no issues: respond "Plan verified. No structural issues found."

<plan>
[full plan text]
</plan>
```

**If issues found:** Fix them in the saved plan file before proceeding.
**If no issues:** Proceed to execution handoff.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Stay in this session
- Fresh subagent per task + code review

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses superpowers:executing-plans
