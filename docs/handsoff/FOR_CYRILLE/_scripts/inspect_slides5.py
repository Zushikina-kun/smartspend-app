from pptx import Presentation

# Check what slide 7 and 8 actually are (they have mostly image shapes)
prs = Presentation('SmartSpend_Defense.pptx')

for i in range(len(prs.slides)):
    slide = prs.slides[i]
    slide_num = i + 1
    # Get title if any
    title = ""
    for shape in slide.shapes:
        if hasattr(shape, 'shapes'):
            for sub in shape.shapes:
                if sub.has_text_frame:
                    for para in sub.text_frame.paragraphs:
                        t = para.text.strip()
                        if t and len(t) < 100:
                            if title == "":
                                title = t
        elif shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                t = para.text.strip()
                if t and len(t) < 100:
                    if title == "":
                        title = t
    print(f"Slide {slide_num}: first_text={title!r}")

print()
print("=== Check if Objectives or Methods slides exist ===")
for i, slide in enumerate(prs.slides):
    for shape in slide.shapes:
        if hasattr(shape, 'shapes'):
            for sub in shape.shapes:
                if sub.has_text_frame:
                    for para in sub.text_frame.paragraphs:
                        t = para.text.strip().lower()
                        if 'objective' in t or 'method' in t or 'research design' in t:
                            print(f"Slide {i+1}: {para.text!r}")
        elif shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                t = para.text.strip().lower()
                if 'objective' in t or 'method' in t or 'research design' in t:
                    print(f"Slide {i+1}: {para.text!r}")

print()
print("=== Check table contents on slide 5 ===")
slide5 = prs.slides[4]
for shape in slide5.shapes:
    if shape.shape_type == 19:  # TABLE
        print(f"Found table: {shape.name!r}")
        tbl = shape.table
        for row_idx, row in enumerate(tbl.rows):
            for col_idx, cell in enumerate(row.cells):
                text = cell.text.strip()
                if text:
                    print(f"  [{row_idx},{col_idx}]: {text!r}")
