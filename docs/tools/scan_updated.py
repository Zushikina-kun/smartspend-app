"""Scan SmartSpend_Manuscript_updated.docx for all issues."""
from docx import Document
import re, os

fname = 'docs/handsoff/SmartSpend_Manuscript_updated.docx'
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

# Issue patterns
patterns = {
    r'\[\[': '[[PENDING/VERIFY TAG',
    r'\[Figure to be inserted': 'FIGURE PLACEHOLDER',
    r'\[.*screenshot.*\]': 'SCREENSHOT PLACEHOLDER',
    r'to be inserted': 'PLACEHOLDER TEXT',
    r'\bN\s*=\s*5\b': 'OLD N=5',
    r'\bN\s*=\s*25\b': 'OLD N=25',
    r'\bN\s*=\s*33\b': 'OLD N=33',
    r'\b62\.50\b': 'OLD SUS 62.50',
    r'\b63\.06\b': 'OLD SUS 63.06',
    r'97\.0\s*%': 'OLD 97.0%',
    r'25\s+achievement\s+badges': 'WRONG 25 BADGES',
    r'31\s+agentic': 'WRONG 31 ACTIONS',
    r'Mangaoang,\s+MIT': 'WRONG TITLE MIT',
    r'Verzola': 'REMOVED ADVISER',
    r'SmartSpend SmartSpend': 'DUPLICATE WORD',
    r'will conduct interviews': 'INTERVIEW REF',
    r'interview guide': 'INTERVIEW GUIDE',
    r'Appendix D': 'APPENDIX D CHECK',
    r'30\+\s+Philippine\s+banks': 'WRONG BANK COUNT',
    r'20\+\s+Philippine\s+banks': 'WRONG BANK COUNT 20+',
    r'will involve|will adopt|will utilize|will be distributed': 'FUTURE TENSE',
    r'proposed system|proposed application': 'PROPOSED NOT DEVELOPED',
    r'same group|same respondents': 'SAME GROUP AMBIGUITY',
}

found = {}
for loc, text in items:
    for pat, label in patterns.items():
        if re.search(pat, text, re.IGNORECASE):
            tl = text.lower()
            # Skip false positives
            if label == 'PROPOSED NOT DEVELOPED':
                if any(w in tl for w in ['recommend', 'future', 'may', 'developers']):
                    continue
            if label == 'APPENDIX D CHECK':
                if 'appendix d' not in tl:
                    continue
            key = f"{label}|||{text[:100]}"
            if key not in found:
                found[key] = loc

by_label = {}
for key, loc in found.items():
    label = key.split('|||')[0]
    text = key.split('|||')[1]
    if label not in by_label:
        by_label[label] = []
    by_label[label].append((loc, text))

if by_label:
    total = sum(len(v) for v in by_label.values())
    print(f"ISSUES FOUND: {total} in {len(by_label)} categories\n")
    for label in sorted(by_label.keys()):
        issues = by_label[label]
        print(f"[{label}] — {len(issues)}")
        for loc, text in issues[:3]:
            print(f"  {loc}: {text}")
        if len(issues) > 3:
            print(f"  ... +{len(issues)-3} more")
        print()
else:
    print("NO ISSUES FOUND ✅")

print("=== REQUIRED VALUES ===")
required = [
    ('61.83', 'SUS score 61.83'),
    ('63.06', 'Group mean 63.06 — wait, should this be here?'),
    ('62.05', 'Parent group mean 62.05'),
    ('30 respondents', '30 respondents'),
    ('96.7%', '96.7% intent'),
    ('93.3%', '93.3% GCash'),
    ('Mangaoang, DIT', 'DIT title'),
    ('Layco, MIS', 'MIS dean'),
    ('36 achievement', '36 badges'),
    ('34 agentic', '34 actions'),
    ('Overspend Control', 'FHS pillar'),
    ('November 10', 'Defense date'),
    ('Grade D', 'Grade D'),
    ('20 Philippine banks', '20 banks (E1 fix)'),
    ('separate', 'separate groups mention (E4)'),
]
for term, label in required:
    found_val = term.lower() in full.lower()
    print(f"  {'✅' if found_val else '❌ MISSING'}: {label}")
