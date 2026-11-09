"""
Manuscript formatting audit and figure insertion script.
Tasks: 1-7 as specified in the workflow prompt.
"""

import os
import sys
import copy
import shutil
import zipfile
import re
from io import BytesIO

from docx import Document
from docx.shared import Inches, Pt, Emu, RGBColor
from docx.oxml.ns import qn, nsmap
from docx.oxml import OxmlElement
from docx.enum.text import WD_LINE_SPACING, WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_SECTION
from lxml import etree

# ─────────────────────────────────────────────
# Paths
# ─────────────────────────────────────────────
BASE = r"c:\xampp\htdocs\smartspend_app"
CAPSTONE   = os.path.join(BASE, "docs", "handsoff",
             "CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx")
TEMPLATE   = os.path.join(BASE, "docs", "manuscript", "templates", "TEMPLATE_HABSS.docx")
FIGS       = os.path.join(BASE, "docs", "manuscript", "figures")

FIG_FILES = {
    "1.1": os.path.join(FIGS, "Figure_1_1_Financial_Literacy_Rates.png"),
    "1.2": os.path.join(FIGS, "Figure_1_2_Conceptual_Framework_IPO.png"),
    "2.1": os.path.join(FIGS, "Figure_2_1_SUS_Score_Interpretation.png"),
    "2.2": os.path.join(FIGS, "Figure_2_2_Agile_Kanban_Workflow.png"),
}
# Display widths in inches (height computed proportionally)
FIG_WIDTHS = {
    "1.1": 4.22,
    "1.2": 6.0,
    "2.1": 6.0,
    "2.2": 6.5,
}
# Native pixel dimensions (width x height)
FIG_DIMS = {
    "1.1": (1333, 748),
    "1.2": (1308, 852),
    "2.1": (1336, 625),
    "2.2": (2385, 940),
}

log = []


def L(msg):
    print(msg)
    log.append(msg)


# ─────────────────────────────────────────────
# TASK 1 — Extract template style properties
# ─────────────────────────────────────────────

def emu_to_inches(emu):
    if emu is None:
        return None
    return round(emu / 914400, 3)


def pt_val(font_size):
    """Return Pt value or None."""
    if font_size is None:
        return None
    return font_size.pt


def extract_style_info(doc, style_name):
    """Extract font/spacing info from a named style."""
    info = {}
    try:
        style = doc.styles[style_name]
    except KeyError:
        return info
    f = style.font
    pf = style.paragraph_format
    info["font_name"] = f.name
    info["font_size_pt"] = pt_val(f.size)
    info["bold"] = f.bold
    info["caps"] = f.all_caps
    info["space_before_pt"] = pt_val(pf.space_before)
    info["space_after_pt"] = pt_val(pf.space_after)
    info["line_spacing"] = pf.line_spacing
    info["line_spacing_rule"] = str(pf.line_spacing_rule)
    info["first_line_indent"] = emu_to_inches(pf.first_line_indent)
    return info


def extract_margins(doc):
    margins = {}
    for i, sec in enumerate(doc.sections):
        margins[i] = {
            "top":    emu_to_inches(sec.top_margin),
            "bottom": emu_to_inches(sec.bottom_margin),
            "left":   emu_to_inches(sec.left_margin),
            "right":  emu_to_inches(sec.right_margin),
        }
    return margins


L("=" * 60)
L("TASK 1 — Cross-examine TEMPLATE_HABSS vs CAPSTONE_5")
L("=" * 60)

tmpl = Document(TEMPLATE)
cap  = Document(CAPSTONE)

STYLE_NAMES = ["Normal", "Heading 1", "Heading 2", "Heading 3"]
tmpl_styles = {s: extract_style_info(tmpl, s) for s in STYLE_NAMES}
cap_styles  = {s: extract_style_info(cap,  s) for s in STYLE_NAMES}

L("\n--- TEMPLATE_HABSS styles ---")
for sn, props in tmpl_styles.items():
    L(f"  [{sn}] {props}")

L("\n--- CAPSTONE_5 styles ---")
for sn, props in cap_styles.items():
    L(f"  [{sn}] {props}")

