from pptx import Presentation

prs = Presentation('SmartSpend_Defense.pptx')

# Check the numbers in slide 10 - look at the groups which likely have numbers
print("=== Slide 10 Groups (numbers) ===")
slide10 = prs.slides[9]
for shape in slide10.shapes:
    print(f'  Shape: name={shape.name!r}, type={shape.shape_type}')
    if hasattr(shape, 'shapes'):  # group
        for sub in shape.shapes:
            if sub.has_text_frame:
                for para in sub.text_frame.paragraphs:
                    if para.text.strip():
                        print(f'    Sub [{sub.name}]: {para.text!r}')

print()
print("=== Slide 15 (SUS) full detail ===")
slide15 = prs.slides[14]
for shape in slide15.shapes:
    print(f'  Shape: name={shape.name!r}, type={shape.shape_type}')
    if hasattr(shape, 'shapes'):
        for sub in shape.shapes:
            if sub.has_text_frame:
                for para in sub.text_frame.paragraphs:
                    if para.text.strip():
                        print(f'    Sub [{sub.name}]: {para.text!r}')
    elif shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            if para.text.strip():
                print(f'    Para: {para.text!r}')

print()
print("=== Slide 16 (Conclusions) full detail ===")
slide16 = prs.slides[15]
for shape in slide16.shapes:
    print(f'  Shape: name={shape.name!r}')
    if hasattr(shape, 'shapes'):
        for sub in shape.shapes:
            if sub.has_text_frame:
                for para in sub.text_frame.paragraphs:
                    if para.text.strip():
                        print(f'    Sub [{sub.name}]: {para.text!r}')
    elif shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            if para.text.strip():
                print(f'    Para: {para.text!r}')

print()
print("=== Slide 9 (Obj 1 results) groups ===")
slide9 = prs.slides[8]
for shape in slide9.shapes:
    print(f'  Shape: name={shape.name!r}')
    if hasattr(shape, 'shapes'):
        for sub in shape.shapes:
            if sub.has_text_frame:
                for para in sub.text_frame.paragraphs:
                    if para.text.strip():
                        print(f'    Sub [{sub.name}]: {para.text!r}')
    elif shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            if para.text.strip():
                print(f'    Para: {para.text!r}')
