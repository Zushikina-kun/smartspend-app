"""
Fix Slide 11 in SmartSpend_Defense.pptx
Replace N=5 individual scores with N=30 aggregate range
"""
from pptx import Presentation
import os

pptx_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
backup_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\SmartSpend_Defense_BACKUP_before_slide11_fix.pptx'

# Create backup before modifying
print(f"Creating backup: {backup_path}")
import shutil
shutil.copy2(pptx_path, backup_path)

# Load presentation
print(f"Loading presentation: {pptx_path}")
prs = Presentation(pptx_path)

# Slide 11 is index 10 (0-indexed)
slide = prs.slides[10]
print(f"Processing Slide 11 (index 10)")

fixed = False
for shape in slide.shapes:
    if not hasattr(shape, 'text_frame'):
        continue
    
    text = shape.text
    
    # Look for the problematic text with N=5 individual scores
    if 'Individual scores:' in text or '60.0, 55.0, 55.0, 75.0, 67.5' in text:
        print(f"Found target shape with text containing individual scores")
        
        # Replace the text
        for paragraph in shape.text_frame.paragraphs:
            for run in paragraph.runs:
                if '60.0, 55.0' in run.text or 'Individual scores:' in run.text:
                    old_text = run.text
                    run.text = 'Individual scores range: 35.0–92.5 (N=30, Final)'
                    print(f"  Replaced: '{old_text[:50]}...' -> '{run.text}'")
                    fixed = True
                    break
            if fixed:
                break
    
    # Also look for the range notation "Range: 55.0–75.0"
    if 'Range:' in text and '55.0' in text:
        print(f"Found Range text")
        for paragraph in shape.text_frame.paragraphs:
            for run in paragraph.runs:
                if 'Range:' in run.text or '55.0–75.0' in run.text:
                    old_text = run.text
                    run.text = 'Range: 35.0–92.5 (N=30)'
                    print(f"  Replaced: '{old_text}' -> '{run.text}'")
                    fixed = True
                    break

if fixed:
    print(f"Saving modified presentation to: {pptx_path}")
    prs.save(pptx_path)
    print("✅ Slide 11 fixed successfully!")
else:
    print("⚠️ Warning: Could not find the specific text to replace")
    print("Manual inspection may be needed")

print("\nDone!")
