"""
apply_fixes.py — Apply all Maam Ellen transcript fixes to V4(3) manuscript.
SOURCE: 1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (3).docx
OUTPUT: FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx
"""

import shutil
import os
import re
import sys
from datetime import datetime
from copy import deepcopy
from lxml import etree

try:
    from docx import Document
    from docx.oxml.ns import qn
except ImportError:
    os.system("pip install python-docx")
    from docx import Document
    from docx.oxml.ns import qn

# ─── Paths ────────────────────────────────────────────────────────────────────
SOURCE = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (3).docx"
OUTPUT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
REPORT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\V4_3_FIXES_REPORT.md"

# ─── Logging ──────────────────────────────────────────────────────────────────
log_entries = []

def log(fix_id, status, detail=""):
    msg = f"[{fix_id}] {status}" + (f": {detail}" if detail else "")
    print(msg)
    log_entries.append((fix_id, status, detail))

# ─── Helpers ──────────────────────────────────────────────────────────────────

def get_full_text(p):
    return "".join(r.text for r in p.runs if r.text)

def replace_in_paragraph(p, old, new):
    """Replace 'old' with 'new' in paragraph, preserving first run's formatting."""
    full = "".join(r.text or "" for r in p.runs)
    if old in full:
        new_full = full.replace(old, new)
        if p.runs:
            p.runs[0].text = new_full
            for r in p.runs[1:]:
                r.text = ""
        else:
            p.add_run(new_full)
        return True
    return False

def set_paragraph_text(p, new_text):
    """Replace entire paragraph text, preserving style."""
    p.clear()
    p.add_run(new_text)

def delete_paragraph(p):
    """Remove a paragraph element from its parent."""
    parent = p._element.getparent()
    if parent is not None:
        parent.remove(p._element)

def set_cell_text(cell, new_text):
    """Set cell text, clearing all existing runs."""
    for para in cell.paragraphs:
        for run in para.runs:
            run.text = ""
    if cell.paragraphs:
        cell.paragraphs[0].clear()
        cell.paragraphs[0].add_run(new_text)
    else:
        cell.add_paragraph(new_text)

def apply_replacement_all(doc, old, new, label):
    """Apply a string replacement across all paragraphs and table cells."""
    count = 0
    for p in doc.paragraphs:
        if replace_in_paragraph(p, old, new):
            count += 1
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for p in cell.paragraphs:
                    if replace_in_paragraph(p, old, new):
                        count += 1
    if count:
        log(label, "APPLIED", f"replaced {count} occurrence(s)")
    else:
        log(label, "SKIPPED", f"'{old}' not found")

# ─── STEP 1: Copy source ──────────────────────────────────────────────────────
print("\n=== STEP 1: Copy source ===")
os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
shutil.copy2(SOURCE, OUTPUT)
log("STEP1_COPY", "APPLIED", f"Copied source to {OUTPUT}")

doc = Document(OUTPUT)

# ─── STEP 2A: Research Design ─────────────────────────────────────────────────
print("\n=== STEP 2A: Research Design ===")

apply_replacement_all(doc, "mixed-methods developmental", "quantitative descriptive developmental", "2A.1_mixed-methods")
apply_replacement_all(doc, "mixed methods developmental", "quantitative descriptive developmental", "2A.2_mixed-methods-nohyphen")
apply_replacement_all(doc, "qualitative and quantitative approaches", "quantitative approach", "2A.3_qual-quant-approaches")
apply_replacement_all(doc, "both qualitative and quantitative", "quantitative", "2A.4_both-qual-quant")

# Replace specific paragraph
target_sub = "To gather user input for the study, structured survey questionnaires were used to collect respondents' views regarding the features and functionality"
replacement_text = "The study employed structured survey questionnaires to collect quantitative data on the financial management practices, budgeting challenges, and expense tracking behaviors of the target population."
found_2a5 = False
for p in doc.paragraphs:
    if target_sub in get_full_text(p):
        set_paragraph_text(p, replacement_text)
        log("2A.5_survey-para", "APPLIED", "Replaced survey questionnaire paragraph")
        found_2a5 = True
        break
if not found_2a5:
    log("2A.5_survey-para", "SKIPPED", f"Substring not found: '{target_sub[:60]}...'")

# ─── STEP 2B: Validator name ──────────────────────────────────────────────────
print("\n=== STEP 2B: Validator name ===")

apply_replacement_all(doc, "Susan C. Arquisal", "Avigail Candevario, PFMe", "2B.1_susan-replace")

found_2b2 = False
paras_to_delete = []
for p in doc.paragraphs:
    txt = get_full_text(p).strip()
    if txt == "The survey questionnaire was reviewed by , a graduate of" or txt.startswith("The survey questionnaire was reviewed by ,"):
        paras_to_delete.append(p)
        found_2b2 = True
for p in paras_to_delete:
    delete_paragraph(p)
if found_2b2:
    log("2B.2_delete-broken-validator", "APPLIED", f"Deleted {len(paras_to_delete)} broken validator paragraph(s)")
else:
    log("2B.2_delete-broken-validator", "SKIPPED", "Broken validator paragraph not found")

# ─── STEP 2C: Delete false technical validator sentence ───────────────────────
print("\n=== STEP 2C: False technical validator ===")

target_c = "The System Usability Scale (SUS) evaluation process and the overall technical functionality of the SmartSpend system was reviewed by a subject matter expert in information technology"
found_c = False
for p in doc.paragraphs:
    if target_c in get_full_text(p):
        delete_paragraph(p)
        log("2C_delete-sus-validator", "APPLIED")
        found_c = True
        break
if not found_c:
    log("2C_delete-sus-validator", "SKIPPED", "Target sentence not found")

# ─── STEP 2D: Distribution of Respondents table ───────────────────────────────
print("\n=== STEP 2D: Distribution of Respondents table ===")

