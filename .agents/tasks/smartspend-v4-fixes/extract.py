import sys
from docx import Document
from docx.oxml.ns import qn

SRC = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (2).docx"

doc = Document(SRC)
paras = doc.paragraphs
tables = doc.tables

def has_image(p):
    # check for drawing/image blips in the run XML
    for run in p.runs:
        if run._element.findall('.//' + qn('a:blip')):
            return True
        if run._element.findall('.//' + qn('w:drawing')):
            return True
    # also inline shapes
    try:
        if p._element.findall('.//' + qn('pic:pic')):
            return True
    except Exception:
        pass
    return False

out = []
out.append(f"=== V4(2) FULL DUMP ===")
out.append(f"Paragraph count: {len(paras)} | Table count: {len(tables)}")
out.append("")

# Full paragraph dump
out.append("### PARAGRAPHS ###")
for i, p in enumerate(paras):
    style = p.style.name if p.style else "?"
    img = " [IMG]" if has_image(p) else ""
    txt = p.text.replace("\n", "\\n")
    if len(txt) > 220:
        txt = txt[:220] + "…"
    out.append(f"[{i:04d}] ({style}){img}: {txt}")

# Tables dump
out.append("")
out.append("### TABLES ###")
for ti, t in enumerate(tables):
    out.append(f"--- TABLE INDEX {ti} | rows={len(t.rows)} cols={len(t.columns)} ---")
    for ri, row in enumerate(t.rows):
        cells = []
        for ci, cell in enumerate(row.cells):
            ctext = cell.text.replace("\n", " ").strip()
            if len(ctext) > 80:
                ctext = ctext[:80] + "…"
            cells.append(f"[{ci}]{ctext}")
        out.append(f"  R{ri}: " + " | ".join(cells))

with open(r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-v4-fixes\full_dump.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(out))
print("WROTE full_dump.txt", len(out), "lines")
