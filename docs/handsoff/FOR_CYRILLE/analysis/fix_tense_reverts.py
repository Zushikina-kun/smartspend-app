"""Fix paras 348 and 349 which had tense reverted by the merge (apply->applied, ships->shipped)."""
from docx import Document
import re

FINAL_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

doc = Document(FINAL_PATH)
paras = list(doc.paragraphs)

fixes = 0

# Para 348 (0-indexed 347): 'behaviours apply' should be 'behaviours applied'
p348 = paras[347]
for run in p348.runs:
    if 'behaviours apply ' in run.text:
        run.text = run.text.replace('behaviours apply ', 'behaviours applied ')
        print(f"  Para 348: Fixed 'behaviours apply' -> 'behaviours applied'")
        fixes += 1

# Para 349 (0-indexed 348): 'ships with' should be 'shipped with'
p349 = paras[348]
for run in p349.runs:
    if 'ships with' in run.text:
        run.text = run.text.replace('ships with', 'shipped with')
        print(f"  Para 349: Fixed 'ships with' -> 'shipped with'")
        fixes += 1

# Also check for 'falls below' -> 'fell below', 'becomes' -> 'became' in p349
for run in p349.runs:
    if ' falls ' in run.text:
        run.text = run.text.replace(' falls ', ' fell ')
        print(f"  Para 349: Fixed 'falls' -> 'fell'")
        fixes += 1
    if ' becomes ' in run.text:
        run.text = run.text.replace(' becomes ', ' became ')
        print(f"  Para 349: Fixed 'becomes' -> 'became'")
        fixes += 1

print(f"\nTotal fixes: {fixes}")

# Verify
p348_text = p348.text
p349_text = p349.text
print(f"\nPara 348 now: {p348_text[:200]}")
print(f"Para 349 now: {p349_text[:200]}")

doc.save(FINAL_PATH)
print("\nSaved.")
