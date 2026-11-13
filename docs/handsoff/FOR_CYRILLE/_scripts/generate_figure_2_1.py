"""
Generate Figure 2.1: SUS Score Interpretation Framework
Based on Bangor et al. (2008) acceptability ranges + Bangor et al. (2009) adjective anchors
+ Sauro & Lewis (2016) 68 average benchmark
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch
import numpy as np

fig, ax = plt.subplots(figsize=(10, 5))
fig.patch.set_facecolor('white')

# ── Acceptability zones (Bangor et al., 2008) ──────────────────────────────
zones = [
    (0,   50,  '#d9534f', 0.25, 'Not\nAcceptable'),   # red
    (50,  70,  '#f0ad4e', 0.25, 'Marginal'),           # amber
    (70, 100,  '#5cb85c', 0.25, 'Acceptable'),         # green
]
for x0, x1, color, alpha, label in zones:
    ax.barh(0, x1 - x0, left=x0, height=0.45,
            color=color, alpha=0.35, edgecolor='none')
    cx = (x0 + x1) / 2
    ax.text(cx, 0, label, ha='center', va='center',
            fontsize=10, fontweight='bold', color='#333333')

# ── Adjective anchors (Bangor et al., 2009) ────────────────────────────────
anchors = [
    (25,  'Worst\nImaginable', '#d9534f'),
    (39,  'Poor',              '#e07b3a'),
    (52,  'OK',                '#c8952a'),
    (71,  'Good',              '#3a7d44'),
    (85,  'Excellent',         '#2266aa'),
    (100, 'Best\nImaginable',  '#1a4a8a'),
]
for score, label, color in anchors:
    ax.plot(score, 0, 'D', color=color, markersize=7, zorder=5)
    ax.text(score, 0.30, label, ha='center', va='bottom',
            fontsize=7.5, color=color, fontweight='bold')

# ── 68 average benchmark (Sauro & Lewis, 2016) ────────────────────────────
ax.axvline(x=68, color='#555555', linestyle='--', linewidth=1.4, zorder=4)
ax.text(68, -0.33, '68\n(avg.)', ha='center', va='top',
        fontsize=8, color='#555555', style='italic')

# ── 80 pre-set target ─────────────────────────────────────────────────────
ax.axvline(x=80, color='#2266aa', linestyle=':', linewidth=1.6, zorder=4)
ax.text(80, -0.33, '80\n(target)', ha='center', va='top',
        fontsize=8, color='#2266aa', fontweight='bold')

# ── SmartSpend score 61.83 ────────────────────────────────────────────────
score = 61.83
ax.axvline(x=score, color='#c0392b', linestyle='-', linewidth=2.2, zorder=6)
ax.plot(score, 0, 's', color='#c0392b', markersize=10, zorder=7)
ax.text(score, -0.33, f'SmartSpend\n{score}', ha='center', va='top',
        fontsize=8.5, color='#c0392b', fontweight='bold')

# ── Score axis ────────────────────────────────────────────────────────────
ax.set_xlim(0, 100)
ax.set_ylim(-0.65, 0.75)
ax.set_xlabel('SUS Score (0 – 100)', fontsize=11, labelpad=6)
ax.set_xticks(range(0, 101, 10))
ax.tick_params(axis='x', labelsize=9)
ax.get_yaxis().set_visible(False)
for spine in ['left', 'right', 'top']:
    ax.spines[spine].set_visible(False)
ax.spines['bottom'].set_linewidth(1.2)

# ── Legend ────────────────────────────────────────────────────────────────
legend_elements = [
    mpatches.Patch(facecolor='#d9534f', alpha=0.45, label='Not Acceptable (< 51)'),
    mpatches.Patch(facecolor='#f0ad4e', alpha=0.45, label='Marginal (51 – 70)'),
    mpatches.Patch(facecolor='#5cb85c', alpha=0.45, label='Acceptable (≥ 71)'),
    plt.Line2D([0], [0], color='#555555', linestyle='--', linewidth=1.4,
               label='68 avg. benchmark (Sauro & Lewis, 2016)'),
    plt.Line2D([0], [0], color='#2266aa', linestyle=':', linewidth=1.6,
               label='80 pre-set target'),
    plt.Line2D([0], [0], color='#c0392b', linestyle='-', linewidth=2.2,
               marker='s', markersize=7, label='SmartSpend score (61.83)'),
]
ax.legend(handles=legend_elements, loc='upper left',
          fontsize=8, framealpha=0.9, edgecolor='#cccccc')

# ── Title ─────────────────────────────────────────────────────────────────
ax.set_title(
    'Figure 2.1. SUS Score Interpretation Framework\n'
    '(Bangor et al., 2008, 2009; Sauro & Lewis, 2016)',
    fontsize=11, fontweight='bold', pad=10
)

plt.tight_layout()

out = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES\Figure_2_1_SUS_Interpretation.png'
plt.savefig(out, dpi=180, bbox_inches='tight', facecolor='white')
print(f"Saved: {out}")
plt.close()
