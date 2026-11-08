"""Thorough scan of the ACTUAL final manuscript they are working on."""
from docx import Document
import re, os

fname = 'docs/handsoff/1_MAIN_MANUSCRIPT (FINAL).docx'
doc = Document(fname)

items = []
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t:
        items.append(('P'+str(i), t))

for ti, table in enumerate(doc.tables):
    for ri, row in enumerate(table.rows):
        for ci, cell in enumerate(row.cells):
            for pi, p in enumerate(cell.paragraphs):
                t = p.text.strip()
                if t:
                    items.append((f'T{ti}R{ri}C{ci}', t))

full = ' '.join(t for _, t in items)
print(f"File: {fname}")
print(f"Size: {os.path.getsize(fname)//1024}KB | Paragraphs: {len(doc.paragraphs)} | Tables: {len(doc.tables)}")
print()

# All patterns
patterns = {
    r'\[\[': '[[PENDING/TAG',
    r'\[Figure to be inserted': 'FIGURE PLACEHOLDER',
    r'\[insert': '[insert PLACEHOLDER',
    r'TBD\b': 'TBD',
    r'\bN\s*=\s*5\b': 'OLD N=5',
    r'\bN\s*=\s*25\b': 'OLD N=25',
    r'\bN\s*=\s*31\b': 'OLD N=31',
    r'\bN\s*=\s*33\b': 'OLD N=33',
    r'\b62\.50\b': 'OLD SUS 62.50',
    r'\b63\.06\b': 'OLD SUS 63.06',
    r'\b56\.30\b': 'OLD SUS 56.30',
    r'97\.0\s*%': 'OLD 97.0%',
    r'18\.59': 'OLD SD 18.59',
    r'\b25\s+achievement\s+badges': 'WRONG 25 BADGES',
    r'\b31\s+agentic': 'WRONG 31 ACTIONS',
    r'Mangaoang,\s+MIT': 'WRONG TITLE MIT',
    r'Verzola': 'REMOVED ADVISER',
    r'SmartSpend SmartSpend': 'DUPLICATE WORD',
    r'will conduct interviews': 'INTERVIEW REF',
    r'interview guide': 'INTERVIEW GUIDE',
    r'Semi.Structured': 'INTERVIEW GUIDE',
    r'Appendix D': 'APPENDIX D',
    r'13\s*\(preliminary': 'OLD N=13 PRELIMINARY',
    r'9\s+parents.*4\s+young': 'OLD SPLIT 9+4',
    r'Budget Setup': 'WRONG FHS PILLAR',
    r'will (adopt|utilize|conduct|involve|be distributed)': 'FUTURE TENSE',
    r'proposed system': 'PROPOSED NOT DEVELOPED',
    r'\[\[VERIFY': 'VERIFY TAG',
    r'v3\.1\.1\b': 'OLD VERSION 3.1.1',
    r'v2\.9\.\d': 'OLD VERSION 2.9.x (check context)',
}

found = {}
for loc, text in items:
    for pat, label in patterns.items():
        if re.search(pat, text, re.IGNORECASE):
            # Skip false positives
            tl = text.lower()
            if label == 'PROPOSED NOT DEVELOPED':
                if any(w in tl for w in ['recommend', 'future', 'may implement', 'developers may']):
                    continue
            if label == 'TBD':
                if 'not yet measured' in tl:
                    continue
            if label == 'OLD VERSION 2.9.x (check context)':
                # v2.9.97 in a historical range description is OK
                if 'v2.9.97–3.1' in text or 'v2.9.97-3.1' in text:
                    continue

            key = f"{label}|||{text[:100]}"
            if key not in found:
                found[key] = loc

# Group and print
by_label = {}
for key, loc in found.items():
    label = key.split('|||')[0]
    text = key.split('|||')[1]
    if label not in by_label:
        by_label[label] = []
    by_label[label].append((loc, text))

if by_label:
    print(f"ISSUES FOUND: {sum(len(v) for v in by_label.values())} in {len(by_label)} categories\n")
    for label in sorted(by_label.keys()):
        issues = by_label[label]
        print(f"{'='*60}")
        print(f"[{label}] — {len(issues)} occurrence(s)")
        for loc, text in issues[:4]:
            print(f"  {loc}: {text}")
        if len(issues) > 4:
            print(f"  ... +{len(issues)-4} more")
        print()
else:
    print("NO ISSUES FOUND ✅")

# Required values
print("="*60)
print("REQUIRED VALUES CHECK:")
required = [
    ('61.83', 'SUS score'),
    ('N=30', 'sample size'),
    ('96.7%', 'AI intent'),
    ('Mangaoang, DIT', 'adviser DIT'),
    ('Layco, MIS', 'dean MIS'),
    ('36 achievement', '36 badges'),
    ('34 agentic', '34 actions'),
    ('Overspend Control', 'FHS pillar'),
]
for term, label in required:
    found_val = term.lower() in full.lower()
    print(f"  {'✅' if found_val else '❌ MISSING'}: {label} ({term})")
