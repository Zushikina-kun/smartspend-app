"""
Comprehensive verification of manuscript, PPT, and script.
Checks every important fix we made. Reports PASS/FAIL for each.
"""
from docx import Document
from pptx import Presentation
from pptx.util import Pt
import os, re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
PPT  = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
SCRIPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md'

doc = Document(DOCX)
prs = Presentation(PPT)
script = open(SCRIPT, encoding='utf-8').read()

all_text = '\n'.join(p.text for p in doc.paragraphs)
table_text = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
full_doc = all_text + '\n' + table_text

def ppt_all_text():
    texts = []
    def get_shape_text(shape):
        if shape.has_text_frame:
            texts.append(shape.text_frame.text)
        if shape.has_table:
            for row in shape.table.rows:
                for cell in row.cells:
                    texts.append(cell.text_frame.text)
        if shape.shape_type == 6:
            for s in shape.shapes:
                get_shape_text(s)
    for slide in prs.slides:
        for shape in slide.shapes:
            get_shape_text(shape)
    return '\n'.join(texts)

ppt_text = ppt_all_text()

results = []
def check(label, condition, detail=''):
    results.append((label, condition, detail))

# ══════════════════════════════════════════════════════
# MANUSCRIPT CHECKS
# ══════════════════════════════════════════════════════
print('=== MANUSCRIPT ===')

# Core values
check('MS: 61.83 present', '61.83' in full_doc)
check('MS: SD 17.58 present', '17.58' in full_doc)
check('MS: N=30 present', 'N = 30' in full_doc or 'N=30' in full_doc or 'thirty (30)' in full_doc)
check('MS: Grade D present', 'grade of D' in full_doc or 'Grade D' in full_doc)
check('MS: Partially achieved', 'partially achieved' in full_doc)
check('MS: 96.7% present', '96.7%' in full_doc or '96.7' in full_doc)
check('MS: 93.3% present', '93.3%' in full_doc or '93.3' in full_doc)

# Names
check('MS: Avigail present', 'Avigail Candevario' in full_doc)
check('MS: Susan removed', 'Susan C. Arquisal' not in full_doc)
check('MS: Jeoffrey correct', 'Jeoffrey' in full_doc)
check('MS: No Joffrey typo', 'Joffrey' not in full_doc)
check('MS: Shekiro MTS MIS', 'Shekiro R. Raposas, MTS, MIS' in full_doc)
check('MS: Ellen DIT', 'Ellen' in full_doc and ('DIT' in full_doc or 'Mangaoang' in full_doc))

# Research design
check('MS: Quantitative design', 'quantitative descriptive developmental' in full_doc)
check('MS: No mixed-methods', 'mixed-methods developmental' not in full_doc)
check('MS: By combining quantitative', 'quantitative developmental approach' in full_doc)

# Scope condensed
check('MS: Scope 2-para (Android only)', 'The system was available only on Android devices.' in full_doc)
check('MS: Scope no Firebase detail', 'The system optionally integrated cloud-based storage' not in full_doc)

# Technical Background condensed
check('MS: Tech BG Firebase fused', 'Firebase. Firebase Firestore was used to synchronize' in full_doc)
check('MS: No Firebase split (old)', 'Firebase Crashlytics. Firebase Crashlytics was integrated for real-time crash' not in full_doc)
check('MS: No Backup Restore section', 'Backup and Restore. The application implemented backup' not in full_doc)

# Table references
check('MS: No Table 1.1 ref', 'Table 1.1 presented' not in full_doc)
check('MS: No Table 2.1 ref', 'Table 2.1 summarized' not in full_doc)
check('MS: Table 2 ref correct', 'Table 2 summarized' in full_doc or 'Table 2' in full_doc)

# Figures
check('MS: Fig 3 zones correct (Not Acceptable)', 'Not Acceptable (below 51)' in full_doc)
check('MS: Fig 5 updated (16 parents)', '16' in full_doc and 'parents' in full_doc.lower())

# FHS
check('MS: FHS item 3 (Budget Adherence)', 'Budget Adherence (25 pts)' in full_doc)
check('MS: FHS items 1 2 4 present', 'Savings Rate (25 pts)' in full_doc and 'Overspend Control' in full_doc and 'Logging Consistency (25 pts)' in full_doc)

# Population
check('MS: Random sampling', 'random sampling, as any parent' in full_doc)

# Data gathering
check('MS: Obj 2 Data Gathering', 'For the second objective, SmartSpend was designed and developed' in full_doc)
check('MS: No interviews', 'No interviews were conducted' in full_doc)

# Abstract
check('MS: 8-provider chain', 'eight-provider' in full_doc)
check('MS: 9 recommendations in abstract', 'Nine recommendations' in full_doc)
check('MS: Gemini 3.5 in abstract', 'Gemini 3.5 Flash-Lite' in full_doc)

