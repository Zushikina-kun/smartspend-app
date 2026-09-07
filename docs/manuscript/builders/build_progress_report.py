"""
build_progress_report.py
Generates Lorma BSIT Capstone Progress Report DOCX files
matching the exact template format from Capstone_Progress_Report_BSIT.docx

Usage:
    python build_progress_report.py week4
    python build_progress_report.py week5
    python build_progress_report.py all

Output:
    docs/manuscript/SmartSpend_Progress_Report_Week4.docx
    docs/manuscript/SmartSpend_Progress_Report_Week5.docx
"""

import sys
import os
from pathlib import Path
from docx import Document
from docx.shared import Pt, Inches, RGBColor, Cm, Twips
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_ALIGN_VERTICAL, WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import copy

# ── Lorma template colours ────────────────────────────────────────────────────
MAROON_DARK  = RGBColor(0x5C, 0x0E, 0x24)  # title banner + section headings
MAROON_LOGO  = RGBColor(0x7A, 0x12, 0x30)  # "LORMA COLLEGES"
DARK_TEXT    = RGBColor(0x22, 0x22, 0x22)  # body / adviser name
GREY_TEXT    = RGBColor(0x6B, 0x6B, 0x6B)  # subtitles, prompts, labels
WHITE        = RGBColor(0xFF, 0xFF, 0xFF)
CREAM_BG     = "F2EFEC"   # instructions box background (hex string)
MAROON_HEX   = "5C0E24"   # banner background

FONT = "Tahoma"

# ── Helper utilities ──────────────────────────────────────────────────────────

def set_cell_bg(cell, hex_color: str):
    """Fill a table cell with a solid background colour."""
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), hex_color)
    tcPr.append(shd)


def set_col_width(cell, width_twips: int):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    tcW = OxmlElement('w:tcW')
    tcW.set(qn('w:w'), str(width_twips))
    tcW.set(qn('w:type'), 'dxa')
    tcPr.append(tcW)


def add_para(cell_or_doc, text: str, bold=False, size_pt=9,
             color: RGBColor = None, align=WD_ALIGN_PARAGRAPH.LEFT,
             space_before=0, space_after=0) -> None:
    """Add a paragraph to a cell or document with given formatting."""
    if hasattr(cell_or_doc, 'paragraphs') and hasattr(cell_or_doc, '_body'):
        # It's a cell
        p = cell_or_doc.add_paragraph()
    else:
        p = cell_or_doc.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_before = Pt(space_before)
    p.paragraph_format.space_after = Pt(space_after)
    run = p.add_run(text)
    run.font.name = FONT
    run.font.size = Pt(size_pt)
    run.bold = bold
    if color:
        run.font.color.rgb = color
    return p


def set_table_borders(table, border_color="BFBFBF", border_size=4):
    """Apply thin borders to all cells in a table."""
    tbl = table._tbl
    tblPr = tbl.tblPr
    if tblPr is None:
        tblPr = OxmlElement('w:tblPr')
        tbl.insert(0, tblPr)
    tblBorders = OxmlElement('w:tblBorders')
    for side in ('top', 'left', 'bottom', 'right', 'insideH', 'insideV'):
        border = OxmlElement(f'w:{side}')
        border.set(qn('w:val'), 'single')
        border.set(qn('w:sz'), str(border_size))
        border.set(qn('w:space'), '0')
        border.set(qn('w:color'), border_color)
        tblBorders.append(border)
    tblPr.append(tblBorders)


def clear_table_borders(table):
    """Remove borders from a table (for header/logo table)."""
    tbl = table._tbl
    tblPr = tbl.tblPr
    if tblPr is None:
        tblPr = OxmlElement('w:tblPr')
        tbl.insert(0, tblPr)
    tblBorders = OxmlElement('w:tblBorders')
    for side in ('top', 'left', 'bottom', 'right', 'insideH', 'insideV'):
        border = OxmlElement(f'w:{side}')
        border.set(qn('w:val'), 'none')
        border.set(qn('w:sz'), '0')
        border.set(qn('w:space'), '0')
        border.set(qn('w:color'), 'auto')
        tblBorders.append(border)
    tblPr.append(tblBorders)


def set_table_width(table, width_twips: int):
    tbl = table._tbl
    tblPr = tbl.tblPr
    if tblPr is None:
        tblPr = OxmlElement('w:tblPr')
        tbl.insert(0, tblPr)
    # Remove any existing tblW elements first to avoid duplicates
    for existing in tblPr.findall(qn('w:tblW')):
        tblPr.remove(existing)
    tblW = OxmlElement('w:tblW')
    tblW.set(qn('w:w'), str(width_twips))
    tblW.set(qn('w:type'), 'dxa')
    tblPr.append(tblW)


# ── Main builder ──────────────────────────────────────────────────────────────

