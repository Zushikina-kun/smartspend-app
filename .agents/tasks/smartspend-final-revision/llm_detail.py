from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)
paras = [(i, p.text, p.style.name) for i, p in enumerate(doc.paragraphs)]

# Check paragraph 288 onwards - LLM selection text
print('=== LLM selection paragraph 288-300 ===')
for i, text, style in paras:
    if 288 <= i <= 300:
        if text.strip():
            print(f'[{i}]: {text[:400]}')
            print()

# Check abstract for "eight" LLM context
print('=== Abstract LLM mention ===')
for i, text, style in paras:
    if i < 100 and ('eight' in text.lower() or 'eight-provider' in text.lower()):
        print(f'[{i}]: {text[:300]}')

# Check the "eight-provider chain" context
all_text = '\n'.join(p.text for p in doc.paragraphs)
idx = all_text.find('eight-provider')
if idx >= 0:
    print(f'\n=== eight-provider context ===')
    print(all_text[max(0,idx-200):idx+400])
    
# Also check "eight providers" vs "eight LLM APIs"
idx2 = all_text.find('eight providers')
if idx2 >= 0:
    print(f'\n=== eight providers context ===')
    print(all_text[max(0,idx2-100):idx2+300])

# Also what does the abstract say?
print('\n=== Abstract paragraphs ===')
in_abstract = False
for i, text, style in paras:
    if text.strip().upper() == 'ABSTRACT':
        in_abstract = True
        continue
    if in_abstract:
        if text.strip() and 'Heading' in style:
            break
        if text.strip():
            print(f'[{i}]: {text[:300]}')
            if i > 80:
                break
