import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.figref.bak')
doc = Document(DOCX)
fixes = []

for i, para in enumerate(doc.paragraphs):
    t = para.text
    # Fix "Figure #" -> "Figure 4" (Kanban is Figure 4)
    if 'Figure #' in t:
        new_t = t.replace('Figure #', 'Figure 4')
        if para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] Figure # -> Figure 4')

    # Fix "Figure [N]" -> "Figure 10" (Home Dashboard is Figure 10)
    if 'Figure [N]' in t:
        new_t = t.replace('Figure [N]', 'Figure 10')
        if para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] Figure [N] -> Figure 10')

    # Fix Table 5 caption which says "presented the demographic profile..."
    if t.strip().startswith('Table 5') and 'presented' in t and 'Profile' not in t:
        new_t = 'Table 5. Demographic Distribution of Needs-Assessment Respondents (N = 30)'
        if para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] Fixed Table 5 caption')

doc.save(DOCX)
print(f'{len(fixes)} fixes:')
for f in fixes: print(f'  {f}')
print('Done.')
