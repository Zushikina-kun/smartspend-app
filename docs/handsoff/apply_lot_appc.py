"""
Fix remaining 2 items:
1. Fill List of Tables (only 2 blank paras available, need to insert 9 entries)
2. Fix Appendix C label — need to find and fix the TOC entry
"""
import shutil
from docx import Document
from docx.shared import Pt
from docx.oxml.ns import qn
from lxml import etree
import copy

DOCX = r"Source of Truth\1_MAIN_MANUSCRIPT_FINAL.docx"
shutil.copy(DOCX, DOCX + '.lot_appc.bak')
doc = Document(DOCX)
log = []

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

# ── Fix LOT: insert entries after LIST OF TABLES heading (para 136) ──────
# Para 137 and 138 are blank, then 139 starts Chapter I
# We need to insert 9 paragraphs - use existing blanks and insert new ones

lot_heading_para = doc.paragraphs[136]
print(f'LOT heading: {lot_heading_para.text}')

# Use para 137 and 138 for first 2 entries, then insert after para 138
lot_blank = [137, 138]

# Fill the 2 existing blank paras
for i, entry in enumerate(LOT_ENTRIES[:2]):
    para = doc.paragraphs[lot_blank[i]]
    for run in para.runs:
        run.text = ''
    run = para.add_run(entry)
    run.font.size = Pt(11)

# Insert 7 more paragraphs after para 138 (before Chapter I)
# We insert before para 139 (Chapter I)
chap1_para = doc.paragraphs[139]
chap1_elem = chap1_para._element

for entry in reversed(LOT_ENTRIES[2:]):  # insert in reverse to maintain order
    new_para = doc.add_paragraph()
    new_para_elem = new_para._element
    # Remove from end and insert before Chapter I
    new_para._element.getparent().remove(new_para._element)
    
    # Create new paragraph element
    from docx.oxml import OxmlElement
    p = OxmlElement('w:p')
    r = OxmlElement('w:r')
    t = OxmlElement('w:t')
    t.text = entry
    r.append(t)
    p.append(r)
    chap1_elem.addprevious(p)

log.append(f'FIX LOT: Inserted {len(LOT_ENTRIES)} table entries')

# ── Fix Appendix C: search for the TOC entry ─────────────────────────────
# The second TOC (text-based) doesn't seem to have appendix entries
# Check what's between CURRICULUM VITAE and CHAPTERS in TOC area
print('\nSearching for Appendix C TOC entry...')
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if i < 200 and ('Appendix' in t or 'APPENDIX' in t) and ('C' in t):
        print(f'  [{i}]: {repr(t[:150])}')

# The TOC in this manuscript (second, text-based one) goes up to para ~100
# Check if there are appendix entries there
print('\nFull TOC area (75-102):')
for i in range(75, 102):
    t = doc.paragraphs[i].text.strip()
    if t: print(f'  [{i}]: {repr(t[:100])}')

# This TOC doesn't have appendix entries — they're in the first (table-format) TOC
# Check the first TOC (table format)
print('\nFirst TOC area (search for appendix entries):')
for i, p in enumerate(doc.paragraphs[:75]):
    t = p.text.strip()
    if 'Appendix' in t or 'APPENDIX' in t or 'SUS Individual' in t or 'Transcript' in t:
        print(f'  [{i}]: {repr(t[:150])}')

doc.save(DOCX)
print(f'\n{len(log)} fixes: {log}')

# Verify
doc2 = Document(DOCX)
ms2 = '\n'.join(p.text for p in doc2.paragraphs)
print('\nVerification:')
print(f'  LOF Figure 1-17: {"OK" if "Figure 1." in ms2[:8000] and "Figure 17." in ms2[:8000] else "FAIL"}')
print(f'  LOT Table 1-9: {"OK" if "Table 1:" in ms2 and "Table 9:" in ms2 else "FAIL"}')
print(f'  Validator note (should be 1): {ms2.count("content validator participated separately")}')
