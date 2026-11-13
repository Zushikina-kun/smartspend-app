from pptx import Presentation

prs = Presentation('SmartSpend_Defense.pptx')

# Check all text in slides 3, 4, 5 for Table references
for i in [2, 3, 4]:  # slides 3, 4, 5
    slide = prs.slides[i]
    slide_num = i + 1
    print(f"\n=== Slide {slide_num} ALL TEXT ===")
    def collect_text(shape, texts):
        if hasattr(shape, 'shapes'):
            for sub in shape.shapes:
                collect_text(sub, texts)
        elif shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                t = para.text.strip()
                if t:
                    texts.append((shape.name, t))
    texts = []
    for shape in slide.shapes:
        collect_text(shape, texts)
    for name, text in texts:
        print(f"  [{name}]: {text!r}")

# Also check if any Table shape in slides 4 and 5
print("\n=== TABLES in slide 4 ===")
slide4 = prs.slides[3]
for shape in slide4.shapes:
    if shape.shape_type == 19:
        print(f"Table: {shape.name}")
        for row in shape.table.rows:
            for cell in row.cells:
                if cell.text.strip():
                    print(f"  Cell: {cell.text!r}")

print("\n=== TABLES in slide 5 ===")
slide5 = prs.slides[4]
for shape in slide5.shapes:
    if shape.shape_type == 19:
        print(f"Table: {shape.name}")
        tbl = shape.table
        # just check caption/header cells for table references  
        for row in tbl.rows:
            for cell in row.cells:
                if 'Table' in cell.text or 'table' in cell.text:
                    print(f"  Cell with 'Table': {cell.text!r}")
