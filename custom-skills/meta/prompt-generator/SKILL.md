---
name: prompt-generator
description: Use when asked to generate a prompt, system prompt, briefing document, or reusable instruction set — produces a structured, efficient prompt saved to a markdown file
---

# Prompt Generator

## Overview

Turn a knowledge base, workflow, or set of conventions into a reusable prompt that works without the current conversation history.

**Core principle:** A generated prompt must be self-contained. The reader has no context from the session that produced it.

---

## When to Use

- User says "generate a prompt", "create a prompt", "write a system prompt"
- User wants to export knowledge from the current session as reusable instructions
- User wants a prompt for a specific agent role or task type
- User wants to document conventions as an instruction set

---

## The Process

### Step 1: Identify the prompt's purpose

Answer these before writing:

```
Purpose:   What will this prompt be used for? (system prompt, task brief, agent role)
Audience:  Who reads it? (Claude in a fresh session, a subagent, a human)
Scope:     What knowledge/behavior should it encode?
Activation: When should the behavior described trigger?
```

### Step 2: Gather the content

Collect from the current conversation:
- Decisions made and rationale
- Conventions established
- Skills, tools, or workflows referenced
- Patterns that should be preserved across sessions

### Step 3: Structure the prompt

Use this template:

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
[Add sections as needed: Catalog, Workflows, Rules, Constraints]

## Constraints
[What the model must NOT do. Explicit negatives.]
```

### Step 4: Apply prompt-efficiency patterns

Before finalizing:
- [ ] Is the goal stated in the first section?
- [ ] Is the output format constrained where relevant?
- [ ] Are negative constraints explicit?
- [ ] Is any content repeated unnecessarily?
- [ ] Are instructions imperative ("Do X") not hedged ("You might want to X")?

### Step 5: Save the output

Save to: `prompts/YYYY-MM-DD-<purpose>.md`

Tell the user: "Prompt saved to `prompts/<filename>.md`. Use it by loading it as a system prompt or pasting it at the start of a new session."

---

## Quality Checks

| Check | Pass condition |
|-------|---------------|
| Self-contained | Reader needs no prior conversation to understand it |
| Imperative | Instructions use present tense commands, not suggestions |
| No filler | Every sentence carries information |
| Constrained | Model knows what NOT to do, not just what to do |
| Structured | Sections are scannable; reader can find relevant part quickly |
