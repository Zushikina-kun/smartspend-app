import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.fighash.bak')
doc = Document(DOCX)

fixes = []

for i, para in enumerate(doc.paragraphs):
    t = para.text
    # Fix "Figure #" -> "Figure 4" (Kanban is Figure 4 per LOF)
    if 'Figure #' in t:
        new_t = t.replace('Figure #', 'Figure 4')
        if para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] Fixed Figure # -> Figure 4')

    # Also fix Table 5 caption - it has "presented the demographic..." in the title
    # Table 5 caption should be clean title only
    if t.strip().startswith('Table 5.') and 'presented' in t:
        # Clean up - should just be the title
        new_t = 'Table 5. Demographic Distribution of Needs-Assessment Respondents (N = 30)'
        if para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] Fixed Table 5 caption title')

doc.save(DOCX)
print(f'{len(fixes)} fixes:')
for f in fixes: print(f'  {f}')
