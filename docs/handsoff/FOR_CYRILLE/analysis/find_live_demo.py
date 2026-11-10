"""Find and fix 'live demonstration' occurrences."""
from docx import Document
import re

FINAL_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
SOURCE_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL (groupmates) V2.docx'

doc = Document(FINAL_PATH)
src_doc = Document(SOURCE_PATH)

print("=== FINAL: Paras containing 'live demonstration' ===")
for i, p in enumerate(doc.paragraphs):
    if 'live demonstration' in p.text.lower():
        print(f"  Para {i+1}: {p.text[:300]}")

# Find the original text from the previous merge run / what it should say
print("\n=== V2 Source paras with 'live demonstration' ===")
for i, p in enumerate(src_doc.paragraphs):
    if 'live demonstration' in p.text.lower():
        print(f"  Src Para {i+1}: {p.text[:300]}")

# Our correct text should have 'self-directed use' instead
# Let's also look at what the correct para should be from base
print("\n=== Check paras around any self-directed use mention ===")
for i, p in enumerate(doc.paragraphs):
    if 'self-directed' in p.text.lower() or 'self directed' in p.text.lower():
        print(f"  Para {i+1}: {p.text[:300]}")