found_d = False
for table in doc.tables:
    # Collect all cell texts for detection
    all_cells = []
    for row in table.rows:
        for cell in row.cells:
            all_cells.append(cell.text.strip())
    
    has_distribution = any("Distribution of Respondents" in c for c in all_cells)
    has_parents = any("Parents" in c for c in all_cells)
    
    if not (has_distribution or has_parents):
        continue
    
    # Found the target table
    found_d = True
    parents_row_idx = None
    
    for i, row in enumerate(table.rows):
        cell_texts = [cell.text.strip() for cell in row.cells]
        # Find Parents row with count 16
        if cell_texts and "Parents" in cell_texts[0]:
            parents_row_idx = i
            # Find cell containing "16" and change to "13"
            for j, cell in enumerate(row.cells):
                if cell.text.strip() == "16":
                    set_cell_text(cell, "13")
                    log("2D.1_parents-count", "APPLIED", f"Changed 16→13 in row {i}, col {j}")
                    break
            else:
                # Try numeric cell anywhere in row
                for j, cell in enumerate(row.cells):
                    if "16" in cell.text:
                        old_text = cell.text.strip()
                        new_text = old_text.replace("16", "13")
                        set_cell_text(cell, new_text)
                        log("2D.1_parents-count", "APPLIED", f"Changed 16→13 in row {i}, col {j}")
                        break
                else:
                    log("2D.1_parents-count", "SKIPPED", f"Parents row {i} found but no cell with '16'")
    
    # Check if Both Groups row already exists
    has_both_groups = any("Both Groups" in c for c in all_cells)
    if has_both_groups:
        log("2D.2_both-groups-row", "SKIPPED", "Both Groups row already exists")
    elif parents_row_idx is not None:
        # Add a new row after parents_row_idx
        # Determine number of columns
        num_cols = len(table.rows[0].cells)
        # Copy structure from parents row
        parents_tr = table.rows[parents_row_idx]._tr
        new_tr = deepcopy(parents_tr)
        # Set cell texts in new row
        new_tcs = new_tr.findall(qn('w:tc'))
        new_values = ["Both Groups", "3"] + [""] * (num_cols - 2)
        for idx, tc in enumerate(new_tcs):
            # Clear existing paragraphs' runs
            for para_el in tc.findall('.//' + qn('w:p')):
                for r_el in para_el.findall(qn('w:r')):
                    for t_el in r_el.findall(qn('w:t')):
                        t_el.text = new_values[idx] if idx < len(new_values) else ""
                    break
                break
        # Insert after parents row
        parents_tr.addnext(new_tr)
        log("2D.2_both-groups-row", "APPLIED", "Added Both Groups row after Parents row")
    else:
        log("2D.2_both-groups-row", "SKIPPED", "Parents row not found in table")
    
    break  # Only process first matching table

if not found_d:
    log("2D_respondents-table", "SKIPPED", "Distribution of Respondents table not found")

# ─── STEP 2E: Fill population blank ──────────────────────────────────────────
print("\n=== STEP 2E: Population blank ===")
apply_replacement_all(doc, "There are a total of __ respondents", "A total of thirty (30) respondents participated", "2E_population-blank")

# ─── STEP 2F: Remove Step N: labels ──────────────────────────────────────────
print("\n=== STEP 2F: Remove Step N: labels ===")

step_labels = ["Step 1:", "Step 2:", "Step 3:", "Step 4:", "Step 5:", "Step 6:"]
f_count = 0
for p in doc.paragraphs:
    txt = get_full_text(p).strip()
    for label in step_labels:
        if txt.startswith(label):
            # Remove just the label prefix
            new_text = txt[len(label):].lstrip()
            set_paragraph_text(p, new_text)
            f_count += 1
            break

if f_count:
    log("2F_step-labels", "APPLIED", f"Removed step labels from {f_count} paragraph(s)")
else:
    log("2F_step-labels", "SKIPPED", "No Step N: labels found at start of paragraphs")

# ─── STEP 2G: Placeholder replacements/deletions ─────────────────────────────
print("\n=== STEP 2G: Placeholder replacements/deletions ===")

# G.1
g1_target = "EXPLAIN WHAT DID IN THE DESIGN AND DEVELOPMENT"
g1_replacement = "SmartSpend was developed as an Android mobile application using Flutter for the UI, SQLite for local storage, Firebase for cloud sync, and a large language model API for AI-powered expense parsing and financial assistance."
found_g1 = False
for p in doc.paragraphs:
    if g1_target in get_full_text(p):
        set_paragraph_text(p, g1_replacement)
        log("2G.1_explain-placeholder", "APPLIED")
        found_g1 = True
        break
if not found_g1:
    log("2G.1_explain-placeholder", "SKIPPED", "Target not found")

# G.2 — DELETE paragraph "DISCUSSION"
found_g2 = False
for p in doc.paragraphs:
    if get_full_text(p).strip() == "DISCUSSION":
        delete_paragraph(p)
        log("2G.2_delete-DISCUSSION", "APPLIED")
        found_g2 = True
        break
if not found_g2:
    log("2G.2_delete-DISCUSSION", "SKIPPED", "Standalone DISCUSSION paragraph not found")

# G.3 — DELETE paragraph "DESCRIPTION"
found_g3 = False
for p in doc.paragraphs:
    if get_full_text(p).strip() == "DESCRIPTION":
        delete_paragraph(p)
        log("2G.3_delete-DESCRIPTION", "APPLIED")
        found_g3 = True
        break
if not found_g3:
    log("2G.3_delete-DESCRIPTION", "SKIPPED", "Standalone DESCRIPTION paragraph not found")

# G.4
g4_target = "fIGURE 3 PRESENTS THE DASHBOARD OF SMARTSPEND. WHAT? HOW TO USE"
g4_replacement = "Figure [N] presents the Home Dashboard of SmartSpend, which displayed the Financial Health Score, recent transactions, and spending insights. The dashboard served as the main navigation screen."
found_g4 = False
for p in doc.paragraphs:
    if g4_target.lower() in get_full_text(p).lower():
        set_paragraph_text(p, g4_replacement)
        log("2G.4_figure3-placeholder", "APPLIED")
        found_g4 = True
        break
