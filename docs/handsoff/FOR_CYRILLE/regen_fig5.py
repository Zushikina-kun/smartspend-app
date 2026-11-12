"""
Regenerate Figure 5: Demographic Distribution
Updated: Parents=16 (includes 3 reclassified from 'Both'), YP=14
No more 'Both Groups' bar since they were merged into parents.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import shutil
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph
from docx.shared import Inches

FIG_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES\Figure_Demographic_Breakdown.png'
DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

# ── Generate updated chart ─────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(7, 4.5))
fig.patch.set_facecolor('white')
ax.set_facecolor('white')

categories = ['Parents\n(Ages 35–55)', 'Young Professionals\n(Ages 21–35)']
counts = [16, 14]
pcts = ['53.3%', '46.7%']
colors = ['#E8A87C', '#00C896']

bars = ax.bar(categories, counts, color=colors, width=0.5, zorder=3)
ax.set_ylim(0, 22)
ax.set_ylabel('Number of Respondents', fontsize=11)
ax.set_title(
    'Figure 5. Demographic Distribution of Needs-Assessment Respondents (N = 30)\n'
    '(3 respondents who identified as both groups were reclassified as parents)',
    fontsize=10, fontweight='bold', pad=12
)
ax.yaxis.set_major_locator(plt.MultipleLocator(5))
ax.grid(axis='y', linestyle='--', alpha=0.4, zorder=0)
for spine in ['top', 'right']:
    ax.spines[spine].set_visible(False)

for bar, count, pct in zip(bars, counts, pcts):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.4,
            f'{count}\n({pct})', ha='center', va='bottom',
            fontsize=12, fontweight='bold')

ax.text(0.5, -0.18,
        'Sources: Needs-Assessment Survey, SmartSpend Study (2026)',
        transform=ax.transAxes, ha='center', fontsize=8, color='#555555',
        style='italic')

plt.tight_layout()
plt.savefig(FIG_PATH, dpi=180, bbox_inches='tight', facecolor='white')
plt.close()
print(f'Saved: {FIG_PATH}')

# ── Re-embed in manuscript ─────────────────────────────────────────────────
shutil.copy(DOCX, DOCX + '.fig5.bak')
doc = Document(DOCX)

for i, para in enumerate(doc.paragraphs):
    if 'Figure 5' in para.text and 'Demographic' in para.text:
        # Image should be in para i-1 or i-2
        for offset in [1, 2, 3]:
            img_para = doc.paragraphs[i - offset] if i >= offset else None
            if img_para and img_para._p.findall('.//' + qn('a:blip')):
                # Clear existing image and re-embed
                for run in img_para.runs:
                    run._element.getparent().remove(run._element)
                run = img_para.add_run()
                run.add_picture(FIG_PATH, width=Inches(5.5))
                img_para.alignment = 1  # center
                print(f'Re-embedded Figure 5 at para {i-offset}')
                break
        break

doc.save(DOCX)
print('Manuscript saved.')
