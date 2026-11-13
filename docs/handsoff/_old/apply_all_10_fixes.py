"""
Apply all 10 fixes to the SmartSpend manuscript.
Opens docs/handsoff/1_MAIN_MANUSCRIPT_FINAL (1).docx (source)
but actually works on the more up-to-date docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx,
makes targeted edits, saves to docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx,
and also copies to FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx for the verifier.
"""

import re, shutil, copy
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from lxml import etree
from pptx import Presentation
from pptx.util import Pt

# ── Paths ──────────────────────────────────────────────────────────────────────
BASE = r'c:\xampp\htdocs\smartspend_app\docs\handsoff'
SRC  = BASE + r'\1_MAIN_MANUSCRIPT_FINAL.docx'          # already-partially-fixed
OUT  = BASE + r'\1_MAIN_MANUSCRIPT_FINAL.docx'          # overwrite
FOR_CYRILLE = BASE + r'\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

PPT_PATH    = BASE + r'\FOR_CYRILLE\SmartSpend_Defense.pptx'
SCRIPT_PATH = BASE + r'\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md'

# ── Load document ──────────────────────────────────────────────────────────────
doc = Document(SRC)

# ── Helper: replace text in a paragraph run-by-run ───────────────────────────
def replace_in_para(para, old, new):
    """Replace 'old' with 'new' across the full paragraph text, preserving runs."""
    full = para.text
    if old not in full:
        return False
    # Simple run replacement: rebuild runs
    new_text = full.replace(old, new)
    # Assign to first run, clear rest
    if para.runs:
        para.runs[0].text = new_text
        for run in para.runs[1:]:
            run.text = ''
    return True

def replace_in_runs(runs, old, new):
    """Replace across a list of runs."""
    full = ''.join(r.text for r in runs)
    if old not in full:
        return False
    new_full = full.replace(old, new)
    if runs:
        runs[0].text = new_full
        for r in runs[1:]:
            r.text = ''
    return True

def para_text(p):
    return p.text

# ── Collect paragraphs with their text ────────────────────────────────────────
paras = doc.paragraphs

print("=" * 60)
print("STARTING FIXES")
print("=" * 60)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 1: Duplicate Figure 6 already removed in source file.
# Body figure captions for Figs 6-16 already use period style.
# TOC figure list needs to be updated (colon → period, citation removed).
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 1: Figure numbering check (duplicate already removed)...")

# Fix TOC figure entries (P87-P102 area): change colon style to period style 
# and remove citation from Fig 1
toc_fig_fixes = {
    'Figure 1: Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024).':
        'Figure 1. Financial Literacy Rates by Demographic Group',
    'Figure 2: Conceptual Framework (Mobile Application)':
        'Figure 2. Conceptual Framework (Mobile Application)',
    'Figure 3: System Usability Scale (SUS) Score Interpretation':
        'Figure 3. System Usability Scale (SUS) Score Interpretation',
    'Figure 4: Agile Kanban Workflow for SmartSpend Development':
        'Figure 4. Agile Kanban Workflow for SmartSpend Development',
    'Figure 5: Demographic Distribution of Needs-Assessment Respondents (N = 30).':
        'Figure 5. Demographic Distribution of Needs-Assessment Respondents (N = 30)',
    'Figure 6: SmartSpend System Flowchart':
        'Figure 6. SmartSpend System Flowchart',
    'Figure 7: Use Case Diagram':
        'Figure 7. Use Case Diagram',
    'Figure 8: Visual Table of Contents':
        'Figure 8. Visual Table of Contents',
    'Figure 9: Login and Demo Mode Screen':
        'Figure 9. Login and Demo Mode Screen',
    'Figure 10: Home Dashboard':
        'Figure 10. Home Dashboard',
    'Figure 11: Expense Logging Through Peso Chat':
        'Figure 11. Expense Logging Through Peso Chat',
    'Figure 12: Receipt Scanning and Batch Screenshot Import':
        'Figure 12. Receipt Scanning and Batch Screenshot Import',
    'Figure 13: Financial Health Score Breakdown':
        'Figure 13. Financial Health Score Breakdown',
    'Figure 14: Budgets, Safe-to-Spend, and Savings Goals':
        'Figure 14. Budgets, Safe-to-Spend, and Savings Goals',
    'Figure 15: Local AI Mode Setup':
        'Figure 15. Local AI Mode Setup',
    'Figure 16: SUS Computation Table':
        'Figure 16. SUS Computation Table',
}

