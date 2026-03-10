---
name: doc-coauthoring
description: Use when collaboratively editing a document with a human — iterating on drafts, tracking versions, and managing structured feedback cycles. Invoke when asked to "work on a doc together", "iterate on this draft", or "help me write and refine this document".
---

# Doc Co-Authoring

## Overview

A collaborative document editing workflow for iterative drafting with a human author.

**Core principle:** Each iteration must be reviewable. Never overwrite without tracking what changed.

---

## Workflow

### Phase 1: Establish the Document

Before writing:
1. **Clarify purpose** — who reads this and what should they do after?
2. **Agree on structure** — outline first, prose second
3. **Set a version file** — `docs/<document-name>.md` (committed) and store version history

### Phase 2: Draft → Review Loop

Each cycle:

```
1. AI writes or expands a section
2. Human reviews and marks with:
   [APPROVE] — section is done
   [REVISE: <note>] — change this specifically
   [REWRITE] — start this section over
3. AI addresses all marks before next section
4. No section advances until marked [APPROVE]
```

**Version tagging:**

```markdown
<!-- v1.0 — 2026-03-10 — initial draft -->
<!-- v1.1 — 2026-03-10 — revised intro per feedback -->
```

### Phase 3: Final Review

Before calling the document complete:
- [ ] All sections marked [APPROVE]
- [ ] No [REVISE] or [REWRITE] marks remaining
- [ ] Document reads top-to-bottom without revision artifacts
- [ ] All links, references, and examples verified

---

## Feedback Protocol

When receiving feedback:

| Marker | Meaning | Response |
|--------|---------|----------|
| `[APPROVE]` | Done | Move to next section |
| `[REVISE: note]` | Specific change needed | Address the note, re-present |
| `[REWRITE]` | Start over | Ask: what was wrong? Then rewrite |
| `[QUESTION: ?]` | Clarification needed | Answer before editing |

**Rule:** Never skip feedback. If there are 3 [REVISE] marks, address all 3 before moving on.

---

## Hard Rules

- **Outline before prose.** Agree on structure before writing content.
- **One section at a time.** Don't advance past an unreviewed section.
- **Tag every version.** Changes without version tags are untrackable.
- **Don't silently incorporate feedback** — state what changed: "Revised intro: shortened from 3 paragraphs to 1, removed the history section per your note."
