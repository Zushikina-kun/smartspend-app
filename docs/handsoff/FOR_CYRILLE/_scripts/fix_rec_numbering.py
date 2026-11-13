"""Fix the scrambled recommendation numbering in Chapter IV."""
import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.recnum.backup')
doc = Document(DOCX)

# Current order at paras 401-409:
# [401] 1. UI/UX refinement
# [402] 2. Formal parsing evaluation
# [403] 6. Payday-cycle-aware budgeting  ← wrong number
# [404] 3. Backend API proxy             ← ok
# [405] — A Google Play release          ← should be 4. 
# [406] 5. On-device AI tier             ← ok
# [407] 4. SQLite encryption             ← wrong number, should be 6
# [408] 7. Household and remittance      ← ok
# [409] 8. Longitudinal evaluation       ← ok
#
# Correct order per manuscript fix guide (Section D):
# 1. UI/UX refinement
# 2. Formal parsing evaluation
# 3. Backend API proxy + Google Play release
# 4. SQLite encryption
# 5. On-device AI tier
# 6. Payday-cycle-aware budgeting
# 7. Household and remittance features
# 8. Longitudinal evaluation

fixes = []

for i, para in enumerate(doc.paragraphs):
    t = para.text.strip()

    # Fix "6. Payday" → "6. Payday" (renumber to 6)
    # It's already labeled 6, but appears in position 3 — the fix is to reorder
    # Since we can't easily reorder paragraphs in python-docx, just renumber:

    # Para 403: "6. Payday-cycle" → keep as 6 (it IS rec 6, just out of order visually)
    # Actually let's just fix the numbers to be correct regardless of order:
    # The correct numbers based on content:

    if t.startswith('6. Payday-cycle') or t.startswith('6. Payday'):
        # This should stay as 6
        pass  # already correct number

    # Para 405: "— A Google Play release" → "4. Google Play release"
    if t.startswith('— A Google Play release') or t.startswith('— A Google Play'):
        new_t = t.replace('— A Google Play release', '4. Google Play release', 1)
        if para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] Fixed: "— A Google Play" → "4. Google Play release"')

    # Para 407: "4. SQLite encryption" → should be "6. SQLite encryption"
    # Wait — actually looking at the guide, correct order is:
    # 3. Backend proxy + Google Play (combined)
    # 4. SQLite encryption
    # 5. On-device AI
    # 6. Payday-cycle
    # So "4. SQLite" is actually CORRECT per the guide
    # And "6. Payday" is also correct
    # The issue is just para 403 appears before para 404 (backend proxy)
    # That's a visual/display ordering issue in the document, not a numbering error

    # The REAL fix needed: Backend proxy (para 404 = "3.") and Google Play (para 405 = "— A")
    # should be combined into one rec OR Google Play should be "3b" or just part of rec 3

# Actually re-read: the guide says rec 3 = "Backend API proxy AND Google Play release"
# combined into one item. So para 405 "— A Google Play release" is a sub-bullet of rec 3.
# The dash (—) makes it look like a continuation of rec 3. That's actually correct!
# The issue the reviewer saw was "— A Google Play" looking like an unnumbered item.
# Let's make it clearer by merging it into rec 3's paragraph.

for i, para in enumerate(doc.paragraphs):
    t = para.text.strip()
    # Find the backend proxy paragraph
    if t.startswith('3. Backend API proxy') and i < 420:
        # Check if next para is the Google Play dash item
        if i+1 < len(doc.paragraphs):
            next_t = doc.paragraphs[i+1].text.strip()
            if next_t.startswith('— A Google Play') or next_t.startswith('— A Google'):
                # Merge: append Google Play to backend proxy paragraph
                combined = t.rstrip('.') + ', followed by a Google Play release once a privacy policy is in place.'
                if para.runs:
                    para.runs[0].text = combined
                    for r in para.runs[1:]: r.text = ''
                # Clear the Google Play paragraph
                if doc.paragraphs[i+1].runs:
                    doc.paragraphs[i+1].runs[0].text = ''
                    for r in doc.paragraphs[i+1].runs[1:]: r.text = ''
                fixes.append(f'[{i}] Merged Google Play into Backend API proxy rec 3')
                break

doc.save(DOCX)
print(f'Done. {len(fixes)} fixes:')
for f in fixes: print(f'  {f}')

# Show final recommendations
doc2 = Document(DOCX)
print('\nFinal recommendations:')
in_recs = False
for i, p in enumerate(doc2.paragraphs):
    t = p.text.strip()
    if 'Recommendations' in t and i > 390 and i < 420:
        in_recs = True
    if in_recs and t and t[0].isdigit() and '. ' in t[:5]:
        print(f'  [{i}] {t[:120]}')
    if in_recs and 'References' in t and i > 400:
        break
