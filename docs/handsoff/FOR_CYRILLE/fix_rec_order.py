"""
Fix recommendation ordering and numbering in Chapter IV.
Reorders paragraphs 401-409 to: 1(UI/UX), 2(Parsing), 3(Backend), 4(SQLite), 5(AI), 6(Payday), 7(Household), 8(Longitudinal)
Google Play (old "4.") gets merged into Backend (3.) or becomes sub-point.
"""
import shutil
from docx import Document
from docx.oxml import OxmlElement
from lxml import etree
import copy

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.recorder.backup')
doc = Document(DOCX)

# Find recommendation paragraphs
rec_paras = {}  # number/key -> (index, paragraph)
rec_start = None
in_recs = False

for i, para in enumerate(doc.paragraphs):
    t = para.text.strip()
    if 'Recommendations' in t and i > 390 and i < 420:
        in_recs = True
        rec_start = i
        continue
    if in_recs:
        if 'References' in t and i > 400:
            break
        if not t:
            continue
        # Map by content keyword
        tl = t.lower()
        if t.startswith('1.') or 'ui/ux' in tl: rec_paras['1_uiux'] = (i, para)
        elif t.startswith('2.') or 'formal parsing' in tl: rec_paras['2_parsing'] = (i, para)
        elif t.startswith('3.') or 'backend api' in tl: rec_paras['3_backend'] = (i, para)
        elif 'google play' in tl and t.startswith('4.'): rec_paras['3b_googleplay'] = (i, para)
        elif t.startswith('4.') and 'sqlite' in tl: rec_paras['4_sqlite'] = (i, para)
        elif t.startswith('5.') or 'on-device ai' in tl: rec_paras['5_ai'] = (i, para)
        elif t.startswith('6.') or 'payday' in tl: rec_paras['6_payday'] = (i, para)
        elif t.startswith('7.') or 'household' in tl: rec_paras['7_household'] = (i, para)
        elif t.startswith('8.') or 'longitudinal' in tl: rec_paras['8_longitudinal'] = (i, para)

print('Found rec paragraphs:', list(rec_paras.keys()))

# Merge Google Play into Backend if separate
if '3b_googleplay' in rec_paras and '3_backend' in rec_paras:
    backend_idx, backend_para = rec_paras['3_backend']
    gp_idx, gp_para = rec_paras['3b_googleplay']
    # Merge Google Play text into backend paragraph
    gp_text = gp_para.text.strip()
    # Extract the core sentence after "4. Google Play release."
    gp_core = gp_text[gp_text.find('.')+1:].strip() if '.' in gp_text[:30] else gp_text
    backend_text = backend_para.text.strip()
    if 'Google Play' not in backend_text:
        new_backend = backend_text.rstrip('.') + '. ' + gp_core
        if backend_para.runs:
            backend_para.runs[0].text = new_backend
            for r in backend_para.runs[1:]: r.text = ''
        # Clear Google Play paragraph
        if gp_para.runs:
            gp_para.runs[0].text = ''
            for r in gp_para.runs[1:]: r.text = ''
        print('Merged Google Play into Backend rec 3')
    del rec_paras['3b_googleplay']

# Now renumber correctly
correct_numbers = {
    '1_uiux': '1', '2_parsing': '2', '3_backend': '3',
    '4_sqlite': '4', '5_ai': '5', '6_payday': '6',
    '7_household': '7', '8_longitudinal': '8'
}

for key, correct_num in correct_numbers.items():
    if key not in rec_paras:
        print(f'  MISSING: {key}')
        continue
    idx, para = rec_paras[key]
    t = para.text.strip()
    # Fix the number prefix
    import re
    # Replace leading "N." or "N. " with the correct number
    new_t = re.sub(r'^\d+\.', f'{correct_num}.', t)
    if new_t != t:
        if para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
        print(f'  Renumbered [{idx}]: {t[:40]!r} → {new_t[:40]!r}')
    else:
        print(f'  OK [{idx}]: {t[:60]!r}')

doc.save(DOCX)
print('\nDone.')

# Verify final order
doc2 = Document(DOCX)
print('\nFinal recommendations in document order:')
in_recs = False
for i, p in enumerate(doc2.paragraphs):
    t = p.text.strip()
    if 'Recommendations' in t and i > 390 and i < 420:
        in_recs = True
    if in_recs and t and t[0].isdigit() and '. ' in t[:5]:
        print(f'  [{i}] {t[:130]}')
    if in_recs and 'References' in t and i > 400:
        break
