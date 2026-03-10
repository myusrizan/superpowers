---
name: pdf
description: Use when reading, analyzing, extracting information from, or summarizing PDF files. Invoke when the user provides a PDF file, asks to read a PDF, extract data from a PDF, or summarize a PDF document.
---

# PDF Processing

## Overview

Read, analyze, and extract structured information from PDF files.

**Core principle:** Read the full document before extracting. Partial reads produce partial answers.

---

## Reading PDFs

Use the Read tool to read PDF files directly:

```
Read the file at [path/to/file.pdf]
```

For large PDFs (> 10 pages), read in sections:
- Pages 1–10 first (typically: executive summary, intro, key conclusions)
- Then targeted sections based on what the user needs

---

## Extraction Workflows

### Extract Key Information

After reading the PDF, structure the output based on document type:

**For reports/research:**
```markdown
## Summary
[2-3 sentence overview of the document's purpose and main finding]

## Key Findings
1. [Finding 1 — with page reference]
2. [Finding 2 — with page reference]

## Data / Statistics
| Metric | Value | Source (page) |
|--------|-------|---------------|
| [metric] | [value] | p.X |

## Recommendations (if present)
- [Recommendation 1]

## Methodology (if relevant)
[How the research/analysis was conducted]
```

**For contracts/legal documents:**
```markdown
## Parties
- Party 1: [name, role]
- Party 2: [name, role]

## Key Terms
- Effective Date:
- Term/Duration:
- Payment Terms:
- Termination Clauses:

## Obligations
- Party 1 must: [...]
- Party 2 must: [...]

## Important Dates / Deadlines
| Date | What happens |
|------|-------------|
| [date] | [event] |

## Risks / Red Flags
- [Any concerning clauses or ambiguous language]
```

**For financial documents:**
```markdown
## Period
[Reporting period]

## Key Figures
| Metric | Value | Change YoY |
|--------|-------|-----------|
| Revenue | $X | +X% |
| ...

## Notable Items
- [Unusual line items, one-time charges, commentary]
```

---

## Analysis Workflows

### Summarize

Produce a summary at the requested depth:

| Mode | Length | Content |
|------|--------|---------|
| **tldr** | 1–3 sentences | The single most important point |
| **executive** | 1 paragraph | Purpose, main finding, implications |
| **standard** | 1–2 pages | All major sections, key data |
| **detailed** | Full | Every section with evidence |

### Compare Multiple PDFs

When comparing two or more documents:
1. Read all documents first
2. Identify shared dimensions (topics, time periods, metrics)
3. Build a comparison table
4. Note what's present in one but absent in another

### Find Specific Information

When asked to find something specific:
```
1. Scan the document structure (table of contents if present)
2. Jump to the most likely section
3. Return the exact quote + page number
4. Note if the information is absent
```

---

## Output Rules

- **Always cite page numbers** when extracting specific facts
- **Quote directly** for anything with precise legal or factual significance
- **Note uncertainty** — "appears to be" when text is ambiguous or cut off
- **Flag if the PDF is scanned** — scanned PDFs may have OCR errors; note any suspected errors

---

## Hard Rules

- **Read before summarizing.** Never summarize a PDF you haven't read.
- **Page references required for facts.** "The report says X" without a page number is unverifiable.
- **Distinguish your analysis from the document's claims.** Use "the document states" vs. "this means".
- **Note what's missing.** If the user asks for information not in the PDF, say so explicitly.