def build_report(data: dict, output_path: Path):
    doc = Document()

    # ── Page setup: Letter, 0.7" margins ─────────────────────────────────────
    section = doc.sections[0]
    section.page_width  = Inches(8.5)
    section.page_height = Inches(11)
    margin = Inches(0.7)
    section.top_margin    = margin
    section.bottom_margin = margin
    section.left_margin   = margin
    section.right_margin  = margin

    # Remove default paragraph spacing
    doc.styles['Normal'].font.name = FONT
    doc.styles['Normal'].font.size = Pt(9)
    doc.styles['Normal'].paragraph_format.space_before = Pt(0)
    doc.styles['Normal'].paragraph_format.space_after  = Pt(2)

    # ── HEADER TABLE (3-col, borderless) ─────────────────────────────────────
    hdr = doc.add_table(rows=1, cols=3)
    set_table_width(hdr, 10224)
    clear_table_borders(hdr)
    hdr.alignment = WD_TABLE_ALIGNMENT.CENTER

    # Left logo placeholder
    lc = hdr.cell(0, 0)
    set_col_width(lc, 2100)
    p = lc.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run('[Logo]')
    run.font.name = FONT; run.font.size = Pt(8); run.font.color.rgb = GREY_TEXT

    # Center — school name block
    cc = hdr.cell(0, 1)
    set_col_width(cc, 6024)
    cc.paragraphs[0].clear()
    for txt, bold, sz, col in [
        ('LORMA COLLEGES',                               True,  15, MAROON_LOGO),
        ('College of Computer Studies and Engineering',  False, 10, DARK_TEXT),
        ('Bachelor of Science in Information Technology',False,  9, GREY_TEXT),
    ]:
        p = cc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after  = Pt(1)
        r = p.add_run(txt)
        r.font.name = FONT; r.font.size = Pt(sz); r.bold = bold; r.font.color.rgb = col

    # Right logo placeholder
    rc = hdr.cell(0, 2)
    set_col_width(rc, 2100)
    p = rc.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run('[Logo]')
    run.font.name = FONT; run.font.size = Pt(8); run.font.color.rgb = GREY_TEXT

    # ── Spacer ────────────────────────────────────────────────────────────────
    sp = doc.add_paragraph()
    sp.paragraph_format.space_before = Pt(4)
    sp.paragraph_format.space_after  = Pt(0)

    # ── TITLE BANNER ─────────────────────────────────────────────────────────
    banner = doc.add_table(rows=1, cols=1)
    set_table_width(banner, 10224)
    clear_table_borders(banner)
    bc = banner.cell(0, 0)
    set_cell_bg(bc, MAROON_HEX)
    p = bc.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after  = Pt(4)
    r = p.add_run('CAPSTONE PROJECT PROGRESS REPORT')
    r.font.name = FONT; r.font.size = Pt(13); r.bold = True; r.font.color.rgb = WHITE

    # ── Spacer ────────────────────────────────────────────────────────────────
    doc.add_paragraph()

    # ── GENERAL INSTRUCTIONS BOX ─────────────────────────────────────────────
    ibox = doc.add_table(rows=1, cols=1)
    set_table_width(ibox, 10224)
    set_table_borders(ibox, "CCCCCC", 4)
    ic = ibox.cell(0, 0)
    set_cell_bg(ic, CREAM_BG)
    p = ic.paragraphs[0]
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after  = Pt(2)
    r = p.add_run('GENERAL INSTRUCTIONS')
    r.font.name = FONT; r.font.size = Pt(9); r.bold = True; r.font.color.rgb = DARK_TEXT
    instructions = [
        'Use this format for all progress report submissions.',
        'Encode the report clearly and concisely.',
        'Submit on or before the deadline set by the adviser.',
        'Attach photo documentation as required.',
    ]
    for inst in instructions:
        p2 = ic.add_paragraph(style='List Bullet')
        p2.paragraph_format.space_before = Pt(0)
        p2.paragraph_format.space_after  = Pt(1)
        p2.paragraph_format.left_indent  = Inches(0.25)
        r2 = p2.add_run(inst)
        r2.font.name = FONT; r2.font.size = Pt(9); r2.font.color.rgb = DARK_TEXT

    doc.add_paragraph()

    # ── SECTION: Report Details ───────────────────────────────────────────────
    _section_label(doc, 'Report Details')

    details = doc.add_table(rows=3, cols=2)
    set_table_width(details, 10224)
    set_table_borders(details, "AAAAAA", 4)
    details.alignment = WD_TABLE_ALIGNMENT.LEFT
    label_w, val_w = 2200, 8024
    rows_data = [
        ('Project / Capstone Title', data['project_title']),
        ('Report No.',               data['report_no']),
        ('Date Submitted',           data['date_submitted']),
    ]
    for i, (lbl, val) in enumerate(rows_data):
        lc2 = details.cell(i, 0)
        vc  = details.cell(i, 1)
        set_col_width(lc2, label_w)
        set_col_width(vc,  val_w)
        lc2.paragraphs[0].clear()
        p = lc2.paragraphs[0]
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after  = Pt(2)
        r = p.add_run(lbl)
        r.font.name = FONT; r.font.size = Pt(9); r.bold = True; r.font.color.rgb = DARK_TEXT
        vc.paragraphs[0].clear()
        p2 = vc.paragraphs[0]
        p2.paragraph_format.space_before = Pt(2)
        p2.paragraph_format.space_after  = Pt(2)
        r2 = p2.add_run(val)
        r2.font.name = FONT; r2.font.size = Pt(9); r2.font.color.rgb = DARK_TEXT

    doc.add_paragraph()

    # ── SECTION: Members ─────────────────────────────────────────────────────
    _section_label(doc, 'Members')

    members_tbl = doc.add_table(rows=len(data['members']) + 1, cols=2)
    set_table_width(members_tbl, 10224)
    set_table_borders(members_tbl, "AAAAAA", 4)
    num_w, name_w = 800, 9424

    # Header row
    for col_i, htext in enumerate(['#', 'Member Name']):
        c = members_tbl.cell(0, col_i)
        set_col_width(c, num_w if col_i == 0 else name_w)
        set_cell_bg(c, "E8E0DA")
        p = c.paragraphs[0]
        p.paragraph_format.space_before = Pt(2); p.paragraph_format.space_after = Pt(2)
        r = p.add_run(htext)
        r.font.name = FONT; r.font.size = Pt(9); r.bold = True; r.font.color.rgb = DARK_TEXT

    for i, member in enumerate(data['members'], start=1):
        nc = members_tbl.cell(i, 0)
        mc = members_tbl.cell(i, 1)
        set_col_width(nc, num_w)
        set_col_width(mc, name_w)
        for c2, txt in [(nc, str(i)), (mc, member)]:
            p = c2.paragraphs[0]
            p.paragraph_format.space_before = Pt(2); p.paragraph_format.space_after = Pt(2)
            r = p.add_run(txt)
            r.font.name = FONT; r.font.size = Pt(9); r.font.color.rgb = DARK_TEXT

    doc.add_paragraph()

    # ── SECTION: Narrative ────────────────────────────────────────────────────
    _section_label(doc, 'Narrative')

    p_intro = doc.add_paragraph()
    p_intro.paragraph_format.space_before = Pt(0)
    p_intro.paragraph_format.space_after  = Pt(4)
    r = p_intro.add_run('Describe the project\'s current status. Write each part in paragraph form.')
    r.font.name = FONT; r.font.size = Pt(9); r.font.color.rgb = GREY_TEXT

    narrative_sections = [
        ('1. Tasks Already Completed',
         'What has the team finished since the last report?',
         data['completed']),
        ('2. Ongoing Activities',
         'What is currently in progress?',
         data['ongoing']),
        ('3. Problems or Challenges Encountered',
         'What issues or roadblocks came up?',
         data['problems']),
        ('4. Solutions Applied or Actions Taken',
         'How were the above issues addressed?',
         data['solutions']),
        ('5. Next Steps / Plans Before the Next Report',
         'What will the team do next?',
         data['next_steps']),
    ]

    for heading, prompt, content in narrative_sections:
        # Subsection heading
        ph = doc.add_paragraph()
        ph.paragraph_format.space_before = Pt(6)
        ph.paragraph_format.space_after  = Pt(1)
        rh = ph.add_run(heading)
        rh.font.name = FONT; rh.font.size = Pt(10.5); rh.bold = True
        rh.font.color.rgb = MAROON_DARK

        # Prompt question
        pp2 = doc.add_paragraph()
        pp2.paragraph_format.space_before = Pt(0)
        pp2.paragraph_format.space_after  = Pt(3)
        rp = pp2.add_run(prompt)
        rp.font.name = FONT; rp.font.size = Pt(8.5); rp.font.color.rgb = GREY_TEXT

        # Content box (single-cell bordered table)
        ctbl = doc.add_table(rows=1, cols=1)
        set_table_width(ctbl, 10224)
        set_table_borders(ctbl, "AAAAAA", 4)
        cc2 = ctbl.cell(0, 0)
        cc2.paragraphs[0].clear()

        # Write content paragraphs
        lines = content.strip().split('\n')
        first = True
        for line in lines:
            if first:
                p2 = cc2.paragraphs[0]
                first = False
            else:
                p2 = cc2.add_paragraph()
            p2.paragraph_format.space_before = Pt(3)
            p2.paragraph_format.space_after  = Pt(3)
            r2 = p2.add_run(line)
            r2.font.name = FONT; r2.font.size = Pt(9.5); r2.font.color.rgb = DARK_TEXT

        doc.add_paragraph()

    # ── SECTION: Photo Documentation ──────────────────────────────────────────
    _section_label(doc, 'Photo Documentation')

    p_photo_inst = doc.add_paragraph()
    p_photo_inst.paragraph_format.space_before = Pt(0)
    p_photo_inst.paragraph_format.space_after  = Pt(4)
    r = p_photo_inst.add_run(
        'Attach clear photos showing actual progress of the project. '
        'Each photo should have a short caption describing what is shown.')
    r.font.name = FONT; r.font.size = Pt(9); r.font.color.rgb = GREY_TEXT

    photo_pairs = data.get('photos', [])  # list of (path, caption) tuples
    # Pad to even number
    if len(photo_pairs) % 2 != 0:
        photo_pairs = list(photo_pairs) + [('', '')]

    col_w = 5112  # half of 10224

    for pair_idx in range(0, len(photo_pairs), 2):
        left_img,  left_cap  = photo_pairs[pair_idx]
        right_img, right_cap = photo_pairs[pair_idx + 1]

        # One table per pair: row 0 = images, row 1 = captions
        tbl = doc.add_table(rows=2, cols=2)
        set_table_width(tbl, 10224)
        set_table_borders(tbl, "AAAAAA", 4)

        for col_i, (img_path, caption) in enumerate([(left_img, left_cap), (right_img, right_cap)]):
            img_cell  = tbl.cell(0, col_i)
            cap_cell  = tbl.cell(1, col_i)
            set_col_width(img_cell, col_w)
            set_col_width(cap_cell, col_w)

            # Image row
            ip = img_cell.paragraphs[0]
            ip.alignment = WD_ALIGN_PARAGRAPH.CENTER
            ip.paragraph_format.space_before = Pt(4)
            ip.paragraph_format.space_after  = Pt(4)
            if img_path and os.path.isfile(img_path):
                run = ip.add_run()
                # Portrait screenshot: fit width ~2.3" so two fit side-by-side
                run.add_picture(img_path, width=Inches(2.3))
            else:
                r2 = ip.add_run('[ Insert Photo Here ]')
                r2.font.name = FONT; r2.font.size = Pt(8.5)
                r2.font.color.rgb = GREY_TEXT
                ip.paragraph_format.space_before = Pt(36)
                ip.paragraph_format.space_after  = Pt(36)

            # Caption row
            cp = cap_cell.paragraphs[0]
            cp.alignment = WD_ALIGN_PARAGRAPH.LEFT
            cp.paragraph_format.space_before = Pt(3)
            cp.paragraph_format.space_after  = Pt(3)
            cap_text = caption if caption else 'Caption: '
            r3 = cp.add_run(cap_text)
            r3.font.name = FONT; r3.font.size = Pt(9)
            r3.font.color.rgb = DARK_TEXT if caption else GREY_TEXT

        doc.add_paragraph()

    doc.add_paragraph()

    # ── SIGNATURE BLOCK ───────────────────────────────────────────────────────
    sig = doc.add_table(rows=3, cols=3)
    set_table_width(sig, 10224)
    clear_table_borders(sig)
    left_w, mid_w, right_w = 4912, 400, 4912

    for row_i in range(3):
        for col_i in range(3):
            c = sig.cell(row_i, col_i)
            set_col_width(c, [left_w, mid_w, right_w][col_i])
            c.paragraphs[0].clear()

    # Top labels
    # Left: "Submitted by" label
    p0l = sig.cell(0, 0).paragraphs[0]
    p0l.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p0l.paragraph_format.space_before = Pt(2)
    p0l.paragraph_format.space_after  = Pt(0)
    r0l = p0l.add_run('Submitted by')
    r0l.font.name = FONT; r0l.font.size = Pt(8.5); r0l.font.color.rgb = GREY_TEXT

    # Right: adviser name + "Noted by" label
    p0r = sig.cell(0, 2).paragraphs[0]
    p0r.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p0r.paragraph_format.space_before = Pt(2)
    p0r.paragraph_format.space_after  = Pt(0)
    r0r = p0r.add_run('Noted by')
    r0r.font.name = FONT; r0r.font.size = Pt(8.5); r0r.font.color.rgb = GREY_TEXT

    # Signature space (middle row)
    # Left: embed actual signature image if available, else blank space
    _sig_img = 'c:/xampp/htdocs/smartspend_app/docs/manuscript/progress_reports/draw_sign.png'
    p_sig = sig.cell(1, 0).paragraphs[0]
    p_sig.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sig.paragraph_format.space_before = Pt(4)
    p_sig.paragraph_format.space_after  = Pt(2)
    if os.path.isfile(_sig_img):
        run_sig = p_sig.add_run()
        run_sig.add_picture(_sig_img, width=Inches(1.6))
    else:
        p_sig.paragraph_format.space_before = Pt(28)
        p_sig.paragraph_format.space_after  = Pt(4)

    # Right: adviser signature space stays blank
    p_adv = sig.cell(1, 2).paragraphs[0]
    p_adv.paragraph_format.space_before = Pt(28)
    p_adv.paragraph_format.space_after  = Pt(4)

    # Underline / role row — includes printed name under leader signature
    # Left cell: printed name bold + role label below
    p_left = sig.cell(2, 0).paragraphs[0]
    p_left.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_left.paragraph_format.space_before = Pt(0)
    p_left.paragraph_format.space_after  = Pt(0)
    r_name = p_left.add_run('Brix A. Directo')
    r_name.font.name = FONT; r_name.font.size = Pt(9); r_name.bold = True
    r_name.font.color.rgb = DARK_TEXT
    # Role label as a second paragraph inside the cell
    p_role = sig.cell(2, 0).add_paragraph()
    p_role.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_role.paragraph_format.space_before = Pt(1)
    p_role.paragraph_format.space_after  = Pt(0)
    r_role = p_role.add_run('Group Leader / Signature over Printed Name')
    r_role.font.name = FONT; r_role.font.size = Pt(7.5); r_role.font.color.rgb = GREY_TEXT

    # Right cell: adviser name bold + role label below
    p_right = sig.cell(2, 2).paragraphs[0]
    p_right.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_right.paragraph_format.space_before = Pt(0)
    p_right.paragraph_format.space_after  = Pt(0)
    r_adv_name = p_right.add_run(data['adviser_name'])
    r_adv_name.font.name = FONT; r_adv_name.font.size = Pt(9); r_adv_name.bold = True
    r_adv_name.font.color.rgb = DARK_TEXT
    p_adv_role = sig.cell(2, 2).add_paragraph()
    p_adv_role.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_adv_role.paragraph_format.space_before = Pt(1)
    p_adv_role.paragraph_format.space_after  = Pt(0)
    r_adv = p_adv_role.add_run('Teacher in Charge / Signature over Printed Name')
    r_adv.font.name = FONT; r_adv.font.size = Pt(7.5); r_adv.font.color.rgb = GREY_TEXT

    # ── Footer ───────────────────────────────────────────────────────────────
    footer = section.footer
    footer.paragraphs[0].clear()
    fp = footer.paragraphs[0]
    fp.paragraph_format.space_before = Pt(2)
    fp.paragraph_format.space_after  = Pt(0)

    # Left: institution text
    fr = fp.add_run(
        'Lorma Colleges \u2013 College of Computer Studies and Engineering '
        '| BS Information Technology Capstone Project')
    fr.font.name = FONT; fr.font.size = Pt(7); fr.font.color.rgb = GREY_TEXT

    # Tab to right side
    fp.add_run('\t')

    # "Page " text run
    fr_pg = fp.add_run('Page ')
    fr_pg.font.name = FONT; fr_pg.font.size = Pt(7); fr_pg.font.color.rgb = GREY_TEXT

    # PAGE field — correct OOXML: fldChar(begin) + instrText + fldChar(end)
    # each must be a child of its own <w:r>
    def _add_field_run(para, instr: str, rpr_xml: str = None):
        """Add a complete field (begin + instrText + end) as three <w:r> elements."""
        p_xml = para._p
        ns = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        for fld_type, extra in [('begin', None), (None, instr), ('end', None)]:
            r_el = OxmlElement('w:r')
            if rpr_xml:
                rpr = OxmlElement('w:rPr')
                r_el.append(rpr)
            if fld_type is not None:
                fc = OxmlElement('w:fldChar')
                fc.set(qn('w:fldCharType'), fld_type)
                r_el.append(fc)
            else:
                it = OxmlElement('w:instrText')
                it.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
                it.text = extra
                r_el.append(it)
            p_xml.append(r_el)

    _add_field_run(fp, ' PAGE ')

    fr_of = fp.add_run(' of ')
    fr_of.font.name = FONT; fr_of.font.size = Pt(7); fr_of.font.color.rgb = GREY_TEXT

    _add_field_run(fp, ' NUMPAGES ')

    doc.save(output_path)
    print(f"✓ Saved: {output_path}")


