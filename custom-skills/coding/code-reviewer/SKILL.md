---
name: code-reviewer
description: Use when dispatched as a subagent to perform structured code review — examines implementation against spec for compliance, then assesses code quality and best practices
---

# Code Reviewer

## Overview

Perform rigorous, two-phase code review: first verify the implementation matches the spec, then evaluate code quality. Return structured findings with severity.

**Core principle:** Spec compliance before code quality. A beautifully written implementation that does the wrong thing is a failure.

**Signal quality over volume.** False positives erode trust faster than missed issues. Only report findings you would stake your credibility on. A short list of real problems is better than a long list of maybes.

**This skill is invoked by subagent dispatch from `requesting-code-review`.** When you are dispatched as a code-reviewer, follow this skill exactly.

---

## What to Report vs. What to Skip

### Report only — high-signal findings

**Spec compliance (Phase 1):**
- Requirements that are missing entirely
- Behavior that is definitively wrong relative to the spec

**Code quality (Phase 2):**
- Code that won't compile (syntax errors, type errors, missing imports)
- Logic that produces definitively wrong results
- Security vulnerabilities with a clear exploit path
- Error handling that silently swallows exceptions on critical paths

### Never report — low-signal noise

- Style preferences and formatting (use a linter, not a reviewer)
- Subjective improvements ("could be cleaner", "I'd have done it differently")
- Potential issues that require external context you don't have ("this might be a problem if…")
- Things that could be optimized but aren't causing real problems
- Missing tests for behavior that is already working and tested elsewhere
- Suggestions for features not in the spec (YAGNI)

**The signal test:** If you can't point to a specific line and say "this will fail / this is wrong / this violates the spec at section X" — don't report it.

---

## Confidence Scoring

Assign every finding a confidence score before reporting it:

| Score | Meaning | Action |
|-------|---------|--------|
| 90–100 | Certain — provably wrong or missing | Report |
| 80–89 | High confidence — very likely an issue | Report |
| 60–79 | Medium — possible issue, needs more context | Validate or drop |
| < 60 | Low — speculation | Drop silently |

**Only report findings with confidence ≥ 80.** For findings scoring 60–79, do a validation pass (re-read the code, check if there's context that resolves it) before deciding to include or drop.

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
- Critical [conf: 95]: [description] at [location]
- Important [conf: 82]: [description] at [location]
- Minor [conf: 80]: [description] at [location]

Assessment: [Ready to proceed / Needs fixes before proceeding]
```

Include confidence score inline with each finding. Only list findings ≥ 80.

---

## Validation Pass — Before Reporting Anything

After collecting candidate findings from both phases, validate each one before including it in the output:

For every candidate finding, ask:
1. **Can I quote the specific line(s)?** If not, the finding is too vague to report.
2. **Is this definitely wrong, or just different from how I'd do it?** If the latter, drop it.
3. **Does reading the surrounding context change my assessment?** Re-read 10–20 lines around the issue before finalising.
4. **What is my confidence score?** If < 80, drop it.

This validation pass is not optional. It is what separates a useful review from a noisy one.

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
