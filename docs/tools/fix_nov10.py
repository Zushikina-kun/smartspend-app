"""Fix defense date and add Table 2.X placeholder in CAPSTONE_5 docx."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

date_patterns = [
    'November 9, 2026',
    'November 9,2026',
    'Nov 9, 2026',
    'Nov. 9, 2026',
]

def fix_para_text(para, old, new):
    global fixes
    # Try runs first
    full = para.text
    if old.lower() not in full.lower():
        return False
    for run in para.runs:
        if old.lower() in run.text.lower():
            run.text = run.text.replace(old, new)
            fixes += 1
            return True
    # Try XML elements
    for elem in para._p.iter():
        if hasattr(elem, 'text') and elem.text and old.lower() in elem.text.lower():
            elem.text = elem.text.replace(old, new)
            fixes += 1
            return True
    return False

all_paras = list(doc.paragraphs)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            all_paras.extend(cell.paragraphs)

for para in all_paras:
    for old_date in date_patterns:
        # Only fix if it's the DEFENSE date context (near "defense", "final", "examination")
        ctx = para.text.lower()
        if old_date.lower() in ctx:
            if any(w in ctx for w in ['defense', 'final', 'examination', 'oral', 'november 9']):
                # Check it's not the "reporting" date context
                if 'progress' not in ctx and 'reporting' not in ctx:
                    fix_para_text(para, old_date, 'November 10, 2026')
                    print(f'Fixed date: {para.text[:100]}')

# Also fix approval sheet area which often has the date
for i, para in enumerate(doc.paragraphs[:50]):
    for old_date in date_patterns:
        if old_date.lower() in para.text.lower():
            fix_para_text(para, old_date, 'November 10, 2026')
            print(f'Fixed date in first 50 paras: {para.text[:80]}')

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f'Total fixes: {fixes}')
