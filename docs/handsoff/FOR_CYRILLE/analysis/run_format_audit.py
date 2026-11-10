"""
FORMATTING_AUDIT_NOV10.py
Extracts formatting metadata from all reference/template .docx files and
the FINAL manuscript, then writes a Markdown audit report.
"""

import os
import json
from pathlib import Path
from docx import Document
from docx.shared import Pt, Inches, Emu
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn

# ── Paths ────────────────────────────────────────────────────────────────────
BASE = Path(r"c:\xampp\htdocs\smartspend_app")
REF_DIR  = BASE / "docs/handsoff/reference_manuscripts"
TPL_DIR  = BASE / "docs/manuscript/templates"
FINAL    = BASE / "docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx"
OUT_DIR  = BASE / "docs/handsoff/FOR_CYRILLE/analysis"
OUT_FILE = OUT_DIR / "FORMATTING_AUDIT_NOV10.md"

OUT_DIR.mkdir(parents=True, exist_ok=True)

FILES = {
    "REF1_CAPSTONE5":     REF_DIR / "CAPSTONE_5_team_revision_backup.docx",
    "REF2_LIGTASK":       REF_DIR / "LigTask_Manuscript_Reference.docx",
    "TPL1_HABSS":         TPL_DIR / "TEMPLATE_HABSS.docx",
    "TPL2_LORMA":         TPL_DIR / "TEMPLATE_LORMA_ACCESS_PLUS.docx",
    "TPL3_LIGTASK_REF":   TPL_DIR / "Reference_LigTask_Manuscript.docx",
    "TPL4_PROGRESS":      TPL_DIR / "Template_ProgressReport_BSIT.docx",
    "FINAL":              FINAL,
}

# ── Helpers ───────────────────────────────────────────────────────────────────

def emu_to_inches(emu):
    if emu is None:
        return None
    return round(emu / 914400, 3)

def emu_to_pt(emu):
    if emu is None:
        return None
    return round(emu / 12700, 2)

def pt_val(pt_obj):
    """Return float pts from a Pt/None object."""
    if pt_obj is None:
        return None
    try:
        return round(pt_obj.pt, 2)
    except Exception:
        return None

def align_name(align):
    MAP = {
        WD_ALIGN_PARAGRAPH.LEFT:      "left",
        WD_ALIGN_PARAGRAPH.CENTER:    "center",
        WD_ALIGN_PARAGRAPH.RIGHT:     "right",
        WD_ALIGN_PARAGRAPH.JUSTIFY:   "justify",
    }
    return MAP.get(align, str(align))

def get_margins(doc):
    """Return margin dict (inches) from first section."""
    sec = doc.sections[0]
    return {
        "top":    emu_to_inches(sec.top_margin),
        "bottom": emu_to_inches(sec.bottom_margin),
        "left":   emu_to_inches(sec.left_margin),
        "right":  emu_to_inches(sec.right_margin),
        "header": emu_to_inches(sec.header_distance),
        "footer": emu_to_inches(sec.footer_distance),
        "paper_width_in":  emu_to_inches(sec.page_width),
        "paper_height_in": emu_to_inches(sec.page_height),
        "orientation": "landscape" if sec.page_width and sec.page_height and sec.page_width > sec.page_height else "portrait",
    }

def get_default_font(doc):
    """Try to read Normal style font details."""
    info = {}
    try:
        normal = doc.styles["Normal"]
        font = normal.font
        info["name"]  = font.name
        info["size_pt"] = pt_val(font.size)
        info["bold"]    = font.bold
        info["italic"]  = font.italic
    except Exception as e:
        info["error"] = str(e)
    return info

def get_normal_paragraph_format(doc):
    """Read paragraph format from Normal style."""
    info = {}
    try:
        normal = doc.styles["Normal"]
        pf = normal.paragraph_format
        info["alignment"]          = align_name(pf.alignment)
        info["first_line_indent_pt"] = emu_to_pt(pf.first_line_indent) if pf.first_line_indent else None
        info["left_indent_pt"]     = emu_to_pt(pf.left_indent) if pf.left_indent else None
        info["space_before_pt"]    = pt_val(pf.space_before)
        info["space_after_pt"]     = pt_val(pf.space_after)
        info["line_spacing_pt"]    = pt_val(pf.line_spacing)
        info["line_spacing_rule"]  = str(pf.line_spacing_rule)
    except Exception as e:
        info["error"] = str(e)
    return info

def get_heading_styles(doc):
    """Extract heading style info for H1, H2, H3."""
    result = {}
    for level in [1, 2, 3]:
        style_name = f"Heading {level}"
        info = {}
        try:
            st = doc.styles[style_name]
            font = st.font
            pf   = st.paragraph_format
            info["font_name"]   = font.name
            info["font_size_pt"]= pt_val(font.size)
            info["bold"]        = font.bold
            info["italic"]      = font.italic
            info["all_caps"]    = font.all_caps
            info["alignment"]   = align_name(pf.alignment)
            info["space_before_pt"] = pt_val(pf.space_before)
            info["space_after_pt"]  = pt_val(pf.space_after)
            info["first_line_indent_pt"] = emu_to_pt(pf.first_line_indent) if pf.first_line_indent else None
            info["left_indent_pt"]       = emu_to_pt(pf.left_indent) if pf.left_indent else None
        except Exception as e:
            info["error"] = str(e)
        result[style_name] = info
    return result

