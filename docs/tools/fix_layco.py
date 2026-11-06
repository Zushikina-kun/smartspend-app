from docx import Document

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0
for para in doc.paragraphs:
    for run in para.runs:
        if 'Layco, MIT' in run.text:
            run.text = run.text.replace('Layco, MIT', 'Layco, MIS')
            fixes += 1
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for para in cell.paragraphs:
                for run in para.runs:
                    if 'Layco, MIT' in run.text:
                        run.text = run.text.replace('Layco, MIT', 'Layco, MIS')
                        fixes += 1
doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f'Fixed {fixes} in CAPSTONE 5 docx — Layco now MIS')
