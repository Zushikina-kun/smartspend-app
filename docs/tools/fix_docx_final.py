"""Final sync of all markdown fixes into CAPSTONE_5 docx."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

def fix_runs(para, old, new):
    global fixes
    changed = False
    for run in para.runs:
        if old.lower() in run.text.lower():
            run.text = re.sub(re.escape(old), new, run.text, flags=re.IGNORECASE)
            fixes += 1
            changed = True
    if not changed:
        for elem in para._p.iter():
            if hasattr(elem, 'text') and elem.text and old.lower() in elem.text.lower():
                elem.text = re.sub(re.escape(old), new, elem.text, flags=re.IGNORECASE)
                fixes += 1
    return changed

replacements = [
    # Badge counts
    ('25 achievement badges', '36 achievement badges'),
    ('25 habit achievement badges', '36 habit achievement badges'),
    ('23 achievement badges', '36 achievement badges'),
    # Actions
    ('31 agentic actions', '34 agentic actions'),
    ('31 conversational actions', '34 conversational actions'),
    ('31 distinct data actions', '34 distinct data actions'),
    # SUS Grade labels
    ('Grade D / "OK"', '"OK" per Bangor et al. (2009)'),
    ('Marginal (Grade D)', 'Marginal / OK'),
    ('Grade D per Bangor', '"OK" per Bangor'),
    # Defense date
    ('Final Defense: November 9, 2026', 'Final Defense: November 10, 2026'),
    ('defense on November 9', 'defense on November 10'),
    # Warren year
    ('Warren & Tyagi (2004)', 'Warren & Tyagi (2005)'),
    # Adviser title - MIT already fixed but confirm
    ('Mangaoang, MIT', 'Mangaoang, DIT'),
]

for para in doc.paragraphs:
    for old, new in replacements:
        fix_runs(para, old, new)

# Also fix in tables
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for para in cell.paragraphs:
                for old, new in replacements:
                    fix_runs(para, old, new)

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f'Applied {fixes} fixes to CAPSTONE_5 docx')
