# -*- coding: utf-8 -*-
"""Extract full text + structure of V4(2) manuscript for read-only investigation."""
import os, re
from docx import Document
from docx.oxml.ns import qn

OUT = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-v4-investigation"
V42 = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (2).docx"
V41 = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx"

def count_images(doc):
    return sum(1 for rel in doc.part.rels.values() if "image" in rel.reltype)

def has_inline_image(p):
    for run in p.runs:
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
        lines.append("--- Table idx {} (rows={}, cols={}) ---".format(ti, len(t.rows), len(t.columns)))
        for ri, row in enumerate(t.rows):
            cells = [c.text.replace("\n", " | ").strip() for c in row.cells]
            lines.append("  R{}: {}".format(ri, " || ".join(cells)))
    out = os.path.join(OUT, "{}_dump.txt".format(name))
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    return out, len(doc.paragraphs), len(doc.tables), count_images(doc)

for name, path in [("V4_2", V42), ("V4_1", V41)]:
    try:
        out, np_, nt_, ni_ = extract(name, path)
        print("Wrote {} (paras={}, tables={}, imgs={})".format(out, np_, nt_, ni_))
    except Exception as e:
        print("ERR", name, e)

# Structural summary for V4(2): headings, figure captions, table captions, list-of-figs/tables
doc = Document(V42)
s = []
s.append("=== V4(2) STRUCTURAL SUMMARY ===")
s.append("Total paragraphs: {} | tables: {} | image rels: {}".format(len(doc.paragraphs), len(doc.tables), count_images(doc)))
s.append("")
s.append("### HEADINGS (style contains Heading/Title/CHAPTER) ###")
for i, p in enumerate(doc.paragraphs):
    st = (p.style.name if p.style else "") or ""
    if re.search(r'Heading|Title|CHAPTER|TOC', st, re.I):
        s.append("[{:04d}] ({}): {}".format(i, st, p.text.strip()))
s.append("")
s.append("### PARAGRAPHS containing 'Figure' caption-like text ###")
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if re.match(r'^(Figure|Fig\.?)\s*\d', t, re.I) or re.match(r'^Figure\s', t):
        s.append("[{:04d}]: {}".format(i, t))
s.append("")
s.append("### PARAGRAPHS containing 'Table' caption-like text ###")
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if re.match(r'^(Table|Tbl\.?)\s*\d', t, re.I) or re.match(r'^Table\s', t):
        s.append("[{:04d}]: {}".format(i, t))
s.append("")
s.append("### INLINE IMAGE positions ###")
for i, p in enumerate(doc.paragraphs):
    if has_inline_image(p):
        nxt = doc.paragraphs[i+1].text.strip() if i+1 < len(doc.paragraphs) else ""
        s.append("[{:04d}] [IMG] next: {}".format(i, nxt[:120]))
with open(os.path.join(OUT, "V4_2_structure.txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(s))
print("Wrote structure summary")
