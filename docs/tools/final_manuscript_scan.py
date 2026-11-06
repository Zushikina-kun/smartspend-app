from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')

# Collect all text
all_text = []
for i, para in enumerate(doc.paragraphs):
    if para.text.strip():
        all_text.append((f'P{i}', para.text.strip()))

for t_i, table in enumerate(doc.tables):
    for r_i, row in enumerate(table.rows):
        for c_i, cell in enumerate(row.cells):
            for p_i, para in enumerate(cell.paragraphs):
                if para.text.strip():
                    all_text.append((f'T{t_i}R{r_i}C{c_i}', para.text.strip()))

# Things confirmed today
checks = {
    'Mangaoang DIT': ('Mangaoang, DIT', True),   # should exist
    'Mangaoang MIT (wrong)': ('Mangaoang, MIT', False),  # should NOT exist
    'Layco MIS': ('Layco, MIS', True),            # should exist
    'Layco MIT (wrong)': ('Layco, MIT', False),   # should NOT exist
    'Verzola (wrong)': ('Verzola', False),         # should NOT exist
    '31 agentic (wrong)': ('31 agentic', False),  # should NOT exist
    '34 agentic': ('34 agentic', True),            # should exist (or 34 AI)
    '23 badge (wrong)': ('23 achievement', False), # should NOT exist
    'Warren 2004 (wrong)': ('Tyagi, 2004', False), # should NOT exist
    'Warren 2005': ('Tyagi, 2005', True),          # should exist
    'SUS 62.50': ('62.50', True),                  # should exist
    'N=5 preliminary': ('preliminary', True),       # should exist
    'exceeding 80 (wrong)': ('exceeding the predefined threshold', False),  # should NOT
    'DIT in approval': ('Mangaoang, DIT', True),   # should exist
    'MIS in approval': ('Layco, MIS', True),        # should exist
}

print('=== MANUSCRIPT FINAL SCAN ===')
print()
issues = []
clean = []

for label, (term, should_exist) in checks.items():
    found = any(term.lower() in text.lower() for _, text in all_text)
    if should_exist and not found:
        issues.append(f'MISSING: {label} — "{term}" not found')
    elif not should_exist and found:
        # Find where
        locs = [(loc, text[:80]) for loc, text in all_text if term.lower() in text.lower()]
        issues.append(f'WRONG: {label} — "{term}" still in doc at {locs[0][0]}: {locs[0][1]}')
    else:
        clean.append(f'OK: {label}')

print('CLEAN:')
for c in clean:
    print(f'  {c}')
print()
print('ISSUES:')
for i in issues:
    print(f'  {i}')

print()
print(f'Result: {len(clean)} clean, {len(issues)} issues')

# Also count remaining PENDING tags
pending = [(loc, text) for loc, text in all_text if '[[PENDING' in text or '[[N]]' in text]
print(f'Remaining [[PENDING]] tags: {len(pending)}')
for loc, text in pending[:10]:
    print(f'  {loc}: {text[:100]}')
