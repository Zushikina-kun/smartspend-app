"""
Compare SmartSpend_Defense.pptx (18 slides) with 3_PRESENTATION_FINAL.pptx (16 slides)
to identify which content differs and if anything needs to be merged.
"""

from pptx import Presentation

def get_slide_info(prs, slide_idx):
    """Extract title and key content from a slide"""
    slide = prs.slides[slide_idx]
    title = ""
    content = []
    
    for shape in slide.shapes:
        if hasattr(shape, 'text_frame'):
            text = shape.text_frame.text.strip()
            if text:
                # First text shape is usually the title
                if not title and len(text) < 200:
                    title = text
                else:
                    content.append(text[:100])  # First 100 chars of each content
    
    return title, content

print("="*80)
print("PRESENTATION COMPARISON")
print("="*80)

new_defense_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
final_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\3_PRESENTATION_FINAL.pptx'

prs_new = Presentation(new_defense_path)
prs_final = Presentation(final_path)

print(f"\nNEW_DEFENSE: {len(prs_new.slides)} slides")
print(f"FINAL: {len(prs_final.slides)} slides")
print(f"Difference: {len(prs_new.slides) - len(prs_final.slides)} extra slides in NEW_DEFENSE")

print("\n" + "="*80)
print("SLIDE-BY-SLIDE COMPARISON")
print("="*80)

# Compare all slides from FINAL
print("\n📋 Slides in FINAL (16 slides):")
final_titles = []
for i in range(len(prs_final.slides)):
    title, _ = get_slide_info(prs_final, i)
    final_titles.append(title)
    print(f"  {i+1}. {title}")

print("\n📋 Slides in NEW_DEFENSE (18 slides):")
new_titles = []
for i in range(len(prs_new.slides)):
    title, _ = get_slide_info(prs_new, i)
    new_titles.append(title)
    print(f"  {i+1}. {title}")

# Find potential missing content
print("\n" + "="*80)
print("ANALYSIS")
print("="*80)

# Check if all FINAL titles appear in NEW_DEFENSE
missing_from_new = []
for i, title in enumerate(final_titles):
    if title and title not in new_titles:
        missing_from_new.append((i+1, title))

if missing_from_new:
    print("\n⚠️  Slides from FINAL potentially missing in NEW_DEFENSE:")
    for slide_num, title in missing_from_new:
        print(f"  - Slide {slide_num}: {title}")
else:
    print("\n✓ All FINAL slide titles appear in NEW_DEFENSE")

# Check extra slides in NEW_DEFENSE
extra_in_new = []
for i, title in enumerate(new_titles):
    if title and title not in final_titles:
        extra_in_new.append((i+1, title))

if extra_in_new:
    print(f"\n📌 Extra slides in NEW_DEFENSE ({len(extra_in_new)}):")
    for slide_num, title in extra_in_new:
        print(f"  + Slide {slide_num}: {title}")

print("\n" + "="*80)
print("RECOMMENDATION")
print("="*80)
if len(extra_in_new) == 2 and len(missing_from_new) == 0:
    print("✓ NEW_DEFENSE appears to have 2 additional slides beyond FINAL.")
    print("  This is expected and likely represents enhanced content.")
    print("  No content from FINAL appears to be missing.")
elif len(missing_from_new) > 0:
    print("⚠️  Some content from FINAL may be missing in NEW_DEFENSE.")
    print("  Manual review recommended to determine if merge is needed.")
else:
    print("✓ Slide structure looks consistent.")
