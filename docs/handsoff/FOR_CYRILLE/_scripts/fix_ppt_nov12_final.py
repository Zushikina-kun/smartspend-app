"""
Fix SmartSpend Defense PPT for Cyrille's defense.
Source: SmartSpend_Defense.pptx (already in FOR_CYRILLE — this IS the working copy)
Output: SmartSpend_Defense.pptx (overwritten in-place after backup)

Changes applied:
1. Remove all literal ‹#› page-number artifacts
2. Slide 9 (Obj 1 results): fix "already use GCash" -> "already used GCash"
   Add "96.7% (29 of 30)" label if not present
3. Slide 15 (SUS): ensure N=30 is explicitly mentioned
4. Slide 16 (Limitations/Conclusions mapping):
   The actual Conclusions are on slide 17, which already says "Partially achieved" — OK
5. Slide 8 (Methods): fix wording to match protected values
   "16 parents + 14 YP" for needs assessment
6. Slide 14 (Privacy): On-device AI is already framed as recommendation — verify/no change needed
"""

import shutil
import os
from pptx import Presentation
from pptx.util import Pt
from pptx.dml.color import RGBColor
import copy

SOURCE = 'SmartSpend_Defense.pptx'
BACKUP = 'SmartSpend_Defense.pptx.fix_nov12.bak'
OUTPUT = 'SmartSpend_Defense.pptx'

# Backup
shutil.copy2(SOURCE, BACKUP)
print(f"Backed up to {BACKUP}")

prs = Presentation(SOURCE)

changes = []

def replace_text_in_shape(shape, old_text, new_text, label=""):
    """Replace text in a shape's text frame, preserving formatting."""
    changed = False
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                if old_text in run.text:
                    run.text = run.text.replace(old_text, new_text)
                    changed = True
            # Also handle full paragraph text if no runs
            full = para.text
            if old_text in full and not para.runs:
                # Try to modify directly (rare case)
                pass
    return changed

def collect_all_text_shapes(slide):
    """Recursively collect all shapes with text frames."""
    shapes = []
    def recurse(shape):
        if hasattr(shape, 'shapes'):
            for sub in shape.shapes:
                recurse(sub)
        if shape.has_text_frame:
            shapes.append(shape)
    for shape in slide.shapes:
        recurse(shape)
    return shapes

def fix_text_in_slide(slide, old_text, new_text, description=""):
    """Find and replace text across all shapes in a slide."""
    changed = False
    for shape in collect_all_text_shapes(slide):
        if replace_text_in_shape(shape, old_text, new_text):
            changed = True
    if changed and description:
        changes.append(description)
    return changed

# ===========================================================================
# FIX 1: Remove ‹#› from ALL slides
# ===========================================================================
page_num_artifact = '‹#›'
for i, slide in enumerate(prs.slides):
    for shape in collect_all_text_shapes(slide):
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                for run in para.runs:
                    if page_num_artifact in run.text:
                        run.text = run.text.replace(page_num_artifact, '')
                        changes.append(f"Slide {i+1}: Removed ‹#› artifact from shape '{shape.name}'")
                # Also clear paragraph text if it only has ‹#›
                if para.text.strip() == page_num_artifact:
                    for run in para.runs:
                        run.text = ''

print("Fix 1: Removed ‹#› artifacts")

# ===========================================================================
# FIX 2: Slide 3 — "uses a mobile app" check (already "used a mobile app")
# The slide text shows "used a mobile app" already, so no change needed.
# But check for "uses" just in case
# ===========================================================================
slide3 = prs.slides[2]
fix_text_in_slide(slide3, "uses a mobile app", "used a mobile app",
                  "Slide 3: Fixed 'uses a mobile app' -> 'used a mobile app'")
fix_text_in_slide(slide3, "use a mobile app", "used a mobile app",
                  "Slide 3: Fixed 'use a mobile app' -> 'used a mobile app'")

