"""
Compare the List of Figures/Tables (TOC area) vs the body text
to identify any numbering discrepancies. READ-ONLY.
"""
import zipfile
import xml.etree.ElementTree as ET
import re

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

# --- Scan for List of Figures section
print("=== LIST OF FIGURES SECTION ===")
in_lof = False
in_lot = False
lof_entries = []
lot_entries = []

for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    stripped = text.strip()
    
    if 'List of Figures' in stripped and i < 200:
        in_lof = True
        in_lot = False
        print("[%d] [LOF HEADER] %s" % (i, stripped[:100]))
        continue
    if 'List of Tables' in stripped and i < 200:
        in_lot = True
        in_lof = False
        print("[%d] [LOT HEADER] %s" % (i, stripped[:100]))
        continue
    if in_lof:
        if re.match(r'^\s*(Figure|FIGURE)', stripped, re.I):
            lof_entries.append({'idx': i, 'text': stripped[:200]})
            print("[%d] [LOF] %s" % (i, stripped[:200]))
        elif stripped and not re.match(r'^\s*(Table|List|Chapter|CHAPTER)', stripped, re.I):
            if i > 50:
                in_lof = False
    if in_lot:
        if re.match(r'^\s*(Table|TABLE)', stripped, re.I):
            lot_entries.append({'idx': i, 'text': stripped[:200]})
            print("[%d] [LOT] %s" % (i, stripped[:200]))
        elif stripped and not re.match(r'^\s*(Figure|List|Chapter|CHAPTER)', stripped, re.I):
            if i > 50:
                in_lot = False

# --- Now compare what's in body vs TOC
print("\n=== BODY FIGURE CAPTIONS vs TOC ===")
body_figures = []
body_tables = []

for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    stripped = text.strip()
    
    # Only look at captions (single-sentence Figure/Table statements)
    if re.match(r'^Figure\s+\d+[\.\:]', stripped) and len(stripped) < 200:
        body_figures.append({'idx': i, 'text': stripped})
    elif re.match(r'^Table\s+\d+[\.\:]', stripped) and len(stripped) < 200:
        body_tables.append({'idx': i, 'text': stripped})

print("Body Figures:")
for f in body_figures:
    print("  [%d] %s" % (f['idx'], f['text'][:160]))

print("\nBody Tables:")
for t in body_tables:
    print("  [%d] %s" % (t['idx'], t['text'][:160]))

# --- Check for chapter-prefixed numbers  
print("\n=== CHAPTER-PREFIXED FIGURE/TABLE REFS (Figure X.Y style) ===")
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    stripped = text.strip()
    if re.match(r'^(Figure|Table)\s+\d+\.\d+', stripped):
        print("[%d] %s" % (i, stripped[:150]))

# --- Full scan of all figure mentions in text with context
print("\n=== ALL FIGURE MENTIONS IN RUNNING TEXT ===")
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    stripped = text.strip()
    
    # Look for in-line references to figures like "(Figure X)" or "Figure X presents"
    # but not stand-alone captions
    if not re.match(r'^(Figure|Table)\s+\d', stripped):
        matches = re.findall(r'\b(?:Figure|Table)\s+\d+(?:\.\d+)?', text)
        if matches:
            print("[%d] %s : %s" % (i, matches, stripped[:120]))

# --- Check abstract for numbers
print("\n=== ABSTRACT PARAGRAPH ===")
for i in range(55, 80):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        if text.strip():
            print("[%d] %s" % (i, text.strip()[:300]))

print("\nDone.")
