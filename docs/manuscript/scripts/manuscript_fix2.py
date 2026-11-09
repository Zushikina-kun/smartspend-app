"""
Fix 2: Apply double-spacing and font fixes directly via XML manipulation,
since python-docx's paragraph_format setters don't write the XML attributes
when existing spacing elements are present.
Also apply Times New Roman 12pt to Normal style via XML directly.
"""

import os
from docx import Document
from docx.shared import Pt, Inches
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from lxml import etree

CAPSTONE = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx"
W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"


def set_spacing_double_xml(ppr_or_style_ppr):
    """
    Set w:spacing element on a pPr to double line spacing.
    w:line="480" w:lineRule="auto" means double (240*2).
    """
    spc = ppr_or_style_ppr.find(qn('w:spacing'))
    if spc is None:
        spc = OxmlElement('w:spacing')
        ppr_or_style_ppr.append(spc)
    spc.set(qn('w:line'), '480')
    spc.set(qn('w:lineRule'), 'auto')
    # Remove exact/atLeast lineRule artifacts
    for attr in (qn('w:after'), qn('w:before')):
        pass  # keep these, don't remove after/before spacing


def set_spacing_single_xml(ppr_or_style_ppr):
    """Set single spacing on a pPr."""
    spc = ppr_or_style_ppr.find(qn('w:spacing'))
    if spc is None:
        spc = OxmlElement('w:spacing')
        ppr_or_style_ppr.append(spc)
    spc.set(qn('w:line'), '240')
    spc.set(qn('w:lineRule'), 'auto')


def set_font_xml(rpr, font_name, size_half_pt):
    """
    Set font on an rPr element directly.
    size_half_pt = pt * 2 (Word stores half-points: 12pt = 24, 24pt = 48)
    """
    # w:rFonts
    rfonts = rpr.find(qn('w:rFonts'))
    if rfonts is None:
        rfonts = OxmlElement('w:rFonts')
        rpr.insert(0, rfonts)
    rfonts.set(qn('w:ascii'), font_name)
    rfonts.set(qn('w:hAnsi'), font_name)
    rfonts.set(qn('w:cs'), font_name)
    # w:sz
    sz = rpr.find(qn('w:sz'))
    if sz is None:
        sz = OxmlElement('w:sz')
        rpr.append(sz)
    sz.set(qn('w:val'), str(size_half_pt))
    # w:szCs
    szcs = rpr.find(qn('w:szCs'))
    if szcs is None:
        szcs = OxmlElement('w:szCs')
        rpr.append(szcs)
    szcs.set(qn('w:val'), str(size_half_pt))


print("Loading document...")
doc = Document(CAPSTONE)

# ── Fix Normal style via XML ──────────────────────────────────────
print("Fixing Normal style via XML...")
normal_style = doc.styles['Normal']
style_elem = normal_style.element

# Get or create pPr
ppr = style_elem.find(qn('w:pPr'))
if ppr is None:
    ppr = OxmlElement('w:pPr')
    style_elem.append(ppr)

set_spacing_double_xml(ppr)
print("  Normal style: set double spacing in pPr XML")

# Fix Normal rPr font
rpr = style_elem.find(qn('w:rPr'))
if rpr is None:
    rpr = OxmlElement('w:rPr')
    style_elem.append(rpr)

set_font_xml(rpr, 'Times New Roman', 24)  # 12pt = 24 half-points
print("  Normal style: set Times New Roman 12pt in rPr XML")

# ── Fix all body paragraphs with direct XML ───────────────────────
print("Fixing body paragraph spacing via XML...")
heading_styles = {'Heading 1', 'Heading 2', 'Heading 3', 'Heading 4',
                  'Heading 5', 'Heading 6', 'Caption', 'Figure Caption',
                  'Table Caption'}

body_fixed = 0
for para in doc.paragraphs:
    sname = para.style.name if para.style else ''
    if sname in heading_styles or sname.lower().startswith('heading'):
        continue

    p_elem = para._p
    ppr = p_elem.find(qn('w:pPr'))
    if ppr is None:
        ppr = OxmlElement('w:pPr')
        p_elem.insert(0, ppr)

    set_spacing_double_xml(ppr)
    body_fixed += 1

print(f"  Double spacing applied to {body_fixed} body paragraphs via XML")

# ── Fix table cells: single spacing ──────────────────────────────
print("Fixing table cell paragraph spacing via XML...")
table_fixed = 0
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for para in cell.paragraphs:
                p_elem = para._p
                ppr = p_elem.find(qn('w:pPr'))
                if ppr is None:
                    ppr = OxmlElement('w:pPr')
                    p_elem.insert(0, ppr)
                set_spacing_single_xml(ppr)
                table_fixed += 1

print(f"  Single spacing applied to {table_fixed} table cell paragraphs via XML")

