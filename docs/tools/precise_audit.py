"""Precise audit — only real issues, not false positives."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')

all_text = []
for p in doc.paragraphs:
    if p.text.strip():
        all_text.append(p.text.strip())
for t in doc.tables:
    for row in t.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                if p.text.strip():
                    all_text.append(p.text.strip())

full = '\n'.join(all_text)

print("=== PRECISE FINAL AUDIT ===\n")

# 1. Real [[PENDING]] tags only (double brackets)
real_pending = [line for line in all_text if '[[PENDING' in line or '[[N]]' in line]
print(f"Real [[PENDING]] tags: {len(real_pending)}")
for p in real_pending:
    print(f"  {p[:120]}")

# 2. Number consistency
print("\nNumber checks:")
checks = [
    ('61.83', True, 'SUS mean'),
    ('N=30', True, 'sample size'),
    ('96.7%', True, 'AI intent'),
    ('62.50', False, 'old SUS'),
    ('63.06', False, 'old SUS'),
    ('Verzola', False, 'removed adviser'),
    ('Mangaoang, MIT', False, 'wrong title'),
    ('Mangaoang, DIT', True, 'correct title'),
    ('31 agentic', False, 'old action count'),
    ('34 agentic', True, 'correct action count'),
    ('25 achievement', False, 'old badge count'),
    ('36 achievement', True, 'correct badge count'),
    ('Layco, MIS', True, 'dean title'),
    ('Budget Setup', False, 'wrong FHS pillar'),
    ('Overspend Control', True, 'correct FHS pillar'),
    ('November 10', True, 'defense date'),
]
for term, should_exist, label in checks:
    found = term.lower() in full.lower()
    ok = found == should_exist
    status = 'OK' if ok else 'ISSUE'
    print(f"  [{status}] {term} ({label})")

# 3. Tense check in results sections
tense_issues = []
for line in all_text:
    ll = line.lower()
    if any(phrase in ll for phrase in ['will be evaluated', 'will be conducted', 'will be developed', 'proposed system', 'will utilize a kanban']):
        # Only flag if not in future recommendations
        if 'chapter iv' not in ll and 'recommend' not in ll and 'future' not in ll:
            tense_issues.append(line[:100])

print(f"\nTense issues (future tense in past work): {len(tense_issues)}")
for t in tense_issues[:5]:
    print(f"  {t}")

# 4. Key sections
print("\nKey sections:")
sections = ['CHAPTER I', 'CHAPTER II', 'CHAPTER III', 'CHAPTER IV', 'ABSTRACT', 'APPENDIX A', 'APPENDIX B', 'APPENDIX C', 'REFERENCES', 'CURRICULUM VITAE']
for s in sections:
    found = s.lower() in full.lower()
    print(f"  {'OK' if found else 'MISSING'}: {s}")

import os
print(f"\nDocx size: {os.path.getsize('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')//1024}KB")
