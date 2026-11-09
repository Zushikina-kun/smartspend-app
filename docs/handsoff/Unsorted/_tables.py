from docx import Document

SRC = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\CAPSTONE_LucidFrame_-_SMARTSPEND__5_ (1).docx"
doc = Document(SRC)

print(f"TOTAL TABLES: {len(doc.tables)}")
print(f"TOTAL PARAGRAPHS: {len(doc.paragraphs)}")
print()

for ti, tbl in enumerate(doc.tables):
    print(f"===== TABLE {ti} ({len(tbl.rows)}x{len(tbl.columns)}) =====")
    for ri, row in enumerate(tbl.rows):
        cells = [c.text.replace("\n", "\\n") for c in row.cells]
        print(f"  R{ri}: {cells}")
    print()