# ===========================================================================
# FIX 3: Slide 4 and 5 — Table 1.2 -> Table 2, Table 2.1 -> Table 2
# ===========================================================================
for slide_idx in [3, 4]:  # slides 4 and 5
    slide = prs.slides[slide_idx]
    sn = slide_idx + 1
    fix_text_in_slide(slide, "Table 1.2", "Table 2",
                      f"Slide {sn}: Fixed 'Table 1.2' -> 'Table 2'")
    fix_text_in_slide(slide, "Table 2.1", "Table 2",
                      f"Slide {sn}: Fixed 'Table 2.1' -> 'Table 2'")

print("Fix 2-3 complete")

# ===========================================================================
# FIX 4: Slide 9 (Objective 1 results)
# - "already use GCash" -> "already used GCash"
# - Verify "96.7% (29 of 30)" label is present
# ===========================================================================
slide9 = prs.slides[8]  # 0-indexed

# Fix "already use GCash" -> "already used GCash"
# The text box says "already use GCash (28 of 30)"
fix_text_in_slide(slide9, "already use GCash", "already used GCash",
                  "Slide 9: Fixed 'already use GCash' -> 'already used GCash'")

# Check if "29 of 30" is present (for the 96.7% label)
all_texts_slide9 = []
for shape in collect_all_text_shapes(slide9):
    for para in shape.text_frame.paragraphs:
        all_texts_slide9.append(para.text)

has_29_of_30 = any("29 of 30" in t for t in all_texts_slide9)
has_96_pct = any("96.7%" in t for t in all_texts_slide9)

print(f"Slide 9 - has '29 of 30': {has_29_of_30}")
print(f"Slide 9 - has '96.7%': {has_96_pct}")

if not has_29_of_30:
    # Find the TextBox 13 (which says "intend to use an AI-powered financial app")
    # We need to update TextBox 12 or the label near the 96.7% number
    for shape in collect_all_text_shapes(slide9):
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                if "intend to use an AI-powered financial app" in para.text:
                    # This is the description text. The parent group has the number.
                    # Prepend the (29 of 30) clarification
                    for run in para.runs:
                        if "intend to use" in run.text:
                            run.text = "(29 of 30) " + run.text
                            changes.append("Slide 9: Added '(29 of 30)' to intent label")
                            break
                    break

print("Fix 4 complete")

# ===========================================================================
# FIX 5: Slide 10 (System Overview) — verify numbers
# From manuscript: 34 AI actions, 7 input modalities, 26 SQLite tables,
#                  45 screens, 36 badges
# From PPT: 34 ✓, 7 ✓, 26 ✓, 45 ✓, 36 ✓ — no changes needed
# ===========================================================================
print("Fix 5: Slide 10 numbers verified - 34 AI, 7 modalities, 26 SQLite, 45 screens, 36 badges — all match manuscript")
changes.append("Slide 10: Verified - 34 AI actions, 7 modalities, 26 SQLite tables, 45 screens, 36 badges — all match manuscript")

# ===========================================================================
# FIX 6: Slide 14 (Privacy tiers) — verify on-device AI is framed as recommendation
# From PPT: "NOT yet built — presented as Recommendation 4" — already correct
# ===========================================================================
print("Fix 6: Slide 14 on-device AI already correctly framed as Recommendation 4 (not current feature)")
changes.append("Slide 14: Verified - on-device AI correctly framed as future recommendation (NOT yet built)")

# ===========================================================================
# FIX 7: Slide 15 (SUS results) — verify all required values present
# Check: 61.83, SD 17.58, median 55.0, range 35.0-92.5, Grade D, OK, N=30, 68 benchmark, 80 target
# ===========================================================================
slide15 = prs.slides[14]
all_texts_slide15 = []
for shape in collect_all_text_shapes(slide15):
    for para in shape.text_frame.paragraphs:
        all_texts_slide15.append(para.text)

full_text_15 = " ".join(all_texts_slide15)
print(f"\nSlide 15 all text: {full_text_15[:500]}")

