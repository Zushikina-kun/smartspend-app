from pptx import Presentation
import re

prs = Presentation('3_PRESENTATION_FINAL.pptx')

print('=== SLIDE 10 ANALYSIS ===')
slide = prs.slides[9]

for idx, shape in enumerate(slide.shapes):
    if hasattr(shape, 'text'):
        text = shape.text
        if re.search(r'\bpending\b', text, re.IGNORECASE):
            print(f'\nShape {idx} contains pending:')
            print(text)
            print('\n---Context---')
            # Show surrounding words
            match = re.search(r'(\w+\s+){0,5}\bpending\b(\s+\w+){0,5}', text, re.IGNORECASE)
            if match:
                print(f'Context: ...{match.group()}...')
