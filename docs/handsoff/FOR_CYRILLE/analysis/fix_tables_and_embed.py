#!/usr/bin/env python3
"""
Fix remaining issues found in audit:
1. Table 1.2: Change SmartSpend Paluwagan from 'No' to 'Yes' 
   (app text at para 335 confirms Paluwagan tracker was implemented)
2. Para 371: Replace 'Priority 9' with 'Recommendation 6' 
3. Embed SUS Distribution figure after Figure 3.11 SUS Computation Table (in results section)
4. Embed SUS Subgroup figure after Table 3.4
5. Embed Demographic Breakdown figure after Table 3.1
"""
import os, re
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

MANUSCRIPT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
FIGURES_DIR = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES"

DIST_IMG = os.path.join(FIGURES_DIR, 'Figure_SUS_Distribution.png')
SUBG_IMG = os.path.join(FIGURES_DIR, 'Figure_SUS_Subgroup.png')
DEMOG_IMG = os.path.join(FIGURES_DIR, 'Figure_Demographic_Breakdown.png')

doc = Document(MANUSCRIPT)
paras = doc.paragraphs

# ─── Fix 1: Table 1.2 Paluwagan ───────────────────────────────────────────────
print("=== Fix 1: Table 1.2 Paluwagan SmartSpend → Yes ===")
t12 = doc.tables[1]
for ri, row in enumerate(t12.rows):
    cells = row.cells
    if 'Paluwagan' in cells[0].text:
        ss_cell = cells[-1]  # SmartSpend is last column
        old_val = ss_cell.text.strip()
        if old_val == 'No':
            # Clear the cell and set to 'Yes'
            for para in ss_cell.paragraphs:
                for run in para.runs:
                    run.text = ''
            # Set first run or add new run
            if ss_cell.paragraphs[0].runs:
                ss_cell.paragraphs[0].runs[0].text = 'Yes'
            else:
                ss_cell.paragraphs[0].add_run('Yes')
            print(f"  ✓ Changed Paluwagan SmartSpend: No → Yes (row {ri})")
        else:
            print(f"  Already '{old_val}' for SmartSpend Paluwagan")
        break

# ─── Fix 2: Priority 9 → Recommendation 6 ─────────────────────────────────────
print("\n=== Fix 2: Replace 'Priority 9' with 'Recommendation 6' ===")
fixed_count = 0
for i, p in enumerate(paras):
    if 'Priority 9' in p.text:
        for run in p.runs:
            if 'Priority 9' in run.text:
                run.text = run.text.replace('Priority 9', 'Recommendation 6')
                print(f"  ✓ Para [{i}] fixed: Priority 9 → Recommendation 6")
                fixed_count += 1
        # If not found in runs, try the full paragraph text approach
        if fixed_count == 0 or 'Priority 9' in p.text:
            # The text might be split across runs; check full para
            full_text = p.text
            if 'Priority 9' in full_text:
                print(f"  ⚠ Para [{i}] still contains 'Priority 9' after run-level fix")
                print(f"    Full text: {full_text[:200]}")
                # Try rebuilding paragraph text
                # Collect all run text
                new_full = full_text.replace('Priority 9', 'Recommendation 6')
                # Clear runs and put in first run
                first_run = None
                for run in p.runs:
                    if first_run is None:
                        first_run = run
                    else:
                        run.text = ''
                if first_run:
                    first_run.text = new_full
                    print(f"  ✓ Para [{i}] rebuilt: Priority 9 → Recommendation 6")
                    fixed_count += 1

print(f"  Total 'Priority 9' fixes: {fixed_count}")

# ─── Fix 3: Embed new figures in manuscript ────────────────────────────────────
print("\n=== Fix 3: Embedding new figures ===")

def get_para_idx(doc, para_obj):
    for i, p in enumerate(doc.paragraphs):
        if p._p is para_obj._p:
            return i
    return -1

def insert_image_and_caption_after(doc, after_para_idx, img_path, caption_text, width_inches=5.0):
    """Insert an image paragraph + caption paragraph immediately after after_para_idx."""
    paras = doc.paragraphs
    after_p = paras[after_para_idx]
    after_p_xml = after_p._p
    
    # Create caption paragraph
    cap_p_xml = OxmlElement('w:p')
    cap_pPr = OxmlElement('w:pPr')
    cap_jc = OxmlElement('w:jc')
    cap_jc.set(qn('w:val'), 'center')
    cap_pPr.append(cap_jc)
    cap_r = OxmlElement('w:r')
    # Make caption italic like academic style
    cap_rPr = OxmlElement('w:rPr')
    cap_sz = OxmlElement('w:sz')
    cap_sz.set(qn('w:val'), '20')  # 10pt
    cap_rPr.append(cap_sz)
    cap_r.append(cap_rPr)
    cap_t = OxmlElement('w:t')
    cap_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    cap_t.text = caption_text
    cap_r.append(cap_t)
    cap_p_xml.append(cap_pPr)
    cap_p_xml.append(cap_r)
    
    # Create image paragraph
    img_p_xml = OxmlElement('w:p')
    img_pPr = OxmlElement('w:pPr')
    img_jc = OxmlElement('w:jc')
    img_jc.set(qn('w:val'), 'center')
    img_pPr.append(img_jc)
    img_p_xml.append(img_pPr)
    
    # Also add a blank spacer paragraph before
    spacer_p = OxmlElement('w:p')
    
    # Insert after the target paragraph: spacer, then image, then caption
    after_p_xml.addnext(cap_p_xml)
    after_p_xml.addnext(img_p_xml)
    after_p_xml.addnext(spacer_p)
    
    # Now find the image paragraph object and add image to it
    img_para_obj = None
    for p in doc.paragraphs:
        if p._p is img_p_xml:
            img_para_obj = p
            break
    
    if img_para_obj is None:
        print(f"  ERROR: Could not find inserted image paragraph")
        return False
    
    run = img_para_obj.add_run()
    run.add_picture(img_path, width=Inches(width_inches))
    img_para_obj.alignment = WD_ALIGN_PARAGRAPH.CENTER
    
    print(f"  ✓ Inserted {os.path.basename(img_path)} with caption: '{caption_text[:60]}...'")
    return True


