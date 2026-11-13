from docx import Document
doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')

wrong = [(i, p.text.strip()[:150]) for i, p in enumerate(doc.paragraphs) if 'Joffrey' in p.text]
right = [(i, p.text.strip()[:150]) for i, p in enumerate(doc.paragraphs) if 'Jeoffrey' in p.text]

print(f'Wrong "Joffrey" instances: {len(wrong)}')
for i, t in wrong:
    print(f'  [{i}] {t}')

print(f'\nCorrect "Jeoffrey" instances: {len(right)}')
for i, t in right:
    print(f'  [{i}] {t}')
