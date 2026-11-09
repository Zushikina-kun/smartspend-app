from docx import Document

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')

print('=== ALL TABLES IN MANUSCRIPT ===')
for idx, table in enumerate(doc.tables, 1):
    print(f'\n--- Table {idx} ---')
    for row_idx, row in enumerate(table.rows):
        row_text = ' | '.join([cell.text.strip() for cell in row.cells])
        print(f'Row {row_idx}: {row_text}')
    print()
