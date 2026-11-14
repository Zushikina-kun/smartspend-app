"""
Fix three figures:
1. fig4_kanban.png  — crop the bottom caption box ("Figure X...")
2. fig5_demographic — regenerate as Option B (16/14) with clean title
3. fig16_receipt.jpg — blur all PII regions
Save to figures_to_fix/fixed/
"""
import os
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

FIGS  = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\figures_to_fix"
FIXED = os.path.join(FIGS, "fixed")
os.makedirs(FIXED, exist_ok=True)

# ══════════════════════════════════════════════════════════════════════════
# FIG 4 — Kanban: crop bottom caption box
# ══════════════════════════════════════════════════════════════════════════
img4 = Image.open(os.path.join(FIGS, "fig4_kanban.png"))
w4, h4 = img4.size
print(f"Fig4 original: {w4}x{h4}")

# Scan from bottom to find where the caption box starts
arr4 = np.array(img4.convert("RGB"))
# The caption box is light blue/grey. Find the boundary by looking for
# a sudden transition to lighter/different background ~200px from bottom
# The kanban board itself ends, then there's white space, then caption box
# From earlier analysis, crop at ~735px
crop_bottom = 735
img4_fixed = img4.crop((0, 0, w4, crop_bottom))
img4_fixed.save(os.path.join(FIXED, "fig4_kanban_fixed.png"), dpi=(150, 150))
print(f"Fig4 fixed: {img4_fixed.size} (removed bottom {h4-crop_bottom}px caption box)")

# ══════════════════════════════════════════════════════════════════════════
# FIG 5 — Demographic: regenerate as 16/14 (Option B), clean title
# ══════════════════════════════════════════════════════════════════════════
fig5, ax5 = plt.subplots(figsize=(9, 6))
fig5.patch.set_facecolor('white')

categories = ['Parents\n(Ages 35–55)', 'Young Professionals\n(Ages 21–35)']
values     = [16, 14]
colors     = ['#E8A87C', '#00BFA6']   # warm orange, teal — matches original style

bars = ax5.bar(categories, values, color=colors, width=0.45,
               edgecolor='white', linewidth=1.5)

# Value labels on top of bars
for bar, val, pct in zip(bars, values, ['53.3%', '46.7%']):
    ax5.text(bar.get_x() + bar.get_width()/2,
             bar.get_height() + 0.3,
             f'{val}\n({pct})',
             ha='center', va='bottom',
             fontsize=14, fontweight='bold', color='#1a1a1a')

ax5.set_ylabel('Number of Respondents', fontsize=13, color='#333333')
ax5.set_ylim(0, 20)
ax5.yaxis.set_major_locator(plt.MaxNLocator(integer=True))
ax5.set_yticks([0, 2.5, 5, 7.5, 10, 12.5, 15, 17.5, 20])
ax5.set_yticklabels(['0', '', '5', '', '10', '', '15', '', '20'], fontsize=11)
ax5.tick_params(axis='x', labelsize=12, length=0)
ax5.spines['top'].set_visible(False)
ax5.spines['right'].set_visible(False)
ax5.spines['left'].set_color('#cccccc')
ax5.spines['bottom'].set_color('#cccccc')
ax5.yaxis.grid(True, color='#e0e0e0', linestyle='--', linewidth=0.8)
ax5.set_axisbelow(True)

# Source note at bottom
fig5.text(0.5, 0.01,
          'Sources: Needs-Assessment Survey, SmartSpend Study (2026)',
          ha='center', fontsize=9.5, color='#666666', style='italic')

# Note about the 3 "both" respondents classified with parents (Option B)
fig5.text(0.5, 0.055,
          '† Three respondents who identified as both groups were classified\n'
          'with the parent group based on their Q1 age bracket (Ages 35–55).',
          ha='center', fontsize=8.5, color='#555555', style='italic')

plt.tight_layout(rect=[0, 0.09, 1, 1])
out5 = os.path.join(FIXED, "fig5_demographic_fixed.png")
plt.savefig(out5, dpi=180, bbox_inches='tight', facecolor='white')
plt.close()
print(f"Fig5 regenerated (Option B 16/14): {out5}")

# ══════════════════════════════════════════════════════════════════════════
# FIG 16 — Receipt: blur PII regions
# ══════════════════════════════════════════════════════════════════════════
img16 = Image.open(os.path.join(FIGS, "fig16_receipt.jpg"))
w16, h16 = img16.size
print(f"\nFig16 original: {w16}x{h16}")

# PII regions (approximate, from visual inspection of 810x1800 image):
# The receipt photo occupies roughly top half of the image (y: 150 to 850)
# Within that, PII appears at approximately:
#   - Receipt number "SJ223568"       : receipt top area
#   - Student ID "4800551"            : "Received from" line
#   - Name "DI RECTO, BRIX A."        : same "Received from" line  
#   - Cashier "MARICELMONIS"          : cashier line
#   - TIN / other identifiers         : bottom of receipt

# Strategy: blur specific horizontal bands within the receipt photo area
# Receipt photo runs from about y=150 to y=850 in the full image
# Within that region, blur:
#   Band 1 (receipt number SJ223568): relative y ~180-220 of receipt → abs ~330-370
#   Band 2 (student ID + name line):  relative y ~230-280 → abs ~380-430
#   Band 3 (cashier line):            relative y ~340-380 → abs ~490-530
#   Also blur the extracted text box below (abs y ~900 to ~1650)

draw = ImageDraw.Draw(img16)

def blur_region(img, x1, y1, x2, y2, radius=25):
    """Blur a rectangular region of the image."""
    region = img.crop((x1, y1, x2, y2))
    blurred = region.filter(ImageFilter.GaussianBlur(radius=radius))
    img.paste(blurred, (x1, y1))

img16_copy = img16.copy()

# Blur the entire "Received from" section and receipt numbers
# (conservative — blur the full width of these lines)
blur_region(img16_copy,  0, 300,  w16, 580, radius=30)  # receipt number, student ID, name, cashier lines
blur_region(img16_copy,  0, 850,  w16, h16, radius=35)  # extracted text box (shows all PII as text — start higher)

# Also blur the receipt reference number at very top of receipt
blur_region(img16_copy,  0, 155,  w16, 310, radius=20)  # receipt header area

out16 = os.path.join(FIXED, "fig16_receipt_blurred.jpg")
img16_copy.save(out16, quality=92)
print(f"Fig16 PII blurred: {out16}")

print("\n✅ All three figures processed. Check figures_to_fix/fixed/")