for para in paras:
    t = para.text.strip()
    if t in toc_fig_fixes:
        replace_in_para(para, t, toc_fig_fixes[t])
        print(f"  TOC Fig: '{t[:60]}' → period style")

# Fix body figure captions: colon → period style
body_fig_fixes = {
    'Figure 1: Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024).':
        'Figure 1. Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024).',
    'Figure 2: Conceptual Framework (Mobile Application)':
        'Figure 2. Conceptual Framework (Mobile Application)',
    'Figure 3: System Usability Scale (SUS) Score Interpretation':
        'Figure 3. System Usability Scale (SUS) Score Interpretation',
    'Figure 4: Agile Kanban Workflow for SmartSpend Development':
        'Figure 4. Agile Kanban Workflow for SmartSpend Development',
    'Figure 5: Demographic Distribution of Needs-Assessment Respondents (N = 30).':
        'Figure 5. Demographic Distribution of Needs-Assessment Respondents (N = 30)',
}

for para in paras:
    t = para.text.strip()
    for old, new in body_fig_fixes.items():
        if t == old:
            replace_in_para(para, t, new)
            print(f"  Body Fig: '{old[:60]}' → period style")

print("FIX 1: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 2: Table renumbering
# Table 6 (demographics) → Table 5
# Table 7 (LLM comparison) → Table 6
# Table 8 (Overall SUS) → Table 7
# Table 9 (SUS by group) → Table 8
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 2: Table renumbering...")

# We must do in reverse order to avoid double-replacement
# Table 9 → 8, Table 8 → 7, Table 7 → 6, Table 6 → 5

table_text_replacements = [
    # (old, new)  - applied in order listed, do in reverse to avoid conflicts
    ('Table 9',  'Table 8'),
    ('Table 8',  'Table 7'),
    ('Table 7',  'Table 6'),
    ('Table 6',  'Table 5'),
]

# First pass: mark all paragraphs with a placeholder, then replace
# Use multi-pass with safe placeholders
placeholder_map = {
    'Table 6':  '##T5##',
    'Table 7':  '##T6##',
    'Table 8':  '##T7##',
    'Table 9':  '##T8##',
}
reverse_map = {v: k[:-1] + str(int(k[-1]) - 1) for k, v in placeholder_map.items()}
# Actually: Table 6→5, 7→6, 8→7, 9→8
reverse_map = {
    '##T5##': 'Table 5',
    '##T6##': 'Table 6',
    '##T7##': 'Table 7',
    '##T8##': 'Table 8',
}

for para in paras:
    t = para.text
    if any(x in t for x in ['Table 6', 'Table 7', 'Table 8', 'Table 9']):
        new_t = t
        for old_t, ph in placeholder_map.items():
            new_t = new_t.replace(old_t, ph)
        for ph, new_tbl in reverse_map.items():
            new_t = new_t.replace(ph, new_tbl)
        if new_t != t:
            replace_in_para(para, t, new_t)
            print(f"  Table ref updated: '{t[:80]}' → '{new_t[:80]}'")

# Also update table caption cells inside tables (Table objects)
for tbl in doc.tables:
    for row in tbl.rows:
        for cell in row.cells:
            for para in cell.paragraphs:
                t = para.text
                if any(x in t for x in ['Table 6', 'Table 7', 'Table 8', 'Table 9']):
                    new_t = t
                    for old_t, ph in placeholder_map.items():
                        new_t = new_t.replace(old_t, ph)
                    for ph, new_tbl in reverse_map.items():
                        new_t = new_t.replace(ph, new_tbl)
                    if new_t != t:
                        replace_in_para(para, t, new_t)

# Fix specific in-text references mentioned in the brief
# "Table 7 presented the comparative evaluation" → "Table 6 presented"
# "(Table 7)" in Table4 deliverable → "(Table 6)"
# "Recommendation 2 (Table 7)" → "(Table 6)"
# "Tables 8 and 9" → "Tables 7 and 8"
# Note: these should already be handled by the bulk replacement above.
# Double-check:
for para in paras:
    if 'Tables 8 and 9' in para.text:
        replace_in_para(para, 'Tables 8 and 9', 'Tables 7 and 8')
        print("  Fixed: Tables 8 and 9 → Tables 7 and 8")

print("FIX 2: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 3: Full TOC rebuild
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 3: TOC rebuild...")

# Find the TABLE OF CONTENTS heading and the INTRODUCTION line after the TOC
# We need to replace the TOC section entirely

# Find indexes
toc_start = None  # " TABLE OF CONTENTS" paragraph
toc_end = None    # paragraph just before the first body content (INTRODUCTION or CHAPTER I)

for i, p in enumerate(paras):
    if 'TABLE OF CONTENTS' in p.text and toc_start is None:
        toc_start = i
    # Find the INTRODUCTION standalone line (which is after TOC)
    if p.text.strip() == 'INTRODUCTION' and toc_start is not None and toc_end is None:
        toc_end = i  # We will delete this paragraph too

print(f"  TOC found: P{toc_start} to P{toc_end}")

# The TOC section runs from toc_start to toc_end (inclusive of INTRODUCTION)
# We need to:
# 1. Keep the " TABLE OF CONTENTS" heading paragraph
# 2. Replace everything from toc_start+1 to toc_end (inclusive) with the new TOC content
# 3. Remove the standalone "INTRODUCTION" line

# New TOC content (plain text lines)
# We'll replace the content of paragraphs P{toc_start+1} to P{toc_end}
# and remove any extra paragraphs

new_toc_lines = [
    "\t\t\t\t\t\t\t\t  Page",
    "Title Page\t\t\t\t\t\t\t\t\t\t\t\t\t\t\ti",
    "Approval Sheet\t\t\t\t\t\t\t\t\t\t\t\t\t\tii",
    "Abstract\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tiii",
    "Acknowledgement\t\t\t\t\t\t\t\t\t\t\t\t\tiv",
    "Dedication\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tv",
    "Table of Contents\t\t\t\t\t\t\t\t\t\t\t\tvi",
    "List of Figures\t\t\t\t\t\t\t\t\t\t\t\t\tvii",
    "List of Tables\t\t\t\t\t\t\t\t\t\t\t\t\tviii",
    "",
    "List of Figures",
    "Figure 1. Financial Literacy Rates by Demographic Group\t\t____",
    "Figure 2. Conceptual Framework (Mobile Application)\t\t\t____",
    "Figure 3. System Usability Scale (SUS) Score Interpretation\t____",
    "Figure 4. Agile Kanban Workflow for SmartSpend Development\t____",
    "Figure 5. Demographic Distribution of Needs-Assessment Respondents (N = 30)\t____",
    "Figure 6. SmartSpend System Flowchart\t\t\t\t\t\t____",
    "Figure 7. Use Case Diagram\t\t\t\t\t\t\t\t\t____",
    "Figure 8. Visual Table of Contents\t\t\t\t\t\t\t____",
    "Figure 9. Login and Demo Mode Screen\t\t\t\t\t\t____",
    "Figure 10. Home Dashboard\t\t\t\t\t\t\t\t\t____",
    "Figure 11. Expense Logging Through Peso Chat\t\t\t\t____",
    "Figure 12. Receipt Scanning and Batch Screenshot Import\t\t____",
    "Figure 13. Financial Health Score Breakdown\t\t\t\t\t____",
    "Figure 14. Budgets, Safe-to-Spend, and Savings Goals\t\t____",
    "Figure 15. Local AI Mode Setup\t\t\t\t\t\t\t\t____",
    "Figure 16. SUS Computation Table\t\t\t\t\t\t\t____",
    "",
    "List of Tables",
    "Table 1: Three-Level Gap Analysis of SmartSpend\t\t\t____",
    "Table 2: Feature Comparison of SmartSpend with Existing Financial Applications (including Filipino-context apps)\t____",
    "Table 3: Distribution of Respondents and Validators\t\t\t____",
    "Table 4: Agile Kanban Workflow Phases and Deliverables\t\t____",
    "Table 5: Demographic Profile and Expense Tracking Methods of Respondents (N = 30)\t____",
    "Table 6: Comparative Evaluation of LLM APIs for SmartSpend Integration\t____",
    "Table 7: Overall SUS Result\t\t\t\t\t\t\t\t____",
    "Table 8: System Usability Scale (SUS) Results by Respondent Group\t____",
    "",
    "CHAPTER I \u2013 Introduction",
    "    Project Context",
    "    Conceptual Framework",
    "    Statement of Objectives",
    "    Scope and Limitations of the Study",
    "    Purpose and Description",
    "    Technical Background",
    "CHAPTER II \u2013 Design and Methodology",
    "    Research Design",
    "    Population and Locale",
    "    Ethical Considerations",
    "    Data Gathering Tools and Procedure",
    "    Software Methodology",
    "CHAPTER III \u2013 Results and Discussion",
    "    Assessment of the Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors of Parents and Young Professionals",
    "    Design and Development of the SmartSpend Mobile Application",
    "        System Development Results",
    "        Overview of the System",
    "    Usability Evaluation of SmartSpend Using the System Usability Scale (SUS)",
    "CHAPTER IV \u2013 Conclusions and Recommendations",
    "    Conclusions",
    "    Recommendations",
    "References",
    "Appendices",
    "    Appendix A Survey Questionnaire",
    "    Appendix B Informed Consent Form",
    "    Appendix C System Usability Scale (SUS) Questionnaire",
    "    Appendix D Content Validation Certificate (Survey Questionnaire)",
    "    Appendix E Content Validation Certificate (FHS Formula and Literature)",
    "Curriculum Vitae",
    "    Brix A. Directo",
    "    Cyrille John M. Rubis",
    "    Djaunathan Albert S. Madayag",
]

# Get the XML body element
body = doc.element.body

# Find the paragraph XML elements for the TOC range
# We'll replace paragraphs from toc_start+1 to toc_end (inclusive)
# by modifying their text, then removing/adding as needed

# Get all paragraph elements in the body (not in tables)
all_body_paras = [el for el in body if el.tag == qn('w:p')]

# Find the paragraph objects for toc range
toc_range = list(range(toc_start + 1, toc_end + 1))  # paragraphs to replace/delete

# Update the first N paragraphs in the TOC range with new content
# Delete extras or add new paragraphs as needed

# Strategy: replace content of existing paragraphs, delete/insert as needed
# First, copy the style from toc_start paragraph
toc_heading_para = paras[toc_start]

# Get the XML elements for the range
para_elements_in_range = []
count = 0
for el in body:
    if el.tag == qn('w:p'):
        if count in toc_range:
            para_elements_in_range.append((count, el))
        count += 1

print(f"  TOC range has {len(para_elements_in_range)} paragraphs, need {len(new_toc_lines)}")

# Replace existing paragraphs with new content
# Get a reference style from one of the existing TOC lines
ref_style = None
if para_elements_in_range:
    ref_style = para_elements_in_range[0][1]

# Update existing paragraphs
for idx, (para_idx, para_el) in enumerate(para_elements_in_range):
    if idx < len(new_toc_lines):
        # Set text
        # Clear existing runs
        for r in para_el.findall('.//' + qn('w:r')):
            para_el.remove(r)
        # Remove existing w:pPr runs and hyperlinks
        for child in list(para_el):
            if child.tag in [qn('w:r'), qn('w:hyperlink'), qn('w:bookmarkStart'), qn('w:bookmarkEnd'), qn('w:fldSimple')]:
                para_el.remove(child)
        # Add new run with text
        new_r = OxmlElement('w:r')
        new_t = OxmlElement('w:t')
        new_t.text = new_toc_lines[idx]
        if new_toc_lines[idx].startswith(' ') or new_toc_lines[idx].endswith(' '):
            new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        new_r.append(new_t)
        para_el.append(new_r)
    else:
        # Remove extra paragraphs
        body.remove(para_el)

# Add any missing paragraphs (if new_toc_lines is longer than range)
if len(new_toc_lines) > len(para_elements_in_range):
    # Find the insertion point (after the last TOC paragraph, before INTRODUCTION body text)
    # Find the CHAPTER I INTRODUCTION paragraph (the body heading, not TOC)
    # Insert after last processed paragraph
    last_toc_el = para_elements_in_range[-1][1] if para_elements_in_range else toc_heading_para._element
    
    # We need to insert after last_toc_el
    for extra_idx in range(len(para_elements_in_range), len(new_toc_lines)):
        new_para_el = OxmlElement('w:p')
        new_r = OxmlElement('w:r')
        new_t = OxmlElement('w:t')
        new_t.text = new_toc_lines[extra_idx]
        if new_toc_lines[extra_idx].startswith(' ') or new_toc_lines[extra_idx].endswith(' '):
            new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        new_r.append(new_t)
        new_para_el.append(new_r)
        last_toc_el.addnext(new_para_el)
        last_toc_el = new_para_el

# Reload paragraphs after modification
paras = doc.paragraphs
print("FIX 3: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 4: Caption punctuation (already partially done by FIX 1)
# All figure body captions → period style: "Figure N. Title"
# All table body captions → colon style: "Table N: Title"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 4: Caption punctuation...")

paras = doc.paragraphs

# Fix body table captions that use period instead of colon
table_cap_fixes = [
    ('Table 8. Overall SUS Result',
     'Table 7: Overall SUS Result'),
    ('Table 9. System Usability Scale (SUS) Results by Respondent Group',
     'Table 8: System Usability Scale (SUS) Results by Respondent Group'),
]

for para in paras:
    t = para.text.strip()
    for old, new in table_cap_fixes:
        if t == old:
            replace_in_para(para, t, new)
            print(f"  Table cap: '{old}' → '{new}'")

# Fix figure captions that still use colon (body captions)
# Pattern: "Figure N: ..." → "Figure N. ..."
for para in paras:
    t = para.text
    if re.match(r'^Figure \d+:', t):
        new_t = re.sub(r'^(Figure \d+):', r'\1.', t)
        if new_t != t:
            replace_in_para(para, t, new_t)
            print(f"  Fig cap colon→period: '{t[:70]}' → '{new_t[:70]}'")

print("FIX 4: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 5: Chapter III headings
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 5: Chapter III headings...")

paras = doc.paragraphs

for para in paras:
    t = para.text.strip()
    
    # 1. Change "Determined the Usability..." heading to new title
    if ('Determined the Usability of SmartSpend Using the System Usability Scale' in t
            and 'Usability Evaluation' not in t):
        new_t = t.replace(
            'Determined the Usability of SmartSpend Using the System Usability Scale',
            'Usability Evaluation of SmartSpend Using the System Usability Scale (SUS)'
        )
        replace_in_para(para, para.text, new_t)
        print(f"  CH3 SUS heading updated: '{new_t[:80]}'")
    
    # 2. Fix Objective 1 heading
    if t == 'Assessment of Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors':
        new_t = 'Assessment of the Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors of Parents and Young Professionals'
        replace_in_para(para, para.text, new_t)
        print(f"  CH3 Obj1 heading updated")

    # 3. TOC entry for Objective 1
    if t.strip() == '    Assessment of Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors':
        new_t = t.replace(
            'Assessment of Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors',
            'Assessment of the Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors of Parents and Young Professionals'
        )
        replace_in_para(para, para.text, new_t)
        print(f"  TOC Obj1 entry updated")

print("FIX 5: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 6: Table 3 note
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 6: Table 3 note...")

paras = doc.paragraphs
all_text = '\n'.join(p.text for p in paras)

if 'content validator participated separately' not in all_text:
    # Find the Table 3 body (the second occurrence, in the body, not TOC)
    # Then find the paragraph after the table body
    # Table 3 is at P210 in the original structure
    # After the table itself, we add a note paragraph
    
    # Find the Table 3 object (3rd table in the document, index 2)
    # Actually, let's find by caption paragraph
    table3_para_idx = None
    for i, p in enumerate(doc.paragraphs):
        if p.text.strip() == 'Table 3: Distribution of Respondents and Validators':
            table3_para_idx = i
    
    print(f"  Table 3 caption at P{table3_para_idx}")
    
    # Find the Table 3 object (after this caption paragraph)
    # We need to insert a note paragraph after the table that follows this caption
    
    # Find the table element that comes after the caption
    body = doc.element.body
    cap_el = doc.paragraphs[table3_para_idx]._element
    
    # Find the table element after cap_el
    found_cap = False
    table3_el = None
    for el in body:
        if el == cap_el:
            found_cap = True
        elif found_cap and el.tag == qn('w:tbl'):
            table3_el = el
            break
    
    if table3_el is not None:
        # Insert note paragraph after table3_el
        note_para_el = OxmlElement('w:p')
        note_r = OxmlElement('w:r')
        note_t = OxmlElement('w:t')
        note_t.text = 'Note. The content validator participated separately and is not included in the respondent total of 30.'
        note_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        note_r.append(note_t)
        note_para_el.append(note_r)
        table3_el.addnext(note_para_el)
        print("  Table 3 note added after Table 3 body")
    else:
        # Fallback: insert after the caption paragraph
        note_para_el = OxmlElement('w:p')
        note_r = OxmlElement('w:r')
        note_t = OxmlElement('w:t')
        note_t.text = 'Note. The content validator participated separately and is not included in the respondent total of 30.'
        note_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        note_r.append(note_t)
        note_para_el.append(note_r)
        cap_el.addnext(note_para_el)
        print("  Table 3 note added (fallback: after caption)")
else:
    print("  Table 3 note already present")

print("FIX 6: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 7: "20 candidate LLM models" → "eight candidate LLM APIs"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 7: 20 candidate LLM models fix...")

paras = doc.paragraphs
for para in paras:
    if '20 candidate LLM models' in para.text:
        replace_in_para(para, '20 candidate LLM models', 'eight candidate LLM APIs')
        print(f"  Fixed: 20 candidate LLM models → eight candidate LLM APIs")

print("FIX 7: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 8: Appendix cross-references
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 8: Appendix cross-references...")

paras = doc.paragraphs
all_text = '\n'.join(p.text for p in paras)

# Add "(see Appendix B)" after the informed consent mention in Ethical Considerations
if 'see Appendix B' not in all_text:
    for para in paras:
        t = para.text
        # Look for the informed consent paragraph
        if ('Informed consent was obtained' in t and 
                'see Appendix B' not in t):
            new_t = t.rstrip()
            if new_t.endswith('.'):
                new_t = new_t[:-1] + ' (see Appendix B).'
            else:
                new_t = new_t + ' (see Appendix B).'
            replace_in_para(para, t, new_t)
            print(f"  Added (see Appendix B) to informed consent paragraph")
            break
else:
    print("  (see Appendix B) already present")

# Add "(see Appendix D)" after the validator sentence mentioning Avigail Candevario
paras = doc.paragraphs
all_text = '\n'.join(p.text for p in paras)
if 'see Appendix D' not in all_text:
    for para in paras:
        t = para.text
        if ('Avigail Candevario' in t and 'see Appendix D' not in t):
            new_t = t.rstrip()
            if new_t.endswith('.'):
                new_t = new_t[:-1] + ' (see Appendix D).'
            else:
                new_t = new_t + ' (see Appendix D).'
            replace_in_para(para, t, new_t)
            print(f"  Added (see Appendix D) to Avigail Candevario paragraph")
            break
else:
    print("  (see Appendix D) already present")

print("FIX 8: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 9: Adviser on title page
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 9: Adviser label on title page...")

paras = doc.paragraphs
all_text = '\n'.join(p.text for p in paras)

# Find "Ellen Flores Mangaoang, DIT" in the title page (by: section)
# This is around P16-P25
# We need to add "Adviser:" before her name
# Check if already has Adviser label
if 'Adviser:' not in all_text:
    for i, para in enumerate(paras):
        t = para.text.strip()
        # Title page "by:" section - Ellen is listed right after the students
        if t == 'Ellen Flores Mangaoang, DIT' and i < 30:
            # Check if previous paragraph is a student name or "by:"
            prev_text = paras[i-1].text.strip() if i > 0 else ''
            if prev_text in ['Djaunathan Albert S. Madayag', 'by:', 'Cyrille John M. Rubis']:
                # Insert "Adviser:" paragraph before Ellen's name
                body = doc.element.body
                ellen_el = para._element
                
                # Add empty line before Adviser label
                blank_el = OxmlElement('w:p')
                blank_r = OxmlElement('w:r')
                blank_t = OxmlElement('w:t')
                blank_t.text = ''
                blank_r.append(blank_t)
                blank_el.append(blank_r)
                
                adviser_el = OxmlElement('w:p')
                adviser_r = OxmlElement('w:r')
                adviser_t = OxmlElement('w:t')
                adviser_t.text = 'Adviser:'
                adviser_r.append(adviser_t)
                adviser_el.append(adviser_r)
                
                # Insert before Ellen's paragraph
                ellen_el.addprevious(adviser_el)
                ellen_el.addprevious(blank_el)
                
                print(f"  Added 'Adviser:' label before P{i}: '{t}'")
                break
else:
    print("  Adviser: label already present")

print("FIX 9: Done")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Save the DOCX
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print(f"\nSaving to {OUT}...")
doc.save(OUT)
print("DOCX saved.")

# Also copy to FOR_CYRILLE for the verifier
print(f"Copying to {FOR_CYRILLE}...")
shutil.copy2(OUT, FOR_CYRILLE)
print("Copy done.")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIX 10: PPT and Script sync
# (already passing, but verify and patch if needed)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print("\nFIX 10: Checking PPT and Script...")

# Check script
with open(SCRIPT_PATH, encoding='utf-8') as f:
    script = f.read()

script_changed = False

# Replace table number references in script
# Table 5=Demographics, Table 6=LLM comparison, Table 7=Overall SUS, Table 8=SUS by group
# Check for old references
script_placeholders = {
    'Table 6': '##T5##',
    'Table 7': '##T6##',
    'Table 8': '##T7##',
    'Table 9': '##T8##',
}
script_reverse = {
    '##T5##': 'Table 5',
    '##T6##': 'Table 6',
    '##T7##': 'Table 7',
    '##T8##': 'Table 8',
}

# Only update if old references exist (Table 6 as demographics)
# Check if script needs table number updates
if 'Table 6' in script or 'Table 7' in script or 'Table 8' in script or 'Table 9' in script:
    # Context check: if "Table 6" is used to mean LLM comparison, it's already updated
    # If "Table 6" means demographics, it needs updating
    # Look for context clues
    if 'Table 6' in script and 'demographic' in script.lower():
        # Check if Table 6 refers to demographics
        import re as re2
        for m in re2.finditer(r'Table 6', script):
            start = max(0, m.start() - 100)
            end = min(len(script), m.end() + 100)
            ctx = script[start:end].lower()
            if 'demographic' in ctx or 'respondent' in ctx:
                new_script = script
                for old_t, ph in script_placeholders.items():
                    new_script = new_script.replace(old_t, ph)
                for ph, new_t in script_reverse.items():
                    new_script = new_script.replace(ph, new_t)
                if new_script != script:
                    script = new_script
                    script_changed = True
                    print("  Script table references updated")
                break

# Verify Gemini 1.5 not in script
if 'Gemini 1.5' in script:
    script = script.replace('Gemini 1.5', 'Gemini 3.5 Flash-Lite')
    script_changed = True
    print("  Script: Gemini 1.5 → Gemini 3.5 Flash-Lite")

if script_changed:
    with open(SCRIPT_PATH, 'w', encoding='utf-8') as f:
        f.write(script)
    print("  Script saved.")
else:
    print("  Script: no changes needed")

# Check PPT
prs = Presentation(PPT_PATH)
ppt_changed = False

def get_all_ppt_shapes(prs):
    shapes = []
    for slide in prs.slides:
        for shape in slide.shapes:
            shapes.append(shape)
            if shape.shape_type == 6:  # group
                for s in shape.shapes:
                    shapes.append(s)
    return shapes

def fix_ppt_text(text_frame, old, new):
    changed = False
    for para in text_frame.paragraphs:
        for run in para.runs:
            if old in run.text:
                run.text = run.text.replace(old, new)
                changed = True
    return changed

# Check for Gemini 1.5 in PPT
for shape in get_all_ppt_shapes(prs):
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                if 'Gemini 1.5' in run.text:
                    run.text = run.text.replace('Gemini 1.5', 'Gemini 3.5 Flash-Lite')
                    ppt_changed = True
                    print("  PPT: Gemini 1.5 → Gemini 3.5 Flash-Lite")
    if shape.has_table:
        for row in shape.table.rows:
            for cell in row.cells:
                if fix_ppt_text(cell.text_frame, 'Gemini 1.5', 'Gemini 3.5 Flash-Lite'):
                    ppt_changed = True

if ppt_changed:
    prs.save(PPT_PATH)
    print("  PPT saved.")
else:
    print("  PPT: no changes needed")

print("\nFIX 10: Done")
print("\n" + "=" * 60)
print("ALL FIXES APPLIED")
print("=" * 60)
