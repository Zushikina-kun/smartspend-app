"""
Fix the 5 manuscript blockers flagged by the code reviewer.
Works directly on the paragraph XML to avoid python-docx style conflicts.
"""
import shutil, re
from docx import Document
from docx.shared import Pt
from docx.oxml.ns import qn

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.blocker.backup')
doc = Document(DOCX)
fixes = []

def replace_runs(para, old, new, label):
    full = para.text
    if old not in full:
        return False
    new_full = full.replace(old, new, 1)
    if para.runs:
        para.runs[0].text = new_full
        for r in para.runs[1:]:
            r.text = ''
    fixes.append(f"FIXED [{label}]: {old[:60]!r}")
    return True

# ── BLOCKER 1: Abstract garbled — duplicate benchmark clause ─────────────
# Find the abstract paragraph with the duplicate clause
for i, para in enumerate(doc.paragraphs):
    t = para.text
    # Fix "a an" double article
    if 'a an adjective' in t:
        replace_runs(para, 'a an adjective', 'an adjective', 'B1-double-article')
    # Fix duplicate benchmark clause pattern:
    # "... grade of D — below the 68-point benchmark … target of 80 — below the 68-point benchmark … target of 80"
    if t.count('below the 68-point benchmark') > 1 or t.count('below the 68') > 1:
        # Remove the second occurrence of the clause
        # Find from second occurrence onward
        idx1 = t.find('below the 68')
        idx2 = t.find('below the 68', idx1 + 10)
        if idx2 > 0:
            # Find the end of the second clause (up to next sentence or end)
            end = t.find('.', idx2)
            if end == -1:
                end = len(t)
            # Remove from just before second "below" back to after first clause end
            # Strategy: find sentence break between the two
            between = t[idx1:idx2]
            # Remove the duplicate: keep everything up to end of first clause, skip second
            first_end = t.find('.', idx1)
            if first_end > 0 and first_end < idx2:
                new_text = t[:first_end+1]
            else:
                # Just remove the second occurrence
                second_clause_end = t.find('.', idx2)
                if second_clause_end == -1:
                    second_clause_end = len(t)
                new_text = t[:idx2].rstrip(' —,') + t[second_clause_end:]
            if new_text != t and para.runs:
                para.runs[0].text = new_text
                for r in para.runs[1:]:
                    r.text = ''
                fixes.append(f'FIXED [B1-dup-clause] para {i}: removed duplicate benchmark clause')

# ── BLOCKER 2: Abstract "successfully developed" overclaim ───────────────
for i, para in enumerate(doc.paragraphs):
    t = para.text
    if 'successfully developed with all identified features implemented' in t:
        replace_runs(para,
            'successfully developed with all identified features implemented',
            'developed as a working Android prototype with the features reported in Chapter III; on-device AI, a backend proxy, and database encryption remain future work',
            'A7-overclaim')
    # Also try shorter variant
    elif 'developed as a working Android application with all' in t or 'all identified features implemented' in t:
        replace_runs(para,
            'all identified features implemented',
            'the features reported in Chapter III; on-device AI, a backend proxy, and database encryption remain future work',
            'A7-overclaim-short')

# ── BLOCKER 3 & 4: Chapter IV Conclusions and Recommendations ────────────
# Find the Chapter IV conclusions area
ch4_start = None
for i, para in enumerate(doc.paragraphs):
    if 'CHAPTER IV' in para.text or 'Chapter IV' in para.text:
        ch4_start = i
        break

