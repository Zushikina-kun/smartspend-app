"""
deep_format_audit.py
Extract EXACT XML for key sections from both templates and source doc.
We need to see the actual raw XML that Word uses, not just python-docx abstractions.
"""
import zipfile, os
from lxml import etree

BASE = os.path.dirname(__file__)
DOCS = {
    "WORKING":  "SMARTSPEND_CAPSTONE_WORKING.docx",
    "LORMA":    "templates/TEMPLATE_LORMA_ACCESS_PLUS.docx",
    "HABSS":    "templates/TEMPLATE_HABSS.docx",
    "V4":       "SMARTSPEND_FINAL_V4.docx",
}
NS  = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
NSM = {"w": NS}

def get_doc_xml(fname):
    path = os.path.join(BASE, fname)
    with zipfile.ZipFile(path) as z:
        return z.read("word/document.xml")

def get_styles_xml(fname):
    path = os.path.join(BASE, fname)
    with zipfile.ZipFile(path) as z:
        return z.read("word/styles.xml")

def get_settings_xml(fname):
    path = os.path.join(BASE, fname)
    with zipfile.ZipFile(path) as z:
        try:
            return z.read("word/settings.xml")
        except:
            return b""

def para_format_summary(p):
    """Extract all formatting from a paragraph element as a dict."""
    pPr = p.find("w:pPr", NSM)
    rPr_first = None
    for r in p.findall(".//w:r", NSM):
        rPr_first = r.find("w:rPr", NSM)
        break

    result = {}

    if pPr is not None:
        # Alignment
        jc = pPr.find("w:jc", NSM)
        result["align"] = jc.get("{%s}val" % NS) if jc is not None else "left"

        # Spacing
        sp = pPr.find("w:spacing", NSM)
        if sp is not None:
            result["before"] = sp.get("{%s}before" % NS)
            result["after"]  = sp.get("{%s}after" % NS)
            result["line"]   = sp.get("{%s}line" % NS)
            result["lineRule"] = sp.get("{%s}lineRule" % NS)

        # Indent
        ind = pPr.find("w:ind", NSM)
        if ind is not None:
            result["firstLine"] = ind.get("{%s}firstLine" % NS)
            result["hanging"]   = ind.get("{%s}hanging" % NS)
            result["left"]      = ind.get("{%s}left" % NS)

        # Style
        sty = pPr.find("w:pStyle", NSM)
        result["style"] = sty.get("{%s}val" % NS) if sty is not None else "Normal"

        # Outline level
        ol = pPr.find("w:outlineLvl", NSM)
        result["outlineLevel"] = ol.get("{%s}val" % NS) if ol is not None else None

        # Page break before
        pb = pPr.find("w:pageBreakBefore", NSM)
        result["pageBreakBefore"] = pb is not None

        # Context spacing
        cs = pPr.find("w:contextualSpacing", NSM)
        result["contextualSpacing"] = cs is not None

    if rPr_first is not None:
        rf = rPr_first.find("w:rFonts", NSM)
        result["font"]   = rf.get("{%s}ascii" % NS) if rf is not None else None
        sz = rPr_first.find("w:sz", NSM)
        result["size"]   = int(sz.get("{%s}val" % NS)) / 2 if sz is not None else None
        result["bold"]   = rPr_first.find("w:b", NSM) is not None
        result["italic"] = rPr_first.find("w:i", NSM) is not None

    return result

def get_text(p):
    return "".join(t.text or "" for t in p.findall(".//w:t", NSM)).strip()

