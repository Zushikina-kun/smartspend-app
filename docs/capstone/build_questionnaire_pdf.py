"""
build_questionnaire_pdf.py
Extract the 30 survey questions from the FINAL .docx (python-docx) and render
a clean, printable questionnaire PDF for Ma'am Ellen to review and sign.

Method (reused from docs/capstone/build_summary_pdf.py):
  1. Read the .docx with python-docx; pull section headers/descriptions from the
     body paragraphs and the 30 questions + response options from the tables.
  2. Build styled HTML (cover page -> 5 sections -> validator signature block).
  3. Render HTML -> PDF with a headless Chromium-based browser (Microsoft Edge)
     via --print-to-pdf.
  4. Verify the result with pypdf (page count + text-layer sanity check).

Run:  python docs/capstone/build_questionnaire_pdf.py
Out:  docs/capstone/SmartSpend_Survey_Questionnaire_FOR_VALIDATION.pdf
"""
import datetime as _dt
import html
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import docx
import pypdf

HERE = Path(__file__).resolve().parent
SRC_DOCX = HERE.parent / "handsoff" / "new-SmartSpend_Selected_Survey_Questions_FINAL-1.docx"
OUT_PDF = HERE / "SmartSpend_Survey_Questionnaire_FOR_VALIDATION.pdf"

# Chromium binary used for headless PDF rendering (Edge is Chromium-based).
EDGE_BIN = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# Q-range subtitle per section (matches the manuscript's summary table).
SECTION_RANGE = {
    "A": "Q1\u2013Q7",
    "B": "Q8\u2013Q13",
    "C": "Q14\u2013Q20",
    "D": "Q21\u2013Q26",
    "E": "Q27\u2013Q30",
}

CSS = """
@page { size: Letter; margin: 18mm 18mm 20mm 18mm; }
* { box-sizing: border-box; }
html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body {
  font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
  font-size: 10.5pt; line-height: 1.5; color: #222; margin: 0;
}

/* ---------- Cover page ---------- */
.cover {
  page-break-after: always;
  min-height: 240mm;
  display: flex; flex-direction: column; justify-content: center;
  align-items: center; text-align: center;
}
.cover .brand {
  font-size: 12pt; letter-spacing: 3px; text-transform: uppercase;
  color: #008F6A; font-weight: 700; margin-bottom: 26px;
}
.cover h1 {
  font-size: 27pt; color: #5C0E24; line-height: 1.2;
  margin: 0 0 6px 0; font-weight: 700;
}
.cover .subtitle {
  font-size: 15pt; color: #333; font-style: italic; margin: 0 0 30px 0;
}
.cover .rule { width: 60mm; border-top: 2px solid #5C0E24; margin: 6px auto 26px auto; }
.cover .tagline { font-size: 11.5pt; color: #333; margin: 0 0 6px 0; max-width: 150mm; }
.cover .inst { font-size: 11pt; color: #555; margin: 0 0 34px 0; }
.cover .note {
  font-size: 10pt; color: #666; max-width: 140mm; line-height: 1.55;
  border: 1px solid #ddd; background: #FAF7F8; padding: 12px 16px; border-radius: 6px;
}
.cover .meta { margin-top: 22px; font-size: 9.5pt; color: #888; }

/* ---------- Section headers ---------- */
h2.section-title {
  font-size: 13.5pt; color: #5C0E24; margin: 20px 0 2px 0;
  border-bottom: 2px solid #5C0E24; padding-bottom: 4px;
}
.section-sub { font-size: 9.5pt; color: #555; font-style: italic; margin: 0 0 2px 0; }
.section-desc { font-size: 9.5pt; color: #444; margin: 0 0 4px 0; }
.scale-note {
  font-size: 9.5pt; color: #333; background: #F2E6EA; border-left: 3px solid #5C0E24;
  padding: 5px 9px; margin: 8px 0; border-radius: 2px;
}

/* ---------- Questions ---------- */
.q { margin: 0 0 11px 0; page-break-inside: avoid; }
.q .qhead { font-size: 10.5pt; margin: 0 0 3px 0; }
.q .qnum { font-weight: 700; color: #5C0E24; }
.q .qtext { color: #1a1a1a; }
ul.opts { list-style: none; margin: 2px 0 0 0; padding-left: 20px; }
ul.opts li { margin: 1.5px 0; font-size: 10pt; }
ul.opts li .box { color: #5C0E24; margin-right: 6px; }

/* ---------- Validator certification page ---------- */
.cert { page-break-before: always; }
.cert h2 {
  font-size: 15pt; color: #5C0E24; text-align: center;
  letter-spacing: 1px; margin: 6px 0 22px 0;
}
.cert .statement {
  font-size: 11pt; line-height: 1.7; text-align: justify;
  margin: 0 0 30px 0;
}
.sig-row { display: flex; align-items: flex-end; margin: 22px 0; }
.sig-row .lbl { font-weight: 600; white-space: nowrap; font-size: 10.5pt; }
.sig-row .line { flex: 1; border-bottom: 1px solid #333; margin-left: 10px; min-height: 1.15em; }
.sig-row .lbl2 { font-weight: 600; white-space: nowrap; font-size: 10.5pt; margin-left: 22px; }
"""


