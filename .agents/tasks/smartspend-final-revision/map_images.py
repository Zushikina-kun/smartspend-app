"""
Map every image in the DOCX to its paragraph context (nearby text)
so we know which image file = which Figure number.
"""
from docx import Document
from docx.oxml.ns import qn
import os

DOCX = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"
doc = Document(DOCX)

# Build a list of (paragraph_index, paragraph_text, has_image)
results = []
img_counter = 1

for i, para in enumerate(doc.paragraphs):
    text = para.text.strip()
    # Check if this paragraph contains an image
    has_img = False
    for run in para.runs:
        drawings = run._r.findall('.//' + qn('a:blip'), run._r.nsmap) if run._r.nsmap else []
        # simpler check
        if run._r.find('.//' + qn('wp:inline')) is not None or run._r.find('.//' + qn('wp:anchor')) is not None:
            has_img = True
            break
        # also check for drawing
        if run._r.find('.//' + qn('a:blip')) is not None:
            has_img = True
            break

    if has_img:
        # Get context: this para text + next 2 paras
        ctx_parts = [text]
        for j in range(i+1, min(i+3, len(doc.paragraphs))):
            t = doc.paragraphs[j].text.strip()
            if t:
                ctx_parts.append(t)
        ctx = " | ".join(ctx_parts)
        results.append((img_counter, i, ctx[:200]))
        img_counter += 1

print(f"Found {len(results)} image paragraphs:\n")
for num, para_idx, ctx in results:
    print(f"  image{num}: para[{para_idx}] → {ctx!r}")
