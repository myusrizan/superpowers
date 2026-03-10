---
name: llm-council
description: Use when a decision is high-stakes and benefits from multiple independent perspectives — to consult multiple reasoning passes, synthesize divergent views, and build consensus before acting. Invoke when the user says "get a second opinion", "think about this from multiple angles", or when a decision is too important to trust to a single reasoning pass.
---

# LLM Council

## Overview

Consult multiple independent reasoning passes on a decision, synthesize their perspectives, and surface genuine disagreements before committing to an answer.

**Core principle:** Consensus is more reliable than a single confident opinion. Disagreement is signal, not noise.

---

## When to Use

- High-stakes architectural decisions where a wrong choice is expensive to reverse
- Ambiguous requirements where multiple interpretations exist
- Risk assessment (security review, breaking change analysis)
- Creative problems where multiple approaches should be explored
- Any situation where "what am I missing?" is the right question

---

## Process

### Step 1: Define the Question

Frame a precise question for the council. Vague questions produce vague answers.

```
❌ "Should we use microservices?"
✅ "For a team of 3 engineers building an internal tool with 50 users, should we
    decompose auth, data, and API into separate services now, or start as a monolith?"
```

### Step 2: Dispatch Independent Reasoning Passes

Dispatch 3 separate subagent reasoning passes with identical context but different **framings**:

```
Subagent A — Devil's Advocate:
"Argue the strongest case AGAINST [option X]. What are the hidden costs, risks, and failure modes?"

Subagent B — Advocate:
"Argue the strongest case FOR [option X]. What are the concrete benefits and why do the risks not outweigh them?"

Subagent C — Neutral Analyst:
"Evaluate [option X] without advocating for or against it. List the key assumptions that must hold for it to succeed."
```

Each subagent should produce:
- 3–5 strongest points
- Evidence or examples for each point
- Confidence level (High/Medium/Low) for each point

### Step 3: Synthesize

Collect the three outputs. Look for:

| Signal | Meaning |
|--------|---------|
| All three agree on a point | High confidence — this is likely true |
| Two agree, one disputes | Moderate confidence — investigate the dissent |
| All three disagree | High uncertainty — more information needed |
| A point appears in only one | Weak signal — treat as hypothesis |

**Synthesis format:**

```markdown
## Council Synthesis

### High Confidence (3/3 agreement)
- [Point all three agreed on]

### Disputed Points (requires judgment)
- [Point]: Advocate says X. Devil's Advocate says Y. Analyst says Z.
  → Lean toward: [which is better supported and why]

### Minority Views (worth considering)
- [Point raised by one subagent only] — [assess whether to investigate]

### Recommendation
[Decision + the 2-3 strongest reasons supporting it]

### Key Risks
[The strongest counterarguments that the recommendation must accept]
```

### Step 4: Present to User

Present:
1. The recommendation
2. The key reasoning that drove it
3. The strongest counterarguments (from Devil's Advocate pass)
4. What would change the recommendation (conditions)

---

## Hard Rules

- **Identical context for all subagents.** Different information → incomparable outputs.
- **Explicit framing per subagent.** Without a role, all passes converge on the same answer.
- **Don't bury the recommendation.** Lead with the answer, then the reasoning.
- **Report genuine disagreement.** If the council can't reach consensus, that IS the finding — tell the user.
- **Limit to 3 passes for most decisions.** More passes add noise, not signal.