if not found_g4:
    log("2G.4_figure3-placeholder", "SKIPPED", "Target not found")

# G.5 — DELETE "Ano meaning ng 7"
found_g5 = False
for p in doc.paragraphs:
    if "Ano meaning ng 7" in get_full_text(p):
        delete_paragraph(p)
        log("2G.5_delete-ano-meaning", "APPLIED")
        found_g5 = True
        break
if not found_g5:
    log("2G.5_delete-ano-meaning", "SKIPPED", "Target not found")

# G.6 — DELETE dopamine paragraph
g6_target = "Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as \"dopamine reinforcement\""
found_g6 = False
for p in doc.paragraphs:
    if 'dopamine reinforcement' in get_full_text(p) or 'Present Peso as a design feature' in get_full_text(p):
        delete_paragraph(p)
        log("2G.6_delete-dopamine", "APPLIED")
        found_g6 = True
        break
if not found_g6:
    log("2G.6_delete-dopamine", "SKIPPED", "Target not found")

# G.7 — DELETE zero category budgets paragraph
g7_target = "The behavior of this component when zero category budgets were configured was a known open item"
found_g7 = False
for p in doc.paragraphs:
    if g7_target in get_full_text(p):
        delete_paragraph(p)
        log("2G.7_delete-zero-budget", "APPLIED")
        found_g7 = True
        break
if not found_g7:
    log("2G.7_delete-zero-budget", "SKIPPED", "Target not found")

# G.8 — Replace designed-and-developed objective placeholder
apply_replacement_all(
    doc,
    "Designed and Developed of the SmartSpend Mobile Application - see objective",
    "Designed and Developed of the SmartSpend Mobile Application",
    "2G.8_designed-developed"
)

# G.9 — DELETE "Discuss how system was developed and tools"
g9_target = "Discuss how system was developed and tools"
found_g9 = False
for p in doc.paragraphs:
    txt = get_full_text(p)
    if g9_target in txt and g1_replacement not in txt:
        delete_paragraph(p)
        log("2G.9_delete-discuss-tools", "APPLIED")
        found_g9 = True
        break
if not found_g9:
    log("2G.9_delete-discuss-tools", "SKIPPED", "Target not found")

# ─── STEP 2H: Tense fixes ─────────────────────────────────────────────────────
print("\n=== STEP 2H: Tense fixes ===")

tense_fixes = [
    ("proposed AI-powered", "developed AI-powered"),
    ("This study proposed SmartSpend", "This study developed SmartSpend"),
    ("The proposed solution", "The developed solution"),
    ("that can respond to user inputs", "that responded to user inputs"),
    ("SmartSpend enables users", "SmartSpend allowed users"),
    ("Voice recognition accuracy will be affected", "Voice recognition accuracy would be affected"),
    ("No surveys were conducted; qualitative insights", "No interviews were conducted; qualitative insights"),
    ("93.3% already use GCash", "93.3% already used GCash"),
]

for old, new in tense_fixes:
    apply_replacement_all(doc, old, new, f"2H_tense_{old[:30]}")

# ─── STEP 2I: References fixes ────────────────────────────────────────────────
print("\n=== STEP 2I: References fixes ===")

# I.1 — Remove URL from Ariely paragraph
url_to_remove = "https://www.anthropic.com/claude"
found_i1 = False
for p in doc.paragraphs:
    txt = get_full_text(p)
    if "Ariely" in txt and "2008" in txt and url_to_remove in txt:
        # Remove URL and surrounding punctuation
        new_txt = txt
        # Remove space + URL patterns
        for pattern in [" " + url_to_remove, url_to_remove + ".", url_to_remove + " ", url_to_remove]:
            new_txt = new_txt.replace(pattern, "")
        new_txt = new_txt.strip()
        set_paragraph_text(p, new_txt)
        log("2I.1_ariely-url", "APPLIED", "Removed URL from Ariely paragraph")
        found_i1 = True
        break
if not found_i1:
    log("2I.1_ariely-url", "SKIPPED", "Ariely paragraph with URL not found")

# I.2 — Remove duplicate "Note: The 3 respondents" paragraphs
note_paras = []
for p in doc.paragraphs:
    if "Note: The 3 respondents" in get_full_text(p):
        note_paras.append(p)
if len(note_paras) > 1:
    for p in note_paras[1:]:
        delete_paragraph(p)
    log("2I.2_duplicate-note", "APPLIED", f"Deleted {len(note_paras)-1} duplicate note paragraph(s)")
elif len(note_paras) == 1:
    log("2I.2_duplicate-note", "SKIPPED", "Only one note paragraph found (no duplicates)")
else:
    log("2I.2_duplicate-note", "SKIPPED", "Note paragraph not found")

# I.3 — Move stray references to correct alphabetical positions
print("Processing I.3: Move stray references...")

stray_keywords = {
    "Bangor": None,
    "Deci": None,
    "Sauro": None,
}

# Find the References heading
ref_heading_idx = None
all_paras = list(doc.paragraphs)
for i, p in enumerate(all_paras):
    txt = get_full_text(p).strip()
    if txt in ("References", "REFERENCES") or (txt.startswith("Reference") and len(txt) < 20):
        # Check it's a heading style
        if p.style and ("Heading" in p.style.name or txt in ("References", "REFERENCES")):
            ref_heading_idx = i
            break

if ref_heading_idx is None:
    # Try to find it without style check
    for i, p in enumerate(all_paras):
        txt = get_full_text(p).strip()
        if txt in ("References", "REFERENCES"):
            ref_heading_idx = i
            break