def analyze_doc(label, fname):
    path = os.path.join(BASE, fname)
    if not os.path.exists(path):
        print(f"\n{label}: NOT FOUND"); return

    xml    = get_doc_xml(fname)
    tree   = etree.fromstring(xml)
    paras  = tree.findall(".//w:body/w:p", NSM)
    tables = tree.findall(".//w:body/w:tbl", NSM)

    print(f"\n{'='*70}")
    print(f"  {label}: {fname}")
    print(f"  Paragraphs: {len(paras)}   Tables: {len(tables)}")
    print(f"{'='*70}")

    # Show first 60 non-empty paragraphs with FULL formatting
    print(f"\n{'IDX':>4} {'STYLE':16} {'FONT':8} {'SZ':4} {'B':1} {'I':1} {'ALIGN':8} {'BEF':5} {'AFT':5} {'LINE':5} {'FI':5} {'LEFT':5}  TEXT")
    print("-"*110)

    shown = 0
    for i, p in enumerate(paras):
        txt = get_text(p)
        if not txt: continue
        f = para_format_summary(p)
        print(f"{i:>4} {f.get('style','?'):16} "
              f"{(f.get('font') or 'inh'):8} "
              f"{str(f.get('size') or 'inh'):4} "
              f"{'B' if f.get('bold') else ' '} "
              f"{'I' if f.get('italic') else ' '} "
              f"{f.get('align','?'):8} "
              f"{str(f.get('before') or 'inh'):5} "
              f"{str(f.get('after') or 'inh'):5} "
              f"{str(f.get('line') or 'inh'):5} "
              f"{str(f.get('firstLine') or ''):5} "
              f"{str(f.get('left') or ''):5}  "
              f"{txt[:50]}")
        shown += 1
        if shown >= 60: break

    # Table analysis
    print(f"\n--- TABLES ({len(tables)}) ---")
    for ti, tbl in enumerate(tables):
        tblPr = tbl.find("w:tblPr", NSM)
        tblW  = tblPr.find("w:tblW", NSM) if tblPr is not None else None
        tblStyle = tblPr.find("w:tblStyle", NSM) if tblPr is not None else None
        tblInd = tblPr.find("w:tblInd", NSM) if tblPr is not None else None
        tblLayout = tblPr.find("w:tblLayout", NSM) if tblPr is not None else None

        rows   = tbl.findall("w:tr", NSM)
        if not rows: continue

        # First row cells
        first_cells = rows[0].findall("w:tc", NSM)
        cell_widths = []
        for tc in first_cells:
            tcPr = tc.find("w:tcPr", NSM)
            tcW  = tcPr.find("w:tcW", NSM) if tcPr is not None else None
            if tcW is not None:
                cell_widths.append(tcW.get("{%s}w" % NS))

        # Cell font info from first data cell
        cell_font = "?"
        for tc in first_cells:
            for r in tc.findall(".//w:r", NSM):
                rp = r.find("w:rPr", NSM)
                if rp is not None:
                    rf = rp.find("w:rFonts", NSM)
                    sz = rp.find("w:sz", NSM)
                    if rf is not None:
                        cell_font = f"{rf.get('{%s}ascii'%NS,'?')}/{int(sz.get('{%s}val'%NS,0))/2 if sz is not None else '?'}pt"
                    break
            if cell_font != "?": break

        tbl_w_val  = tblW.get("{%s}w" % NS) if tblW is not None else "?"
        tbl_w_type = tblW.get("{%s}type" % NS) if tblW is not None else "?"
        tbl_style  = tblStyle.get("{%s}val" % NS) if tblStyle is not None else "none"
        tbl_layout = tblLayout.get("{%s}type" % NS) if tblLayout is not None else "?"

        hdr_text = get_text(rows[0])[:50]
        print(f"  T{ti+1}: {len(rows)}rows x {len(first_cells)}cols  "
              f"width={tbl_w_val}({tbl_w_type})  style={tbl_style}  "
              f"layout={tbl_layout}  cellFont={cell_font}")
        print(f"       cellWidths={cell_widths[:5]}{'...' if len(cell_widths)>5 else ''}")
        print(f"       hdr='{hdr_text}'")

    # Normal style definition
    styles_xml = get_styles_xml(fname)
    stree = etree.fromstring(styles_xml)
    print(f"\n--- STYLES ---")
    for style in stree.findall(".//w:style", NSM):
        sid = style.get("{%s}styleId" % NS)
        if sid in ("Normal", "normal", "DefaultParagraphFont", "TableGrid"):
            pPr = style.find(".//w:pPr", NSM)
            rPr = style.find(".//w:rPr", NSM)
            rf  = rPr.find("w:rFonts", NSM) if rPr is not None else None
            sz  = rPr.find("w:sz", NSM) if rPr is not None else None
            sp  = pPr.find("w:spacing", NSM) if pPr is not None else None
            line = sp.get("{%s}line" % NS) if sp is not None else None
            before = sp.get("{%s}before" % NS) if sp is not None else None
            after  = sp.get("{%s}after" % NS) if sp is not None else None
            font   = rf.get("{%s}ascii" % NS) if rf is not None else None
            size   = int(sz.get("{%s}val" % NS))/2 if sz is not None else None
            print(f"  {sid}: font={font} size={size} line={line} before={before} after={after}")

    # Settings - default tab stop
    settings_xml = get_settings_xml(fname)
    if settings_xml:
        stree2 = etree.fromstring(settings_xml)
        dts = stree2.find(".//w:defaultTabStop", NSM)
        if dts is not None:
            print(f"\n--- SETTINGS ---")
            print(f"  defaultTabStop: {dts.get('{%s}val'%NS)} twips = {int(dts.get('{%s}val'%NS,720))/1440:.3f}\"")

for label, fname in DOCS.items():
    analyze_doc(label, fname)
