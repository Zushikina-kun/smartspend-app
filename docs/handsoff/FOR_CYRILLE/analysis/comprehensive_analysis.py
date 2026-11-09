"""
Comprehensive Defense Documents Analysis Script
Analyzes all presentations, manuscripts, and script for inconsistencies
"""

import json
import re
from collections import defaultdict
from pathlib import Path
from pptx import Presentation
from docx import Document
import PyPDF2

# Define file paths
BASE_DIR = Path(r"c:\xampp\htdocs\smartspend_app\docs\handsoff")
FOR_CYRILLE = BASE_DIR / "FOR_CYRILLE"
ANALYSIS_DIR = FOR_CYRILLE / "analysis"
ANALYSIS_DIR.mkdir(exist_ok=True)

# Presentation files
PRESENTATIONS = {
    "FINAL": FOR_CYRILLE / "3_PRESENTATION_FINAL.pptx",
    "NEW_DEFENSE": FOR_CYRILLE / "SmartSpend_Defense.pptx",
    "AI_POWERED": BASE_DIR / "SMARTSPEND AI-Powered Receipt Expense Tracker for Personal Finance Management.pptx",
    "AI_ASSISTED": BASE_DIR / "SmartSpend An AI-Assisted Receipt and Expense Tracker for Personal Financial Management.pptx",
}

# Document files
MANUSCRIPT_DOCX = FOR_CYRILLE / "1_MAIN_MANUSCRIPT_FINAL.docx"
MANUSCRIPT_PDF = FOR_CYRILLE / "1_MAIN_MANUSCRIPT_FINAL.docx.pdf"
SCRIPT_FILE = FOR_CYRILLE / "4_DEFENSE_SCRIPT_FINAL.md"

# Critical values to check
CRITICAL_VALUES = {
    "SUS_MEAN": "61.83",
    "DEMOGRAPHICS_PARENTS": "10",
    "DEMOGRAPHICS_YOUNG_PROFESSIONALS": "20",
    "TOTAL_PARTICIPANTS": "30",
    "SUS_GRADE": "D",
}

# Patterns to search for issues
ISSUE_PATTERNS = {
    "preliminary": re.compile(r"\bpreliminary\b", re.IGNORECASE),
    "pending": re.compile(r"\bpending\b", re.IGNORECASE),
    "placeholder": re.compile(r"\b(placeholder|todo|tbd|fix|xxx)\b", re.IGNORECASE),
    "old_dates": re.compile(r"\b(2024|2025)\b"),
}

def analyze_presentation(ppt_path, name):
    """Analyze a single presentation file"""
    print(f"\n{'='*60}")
    print(f"Analyzing: {name}")
    print(f"Path: {ppt_path}")
    print(f"{'='*60}")
    
    if not ppt_path.exists():
        return {
            "name": name,
            "path": str(ppt_path),
            "error": "File not found",
        }
    
    try:
        prs = Presentation(str(ppt_path))
        
        analysis = {
            "name": name,
            "path": str(ppt_path),
            "file_size": ppt_path.stat().st_size,
            "slide_count": len(prs.slides),
            "slides": [],
            "fonts_used": set(),
            "issues_found": [],
            "numerical_data": {},
            "has_images": 0,
            "has_charts": 0,
            "has_tables": 0,
        }
        
        # Analyze each slide
        for slide_idx, slide in enumerate(prs.slides, 1):
            slide_info = {
                "slide_number": slide_idx,
                "layout_name": slide.slide_layout.name if slide.slide_layout else "Unknown",
                "shapes_count": len(slide.shapes),
                "text_content": [],
                "has_title": False,
                "has_images": False,
                "has_charts": False,
                "has_tables": False,
            }
            
            # Extract text and check for issues
            for shape in slide.shapes:
                # Check for title
                if hasattr(shape, "is_placeholder") and shape.is_placeholder:
                    if shape.placeholder_format.type == 1:  # Title placeholder
                        slide_info["has_title"] = True
                
                # Check for images
                if shape.shape_type == 13:  # Picture
                    slide_info["has_images"] = True
                    analysis["has_images"] += 1
                
                # Check for charts
                if shape.shape_type == 3:  # Chart
                    slide_info["has_charts"] = True
                    analysis["has_charts"] += 1
                
                # Check for tables
                if shape.shape_type == 19:  # Table
                    slide_info["has_tables"] = True
                    analysis["has_tables"] += 1
                
                # Extract text
                if hasattr(shape, "text"):
                    text = shape.text.strip()
                    if text:
                        slide_info["text_content"].append(text)
                        
                        # Check for issues
                        for issue_name, pattern in ISSUE_PATTERNS.items():
                            if pattern.search(text):
                                analysis["issues_found"].append({
                                    "slide": slide_idx,
                                    "issue_type": issue_name,
                                    "text": text[:100],
                                })
                        
                        # Extract numerical data
                        if "61.83" in text or "SUS" in text:
                            analysis["numerical_data"][f"slide_{slide_idx}_sus"] = text
                        if "30" in text and ("participant" in text.lower() or "respondent" in text.lower()):
                            analysis["numerical_data"][f"slide_{slide_idx}_participants"] = text
                        if "parent" in text.lower() or "young professional" in text.lower():
                            analysis["numerical_data"][f"slide_{slide_idx}_demographics"] = text
                
                # Extract fonts
                if hasattr(shape, "text_frame"):
                    for paragraph in shape.text_frame.paragraphs:
                        for run in paragraph.runs:
                            if run.font.name:
                                analysis["fonts_used"].add(run.font.name)
            
            analysis["slides"].append(slide_info)
        
        # Convert sets to lists for JSON serialization
        analysis["fonts_used"] = sorted(list(analysis["fonts_used"]))
        
        print(f"✓ {name}: {analysis['slide_count']} slides, {analysis['has_images']} images, {len(analysis['issues_found'])} issues")
        
        return analysis
        
    except Exception as e:
        print(f"✗ Error analyzing {name}: {str(e)}")
        return {
            "name": name,
            "path": str(ppt_path),
            "error": str(e),
        }