def get_header_footer(doc):
    """Check first section header/footer for content."""
    info = {}
    sec = doc.sections[0]
    # Header
    hdr = sec.header
    hdr_text = " | ".join(p.text.strip() for p in hdr.paragraphs if p.text.strip())
    info["header_text"] = hdr_text if hdr_text else "(empty)"
    info["header_linked_to_prev"] = sec.header.is_linked_to_previous
    # Footer
    ftr = sec.footer
    ftr_text = " | ".join(p.text.strip() for p in ftr.paragraphs if p.text.strip())
    info["footer_text"] = ftr_text if ftr_text else "(empty)"
    info["footer_linked_to_prev"] = sec.footer.is_linked_to_previous
    # Check if page number field exists in footer
    has_pgnum = False
    for p in ftr.paragraphs:
        for run in p.runs:
            xml = run._r.xml
            if 'fldChar' in xml or 'PAGE' in xml:
                has_pgnum = True
        if 'PAGE' in p._p.xml:
            has_pgnum = True
    info["footer_has_page_number_field"] = has_pgnum
    # Header page number check
    has_pgnum_hdr = False
    for p in hdr.paragraphs:
        if 'PAGE' in p._p.xml:
            has_pgnum_hdr = True
    info["header_has_page_number_field"] = has_pgnum_hdr
    return info

def scan_paragraphs(doc):
    """Scan paragraphs for key content patterns."""
    findings = {
        "chapter_headings": [],
        "figure_captions": [],
        "table_captions": [],
        "toc_entries": [],
        "abstract_paras": [],
        "references_paras": [],
        "appendix_headings": [],
        "title_page_paras": [],
        "sample_body_paras": [],
    }

    for idx, para in enumerate(doc.paragraphs):
        txt = para.text.strip()
        style = para.style.name if para.style else ""
        txt_up = txt.upper()
        font_size = None
        font_name = None
        bold = None
        try:
            if para.runs:
                run = para.runs[0]
                font_size = pt_val(run.font.size)
                font_name = run.font.name
                bold      = run.bold
        except Exception:
            pass

        entry = {
            "idx": idx,
            "style": style,
            "text_preview": txt[:120],
            "alignment": align_name(para.paragraph_format.alignment),
            "first_line_indent_pt": emu_to_pt(para.paragraph_format.first_line_indent) if para.paragraph_format.first_line_indent else None,
            "space_before_pt": pt_val(para.paragraph_format.space_before),
            "space_after_pt":  pt_val(para.paragraph_format.space_after),
            "line_spacing_pt": pt_val(para.paragraph_format.line_spacing),
            "font_size_pt": font_size,
            "font_name": font_name,
            "bold": bold,
        }

        # Chapter headings
        if ("CHAPTER" in txt_up and len(txt) < 60) or style.startswith("Heading"):
            findings["chapter_headings"].append(entry)

        # Figure captions
        if txt_up.startswith("FIGURE") or txt_up.startswith("FIG.") or "figure" in style.lower() or "caption" in style.lower():
            findings["figure_captions"].append(entry)

        # Table captions
        if txt_up.startswith("TABLE") and len(txt) < 300:
            findings["table_captions"].append(entry)

        # TOC entries
        if "toc" in style.lower() or "contents" in style.lower():
            findings["toc_entries"].append(entry)

        # Abstract
        if txt_up == "ABSTRACT" or ("abstract" in style.lower()):
            findings["abstract_paras"].append(entry)
        if idx < 60 and txt and not txt_up.startswith("CHAPTER"):
            findings["title_page_paras"].append(entry)

        # References
        if txt_up in ("REFERENCES", "BIBLIOGRAPHY", "REFERENCE LIST") or "reference" in style.lower():
            findings["references_paras"].append(entry)

        # Appendix
        if txt_up.startswith("APPENDIX"):
            findings["appendix_headings"].append(entry)

        # Sample body paragraphs (collect first 5 non-heading, non-empty)
        if (len(findings["sample_body_paras"]) < 5 and
                txt and len(txt) > 80 and
                "heading" not in style.lower() and
                "toc" not in style.lower()):
            findings["sample_body_paras"].append(entry)

    return findings

