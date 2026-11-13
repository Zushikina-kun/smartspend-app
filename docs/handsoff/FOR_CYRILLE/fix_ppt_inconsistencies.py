"""
Fix PPT inconsistencies found during cross-check with manuscript:
1. Slide 12: "20 candidate models" -> "8 candidate LLM APIs"
2. Slide 12: "6 weighted criteria, 20 candidate models" -> correct numbers
"""
import shutil
from pptx import Presentation
from pptx.oxml.ns import qn

PPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
shutil.copy(PPT, PPT + '.inconsistency_fix.bak')

prs = Presentation(PPT)
log = []

REPLACEMENTS = [
    ('6 weighted criteria, 20 candidate models', '6 weighted criteria, 8 candidate LLM APIs'),
    ('20 candidate models', '8 candidate LLM APIs'),
    ('six providers', 'multiple providers'),
]

def fix_runs(shape):
    fixed = []
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                for old, new in REPLACEMENTS:
                    if old in run.text:
                        run.text = run.text.replace(old, new)
                        fixed.append(f'  Fixed: "{old}" → "{new}"')
    if shape.shape_type == 6:
        for s in shape.shapes:
            fixed.extend(fix_runs(s))
    return fixed

for i, slide in enumerate(prs.slides):
    for shape in slide.shapes:
        fixes = fix_runs(shape)
        for f in fixes:
            log.append(f'Slide {i+1}: {f}')

prs.save(PPT)
print('PPT saved.')
print(f'\n{len(log)} fixes:')
for l in log:
    print(l)

# Verify
prs2 = Presentation(PPT)
all_text = ' '.join(
    run.text
    for slide in prs2.slides
    for shape in slide.shapes
    for run in (
        [r for para in shape.text_frame.paragraphs for r in para.runs]
        if shape.has_text_frame else []
    )
)

checks = [
    ('No "20 candidate models"', '20 candidate models' not in all_text),
    ('No "6 weighted criteria, 20"', '6 weighted criteria, 20' not in all_text),
    ('Has "8 candidate LLM APIs" or "eight"', '8 candidate LLM APIs' in all_text or 'eight candidate' in all_text.lower()),
    ('No Gemini 1.5', 'Gemini 1.5' not in all_text),
    ('SUS 61.83 present', '61.83' in all_text),
    ('Gemini 3.5 present', 'Gemini 3.5' in all_text),
]

print('\nVerification:')
for label, ok in checks:
    print(f'  {"OK  " if ok else "FAIL"}: {label}')