# ── Fix Heading styles via XML ────────────────────────────────────
# TEMPLATE values from Task 1:
# H1: 24pt bold, space_before=24pt, space_after=6pt, MULTIPLE line
# H2: 18pt bold, space_before=18pt, space_after=4pt, MULTIPLE line
# H3: Times New Roman 13.5pt bold, line=SINGLE
HEADING_FIXES = {
    'Heading 1': {'font': None, 'size_pt': 24, 'bold': True,
                  'space_before_twips': 480, 'space_after_twips': 120},  # 24pt*20=480 twips, 6pt*20=120
    'Heading 2': {'font': None, 'size_pt': 18, 'bold': True,
                  'space_before_twips': 360, 'space_after_twips': 80},   # 18pt*20=360, 4pt*20=80  
    'Heading 3': {'font': 'Times New Roman', 'size_pt': 13.5, 'bold': True,
                  'space_before_twips': None, 'space_after_twips': None},
}

for hname, props in HEADING_FIXES.items():
    try:
        hstyle = doc.styles[hname]
        se = hstyle.element

        ppr = se.find(qn('w:pPr'))
        if ppr is None:
            ppr = OxmlElement('w:pPr')
            se.append(ppr)

        # Set space before/after via jc+spacing
        if props['space_before_twips'] is not None or props['space_after_twips'] is not None:
            spc = ppr.find(qn('w:spacing'))
            if spc is None:
                spc = OxmlElement('w:spacing')
                ppr.append(spc)
            if props['space_before_twips']:
                spc.set(qn('w:before'), str(props['space_before_twips']))
            if props['space_after_twips']:
                spc.set(qn('w:after'), str(props['space_after_twips']))

        rpr = se.find(qn('w:rPr'))
        if rpr is None:
            rpr = OxmlElement('w:rPr')
            se.append(rpr)

        # Set font if specified
        if props['font']:
            set_font_xml(rpr, props['font'], int(props['size_pt'] * 2))
        else:
            # Just set size
            size_half = int(props['size_pt'] * 2)
            sz = rpr.find(qn('w:sz'))
            if sz is None:
                sz = OxmlElement('w:sz')
                rpr.append(sz)
            sz.set(qn('w:val'), str(size_half))
            szcs = rpr.find(qn('w:szCs'))
            if szcs is None:
                szcs = OxmlElement('w:szCs')
                rpr.append(szcs)
            szcs.set(qn('w:val'), str(size_half))

        # Bold
        if props['bold']:
            b = rpr.find(qn('w:b'))
            if b is None:
                b = OxmlElement('w:b')
                rpr.insert(0, b)

        print(f"  Fixed {hname} via XML")
    except Exception as e:
        print(f"  WARNING: {hname} fix failed: {e}")

# ── Ensure margins are explicitly set on all sections ────────────
print("Ensuring all sections have explicit margins...")
for i, sec in enumerate(doc.sections):
    sec.top_margin    = Inches(1.0)
    sec.bottom_margin = Inches(1.0)
    sec.left_margin   = Inches(1.5)
    sec.right_margin  = Inches(1.0)

print(f"  All {len(doc.sections)} sections margins set explicitly")

# ── Save ─────────────────────────────────────────────────────────
print("Saving...")
doc.save(CAPSTONE)
final_size = os.path.getsize(CAPSTONE)
print(f"Saved: {CAPSTONE}")
print(f"Size: {final_size/1024:.1f} KB ({final_size:,} bytes)")

# ── Quick verification ────────────────────────────────────────────
print("\n--- Verification ---")
doc2 = Document(CAPSTONE)

# Check Normal style
normal2 = doc2.styles['Normal']
ppr2 = normal2.element.find(qn('w:pPr'))
if ppr2 is not None:
    spc2 = ppr2.find(qn('w:spacing'))
    print(f"Normal pPr spacing: line={spc2.get(qn('w:line')) if spc2 is not None else 'N/A'} "
          f"lineRule={spc2.get(qn('w:lineRule')) if spc2 is not None else 'N/A'}")
else:
    print("Normal: no pPr found!")

# Check a body paragraph
for p in doc2.paragraphs:
    if p.text.strip() and not p.style.name.startswith('Heading'):
        pp = p._p.pPr
        if pp is not None:
            spc = pp.find(qn('w:spacing'))
            print(f"Body para spacing: line={spc.get(qn('w:line')) if spc else 'N/A'} "
                  f"lineRule={spc.get(qn('w:lineRule')) if spc else 'N/A'}")
        break

# Check sections
for i, sec in enumerate(doc2.sections):
    from docx.shared import Emu
    def ei(v): return round(v / 914400, 3) if v else None
    print(f"Section {i}: top={ei(sec.top_margin)} bottom={ei(sec.bottom_margin)} "
          f"left={ei(sec.left_margin)} right={ei(sec.right_margin)}")

print("\nFix 2 complete.")