L("\n--- DEVIATIONS ---")
deviations = []
for sn in STYLE_NAMES:
    tp = tmpl_styles.get(sn, {})
    cp = cap_styles.get(sn, {})
    all_keys = set(tp.keys()) | set(cp.keys())
    for k in sorted(all_keys):
        tv = tp.get(k)
        cv = cp.get(k)
        if tv != cv:
            msg = f"  DEVIATION [{sn}] {k}: template={tv!r}  capstone={cv!r}"
            L(msg)
            deviations.append((sn, k, tv, cv))

tmpl_margins = extract_margins(tmpl)
cap_margins  = extract_margins(cap)

L("\n--- TEMPLATE margins ---")
for i, m in tmpl_margins.items():
    L(f"  Section {i}: {m}")

L("\n--- CAPSTONE margins ---")
for i, m in cap_margins.items():
    L(f"  Section {i}: {m}")

L("\n--- MARGIN DEVIATIONS ---")
margin_deviations = []
for i, tm in tmpl_margins.items():
    cm = cap_margins.get(i, {})
    for side, tv in tm.items():
        cv = cm.get(side)
        if tv != cv:
            msg = f"  DEVIATION margin section {i} {side}: template={tv}  capstone={cv}"
            L(msg)
            margin_deviations.append((i, side, tv, cv))

# ─────────────────────────────────────────────
# TASK 2 — Apply formatting fixes
# ─────────────────────────────────────────────
L("\n" + "=" * 60)
L("TASK 2 — Apply formatting fixes to CAPSTONE_5")
L("=" * 60)

def apply_style_from_template(doc_style, tmpl_info):
    """Apply font/paragraph properties from tmpl_info dict to doc_style."""
    f = doc_style.font
    pf = doc_style.paragraph_format

    if tmpl_info.get("font_name"):
        f.name = tmpl_info["font_name"]
    if tmpl_info.get("font_size_pt") is not None:
        f.size = Pt(tmpl_info["font_size_pt"])
    if tmpl_info.get("bold") is not None:
        f.bold = tmpl_info["bold"]
    # all_caps requires XML tweak via docx element
    caps_val = tmpl_info.get("caps")
    if caps_val is not None:
        try:
            f.all_caps = caps_val
        except Exception:
            pass

    if tmpl_info.get("space_before_pt") is not None:
        pf.space_before = Pt(tmpl_info["space_before_pt"])
    if tmpl_info.get("space_after_pt") is not None:
        pf.space_after = Pt(tmpl_info["space_after_pt"])

    # Line spacing
    lsr = tmpl_info.get("line_spacing_rule", "")
    ls  = tmpl_info.get("line_spacing")
    if ls is not None and "DOUBLE" in str(lsr).upper():
        pf.line_spacing_rule = WD_LINE_SPACING.DOUBLE
    elif ls is not None and "EXACTLY" in str(lsr).upper():
        pf.line_spacing_rule = WD_LINE_SPACING.EXACTLY
        pf.line_spacing = ls
    elif ls is not None and "AT_LEAST" in str(lsr).upper():
        pf.line_spacing_rule = WD_LINE_SPACING.AT_LEAST
        pf.line_spacing = ls
    # For Normal style we always want double spacing
    # (handled specially below)


# Apply heading styles from template
for sn in ["Heading 1", "Heading 2", "Heading 3"]:
    ti = tmpl_styles.get(sn, {})
    if not ti:
        continue
    try:
        cs = cap.styles[sn]
        apply_style_from_template(cs, ti)
        L(f"  Applied template style to [{sn}]")
    except Exception as e:
        L(f"  WARNING: could not apply [{sn}]: {e}")

# Normal style — Times New Roman 12pt, double spacing
try:
    normal_tmpl = tmpl_styles.get("Normal", {})
    cap_normal = cap.styles["Normal"]
    fn = normal_tmpl.get("font_name") or "Times New Roman"
    fs = normal_tmpl.get("font_size_pt") or 12.0
    cap_normal.font.name = fn
    cap_normal.font.size = Pt(fs)
    cap_normal.paragraph_format.line_spacing_rule = WD_LINE_SPACING.DOUBLE
    cap_normal.paragraph_format.line_spacing = None
    L(f"  Applied Normal style: {fn} {fs}pt, double spacing")