def _section_label(doc, text: str):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after  = Pt(2)
    r = p.add_run(text)
    r.font.name = FONT; r.font.size = Pt(12); r.bold = True
    r.font.color.rgb = MAROON_DARK


# ── Report data ───────────────────────────────────────────────────────────────

_SS = 'c:/xampp/htdocs/smartspend_app/docs/debug/screenshots/'

WEEK4 = {
    'project_title': (
        'SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management '
        'Application for Filipino Users Using Agentic Large Language Model Architecture'
    ),
    'report_no':        '04',
    'date_submitted':   'September 3, 2026',
    'adviser_name':     'Ellen F. Mangaoang, MIT',
    'members': [
        'Brix A. Directo — Lead Developer',
        'Cyrille John M. Rubis — UI/UX Designer & Documentation Lead',
        'Djaunathan Albert S. Madayag — Project Manager & QA Lead',
    ],
    'completed': (
        'Completed a comprehensive documentation audit resolving 30+ inconsistencies '
        'across all project documents. Critical corrections included: screen count '
        'updated from 36 to 37, service count from 23 to 26, stale AI model names '
        'updated (GPT-4o to GPT-5.6, Claude 3.5 to Claude Fable 5), input modality '
        'count corrected from 7 to 6, and the Financial Management Score (FMS) formula '
        'fixed from 3×33.3 pts to 4×25 pts to match the actual implementation.\n\n'
        'Implemented 6 AI coverage gaps identified through systematic audit:\n'
        '(1) Added set_spending_limit agentic action — AI can now set daily, weekly, '
        'monthly, and yearly spending caps directly from natural language chat;\n'
        '(2) Added add_insurance_policy action — AI can create SSS, PhilHealth, '
        'Pag-IBIG, and private insurance entries on command;\n'
        '(3) Added Rule 12 (Taglish language triggers) to the system prompt across '
        'all 34 action types for Filipino-English mixed input;\n'
        '(4) Budget queries now route to the smart model tier (LLaMA 70B or Gemini) '
        'instead of the fast 8B model for improved accuracy;\n'
        '(5) set_budget fallback parser added for edge-case input formats;\n'
        '(6) Auto-categorization rules injected into AI context for consistent '
        'category assignment.\n\n'
        'Added Financial Management Score (FMS) mini-cards to both the Home screen '
        '(compact strip showing 88/100 Expert Tracker) and the Analytics screen '
        '(full 4-component breakdown). FHS "Unmeasured" label added when income '
        'tracking is disabled — displays as a grey chip with dashed progress bar.\n\n'
        'Fixed ScanReviewScreen code duplication — removed a 295-line embedded class '
        'from smart_camera_screen.dart and replaced it with an import of the '
        'standalone file, eliminating a maintenance risk.\n\n'
        'Fixed the recurring transaction "Add Recurring" button — the entry now saves '
        'directly to the database without navigating to a blank screen first.\n\n'
        'Rebuilt SMARTSPEND_FINAL_V5.docx: 17 sections, 63 APA references, 7 embedded '
        'figures. Action count updated from 29 to 31 across all 12 documentation files. '
        'Released v2.9.8 to GitHub with 3 signed APK variants '
        '(arm64-v8a, armeabi-v7a, x86_64).'
    ),
    'ongoing': (
        'Manuscript revision: Chapters 1 through 4 complete in '
        'SMARTSPEND_REVISED_MANUSCRIPT.md. Google Docs version pending Fixes 11–16 '
        'from MANUSCRIPT_GUIDE.md covering account type flexibility, target population '
        'reframing, respondent criteria, and validator role descriptions.\n\n'
        'Pre-Final Defense preparation: demo flow rehearsal targeting 8–9 minutes per '
        'DEFENSE_GUIDE.md Part 2. Presentation slides in progress.\n\n'
        'SUS survey instrument finalization — targeting 30 respondents '
        '(20 parents aged 35–55, 10 young professionals aged 21–35) for Week 7.'
    ),
    'problems': (
        'Multi-item AI logging was silently failing for messages with common Filipino '
        'spelling variants and typos (e.g., "spen 30 for transport") — the max_tokens '
        'estimate was too low, and the multi-item detection regex did not match '
        'informal Tagalog verb forms.\n\n'
        'The 50/30/20 analytics card and income-based overview cards were rendering '
        'using stale income data (₱650 set months prior) even when income tracking '
        'was OFF, producing meaningless budget percentages for the student user profile.'
    ),
    'solutions': (
        'Multi-item fix: broadened the verb detection regex to catch typos and '
        'Tagalog variants (spen, spe, nagastos, ginastos); added connector-aware '
        'detection for comma-separated and "and"-joined entries; scaled token budget '
        'from 800 to 1,200 tokens based on item count; multi-item messages now route '
        'to the smart model tier. System prompt Rules 1 and 2 updated with explicit '
        'Filipino-language examples.\n\n'
        'Lightweight Mode analytics fix: added _incomeWalletMode state field to '
        'AnalyticsScreen, populated from the database on _loadData(). All three '
        'income-dependent cards (50/30/20, Tax+Savings, Allowance Overview) are now '
        'gated on the _incomeWalletMode flag and hidden when income tracking is OFF.'
    ),
    'next_steps': (
        'Week 5: Configure GitHub Actions secrets (KEYSTORE_BASE64, KEY_PROPERTIES, '
        'GOOGLE_SERVICES_JSON, APP_CONFIG_DART) to enable the automated APK release '
        'pipeline built this week.\n\n'
        'Apply Google Docs manuscript fixes (Fixes 11–16): account type flexibility, '
        'target population reframing, respondent criteria, and validator role sections.\n\n'
        'Generate Figure 1.1 bar chart using BSP financial literacy data and insert '
        'into Google Docs manuscript.\n\n'
        'Obtain validator signatures on Appendix A validation certificates '
        '(survey content validator and technical/SUS validator).\n\n'
        'Complete Pre-Final Defense presentation slides and conduct a full timed '
        'rehearsal using the DEFENSE_GUIDE.md script.'
    ),
    'photos': [
        (_SS + 'Screenshot_2026-09-07-07-57-46-826_com.lucidframe.smartspend_app.jpg',
         'SmartSpend splash screen — app logo with tagline "Your AI Financial Assistant" on launch'),
        (_SS + 'Screenshot_2026-09-07-07-57-49-825_com.lucidframe.smartspend_app.jpg',
         'Home screen — ₱185 monthly spending (7% below last month), recurring pattern alert, Quick Log chips (Jeepney ₱30, Lunch ₱85), and achievement badges'),
        (_SS + 'Screenshot_2026-09-07-07-57-57-491_com.lucidframe.smartspend_app.jpg',
         'Home screen scrolled — Daily Quests (1/4 complete), FHS 63/100 Fair with AI explanation, FMS 88/100 Expert Tracker strip, and Budgets 5 set'),
        (_SS + 'Screenshot_2026-09-07-07-58-00-575_com.lucidframe.smartspend_app.jpg',
         'Home screen — AI Insights card with 3 behavioral tips (Food 43%, Transportation 32%, Small purchases), Consistent Saver badge, and Quick Access grid'),
        (_SS + 'Screenshot_2026-09-07-07-58-07-259_com.lucidframe.smartspend_app.jpg',
         'Analytics — Spending by Category donut chart (13 categories, All Time view): Shopping ₱9,732 leads, followed by Food ₱4,762 and Gaming ₱8,300'),
        (_SS + 'Screenshot_2026-09-07-07-58-53-139_com.lucidframe.smartspend_app.jpg',
         'Profile — Brix Arquisal Directo: 185 total expenses, ₱37,512 total spent, FHS 63/100 with 4-component Score Breakdown showing improvement areas'),
        (_SS + 'Screenshot_2026-09-07-07-58-55-849_com.lucidframe.smartspend_app.jpg',
         'Profile — FMS 88/100 Expert Tracker: Logging 13/25, Budget Setup 25/25, Goal Tracking 25/25, Data Completeness 25/25 — account type: Student, Dark Mode ON'),
        (_SS + 'Screenshot_2026-09-07-07-59-07-682_com.lucidframe.smartspend_app.jpg',
         'App Settings — AI Model section: Gemini 3.1 Flash-Lite selected (1,000/day free, fastest Gemini), with 4 fallback providers including LLaMA 3.3 70B and Cerebras'),
    ],
}

