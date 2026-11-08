"""
Fix remaining issues in CAPSTONE_5 docx:
1. Replace bare [[PENDING]] figure placeholders with descriptive text
2. Fix tense issues in methodology
3. Add defense date
"""
from docx import Document
import shutil

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0
fig_counter = [3, 1]  # starts at Figure 3.1

def fix_para(para):
    global fixes
    t = para.text.strip()
    
    # Fix bare [[PENDING]] - these are figure placeholders in table cells
    if t == '[[PENDING]]':
        for run in para.runs:
            run.text = ''
        if para.runs:
            para.runs[0].text = '[Figure to be inserted — see TODO guide for instructions]'
        else:
            para.add_run('[Figure to be inserted — see TODO guide for instructions]')
        fixes += 1
        return
    
    # Fix tense issues
    tense_fixes = [
        ('this study will adopt a descriptive-developmental',
         'this study adopted a descriptive-developmental'),
        ('the researchers will utilize a Kanban board',
         'the researchers utilized a Kanban board'),
        ('The Development Phase will involve the actual implementation',
         'The Development Phase involved the actual implementation'),
        ('The Design Phase will involve',
         'The Design Phase involved'),
        ('The Testing Phase, the researchers will conduct',
         'The Testing Phase, the researchers conducted'),
        ('researchers will evaluate the overall performance',
         'researchers evaluated the overall performance'),
    ]
    for old, new in tense_fixes:
        if old.lower() in para.text.lower():
            for run in para.runs:
                if old.lower() in run.text.lower():
                    import re
                    run.text = re.sub(re.escape(old), new, run.text, flags=re.IGNORECASE)
                    fixes += 1
            for elem in para._p.iter():
                if hasattr(elem, 'text') and elem.tag.endswith('}t') and elem.text and old.lower() in elem.text.lower():
                    import re
                    elem.text = re.sub(re.escape(old), new, elem.text, flags=re.IGNORECASE)
                    fixes += 1

# Fix all paragraphs
for p in doc.paragraphs:
    fix_para(p)

# Fix table cells too
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                fix_para(p)

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f"Fixed {fixes} issues")

# Update FOR_CYRILLE copy
shutil.copy2(
    'docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx',
    'docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT.docx'
)
print("FOR_CYRILLE copy updated")

# Final count
doc2 = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
full2 = ' '.join(p.text for p in doc2.paragraphs)
pending = full2.count('[[PENDING]]')
print(f"Remaining [[PENDING]]: {pending}")
print(f"November 10 present: {'November 10' in full2}")
print(f"61.83 present: {'61.83' in full2}")
print(f"DIT present: {'Mangaoang, DIT' in full2}")
