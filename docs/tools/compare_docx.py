"""Compare current CAPSTONE_5 docx vs last committed version."""
import subprocess, os, tempfile
from docx import Document

# Extract committed version to temp file
committed_path = os.path.join(tempfile.gettempdir(), 'capstone5_committed.docx')
with open(committed_path, 'wb') as f:
    result = subprocess.run(
        ['git', 'show', 'HEAD:docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx'],
        capture_output=True, cwd='c:/xampp/htdocs/smartspend_app'
    )
    f.write(result.stdout)

print(f'Committed version saved: {len(result.stdout)//1024}KB')

# Load both
current = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
committed = Document(committed_path)

print(f'Current paragraphs: {len(current.paragraphs)}')
print(f'Committed paragraphs: {len(committed.paragraphs)}')

# Key value checks on current
def get_full_text(doc):
    parts = []
    for p in doc.paragraphs:
        if p.text.strip():
            parts.append(p.text)
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for p in cell.paragraphs:
                    if p.text.strip():
                        parts.append(p.text)
    return ' '.join(parts)

cur_text = get_full_text(current)
com_text = get_full_text(committed)

checks = {
    '36 achievement': True,
    '25 achievement': False,
    '34 agentic': True,
    '31 agentic': False,
    'Mangaoang, DIT': True,
    'Mangaoang, MIT': False,
    'Layco, MIS': True,
    '62.50': True,
    'Grade D': False,
    'Verzola': False,
}

print('\n=== CURRENT FILE ===')
issues_cur = []
for term, should_exist in checks.items():
    found = term.lower() in cur_text.lower()
    ok = found == should_exist
    status = '✅' if ok else '❌'
    print(f'  {status} {term}')
    if not ok:
        issues_cur.append(term)

print('\n=== COMMITTED (KIRO) VERSION ===')
issues_com = []
for term, should_exist in checks.items():
    found = term.lower() in com_text.lower()
    ok = found == should_exist
    status = '✅' if ok else '❌'
    print(f'  {status} {term}')
    if not ok:
        issues_com.append(term)

print(f'\nCurrent issues: {issues_cur}')
print(f'Committed issues: {issues_com}')

# Check paragraph count difference
print(f'\nParagraph diff: {len(current.paragraphs) - len(committed.paragraphs)} (current vs committed)')
