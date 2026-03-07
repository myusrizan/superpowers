---
name: skill-creator
description: Use when creating a new skill, improving an existing skill, or optimizing a skill's description for better triggering. Invoke when a user wants to capture a workflow as a skill, test whether a skill works, or iterate on skill quality.
---

# Skill Creator

## Overview

Skills are the primary way to encode workflows into Claude's behavior. A good skill reliably triggers when needed, executes the right steps, and produces consistent outputs. A bad skill either never triggers, always triggers, or guides Claude in the wrong direction.

**The process:** Capture intent → draft → test → evaluate → iterate → optimize description.

---

## How Skill Triggering Works

Before writing a skill, understand how Claude decides to invoke it:

- Skills appear with their `name` and `description` in Claude's context
- Claude invokes a skill when the description matches the task **and** the task is complex enough to benefit from specialized guidance
- **Simple, one-step queries won't trigger skills** — Claude handles those directly. Multi-step or specialized workflows reliably trigger when the description matches
- **Claude undertriggers by default** — it avoids invoking skills when it could handle the task directly. Combat this with "pushy" descriptions

**Implication:** Write descriptions that describe both what the skill does AND specific contexts where it applies — including adjacent phrasings the user might use without knowing the skill name.

---

## Phase 1: Capture Intent

Start by understanding what the skill should do. If the current conversation already contains a workflow to capture (the user just did something you want to encode), extract the steps from conversation history first.

Answer these before drafting:

1. What should this skill enable Claude to do?
2. When should it trigger? What would a user actually say?
3. What's the expected output format?
4. Are the outputs objectively verifiable (code generated, file created, data extracted) or subjective (writing quality, design choices)?

Objectively verifiable outputs → write test cases. Subjective outputs → rely on qualitative review.

---

## Phase 2: Interview

Before writing the full skill, ask about:
- Edge cases: what should the skill do when X happens?
- Input constraints: what context does Claude need to run this skill?
- Success criteria: how do you know the skill worked?
- Failure modes: what does a bad output look like?

Don't write test cases until the interview is complete.

---

## Phase 3: Write the SKILL.md

### File structure

```
skill-name/
├── SKILL.md          ← Required: frontmatter + instructions
└── references/       ← Optional: large docs loaded on demand
    └── details.md
```

### Frontmatter

```yaml
---
name: skill-name
description: <TRIGGERING DESCRIPTION — see guidelines below>
---
```

### Description writing guidelines

The description is the single most important part of the skill. It's the primary trigger mechanism.

**Make it pushy.** Don't just describe what the skill does — tell Claude when to invoke it, including adjacent contexts.

| Too passive | Pushy (better) |
|-------------|---------------|
| "How to design REST APIs" | "Use when designing or reviewing REST APIs. Invoke whenever someone asks about endpoint naming, HTTP methods, response formats, or versioning — even if they don't say 'API design'." |
| "TDD workflow" | "Use before writing any production code. Invoke even for small changes, even if the user doesn't mention tests." |

**Include:**
- What the skill does
- When to trigger (specific conditions)
- Adjacent phrasings that should also trigger it
- "Even if the user doesn't say X" for common skip scenarios

**Keep under ~100 words.** The description is always in context. Every word has a cost.

### Body writing guidelines

- **Imperative form**: "Write the test first." not "The test should be written first."
- **Explain the why**: Don't just say MUST/ALWAYS — explain the reasoning so Claude understands and can adapt
- **Examples over prose**: Show a good example and a bad example rather than describing the difference
- **Progressive disclosure**: Metadata (100 words) → body (<500 lines) → references (unlimited, loaded on demand)
- **No multi-language dilution**: Pick the most common language for examples; note others apply by analogy

---

## Phase 4: Test

Write 2–3 realistic test prompts — the kind of thing a real user would actually say. Not abstract, not "use the skill". Include context: file paths, background, specifics.

**Bad test prompt:** "Design a REST API"

