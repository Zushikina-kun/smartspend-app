from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)
paras = [(i, p.text, p.style.name) for i, p in enumerate(doc.paragraphs)]

# Check exact scope paragraphs at body lines 197-205
print('=== Scope body section lines 197-205 ===')
for i, text, style in paras:
    if 196 <= i <= 205:
        print(f'[{i}] style={style}: {text[:300]}')

# Check the "No interviews" exact wording
print('\n=== No interviews exact context ===')
for i, text, style in paras:
    if 'interview' in text.lower():
        print(f'[{i}]: {text[:400]}')

# Check the Flutter paragraph for citations more carefully
print('\n=== Flutter paragraph full text at 212 ===')
for i, text, style in paras:
    if i == 212:
        print(text)
        print(f'  Has any citation bracket: {bool(re.search(r"\(", text))}')

# Check SQLite paragraph full text at 213
print('\n=== SQLite paragraph full text at 213 ===')
for i, text, style in paras:
    if i == 213:
        print(text)
        print(f'  Has any citation bracket: {bool(re.search(r"\(", text))}')

# Check the paragraph at line 238 (population - 13 parents)
print('\n=== Population para 238 full text ===')
for i, text, style in paras:
    if i == 238:
        print(text[:600])

# Check line 199 (scope body content)
print('\n=== Scope body content at 199-202 ===')
for i, text, style in paras:
    if 199 <= i <= 202:
        print(f'[{i}]: {text[:400]}')
        print()

# Count actual scope body paragraphs (199-209 approx)
print('\n=== Scope body paragraph count ===')
scope_start = 199
scope_end = 212  # technical background starts at 210
count = 0
for i, text, style in paras:
    if scope_start <= i < scope_end and text.strip():
        count += 1
        print(f'  [{i}]: {text[:100]}')
print(f'  Count: {count}')
