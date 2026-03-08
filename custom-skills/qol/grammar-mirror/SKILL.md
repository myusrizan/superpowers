---
name: grammar-mirror
description: Use when the user's message contains grammatical errors, awkward phrasing, or unclear sentence structure — especially when they appear to be a non-native speaker or write casually. Always show the corrected version of their input first, then answer.
---

# Grammar Mirror

## Overview

Before responding to the user's request, reflect back a grammatically correct version of what they said, then answer.

**Core principle:** Respect the intent, fix the form. Never change what the user meant — only how it's expressed. The correction is a gift, not a correction.

---

## When to Activate

Activate when the user's message has any of:

- Subject-verb agreement errors ("i want that claude response with")
- Missing articles ("before answering claude will response")
- Wrong verb form ("will response" → "will respond")
- Awkward or missing prepositions
- Unclear pronoun references
- Fragmented sentences

**Do NOT activate when:**
- The message is already grammatically correct (skip the mirror section entirely)
- The "error" is intentional style (e.g., "gonna", "wanna", technical shorthand)
- The message is just code or commands

---

## Output Format

When activated, structure the response as:

```
**What you said (corrected):**
> [Grammatically corrected version of the user's message — preserve exact meaning]

---

[Your actual answer to their request]
```

**Rules for the corrected version:**
1. Keep the same meaning and intent — word for word where possible
2. Fix grammar, not style. Do not rewrite or elaborate.
3. Use a blockquote (`>`) so it's visually distinct
4. Keep it to one or two sentences — don't paraphrase the entire message if it's long, just the part with errors

---

## Example

**User said:**
> "i want before answering claude will response with the grammatically correct sentence and then continue with the response"

**Output:**

**What you said (corrected):**
> "I want Claude to respond with the grammatically correct version of my sentence before answering, and then continue with the response."

---

[Answer to their actual request here]

---

## Common Fixes Reference

| Error type | Example (wrong) | Fix |
|------------|----------------|-----|
| Wrong verb form | "will response" | "will respond" |
| Missing article | "the grammatically correct sentence" before a noun needing "a" | add "a" or "the" as appropriate |
| Subject dropped | "before answering claude will..." | "Before answering, Claude will..." |
| Missing comma after intro clause | "before answering claude" | "Before answering, Claude" |
| Wrong preposition | "respond with a correct sentence" (when "provide" fits better) | choose the more natural verb |

---

## Red Flags — Do Not Over-Correct

- Do not change vocabulary to sound "smarter"
- Do not expand a short message into a long one
- Do not add formality the user didn't intend
- Do not correct dialect features (e.g., AAVE patterns) that are intentional
- If you're unsure whether something is an error or style choice — leave it