def audit_file(label, path):
    """Run all checks on a single file."""
    result = {"label": label, "path": str(path), "exists": path.exists()}
    if not path.exists():
        result["error"] = "FILE NOT FOUND"
        return result
    try:
        doc = Document(str(path))
        result["margins"]          = get_margins(doc)
        result["default_font"]     = get_default_font(doc)
        result["normal_para_fmt"]  = get_normal_paragraph_format(doc)
        result["heading_styles"]   = get_heading_styles(doc)
        result["header_footer"]    = get_header_footer(doc)
        result["paragraph_scan"]   = scan_paragraphs(doc)
        result["num_paragraphs"]   = len(doc.paragraphs)
        result["num_sections"]     = len(doc.sections)
        # Count multiple sections header/footer
        sections_info = []
        for i, sec in enumerate(doc.sections):
            si = {
                "section": i,
                "top": emu_to_inches(sec.top_margin),
                "bottom": emu_to_inches(sec.bottom_margin),
                "left": emu_to_inches(sec.left_margin),
                "right": emu_to_inches(sec.right_margin),
                "diff_first_page": sec.different_first_page_header_footer,
                "even_odd": sec.even_page_header.is_linked_to_previous if hasattr(sec, 'even_page_header') else None,
            }
            ftr = sec.footer
            ftr_pg = 'PAGE' in ftr._element.xml
            si["footer_has_page_field"] = ftr_pg
            hdr = sec.header
            hdr_pg = 'PAGE' in hdr._element.xml
            si["header_has_page_field"] = hdr_pg
            sections_info.append(si)
        result["all_sections"] = sections_info
    except Exception as e:
        result["error"] = str(e)
    return result

# ── Run audit ─────────────────────────────────────────────────────────────────
print("Running formatting audit...")
data = {}
for label, path in FILES.items():
    print(f"  Auditing {label} ...")
    data[label] = audit_file(label, path)

