from docx import Document
import sys

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')

# Look through tables for demographics
print('=== TABLES WITH DEMOGRAPHIC DATA ===')
for idx, table in enumerate(doc.tables):
    all_cells = []
    for row in table.rows:
        row_data = [cell.text for cell in row.cells]
        all_cells.extend(row_data)
    
    table_text = ' '.join(all_cells)
    
    # Check if this is demographics table
    if 'parent' in table_text.lower() or 'young professional' in table_text.lower():
        print(f'\n--- Table {idx+1} ---')
        for row in table.rows:
            row_text = ' | '.join([cell.text for cell in row.cells])
            print(row_text)
            
# Also search paragraphs for methodology section
print('\n\n=== METHODOLOGY SECTION DEMOGRAPHICS ===')
full_text = '\n'.join([para.text for para in doc.paragraphs])

# Find methodology section
method_keywords = ['thirty (30)', 'thirty respondents', '30 respondents', 'N=30', 'N = 30']
for keyword in method_keywords:
    idx = full_text.find(keyword)
    if idx > 0:
        context = full_text[max(0, idx-300):idx+500]
        print(f'\nContext around "{keyword}":')
        print(context)
        print('\n' + '='*60)
