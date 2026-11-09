"""
Analyze AI_POWERED and AI_ASSISTED presentations for potential improvements:
- Logo usage (Lorma Colleges, CCSE)
- Layout quality
- Chart/image quality
- Additional context
"""

from pptx import Presentation
from pptx.enum.shapes import MSO_SHAPE_TYPE

def analyze_presentation(pptx_path, name):
    print(f"\n{'='*80}")
    print(f"ANALYZING: {name}")
    print(f"Path: {pptx_path}")
    print('='*80)
    
    prs = Presentation(pptx_path)
    
    print(f"Total Slides: {len(prs.slides)}")
    
    # Track logos and images
    logo_keywords = ['lorma', 'ccse', 'college', 'university', 'logo']
    logos_found = []
    charts_found = 0
    tables_found = 0
    
    for slide_idx, slide in enumerate(prs.slides, 1):
        slide_has_logo = False
        
        for shape in slide.shapes:
            # Check for images/pictures
            if shape.shape_type == MSO_SHAPE_TYPE.PICTURE:
                # Check if it might be a logo (usually smaller)
                if hasattr(shape, 'name'):
                    name_lower = shape.name.lower()
                    for keyword in logo_keywords:
                        if keyword in name_lower:
                            if not slide_has_logo:
                                logos_found.append((slide_idx, shape.name))
                                slide_has_logo = True
            
            # Check for charts
            elif shape.shape_type == MSO_SHAPE_TYPE.CHART:
                charts_found += 1
            
            # Check for tables
            elif shape.shape_type == MSO_SHAPE_TYPE.TABLE:
                tables_found += 1
    
    print(f"Charts: {charts_found}")
    print(f"Tables: {tables_found}")
    
    if logos_found:
        print(f"\n🎨 Potential Logos Found ({len(logos_found)}):")
        for slide_num, logo_name in logos_found[:10]:  # Show first 10
            print(f"  - Slide {slide_num}: {logo_name}")
    else:
        print("\n⚠️  No obvious logos detected by keyword search")
    
    # Sample slide titles
    print(f"\n📋 Sample Slide Titles:")
    for i in range(min(5, len(prs.slides))):
        for shape in prs.slides[i].shapes:
            if hasattr(shape, 'text_frame'):
                text = shape.text_frame.text.strip()
                if text and len(text) < 150:
                    print(f"  {i+1}. {text}")
                    break
    
    return {
        'total_slides': len(prs.slides),
        'charts': charts_found,
        'tables': tables_found,
        'logos': len(logos_found)
    }

# Analyze both reference presentations
ai_powered_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\SMARTSPEND AI-Powered Receipt Expense Tracker for Personal Finance Management.pptx'
ai_assisted_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\SmartSpend An AI-Assisted Receipt and Expense Tracker for Personal Financial Management.pptx'

stats_powered = analyze_presentation(ai_powered_path, "AI_POWERED")
stats_assisted = analyze_presentation(ai_assisted_path, "AI_ASSISTED")

print(f"\n{'='*80}")
print("SUMMARY")
print('='*80)
print(f"AI_POWERED: {stats_powered['total_slides']} slides, {stats_powered['charts']} charts, {stats_powered['logos']} potential logos")
print(f"AI_ASSISTED: {stats_assisted['total_slides']} slides, {stats_assisted['charts']} charts, {stats_assisted['logos']} potential logos")

print("\n💡 RECOMMENDATIONS:")
print("  1. These appear to be earlier/alternative versions of the presentation")
print("  2. NEW_DEFENSE (SmartSpend_Defense.pptx) is the most current version")
print("  3. If specific logos or layouts are needed, they should be copied manually")
print("  4. The comprehensive_analysis.py found 1 issue each in these reference files")
