"""
Manual verification script - extracts actual text from DOCX and checks critical issues
"""

from docx import Document
from pptx import Presentation
import re

def check_manuscript_2025():
    """Check manuscript for 2025 references"""
    doc = Document(r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx")
    
    print("=" * 80)
    print("CHECKING MANUSCRIPT FOR 2025 REFERENCES")
    print("=" * 80)
    
    issues = []
    for i, para in enumerate(doc.paragraphs, 1):
        text = para.text
        if "2025" in text:
            # Check context - is it in CV/References/Historical?
            context_lower = text.lower()
            if any(kw in context_lower for kw in ["curriculum", "vitae", "born", "graduated", "reference", "citation"]):
                print(f"Para {i}: OK (CV/Reference context): {text[:100]}")
            else:
                print(f"Para {i}: ⚠️ NEEDS CHECK: {text[:150]}")
                issues.append((i, text[:150]))
    
    print(f"\nTotal 2025 mentions needing review: {len(issues)}")
    return issues

def check_script_2025():
    """Check script for 2025 references"""
    with open(r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md", 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    print("\n" + "=" * 80)
    print("CHECKING SCRIPT FOR 2025 REFERENCES")
    print("=" * 80)
    
    issues = []
    for i, line in enumerate(lines, 1):
        if "2025" in line:
            print(f"Line {i}: {line.strip()}")
            issues.append((i, line.strip()))
    
    print(f"\nTotal 2025 mentions: {len(issues)}")
    return issues

def check_manuscript_sections():
    """Check if required sections exist"""
    doc = Document(r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx")
    
    print("\n" + "=" * 80)
    print("CHECKING MANUSCRIPT SECTIONS")
    print("=" * 80)
    
    full_text = "\n".join([p.text for p in doc.paragraphs])
    
    sections = {
        "Abstract": ["abstract", "ABSTRACT"],
        "Acknowledgment": ["acknowledgment", "ACKNOWLEDGMENT", "acknowledgement", "ACKNOWLEDGEMENT"],
        "Chapter I": ["CHAPTER I", "Chapter I", "CHAPTER 1", "Chapter 1"],
        "Chapter II": ["CHAPTER II", "Chapter II", "CHAPTER 2", "Chapter 2"],
        "Chapter III": ["CHAPTER III", "Chapter III", "CHAPTER 3", "Chapter 3"],
        "Chapter IV": ["CHAPTER IV", "Chapter IV", "CHAPTER 4", "Chapter 4"],
        "Chapter V": ["CHAPTER V", "Chapter V", "CHAPTER 5", "Chapter 5"],
    }
    
    for section, patterns in sections.items():
        found = any(p in full_text for p in patterns)
        status = "✅" if found else "❌"
        print(f"{status} {section}")
    
def check_script_structure():
    """Check script structure"""
    with open(r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md", 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("\n" + "=" * 80)
    print("CHECKING SCRIPT STRUCTURE")
    print("=" * 80)
    
    # Check for slide headers (various patterns)
    patterns = [
        r'##\s*Slide\s+\d+',
        r'###\s*Slide\s+\d+',
        r'\*\*Slide\s+\d+',
        r'Slide\s+\d+:',
    ]
    
    for pattern in patterns:
        matches = re.findall(pattern, content, re.IGNORECASE)
        if matches:
            print(f"Pattern '{pattern}' found {len(matches)} times")
            print(f"First 5 matches: {matches[:5]}")

def check_presentation_dates():
    """Check presentation for date errors"""
    prs = Presentation(r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx")
    
    print("\n" + "=" * 80)
    print("CHECKING PRESENTATION FOR 2025 REFERENCES")
    print("=" * 80)
    
    for i, slide in enumerate(prs.slides, 1):
        slide_text = []
        for shape in slide.shapes:
            if hasattr(shape, "text"):
                slide_text.append(shape.text)
        full_text = "\n".join(slide_text)
        
        if "2025" in full_text:
            print(f"\nSlide {i}:")
            print(full_text[:300])

if __name__ == "__main__":
    check_manuscript_2025()
    check_script_2025()
    check_manuscript_sections()
    check_script_structure()
    check_presentation_dates()