except Exception as e:
    L(f"  WARNING: Normal style: {e}")

# Apply margins from template (or Lorma standard if template differs from 1in)
# Lorma standard: left=1.5in, top/right/bottom=1in
LORMA_LEFT   = Inches(1.5)
LORMA_OTHERS = Inches(1.0)

# Use template if it has explicit margins, otherwise Lorma standard
def get_target_margin(side, tmpl_val):
    if tmpl_val is not None:
        return Inches(tmpl_val)
    if side == "left":
        return LORMA_LEFT
    return LORMA_OTHERS

L("\n  Applying margins to all sections...")
for i, sec in enumerate(cap.sections):
    tm = tmpl_margins.get(0, {})  # use first template section as reference
    sec.top_margin    = get_target_margin("top",    tm.get("top"))
    sec.bottom_margin = get_target_margin("bottom", tm.get("bottom"))
    sec.left_margin   = get_target_margin("left",   tm.get("left"))
    sec.right_margin  = get_target_margin("right",  tm.get("right"))
    L(f"  Section {i} margins set: top={emu_to_inches(sec.top_margin)}in "
      f"bottom={emu_to_inches(sec.bottom_margin)}in "
      f"left={emu_to_inches(sec.left_margin)}in "
      f"right={emu_to_inches(sec.right_margin)}in")

# Apply double-spacing to all body paragraphs (not in tables, not headings)
heading_style_names = {"Heading 1", "Heading 2", "Heading 3",
                       "Heading 4", "Heading 5", "Heading 6"}
caption_styles = {"Caption", "Figure Caption", "Table Caption"}

body_para_count = 0
for para in cap.paragraphs:
    sname = para.style.name if para.style else ""
    if sname in heading_style_names or sname in caption_styles:
        continue
    if sname.startswith("Heading"):
        continue
    # Apply double spacing to normal body paragraphs
    pf = para.paragraph_format
    pf.line_spacing_rule = WD_LINE_SPACING.DOUBLE
    pf.line_spacing = None
    body_para_count += 1

L(f"  Double spacing applied to {body_para_count} body paragraphs")

# Apply single spacing inside tables
table_para_count = 0
for table in cap.tables:
    for row in table.rows:
        for cell in row.cells:
            for para in cell.paragraphs:
                pf = para.paragraph_format
                pf.line_spacing_rule = WD_LINE_SPACING.SINGLE
                pf.line_spacing = None
                table_para_count += 1

L(f"  Single spacing applied to {table_para_count} table cell paragraphs")

# ─────────────────────────────────────────────
# TASK 3 — Replace blurry bar chart
# ─────────────────────────────────────────────
L("\n" + "=" * 60)
L("TASK 3 — Replace blurry bar chart with high-res Figure 1.1")
L("=" * 60)

def get_image_size_from_part(img_part):
    """Try to read image dimensions from image bytes using struct."""
    import struct
    data = img_part.blob
    # PNG: width at bytes 16-20, height at 20-24
    if data[:8] == b'\x89PNG\r\n\x1a\n':
        w, h = struct.unpack('>II', data[16:24])
        return w, h
    # JPEG: scan for SOF marker
    if data[:2] == b'\xff\xd8':
        i = 2
        while i < len(data) - 9:
            if data[i] == 0xff:
                marker = data[i+1]
                if marker in (0xc0, 0xc1, 0xc2):
                    h = struct.unpack('>H', data[i+5:i+7])[0]
                    w = struct.unpack('>H', data[i+7:i+9])[0]
                    return w, h
                length = struct.unpack('>H', data[i+2:i+4])[0]
                i += 2 + length
            else:
                i += 1
    return None, None


