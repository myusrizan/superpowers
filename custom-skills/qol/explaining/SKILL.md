---
name: explaining
description: Use when the user asks to explain something, says "help me understand", "what is X", "break this down", "explain like I'm a [level]", or is clearly confused about a concept or system
---

# Explaining

## Overview

Make something understandable to a specific person — not to everyone in general.

**Core principle:** Calibrate to the audience, not to the content. The same concept needs a completely different explanation for a beginner vs. an expert. One explanation fits no one.

---

## Step 1: Identify the Audience Level

Detect level from explicit signal or language clues:

| Signal | Level | Approach |
|--------|-------|----------|
| "explain like I'm 5" / "I know nothing about X" | Beginner | Analogies only, zero jargon, start from scratch |
| Questions about basic terminology | Beginner-intermediate | Define terms before using them |
| Uses domain language correctly, asks about specifics | Intermediate | Skip fundamentals, go deeper on mechanics |
| "I know X, how does Y compare?" | Advanced | Peer-level, precise, acknowledge trade-offs |
| No signal given | Unknown | Start at intermediate, check fit after first point |

**When level is unknown:** Make your assumed level explicit. "I'm going to assume some familiarity with X — let me know if I should go more basic." Then adjust.

---

## Step 2: Pick the Right Tool

Use one or more of these to make the concept land:

### Analogy
Map the unfamiliar to something the audience already understands well.

> "A database index is like the index at the back of a textbook — you look up the term, get the page number, jump straight there instead of reading every page."

Good analogy: precise mapping, audience knows the domain used. Bad analogy: the analogy itself needs explaining.

### Concrete Example
Show the concept in action in a specific, real scenario. Not "imagine you have data" — give actual data.

> "If you have 1 million rows and search without an index, the database checks all 1 million. With an index on the email column, it jumps directly to the matching row."

### Contrast (What It's NOT)
Sometimes the clearest path is eliminating the misconception.

> "A cache is not a backup. A backup is for recovery when data is lost. A cache is for speed — it's a throwaway copy. If the cache disappears, nothing is lost."

---

## Step 3: Layer Complexity

Don't dump everything at once. Use the ladder:

```
1. State the core idea in one sentence (simplest possible)
2. Show one concrete example
3. Add the first layer of nuance
4. Check: "Does that make sense so far?" or watch for confusion signals
5. Add next layer only after the previous one lands
```

**Stop adding layers when:** The user can repeat the concept back in their own words, or they're asking questions that show they got it and want more.

---

## Step 4: Verify Understanding

Don't ask "does that make sense?" — people say yes to avoid feeling slow.

Ask instead:
- "What would you expect to happen if...?"
- "How would you explain this to someone else?"
- "What's still fuzzy?"

Or watch for signals they're lost: vague follow-up questions, restating the original confusion, going quiet.

---

## Common Failures

| Failure | What it looks like | Fix |
|---------|--------------------|-----|
| **Level mismatch (too high)** | Using jargon to explain jargon | State the assumed level; ask if you should go simpler |
| **Level mismatch (too low)** | Over-explaining basics to an expert | Notice domain language they're using; match it |
| **Analogy breakdown** | The analogy needs its own explanation | Choose an analogy from a domain you know they know |
| **Completeness trap** | Explaining everything instead of the thing they asked | Answer the specific question; offer to go deeper |
| **Abstract only** | All principles, no examples | Always follow a principle with a concrete case |
| **"Does that make sense?"** | User says yes, still confused | Ask a test question instead |

---

## Red Flags — Recalibrate

- You used a term in the explanation that you didn't define
- Your explanation is longer than the thing you're explaining
- You explained what it is without showing what it does
- The user asked the same question a different way (you didn't land it)
- You're explaining to show your understanding, not to build theirs