def analyze_manuscript_docx():
    """Analyze the manuscript DOCX file"""
    print(f"\n{'='*60}")
    print(f"Analyzing Manuscript DOCX")
    print(f"{'='*60}")
    
    if not MANUSCRIPT_DOCX.exists():
        return {"error": "DOCX file not found"}
    
    try:
        doc = Document(str(MANUSCRIPT_DOCX))
        
        analysis = {
            "path": str(MANUSCRIPT_DOCX),
            "paragraphs_count": len(doc.paragraphs),
            "tables_count": len(doc.tables),
            "sections_count": len(doc.sections),
            "issues_found": [],
            "numerical_data": {},
            "headings": [],
        }
        
        # Extract text and check for issues
        for para_idx, para in enumerate(doc.paragraphs):
            text = para.text.strip()
            if not text:
                continue
            
            # Capture headings
            if para.style.name.startswith("Heading"):
                analysis["headings"].append({
                    "level": para.style.name,
                    "text": text[:100],
                })
            
            # Check for issues
            for issue_name, pattern in ISSUE_PATTERNS.items():
                if pattern.search(text):
                    analysis["issues_found"].append({
                        "paragraph": para_idx,
                        "issue_type": issue_name,
                        "text": text[:100],
                    })
            
            # Extract numerical data
            if "61.83" in text or "SUS" in text.upper():
                analysis["numerical_data"][f"para_{para_idx}_sus"] = text[:200]
            if "30" in text and ("participant" in text.lower() or "respondent" in text.lower()):
                analysis["numerical_data"][f"para_{para_idx}_participants"] = text[:200]
            if "parent" in text.lower() or "young professional" in text.lower():
                if "10" in text or "20" in text:
                    analysis["numerical_data"][f"para_{para_idx}_demographics"] = text[:200]
        
        print(f"✓ Manuscript DOCX: {analysis['paragraphs_count']} paragraphs, {analysis['tables_count']} tables, {len(analysis['issues_found'])} issues")
        
        return analysis
        
    except Exception as e:
        print(f"✗ Error analyzing manuscript DOCX: {str(e)}")
        return {"error": str(e)}

def analyze_manuscript_pdf():
    """Analyze the manuscript PDF file"""
    print(f"\n{'='*60}")
    print(f"Analyzing Manuscript PDF")
    print(f"{'='*60}")
    
    if not MANUSCRIPT_PDF.exists():
        return {"error": "PDF file not found"}
    
    try:
        with open(MANUSCRIPT_PDF, 'rb') as f:
            pdf = PyPDF2.PdfReader(f)
            
            analysis = {
                "path": str(MANUSCRIPT_PDF),
                "pages_count": len(pdf.pages),
                "issues_found": [],
                "numerical_data": {},
            }
            
            # Extract text from each page
            for page_idx, page in enumerate(pdf.pages):
                text = page.extract_text()
                
                # Check for issues
                for issue_name, pattern in ISSUE_PATTERNS.items():
                    if pattern.search(text):
                        matches = pattern.findall(text)
                        analysis["issues_found"].append({
                            "page": page_idx + 1,
                            "issue_type": issue_name,
                            "count": len(matches),
                        })
                
                # Extract numerical data
                if "61.83" in text:
                    analysis["numerical_data"][f"page_{page_idx+1}_sus"] = "Found SUS score"
                if "30" in text and ("participant" in text.lower() or "respondent" in text.lower()):
                    analysis["numerical_data"][f"page_{page_idx+1}_participants"] = "Found participant count"
        
        print(f"✓ Manuscript PDF: {analysis['pages_count']} pages, {len(analysis['issues_found'])} issues")
        
        return analysis
        
    except Exception as e:
        print(f"✗ Error analyzing manuscript PDF: {str(e)}")
        return {"error": str(e)}

