"""
Render Peso mascot logo from the design spec in peso_mascot.dart.
Peso = friendly round coin, emerald green, big eyes, ₱ on forehead.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Circle, FancyBboxPatch, Arc
import numpy as np

# SmartSpend brand colors
PESO_GREEN      = '#00C896'
PESO_GREEN_DARK = '#008F6A'
PESO_GREEN_LIGHT= '#B3F5E6'

def draw_peso(ax, cx=0.5, cy=0.5, r=0.42):
    """Draw Peso mascot centered at (cx,cy) with radius r."""
    # -- Body (green coin circle) --
    body = Circle((cx, cy), r, facecolor=PESO_GREEN, edgecolor=PESO_GREEN_DARK,
                  linewidth=3, zorder=2)
    ax.add_patch(body)

    # -- Inner sheen (lighter green ring at top-left) --
    sheen = Circle((cx - r*0.22, cy + r*0.22), r*0.55,
                   facecolor=PESO_GREEN_LIGHT, edgecolor='none', alpha=0.25, zorder=3)
    ax.add_patch(sheen)

    # -- Eyes (white circles + black pupils) --
    eye_y    = cy + r * 0.14
    eye_dx   = r * 0.26
    eye_r    = r * 0.175
    pupil_r  = r * 0.085
    for ex in [cx - eye_dx, cx + eye_dx]:
        # white sclera
        ax.add_patch(Circle((ex, eye_y), eye_r,
                            facecolor='white', edgecolor='white', zorder=4))
        # pupil (slightly down-centre for friendly look)
        ax.add_patch(Circle((ex, eye_y - eye_r*0.12), pupil_r,
                            facecolor='#1a1a1a', edgecolor='none', zorder=5))
        # highlight dot
        ax.add_patch(Circle((ex + eye_r*0.25, eye_y + eye_r*0.25), pupil_r*0.38,
                            facecolor='white', edgecolor='none', zorder=6))

    # -- Happy mouth (arc) --
    mouth_y  = cy - r * 0.19
    mouth_w  = r * 0.36
    mouth_h  = r * 0.20
    theta    = np.linspace(np.pi, 2*np.pi, 60)
    mx = cx + mouth_w * np.cos(theta)
    my = mouth_y + mouth_h * np.sin(theta)
    ax.plot(mx, my, color='white', linewidth=r*6, solid_capstyle='round', zorder=4)

    # -- ₱ symbol on forehead --
    ax.text(cx, cy + r*0.56, '₱',
            ha='center', va='center',
            fontsize=r * 68, fontweight='bold',
            color='white', alpha=0.95, zorder=5,
            fontfamily='DejaVu Sans')

    # -- Tiny blush dots --
    for sign, blush_x in [(-1, cx - r*0.44), (1, cx + r*0.44)]:
        ax.add_patch(Circle((blush_x, cy - r*0.08), r*0.09,
                            facecolor='#FF8FA3', alpha=0.45, edgecolor='none', zorder=4))

OUT_DIR = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES'

# ── Transparent PNG (512×512) ───────────────────────────────────────────
fig, ax = plt.subplots(figsize=(5.12, 5.12), facecolor='none')
ax.set_facecolor('none')
ax.set_xlim(0, 1); ax.set_ylim(0, 1)
ax.set_aspect('equal'); ax.axis('off')
draw_peso(ax)
fig.savefig(f'{OUT_DIR}/Peso_Logo_transparent.png',
            dpi=100, bbox_inches='tight', transparent=True)
plt.close()

# ── White background PNG (512×512) ──────────────────────────────────────
fig, ax = plt.subplots(figsize=(5.12, 5.12), facecolor='white')
ax.set_xlim(0, 1); ax.set_ylim(0, 1)
ax.set_aspect('equal'); ax.axis('off')
draw_peso(ax)
fig.savefig(f'{OUT_DIR}/Peso_Logo_white_bg.png',
            dpi=100, bbox_inches='tight', facecolor='white')
plt.close()

# ── Side-by-side: SmartSpend logo + Peso ────────────────────────────────
from PIL import Image
import os

smartspend_path = r'c:\xampp\htdocs\smartspend_app\assets\logo.png'

fig, axes = plt.subplots(1, 2, figsize=(10, 5), facecolor='white')
fig.patch.set_facecolor('white')

# Left: SmartSpend logo
if os.path.exists(smartspend_path):
    img = Image.open(smartspend_path)
    axes[0].imshow(img)
    axes[0].axis('off')
    axes[0].set_title('SmartSpend Logo', fontsize=14, fontweight='bold', pad=10)

# Right: Peso
axes[1].set_xlim(0,1); axes[1].set_ylim(0,1)
axes[1].set_aspect('equal'); axes[1].axis('off')
axes[1].set_title('Peso Mascot', fontsize=14, fontweight='bold', pad=10)
axes[1].set_facecolor('white')
draw_peso(axes[1])

plt.tight_layout()
fig.savefig(f'{OUT_DIR}/SmartSpend_and_Peso_Logos.png',
            dpi=120, bbox_inches='tight', facecolor='white')
plt.close()

print(f'Saved to {OUT_DIR}:')
print('  Peso_Logo_transparent.png')
print('  Peso_Logo_white_bg.png')
print('  SmartSpend_and_Peso_Logos.png')
