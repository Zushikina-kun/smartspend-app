"""
Detailed search for demographics information in SmartSpend_Defense.pptx
"""

from pptx import Presentation

pptx_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
print(f"Searching for demographics in: {pptx_path}\n")

prs = Presentation(pptx_path)

keywords = ['parent', 'young professional', 'n=30', 'n = 30', '35-55', '21-35', 'demographic']

print("="*80)
for slide_idx, slide in enumerate(prs.slides, 1):
    found_in_slide = False
    slide_matches = []
    
    for shape in slide.shapes:
        if hasattr(shape, 'text_frame'):
            text = shape.text_frame.text
            text_lower = text.lower()
            
            for keyword in keywords:
                if keyword.lower() in text_lower:
                    if not found_in_slide:
                        print(f"\n📍 SLIDE {slide_idx}")
                        found_in_slide = True
                    
                    # Show context around the keyword
                    lines = text.split('\n')
                    for line in lines:
                        if keyword.lower() in line.lower():
                            print(f"   • {line.strip()}")
                            slide_matches.append(line.strip())

print("\n" + "="*80)
print("Search complete.")
