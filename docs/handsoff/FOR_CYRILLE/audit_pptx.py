"""Audit PPTX presentation for image placement and layout issues"""
from pptx import Presentation
import os

pptx_path = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\3_PRESENTATION.pptx"

if not os.path.exists(pptx_path):
    print(f"ERROR: File not found: {pptx_path}")
    exit(1)

prs = Presentation(pptx_path)

print(f"Total slides: {len(prs.slides)}\n")
print("="*80)

for idx, slide in enumerate(prs.slides, 1):
    print(f"\nSLIDE {idx}")
    print("-" * 80)
    
    # Get slide title if available
    if slide.shapes.title:
        print(f"Title: {slide.shapes.title.text}")
    
    # Count and list images
    images = []
    text_boxes = []
    
    for shape in slide.shapes:
        if shape.shape_type == 13:  # Picture
            images.append(shape)
            print(f"  📷 IMAGE found:")
            print(f"     - Position: ({shape.left}, {shape.top})")
            print(f"     - Size: {shape.width} x {shape.height}")
            if hasattr(shape, 'image'):
                print(f"     - Image type: {shape.image.content_type}")
        elif hasattr(shape, "text") and shape.text.strip():
            text_boxes.append(shape)
    
    print(f"  Total images on slide: {len(images)}")
    print(f"  Total text boxes on slide: {len(text_boxes)}")
    
    # Check for potential layout issues
    if len(images) > 2:
        print(f"  ⚠️  WARNING: {len(images)} images on one slide - may be crowded")
    
    # Check if images overlap with text (basic check)
    for img in images:
        for txt in text_boxes:
            # Simple overlap check
            if (img.left < txt.left + txt.width and 
                img.left + img.width > txt.left and
                img.top < txt.top + txt.height and
                img.top + img.height > txt.top):
                print(f"  ⚠️  POTENTIAL OVERLAP between image and text box")
                break

print("\n" + "="*80)
print("Audit complete!")
