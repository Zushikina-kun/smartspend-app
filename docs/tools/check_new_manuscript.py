from docx import Document

# Check (1).docx — the new version from the team
doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_ (1).docx')
print(f'(1).docx: {len(doc.paragraphs)} paragraphs')

# Find Appendix D
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if 'appendix d' in t.lower() or ('appendix' in t.lower() and 'interview' in t.lower()):
        print(f'\nFound at P{i}: {t}')
        for j in range(i+1, min(i+8, len(doc.paragraphs))):
            pt = doc.paragraphs[j].text.strip()
            if pt:
                print(f'  P{j}: {pt[:100]}')
        break
else:
    print('  No Appendix D found')

# Find all appendices
print('\nAll appendix references:')
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t.lower().startswith('appendix'):
        print(f'  P{i}: {t}')

# Key value check
full = ' '.join(p.text for p in doc.paragraphs)
checks = [
    ('Mangaoang, DIT', True),
    ('Mangaoang, MIT', False),
    ('Layco, MIS', True),
    ('36 achievement', True),
    ('25 achievement', False),
    ('34 agentic', True),
    ('31 agentic', False),
    ('63.06', True),
    ('56.30', False),
    ('62.50', False),
    ('Verzola', False),
]
print('\nKey value checks:')
for term, should_exist in checks:
    found = term.lower() in full.lower()
    ok = found == should_exist
    status = 'OK' if ok else 'ISSUE'
    print(f'  [{status}] {term}: {"found" if found else "not found"}')