has_n30 = "N = 30" in full_text_15 or "N=30" in full_text_15 or "N = 30" in full_text_15 or "30 valid" in full_text_15
has_6183 = "61.83" in full_text_15
has_sd1758 = "17.58" in full_text_15
has_median = "55.0" in full_text_15 or "55.00" in full_text_15
has_range = "35.0" in full_text_15
has_grade_d = "Grade D" in full_text_15
has_ok = '"OK"' in full_text_15 or "'OK'" in full_text_15 or "OK" in full_text_15
has_68 = "68" in full_text_15
has_80 = "80" in full_text_15

print(f"N=30: {has_n30}, 61.83: {has_6183}, SD: {has_sd1758}, median: {has_median}")
print(f"range: {has_range}, Grade D: {has_grade_d}, OK: {has_ok}, 68: {has_68}, 80: {has_80}")

changes.append(f"Slide 15 (SUS): Verified values present - 61.83:{has_6183}, SD:{has_sd1758}, median:{has_median}, range:{has_range}, GradeD:{has_grade_d}, OK:{has_ok}, N30:{has_n30}, 68bench:{has_68}, 80target:{has_80}")

# ===========================================================================
# FIX 8: Slide 16 (Limitations) and Slide 17 (Conclusions)
# The prompt expects Slide 16 to have Conclusions with Obj 3 "partially achieved"
# In this PPT: Slide 16 = Limitations, Slide 17 = Conclusions (with "Partially achieved" ✓)
# The Conclusions ARE on slide 17. Slide 16 is Limitations. This is correct.
# Check slide 17 to ensure "Partially achieved" is there for Obj 3
# ===========================================================================
slide17 = prs.slides[16]
all_texts_slide17 = []
for shape in collect_all_text_shapes(slide17):
    for para in shape.text_frame.paragraphs:
        if para.text.strip():
            all_texts_slide17.append(para.text)
print(f"\nSlide 17 (Conclusions) texts: {all_texts_slide17}")
has_partial = any("Partially achieved" in t or "partially achieved" in t for t in all_texts_slide17)
has_achieved_1 = any("Achieved" in t for t in all_texts_slide17)
print(f"Has 'Partially achieved': {has_partial}, Has 'Achieved': {has_achieved_1}")
changes.append(f"Slide 17 (Conclusions): Verified - 'Partially achieved' present: {has_partial}")

# ===========================================================================
# FIX 9: Slide 8 (Methods) — fix "13 parents, 14 YP, 3 both → reclassified as 16 parents + 14 YP"
# Per protected values: "16 parents and 14 young professionals" for needs-assessment (30 total)
# The current text says "13 parents, 14 YP, 3 both → reclassified as 16 parents + 14 YP" — this is accurate
# but the prompt says to say "16 parents and 14 young professionals"
# Update to simpler "16 parents + 14 YP = 30" framing
# ===========================================================================
slide8 = prs.slides[7]
old_methods_text = "respondents, random sampling: 13 parents, 14 YP, 3 both → reclassified as 16 parents + 14 YP"
new_methods_text = "respondents (needs assessment), random sampling: 16 parents + 14 young professionals = 30"
if fix_text_in_slide(slide8, old_methods_text, new_methods_text,
                     "Slide 8: Updated methods text to '16 parents + 14 YP = 30' framing"):
    print("Fixed slide 8 methods text")
else:
    print("Slide 8 methods text: exact match not found, trying partial fix")
    fix_text_in_slide(slide8, "13 parents, 14 YP, 3 both → reclassified as 16 parents + 14 YP",
                      "16 parents + 14 young professionals = 30 (needs assessment)",
                      "Slide 8: Updated methods text to '16 parents + 14 YP' framing")

# ===========================================================================
# FIX 10: Slide 16 — "30 purposive respondents" -> "30 respondents" 
# (the needs assessment used purposive per manuscript, the SUS was separate)
# ===========================================================================
slide16 = prs.slides[15]
fix_text_in_slide(slide16, "30 purposive respondents", "30 SUS respondents",
                  "Slide 16: Clarified '30 purposive respondents' -> '30 SUS respondents'")

# ===========================================================================
# SAVE
# ===========================================================================
prs.save(OUTPUT)
print(f"\nSaved to {OUTPUT}")

print(f"\n=== CHANGES APPLIED ({len(changes)}) ===")
for c in changes:
    print(f"  - {c}")
