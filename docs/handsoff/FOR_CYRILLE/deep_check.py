"""Deep check for hidden issues in manuscript, PPT, and script."""
import zipfile, os
from docx import Document
from pptx import Presentation

DOCX   = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
PPT    = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
SCRIPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md'

issues = []
ok     = []

# ── MANUSCRIPT: hidden XML issues ────────────────────────────────────────
print('=== MANUSCRIPT ZIP CONTENTS ===')
with zipfile.ZipFile(DOCX) as z:
    for item in z.namelist():
        size = z.getinfo(item).file_size
        if 'comment' in item.lower():
            status = 'EMPTY(OK)' if size < 300 else f'HAS CONTENT({size}b) ← COMMENTS PRESENT'
            if size >= 300:
                issues.append(f'DOCX: {item} still has {size} bytes of comments')
            else:
                ok.append(f'DOCX: {item} cleared ({size} bytes)')
            print(f'  {status}: {item}')
        if 'tracked' in item.lower() or 'revision' in item.lower():
            print(f'  CHECK: {item} ({size} bytes)')

# Check for tracked changes in document.xml
with zipfile.ZipFile(DOCX) as z:
    doc_xml = z.read('word/document.xml').decode('utf-8', errors='ignore')
    rev_count = doc_xml.count('<w:ins ') + doc_xml.count('<w:del ')
    comment_refs = doc_xml.count('w:commentReference')
    if rev_count > 0:
        issues.append(f'DOCX: {rev_count} tracked changes still in document.xml')
    else:
        ok.append(f'DOCX: No tracked changes in document.xml')
    if comment_refs > 0:
        issues.append(f'DOCX: {comment_refs} comment references still in document.xml')
    else:
        ok.append(f'DOCX: No comment references in document.xml')

# Content spot checks
doc = Document(DOCX)
all_text = '\n'.join(p.text for p in doc.paragraphs)

spot = [
    ('Scope condensed', 'The system was available only on Android', True),
    ('Tech BG condensed', 'Firebase. Firebase Firestore was used to synchronize', True),
    ('Susan removed', 'Susan C. Arquisal', False),
    ('Avigail present', 'Avigail Candevario', True),
    ('Quantitative design', 'quantitative descriptive developmental', True),
    ('No mixed-methods', 'mixed-methods developmental', False),
    ('61.83 present', '61.83', True),
    ('Partially achieved', 'partially achieved', True),
    ('9 recs', '9. Formal parsing', True),
    ('FHS item 3', 'Budget Adherence (25 pts)', True),
    ('Random sampling', 'random sampling, as any parent', True),
    ('Obj 2 Data Gathering', 'For the second objective, SmartSpend was designed and developed', True),
    ('No Photo Doc', 'PHOTO DOCUMENTATION', False),
    ('Fig 3 zones', 'Not Acceptable (below 51)', True),
    ('No old Tech BG', 'Firebase Crashlytics. Firebase Crashlytics was integrated for real-time crash', False),
    ('Gemini 3.5 in doc', 'Gemini 3.5 Flash-Lite', True),
]
for label, term, should_exist in spot:
    found = term in all_text
    if should_exist == found:
        ok.append(f'DOCX content: {label}')
    else:
        issues.append(f'DOCX content FAIL: {label} (expected {"present" if should_exist else "absent"}, got {"present" if found else "absent"})')

# ── PPT: hidden XML issues ─────────────────────────────────────────────
print('\n=== PPT ZIP CONTENTS ===')
with zipfile.ZipFile(PPT) as z:
    for item in z.namelist():
        size = z.getinfo(item).file_size
        if 'comment' in item.lower() or 'note' in item.lower():
            print(f'  {item} ({size} bytes)')
            if size > 500 and 'comment' in item.lower():
                issues.append(f'PPT: {item} has {size} bytes of content — may have comments')

# PPT content checks
def get_all_ppt_text(prs):
    texts = []
    def get_shape(shape):
        if shape.has_text_frame:
            texts.append(shape.text_frame.text)
        if shape.has_table:
            for row in shape.table.rows:
                for cell in row.cells:
                    texts.append(cell.text_frame.text)
        if shape.shape_type == 6:
            for s in shape.shapes:
                get_shape(s)
    for slide in prs.slides:
        for shape in slide.shapes:
            get_shape(shape)
    return '\n'.join(texts)

prs = Presentation(PPT)
ppt_text = get_all_ppt_text(prs)

ppt_checks = [
    ('No Gemini 1.5', 'Gemini 1.5', False),
    ('Gemini 3.5 present', 'Gemini 3.5', True),
    ('61.83 present', '61.83', True),
    ('Partially achieved', 'artially achieved', True),
    ('96.7% present', '96.7', True),
    ('93.3% used (past)', '93.3% used', True),
    ('No 93.3% use (present tense)', '93.3% use GCash', False),
    ('No page number artifacts', '‹#›', False),
    ('16 parents', '16', True),
]
for label, term, should_exist in ppt_checks:
    found = term in ppt_text
    if should_exist == found:
        ok.append(f'PPT: {label}')
    else:
        issues.append(f'PPT FAIL: {label}')

# ── SCRIPT: checks ────────────────────────────────────────────────────
print('\n=== SCRIPT CHECKS ===')
script = open(SCRIPT, encoding='utf-8').read()
script_checks = [
    ('No Gemini 1.5', 'Gemini 1.5', False),
    ('Gemini 3.5', 'Gemini 3.5', True),
    ('Nov 16', 'November 16', True),
    ('Quantitative', 'quantitative', True),
    ('No mixed methods', 'mixed methods research', False),
    ('61.83', '61.83', True),
    ('Jeoffrey', 'Jeoffrey', True),
    ('Raposas MTS MIS', 'MTS, MIS', True),
    ('Partially achieved', 'partially achieved', True),
    ('9 Q&As minimum', 'Q9' if 'Q9' in script else '9.', True),
]
for label, term, should_exist in script_checks:
    found = term in script
    if should_exist == found:
        ok.append(f'Script: {label}')
    else:
        issues.append(f'Script FAIL: {label}')

# ── SUMMARY ───────────────────────────────────────────────────────────
print('\n' + '='*60)
print(f'PASS: {len(ok)}')
print(f'FAIL: {len(issues)}')
if issues:
    print('\nISSUES FOUND:')
    for x in issues: print(f'  ❌ {x}')
else:
    print('\n✅ ALL CHECKS PASSED — No hidden issues found')