if ref_heading_idx is not None:
    # Collect all paragraphs after References heading
    ref_paras = all_paras[ref_heading_idx + 1:]
    
    # Find stray references (appearing after main body of ref list)
    stray_paras = {}
    for keyword in stray_keywords:
        for p in ref_paras:
            txt = get_full_text(p)
            if keyword in txt and len(txt) > 10:
                # Check if it looks like a reference
                if re.search(r'\(\d{4}\)', txt) or re.search(r'\d{4}', txt):
                    stray_paras[keyword] = p
                    break
    
    # For each stray, find correct alphabetical position in ref list
    for keyword, stray_p in stray_paras.items():
        if stray_p is None:
            log(f"2I.3_{keyword}", "SKIPPED", "Not found in references")
            continue
        
        # Get current index of stray paragraph
        try:
            stray_idx_in_all = all_paras.index(stray_p)
        except ValueError:
            log(f"2I.3_{keyword}", "SKIPPED", "Paragraph index error")
            continue
        
        # Find correct insertion point (alphabetical by first letter of keyword)
        # First letter of keyword = insertion point
        first_letter = keyword[0].upper()
        
        # Find ref paragraphs that start with the same or next letter
        insert_after = None
        for p in ref_paras:
            if p is stray_p:
                continue
            txt = get_full_text(p).strip()
            if not txt:
                continue
            first_char = txt[0].upper() if txt else ""
            if first_char < first_letter:
                insert_after = p
            elif first_char == first_letter:
                # Check alphabetical within same letter
                if txt[:len(keyword)].lower() < keyword.lower():
                    insert_after = p
                else:
                    break
            else:
                break
        
        if insert_after is not None and insert_after is not stray_p:
            # Move stray_p to after insert_after
            stray_el = stray_p._element
            parent = stray_el.getparent()
            if parent is not None:
                parent.remove(stray_el)
                insert_after._element.addnext(stray_el)
                log(f"2I.3_{keyword}", "APPLIED", f"Moved to after entry starting with '{get_full_text(insert_after)[:40]}'")
        else:
            log(f"2I.3_{keyword}", "SKIPPED", f"Could not determine insertion point for {keyword}")
    
    # Log any not found
    for keyword in stray_keywords:
        if keyword not in stray_paras:
            log(f"2I.3_{keyword}", "SKIPPED", f"Stray reference not found")
else:
    log("2I.3_stray-refs", "SKIPPED", "References heading not found")

# ─── STEP 2J: Conclusions — fix SUS benchmark description ─────────────────────
print("\n=== STEP 2J: SUS benchmark fix ===")
apply_replacement_all(
    doc,
    "below the ≥80 target but acceptable for a prototype system",
    "below both the 68-point average benchmark and the pre-established target of 80",
    "2J_sus-benchmark"
)

# ─── STEP 2K: Appendix B cross-reference fix ─────────────────────────────────
print("\n=== STEP 2K: Appendix B → C for SUS ===")

k_count = 0
for p in doc.paragraphs:
    txt = get_full_text(p)
    if "see Appendix B" in txt and "SUS" in txt.upper():
        if replace_in_paragraph(p, "see Appendix B", "see Appendix C"):
            k_count += 1
    elif "See Appendix B" in txt and "SUS" in txt.upper():
        if replace_in_paragraph(p, "See Appendix B", "see Appendix C"):
            k_count += 1

if k_count:
    log("2K_appendix-b-sus", "APPLIED", f"{k_count} paragraph(s) updated")
else:
    log("2K_appendix-b-sus", "SKIPPED", "No 'see Appendix B' in SUS context found")

# ─── STEP 2L: Photo Documentation — delete empty heading/blank paras ──────────
print("\n=== STEP 2L: Photo Documentation section ===")

photo_heading_idx = None
for i, p in enumerate(doc.paragraphs):
    txt = get_full_text(p).strip()
    if "Photo Documentation" in txt:
        photo_heading_idx = i
        break

if photo_heading_idx is not None:
    all_paras_now = list(doc.paragraphs)
    # Delete blank paragraphs immediately after
    blanks_deleted = 0
    j = photo_heading_idx + 1
    while j < len(all_paras_now):
        p_next = all_paras_now[j]
        if get_full_text(p_next).strip() == "":
            delete_paragraph(p_next)
            blanks_deleted += 1
            j += 1
        else:
            break
    
    # Check if next non-blank is a new heading (meaning section is empty)
    # Re-read paragraphs
    all_paras_now2 = list(doc.paragraphs)
    try:
        new_idx = all_paras_now2.index(all_paras_now[photo_heading_idx]) if all_paras_now[photo_heading_idx] in all_paras_now2 else None
    except (ValueError, IndexError):
        new_idx = None
    
    if new_idx is not None:
        # Check the paragraph after photo heading
        if new_idx + 1 < len(all_paras_now2):
            next_p = all_paras_now2[new_idx + 1]
            next_style = next_p.style.name if next_p.style else ""
            next_txt = get_full_text(next_p).strip()
            is_heading = "Heading" in next_style or next_txt.isupper()
            if is_heading or not next_txt:
                # Section is empty — delete the Photo Documentation heading
                photo_p = all_paras_now[photo_heading_idx]
                delete_paragraph(photo_p)
                log("2L_photo-documentation", "APPLIED", f"Deleted Photo Documentation heading and {blanks_deleted} blank paragraph(s)")
            else:
                if blanks_deleted:
                    log("2L_photo-documentation", "APPLIED", f"Deleted {blanks_deleted} blank paragraph(s) after Photo Documentation heading (kept heading, section has content)")
                else:
                    log("2L_photo-documentation", "SKIPPED", "Photo Documentation section has content, nothing to delete")
        else:
            # At end of doc — delete heading
            photo_p = all_paras_now[photo_heading_idx]
            delete_paragraph(photo_p)
            log("2L_photo-documentation", "APPLIED", f"Deleted Photo Documentation heading (at end of doc) and {blanks_deleted} blank paragraph(s)")
    else:
        log("2L_photo-documentation", "APPLIED", f"Deleted {blanks_deleted} blank paragraph(s) after Photo Documentation heading")
