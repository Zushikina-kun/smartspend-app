"""Fix Gemini 1.5 -> 3.5 in PPT slides 12 and 17"""
import shutil
from pptx import Presentation
from pptx.util import Pt

PPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
shutil.copy(PPT, PPT + '.gemini_fix.bak')
prs = Presentation(PPT)

fixes = []
for i, slide in enumerate(prs.slides):
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                for run in para.runs:
                    if 'Gemini 1.5' in run.text or 'gemini 1.5' in run.text.lower():
                        old = run.text
                        run.text = run.text.replace('Gemini 1.5', 'Gemini 3.5')
                        fixes.append(f'Slide {i+1}: "{old[:60]}" -> "{run.text[:60]}"')

prs.save(PPT)
print(f'{len(fixes)} fixes applied:')
for f in fixes: print(f'  {f}')

# Verify
prs2 = Presentation(PPT)
wrong = []
correct = []
for i, slide in enumerate(prs2.slides):
    for shape in slide.shapes:
        if shape.has_text_frame:
            t = shape.text_frame.text
            if 'Gemini 1.5' in t: wrong.append(f'Slide {i+1}')
            if 'Gemini 3.5' in t: correct.append(f'Slide {i+1}')

print(f'\nWrong "Gemini 1.5" remaining: {wrong}')
print(f'Correct "Gemini 3.5" on slides: {correct}')
