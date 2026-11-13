"""Verification scan of the final document."""
from docx import Document
import re

DOC_PATH = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
doc = Document(DOC_PATH)
paras = doc.paragraphs
print(f"Total paragraphs: {len(paras)}")

# 1. Check for any remaining old figure numbers (6, 7, 8) in body
print("\n=== Checking for stale Figure 6/7/8 references ===")
issues = []
for i, p in enumerate(paras):
    txt = p.text.strip()
    for n in ('6', '7', '8'):
        # Only flag if it's a "Figure N" reference, not random number
        if re.search(r'(?i)\bfigure\s+' + n + r'\b', txt):
            issues.append((i, txt[:100]))
if issues:
    for i, t in issues:
        print(f"  WARN [{i:04d}] {t!r}")
else:
    print("  OK: No stale Figure 6/7/8 references found")

# 2. Verify figure captions are 1-13
print("\n=== All figure captions (LoF excluded) ===")
lof_idx = lot_idx = -1
for i, p in enumerate(paras):
    t = p.text.strip()
    if t == 'LIST OF FIGURES': lof_idx = i
    elif t == 'LIST OF TABLES': lot_idx = i

cap_nums = []
for i, p in enumerate(paras):
    if lof_idx <= i <= lot_idx:
        continue
    txt = p.text.strip()
    m = re.match(r'(?i)^figure\s+(\d+)\.\s{1,}(.+)', txt)
    if m:
        cap_nums.append(int(m.group(1)))
        print(f"  [{i:04d}] Figure {m.group(1)}: {m.group(2)[:60]!r}")

expected = list(range(1, len(cap_nums)+1))
if cap_nums == expected:
    print(f"  OK: Figures are sequential 1-{len(cap_nums)}")
else:
    print(f"  WARN: Expected {expected}, got {cap_nums}")

# 3. Verify table captions are 1-8
print("\n=== All table captions (LoT excluded) ===")
lot_end = -1
for i in range(lot_idx+1, min(lot_idx+20, len(paras))):
    t = paras[i].text.strip()
    if t.startswith('Chapter') or t == 'INTRODUCTION':
        lot_end = i
        break

tbl_nums = []
for i, p in enumerate(paras):
    if lot_idx <= i <= (lot_end if lot_end > 0 else lot_idx+15):
        continue
    if lof_idx <= i <= lot_idx:
        continue
    txt = p.text.strip()
    m = re.match(r'(?i)^table\s+(\d+)\.\s{1,}(.+)', txt)
    if m:
        tbl_nums.append(int(m.group(1)))
        print(f"  [{i:04d}] Table {m.group(1)}: {m.group(2)[:60]!r}")

expected_t = list(range(1, len(tbl_nums)+1))
if tbl_nums == expected_t:
    print(f"  OK: Tables are sequential 1-{len(tbl_nums)}")
else:
    print(f"  WARN: Expected {expected_t}, got {tbl_nums}")

# 4. Check LoF matches body captions
print("\n=== LoF vs body figures cross-check ===")
lof_entries = []
for i in range(lof_idx+1, lot_idx):
    txt = paras[i].text.strip()
    m = re.match(r'(?i)^figure\s+(\d+)\.\t(.+)', txt)
    if m:
        lof_entries.append((m.group(1), m.group(2)))

body_fig_caps = []
for i, p in enumerate(paras):
    if lof_idx <= i <= lot_idx:
        continue
    txt = p.text.strip()
    m = re.match(r'(?i)^figure\s+(\d+)\.\s{1,}(.+)', txt)
    if m:
        body_fig_caps.append((m.group(1), m.group(2)))

if len(lof_entries) == len(body_fig_caps):
    print(f"  OK: LoF has {len(lof_entries)} entries, body has {len(body_fig_caps)} captions")
    for (ln, lt), (bn, bt) in zip(lof_entries, body_fig_caps):
        if ln != bn:
            print(f"  MISMATCH: LoF Figure {ln} vs body Figure {bn}")
else:
    print(f"  WARN: LoF has {len(lof_entries)} entries but body has {len(body_fig_caps)} captions")

# 5. Check SUS values are still intact
print("\n=== SUS values check ===")
sus_ok = True
for i, p in enumerate(paras):
    txt = p.text
    if '61.83' in txt:
        print(f"  OK: 61.83 found at [{i:04d}]: {txt.strip()[:80]!r}")
    if '17.58' in txt:
        print(f"  OK: 17.58 found at [{i:04d}]: {txt.strip()[:80]!r}")

# 6. Summary
print(f"\n=== FINAL SUMMARY ===")
print(f"Total paragraphs: {len(paras)}")
print(f"Figure captions in body: {len(body_fig_caps)} (Figure 1 through Figure {len(body_fig_caps)})")
print(f"Table captions in body: {len(tbl_nums)} (Table 1 through Table {len(tbl_nums)})")
print(f"LoF entries: {len(lof_entries)}")