def find_all_inline_images(doc):
    """
    Return list of (paragraph_idx, run_elem, blip_elem, rId, img_part, w_px, h_px, cx_emu, cy_emu)
    for every inline image in the document body.
    """
    results = []
    NS = {
        'a':   'http://schemas.openxmlformats.org/drawingml/2006/main',
        'r':   'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
        'wp':  'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
        'pic': 'http://schemas.openxmlformats.org/drawingml/2006/picture',
    }
    body = doc.element.body
    paras = body.findall('.//' + qn('w:p'))
    for p_idx, p_el in enumerate(paras):
        for drawing in p_el.findall('.//' + qn('w:drawing')):
            # Inline
            for inline in drawing.findall('{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}inline'):
                # Get display size
                extent = inline.find('{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}extent')
                cx_emu = int(extent.get('cx')) if extent is not None else None
                cy_emu = int(extent.get('cy')) if extent is not None else None
                # Find blip
                blip = inline.find('.//{http://schemas.openxmlformats.org/drawingml/2006/main}blip')
                if blip is None:
                    continue
                rId = blip.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed')
                if rId is None:
                    continue
                try:
                    img_part = doc.part.related_parts[rId]
                except KeyError:
                    continue
                w_px, h_px = get_image_size_from_part(img_part)
                results.append({
                    'p_idx': p_idx,
                    'p_el':  p_el,
                    'inline': inline,
                    'blip':  blip,
                    'rId':   rId,
                    'img_part': img_part,
                    'w_px':  w_px,
                    'h_px':  h_px,
                    'cx_emu': cx_emu,
                    'cy_emu': cy_emu,
                })
    return results


all_images = find_all_inline_images(cap)
L(f"  Found {len(all_images)} inline images in document")

# Log all images with their dimensions
for img in all_images:
    sz = round(len(img['img_part'].blob) / 1024, 1)
    cx_in = round(img['cx_emu'] / 914400, 2) if img['cx_emu'] else '?'
    cy_in = round(img['cy_emu'] / 914400, 2) if img['cy_emu'] else '?'
    L(f"    rId={img['rId']} px={img['w_px']}x{img['h_px']} kb={sz} "
      f"display={cx_in}x{cy_in}in")

# Identify blurry chart: small image ~600x371 or ~12KB
# Also track images that might be Figure 1.2, 2.1, 2.2 by size/rId
blurry_chart = None
low_res_threshold_kb = 50  # under 50KB is suspect

# Protected image rIds (student photos + header/footer)
# We'll identify them by blob size ranges as a safety check too
PROTECTED_RIDS = set()  # will populate after scanning

# Find the blurry chart (smallest non-protected non-photo image)
candidate_replacements = []
for img in all_images:
    sz_kb = len(img['img_part'].blob) / 1024
    w = img['w_px'] or 0
    h = img['h_px'] or 0
    # Skip large photos (student photos tend to be large files OR very small display)
    # Blurry chart: ~600x371px, ~12KB, display ~4.22x2.60in
    if sz_kb < 50 and w > 100 and h > 100:
        candidate_replacements.append(img)
        L(f"  Candidate blurry image: rId={img['rId']} {w}x{h}px {sz_kb:.1f}KB")

if candidate_replacements:
    # Pick the smallest one as the blurry chart
    blurry_chart = min(candidate_replacements, key=lambda x: len(x['img_part'].blob))
    L(f"  → Selected as blurry chart: rId={blurry_chart['rId']} "
      f"{blurry_chart['w_px']}x{blurry_chart['h_px']}px "
      f"{len(blurry_chart['img_part'].blob)/1024:.1f}KB")
else:
    L("  No blurry chart candidate found")


def replace_image_in_part(doc_part, old_rid, new_img_path):
    """
    Replace the image bytes in an existing relationship.
    Returns the new rId.
    """
    from docx.opc.part import Part
    from docx.opc.packuri import PackURI
    import posixpath

    with open(new_img_path, 'rb') as f:
        new_bytes = f.read()

    # Determine content type
    ext = os.path.splitext(new_img_path)[1].lower()
    ct_map = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg'}
    content_type = ct_map.get(ext, 'image/png')

    # Get the existing part and replace its blob
    existing_part = doc_part.related_parts[old_rid]
    existing_part._blob = new_bytes
    # Update content type if needed
    # (The part's partname stays the same, just bytes change)
    L(f"    Replaced blob for rId={old_rid}: "
      f"old={len(existing_part._blob)} bytes after write — "
      f"new={len(new_bytes)} bytes from {os.path.basename(new_img_path)}")
    return old_rid


