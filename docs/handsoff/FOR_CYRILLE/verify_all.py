from docx import Document
from docx.oxml.ns import qn

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

results = []

# ── 1. Image embedding ────────────────────────────────────────────────────
def prev_has_image(caption_substr):
    for i, para in enumerate(doc.paragraphs):
        if caption_substr in para.text:
            if i == 0:
                return i, False
            has = bool(doc.paragraphs[i-1]._p.findall('.//' + qn('a:blip')))
            return i, has
    return -1, False

results.append("=== Image embedding ===")
for caption, label in [
    ('Figure 2.1',  'Fig 2.1 SUS interpretation'),
    ('Figure 3.11', 'SUS Distribution before Fig 3.11'),
    ('Table 3.4. System Usability Scale', 'SUS Subgroup before Table 3.4'),
    ('Table 3.1. Demographic Profile and Expense Tracking Methods', 'Demographics before Table 3.1'),
]:
    idx, has = prev_has_image(caption)
    status = "OK" if has else "MISSING"
    results.append(f"  [{status}] {label}  (caption at para {idx})")

# ── 2. Table spot-checks ──────────────────────────────────────────────────
results.append("\n=== Table values ===")

# Table 1.2 Paluwagan
try:
    t12 = doc.tables[1]
    for row in t12.rows:
        if 'Paluwagan' in row.cells[0].text:
            val = row.cells[7].text.strip()
            results.append(f"  Table 1.2 Paluwagan/SmartSpend: {repr(val)} -> {'OK' if val == 'Yes' else 'WRONG'}")
            break
except Exception as e:
    results.append(f"  Table 1.2 error: {e}")

# Table 3.3
try:
    t33 = doc.tables[6]
    r = t33.rows[1]
    vals = [c.text.strip() for c in r.cells]
    ok = '61.83' in vals[0] and 'D' in vals[1] and 'OK' in vals[2]
    results.append(f"  Table 3.3: {vals[:3]} -> {'OK' if ok else 'WRONG'}")
except Exception as e:
    results.append(f"  Table 3.3 error: {e}")

# Table 3.4
try:
    t34 = doc.tables[7]
    for row in t34.rows[1:]:
        c = [c.text.strip() for c in row.cells[:4]]
        results.append(f"  Table 3.4 row: {c}")
except Exception as e:
    results.append(f"  Table 3.4 error: {e}")

# Table 2.1 SUS rows
try:
    t21 = doc.tables[2]
    sus_rows = []
    for row in t21.rows:
        c0 = row.cells[0].text.strip()
        c1 = row.cells[1].text.strip()
        if any(k in c0 for k in ['SUS', 'Parents (35', 'Young Prof', 'Total']):
            sus_rows.append(f"    {c0[:40]!r} | {c1!r}")
    if sus_rows:
        results.append("  Table 2.1 SUS rows found:")
        results.extend(sus_rows)
    else:
        results.append("  Table 2.1 SUS rows: MISSING")
except Exception as e:
    results.append(f"  Table 2.1 error: {e}")

# ── 3. Table 3.1 footnote ─────────────────────────────────────────────────
results.append("\n=== Table 3.1 footnote ===")
t31_idx = None
for i, para in enumerate(doc.paragraphs):
    if 'Table 3.1. Demographic Profile' in para.text:
        t31_idx = i
        break
if t31_idx is not None:
    found = False
    for para in doc.paragraphs[t31_idx:t31_idx+40]:
        if '\u2020' in para.text or 'both a parent' in para.text.lower() or 'dual' in para.text.lower():
            results.append(f"  Footnote OK: {para.text[:100]!r}")
            found = True
            break
    if not found:
        results.append("  MISSING - dagger footnote not found near Table 3.1")
else:
    results.append("  Table 3.1 caption not found")

# ── 4. References ─────────────────────────────────────────────────────────
results.append("\n=== References ===")
found_bangor08 = found_sauro = found_deci = False
still_present = []
for para in doc.paragraphs:
    t = para.text
    if 'Bangor' in t and '2008' in t: found_bangor08 = True
    if 'Sauro' in t and '2016' in t:  found_sauro    = True
    if 'Deci'  in t and '2000' in t:  found_deci     = True
    for bad in ['Faulkner (2003)', 'Nielsen & Landauer', 'Financial Health Network (2026)',
                'MaikuB', 'Wajid et al. (2025)']:
        if bad in t and bad not in still_present:
            still_present.append(bad)

results.append(f"  Bangor 2008 added: {'OK' if found_bangor08 else 'MISSING'}")
results.append(f"  Sauro & Lewis 2016 added: {'OK' if found_sauro else 'MISSING'}")
results.append(f"  Deci & Ryan 2000 added: {'OK' if found_deci else 'MISSING'}")
if still_present:
    results.append(f"  Uncited refs still present: {still_present}")
else:
    results.append("  Uncited refs deleted: OK")

# ── 5. Key text fixes ─────────────────────────────────────────────────────
results.append("\n=== Key text fixes ===")
checks = {
    'Objective 3 partially achieved': lambda t: 'partially achieved' in t.lower() and 'third' in t.lower(),
    'Instructor Mr. Shekiro': lambda t: 'Shekiro' in t,
    'SUS protocol 10+ min': lambda t: '10 minutes' in t and 'screening' in t,
    'CFIS 2025 (not 2026)': lambda t: 'CFIS 2025' in t,
    '68 Sauro & Lewis': lambda t: '68' in t and 'Sauro' in t,
    'LLM 6 weighted criteria': lambda t: '6 weighted' in t or 'six weighted' in t,
    'v3.1.0 build evaluated': lambda t: 'v3.1.0' in t and ('evaluated' in t.lower() or 'build' in t.lower()),
}
found_any = {k: False for k in checks}
for para in doc.paragraphs:
    t = para.text
    for k, fn in checks.items():
        if not found_any[k] and fn(t):
            found_any[k] = True

for k, v in found_any.items():
    results.append(f"  {'OK' if v else 'MISSING'}: {k}")

# ── Print all ─────────────────────────────────────────────────────────────
for r in results:
    print(r)
