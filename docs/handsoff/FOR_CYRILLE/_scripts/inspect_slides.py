from pptx import Presentation

prs = Presentation('SmartSpend_Defense.pptx')
print(f'Slide count: {len(prs.slides)}')
for i, slide in enumerate(prs.slides):
    print(f'\n=== Slide {i+1} ===')
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                text = para.text.strip()
                if text:
                    print(f'  [{shape.name}]: {text[:200]}')
