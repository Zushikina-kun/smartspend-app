from pypdf import PdfReader

checks = [
    ('docs/handsoff/FOR_MAAM_ELLEN/2_PRINT_Formula_Doc.pdf', 'FILE 2 — Formula Doc'),
    ('docs/handsoff/FOR_MAAM_ELLEN/3_PRINT_Basis_Table.pdf', 'FILE 3 — Basis Table'),
]

for path, label in checks:
    r = PdfReader(path)
    full = ' '.join((p.extract_text() or '') for p in r.pages)
    issues = []
    if 'DIT' in full:
        issues.append('Mangaoang DIT (should be MIT)')
    if 'Verzola' in full:
        issues.append('Verzola found')
    if '2004' in full:
        issues.append('2004 citation (should be 2005)')
    if '31 agentic' in full.lower():
        issues.append('31 agentic actions')
    result = ', '.join(issues) if issues else 'all clean'
    print(f'{label}: {result}')
