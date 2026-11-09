from docx import Document
import sys

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')

# Extract all text
full_text = '\n'.join([para.text for para in doc.paragraphs])

print('=== DEMOGRAPHICS CHECK ===')
# Look for various phrasings
patterns = [
    '10 parents',
    '20 young professionals',
    '20 parents',
    '10 young professionals',
    'ten parents',
    'twenty young professionals',
    'twenty parents',
    'ten young professionals',
]

for pattern in patterns:
    count = full_text.lower().count(pattern.lower())
    if count > 0:
        print(f'"{pattern}": found {count} time(s)')
        
# Find specific context around demographics
demo_idx = full_text.lower().find('demographic')
if demo_idx > 0:
    context = full_text[demo_idx:demo_idx+1000]
    print(f'\nContext around "demographic":')
    print(context[:500])
