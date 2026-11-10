"""Check specific paragraphs that may have had tense reverted."""
from docx import Document
import re

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')
paras = list(doc.paragraphs)

# Check paras 345-355 (0-indexed 344-354) for tense issues
print("=== Para 345-360 (tense check) ===")
for i in range(344, min(360, len(paras))):
    p = paras[i]
    t = p.text.strip()
    if t:
        print(f"  Para {i+1}: {t[:200]}")

# Specifically look for present-tense reversal keywords in past-narrative sections
print("\n=== Searching for present-tense verbs that should be past ===")
present_verbs = ['behaviours apply', 'ships with', 'shipped with', 'applies the same', 'falls below']
for i, p in enumerate(paras):
    t = p.text
    for v in present_verbs:
        if v.lower() in t.lower():
            print(f"  Para {i+1}: FOUND '{v}' -> {t[:150]}")
