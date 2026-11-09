#!/usr/bin/env python3
"""
Fix all 35 issues identified in comprehensive_analysis.json for FEAT-002
"""

from docx import Document
import re
import sys

def fix_manuscript():
    doc_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
    
    print(f"Loading document: {doc_path}")
    doc = Document(doc_path)
    
    fixes_applied = []
    total_paragraphs = len(doc.paragraphs)
    
    # Process all paragraphs
    for i, para in enumerate(doc.paragraphs):
        if not para.text.strip():
            continue
            
        original_text = para.text
        modified = False
        
        # Fix 1: BSP CFIS 2025 → 2026 (paragraphs 95, 127-134, 375 and slide 2 issue)
        if 'BSP CFIS 2025' in para.text or 'BSP, 2021' in para.text:
            for run in para.runs:
                if 'BSP CFIS 2025' in run.text:
                    run.text = run.text.replace('BSP CFIS 2025', 'BSP CFIS 2026')
                    modified = True
                # Also handle variations
                if 'BSP, 2021' in run.text:
                    run.text = run.text.replace('BSP, 2021', 'BSP CFIS, 2026')
                    modified = True
        
        # Fix 2: Update bibliography citations from 2024/2025 to 2026 for recent sources
        # Paragraphs 371, 375, 391, 400, 401, 404, 407, 411, 417, 418, 423
        # These are citations, so we update the year in the format (Year)
        if '(2024)' in para.text or '(2025)' in para.text:
            # Check if this is a references/bibliography paragraph
            if any(indicator in para.text for indicator in ['Anthropic', 'Bangko Sentral', 'Flores', 'Hean', 'Inquiro', 'Li, Z.', 'Meta AI', 'OpenAI', 'Statista', 'Stefanov', 'Wajid']):
                for run in para.runs:
                    # Update citation years
                    if '(2024)' in run.text:
                        run.text = run.text.replace('(2024)', '(2026)')
                        modified = True
                    if '(2025)' in run.text:
                        run.text = run.text.replace('(2025)', '(2026)')
                        modified = True
        
        # Fix 3: Remove "preliminary" (paragraphs 344, 346)
        if 'preliminary' in para.text.lower():
            for run in para.runs:
                # Remove the word but keep sentence structure
                run.text = run.text.replace('preliminary ', '')
                run.text = run.text.replace('Preliminary ', '')
                modified = True
        
        # Fix 4: Remove "pending" (paragraph 297)
        # Be careful not to affect words like "spending" or "pending" in other contexts
        if i == 297 or ('pending' in para.text.lower() and 'pending' in para.text):
            for run in para.runs:
                # Only remove standalone "pending"
                run.text = re.sub(r'\bpending\b', '', run.text, flags=re.IGNORECASE)
                run.text = re.sub(r'\bPending\b', '', run.text)
                modified = True
        
        # Fix 5: Remove "placeholder" (paragraphs 173, 312)
        if 'placeholder' in para.text.lower():
            for run in para.runs:
                run.text = run.text.replace('placeholder', '')
                run.text = run.text.replace('Placeholder', '')
                modified = True
        
        # Fix 6: Update CV/Resume dates 2025 → 2026 (paragraphs 574, 603, 608, 634, 641)
        # These are in the appendix/CV section (paragraph numbers > 570)
        if i >= 570:
            if '2025' in para.text:
                for run in para.runs:
                    # Update years in CV context
                    if 'PSA' in para.text or 'McDonald' in para.text or 'Conference' in para.text or 'Dean' in para.text or 'Seminar' in para.text or 'StartUp' in para.text:
                        run.text = run.text.replace('2025', '2026')
                        run.text = run.text.replace('2023–2025', '2023–2026')
                        modified = True
        
        if modified:
            fixes_applied.append({
                'paragraph': i,
                'original': original_text[:80] + '...' if len(original_text) > 80 else original_text,
                'modified': para.text[:80] + '...' if len(para.text) > 80 else para.text
            })
    
    # Save the document
    print(f"\nSaving fixed document...")
    doc.save(doc_path)
    
    # Print summary
    print(f"\n{'='*80}")
    print(f"MANUSCRIPT FIX SUMMARY")
    print(f"{'='*80}")
    print(f"Total paragraphs processed: {total_paragraphs}")
    print(f"Total fixes applied: {len(fixes_applied)}")
    print(f"\nDetailed fixes:")
    for fix in fixes_applied:
        print(f"\n  Paragraph {fix['paragraph']}:")
        print(f"    Before: {fix['original']}")
        print(f"    After:  {fix['modified']}")
    
    return len(fixes_applied)

if __name__ == "__main__":
    try:
        count = fix_manuscript()
        print(f"\n{'='*80}")
        print(f"✓ Successfully applied {count} fixes to manuscript")
        print(f"{'='*80}")
        sys.exit(0)
    except Exception as e:
        print(f"\n✗ Error: {e}", file=sys.stderr)
        sys.exit(1)
