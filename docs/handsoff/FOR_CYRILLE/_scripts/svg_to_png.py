"""
Render Peso_Logo.svg to PNG using matplotlib — faithful to the actual SVG geometry.
Transparent background, 512x597 px (matches viewBox 120x140 aspect ratio).
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import Ellipse, Circle, FancyArrowPatch
from matplotlib.path import Path
import matplotlib.patheffects as pe
import numpy as np

# SVG viewBox: 0 0 120 140  → we work in those coords, matplotlib scales to output
VW, VH = 120, 140
FIG_W, FIG_H = 5.12, 5.97   # inches at 100 dpi = 512 x 597 px

fig, ax = plt.subplots(figsize=(FIG_W, FIG_H))
fig.patch.set_alpha(0)
ax.set_facecolor((0, 0, 0, 0))
ax.set_xlim(0, VW)
ax.set_ylim(VH, 0)          # flip Y so SVG top-left = matplotlib top-left
ax.set_aspect('equal')
ax.axis('off')
fig.subplots_adjust(0, 0, 1, 1)

# ── Helpers ──────────────────────────────────────────────────────────────
def rgba(hex_color, alpha=1.0):
    h = hex_color.lstrip('#')
    r, g, b = tuple(int(h[i:i+2], 16)/255 for i in (0, 2, 4))
    return (r, g, b, alpha)

GREEN_LIGHT = rgba('2ECC88')
GREEN_DARK  = rgba('00A86B')
GREEN_MID   = rgba('00C896')
DARK        = rgba('0D2B1A')

# ── Drop shadow ───────────────────────────────────────────────────────────
shadow = Circle((60, 68), 42, color=rgba('00A86B', 0.18), zorder=1)
ax.add_patch(shadow)

# ── Body (radial gradient approximated with two overlapping circles) ──────
body_outer = Circle((60, 62), 42, color=GREEN_DARK, zorder=2)
ax.add_patch(body_outer)
body_highlight = Circle((52, 54), 32, color=rgba('2ECC88', 0.55), zorder=3)
ax.add_patch(body_highlight)

# ── Inner rim ring ────────────────────────────────────────────────────────
rim = Circle((60, 62), 38, fill=False,
             edgecolor=(1,1,1,0.18), linewidth=2, zorder=4)
ax.add_patch(rim)

# ── Face surface (translucent white highlight on upper-left) ─────────────
face = Circle((54, 56), 34, color=(1,1,1,0.20), zorder=5)
ax.add_patch(face)

# ── ₱ forehead ────────────────────────────────────────────────────────────
ax.text(60, 38, '₱', ha='center', va='center',
        fontsize=11, fontweight='black', color=rgba('00A86B', 0.85),
        zorder=6, fontfamily='DejaVu Sans')

# ── Arms ──────────────────────────────────────────────────────────────────
# Left arm line + 3-blob hand
ax.plot([22, 8], [58, 42], color=GREEN_MID, linewidth=7,
        solid_capstyle='round', zorder=6)
for cx, cy, r in [(5, 38, 5.5), (10, 33, 4.5), (1, 33, 4)]:
    ax.add_patch(Circle((cx, cy), r, color=GREEN_MID, zorder=6))
# Right arm line + 3-blob hand
ax.plot([98, 112], [58, 42], color=GREEN_MID, linewidth=7,
        solid_capstyle='round', zorder=6)
for cx, cy, r in [(115, 38, 5.5), (110, 33, 4.5), (119, 33, 4)]:
    ax.add_patch(Circle((cx, cy), r, color=GREEN_MID, zorder=6))

# ── Eyebrows ──────────────────────────────────────────────────────────────
# Left brow: M 37 43 Q 42 40 47 43  (quadratic bezier)
t = np.linspace(0, 1, 40)
# Quadratic bezier: P = (1-t)^2*P0 + 2(1-t)t*P1 + t^2*P2
def qbez(p0, p1, p2, t):
    return (1-t)**2*np.array(p0) + 2*(1-t)*t*np.array(p1) + t**2*np.array(p2)
lb = qbez((37,43),(42,40),(47,43), t.reshape(-1,1)).T
rb = qbez((73,43),(78,40),(83,43), t.reshape(-1,1)).T
ax.plot(lb[0], lb[1], color=GREEN_DARK, linewidth=2.8, solid_capstyle='round', zorder=7)
ax.plot(rb[0], rb[1], color=GREEN_DARK, linewidth=2.8, solid_capstyle='round', zorder=7)

# ── Eye whites ────────────────────────────────────────────────────────────
for cx in [42, 78]:
    ax.add_patch(Circle((cx, 54), 12, color='white', zorder=8))

# ── Pupils ────────────────────────────────────────────────────────────────
ax.add_patch(Circle((44, 56), 7, color=DARK, zorder=9))
ax.add_patch(Circle((80, 56), 7, color=DARK, zorder=9))

# ── Eye shine main ────────────────────────────────────────────────────────
ax.add_patch(Circle((47, 52), 3, color='white', zorder=10))
ax.add_patch(Circle((83, 52), 3, color='white', zorder=10))
# secondary shine
ax.add_patch(Circle((41, 58), 1.4, color=(1,1,1,0.5), zorder=10))
ax.add_patch(Circle((77, 58), 1.4, color=(1,1,1,0.5), zorder=10))

# ── Blush ─────────────────────────────────────────────────────────────────
ax.add_patch(Ellipse((28, 68), 18, 11, color=(1, 0.39, 0.39, 0.18), zorder=7))
ax.add_patch(Ellipse((92, 68), 18, 11, color=(1, 0.39, 0.39, 0.18), zorder=7))

# ── Smile (quadratic bezier M 38 74 Q 60 90 82 74) ────────────────────────
sm = qbez((38,74),(60,90),(82,74), t.reshape(-1,1)).T
# Tooth fill polygon (approximate the closed path)
# "M 38 74 Q 60 90 82 74 L 79 76 Q 60 90 41 76 Z"
sm2 = qbez((82,74),(60,90),(38,74), t.reshape(-1,1)).T   # reverse
# inner curve (slightly inside)
si = qbez((41,76),(60,90),(79,76), t.reshape(-1,1)).T
tooth_x = np.concatenate([sm[0], si[0][::-1]])
tooth_y = np.concatenate([sm[1], si[1][::-1]])
ax.fill(tooth_x, tooth_y, color=(1,1,1,0.80), zorder=8)
# smile outline
ax.plot(sm[0], sm[1], color=DARK, linewidth=3.5, solid_capstyle='round', zorder=9)

# ── Legs ──────────────────────────────────────────────────────────────────
ax.plot([50, 44], [103, 122], color=GREEN_MID, linewidth=7,
        solid_capstyle='round', zorder=6)
ax.plot([70, 76], [103, 122], color=GREEN_MID, linewidth=7,
        solid_capstyle='round', zorder=6)

# ── Feet (ellipses) ───────────────────────────────────────────────────────
ax.add_patch(Ellipse((40, 126), 22, 11, color=GREEN_MID, zorder=6))
ax.add_patch(Ellipse((80, 126), 22, 11, color=GREEN_MID, zorder=6))

OUT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES\Peso_Logo_transparent.png'
fig.savefig(OUT, dpi=100, bbox_inches='tight',
            transparent=True, facecolor=(0,0,0,0))
plt.close()
print(f'Saved: {OUT}')