# Replace blurry chart (Task 3)
blurry_replaced = False
if blurry_chart:
    old_sz = len(blurry_chart['img_part'].blob)
    new_rid = replace_image_in_part(cap.part, blurry_chart['rId'],
                                    FIG_FILES["1.1"])
    new_sz = len(blurry_chart['img_part'].blob)
    # Preserve display size ~4.22x2.60in
    cx_target = int(4.22 * 914400)
    cy_target = int(2.60 * 914400)
    extent = blurry_chart['inline'].find(
        '{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}extent')
    if extent is not None:
        extent.set('cx', str(cx_target))
        extent.set('cy', str(cy_target))
    blurry_replaced = True
    L(f"  ✓ Blurry chart replaced: {old_sz/1024:.1f}KB → {new_sz/1024:.1f}KB "
      f"(display kept ~4.22x2.60in)")


# ─────────────────────────────────────────────
# TASK 4 — Insert figures into [[PENDING]] placeholders
# ─────────────────────────────────────────────
L("\n" + "=" * 60)
L("TASK 4 — Process [[PENDING]] placeholders")
L("=" * 60)

def compute_display_size(fig_key):
    """Return (cx_emu, cy_emu) for a figure, preserving aspect ratio."""
    w_in = FIG_WIDTHS[fig_key]
    wpx, hpx = FIG_DIMS[fig_key]
    ratio = hpx / wpx
    h_in = w_in * ratio
    return int(w_in * 914400), int(h_in * 914400)


def add_image_to_paragraph(para, img_path, cx_emu, cy_emu):
    """
    Add an inline image run to an existing paragraph using low-level XML.
    Clears the paragraph's existing runs first (removes placeholder text).
    """
    from docx.oxml import OxmlElement
    from docx.oxml.ns import qn
    import uuid

    doc_part = cap.part

    # Add image part to document relationships
    with open(img_path, 'rb') as f:
        img_bytes = f.read()

    ext = os.path.splitext(img_path)[1].lower()
    ct_map = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg'}
    content_type = ct_map.get(ext, 'image/png')

    # Use python-docx's inline_shapes add mechanism via document part
    from docx.opc.part import Part as OpcPart
    from docx.image.image import Image as DocxImage

    # Add image using the document's internal add mechanism
    image_descriptor = cap.part.image_parts._get_or_add_image_part(img_bytes)
    rId = cap.part.relate_to(image_descriptor,
        'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image')

    # Build the drawing XML
    pic_id = abs(hash(img_path + str(cx_emu))) % 100000
    pic_name = os.path.basename(img_path)

    # Clear existing runs from placeholder paragraph
    p_elem = para._p
    for child in list(p_elem):
        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
        if tag in ('r', 'hyperlink', 'ins', 'del'):
            p_elem.remove(child)

    # Build inline drawing XML
    drawing_xml = f"""<w:r xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:drawing>
    <wp:inline distT="0" distB="0" distL="0" distR="0"
      xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
      <wp:extent cx="{cx_emu}" cy="{cy_emu}"/>
      <wp:effectExtent l="0" t="0" r="0" b="0"/>
      <wp:docPr id="{pic_id}" name="{pic_name}"/>
      <wp:cNvGraphicFramePr>
        <a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>
      </wp:cNvGraphicFramePr>
      <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
        <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
          <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:nvPicPr>
              <pic:cNvPr id="{pic_id}" name="{pic_name}"/>
              <pic:cNvPicPr/>
            </pic:nvPicPr>
            <pic:blipFill>
              <a:blip r:embed="{rId}"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>
              <a:stretch><a:fillRect/></a:stretch>
            </pic:blipFill>
            <pic:spPr>
              <a:xfrm>
                <a:off x="0" y="0"/>
                <a:ext cx="{cx_emu}" cy="{cy_emu}"/>
              </a:xfrm>
              <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
            </pic:spPr>
          </pic:pic>
        </a:graphicData>
      </a:graphic>
    </wp:inline>
  </w:drawing>
</w:r>"""

    run_elem = etree.fromstring(drawing_xml)
    p_elem.append(run_elem)
    return rId