else:
    log("2L_photo-documentation", "SKIPPED", "Photo Documentation heading not found")

# ─── STEP 2M: Lowercase Survey fix ───────────────────────────────────────────
print("\n=== STEP 2M: Lowercase Survey fix ===")
apply_replacement_all(
    doc,
    "No formal open-ended Survey data",
    "No formal open-ended survey data",
    "2M_lowercase-survey"
)

# ─── STEP 2N: Scope and Limitations replacement ───────────────────────────────
print("\n=== STEP 2N: Scope and Limitations ===")

scope_heading_idx = None
for i, p in enumerate(doc.paragraphs):
    if "Scope and Limitations" in get_full_text(p):
        scope_heading_idx = i
        break

if scope_heading_idx is not None:
    all_p = list(doc.paragraphs)
    # Collect next 4 body paragraphs (skip blank ones)
    body_paras = []
    j = scope_heading_idx + 1
    while j < len(all_p) and len(body_paras) < 4:
        p_cand = all_p[j]
        txt = get_full_text(p_cand).strip()
        if txt:  # skip blank
            # Stop if we hit a heading
            style_name = p_cand.style.name if p_cand.style else ""
            if "Heading" in style_name:
                break
            body_paras.append(p_cand)
        j += 1
    
    scope_p1 = "The study was limited to the development and evaluation of SmartSpend as an Android mobile application. The system supported voice input, receipt scanning through OCR, barcode scanning, and text-based chat through the AI assistant. It integrated a large language model API for natural language processing and financial assistance, local data storage through SQLite, and optional cloud synchronization through Firebase. A Financial Health Score was developed as a prototype indicator of budgeting behavior."
    scope_p2 = "The system was available only on Android devices. Direct banking integration was excluded. The application did not provide professional financial or investment advice. OCR accuracy depended on receipt image quality. Voice recognition was affected by background noise. All AI features required an active internet connection."

    if len(body_paras) >= 1:
        set_paragraph_text(body_paras[0], scope_p1)
        log("2N.1_scope-p1", "APPLIED")
    else:
        log("2N.1_scope-p1", "SKIPPED", "No body paragraphs after Scope and Limitations heading")
    
    if len(body_paras) >= 2:
        set_paragraph_text(body_paras[1], scope_p2)
        log("2N.2_scope-p2", "APPLIED")
    else:
        log("2N.2_scope-p2", "SKIPPED", "Only 1 body paragraph found")
    
    # Clear and delete paragraphs 3 and 4
    if len(body_paras) >= 3:
        delete_paragraph(body_paras[2])
        log("2N.3_scope-p3-delete", "APPLIED")
    else:
        log("2N.3_scope-p3-delete", "SKIPPED", "No 3rd paragraph")
    
    if len(body_paras) >= 4:
        delete_paragraph(body_paras[3])
        log("2N.4_scope-p4-delete", "APPLIED")
    else:
        log("2N.4_scope-p4-delete", "SKIPPED", "No 4th paragraph")
else:
    log("2N_scope-limitations", "SKIPPED", "Scope and Limitations heading not found")

# ─── STEP 2O: Remove SUS distribution figures 3.12 and 3.13 ──────────────────
print("\n=== STEP 2O: Remove SUS figures 3.12 and 3.13 ===")

WNS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
DRAWING_NS = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"

def has_image(p):
    """Check if paragraph contains an inline image."""
    for r in p.runs:
        # Check for drawing in run element
        if r._element.findall('.//{%s}drawing' % WNS):
            return True
        if r._element.findall('.//{%s}inline' % DRAWING_NS):
            return True
        if r._element.findall('.//{%s}anchor' % DRAWING_NS):
            return True
    return False

o_deleted = 0
all_paras_o = list(doc.paragraphs)
captions_to_delete = []

for i, p in enumerate(all_paras_o):
    txt = get_full_text(p)
    if "Figure 3.12" in txt or "Figure 3.13" in txt:
        captions_to_delete.append(i)

for cap_idx in reversed(captions_to_delete):
    # Delete image paragraph before caption
    if cap_idx > 0:
        prev_p = all_paras_o[cap_idx - 1]
        if has_image(prev_p):
            delete_paragraph(prev_p)
            o_deleted += 1
    # Delete caption
    delete_paragraph(all_paras_o[cap_idx])
    o_deleted += 1

if o_deleted:
    log("2O_sus-figures", "APPLIED", f"Deleted {o_deleted} paragraph(s) for Figure 3.12/3.13")
else:
    log("2O_sus-figures", "SKIPPED", "Figure 3.12/3.13 captions not found")

# Also scan List of Figures
lof_heading_idx = None
for i, p in enumerate(doc.paragraphs):
    txt = get_full_text(p).strip()
    if "List of Figures" in txt:
        lof_heading_idx = i
        break

if lof_heading_idx is not None:
    all_p_now = list(doc.paragraphs)
    j = lof_heading_idx + 1
    lof_deleted = 0
    while j < len(all_p_now):
        p_cand = all_p_now[j]
        style_name = p_cand.style.name if p_cand.style else ""
        if "Heading" in style_name and "List of Figures" not in get_full_text(p_cand):
            break
        txt = get_full_text(p_cand)
        if "3.12" in txt or "3.13" in txt:
            delete_paragraph(p_cand)
            lof_deleted += 1
        j += 1
    if lof_deleted:
        log("2O_lof-entries", "APPLIED", f"Deleted {lof_deleted} LOF entries for 3.12/3.13")
    else:
        log("2O_lof-entries", "SKIPPED", "No 3.12/3.13 entries in List of Figures")

# ─── STEP 2P: Remove Technical Performance Benchmarks section ─────────────────
print("\n=== STEP 2P: Remove Technical Performance Benchmarks ===")

tech_heading_idx = None
for i, p in enumerate(doc.paragraphs):
    if "Technical Performance Benchmarks" in get_full_text(p):
        tech_heading_idx = i
        break

