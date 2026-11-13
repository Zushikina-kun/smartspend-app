"""
Fix burned-in figure labels by cropping:
- fig3_sus_chart.png: crop top ~95px (contains "Figure 2.1. SUS Score Interpretation Framework...")
- fig4_kanban.png: crop bottom ~290px (contains "Figure X." caption box)
- fig5_demographic.png: crop top ~90px (contains "Figure 5. Demographic Distribution...")

Then reinsert into the DOCX at the correct paragraph indices and save.
"""
import os, shutil
from PIL import Image
from docx import Document
from docx.oxml.ns import qn
from lxml import etree
import io

FIGURES_DIR = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-final-revision\figures"
DOCX_PATH   = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"
FIXED_DIR   = os.path.join(FIGURES_DIR, "fixed")
os.makedirs(FIXED_DIR, exist_ok=True)

# ── 1. Crop fig3: remove top title strip ─────────────────────────────────────
img3 = Image.open(os.path.join(FIGURES_DIR, "fig3_sus_chart.png"))
w3, h3 = img3.size
print(f"fig3 original: {w3}x{h3}")
# Title "Figure 2.1..." occupies roughly top 90px; crop with margin
# Scan for first row that is NOT mostly dark/text (find where chart content starts)
import numpy as np
arr3 = np.array(img3.convert("L"))
# Find first row after row 50 where density drops below 0.05 (white background)
crop_top3 = 0
for r in range(40, 200):
    density = np.mean(arr3[r] < 150)
    if density < 0.03:
        crop_top3 = r
        break
# Also find where the actual chart starts (first significant content after whitespace)
# Be conservative: use 85px which is clearly past both title lines
crop_top3 = max(crop_top3, 85)
img3_fixed = img3.crop((0, crop_top3, w3, h3))
print(f"fig3 cropped: removed top {crop_top3}px → {img3_fixed.size}")
img3_fixed.save(os.path.join(FIXED_DIR, "fig3_sus_chart.png"), dpi=(150,150))

# ── 2. Crop fig4: remove bottom caption box ───────────────────────────────────
img4 = Image.open(os.path.join(FIGURES_DIR, "fig4_kanban.png"))
w4, h4 = img4.size
print(f"\nfig4 original: {w4}x{h4}")
# The caption box at bottom starts with a light blue rounded rect
# Scan from bottom upward to find where the box top edge is
arr4 = np.array(img4.convert("L"))
crop_bottom4 = h4
for r in range(h4-1, h4//2, -1):
    # Look for the top of the caption box: a row that transitions from white to blue-ish
    row_arr = np.array(img4.convert("RGB"))[r]
    # Check if this row is mostly white/light (above the box)
    brightness = np.mean(row_arr)
    if brightness > 240:  # very white row = above the box
        crop_bottom4 = r
        # Keep scanning up a bit more to find consistent white
        break
# Be conservative: scan for the separator line
# The box has a distinct border. Find first mostly-white row from bottom going up
white_rows = []
for r in range(h4-1, h4//2, -1):
    brightness = np.mean(np.array(img4.convert("RGB"))[r])
    if brightness > 235:
        white_rows.append(r)
    elif white_rows:
        break  # found the top of the white gap above the box

if white_rows:
    crop_bottom4 = max(white_rows) + 1
else:
    # fallback: crop last 290px which is the caption box height
    crop_bottom4 = h4 - 290

print(f"fig4 crop bottom at row: {crop_bottom4} (removing bottom {h4-crop_bottom4}px)")
img4_fixed = img4.crop((0, 0, w4, crop_bottom4))
print(f"fig4 cropped: {img4_fixed.size}")
img4_fixed.save(os.path.join(FIXED_DIR, "fig4_kanban.png"), dpi=(150,150))

# ── 3. Crop fig5: remove top title lines ──────────────────────────────────────
img5 = Image.open(os.path.join(FIGURES_DIR, "fig5_demographic.png"))
w5, h5 = img5.size
print(f"\nfig5 original: {w5}x{h5}")
arr5 = np.array(img5.convert("L"))
# Title has two lines: "Figure 5. Demographic Distribution..." and subtitle
# Find first row after row 60 with low dark pixel density (start of chart)
crop_top5 = 85
for r in range(60, 200):
    density = np.mean(arr5[r] < 150)
    if density < 0.02:
        # Check next 5 rows too
        next_densities = [np.mean(arr5[min(r+k, h5-1)] < 150) for k in range(1,5)]
        if all(d < 0.05 for d in next_densities):
            crop_top5 = r
            break
print(f"fig5 crop top at row: {crop_top5}")
img5_fixed = img5.crop((0, crop_top5, w5, h5))
print(f"fig5 cropped: {img5_fixed.size}")
img5_fixed.save(os.path.join(FIXED_DIR, "fig5_demographic.png"), dpi=(150,150))

print("\n--- All 3 figures cropped and saved to figures/fixed/ ---")
print("Now reinserting into DOCX...")

# ── 4. Reinsert into DOCX ────────────────────────────────────────────────────
doc = Document(DOCX_PATH)

# Target: paragraph indices from map_images.py
# image4 (seq) = para 227 = Figure 3
# image5 (seq) = para 232 = Figure 4  
# image8 (seq) = para 254 = Figure 5
PARA_FIXES = {
    227: ("fig3_sus_chart.png",  "image/png"),
    232: ("fig4_kanban.png",     "image/png"),
    254: ("fig5_demographic.png","image/png"),
}

replaced = []
img_seq = 0
for para_idx, para in enumerate(doc.paragraphs):
    has_img = False
    for run in para.runs:
        if (run._r.find('.//' + qn('wp:inline')) is not None or
            run._r.find('.//' + qn('wp:anchor')) is not None or
            run._r.find('.//' + qn('a:blip')) is not None):
            has_img = True
            break
    if has_img:
        img_seq += 1
        if para_idx not in PARA_FIXES:
            continue
        
        fname, mime = PARA_FIXES[para_idx]
        fixed_path = os.path.join(FIXED_DIR, fname)
        
        # Find the blip relationship and replace the image part bytes
        for run in para.runs:
            blips = run._r.findall('.//' + qn('a:blip'))
            for blip in blips:
                rEmbed = blip.get(qn('r:embed'))
                if rEmbed:
                    rel = para.part.rels.get(rEmbed)
                    if rel:
                        with open(fixed_path, 'rb') as f:
                            new_bytes = f.read()
                        rel.target_part._blob = new_bytes
                        replaced.append((para_idx, fname))
                        print(f"  Replaced para[{para_idx}] with {fname} ({len(new_bytes)//1024} KB)")

doc.save(DOCX_PATH)
print(f"\nDOCX saved. {len(replaced)} images replaced: {replaced}")
print("\nDone!")
