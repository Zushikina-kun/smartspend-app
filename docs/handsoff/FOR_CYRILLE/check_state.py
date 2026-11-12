from docx import Document
from docx.oxml.ns import qn

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')
imgs = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in doc.paragraphs)
print(f'Current FINAL: {len(doc.paragraphs)} paras, {imgs} images')

checks = {
    '61.83': False, 'Avigail': False, 'Susan': False,
    'Jeoffrey': False, 'No interviews': False,
    'No surveys': False, 'Ano meaning': False,
    'DESCRIPTION': False, 'EXPLAIN WHAT': False,
    'partially achieved': False,
}
for p in doc.paragraphs:
    t = p.text
    for k in checks:
        if k in t:
            checks[k] = True

for k, v in checks.items():
    print(f'  {"FOUND" if v else "not found"}: {k}')

# Show Table 2.1 parents count
for t in doc.tables:
    for row in t.rows:
        if 'Parents' in row.cells[0].text and 'Ages' in row.cells[0].text:
            print(f'Table Parents row: {[c.text.strip() for c in row.cells]}')
            break
