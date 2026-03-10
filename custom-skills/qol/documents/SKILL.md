---
name: documents
description: Use when working with documents — reading/analyzing/extracting from PDFs, or creating PowerPoint presentations, Word documents, or Excel spreadsheets. Invoke when the user provides a PDF to read, wants to extract data from a document, or wants to create a pptx/docx/xlsx file.
---

# Documents

Two modes. Use the mode that matches your situation.

```
Reading a PDF, contract, report, or document → Mode A: Read & Extract
Creating a presentation, Word doc, or spreadsheet → Mode B: Create (Office)
```

---

## Mode A: Read & Extract (PDF)

**Core principle:** Read the full document before extracting. Partial reads produce partial answers.

### Reading PDFs

Use the Read tool directly:

```
Read the file at [path/to/file.pdf]
```

For large PDFs (> 10 pages), read in sections:
- Pages 1–10 first (executive summary, intro, conclusions)
- Then targeted sections based on what the user needs

### Extraction Templates

**For reports/research:**
```markdown
## Summary
[2-3 sentence overview]

## Key Findings
1. [Finding — with page reference]

## Data / Statistics
| Metric | Value | Source (page) |
|--------|-------|---------------|

## Recommendations
- [Recommendation 1]
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

## Important Dates
| Date | What happens |
|------|-------------|

## Risks / Red Flags
- [Concerning clauses or ambiguous language]
```

**For financial documents:**
```markdown
## Period
[Reporting period]

## Key Figures
| Metric | Value | Change YoY |
|--------|-------|-----------|

## Notable Items
- [Unusual line items, one-time charges]
```

### Analysis Workflows

**Summarize** — at requested depth:

| Mode | Length | Content |
|------|--------|---------|
| **tldr** | 1–3 sentences | Single most important point |
| **executive** | 1 paragraph | Purpose, main finding, implications |
| **standard** | 1–2 pages | All major sections, key data |
| **detailed** | Full | Every section with evidence |

**Compare multiple PDFs:**
1. Read all documents first
2. Identify shared dimensions (topics, periods, metrics)
3. Build a comparison table
4. Note what's present in one but absent in another

**Find specific information:**
1. Scan the table of contents if present
2. Jump to the most likely section
3. Return the exact quote + page number
4. Note if the information is absent

### Hard Rules (Read)

- **Read before summarizing.** Never summarize a document you haven't read.
- **Page references required for facts.** "The report says X" without a page number is unverifiable.
- **Distinguish analysis from document claims.** "The document states" vs. "this means".
- **Flag scanned PDFs.** Scanned PDFs may have OCR errors — note any suspected errors.
- **Note what's missing.** If the user asks for information not in the PDF, say so explicitly.

---

## Mode B: Create (Office Documents)

**Core principle:** Code the document structure, don't describe it. A script that generates the file is reproducible; manual instructions are not.

### Setup

```bash
pip install python-pptx python-docx openpyxl
```

### Workflow

1. **Clarify format** — which type (pptx/docx/xlsx)? What content?
2. **Write the generation script** in Python
3. **Run the script** to produce the file
4. **Verify** — report filename and key sections created
5. **Iterate** — modify the script and re-run for changes

---

### PowerPoint (PPTX)

```python
from pptx import Presentation
from pptx.util import Inches, Pt

prs = Presentation()

# Title slide
slide = prs.slides.add_slide(prs.slide_layouts[0])  # 0=title, 1=title+content, 6=blank
slide.shapes.title.text = "Presentation Title"
slide.placeholders[1].text = "Subtitle or author"

# Content slide
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Section Title"
tf = slide.placeholders[1].text_frame
tf.text = "First bullet"
p = tf.add_paragraph()
p.text = "Sub-bullet"
p.level = 1

# Add image
slide.shapes.add_picture("image.png", Inches(1), Inches(1), Inches(4), Inches(3))

# Add table
table = slide.shapes.add_table(rows=3, cols=3,
    left=Inches(1), top=Inches(2), width=Inches(8), height=Inches(2)).table
table.cell(0, 0).text = "Header 1"

prs.save("output.pptx")
```

---

### Word Document (DOCX)

```python
from docx import Document
from docx.shared import Pt, Inches

doc = Document()

doc.add_heading("Document Title", 0)   # 0=Title, 1=Heading1, 2=Heading2
doc.add_heading("Section 1", 1)
doc.add_paragraph("Body text.")

# Styled run
p = doc.add_paragraph()
p.add_run("Bold text ").bold = True
p.add_run("normal text")

# Lists
doc.add_paragraph("Item 1", style="List Bullet")
doc.add_paragraph("Sub-item", style="List Bullet 2")

# Table
table = doc.add_table(rows=2, cols=3)
table.style = "Table Grid"
table.cell(0, 0).text = "Header"
table.cell(1, 0).text = "Data"

doc.save("output.docx")
```

---

### Excel Spreadsheet (XLSX)

```python
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill
from openpyxl.utils import get_column_letter

# Create
wb = Workbook()
ws = wb.active
ws.title = "Sheet 1"

headers = ["Name", "Value", "Category"]
for col, header in enumerate(headers, 1):
    cell = ws.cell(row=1, column=col, value=header)
    cell.font = Font(bold=True)
    cell.fill = PatternFill(fill_type="solid", fgColor="4472C4")

data = [("Alpha", 100, "A"), ("Beta", 200, "B")]
for row_idx, row_data in enumerate(data, 2):
    for col_idx, value in enumerate(row_data, 1):
        ws.cell(row=row_idx, column=col_idx, value=value)

# Auto-size columns
for col in ws.columns:
    max_len = max(len(str(cell.value or "")) for cell in col)
    ws.column_dimensions[get_column_letter(col[0].column)].width = max_len + 2

ws["D2"] = "=B2*2"  # Formulas
wb.save("output.xlsx")

# Read existing
wb = load_workbook("existing.xlsx")
for row in wb.active.iter_rows(min_row=2, values_only=True):
    print(row)
```

---

### Hard Rules (Create)

- **Generate via script, not manual steps.** The script is the artifact — it can be rerun.
- **Save with a descriptive filename.** `report-2026-03-10.xlsx` not `output.xlsx`.
- **Verify the file was created** before reporting success.
- **Ask for content before generating.** Don't produce placeholder content unless explicitly asked.
