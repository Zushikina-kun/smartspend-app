from docx import Document
doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')
print(f'Total paras: {len(doc.paragraphs)}')

# Find Chapter IV
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if 'CHAPTER IV' in t.upper() and i > 200:
        print(f'\nChapter IV at [{i}]')
        for j in range(i, min(i+50, len(doc.paragraphs))):
            t2 = doc.paragraphs[j].text.strip()
            if t2:
                print(f'  [{j}] {t2[:130]}')
        break
