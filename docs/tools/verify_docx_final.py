"""Verify key values in CAPSTONE_5 docx."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')

all_text = []
for p in doc.paragraphs:
    if p.text.strip():
        all_text.append(p.text)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                if p.text.strip():
                    all_text.append(p.text)

full = ' '.join(all_text)

checks = {
    '36 achievement badges': True,
    '25 achievement badges': False,  # should NOT exist
    '34 agentic': True,
    '31 agentic': False,
    '62.50': True,
    'Grade D': False,
    'Mangaoang, DIT': True,
    'Mangaoang, MIT': False,
    'Layco, MIS': True,
    'November 10, 2026': True,
    'Verzola': False,
}

print('=== CAPSTONE_5 DOCX VERIFICATION ===')
issues = []
for term, should_exist in checks.items():
    found = term.lower() in full.lower()
    ok = found == should_exist
    status = '✅' if ok else '❌'
    print(f'{status} {term}: {"found" if found else "not found"} (expected: {"present" if should_exist else "absent"})')
    if not ok:
        issues.append(term)

print()
if issues:
    print(f'ISSUES: {issues}')
else:
    print('All checks passed!')
