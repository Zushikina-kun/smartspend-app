"""
Additional fixes after first pass:
1. Slide 17 Conclusions: "93.3% use GCash" -> "93.3% used GCash" (past tense, match manuscript)
2. Slide 17 Conclusions: LLM name "Gemini 3.5 Flash-Lite" -> "Gemini 1.5 Flash-Lite" (manuscript says 1.5)
3. Verify the save was clean
"""
from pptx import Presentation

SOURCE = 'SmartSpend_Defense.pptx'

prs = Presentation(SOURCE)
changes = []

def collect_all_text_shapes(slide):
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
    changed = False
    for shape in collect_all_text_shapes(slide):
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                for run in para.runs:
                    if old_text in run.text:
                        run.text = run.text.replace(old_text, new_text)
                        changed = True
    if changed and description:
        changes.append(description)
    return changed

# Fix all slides for GCash tense
for i, slide in enumerate(prs.slides):
    # "already use GCash" -> "already used GCash" (past tense)
    fix_text_in_slide(slide, "already use GCash", "already used GCash",
                      f"Slide {i+1}: Fixed 'already use GCash' -> 'already used GCash'")
    # "93.3% use GCash" -> "93.3% used GCash"
    fix_text_in_slide(slide, "93.3% use GCash", "93.3% used GCash",
                      f"Slide {i+1}: Fixed '93.3% use GCash' -> '93.3% used GCash'")
    # Fix LLM name
    fix_text_in_slide(slide, "Gemini 3.5 Flash-Lite", "Gemini 1.5 Flash-Lite",
                      f"Slide {i+1}: Fixed 'Gemini 3.5 Flash-Lite' -> 'Gemini 1.5 Flash-Lite'")
    fix_text_in_slide(slide, "Gemini 3.5", "Gemini 1.5",
                      f"Slide {i+1}: Fixed 'Gemini 3.5' -> 'Gemini 1.5'")

prs.save(SOURCE)
print(f"Saved to {SOURCE}")
print(f"\nChanges ({len(changes)}):")
for c in changes:
    print(f"  - {c}")

# Quick verification
prs2 = Presentation(SOURCE)
print(f"\nVerification: Slide count = {len(prs2.slides)}")
# Check slide 17 conclusions text
slide17 = prs2.slides[16]
for shape in collect_all_text_shapes(slide17):
    for para in shape.text_frame.paragraphs:
        if para.text.strip():
            print(f"  Slide17: {para.text!r}")
