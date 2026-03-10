---
name: skill-creator
description: Use when writing a new skill from scratch — to design, draft, and validate it before adding to the collection. Invoke when the user says "create a skill for X", "write a new skill", or "I want a skill that does Y".
---

# Skill Creator

## Overview

A structured workflow for authoring new skills. Produces actionable, well-scoped skills that trigger reliably and integrate cleanly with the existing collection.

**Core principle:** A skill is a workflow, not a wiki page. Every line must drive behavior, not document knowledge.

---

## Phase 1: Define Scope

Before writing anything, answer these questions:

**1. What is the trigger?**
In what situation should this skill activate? Be specific — "when the user wants to improve code" is too broad.

**2. What is the outcome?**
What tangible output or state change does this skill produce?

**3. What is it NOT?**
What adjacent skills already cover? Where does this skill end and another begin?

**4. Does it already exist?**
Search the collection first:
```bash
rg "name:" custom-skills/ -l
rg "description:" custom-skills/ -A 1 | grep -i "<keyword>"
```

If a close match exists, consider enhancing it instead of creating a new one.

---

## Phase 2: Write the SKILL.md

### Frontmatter

```yaml
---
name: my-skill-name
description: Use when [specific triggering condition]. Invoke whenever [adjacent condition] — even if the user doesn't explicitly mention [skill name].
---
```

**Frontmatter rules:**
- `name`: kebab-case, matches the directory name
- `description`: The primary trigger mechanism. Be specific. Include adjacent phrasings — Claude undertriggers by default
- Start with "Use when" — describes the situation
- End with "Invoke whenever" — covers adjacent cases the user might not phrase explicitly

### Body

Structure by what the agent needs to do, in order:

```markdown
# Skill Name

## Overview
[1-3 sentences: what this skill does and its core principle]

## When to Use
[Bullet list of triggers. Include "Do NOT use when" to set boundaries]

## The Process
[Numbered steps. Each step = one action the agent takes]

## Output Format (if applicable)
[Templates the agent fills in]

## Hard Rules
[Non-negotiable constraints. Short. Imperative.]

## Common Failures
[Table: failure mode → what it looks like → fix]
```

**Body rules:**
- Every section must drive action — no section is purely informational
- Steps must be executable, not aspirational ("read the test output" not "consider testing")
- Hard Rules are the immune system — they prevent the most common failures
- Common Failures section is optional but high-value for skills with predictable failure modes

---

## Phase 3: Validate

Before saving:

**Trigger test:**
> Read only the `description` field. Would you activate this skill in the right situation? Would you miss any adjacent situation?

**Coverage test:**
> Walk through 3 realistic scenarios where this skill would be invoked. Does the process handle all 3?

**Scope test:**
> Is there any step that belongs in a different existing skill? If yes, reference the other skill instead.

**Completeness test:**
> Could someone follow this skill with no prior context and produce the correct output?

---

## Phase 4: Place and Register

1. Create directory: `custom-skills/<category>/<skill-name>/`
2. Write `SKILL.md` to that directory
3. Rebuild catalog:
```bash
bash scripts/build-skills.sh
```
4. Verify the skill appears in `skills/` after build

---

## Category Placement Guide

| Category | Skills in it |
|----------|-------------|
| `coding/` | Software development workflows |
| `agents/` | Agent orchestration, MCP, multi-agent patterns |
| `git/` | Version control, GitHub, PR workflows |
| `thinking/` | Reasoning, decision-making, intellectual engagement |
| `qol/` | Output production (documents, messages, summaries) |
| `meta/` | The skill system itself, CLAUDE.md, memory, session management |

When in doubt: if it drives how Claude works on software tasks → `coding/`. If it helps Claude organize its own behavior → `meta/`.

---

## Hard Rules

- **One trigger per skill.** If the skill needs two different "When to use" conditions with no overlap, split it.
- **Draft in the skill file, not in chat.** The skill is the artifact — it lives on disk.
- **Test the description field in isolation.** That field alone determines when the skill fires.
- **Hard Rules section is mandatory.** Every skill has failure modes — name them.
