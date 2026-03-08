---
name: combined-meta-qol-thinking
description: Combined skill set covering meta (skill system, prompting, session memory, sensitive data, CLAUDE.md, skill management), quality-of-life output (documenting, drafting, explaining, grammar correction, researching, summarizing), and thinking (decision-making, reasoning, thinking partner). Invoke when any of these capabilities are needed.
---

<!-- ═══════════════════════════════════════════════════════════════════
     META SKILLS
     ═══════════════════════════════════════════════════════════════════ -->

# Using Superpowers

> **Trigger:** Use at the start of every conversation to discover available skills before taking any action or asking clarifying questions.

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files.

**In other environments:** Check your platform's documentation for how skills are loaded.

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## Skill Priority

When multiple skills could apply:

1. **Process skills first** (brainstorming, debugging) — these determine HOW to approach the task
2. **Output skills second** (summarizing, drafting, explaining) — these guide what to produce

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.

---

# CLAUDE.md Improver

> **Trigger:** Use when auditing, improving, or updating CLAUDE.md files — to keep project memory aligned with the actual codebase. Invoke when a CLAUDE.md might be stale, incomplete, or generic, or when the user asks to "audit the CLAUDE.md" or "check if CLAUDE.md is up to date".

## Overview

CLAUDE.md is Claude's project memory. It tells Claude how to navigate the codebase, which commands to run, what conventions to follow, and what gotchas to avoid. When it's out of date or too generic, every session starts from a worse baseline.