# --------------------------------------------------------------------------- #
# 1. Extract content from the .docx
# --------------------------------------------------------------------------- #
def extract_sections(doc):
    """Return ordered list of dicts: {letter, title, desc:[...], questions:[...]}."""
    sections = []
    cur = None
    summary_re = re.compile(r"^\d+\.\s")
    for p in doc.paragraphs:
        t = p.text.strip()
        if t.startswith("SECTION "):
            cur = {"title": t, "desc": [], "questions": []}
            sections.append(cur)
        elif cur is not None:
            if summary_re.match(t):
                break  # "5. Final Questionnaire Summary ..." — stop
            if t:
                cur["desc"].append(t)

    # Attach the letter (A..E) and a Q-range subtitle.
    for i, s in enumerate(sections):
        m = re.match(r"SECTION\s+([A-Z])\.", s["title"])
        letter = m.group(1) if m else chr(ord("A") + i)
        s["letter"] = letter
        s["range"] = SECTION_RANGE.get(letter, "")

    # The first five tables hold the questions (table 5 is the summary).
    q_tables = [t for t in doc.tables if len(t.columns) >= 3][:5]
    if len(q_tables) != 5:
        raise RuntimeError(f"Expected 5 question tables, found {len(q_tables)}.")
    for s, tbl in zip(sections, q_tables):
        for row in tbl.rows[1:]:  # skip header row
            cells = [c.text.strip() for c in row.cells]
            if not cells or not cells[0]:
                continue
            s["questions"].append({"num": cells[0], "text": cells[2]})
    return sections


def parse_question(text):
    """Split a 'question + response options' cell into (question, [options])."""
    lines = text.split("\n")
    qtext = lines[0].strip()
    options = []
    for ln in lines[1:]:
        s = ln.strip()
        if not s:
            continue
        if s.startswith("\u2610"):  # ☐ checkbox option
            options.append(s[1:].strip())
        elif "\u00b7" in s and re.search(r"\d\s*=", s):  # inline Likert scale
            for part in s.split("\u00b7"):
                p = part.strip()
                if p:
                    options.append(p)
        else:
            options.append(s)
    return qtext, options


# --------------------------------------------------------------------------- #
# 2. Build the HTML
# --------------------------------------------------------------------------- #
def esc(s):
    return html.escape(s, quote=False)


def build_html(sections):
    today = _dt.date.today().strftime("%B %d, %Y")
    total = sum(len(s["questions"]) for s in sections)

    parts = [
        "<!DOCTYPE html><html lang='en'><head><meta charset='utf-8'>",
        f"<style>{CSS}</style></head><body>",
    ]

    # ---- Cover page ----
    parts.append(
        "<div class='cover'>"
        "<div class='brand'>SmartSpend</div>"
        "<h1>SmartSpend Survey Questionnaire</h1>"
        "<div class='subtitle'>For Content Validation</div>"
        "<div class='rule'></div>"
        "<div class='tagline'>SmartSpend: An AI-Assisted Mobile Financial Tracking "
        "and Advisory Application</div>"
        "<div class='inst'>Lorma Colleges \u2014 College of Computer Studies and Engineering</div>"
        "<div class='note'>This questionnaire contains " + str(total) + " items across five "
        "sections. It is submitted to the adviser for content validation and signature "
        "prior to administration to the target respondents (parents and young "
        "professionals in San Fernando City, La Union).</div>"
        f"<div class='meta'>Prepared for adviser validation &middot; {esc(today)}</div>"
        "</div>"
    )

    # ---- Sections + questions ----
    for s in sections:
        title = s["title"]
        # Convert "SECTION A. Respondent Profile" -> "Section A — Respondent Profile"
        disp = re.sub(r"^SECTION\s+([A-Z])\.\s*", "Section \\1 \u2014 ", title)
        parts.append(f"<h2 class='section-title'>{esc(disp)} <span style='font-size:10.5pt;font-weight:600;color:#555;'>({esc(s['range'])})</span></h2>")
        for d in s["desc"]:
            if d.startswith("For Questions"):
                parts.append(f"<div class='scale-note'>{esc(d)}</div>")
            elif d.startswith("Objective") or "theme" in d:
                parts.append(f"<div class='section-sub'>{esc(d)}</div>")
            else:
                parts.append(f"<div class='section-desc'>{esc(d)}</div>")

        for q in s["questions"]:
            qtext, options = parse_question(q["text"])
            parts.append("<div class='q'>")
            parts.append(
                f"<div class='qhead'><span class='qnum'>Q{esc(q['num'])}.</span> "
                f"<span class='qtext'>{esc(qtext)}</span></div>"
            )
            if options:
                parts.append("<ul class='opts'>")
                for o in options:
                    parts.append(
                        f"<li><span class='box'>\u2610</span>{esc(o)}</li>"
                    )
                parts.append("</ul>")
            parts.append("</div>")

    # ---- Validator certification + signature block ----
    parts.append(
        "<div class='cert'>"
        "<h2>CONTENT VALIDATOR CERTIFICATION</h2>"
        "<p class='statement'>I hereby certify that I have reviewed the survey "
        "questionnaire and confirm that the questions are appropriate, valid, and "
        "suitable for administration to the target respondents.</p>"
        "<div class='sig-row'><span class='lbl'>Validator's Name:</span>"
        "<span class='line'></span></div>"
        "<div class='sig-row'><span class='lbl'>Designation/Position:</span>"
        "<span class='line'></span></div>"
        "<div class='sig-row'><span class='lbl'>Institution:</span>"
        "<span class='line'></span></div>"
        "<div class='sig-row'><span class='lbl'>Signature:</span>"
        "<span class='line' style='flex:2'></span>"
        "<span class='lbl2'>Date:</span>"
        "<span class='line' style='flex:1'></span></div>"
        "</div>"
    )

    parts.append("</body></html>")
    return "\n".join(parts), total


