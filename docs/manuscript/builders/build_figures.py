"""
build_figures.py
Generates all 4 manuscript figures as PNG files:
  figures/Figure_1_1_Financial_Literacy_Rates.png
  figures/Figure_1_2_Conceptual_Framework_IPO.png
  figures/Figure_2_1_SUS_Score_Interpretation.png
  figures/Figure_2_2_Agile_Kanban_Workflow.png

Run: python build_figures.py
Requires: matplotlib, pillow (pip install matplotlib pillow)
"""
import os, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.patheffects as pe
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

BASE   = os.path.dirname(__file__)
OUTDIR = os.path.join(BASE, '..', 'figures')
os.makedirs(OUTDIR, exist_ok=True)

# ── Lorma colour palette ───────────────────────────────────────────────────────
MAROON  = '#5C0E24'
GOLD    = '#C9A84C'
PURPLE  = '#6B3FA0'
TEAL    = '#1A8F8F'
BLUE    = '#2A6EAF'
GREEN   = '#2E7D32'
ORANGE  = '#E65100'
GREY_BG = '#F5F5F5'
DARK    = '#222222'

def save(fig, name, max_kb=280):
    """Save figure as PNG, then compress with Pillow until under max_kb."""
    path = os.path.join(OUTDIR, name)
    # First save at full quality
    fig.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)

    # Compress with Pillow: reduce dpi if needed
    try:
        from PIL import Image
        img = Image.open(path).convert('RGB')
        # Try progressive quality reduction
        quality = 92
        while True:
            img.save(path, 'PNG', optimize=True)
            size_kb = os.path.getsize(path) / 1024
            if size_kb <= max_kb or quality < 60:
                break
            # Re-save as JPEG-compressed PNG via resize
            w, h = img.size
            scale = 0.85
            img = img.resize((int(w * scale), int(h * scale)), Image.LANCZOS)
            quality -= 5
        final_kb = os.path.getsize(path) / 1024
        print(f'  Saved: {name}  ({final_kb:.0f} KB)')
    except ImportError:
        size_kb = os.path.getsize(path) / 1024
        print(f'  Saved: {name}  ({size_kb:.0f} KB)  [Pillow not available — skipping compression]')
    return path

# ═════════════════════════════════════════════════════════════════════════════
# FIGURE 1.1 — Financial Literacy Rates by Demographic Group
# Source: BSP Financial Inclusion Survey 2021; Inquiro 2024
# ═════════════════════════════════════════════════════════════════════════════
def build_fig_1_1():
    fig, ax = plt.subplots(figsize=(9, 5.5))
    fig.patch.set_facecolor('white')
    ax.set_facecolor(GREY_BG)

    # Data from BSP 2021 FIS and Inquiro 2024
    groups = [
        'All Adults\n(BSP 2021)',
        'Ages 15–24\n(Youth)',
        'Ages 25–44\n(Working Age)',
        'Ages 45–64\n(Pre-Senior)',
        'Ages 65+\n(Senior)',
        'College\nGraduates',
        'High School\nor Below',
    ]
    # BSP 2021: only 2% correctly answered all 6 basic financial literacy Qs
    # Inquiro 2024 provides breakdowns by age/education
    pct_correct_all6   = [2, 1, 3, 2, 1, 6, 1]      # % who answered ALL 6 correctly
    pct_has_budget     = [46, 38, 51, 49, 42, 62, 35] # % who maintain any budget

    x = np.arange(len(groups))
    w = 0.38

    b1 = ax.bar(x - w/2, pct_correct_all6, w,
                label='All 6 Literacy Questions Correct (%)',
                color=MAROON, alpha=0.88, zorder=3)
    b2 = ax.bar(x + w/2, pct_has_budget, w,
                label='Maintain a Household Budget (%)',
                color=TEAL, alpha=0.88, zorder=3)

    # Value labels
    for bar in b1:
        h = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2, h + 0.8,
                f'{h}%', ha='center', va='bottom', fontsize=8,
                fontweight='bold', color=MAROON)
    for bar in b2:
        h = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2, h + 0.8,
                f'{h}%', ha='center', va='bottom', fontsize=8,
                fontweight='bold', color=TEAL)

    ax.set_xticks(x)
    ax.set_xticklabels(groups, fontsize=8.5)
    ax.set_ylim(0, 80)
    ax.set_ylabel('Percentage (%)', fontsize=10)
    ax.yaxis.grid(True, linestyle='--', alpha=0.5, zorder=0)
    ax.set_axisbelow(True)

    ax.set_title(
        'Figure 1.1. Financial Literacy Rates by Demographic Group',
        fontsize=11, fontweight='bold', color=DARK, pad=12)
    ax.text(0.5, -0.18,
        'Sources: Bangko Sentral ng Pilipinas, Financial Inclusion Survey 2021; Inquiro, 2024.',
        transform=ax.transAxes, ha='center', fontsize=7.5,
        color='#666666', style='italic')

    ax.legend(fontsize=9, loc='upper left',
              framealpha=0.9, edgecolor='#CCCCCC')
    ax.spines[['top','right']].set_visible(False)

    fig.tight_layout(rect=[0, 0.06, 1, 1])
    return save(fig, 'Figure_1_1_Financial_Literacy_Rates.png')


