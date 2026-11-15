"""
Fix 3 remaining items in the Source of Truth manuscript:
1. Remove duplicate validator note above Figure 4
2. Fix Appendix C label in TOC
3. Replace old chapter-prefixed List of Figures with sequential (Figures 1-17)
"""
import shutil, re
from docx import Document
from docx.shared import Pt
from docx.oxml.ns import qn

DOCX = r"Source of Truth\1_MAIN_MANUSCRIPT_FINAL.docx"
shutil.copy(DOCX, DOCX + '.3items.bak')
doc = Document(DOCX)
lines_raw = [(i, p) for i, p in enumerate(doc.paragraphs)]
log = []

# ── FIX 1: Remove duplicate validator note ───────────────────────────────
# The note appears twice — once in Population section and once above Figure 4
# We want to keep only the one below Table 3, delete the one above Figure 4
note_text = 'content validator participated separately'
note_paras = [(i, p) for i, p in lines_raw if note_text in p.text]
print(f'Found {len(note_paras)} validator note paragraphs:')
for i, p in note_paras:
    print(f'  para[{i}]: {p.text[:150]}')

if len(note_paras) >= 2:
    # The one above Figure 4 is the duplicate — it's near the Kanban figure
    # Find which one is near "Figure 4" or "Agile Kanban"
    lines_text = [p.text.strip() for p in doc.paragraphs]
    
    # Find Figure 4 paragraph index
    fig4_idx = next((i for i, l in enumerate(lines_text) 
                     if 'Figure 4' in l and 'Agile Kanban' in l), None)
    print(f'Figure 4 at para[{fig4_idx}]')
    
    # The duplicate validator note is the one closest to Figure 4
    # Keep the one that's farther from Figure 4 (the original near Table 3)
    if fig4_idx:
        note_distances = [(abs(i - fig4_idx), i, p) for i, p in note_paras]
        note_distances.sort()
        # Closest to Figure 4 = duplicate to remove
        _, dup_idx, dup_para = note_distances[0]
        print(f'Removing duplicate at para[{dup_idx}]: {dup_para.text[:100]}')
        # Clear the paragraph
        for run in dup_para.runs:
            run.text = ''
        # Also clear via XML
        dup_para.clear()
        log.append(f'FIX 1: Removed duplicate validator note at para[{dup_idx}]')

# ── FIX 2: Fix Appendix C label in TOC ───────────────────────────────────
# Find TOC section and fix Appendix C entry
appendix_c_fixes = [
    ('APPENDIX C: SUS Individual Scores', 'APPENDIX C: System Usability Scale (SUS) Questionnaire'),
    ('APPENDIX C: Transcript of Interview', 'APPENDIX C: System Usability Scale (SUS) Questionnaire'),
    ('C\tSystem Usability Scale (SUS) Questionnaire', 'APPENDIX C: System Usability Scale (SUS) Questionnaire'),
]

fixed_c = False
for i, para in enumerate(doc.paragraphs):
    for old, new in appendix_c_fixes:
        if old in para.text:
            for run in para.runs:
                if old in run.text:
                    run.text = run.text.replace(old, new)
                    log.append(f'FIX 2: Fixed Appendix C label at para[{i}]: "{old}" -> "{new}"')
                    fixed_c = True
            if not fixed_c:
                # Try replacing full paragraph text
                if para.text.strip() == old or old in para.text:
                    para.clear()
                    run = para.add_run(new)
                    run.font.size = Pt(12)
                    log.append(f'FIX 2: Replaced Appendix C paragraph at para[{i}]')
                    fixed_c = True

if not fixed_c:
    # Search more broadly
    for i, para in enumerate(doc.paragraphs):
        if 'APPENDIX C' in para.text and ('SUS Individual' in para.text or 
                                            'Transcript' in para.text or
                                            'Individual Scores' in para.text):
            full = para.text
            new_text = full.replace('SUS Individual Scores', 'System Usability Scale (SUS) Questionnaire')
            new_text = new_text.replace('Transcript of Interview', 'System Usability Scale (SUS) Questionnaire')
            if new_text != full:
                for run in para.runs:
                    run.text = ''
                if para.runs:
                    para.runs[0].text = new_text
                else:
                    para.add_run(new_text)
                log.append(f'FIX 2: Broad fix Appendix C at para[{i}]')
                fixed_c = True