if tech_heading_idx is not None:
    all_p = list(doc.paragraphs)
    tech_p = all_p[tech_heading_idx]
    tech_style = tech_p.style.name if tech_p.style else ""
    
    # Collect body paragraphs to delete (until next heading)
    to_delete = [tech_p]
    j = tech_heading_idx + 1
    while j < len(all_p):
        p_cand = all_p[j]
        style_name = p_cand.style.name if p_cand.style else ""
        if "Heading" in style_name and p_cand is not tech_p:
            break  # Stop before next heading
        to_delete.append(p_cand)
        j += 1
    
    for p_del in to_delete:
        delete_paragraph(p_del)
    
    log("2P_tech-benchmarks", "APPLIED", f"Deleted {len(to_delete)} paragraphs in Technical Performance Benchmarks section")
else:
    log("2P_tech-benchmarks", "SKIPPED", "Technical Performance Benchmarks heading not found")

# ─── STEP 2Q: Continuous figure and table numbering ──────────────────────────
print("\n=== STEP 2Q: Continuous figure/table numbering ===")

# Pattern: Figure X.Y or Figure X (at start of paragraph text)
FIG_PAT = re.compile(r'^(Figure)\s+(\d+(?:\.\d+)?)', re.IGNORECASE)
TBL_PAT = re.compile(r'^(Table)\s+(\d+(?:\.\d+)?)', re.IGNORECASE)

# Collect all figure caption paragraphs
fig_captions = []  # (paragraph, old_label)
tbl_captions = []  # (paragraph, old_label)

for p in doc.paragraphs:
    txt = get_full_text(p).strip()
    m = FIG_PAT.match(txt)
    if m:
        old_label = m.group(1) + " " + m.group(2)
        fig_captions.append((p, old_label))
        continue
    m2 = TBL_PAT.match(txt)
    if m2:
        old_label = m2.group(1) + " " + m2.group(2)
        tbl_captions.append((p, old_label))

# Build old→new maps
fig_map = {}  # "Figure X.Y" → "Figure N"
for n, (p, old_label) in enumerate(fig_captions, 1):
    new_label = f"Figure {n}"
    fig_map[old_label] = new_label

tbl_map = {}  # "Table X.Y" → "Table N"
for n, (p, old_label) in enumerate(tbl_captions, 1):
    new_label = f"Table {n}"
    tbl_map[old_label] = new_label

# Apply new labels to captions
for n, (p, old_label) in enumerate(fig_captions, 1):
    new_label = f"Figure {n}"
    txt = get_full_text(p)
    new_txt = FIG_PAT.sub(new_label, txt, count=1)
    if new_txt != txt:
        set_paragraph_text(p, new_txt)

for n, (p, old_label) in enumerate(tbl_captions, 1):
    new_label = f"Table {n}"
    txt = get_full_text(p)
    new_txt = TBL_PAT.sub(new_label, txt, count=1)
    if new_txt != txt:
        set_paragraph_text(p, new_txt)

log("2Q_fig-captions", "APPLIED", f"Renumbered {len(fig_captions)} figure captions, {len(tbl_captions)} table captions")

# Build comprehensive in-text replacement patterns
# Collect all old labels from both maps
def build_intext_replacement(text, fig_map, tbl_map):
    """Replace old figure/table references with new sequential numbers."""
    result = text
    
    # Sort by length descending to avoid partial replacements
    all_fig_old = sorted(fig_map.keys(), key=lambda x: len(x), reverse=True)
    all_tbl_old = sorted(tbl_map.keys(), key=lambda x: len(x), reverse=True)
    
    for old, new in [(k, fig_map[k]) for k in all_fig_old]:
        result = result.replace(old, new)
        # Also handle lowercase
        result = result.replace(old.lower(), new)
        result = result.replace(old.capitalize(), new)
    
    for old, new in [(k, tbl_map[k]) for k in all_tbl_old]:
        result = result.replace(old, new)
        result = result.replace(old.lower(), new)
    
    # Also handle patterns like "Figure 1.1" generically that weren't in captions
    # Replace any remaining Figure X.Y or Table X.Y patterns
    def fig_sub(m):
        old_lbl = "Figure " + m.group(2)
        return fig_map.get(old_lbl, m.group(0))
    
    def tbl_sub(m):
        old_lbl = "Table " + m.group(2)
        return tbl_map.get(old_lbl, m.group(0))
    
    result = re.sub(r'(?i)(Figure)\s+(\d+\.\d+)', fig_sub, result)
    result = re.sub(r'(?i)(Table)\s+(\d+\.\d+)', tbl_sub, result)
    
    return result

# Update in-text references in all paragraphs
q_intext_count = 0
for p in doc.paragraphs:
    txt = get_full_text(p)
    new_txt = build_intext_replacement(txt, fig_map, tbl_map)
    if new_txt != txt:
        # Preserve runs
        if p.runs:
            p.runs[0].text = new_txt
            for r in p.runs[1:]:
                r.text = ""
        q_intext_count += 1

# Update in-text references in table cells
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                txt = get_full_text(p)
                new_txt = build_intext_replacement(txt, fig_map, tbl_map)
                if new_txt != txt:
                    if p.runs:
                        p.runs[0].text = new_txt
                        for r in p.runs[1:]:
                            r.text = ""
                    q_intext_count += 1

log("2Q_intext-refs", "APPLIED", f"Updated {q_intext_count} in-text reference paragraph(s)")

