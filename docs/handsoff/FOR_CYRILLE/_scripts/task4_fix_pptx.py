"""
TASK 4: Check and fix presentation screenshots
"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.shapes import MSO_SHAPE_TYPE
import os
import copy

PPTX_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
FIGURES_DIR = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES'

# Figure map: keywords -> image file
FIGURE_MAP = [
    (["3.4", "Login", "Demo Mode"], "Figure_3.4_Login_Demo_Mode.jpg"),
    (["3.5", "Dashboard", "Home Dashboard"], "Figure_3.5_Home_Dashboard.jpg"),
    (["3.6", "Peso Chat", "Expense Logging"], "Figure_3.6_Peso_Chat_Expense_Logging.jpg"),
    (["3.7", "Batch Import", "GCash"], "Figure_3.7_Batch_Import_GCash.jpg"),
    (["3.8", "FHS", "Financial Health", "Breakdown"], "Figure_3.8_FHS_Breakdown.jpg"),
    (["3.9", "Budget", "Savings Goals", "Safe-to-Spend"], "Figure_3.9_Budgets_Savings_Goals.jpg"),
    (["3.10", "Local AI"], "Figure_3.10_Local_AI_Setup.jpg"),
    (["3.11", "SUS Computation"], "Figure_3.11_SUS_Computation_Table.png"),
]

def get_slide_text(slide):
    """Get all text from a slide."""
    texts = []
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                t = para.text.strip()
                if t:
                    texts.append(t)
    return ' | '.join(texts)

def find_figure_for_slide(slide_text):
    """Find which figure should be on this slide based on text clues."""
    for keywords, img_file in FIGURE_MAP:
        for kw in keywords:
            if kw.lower() in slide_text.lower():
                return img_file, kw
    return None, None

def get_picture_shapes(slide):
    """Get all picture shapes from a slide."""
    pics = []
    for shape in slide.shapes:
        if shape.shape_type == MSO_SHAPE_TYPE.PICTURE:
            pics.append(shape)
    return pics

prs = Presentation(PPTX_PATH)
slides_checked = []
slides_replaced = []
slides_flagged = []

print(f"Presentation has {len(prs.slides)} slides\n")

for slide_num, slide in enumerate(prs.slides, 1):
    slide_text = get_slide_text(slide)
    pics = get_picture_shapes(slide)
    
    # Get title if available
    title_text = ""
    if slide.shapes.title:
        title_text = slide.shapes.title.text.strip()
    
    print(f"Slide {slide_num}: '{title_text[:50]}' | {len(pics)} image(s)")
    if slide_text:
        print(f"  Text: {slide_text[:100]}")
    
    slides_checked.append(slide_num)
    
    # For slides 8-15, check for figure references
    if 8 <= slide_num <= 15:
        img_file, matched_kw = find_figure_for_slide(slide_text)
        
        if img_file:
            img_path = os.path.join(FIGURES_DIR, img_file)
            if not os.path.exists(img_path):
                print(f"  WARNING: Image file not found: {img_path}")
                slides_flagged.append((slide_num, f"Image file not found: {img_file}"))
                continue
            
            if not pics:
                print(f"  NOTE: No existing image on slide {slide_num}, would add '{img_file}' (matched: '{matched_kw}')")
                slides_flagged.append((slide_num, f"No existing image to replace; matched '{matched_kw}' -> {img_file}"))
                continue
            
            # Replace the first (or largest) picture
            pic_shape = pics[0]
            if len(pics) > 1:
                # Choose the largest one
                pic_shape = max(pics, key=lambda p: p.width * p.height)
            
            left = pic_shape.left
            top = pic_shape.top
            width = pic_shape.width
            height = pic_shape.height
            
            # Remove old picture
            sp = pic_shape._element
            sp.getparent().remove(sp)
            
            # Add new picture
            new_pic = slide.shapes.add_picture(img_path, left, top, width, height)
            
            print(f"  REPLACED: Slide {slide_num} -> '{img_file}' (matched: '{matched_kw}')")
            print(f"    Position: left={left}, top={top}, width={width}, height={height}")
            slides_replaced.append((slide_num, img_file, matched_kw))
        else:
            if pics:
                print(f"  NOTE: Slide {slide_num} has {len(pics)} image(s) but no figure keyword found in text.")
                slides_flagged.append((slide_num, "Has images but no figure keyword found — cannot determine correct figure"))
            else:
                print(f"  NOTE: Slide {slide_num} (in range 8-15) has no images and no figure keyword.")

print(f"\n{'='*60}")
print(f"SUMMARY:")
print(f"  Total slides checked: {len(slides_checked)}")
print(f"  Slides with images replaced: {len(slides_replaced)}")
for sn, img, kw in slides_replaced:
    print(f"    - Slide {sn}: {img} (matched '{kw}')")
print(f"  Slides flagged (uncertain): {len(slides_flagged)}")
for sn, reason in slides_flagged:
    print(f"    - Slide {sn}: {reason}")

# Save
prs.save(PPTX_PATH)
print(f"\nSaved: {PPTX_PATH}")

size = os.path.getsize(PPTX_PATH)
print(f"File size after save: {size:,} bytes")
if size < 100000:
    print("WARNING: File size suspiciously small!")
else:
    print("File size OK.")
