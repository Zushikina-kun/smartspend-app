"""
structure_audit.py
Full structural scan of SMARTSPEND_UPDATED_MANUSCRIPT.docx
Maps every element in order: page breaks, sections, paragraphs, tables, images
to find placement issues, wrong content in wrong sections, etc.
"""
from docx import Document
from docx.oxml.ns import qn
import os

NS   = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
BASE = os.path.dirname(__file__)
DOC  = os.path.join(BASE, "SMARTSPEND_UPDATED_MANUSCRIPT.docx")

doc  = Document(DOC)
body = doc.element.body

def get_text(el):
    return "".join(t.text or "" for t in el.findall(".//{%s}t" % NS)).strip()

def has_page_break(el):
    for br in el.findall(".//{%s}br" % NS):
        if br.get(qn("w:type")) == "page":
            return True
    return False

# ── Walk every body element in order ──────────────────────────────────────────
print("=== FULL STRUCTURAL MAP ===")
print(f"{'IDX':>4}  {'TYPE':6}  {'PB':2}  CONTENT")
print("-" * 100)

page    = 1
section = "FRONT"
img_count = 0
tbl_count = 0

all_issues = []

for i, child in enumerate(body):
    tag = child.tag.split("}")[-1] if "}" in child.tag else child.tag
    text = get_text(child)
    pb   = has_page_break(child)

    if pb:
        page += 1

    if tag == "p":
        t = text[:70]
        # Detect section changes
        tu = text.upper().strip()
        if tu in ("APPROVAL SHEET", "CAPSTONE PROJECT ABSTRACT", "ABSTRACT",
                  "ACKNOWLEDGEMENT", "DEDICATION", "TABLE OF CONTENTS",
                  "LIST OF FIGURES", "LIST OF TABLES"):
            section = tu
        elif tu.startswith("CHAPTER I") and len(text) < 20:
            section = "CHAPTER I"
        elif tu.startswith("CHAPTER II") and len(text) < 20:
            section = "CHAPTER II"
        elif tu.startswith("CHAPTER III") and len(text) < 20:
            section = "CHAPTER III"
        elif tu.startswith("CHAPTER IV") and len(text) < 20:
            section = "CHAPTER IV"
        elif tu == "REFERENCES":
            section = "REFERENCES"
        elif tu.startswith("APPENDIX A") and len(text) < 30:
            section = "APPENDIX A"
        elif tu.startswith("APPENDIX B") and len(text) < 30:
            section = "APPENDIX B"
        elif tu.startswith("APPENDIX C") and len(text) < 30:
            section = "APPENDIX C"
        elif tu == "APPENDICES":
            section = "APPENDICES"
        elif "CURRICULUM VITAE" in tu and len(text) < 25:
            section = "CV"

        pb_mark = "PB" if pb else "  "
        print(f"{i:>4}  para   {pb_mark}  [{section:20}]  {t}")

        # Flag issues
        if section == "TABLE OF CONTENTS" and (
            "Feature" in text or "Tarsi" in text or
            "YNAB" in text or "LLM" in text or
            "Gap Level" in text
        ):
            all_issues.append(f"  ❌ TABLE CONTENT IN TOC at idx {i}: '{text[:60]}'")

        if section in ("TABLE OF CONTENTS", "LIST OF FIGURES", "LIST OF TABLES"):
            # Check for real chapter content that shouldn't be here
            if len(text) > 100 and not any(x in text for x in ["\t", "..."]):
                all_issues.append(f"  ❌ LONG TEXT IN TOC SECTION at idx {i}: '{text[:60]}'")

    elif tag == "tbl":
        tbl_count += 1
        rows  = child.findall(".//{%s}tr" % NS)
        cells = child.findall(".//{%s}tc" % NS)
        hdr   = get_text(rows[0]) if rows else ""
        print(f"{i:>4}  TABLE  {'PB' if pb else '  '}  [{section:20}]  T{tbl_count}: {len(rows)}rows  hdr='{hdr[:50]}'")

        # Flag tables in wrong sections
        if section in ("TABLE OF CONTENTS", "LIST OF FIGURES", "LIST OF TABLES",
                       "FRONT", "APPROVAL SHEET", "ABSTRACT", "ACKNOWLEDGEMENT",
                       "DEDICATION", "REFERENCES"):
            all_issues.append(f"  ❌ TABLE IN WRONG SECTION '{section}' at idx {i}: hdr='{hdr[:40]}'")

    elif tag == "sdt":  # structured document tag (sometimes wraps content)
        txt = get_text(child)
        print(f"{i:>4}  SDT    {'PB' if pb else '  '}  [{section:20}]  '{txt[:60]}'")

