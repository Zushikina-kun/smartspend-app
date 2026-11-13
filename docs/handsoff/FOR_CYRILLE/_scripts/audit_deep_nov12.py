"""
Deep audit of figures, tables, and key data in SmartSpend manuscript.
Reads all paragraph text and finds Figure/Table references.
"""
import zipfile
import xml.etree.ElementTree as ET
import re
import json
from collections import Counter

docx_path = '1_MAIN_MANUSCRIPT_FINAL.docx'
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

def get_full_para_text(para, ns):
    """Get ALL text from paragraph including all runs"""
    texts = []
    for elem in para.iter():
        if elem.tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t':
            if elem.text:
                texts.append(elem.text)
    return ''.join(texts)

def para_has_drawing(para):
    """Check if paragraph contains an embedded image/drawing"""
    para_str = ET.tostring(para, encoding='unicode')
    return ('a:blip' in para_str or 
            '<w:drawing' in para_str or 
            '<w:pict' in para_str or
            'wp:inline' in para_str or
            'wp:anchor' in para_str)

with zipfile.ZipFile(docx_path) as z:
    with z.open('word/document.xml') as f:
        tree = ET.parse(f)

root = tree.getroot()
body = root.find('.//w:body', ns)
paras = body.findall('.//w:p', ns)
print("=== MANUSCRIPT PARAGRAPH AUDIT ===")
print("Total paragraphs: %d\n" % len(paras))

# Find all paragraphs that start with Figure or Table
print("=== ALL FIGURE AND TABLE REFERENCES IN BODY TEXT ===")
fig_table_paras = []
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    if not text.strip():
        continue
    # Match any para that starts with Figure or Table + number
    if re.match(r'^\s*(Figure|Table)\s+\d', text, re.IGNORECASE):
        fig_table_paras.append({'idx': i, 'text': text.strip()[:300]})

for item in fig_table_paras:
    print("[%d] %s" % (item['idx'], item['text'][:200]))

# Also scan for all paragraphs that REFERENCE figures/tables (not start with them)
print("\n=== IN-TEXT FIGURE/TABLE REFERENCES ===")
ref_paras = []
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    if not text.strip():
        continue
    matches = re.findall(r'(Figure\s+\d+[\.\d]*|Table\s+\d+[\.\d]*)', text)
    if matches:
        ref_paras.append({'idx': i, 'text': text.strip()[:200], 'refs': list(set(matches))})

for item in ref_paras[:50]:  # first 50 only
    print("[%d] refs=%s : %s" % (item['idx'], item['refs'], item['text'][:120]))

# Count reference occurrences
all_refs = []
for item in ref_paras:
    all_refs.extend(item['refs'])
ref_counts = Counter(all_refs)
print("\n=== REFERENCE COUNT SUMMARY ===")
for ref, count in sorted(ref_counts.items()):
    print("  %s: %d references" % (ref, count))

# Find all image paragraphs
print("\n=== ALL PARAGRAPHS WITH EMBEDDED IMAGES ===")
image_paras = []
for i, p in enumerate(paras):
    if para_has_drawing(p):
        text = get_full_para_text(p, ns)
        image_paras.append({'idx': i, 'text': text.strip()[:100]})

print("Total paragraphs with images: %d" % len(image_paras))
for item in image_paras:
    print("[%d] %s" % (item['idx'], item['text'] if item['text'] else '(empty)'))

# Look for old Table 8, Table 5, Table 6, Table 7 references (pre-renumbering)
print("\n=== OLD TABLE NUMBER REFERENCES (Table 5, 6, 7, 8 etc.) ===")
old_table_pattern = re.compile(r'\b(Table\s+[5-9]|Table\s+1[0-9])\b')
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    matches = old_table_pattern.findall(text)
    if matches:
        print("[%d] %s : %s" % (i, matches, text[:150]))

# Check for inconsistent demographics in text
print("\n=== DEMOGRAPHICS CONSISTENCY CHECK ===")
demo_patterns = {
    'parents_13': re.compile(r'13\s+(?:parents?|respondents?\s+who)', re.I),
    'parents_10': re.compile(r'10\s+parents?', re.I),
    'parents_16': re.compile(r'16\s+parents?', re.I),
    'yp_14': re.compile(r'14\s+young\s+professionals?', re.I),
    'yp_20': re.compile(r'20\s+young\s+professionals?', re.I),
    'both_3': re.compile(r'3\s+(?:respondents?\s+(?:who|identifying)|both)', re.I),
    'total_30': re.compile(r'(?:N\s*=\s*30|30\s+respondents)', re.I),
}
for pname, pat in demo_patterns.items():
    matches = []
    for i, p in enumerate(paras):
        text = get_full_para_text(p, ns)
        if pat.search(text):
            matches.append({'idx': i, 'text': text[:120]})
    if matches:
        print("\n[%s] - %d occurrences" % (pname, len(matches)))
        for m in matches[:3]:
            print("  [%d] %s" % (m['idx'], m['text'][:100]))

# Check Table 3.1 actual content (demographics table)
print("\n=== LOOKING FOR DEMOGRAPHICS TABLE CONTENT ===")
sus_related = []
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    if any(x in text for x in ['43.3%', '46.7%', '10.0%', 'Parents (n =', 'Young Professionals (n =']):
        sus_related.append({'idx': i, 'text': text.strip()[:200]})
for item in sus_related[:20]:
    print("[%d] %s" % (item['idx'], item['text']))

# Check for "Gemini" model version references
print("\n=== GEMINI VERSION REFERENCES ===")
for i, p in enumerate(paras):
    text = get_full_para_text(p, ns)
    if 'Gemini' in text:
        print("[%d] %s" % (i, text[:160]))

print("\nDone.")