WEEK5 = {
    'project_title': (
        'SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management '
        'Application for Filipino Users Using Agentic Large Language Model Architecture'
    ),
    'report_no':        '05',
    'date_submitted':   'September 4, 2026',
    'adviser_name':     'Ellen F. Mangaoang, MIT',
    'members': [
        'Brix A. Directo — Lead Developer',
        'Cyrille John M. Rubis — UI/UX Designer & Documentation Lead',
        'Djaunathan Albert S. Madayag — Project Manager & QA Lead',
    ],
    'completed': (
        'Analyzed real device debug data (Debug Log, JSON backup, CSV export from '
        'Poco X6 Pro test device) and resolved 5 specific bugs confirmed on actual hardware:\n\n'
        'Bug #1 — Lightweight Mode analytics: The 50/30/20 card, Tax+Savings card, '
        'and Allowance Overview were rendering using a stale ₱650 income value even '
        'when income tracking was OFF. Fixed by adding _incomeWalletMode state to '
        'AnalyticsScreen and gating all three income-dependent cards on that flag.\n\n'
        'Bug #2 — Logging Consistency scoring: activeDays was computed from the '
        'user\'s first logged entry of the month, allowing a single entry on Sep 2 '
        'to award 25/25 "Logging every active day." Fixed by using daysPassed as the '
        'baseline (honest score). A grace period is preserved for users who start '
        'logging mid-month (after day 7). Applied to 3 locations in score_service.dart.\n\n'
        'Bug #3 — FMS "See breakdown" tap: tapping the link navigated to the Profile '
        'screen top with no scroll. Fixed using a static flag ProfileScreen.scrollToFMS, '
        'a GlobalKey, and a ScrollController — the screen now auto-scrolls to the FMS '
        'section after data loads.\n\n'
        'Bug #4 — AI language detection: the AI was replying in Taglish when the user '
        'wrote in English. Fixed by adding Rule 12 to the system prompt and updating '
        'the persona line to strictly match the user\'s input language.\n\n'
        'Bug #5 — Score history chart: showed 2 data points with no explanation. '
        'Added a placeholder card explaining that scores are recorded each time the '
        'app is opened, prompting users to engage daily.\n\n'
        'Created GitHub Actions CI/CD workflow (.github/workflows/release.yml): '
        'auto-builds all 3 APK variants and creates a GitHub Release on version tag push. '
        'Triggers on v*.*.* tags; uses Java 17 and Flutter 3.41.6.\n\n'
        'Built and released v2.9.9 to GitHub. Rebuilt progress reports using the exact '
        'Lorma BSIT progress report template format.\n\n'
        'Added UX/Behavioral backlog (8 items) and Document Tooling backlog '
        '(8 tools) to PROJECT_STATUS.md for future sprint planning.'
    ),
    'ongoing': (
        'Configuring GitHub Actions secrets (KEYSTORE_BASE64, KEY_PROPERTIES, '
        'GOOGLE_SERVICES_JSON, APP_CONFIG_DART) to activate the automated release '
        'pipeline. These signing credentials and API keys cannot be committed to the '
        'repository and must be set manually in GitHub Settings → Secrets.\n\n'
        'Pre-Final Defense preparation: finalizing presentation slides and conducting '
        'full 8–9 minute demo rehearsal using the DEFENSE_GUIDE.md flow.\n\n'
        'Google Docs manuscript: applying Fixes 11–16 (account type, target population, '
        'respondent criteria, validator roles).\n\n'
        'SUS survey instrument finalization and respondent recruitment coordination '
        'for Week 7 administration.'
    ),
    'problems': (
        'GitHub Actions automated release workflow requires 4 secrets to be configured '
        'manually in repository settings before the first build can succeed — the '
        'keystore file, key.properties, google-services.json, and app_config.dart '
        'all contain signing credentials and API keys that cannot be committed to '
        'the public repository.\n\n'
        'Logging Consistency score was returning inflated results (25/25) for users '
        'who log their first entry on day 1 or 2 of the month, because activeDays '
        'was computed relative to the first logged entry rather than the start of '
        'the calendar month.'
    ),
    'solutions': (
        'GitHub Actions: the workflow file (release.yml) has been created, committed, '
        'and merged. Step-by-step secret configuration instructions are documented '
        'in the workflow file comments. Once the 4 secrets are set in GitHub Settings, '
        'future releases require only two commands:\n'
        '  git tag v2.9.X && git push origin v2.9.X\n\n'
        'Logging Consistency: fixed the activeDays baseline to use daysPassed (days '
        'elapsed since the first day of the month). The grace period is preserved — '
        'if the user began logging after day 7 of the month, the span from their first '
        'entry is still used to avoid penalizing new users. The fix was applied '
        'consistently across FHS full mode, FHS lightweight mode, and FMS (3 files).'
    ),
    'next_steps': (
        'Configure GitHub Actions secrets to enable the automated APK release pipeline.\n\n'
        'Complete Pre-Final Defense preparation: finalize slides, conduct a full '
        '8–9 minute timed rehearsal following the DEFENSE_GUIDE.md demo flow.\n\n'
        'Apply remaining Google Docs manuscript fixes (Fixes 11–16).\n\n'
        'Generate Figure 1.1 bar chart and obtain validator signatures for Appendix A.\n\n'
        'Prepare SUS survey instruments and begin respondent recruitment '
        '(target: 30 respondents — 20 parents aged 35–55, 10 young professionals '
        'aged 21–35).'
    ),
    'photos': [
        (_SS + 'Screenshot_2026-09-07-07-58-09-326_com.lucidframe.smartspend_app.jpg',
         'Analytics — This Month vs Last Month comparison + Spending by Day of Week heatmap (Mon ₱453 peak) + Score Components 63/100 partial view'),
        (_SS + 'Screenshot_2026-09-07-07-58-11-946_com.lucidframe.smartspend_app.jpg',
         'Analytics — Score Components 63/100 full: Wants 25/25, Logging 13/25 (Bug #2 fix), Budgets 25/25, Streak 0/25 — FMS 88/100 Expert Tracker breakdown'),
        (_SS + 'Screenshot_2026-09-07-07-58-14-593_com.lucidframe.smartspend_app.jpg',
         'Analytics — "What you did right / what to fix" feedback panel, Health Score History (1 data point, Bug #5 fix), and Projected Next Month ₱1,590'),
        (_SS + 'Screenshot_2026-09-07-07-59-19-238_com.lucidframe.smartspend_app.jpg',
         'AI Chat screen — Gemini 3.1 Flash-Lite active (60 requests remaining), 5 quick-suggestion chips, Smart Import bottom sheet with 4 input modes'),
        (_SS + 'Screenshot_2026-09-07-07-59-22-327_com.lucidframe.smartspend_app.jpg',
         'AI Chat — AI Model selector bottom sheet: Gemini 3.1 Flash-Lite selected (✓), showing all 5 available models with daily request limits'),
        (_SS + 'Screenshot_2026-09-07-08-00-06-116_com.lucidframe.smartspend_app.jpg',
         'Achievements screen — 7 of 23 badges earned: First Step ✓, Budget Boss ✓, Spare Change Hero ✓; remaining badges locked with unlock criteria visible'),
        (_SS + 'Screenshot_2026-09-07-08-00-09-103_com.lucidframe.smartspend_app.jpg',
         'Achievements page 2 — Detail Oriented ✓, Night Owl ✓, Early Bird ✓, Century Club ✓ unlocked; Receipt Scanner, Consistent Logger, Insurance Aware still locked'),
        (_SS + 'Screenshot_2026-09-07-07-59-10-066_com.lucidframe.smartspend_app.jpg',
         'App Settings — Home Screen show/hide section (Quick-log chips ON, Achievement badges ON, Behavioral prediction ON) and Analytics section visibility controls'),
    ],
}


