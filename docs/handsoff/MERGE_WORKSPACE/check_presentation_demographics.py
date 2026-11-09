from pptx import Presentation
import sys

prs = Presentation(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\3_PRESENTATION_FINAL.pptx')

print('=== PRESENTATION DEMOGRAPHICS CHECK ===')

# Extract all text
all_text = []
for slide_num, slide in enumerate(prs.slides, 1):
    for shape in slide.shapes:
        if hasattr(shape, "text") and shape.text.strip():
            text = shape.text.strip()
            # Look for demographics mentions
            if any(word in text.lower() for word in ['parent', 'young professional', 'n=', 'n =', 'respondent']):
                print(f'\nSlide {slide_num}:')
                print(text)
                print('-' * 60)

# Also check tables
print('\n\n=== TABLES IN PRESENTATION ===')
for slide_num, slide in enumerate(prs.slides, 1):
    for shape in slide.shapes:
        if shape.has_table:
            print(f'\nSlide {slide_num} - Table:')
            table = shape.table
            for row in table.rows:
                row_text = ' | '.join([cell.text for cell in row.cells])
                if 'parent' in row_text.lower() or 'young' in row_text.lower() or 'professional' in row_text.lower():
                    print(row_text)
