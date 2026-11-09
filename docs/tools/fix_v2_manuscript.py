"""
Fix SmartSpend_Manuscript_updated_v2.docx:
1. Update exclusion reason: "6 excluded for insufficient app usage time" 
   → "5 excluded for insufficient app usage time and 1 excluded for straight-line response bias"
2. Fix "acceptable" wording in Chapter IV to match Table 3.3
3. Copy to FOR_CYRILLE
"""
from docx import Document
from docx.oxml.ns import qn
import re, shutil

fname = 'docs/handsoff/SmartSpend_Manuscript_updated_v2.docx'
doc = Document(fname)
fixes = 0

all_paras = list(doc.paragraphs)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            all_paras.extend(cell.paragraphs)

def replace_in_para(para, old, new):
    global fixes
    if old.lower() not in para.text.lower():
        return False
    changed = False
    for run in para.runs:
        if old.lower() in run.text.lower():
            run.text = re.sub(re.escape(old), new, run.text, flags=re.IGNORECASE)
            fixes += 1
            changed = True
    if not changed:
        for t_elem in para._p.findall('.//' + qn('w:t')):
            if t_elem.text and old.lower() in t_elem.text.lower():
                t_elem.text = re.sub(re.escape(old), new, t_elem.text, flags=re.IGNORECASE)
                fixes += 1
                changed = True
    return changed

replacements = [
    # Fix exclusion reason - 6 excluded → 5 for time + 1 for straight-lining
    ('6 excluded for insufficient app usage time',
     '5 excluded for insufficient app usage time and 1 excluded for straight-line response bias (all items rated at the maximum)'),
    ('6 were excluded for not using the app for the required minimum',
     '5 were excluded for not using the app for the required minimum duration, and 1 was excluded for straight-line response bias (uniform maximum ratings across all items)'),
    ('The remaining 6 were excluded',
     'The remaining 6 were excluded: 5 for insufficient app usage time and 1 for straight-line response bias'),
    # Fix "acceptable" wording inconsistency
    ('acceptable for a prototype system',
     'below the target threshold, acknowledged as a prototype limitation'),
    ('this is acceptable for a prototype',
     'this is a known limitation of the current prototype'),
]

for para in all_paras:
    for old, new in replacements:
        if replace_in_para(para, old, new):
            print(f"Fixed: {old[:60]} → {new[:60]}")

doc.save(fname)
print(f"\nTotal fixes: {fixes}")

# Copy to FOR_CYRILLE
shutil.copy2(fname, 'docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT.docx')
print("Copied to FOR_CYRILLE/1_MAIN_MANUSCRIPT.docx")

# Final verification
doc2 = Document(fname)
full2 = ' '.join(p.text for p in doc2.paragraphs)
for table in doc2.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                full2 += ' ' + p.text

checks = [
    ('straight-line response bias', True),
    ('6 excluded for insufficient', False),
    ('acceptable for a prototype system', False),
    ('61.83', True),
    ('96.7%', True),
    ('Mangaoang, DIT', True),
]
print("\nVerification:")
for term, should in checks:
    found = term.lower() in full2.lower()
    ok = found == should
    print(f"  {'OK' if ok else 'ISSUE'}: {term}")
