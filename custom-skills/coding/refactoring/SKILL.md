---
name: refactoring
description: Use when improving the structure, clarity, or design of existing code without changing its observable behavior. Invoke whenever someone says "clean this up", "this is messy", "reorganize this", or "simplify this code".
---

# Refactoring

## Overview

Refactoring changes how code is written, not what it does. The external behavior must be identical before and after.

**Core principle:** Never refactor and change behavior in the same step. If behavior needs to change, that is a separate task.

---

## When to Use

- Code works but is hard to read, extend, or test
- Duplication needs to be removed
- A function/class has grown too large
- Naming no longer reflects intent
- You are about to add a feature and the current structure makes it hard

**Do NOT use this skill when:**
- The code is broken — fix it first (`systematic-debugging`)
- You want to add new behavior — that is a feature (`brainstorming` → `writing-plans`)
- There are no tests — write characterization tests first (see Step 1)

---

## The Process

### Step 1: Establish a safety net

You cannot refactor safely without tests. Before touching any code:

1. **Check existing test coverage.** Run the test suite. Note which paths are covered.
2. **Write characterization tests for uncovered paths.** These tests capture current behavior — even bugs. They are not asserting correct behavior, they are asserting current behavior.

```
Characterization test goal: if I change the code, the test fails.
Not: if the behavior is correct, the test passes.
```

3. **Confirm all tests pass before any refactoring begins.** If tests are failing, stop — fix them first.

### Step 2: Identify the refactoring type

Name what you are doing. This keeps scope contained.

| Refactoring | What it does |
|-------------|-------------|
| Extract function/method | Pull code block into a named function |
| Inline function | Replace call with the function body (reverse of above) |
| Rename | Rename variable, function, class to better reflect intent |
| Extract variable | Name an expression to make it readable |
| Move | Move function/class to a more appropriate module |
| Extract class | Split a class doing too many things |
| Replace conditional with polymorphism | Replace `if type == X` chains with subclasses/strategy |
| Simplify conditional | Remove negation, flatten nesting, use early returns |
| Remove duplication | Extract shared logic into one place |
| Encapsulate field | Replace direct field access with getter/setter |

**One type per session.** Do not combine rename + extract + move in one pass.

### Step 3: Refactor in small steps

Each step must:
1. Leave the code in a working state
2. Pass all tests

**The cycle:**
```
Make one small change → Run tests → Green → Next change
                                  → Red → Undo the change → Understand why → Try differently
```

Never accumulate multiple changes before running tests. If tests go red, undo the last change immediately — do not fix forward unless the failure is obviously from the refactor.

### Step 4: Verify behavioral equivalence

After completing the refactoring:

- [ ] All pre-refactoring tests still pass with no modifications to test assertions
- [ ] No new public API was added or removed
- [ ] No behavior was added, removed, or changed
- [ ] If any test had to be updated: confirm the update reflects the rename/move only, not a behavior change

### Step 5: Review the result

- [ ] Is the code easier to read than before?
- [ ] Is the naming clearer?
- [ ] Is the scope smaller (functions shorter, classes more focused)?
- [ ] Would a new reader understand it faster?

If the answer to all of these is yes — the refactoring is complete. If not, identify what still needs work and repeat the cycle.

---

## Hard Rules

- **Tests pass before you start. Tests pass after every change.** Not at the end — after every change.
- **Do not refactor broken code.** Fix it first.
- **Do not change behavior while refactoring.** If you find a bug during refactoring, note it and fix it separately after the refactoring is committed.
- **One refactoring type at a time.** Mixing types makes it impossible to attribute test failures.
- **Undo, don't fix forward.** If a change breaks tests, undo it. Understand why. Then try again.

---

## Red Flags — Stop and Reassess

- "I'll just fix this small bug while I'm in here" → separate commit, separate task
- "The tests are wrong, I'll update them to match the new behavior" → you changed behavior, that's a feature
- "I'll refactor and add the new feature at the same time" → split into two tasks
- Tests are failing before you start → fix them before refactoring
- No tests exist → write characterization tests before refactoring

---

## Common Failures

| Failure | Consequence |
|---------|------------|
| Refactoring without tests | No way to know if behavior changed |
| Running tests only at the end | Hard to identify which change broke things |
| Mixing refactoring with behavior change | Impossible to review or revert cleanly |
| Updating test assertions to match new behavior | Silently changing behavior under the guise of refactoring |
| Scope creep — "while I'm here..." | Large, hard-to-review diffs with mixed intent |
