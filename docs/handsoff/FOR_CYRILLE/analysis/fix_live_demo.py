"""
Fix 'live demonstration' occurrences.
Para 246: check if the full text is correct (this was REJECTed from V2 but check if it already 
           has 'live demonstration' from before the merge — if so, it needs the proper text.
Para 279: should use 'self-directed use 10+ minutes' approach instead of 'live demonstration'.

We need to restore the base text that was in FINAL before the merge for these paras.
Since git history is available, we'll re-read from groupmates V1 merge log and known correct text.

The correct text for the SUS procedure paragraph should be something like:
"Respondents were required to use the SmartSpend application independently for at least 
10 minutes using the self-directed use protocol..."

Let's look at the actual para 279 and para 246 texts more carefully.
"""
from docx import Document
import re

FINAL_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
SOURCE_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL (groupmates) V2.docx'

doc = Document(FINAL_PATH)
src_doc = Document(SOURCE_PATH)

paras = list(doc.paragraphs)
src_paras = list(src_doc.paragraphs)

# Show context around para 279
print("=== Context around Para 279 ===")
for i in range(275, min(285, len(paras))):
    p = paras[i]
    t = p.text.strip()
    if t:
        print(f"  Para {i+1}: {t[:300]}")

print("\n=== Context around Para 246 ===")
for i in range(243, min(250, len(paras))):
    p = paras[i]
    t = p.text.strip()
    if t:
        print(f"  Para {i+1}: {t[:300]}")

# Check: in the V2 source, what does para ~276 say?
print("\n=== V2 source paras 273-280 ===")
for i in range(272, min(281, len(src_paras))):
    p = src_paras[i]
    t = p.text.strip()
    if t:
        print(f"  Src Para {i+1}: {t[:300]}")