# Scan for [[PENDING]] placeholders
pending_resolved = []
pending_manual = []
pending_other = []

paras = cap.paragraphs
for i, para in enumerate(paras):
    text = para.text
    if '[[PENDING' not in text and '[[PENDING:' not in text.upper():
        continue

    L(f"  Found PENDING para {i}: {text[:100]!r}")

    # Check which figure it references
    fig_match = re.search(r'Figure\s+(\d+\.\d+)', text, re.IGNORECASE)
    if fig_match:
        fig_num = fig_match.group(1)  # e.g. "1.1"
        if fig_num in FIG_FILES:
            # Insert high-res figure
            img_path = FIG_FILES[fig_num]
            cx, cy = compute_display_size(fig_num)
            try:
                rId = add_image_to_paragraph(para, img_path, cx, cy)
                L(f"  ✓ Inserted Figure {fig_num} (rId={rId}) into para {i}")
                pending_resolved.append(fig_num)
            except Exception as e:
                L(f"  ERROR inserting Figure {fig_num}: {e}")
                pending_manual.append(f"Figure {fig_num} (error: {e})")
        elif fig_num.startswith("3."):
            # Replace with manual placeholder text
            fig_label = fig_num
            if fig_num == "3.1":
                new_text = f"[Figure 3.1 — System flowchart/DFD to be inserted by Cyrille before printing]"
            else:
                new_text = f"[Figure {fig_label} — App screenshot to be inserted by Cyrille before printing]"
            # Clear and set new text
            p_elem = para._p
            for child in list(p_elem):
                tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
                if tag in ('r', 'hyperlink'):
                    p_elem.remove(child)
            # Add a single run with the new text
            run_el = OxmlElement('w:r')
            t_el = OxmlElement('w:t')
            t_el.text = new_text
            t_el.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
            run_el.append(t_el)
            p_elem.append(run_el)
            L(f"  ✓ Set manual placeholder for Figure {fig_num}")
            pending_manual.append(f"Figure {fig_num}")
        else:
            L(f"  ? Unrecognized figure number {fig_num} — leaving as-is")
            pending_other.append(text[:80])
    else:
        # Non-figure PENDING — leave as-is
        L(f"  → Non-figure PENDING, leaving as-is: {text[:80]!r}")
        pending_other.append(text[:80])


L(f"\n  Pending resolved (figures inserted): {len(pending_resolved)} → {pending_resolved}")
L(f"  Pending manual (screenshots/DFD): {len(pending_manual)}")
L(f"  Pending other (non-figure): {len(pending_other)}")


# ─────────────────────────────────────────────
# Check and replace existing embedded figures (P161, P261, P265)
# ─────────────────────────────────────────────
L("\n--- Checking existing embedded figures for low-res replacements ---")

# Re-scan all images after modifications
all_images_v2 = find_all_inline_images(cap)

# Identify figures that are present but low-res (< 100KB and not student photos)
# Student photos: rId60 (184x185), rId61 (1536x2048), rId62 (433x457)
# Header banner: typically large or identifiable
# We'll check based on image dimensions vs known figure dimensions

figure_size_map = {
    "1.2": (1308, 852),
    "2.1": (1336, 625),
    "2.2": (2385, 940),
}

