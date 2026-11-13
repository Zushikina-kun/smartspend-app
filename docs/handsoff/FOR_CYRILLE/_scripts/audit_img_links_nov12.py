"""
Check image-to-paragraph linkage in the manuscript.
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

with zipfile.ZipFile(docx_path) as z:
    with z.open('word/document.xml') as f:
        content_bytes = f.read()
        content = content_bytes.decode('utf-8')
    with z.open('word/document.xml') as f:
        tree = ET.parse(f)

root = tree.getroot()
body = root.find('.//w:body', ns)
paras = body.findall('.//w:p', ns)

# Find ALL drawing/pict elements by scanning the raw XML
print("=== RAW XML DRAWING SCAN ===")
# Split XML by paragraphs and find which paragraphs have drawings
# More reliable: iterate over all elements looking for drawing tags
all_drawings_in_paras = []
for i, p in enumerate(paras):
    p_xml = ET.tostring(p, encoding='unicode')
    if '<w:drawing' in p_xml or '<w:pict' in p_xml or 'pic:pic' in p_xml or 'v:shape' in p_xml:
        text = get_full_para_text(p, ns)
        # Count embedded relationships
        rel_ids = re.findall(r'r:embed="([^"]+)"', p_xml)
        all_drawings_in_paras.append({'idx': i, 'text': text.strip()[:100], 'rels': rel_ids})

print("Paragraphs with drawings: %d" % len(all_drawings_in_paras))
for d in all_drawings_in_paras:
    print("[%d] rels=%s : '%s'" % (d['idx'], d['rels'], d['text']))

# Also check using raw content split
print("\n=== CHECKING RAW XML FOR DRAWING PRESENCE ===")
# Count specific XML tags
print("Count of <w:drawing>: %d" % content.count('<w:drawing'))
print("Count of <w:pict>: %d" % content.count('<w:pict'))
print("Count of pic:pic: %d" % content.count('pic:pic'))
print("Count of a:blip: %d" % content.count('a:blip'))
print("Count of v:imagedata: %d" % content.count('v:imagedata'))
print("Count of r:embed: %d" % content.count('r:embed'))

# --- Check relationships (which rId maps to which image)
print("\n=== IMAGE RELATIONSHIPS (word/_rels/document.xml.rels) ===")
with zipfile.ZipFile(docx_path) as z:
    with z.open('word/_rels/document.xml.rels') as f:
        rels_content = f.read().decode('utf-8')

# Parse relationships
img_rels = re.findall(r'<Relationship\s+Id="([^"]+)"\s+Type="[^"]*image[^"]*"\s+Target="([^"]+)"', rels_content)
print("Image relationships: %d" % len(img_rels))
for rid, target in img_rels[:20]:
    print("  %s -> %s" % (rid, target))

# Map all r:embed values in document to their image files
print("\n=== ALL r:embed IDs IN DOCUMENT ===")
all_embeds = re.findall(r'r:embed="(r[Ii][Dd]\d+)"', content)
from collections import Counter
embed_counts = Counter(all_embeds)
print("Unique r:embed IDs: %d, Total: %d" % (len(embed_counts), sum(embed_counts.values())))
for rid, count in sorted(embed_counts.items()):
    # Find corresponding image
    target = dict(img_rels).get(rid, 'NOT FOUND')
    print("  %s (%dx) -> %s" % (rid, count, target))

# Now find WHICH paragraph each embed appears in
print("\n=== EMBED-TO-PARAGRAPH MAPPING ===")
# Find paragraph boundaries in the raw XML
# Use a simpler approach: find embed IDs in raw XML near paragraph markers
for rid, target in img_rels:
    # Find where this rId appears in the raw XML
    pos = content.find('r:embed="%s"' % rid)
    if pos < 0:
        pos = content.find("r:embed='%s'" % rid)
    if pos >= 0:
        # Get surrounding context (500 chars before)
        ctx_start = max(0, pos - 2000)
        ctx = content[ctx_start:pos+200]
        # Count how many <w:p  appear before this position to estimate paragraph number
        paras_before = content[:pos].count('<w:p ')
        # Find nearby text
        nearby_text = re.findall(r'<w:t[^>]*>([^<]+)</w:t>', ctx[-500:])
        print("  %s -> %s : near para ~%d, nearby text: '%s'" % (
            rid, target, paras_before, ''.join(nearby_text)[-80:]))

print("\nDone.")
