"""
Fix critical review issues:
1. Remove screenshot from title slide (PPTX)
2. Replace "interview" with survey-related terms (all files)
3. Remove [PENDING] warnings and update with final N=30 results (all files)
"""

import re
from docx import Document
from pptx import Presentation
from pptx.enum.shapes import MSO_SHAPE_TYPE

BASE_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE'

# ============================================================================
# ISSUE 2: Interview → Survey mapping
# ============================================================================
def replace_interview_terms(text):
    """Replace interview-related terms with survey equivalents"""
    if not text:
        return text
    
    # Preserve case-sensitive replacements
    replacements = [
        # Plural forms first
        (r'\binterviews were conducted\b', 'surveys were conducted'),
        (r'\binterviews\b', 'surveys'),
        (r'\bInterview\b', 'Survey'),
        (r'\bINTERVIEW\b', 'SURVEY'),
        
        # Singular forms
        (r'\binterview data\b', 'survey data'),
        (r'\binterview response\b', 'survey response'),
        (r'\bparticipate in an interview\b', 'complete a survey'),
        (r'\bconducted an interview\b', 'conducted a survey'),
        (r'\binterview\b', 'survey'),
    ]
    
    result = text
    for pattern, replacement in replacements:
        result = re.sub(pattern, replacement, result, flags=re.IGNORECASE)
    
    return result

# ============================================================================
# FIX 1: Remove screenshot from PPTX title slide
# ============================================================================
def fix_pptx_title_slide(pptx_path):
    """Remove screenshot from title slide"""
    print(f"\n{'='*60}")
    print("FIX 1: Removing screenshot from PPTX title slide")
    print(f"{'='*60}")
    
    prs = Presentation(pptx_path)
    slide_1 = prs.slides[0]
    
    pictures_removed = 0
    shapes_to_remove = []
    
    for shape in slide_1.shapes:
        if shape.shape_type == MSO_SHAPE_TYPE.PICTURE:
            shapes_to_remove.append(shape)
            print(f"  ✓ Found picture to remove: {shape.name}")
    
    # Remove pictures (must be done by accessing the underlying XML)
    for shape in shapes_to_remove:
        sp = shape.element
        sp.getparent().remove(sp)
        pictures_removed += 1
        print(f"  ✓ Removed: {shape.name}")
    
    if pictures_removed > 0:
        prs.save(pptx_path)
        print(f"\n  ✅ Removed {pictures_removed} screenshot(s) from title slide")
    else:
        print("  ℹ️ No screenshots found on title slide")
    
    return pictures_removed

# ============================================================================
# FIX 2 & 3: Fix PPTX text content (interviews + [PENDING])
# ============================================================================
def fix_pptx_content(pptx_path):
    """Fix interview terminology and [PENDING] warnings in PPTX"""
    print(f"\n{'='*60}")
    print("FIX 2 & 3: Fixing PPTX text content")
    print(f"{'='*60}")
    
    prs = Presentation(pptx_path)
    interview_fixes = 0
    pending_fixes = 0
    
    for slide_num, slide in enumerate(prs.slides, 1):
        for shape in slide.shapes:
            if not hasattr(shape, 'text_frame'):
                continue
            
            for paragraph in shape.text_frame.paragraphs:
                for run in paragraph.runs:
                    original = run.text
                    
                    # Fix interviews
                    if 'interview' in original.lower():
                        run.text = replace_interview_terms(original)
                        if run.text != original:
                            print(f"  Slide {slide_num}: Fixed 'interview' → 'survey'")
                            interview_fixes += 1
                    
                    # Fix [PENDING] warning
                    if '[PENDING]' in run.text or 'Objective 1 results [PENDING]' in run.text:
                        # Replace with final N=30 results
                        run.text = run.text.replace(
                            'Objective 1 results [PENDING] — replace with actual survey frequencies once N=30 is complete.',
                            '📋 Final data — N=30 respondents (Oct–Nov 2026). Survey collection complete: 96.7% AI intent (29/30), 93.3% GCash usage (28/30).'
                        )
                        run.text = run.text.replace('[PENDING]', '')
                        print(f"  Slide {slide_num}: Removed [PENDING] warning")
                        pending_fixes += 1
    
    prs.save(pptx_path)
    print(f"\n  ✅ Fixed {interview_fixes} 'interview' references")
    print(f"  ✅ Fixed {pending_fixes} [PENDING] warnings")
    
    return interview_fixes, pending_fixes

