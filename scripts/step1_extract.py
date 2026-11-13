"""
Step 1: Extract full paragraph structure from both documents.
Outputs structural summaries to .agents/tasks/smartspend-v4-investigation/
"""

import os
import sys
from docx import Document


SMARTSPEND_PATH = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
LIGTASK_PATH = r"c:\xampp\htdocs\smartspend_app\docs\manuscript\templates\Reference_LigTask_Manuscript.docx"
OUT_DIR = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-v4-investigation"

os.makedirs(OUT_DIR, exist_ok=True)

def has_image(para):
    """Return True if the paragraph contains an inline image or drawing."""
    xml_str = para._element.xml if hasattr(para._element, 'xml') else str(para._element)
    # Check for drawing/picture XML tags that indicate embedded images
    for tag in ('w:drawing', 'w:pict', 'a:blip', 'v:imagedata', 'pic:pic'):
        if tag in xml_str:
            return True
    return False

def extract_doc(path, label):
    doc = Document(path)
    paras = doc.paragraphs
    lines = []
    for i, p in enumerate(paras):
        text = p.text.strip()
        style = p.style.name if p.style else "None"
        img = "[IMG]" if has_image(p) else ""
        lines.append(f"[{i:04d}] [{style}] {img} {text[:200]}")
    out_path = os.path.join(OUT_DIR, f"{label}_dump.txt")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"Wrote {len(lines)} paragraphs to {out_path}")
    return doc, paras

def find_headings(paras, label):
    headings = []
    for i, p in enumerate(paras):
        style = p.style.name if p.style else ""
        text = p.text.strip()
        if ("Heading" in style or text.upper() == text and len(text) > 3 and len(text) < 100):
            headings.append((i, style, text))
    out_path = os.path.join(OUT_DIR, f"{label}_headings.txt")
    with open(out_path, "w", encoding="utf-8") as f:
        for i, s, t in headings:
            f.write(f"[{i:04d}] [{s}] {t}\n")
    print(f"Wrote {len(headings)} headings to {out_path}")
    return headings

def find_captions(paras, label):
    import re
    fig_captions = []
    tbl_captions = []
    for i, p in enumerate(paras):
        text = p.text.strip()
        style = p.style.name if p.style else ""
        if re.match(r'(?i)figure\s+[\d\.]+', text) or 'caption' in style.lower():
            if re.search(r'(?i)figure\s+[\d\.]+', text):
                fig_captions.append((i, style, text))
        if re.match(r'(?i)table\s+[\d\.]+', text) or ('caption' in style.lower() and re.search(r'(?i)table', text)):
            tbl_captions.append((i, style, text))
    out_path = os.path.join(OUT_DIR, f"{label}_captions.txt")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("=== FIGURE CAPTIONS ===\n")
        for i, s, t in fig_captions:
            f.write(f"[{i:04d}] [{s}] {t}\n")
        f.write("\n=== TABLE CAPTIONS ===\n")
        for i, s, t in tbl_captions:
            f.write(f"[{i:04d}] [{s}] {t}\n")
    print(f"Found {len(fig_captions)} figure captions and {len(tbl_captions)} table captions → {out_path}")
    return fig_captions, tbl_captions

def find_images(paras, label):
    imgs = []
    for i, p in enumerate(paras):
        if has_image(p):
            imgs.append((i, p.text.strip()[:100]))
    out_path = os.path.join(OUT_DIR, f"{label}_images.txt")
    with open(out_path, "w", encoding="utf-8") as f:
        for i, t in imgs:
            f.write(f"[{i:04d}] {t}\n")
    print(f"Found {len(imgs)} image paragraphs → {out_path}")
    return imgs

# --- SmartSpend ---
print("\n=== SmartSpend FINAL ===")
ss_doc, ss_paras = extract_doc(SMARTSPEND_PATH, "smartspend")
find_headings(ss_paras, "smartspend")
find_captions(ss_paras, "smartspend")
find_images(ss_paras, "smartspend")

# --- LigTask ---
print("\n=== LigTask ===")
lt_doc, lt_paras = extract_doc(LIGTASK_PATH, "ligtask")
find_headings(lt_paras, "ligtask")
find_captions(lt_paras, "ligtask")
find_images(lt_paras, "ligtask")

print("\nDone.")
