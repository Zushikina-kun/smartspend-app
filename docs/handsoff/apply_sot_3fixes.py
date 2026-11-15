"""
Apply 3 remaining fixes to Source of Truth manuscript:
1. Remove duplicate validator note (already done in previous script — verify)
2. Fix Appendix C label in body (para 594)
3. Fill in the empty List of Figures section (paras 103-135 are blank)
   Also fix List of Tables if empty
"""
import shutil
from docx import Document
from docx.shared import Pt, RGBColor
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

DOCX = r"Source of Truth\1_MAIN_MANUSCRIPT_FINAL.docx"
shutil.copy(DOCX, DOCX + '.pre3fix.bak')
doc = Document(DOCX)
log = []

# ── Verify Fix 1 (duplicate validator note) ──────────────────────────────
count = sum(1 for p in doc.paragraphs if 'content validator participated separately' in p.text)
print(f'Validator note count: {count} (should be 1)')
if count == 1:
    log.append('FIX 1: Duplicate validator note already removed - OK')
elif count == 0:
    log.append('FIX 1: Validator note completely gone - check manuscript')
else:
    log.append(f'FIX 1: Still {count} validator notes - needs manual fix')

# ── Fix 2: Appendix C label ───────────────────────────────────────────────
# para[594] is the APPENDIX C heading — but we need the TOC entry
# The TOC entry is in the second TOC (the text-based one around paras 60-100)
# Check what's around it
appendix_entries = [(i, p) for i, p in enumerate(doc.paragraphs)
                    if 'APPENDIX C' in p.text]
print(f'\nAppendix C occurrences:')
for i, p in appendix_entries:
    print(f'  [{i}]: {p.text[:150]}')

# The TOC appendix line — look for it in the chapter outline area
# It should be near the other appendix entries
toc_app_c = None
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    # TOC area appendix entries look like "APPENDIX C: ..." or "C\tSUS..."
    if i < 200 and ('APPENDIX C' in t or ('C\t' in t and ('SUS' in t or 'Transcript' in t or 'Individual' in t))):
        toc_app_c = (i, p)
        print(f'\nTOC Appendix C at para[{i}]: {repr(t[:150])}')

# Fix the body APPENDIX C heading label (para 594) - this is fine as heading
# The real issue is the TOC text entry
# Let's look at what's in the second TOC (text-based one around para 75-102)
print('\nSecond TOC area (75-102):')
for i in range(75, 102):
    t = doc.paragraphs[i].text.strip()
    if t: print(f'  [{i}]: {repr(t)}')

# ── Fix 3: Fill empty List of Figures ────────────────────────────────────
# Paras 103-135 are blank — fill them with the correct LOF entries
LOF_ENTRIES = [
    'Figure 1.\tFinancial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024)',
    'Figure 2.\tConceptual Framework (Mobile Application)',
    'Figure 3.\tSystem Usability Scale (SUS) Score Interpretation',
    'Figure 4.\tAgile Kanban Workflow for SmartSpend Development',
    'Figure 5.\tDemographic Distribution of Needs-Assessment Respondents (N = 30)',
    'Figure 6.\tSmartSpend System Flowchart',
    'Figure 7.\tUse Case Diagram',
    'Figure 8.\tVisual Table of Contents',
    'Figure 9.\tLogin and Demo Mode Screen',
    'Figure 10.\tHome Dashboard',
    'Figure 11.\tExpense Logging Through Peso Chat',
    'Figure 12.\tReceipt Scanning and Batch Screenshot Import',
    'Figure 13.\tFinancial Health Score Breakdown',
    'Figure 14.\tBudgets, Safe-to-Spend, and Savings Goals',
    'Figure 15.\tLocal AI Mode Setup',
    'Figure 16.\tSUS Computation Table',
    'Figure 17.\tSUS Scores by Respondent Group (N = 30)',
]