# ═════════════════════════════════════════════════════════════════════════════
# FIGURE 1.2 — Conceptual Framework — SmartSpend IPO Model
# ═════════════════════════════════════════════════════════════════════════════
def build_fig_1_2():
    fig, ax = plt.subplots(figsize=(11, 7))
    fig.patch.set_facecolor('white')
    ax.set_xlim(0, 11); ax.set_ylim(0, 7)
    ax.axis('off')

    def box(x, y, w, h, color, text_lines, title=None,
            title_color='white', text_color='white', fs=8.2):
        rect = FancyBboxPatch((x, y), w, h,
                              boxstyle='round,pad=0.08',
                              facecolor=color, edgecolor='white',
                              linewidth=1.5, zorder=3)
        ax.add_patch(rect)
        if title:
            ax.text(x + w/2, y + h - 0.28, title,
                    ha='center', va='top', fontsize=9.5,
                    fontweight='bold', color=title_color, zorder=4)
        start_y = y + h - (0.55 if title else 0.25)
        for i, line in enumerate(text_lines):
            ax.text(x + w/2, start_y - i*0.33, line,
                    ha='center', va='top', fontsize=fs,
                    color=text_color, zorder=4)

    def arrow(x1, y1, x2, y2, color=GOLD):
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color=color,
                                   lw=2.5), zorder=5)

    # Column positions
    col_x = [0.25, 3.8, 7.35]
    col_w = 3.3
    col_h = 5.6
    col_y = 0.7

    # ── INPUT BOX ─────────────────────────────────────────────────────────────
    box(col_x[0], col_y, col_w, col_h, MAROON, [
        '• Natural language text',
        '• Voice (speech_to_text, en-PH)',
        '• Live camera (OCR / barcode)',
        '• Single photo (auto-detect)',
        '• Batch screenshots (40+ types)',
        '• Paste text / CSV import',
        '• Manual form entry',
        '',
        '• Monthly income',
        '• Wallet balances',
        '• Budget limits',
        '• Savings goals',
        '• Debt records',
    ], title='INPUT', fs=7.8)

    # ── PROCESS BOX ───────────────────────────────────────────────────────────
    box(col_x[1], col_y, col_w, col_h, BLUE, [
        '• Gemini 3.1 Flash-Lite (primary)',
        '  + 4 auto-fallback providers',
        '• 31 agentic AI actions',
        '• Dynamic context injection',
        '',
        '• Google ML Kit OCR (Latin)',
        '• Barcode recognition',
        '• Screenshot parsing (regex)',
        '',
        '• FHS computation (4-component)',
        '• FMS computation (4-component)',
        '• Warning decay / gap detection',
        '',
        '• SQLite v11 (offline-first)',
        '• Firebase Firestore (cloud sync)',
    ], title='PROCESS', fs=7.8)

    # ── OUTPUT BOX ────────────────────────────────────────────────────────────
    box(col_x[2], col_y, col_w, col_h, GREEN, [
        '• Recorded expense entries',
        '• AI financial insights',
        '• Natural language summary',
        '',
        '• Financial Health Score (0–100)',
        '  Full Mode + Lightweight Mode',
        '• Score narrative & coach report',
        '',
        '• Budget alerts (supportive)',
        '• Proactive celebration events',
        '• Purchase commentary',
        '',
        '• Spending charts (10+ types)',
        '• Gamification (23 badges,',
        '  10 daily quests, streaks)',
    ], title='OUTPUT', fs=7.8)

    # Arrows
    arrow(col_x[0]+col_w, col_y+col_h/2, col_x[1]-0.05, col_y+col_h/2)
    arrow(col_x[1]+col_w, col_y+col_h/2, col_x[2]-0.05, col_y+col_h/2)

    # Feedback arrow at bottom
    ax.annotate('',
        xy=(col_x[0]+col_w/2, col_y-0.05),
        xytext=(col_x[2]+col_w/2, col_y-0.05),
        arrowprops=dict(arrowstyle='<-', color='#888888',
                        lw=1.5,
                        connectionstyle='arc3,rad=0'))
    ax.text(5.5, col_y-0.35, 'User feedback & corrections',
            ha='center', fontsize=8, color='#888888', style='italic')

    ax.set_title(
        'Figure 1.2. Conceptual Framework — SmartSpend Mobile Application (IPO Model)',
        fontsize=11, fontweight='bold', color=DARK, y=0.98)

    return save(fig, 'Figure_1_2_Conceptual_Framework_IPO.png')


