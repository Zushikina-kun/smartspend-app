"""
Figure and Table Caption Audit - SmartSpend Manuscript
READ-ONLY audit script. No edits made.
"""
import zipfile
import xml.etree.ElementTree as ET
import re
import json
import sys

docx_path = '1_MAIN_MANUSCRIPT_FINAL.docx'
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

def get_para_text(para, ns):
    texts = []
    for r in para.findall('.//w:r', ns):
        for t in r.findall('w:t', ns):
            if t.text:
                texts.append(t.text)
    return ''.join(texts).strip()

def has_image(para, ns):
    return len(para.findall('.//{http://schemas.openxmlformats.org/drawingml/2006/main}blip', {})) > 0 or \
           len(para.findall('.//{http://schemas.openxmlformats.org/drawingml/2006/picture}pic', {})) > 0 or \
           len(para.findall('.//{urn:schemas-microsoft-com:vml}shape', {})) > 0

with zipfile.ZipFile(docx_path) as z:
    with z.open('word/document.xml') as f:
        tree = ET.parse(f)

root = tree.getroot()
body = root.find('.//w:body', ns)
paras = body.findall('.//w:p', ns)
print("Total paragraphs: %d" % len(paras))

# Collect all captions
captions = []
for i, p in enumerate(paras):
    text = get_para_text(p, ns)
    if re.match(r'^(Figure|Table)\s+\d+\.\d+', text):
        captions.append({'idx': i, 'text': text[:300], 'has_img': has_image(p, ns)})

print("\n=== ALL FIGURE/TABLE CAPTIONS ===")
for c in captions:
    img_marker = "[IMG]" if c['has_img'] else "     "
    print("%s [%d] %s" % (img_marker, c['idx'], c['text']))

# Check for duplicate captions
print("\n=== DUPLICATE CAPTION KEYS ===")
from collections import Counter
keys = []
for c in captions:
    m = re.match(r'^((?:Figure|Table)\s+\d+\.\d+)', c['text'])
    if m:
        keys.append(m.group(1))
key_counts = Counter(keys)
for k, v in sorted(key_counts.items()):
    if v > 1:
        print("DUPLICATE: %s appears %d times" % (k, v))

# Check for images near captions
print("\n=== IMAGE-CAPTION PROXIMITY CHECK ===")
for c in captions:
    idx = c['idx']
    # Check 3 paragraphs before and after for images
    near_img = False
    for j in range(max(0, idx-3), min(len(paras), idx+4)):
        p = paras[j]
        # Check for inline images using drawing namespace
        drawings = p.findall('.//{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}inline') + \
                   p.findall('.//{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}anchor')
        if drawings:
            near_img = True
            break
    status = "OK" if near_img else "MISSING IMAGE"
    print("%s: [%d] %s" % (status, idx, c['text'][:80]))

# Scan for key data values in text paragraphs
print("\n=== KEY DATA VALUES IN BODY TEXT ===")
key_values = {
    'SUS Score': [r'61\.83', r'62\.50', r'63\.06'],
    'Sample size': [r'N\s*=\s*30', r'N\s*=\s*31', r'N\s*=\s*36'],
    'Parents count': [r'10\s+parents', r'13\s+parents', r'16\s+parents'],
    'YP count': [r'20\s+young', r'14\s+young'],
    'SUS Grade': [r'Grade\s+D', r'Grade\s+C', r'Grade\s+B'],
    'SUS Adjective': [r'"OK"', r'"Good"', r'"Acceptable"'],
    'SD': [r'17\.58', r'SD\s*=\s*17'],
    'Parents SUS': [r'58\.25'],
    'YP SUS': [r'63\.62'],
}
found = {k: [] for k in key_values}
for i, p in enumerate(paras):
    text = get_para_text(p, ns)
    if not text:
        continue
    for k, patterns in key_values.items():
        for pat in patterns:
            if re.search(pat, text, re.IGNORECASE):
                found[k].append({'idx': i, 'text': text[:120], 'pattern': pat})

for k, hits in found.items():
    if hits:
        print("\n[%s]" % k)
        for h in hits[:6]:
            print("  [%d] pattern=%s : %s" % (h['idx'], h['pattern'], h['text'][:100]))

# Check Table 3.1 data - demographic numbers
print("\n=== TABLE 3.1 DEMOGRAPHIC DATA CHECK ===")
# Look for Word tables
with zipfile.ZipFile(docx_path) as z:
    with z.open('word/document.xml') as f:
        content = f.read().decode('utf-8')

# Find table rows with demographic data
table_pattern = re.compile(r'<w:tr\b.*?</w:tr>', re.DOTALL)
cell_text_pattern = re.compile(r'<w:t[^>]*>(.*?)</w:t>', re.DOTALL)
tables = table_pattern.findall(content)
print("Total Word tables found: %d" % len(tables))

# Check Table 3.5 parsing performance data
print("\n=== TABLE 3.5 PARSING PERFORMANCE CHECK ===")
# Find rows with 'Not measured' or actual numbers
nm_count = content.count('Not measured')
print("'Not measured' occurrences: %d" % nm_count)

# Check for Gemini model names
print("\n=== MODEL NAME CONSISTENCY CHECK ===")
gemini_patterns = [r'Gemini\s+[\d\.]+\s+Flash', r'Gemini\s+Flash', r'Gemini\s+1\.5', r'Gemini\s+2\.']
for pat in gemini_patterns:
    matches = re.findall(pat, content)
    if matches:
        from collections import Counter
        cnt = Counter(matches)
        for name, count in cnt.most_common():
            print("  %dx: %s" % (count, name))

# Check figure caption naming consistency
print("\n=== CAPTION NAMING STYLE CHECK ===")
for c in captions:
    text = c['text']
    # Check period after number
    if re.match(r'^(Figure|Table)\s+\d+\.\d+\s+[A-Z]', text):
        print("MISSING PERIOD: [%d] %s" % (c['idx'], text[:80]))
    elif re.match(r'^(Figure|Table)\s+\d+\.\d+\.\s+', text):
        print("OK PERIOD: [%d] %s" % (c['idx'], text[:80]))
    elif re.match(r'^(Figure|Table)\s+\d+\.\d+:\s+', text):
        print("COLON STYLE: [%d] %s" % (c['idx'], text[:80]))

print("\nDone.")
