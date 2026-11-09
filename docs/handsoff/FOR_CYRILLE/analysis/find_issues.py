"""
Search for remaining issues in SmartSpend_Defense.pptx:
- Any instance of '2025' (should be 0)
- Any problematic 'preliminary' language
"""

from pptx import Presentation

pptx_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
print(f"Scanning: {pptx_path}\n")

prs = Presentation(pptx_path)

issues_found = []

print("="*80)
print("SEARCHING FOR '2025'")
print("="*80)
found_2025 = False
for slide_idx, slide in enumerate(prs.slides, 1):
    for shape in slide.shapes:
        if hasattr(shape, 'text_frame'):
            text = shape.text_frame.text
            if '2025' in text:
                found_2025 = True
                print(f"❌ SLIDE {slide_idx}: Found '2025'")
                lines = text.split('\n')
                for line in lines:
                    if '2025' in line:
                        print(f"   → {line.strip()}")
                issues_found.append(f"Slide {slide_idx}: '2025' found")

if not found_2025:
    print("✓ No instances of '2025' found")

print("\n" + "="*80)
print("SEARCHING FOR PROBLEMATIC 'PRELIMINARY' LANGUAGE")
print("="*80)
found_preliminary = False
for slide_idx, slide in enumerate(prs.slides, 1):
    for shape in slide.shapes:
        if hasattr(shape, 'text_frame'):
            text = shape.text_frame.text
            text_lower = text.lower()
            
            # Check for preliminary with testing/results/findings context
            if 'preliminary' in text_lower:
                # These are OK contexts (e.g., "preliminary research phase")
                ok_contexts = ['preliminary research', 'preliminary study', 'preliminary investigation', 
                               'preliminary interview', 'preliminary survey']
                
                is_problematic = True
                for ok_context in ok_contexts:
                    if ok_context in text_lower:
                        is_problematic = False
                        break
                
                if is_problematic:
                    found_preliminary = True
                    print(f"⚠️  SLIDE {slide_idx}: Found 'preliminary'")
                    lines = text.split('\n')
                    for line in lines:
                        if 'preliminary' in line.lower():
                            print(f"   → {line.strip()}")
                    issues_found.append(f"Slide {slide_idx}: 'preliminary' found")

if not found_preliminary:
    print("✓ No problematic 'preliminary' language found")

print("\n" + "="*80)
print("SUMMARY")
print("="*80)
if len(issues_found) == 0:
    print("✅ PASSED: No critical issues found")
    exit(0)
else:
    print(f"❌ FAILED: {len(issues_found)} issue(s) found:")
    for issue in issues_found:
        print(f"   - {issue}")
    exit(1)
