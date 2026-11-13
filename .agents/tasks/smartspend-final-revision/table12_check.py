from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)
paras = [(i, p.text, p.style.name) for i, p in enumerate(doc.paragraphs)]

print('=== Table 1.2 occurrences ===')
for i, text, style in paras:
    if 'Table 1.2' in text:
        print(f'[{i}] style={style}: {text[:300]}')

print('\n=== All Table X.Y patterns ===')
for i, text, style in paras:
    m = re.search(r'Table\s+\d+\.\d+', text)
    if m:
        print(f'[{i}] style={style}: {text[:200]}')

# Check the SQLite (version 11) citation - is that the bracket?
print('\n=== SQLite citation bracket check ===')
for i, text, style in paras:
    if i == 213:
        brackets = re.findall(r'\([^)]+\)', text)
        print(f'  Brackets: {brackets}')
        
# Is "version 11" just a package version number, not a citation?
# (version 11) is the sqflite package version - not a source citation
print('\n--- sqflite version bracket is NOT a citation (it is package version) ---')
