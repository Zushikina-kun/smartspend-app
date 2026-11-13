from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

all_text = '\n'.join(p.text for p in doc.paragraphs)
table_text = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
full_doc = all_text + '\n' + table_text

lines = full_doc.split('\n')

# ===== A. Flutter and SQLite descriptions =====
print('===== A. Flutter / SQLite descriptions =====')
for i, line in enumerate(lines):
    if 'flutter' in line.lower() and len(line) > 10:
        ctx_start = max(0, i-1)
        ctx_end = min(len(lines), i+5)
        print(f'\n[Flutter @ line {i}]:')
        for j in range(ctx_start, ctx_end):
            print(f'  {lines[j][:200]}')

for i, line in enumerate(lines):
    if 'sqlite' in line.lower() and len(line) > 10:
        ctx_start = max(0, i-1)
        ctx_end = min(len(lines), i+5)
        print(f'\n[SQLite @ line {i}]:')
        for j in range(ctx_start, ctx_end):
            print(f'  {lines[j][:200]}')

# Check for citations in those sections
print('\n--- Citations in Flutter/SQLite sections ---')
for i, line in enumerate(lines):
    if ('flutter' in line.lower() or 'sqlite' in line.lower()) and re.search(r'\([\w\s]+,\s*\d{4}', line):
        print(f'  [{i}] {line[:200]}')

# ===== B. Data Gathering — numbered steps =====
print('\n===== B. Data Gathering — Step N: format =====')
for i, line in enumerate(lines):
    if re.search(r'Step\s+\d+', line, re.IGNORECASE):
        print(f'  [{i}] {line[:200]}')

# ===== C. No interviews =====
print('\n===== C. No interviews statement =====')
for i, line in enumerate(lines):
    if 'interview' in line.lower():
        print(f'  [{i}] {line[:200]}')

# ===== D. Scope and Limitations =====
print('\n===== D. Scope and Limitations section =====')
in_scope = False
scope_paras = []
for i, line in enumerate(lines):
    uline = line.upper().strip()
    if 'SCOPE' in uline and ('LIMITATION' in uline or 'DELIMITATION' in uline):
        in_scope = True
        scope_paras = []
        print(f'  [START @ {i}]: {line[:100]}')
    elif in_scope:
        # Stop at next major heading (CHAPTER or all-caps short heading)
        if re.match(r'^(CHAPTER|SIGNIFICANCE|DEFINITION|REVIEW OF|BACKGROUND|CONCEPTUAL|RESEARCH DESIGN|METHODOLOGY)', uline):
            print(f'  [END @ {i}]: {line[:80]}')
            in_scope = False
            break
        if line.strip():
            scope_paras.append((i, line))

print(f'\n  Total paragraphs in Scope section: {len(scope_paras)}')
for idx, (i, line) in enumerate(scope_paras):
    print(f'  [{i}] PARA {idx+1}: {line[:200]}')

# ===== E. Population paragraph — purposive vs random, 13/14/3 vs 16/14 =====
print('\n===== E. Population paragraph =====')
for i, line in enumerate(lines):
    if 'thirty (30)' in line.lower() or ('respondent' in line.lower() and ('select' in line.lower() or 'sampl' in line.lower())):
        print(f'  [{i}] {line[:300]}')

for i, line in enumerate(lines):
    if 'thirteen (13)' in line.lower() or '13 parent' in line.lower():
        print(f'  [13-parents @ {i}] {line[:300]}')

for i, line in enumerate(lines):
    if 'purposive sampling' in line.lower():
        print(f'  [purposive @ {i}] {line[:300]}')

# ===== F. Table 3 content =====
print('\n===== F. Table 3 content =====')
for t in doc.tables:
    flat = ' '.join(c.text for row in t.rows for c in row.cells)
    if 'distribution' in flat.lower() or 'respondent' in flat.lower() and 'validator' in flat.lower():
        print(f'  Table with {len(t.rows)} rows:')
        for row in t.rows:
            cells = [c.text.strip() for c in row.cells]
            if any(cells):
                print(f'    {cells}')
        print()

# Check for the "3 both" language
print('\n--- "both" / "three (3)" in population context ---')
for i, line in enumerate(lines):
    if ('three (3)' in line.lower() or ' 3 ' in line) and ('both' in line.lower() or 'parent' in line.lower() or 'professional' in line.lower()):
        print(f'  [{i}] {line[:300]}')
