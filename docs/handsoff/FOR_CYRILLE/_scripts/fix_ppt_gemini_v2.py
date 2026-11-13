"""Fix Gemini 1.5 -> 3.5 in PPT group shapes (slides 12 and 17)"""
import shutil
from pptx import Presentation

PPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
shutil.copy(PPT, PPT + '.g2.bak')
prs = Presentation(PPT)
fixes = []

def fix_shape(shape, slide_num):
    # Regular text frame
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                if 'Gemini 1.5' in run.text:
                    old = run.text
                    run.text = run.text.replace('Gemini 1.5', 'Gemini 3.5')
                    fixes.append(f'Slide {slide_num} shape: "{old[:60]}"')
    # Table
    if shape.has_table:
        for row in shape.table.rows:
            for cell in row.cells:
                for para in cell.text_frame.paragraphs:
                    for run in para.runs:
                        if 'Gemini 1.5' in run.text:
                            old = run.text
                            run.text = run.text.replace('Gemini 1.5', 'Gemini 3.5')
                            fixes.append(f'Slide {slide_num} table: "{old[:60]}"')
    # Group — recurse
    if shape.shape_type == 6:
        for s in shape.shapes:
            fix_shape(s, slide_num)

for i, slide in enumerate(prs.slides):
    for shape in slide.shapes:
        fix_shape(shape, i+1)

prs.save(PPT)
print(f'{len(fixes)} fixes:')
for f in fixes: print(f'  {f}')

# Verify
prs2 = Presentation(PPT)
remaining = []
def check_shape(shape, slide_num):
    if shape.has_text_frame:
        t = shape.text_frame.text
        if 'Gemini 1.5' in t: remaining.append(f'Slide {slide_num}: {t[:60]}')
    if shape.shape_type == 6:
        for s in shape.shapes:
            check_shape(s, slide_num)

for i, slide in enumerate(prs2.slides):
    for shape in slide.shapes:
        check_shape(shape, i+1)

if remaining:
    print(f'\nStill wrong: {remaining}')
else:
    print('\nAll Gemini 1.5 → 3.5 fixed in PPT')
