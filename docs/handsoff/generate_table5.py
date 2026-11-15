"""
Generate a clean Table 5 DOCX file for copy-paste into the manuscript.
Option B: Parents (n=16), Young Professionals (n=14), Total (N=30)
No "Both" column. No typos.
"""
from docx import Document
from docx.shared import Pt, RGBColor, Inches, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import copy

doc = Document()

# Set narrow margins
for section in doc.sections:
    section.top_margin    = Inches(1)
    section.bottom_margin = Inches(1)
    section.left_margin   = Inches(1)
    section.right_margin  = Inches(1)

# ── Caption ───────────────────────────────────────────────────────────────
cap = doc.add_paragraph()
cap.alignment = WD_ALIGN_PARAGRAPH.LEFT
r = cap.add_run('Table 5: ')
r.bold = True
r.font.size = Pt(11)
r2 = cap.add_run('Demographic Profile and Expense Tracking Methods of Respondents (N = 30)')
r2.font.size = Pt(11)
cap.paragraph_format.space_after = Pt(4)

# ── Table data ────────────────────────────────────────────────────────────
# col headers
headers = ['Item', 'Parents\n(n = 16)', 'Young Professionals\n(n = 14)', 'Total\n(N = 30)']

# rows: (text, p_val, yp_val, total_val)
# None = merged/spanned cell (leave blank)
rows_data = [
    # Section A header
    ('A. Demographic profile, f (%)', None, None, None),
    ('Parents aged 35–55',           '16 (53.3%)', '—', '16 (53.3%)'),
    ('Young professionals aged 21–35','—', '14 (46.7%)', '14 (46.7%)'),
    ('Employed full-time',            '', '', '10 (33.3%)'),
    ('Freelance or contractual',      '', '', '9 (30.0%)'),
    ('Self-employed',                 '', '', '8 (26.7%)'),
    ('Unemployed or part-time',       '', '', '3 (10.0%)'),
    ('GCash users',                   '', '', '28 (93.3%)'),
    # Section B header
    ('B. Expense tracking methods used, f (%)', None, None, None),
    ('Receipts',                      '14 (87.5%)', '13 (92.9%)', '27 (90.0%)'),
    ('Mental estimates',              '9 (56.3%)',  '7 (50.0%)',  '16 (53.3%)'),
    ('E-wallet transaction history',  '7 (43.8%)',  '6 (42.9%)',  '13 (43.3%)'),
    ('Notes app',                     '4 (25.0%)',  '5 (35.7%)',  '9 (30.0%)'),
    ('Notebook',                      '4 (25.0%)',  '3 (21.4%)',  '7 (23.3%)'),
    ('Mobile app',                    '1 (6.3%)',   '2 (14.3%)',  '3 (10.0%)'),
]

col_widths = [Cm(6.5), Cm(2.8), Cm(3.2), Cm(2.8)]

tbl = doc.add_table(rows=1 + len(rows_data), cols=4)
tbl.style = 'Table Grid'
tbl.alignment = WD_TABLE_ALIGNMENT.LEFT

def set_cell_bg(cell, hex_color):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), hex_color)
    tcPr.append(shd)

def set_cell_text(cell, text, bold=False, italic=False, size=10, align=WD_ALIGN_PARAGRAPH.LEFT, color=None):
    cell.text = ''
    para = cell.paragraphs[0]
    para.alignment = align
    run = para.add_run(text)
    run.bold = bold
    run.italic = italic
    run.font.size = Pt(size)
    if color:
        run.font.color.rgb = RGBColor(*color)
    cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER

# ── Header row ────────────────────────────────────────────────────────────
hdr = tbl.rows[0]
for i, (cell, w, htext) in enumerate(zip(hdr.cells, col_widths, headers)):
    cell.width = w
    set_cell_text(cell, htext, bold=True, size=10, align=WD_ALIGN_PARAGRAPH.CENTER)
    set_cell_bg(cell, '1F4E79')
    for run in cell.paragraphs[0].runs:
        run.font.color.rgb = RGBColor(255, 255, 255)

# ── Data rows ─────────────────────────────────────────────────────────────
SECTION_BG = 'D6E4F0'   # light blue for section headers
DATA_BG_1  = 'FFFFFF'
DATA_BG_2  = 'F2F7FC'

for ri, (rtext, p, yp, tot) in enumerate(rows_data):
    row = tbl.rows[ri + 1]
    for i, w in enumerate(col_widths):
        row.cells[i].width = w

    is_section = (p is None)

    if is_section:
        # Merge all 4 cells for section header
        row.cells[0].merge(row.cells[3])
        set_cell_text(row.cells[0], rtext, bold=True, size=10)
        set_cell_bg(row.cells[0], SECTION_BG)
    else:
        bg = DATA_BG_1 if ri % 2 == 0 else DATA_BG_2
        vals = [rtext, p or '', yp or '', tot or '']
        aligns = [WD_ALIGN_PARAGRAPH.LEFT,
                  WD_ALIGN_PARAGRAPH.CENTER,
                  WD_ALIGN_PARAGRAPH.CENTER,
                  WD_ALIGN_PARAGRAPH.CENTER]
        for ci, (cell, val, aln) in enumerate(zip(row.cells, vals, aligns)):
            set_cell_text(cell, val, size=10, align=aln)
            set_cell_bg(cell, bg)

# ── Set column widths explicitly ──────────────────────────────────────────
for row in tbl.rows:
    for i, w in enumerate(col_widths):
        try:
            row.cells[i].width = w
        except Exception:
            pass

# ── Note paragraph ────────────────────────────────────────────────────────
doc.add_paragraph()  # small gap
note = doc.add_paragraph()
note.alignment = WD_ALIGN_PARAGRAPH.LEFT
nr = note.add_run(
    'Note. '
)
nr.italic = True
nr.font.size = Pt(9.5)
nr2 = note.add_run(
    'Respondents could select more than one tracking method, so percentages were computed '
    'within each group (parents n = 16, young professionals n = 14) and for the total sample '
    '(N = 30); columns therefore did not sum to 100%. Three respondents who identified as both '
    'groups were classified with the parent group based on their Q1 age bracket (Ages 35–55).'
)
nr2.italic = True
nr2.font.size = Pt(9.5)

OUT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\Table5_clean.docx'
doc.save(OUT)
print(f'Saved: {OUT}')
print('Open in Word, select all (Ctrl+A), copy, then paste into your manuscript.')