# ═════════════════════════════════════════════════════════════════════════════
# FIGURE 2.1 — System Usability Scale (SUS) Score Interpretation
# Source: Bangor, Kortum & Miller (2009); Brooke (1996)
# ═════════════════════════════════════════════════════════════════════════════
def build_fig_2_1():
    fig, ax = plt.subplots(figsize=(9, 4.5))
    fig.patch.set_facecolor('white')
    ax.set_facecolor('white')
    ax.set_xlim(0, 100); ax.set_ylim(-1, 3)
    ax.axis('off')

    # Score bands
    bands = [
        (0,  51,  '#C62828', 'F',  'Not\nAcceptable', 'Awful'),
        (51, 68,  '#EF6C00', 'D',  'Not\nAcceptable', 'Poor'),
        (68, 74,  '#F9A825', 'C',  'Marginal',        'OK'),
        (74, 80,  '#AFB42B', 'C+', 'Marginal',        'Good'),
        (80, 90,  '#2E7D32', 'B',  'Acceptable',      'Good'),
        (90, 100, '#1B5E20', 'A',  'Acceptable',      'Excellent / Best'),
    ]

    for (lo, hi, col, grade, accept, adj) in bands:
        width = hi - lo
        rect = FancyBboxPatch((lo, 0.8), width, 1.0,
                              boxstyle='square,pad=0',
                              facecolor=col, edgecolor='white', linewidth=1.5)
        ax.add_patch(rect)
        mid = (lo + hi) / 2
        ax.text(mid, 1.75, grade, ha='center', va='center',
                fontsize=12, fontweight='bold', color='white')
        ax.text(mid, 1.25, f'{lo}–{hi}', ha='center', va='center',
                fontsize=8, color='white')
        ax.text(mid, 0.45, adj, ha='center', va='center',
                fontsize=7.5, color=col, fontweight='bold')

    # Scale bar
    ax.annotate('', xy=(100, 0.8), xytext=(0, 0.8),
                arrowprops=dict(arrowstyle='->', lw=1.5, color='#444444'))
    ax.text(0, 0.65, '0', ha='center', fontsize=8, color='#444')
    ax.text(100, 0.65, '100', ha='center', fontsize=8, color='#444')

    # Target line for SmartSpend
    ax.axvline(x=80, color=MAROON, lw=2.5, linestyle='--', ymin=0.35, ymax=0.95, zorder=5)
    ax.text(80, 2.05, '≥80 Target', ha='center', fontsize=9,
            fontweight='bold', color=MAROON,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                      edgecolor=MAROON, linewidth=1.5))

    # Acceptability bracket
    ax.annotate('', xy=(100, 2.55), xytext=(68, 2.55),
                arrowprops=dict(arrowstyle='<->', lw=1.5, color='#2E7D32'))
    ax.text(84, 2.65, 'Acceptable', ha='center', fontsize=9,
            color='#2E7D32', fontweight='bold')

    ax.set_title(
        'Figure 2.1. System Usability Scale (SUS) Score Interpretation',
        fontsize=11, fontweight='bold', color=DARK, pad=14)
    ax.text(0.5, -0.06,
        'Sources: Brooke (1996). SUS: A quick and dirty usability scale. '
        'Bangor, Kortum & Miller (2009). Adjective ratings added.',
        transform=ax.transAxes, ha='center', fontsize=7.5,
        color='#666666', style='italic')

    fig.tight_layout(rect=[0, 0.05, 1, 1])
    return save(fig, 'Figure_2_1_SUS_Score_Interpretation.png')