WEEK6 = {
    'project_title': (
        'SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management '
        'Application for Filipino Users Using Agentic Large Language Model Architecture'
    ),
    'report_no':        '06',
    'date_submitted':   'September 10, 2026',
    'adviser_name':     'Ellen F. Mangaoang, MIT',
    'members': [
        'Brix A. Directo — Lead Developer',
        'Cyrille John M. Rubis — UI/UX Designer & Documentation Lead',
        'Djaunathan Albert S. Madayag — Project Manager & QA Lead',
    ],
    'completed': (
        'Released SmartSpend v2.9.10 — Behavioral Feedback Layer (8 UX items):\n\n'
        '(1) Score Narrative Engine — AI-generated weekly summary cards replace the '
        'plain "FHS: 63/100" label. Context-aware messages such as "You\'re spending '
        'more than usual on Food — ₱2,340 this week" appear on the Home screen.\n\n'
        '(2) Score Celebration Toasts — Animated on-screen toast when FHS crosses '
        'milestone thresholds (50, 65, 75, 90), reinforcing positive financial behavior '
        'with Lorma maroon/gold visual styling.\n\n'
        '(3) Purchase Commentary — AI appends a brief behavioral note to '
        'receipt-scan and voice-logged entries above ₱500 (e.g., "This counts as a '
        'discretionary purchase — consider tracking against your Food budget.").\n\n'
        '(4) Supportive Budget Warning Alerts — Budget overspend warnings now include '
        'a constructive follow-up suggestion instead of a plain red banner, '
        'applying Thaler & Sunstein (2008) nudge theory.\n\n'
        '(5) FMS Next-Step Guidance — The FMS card now shows a single prioritized '
        'action tip (e.g., "Set a Food budget to unlock full Budget Adherence scoring") '
        'when any FMS sub-component falls below 20/25.\n\n'
        '(6) Coach Report — Weekly AI-generated coach letter on the Profile screen '
        'summarizing the week\'s financial behavior, the user\'s strongest category, '
        'and one recommended habit change for the coming week.\n\n'
        '(7) Goal Milestone Notifications — In-app notification when a savings goal '
        'reaches 25%, 50%, 75%, and 100% of its target, with celebratory '
        'color-coded progress card updates.\n\n'
        '(8) Score Explanation Tooltips — "Why is my FHS this score?" info button '
        'added to the FHS card, opening a bottom sheet with per-component breakdown '
        'and plain-language explanation.\n\n'
        'Completed full documentation reorganization: all docs folders renamed, '
        'sorted, and restructured (archive, capstone, debug, guides, manuscript, '
        'reference, status, tools). Committed as v2.9.10 to GitHub master.\n\n'
        'Built all 4 manuscript figures as compressed PNG files using Pillow and '
        'matplotlib:\n'
        '  • Figure 1.1 — Financial Literacy Rates by Demographic Group (74 KB)\n'
        '  • Figure 1.2 — IPO Conceptual Framework (131 KB)\n'
        '  • Figure 2.1 — SUS Score Interpretation (40 KB)\n'
        '  • Figure 2.2 — Agile Kanban Workflow (111 KB)\n\n'
        'Rebuilt SmartSpend_Manuscript_FINAL.docx with all 4 figures embedded: '
        '17 sections verified, 12 media files, 63 APA references, approximately '
        '12,685 words (~50 pages). Figures 2.1 and 2.2 injected into Chapter III '
        'via the _fig() helper.\n\n'
        'Built SmartSpend_Compliance_Matrix_PreFinal.docx — pre-filled with project '
        'title, proponents, adviser, and panelist placeholder fields, ready for '
        'printing and panel submission.'
    ),
    'ongoing': (
        'Pre-Final Defense preparation: finalizing presentation slides and conducting '
        'full 8–9 minute demo rehearsal using the DEFENSE_GUIDE.md flow.\n\n'
        'SUS survey administration: targeting 30 respondents (20 parents aged 35–55, '
        '10 young professionals aged 21–35) for Week 7. Survey instruments finalized.\n\n'
        'Google Docs manuscript: applying manuscript text from '
        'SmartSpend_Manuscript_Source.md, inserting all 4 figures, and completing '
        'the CV section for all 3 members.\n\n'
        'Validator coordination: obtaining signatures on Appendix A validation '
        'certificates (survey content validator and technical/SUS validator).'
    ),
    'problems': (
        'GitHub Actions automated release pipeline still pending — 4 repository '
        'secrets (KEYSTORE_BASE64, KEY_PROPERTIES, GOOGLE_SERVICES_JSON, '
        'APP_CONFIG_DART) require manual configuration in GitHub Settings → '
        'Secrets and variables → Actions. These signing credentials and API keys '
        'cannot be committed to the repository.\n\n'
        'Figures 1.1 and 1.2 in the Google Docs Working copy were originally '
        'embedded as large uncompressed PNGs (1.8 MB and 1.6 MB). The new '
        'compressed versions (74 KB and 131 KB) need to be manually replaced '
        'in the Working copy by Cyrille before the next panel submission.'
    ),
    'solutions': (
        'GitHub Actions: the workflow file (release.yml) is already committed and '
        'operational. Once the 4 secrets are configured in GitHub Settings, future '
        'releases require only:\n'
        '  git tag v2.9.X && git push origin v2.9.X\n'
        'Setup instructions are documented in the workflow file comments.\n\n'
        'Figures: all 4 compressed PNG files are saved to docs/manuscript/figures/. '
        'The build_figures.py script regenerates all 4 at any time with a single '
        'command: python build_figures.py. The FINAL.docx is rebuilt automatically '
        'by build_final_docx.py with compressed images via python-docx add_picture(). '
        'Manual replacement in the Working copy is tracked as a Cyrille task for '
        'Week 7.'
    ),
    'next_steps': (
        'Week 7 — Administer SUS survey to 30 respondents (20 parents, '
        '10 young professionals). Tabulate results and compute SUS scores using '
        'the Brooke (1996) formula. Insert results into Chapter III.\n\n'
        'Complete Pre-Final Defense presentation slides and conduct the full '
        'rehearsal. Print Compliance Matrix and obtain panel signatures.\n\n'
        'Configure GitHub Actions secrets for the automated APK release pipeline.\n\n'
        'Obtain validator signatures on Appendix A validation certificates.\n\n'
        'Cyrille: Insert all 4 figures into the Google Docs Working copy. '
        'Complete CV section for all 3 members. Apply remaining manuscript fixes.'
    ),
    'photos': [
        (_SS + 'Screenshot_2026-09-07-07-58-31-856_com.lucidframe.smartspend_app.jpg',
         'Analytics — Market Insights live exchange rates (USD ₱62.68, EUR ₱72.77, GBP ₱84.70) + AI Financial Advice card with 3 actionable spending tips'),
        (_SS + 'Screenshot_2026-09-07-07-58-34-962_com.lucidframe.smartspend_app.jpg',
         'Analytics — AI Financial Advice continued: "Prioritize Needs over Wants" and "Start a Micro-Savings fund" tips based on real spending data'),
        (_SS + 'Screenshot_2026-09-07-07-58-40-688_com.lucidframe.smartspend_app.jpg',
         'Hub — Quick Access bottom sheet: Savings Goals, Income, Debts & Lending, Recurring Transactions, Budgets, Currency Exchange, Transactions, Installment Plans'),
        (_SS + 'Screenshot_2026-09-07-07-58-43-815_com.lucidframe.smartspend_app.jpg',
         'Hub — Quick Access continued: My Wallets, Bill Calendar, Categories, Auto-Categorization Rules, Import from Bank/GCash, Insurance & Contributions, PH Banks & Investments'),
        (_SS + 'Screenshot_2026-09-07-07-58-59-167_com.lucidframe.smartspend_app.jpg',
         'Profile — settings list: Export CSV, Financial Health Certificate, Backup/Restore Data, Import from Bank/GCash, Batch Screenshot Import, Load Demo Data'),
        (_SS + 'Screenshot_2026-09-07-08-01-03-568_com.lucidframe.smartspend_app.jpg',
         'Financial Health Certificate — Brix Arquisal Directo has achieved FHS 63/100 (Good ✓), September 2026 · SmartSpend by Lucid Frame, shareable card'),
        (_SS + 'Screenshot_2026-09-07-08-01-17-818_com.lucidframe.smartspend_app.jpg',
         'Financial Calendar — September 2026 view: Sep 7 highlighted (today), Sep 2 expense dot, Sep 18 installment due dot for GCash GLoan'),
        (_SS + 'Screenshot_2026-09-07-08-01-32-159_com.lucidframe.smartspend_app.jpg',
         'Financial Calendar — Sep 2 day detail: ₱185 total in 5 expenses (Jeepney ₱30, 1ltr Coke ₱50, Super Glue ₱45, Lunch ₱30, Jeepney ₱30)'),
    ],
}