# Find insertion points
# 3a. SUS Distribution: insert after Figure 3.11 caption (para 362) + some text
# Actually insert AFTER Table 3.3 results text and Table 3.4 caption
# Best place: after the Table 3.4 block (para ~366) and its associated analysis
# We'll insert after the last sentence discussing Table 3.4 results

# Find "Table 3.4" caption and surrounding text
t34_end_idx = None
for i, p in enumerate(paras):
    t = p.text.strip()
    if 'Table 3.4' in t and 'SUS' in t and 'Group' in t and i > 360:
        t34_end_idx = i
        print(f"  Found Table 3.4 caption at para {i}: {t[:80]}")
        break

# The table follows the caption; find the paragraph after the table
# Para 365 is Table 3.4 caption, table follows, then para 367 is next text
# Insert SUS Distribution figure after Table 3.4 discussion (para 367 area)
sus_discuss_idx = None
for i in range(360, min(380, len(paras))):
    t = paras[i].text.strip()
    if 'No formal open-ended' in t or ('Table 3.4' in t and i > 363) or ('discussed' in t and 'SUS' in t):
        sus_discuss_idx = i - 1
        print(f"  Inserting SUS distribution figures after para {sus_discuss_idx}: {paras[sus_discuss_idx].text.strip()[:80]}")
        break

if sus_discuss_idx is None:
    # Default: insert before Technical Performance Benchmarks
    for i, p in enumerate(paras):
        if 'Technical Performance' in p.text and i > 360:
            sus_discuss_idx = i - 1
            break

if sus_discuss_idx:
    # Insert SUS Distribution first
    insert_image_and_caption_after(
        doc, sus_discuss_idx,
        DIST_IMG,
        'Figure 3.12. SUS Score Distribution (N = 30). Individual scores sorted in ascending order. '
        'Zone coloring reflects Bangor et al. (2008) acceptability ranges. '
        'Mean = 61.83 (SD = 17.58); range 35.0–92.5.',
        width_inches=5.5
    )
    # Reload paras and insert subgroup figure (index shifts after insert)
    # Insert 3 paragraphs were added (spacer, img, caption)
    subg_insert_idx = sus_discuss_idx + 3
    insert_image_and_caption_after(
        doc, subg_insert_idx,
        SUBG_IMG,
        'Figure 3.13. SUS Scores by Respondent Group (N = 30). '
        'Parents (n = 10) scored M = 58.25 (SD = 19.72); Young Professionals (n = 20) scored M = 63.62 (SD = 16.65). '
        'Error bars represent ±1 SD; adjective ratings based on Bangor et al. (2009).',
        width_inches=5.0
    )
else:
    print("  WARNING: Could not find insertion point for SUS figures")

# 3b. Demographic Breakdown: insert after Table 3.1 caption + table
# Table 3.1 caption is at para ~334 (in body, not list of figures section)
t31_body_idx = None
for i, p in enumerate(paras):
    t = p.text.strip()
    if 'Table 3.1' in t and 'Demographic' in t and 'Respondents' in t and i > 300:
        t31_body_idx = i
        print(f"  Found Table 3.1 body caption at para {i}: {t[:80]}")
        break

if t31_body_idx:
    # The table follows; insert demographic figure after Table 3.1 + 1 para
    # Find next paragraph after the table (look for non-empty para after table)
    demog_insert_idx = t31_body_idx + 2  # Caption + table + insert here
    # Search a few paragraphs ahead for good insert point
    for j in range(t31_body_idx + 1, min(t31_body_idx + 10, len(paras))):
        t = paras[j].text.strip()
        if t and not t.startswith('Table') and 'expense' in t.lower():
            demog_insert_idx = j - 1
            break
    
    print(f"  Inserting demographic figure after para {demog_insert_idx}")
    insert_image_and_caption_after(
        doc, demog_insert_idx,
        DEMOG_IMG,
        'Figure 3.14. Demographic Distribution of Needs-Assessment Respondents (N = 30). '
        '† The 3 respondents who identified as both parent and young professional were reclassified '
        'by primary financial role for SUS subgroup analysis, yielding 10 parents and 20 young professionals.',
        width_inches=5.0
    )
else:
    print("  WARNING: Could not find Table 3.1 body caption for demographic figure insertion")

# ─── Save ──────────────────────────────────────────────────────────────────────
doc.save(MANUSCRIPT)
print(f"\n✓ Manuscript saved: {MANUSCRIPT}")
print("\n=== All fixes applied ===")
