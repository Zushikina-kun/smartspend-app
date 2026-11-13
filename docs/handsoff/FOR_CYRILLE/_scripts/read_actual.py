from docx import Document
doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')
print(f'Size on disk paras: {len(doc.paragraphs)}')
# Show scope section
for i, p in enumerate(doc.paragraphs):
    if 'Scope and Limitations' in p.text and i > 100:
        print(f'\n=== Scope (para {i}) ===')
        for j in range(i, min(i+6, len(doc.paragraphs))):
            t = doc.paragraphs[j].text.strip()
            if t: print(f'  [{j}] {t[:120]}')
        break
# Show tech bg
for i, p in enumerate(doc.paragraphs):
    if p.text.strip() == 'Technical Background' and i > 100:
        print(f'\n=== Tech BG (para {i}) ===')
        for j in range(i+1, min(i+6, len(doc.paragraphs))):
            t = doc.paragraphs[j].text.strip()
            if t: print(f'  [{j}] {t[:120]}')
        break
# Check Susan
print(f'\nSusan instances: {sum(1 for p in doc.paragraphs if "Susan" in p.text)}')
print(f'Avigail instances: {sum(1 for p in doc.paragraphs if "Avigail" in p.text)}')
print(f'Firebase split: {sum(1 for p in doc.paragraphs if "Firebase Crashlytics. Firebase Crashlytics was integrated for real-time" in p.text)}')
print(f'Firebase fused: {sum(1 for p in doc.paragraphs if "Firebase. Firebase Firestore was used to synchronize" in p.text)}')
