from pptx import Presentation

prs = Presentation('SmartSpend_Defense.pptx')
print(f'Slide count: {len(prs.slides)}')

# Get more detail on specific slides
slides_of_interest = [1, 3, 9, 10, 15, 16]  # 0-indexed

for i, slide in enumerate(prs.slides):
    slide_num = i + 1
    print(f'\n=== Slide {slide_num} (ALL SHAPES) ===')
    for shape in slide.shapes:
        print(f'  Shape: name={shape.name!r}, type={shape.shape_type}, has_text={shape.has_text_frame}')
        if shape.has_text_frame:
            for j, para in enumerate(shape.text_frame.paragraphs):
                text = para.text
                if text:
                    print(f'    Para {j}: {text!r}')
