#!/usr/bin/env python3
"""
Extract every embedded image from the manuscript, save to a temp review folder,
and map each image to its nearest following 'Figure X.X' caption so we know
which figure each image represents. Also report image width/height in EMUs
and approximate inches.
"""
import os, re, json
from docx import Document
from docx.shared import Emu
from docx.oxml.ns import qn

MANUSCRIPT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
OUTDIR = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\extracted_images"
os.makedirs(OUTDIR, exist_ok=True)

doc = Document(MANUSCRIPT)
paras = doc.paragraphs
caption_re = re.compile(r'^\s*(Figure|Table)\s*([0-9]+\.[0-9]+)\b', re.IGNORECASE)

def nearest_caption_after(idx):
    for j in range(idx + 1, min(idx + 6, len(paras))):
        m = caption_re.match(paras[j].text.strip())
        if m:
            kind = 'Figure' if m.group(1).lower().startswith('fig') else 'Table'
            return f"{kind} {m.group(2)}", paras[j].text.strip()
    return None, None

def nearest_caption_before(idx):
    for j in range(idx - 1, max(idx - 6, -1), -1):
        m = caption_re.match(paras[j].text.strip())
        if m:
            kind = 'Figure' if m.group(1).lower().startswith('fig') else 'Table'
            return f"{kind} {m.group(2)}", paras[j].text.strip()
    return None, None

# Collect blips. A drawing can contain an inline or anchor; get the blip embed id
# and dimensions from extent.
results = []
img_count = 0
for pi, p in enumerate(paras):
    drawings = list(p._p.iter(qn('w:drawing')))
    for d in drawings:
        # extent (inline) or extent in anchor
        extent = d.find(qn('wp:extent'))
        if extent is None:
            ext_el = d.find('.//' + qn('wp:extent'))
            extent = ext_el
        cx = int(extent.get('cx')) if extent is not None and extent.get('cx') else 0
        cy = int(extent.get('cy')) if extent is not None and extent.get('cy') else 0
        # blip
        blips = list(d.iter(qn('a:blip')))
        for bi, blip in enumerate(blips):
            rid = blip.get(qn('r:embed'))
            if not rid:
                continue
            part = doc.part.related_parts.get(rid)
            if part is None:
                continue
            cap_after, cap_after_text = nearest_caption_after(pi)
            cap_before, cap_before_text = nearest_caption_before(pi)
            img_count += 1
            # Determine the assigned figure: prefer caption AFTER (images usually precede caption)
            assigned = cap_after or cap_before
            safe = (assigned or f"img{img_count}").replace(' ', '_').replace('.', '_')
            ext = part.partname.ext if hasattr(part, 'partname') else '.png'
            if not ext:
                # guess from content type
                ct = part.content_type if hasattr(part, 'content_type') else ''
                ext = '.png' if 'png' in ct else ('.jpg' if 'jpeg' in ct else '.png')
            fname = f"{img_count:02d}_{safe}{ext}"
            fpath = os.path.join(OUTDIR, fname)
            with open(fpath, 'wb') as f:
                f.write(part.blob)
            results.append({
                'idx': img_count,
                'para_idx': pi,
                'rel_id': rid,
                'width_emu': cx,
                'height_emu': cy,
                'width_in': round(cx / 914400, 2) if cx else 0,
                'height_in': round(cy / 914400, 2) if cy else 0,
                'caption_after': cap_after,
                'caption_after_text': cap_after_text,
                'caption_before': cap_before,
                'caption_before_text': cap_before_text,
                'assigned': assigned,
                'file': fname,
                'bytes': len(part.blob),
            })

with open(os.path.join(OUTDIR, 'image_map.json'), 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2, default=str)

print(f"Extracted {img_count} images to {OUTDIR}")
print()
print(f"{'#':>3} {'para':>5} {'W\"':>6} {'H\"':>6} {'assigned':<14} file")
for r in results:
    print(f"{r['idx']:>3} {r['para_idx']:>5} {r['width_in']:>6} {r['height_in']:>6} {str(r['assigned']):<14} {r['file']}")