# Update List of Figures
if lof_heading_idx is not None:
    all_p_now = list(doc.paragraphs)
    # Find LOF heading in current list
    lof_p = None
    for p in all_p_now:
        if "List of Figures" in get_full_text(p).strip() and "Heading" in (p.style.name if p.style else ""):
            lof_p = p
            break
    if lof_p is None:
        for p in all_p_now:
            if get_full_text(p).strip() == "List of Figures":
                lof_p = p
                break
    
    if lof_p is not None:
        lof_idx = all_p_now.index(lof_p)
        # Collect LOF entries
        lof_entries = []
        j = lof_idx + 1
        while j < len(all_p_now):
            p_cand = all_p_now[j]
            style_name = p_cand.style.name if p_cand.style else ""
            if "Heading" in style_name and "List of" not in get_full_text(p_cand):
                break
            lof_entries.append(p_cand)
            j += 1
        
        # Rebuild from fig_captions
        for n, (cap_p, old_label) in enumerate(fig_captions, 1):
            new_label = f"Figure {n}"
            cap_txt = get_full_text(cap_p).strip()
            # Strip old label from caption text
            entry_txt = re.sub(r'^Figure\s+\d+(?:\.\d+)?\s*', '', cap_txt, flags=re.IGNORECASE).strip()
            lof_text = f"{new_label}   {entry_txt}"
            
            if n - 1 < len(lof_entries):
                set_paragraph_text(lof_entries[n - 1], lof_text)
            else:
                # LOF has fewer entries than captions; this is fine
                pass
        
        # Remove extra LOF entries if any
        if len(lof_entries) > len(fig_captions):
            for extra_p in lof_entries[len(fig_captions):]:
                delete_paragraph(extra_p)
        
        log("2Q_lof-rebuild", "APPLIED", f"Rebuilt {min(len(fig_captions), len(lof_entries))} LOF entries")
    else:
        log("2Q_lof-rebuild", "SKIPPED", "List of Figures heading not found in current doc")
else:
    log("2Q_lof-rebuild", "SKIPPED", "List of Figures heading index not found")

# Update List of Tables
lot_heading_idx = None
for i, p in enumerate(doc.paragraphs):
    txt = get_full_text(p).strip()
    if "List of Tables" in txt:
        lot_heading_idx = i
        break

if lot_heading_idx is not None:
    all_p_now = list(doc.paragraphs)
    lot_p = all_p_now[lot_heading_idx]
    j = lot_heading_idx + 1
    lot_entries = []
    while j < len(all_p_now):
        p_cand = all_p_now[j]
        style_name = p_cand.style.name if p_cand.style else ""
        if "Heading" in style_name and "List of" not in get_full_text(p_cand):
            break
        lot_entries.append(p_cand)
        j += 1
    
    for n, (cap_p, old_label) in enumerate(tbl_captions, 1):
        new_label = f"Table {n}"
        cap_txt = get_full_text(cap_p).strip()
        entry_txt = re.sub(r'^Table\s+\d+(?:\.\d+)?\s*', '', cap_txt, flags=re.IGNORECASE).strip()
        lot_text = f"{new_label}   {entry_txt}"
        
        if n - 1 < len(lot_entries):
            set_paragraph_text(lot_entries[n - 1], lot_text)
    
    if len(lot_entries) > len(tbl_captions):
        for extra_p in lot_entries[len(tbl_captions):]:
            delete_paragraph(extra_p)
    
    log("2Q_lot-rebuild", "APPLIED", f"Rebuilt {min(len(tbl_captions), len(lot_entries))} LOT entries")
else:
    log("2Q_lot-rebuild", "SKIPPED", "List of Tables heading not found")

# ─── STEP 2R: LLM Table ───────────────────────────────────────────────────────
print("\n=== STEP 2R: LLM Table ===")

MODELS_TO_DELETE = [
    "gpt-4o mini", "gpt-4o", "claude", "grok", "deepseek", "fin-r1",
    "mistral", "gemma", "llama 4 scout", "llama 3.3", "llama 3.1",
    "not used", "not use"
]
MODELS_TO_KEEP = [
    "gemini", "qwen", "gpt-oss", "groq compound", "cerebras"
]

def row_should_delete(row):
    """Return True if this row should be deleted (not-used model)."""
    cells_text = [c.text.strip().lower() for c in row.cells]
    combined = " ".join(cells_text)
    
    # Check if it's a header row
    if any(h in combined for h in ["model", "parameter", "status", "description", "architecture"]):
        # Check it's not a data row
        if not any(keep in combined for keep in MODELS_TO_KEEP):
            return False  # Keep header
    
    # Check "not used" in status cell
    if "not used" in combined or "not use" in combined:
        return True
    
    # Check model names to delete
    for del_model in MODELS_TO_DELETE:
        if del_model in combined:
            # Make sure it's not a keep model
            for keep in MODELS_TO_KEEP:
                if keep in combined:
                    return False
            if del_model not in ["not used", "not use", "gpt-4o"]:
                return True
            if del_model == "gpt-4o" and "gpt-oss" not in combined and "groq" not in combined:
                return True
    
    return False

# Find the LLM comparison table
llm_table = None
for table in doc.tables:
    all_text = " ".join(c.text.strip().lower() for row in table.rows for c in row.cells)
    has_model_indicators = any(kw in all_text for kw in ["gemini", "gpt", "claude", "llm", "model"])
    has_status = "status" in all_text
    if has_model_indicators and (has_status or "gemini" in all_text):
        llm_table = table
        break