WEEK7 = {
    'project_title': (
        'SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management '
        'Application for Filipino Users Using Agentic Large Language Model Architecture'
    ),
    'report_no':        '07',
    'date_submitted':   'September 7, 2026',
    'adviser_name':     'Ellen F. Mangaoang, MIT',
    'members': [
        'Brix A. Directo — Lead Developer',
        'Cyrille John M. Rubis — UI/UX Designer & Documentation Lead',
        'Djaunathan Albert S. Madayag — Project Manager & QA Lead',
    ],
    'completed': (
        'Conducted full live walkthrough of the SmartSpend application on the Poco X6 Pro '
        'test device to verify all features are functional ahead of the Pre-Final Defense. '
        'All 5 core screens (Home, Analytics, AI Chat, Hub, Profile) confirmed working '
        'with real user data.\n\n'
        'Verified the complete expense logging flow: the multi-modal Add Expense screen '
        'supports natural language input (e.g., "Ate at KFC 250 pesos"), Voice logging '
        'via microphone, and AI-powered Analyze mode. The form includes category '
        'selection from 14 built-in categories, Need/Want tagging, payment method '
        'selection, merchant/shop field, notes, receipt photo attachment, and custom '
        'tags (e.g., #capstone).\n\n'
        'Verified Budgets module: 5 category budgets configured (Food ₱5,000, '
        'Education ₱1,650, Bills ₱990, Shopping ₱990, Gaming ₱1,299) totaling '
        '₱9,929 budgeted against ₱650 income and ₱185 spent. Budget categories '
        'support both fixed ₱ and % of income modes. All 5 budgets are on track '
        'as of Day 7 of 30.\n\n'
        'Verified Debts & Lending module: I Owe, Owed to Me, and Plans tabs all '
        'functional. Active plan: GCash GLoan for Acer KA272 PC Monitor — '
        '2 of 9 months paid, ₱6,349 remaining at ₱907/month, due in 10 days. '
        'ShopeePayLater plan marked as fully paid (₱1,120). Add Debt form '
        'supports I Owe and They Owe Me modes with description, amount, due date, '
        'notes, and interest rate fields. Add Payment Plan form supports '
        'ShopeePaylater, GCash GLoan, HomeCredit, and other installment formats.\n\n'
        'Verified My Wallets module: Cash on Hand ₱953, Landbank ₱500, GCash, Maya, '
        'and GoTyme Bank configured. Total liquid balance: ₱1,453. Add wallet '
        'supports 29 providers including GrabPay, ShopeePay, Coins.ph, PayPal, '
        'Wise, Tonik, UNO bank, and all major PH banks (BDO, BPI, Metrobank, '
        'PNB, RCBC, Security Bank, Chinabank, UnionBank, EastWest, Seabank, '
        'PSBank, Maybank, Cebuana, M Lhuillier, Palawan Pawnshop, Western Union, '
        'LBC, Tambunting, USSC).\n\n'
        'Verified App Settings: Lite Mode, Auto-deduct wallets, Impulse pause, '
        'Budget alerts, Round-up savings, and Compact mode all confirmed functional. '
        'Spending anomaly alerts enabled. Home Screen and Analytics show/hide '
        'section toggles verified. AI model switch confirmed (Gemini 3.1 Flash-Lite '
        'active, 5 models available).\n\n'
        'Verified Spending Limits: Daily, Weekly, Monthly, and Yearly cap fields '
        'accessible from Profile settings. Limits set and confirmed reflected on '
        'the Home screen spending card.\n\n'
        'Configured GitHub Actions 2 of 4 secrets. Release pipeline partially active.'
    ),
    'ongoing': (
        'SUS survey administration in progress — targeting 30 respondents '
        '(20 parents aged 35–55, 10 young professionals aged 21–35). '
        'Instruments distributed; responses being collected.\n\n'
        'Pre-Final Defense presentation slides: final polish and rehearsal. '
        'Full 8–9 minute timed run-through scheduled before submission deadline.\n\n'
        'Cyrille: inserting all 4 figures into the Google Docs Working copy and '
        'completing the CV section for all 3 members.\n\n'
        'Remaining GitHub Actions secrets configuration (KEYSTORE_BASE64, '
        'KEY_PROPERTIES) pending signing keystore transfer.'
    ),
    'problems': (
        'SUS respondent recruitment for the parent demographic (35–55 age group) '
        'is proving slower than expected — the target of 20 parent respondents '
        'requires direct outreach through faculty and community contacts, which '
        'is time-consuming during the pre-defense period.\n\n'
        'Budgets total (₱9,929) exceeds the configured income (₱650) by ₱9,279, '
        'which triggers a budget warning in the app. This is intentional for the '
        'test device (demo data), but needs to be clearly explained during the '
        'defense demonstration to avoid confusion from the panel.'
    ),
    'solutions': (
        'SUS recruitment: expanded outreach to include online survey distribution '
        'via class group chats and faculty referrals. The young professional '
        'demographic (10 respondents) is on track. A deadline of September 12 has '
        'been set to complete all 30 surveys before the defense date.\n\n'
        'Budget warning: a verbal note has been added to the defense script '
        '(DEFENSE_GUIDE.md) acknowledging the demo data context — the panel will '
        'be informed that the ₱9,929 budget total reflects aspirational category '
        'limits set during testing, not the live student monthly budget. '
        'The app correctly flags the overage as a feature, not a bug.'
    ),
    'next_steps': (
        'Complete SUS survey data collection (target: September 12, 2026). '
        'Tabulate results and compute SUS scores using the Brooke (1996) formula. '
        'Insert tabulated results and interpretation into Chapter III.\n\n'
        'Submit Pre-Final Defense requirements: printed Compliance Matrix with '
        'panel signatures, final manuscript printout, and defense slide deck.\n\n'
        'Conduct final full rehearsal of the 8–9 minute demo using '
        'DEFENSE_GUIDE.md. Assign speaking roles for each team member.\n\n'
        'Complete remaining GitHub Actions secrets configuration to finalize '
        'the automated APK release pipeline.\n\n'
        'Obtain validator signatures on Appendix A validation certificates '
        'and submit to the capstone coordinator before the defense date.'
    ),
    'photos': [
        (_SS + 'Screenshot_2026-09-07-07-59-42-070_com.lucidframe.smartspend_app.jpg',
         'Add Expense screen — multi-modal logging: NLP text input, Voice and AI Analyze buttons, category selector, Need/Want tag, payment method, merchant, notes, and receipt attachment'),
        (_SS + 'Screenshot_2026-09-07-07-59-44-383_com.lucidframe.smartspend_app.jpg',
         'Add Expense — form continued: Tags field (e.g. #capstone), and Confirm & Save button — supports fully manual or AI-assisted expense entry'),
        (_SS + 'Screenshot_2026-09-07-08-01-42-772_com.lucidframe.smartspend_app.jpg',
         'Budgets screen — ₱9,929 budgeted vs ₱185 spent vs ₱650 income, Day 7 of 30 (23% elapsed); 5 category budgets all on track with pace indicators'),
        (_SS + 'Screenshot_2026-09-07-08-01-43-846_com.lucidframe.smartspend_app.jpg',
         'Budgets — all 5 configured: Food ₱80/₱5,000, Education ₱0/₱1,650, Bills ₱0/₱990, Shopping ₱45/₱990, Gaming ₱0/₱1,299 — all under expected pace'),
        (_SS + 'Screenshot_2026-09-07-08-02-15-605_com.lucidframe.smartspend_app.jpg',
         'Debts & Lending — Plans tab: GCash GLoan (Acer KA272) active — 2/9 months paid, ₱6,349 remaining at ₱907/mo, due in 10 days; ShopeePayLater fully paid ✓'),
        (_SS + 'Screenshot_2026-09-07-08-00-20-624_com.lucidframe.smartspend_app.jpg',
         'Spending Limits — Daily, Weekly, Monthly, and Yearly cap input fields; any combination can be set; blank fields are skipped'),
        (_SS + 'Screenshot_2026-09-07-08-02-30-862_com.lucidframe.smartspend_app.jpg',
         'My Wallets — Total liquid ₱1,453: Cash on Hand ₱953, Landbank ₱500, GCash, Maya, GoTyme Bank configured; 29 wallet providers available to add'),
        (_SS + 'Screenshot_2026-09-07-08-02-34-907_com.lucidframe.smartspend_app.jpg',
         'My Wallets — Add wallet options: GrabPay, ShopeePay, Coins.ph, Lazada, TikTok Shop, PayPal, Wise, Tonik, UNO, UnionDigital, BDO, BPI, Metrobank, PNB, RCBC, and 14 more'),
    ],
}


def main():
    out_dir = Path(__file__).parent
    target = sys.argv[1].lower() if len(sys.argv) > 1 else 'all'

    if target in ('week4', 'all'):
        build_report(WEEK4, out_dir / '..' / 'progress_reports' / 'SmartSpend_Progress_Report_Week4.docx')
    if target in ('week5', 'all'):
        build_report(WEEK5, out_dir / '..' / 'progress_reports' / 'SmartSpend_Progress_Report_Week5.docx')
    if target in ('week6', 'all'):
        build_report(WEEK6, out_dir / '..' / 'progress_reports' / 'SmartSpend_Progress_Report_Week6.docx')
    if target in ('week7', 'all'):
        build_report(WEEK7, out_dir / '..' / 'progress_reports' / 'SmartSpend_Progress_Report_Week7.docx')


if __name__ == '__main__':
    main()