**Good test prompt:** "I'm building a task management app in Next.js. I need endpoints for tasks, projects, and user assignments. The frontend uses React Query. Can you design the API structure for me?"

For each test prompt:
1. Run Claude WITH the skill (either via subagent with skill path, or by manually following the skill in the same session)
2. Run Claude WITHOUT the skill (baseline)
3. Compare outputs

Save test prompts for future iterations. If you improve the skill, re-run the same prompts.

---

## Phase 5: Evaluate

For each test output, assess:

| Dimension | Questions |
|-----------|-----------|
| **Triggered correctly?** | Did the skill fire for the prompt? Did it fire for prompts it shouldn't have? |
| **Followed the skill?** | Did Claude follow the skill's steps, or did it improvise? |
| **Output quality** | Is the output better than without the skill? |
| **Missing steps** | Did Claude skip steps that should have run? |
| **Over-engineering** | Did the skill cause Claude to do unnecessary work? |

---

## Phase 6: Iterate

Based on evaluation:

1. **If the skill didn't trigger:** The description is too narrow. Add adjacent phrasings. Make it pushier.
2. **If the skill triggered for the wrong prompts:** The description is too broad. Narrow the trigger condition.
3. **If Claude skipped steps:** The skill body is too long or unclear. Break steps into smaller, explicit instructions.
4. **If output is worse than baseline:** The skill is adding friction. Simplify or remove steps that don't pull their weight.
5. **If Claude over-engineers:** The skill has too many requirements. Remove steps that don't improve outcomes.

**Key principle from Anthropic:** Don't add rigid MUSTs and ALWAYs — explain why things matter. LLMs are smart; theory of mind works better than rigid commands.

Repeat Phase 4–6 until:
- The skill triggers reliably for its target prompts
- Outputs are consistently better than baseline
- The skill doesn't trigger for off-target prompts

---

## Phase 7: Optimize Description (Optional)

For skills where triggering accuracy matters most, generate 20 eval queries (10 should-trigger, 10 should-not-trigger) and test them manually:

**Should-trigger queries:** Different phrasings of the same intent. Include casual speech, typos, context-heavy prompts, and cases where the user doesn't name the skill.

**Should-not-trigger queries:** Near-misses — adjacent domains, shared keywords, contexts where another skill is more appropriate. These are the most valuable test cases.

Evaluate each: does the skill trigger? Should it?

Update the description to close gaps found.

---

## Placing the Skill

Our skill system:
```
custom-skills/
├── coding/      ← development workflow: tdd, debugging, security, etc.
├── agents/      ← agent patterns: parallel dispatch, loops, retrieval
├── git/         ← version control workflows
├── thinking/    ← reasoning, decisions, ideation
├── qol/         ← output: docs, drafts, summaries, explanations
└── meta/        ← skill system itself, context, prompts
```

After placing:
```bash
bash scripts/build-skills.sh
# → "Catalog regenerated"
```

The build script reads frontmatter from all SKILL.md files and regenerates the catalog in `using-superpowers/SKILL.md`.

---

## Installing the Official Plugin

Anthropic's full `skill-creator` plugin (with browser eval viewer, Python benchmark scripts, blind comparison, and description optimizer) is available via:

```
/plugins install skill-creator
```

The official plugin provides:
- Automated baseline vs. with-skill comparison via subagents
- Browser-based eval viewer for reviewing outputs
- Quantitative assertions with grader agents
- Description optimizer (runs 5 iterations, reports test scores)
- Packaging to `.skill` files for sharing

This lightweight skill captures the methodology. The official plugin provides the tooling.

---

## Hard Rules

- **Write the description last.** Draft the body first, understand what the skill actually does, then write the trigger.
- **Test before declaring done.** A skill that hasn't been tested with real prompts is a guess.
- **Explain the why.** "Write the test first" → explain why order matters. Claude follows reasoning better than mandates.
- **Keep body under 500 lines.** Longer skills get diluted. Use references/ for large docs.
- **Run the build after every change.** `bash scripts/build-skills.sh` — the catalog won't update otherwise.
