from docx import Document
from docx.oxml.ns import qn

V4   = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx'
OURS = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

v4  = Document(V4)
our = Document(OURS)

v4_imgs  = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in v4.paragraphs)
our_imgs = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in our.paragraphs)

print(f'V4  : {len(v4.paragraphs)} paras, {len(v4.tables)} tables, {v4_imgs} images')
print(f'OURS: {len(our.paragraphs)} paras, {len(our.tables)} tables, {our_imgs} images')

vals = ['61.83','Avigail','Jeoffrey','Shekiro','MTS, MIS','partially achieved',
        'grade of D','interviews were used','Susan']
print()
print('=== Key checks in V4 ===')
for v in vals:
    found = any(v in p.text for p in v4.paragraphs)
    status = "OK" if found else "MISSING"
    print(f'  {status}: {v}')

print()
print('=== V4 Abstract ===')
for i in range(48, 60):
    t = v4.paragraphs[i].text.strip()
    if t: print(f'[{i}] {t[:160]}')

print()
print('=== V4 Acknowledgements ===')
for i in range(52, 72):
    t = v4.paragraphs[i].text.strip()
    if t: print(f'[{i}] {t[:160]}')

print()
print('=== V4 qualitative/quantitative paragraphs ===')
for i, p in enumerate(v4.paragraphs):
    t = p.text
    if 'qualitative aspect' in t.lower() or 'quantitative aspect' in t.lower():
        print(f'[{i}] {t[:250]}')

print()
print('=== V4 Table 2.1 ===')
for t in v4.tables:
    for row in t.rows:
        cells = [c.text.strip() for c in row.cells]
        if any('Parent' in c or 'Young' in c or 'Validator' in c or 'SUS' in c for c in cells):
            print(f'  {cells}')

print()
print('=== V4 Chapter IV recommendations ===')
in_recs = False
for i, p in enumerate(v4.paragraphs):
    t = p.text.strip()
    if 'Recommendations' in t and i > 300:
        in_recs = True
    if in_recs and t and t[0].isdigit() and '. ' in t[:5]:
        print(f'  [{i}] {t[:130]}')
    if in_recs and 'References' in t and i > 350:
        break

print()
print('=== V4 Susan/validator mentions ===')
for i, p in enumerate(v4.paragraphs):
    t = p.text
    if 'Susan' in t or 'Technical Validator' in t or 'technical validator' in t:
        print(f'[{i}] {t[:200]}')
