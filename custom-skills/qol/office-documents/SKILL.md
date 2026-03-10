---
name: office-documents
description: Use when creating, editing, or working with Office documents — PowerPoint presentations (pptx), Word documents (docx), or Excel spreadsheets (xlsx). Invoke when the user wants to create a presentation, write a Word doc, build a spreadsheet, or export data to Office format.
---

# Office Documents

## Overview

Create and edit PowerPoint, Word, and Excel files using Python with the python-pptx, python-docx, and openpyxl libraries.

**Core principle:** Code the document structure, don't describe it. A script that generates the file is reproducible; manual instructions are not.

---

## Setup

```bash
pip install python-pptx python-docx openpyxl
```

---

## PowerPoint (PPTX)

### Create a presentation

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN

prs = Presentation()

# Title slide
slide_layout = prs.slide_layouts[0]  # 0=title, 1=title+content, 6=blank
slide = prs.slides.add_slide(slide_layout)
slide.shapes.title.text = "Presentation Title"
slide.placeholders[1].text = "Subtitle or author"

# Content slide
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Section Title"
tf = slide.placeholders[1].text_frame
tf.text = "First bullet"
p = tf.add_paragraph()
p.text = "Second bullet"
p.level = 1  # sub-bullet

prs.save("output.pptx")
```

### Add an image

```python
from pptx.util import Inches
slide.shapes.add_picture("image.png", Inches(1), Inches(1), Inches(4), Inches(3))
```

### Add a table

```python
from pptx.util import Inches
table = slide.shapes.add_table(rows=3, cols=3, left=Inches(1), top=Inches(2),
                                width=Inches(8), height=Inches(2)).table
table.cell(0, 0).text = "Header 1"
table.cell(0, 1).text = "Header 2"
```

---

## Word Document (DOCX)

### Create a document

```python
from docx import Document
from docx.shared import Pt, Inches

doc = Document()

# Heading styles: 0=Title, 1=Heading1, 2=Heading2, etc.
doc.add_heading("Document Title", 0)
doc.add_heading("Section 1", 1)

doc.add_paragraph("This is body text.")

# Styled paragraph
p = doc.add_paragraph()
run = p.add_run("Bold text ")
run.bold = True
run = p.add_run("normal text")

# List
doc.add_paragraph("Item 1", style="List Bullet")
doc.add_paragraph("Item 2", style="List Bullet")
doc.add_paragraph("Sub-item", style="List Bullet 2")

# Table
table = doc.add_table(rows=2, cols=3)
table.style = "Table Grid"
table.cell(0, 0).text = "Header 1"
table.cell(1, 0).text = "Data 1"

doc.save("output.docx")
```

---

## Excel Spreadsheet (XLSX)

### Create a spreadsheet

```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

wb = Workbook()
ws = wb.active
ws.title = "Sheet 1"

# Write headers
headers = ["Name", "Value", "Category"]
for col, header in enumerate(headers, 1):
    cell = ws.cell(row=1, column=col, value=header)
    cell.font = Font(bold=True)
    cell.fill = PatternFill(fill_type="solid", fgColor="4472C4")

# Write data
data = [("Alpha", 100, "A"), ("Beta", 200, "B")]
for row_idx, row_data in enumerate(data, 2):
    for col_idx, value in enumerate(row_data, 1):
        ws.cell(row=row_idx, column=col_idx, value=value)

# Auto-size columns
for col in ws.columns:
    max_len = max(len(str(cell.value or "")) for cell in col)
    ws.column_dimensions[get_column_letter(col[0].column)].width = max_len + 2

# Add formula
ws["D2"] = "=B2*2"

wb.save("output.xlsx")
```

### Read existing spreadsheet

```python
from openpyxl import load_workbook

wb = load_workbook("existing.xlsx")
ws = wb.active

for row in ws.iter_rows(min_row=2, values_only=True):
    print(row)
```

---

## Workflow

1. **Clarify format** — which document type? What content?
2. **Write the generation script** in Python
3. **Run the script** to produce the file
4. **Verify** by reporting: filename, size, key content sections created
5. **Iterate** if user wants changes — modify the script, re-run

---

## Hard Rules

- **Generate via script, not manual steps.** The script is the artifact — it can be rerun.
- **Save with a descriptive filename.** `report-2026-03-10.xlsx` not `output.xlsx`.
- **Verify the file was created** before reporting success.
- **Ask for content before generating.** Don't write a document with placeholder content unless explicitly asked.
