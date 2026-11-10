"""Inspect TOC-area paragraphs in the saved FINAL to check for corrupted entries."""
from docx import Document
import re

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')
paras = list(doc.paragraphs)

# Check paras 120-165 (TOC/list of figures area, 0-indexed 119-164)
print("=== TOC/Figure List Area (para 120-165) ===")
for i in range(119, min(165, len(paras))):
    p = paras[i]
    t = p.text
    if t.strip():
        print(f"  Para {i+1}: {repr(t[:120])}")

# Also check for any garbled entries with excessive whitespace
print("\n=== Paragraphs with excessive internal whitespace (possible corruption) ===")
for i, p in enumerate(paras):
    t = p.text
    if '   ' in t and len(t) > 10:  # 3+ spaces in a row is unusual
        # Check if it looks like a figure/table entry
        if re.match(r'^\d+\.\d+', t.strip()):
            print(f"  Para {i+1}: {repr(t[:150])}")
