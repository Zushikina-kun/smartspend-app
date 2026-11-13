"""Deep check of PPT and script for all table/figure references."""
from pptx import Presentation
import re

prs = Presentation('SmartSpend_Defense.pptx')

def get_all_text_deep(shape):
    texts = []
    if shape.has_text_frame:
        texts.append(shape.text_frame.text)
    if shape.has_table:
        for row in shape.table.rows:
            for cell in row.cells:
                texts.append(cell.text_frame.text)
    if hasattr(shape, 'shapes'):
        for s in shape.shapes:
            texts.extend(get_all_text_deep(s))
    return texts

print("=== ALL TABLE/FIGURE MENTIONS IN PPT ===")
for i, slide in enumerate(prs.slides, 1):
    slide_texts = []
    for shape in slide.shapes:
        slide_texts.extend(get_all_text_deep(shape))
    combined = '\n'.join(slide_texts)
    matches = re.findall(r'(Table|Figure|Fig)\s*[\d.]+[^.\n]*', combined, re.IGNORECASE)
    if matches:
        print(f"Slide {i}:")
        for m in matches:
            print(f"  {m}")

print()
print("=== ALL TABLE/FIGURE MENTIONS IN SCRIPT ===")
script = open('4_DEFENSE_SCRIPT_FINAL.md', encoding='utf-8').read()
matches = re.findall(r'(Table|Figure|Fig)\s*[\d.]+[^\n]*', script)
for m in matches:
    print(f"  {m}")

print()
print("=== SLIDE 9 FULL CONTENT (demographics) ===")
slide9 = prs.slides[8]
for shape in slide9.shapes:
    texts = get_all_text_deep(shape)
    for t in texts:
        if t.strip():
            print(f"  {repr(t[:300])}")

print()
print("=== SLIDE 15 FULL CONTENT (SUS) ===")
slide15 = prs.slides[14]
for shape in slide15.shapes:
    texts = get_all_text_deep(shape)
    for t in texts:
        if t.strip():
            print(f"  {repr(t[:300])}")
