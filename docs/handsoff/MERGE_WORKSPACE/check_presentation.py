from pptx import Presentation
import sys

prs = Presentation(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\3_PRESENTATION_FINAL.pptx')

print('=== PRESENTATION ANALYSIS ===')
print(f'Total slides: {len(prs.slides)}')

# Count images per slide
total_images = 0
for i, slide in enumerate(prs.slides, 1):
    image_count = 0
    for shape in slide.shapes:
        if hasattr(shape, "image"):
            image_count += 1
    print(f'Slide {i}: {image_count} images')
    total_images += image_count

print(f'\nTotal images across all slides: {total_images}')

# Check for text content
print('\n=== TEXT CONTENT CHECKS ===')
all_text = []
for slide in prs.slides:
    for shape in slide.shapes:
        if hasattr(shape, "text"):
            all_text.append(shape.text)

full_text = ' '.join(all_text)
print(f'Grade D present: {"Grade D" in full_text}')
print(f'Grade C present: {"Grade C" in full_text}')
print(f'SUS 61.83: {"61.83" in full_text}')
print(f'10 parents: {"10" in full_text and "parent" in full_text.lower()}')
print(f'20 young prof: {"20" in full_text and "young professional" in full_text.lower()}')
print(f'PENDING tags: {"[PENDING]" in full_text or "PENDING" in full_text}')
print(f'Interview mentions: {full_text.lower().count("interview")}')
print(f'Survey mentions: {full_text.lower().count("survey")}')

# Check title slide specifically
print('\n=== TITLE SLIDE CHECK ===')
title_slide = prs.slides[0]
title_images = 0
for shape in title_slide.shapes:
    if hasattr(shape, "image"):
        title_images += 1
print(f'Title slide (Slide 1) has {title_images} images (should be 0)')

# Look for yellow warning boxes by checking for yellow fill colors
print('\n=== YELLOW WARNING BOX CHECK ===')
yellow_shapes = 0
for slide in prs.slides:
    for shape in slide.shapes:
        if hasattr(shape, 'fill') and shape.fill.type:
            try:
                if hasattr(shape.fill, 'fore_color') and shape.fill.fore_color.rgb:
                    r, g, b = shape.fill.fore_color.rgb
                    # Check if yellow-ish (high R and G, low B)
                    if r > 200 and g > 200 and b < 100:
                        yellow_shapes += 1
            except:
                pass

print(f'Yellow-colored shapes found: {yellow_shapes}')
