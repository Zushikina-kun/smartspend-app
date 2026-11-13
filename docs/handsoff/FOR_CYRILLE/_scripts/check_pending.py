from pptx import Presentation
import re

prs = Presentation('3_PRESENTATION_FINAL.pptx')

print('Checking Slide 12 for problematic pending (not overspending)...')
slide = prs.slides[11]

found_issues = False
for idx, shape in enumerate(slide.shapes):
    if hasattr(shape, 'text'):
        text = shape.text
        # Check for pending as separate word, not part of overspending
        if re.search(r'\bpending\b', text, re.IGNORECASE):
            print(f'Shape {idx} has actual pending:')
            print(text[:200])
            found_issues = True

if not found_issues:
    print('NO PROBLEMATIC PENDING TEXT FOUND')
    print('(only overspending which is correct)')
