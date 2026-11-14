"""
Generate Figure 3: System Usability Scale (SUS) Score Interpretation
Clean version — no burned-in figure number.
Matches the data in the manuscript:
- SmartSpend score: 61.83
- 68-point average benchmark (Sauro & Lewis, 2016)
- 80 pre-set target
- Zones: Not Acceptable (<51), Marginal (51-70), Acceptable (>=71)
- Adjective labels: Worst Imaginable, Poor, OK, Good, Excellent, Best Imaginable
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import os

OUT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\figures_to_fix\fixed\fig3_sus_interpretation.png"
os.makedirs(os.path.dirname(OUT), exist_ok=True)

fig, ax = plt.subplots(figsize=(12, 5.5))
fig.patch.set_facecolor('white')

# ── Background zones ──────────────────────────────────────────────────────
ax.axvspan(0,   51,  alpha=0.18, color='#e74c3c', zorder=0)   # Not Acceptable
ax.axvspan(51,  71,  alpha=0.20, color='#f39c12', zorder=0)   # Marginal
ax.axvspan(71,  101, alpha=0.18, color='#27ae60', zorder=0)   # Acceptable

# Zone labels (inside zones)
ax.text(25,   0.78, 'Not\nAcceptable', ha='center', va='center',
        fontsize=13, fontweight='bold', color='#c0392b',
        transform=ax.get_xaxis_transform())
ax.text(60.5, 0.78, 'Marginal', ha='center', va='center',
        fontsize=13, fontweight='bold', color='#e67e22',
        transform=ax.get_xaxis_transform())
ax.text(85,   0.78, 'Acceptable', ha='center', va='center',
        fontsize=13, fontweight='bold', color='#1a7a4a',
        transform=ax.get_xaxis_transform())

# ── Adjective labels (top row) ────────────────────────────────────────────
adjectives = [
    (1,   'Worst\nImaginable', '#c0392b'),
    (25,  'Poor',             '#e67e22'),
    (51,  'OK',               '#d4ac0d'),
    (71,  'Good',             '#27ae60'),
    (85,  'Excellent',        '#1a7a4a'),
    (100, 'Best\nImaginable', '#1a7a4a'),
]
for x, label, color in adjectives:
    ax.text(x, 0.93, label, ha='center', va='center',
            fontsize=9.5, color=color, fontweight='semibold',
            transform=ax.get_xaxis_transform())

# ── Adjective marker diamonds ─────────────────────────────────────────────
marker_x = [25, 39, 52, 71, 85, 100]
marker_colors = ['#c0392b', '#e67e22', '#d4ac0d', '#27ae60', '#1a7a4a', '#1a4a7a']
for x, c in zip(marker_x, marker_colors):
    ax.plot(x, 0.5, 'D', color=c, markersize=11, zorder=4,
            transform=ax.get_xaxis_transform())

# ── Reference lines ───────────────────────────────────────────────────────
# 68 benchmark
ax.axvline(68, color='#555555', linestyle='--', linewidth=1.8, zorder=3, label='68 avg. benchmark (Sauro & Lewis, 2016)')
ax.text(69.5, 0.08, '68\n(avg.)', ha='left', va='bottom', fontsize=8.5,
        color='#555555', transform=ax.get_xaxis_transform())

# 80 target
ax.axvline(80, color='#2471a3', linestyle=':', linewidth=1.8, zorder=3, label='80 pre-set target')
ax.text(81.5, 0.08, '80\n(target)', ha='left', va='bottom', fontsize=8.5,
        color='#2471a3', transform=ax.get_xaxis_transform())

# SmartSpend score
ax.axvline(61.83, color='#c0392b', linestyle='-', linewidth=2.5, zorder=5,
           label='SmartSpend score (61.83)')
ax.text(58.5, 0.08, 'SmartSpend\n61.83', ha='right', va='bottom', fontsize=8.5,
        color='#c0392b', fontweight='bold', transform=ax.get_xaxis_transform())

# ── Axis / spine formatting ───────────────────────────────────────────────
ax.set_xlim(0, 100)
ax.set_ylim(0, 1)
ax.set_yticks([])
ax.set_xticks(range(0, 101, 10))
ax.tick_params(axis='x', labelsize=11)
ax.set_xlabel('SUS Score (0 – 100)', fontsize=12, labelpad=8)
for spine in ['top', 'right', 'left']:
    ax.spines[spine].set_visible(False)
ax.spines['bottom'].set_color('#888888')

# ── Legend ────────────────────────────────────────────────────────────────
patches = [
    mpatches.Patch(color='#e74c3c', alpha=0.5, label='Not Acceptable (< 51)'),
    mpatches.Patch(color='#f39c12', alpha=0.5, label='Marginal (51 – 70)'),
    mpatches.Patch(color='#27ae60', alpha=0.5, label='Acceptable (≥ 71)'),
    plt.Line2D([0], [0], color='#555555', linestyle='--', linewidth=1.8, label='68 avg. benchmark (Sauro & Lewis, 2016)'),
    plt.Line2D([0], [0], color='#2471a3', linestyle=':',  linewidth=1.8, label='80 pre-set target'),
    plt.Line2D([0], [0], color='#c0392b', linestyle='-',  linewidth=2.5, label='SmartSpend score (61.83)'),
]
ax.legend(handles=patches, loc='upper left', fontsize=9, framealpha=0.9,
          bbox_to_anchor=(0.01, 0.75), borderpad=0.8)

plt.tight_layout(pad=1.5)
plt.savefig(OUT, dpi=180, bbox_inches='tight', facecolor='white')
plt.close()
print(f'Saved: {OUT}')