if llm_table is not None:
    # Find Status column index
    status_col_idx = None
    if llm_table.rows:
        header_row = llm_table.rows[0]
        for j, cell in enumerate(header_row.cells):
            if "status" in cell.text.strip().lower():
                status_col_idx = j
                break
    
    # Delete rows for unused models (iterate in reverse to avoid index issues)
    rows_deleted = 0
    for row in list(llm_table.rows):
        cells_text = [c.text.strip().lower() for c in row.cells]
        combined = " ".join(cells_text)
        
        # Skip header row
        if any(h in combined for h in ["model name", "parameter count", "architecture"]):
            continue
        # Header row detection: all cells look like headers
        first_cell = cells_text[0] if cells_text else ""
        if first_cell in ("model", "model name", "llm", "#"):
            continue
        
        # Check if row should be deleted
        should_del = False
        
        # Check for "not used" / "not use" in status column
        if status_col_idx is not None and status_col_idx < len(row.cells):
            status_txt = row.cells[status_col_idx].text.strip().lower()
            if "not used" in status_txt or "not use" in status_txt:
                should_del = True
        
        # Check model name in first cell or any cell
        for del_model in ["gpt-4o mini", "claude", "grok", "deepseek", "fin-r1",
                          "mistral", "gemma", "llama 4 scout", "llama 3.3", "llama 3.1 8b"]:
            if del_model in combined:
                # Ensure it's not a keep model
                keep_found = any(keep in combined for keep in ["gpt-oss", "groq compound", "qwen"])
                if not keep_found:
                    should_del = True
                    break
        
        if should_del:
            tbl_el = row._tr.getparent()
            tbl_el.remove(row._tr)
            rows_deleted += 1
    
    log("2R_llm-rows-deleted", "APPLIED" if rows_deleted else "SKIPPED",
        f"Deleted {rows_deleted} model rows" if rows_deleted else "No matching rows found")
    
    # Delete Status column
    if status_col_idx is not None:
        cols_deleted = 0
        for row in llm_table.rows:
            tcs = row._tr.findall(qn('w:tc'))
            if status_col_idx < len(tcs):
                row._tr.remove(tcs[status_col_idx])
                cols_deleted += 1
        log("2R_status-column", "APPLIED", f"Deleted Status column from {cols_deleted} rows")
    else:
        log("2R_status-column", "SKIPPED", "Status column not found in LLM table")
else:
    log("2R_llm-table", "SKIPPED", "LLM comparison table not found")

# ─── STEP 3: Verify ───────────────────────────────────────────────────────────
print("\n=== STEP 3: Verification ===")

# Save first so we verify the saved file
doc.save(OUTPUT)
print(f"Saved to {OUTPUT}")

# Reload for verification
doc_v = Document(OUTPUT)
all_text_v = "\n".join(get_full_text(p) for p in doc_v.paragraphs)
# Also include table cells
for t in doc_v.tables:
    for row in t.rows:
        for cell in row.cells:
            all_text_v += "\n" + "\n".join(get_full_text(p) for p in cell.paragraphs)

verifications = []

def vcheck(label, condition, expected):
    status = "PASS" if condition else "FAIL"
    verifications.append((label, status, expected))
    print(f"  {'✓' if condition else '✗'} {label}: {status}")

vcheck("61.83 present (SUS score intact)", "61.83" in all_text_v, "Should be present")
vcheck("N=30 or 30 respondents present", "N=30" in all_text_v or "30 respondents" in all_text_v or "thirty (30)" in all_text_v, "Should be present")
vcheck("partially achieved present", "partially achieved" in all_text_v, "Should be present")
vcheck("Avigail present", "Avigail" in all_text_v, "Should be present")
vcheck("Susan NOT present", "Susan" not in all_text_v, "Should NOT be present")
vcheck("Ano meaning NOT present", "Ano meaning" not in all_text_v, "Should NOT be present")
vcheck("DESCRIPTION standalone NOT present", "\nDESCRIPTION\n" not in "\n" + all_text_v + "\n" and not any(get_full_text(p).strip() == "DESCRIPTION" for p in doc_v.paragraphs), "Should NOT be present")
vcheck("EXPLAIN WHAT NOT present", "EXPLAIN WHAT" not in all_text_v, "Should NOT be present")
vcheck("No Figure X.Y pattern (continuous numbering)", not re.search(r'Figure \d+\.\d+', all_text_v), "Should use Figure N format")
vcheck("Parents count 13 present in table", any(
    any("13" in cell.text for cell in row.cells)
    for t in doc_v.tables for row in t.rows
    if any("Parents" in cell.text for cell in row.cells)
), "Should be present")

# ─── STEP 4: Save once (already saved above) ─────────────────────────────────
print(f"\n=== STEP 4: Document already saved to {OUTPUT} ===")

# ─── STEP 6: Write report ─────────────────────────────────────────────────────
print("\n=== STEP 6: Writing report ===")

os.makedirs(os.path.dirname(REPORT), exist_ok=True)

now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

applied = sum(1 for _, s, _ in log_entries if s == "APPLIED")
skipped = sum(1 for _, s, _ in log_entries if s == "SKIPPED")
errors  = sum(1 for _, s, _ in log_entries if s == "ERROR")

report_lines = [
    f"# V4(3) Fixes Report",
    f"",
    f"**Date/Time:** {now}  ",
    f"**Source:** `1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (3).docx`  ",
    f"**Output:** `FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx`  ",
    f"",
    f"---",
    f"",
    f"## Fix Log",
    f"",
    f"| Fix ID | Status | Detail |",
    f"|--------|--------|--------|",
]

for fix_id, status, detail in log_entries:
    report_lines.append(f"| `{fix_id}` | **{status}** | {detail} |")

report_lines += [
    f"",
    f"---",
    f"",
    f"## Verification Results",
    f"",
    f"| Check | Result | Note |",
    f"|-------|--------|------|",
]

for label, status, expected in verifications:
    icon = "✅" if status == "PASS" else "❌"
    report_lines.append(f"| {label} | {icon} {status} | {expected} |")

passes = sum(1 for _, s, _ in verifications if s == "PASS")
fails  = sum(1 for _, s, _ in verifications if s == "FAIL")

report_lines += [
    f"",
    f"---",
    f"",
    f"## Summary",
    f"",
    f"| Metric | Count |",
    f"|--------|-------|",
    f"| Fixes Applied | {applied} |",
    f"| Fixes Skipped | {skipped} |",
    f"| Errors | {errors} |",
    f"| Verification PASS | {passes} |",
    f"| Verification FAIL | {fails} |",
    f"",
    f"**Script completed at {now}.**",
]

with open(REPORT, "w", encoding="utf-8") as f:
    f.write("\n".join(report_lines))

print(f"Report written to {REPORT}")
print(f"\n=== DONE: {applied} applied, {skipped} skipped, {errors} errors ===")
print(f"=== Verification: {passes} pass, {fails} fail ===")