for img in all_images_v2:
    sz_kb = len(img['img_part'].blob) / 1024
    w = img['w_px'] or 0
    h = img['h_px'] or 0
    rId = img['rId']

    # Skip very large images (likely photos/banner) and tiny ones
    if sz_kb > 500 or sz_kb < 5:
        continue

    # Skip images we already replaced (the blurry chart)
    if blurry_chart and rId == blurry_chart['rId']:
        continue

    # Check if this might be a low-res version of one of our figures
    # by aspect ratio comparison
    for fig_key, (fw, fh) in figure_size_map.items():
        target_ratio = fw / fh
        if w > 50 and h > 50:
            current_ratio = w / h
            ratio_match = abs(current_ratio - target_ratio) < 0.15
            if ratio_match and sz_kb < 100:
                L(f"  Low-res embedded figure candidate: rId={rId} {w}x{h}px {sz_kb:.1f}KB "
                  f"(matches Figure {fig_key} aspect ratio)")
                # Replace with high-res
                old_sz = sz_kb
                replace_image_in_part(cap.part, rId, FIG_FILES[fig_key])
                new_sz = len(img['img_part'].blob) / 1024
                L(f"  ✓ Replaced low-res Figure {fig_key}: {old_sz:.1f}KB → {new_sz:.1f}KB")


# ─────────────────────────────────────────────
# TASK 5 — Save output
# ─────────────────────────────────────────────
L("\n" + "=" * 60)
L("TASK 5 — Save output")
L("=" * 60)

cap.save(CAPSTONE)
final_size = os.path.getsize(CAPSTONE)
L(f"  ✓ Saved to: {CAPSTONE}")
L(f"  Final file size: {final_size/1024:.1f} KB ({final_size:,} bytes)")


# ─────────────────────────────────────────────
# TASK 7 — Verification report
# ─────────────────────────────────────────────
L("\n" + "=" * 60)
L("TASK 7 — Verification Report")
L("=" * 60)

# Reload and verify
cap_verify = Document(CAPSTONE)

# Check Normal style
try:
    ns = cap_verify.styles["Normal"]
    L(f"  Normal font: {ns.font.name} {pt_val(ns.font.size)}pt "
      f"line_spacing_rule={ns.paragraph_format.line_spacing_rule}")
except Exception as e:
    L(f"  WARNING: Could not verify Normal style: {e}")

# Check heading styles
for sn in ["Heading 1", "Heading 2", "Heading 3"]:
    try:
        hs = cap_verify.styles[sn]
        L(f"  [{sn}] font={hs.font.name} size={pt_val(hs.font.size)}pt bold={hs.font.bold}")
    except Exception as e:
        L(f"  WARNING: {sn}: {e}")

# Check margins
for i, sec in enumerate(cap_verify.sections):
    L(f"  Section {i} margins: top={emu_to_inches(sec.top_margin)}in "
      f"bottom={emu_to_inches(sec.bottom_margin)}in "
      f"left={emu_to_inches(sec.left_margin)}in "
      f"right={emu_to_inches(sec.right_margin)}in")

# Count remaining [[PENDING]] tags
remaining_pending = []
for para in cap_verify.paragraphs:
    if '[[PENDING' in para.text:
        remaining_pending.append(para.text[:100])

L(f"\n  Remaining [[PENDING]] tags: {len(remaining_pending)}")
for rp in remaining_pending:
    L(f"    {rp!r}")

# Report blurry chart replacement
if blurry_replaced:
    L(f"\n  ✓ Blurry chart replaced successfully")
else:
    L(f"\n  ⚠ Blurry chart was NOT replaced (not found)")

L(f"\n  Final file: {CAPSTONE}")
L(f"  Size: {final_size/1024:.1f} KB")


# ─────────────────────────────────────────────
# Print summary for commit message
# ─────────────────────────────────────────────
print("\n" + "=" * 60)
print("SUMMARY")
print("=" * 60)
print(f"Blurry chart replaced: {blurry_replaced}")
print(f"[[PENDING]] figures inserted: {pending_resolved}")
print(f"[[PENDING]] manual placeholders set: {pending_manual}")
print(f"[[PENDING]] other (unchanged): {len(pending_other)}")
print(f"Style deviations found: {len(deviations)}")
print(f"Margin deviations found: {len(margin_deviations)}")
print(f"Body paragraphs double-spaced: {body_para_count}")
print(f"Table paragraphs single-spaced: {table_para_count}")
print(f"Remaining [[PENDING]] tags: {len(remaining_pending)}")
print(f"Final file size: {final_size/1024:.1f} KB ({final_size:,} bytes)")
