import sys
from docx import Document

SRC = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\CAPSTONE_LucidFrame_-_SMARTSPEND__5_ (1).docx"
doc = Document(SRC)

print("=" * 80)
print("PARAGRAPHS (index | style | text)")
print("=" * 80)
for i, p in enumerate(doc.paragraphs):
    txt = p.text
    style = p.style.name if p.style else "?"
    # Only print non-empty or headings to keep output manageable
    if txt.strip() or "Heading" in style or "Title" in style:
        print(f"[{i}] ({style}) {txt!r}")

print()
print("=" * 80)
print("TABLES")
print("=" * 80)
for ti, tbl in enumerate(doc.tables):
    print(f"--- TABLE {ti} ({len(tbl.rows)} rows x {len(tbl.columns)} cols) ---")
    for ri, row in enumerate(tbl.rows):
        cells = [c.text.replace("\n", " | ") for c in row.cells]
        print(f"  R{ri}: {cells}")
