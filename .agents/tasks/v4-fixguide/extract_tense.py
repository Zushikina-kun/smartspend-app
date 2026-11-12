# -*- coding: utf-8 -*-
"""Extract the tense corrections list."""
import os
from docx import Document

OUT = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\v4-fixguide"
path = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\SmartSpend_Tense_Corrections_List.docx"

doc = Document(path)
lines = []
lines.append("=== TENSE CORRECTIONS LIST ===")
lines.append("Paragraphs: {}".format(len(doc.paragraphs)))
lines.append("Tables: {}".format(len(doc.tables)))
lines.append("")
# Try tables first (corrections list is usually a table)
for ti, t in enumerate(doc.tables):
    lines.append("--- Table {} (rows={}, cols={}) ---".format(ti, len(t.rows), len(t.columns)))
    for ri, row in enumerate(t.rows):
        cells = [c.text.replace("\n", " | ").strip() for c in row.cells]
        lines.append("R{:04d}: {}".format(ri, " || ".join(cells)))
lines.append("")
lines.append("### PARAGRAPHS ###")
for i, p in enumerate(doc.paragraphs):
    txt = p.text.strip()
    if txt:
        lines.append("[{:04d}]: {}".format(i, txt))

out = os.path.join(OUT, "TENSE_dump.txt")
with open(out, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print("Wrote", out)
