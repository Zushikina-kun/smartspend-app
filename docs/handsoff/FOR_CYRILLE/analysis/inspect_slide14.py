"""
Inspect Slide 14 (SUS results) in NEW_DEFENSE presentation
"""
from pptx import Presentation

pptx_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'

print(f"Loading presentation: {pptx_path}")
prs = Presentation(pptx_path)

print(f"\nTotal slides: {len(prs.slides)}")

# Slide 14 is index 13
slide = prs.slides[13]
print(f"\n=== SLIDE 14 (index 13) - SUS RESULTS ===")
print(f"Number of shapes: {len(slide.shapes)}")

for i, shape in enumerate(slide.shapes):
    print(f"\n--- Shape {i} ---")
    
    if hasattr(shape, 'text'):
        text = shape.text
        if text.strip():
            print(f"  Text: {text[:300]}")
            
            # Look for SUS-related content
            if any(keyword in text for keyword in ['61.83', 'SUS', 'N=30', 'N = 30', 'Grade D', 'OK']):
                print(f"  ⭐ CONTAINS SUS DATA ⭐")

print("\n=== Done ===")
