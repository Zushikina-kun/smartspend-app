"""
Fix all PPT issues:
1. Slide 9: regenerate tracking methods chart with proper labels
2. Slide 15: regenerate SUS results chart with proper labels
3. Slide 14: fix Tier 3 text overflow
4. Minor position/overflow fixes
"""
import shutil, io, os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

PPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
shutil.copy(PPT, PPT + '.charts_fix.bak')
prs = Presentation(PPT)
log = []

GREEN  = '#1a7a4a'
GREEN2 = '#2d9e63'
GOLD   = '#d4a017'
GRAY   = '#94a3b8'
RED    = '#c0392b'
BLUE   = '#2471a3'

# ══════════════════════════════════════════════════════
# HELPER: replace image in a Picture shape
# ══════════════════════════════════════════════════════
def replace_picture(shape, img_bytes):
    """Replace the image bytes in a picture shape."""
    from pptx.oxml.ns import qn
    # Find blip ref
    blip = shape._element.find('.//' + qn('a:blip'))
    if blip is None:
        return False
    rEmbed = blip.get(qn('r:embed'))
    if rEmbed is None:
        return False
    rel = shape.part.rels.get(rEmbed)
    if rel is None:
        return False
    rel.target_part._blob = img_bytes
    return True

def fig_to_bytes(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=180, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = buf.read()
    buf.close()
    plt.close(fig)
    return data

# ══════════════════════════════════════════════════════
# FIX 1 — Slide 9: Tracking Methods chart
# ══════════════════════════════════════════════════════
fig9, ax9 = plt.subplots(figsize=(9, 5.5))
fig9.patch.set_facecolor('white')

methods = ['Receipts', 'Mental\nestimates', 'E-wallet\nhistory', 'Notes\napp', 'Notebook', 'Mobile\napp (dedicated)']
values  = [90.0, 53.3, 43.3, 30.0, 23.3, 10.0]
colors9 = [GREEN, GREEN2, GREEN2, GRAY, GRAY, '#e74c3c']

bars9 = ax9.barh(methods, values, color=colors9, edgecolor='white', linewidth=1.5, height=0.6)

# Value labels
for bar, val in zip(bars9, values):
    ax9.text(val + 1, bar.get_y() + bar.get_height()/2,
             f'{val}%', va='center', ha='left',
             fontsize=11, fontweight='bold', color='#1e293b')

# Key annotations
ax9.axvline(93.3, color='#e67e22', linestyle='--', linewidth=1.5, alpha=0.7)
ax9.text(94, 2.5, '93.3% use GCash\n(validating import feature)', fontsize=8,
         color='#e67e22', va='center')

ax9.set_xlim(0, 115)
ax9.set_xlabel('% of 30 respondents (multiple answers allowed)', fontsize=10, color='#475569')
ax9.invert_yaxis()
ax9.spines['top'].set_visible(False)
ax9.spines['right'].set_visible(False)
ax9.spines['left'].set_color('#e2e8f0')
ax9.tick_params(axis='y', labelsize=11, length=0)
ax9.tick_params(axis='x', labelsize=9)
ax9.xaxis.grid(True, color='#f1f5f9', linewidth=0.8)
ax9.set_axisbelow(True)
ax9.set_title('How respondents track expenses today (% of 30, multiple answers)', 
              fontsize=11, color='#1e293b', pad=10, fontweight='semibold')

plt.tight_layout(pad=1.2)
img9 = fig_to_bytes(fig9)
log.append(f'Slide 9: regenerated tracking methods chart ({len(img9)//1024}KB)')

# Replace in slide 9
slide9 = prs.slides[8]
for shape in slide9.shapes:
    if shape.shape_type == 13:
        if replace_picture(shape, img9):
            log.append('Slide 9: chart image replaced')
        break

# ══════════════════════════════════════════════════════
# FIX 2 — Slide 15: SUS Results chart
# ══════════════════════════════════════════════════════
fig15, ax15 = plt.subplots(figsize=(8, 5.5))
fig15.patch.set_facecolor('white')

groups  = ['Parents\n(n=10)', 'Young\nProfessionals\n(n=20)', 'Combined\n(N=30)']
scores  = [58.25, 63.62, 61.83]
bar_colors = ['#e67e22', '#2471a3', GREEN]

bars15 = ax15.bar(groups, scores, color=bar_colors, width=0.5,
                   edgecolor='white', linewidth=2)

# Value labels on bars
for bar, val in zip(bars15, scores):
    ax15.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.8,
              f'{val}', ha='center', va='bottom',
              fontsize=13, fontweight='bold', color='#1e293b')

# Reference lines
ax15.axhline(68, color='#555555', linestyle='--', linewidth=2, zorder=4,
             label='68 avg. benchmark (Sauro & Lewis, 2016)')
ax15.axhline(80, color=BLUE,     linestyle=':',  linewidth=2, zorder=4,
             label='80 pre-set target (Bangor et al., 2009)')
ax15.axhline(61.83, color=RED,   linestyle='-',  linewidth=1.5, alpha=0.5, zorder=3)

# Annotations
ax15.text(2.6, 68.8, '68 (avg.)', fontsize=9, color='#555555', va='bottom')
ax15.text(2.6, 80.8, '80 (target)', fontsize=9, color=BLUE, va='bottom')

