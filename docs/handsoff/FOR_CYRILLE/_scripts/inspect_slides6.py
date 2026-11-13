from pptx import Presentation

prs = Presentation('SmartSpend_Defense.pptx')

def print_slide_full(slide, num):
    print(f"\n=== Slide {num} ALL SHAPES ===")
    def print_shape(shape, indent=2):
        spaces = ' ' * indent
        print(f"{spaces}Shape: {shape.name!r} type={shape.shape_type}")
        if hasattr(shape, 'shapes'):
            for sub in shape.shapes:
                print_shape(sub, indent+2)
        elif shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                if para.text.strip():
                    print(f"{spaces}  TEXT: {para.text!r}")
    for shape in slide.shapes:
        print_shape(shape)

# Slides 6, 7, 8
for i in [5, 6, 7]:
    print_slide_full(prs.slides[i], i+1)
