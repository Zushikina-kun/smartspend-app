"""
fix_new_ppt.py
Applies all required corrections to SMARTSPEND PPT.pptx (19 slides)
and saves to FOR_CYRILLE/SmartSpend_Defense.pptx.

Changes made:
- Slide 1: Fix date to Nov 16, 2026 3:00 PM; fix adviser full name; add panel names
- Slide 3: Fix "use" → "used" (past tense)
- Slide 5: Fix "Table 1.2" → "Table 2"
- Slide 6: Fix objective wording to match Maam Ellen short form; ensure research design correct
- Slide 8: Fix "Mixed methods" → "quantitative descriptive developmental"; fix population/sampling text
- Slide 11: Add figure number labels (Figure 9–13) to screenshot captions
- Slide 14: Fix on-device AI description to clearly state FUTURE WORK / Recommendation
- Slide 17: Conclusions - no changes needed (already correct)
- Slide 19: Fix adviser name to "Ellen Flores Mangaoang, DIT"
"""

import shutil, re
from pptx import Presentation
from pptx.util import Pt
from lxml import etree

SRC = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\SMARTSPEND PPT.pptx'
DST = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'

shutil.copy2(SRC, DST)
prs = Presentation(DST)

NSMAP = {
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
    'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
}


def find_shape_by_name(slide, name):
    for shape in slide.shapes:
        if shape.name == name:
            return shape
    return None


def set_text_in_shape(shape, new_text, preserve_format=True):
    """Replace all text in a shape's text frame with new_text, preserving first run format."""
    if not shape.has_text_frame:
        return
    tf = shape.text_frame
    # Clear all paragraphs except first, then set text
    while len(tf.paragraphs) > 1:
        p = tf.paragraphs[-1]._p
        p.getparent().remove(p)
    para = tf.paragraphs[0]
    # Preserve runs if any, else just set
    if para.runs:
        run = para.runs[0]
        run.text = new_text
        # Remove extra runs
        for extra_run in para.runs[1:]:
            extra_run._r.getparent().remove(extra_run._r)
    else:
        from pptx.util import Pt
        run = para.add_run()
        run.text = new_text


def add_text_line(shape, new_text):
    """Add a new paragraph with new_text to shape's text frame."""
    if not shape.has_text_frame:
        return
    tf = shape.text_frame
    p = tf.add_paragraph()
    run = p.add_run()
    run.text = new_text


def find_textbox_containing(slide, search_text):
    """Find a textbox shape containing the given search text."""
    for shape in slide.shapes:
        if shape.has_text_frame:
            full = shape.text_frame.text
            if search_text in full:
                return shape
    return None


def find_group_containing(slide, search_text):
    """Find a group shape that contains a text shape with search_text."""
    def search_shape(s, text):
        if hasattr(s, 'has_text_frame') and s.has_text_frame:
            if text in s.text_frame.text:
                return True
        if s.shape_type == 6:  # GROUP
            for child in s.shapes:
                if search_shape(child, text):
                    return True
        return False

    for shape in slide.shapes:
        if search_shape(shape, search_text):
            return shape
    return None


def replace_text_in_shape_tree(shape, old_text, new_text):
    """Recursively replace text in all text frames within a shape (including groups)."""
    if hasattr(shape, 'has_text_frame') and shape.has_text_frame:
        tf = shape.text_frame
        for para in tf.paragraphs:
            for run in para.runs:
                if old_text in run.text:
                    run.text = run.text.replace(old_text, new_text)
    if shape.shape_type == 6:  # GROUP
        for child in shape.shapes:
            replace_text_in_shape_tree(child, old_text, new_text)


def replace_text_in_slide(slide, old_text, new_text):
    """Replace text across all shapes in a slide."""
    for shape in slide.shapes:
        replace_text_in_shape_tree(shape, old_text, new_text)


# =====================================================================
# SLIDE 1: Title slide
# =====================================================================
slide1 = prs.slides[0]

# Fix date - change "November 2026" to "November 16, 2026 | 3:00 PM"
replace_text_in_slide(slide1, 'November 2026', 'November 16, 2026  |  3:00 PM')

# Fix adviser full name: "Ellen F. Mangaoang" → "Ellen Flores Mangaoang"
replace_text_in_slide(slide1, 'Ellen F. Mangaoang', 'Ellen Flores Mangaoang')

# Add panel names to the adviser textbox (TextBox 16)
adviser_box = find_shape_by_name(slide1, 'TextBox 16')
if adviser_box and adviser_box.has_text_frame:
    tf = adviser_box.text_frame
    # Check if panel names are already there
    full_text = tf.text
    if 'Layco' not in full_text:
        # Add panel members as new paragraph(s)
        p = tf.add_paragraph()
        run = p.add_run()
        run.text = 'Panel: Jeoffrey B. Layco MIS (Chair)  |  Shekiro R. Raposas MTS/MIS  |  Mary-Ann Mzana MTS'
        # Try to match font size of existing text
        if tf.paragraphs[0].runs:
            existing_font = tf.paragraphs[0].runs[0].font
            if existing_font.size:
                run.font.size = existing_font.size

print("Slide 1: Fixed date, adviser name, added panel.")

# =====================================================================
# SLIDE 3: Problem / Background
# =====================================================================
slide3 = prs.slides[2]

# Fix "use" → "used" (past tense) in the 10% stat label
replace_text_in_slide(slide3, 'of our 30 respondents use a mobile app to track expenses',
                               'of our 30 respondents used a mobile app to track expenses')

print("Slide 3: Fixed 'use' → 'used'.")

