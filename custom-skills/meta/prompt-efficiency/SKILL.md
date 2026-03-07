---
name: prompt-efficiency
description: Use when writing prompts, agent task descriptions, or skill instructions. Invoke whenever a prompt is getting long, repetitive, or unclear — before sending to a subagent or external model.
---

# Prompt Efficiency

## Overview

Every unnecessary token in a prompt costs latency, context space, and model attention. Every vague instruction costs a clarifying round.

**Core principle:** Say exactly what you need. Constrain everything you can constrain upfront.

---

## The 8 Patterns

### 1. Goal first, context second

The model starts generating before reading the full prompt. Lead with the action.

```
❌ "I've been working on the auth system. There's this issue where calling login()
    without a token causes a crash. Could you look into fixing that?"

✅ "Fix: login() crashes when called without a token.
    File: src/auth.ts:45"
```

### 2. Constrain the output immediately

State the format you want before the model decides on one.

```
❌ "Can you explain how this works?"       → gets 300 words
✅ "Explain in one sentence."              → gets one sentence

❌ "List the options."                     → gets prose + bullet mix
✅ "List only. No prose."                  → gets a clean list

❌ "Write the function."                   → gets function + explanation + usage
✅ "Write the function. No explanation."   → gets just the function
```

### 3. Use negative constraints

"No X" is more reliable than hoping for concision.

```
No explanation.
No new files.
No new dependencies.
No tests.
Touch only src/auth.ts.
Return only the changed lines.
```

### 4. Define done explicitly

Without a completion signal, the model keeps producing output.

```
❌ "Fix the tests."
✅ "Fix the tests. Done when: all tests pass, no new files created."

❌ "Implement the feature."
✅ "Implement the feature. Done when: the 3 acceptance criteria in the spec are met."
```

### 5. Reference, don't repeat

If it's already in context, point to it — don't restate it.

```
❌ "Fix the bug where the function returns null when the input array is empty,
    as I described in my earlier message when I showed you the test output."

✅ "Fix the bug from the test output above."
```

### 6. Batch related requests

One structured message with 3 requests outperforms 3 separate messages.

```
❌ Message 1: "Read the file"
   Message 2: "Now find the bug"
   Message 3: "Now fix it"

✅ "Read src/auth.ts. Find the bug causing test failure. Fix it.
    Return: one-line summary of what changed."
```

### 7. Structure over prose

Tables and bullets communicate more per token than prose.

```
❌ "I need you to read the auth file and then find what's wrong and fix it and
    make sure the tests still pass and don't touch anything else."

✅ Task:
   1. Read src/auth.ts
   2. Identify root cause of test failure
   3. Fix it — touch ONLY this file
   4. Verify: run `npm test auth`
   Return: root cause (1 line) + what you changed (1 line)
```

### 8. Constrain agent reports

Subagent return messages bloat context. Specify the format.

```
❌ (no instruction) → agent returns 500-word summary of everything it did

✅ "Return: [what you found] / [what you changed] / [command to verify]"
   → agent returns 3 lines
```

---

## For Subagent Prompts Specifically

Every subagent prompt should include:

```
Scope:    [exactly which files/systems to touch]
Goal:     [what done looks like]
Constraints: [what NOT to do]
Return:   [the format of the output you expect]
```

Example:
```
Fix the 2 failing tests in tests/auth.test.ts.

Scope: tests/auth.test.ts and src/auth.ts only.
Goal: both tests pass.
Constraints: no new files, no new dependencies, do not modify other tests.
Return: root cause (1 sentence) + what you changed (1 sentence).
```

---

## Common Failures

| Pattern | Problem | Fix |
|---------|---------|-----|
| Context dump before goal | Model weights early content more | State goal first |
| No output constraint | Model defaults to verbose | Add "Return: [format]" |
| "If possible" / "maybe" | Model treats as optional | Remove hedging language |
| Asking one thing at a time | Wastes rounds for related tasks | Batch into one message |
| Restating context already in scope | Wastes tokens | Reference it, don't repeat it |
| No done condition | Model over-delivers | State explicit completion criteria |
| Prose instructions for multi-step tasks | Ambiguous ordering | Use numbered steps |

---

## Domain Patterns

Front-load everything a domain requires in the **first message**. These are the most common sources of unnecessary follow-up rounds.

### Coding

Bad opening:
```
❌ "Can you help me fix this bug?"
   → Follow-up needed: what file? what error? what environment?
```

Good opening (everything in one message):
```
✅ Language/runtime: Node 20, TypeScript 5.4
   File: src/auth/login.ts:78
   Error: "Cannot read properties of undefined (reading 'token')"
   Reproduction: call login() with no session cookie set
   Constraint: touch only src/auth/login.ts
   Goal: fix the crash. Done when: unit test passes, no new deps.
```

Rule: provide environment, file path, full error message, reproduction step, and constraints in the **opening message**.

### Writing

Bad opening:
```
❌ "Edit this for me." [pastes text]
   → Follow-up needed: tone? audience? scope of changes?
```

Good opening:
```
✅ Audience: senior engineers, no background in ML
   Tone: direct, no hedging
   Goal: tighten the intro paragraph — cut to ≤3 sentences
   Constraint: preserve all technical claims exactly
   [full text]
```

Rule: state audience, tone, scope, and constraints **before** the content. Submit the complete text — never ask for partial edits then paste more.

### Research

Bad opening:
```
❌ "Research this topic for me."
   → Follow-up needed: scope? output format? what you already know?
```

Good opening:
```
✅ Question: Which Postgres index type is fastest for prefix-search on a 10M-row VARCHAR column?
   Context: using Postgres 16, query pattern is LIKE 'prefix%', write-heavy table
   Already know: GIN supports full-text; unsure about GiST vs. BRIN for this pattern
   Output: recommendation + 1-paragraph rationale + one concrete benchmark reference
```

Rule: define the exact question, provide all relevant constraints/context you have, state what you already know (prevents re-explaining the obvious), and specify output format upfront.

---

## Efficiency Checklist

Before sending a prompt:

- [ ] Goal stated in the first line?
- [ ] Output format constrained ("Return: ...")?
- [ ] Negative constraints explicit ("No X")?
- [ ] Am I repeating context already in scope?
- [ ] Could I batch this with other related requests?
- [ ] Is "done" defined?
- [ ] (Domain check) Have I front-loaded all env/audience/scope context so no follow-up round is needed?
