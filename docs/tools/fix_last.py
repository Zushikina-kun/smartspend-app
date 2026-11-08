from docx import Document
from docx.oxml.ns import qn
import re

fname = 'docs/handsoff/1_MAIN_MANUSCRIPT (FINAL).docx'
doc = Document(fname)
fixes = 0

all_paras = list(doc.paragraphs)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            all_paras.extend(cell.paragraphs)

# Fix remaining future tense
tense = [
    ('system will optionally integrate', 'system optionally integrates'),
    ('The Development Phase will involve', 'The Development Phase involved'),
    ('Functional testing will ensure', 'Functional testing ensured'),
    ('will ensure that each feature', 'ensured that each feature'),
]
for para in all_paras:
    for old, new in tense:
        if old.lower() in para.text.lower():
            for run in para.runs:
                if old.lower() in run.text.lower():
                    run.text = re.sub(re.escape(old), new, run.text, re.IGNORECASE)
                    fixes += 1
                    print(f"Fixed tense: {old[:40]}")
            for t_elem in para._p.findall('.//' + qn('w:t')):
                if t_elem.text and old.lower() in t_elem.text.lower():
                    t_elem.text = re.sub(re.escape(old), new, t_elem.text, re.IGNORECASE)
                    fixes += 1

# Fix TBD in table — replace with "Not formally tested"
for ti, table in enumerate(doc.tables):
    for ri, row in enumerate(table.rows):
        for ci, cell in enumerate(row.cells):
            for p in cell.paragraphs:
                if p.text.strip() == 'TBD':
                    for run in p.runs:
                        if run.text.strip() == 'TBD':
                            run.text = 'Not measured'
                            fixes += 1
                            print(f"Fixed TBD in T{ti}R{ri}C{ci}")
                    for t_elem in p._p.findall('.//' + qn('w:t')):
                        if t_elem.text and t_elem.text.strip() == 'TBD':
                            t_elem.text = 'Not measured'
                            fixes += 1

doc.save(fname)
print(f"Fixes applied: {fixes}")

# Final check
doc2 = Document(fname)
full2 = ' '.join(p.text for p in doc2.paragraphs)
for table in doc2.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                full2 += ' ' + p.text

remaining_tbd = full2.count('\nTBD\n') + full2.count(' TBD ') + (' TBD' in full2 and 'TBD' in full2)
print(f"TBD remaining: {'TBD' in full2}")
print(f"Future tense 'will involve': {'Development Phase will involve' in full2}")
print(f"Future tense 'will integrate': {'will optionally integrate' in full2}")
print(f"61.83 present: {'61.83' in full2}")
print(f"All clean: {not any(bad in full2.lower() for bad in ['62.50', '63.06', 'verzola', 'mangaoang, mit', '[[pending', '[[verify'])}")
