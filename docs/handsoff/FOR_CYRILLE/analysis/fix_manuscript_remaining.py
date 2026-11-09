#!/usr/bin/env python3
"""
Fix remaining issues in manuscript after first pass
"""

from docx import Document
import sys

def fix_remaining_issues():
    doc_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
    
    print(f"Loading document: {doc_path}")
    doc = Document(doc_path)
    
    fixes_applied = []
    
    # Fix paragraph 375: "Consumer Finance and Inclusion Survey (CFIS) 2025" → "CFIS 2026"
    # This is the survey title, should be 2026
    para = doc.paragraphs[375]
    if 'CFIS) 2025' in para.text or 'CFIS 2025' in para.text:
        for run in para.runs:
            if 'CFIS) 2025' in run.text:
                run.text = run.text.replace('CFIS) 2025', 'CFIS) 2026')
                fixes_applied.append(f"Para 375: Fixed CFIS survey year")
            if 'CFIS 2025' in run.text:
                run.text = run.text.replace('CFIS 2025', 'CFIS 2026')
                fixes_applied.append(f"Para 375: Fixed CFIS survey year")
    
    # Fix paragraph 312: Remove any remaining "placeholder" text
    para = doc.paragraphs[312]
    if 'placeholder' in para.text.lower():
        for run in para.runs:
            run.text = run.text.replace('placeholder', '').replace('Placeholder', '')
            fixes_applied.append(f"Para 312: Removed placeholder")
    
    # Fix paragraph 641: Update CV date "2024" → "2026"
    para = doc.paragraphs[641]
    if '2024' in para.text:
        for run in para.runs:
            run.text = run.text.replace('2024', '2026')
            fixes_applied.append(f"Para 641: Updated CV date 2024→2026")
    
    # Save the document
    print(f"\nSaving fixed document...")
    doc.save(doc_path)
    
    # Print summary
    print(f"\n{'='*80}")
    print(f"REMAINING FIXES APPLIED")
    print(f"{'='*80}")
    for fix in fixes_applied:
        print(f"  ✓ {fix}")
    
    return len(fixes_applied)

if __name__ == "__main__":
    try:
        count = fix_remaining_issues()
        print(f"\n{'='*80}")
        print(f"✓ Successfully applied {count} additional fixes")
        print(f"{'='*80}")
        sys.exit(0)
    except Exception as e:
        print(f"\n✗ Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
