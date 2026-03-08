---
name: code-review
description: Use when completing tasks or features and needing review before merging (as requester), when dispatched as a subagent to perform structured review (as reviewer), or when receiving feedback and deciding how to respond (as recipient). Invoke before any merge, push to main, or when receiving review feedback.
---

# Code Review

Three roles are covered by this skill. Read the role that matches your situation.

---

## Role A: Requesting Review

**When:** You have completed implementation and need a review before merging.

**Core principle:** Review early, review often. Never skip because "it's simple."

### When to Request

**Mandatory:** After each task in subagent-driven development · After completing a major feature · Before merge to main

**Optional but valuable:** When stuck (fresh perspective) · Before refactoring · After fixing a complex bug

### How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code-review subagent:**

Read `code-review/reviewer-prompt.md`, fill in the placeholders, then dispatch using the **Task tool** with `subagent_type: general-purpose`. Do NOT use the Skill tool — this is a prompt template, not a registered skill.

**Placeholders:**
- `{WHAT_WAS_IMPLEMENTED}` — what you just built
- `{PLAN_OR_REQUIREMENTS}` — what it should do
- `{BASE_SHA}` — starting commit
- `{HEAD_SHA}` — ending commit
- `{DESCRIPTION}` — brief summary

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back with technical reasoning if reviewer is wrong

> **For large PRs or high-stakes merges:** dispatch 2 independent reviewer subagents in parallel. A finding in both carries higher confidence. Discard findings that appear in only one review without clear rationale.

### Integration with Workflows

- **Subagent-Driven Development:** Review after EACH task
- **Executing Plans:** Review after each batch (3 tasks)
- **Ad-Hoc Development:** Review before merge

---

## Role B: Performing Review (as dispatched subagent)

**When:** You have been dispatched as a code-reviewer subagent.

**Core principle:** Spec compliance before code quality. Signal quality over volume. False positives erode trust faster than missed issues.

### What to Report vs. Skip

**Report only — high-signal findings (confidence ≥ 80):**
- Missing requirements · definitively wrong behavior · syntax/type errors · logic producing wrong results · security vulnerabilities with clear exploit path · errors swallowed on critical paths

**Never report:**
- Style preferences · subjective improvements · potential issues needing external context · things that could be optimized but aren't problems · missing tests for already-tested behavior · YAGNI suggestions

### Confidence Scoring

| Score | Meaning | Action |
|-------|---------|--------|
| 90–100 | Certain — provably wrong or missing | Report |
| 80–89 | High confidence | Report |
| 60–79 | Medium — possible issue | Validate or drop |
| < 60 | Low — speculation | Drop silently |

Only report findings with confidence ≥ 80.

### Phase 1: Spec Compliance Review

Read spec/requirements/plan and verify implementation matches exactly.

```
SPEC COMPLIANCE: ✅ PASS / ❌ FAIL

Issues (if any):
- Missing: [what the spec required that's absent]
- Extra: [what was added beyond spec]
- Mismatch: [what behaves differently than spec describes]
```

If FAIL: return findings. Implementer must fix before Phase 2.

### Phase 2: Code Quality Review

| Dimension | What to check |
|-----------|--------------|
| **Correctness** | Does the logic actually work? Edge cases handled? |
| **Tests** | Do tests verify behavior, not implementation? |
| **Clarity** | Can someone read this in 5 minutes? |
| **Duplication** | Is DRY violated unnecessarily? |
| **Error handling** | Failures caught and communicated appropriately? |
| **Security** | Input validation issues, injection vectors, exposed secrets? |
| **Performance** | Obvious O(n²) where O(n) is straightforward? |

**Issue severity:** Critical · Important · Minor

```
CODE QUALITY: ✅ APPROVED / ⚠️ APPROVED WITH NOTES / ❌ NEEDS CHANGES

Strengths:
- [what's done well]

Issues:
- Critical [conf: 95]: [description] at [location]
- Important [conf: 82]: [description] at [location]

Assessment: [Ready to proceed / Needs fixes before proceeding]
```

### Validation Pass (Before Reporting)

For every candidate finding:
1. Can I quote the specific line(s)?
2. Is this definitely wrong, or just different from how I'd do it?
3. Does the surrounding context change my assessment?
4. Is my confidence ≥ 80?

### How to Examine the Code

```bash
git diff {BASE_SHA}..{HEAD_SHA}
```

Read changed files in full context when the diff alone is ambiguous. Run the test suite if available.

---

## Role C: Receiving Review

**When:** You have received code review feedback and need to respond and implement.

**Core principle:** Technical evaluation, not emotional performance. Verify before implementing.

### The Response Pattern

```
1. READ:      Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY:    Check against codebase reality
4. EVALUATE:  Technically sound for THIS codebase?
5. RESPOND:   Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

### Forbidden Responses

**NEVER:** "You're absolutely right!" · "Great point!" · "Let me implement that now" (before verification) · any gratitude expression (say "Fixed." not "Thanks for catching that!")

**INSTEAD:** Restate the technical requirement · ask clarifying questions · push back with technical reasoning if wrong · just start working

### Handling Unclear Feedback

If any item is unclear: STOP. Do not implement anything. Ask for clarification on unclear items first. Partial understanding = wrong implementation.

### From External Reviewers

Before implementing any suggestion:
1. Check: technically correct for THIS codebase?
2. Check: breaks existing functionality?
3. Check: reason for current implementation?
4. Check: conflicts with your human partner's decisions?

If suggestion seems wrong: push back with technical reasoning.

### YAGNI Check

If reviewer suggests "implementing properly" — grep the codebase for actual usage first. If unused: suggest removing it.

### Implementation Order

1. Clarify anything unclear FIRST
2. Blocking issues → simple fixes → complex fixes
3. Test each fix individually
4. Verify no regressions

### Acknowledging Correct Feedback

```
✅ "Fixed. [Brief description of what changed]"
✅ "Good catch — [specific issue]. Fixed in [location]."
✅ [Just fix it and show in the code]

❌ "You're absolutely right!" ❌ "Great point!" ❌ "Thanks for [anything]"
```

### GitHub Thread Replies

Reply in the inline comment thread: `gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`
Not as a top-level PR comment.
