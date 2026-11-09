"""
Inspect Slide 11 structure to find exact text to replace
"""
from pptx import Presentation

pptx_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'

print(f"Loading presentation: {pptx_path}")
prs = Presentation(pptx_path)

# Slide 11 is index 10
slide = prs.slides[10]
print(f"\n=== SLIDE 11 (index 10) ===")
print(f"Number of shapes: {len(slide.shapes)}")

for i, shape in enumerate(slide.shapes):
    print(f"\n--- Shape {i} ---")
    print(f"  Type: {shape.shape_type}")
    
    if hasattr(shape, 'text'):
        text = shape.text
        if text.strip():
            print(f"  Text (first 200 chars): {text[:200]}")
            
            # Look for anything related to N=5 or individual scores
            if any(keyword in text for keyword in ['60.0', '55.0', '75.0', '67.5', 'Individual', 'Range', 'N=5', 'N=30']):
                print(f"  ⭐ CONTAINS TARGET TEXT ⭐")
                print(f"  Full text:\n{text}")
                
                if hasattr(shape, 'text_frame'):
                    print(f"  Text frame paragraphs: {len(shape.text_frame.paragraphs)}")
                    for p_idx, para in enumerate(shape.text_frame.paragraphs):
                        print(f"    Para {p_idx}: {para.text[:100]}")

print("\n=== Done ===")