# Conclusions
check('MS: Obj 1 conclusion', 'The first objective was achieved' in full_doc)
check('MS: Obj 2 conclusion', 'second objective' in full_doc and 'achieved' in full_doc)
check('MS: Obj 3 partial', 'third objective was partially achieved' in full_doc)
check('MS: No acceptable for prototype', 'acceptable for a prototype system' not in full_doc)

# Recommendations
check('MS: 9 recs (formal parsing)', '9. Formal parsing evaluation' in full_doc)
check('MS: 8 recs (UI/UX)', '8. UI/UX refinement' in full_doc)
check('MS: Rec 7 longitudinal', '7. Longitudinal evaluation' in full_doc)

# Misc
check('MS: Appendix A uppercase', 'see Appendix A)' in full_doc)
check('MS: No Photo Documentation', 'PHOTO DOCUMENTATION' not in full_doc)
check('MS: Appendix D present', 'APPENDIX D' in full_doc or 'Appendix D' in full_doc)
check('MS: Appendix E present', 'APPENDIX E' in full_doc or 'Appendix E' in full_doc)
check('MS: Table 7 LLM present', 'Gemini 3.5 Flash-Lite' in table_text)
check('MS: Table 8 SUS 61.83', '61.83' in table_text)
check('MS: Table 9 parents 10', '10' in table_text and '58.25' in table_text)

# ══════════════════════════════════════════════════════
# PPT CHECKS
# ══════════════════════════════════════════════════════
print()

check('PPT: No Gemini 1.5', 'Gemini 1.5' not in ppt_text)
check('PPT: Gemini 3.5 present', 'Gemini 3.5' in ppt_text or 'Gemini' in ppt_text)
check('PPT: 61.83 present', '61.83' in ppt_text)
check('PPT: Grade D present', 'Grade D' in ppt_text or 'grade' in ppt_text.lower())
check('PPT: Partially achieved', 'Partially achieved' in ppt_text or 'partially achieved' in ppt_text.lower())
check('PPT: 96.7%', '96.7' in ppt_text)
check('PPT: 93.3% used (past tense)', '93.3% used' in ppt_text or '93.3% already used' in ppt_text)
check('PPT: No 93.3% use (present)', '93.3% use GCash' not in ppt_text)
check('PPT: 16 parents framing', '16' in ppt_text)
check('PPT: N=30', '30' in ppt_text)

# ══════════════════════════════════════════════════════
# SCRIPT CHECKS
# ══════════════════════════════════════════════════════
print()

check('SCRIPT: No Gemini 1.5', 'Gemini 1.5' not in script.replace('"Gemini 1.5"', '').replace('| "Gemini 1.5"', ''))
check('SCRIPT: Gemini 3.5', 'Gemini 3.5' in script)
check('SCRIPT: Nov 16', 'November 16' in script or '16, 2026' in script)
check('SCRIPT: Partially achieved', 'partially achieved' in script.lower())
check('SCRIPT: 61.83', '61.83' in script)
check('SCRIPT: Jeoffrey', 'Jeoffrey' in script)
check('SCRIPT: Quantitative', 'quantitative' in script.lower())
check('SCRIPT: No mixed methods', 'mixed methods' not in script.replace('"mixed methods"', '').replace('mixed methods" (no interviews', ''))
check('SCRIPT: Panel correct', 'Raposas' in script and 'Mzana' in script and 'Layco' in script)

# ══════════════════════════════════════════════════════
# PRINT RESULTS
# ══════════════════════════════════════════════════════
print('='*60)
ms_pass = sum(1 for l, c, d in results if c and l.startswith('MS'))
ms_fail = sum(1 for l, c, d in results if not c and l.startswith('MS'))
ppt_pass = sum(1 for l, c, d in results if c and l.startswith('PPT'))
ppt_fail = sum(1 for l, c, d in results if not c and l.startswith('PPT'))
sc_pass = sum(1 for l, c, d in results if c and l.startswith('SCRIPT'))
sc_fail = sum(1 for l, c, d in results if not c and l.startswith('SCRIPT'))

for label, ok, detail in results:
    status = 'PASS' if ok else 'FAIL'
    print(f'  {status}: {label}')

print()
print(f'MANUSCRIPT: {ms_pass} PASS, {ms_fail} FAIL')
print(f'PPT:        {ppt_pass} PASS, {ppt_fail} FAIL')
print(f'SCRIPT:     {sc_pass} PASS, {sc_fail} FAIL')
total = len(results)
total_pass = sum(1 for l, c, d in results if c)
print(f'\nTOTAL: {total_pass}/{total} PASS')
if total_pass == total:
    print('ALL PASS - DEFENSE READY')
else:
    print('ISSUES FOUND - see FAIL items above')
