---
name: prompting
description: Use when writing prompts, agent task descriptions, or skill instructions and they are getting long, repetitive, or unclear (efficiency mode), or when asked to generate a reusable prompt, system prompt, briefing document, or instruction set from scratch (generation mode). Invoke before sending any prompt to a subagent or external model, or when the user says "generate a prompt", "create a system prompt", or wants to export a workflow as reusable instructions.
---

# Prompting

Two modes. Use the mode that matches your situation.

```
Prompt is getting long / unclear / repetitive  → Mode A: Make It Efficient
Need a new reusable prompt from scratch        → Mode B: Generate It
```

---

## Mode A: Prompt Efficiency

**Core principle:** Say exactly what you need. Constrain everything you can constrain upfront. Every unnecessary token costs latency, context space, and model attention. Every vague instruction costs a clarifying round.

### The 8 Patterns

**1. Goal first, context second**

The model starts generating before reading the full prompt. Lead with the action.

```
❌ "I've been working on the auth system. There's this issue where calling login()
    without a token causes a crash. Could you look into fixing that?"

✅ "Fix: login() crashes when called without a token.
    File: src/auth.ts:45"
```

**2. Constrain the output immediately**

State the format before the model decides on one.

```
❌ "Can you explain how this works?"    → gets 300 words
✅ "Explain in one sentence."           → gets one sentence

❌ "List the options."                  → gets prose + bullets
✅ "List only. No prose."              → gets a clean list
```

**3. Use negative constraints**

"No X" is more reliable than hoping for concision.

```
No explanation.   No new files.   No new dependencies.
Touch only src/auth.ts.   Return only the changed lines.
```

**4. Define done explicitly**

```
❌ "Fix the tests."
✅ "Fix the tests. Done when: all tests pass, no new files created."
```

**5. Reference, don't repeat**

If it's already in context, point to it — don't restate it.

```
❌ "Fix the bug where the function returns null when the input array is empty,
    as I described in my earlier message when I showed you the test output."
✅ "Fix the bug from the test output above."
```

**6. Batch related requests**

One structured message with 3 requests outperforms 3 separate messages.

```
❌ Message 1: "Read the file"  Message 2: "Find the bug"  Message 3: "Fix it"
✅ "Read src/auth.ts. Find the bug causing test failure. Fix it.
    Return: one-line summary of what changed."
```

**7. Structure over prose**

```
❌ "I need you to read the auth file and then find what's wrong and fix it
    and make sure the tests still pass and don't touch anything else."

✅ Task:
   1. Read src/auth.ts
   2. Identify root cause of test failure
   3. Fix it — touch ONLY this file
   4. Verify: run `npm test auth`
   Return: root cause (1 line) + what you changed (1 line)
```

**8. Constrain subagent reports**

```
❌ (no instruction) → agent returns 500-word summary of everything it did
✅ "Return: [what you found] / [what you changed] / [command to verify]"
   → agent returns 3 lines
```

### For Subagent Prompts

Every subagent prompt must include:

```
Scope:       [exactly which files/systems to touch]
Goal:        [what done looks like]
Constraints: [what NOT to do]
Return:      [the format of the output you expect]
```

Example:
```
Fix the 2 failing tests in tests/auth.test.ts.

Scope: tests/auth.test.ts and src/auth.ts only.
Goal: both tests pass.
Constraints: no new files, no new dependencies, do not modify other tests.
Return: root cause (1 sentence) + what you changed (1 sentence).
```

### Domain Front-Loading

Front-load everything a domain requires in the **first message** to avoid follow-up rounds.

**Coding:**
```
Language/runtime: Node 20, TypeScript 5.4
File: src/auth/login.ts:78
Error: "Cannot read properties of undefined (reading 'token')"
Reproduction: call login() with no session cookie set
Constraint: touch only src/auth/login.ts
Goal: fix the crash. Done when: unit test passes, no new deps.
```

**Writing:**
```
Audience: senior engineers, no ML background
Tone: direct, no hedging
Goal: tighten the intro — cut to ≤3 sentences
Constraint: preserve all technical claims exactly
[full text]
```

**Research:**
```
Question: Which Postgres index type is fastest for prefix-search on a 10M-row VARCHAR column?
Context: Postgres 16, query pattern is LIKE 'prefix%', write-heavy table
Already know: GIN supports full-text; unsure about GiST vs. BRIN for this pattern
Output: recommendation + 1-paragraph rationale + one concrete benchmark reference
```

### Efficiency Checklist

Before sending a prompt:
- [ ] Goal stated in the first line?
- [ ] Output format constrained ("Return: ...")?
- [ ] Negative constraints explicit ("No X")?
- [ ] Am I repeating context already in scope?
- [ ] Could I batch this with other related requests?
- [ ] Is "done" defined?
- [ ] (Domain) Have I front-loaded all env/audience/scope context?

### Common Failures

| Pattern | Problem | Fix |
|---------|---------|-----|
| Context dump before goal | Model weights early content more | State goal first |
| No output constraint | Model defaults to verbose | Add "Return: [format]" |
| "If possible" / "maybe" | Model treats as optional | Remove hedging language |
| Asking one thing at a time | Wastes rounds for related tasks | Batch into one message |
| Restating context in scope | Wastes tokens | Reference it, don't repeat |
| No done condition | Model over-delivers | State explicit completion criteria |
| Prose for multi-step tasks | Ambiguous ordering | Use numbered steps |

---

## Mode B: Generate a Prompt

**Core principle:** A generated prompt must be self-contained. The reader has no context from the session that produced it.

**When:** User says "generate a prompt" · "create a system prompt" · "write a briefing" · wants to export session knowledge as reusable instructions.

### Process

**Step 1 — Identify purpose:**
```
Purpose:    What will this prompt be used for? (system prompt, task brief, agent role)
Audience:   Who reads it? (Claude in a fresh session, a subagent, a human)
Scope:      What knowledge/behavior should it encode?
Activation: When should the behavior described trigger?
```

**Step 2 — Gather content** from the current conversation:
- Decisions made and rationale
- Conventions established
- Skills, tools, or workflows referenced
- Patterns that should be preserved across sessions

**Step 3 — Structure the prompt:**

```markdown
# [Prompt Title]

> Purpose: [one sentence on what this prompt enables]

## Context
[What the model needs to know to operate correctly.
State facts, not instructions here.]

## Behavior
[What the model should do. Imperative, present tense.
"Check X before Y." not "You should probably check X."]

## [Domain-specific sections]
[Add as needed: Catalog, Workflows, Rules, Constraints]

## Constraints
[What the model must NOT do. Explicit negatives.]
```

**Step 4 — Apply efficiency patterns** (from Mode A) before finalizing:
- [ ] Goal stated in the first section?
- [ ] Output format constrained where relevant?
- [ ] Negative constraints explicit?
- [ ] Instructions imperative ("Do X") not hedged ("You might want to X")?
- [ ] Any content repeated unnecessarily?

**Step 5 — Save:**

Save to `prompts/[category]/[prompt-name]/prompt.md`

Tell the user: "Prompt saved to `prompts/<path>`. Use it by loading it as a system prompt or pasting at the start of a new session."

### Quality Checks

| Check | Pass condition |
|-------|---------------|
| Self-contained | Reader needs no prior conversation to understand it |
| Imperative | Instructions use present-tense commands, not suggestions |
| No filler | Every sentence carries information |
| Constrained | Model knows what NOT to do, not just what to do |
| Structured | Sections are scannable; reader can find relevant part quickly |
