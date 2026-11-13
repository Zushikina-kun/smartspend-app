from docx import Document

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')

issues = []
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if 'Susan' in t: issues.append(f'[{i}] SUSAN: {t[:80]}')
    if 'Ano meaning' in t: issues.append(f'[{i}] ANO MEANING: {t[:80]}')
    if t.upper() == 'DESCRIPTION': issues.append(f'[{i}] DESCRIPTION placeholder')
    if 'EXPLAIN WHAT' in t.upper(): issues.append(f'[{i}] EXPLAIN WHAT placeholder')
    if 'Figure #' in t: issues.append(f'[{i}] Figure # unfilled: {t[:80]}')
    if t == 'SmartSpend' and i > 300: issues.append(f'[{i}] orphan SmartSpend')

print('=== Figure captions ===')
figs = [(i, p.text.strip()) for i, p in enumerate(doc.paragraphs) if p.text.strip().startswith('Figure ')]
for i, t in figs[:18]:
    print(f'  [{i}] {t[:90]}')

print()
print('=== Table captions ===')
tbls = [(i, p.text.strip()) for i, p in enumerate(doc.paragraphs) if p.text.strip().startswith('Table ')]
for i, t in tbls[:12]:
    print(f'  [{i}] {t[:90]}')

print()
if issues:
    print(f'ISSUES ({len(issues)}):')
    for x in issues:
        print(f'  {x}')
else:
    print('No placeholder issues found.')

print()
print('=== Protected values ===')
checks = ['61.83', 'Avigail', 'Jeoffrey', 'partially achieved', 'grade of D', 'Grade D', '13']
for v in checks:
    found = any(v in p.text for p in doc.paragraphs)
    status = 'OK' if found else 'MISSING'
    print(f'  {status}: {v}')

# Parents table count
for t in doc.tables:
    for row in t.rows:
        if 'Parents' in row.cells[0].text and 'Ages' in row.cells[0].text:
            print(f'  Table Parents: {row.cells[1].text.strip()}')