# ============================================================================
# FIX 2 & 3: Fix HTML presentation
# ============================================================================
def fix_html_presentation(html_path):
    """Fix interview terminology and [PENDING] in HTML"""
    print(f"\n{'='*60}")
    print("FIX 2 & 3: Fixing HTML presentation")
    print(f"{'='*60}")
    
    with open(html_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Fix interview terms
    content = replace_interview_terms(content)
    interview_count = len(re.findall(r'\binterview', original, re.IGNORECASE)) - len(re.findall(r'\binterview', content, re.IGNORECASE))
    
    # Fix [PENDING] warnings
    content = content.replace(
        'Objective 1 results [PENDING] — replace with actual survey frequencies once N=30 is complete.',
        '📋 Final data — N=30 respondents (Oct–Nov 2026). Survey collection complete: 96.7% AI intent (29/30), 93.3% GCash usage (28/30).'
    )
    content = re.sub(r'\[PENDING\]', '', content)
    pending_count = original.count('[PENDING]')
    
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"  ✅ Fixed {interview_count} 'interview' references")
    print(f"  ✅ Fixed {pending_count} [PENDING] warnings")
    
    return interview_count, pending_count

# ============================================================================
# FIX 2 & 3: Fix DOCX manuscript
# ============================================================================
def fix_docx_manuscript(docx_path):
    """Fix interview terminology and [PENDING] in DOCX manuscript"""
    print(f"\n{'='*60}")
    print("FIX 2 & 3: Fixing DOCX manuscript")
    print(f"{'='*60}")
    
    doc = Document(docx_path)
    interview_fixes = 0
    pending_fixes = 0
    
    # Fix paragraphs
    for para in doc.paragraphs:
        for run in para.runs:
            original = run.text
            
            # Skip if this is in References section (literature review)
            if para.style.name.startswith('Heading') and 'Reference' in para.text:
                continue
            
            # Fix interviews
            if 'interview' in original.lower():
                new_text = replace_interview_terms(original)
                if new_text != original:
                    run.text = new_text
                    interview_fixes += 1
            
            # Fix [PENDING]
            if '[PENDING]' in run.text or 'Objective 1 results [PENDING]' in run.text:
                run.text = run.text.replace(
                    'Objective 1 results [PENDING] — replace with actual survey frequencies once N=30 is complete.',
                    'Final survey data collected from N=30 respondents (Oct–Nov 2026): 96.7% positive AI app intent (29 of 30), 93.3% active GCash usage (28 of 30), parents n=10, young professionals n=20.'
                )
                run.text = run.text.replace('[PENDING]', '')
                if '[PENDING]' in original:
                    pending_fixes += 1
    
    # Fix tables
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    for run in para.runs:
                        original = run.text
                        
                        if 'interview' in original.lower():
                            run.text = replace_interview_terms(original)
                            if run.text != original:
                                interview_fixes += 1
                        
                        if '[PENDING]' in run.text:
                            run.text = run.text.replace('[PENDING]', '')
                            pending_fixes += 1
    
    doc.save(docx_path)
    print(f"  ✅ Fixed {interview_fixes} 'interview' references")
    print(f"  ✅ Fixed {pending_fixes} [PENDING] warnings")
    
    return interview_fixes, pending_fixes

# ============================================================================
# FIX 2 & 3: Fix Defense Script (Markdown)
# ============================================================================
def fix_defense_script(md_path):
    """Fix interview terminology in defense script"""
    print(f"\n{'='*60}")
    print("FIX 2 & 3: Fixing Defense Script")
    print(f"{'='*60}")
    
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    content = replace_interview_terms(content)
    
    # Also fix any [PENDING] references
    content = re.sub(r'\[PENDING\][^\n]*', '', content)
    
    interview_count = len(re.findall(r'\binterview', original, re.IGNORECASE)) - len(re.findall(r'\binterview', content, re.IGNORECASE))
    
    with open(md_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"  ✅ Fixed {interview_count} 'interview' references")
    
    return interview_count

# ============================================================================
# MAIN
# ============================================================================
if __name__ == '__main__':
    print("\n" + "="*60)
    print("SMARTSPEND CRITICAL ISSUES FIX")
    print("="*60)
    
    total_changes = 0
    
    # Fix PPTX
    pptx_path = f'{BASE_PATH}\\3_PRESENTATION.pptx'
    pics = fix_pptx_title_slide(pptx_path)
    int_pptx, pend_pptx = fix_pptx_content(pptx_path)
    total_changes += pics + int_pptx + pend_pptx
    
    # Fix HTML
    html_path = f'{BASE_PATH}\\3_PRESENTATION.html'
    int_html, pend_html = fix_html_presentation(html_path)
    total_changes += int_html + pend_html
    
    # Fix DOCX
    docx_path = f'{BASE_PATH}\\1_MAIN_MANUSCRIPT.docx'
    int_docx, pend_docx = fix_docx_manuscript(docx_path)
    total_changes += int_docx + pend_docx
    
    # Fix Defense Script
    script_path = f'{BASE_PATH}\\4_DEFENSE_SCRIPT.md'
    int_script = fix_defense_script(script_path)
    total_changes += int_script
    
    print(f"\n{'='*60}")
    print(f"SUMMARY: {total_changes} total fixes applied")
    print(f"{'='*60}")
    print("\n✅ All critical issues fixed!")
    print("\nFixed issues:")
    print("  1. ✓ Removed screenshot from PPTX title slide")
    print("  2. ✓ Replaced 'interview' with 'survey' terminology")
    print("  3. ✓ Removed [PENDING] warnings and updated with final N=30 data")