# --------------------------------------------------------------------------- #
# 3. Render HTML -> PDF with headless Chromium (Edge)
# --------------------------------------------------------------------------- #
def render_pdf(html_path, pdf_path):
    url = "file:///" + str(html_path).replace("\\", "/")
    cmd = [
        EDGE_BIN,
        "--headless=new",
        "--disable-gpu",
        "--no-pdf-header-footer",
        f"--print-to-pdf={pdf_path}",
        url,
    ]
    subprocess.run(cmd, check=True, capture_output=True)


# --------------------------------------------------------------------------- #
# 4. Verify
# --------------------------------------------------------------------------- #
def verify(pdf_path, total):
    reader = pypdf.PdfReader(str(pdf_path))
    pages = len(reader.pages)
    text = "\n".join(p.extract_text() for p in reader.pages)
    print(f"  PDF pages: {pages}")
    ok = True
    for needle in [
        "SmartSpend Survey Questionnaire",
        "For Content Validation",
        "CONTENT VALIDATOR CERTIFICATION",
        "appropriate, valid, and suitable",
        "Validator's Name",
        "Signature:",
    ]:
        if needle not in text:
            print(f"  WARNING: expected text not found in PDF: {needle!r}")
            ok = False
    # Count question markers Q1. .. Q{total}.
    found = sum(1 for n in range(1, total + 1) if f"Q{n}." in text)
    print(f"  Question markers found in text layer: {found}/{total}")
    if found != total:
        print("  WARNING: not all question markers were found in the text layer.")
    return ok and found == total and pages >= 2


# --------------------------------------------------------------------------- #
def main():
    if not SRC_DOCX.exists():
        print(f"ERROR: source docx not found: {SRC_DOCX}", file=sys.stderr)
        return 1
    if not Path(EDGE_BIN).exists():
        print(f"ERROR: headless Chromium binary not found: {EDGE_BIN}", file=sys.stderr)
        return 1

    print(f"  Reading: {SRC_DOCX.name}")
    doc = docx.Document(str(SRC_DOCX))
    sections = extract_sections(doc)
    total = sum(len(s["questions"]) for s in sections)
    nums = sorted(int(q["num"]) for s in sections for q in s["questions"])
    print(f"  Extracted {total} questions: "
          f"{sections[0]['questions'][0]['num']}..{sections[-1]['questions'][-1]['num']}")
    if total != 30 or nums != list(range(1, 31)):
        print(f"  ERROR: expected 30 questions (1..30), got {total}: {nums}",
              file=sys.stderr)
        return 1

    html_text, _ = build_html(sections)
    with tempfile.TemporaryDirectory() as tmp:
        html_path = Path(tmp) / "questionnaire.html"
        html_path.write_text(html_text, encoding="utf-8")
        if OUT_PDF.exists():
            OUT_PDF.unlink()
        render_pdf(html_path, OUT_PDF)

    size = OUT_PDF.stat().st_size
    print(f"  PDF written: {OUT_PDF}  ({size:,} bytes, {size // 1024} KB)")
    ok = verify(OUT_PDF, total)
    return 0 if ok else 2


if __name__ == "__main__":
    raise SystemExit(main())
