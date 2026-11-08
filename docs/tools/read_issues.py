"""Read full text of all flagged paragraphs."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')

print("=== FUTURE TENSE ISSUES (full text) ===\n")
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if re.search(r'(will conduct|will adopt|will utilize|will be distributed|Phase will involve|will conduct int)', t, re.IGNORECASE):
        print(f"P{i}: {t[:300]}")
        print()

print("\n=== OLD VERSION v2.9 CONTEXT ===\n")
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if re.search(r'v2\.9\.\d+', t, re.IGNORECASE):
        print(f"P{i}: {t[:300]}")
        print()

print("\n=== TBD IN TABLE ===\n")
for ti, table in enumerate(doc.tables):
    for ri, row in enumerate(table.rows):
        for ci, cell in enumerate(row.cells):
            for p in cell.paragraphs:
                if p.text.strip() == 'TBD':
                    print(f"T{ti}R{ri}C{ci}: TBD")
                    # Print surrounding row for context
                    row_texts = [c.text.strip() for c in row.cells]
                    print(f"  Row: {row_texts}")

print("\n=== DUPLICATE WORD ===\n")
for i, p in enumerate(doc.paragraphs):
    if 'SmartSpend SmartSpend' in p.text:
        print(f"P{i}: {p.text.strip()[:200]}")

print("\n=== FIGURE PLACEHOLDER IN TABLE ===\n")
for ti, table in enumerate(doc.tables):
    for ri, row in enumerate(table.rows):
        for ci, cell in enumerate(row.cells):
            for p in cell.paragraphs:
                if '[Figure to be inserted' in p.text:
                    row_texts = [c.text.strip()[:40] for c in row.cells]
                    print(f"T{ti}R{ri}C{ci}: {row_texts}")
