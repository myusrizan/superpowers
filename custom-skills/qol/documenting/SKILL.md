---
name: documenting
description: Use when writing technical documentation — READMEs, API docs, architecture decision records, CHANGELOG entries, or any persistent reference meant to be read by engineers later
---

# Documenting

## Overview

Write documentation that is accurate, maintainable, and useful months after it's written.

**Core principle:** Documentation is for the reader who wasn't there. Write for someone who has no context about the decisions, the constraints, or the "why" — because that's who will read it.

---

## Documentation Types

| Type | Purpose | Key question |
|------|---------|--------------|
| **README** | Entry point — what is this and how do I use it | Can someone get started in 5 minutes? |
| **API doc** | Reference for consumers | Can someone use this without reading the source? |
| **ADR** | Architecture Decision Record — why this decision was made | Will this decision make sense in 2 years? |
| **CHANGELOG** | What changed between versions | Can someone evaluate whether to upgrade? |
| **Inline comments** | Explain non-obvious code | Is the why documented (not the what)? |

---

## README

**Structure:**

```markdown
# Project Name

One-sentence description of what this is and what problem it solves.

## What it does
[2-3 sentences. Focus on the user's problem, not the implementation.]

## Installation
[Exact commands. No "install dependencies" — show the commands.]

## Usage
[Most common use case first. Working example, not pseudo-code.]

## Configuration
[Only if required. What each option does and when to use it.]

## Contributing
[How to set up locally. How to run tests. PR expectations.]
```

**Rules:**
- First sentence must describe the problem solved, not the technology used
- Every code block must be runnable — no fill-in-the-blanks
- Link to deeper docs rather than expanding inline past ~1 page
- Badges are noise unless they convey actionable status (build passing, coverage %)

---

## API Documentation

**For each function/endpoint/method:**

```markdown
### functionName(param1, param2)

**What it does:** [One sentence — the behavior, not the implementation]

**Parameters:**
- `param1` (type, required/optional): Description. Valid values if constrained.
- `param2` (type, optional, default: X): Description.

**Returns:** (type): Description of return value. What it means.

**Throws/Errors:**
- `ErrorType`: When this is thrown and what it means.

**Example:**
[Complete, runnable example showing the most common use case]

**Notes:** [Edge cases, performance characteristics, deprecation warnings]
```

**Rules:**
- Document behavior, not source code — "returns the user's display name" not "returns `user.displayName`"
- Every parameter that accepts constrained values must list those values
- One complete working example beats three partial ones

---

## Architecture Decision Record (ADR)

**Use when:** A significant technical decision was made that future engineers need to understand.

**Structure:**

```markdown
# ADR-NNN: [Decision title]

**Date:** YYYY-MM-DD
**Status:** Accepted / Superseded by ADR-NNN / Deprecated

## Context

What situation prompted this decision? What constraints existed?
What options were considered?

## Decision

What was decided. State it as a fact: "We will use X."

## Consequences

**Positive:**
- [What this enables or improves]

**Negative / Trade-offs:**
- [What this costs or constrains]

**Risks:**
- [What could go wrong and how we'd know]
```

**Rules:**
- Context section must explain why the obvious alternative wasn't chosen
- Consequences must include trade-offs — if there are no negatives listed, the ADR is incomplete
- Status must be kept updated when decisions are superseded

---

## CHANGELOG

**Format:** [Keep a Changelog](https://keepachangelog.com) — organize by version, then by type.

```markdown
## [1.2.0] - YYYY-MM-DD

### Added
- New feature X that does Y (what problem does it solve?)

### Changed
- Behavior of Z now does W instead of V (breaking: yes/no)

### Fixed
- Bug where X caused Y under condition Z

### Deprecated
- Feature A is deprecated; use feature B instead

### Removed
- Feature C (was deprecated in 1.0.0)

### Security
- Fixed vulnerability in X (CVE-YYYY-NNNN if applicable)
```

**Rules:**
- Every entry answers: what changed AND why does it matter to the reader
- Breaking changes must be labeled explicitly
- "Improved performance" without specifics is not a changelog entry

---

## Inline Comments

**Comment the why, not the what:**

```python
# ❌ BAD: Repeats the code
# Increment counter by 1
counter += 1

# ✅ GOOD: Explains why
# Rate limit: max 10 requests/sec per RFC 6585
counter += 1
```

**Comment when:**
- The code is correct but non-obvious (workaround, quirk, performance trick)
- A simpler approach was tried and abandoned (explain why)
- External context is required (link to RFC, bug report, vendor doc)

**Don't comment when:**
- The code reads clearly as-is
- The comment just translates the code to English

---

## Common Failures

| Failure | What it looks like | Fix |
|---------|--------------------|-----|
| **Assumed context** | "After running the setup from last week's meeting..." | Write for someone who wasn't there |
| **Pseudo-code examples** | `npm install <your-package>` | Show real, runnable commands |
| **Incomplete API docs** | Documenting happy path, skipping errors | Every error case must be documented |
| **Stale docs** | README describes a feature that no longer works | Documentation is a deliverable — update it with the code |
| **Over-commenting** | Comments on every line | Comment the non-obvious; trust the code for the obvious |
| **ADR without trade-offs** | "We chose X because it's better" | Every decision has a cost — name it |

---

## When NOT to Document

- YAGNI applies to documentation too. Don't write docs for code that doesn't exist yet.
- Internal implementation details that will change — document the interface, not the internals
- Things that are genuinely obvious from reading the code