if ch4_start:
    # Find the Conclusions paragraph and check for truncated sentence
    for i in range(ch4_start, min(ch4_start + 30, len(doc.paragraphs))):
        t = doc.paragraphs[i].text.strip()
        # Blocker 3: truncated "SmartSpend " sentence
        if t == 'SmartSpend' or t == 'SmartSpend ':
            # This is a stray truncated paragraph - clear it
            if doc.paragraphs[i].runs:
                doc.paragraphs[i].runs[0].text = ''
                for r in doc.paragraphs[i].runs[1:]:
                    r.text = ''
            fixes.append(f'FIXED [B3-truncated] para {i}: removed stray "SmartSpend" paragraph')

        # Blocker 3: Objective 3 conclusion missing "partially achieved" and "marginal"
        if 'third objective' in t.lower() and 'achieved' in t.lower():
            if 'partially' not in t.lower():
                replace_runs(doc.paragraphs[i],
                    'The third objective was achieved',
                    'The third objective was partially achieved',
                    'B3-obj3-partial')
                replace_runs(doc.paragraphs[i],
                    'the third objective was achieved',
                    'the third objective was partially achieved',
                    'B3-obj3-partial-lower')

    # Blocker 4: Check if recommendations have 7 or 8 items
    # Find recommendations section
    recs_start = None
    for i in range(ch4_start, len(doc.paragraphs)):
        if 'Recommendations' in doc.paragraphs[i].text and i > ch4_start:
            recs_start = i
            break

    if recs_start:
        # Count recommendation items (1. 2. 3. etc)
        rec_items = []
        for i in range(recs_start, min(recs_start + 20, len(doc.paragraphs))):
            t = doc.paragraphs[i].text.strip()
            if t and t[0].isdigit() and '. ' in t[:5]:
                rec_items.append((i, t[:80]))

        fixes.append(f'Found {len(rec_items)} recommendation items:')
        for idx, text in rec_items:
            fixes.append(f'  [{idx}] {text}')

        # If UI/UX refinement and Formal parsing evaluation are missing, add them
        texts_joined = ' '.join(t for _, t in rec_items).lower()
        if 'ui/ux' not in texts_joined and 'refinement' not in texts_joined:
            # Insert UI/UX as item 1 and Formal parsing as item 2
            # Shift existing 1-7 to 3-9 isn't feasible without major surgery
            # Instead: add note that they should be items 1 and 2
            fixes.append('NOTE: UI/UX refinement and Formal parsing evaluation missing from recommendations.')
            fixes.append('      Abstract says "eight recommendations" but Ch IV only has 7.')
            fixes.append('      MANUAL FIX NEEDED: Add these two items to Chapter IV recommendations.')

# ── BLOCKER 5: SUS exclusion paragraph doubled/garbled ───────────────────
for i, para in enumerate(doc.paragraphs):
    t = para.text
    # Look for doubled opening phrase
    if 'Of 36 respondents' in t and t.count('Of 36 respondents') > 1:
        # Keep only first proper sentence
        idx2 = t.find('Of 36 respondents', t.find('Of 36 respondents') + 10)
        new_text = t[:idx2].rstrip()
        if para.runs:
            para.runs[0].text = new_text
            for r in para.runs[1:]:
                r.text = ''
        fixes.append(f'FIXED [B5-doubled] para {i}: removed doubled SUS exclusion phrase')
    # Also fix if first sentence is duplicated
    elif 'confirmed they used the app' in t and t.count('confirmed they used') > 1:
        # Remove second occurrence
        idx = t.find('confirmed they used', t.find('confirmed they used') + 10)
        # Find start of duplicate sentence
        sent_start = t.rfind('.', 0, idx)
        if sent_start > 0:
            new_text = t[:sent_start+1]
            if para.runs:
                para.runs[0].text = new_text
                for r in para.runs[1:]:
                    r.text = ''
            fixes.append(f'FIXED [B5-doubled-v2] para {i}: removed duplicate exclusion sentence')

doc.save(DOCX)
print(f'Done. {len(fixes)} actions:')
for f in fixes:
    print(f'  {f}')

# Quick verification
doc2 = Document(DOCX)
vals = {
    '61.83': False, 'partially achieved': False,
    'Avigail': False, 'Jeoffrey': False,
}
for p in doc2.paragraphs:
    for k in vals:
        if k in p.text:
            vals[k] = True
print('\nKey values:')
for k, v in vals.items():
    print(f'  {"OK" if v else "MISSING"}: {k}')
print(f'Paras: {len(doc2.paragraphs)}')
