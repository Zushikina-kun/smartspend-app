"""
Full audit of Source of Truth manuscript:
1. Extract every figure caption (with para index)
2. Extract every table caption (with para index)  
3. Extract every image location (with para index)
4. Extract every chapter/section heading
5. Report mismatches: captions without images, images without captions, numbering gaps
"""
from docx import Document
from docx.oxml.ns import qn

DOCX = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\Source of Truth\1_MAIN_MANUSCRIPT_FINAL.docx"
doc  = Document(DOCX)
lines = [p.text.strip() for p in doc.paragraphs]

# ── Find images ───────────────────────────────────────────────────────────
image_paras = []
for i, para in enumerate(doc.paragraphs):
    has_img = any(
        run._r.find('.//' + qn('wp:inline')) is not None or
        run._r.find('.//' + qn('wp:anchor')) is not None or
        run._r.find('.//' + qn('a:blip'))   is not None
        for run in para.runs
    )
    if has_img:
        ctx = lines[i]
        for j in range(i+1, min(i+3, len(lines))):
            if lines[j]: ctx += ' | ' + lines[j][:60]; break
        image_paras.append((i, ctx[:100]))

# ── Find figure captions ──────────────────────────────────────────────────
import re
fig_captions = []
for i, l in enumerate(lines):
    if re.match(r'^Figure\s+\d+[\.\:]', l) and len(l) > 15:
        fig_captions.append((i, l[:120]))

# ── Find table captions ───────────────────────────────────────────────────
tbl_captions = []
for i, l in enumerate(lines):
    if re.match(r'^Table\s+\d+[\.\:]', l) and len(l) > 10:
        tbl_captions.append((i, l[:120]))

# ── Find section headings ─────────────────────────────────────────────────
headings = []
for i, para in enumerate(doc.paragraphs):
    if para.style.name.startswith('Heading') or para.style.name in ['heading 1','heading 2','heading 3']:
        if para.text.strip():
            headings.append((i, para.style.name, para.text.strip()[:100]))

# ── Print results ─────────────────────────────────────────────────────────
print("=" * 65)
print("SECTION HEADINGS (from heading styles)")
print("=" * 65)
for i, style, text in headings:
    print(f"  [{i:3d}] {style}: {text}")

print()
print("=" * 65)
print(f"FIGURE CAPTIONS ({len(fig_captions)} found)")
print("=" * 65)
for i, text in fig_captions:
    print(f"  [{i:3d}]: {text}")

print()
print("=" * 65)
print(f"TABLE CAPTIONS ({len(tbl_captions)} found)")
print("=" * 65)
for i, text in tbl_captions:
    print(f"  [{i:3d}]: {text}")

print()
print("=" * 65)
print(f"IMAGE LOCATIONS ({len(image_paras)} images)")
print("=" * 65)
for i, ctx in image_paras:
    print(f"  [{i:3d}]: {ctx}")

print()
print("=" * 65)
print("ANALYSIS: Figure captions vs images")
print("=" * 65)
# For each figure caption, find nearest image
for fi, (fc_para, fc_text) in enumerate(fig_captions):
    # Find image within 5 paras before or after
    nearby = [(ip, ic) for ip, ic in image_paras if abs(ip - fc_para) <= 5]
    if nearby:
        closest = min(nearby, key=lambda x: abs(x[0] - fc_para))
        print(f"  ✅ {fc_text[:60]} → image at para[{closest[0]}]")
    else:
        print(f"  ❌ MISSING IMAGE: {fc_text[:80]}")

print()
print("=" * 65)
print("ORPHAN IMAGES (images far from any figure caption)")
print("=" * 65)
for ip, ic in image_paras:
    nearby_caps = [fc_para for fc_para, _ in fig_captions if abs(fc_para - ip) <= 5]
    if not nearby_caps:
        print(f"  ⚠️  Image at para[{ip}] has no nearby figure caption: {ic[:80]}")