# =====================================================================
# SLIDE 5: Feature comparison table (Table reference)
# =====================================================================
slide5 = prs.slides[4]

# Fix "Table 1.2" → "Table 2"
replace_text_in_slide(slide5, 'Table 1.2', 'Table 2')

print("Slide 5: Fixed Table 1.2 → Table 2.")

# =====================================================================
# SLIDE 6: Objectives
# =====================================================================
slide6 = prs.slides[5]

# Fix objective 3 wording (remove "user feedback" per Maam Ellen's instruction to use SUS only)
replace_text_in_slide(slide6, 
    'Usability and performance using the System Usability Scale (SUS) and user feedback.',
    'Usability of the developed system using the System Usability Scale (SUS).')

print("Slide 6: Fixed Objective 3 wording.")

# =====================================================================
# SLIDE 8: Methods
# =====================================================================
slide8 = prs.slides[7]

# Fix "Mixed methods, built with Agile Kanban" title → "Quantitative descriptive developmental, Agile Kanban"
replace_text_in_slide(slide8, 
    'Mixed methods, built with Agile Kanban',
    'Quantitative descriptive developmental, built with Agile Kanban')

# Fix population description: "purposive sampling: 13 parents, 14 young professionals, 3 both"
# → "random sampling: 13 parents, 14 young professionals, 3 both (reclassified: 16 parents, 14 YP)"
replace_text_in_slide(slide8,
    'respondents, purposive sampling: 13 parents, 14 young professionals, 3 both',
    'respondents, random sampling: 13 parents, 14 YP, 3 both → reclassified as 16 parents + 14 YP')

print("Slide 8: Fixed research design and population/sampling text.")

# =====================================================================
# SLIDE 11: Screenshot captions — add Figure numbers
# =====================================================================
slide11 = prs.slides[10]

# Update captions to include figure numbers (continuous numbering)
replace_text_in_slide(slide11, 'Login and Demo Mode', 'Figure 9. Login and Demo Mode')
replace_text_in_slide(slide11, 'Home and Health Score', 'Figure 10. Home Dashboard')
replace_text_in_slide(slide11, 'Taglish chat with Peso', 'Figure 11. Expense Logging Through Peso Chat')
replace_text_in_slide(slide11, 'Receipt scanning (OCR)', 'Figure 12. Receipt Scanning and Batch Screenshot Import')
replace_text_in_slide(slide11, 'Batch screenshot import', 'Figure 13. Financial Health Score Breakdown')

print("Slide 11: Updated screenshot captions with continuous figure numbers.")

# =====================================================================
# SLIDE 14: Privacy — On-device AI (Tier 3) label fix
# =====================================================================
slide14 = prs.slides[13]

# Fix tier 3 description to emphasize it's future work / recommendation
replace_text_in_slide(slide14,
    'A model running on the phone itself, with no network. Feasible on 2026 flagships, not yet on 4 GB mid-range phones.',
    'A model running on the phone itself, with no network required. NOT yet built — presented as Recommendation 4. Most target-user devices lack the RAM to run a 2.6 GB model.')

print("Slide 14: Updated on-device AI tier 3 to clearly show FUTURE WORK.")

# =====================================================================
# SLIDE 15: SUS Results — ensure benchmark mention is present
# =====================================================================
slide15 = prs.slides[14]

# The slide already shows 61.83 and Grade D — just verify "68 benchmark" language is accessible
# The slide has "Mean SUS score (N = 30 valid of 36 responses)" label
# Add a note about the 68 benchmark in the detail box if not present
detail_box = find_shape_by_name(slide15, 'TextBox 13')
if detail_box and detail_box.has_text_frame:
    full = detail_box.text_frame.text
    if '68' not in full:
        # Add benchmark line
        p = detail_box.text_frame.add_paragraph()
        r = p.add_run()
        r.text = 'Below 68 avg. benchmark (Sauro & Lewis) and 80 target'

print("Slide 15: Ensured SUS benchmark language present.")

# =====================================================================
# SLIDE 17: Conclusions — ensure correct Objective format
# =====================================================================
slide17 = prs.slides[16]

# Fix "Gemini 3.5 Flash-Lite with failover" if any old naming
replace_text_in_slide(slide17, 'Gemini Flash-Lite', 'Gemini 3.5 Flash-Lite')

print("Slide 17: Conclusions slide verified.")

# =====================================================================
# SLIDE 19: Closing slide — fix adviser name
# =====================================================================
slide19 = prs.slides[18]

replace_text_in_slide(slide19, 'Ellen F. Mangaoang', 'Ellen Flores Mangaoang')

print("Slide 19: Fixed adviser name.")

# =====================================================================
# GLOBAL: Fix any remaining old figure/table references and adviser name
# =====================================================================
for slide in prs.slides:
    # Fix any remaining "Ellen F. Mangaoang" → "Ellen Flores Mangaoang"
    replace_text_in_slide(slide, 'Ellen F. Mangaoang', 'Ellen Flores Mangaoang')
    # Fix any remaining "Table 1.2" → "Table 2"
    replace_text_in_slide(slide, 'Table 1.2', 'Table 2')
    replace_text_in_slide(slide, 'Table 2.1', 'Table 2')
    # Fix any "mixed methods" language (case insensitive handled by exact match)
    replace_text_in_slide(slide, 'mixed methods', 'quantitative descriptive developmental')
    replace_text_in_slide(slide, 'Mixed methods', 'Quantitative descriptive developmental')

print("Global: Applied global text fixes.")

# =====================================================================
# SAVE
# =====================================================================
prs.save(DST)
print(f"\nSaved to: {DST}")
print("PPT fix script complete.")
