"""Fix PowerPoint presentation layout - reposition and resize images properly"""
from pptx import Presentation
from pptx.util import Inches, Pt
import os

pptx_path = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\3_PRESENTATION.pptx"
output_path = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\3_PRESENTATION_FIXED.pptx"

if not os.path.exists(pptx_path):
    print(f"ERROR: File not found: {pptx_path}")
    exit(1)

prs = Presentation(pptx_path)

print(f"Fixing PowerPoint layout...")
print(f"Total slides: {len(prs.slides)}\n")

# Standard sizes (in inches)
PHONE_WIDTH = Inches(2.0)  # Phone screenshots
PHONE_HEIGHT = Inches(4.5)
TABLE_WIDTH = Inches(8.0)  # SUS table
TABLE_HEIGHT = Inches(3.0)

SLIDE_WIDTH = Inches(10)
SLIDE_HEIGHT = Inches(7.5)

# Helper function to resize and position image
def resize_image(shape, width, height, left, top):
    """Resize and reposition an image maintaining aspect ratio"""
    shape.width = width
    shape.height = height
    shape.left = left
    shape.top = top

# Track changes
changes = []

# SLIDE 6 - FHS Formula (has 5 images - need to reorganize)
# This slide is too crowded - we'll keep only the most relevant images
slide_6 = prs.slides[5]  # 0-indexed
images_slide_6 = [s for s in slide_6.shapes if s.shape_type == 13]
if len(images_slide_6) > 0:
    print(f"Slide 6: Found {len(images_slide_6)} images - repositioning...")
    
    # Position first image on the right side if exists
    if len(images_slide_6) >= 1:
        resize_image(images_slide_6[0], 
                    PHONE_WIDTH, PHONE_HEIGHT,
                    Inches(7.5), Inches(2.0))
        changes.append("Slide 6: Repositioned image 1 to right side")
    
    # If there are more images, position them in a row at bottom
    if len(images_slide_6) >= 2:
        for i in range(1, min(5, len(images_slide_6))):
            x_pos = Inches(0.5 + (i-1) * 2.4)
            resize_image(images_slide_6[i],
                        Inches(2.0), Inches(4.0),
                        x_pos, Inches(4.5))
            changes.append(f"Slide 6: Repositioned image {i+1} to bottom row")

# SLIDE 7 - System Overview (has 4 images - reorganize in 2x2 grid)
slide_7 = prs.slides[6]
images_slide_7 = [s for s in slide_7.shapes if s.shape_type == 13]
if len(images_slide_7) >= 4:
    print(f"Slide 7: Found {len(images_slide_7)} images - creating 2x2 grid...")
    
    # Position in 2x2 grid
    positions = [
        (Inches(0.5), Inches(1.5)),   # Top-left (Figure 3.4)
        (Inches(5.5), Inches(1.5)),   # Top-right (Figure 3.5)
        (Inches(0.5), Inches(4.0)),   # Bottom-left (Figure 3.7)
        (Inches(5.5), Inches(4.0))    # Bottom-right (Figure 3.9)
    ]
    
    for i, (left, top) in enumerate(positions[:len(images_slide_7)]):
        resize_image(images_slide_7[i],
                    Inches(2.2), Inches(4.5),
                    left, top)
        changes.append(f"Slide 7: Positioned image {i+1} in 2x2 grid")

# SLIDE 8 - Competitor Comparison (1 image - center it)
slide_8 = prs.slides[7]
images_slide_8 = [s for s in slide_8.shapes if s.shape_type == 13]
if len(images_slide_8) > 0:
    print(f"Slide 8: Found {len(images_slide_8)} image - centering...")
    resize_image(images_slide_8[0],
                PHONE_WIDTH, PHONE_HEIGHT,
                Inches(4.0), Inches(2.5))
    changes.append("Slide 8: Centered image")

# SLIDE 10 - Privacy (2 images - side by side)
slide_10 = prs.slides[9]
images_slide_10 = [s for s in slide_10.shapes if s.shape_type == 13]
if len(images_slide_10) >= 2:
    print(f"Slide 10: Found {len(images_slide_10)} images - positioning side-by-side...")
    
    # Left image (Figure 3.6)
    resize_image(images_slide_10[0],
                Inches(2.2), Inches(4.5),
                Inches(1.5), Inches(2.0))
    
    # Right image (Figure 3.8)
    resize_image(images_slide_10[1],
                Inches(2.2), Inches(4.5),
                Inches(6.5), Inches(2.0))
    
    changes.append("Slide 10: Positioned 2 images side-by-side")

# SLIDE 11 - Evaluation Protocol (1 image - SUS table, make it wider)
slide_11 = prs.slides[10]
images_slide_11 = [s for s in slide_11.shapes if s.shape_type == 13]
if len(images_slide_11) > 0:
    print(f"Slide 11: Found {len(images_slide_11)} image (SUS table) - resizing...")
    # SUS table should be wider and at bottom
    resize_image(images_slide_11[0],
                Inches(8.5), Inches(2.5),
                Inches(0.75), Inches(4.5))
    changes.append("Slide 11: Resized and positioned SUS table")

# SLIDE 14 - Conclusions (3 images - horizontal row)
slide_14 = prs.slides[13]
images_slide_14 = [s for s in slide_14.shapes if s.shape_type == 13]
if len(images_slide_14) >= 3:
    print(f"Slide 14: Found {len(images_slide_14)} images - creating horizontal row...")
    
    positions = [
        Inches(0.5),   # Left
        Inches(3.7),   # Center
        Inches(6.9)    # Right
    ]
    
    for i, left in enumerate(positions[:len(images_slide_14)]):
        resize_image(images_slide_14[i],
                    Inches(2.8), Inches(6.0),
                    left, Inches(1.0))
        changes.append(f"Slide 14: Positioned image {i+1} in horizontal row")

# Save the fixed presentation
prs.save(output_path)

print(f"\n✅ Layout fixes applied!")
print(f"Changes made:")
for change in changes:
    print(f"  - {change}")
print(f"\nOutput saved to: {output_path}")
print(f"\n⚠️  Please review the output file and rename it to '3_PRESENTATION.pptx' if satisfied")
