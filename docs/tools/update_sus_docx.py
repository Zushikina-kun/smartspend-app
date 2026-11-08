"""Update SUS numbers in CAPSTONE_5 docx from old to new."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

replacements = [
    ('56.30', '63.06'),
    ('62.50', '63.06'),
    ('SD = 13.43', 'SD = 18.59'),
    ('SD=13.43', 'SD=18.59'),
    ('N=5)', 'N=31)'),
    ('N=25', 'N=31'),
    ('n=25', 'n=31'),
    ('(N=5)', '(N=31)'),
    ('N=5 ', 'N=31 '),
    ('Preliminary SUS result (N=5)', 'Final SUS result (N=31)'),
    ('N=5 of target N=30', 'N=31 screened from N=36'),
]

def fix_para(para):
    global fixes
    for old, new in replacements:
        if old.lower() in para.text.lower():
            for run in para.runs:
                if old.lower() in run.text.lower():
                    run.text = run.text.replace(old, new)
                    fixes += 1
            for elem in para._p.iter():
                if hasattr(elem, 'text') and elem.text and old in elem.text:
                    elem.text = elem.text.replace(old, new)
                    fixes += 1

for para in doc.paragraphs:
    fix_para(para)

for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for para in cell.paragraphs:
                fix_para(para)

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f'Applied {fixes} SUS number fixes to docx')

# Verify
doc2 = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
full = ' '.join(p.text for p in doc2.paragraphs)
print(f'63.06 present: {"63.06" in full}')
print(f'56.30 remaining: {"56.30" in full}')
print(f'62.50 remaining: {"62.50" in full}')
