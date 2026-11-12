# -*- coding: utf-8 -*-
"""Extract all text (paragraphs, tables, image refs) from both manuscripts."""
import os
from docx import Document
from docx.oxml.ns import qn

OUT = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\v4-fixguide"

DOCS = {
    "V4": r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx",
    "FINAL": r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx",
}

def count_images(doc):
    n = 0
    for rel in doc.part.rels.values():
        if "image" in rel.reltype:
            n += 1
    return n

def has_inline_image(paragraph):
    for run in paragraph.runs:
        if run._element.findall('.//' + qn('a:blip')):
            return True
    return False

def extract(name, path):
    doc = Document(path)
    lines = []
    lines.append("=== DOC: {} ===".format(name))
    lines.append("Paragraph count: {}".format(len(doc.paragraphs)))
    lines.append("Table count: {}".format(len(doc.tables)))
    lines.append("Image rel count: {}".format(count_images(doc)))
    lines.append("")
    lines.append("### PARAGRAPHS ###")
    for i, p in enumerate(doc.paragraphs):
        txt = p.text.replace("\t", " ").strip()
        img = " [IMG]" if has_inline_image(p) else ""
        style = p.style.name if p.style else ""
        lines.append("[{:04d}] ({}){}: {}".format(i, style, img, txt))
    lines.append("")
    lines.append("### TABLES ###")
    for ti, t in enumerate(doc.tables):
        lines.append("--- Table {} (rows={}, cols={}) ---".format(ti, len(t.rows), len(t.columns)))
        for ri, row in enumerate(t.rows):
            cells = [c.text.replace("\n", " | ").strip() for c in row.cells]
            lines.append("  R{}: {}".format(ri, " || ".join(cells)))
    out = os.path.join(OUT, "{}_dump.txt".format(name))
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    return out

for name, path in DOCS.items():
    p = extract(name, path)
    print("Wrote", p)
