import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.last.bak')
doc = Document(DOCX)
fixes = []

for i, para in enumerate(doc.paragraphs):
    t = para.text

    # Fix 1: "see Appendix a" -> "see Appendix A" (lowercase a in data gathering)
    if 'Appendix a' in t and 'appendix a' not in t.lower().replace('appendix a', ''):
        new_t = t.replace('Appendix a', 'Appendix A').replace('see Appendix a)', 'see Appendix A)')
        if new_t != t and para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
            fixes.append(f'[{i}] Fixed Appendix a -> Appendix A')

    # Fix 2: Delete the drafting note paragraph about "dopamine reinforcement"
    # It's in a longer paragraph - need to find and remove just that sentence
    if 'Present Peso as a design feature' in t or 'dopamine reinforcement' in t:
        # Remove the sentence from the paragraph
        sentences_to_remove = [
            'Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as "dopamine reinforcement".',
            'Present Peso as a design feature, not as evidence of behavior change, and avoid phrases such as "dopamine reinforcement".',
        ]
        new_t = t
        for s in sentences_to_remove:
            new_t = new_t.replace(s, '').strip()
        if new_t != t and para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
            fixes.append(f'[{i}] Removed dopamine note from para')

doc.save(DOCX)
print(f'{len(fixes)} fixes:')
for f in fixes: print(f'  {f}')

# Verify
doc2 = Document(DOCX)
remaining = []
for i, p in enumerate(doc2.paragraphs):
    t = p.text
    if 'dopamine' in t.lower(): remaining.append(f'dopamine still at [{i}]')
    if 'Appendix a)' in t or 'see Appendix a' in t: remaining.append(f'lowercase appendix at [{i}]: {t[:80]}')
if remaining:
    for r in remaining: print(f'STILL: {r}')
else:
    print('All clean.')
print(f'Paras: {len(doc2.paragraphs)}')
