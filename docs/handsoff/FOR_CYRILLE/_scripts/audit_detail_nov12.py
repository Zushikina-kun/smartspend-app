"""
Detailed audit of specific issues found - SmartSpend Manuscript
READ-ONLY
"""
import zipfile
import xml.etree.ElementTree as ET
import re
from collections import Counter

docx_path = '1_MAIN_MANUSCRIPT_FINAL.docx'
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

def get_full_para_text(para, ns):
    texts = []
    for elem in para.iter():
        if elem.tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t':
            if elem.text:
                texts.append(elem.text)
    return ''.join(texts)

with zipfile.ZipFile(docx_path) as z:
    with z.open('word/document.xml') as f:
        tree = ET.parse(f)

root = tree.getroot()
body = root.find('.//w:body', ns)
paras = body.findall('.//w:p', ns)

# --- 1. Full TOC section - paragraphs 100-120 ---
print("=== TOC SECTION (paras 100-115) ===")
for i in range(100, 116):
    text = get_full_para_text(paras[i], ns)
    if text.strip():
        print("[%d] %s" % (i, text.strip()[:200]))

# --- 2. Figure/Table numbering in the actual doc body ---
# Look at paragraphs around the "Figure" captions
print("\n=== FIGURE/TABLE CAPTIONS IN BODY (not TOC) ===")
caption_indices = [121, 123, 139, 291, 341, 368, 374, 384, 415, 417, 474, 482, 559, 561, 564, 573, 575, 578, 580, 582, 584, 586, 593, 594, 608]
for idx in caption_indices:
    if idx < len(paras):
        text = get_full_para_text(paras[idx], ns)
        print("[%d] %s" % (idx, text.strip()[:200]))

# --- 3. Chapter numbering scheme - check ch. numbering ---
print("\n=== CHAPTER HEADINGS ===")
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    if re.match(r'^\s*CHAPTER\s+[IVX]+', text, re.I) or re.match(r'^\s*Chapter\s+[IVX\d]+', text):
        print("[%d] %s" % (i, text.strip()[:150]))

# --- 4. What number scheme is used in Chapter III/Results ---
print("\n=== FIGURE/TABLE NUMBERING SCHEME IN CHAPTER III+ ===")
print("(looking at indices 555-620)")
for i in range(555, 625):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        if text.strip():
            if re.search(r'(Figure|Table)\s+\d', text, re.I):
                print("[%d] %s" % (i, text.strip()[:200]))

# --- 5. All cross-references mixed numbering ---
print("\n=== MIXED NUMBERING CROSS-REFERENCES FOUND IN BODY ===")
# In-body cross refs using BOTH "Table X.Y" and "Table N" formats
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    # Find all Table/Figure references in the text
    chapter_refs = re.findall(r'(?:Table|Figure)\s+\d+\.\d+', text)
    plain_refs = re.findall(r'(?:Table|Figure)\s+(?![\d]+\.)\d+(?!\.\d)', text)
    if chapter_refs and not text.strip().startswith(('Table', 'Figure')):
        print("[%d] chapter-style refs %s : %s" % (i, chapter_refs, text.strip()[:120]))
    elif plain_refs and not text.strip().startswith(('Table', 'Figure')):
        print("[%d] plain refs %s : %s" % (i, plain_refs, text.strip()[:120]))

# --- 6. Table 3.1 - check actual column headers ---
print("\n=== TABLE 3.1 COLUMN ANALYSIS (paras 415-480) ===")
for i in range(415, 480):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        if text.strip():
            print("[%d] %s" % (i, text.strip()[:200]))

# --- 7. Table 3.5 - check parsing performance data ---
print("\n=== TABLE 3.5 AREA (paras 700-740) ===")
for i in range(700, 740):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        if text.strip():
            print("[%d] %s" % (i, text.strip()[:200]))

# --- 8. SUS computation table area ---
print("\n=== SUS AREA (paras 590-660) ===")
for i in range(590, 660):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        if text.strip():
            print("[%d] %s" % (i, text.strip()[:200]))

# --- 9. Check for "Gemini 1.5" or "2.0" references ---
print("\n=== OUTDATED GEMINI VERSION CHECK ===")
old_gemini = re.compile(r'Gemini\s+(?:1\.\d|2\.0|Ultra|Pro(?!\s+\d))', re.I)
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    if old_gemini.search(text):
        print("[%d] %s" % (i, text.strip()[:160]))

# --- 10. Figure 2.1 (SUS interpretation) check ---
print("\n=== SUS INTERPRETATION FIGURE AREA (paras 360-390) ===")
for i in range(360, 395):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        if text.strip():
            print("[%d] %s" % (i, text.strip()[:200]))

print("\nDone.")
