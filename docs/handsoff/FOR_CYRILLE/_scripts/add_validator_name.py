"""Add Avigail Candevario, PFMe to validation paragraphs in Ch II."""
import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.validator.backup')
doc = Document(DOCX)

fixes = []

replacements = [
    # (old_text, new_text)
    (
        'underwent content validation by a subject matter expert in financial management and business operations',
        'underwent content validation by Avigail Candevario, PFMe, a subject matter expert in financial management and business operations'
    ),
    (
        'submitted to a subject matter expert in financial management for content validation',
        'submitted to Avigail Candevario, PFMe, a subject matter expert in financial management, for content validation'
    ),
    (
        "The expert's credentials was recorded in the Content",
        "The validator's credentials were recorded in the Content"
    ),
    (
        "The expert's credentials were recorded in the Content",
        "The validator's credentials were recorded in the Content"
    ),
    # Also fix credentials typo if present
    (
        "credentials was recorded",
        "credentials were recorded"
    ),
]

for i, para in enumerate(doc.paragraphs):
    t = para.text
    for old, new in replacements:
        if old in t:
            # Replace across runs
            full = para.text
            new_full = full.replace(old, new, 1)
            if new_full != full and para.runs:
                para.runs[0].text = new_full
                for run in para.runs[1:]:
                    run.text = ''
                fixes.append(f"[{i}] REPLACED:\n  OLD: {old[:80]}\n  NEW: {new[:80]}")
                break

doc.save(DOCX)
print(f"Saved. {len(fixes)} replacements made.")
for f in fixes:
    print(f)

# Verify
doc2 = Document(DOCX)
found = any('Candevario' in p.text for p in doc2.paragraphs)
print(f"\nCandevario in doc: {'OK' if found else 'MISSING'}")
# Show where
for i, p in enumerate(doc2.paragraphs):
    if 'Candevario' in p.text:
        print(f"  Found at [{i}]: {p.text[:150]}")
