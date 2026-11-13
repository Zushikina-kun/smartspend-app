from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

all_text = '\n'.join(p.text for p in doc.paragraphs)
table_text = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
full_doc = all_text + '\n' + table_text

# 1. What does Table 9 appear as in the doc?
print('=== All table caption-like lines ===')
for i, line in enumerate(full_doc.split('\n')):
    if re.match(r'\s*Table \d+', line) and i < 1200:
        print(f'  [{i}] {line[:150]}')

# 2. Check for "Multimodal" table caption
print('\n=== Multimodal table ===')
for i, line in enumerate(full_doc.split('\n')):
    if 'multimodal' in line.lower() and 'table' in line.lower():
        print(f'  [{i}] {line[:200]}')

# 3. Check the TOC line about Table 3.5
print('\n=== TOC Table lines ===')
for i, line in enumerate(full_doc.split('\n')):
    if 'table' in line.lower() and re.search(r'\d+\.\d+', line) and 'multimodal' in line.lower():
        print(f'  [{i}] {line[:200]}')

# 4. Check the section heading that has 3.5 (table of contents)
for i, line in enumerate(full_doc.split('\n')):
    if '3.5' in line and ('table' in line.lower() or 'multimodal' in line.lower() or 'parsing' in line.lower()):
        print(f'  [{i}] {line[:200]}')

# 5. Check Table 1.2 context
print('\n=== Table 1.2 context ===')
lines = full_doc.split('\n')
for i, line in enumerate(lines):
    if 'Table 1.2' in line:
        start = max(0, i-2)
        end = min(len(lines), i+3)
        for j in range(start, end):
            print(f'  [{j}] {lines[j][:200]}')

# 6. Check purposive sampling exact text
print('\n=== purposive exact ===')
idx = full_doc.find('purposive')
if idx >= 0:
    print(repr(full_doc[max(0,idx-100):idx+200]))
else:
    print('  NOT FOUND')

# 7. Count of LLMs in Table 6
print('\n=== LLM table rows ===')
for t in doc.tables:
    # check if it looks like LLM table
    flat = ' '.join(c.text for row in t.rows for c in row.cells)
    if 'gemini' in flat.lower() or 'llm' in flat.lower():
        print(f'  Table rows: {len(t.rows)}')
        for row in t.rows[:12]:
            print(f'    {[c.text[:40] for c in row.cells]}')

# 8. How many LLM rows (excluding header)
print('\n=== Check 8 LLM APIs text in full doc ===')
for i, line in enumerate(full_doc.split('\n')):
    if '8' in line and ('api' in line.lower() or 'llm' in line.lower() or 'model' in line.lower()):
        if 'evaluat' in line.lower() or 'test' in line.lower() or 'compar' in line.lower():
            print(f'  [{i}] {line[:200]}')