# "OK" adjective label on each bar
for bar, label in zip(bars15, ['OK', 'OK', 'OK']):
    ax15.text(bar.get_x() + bar.get_width()/2,
              bar.get_height()/2,
              f'"OK"', ha='center', va='center',
              fontsize=10, fontweight='bold', color='white', alpha=0.9)

ax15.set_ylim(0, 100)
ax15.set_yticks([0, 20, 40, 60, 80, 100])
ax15.set_ylabel('SUS Score (0–100)', fontsize=10, color='#475569')
ax15.spines['top'].set_visible(False)
ax15.spines['right'].set_visible(False)
ax15.tick_params(axis='x', labelsize=11, length=0)
ax15.tick_params(axis='y', labelsize=9)
ax15.yaxis.grid(True, color='#f1f5f9', linewidth=0.8)
ax15.set_axisbelow(True)

patches = [
    mpatches.Patch(color='#555555', label='68 avg. benchmark (Sauro & Lewis, 2016)'),
    mpatches.Patch(color=BLUE,      label='80 pre-set target'),
]
ax15.legend(handles=patches, loc='lower right', fontsize=8.5,
            framealpha=0.9, borderpad=0.8)

plt.tight_layout(pad=1.2)
img15 = fig_to_bytes(fig15)
log.append(f'Slide 15: regenerated SUS comparison chart ({len(img15)//1024}KB)')

slide15 = prs.slides[14]
for shape in slide15.shapes:
    if shape.shape_type == 13:
        if replace_picture(shape, img15):
            log.append('Slide 15: chart image replaced')
        break

# ══════════════════════════════════════════════════════
# FIX 3 — Slide 14: Fix Tier 3 text overflow
# ══════════════════════════════════════════════════════
slide14 = prs.slides[13]
from pptx.oxml.ns import qn

def get_all_runs(shape):
    runs = []
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                runs.append(run)
    if shape.shape_type == 6:
        for s in shape.shapes:
            runs.extend(get_all_runs(s))
    return runs

for shape in slide14.shapes:
    for run in get_all_runs(shape):
        if 'NOT yet built' in run.text or 'target-user devices lack the RAM' in run.text:
            # Shorten the text to prevent overflow
            full = shape.text_frame.text if shape.has_text_frame else ''
            if 'NOT yet built' in full or 'target-user devices lack the RAM' in full:
                # Enable word wrap
                if shape.has_text_frame:
                    shape.text_frame.word_wrap = True
                    # Reduce font size slightly
                    for para in shape.text_frame.paragraphs:
                        for run in para.runs:
                            if run.font.size and run.font.size > Pt(11):
                                run.font.size = Pt(11)
                log.append('Slide 14: enabled word wrap on Tier 3 text box')
                break

# Also fix the shape height/position if needed - enable auto-fit
for shape in slide14.shapes:
    if shape.has_text_frame and 'NOT yet built' in shape.text_frame.text:
        shape.text_frame.auto_size = None
        shape.text_frame.word_wrap = True
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                if run.font.size is None or run.font.size > Pt(13):
                    run.font.size = Pt(12)
        log.append('Slide 14: Tier 3 text resized and word-wrapped')

# ══════════════════════════════════════════════════════
# FIX 4 — Move slightly off-slide images back
# ══════════════════════════════════════════════════════
w = prs.slide_width
h = prs.slide_height

for slide_idx in [8, 11, 14]:  # slides 9, 12, 15 (0-indexed)
    slide = prs.slides[slide_idx]
    for shape in slide.shapes:
        # Nudge pictures that are slightly off-slide back in
        if shape.shape_type == 13:
            if shape.left < 0:
                old = shape.left
                shape.left = 0
                log.append(f'Slide {slide_idx+1}: moved picture from left={old//9144}pt to 0')
            if shape.left + shape.width > w:
                old = shape.left
                shape.left = w - shape.width
                log.append(f'Slide {slide_idx+1}: moved picture to fit within slide width')

# ══════════════════════════════════════════════════════
# FIX 5 — Slide 11: verify figure labels match manuscript
# ══════════════════════════════════════════════════════
slide11 = prs.slides[10]
# Figure labels should be: 9, 10, 11, 12, 13
expected = {
    'Figure 9': 'Figure 9. Login and Demo Mode',
    'Figure 10': 'Figure 10. Home Dashboard',
    'Figure 11': 'Figure 11. Expense Logging Through Peso Chat',
    'Figure 12': 'Figure 12. Receipt Scanning and Batch Screenshot Import',
    'Figure 13': 'Figure 13. Financial Health Score Breakdown',
}
for shape in slide11.shapes:
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            t = para.text.strip()
            for fignum, correct in expected.items():
                if fignum in t and t != correct:
                    for run in para.runs:
                        if fignum in run.text:
                            run.text = correct
                            log.append(f'Slide 11: fixed caption "{t}" -> "{correct}"')

prs.save(PPT)
log.append('PPT saved.')

# ── Summary ───────────────────────────────────────────────────────────────
print(f'\n{len(log)} actions:')
for l in log:
    print(f'  {l}')

# Clean up temp files
for f in ['slide9_chart.png', 'slide15_chart.png', 'slide12_chart.png']:
    try:
        os.remove(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\\' + f)
    except:
        pass
