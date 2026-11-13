"""
Audit all tables and figures in the manuscript for data accuracy.
Checks: values, naming, consistency with protected values.
"""
from docx import Document
from docx.oxml.ns import qn

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

findings = []
ok = []

# ── Protected values ──────────────────────────────────────────────────────
PROTECTED = {
    'SUS mean': '61.83', 'SUS SD': '17.58', 'N': '30',
    'Grade': 'D', 'Adjective': 'OK',
    'Parents needs-assessment': '16', 'YP needs-assessment': '14',
    'Parents SUS': '10', 'YP SUS': '20',
    'Parents SUS mean': '58.25', 'YP SUS mean': '63.62',
    'AI intent': '96.7', 'GCash': '93.3',
}

# ── Check all tables ──────────────────────────────────────────────────────
print('=== TABLES ===')
for t_idx, table in enumerate(doc.tables):
    # Find nearest caption
    cap = ''
    for i, p in enumerate(doc.paragraphs):
        if p._p in [row.cells[0]._tc.getparent().getparent() for row in table.rows[:1]]:
            # Look back for caption
            for j in range(max(0, i-3), i):
                t = doc.paragraphs[j].text.strip()
                if t.startswith('Table'):
                    cap = t[:80]
                    break
            break

    rows_text = [[c.text.strip() for c in row.cells] for row in table.rows]
    print(f'\nTable {t_idx+1}: {cap}')

    # Table 3 (Distribution of Respondents) - check parents=16
    if 'Distribution' in cap or 'Respondent' in cap and 'Validator' in cap:
        for row in rows_text:
            if 'Parent' in row[0] and 'Ages' in row[0]:
                val = row[1] if len(row) > 1 else '?'
                if val == '16':
                    ok.append(f'Table (Distribution): Parents=16 ✓')
                else:
                    findings.append(f'HIGH: Table (Distribution): Parents={val}, should be 16')

            if 'Technical Validator' in row[0]:
                findings.append(f'HIGH: Table (Distribution): Technical Validator row still present — should be removed')

            if 'Both' in row[0]:
                findings.append(f'MEDIUM: Table (Distribution): Both Groups row still present — should be removed (3 reclassified as parents)')

    # Table 7 (Overall SUS Result)
    if 'Overall SUS' in cap or 'SUS Result' in cap:
        for row in rows_text[1:]:  # skip header
            if row:
                score = row[0] if row[0] else ''
                grade = row[1] if len(row) > 1 else ''
                adj = row[2] if len(row) > 2 else ''
                if '61.83' in score:
                    ok.append(f'Table (SUS Result): 61.83 ✓')
                else:
                    findings.append(f'HIGH: Table (SUS Result): Score={score}, should be 61.83')
                if 'D' in grade:
                    ok.append(f'Table (SUS Result): Grade D ✓')
                if 'OK' in adj:
                    ok.append(f'Table (SUS Result): Adjective OK ✓')

    # Table 8 (SUS by Group)
    if 'Respondent Group' in cap or ('SUS' in cap and 'Group' in cap):
        for row in rows_text[1:]:
            if 'Parent' in row[0] and len(row) >= 3:
                n = row[1]; mean = row[2]
                if n == '10' and '58.25' in mean:
                    ok.append(f'Table (SUS by Group): Parents 10/58.25 ✓')
                else:
                    findings.append(f'HIGH: Table (SUS by Group): Parents N={n} mean={mean}, expected 10/58.25')
            if 'Young Prof' in row[0] and len(row) >= 3:
                n = row[1]; mean = row[2]
                if n == '20' and '63.62' in mean:
                    ok.append(f'Table (SUS by Group): YP 20/63.62 ✓')
                else:
                    findings.append(f'HIGH: Table (SUS by Group): YP N={n} mean={mean}, expected 20/63.62')
            if 'Combined' in row[0] and len(row) >= 3:
                n = row[1]; mean = row[2]
                if n == '30' and '61.83' in mean:
                    ok.append(f'Table (SUS by Group): Combined 30/61.83 ✓')

    # Table 5 (Demographic Profile) - check percentages for 16/14 split
    if 'Demographic Profile' in cap or 'Expense Tracking' in cap:
        full_text = ' '.join([c for row in rows_text for c in row])
        # 16/30 = 53.3%, 14/30 = 46.7%
        if '53.3' in full_text:
            ok.append(f'Table (Demographics): 53.3% for parents ✓')
        else:
            findings.append(f'MEDIUM: Table (Demographics): 53.3% not found — may still show 43.3% (13/30)')
        if '46.7' in full_text:
            ok.append(f'Table (Demographics): 46.7% for YP ✓')
        else:
            findings.append(f'MEDIUM: Table (Demographics): 46.7% not found')

# ── Check figures via captions ─────────────────────────────────────────────
print('\n=== FIGURES ===')
fig_captions = []
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if (t.startswith('Figure ') or t.startswith('Figure\t')) and len(t) > 10:
        # Check if previous para has an image
        has_img = False
        for offset in range(1, 4):
            if i >= offset and doc.paragraphs[i-offset]._p.findall('.//' + qn('a:blip')):
                has_img = True
                break
        fig_captions.append((i, t[:100], has_img))

for i, cap, has_img in fig_captions:
    print(f'  [{i}] {cap} | image: {"✓" if has_img else "MISSING"}')
    if not has_img:
        findings.append(f'HIGH: {cap[:60]} — caption has no image before it')

# ── Check text content for protected values ───────────────────────────────
print('\n=== PROTECTED VALUES IN TEXT ===')
found = {k: False for k in PROTECTED}
for p in doc.paragraphs:
    t = p.text
    for k, v in PROTECTED.items():
        if v in t:
            found[k] = True

for k, v in PROTECTED.items():
    status = '✓' if found[k] else 'MISSING'
    print(f'  {status}: {k}={v}')
    if not found[k]:
        findings.append(f'HIGH: Protected value not found in text: {k}={v}')

# ── Summary ───────────────────────────────────────────────────────────────
print(f'\n=== SUMMARY ===')
print(f'OK: {len(ok)} items')
print(f'Issues: {len(findings)} items')
print('\nISSUES:')
for f in findings:
    print(f'  {f}')
print('\nOK ITEMS:')
for o in ok:
    print(f'  {o}')
