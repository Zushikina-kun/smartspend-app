"""
Audit script to compare document versions and detect content differences
"""
import os
from datetime import datetime
from pathlib import Path
import json

try:
    from docx import Document
    DOCX_AVAILABLE = True
except ImportError:
    DOCX_AVAILABLE = False

try:
    from pptx import Presentation
    PPTX_AVAILABLE = True
except ImportError:
    PPTX_AVAILABLE = False

def get_docx_info(filepath):
    """Extract metadata from a DOCX file"""
    if not DOCX_AVAILABLE:
        return {"error": "python-docx not installed"}
    
    try:
        doc = Document(filepath)
        
        # Count elements
        paragraphs = len(doc.paragraphs)
        tables = len(doc.tables)
        sections = len(doc.sections)
        
        # Get text content length
        text_length = sum(len(p.text) for p in doc.paragraphs)
        
        # Get first 500 chars of text for comparison
        full_text = "\n".join(p.text for p in doc.paragraphs[:20])
        
        # Count headings (approximate by looking at styles)
        headings = sum(1 for p in doc.paragraphs if p.style.name.startswith('Heading'))
        
        return {
            "paragraphs": paragraphs,
            "tables": tables,
            "sections": sections,
            "text_length": text_length,
            "headings": headings,
            "first_text_preview": full_text[:500]
        }
    except Exception as e:
        return {"error": str(e)}

def get_pptx_info(filepath):
    """Extract metadata from a PPTX file"""
    if not PPTX_AVAILABLE:
        return {"error": "python-pptx not installed"}
    
    try:
        prs = Presentation(filepath)
        
        slides = len(prs.slides)
        
        # Get slide titles
        titles = []
        for slide in prs.slides:
            for shape in slide.shapes:
                if hasattr(shape, "text") and shape.text:
                    titles.append(shape.text[:100])
                    break
        
        # Count text shapes across all slides
        text_shapes = 0
        for slide in prs.slides:
            for shape in slide.shapes:
                if hasattr(shape, "text"):
                    text_shapes += 1
        
        return {
            "slides": slides,
            "text_shapes": text_shapes,
            "slide_titles": titles
        }
    except Exception as e:
        return {"error": str(e)}

def analyze_file(filepath):
    """Analyze a single file"""
    path = Path(filepath)
    
    if not path.exists():
        return None
    
    stat = path.stat()
    
    result = {
        "path": str(path),
        "name": path.name,
        "size": stat.st_size,
        "modified": datetime.fromtimestamp(stat.st_mtime).isoformat(),
        "modified_readable": datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S")
    }
    
    ext = path.suffix.lower()
    
    if ext == ".docx":
        result["type"] = "docx"
        result["content"] = get_docx_info(filepath)
    elif ext == ".pptx":
        result["type"] = "pptx"
        result["content"] = get_pptx_info(filepath)
    else:
        result["type"] = "other"
    
    return result

def main():
    # Define all file pairs to compare
    comparisons = {
        "manuscripts": [
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL(groupmates ver).docx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT.docx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/1_MAIN_MANUSCRIPT.docx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/SmartSpend_Manuscript_updated_v2.docx",
            "c:/xampp/htdocs/smartspend_app/docs/manuscript/SmartSpend_Manuscript_updated_v2.docx",
        ],
        "presentations": [
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/3_PRESENTATION_FINAL.pptx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/3_PRESENTATION.pptx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/3_PRESENTATION_BACKUP.pptx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/SmartSpend_Defense.pptx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/3_PRESENTATION.pptx",
        ],
        "other_presentations": [
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/SMARTSPEND AI-Powered Receipt Expense Tracker for Personal Finance Management.pptx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/SmartSpend An AI-Assisted Receipt and Expense Tracker for Personal Financial Management.pptx",
            "c:/xampp/htdocs/smartspend_app/docs/handsoff/BNHS_Beyond_the_Screen-1.pptx.pptx",
        ]
    }
    
    results = {}
    
    for category, files in comparisons.items():
        results[category] = []
        for filepath in files:
            info = analyze_file(filepath)
            if info:
                results[category].append(info)
    
    # Save results
    output_path = "c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/analysis/version_analysis.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
    
    print(f"Analysis complete. Results saved to {output_path}")
    
    # Print summary
    print("\n=== MANUSCRIPT VERSIONS ===")
    for item in results.get("manuscripts", []):
        print(f"\n{item['name']}")
        print(f"  Modified: {item['modified_readable']}")
        print(f"  Size: {item['size']:,} bytes")
        if "content" in item and "paragraphs" in item["content"]:
            print(f"  Paragraphs: {item['content']['paragraphs']}")
            print(f"  Tables: {item['content']['tables']}")
            print(f"  Text length: {item['content']['text_length']:,}")
    
    print("\n=== PRESENTATION VERSIONS ===")
    for item in results.get("presentations", []):
        print(f"\n{item['name']}")
        print(f"  Modified: {item['modified_readable']}")
        print(f"  Size: {item['size']:,} bytes")
        if "content" in item and "slides" in item["content"]:
            print(f"  Slides: {item['content']['slides']}")
            print(f"  Text shapes: {item['content']['text_shapes']}")

if __name__ == "__main__":
    main()
