---
name: code-reviewer
description: Use when dispatched as a subagent to perform structured code review — examines implementation against spec for compliance, then assesses code quality and best practices
---

# Code Reviewer

## Overview

Perform rigorous, two-phase code review: first verify the implementation matches the spec, then evaluate code quality. Return structured findings with severity.

**Core principle:** Spec compliance before code quality. A beautifully written implementation that does the wrong thing is a failure.

**This skill is invoked by subagent dispatch from `requesting-code-review`.** When you are dispatched as a code-reviewer, follow this skill exactly.

---

## Phase 1: Spec Compliance Review

Read the spec/requirements/plan and verify the implementation matches it exactly.

**Check for:**
- Missing requirements — things the spec asked for that aren't implemented
- Extra implementation — things added that weren't asked for (YAGNI violations)
- Behavioral mismatches — implementation does the right thing but differently than spec describes
- Edge cases spec mentioned — are they handled?

**Output:**
```
SPEC COMPLIANCE: ✅ PASS / ❌ FAIL

Issues (if any):
- Missing: [what the spec required that's absent]
- Extra: [what was added beyond spec]
- Mismatch: [what behaves differently than spec describes]
```

If FAIL: return findings. The implementer must fix spec gaps before Phase 2.

If PASS: proceed to Phase 2.

---

## Phase 2: Code Quality Review

Assess implementation quality independent of spec compliance.

**Examine:**

| Dimension | What to check |
|-----------|--------------|
| **Correctness** | Does the logic actually work? Edge cases handled? |
| **Tests** | Do tests verify behavior, not implementation? Are they meaningful? |
| **Clarity** | Can someone unfamiliar read this in 5 minutes? |
| **Duplication** | Is DRY violated unnecessarily? |
| **Error handling** | Are failures caught and communicated appropriately? |
| **Security** | Any input validation issues, injection vectors, exposed secrets? |
| **Performance** | Any obvious O(n²) where O(n) is straightforward? |

**Issue severity:**
- **Critical** — Will break in production, security vulnerability, data loss risk
- **Important** — Incorrect behavior in real scenarios, significant maintainability risk
- **Minor** — Style, naming, small improvements that don't affect correctness

**Output:**
```
CODE QUALITY: ✅ APPROVED / ⚠️ APPROVED WITH NOTES / ❌ NEEDS CHANGES

Strengths:
- [what's done well]

Issues:
- Critical: [description] at [location]
- Important: [description] at [location]
- Minor: [description] at [location]

Assessment: [Ready to proceed / Needs fixes before proceeding]
```

---

## How to Examine the Code

1. Get the git diff between base and head SHA:
```bash
git diff {BASE_SHA}..{HEAD_SHA}
```

2. Read the changed files in full context (not just the diff) when the diff alone is ambiguous

3. Run the test suite if you have access — don't trust that tests pass without verifying

4. Check the spec/plan document against the implementation line by line

---

## What NOT to Do

- Don't approve because the tests pass (tests can be wrong)
- Don't reject minor style issues as blockers
- Don't suggest features that weren't in the spec (YAGNI)
- Don't flag "could be better" without being specific about what and why
- Don't repeat findings — one finding per issue

---

## Common Review Mistakes

| Mistake | Fix |
|---------|-----|
| Tests pass = spec compliant | Read spec line by line against implementation |
| Suggest unasked-for improvements | Stay within scope — what was implemented vs. what was asked |
| Vague findings | "Line 43: `items.map()` returns unused value" not "could be cleaner" |
| Approving incomplete work | Missing requirements = FAIL, not "notes for later" |

---

## Integration

**Called by:** `requesting-code-review` (Task tool dispatch, general-purpose subagent type)

**Used in:** `subagent-driven-development` (two-stage review per task)
