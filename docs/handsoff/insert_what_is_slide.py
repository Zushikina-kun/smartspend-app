"""
Insert a new 'What is SmartSpend?' slide after Slide 6 (Objectives)
to give the panel context before diving into methodology.
"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
import shutil

PPT = r'FOR_CYRILLE\SmartSpend_Defense.pptx'
shutil.copy(PPT, PPT + '.pre_what_is.bak')

prs = Presentation(PPT)

# Get slide 6 (Objectives) layout
slide6 = prs.slides[5]  # 0-indexed
layout = slide6.slide_layout

# Add new slide
new_slide = prs.slides.add_slide(layout)

# Move it to position 7 (after slide 6, before current slide 7 IPO)
slides = list(prs.slides._sldIdLst)
new_slide_id = slides[-1]
slides.remove(new_slide_id)
slides.insert(6, new_slide_id)

print('New slide inserted at position 7 (after Objectives, before IPO)')

# Access the new slide (now at index 6)
new_slide = prs.slides[6]

# Clear existing shapes
for shape in list(new_slide.shapes):
    sp = shape.element
    sp.getparent().remove(sp)

# Add header
header = new_slide.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.5))
tf = header.text_frame
tf.text = 'SmartSpend  |  LORMA Colleges, CCSE'
tf.paragraphs[0].font.size = Pt(12)
tf.paragraphs[0].font.color.rgb = RGBColor(100, 100, 100)

# Add title
title_box = new_slide.shapes.add_textbox(Inches(0.8), Inches(1.2), Inches(8.4), Inches(0.8))
tf = title_box.text_frame
tf.text = 'What is SmartSpend?'
tf.paragraphs[0].font.size = Pt(36)
tf.paragraphs[0].font.bold = True
tf.paragraphs[0].font.color.rgb = RGBColor(0, 51, 102)

# Add content
content_box = new_slide.shapes.add_textbox(Inches(1.2), Inches(2.3), Inches(7.6), Inches(4.0))
tf = content_box.text_frame
tf.word_wrap = True

bullets = [
    'An AI-powered Android mobile application for personal financial management',
    'Built for Filipino parents and young professionals who struggle with manual expense tracking',
    'Natural language expense logging in Taglish: type or speak "nag-lunch ako 150 pesos"',
    'Multi-modal input: voice, text, OCR receipt scanning, batch screenshot import from 40+ platforms',
    'Financial Health Score from 0 to 100 to motivate better spending habits',
    'Offline-first with cloud sync: works without internet, syncs when connected',
]

for bullet in bullets:
    p = tf.add_paragraph()
    p.text = bullet
    p.level = 0
    p.font.size = Pt(16)
    p.space_before = Pt(8)
    p.space_after = Pt(8)

print('Content added to new Slide 7')
prs.save(PPT)
print('Saved. Slide count:', len(prs.slides))

# Verify
prs2 = Presentation(PPT)
print(f'\nVerification: {len(prs2.slides)} slides')
print('Slide 6:', [s.text_frame.text for s in prs2.slides[5].shapes if s.has_text_frame][:2])
print('Slide 7 (new):', [s.text_frame.text for s in prs2.slides[6].shapes if s.has_text_frame][:2])
print('Slide 8 (was 7):', [s.text_frame.text for s in prs2.slides[7].shapes if s.has_text_frame][:2])