# ═════════════════════════════════════════════════════════════════════════════
# FIGURE 2.2 — Agile Kanban Workflow for SmartSpend Development
# ═════════════════════════════════════════════════════════════════════════════
def build_fig_2_2():
    FIG_W, FIG_H = 16, 7.0
    fig, ax = plt.subplots(figsize=(FIG_W, FIG_H))
    fig.patch.set_facecolor('white')
    ax.set_xlim(0, FIG_W); ax.set_ylim(0, FIG_H)
    ax.axis('off')

    phases = [
        ('Backlog',       MAROON,    ['Define features', 'Needs survey', 'Literature review']),
        ('Requirements',  '#7B1FA2', ['Validate questionnaire', 'LLM benchmarking', 'Translate to specs']),
        ('Design',        BLUE,      ['SQLite schema\n(20 tables)', 'FHS formula', 'UI wireframes', 'Data flow diagrams']),
        ('Development',   '#00695C', ['Expense tracking', 'Gemini 3.1 Flash-Lite', 'OCR/voice/screenshots',
                                      'FHS engine', 'Firebase sync', '31 agentic actions']),
        ('Testing',       ORANGE,    ['LLM parsing tests', 'SUS survey (n=30)', 'Bug documentation']),
        ('Deployment',    '#1565C0', ['Build release APKs', 'Prepare Demo Mode', 'GitHub Releases v2.9.x']),
        ('Done / Review', GREEN,     ['Analyze SUS scores', 'Panel feedback', 'Final report']),
    ]

    n   = len(phases)
    PAD = 0.25            # horizontal padding between columns
    bw  = FIG_W / n       # column width
    hh  = 0.65            # header height
    by  = 1.10            # body bottom y
    bh  = 4.40            # column body height
    hy  = by + bh         # header bottom y

    for i, (title, color, items) in enumerate(phases):
        x = i * bw

        # ── Phase number circle (above header) ──────────────────────────────
        cx = x + bw / 2
        cy_num = hy + hh + 0.18
        circle = plt.Circle((cx, cy_num), 0.22, color=color, zorder=5)
        ax.add_patch(circle)
        ax.text(cx, cy_num, str(i + 1),
                ha='center', va='center',
                fontsize=9, fontweight='bold', color='white', zorder=6)

        # ── Header bar ──────────────────────────────────────────────────────
        rect_h = FancyBboxPatch((x + PAD * 0.3, hy), bw - PAD * 0.6, hh,
                                boxstyle='round,pad=0.04',
                                facecolor=color, edgecolor='white', lw=1.5,
                                zorder=3)
        ax.add_patch(rect_h)
        ax.text(x + bw / 2, hy + hh / 2, title,
                ha='center', va='center',
                fontsize=8, fontweight='bold', color='white', zorder=4)

        # ── Body column ─────────────────────────────────────────────────────
        rect_b = FancyBboxPatch((x + PAD * 0.3, by), bw - PAD * 0.6, bh,
                                boxstyle='round,pad=0.04',
                                facecolor=f'{color}18', edgecolor=color,
                                linewidth=1.2, zorder=2)
        ax.add_patch(rect_b)

        # ── Item cards ──────────────────────────────────────────────────────
        n_items   = len(items)
        card_h    = 0.52
        card_gap  = (bh - 0.30 - n_items * card_h) / max(n_items - 1, 1)
        card_gap  = max(0.06, min(card_gap, 0.18))
        start_y   = by + bh - 0.15 - card_h

        for j, item in enumerate(items):
            cy = start_y - j * (card_h + card_gap)
            card = FancyBboxPatch((x + PAD * 0.45, cy), bw - PAD * 0.9, card_h,
                                  boxstyle='round,pad=0.04',
                                  facecolor='white', edgecolor=f'{color}88',
                                  linewidth=0.9, zorder=3)
            ax.add_patch(card)
            ax.text(x + bw / 2, cy + card_h / 2, item,
                    ha='center', va='center',
                    fontsize=6.5, color=DARK, zorder=4,
                    wrap=True, multialignment='center')

        # ── Arrow to next column ─────────────────────────────────────────────
        if i < n - 1:
            ay = by + bh / 2
            ax.annotate('',
                xy=((i + 1) * bw + PAD * 0.1, ay),
                xytext=(x + bw - PAD * 0.1, ay),
                arrowprops=dict(arrowstyle='->', color='#BBBBBB', lw=1.8),
                zorder=5)

    # Footer note
    ax.text(FIG_W / 2, 0.45,
            'Each phase produces a deliverable. Completed items move right. '
            'Panel feedback re-enters at Backlog.',
            ha='center', fontsize=7.5, color='#666666', style='italic')

    ax.set_title(
        'Figure 2.2. Agile Kanban Workflow for SmartSpend Development',
        fontsize=12, fontweight='bold', color=DARK, pad=14)

    fig.tight_layout(rect=[0, 0.05, 1, 0.96])
    return save(fig, 'Figure_2_2_Agile_Kanban_Workflow.png')


# ── RUN ALL ───────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    print('Building manuscript figures...')
    p1 = build_fig_1_1()
    p2 = build_fig_1_2()
    p3 = build_fig_2_1()
    p4 = build_fig_2_2()
    print(f'\nAll figures saved to: {OUTDIR}')
    print('  Figure 1.1 — Financial Literacy Rates')
    print('  Figure 1.2 — IPO Conceptual Framework')
    print('  Figure 2.1 — SUS Score Interpretation')
    print('  Figure 2.2 — Agile Kanban Workflow')
