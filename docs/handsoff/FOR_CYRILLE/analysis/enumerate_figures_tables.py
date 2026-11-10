#!/usr/bin/env python3
"""
Enumerate every figure and table in the manuscript:
- All paragraphs containing "Figure X.X" or "Table X.X" captions
- All inline images (with surrounding paragraph context)
- All real Word tables (doc.tables) with their cell contents
- Cross-references in body text ("Figure X.X", "Table X.X", "see Figure", "shown in")
"""
import re, json, os
from docx import Document
from docx.oxml.ns import qn

MANUSCRIPT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
OUT_MD = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\figures_enumeration.md"
OUT_JSON = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\figures_enumeration.json"

doc = Document(MANUSCRIPT)

# Build a flat list of (kind, item, index) in document order so we can interleave
# paragraphs and tables correctly.
body = doc.element.body
para_idx = 0
table_idx = 0
items = []  # list of dicts
tbl_objs = list(doc.tables)
ti = 0
for child in body.iterchildren():
    tag = child.tag.split('}')[-1]
    if tag == 'p':
        p = doc.paragraphs[para_idx]
        items.append({'kind': 'para', 'text': p.text, 'style': p.style.name if p.style else '',
                      'idx': para_idx})
        para_idx += 1
    elif tag == 'tbl':
        if ti < len(tbl_objs):
            items.append({'kind': 'table', 'obj': tbl_objs[ti], 'idx': ti})
            ti += 1
        table_idx += 1

# Detect inline images inside a paragraph
def para_has_image(p):
    found = False
    for r in p._p.iter(qn('w:drawing')):
        found = True
    for r in p._p.iter(qn('a:blip')):
        found = True
    return found

def count_images_in_para(p):
    n = 0
    for _ in p._p.iter(qn('a:blip')):
        n += 1
    return n

caption_re = re.compile(r'^\s*(Figure|Table|Fig\.|Tbl\.)\s*([0-9]+\.[0-9]+)\b', re.IGNORECASE)
ref_re = re.compile(r'\b(Figure|Table|Fig\.|Tbl\.)\s*([0-9]+\.[0-9]+)\b', re.IGNORECASE)

figures = {}   # key -> list of occurrences
tables_cap = {}
images = []     # list of (para_idx, n_images, nearby caption)
refs = {}       # key -> count
all_caps = []   # ordered list

# Walk items
running_caption_for_image = None
for it in items:
    if it['kind'] == 'para':
        txt = it['text'].strip()
        m = caption_re.match(txt)
        if m:
            kind = 'Figure' if m.group(1).lower().startswith('fig') else 'Table'
            key = f"{kind} {m.group(2)}"
            rec = {
                'key': key,
                'kind': kind,
                'number': m.group(2),
                'caption_full': txt,
                'para_idx': it['idx'],
                'style': it['style'],
                'has_image': para_has_image(doc.paragraphs[it['idx']]),
                'image_count': count_images_in_para(doc.paragraphs[it['idx']]),
            }
            all_caps.append(rec)
            if kind == 'Figure':
                figures.setdefault(key, []).append(rec)
            else:
                tables_cap.setdefault(key, []).append(rec)
        # inline images anywhere
        nimg = count_images_in_para(doc.paragraphs[it['idx']])
        if nimg:
            images.append({
                'para_idx': it['idx'],
                'image_count': nimg,
                'para_text': txt[:200],
                'style': it['style'],
            })
        # references
        for rm in ref_re.finditer(txt):
            k = f"{'Figure' if rm.group(1).lower().startswith('fig') else 'Table'} {rm.group(2)}"
            refs[k] = refs.get(k, 0) + 1
    elif it['kind'] == 'table':
        pass  # handled below

# Extract table cell contents
table_contents = []
for i, t in enumerate(tbl_objs):
    rows = []
    for row in t.rows:
        cells = [c.text.strip() for c in row.cells]
        rows.append(cells)
    # find the nearest caption paragraph BEFORE this table
    # Search backwards in items for the closest preceding caption
    cap_before = None
    for it in reversed(items):
        if it['kind'] == 'table' and it['idx'] == i:
            # found this table; look earlier
            continue
    table_contents.append({
        'table_idx': i,
        'n_rows': len(t.rows),
        'n_cols': len(t.columns),
        'rows': rows,
    })

