"""
Check specific figures, images, and table numbering in manuscript.
READ-ONLY
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

def para_has_image_v2(para):
    para_xml = ET.tostring(para, encoding='unicode')
    indicators = ['<w:drawing', '<w:pict', 'a:blip', 'wp:inline', 'wp:anchor', 'v:imagedata']
    return any(ind in para_xml for ind in indicators)

with zipfile.ZipFile(docx_path) as z:
    with z.open('word/document.xml') as f:
        tree = ET.parse(f)

root = tree.getroot()
body = root.find('.//w:body', ns)
paras = body.findall('.//w:p', ns)

# --- Check which paras have images
print("=== ALL IMAGE PARAGRAPHS (checking XML) ===")
for i, p in enumerate(paras):
    if para_has_image_v2(p):
        text = get_full_para_text(p, ns)
        print("[%d] text='%s'" % (i, text.strip()[:100]))

# --- Check Image relationships in the docx
print("\n=== EMBEDDED IMAGE RELATIONSHIPS ===")
with zipfile.ZipFile(docx_path) as z:
    # List all images stored
    image_files = [name for name in z.namelist() if name.startswith('word/media/')]
    print("Images in docx media folder: %d" % len(image_files))
    for img in image_files:
        info = z.getinfo(img)
        print("  %s (%d bytes)" % (img, info.file_size))

# --- Check for missing Figures 3.1-3.3 (flowchart, use case, TOC) 
# These should be at paras 559, 561, 564
print("\n=== FIGURE 6/7/8 AREA (SYSTEM DIAGRAMS paras 555-595) ===")
for i in range(555, 595):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        has_img = para_has_image_v2(paras[i])
        if text.strip() or has_img:
            img_flag = "[IMG]" if has_img else "     "
            print("%s [%d] %s" % (img_flag, i, text.strip()[:150]))

# --- Check Table 3.1/Table 7 label conflict  
# Looking at how the table is labeled (Table 7 vs Table 3.1) in the actual body text at different positions
print("\n=== TABLE 3.1 LABEL CONFLICT ANALYSIS ===")
# The TOC says "Table 6: Demographic Profile..."  but body text says "Table 7: ..."
# and cross-ref says "Table 3.1" 
for i in range(405, 420):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        if text.strip():
            print("[%d] %s" % (i, text.strip()[:200]))

# --- Check "Table 5" content (Demographic Distribution of Needs-Assessment)  
print("\n=== TABLE 5 AREA (NEEDS ASSESSMENT TABLE paras 103-125) ===")
for i in range(103, 130):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        if text.strip():
            print("[%d] %s" % (i, text.strip()[:200]))

# --- Check LLaMA retirement references
print("\n=== LLAMA / MODEL STATUS REFERENCES ===")
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    if any(x in text for x in ['LLaMA', 'LLM', 'Groq', 'retired', 'GPT-OSS', 'Qwen']):
        print("[%d] %s" % (i, text.strip()[:160]))

# --- Check FHS figure description in manuscript
print("\n=== FHS BREAKDOWN FIGURE AREA (around para 582) ===")
for i in range(578, 598):
    if i < len(paras):
        text = get_full_para_text(paras[i], ns)
        has_img = para_has_image_v2(paras[i])
        if text.strip() or has_img:
            img_flag = "[IMG]" if has_img else "     "
            print("%s [%d] %s" % (img_flag, i, text.strip()[:200]))

print("\nDone.")