# ── Image placement audit ──────────────────────────────────────────────────────
print("\n=== IMAGE PLACEMENT ===")
from docx.oxml.ns import qn as _qn
img_section = "FRONT"
img_idx     = 0
for i, child in enumerate(body):
    tag  = child.tag.split("}")[-1] if "}" in child.tag else child.tag
    text = get_text(child)
    tu   = text.upper().strip()

    # Track section
    for marker, name in [
        ("CHAPTER I", "CHAPTER I"), ("CHAPTER II", "CHAPTER II"),
        ("CHAPTER III", "CHAPTER III"), ("CHAPTER IV", "CHAPTER IV"),
        ("CURRICULUM VITAE", "CV"), ("REFERENCES", "REFERENCES"),
        ("ACKNOWLEDGEMENT", "ACKNOWLEDGEMENT"),
    ]:
        if marker in tu and len(text) < 25:
            img_section = name

    if tag == "p":
        drawings = child.findall(".//{%s}drawing" % NS)
        if drawings:
            img_idx += 1
            # Get image dimensions
            extent = child.find(".//{http://schemas.openxmlformats.org/drawingml/2006/main}../..//{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}extent")
            # Try simpler approach
            extents = child.findall(".//{http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing}extent")
            dims = ""
            if extents:
                cx = int(extents[0].get("cx", 0))
                cy = int(extents[0].get("cy", 0))
                dims = f"{cx/914400:.2f}\" x {cy/914400:.2f}\""
            # Caption context: check next paragraph for caption
            print(f"  IMG{img_idx}: [{img_section}] idx={i}  size={dims}")
            if img_section not in ("CHAPTER I", "CHAPTER II", "CHAPTER III", "CHAPTER IV",
                                   "CV", "ACKNOWLEDGEMENT", "FRONT"):
                all_issues.append(f"  ⚠️  Image in unexpected section: {img_section} at idx {i}")

# ── Summary of issues ─────────────────────────────────────────────────────────
print("\n=== ISSUES FOUND ===")
if all_issues:
    for iss in all_issues:
        print(iss)
else:
    print("  No structural issues found.")

# ── Section order check ────────────────────────────────────────────────────────
print("\n=== SECTION ORDER CHECK ===")
EXPECTED_ORDER = [
    "FRONT",           # title page
    "APPROVAL SHEET",
    "CAPSTONE PROJECT ABSTRACT",
    "ACKNOWLEDGEMENT",
    "DEDICATION",
    "TABLE OF CONTENTS",
    "LIST OF FIGURES",
    "LIST OF TABLES",
    "CHAPTER I",
    "CHAPTER II",
    "CHAPTER III",
    "CHAPTER IV",
    "REFERENCES",
    "APPENDIX A",
    "APPENDIX B",
    "APPENDICES",
    "CV",
]

seen_sections = []
current = "FRONT"
for child in body:
    text = get_text(child).upper().strip()
    for marker, name in [
        ("APPROVAL SHEET", "APPROVAL SHEET"),
        ("CAPSTONE PROJECT ABSTRACT", "CAPSTONE PROJECT ABSTRACT"),
        ("ACKNOWLEDGEMENT", "ACKNOWLEDGEMENT"),
        ("DEDICATION", "DEDICATION"),
        ("TABLE OF CONTENTS", "TABLE OF CONTENTS"),
        ("LIST OF FIGURES", "LIST OF FIGURES"),
        ("LIST OF TABLES", "LIST OF TABLES"),
        ("CHAPTER III", "CHAPTER III"), ("CHAPTER IV", "CHAPTER IV"),
        ("CHAPTER II", "CHAPTER II"),  ("CHAPTER I", "CHAPTER I"),
        ("REFERENCES", "REFERENCES"),
        ("APPENDIX A", "APPENDIX A"), ("APPENDIX B", "APPENDIX B"),
        ("APPENDICES", "APPENDICES"),
        ("CURRICULUM VITAE", "CV"),
    ]:
        if marker in text and len(text) < 30 and name not in seen_sections:
            seen_sections.append(name)
            break

exp_clean = [s for s in EXPECTED_ORDER if s != "FRONT"]
for i, s in enumerate(seen_sections):
    exp = exp_clean[i] if i < len(exp_clean) else "?"
    ok  = "✅" if s == exp else "❌"
    print(f"  {ok} [{i+1:2d}] Got: {s:30}  Expected: {exp}")

# Extra sections not expected
for s in seen_sections:
    if s not in EXPECTED_ORDER:
        print(f"  ⚠️  Unexpected section: {s}")
