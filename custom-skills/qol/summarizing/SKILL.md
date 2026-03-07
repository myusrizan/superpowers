---
name: summarizing
description: Use when the user shares long content and wants key points, a tldr, or a condensed version. Invoke whenever content is shared that's longer than a person would want to read in full — meetings, threads, articles, PRs, docs.
---

# Summarizing

## Overview

Condense content to what matters without losing what's critical.

**Core principle:** A summary that drops a key nuance is worse than no summary. Preserve signal, cut noise — and know which is which before you start cutting.

---

## Output Formats

Choose based on what the user signals they need:

| Format | When to use | Structure |
|--------|-------------|-----------|
| **Bullet summary** | User wants scannable key points | 3–7 bullets, each one complete thought |
| **Narrative summary** | User wants flowing prose, not a list | 1–3 paragraphs, most important point first |
| **Executive summary** | User needs to brief someone else | One sentence verdict + 3–5 supporting bullets |
| **tldr** | User explicitly says tldr or wants one line | Single sentence, ruthlessly compressed |

When the user doesn't specify, default to bullet summary. If the content is a story or argument (not a list of facts), use narrative.

---

## The Process

### 1. Read the whole thing first

Don't start summarizing mid-read. Read to the end, then summarize. You need to know the conclusion before you can judge what's setup vs. what's payload.

### 2. Identify the core claim or event

Every piece of content has one thing it's really saying or one thing that happened. Find it.

- For articles/docs: What is the main argument or finding?
- For meeting notes: What was decided? What's blocked?
- For threads/discussions: What was the disagreement and how did it resolve?
- For code/diffs: What does this change do and why?

### 3. Identify what supports it vs. what's noise

Supporting: evidence, key context, decision rationale, blockers, next steps
Noise: background the reader likely knows, repeated points, examples once the pattern is clear

### 4. Calibrate density

| Content length | User signal | Target summary length |
|---------------|-------------|----------------------|
| < 500 words | "quick summary" | 2–3 bullets |
| 500–2000 words | "summarize" | 4–6 bullets or 1 paragraph |
| 2000+ words | "summarize" | Executive summary format |
| Any length | "tldr" | 1 sentence |
| Any length | "key points" | Bullets only, 5–7 max |

### 5. Write point-first

Most important thing goes first. Don't build to the conclusion — state it, then support it.

---

## Rules

**Do NOT editorialize.** Summarize what the content says, not what you think about it. If asked for your opinion separately, give it separately.

**Preserve critical nuance.** If the original says "this works in X context but not Y", the summary must say the same. Dropping the caveat changes the meaning.

**One idea per bullet.** If a bullet has "and", it's probably two bullets.

**Quote sparingly.** Only quote when the exact wording matters. Otherwise, paraphrase.

---

## Common Failures

| Failure | What it looks like | Fix |
|---------|--------------------|-----|
| **Over-summarizing** | Lost a key caveat, decision, or blocker | Re-read the original; mark what can't be lost |
| **Under-summarizing** | Summary is half the length of the original | Cut more aggressively; every sentence must earn its place |
| **Editorializing** | "The author incorrectly claims..." or "Interestingly..." | Remove judgment; stick to what the content says |
| **Burying the lead** | Most important point is last | Reorder: verdict first, context after |
| **Flat bullets** | All bullets feel equally important | Use hierarchy or bold the most critical one |
| **Missing next steps** | Summary of a meeting without action items | For action-oriented content, always surface what happens next |

---

## Red Flags — Stop and Re-read

- You started writing before reading the whole thing
- Your summary is longer than the original
- You added context the original didn't include
- You left out something the user will definitely ask about
- Your summary of a discussion doesn't say what was decided
