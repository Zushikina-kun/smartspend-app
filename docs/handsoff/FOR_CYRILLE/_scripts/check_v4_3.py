from docx import Document
from docx.oxml.ns import qn

V4_3 = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (3).docx'
doc = Document(V4_3)
imgs = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in doc.paragraphs)
print(f'V4(3): {len(doc.paragraphs)} paras, {len(doc.tables)} tables, {imgs} images')

checks = {
    '61.83': False, 'Avigail': False, 'Susan': False,
    'Jeoffrey': False, 'partially achieved': False,
    'EXPLAIN WHAT': False, 'Ano meaning': False,
    'DESCRIPTION': False, 'dopamine': False,
    'mixed-methods': False, 'mixed methods': False,
    'No interviews': False, 'No surveys': False,
}
for p in doc.paragraphs:
    t = p.text
    for k in checks:
        if k.lower() in t.lower():
            checks[k] = True

print('\nKey content checks:')
for k, v in checks.items():
    print(f'  {"FOUND" if v else "not found"}: {k}')

# Figure numbering check
print('\nFirst 5 figure captions:')
count = 0
for p in doc.paragraphs:
    t = p.text.strip()
    if t.startswith('Figure') and ('.' in t[:12] or ':' in t[:12]):
        print(f'  {t[:80]}')
        count += 1
        if count >= 5: break

# Table for parents
print('\nParents in distribution table:')
for t in doc.tables:
    for row in t.rows:
        if 'Parent' in row.cells[0].text and 'Ages' in row.cells[0].text:
            print(f'  {[c.text.strip() for c in row.cells[:2]]}')
