"""
Fix remaining issues:
1. fig5: crop more from top (still has subtitle line remnant)
2. fig4: manually crop bottom caption box (auto-detect failed)
Then reinsert both into DOCX.
"""
import os
from PIL import Image
import numpy as np
from docx import Document
from docx.oxml.ns import qn

FIGURES_DIR = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-final-revision\figures"
FIXED_DIR   = os.path.join(FIGURES_DIR, "fixed")
DOCX_PATH   = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"

# ── Fix fig5: scan more carefully for subtitle remnant ──────────────────────
img5 = Image.open(os.path.join(FIGURES_DIR, "fig5_demographic.png"))
w5, h5 = img5.size
arr5 = np.array(img5.convert("L"))
print(f"fig5 original: {w5}x{h5}")

# Scan for the first row that is truly blank (all near-white)
# then find the first content row after that blank gap
blank_rows = []
for r in range(0, 200):
    density = np.mean(arr5[r] < 200)
    blank_rows.append((r, density))
    
print("Row densities (top 150):")
for r, d in blank_rows[:150:3]:
    print(f"  row {r:3d}: {d:.3f} {'*' if d < 0.01 else ''}")

# Find the last title/subtitle row by looking for a substantial white gap
# Title lines are dark, then there's a white gap, then the chart starts
# We want to crop everything above the chart content
# Strategy: find longest white gap in first 150 rows, crop at gap start
prev_had_content = False
gap_start = 0
best_gap_start = 0
best_gap_len = 0
gap_len = 0
for r in range(0, 160):
    d = np.mean(arr5[r] < 200)
    if d < 0.015:  # essentially blank row
        if not prev_had_content:
            gap_start = r
            gap_len = 0
        gap_len += 1
        prev_had_content = False
    else:
        if gap_len > best_gap_len:
            best_gap_len = gap_len
            best_gap_start = gap_start
        prev_had_content = True
        gap_len = 0

print(f"\nBest gap: starts at row {best_gap_start}, length {best_gap_len}")
# Crop at the END of the best gap (where chart content starts)
crop_top5 = best_gap_start + best_gap_len
# Safety: ensure we're at least past row 85
crop_top5 = max(crop_top5, 85)
print(f"Cropping fig5 at row {crop_top5}")
img5_fixed = img5.crop((0, crop_top5, w5, h5))
print(f"fig5 fixed size: {img5_fixed.size}")
img5_fixed.save(os.path.join(FIXED_DIR, "fig5_demographic.png"), dpi=(150,150))

# ── Fix fig4: scan for bottom caption box boundary ──────────────────────────
img4 = Image.open(os.path.join(FIGURES_DIR, "fig4_kanban.png"))
w4, h4 = img4.size
print(f"\nfig4 original: {w4}x{h4}")

# The caption box has a light blue/grey background
# Scan from bottom upward looking for a row of consistent near-white
arr4_rgb = np.array(img4.convert("RGB"))

# Check bottom 400 rows for a near-white separator
print("Bottom 400 rows brightness scan:")
for r in range(h4-400, h4, 5):
    row = arr4_rgb[r]
    brightness = np.mean(row)
    r_mean = np.mean(row[:,0])
    g_mean = np.mean(row[:,1])
    b_mean = np.mean(row[:,2])
    print(f"  row {r:4d}: brightness={brightness:.1f} RGB=({r_mean:.0f},{g_mean:.0f},{b_mean:.0f})")