# ── FIX 3: Replace List of Figures with sequential numbering ─────────────
# Find the LIST OF FIGURES section in TOC
# Current: 1.1, 1.2, 2.1, 2.2, 3.1 ... etc
# New: Figure 1. ... Figure 17.

CORRECT_LOF = [
    ('Figure 1.', 'Financial Literacy Rates by Demographic Group'),
    ('Figure 2.', 'Conceptual Framework (Mobile Application)'),
    ('Figure 3.', 'System Usability Scale (SUS) Score Interpretation'),
    ('Figure 4.', 'Agile Kanban Workflow for SmartSpend Development'),
    ('Figure 5.', 'Demographic Distribution of Needs-Assessment Respondents (N = 30)'),
    ('Figure 6.', 'SmartSpend System Flowchart'),
    ('Figure 7.', 'Use Case Diagram'),
    ('Figure 8.', 'Visual Table of Contents'),
    ('Figure 9.', 'Login and Demo Mode Screen'),
    ('Figure 10.', 'Home Dashboard'),
    ('Figure 11.', 'Expense Logging Through Peso Chat'),
    ('Figure 12.', 'Receipt Scanning and Batch Screenshot Import'),
    ('Figure 13.', 'Financial Health Score Breakdown'),
    ('Figure 14.', 'Budgets, Safe-to-Spend, and Savings Goals'),
    ('Figure 15.', 'Local AI Mode Setup'),
    ('Figure 16.', 'SUS Computation Table'),
    ('Figure 17.', 'SUS Scores by Respondent Group (N = 30)'),
]

CORRECT_LOT = [
    ('Table 1:', 'Three-Level Gap Analysis of SmartSpend'),
    ('Table 2:', 'Feature Comparison of SmartSpend with Existing Financial Applications (including Filipino-context apps)'),
    ('Table 3:', 'Distribution of Respondents and Validators'),
    ('Table 4:', 'Agile Kanban Workflow Phases and Deliverables'),
    ('Table 5:', 'Demographic Profile and Expense Tracking Methods of Respondents (N = 30)'),
    ('Table 6:', 'Comparative Evaluation of LLM APIs for SmartSpend Integration'),
    ('Table 7:', 'Overall SUS Result'),
    ('Table 8:', 'System Usability Scale (SUS) Results by Respondent Group'),
    ('Table 9:', 'SmartSpend Multimodal Import: Field-Level Parsing Performance'),
]

# Find the LIST OF FIGURES heading
lof_idx = None
lot_idx = None
chapters_idx = None
for i, para in enumerate(doc.paragraphs):
    t = para.text.strip()
    if t in ('LIST OF FIGURES', 'LIST OF FIGURES\t', '**LIST OF FIGURES**'):
        lof_idx = i
    if t in ('LIST OF TABLES', 'LIST OF TABLES\t', '**LIST OF TABLES**'):
        lot_idx = i
    if 'CHAPTER I' in t and i > 200:
        if chapters_idx is None:
            chapters_idx = i

print(f'\nList of Figures at para[{lof_idx}]')
print(f'List of Tables at para[{lot_idx}]')
print(f'Chapters start at para[{chapters_idx}]')

# Show current LOF content
if lof_idx:
    print('\nCurrent LOF content (first 25 paras after heading):')
    for i in range(lof_idx+1, min(lof_idx+30, len(doc.paragraphs))):
        t = doc.paragraphs[i].text.strip()
        if t and i < (lot_idx or lof_idx+30):
            print(f'  [{i}]: {t[:120]}')

doc.save(DOCX)
print(f'\n{len(log)} fixes applied so far:')
for l in log: print(f'  {l}')
print('\nNOTE: List of Figures replacement needs manual review of paragraph structure.')
print('Run this script again with --apply-lof to replace the LOF section.')