**Core principle:** CLAUDE.md should contain only project-specific, actionable content. Generic advice ("write clean code") that Claude already knows is noise. Missing project-specific content (actual commands, real gotchas, this project's conventions) is a gap.

---

## Phase 1: Discover

Find all CLAUDE.md variants in the project:

```bash
find . -name "CLAUDE.md" -o -name ".claude.local.md" | sort
```

Common locations:
- `/CLAUDE.md` — project root (main file, committed to repo)
- `/.claude.local.md` — local overrides (personal preferences, in `.gitignore`)
- `/packages/*/CLAUDE.md` — package-specific context in monorepos
- `~/.claude/CLAUDE.md` — global default (applies to all projects)

Read each file fully before assessing.

---

## Phase 2: Assess

Score each file against 6 criteria. Be specific about what's missing or stale — not just a score.

### Criteria (each A–F)

| Criterion | A (excellent) | F (failing) |
|-----------|--------------|-------------|
| **Commands & workflows** | Lists actual runnable commands with exact syntax | No commands, or only "run the tests" |
| **Architecture clarity** | Describes where things live, how data flows, key modules | No architecture context |
| **Non-obvious patterns** | Documents gotchas, conventions that aren't in the code | Only states what's already obvious |
| **Conciseness** | Every sentence earns its place | Bloated with generic advice |
| **Currency** | Commands work, packages referenced exist | Stale commands, removed packages |
| **Actionability** | Reader can copy-paste commands and act | Vague descriptions requiring interpretation |

### Scoring

| Score | Grade |
|-------|-------|
| 90–100 | A |
| 80–89 | B |
| 70–79 | C |
| 60–69 | D |
| 0–59 | F |

---

## Phase 3: Report

Before making any changes, produce a quality report. Show it to the user before proposing changes.

---

## Phase 4: Propose

Suggest targeted, minimal additions. Show exactly what would be added and why.

**What to add:**
- Commands discovered in `package.json`, `Makefile`, shell scripts that aren't in CLAUDE.md
- Architecture facts: where the business logic lives, what the key modules do
- Gotchas discovered during the session: env var requirements, timing dependencies, non-obvious conventions
- Package relationships in monorepos: which package does what, dependency direction

**What NOT to add:**
- Generic advice Claude already knows ("write tests for your code", "handle errors")
- Obvious things ("the main file is `index.ts`")
- Opinions without project-specific grounding
- Anything that would be true for any project

---

## Phase 5: Apply

Apply user-approved additions with clear diffs. Don't rewrite sections that are fine — only add what's missing or fix what's stale.

After applying, confirm:
- File still reads top-to-bottom coherently
- No duplicate information introduced
- Commands are runnable (verify with shell if possible)

---

## Hard Rules

- **Only add project-specific content.** If it's true for every project, it doesn't belong here.
- **Commands must be runnable.** Verify that commands listed actually exist before adding them.
- **Report before changing.** Never modify CLAUDE.md without first showing the assessment to the user.
- **Minimal diffs.** Add what's missing, fix what's stale, leave the rest alone.
- **Don't rewrite sections that work.** Improving a B to an A is often not worth the risk of introducing new issues.

---

# Prompting

> **Trigger:** Use when writing prompts, agent task descriptions, or skill instructions and they are getting long, repetitive, or unclear (efficiency mode), or when asked to generate a reusable prompt, system prompt, briefing document, or instruction set from scratch (generation mode). Invoke before sending any prompt to a subagent or external model.

Two modes. Use the mode that matches your situation.

```
Prompt is getting long / unclear / repetitive  → Mode A: Make It Efficient
Need a new reusable prompt from scratch        → Mode B: Generate It
```

---

## Mode A: Prompt Efficiency

**Core principle:** Say exactly what you need. Constrain everything you can constrain upfront. Every unnecessary token costs latency, context space, and model attention. Every vague instruction costs a clarifying round.

### The 8 Patterns

**1. Goal first, context second** — The model starts generating before reading the full prompt. Lead with the action.

**2. Constrain the output immediately** — State the format before the model decides on one.

**3. Use negative constraints** — "No X" is more reliable than hoping for concision.
```
No explanation.   No new files.   No new dependencies.
Touch only src/auth.ts.   Return only the changed lines.
```

**4. Define done explicitly**
```
❌ "Fix the tests."
✅ "Fix the tests. Done when: all tests pass, no new files created."
```

**5. Reference, don't repeat** — If it's already in context, point to it — don't restate it.

**6. Batch related requests** — One structured message with 3 requests outperforms 3 separate messages.

**7. Structure over prose**
```
✅ Task:
   1. Read src/auth.ts
   2. Identify root cause of test failure
   3. Fix it — touch ONLY this file
   4. Verify: run `npm test auth`
   Return: root cause (1 line) + what you changed (1 line)
```

**8. Constrain subagent reports**
```
✅ "Return: [what you found] / [what you changed] / [command to verify]"
```

### For Subagent Prompts

Every subagent prompt must include:
```
Scope:       [exactly which files/systems to touch]
Goal:        [what done looks like]
Constraints: [what NOT to do]
Return:      [the format of the output you expect]
```

### Efficiency Checklist

Before sending a prompt:
- [ ] Goal stated in the first line?
- [ ] Output format constrained ("Return: ...")?
- [ ] Negative constraints explicit ("No X")?
- [ ] Am I repeating context already in scope?
- [ ] Could I batch this with other related requests?
- [ ] Is "done" defined?

---

## Mode B: Generate a Prompt

**Core principle:** A generated prompt must be self-contained. The reader has no context from the session that produced it.

### Process

**Step 1 — Identify purpose:** Purpose · Audience · Scope · Activation

**Step 2 — Gather content** from the current conversation: decisions, conventions, skills/tools referenced, patterns to preserve

**Step 3 — Structure the prompt:**
```markdown
# [Prompt Title]

> Purpose: [one sentence]

## Context
[Facts, not instructions]

## Behavior
[Imperative, present tense. "Check X before Y."]

## Constraints
[What the model must NOT do]
```

**Step 4 — Apply efficiency patterns** (from Mode A) before finalizing.

**Step 5 — Save:** `prompts/[category]/[prompt-name]/prompt.md`

---

# Sensitive Data Guard

> **Trigger:** Use when shared content may contain sensitive data — API keys, passwords, tokens, private keys, credentials, PII, or connection strings — before proceeding with any task involving that content.

## Overview

**Core principle:** Never repeat a sensitive value. Flag the type and location — not the value itself.

## When to Use

**Trigger immediately when you detect:**
- `.env` files, config files, or settings with real values
- Code containing hardcoded credentials or tokens
- Database or service connection strings with embedded credentials
- Log output, error messages, or stack traces containing secrets
- Any paste that includes a key, token, or password field with a non-placeholder value

## Detection Patterns

| Type | Indicators |
|------|-----------|
| OpenAI / Anthropic keys | `sk-`, `sk-ant-` prefixes |
| AWS credentials | `AKIA`, `ASIA` prefixes |
| GitHub tokens | `ghp_`, `gho_`, `ghs_` prefixes |
| Generic API keys | Fields named `api_key`, `apiKey`, `token`, `secret` with non-placeholder values |
| Private keys | `-----BEGIN RSA PRIVATE KEY-----` etc. |
| Database URLs | `postgres://user:pass@host`, `mysql://user:pass@host` |
| PII | SSN, credit card numbers, full names + ID combinations |

**Placeholders are safe:** `API_KEY=your-api-key-here`, `password=<PASSWORD>`, `token=REPLACE_ME`

## Required Actions

### Step 1: STOP
Do not proceed. Do not reference, quote, or repeat any detected value.

### Step 2: Flag what was found
Report **type** and **location** — never the value itself.

### Step 3: Issue revocation warning — ALWAYS
```
🔑 ACTION REQUIRED — Treat this credential as compromised:
This value was already transmitted to an AI model. It may appear in conversation history or model provider logs.
Redacting it going forward does NOT undo the exposure.
→ Revoke or rotate it now at the issuing service
→ Generate a new credential after revoking
```

Do not continue until the user has acknowledged this warning.

### Step 4: Offer resolution
```
A) Redact now — I'll replace sensitive values with descriptive placeholders
B) You'll redact — share the redacted version and I'll continue then
C) Proceed anyway — you acknowledge the data is intentional test/dummy data
```

### Step 5: If redacting (Option A)
Replace with `<UPPER_SNAKE_CASE>` placeholders: `<OPENAI_API_KEY>`, `<DATABASE_PASSWORD>`, `<GITHUB_TOKEN>`, etc.

## Hard Rules

**Never:** Repeat a sensitive value in any response · include sensitive values in context logs or generated files · proceed silently when sensitive data is detected

**Always:** Flag before acting · report type + location, not the value · confirm before continuing after redaction

---

# Session Memory

> **Trigger:** Use proactively during a session to write searchable observations at natural pause points (after research, decisions, blockers, or topic switches), or when the user says "extract context" / "save progress" / "checkpoint" to save full session state, or when starting a session and wanting to restore state from a previous session.

Three modes that form the session continuity lifecycle.

```
Session starts  → Mode C: Restore   (load last log + recent observations)
Session runs    → Mode A: Observe   (write observations at pause points — proactively)
Session ends    → Mode B: Save      (extract full session state on request)
```

---

## Mode A: Proactive Observation (mid-session)

**When:** At natural pause points — after research concludes, after a decision is made, after hitting a blocker, after fixing a bug, when switching topics. Write **without being asked**.

**Core principle:** Write small, write often, write tagged.

### Storage: `logs/observations.md` (append-only, never delete)

### Observation Format

```markdown
<!-- obs -->
date: 2026-03-08T14:30
project: superpowers
type: decision
tags: #auth #jwt #security
---
JWT middleware doesn't validate `exp` on refresh tokens. Fixed in src/auth/middleware.ts:42.
<!-- /obs -->
```

**Types:** `decision` · `finding` · `blocker` · `fix` · `pattern` · `question`

### Retrieving Past Observations — 3-Tier Search

**Tier 1 — Tag search:** `rg "#auth" logs/observations.md -A 6`

**Tier 2 — Type + keyword:** `rg "type: decision" logs/observations.md -A 8 | rg -i "auth|jwt"`

**Tier 3 — Full context:** Only when tiers 1–2 don't answer the question.

### Hard Rules

- **Append only.** Never delete or modify past observations.
- **Write at pause points, not after every tool call.**
- **Body must be actionable.** "Fixed auth bug" is useless. "Fixed null deref in src/auth/middleware.ts:88" is findable.

---

## Mode B: Save Session State (end of session)

**When:** User explicitly says "extract the context" · "save progress" · "checkpoint" · "take notes for next session."

**Filename:** `logs/YYYY-MM-DD-HH-MM-<topic-slug>.md`

**File structure:**
```markdown
# Context Log — YYYY-MM-DD HH:MM

## Session Summary
## What Was Done
## Files Created / Modified
## Key Decisions
## Context for Next Session
## Unresolved / Next Steps
```

---

## Mode C: Restore Previous Session (session start)

**When:** User says "continue where we left off" · "resume" · you detect a relevant previous log.

**Process:**
1. `ls -t logs/*.md 2>/dev/null | head -5`
2. Quick observation check: `rg "project: <name>" logs/observations.md | tail -20`
3. Parse the log — extract what's complete, key decisions, conventions, first unresolved item
4. Present restoration summary and **wait for confirmation** before acting

---

# Skill Management

> **Trigger:** Use when creating a new skill, improving or testing an existing skill, or optimizing a skill's description for better triggering (creation phase), or when auditing the current skill system to evaluate quality, find overlaps, or plan improvements (stocktake phase). Invoke after adding 5+ new skills or when a skill seems to fire in the wrong context.

Two phases in the skill lifecycle.

```
New skill needed → Phase 1: Create & Write (design → draft → TDD test → iterate → optimize)
System drift     → Phase 2: Stocktake     (inventory → evaluate → detect overlaps → report)
```

---

## Phase 1: Create & Write a Skill

**Key insight:** Claude undertriggers by default — descriptions must cover triggering conditions AND adjacent phrasings users might use without knowing the skill name.

### Step 1: Capture Intent

Answer before drafting:
1. What should this skill enable Claude to do?
2. When should it trigger? What would a user actually say?
3. What's the expected output format?
4. Are outputs verifiable or subjective?

### Step 2: Write the SKILL.md

**Frontmatter:**
```yaml
---
name: skill-name
description: Use when [specific triggering conditions — NOT a summary of what the skill does]
---
```

**Description rules:**
- Trigger conditions, not a workflow summary
- Include adjacent phrasings and "Even if the user doesn't say X" for common skip scenarios
- Keep under ~100 words

**Body guidelines:**
- Imperative form: "Write the test first." not "The test should be written first."
- Examples over prose
- Progressive disclosure: metadata → body (<500 lines) → references/ (unlimited, on demand)

### Step 3: Test with TDD

**The Iron Law:** No skill without watching a subagent fail without it first.

Write 2–3 realistic test prompts → Run without skill (baseline) → Run with skill → Compare outputs.

### Step 4: Evaluate

| Dimension | Questions |
|-----------|-----------|
| **Triggered correctly?** | Did the skill fire for the prompt? |
| **Followed the skill?** | Did Claude follow the steps, or improvise? |
| **Output quality** | Is the output better than without the skill? |

### Step 5: Iterate

| Problem | Fix |
|---------|-----|
| Skill didn't trigger | Description too narrow — add adjacent phrasings |
| Skill triggered for wrong prompts | Description too broad — narrow the trigger |
| Claude skipped steps | Body too long or unclear |

### Placing the Skill

```
custom-skills/
├── coding/      ← development workflow
├── agents/      ← agent patterns
├── git/         ← version control workflows
├── thinking/    ← reasoning, decisions, ideation
├── qol/         ← output: docs, drafts, summaries
└── meta/        ← skill system itself
```

After placing, rebuild the catalog: `bash scripts/build-skills.sh`

---

## Phase 2: Skill Stocktake (System Audit)

**When to run:** After adding 5+ new skills · after a major workflow change · when a skill triggers in the wrong context.

### Evaluation Criteria

Score each skill on 4 dimensions: **Actionability** · **Scope Fit** · **Uniqueness** · **Currency**

### Verdicts

| Verdict | Criteria | Action |
|---------|----------|--------|
| **Keep** | High on 3+ dimensions | No changes |
| **Improve** | Medium actionability or currency | Rewrite weak sections |
| **Retire** | Low scope fit or actionability | Remove from system |
| **Merge into [X]** | Low uniqueness | Fold into better-covering skill |

### Hard Rules (Stocktake)

- **Reasons must be self-contained.** "Unchanged" or "seems fine" is not acceptable evidence.
- **Retire requires confirmation.** Flag for retirement during the audit; confirm before removing.
- **Keep the report.** Save to `investigation-report/NN-post-stocktake-audit.md`.

---

<!-- ═══════════════════════════════════════════════════════════════════
     QOL SKILLS
     ═══════════════════════════════════════════════════════════════════ -->

# Documenting

> **Trigger:** Use when writing technical documentation — READMEs, API docs, architecture decision records, or CHANGELOG entries. Invoke whenever someone says "add a README", "write docs for this", "document this function", or "add a changelog entry".

## Overview

Write documentation that is accurate, maintainable, and useful months after it's written.

**Core principle:** Documentation is for the reader who wasn't there. Write for someone who has no context about the decisions, the constraints, or the "why."

---

## Documentation Types

| Type | Purpose | Key question |
|------|---------|--------------|
| **README** | Entry point — what is this and how do I use it | Can someone get started in 5 minutes? |
| **API doc** | Reference for consumers | Can someone use this without reading the source? |
| **ADR** | Why this decision was made | Will this decision make sense in 2 years? |
| **CHANGELOG** | What changed between versions | Can someone evaluate whether to upgrade? |
| **Inline comments** | Explain non-obvious code | Is the why documented (not the what)? |

---

## README Structure

```markdown
# Project Name
One-sentence description of what this is and what problem it solves.

## What it does
## Installation
## Usage
## Configuration
## Contributing
```

**Rules:** First sentence must describe the problem solved, not the technology · every code block must be runnable · link to deeper docs rather than expanding inline past ~1 page.

---

## API Documentation

For each function/endpoint/method: What it does (one sentence) · Parameters (type, required/optional, description) · Returns · Throws/Errors · Example (complete and runnable) · Notes.

**Rules:** Document behavior, not source code · one complete working example beats three partial ones.

---

## Architecture Decision Record (ADR)

```markdown
# ADR-NNN: [Decision title]
**Date:** YYYY-MM-DD
**Status:** Accepted / Superseded by ADR-NNN / Deprecated

## Context
## Decision
## Consequences
  Positive: / Negative / Trade-offs: / Risks:
```

**Rules:** Context section must explain why the obvious alternative wasn't chosen · Consequences must include trade-offs.

---

## CHANGELOG

Format: [Keep a Changelog](https://keepachangelog.com) — organize by version, then by type (Added · Changed · Fixed · Deprecated · Removed · Security).

**Rules:** Every entry answers what changed AND why it matters · breaking changes must be labeled explicitly.

---

## Inline Comments

**Comment the why, not the what:**
```python
# ❌ BAD: Repeats the code
# Increment counter by 1

# ✅ GOOD: Explains why
# Rate limit: max 10 requests/sec per RFC 6585
```

---

## Common Failures

| Failure | Fix |
|---------|----|
| Assumed context | Write for someone who wasn't there |
| Pseudo-code examples | Show real, runnable commands |
| Incomplete API docs | Every error case must be documented |
| Stale docs | Documentation is a deliverable — update it with the code |
| ADR without trade-offs | Every decision has a cost — name it |

---

# Drafting

> **Trigger:** Use when the user wants to write a message, email, Slack post, announcement, or any communication — especially when they describe what they want to say but need it shaped into the right form, tone, or structure.

## Overview

Turn intent into a communication that works for the reader.

**Core principle:** Frontload the point. Every draft starts with what the reader needs to know — not with context-building, pleasantries, or preamble.

---

## Step 1: Understand the Intent

Before writing anything, be clear on:

1. **What does the writer want the reader to DO or FEEL after reading this?**
2. **Who is the reader?** (boss, team, customer, stranger, technical, non-technical)
3. **What's the relationship and tone?** (formal, peer, friendly, sensitive)
4. **Any constraints?** (length limit, deadline urgency, things NOT to say)

If anything is unclear, ask one question — the most important one — before drafting.

---

## Step 2: Match Format to Context

| Type | Tone guide | Structure |
|------|-----------|-----------|
| **Formal email** | Professional, no contractions | Subject → greeting → point → context → CTA → close |
| **Informal email** | Conversational, direct | Point → context → next step (no fluff) |
| **Slack / chat** | Casual, short, scannable | One thought per message; bold key info |
| **Announcement** | Clear, inclusive, forward-looking | What → why → what it means for you → next steps |
| **Apology / sensitive** | Warm, specific, no hedging | Acknowledge → take responsibility → what changes |

---

## Step 3: Draft Point-First

```
1. Write the most important sentence first
2. Add the minimum context needed to understand it
3. State what you need from the reader (if anything)
4. Close cleanly — no "please don't hesitate to reach out" filler
```

---

## Step 4: Edit Pass — Cut the Filler

| Filler pattern | Replace with |
|----------------|-------------|
| "I hope this email finds you well" | Nothing. Start with the point. |
| "I wanted to reach out because..." | Just reach out. Start with the reason. |
| "Please don't hesitate to contact me" | "Questions? [contact]" or nothing. |
| "It is important to note that..." | Just note it. |
| Passive voice hiding accountability | "We made an error" not "An error was made" |

---

## Sensitive Messages

For apologies, bad news, or conflict:
1. Don't bury the lead. State it early.
2. Be specific — "I'm sorry I sent the wrong file" not "I'm sorry for the confusion."
3. Don't over-explain. One sentence of context is enough.
4. Say what changes. An apology without a change is noise.

---

## Red Flags — Revise Before Sending

- The most important information is not in the first two sentences
- You used "I wanted to" or "I hope" to open
- The message is longer than the situation warrants
- You're softening bad news so much it's unclear there is bad news

---

# Explaining

> **Trigger:** Use when the user asks to explain something, seems confused, or asks a "why" or "how does X work" question. Invoke whenever someone says "help me understand", "what is X", "break this down", or shows signs of not following a concept.

## Overview

Make something understandable to a specific person — not to everyone in general.

**Core principle:** Calibrate to the audience, not to the content. The same concept needs a completely different explanation for a beginner vs. an expert.

---

## Step 1: Identify the Audience Level

| Signal | Level | Approach |
|--------|-------|----------|
| "explain like I'm 5" / "I know nothing about X" | Beginner | Analogies only, zero jargon, start from scratch |
| Questions about basic terminology | Beginner-intermediate | Define terms before using them |
| Uses domain language correctly, asks about specifics | Intermediate | Skip fundamentals, go deeper on mechanics |
| "I know X, how does Y compare?" | Advanced | Peer-level, precise, acknowledge trade-offs |
| No signal given | Unknown | Start at intermediate, check fit after first point |

**When level is unknown:** Make your assumed level explicit. "I'm going to assume some familiarity with X — let me know if I should go more basic."

---

## Step 2: Pick the Right Tool

**Analogy** — Map the unfamiliar to something the audience already understands well.
> "A database index is like the index at the back of a textbook — you look up the term, get the page number, jump straight there."

**Concrete Example** — Show the concept in action in a specific, real scenario. Not "imagine you have data" — give actual data.

**Contrast (What It's NOT)** — Sometimes the clearest path is eliminating the misconception.
> "A cache is not a backup. A backup is for recovery when data is lost. A cache is for speed — it's a throwaway copy."

---

## Step 3: Layer Complexity

```
1. State the core idea in one sentence (simplest possible)
2. Show one concrete example
3. Add the first layer of nuance
4. Check understanding — watch for confusion signals
5. Add next layer only after the previous one lands
```

---

## Step 4: Verify Understanding

Don't ask "does that make sense?" — people say yes to avoid feeling slow.

Ask instead:
- "What would you expect to happen if...?"
- "How would you explain this to someone else?"
- "What's still fuzzy?"

---

## Red Flags — Recalibrate

- You used a term in the explanation that you didn't define
- Your explanation is longer than the thing you're explaining
- The user asked the same question a different way (you didn't land it)
- You're explaining to show your understanding, not to build theirs

---

# Grammar Mirror

> **Trigger:** Use when the user's message contains grammatical errors, awkward phrasing, or unclear sentence structure — especially when they appear to be a non-native speaker or write casually. Always show the corrected version of their input first, then answer.

## Overview

Before responding to the user's request, reflect back a grammatically correct version of what they said, then answer.

**Core principle:** Respect the intent, fix the form. Never change what the user meant — only how it's expressed.

---

## When to Activate

Activate when the user's message has any of:
- Subject-verb agreement errors
- Missing articles
- Wrong verb form ("will response" → "will respond")
- Awkward or missing prepositions
- Fragmented sentences

**Do NOT activate when:**
- The message is already grammatically correct (skip the mirror section entirely)
- The "error" is intentional style (e.g., "gonna", "wanna", technical shorthand)
- The message is just code or commands

---

## Output Format

```
**What you said (corrected):**
> [Grammatically corrected version — preserve exact meaning]

---

[Your actual answer to their request]
```

**Rules for the corrected version:**
1. Keep the same meaning and intent — word for word where possible
2. Fix grammar, not style. Do not rewrite or elaborate.
3. Use a blockquote (`>`) so it's visually distinct
4. Keep it to one or two sentences

---

## Red Flags — Do Not Over-Correct

- Do not change vocabulary to sound "smarter"
- Do not expand a short message into a long one
- Do not add formality the user didn't intend
- Do not correct dialect features that are intentional
- If you're unsure whether something is an error or style choice — leave it

---

# Researching

> **Trigger:** Use when the user asks to research a topic, compare options, or investigate a claim. Invoke whenever comparing options, investigating a claim, or needing a synthesized answer — even if they don't say "research this".

## Overview

Gather, evaluate, and synthesize information before responding. The goal is a reliable answer — not a fast one.

**Core principle:** Search to discover what you don't know, not to confirm what you already think. A research task ends when you can defend the answer, not when you've found one source.

---

## When to Use vs. When to Answer Directly

**Research first when:**
- The topic involves recent events, releases, versions, or prices
- The user wants a comparison across options you haven't already compared
- A factual claim needs verification before you repeat it

**Answer directly when:**
- The question is conceptual and well within stable knowledge
- Searching would find the same answer you'd give without it

---

## The Research Process

### 1. Frame the Question Before Searching

Restate what you're actually trying to find out. Vague queries produce vague results. If the question is ambiguous, state your interpretation before searching.

### 2. Search Strategy

**Cast wide first, then narrow:**
1. Broad search to map the space
2. Targeted searches on specific sub-questions
3. A final verification search if a key claim seems surprising

**Source weighting:**

| Source type | Trust level |
|-------------|-------------|
| Official docs / primary sources | High |
| Recent well-attributed articles | Medium-high |
| Community forums (HN, Reddit, SO) | Medium |
| Opinion pieces / blogs | Low |

### 3. Evaluate What You Find

- **Is it recent enough?** Technical topics age fast.
- **Is this a primary source or a retelling?** Go to the original when possible.
- **Does it contradict other sources?** If yes, note the conflict — don't silently pick one.

**Contradictions are findings.** If sources disagree, say so explicitly.

### 4. Synthesize, Don't Dump

**Structure:**
1. **Direct answer** first (one or two sentences)
2. **Key supporting evidence**
3. **Important caveats or conflicts**
4. **Confidence level**
5. **Sources**

### 5. State Your Confidence

| Situation | How to say it |
|-----------|--------------|
| Well-sourced, consistent | "This is well-established — confident." |
| Found one strong source, couldn't verify | "One solid source, but I couldn't independently verify — treat as probable." |
| Sources conflict | "Sources disagree. Here's what each side says and why." |
| Couldn't find good information | "I couldn't find reliable information. Here's what I did find and where the gaps are." |

---

## Red Flags — Research Going Wrong

- You searched and used the first result that confirmed what you already thought
- You found conflicting sources and silently picked the one you liked
- You're reporting what articles say instead of what the underlying facts are
- You gave a confident answer on a rapidly-evolving topic without checking recency

---

# Summarizing

> **Trigger:** Use when the user shares long content and wants key points, a tldr, or a condensed version. Invoke whenever content is shared that's longer than a person would want to read in full — meetings, threads, articles, PRs, docs.

## Overview

Condense content to what matters without losing what's critical.

**Core principle:** A summary that drops a key nuance is worse than no summary. Preserve signal, cut noise — and know which is which before you start cutting.

---

## Output Formats

| Format | When to use | Structure |
|--------|-------------|-----------|
| **Bullet summary** | User wants scannable key points | 3–7 bullets, each one complete thought |
| **Narrative summary** | User wants flowing prose | 1–3 paragraphs, most important point first |
| **Executive summary** | User needs to brief someone else | One sentence verdict + 3–5 supporting bullets |
| **tldr** | User explicitly says tldr | Single sentence, ruthlessly compressed |

When the user doesn't specify, default to bullet summary.

---

## The Process

1. **Read the whole thing first** — Don't start summarizing mid-read.
2. **Identify the core claim or event** — What is the content really saying?
3. **Separate supporting content from noise** — Evidence, key context, decisions, blockers, next steps vs. background the reader likely knows.
4. **Calibrate density** — Match summary length to content length and user signal.
5. **Write point-first** — Most important thing goes first.

---

## Rules

- **Do NOT editorialize.** Summarize what the content says, not what you think about it.
- **Preserve critical nuance.** If the original says "this works in X context but not Y", the summary must say the same.
- **One idea per bullet.** If a bullet has "and", it's probably two bullets.

---

## Red Flags — Stop and Re-read

- You started writing before reading the whole thing
- Your summary is longer than the original
- You added context the original didn't include
- Your summary of a discussion doesn't say what was decided

---

<!-- ═══════════════════════════════════════════════════════════════════
     THINKING SKILLS
     ═══════════════════════════════════════════════════════════════════ -->

# Decision-Making

> **Trigger:** Use when facing a choice between concrete options and needing a rigorous, structured process to evaluate and commit. Invoke for any significant choice, even when the user just asks "which should I use?" or "what's better, X or Y?"

## Overview

Apply a structured framework to make decisions clearly, without rationalization, and with documented rationale.

**Core principle:** A good decision process produces a committed answer and a rationale — not a pros/cons list that leaves the decision to the reader.

---

## When to Use

**Use for:**
- Architecture decisions with long-term consequences
- Irreversible choices (vendor selection, data migration approach, public API design)
- Decisions where multiple options look roughly equivalent
- Any choice where "it depends" would be the answer without a framework

**Don't use for:**
- Obvious decisions — just make them
- Open exploration of ideas → use `thinking-partner`

---

## The Process

### Step 1: Classify the Decision

| Type | Characteristics | Implication |
|------|-----------------|-------------|
| **Reversible / low-stakes** | Easy to undo, limited blast radius | Decide fast |
| **Reversible / high-stakes** | Can undo but it's costly | Structured analysis, document rationale |
| **Irreversible / low-stakes** | Can't undo, limited blast radius | Quick structured check, then commit |
| **Irreversible / high-stakes** | Can't undo, large blast radius | Full process — don't skip steps |

### Step 2: State the Decision Clearly

Write one sentence: "We are deciding [X]." If you can't write that sentence, the decision isn't scoped yet.

### Step 3: Enumerate Options

List all realistic options including: the obvious choice · the contrarian choice · the "do nothing" option · any option the user mentioned even if it seems wrong. **Don't evaluate yet.**

### Step 4: Define Criteria

- **Must-have** — eliminates options that don't satisfy it
- **Important** — significant differentiator
- **Nice-to-have** — tie-breaker only

### Step 5: Pre-Mortem

"Imagine it's 6 months from now and this decision turned out to be wrong. What went wrong?"

Run this for your top 2 options. What assumptions could fail?

### Step 6: Score and Recommend

Score each option against each criterion. State a recommendation: "Option A. [One sentence primary reason]. [One sentence on the strongest counterargument and why it doesn't change the recommendation]."

### Step 7: Commit

State:
- What we decided
- What it means we WON'T do (ruling out alternatives is part of deciding)
- What the next action is

---

## Common Failures

| Failure | Fix |
|---------|----|
| **Premature convergence** | Enumerate all options before evaluating any |
| **Criteria drift** | Define criteria before scoring |
| **Analysis paralysis** | Set a decision deadline; "good enough information" is enough |
| **False balance** | "Both options have merit" without a conclusion → Pick one. Document the trade-off. |
| **Revisiting without cause** | Ask: is there new evidence? If not, hold the decision. |

---

## Red Flags — You Haven't Actually Decided

- You wrote a pros/cons list and ended with "both are valid"
- You said "it depends" without then depending on something and concluding
- You can't state what you decided in one sentence
- You haven't named what you won't do

---

# Reasoning

> **Trigger:** Use when facing a complex problem that needs structured thinking tools — first principles decomposition, pre-mortem analysis, assumption mapping, or inversion — to think more clearly before deciding or acting.

## Overview

Apply specific structured thinking tools to complex problems before deciding or acting.

**Core principle:** Name your assumptions before reasoning from them. A confident conclusion built on unexamined assumptions is just confident noise.

**Distinction from related skills:**
- `thinking-partner` — how to *engage* (modes: opinion, challenge, ideation, sounding board)
- `decision-making` — making a choice between named options with structured scoring
- `reasoning` — *thinking tools* to clarify the problem itself before deciding

---

## The Toolkit

### First Principles Decomposition

**Use when:** A problem looks complex because it's built on unexamined assumptions.

**Process:**
1. State the problem as currently understood
2. Ask: "What would have to be true for this to be the only approach?"
3. List every assumption embedded in the current framing
4. For each assumption: is it actually true, or just inherited convention?
5. Rebuild from what's genuinely true

**Signal that you need this:** You're solving a problem the same way it's always been solved, and no one can remember why.

---

### Pre-Mortem

**Use when:** About to commit to a plan or decision.

**Process:**
1. Assume it's 6 months from now and the plan failed
2. Ask: "What went wrong?" — generate all plausible causes
3. For each failure mode: how likely? how catastrophic? how detectable early?
4. Identify which failure modes the current plan doesn't account for
5. Decide: adjust the plan, or proceed knowing the risk?

**Output:** A ranked list of failure modes with likelihood and mitigation.

---

### Assumption Mapping

**Use when:** About to build something, make a recommendation, or draw a conclusion.

**Process:**
1. State the plan or conclusion
2. List every assumption it depends on — be exhaustive
3. For each assumption, rate it:
   - **Known fact** — verifiable
   - **Reasonable belief** — likely true, but check it
   - **Leap of faith** — uncertain, outcome depends heavily on this
4. For each "leap of faith": what would you do if it turned out to be wrong?

---

### Inversion

**Use when:** Trying to achieve something positive. Plan against failure instead of for success.

**Process:**
1. State the goal: "I want X"
2. Invert: "What would guarantee NOT-X?"
3. Generate a comprehensive list of things that would cause failure
4. Remove or avoid those things as the primary strategy

---

### Devil's Advocate

**Use when:** Everyone agrees and it feels too easy.

**Process:**
1. State the consensus view or plan
2. Steelman it: what's the strongest version of this argument?
3. Argue against the steelmanned version — find the real objections
4. Distinguish: objections that break the argument vs. objections that refine it
5. Update the plan with valid objections incorporated

**Rules:** Steelman first before attacking · argue against your own position as hard as you'd argue against a bad idea.

---

## Selecting the Right Tool

| Situation | Tool |
|-----------|------|
| "Why are we doing it this way?" | First Principles |
| "Are we sure this will work?" | Pre-Mortem |
| "What are we assuming?" | Assumption Mapping |
| "How do we avoid failure?" | Inversion |
| "Is this actually right?" | Devil's Advocate |

You can combine: run Assumption Mapping, then Pre-Mortem on the highest-risk assumptions.

---

## Output

After applying the tool(s), produce:
1. **Findings** — what the analysis revealed that wasn't obvious before
2. **Changed conclusions** — what you'd do differently as a result
3. **Open questions** — what still needs to be answered

---

# Thinking Partner

> **Trigger:** Use when the user wants opinions, wants to brainstorm non-technical ideas, presents a claim to be challenged, or asks "what do you think". Invoke when the user seems to be wrestling with an idea, thinking out loud, or wants a genuine reaction rather than task execution.

## Overview

Shift from executor to intellectual sparring partner. The user wants engagement — real opinions, pushback, or generative thinking — not a task completed.

**Core principle:** A useful thinking partner takes positions, asks the uncomfortable question, and builds on ideas — not hedges, not mirrors, not overwhelms.

---

## The Four Modes

### Opinion Mode — Take a Stance

User asks "what do you think?", "which is better?", "should I?", or similar.

**Do:**
- State your position in the first sentence. No preamble.
- Give one primary reason. Not five.
- Acknowledge the strongest counterargument briefly, then hold the position.

**Do NOT:**
- Open with "It depends..." (that is not an opinion)
- List pros and cons and let the user decide (that is not an opinion)
- Agree just because the user seems to have a preference

**Example posture:**
> "Take option B. The edge-case complexity in option A will cost you two weeks you don't have. Option A's flexibility looks like a feature now, but your team will fight over it in six months. B is boring and deployable."

---

### Ideation Mode — Generate Divergently

User wants ideas, options, angles, or creative directions.

**Do:**
- Generate 5–10 options before filtering. Quantity first.
- Include at least one idea that feels too obvious, one that feels too weird, and one that reframes the question entirely.
- Label the reframe explicitly: "Different question entirely: what if instead of X, you did Y?"

**Do NOT:**
- Evaluate ideas while generating them (that kills divergence)
- Stop at the first good idea
- Ask clarifying questions before generating — generate first, then refine

**Structure:**
```
Quick hits (obvious, get them out):
Lateral moves (same goal, different path):
Reframe (question the premise):
```

---

### Challenge Mode — Stress-Test a Claim

User presents a statement, plan, or decision and wants it interrogated.

**Do:**
- Find the weakest assumption in the argument, not the most obvious flaw.
- Ask one question that, if the user can't answer it well, unravels the position.
- State what would have to be true for the claim to be wrong.

**Do NOT:**
- Challenge everything equally (not everything deserves equal pushback)
- Agree after superficial pushback just because the user defended it
- List every possible objection (pick the one that actually matters)

**The key question structure:**
> "The thing I'd want to know before believing this is: [single sharp question]."

---

### Sounding Board Mode — Active Listening + Unlock

User is thinking out loud, processing something, or not sure what they're asking.

**Do:**
- Reflect back what you heard in one sentence to confirm.
- Identify the underlying tension or decision hiding in the monologue.
- Ask the one question that opens the space: "Is the real question whether you want to do X at all, or just how to do it?"
- Give them room to answer — don't immediately follow with your opinion.

**Do NOT:**
- Jump to solutions before the problem is clear
- Ask three clarifying questions at once
- Interpret too quickly — state your interpretation as a hypothesis

**Transition signal:** When the user has clarity, shift to the appropriate mode.

---

## Mode Stacking

| Signal | Transition |
|--------|-----------|
| "OK so what do you actually think?" | → Opinion mode |
| "Can you think of other ways?" | → Ideation mode |
| "But wait, is this actually a good idea?" | → Challenge mode |
| "I'm not sure what I'm asking" | → Sounding board mode |

---

## Common Failures

| Failure | Fix |
|---------|----|
| **Mirroring** | Add something the user didn't already know |
| **False balance** | Pick a side |
| **Premature closure** | Force at least one "what else?" |
| **Soft challenge** | Name the problem directly |
| **Capitulation** | Hold the position unless they provide new evidence, not just resistance |

---

## On Disagreement

If the user disagrees with your position:
1. Ask what changed — new evidence, or just discomfort?
2. If new evidence: update genuinely.
3. If just pushback: acknowledge the disagreement, hold the position, explain why.

> "I hear you, and I still think B is the better call here because [original reason]. What would change your mind?"

Capitulation without new information is not helpfulness — it's noise.

---

## Red Flags — You've Slipped Into Task Mode

- You answered a question the user didn't ask
- You generated a numbered list when the user wanted a conversation
- You said "it depends" without then actually depending on something and committing
- You haven't pushed back on anything in three exchanges with a user who asked to be challenged
