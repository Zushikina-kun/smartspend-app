"""
Deep scan of CAPSTONE_5 docx for ALL issues.
Checks every paragraph and table cell.
"""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')

issues = []
all_items = []

# Collect all text with location
for i, p in enumerate(doc.paragraphs):
    if p.text.strip():
        all_items.append(('P'+str(i), p.text.strip()))

for ti, table in enumerate(doc.tables):
    for ri, row in enumerate(table.rows):
        for ci, cell in enumerate(row.cells):
            for pi, p in enumerate(cell.paragraphs):
                if p.text.strip():
                    all_items.append((f'T{ti}R{ri}C{ci}', p.text.strip()))

full = ' '.join(t for _, t in all_items)

# ── ISSUE PATTERNS ────────────────────────────────────────────────────────────
patterns = {
    # Unfilled placeholders
    r'\[\[PENDING': 'Unfilled [[PENDING]] tag',
    r'\[\[insert': 'Unfilled [[insert]] tag',
    r'\[\[VERIFY': 'Unverified [[VERIFY]] tag',
    r'\[Figure to be inserted': 'Figure placeholder (manual)',
    r'\[TO INSERT': 'TO INSERT placeholder',

    # Wrong numbers
    r'62\.50': 'Old SUS score (→ 61.83)',
    r'63\.06': 'Old SUS score (→ 61.83)',
    r'56\.30': 'Old SUS score (→ 61.83)',
    r'\bN=5\b': 'Old N=5 (→ N=30)',
    r'\bN=25\b': 'Old N=25 (→ N=30)',
    r'\bN=31\b': 'Old N=31 (→ N=30)',
    r'\bN=33\b': 'Old research N (→ N=30)',
    r'97\.0%': 'Old 97.0% (→ 96.7%)',
    r'18\.59': 'Old SD (→ 17.58)',
    r'25 achievement badges': 'Wrong badge count (→ 36)',
    r'23 achievement': 'Wrong badge count (→ 36)',
    r'31 agentic': 'Wrong action count (→ 34)',

    # Wrong names/titles
    r'Mangaoang, MIT': 'Wrong title (→ DIT)',
    r'Verzola': 'Removed adviser',
    r'Johnny Flores': 'Removed adviser',

    # Future tense in past-work context
    r'this study will adopt': 'Future tense (→ adopted)',
    r'researchers will utilize a Kanban': 'Future tense (→ utilized)',
    r'Phase will involve the actual': 'Future tense (→ involved)',
    r'validated questionnaire will be distributed': 'Future tense (→ was distributed)',
    r'will be distributed to the 20 parent': 'Future tense (→ was distributed)',
    r'proposed system': 'Should be "developed system"',

    # Content issues
    r'SmartSpend SmartSpend': 'Duplicate word',
    r'13 \(preliminary': 'Old preliminary N (→ 30)',
    r'9 parents.*4 young': 'Old respondent split (→ 13 parents, 14 YP)',
    r'Budget Setup': 'Wrong FHS pillar (→ Overspend Control)',
    r'Appendix D': 'Appendix D should not exist (interview guide removed)',
    r'Semi-Structured Interview': 'Interview guide removed',
    r'interview guide': 'Interview guide removed',
}

print("=== DEEP SCAN RESULTS ===\n")
found_issues = {}

for loc, text in all_items:
    for pattern, description in patterns.items():
        if re.search(pattern, text, re.IGNORECASE):
            if description not in found_issues:
                found_issues[description] = []
            found_issues[description].append(f"[{loc}] {text[:120]}")

if found_issues:
    print(f"Issues found: {len(found_issues)} types\n")
    for desc, occurrences in found_issues.items():
        print(f"⚠️  {desc} ({len(occurrences)} occurrence{'s' if len(occurrences)>1 else ''})")
        for occ in occurrences[:2]:
            print(f"   {occ}")
        if len(occurrences) > 2:
            print(f"   ... and {len(occurrences)-2} more")
        print()
else:
    print("✅ No issues found!")

# ── POSITIVE CHECKS ───────────────────────────────────────────────────────────
print("=== REQUIRED VALUES ===\n")
required = {
    '61.83': 'Final SUS score',
    'N=30': 'Final sample size',
    '96.7%': 'Final AI intent',
    '17.58': 'Final SUS SD',
    '36 achievement': 'Correct badge count',
    '34 agentic': 'Correct action count',
    'Mangaoang, DIT': 'Correct adviser title',
    'Layco, MIS': 'Correct dean title',
    'Overspend Control': 'Correct FHS pillar',
    'November 10': 'Defense date',
    'APPENDIX A': 'Appendix A present',
    'APPENDIX B': 'Appendix B present',
    'APPENDIX C': 'Appendix C present',
    'CHAPTER I': 'Chapter I present',
    'CHAPTER III': 'Chapter III present',
    'CHAPTER IV': 'Chapter IV present',
}
for term, label in required.items():
    found = bool(re.search(re.escape(term), full, re.IGNORECASE))
    print(f"  {'✅' if found else '❌ MISSING'}: {label} ({term})")

import os
print(f"\nDocx: {os.path.getsize('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')//1024}KB, {len(doc.paragraphs)} paragraphs")