def analyze_script():
    """Analyze the defense script"""
    print(f"\n{'='*60}")
    print(f"Analyzing Defense Script")
    print(f"{'='*60}")
    
    if not SCRIPT_FILE.exists():
        return {"error": "Script file not found"}
    
    try:
        with open(SCRIPT_FILE, 'r', encoding='utf-8') as f:
            content = f.read()
        
        analysis = {
            "path": str(SCRIPT_FILE),
            "lines_count": len(content.split('\n')),
            "word_count": len(content.split()),
            "issues_found": [],
            "numerical_data": {},
            "slide_references": [],
        }
        
        # Check for issues
        for issue_name, pattern in ISSUE_PATTERNS.items():
            matches = pattern.findall(content)
            if matches:
                analysis["issues_found"].append({
                    "issue_type": issue_name,
                    "count": len(matches),
                })
        
        # Extract slide references
        slide_refs = re.findall(r'slide\s*#?(\d+)', content, re.IGNORECASE)
        analysis["slide_references"] = sorted(list(set(map(int, slide_refs))))
        
        # Extract numerical data
        if "61.83" in content:
            analysis["numerical_data"]["sus_score"] = "Found"
        if "30" in content and ("participant" in content.lower() or "respondent" in content.lower()):
            analysis["numerical_data"]["participants"] = "Found"
        
        print(f"✓ Script: {analysis['lines_count']} lines, {analysis['word_count']} words, {len(analysis['slide_references'])} slide references")
        
        return analysis
        
    except Exception as e:
        print(f"✗ Error analyzing script: {str(e)}")
        return {"error": str(e)}

def compare_presentations(analyses):
    """Compare all presentations to identify the best one"""
    print(f"\n{'='*60}")
    print(f"Comparing Presentations")
    print(f"{'='*60}")
    
    comparison = {
        "summary": {},
        "recommendation": "",
        "reasons": [],
    }
    
    for name, analysis in analyses.items():
        if "error" in analysis:
            continue
        
        comparison["summary"][name] = {
            "slide_count": analysis.get("slide_count", 0),
            "file_size": analysis.get("file_size", 0),
            "has_images": analysis.get("has_images", 0),
            "has_charts": analysis.get("has_charts", 0),
            "has_tables": analysis.get("has_tables", 0),
            "issues_count": len(analysis.get("issues_found", [])),
            "fonts_count": len(analysis.get("fonts_used", [])),
        }
    
    # Determine recommendation
    if all(name in analyses and "error" not in analyses[name] for name in ["FINAL", "NEW_DEFENSE"]):
        final = comparison["summary"].get("FINAL", {})
        new_defense = comparison["summary"].get("NEW_DEFENSE", {})
        
        if new_defense.get("slide_count", 0) > final.get("slide_count", 0):
            comparison["recommendation"] = "NEW_DEFENSE"
            comparison["reasons"].append("Has more slides than FINAL")
        elif new_defense.get("issues_count", 999) < final.get("issues_count", 999):
            comparison["recommendation"] = "NEW_DEFENSE"
            comparison["reasons"].append("Has fewer issues than FINAL")
        else:
            comparison["recommendation"] = "FINAL"
            comparison["reasons"].append("Currently marked as FINAL version")
    
    return comparison

def main():
    """Main analysis function"""
    print("\n" + "="*60)
    print("COMPREHENSIVE DEFENSE DOCUMENTS ANALYSIS")
    print("="*60)
    
    results = {
        "presentations": {},
        "manuscript_docx": {},
        "manuscript_pdf": {},
        "script": {},
        "comparison": {},
        "critical_values_check": {},
    }
    
    # Analyze all presentations
    for name, path in PRESENTATIONS.items():
        results["presentations"][name] = analyze_presentation(path, name)
    
    # Analyze manuscripts
    results["manuscript_docx"] = analyze_manuscript_docx()
    results["manuscript_pdf"] = analyze_manuscript_pdf()
    
    # Analyze script
    results["script"] = analyze_script()
    
    # Compare presentations
    results["comparison"] = compare_presentations(results["presentations"])
    
    # Save results
    output_file = ANALYSIS_DIR / "comprehensive_analysis.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n{'='*60}")
    print(f"✓ Analysis complete! Results saved to:")
    print(f"  {output_file}")
    print(f"{'='*60}\n")
    
    return results

if __name__ == "__main__":
    main()
