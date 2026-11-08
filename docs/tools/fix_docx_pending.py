"""Fix bad values and categorize all [[PENDING]] tags in CAPSTONE_5 docx."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

def fix_para(para):
    global fixes
    replacements = [
        ('63.06', '61.83'),
        ('56.30', '61.83'),
        ('62.50', '61.83'),
        ('N=31', 'N=30'),
        ('N=33', 'N=30'),
        ('N=25', 'N=30'),
        ('97.0%', '96.7%'),
        ('SD = 18.59', 'SD = 17.58'),
        ('SD=18.59', 'SD=17.58'),
        ('18.59', '17.58'),
        ('Mangaoang, MIT', 'Mangaoang, DIT'),
        ('13 (preliminary, target N=30)', '30'),
        ('9 parents aged 35 to 55 (primary target population) and 4 young professionals', '13 parents aged 35 to 55 (primary target population) and 14 young professionals'),
    ]
    for old, new in replacements:
        if old in para.text:
            for run in para.runs:
                if old in run.text:
                    run.text = run.text.replace(old, new)
                    fixes += 1
            for elem in para._p.iter():
                if hasattr(elem, 'text') and elem.text and old in elem.text:
                    elem.text = elem.text.replace(old, new)
                    fixes += 1

for p in doc.paragraphs:
    fix_para(p)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                fix_para(p)

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f"Applied {fixes} fixes")

# Now categorize all [[PENDING]] tags
doc2 = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
pending_figure = []
pending_survey = []
pending_text = []
pending_other = []

for p in doc2.paragraphs:
    t = p.text.strip()
    if '[[PENDING' in t or 'PENDING' in t.upper() and '[[' in t:
        tl = t.lower()
        if 'figure' in tl or 'insert' in tl or 'image' in tl or 'screenshot' in tl:
            pending_figure.append(t[:100])
        elif 'survey' in tl or 'respondent' in tl or 'n=' in tl or 'table 3.' in tl:
            pending_survey.append(t[:100])
        elif 'write' in tl or 'state' in tl or 'describe' in tl or 'after' in tl:
            pending_text.append(t[:100])
        else:
            pending_other.append(t[:100])

print(f"\n=== [[PENDING]] CATEGORIES ===")
print(f"Figure/image inserts: {len(pending_figure)}")
for p in pending_figure[:5]: print(f"  {p}")
print(f"\nSurvey data fills: {len(pending_survey)}")
for p in pending_survey[:5]: print(f"  {p}")
print(f"\nText paragraphs to write: {len(pending_text)}")
for p in pending_text[:5]: print(f"  {p}")
print(f"\nOther: {len(pending_other)}")
for p in pending_other[:5]: print(f"  {p}")

total = len(pending_figure) + len(pending_survey) + len(pending_text) + len(pending_other)
print(f"\nTotal [[PENDING]] tags: {total}")
print(f"  - Figures (Cyrille inserts): {len(pending_figure)}")
print(f"  - Survey data (auto-fill done in .md): {len(pending_survey)}")
print(f"  - Text paragraphs (Cyrille writes): {len(pending_text)}")
print(f"  - Other: {len(pending_other)}")