LOT_ENTRIES = [
    'Table 1:\tThree-Level Gap Analysis of SmartSpend',
    'Table 2:\tFeature Comparison of SmartSpend with Existing Financial Applications (including Filipino-context apps)',
    'Table 3:\tDistribution of Respondents and Validators',
    'Table 4:\tAgile Kanban Workflow Phases and Deliverables',
    'Table 5:\tDemographic Profile and Expense Tracking Methods of Respondents (N = 30)',
    'Table 6:\tComparative Evaluation of LLM APIs for SmartSpend Integration',
    'Table 7:\tOverall SUS Result',
    'Table 8:\tSystem Usability Scale (SUS) Results by Respondent Group',
    'Table 9:\tSmartSpend Multimodal Import: Field-Level Parsing Performance',
]

# Check how many blank paras are between LOF and LOT
lof_idx = 102
lot_idx = 136
blank_in_lof = sum(1 for i in range(lof_idx+1, lot_idx) 
                   if not doc.paragraphs[i].text.strip())
print(f'\nBlank paras in LOF section: {blank_in_lof} (between {lof_idx+1} and {lot_idx-1})')

# Fill the blank paragraphs with LOF entries
blank_paras = [i for i in range(lof_idx+1, lot_idx) 
               if not doc.paragraphs[i].text.strip()]
print(f'Available blank paras: {blank_paras}')

if len(blank_paras) >= len(LOF_ENTRIES):
    for entry_idx, entry_text in enumerate(LOF_ENTRIES):
        para_idx = blank_paras[entry_idx]
        para = doc.paragraphs[para_idx]
        # Clear and set text
        for run in para.runs:
            run.text = ''
        run = para.add_run(entry_text)
        run.font.size = Pt(11)
    log.append(f'FIX 3: Filled {len(LOF_ENTRIES)} LOF entries into blank paragraphs')
else:
    # Not enough blank paras — need to insert after LOF heading
    # Insert entries after para lof_idx
    log.append(f'FIX 3: Not enough blank paras ({len(blank_paras)} < {len(LOF_ENTRIES)}) — using existing blanks and setting text')
    # Use what we have and set them
    for i, (para_idx, entry_text) in enumerate(zip(blank_paras, LOF_ENTRIES)):
        para = doc.paragraphs[para_idx]
        for run in para.runs:
            run.text = ''
        run = para.add_run(entry_text)
        run.font.size = Pt(11)
    log.append(f'FIX 3: Filled {min(len(blank_paras), len(LOF_ENTRIES))} LOF entries')

# Check LOT section similarly
lot_end = None
for i in range(lot_idx+1, min(lot_idx+50, len(doc.paragraphs))):
    t = doc.paragraphs[i].text.strip()
    if t and ('Chapter I' in t or 'CHAPTER I' in t or 'INTRODUCTION' in t):
        lot_end = i
        break
print(f'\nLOT section: para[{lot_idx}] to para[{lot_end}]')
if lot_end:
    blank_in_lot = [i for i in range(lot_idx+1, lot_end) 
                    if not doc.paragraphs[i].text.strip()]
    print(f'Blank paras in LOT: {blank_in_lot}')
    if blank_in_lot and len(blank_in_lot) >= len(LOT_ENTRIES):
        for entry_idx, entry_text in enumerate(LOT_ENTRIES):
            para_idx = blank_in_lot[entry_idx]
            para = doc.paragraphs[para_idx]
            for run in para.runs:
                run.text = ''
            run = para.add_run(entry_text)
            run.font.size = Pt(11)
        log.append(f'FIX 3b: Filled {len(LOT_ENTRIES)} LOT entries')

doc.save(DOCX)
print(f'\nSaved. {len(log)} fixes:')
for l in log: print(f'  {l}')

# Verify
doc2 = Document(DOCX)
ms2 = '\n'.join(p.text for p in doc2.paragraphs)
checks = [
    ('Validator note count <= 1', ms2.count('content validator participated separately') <= 1),
    ('LOF has Figure 1.', 'Figure 1.' in ms2[:6000]),
    ('LOF has Figure 17.', 'Figure 17.' in ms2[:6000]),
    ('LOT has Table 1:', 'Table 1:' in ms2[:6000]),
    ('LOT has Table 9:', 'Table 9:' in ms2[:6000]),
]
print('\nVerification:')
for label, ok in checks:
    print(f'  {"OK  " if ok else "FAIL"}: {label}')
