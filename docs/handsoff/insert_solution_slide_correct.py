"""
Properly insert 'SmartSpend: The Proposed Solution' slide after Slide 6 (Objectives).
This will make it 20 slides total.
"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
import shutil

PPT = r'FOR_CYRILLE\SmartSpend_Defense.pptx'
shutil.copy(PPT, PPT + '.before_solution.bak')

prs = Presentation(PPT)
print(f'Starting with {len(prs.slides)} slides')

# Get slide 6 (Objectives) for reference
slide6 = prs.slides[5]

# Use a blank layout
blank_layout = prs.slide_layouts[6]  # Blank layout

# Add new slide at the end first
new_slide = prs.slides.add_slide(blank_layout)

# Move it to position 7 (after slide 6, index 6)
slides_list = list(prs.slides._sldIdLst)
new_slide_id = slides_list[-1]
slides_list.remove(new_slide_id)
slides_list.insert(6, new_slide_id)

print('Slide inserted at position 7')

# Now design the slide (it's at index 6)
slide = prs.slides[6]

# Add header (like other slides)
header = slide.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.5))
tf = header.text_frame
tf.text = 'SmartSpend  |  LORMA Colleges, CCSE'
tf.paragraphs[0].font.size = Pt(11)
tf.paragraphs[0].font.color.rgb = RGBColor(128, 128, 128)

# Add title
title = slide.shapes.add_textbox(Inches(1.0), Inches(1.4), Inches(8.0), Inches(1.0))
tf = title.text_frame
tf.text = 'SmartSpend: The Proposed Solution'
p = tf.paragraphs[0]
p.font.size = Pt(40)
p.font.bold = True
p.font.color.rgb = RGBColor(0, 51, 102)
p.alignment = 1  # Center

# Add content bullets
content = slide.shapes.add_textbox(Inches(1.5), Inches(2.8), Inches(7.0), Inches(4.0))
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

for bullet in bullets:
    p = tf.add_paragraph()
    p.text = bullet
    p.level = 0
    p.font.size = Pt(15)
    p.space_before = Pt(6)
    p.space_after = Pt(6)

# Remove the empty first paragraph
tf.paragraphs[0].clear()

prs.save(PPT)
print(f'Saved. Now {len(prs.slides)} slides')

# Verify
prs2 = Presentation(PPT)
print(f'\nVerification:')
print(f'  Total slides: {len(prs2.slides)}')

def get_first_text(slide):
    for shape in slide.shapes:
        if shape.has_text_frame:
            txt = shape.text_frame.text.strip()
            if txt: return txt[:60]
        if shape.shape_type == 6:
            for s in shape.shapes:
                if s.has_text_frame:
                    txt = s.text_frame.text.strip()
                    if txt: return txt[:60]
    return '(no text)'

for i in [5, 6, 7]:
    print(f'  Slide {i+1}: {get_first_text(prs2.slides[i])}')
