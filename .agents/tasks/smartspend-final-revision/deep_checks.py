from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

all_text = '\n'.join(p.text for p in doc.paragraphs)
table_text = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
full_doc = all_text + '\n' + table_text

# MC3b - purposive sampling search
print('=== MC3b: purposive sampling ===')
for i, line in enumerate(full_doc.split('\n')):
    if 'purpos' in line.lower():
        print(f'  line ~{i}: {line[:200]}')

# MC15 - 8 LLM APIs
print('\n=== MC15: 8 LLM APIs ===')
for i, line in enumerate(full_doc.split('\n')):
    if 'llm' in line.lower() or ('language model' in line.lower() and 'api' in line.lower()):
        print(f'  line ~{i}: {line[:200]}')
        if i > 100:
            break

# MC17 - Table 9 presence
print('\n=== MC17: Table 9 ===')
for i, line in enumerate(full_doc.split('\n')):
    if 'table 9' in line.lower():
        print(f'  line ~{i}: {line[:200]}')

# Also check table_text for Table 9
print('\n--- In table cells ---')
for i, line in enumerate(table_text.split('\n')):
    if 'table 9' in line.lower():
        print(f'  cell ~{i}: {line[:200]}')

# MC18b - Table X.Y pattern
print('\n=== MC18b: Table X.Y pattern ===')
matches = re.findall(r'Table\s+\d+\.\d+[^\n]{0,80}', full_doc)
for m in matches[:20]:
    print(f'  {m}')

# Check for Multimodal Import Parsing Performance
print('\n=== Multimodal Import Parsing ===')
for i, line in enumerate(full_doc.split('\n')):
    if 'multimodal' in line.lower() or 'parsing performance' in line.lower():
        print(f'  line ~{i}: {line[:200]}')

# Check Table 9 in table headers (caption check)
print('\n=== Table captions ===')
for i, line in enumerate(full_doc.split('\n')):
    if re.match(r'\s*Table \d+', line):
        print(f'  {line[:120]}')
