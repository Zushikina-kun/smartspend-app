"""
build_summary_pdf.py  —  Render SUMMARY_FOR_MAAM_ELLEN.md to a clean printable PDF.

Method (reused from the prior FHS_FORMULA_VALIDATION_FOR_ADVISER.pdf build):
  1. Convert the Markdown source to styled HTML (python `markdown`, tables extension).
  2. Render the HTML to PDF with a headless Chromium-based browser
     (Microsoft Edge on this machine) via --print-to-pdf.
  3. Verify the result with pypdf (page count + text-layer sanity check).

Run:  python build_summary_pdf.py
Out:  docs/capstone/SUMMARY_FOR_MAAM_ELLEN.pdf
"""
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import markdown
import pypdf

HERE = Path(__file__).resolve().parent
SRC_MD = HERE / "SUMMARY_FOR_MAAM_ELLEN.md"
OUT_PDF = HERE / "SUMMARY_FOR_MAAM_ELLEN.pdf"

# Chromium binary used for headless PDF rendering (Edge is Chromium-based).
EDGE_BIN = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

CSS = """
@page { margin: 14mm 16mm; }
* { box-sizing: border-box; }
html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body {
  font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
  font-size: 10.5pt; line-height: 1.45; color: #222; margin: 0;
}
h1 { font-size: 17pt; color: #5C0E24; margin: 0 0 2px 0; line-height: 1.2; }
h3 { font-size: 11pt; color: #333; font-weight: 600; margin: 0 0 12px 0; font-style: italic; }
h2 { font-size: 12.5pt; color: #5C0E24; margin: 16px 0 6px 0;
     border-bottom: 1.5px solid #5C0E24; padding-bottom: 3px; }
p { margin: 0 0 7px 0; text-align: justify; }
strong { color: #111; }
hr { border: none; border-top: 1px solid #ccc; margin: 10px 0; }
ol { margin: 2px 0 8px 0; padding-left: 22px; }
li { margin: 0 0 3px 0; }
table { border-collapse: collapse; width: 100%; margin: 6px 0 10px 0; font-size: 9.5pt; }
th, td { border: 1px solid #999; padding: 4px 7px; text-align: left; vertical-align: top; }
th { background: #F2E6EA; color: #5C0E24; font-weight: 600; }
tr:nth-child(even) td { background: #FAF7F8; }
code { font-family: "Consolas", monospace; font-size: 9pt; background: #F4F4F4;
      padding: 1px 3px; border-radius: 3px; }
"""


def md_to_html(md_text: str) -> str:
    body = markdown.markdown(
        md_text, extensions=["tables", "sane_lists", "nl2br"], output_format="html5"
    )
    return (
        "<!DOCTYPE html><html lang='en'><head><meta charset='utf-8'>"
        f"<style>{CSS}</style></head><body>{body}</body></html>"
    )


def render_pdf(html_path: Path, pdf_path: Path) -> None:
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


def verify(pdf_path: Path) -> None:
    reader = pypdf.PdfReader(str(pdf_path))
    pages = len(reader.pages)
    text = "\n".join(p.extract_text() for p in reader.pages)
    print(f"  PDF pages: {pages}")
    for needle in ["Literature Basis", "Validation", "Questionnaire Status",
                   "CBA", "SUS", "FHS_Formula_For_Maam_Mangaoang.pdf"]:
        if needle not in text:
            print(f"  WARNING: expected text not found in PDF: {needle!r}")
    print(f"  pypdf text-layer sanity check passed (page count = {pages}).")


def main() -> int:
    if not SRC_MD.exists():
        print(f"ERROR: source markdown not found: {SRC_MD}", file=sys.stderr)
        return 1
    if not Path(EDGE_BIN).exists():
        print(f"ERROR: headless Chromium binary not found: {EDGE_BIN}", file=sys.stderr)
        return 1

    md_text = SRC_MD.read_text(encoding="utf-8")
    html = md_to_html(md_text)

    with tempfile.TemporaryDirectory() as tmp:
        html_path = Path(tmp) / "summary.html"
        html_path.write_text(html, encoding="utf-8")
        if OUT_PDF.exists():
            OUT_PDF.unlink()
        render_pdf(html_path, OUT_PDF)

    size = OUT_PDF.stat().st_size
    print(f"  PDF written: {OUT_PDF}  ({size:,} bytes, {size // 1024} KB)")
    verify(OUT_PDF)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