# Map tables to nearest preceding caption by scanning items order
# Build ordered (position, type) and assign captions
ordered = []
for it in items:
    if it['kind'] == 'para':
        ordered.append(('para', it['idx'], it['text'].strip()))
    else:
        ordered.append(('table', it['idx'], None))

def nearest_caption_before(table_pos):
    # table_pos is index into ordered
    # search backwards for a paragraph whose text matches caption_re
    for j in range(table_pos - 1, -1, -1):
        t, idx, txt = ordered[j]
        if t == 'para' and txt:
            m = caption_re.match(txt)
            if m:
                kind = 'Figure' if m.group(1).lower().startswith('fig') else 'Table'
                return f"{kind} {m.group(2)}", txt
        # stop if too far (e.g., a heading) — but keep going a little
    return None, None

table_caption_map = {}
for pos, (t, idx, txt) in enumerate(ordered):
    if t == 'table':
        cap, captext = nearest_caption_before(pos)
        table_caption_map[idx] = {'caption_key': cap, 'caption_text': captext}

# Write markdown
lines = []
lines.append("# Figures and Tables Enumeration — SmartSpend Manuscript")
lines.append("")
lines.append(f"**Manuscript:** `{MANUSCRIPT}`")
lines.append("")
lines.append("## 1. All Captions (in document order)")
lines.append("")
lines.append("| # | Key | Kind | Style | Has Image | Caption Text |")
lines.append("|---|-----|------|-------|-----------|--------------|")
for n, c in enumerate(all_caps, 1):
    cap = c['caption_full'].replace('|', '\\|')
    if len(cap) > 120:
        cap = cap[:120] + '…'
    lines.append(f"| {n} | {c['key']} | {c['kind']} | {c['style']} | {c['image_count']} | {cap} |")
lines.append("")

lines.append("## 2. Inline Images (every image found)")
lines.append("")
if images:
    lines.append("| # | Para Idx | # Images | Style | Paragraph Text (truncated) |")
    lines.append("|---|----------|----------|-------|-----------------------------|")
    for n, im in enumerate(images, 1):
        t = im['para_text'].replace('|', '\\|')
        lines.append(f"| {n} | {im['para_idx']} | {im['image_count']} | {im['style']} | {t} |")
else:
    lines.append("_No inline images detected by blip scan._")
lines.append("")

lines.append("## 3. Word Tables (native doc.tables)")
lines.append("")
lines.append(f"**Total native tables: {len(tbl_objs)}**")
lines.append("")
for tc in table_contents:
    cmap = table_caption_map.get(tc['table_idx'], {})
    lines.append(f"### Word Table #{tc['table_idx']+1} — {tc['n_rows']} rows × {tc['n_cols']} cols")
    lines.append(f"- **Nearest preceding caption:** {cmap.get('caption_key') or '(none)'}")
    if cmap.get('caption_text'):
        lines.append(f"- **Caption text:** {cmap['caption_text'][:150]}")
    lines.append("")
    lines.append("| Row | " + " | ".join(f"Col {i+1}" for i in range(tc['n_cols'])) + " |")
    lines.append("|-----|" + "|".join(["-----"] * tc['n_cols']) + "|")
    for ri, row in enumerate(tc['rows']):
        cells = [str(c).replace('|', '\\|').replace('\n', ' ')[:60] for c in row]
        # pad
        while len(cells) < tc['n_cols']:
            cells.append('')
        lines.append(f"| {ri+1} | " + " | ".join(cells[:tc['n_cols']]) + " |")
    lines.append("")

lines.append("## 4. In-text Cross-references (counts)")
lines.append("")
lines.append("| Key | Times referenced in body text |")
lines.append("|-----|-------------------------------|")
for k in sorted(refs.keys()):
    lines.append(f"| {k} | {refs[k]} |")
lines.append("")

# Write files
with open(OUT_MD, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

# JSON dump
data = {
    'captions': all_caps,
    'images': images,
    'tables': table_contents,
    'table_caption_map': table_caption_map,
    'references': refs,
}
with open(OUT_JSON, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, default=str)

print(f"Wrote {OUT_MD}")
print(f"Wrote {OUT_JSON}")
print(f"Captions: {len(all_caps)} | Images: {len(images)} | Tables: {len(tbl_objs)} | Refs: {len(refs)}")
