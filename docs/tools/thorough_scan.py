"""
Thorough scan of CAPSTONE_5 docx — every paragraph top to bottom.
Prints ALL flagged content with location.
"""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')

# Collect everything with position
items = []
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t:
        items.append(('body', i, t))

for ti, table in enumerate(doc.tables):
    for ri, row in enumerate(table.rows):
        for ci, cell in enumerate(row.cells):
            for pi, p in enumerate(cell.paragraphs):
                t = p.text.strip()
                if t:
                    items.append((f'T{ti}R{ri}C{ci}', pi, t))

print(f"Total items to scan: {len(items)}\n")

# All patterns to flag
flags = [
    # Placeholders
    (r'\[\[', 'PLACEHOLDER TAG'),
    (r'\[Figure to be inserted', 'FIGURE PLACEHOLDER'),
    (r'\[TO INSERT', 'TO INSERT'),
    (r'INSERT HERE', 'INSERT HERE'),
    (r'TBD\b', 'TBD - UNRESOLVED'),
    (r'PLACEHOLDER', 'PLACEHOLDER WORD'),
    (r'\[.*\]', 'BRACKET PLACEHOLDER'),

    # Wrong numbers
    (r'\b62\.50\b', 'OLD SUS 62.50'),
    (r'\b63\.06\b', 'OLD SUS 63.06'),
    (r'\b56\.30\b', 'OLD SUS 56.30'),
    (r'\bN\s*=\s*5\b', 'OLD N=5'),
    (r'\bN\s*=\s*25\b', 'OLD N=25'),
    (r'\bN\s*=\s*31\b', 'OLD N=31'),
    (r'\bN\s*=\s*33\b', 'OLD N=33'),
    (r'97\.0\s*%', 'OLD 97.0%'),
    (r'18\.59', 'OLD SD 18.59'),
    (r'\b25\s+achievement\s+badges', 'WRONG 25 BADGES'),
    (r'\b23\s+achievement', 'WRONG 23 BADGES'),
    (r'\b31\s+agentic', 'WRONG 31 ACTIONS'),
    (r'v2\.9\.\d+', 'OLD VERSION v2.9.x'),
    (r'v3\.1\.1\b', 'OLD VERSION v3.1.1'),
    (r'13\s+\(preliminary', 'OLD N=13 PRELIMINARY'),
    (r'9\s+parents.*4\s+young', 'OLD SPLIT 9+4'),

    # Wrong names
    (r'Mangaoang,\s+MIT', 'WRONG TITLE MIT'),
    (r'Verzola', 'REMOVED ADVISER'),
    (r'Johnny\s+Flores', 'REMOVED ADVISER'),

    # Tense issues
    (r'this study will (adopt|conduct|use|evaluate)', 'FUTURE TENSE'),
    (r'researchers will (utilize|conduct|develop|evaluate|distribute)', 'FUTURE TENSE'),
    (r'(will be|shall be) (distributed|conducted|evaluated|developed|administered)', 'FUTURE TENSE'),
    (r'(Phase|Step|Stage) will (involve|include|focus)', 'FUTURE TENSE'),
    (r'proposed system', 'PROPOSED → DEVELOPED'),
    (r'proposed application', 'PROPOSED → DEVELOPED'),

    # Content issues
    (r'SmartSpend SmartSpend', 'DUPLICATE WORD'),
    (r'Budget Setup', 'WRONG FHS PILLAR'),
    (r'Appendix D', 'APPENDIX D - CHECK'),
    (r'Semi.Structured Interview', 'INTERVIEW GUIDE - REMOVED'),
    (r'interview guide', 'INTERVIEW GUIDE - REMOVED'),
    (r'March 2026|April 2026|May 2026|June 2026|July 2026|August 2026', 'OLD DATE'),
]

found = {}
for loc, idx, text in items:
    for pattern, label in flags:
        if re.search(pattern, text, re.IGNORECASE):
            # Skip false positives
            tl = text.lower()
            # "proposed" is OK in recommendations/future work
            if label == 'PROPOSED → DEVELOPED':
                if 'recommend' in tl or 'future' in tl or 'may' in tl:
                    continue
            # TBD in benchmark table note is expected
            if label == 'TBD - UNRESOLVED' and 'not yet measured' in tl:
                continue
            # PLACEHOLDER in data privacy = "PLACEHOLDER" as a word in context
            if label == 'PLACEHOLDER WORD' and 'placeholder' not in text[:20].lower():
                continue
            # [bracket] that is just a citation number like [11] is fine
            if label == 'BRACKET PLACEHOLDER' and re.match(r'^\[\d+\]', text.strip()):
                continue
            if label == 'BRACKET PLACEHOLDER':
                # Only flag if it looks like a placeholder, not a citation
                m = re.search(r'\[([^\]]+)\]', text)
                if m and re.match(r'^\d+(,\s*\d+)*$', m.group(1)):
                    continue  # citation number
                if m and len(m.group(1)) < 5:
                    continue  # short bracket = probably citation

            key = f"{label}: {text[:80]}"
            if key not in found:
                found[key] = loc

if found:
    print(f"ISSUES FOUND: {len(found)}\n")
    # Group by label
    by_label = {}
    for key, loc in found.items():
        label = key.split(':')[0]
        if label not in by_label:
            by_label[label] = []
        by_label[label].append((key, loc))

    for label, issues in sorted(by_label.items()):
        print(f"\n{'='*60}")
        print(f"[{label}] — {len(issues)} occurrence(s)")
        for key, loc in issues[:5]:
            text = key[len(label)+2:]
            print(f"  {loc}: {text}")
        if len(issues) > 5:
            print(f"  ... and {len(issues)-5} more")
else:
    print("✅ NO ISSUES FOUND")
