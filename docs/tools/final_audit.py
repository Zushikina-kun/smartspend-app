"""
Comprehensive final audit of CAPSTONE_5 docx and FOR_CYRILLE guide.
Checks for: [[PENDING]], placeholders, old numbers, interview guide, 
inconsistencies, missing sections, and incomplete content.
"""
from docx import Document
import re, os

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')

# Collect all text
all_text = []
all_paras = []
for p in doc.paragraphs:
    if p.text.strip():
        all_text.append(p.text.strip())
        all_paras.append((p.text.strip(), 'body'))

for t in doc.tables:
    for row in t.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                if p.text.strip():
                    all_text.append(p.text.strip())
                    all_paras.append((p.text.strip(), 'table'))

full = '\n'.join(all_text)

print(f"=== CAPSTONE_5 DOCX FINAL AUDIT ===")
print(f"Paragraphs: {len(all_paras)}")
print()

# ── BAD VALUES (should be 0) ─────────────────────────────────────────────────
bad = {
    'Verzola': 'Adviser was removed',
    'Mangaoang, MIT': 'Should be DIT',
    '62.50': 'Old SUS score (should be 61.83)',
    '63.06': 'Intermediate SUS score (should be 61.83)',
    '56.30': 'Old SUS score (should be 61.83)',
    'N=5': 'Old SUS N (should be N=30)',
    'N=25': 'Old SUS N (should be N=30)',
    'N=31': 'Old SUS N (should be N=30)',
    'N=33': 'Old research N (should be N=30)',
    '97.0%': 'Old AI intent % (should be 96.7%)',
    '25 achievement badges': 'Should be 36',
    '23 achievement badges': 'Should be 36',
    '31 agentic': 'Should be 34',
    'Semi-Structured Interview': 'Appendix D was removed',
    'Appendix D': 'Should not exist (interview guide removed)',
    'November 10, 2026': 'Defense is Nov 10 — wait, check context',
    '[[PENDING': 'Unfilled placeholder',
    '[[N]]': 'Unfilled N placeholder',
    '[score]': 'Unfilled score placeholder',
    '[grade]': 'Unfilled grade placeholder',
    'INSERT': 'Possible figure placeholder',
    'TBD': 'Unresolved item',
    'PLACEHOLDER': 'Unfilled placeholder',
    'Figure X': 'Unfilled figure reference',
}

print("--- BAD VALUES CHECK ---")
issues_found = []
for term, reason in bad.items():
    # Skip Nov 10 if it's the defense date context (it's correct)
    if term == 'November 10, 2026':
        continue
    found = term.lower() in full.lower()
    if found:
        # Find first occurrence
        for p, src in all_paras:
            if term.lower() in p.lower():
                issues_found.append(f"  ISSUE: '{term}' — {reason}")
                issues_found.append(f"    Context: {p[:100]}")
                break

if issues_found:
    for line in issues_found:
        print(line)
else:
    print("  All clean ✅")

# ── GOOD VALUES (should be present) ─────────────────────────────────────────
print()
print("--- GOOD VALUES CHECK ---")
good = {
    'Mangaoang, DIT': True,
    'Layco, MIS': True,
    '61.83': True,
    'N=30': True,
    '96.7%': True,
    '17.58': True,
    '36 achievement': True,
    '34 agentic': True,
    'Appendix A': True,
    'Appendix B': True,
    'Appendix C': True,
    '61.83': True,
}
for term, should_exist in good.items():
    found = term.lower() in full.lower()
    if found == should_exist:
        print(f"  OK: {term}")
    else:
        print(f"  MISSING: {term} ← should be present")

# ── PENDING/PLACEHOLDER TAGS ────────────────────────────────────────────────
print()
print("--- PENDING/PLACEHOLDER TAGS ---")
pending_paras = [(p, src) for p, src in all_paras if '[[' in p or 'PENDING' in p.upper() or '[TO INSERT' in p.upper()]
if pending_paras:
    print(f"  Found {len(pending_paras)} pending items:")
    for p, src in pending_paras[:20]:
        print(f"  [{src}] {p[:120]}")
else:
    print("  None found ✅")

# ── FIGURE PLACEHOLDERS ──────────────────────────────────────────────────────
print()
print("--- FIGURE PLACEHOLDERS ---")
fig_placeholders = [(p, src) for p, src in all_paras
    if re.search(r'\[.*insert.*figure|figure.*placeholder|insert.*here|insert.*image', p.lower())]
if fig_placeholders:
    print(f"  Found {len(fig_placeholders)} figure placeholders:")
    for p, src in fig_placeholders:
        print(f"  {p[:120]}")
else:
    print("  None found ✅")

# ── KEY SECTIONS PRESENT ─────────────────────────────────────────────────────
print()
print("--- KEY SECTIONS CHECK ---")
sections = [
    'CHAPTER I', 'CHAPTER II', 'CHAPTER III', 'CHAPTER IV',
    'ABSTRACT', 'APPROVAL SHEET', 'BIBLIOGRAPHY', 'APPENDIX A',
    'APPENDIX B', 'APPENDIX C', 'CURRICULUM VITAE',
    'TABLE OF CONTENTS', 'REFERENCES',
]
for sec in sections:
    found = sec.lower() in full.lower()
    print(f"  {'OK' if found else 'MISSING'}: {sec}")

# ── SUMMARY ──────────────────────────────────────────────────────────────────
print()
total_issues = len(issues_found) // 2  # each issue is 2 lines
print(f"=== SUMMARY ===")
print(f"Total issues: {total_issues}")
print(f"Pending/placeholder tags: {len(pending_paras)}")
print(f"Figure placeholders: {len(fig_placeholders)}")
print(f"Docx size: {os.path.getsize('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')//1024}KB")
