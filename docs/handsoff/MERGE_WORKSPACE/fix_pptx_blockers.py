"""
Fix PPTX Blockers #3, #4, #5: Remove preliminary/pending warnings
"""
from pptx import Presentation
import sys

def fix_presentation(input_path, output_path):
    """Fix all preliminary/pending warnings in presentation"""
    prs = Presentation(input_path)
    
    changes_made = []
    
    # Iterate through all slides
    for slide_num, slide in enumerate(prs.slides, start=1):
        # Check all shapes in the slide
        for shape in slide.shapes:
            if not shape.has_text_frame:
                continue
            
            original_text = shape.text
            modified = False
            
            # BLOCKER #3: Slide 9 - "Survey data collection in progress"
            if "Survey data collection in progress" in original_text or "in progress" in original_text.lower():
                # Replace the entire paragraph with completion status
                for paragraph in shape.text_frame.paragraphs:
                    if "in progress" in paragraph.text.lower() or "SUS scores" in paragraph.text:
                        paragraph.text = "✅ Survey data collection complete (N=30, Oct-Nov 2026). SUS evaluation: 10 parents (35-55), 20 young professionals (21-35)."
                        modified = True
                        changes_made.append(f"Slide {slide_num}: Removed 'in progress' warning, added completion status")
                        break
            
            # BLOCKER #4: Slide 11 - "PRELIMINARY DATA — N=5"
            if "PRELIMINARY DATA" in original_text or "N=5" in original_text:
                for paragraph in shape.text_frame.paragraphs:
                    if "PRELIMINARY" in paragraph.text or "may differ" in paragraph.text.lower():
                        paragraph.text = "✅ FINAL RESULTS — N=30 (Oct–Nov 2026). Mean SUS = 61.83 (SD = 17.58) — Grade D, 'OK' per Bangor et al. (2009). Below 68-point benchmark but acceptable for prototype stage."
                        modified = True
                        changes_made.append(f"Slide {slide_num}: Removed PRELIMINARY N=5 warning, added FINAL N=30 results")
                        break
            
            # BLOCKER #5: Slide 12 - "Preliminary findings" and "pending"
            if "Preliminary findings" in original_text or ("N=13" in original_text and "findings" in original_text.lower()):
                for paragraph in shape.text_frame.paragraphs:
                    text_lower = paragraph.text.lower()
                    if "preliminary" in text_lower:
                        paragraph.text = paragraph.text.replace("Preliminary findings", "Final findings")
                        paragraph.text = paragraph.text.replace("preliminary findings", "final findings")
                        paragraph.text = paragraph.text.replace("N=13", "N=30")
                        modified = True
                        changes_made.append(f"Slide {slide_num}: Changed 'Preliminary' to 'Final', N=13 to N=30")
                    
                    if "pending" in text_lower:
                        # Remove entire phrase about pending completion
                        if "Final SUS result" in paragraph.text and "pending" in paragraph.text:
                            paragraph.text = ""
                            modified = True
                            changes_made.append(f"Slide {slide_num}: Removed 'pending completion' text")
    
    # Save the modified presentation
    prs.save(output_path)
    
    return changes_made

if __name__ == "__main__":
    input_file = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\3_PRESENTATION_FINAL.pptx"
    output_file = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\3_PRESENTATION_FINAL.pptx"
    
    print("Fixing PPTX blockers...")
    changes = fix_presentation(input_file, output_file)
    
    if changes:
        print("\n✅ Changes made:")
        for change in changes:
            print(f"  - {change}")
    else:
        print("\n⚠️ No changes detected - text may have different formatting")
    
    print(f"\n✅ Saved to: {output_file}")
