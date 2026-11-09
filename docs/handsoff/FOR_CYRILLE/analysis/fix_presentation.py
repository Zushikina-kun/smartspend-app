"""
Fix critical issues in SmartSpend_Defense.pptx
- Slide 2: Change 'BSP CFIS 2025' to 'BSP CFIS 2026'
- Slide 15: Change 'preliminary developer testing only' to 'developer testing'
- Verify SUS score 61.83 and demographics are present
"""

from pptx import Presentation
import sys

def fix_presentation():
    pptx_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
    
    print(f"Opening presentation: {pptx_path}")
    prs = Presentation(pptx_path)
    
    total_slides = len(prs.slides)
    print(f"Total slides: {total_slides}")
    
    fixes_applied = []
    verification_results = {
        'sus_score_found': False,
        'demographics_found': False,
        'grade_d_found': False
    }
    
    # Fix Slide 2 (index 1): 2025 → 2026
    print("\n--- Fixing Slide 2: BSP CFIS 2025 → 2026 ---")
    slide_2 = prs.slides[1]
    slide_2_fixed = False
    for shape in slide_2.shapes:
        if hasattr(shape, 'text_frame'):
            for paragraph in shape.text_frame.paragraphs:
                for run in paragraph.runs:
                    if '2025' in run.text:
                        old_text = run.text
                        run.text = run.text.replace('2025', '2026')
                        print(f"  Fixed: '{old_text}' → '{run.text}'")
                        fixes_applied.append(f"Slide 2: Changed '{old_text}' to '{run.text}'")
                        slide_2_fixed = True
    
    if not slide_2_fixed:
        print("  No '2025' found in Slide 2 (may already be fixed)")
    
    # Fix Slide 15 (index 14): Remove "preliminary"
    print("\n--- Fixing Slide 15: Remove 'preliminary' language ---")
    if total_slides >= 15:
        slide_15 = prs.slides[14]
        slide_15_fixed = False
        for shape in slide_15.shapes:
            if hasattr(shape, 'text_frame'):
                for paragraph in shape.text_frame.paragraphs:
                    for run in paragraph.runs:
                        if 'preliminary developer testing only' in run.text.lower():
                            old_text = run.text
                            run.text = run.text.replace('preliminary developer testing only', 'developer testing')
                            run.text = run.text.replace('Preliminary developer testing only', 'Developer testing')
                            run.text = run.text.replace('preliminary Developer testing only', 'Developer testing')
                            print(f"  Fixed: '{old_text}' → '{run.text}'")
                            fixes_applied.append(f"Slide 15: Changed '{old_text}' to '{run.text}'")
                            slide_15_fixed = True
                        elif 'preliminary' in run.text.lower() and 'testing' in run.text.lower():
                            old_text = run.text
                            # Generic preliminary removal
                            run.text = run.text.replace('preliminary ', '')
                            run.text = run.text.replace('Preliminary ', '')
                            print(f"  Fixed: '{old_text}' → '{run.text}'")
                            fixes_applied.append(f"Slide 15: Removed 'preliminary' from '{old_text}'")
                            slide_15_fixed = True
        
        if not slide_15_fixed:
            print("  No 'preliminary' language found in Slide 15 (may already be fixed)")
    else:
        print(f"  WARNING: Presentation only has {total_slides} slides, cannot fix slide 15")
    
    # Verification: Search for SUS score 61.83
    print("\n--- Verifying Critical Values ---")
    for slide_idx, slide in enumerate(prs.slides, 1):
        for shape in slide.shapes:
            if hasattr(shape, 'text_frame'):
                text = shape.text_frame.text.lower()
                
                # Check for SUS score
                if '61.83' in text or '61.8' in text:
                    verification_results['sus_score_found'] = True
                    print(f"  ✓ SUS score found in Slide {slide_idx}")
                
                # Check for demographics
                if ('10 parents' in text or '10parents' in text) and ('20 young' in text or '20young' in text):
                    verification_results['demographics_found'] = True
                    print(f"  ✓ Demographics found in Slide {slide_idx}")
                
                if 'n=30' in text or 'n = 30' in text:
                    print(f"  ✓ N=30 found in Slide {slide_idx}")
                
                # Check for Grade D
                if 'grade d' in text:
                    verification_results['grade_d_found'] = True
                    print(f"  ✓ Grade D rating found in Slide {slide_idx}")
    
    # Save the presentation
    print(f"\n--- Saving presentation ---")
    prs.save(pptx_path)
    print(f"Saved: {pptx_path}")
    
    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"Total fixes applied: {len(fixes_applied)}")
    for fix in fixes_applied:
        print(f"  - {fix}")
    
    print(f"\nVerification Results:")
    print(f"  SUS Score 61.83: {'✓ FOUND' if verification_results['sus_score_found'] else '✗ NOT FOUND'}")
    print(f"  Demographics (10+20=30): {'✓ FOUND' if verification_results['demographics_found'] else '✗ NOT FOUND'}")
    print(f"  Grade D Rating: {'✓ FOUND' if verification_results['grade_d_found'] else '✗ NOT FOUND'}")
    
    if not all(verification_results.values()):
        print("\n⚠️  WARNING: Some critical values not found - manual verification recommended")
    
    return len(fixes_applied) > 0

if __name__ == '__main__':
    try:
        success = fix_presentation()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n❌ ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
