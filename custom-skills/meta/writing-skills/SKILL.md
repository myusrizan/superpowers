---
name: writing-skills
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
---

# Writing Skills

## Overview

**Writing skills IS Test-Driven Development applied to process documentation.**

**Personal skills live in agent-specific directories (`~/.claude/skills` for Claude Code, `~/.agents/skills/` for Codex)**

You write test cases (pressure scenarios with subagents), watch them fail (baseline behavior), write the skill (documentation), watch tests pass (agents comply), and refactor (close loopholes).

**Core principle:** If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

**REQUIRED BACKGROUND:** You MUST understand superpowers:test-driven-development before using this skill.

**Official guidance:** See `anthropic-best-practices.md` for Anthropic's official skill authoring best practices.

**Full methodology:** See `detail.md` for the complete TDD process, testing by skill type, bulletproofing, and anti-patterns.

## TDD Mapping for Skills

| TDD Concept | Skill Creation |
|-------------|----------------|
| **Test case** | Pressure scenario with subagent |
| **Production code** | Skill document (SKILL.md) |
| **Test fails (RED)** | Agent violates rule without skill (baseline) |
| **Test passes (GREEN)** | Agent complies with skill present |
| **Refactor** | Close loopholes while maintaining compliance |

## When to Create a Skill

**Create when:**
- Technique wasn't intuitively obvious to you
- You'd reference this again across projects
- Pattern applies broadly (not project-specific)

**Don't create for:**
- One-off solutions or project-specific conventions (put in CLAUDE.md)
- Standard practices well-documented elsewhere
- Mechanical constraints (automate those; save docs for judgment calls)

## Skill Types

| Type | Description | Examples |
|------|-------------|---------|
| Technique | Concrete method with steps | condition-based-waiting, root-cause-tracing |
| Pattern | Way of thinking about problems | flatten-with-flags, test-invariants |
| Reference | API docs, syntax guides, tool documentation | office docs |

## SKILL.md Structure

**Frontmatter (YAML):**
- Only two fields: `name` and `description` (max 1024 characters total)
- `name`: letters, numbers, hyphens only
- `description`: Third-person, starts with "Use when...", triggering conditions ONLY

```markdown
---
name: Skill-Name-With-Hyphens
description: Use when [specific triggering conditions and symptoms]
---

# Skill Name

## Overview
What is this? Core principle in 1-2 sentences.

## When to Use
Bullet list with SYMPTOMS and use cases. When NOT to use.

## Core Pattern (for techniques/patterns)
Before/after comparison.

## Quick Reference
Table or bullets for scanning common operations.

## Implementation
Inline code for simple patterns. Link to file for heavy reference.

## Common Mistakes
What goes wrong + fixes.
```

## Claude Search Optimization (CSO) — Critical Rules

### Description = When to Use, NOT What the Skill Does

**NEVER summarize the skill's process or workflow in the description.**

Why: Testing revealed that when a description summarizes the skill's workflow, Claude may follow the description instead of reading the full skill. A description saying "code review between tasks" caused Claude to do ONE review, even though the skill showed TWO reviews. When the description was changed to just triggering conditions, Claude correctly read and followed the full workflow.

```yaml
# ❌ BAD: Summarizes workflow — Claude may follow this instead of reading skill
description: Use when executing plans - dispatches subagent per task with code review between tasks

# ✅ GOOD: Just triggering conditions, no workflow summary
description: Use when executing implementation plans with independent tasks in the current session

# ✅ GOOD: Technology-specific trigger
description: Use when using React Router and handling authentication redirects
```

### Naming

Use active voice, verb-first: `condition-based-waiting` not `async-test-helpers`. Gerunds work well for processes: `creating-skills`, `testing-skills`.

### Token Efficiency

- Getting-started/frequently-loaded skills: <150 words each
- Other skills: <500 words
- Move heavy reference (100+ lines) to a separate file. Cross-reference rather than repeat.

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

Applies to NEW skills AND EDITS. No exceptions — not for "simple additions," not for "just adding a section."

## Skill Creation Checklist (Summary)

**RED:** Run pressure scenarios WITHOUT skill — document baseline failures verbatim.

**GREEN:** Write skill addressing those specific failures. Run scenarios WITH skill — verify compliance.

**REFACTOR:** Find new rationalizations → add explicit counters → re-test until bulletproof.

**Quality Checks:**
- [ ] Frontmatter: `name` (hyphens only), `description` (Use when..., no workflow, <1024 chars)
- [ ] One excellent example (not multi-language)
- [ ] Quick reference table
- [ ] No narrative storytelling

**Deployment:**
- [ ] Commit and push to git fork (if configured)
- [ ] Consider PR contribution if broadly useful

See `detail.md` for the full checklist, testing methodology by skill type, and rationalization tables.