# Save raw JSON for reference
with open(OUT_DIR / "audit_raw.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, default=str)
print("  Raw JSON saved.")

# ── Report generation ─────────────────────────────────────────────────────────

def fmtval(val):
    if val is None:
        return "—"
    return str(val)

def compare(ref_val, final_val, tolerance=0.05):
    """Return MATCH / MISMATCH / UNKNOWN flag string."""
    if ref_val is None or final_val is None:
        return "UNKNOWN"
    try:
        rv = float(ref_val)
        fv = float(final_val)
        if abs(rv - fv) <= tolerance:
            return "✅ MATCH"
        return "❌ MISMATCH"
    except (TypeError, ValueError):
        if str(ref_val).lower() == str(final_val).lower():
            return "✅ MATCH"
        return "❌ MISMATCH"

def compare_str(ref_val, final_val):
    if ref_val is None and final_val is None:
        return "UNKNOWN"
    if ref_val is None or final_val is None:
        return "⚠️ MISSING"
    if str(ref_val).strip().lower() == str(final_val).strip().lower():
        return "✅ MATCH"
    return "❌ MISMATCH"

FINAL_DATA = data["FINAL"]

lines = []
lines.append("# FORMATTING AUDIT REPORT — Nov 10, 2026")
lines.append("")
lines.append("> **Scope:** Cross-examination of all reference manuscripts and templates against `1_MAIN_MANUSCRIPT_FINAL.docx`.")
lines.append("> **Method:** python-docx 1.2.0 — programmatic extraction of styles, section properties, paragraph scans.")
lines.append("> **Note:** Items marked `UNKNOWN` require visual inspection in Microsoft Word.")
lines.append("")
lines.append("---")
lines.append("")

# ── SECTION 0: File inventory ──────────────────────────────────────────────────
lines.append("## 0. File Inventory")
lines.append("")
lines.append("| ID | File | Status |")
lines.append("|---|---|---|")
for label, info in data.items():
    status = "✅ Found" if info.get("exists") else "❌ NOT FOUND"
    lines.append(f"| {label} | `{Path(info['path']).name}` | {status} |")
lines.append("")

# ── Helper: margin comparison table ───────────────────────────────────────────

def margin_table(ref_key, ref_label):
    rd = data.get(ref_key, {})
    fd = FINAL_DATA
    rmargin = rd.get("margins", {})
    fmargin = fd.get("margins", {})
    out = []
    out.append(f"### Page Setup — {ref_label} vs FINAL")
    out.append("")
    out.append("| Property | Reference | FINAL | Status |")
    out.append("|---|---|---|---|")
    fields = [
        ("top", "Top margin (in)"),
        ("bottom", "Bottom margin (in)"),
        ("left", "Left margin (in)"),
        ("right", "Right margin (in)"),
        ("header", "Header distance (in)"),
        ("footer", "Footer distance (in)"),
        ("paper_width_in", "Paper width (in)"),
        ("paper_height_in", "Paper height (in)"),
        ("orientation", "Orientation"),
    ]
    for key, label in fields:
        rv = rmargin.get(key)
        fv = fmargin.get(key)
        if key == "orientation":
            flag = compare_str(rv, fv)
        else:
            flag = compare(rv, fv, tolerance=0.06)
        out.append(f"| {label} | {fmtval(rv)} | {fmtval(fv)} | {flag} |")
    out.append("")
    return out

def font_table(ref_key, ref_label):
    rd = data.get(ref_key, {})
    fd = FINAL_DATA
    rfont = rd.get("default_font", {})
    ffont = fd.get("default_font", {})
    rpf   = rd.get("normal_para_fmt", {})
    fpf   = fd.get("normal_para_fmt", {})
    out = []
    out.append(f"### Body Text Font & Paragraph Format — {ref_label} vs FINAL")
    out.append("")
    out.append("| Property | Reference | FINAL | Status |")
    out.append("|---|---|---|---|")
    rows = [
        ("Font family",        rfont.get("name"),             ffont.get("name"),         "str"),
        ("Font size (pt)",     rfont.get("size_pt"),          ffont.get("size_pt"),       "num"),
        ("Bold default",       rfont.get("bold"),             ffont.get("bold"),          "str"),
        ("Alignment",          rpf.get("alignment"),          fpf.get("alignment"),       "str"),
        ("First-line indent (pt)", rpf.get("first_line_indent_pt"), fpf.get("first_line_indent_pt"), "num"),
        ("Left indent (pt)",   rpf.get("left_indent_pt"),     fpf.get("left_indent_pt"),  "num"),
        ("Space before (pt)",  rpf.get("space_before_pt"),    fpf.get("space_before_pt"), "num"),
        ("Space after (pt)",   rpf.get("space_after_pt"),     fpf.get("space_after_pt"),  "num"),
        ("Line spacing (pt)",  rpf.get("line_spacing_pt"),    fpf.get("line_spacing_pt"), "num"),
        ("Line spacing rule",  rpf.get("line_spacing_rule"),  fpf.get("line_spacing_rule"), "str"),
    ]
    for label, rv, fv, kind in rows:
        if kind == "num":
            flag = compare(rv, fv, tolerance=0.5)
        else:
            flag = compare_str(rv, fv)
        out.append(f"| {label} | {fmtval(rv)} | {fmtval(fv)} | {flag} |")
    out.append("")
    return out

def heading_table(ref_key, ref_label):
    rd = data.get(ref_key, {})
    fd = FINAL_DATA
    out = []
    out.append(f"### Heading Styles — {ref_label} vs FINAL")
    out.append("")
    for hn in ["Heading 1", "Heading 2", "Heading 3"]:
        rh = rd.get("heading_styles", {}).get(hn, {})
        fh = fd.get("heading_styles", {}).get(hn, {})
        out.append(f"**{hn}**")
        out.append("")
        out.append("| Property | Reference | FINAL | Status |")
        out.append("|---|---|---|---|")
        rows = [
            ("Font family",    rh.get("font_name"),    fh.get("font_name"),    "str"),
            ("Font size (pt)", rh.get("font_size_pt"), fh.get("font_size_pt"), "num"),
            ("Bold",           rh.get("bold"),         fh.get("bold"),         "str"),
            ("All caps",       rh.get("all_caps"),     fh.get("all_caps"),     "str"),
            ("Alignment",      rh.get("alignment"),    fh.get("alignment"),    "str"),
            ("Space before (pt)", rh.get("space_before_pt"), fh.get("space_before_pt"), "num"),
            ("Space after (pt)",  rh.get("space_after_pt"),  fh.get("space_after_pt"),  "num"),
        ]
        for label, rv, fv, kind in rows:
            flag = compare(rv, fv, 0.5) if kind == "num" else compare_str(rv, fv)
            out.append(f"| {label} | {fmtval(rv)} | {fmtval(fv)} | {flag} |")
        out.append("")
    return out

def header_footer_table(ref_key, ref_label):
    rd = data.get(ref_key, {})
    fd = FINAL_DATA
    rhf = rd.get("header_footer", {})
    fhf = fd.get("header_footer", {})
    out = []
    out.append(f"### Header / Footer & Page Numbers — {ref_label} vs FINAL")
    out.append("")
    out.append("| Property | Reference | FINAL | Status |")
    out.append("|---|---|---|---|")
    rows = [
        ("Header text",       rhf.get("header_text"),                   fhf.get("header_text"),                   "str"),
        ("Footer text",       rhf.get("footer_text"),                   fhf.get("footer_text"),                   "str"),
        ("Header has PAGE#",  rhf.get("header_has_page_number_field"),  fhf.get("header_has_page_number_field"),  "str"),
        ("Footer has PAGE#",  rhf.get("footer_has_page_number_field"),  fhf.get("footer_has_page_number_field"),  "str"),
    ]
    for label, rv, fv, kind in rows:
        flag = compare_str(rv, fv)
        out.append(f"| {label} | {fmtval(rv)} | {fmtval(fv)} | {flag} |")

    # Multi-section page number presence
    r_secs = rd.get("all_sections", [])
    f_secs = fd.get("all_sections", [])
    out.append(f"| # Sections | {len(r_secs)} | {len(f_secs)} | {'✅ MATCH' if len(r_secs)==len(f_secs) else '❌ MISMATCH'} |")
    r_pg = sum(1 for s in r_secs if s.get("footer_has_page_field") or s.get("header_has_page_field"))
    f_pg = sum(1 for s in f_secs if s.get("footer_has_page_field") or s.get("header_has_page_field"))
    out.append(f"| Sections with page# | {r_pg} | {f_pg} | {'✅ MATCH' if r_pg==f_pg else '❌ MISMATCH'} |")
    out.append("")
    return out

def para_scan_summary(key, label):
    d = data.get(key, {})
    scan = d.get("paragraph_scan", {})
    out = []
    out.append(f"### Paragraph Scan Highlights — {label}")
    out.append("")

    # Chapter headings
    ch = scan.get("chapter_headings", [])
    out.append(f"**Chapter / Heading paragraphs found:** {len(ch)}")
    if ch:
        out.append("")
        out.append("| Style | Text preview | Align | Font | Size | Bold |")
        out.append("|---|---|---|---|---|---|")
        for e in ch[:12]:
            out.append(f"| {e['style']} | {e['text_preview'][:60]} | {e['alignment']} | {fmtval(e['font_name'])} | {fmtval(e['font_size_pt'])} | {fmtval(e['bold'])} |")
    out.append("")

    # Figure captions
    fc = scan.get("figure_captions", [])
    out.append(f"**Figure captions found:** {len(fc)}")
    if fc:
        out.append("")
        out.append("| Style | Text preview | Align | Font | Size |")
        out.append("|---|---|---|---|---|")
        for e in fc[:8]:
            out.append(f"| {e['style']} | {e['text_preview'][:60]} | {e['alignment']} | {fmtval(e['font_name'])} | {fmtval(e['font_size_pt'])} |")
    out.append("")

    # Table captions
    tc = scan.get("table_captions", [])
    out.append(f"**Table captions found:** {len(tc)}")
    if tc:
        out.append("")
        out.append("| Style | Text preview | Align | Font | Size |")
        out.append("|---|---|---|---|---|")
        for e in tc[:8]:
            out.append(f"| {e['style']} | {e['text_preview'][:60]} | {e['alignment']} | {fmtval(e['font_name'])} | {fmtval(e['font_size_pt'])} |")
    out.append("")

    # Abstract
    ab = scan.get("abstract_paras", [])
    out.append(f"**Abstract label paragraph:** {len(ab)}")
    if ab:
        for e in ab[:3]:
            out.append(f"  - Style: `{e['style']}` | Align: {e['alignment']} | Bold: {e['bold']} | Text: `{e['text_preview'][:60]}`")
    out.append("")

    # References
    rf = scan.get("references_paras", [])
    out.append(f"**References section paragraph:** {len(rf)}")
    if rf:
        for e in rf[:3]:
            out.append(f"  - Style: `{e['style']}` | Indent: {fmtval(e['first_line_indent_pt'])} pt | Text: `{e['text_preview'][:60]}`")
    out.append("")

    # Appendix
    ap = scan.get("appendix_headings", [])
    out.append(f"**Appendix headings found:** {len(ap)}")
    if ap:
        for e in ap[:5]:
            out.append(f"  - Style: `{e['style']}` | Align: {e['alignment']} | Text: `{e['text_preview'][:60]}`")
    out.append("")

    # TOC
    toc = scan.get("toc_entries", [])
    out.append(f"**TOC entries found:** {len(toc)}")
    if toc:
        out.append("")
        out.append("| Style | Text preview | Indent (pt) |")
        out.append("|---|---|---|")
        for e in toc[:8]:
            out.append(f"| {e['style']} | {e['text_preview'][:50]} | {fmtval(e['first_line_indent_pt'])} |")
    out.append("")

    # Sample body
    sb = scan.get("sample_body_paras", [])
    out.append(f"**Sample body paragraphs (first 5):**")
    if sb:
        out.append("")
        out.append("| Align | First-line indent (pt) | Line spacing (pt) | Font | Size |")
        out.append("|---|---|---|---|---|")
        for e in sb:
            out.append(f"| {e['alignment']} | {fmtval(e['first_line_indent_pt'])} | {fmtval(e['line_spacing_pt'])} | {fmtval(e['font_name'])} | {fmtval(e['font_size_pt'])} |")
    out.append("")
    return out


# ── Build report per reference ────────────────────────────────────────────────

REFS = [
    ("REF1_CAPSTONE5",   "REF1 — CAPSTONE_5_team_revision_backup.docx"),
    ("REF2_LIGTASK",     "REF2 — LigTask_Manuscript_Reference.docx"),
    ("TPL1_HABSS",       "TPL1 — TEMPLATE_HABSS.docx"),
    ("TPL2_LORMA",       "TPL2 — TEMPLATE_LORMA_ACCESS_PLUS.docx"),
    ("TPL3_LIGTASK_REF", "TPL3 — Reference_LigTask_Manuscript.docx"),
    ("TPL4_PROGRESS",    "TPL4 — Template_ProgressReport_BSIT.docx"),
]

for ref_key, ref_label in REFS:
    if not data.get(ref_key, {}).get("exists"):
        lines.append(f"## {ref_label}")
        lines.append("")
        lines.append("> ❌ **FILE NOT FOUND — skipped.**")
        lines.append("")
        continue

    lines.append(f"## {ref_label}")
    lines.append("")
    lines += margin_table(ref_key, ref_label)
    lines += font_table(ref_key, ref_label)
    lines += heading_table(ref_key, ref_label)
    lines += header_footer_table(ref_key, ref_label)
    lines += para_scan_summary(ref_key, ref_label)
    lines.append("---")
    lines.append("")

# ── SECTION: FINAL manuscript detail ─────────────────────────────────────────
lines.append("## FINAL Manuscript — Self Detail")
lines.append("")
lines += para_scan_summary("FINAL", "1_MAIN_MANUSCRIPT_FINAL.docx")
lines.append("---")
lines.append("")

# ── SECTION: Consolidated Mismatch Summary ───────────────────────────────────
lines.append("## Consolidated Mismatch Summary (Actionable Items)")
lines.append("")
lines.append("Priority key: 🔴 HIGH (panel will likely notice) | 🟡 MEDIUM (academic standard) | 🟢 LOW (cosmetic)")
lines.append("")

# Collect mismatches programmatically
mismatches = []

FINAL_margins = FINAL_DATA.get("margins", {})
FINAL_font    = FINAL_DATA.get("default_font", {})
FINAL_pf      = FINAL_DATA.get("normal_para_fmt", {})
FINAL_hf      = FINAL_DATA.get("header_footer", {})
FINAL_hs      = FINAL_DATA.get("heading_styles", {})
FINAL_secs    = FINAL_DATA.get("all_sections", [])
FINAL_scan    = FINAL_DATA.get("paragraph_scan", {})

# --- Check margins across all references and find consensus ---
margin_consensus = {}
for mk in ["top", "bottom", "left", "right"]:
    vals = []
    for rk, _ in REFS:
        rd = data.get(rk, {})
        if rd.get("exists"):
            v = rd.get("margins", {}).get(mk)
            if v is not None:
                vals.append(v)
    if vals:
        from collections import Counter
        cnt = Counter([round(v, 1) for v in vals])
        most_common = cnt.most_common(1)[0][0]
        margin_consensus[mk] = most_common

for mk, consensus_val in margin_consensus.items():
    final_val = FINAL_margins.get(mk)
    if final_val is not None and abs(float(final_val) - float(consensus_val)) > 0.08:
        mismatches.append({
            "priority": "🔴 HIGH",
            "element": f"Margin — {mk}",
            "reference_consensus": f"{consensus_val} in",
            "final_value": f"{final_val} in",
            "action": f"Change {mk} margin to {consensus_val} inches in Page Setup",
        })

# --- Font checks ---
# Collect consensus font
font_names = []
font_sizes = []
for rk, _ in REFS:
    rd = data.get(rk, {})
    if rd.get("exists"):
        fn = rd.get("default_font", {}).get("name")
        fs = rd.get("default_font", {}).get("size_pt")
        if fn: font_names.append(fn)
        if fs: font_sizes.append(fs)

if font_names:
    from collections import Counter
    fn_cnt = Counter(font_names)
    consensus_font = fn_cnt.most_common(1)[0][0]
    final_font = FINAL_font.get("name")
    if final_font and str(final_font).lower() != str(consensus_font).lower():
        mismatches.append({
            "priority": "🔴 HIGH",
            "element": "Body text font family",
            "reference_consensus": consensus_font,
            "final_value": final_font,
            "action": f"Change body font to '{consensus_font}' (most common in references)",
        })

if font_sizes:
    fs_cnt = Counter([round(float(s), 0) for s in font_sizes if s])
    consensus_size = fs_cnt.most_common(1)[0][0] if fs_cnt else None
    final_size = FINAL_font.get("size_pt")
    if consensus_size and final_size and abs(float(final_size) - float(consensus_size)) > 0.5:
        mismatches.append({
            "priority": "🔴 HIGH",
            "element": "Body text font size",
            "reference_consensus": f"{consensus_size} pt",
            "final_value": f"{final_size} pt",
            "action": f"Change body font size to {consensus_size} pt",
        })

# --- Line spacing ---
ls_vals = []
for rk, _ in REFS:
    rd = data.get(rk, {})
    if rd.get("exists"):
        ls = rd.get("normal_para_fmt", {}).get("line_spacing_pt")
        if ls: ls_vals.append(ls)

if ls_vals:
    ls_cnt = Counter([round(float(v), 0) for v in ls_vals])
    consensus_ls = ls_cnt.most_common(1)[0][0]
    final_ls = FINAL_pf.get("line_spacing_pt")
    if final_ls and abs(float(final_ls) - float(consensus_ls)) > 1.0:
        mismatches.append({
            "priority": "🟡 MEDIUM",
            "element": "Normal style line spacing",
            "reference_consensus": f"{consensus_ls} pt",
            "final_value": f"{final_ls} pt",
            "action": f"Set Normal paragraph line spacing to {consensus_ls} pt (double spacing = 24 pt typically)",
        })

# --- Page numbers ---
f_pg_count = sum(1 for s in FINAL_secs if s.get("footer_has_page_field") or s.get("header_has_page_field"))
if f_pg_count == 0:
    mismatches.append({
        "priority": "🔴 HIGH",
        "element": "Page numbers",
        "reference_consensus": "Present in all references",
        "final_value": "NOT DETECTED in any section",
        "action": "Insert page numbers (Insert > Page Number). Verify manually — python-docx may miss complex field codes.",
    })

# --- Heading 1 checks ---
for rk, rl in REFS:
    rd = data.get(rk, {})
    if not rd.get("exists"):
        continue
    rh1 = rd.get("heading_styles", {}).get("Heading 1", {})
    fh1 = FINAL_hs.get("Heading 1", {})
    if rh1.get("font_size_pt") and fh1.get("font_size_pt"):
        if abs(float(rh1["font_size_pt"]) - float(fh1["font_size_pt"])) > 1.0:
            mismatches.append({
                "priority": "🟡 MEDIUM",
                "element": f"Heading 1 font size (vs {rl[:30]})",
                "reference_consensus": f"{rh1['font_size_pt']} pt",
                "final_value": f"{fh1['font_size_pt']} pt",
                "action": "Review Heading 1 style font size in Styles pane",
            })
            break  # only flag once

# --- Figure captions ---
ref_fig = []
for rk, _ in REFS:
    rd = data.get(rk, {})
    if rd.get("exists"):
        fc = rd.get("paragraph_scan", {}).get("figure_captions", [])
        ref_fig.extend(fc[:3])
final_fig = FINAL_scan.get("figure_captions", [])
if ref_fig and not final_fig:
    mismatches.append({
        "priority": "🔴 HIGH",
        "element": "Figure captions",
        "reference_consensus": "Present with 'Figure X.X.' label format",
        "final_value": "NONE DETECTED with figure/caption style",
        "action": "Apply 'Caption' style to all figure label lines. Verify figure label format 'Figure 1.1.'",
    })

# --- Table captions ---
ref_tbl = []
for rk, _ in REFS:
    rd = data.get(rk, {})
    if rd.get("exists"):
        tc = rd.get("paragraph_scan", {}).get("table_captions", [])
        ref_tbl.extend(tc[:3])
final_tbl = FINAL_scan.get("table_captions", [])
if ref_tbl and not final_tbl:
    mismatches.append({
        "priority": "🟡 MEDIUM",
        "element": "Table captions",
        "reference_consensus": "Present with 'Table X.' label format",
        "final_value": "NONE DETECTED with table caption style",
        "action": "Ensure table caption paragraphs use 'Caption' or dedicated table caption style",
    })

# --- Abstract ---
ref_ab = []
for rk, _ in REFS:
    rd = data.get(rk, {})
    if rd.get("exists"):
        ab = rd.get("paragraph_scan", {}).get("abstract_paras", [])
        ref_ab.extend(ab[:2])
final_ab = FINAL_scan.get("abstract_paras", [])
if ref_ab and not final_ab:
    mismatches.append({
        "priority": "🟡 MEDIUM",
        "element": "Abstract label paragraph",
        "reference_consensus": "ABSTRACT heading present (centered, bold)",
        "final_value": "NOT DETECTED via style scan",
        "action": "Ensure 'ABSTRACT' paragraph uses a Heading or dedicated Abstract style",
    })

# --- Appendix ---
ref_ap = []
for rk, _ in REFS:
    rd = data.get(rk, {})
    if rd.get("exists"):
        ap = rd.get("paragraph_scan", {}).get("appendix_headings", [])
        ref_ap.extend(ap[:2])
final_ap = FINAL_scan.get("appendix_headings", [])
if ref_ap and not final_ap:
    mismatches.append({
        "priority": "🟡 MEDIUM",
        "element": "Appendix headings",
        "reference_consensus": "APPENDIX X — present as heading",
        "final_value": "NOT DETECTED",
        "action": "Ensure appendix heading paragraphs start with 'APPENDIX' and use Heading style",
    })
elif final_ap:
    # Check alignment
    for e in final_ap:
        if e.get("alignment") not in ("center", "None"):
            mismatches.append({
                "priority": "🟢 LOW",
                "element": "Appendix heading alignment",
                "reference_consensus": "center",
                "final_value": e.get("alignment"),
                "action": "Center-align appendix heading paragraphs",
            })
            break

# --- TOC ---
final_toc = FINAL_scan.get("toc_entries", [])
ref_toc_count = sum(len(data.get(rk, {}).get("paragraph_scan", {}).get("toc_entries", [])) for rk, _ in REFS if data.get(rk, {}).get("exists"))
if ref_toc_count > 0 and len(final_toc) == 0:
    mismatches.append({
        "priority": "🟡 MEDIUM",
        "element": "Table of Contents entries",
        "reference_consensus": "TOC style entries present",
        "final_value": "NOT DETECTED via TOC style scan",
        "action": "Verify TOC entries use built-in 'TOC 1' / 'TOC 2' styles; may need manual inspection",
    })

# Write mismatch table
if mismatches:
    lines.append("| Priority | Element | Reference Standard | FINAL Value | Recommended Action |")
    lines.append("|---|---|---|---|---|")
    for m in mismatches:
        lines.append(f"| {m['priority']} | {m['element']} | {m['reference_consensus']} | {m['final_value']} | {m['action']} |")
else:
    lines.append("> No programmatic mismatches detected. Proceed to manual visual inspection list below.")
lines.append("")

# ── SECTION: Manual Inspection Checklist ──────────────────────────────────────
lines.append("## Manual Inspection Checklist (UNKNOWN items — require Word)")
lines.append("")
lines.append("The following cannot be reliably extracted via python-docx and must be checked visually in Microsoft Word:")
lines.append("")
lines.append("| # | Item | What to look for |")
lines.append("|---|---|---|")
manual_items = [
    ("1", "Title page layout", "School name, program, title, authors, date — positioning and spacing"),
    ("2", "Chapter heading format", "Is 'CHAPTER I' on a separate line from 'INTRODUCTION'? Both centered?"),
    ("3", "TOC dot leaders", "Do dot leaders (...) appear between entry text and page number?"),
    ("4", "TOC page number alignment", "Are page numbers right-aligned in TOC?"),
    ("5", "List of Figures / Tables", "Does LoF/LoT exist? Column layout, header row, indent style"),
    ("6", "Abstract indent", "Is abstract body paragraph indented (first-line or block)?"),
    ("7", "Figure caption position", "Is caption BELOW each figure? Above for tables?"),
    ("8", "Figure caption format", "Label reads 'Figure 1.1.' (period after number) vs 'Fig. 1.1'?"),
    ("9", "Table caption format", "Label reads 'Table 1.' or 'Table 1.1.'?"),
    ("10", "Reference hanging indent", "APA hanging indent (second line indented ~0.5 in)?"),
    ("11", "Reference spacing", "Single or double space between reference entries?"),
    ("12", "Page number position", "Bottom center, top right, or top center?"),
    ("13", "Roman numerals for front matter", "Pages before Chapter 1 (title, TOC, abstract) — roman numerals?"),
    ("14", "Section breaks before chapters", "Page break or section break before each Chapter heading?"),
    ("15", "Appendix page breaks", "Does each appendix start on a new page?"),
    ("16", "Running header content", "What text (if any) appears in the header of body pages?"),
    ("17", "Bold / italic consistency in headings", "H2 bold? H3 italic? Matches reference?"),
    ("18", "Numbering in headings", "Are headings numbered (1.1, 1.2) or un-numbered?"),
    ("19", "Signature/approval page", "Is there an adviser signature page? Format matches reference?"),
    ("20", "Acknowledgement page", "Present? Centered heading? Justified body?"),
]
for num, item, check in manual_items:
    lines.append(f"| {num} | {item} | {check} |")
lines.append("")

# ── SECTION: Section-by-section margin map ───────────────────────────────────
lines.append("## Section-by-Section Margin Map (FINAL Manuscript)")
lines.append("")
lines.append("| Section # | Top (in) | Bottom (in) | Left (in) | Right (in) | Diff 1st Page | Footer PAGE# |")
lines.append("|---|---|---|---|---|---|---|")
for s in FINAL_secs:
    lines.append(f"| {s['section']} | {fmtval(s.get('top'))} | {fmtval(s.get('bottom'))} | {fmtval(s.get('left'))} | {fmtval(s.get('right'))} | {fmtval(s.get('diff_first_page'))} | {fmtval(s.get('footer_has_page_field'))} |")
lines.append("")

# ── SECTION: All reference section margins ───────────────────────────────────
lines.append("## All-Reference Section Margins (for manual comparison)")
lines.append("")
for rk, rl in REFS:
    rd = data.get(rk, {})
    if not rd.get("exists"):
        continue
    secs = rd.get("all_sections", [])
    lines.append(f"**{rl}** ({len(secs)} section(s))")
    lines.append("")
    lines.append("| Sec# | Top | Bottom | Left | Right | Footer PAGE# |")
    lines.append("|---|---|---|---|---|---|")
    for s in secs:
        lines.append(f"| {s['section']} | {fmtval(s.get('top'))} | {fmtval(s.get('bottom'))} | {fmtval(s.get('left'))} | {fmtval(s.get('right'))} | {fmtval(s.get('footer_has_page_field'))} |")
    lines.append("")

# ── FOOTER ────────────────────────────────────────────────────────────────────
lines.append("---")
lines.append("")
lines.append("*Report generated by `run_format_audit.py` using python-docx 1.2.0.*")
lines.append(f"*Files audited: {sum(1 for d in data.values() if d.get('exists'))} of {len(data)} found.*")
lines.append("")

# Write report
report_text = "\n".join(lines)
with open(OUT_FILE, "w", encoding="utf-8") as f:
    f.write(report_text)

print(f"\nReport written to: {OUT_FILE}")
print(f"Total mismatches flagged: {len(mismatches)}")
