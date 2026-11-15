"""
Properly insert Proposed Solution slide between Objectives and IPO.
Use the original slide formatting as a template.
"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from copy import deepcopy
import shutil

# Start from clean FIXED version
SRC = 'SmartSpend_Defense_FIXED.pptx'
DEST = r'FOR_CYRILLE\SmartSpend_Defense.pptx'

shutil.copy(SRC, DEST + '.before_proper_insert.bak')
shutil.copy(SRC, DEST)

prs = Presentation(DEST)
print(f'Starting from clean FIXED: {len(prs.slides)} slides')

# Get Slide 6 (Objectives) to copy its layout and style
objectives_slide = prs.slides[5]
objectives_layout = objectives_slide.slide_layout

# Add new slide using the same layout
new_slide = prs.slides.add_slide(objectives_layout)

# Move it to position 7 (between Objectives and IPO)
# Current order: 0-5 = slides 1-6, 6 = IPO (slide 7), ... 18 = Questions (slide 19)
# We want: 0-5 stay, new slide at index 6, old slide 6 (IPO) becomes index 7

slides_list = list(prs.slides._sldIdLst)
new_slide_id = slides_list[-1]  # Just added, at the end
slides_list.remove(new_slide_id)
slides_list.insert(6, new_slide_id)  # Insert at index 6

print(f'Inserted new slide at position 7 (between Objectives and IPO)')

# Now the new slide is at index 6
slide = prs.slides[6]

# Clear default placeholders if any
for shape in list(slide.shapes):
    sp = shape.element
    sp.getparent().remove(sp)

# Copy header style from Objectives slide (slide 6, now at index 5)
# Find header in objectives slide
header_ref = None
for shape in prs.slides[5].shapes:
    if shape.has_text_frame and 'SmartSpend  |' in shape.text_frame.text:
        header_ref = shape
        break

if header_ref:
    # Add header with same positioning
    header = slide.shapes.add_textbox(
        header_ref.left, header_ref.top, header_ref.width, header_ref.height
    )
    tf = header.text_frame
    tf.text = 'SmartSpend  |  LORMA Colleges, CCSE'
    for para in tf.paragraphs:
        para.font.size = Pt(11)
        para.font.color.rgb = RGBColor(128, 128, 128)

# Add title - center it like other section slides
title = slide.shapes.add_textbox(Inches(1.5), Inches(1.8), Inches(7.0), Inches(1.2))
tf = title.text_frame
tf.text = 'SmartSpend: The Proposed Solution'
p = tf.paragraphs[0]
p.font.size = Pt(36)
p.font.bold = True
p.font.color.rgb = RGBColor(0, 51, 102)
p.alignment = 1  # Center

# Add content box
content = slide.shapes.add_textbox(Inches(1.8), Inches(3.2), Inches(6.4), Inches(3.5))
tf = content.text_frame
tf.word_wrap = True

bullets = [
    'An AI-powered Android mobile application for personal financial management',
    'Built for Filipino parents and young professionals who struggle with manual expense tracking',
    'Natural language expense logging in Taglish: type or speak "nag-lunch ako 150 pesos"',
    'Multi-modal input: voice, text, OCR receipt scanning, batch screenshot import',
    'Financial Health Score from 0 to 100 to motivate better spending habits',
    'Offline-first with cloud sync: works without internet, syncs when connected',
]

# Add bullets with proper formatting
for i, bullet_text in enumerate(bullets):
    if i == 0:
        p = tf.paragraphs[0]
    else:
        p = tf.add_paragraph()
    p.text = bullet_text
    p.level = 0
    p.font.size = Pt(14)
    p.space_before = Pt(8)
    p.space_after = Pt(8)
    p.font.color.rgb = RGBColor(0, 0, 0)

prs.save(DEST)
print(f'Saved. Now {len(prs.slides)} slides')

# Verify
prs2 = Presentation(DEST)
print(f'\nVerification: {len(prs2.slides)} slides')

def get_title(slide):
    for shape in slide.shapes:
        if shape.has_text_frame:
            txt = shape.text_frame.text.strip()
            if txt and len(txt) < 150 and 'SmartSpend  |' not in txt:
                return txt[:70]
        if shape.shape_type == 6:
            for s in shape.shapes:
                if s.has_text_frame:
                    txt = s.text_frame.text.strip()
                    if txt and len(txt) < 150 and 'SmartSpend  |' not in txt:
                        return txt[:70]
    return '(no title)'

for i in [5, 6, 7, 8]:
    print(f'  Slide {i+1}: {get_title(prs2.slides[i])}')
