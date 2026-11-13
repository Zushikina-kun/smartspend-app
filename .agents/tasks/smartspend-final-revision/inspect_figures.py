"""
Inspect the 7 flagged images for burned-in figure number text.
Uses pytesseract if available, otherwise checks pixel density of top/bottom strips.
Outputs a report of findings.
"""
import os, sys
from PIL import Image
import numpy as np

IMAGES_DIR = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-final-revision\images"

# Flagged images with their correct figure assignment
FLAGGED = {
    "image2.jpg":  ("Figure 2",  "Conceptual Framework"),
    "image3.png":  ("Figure 3",  "SUS Score Interpretation"),
    "image4.png":  ("Figure 4",  "Agile Kanban Workflow"),
    "image7.png":  ("Figure 6",  "System Flowchart"),
    "image8.png":  ("Figure 7",  "Use Case Diagram"),
    "image9.png":  ("Figure 8",  "Visual Table of Contents"),
    "image17.png": ("Figure 16", "SUS Computation Table"),
}

# Try pytesseract
try:
    import pytesseract
    HAS_OCR = True
    print("pytesseract available")
except ImportError:
    HAS_OCR = False
    print("pytesseract NOT available — using pixel density analysis")

def has_dark_text_strip(img, strip_height=40, threshold=0.08):
    """Check if top or bottom strip has >threshold dark pixels (likely text)."""
    arr = np.array(img.convert("L"))
    h, w = arr.shape
    top = arr[:strip_height, :]
    bot = arr[max(0, h-strip_height):, :]
    top_dark = np.mean(top < 80)
    bot_dark = np.mean(bot < 80)
    return top_dark, bot_dark

report = []
for fname, (fig_num, fig_title) in FLAGGED.items():
    path = os.path.join(IMAGES_DIR, fname)
    if not os.path.exists(path):
        report.append(f"{fname}: FILE NOT FOUND")
        continue
    img = Image.open(path)
    w, h = img.size
    report.append(f"\n{'='*60}")
    report.append(f"{fname} — {fig_num}: {fig_title}")
    report.append(f"  Size: {w}x{h} px")

    if HAS_OCR:
        # OCR full image
        text = pytesseract.image_to_string(img)
        lines = [l.strip() for l in text.splitlines() if l.strip()]
        report.append(f"  OCR text (first 10 lines):")
        for l in lines[:10]:
            report.append(f"    {l!r}")
        # Check for figure number patterns
        import re
        fig_patterns = re.findall(r'[Ff]igure\s*[\d\.]+', text)
        if fig_patterns:
            report.append(f"  *** BURNED-IN FIGURE REFS FOUND: {fig_patterns}")
        else:
            report.append(f"  No figure number text detected by OCR")
    else:
        top_dark, bot_dark = has_dark_text_strip(img)
        report.append(f"  Top strip dark pixel ratio: {top_dark:.3f}")
        report.append(f"  Bottom strip dark pixel ratio: {bot_dark:.3f}")
        if top_dark > 0.08:
            report.append(f"  *** TOP STRIP likely has text (ratio={top_dark:.3f})")
        if bot_dark > 0.08:
            report.append(f"  *** BOTTOM STRIP likely has text (ratio={bot_dark:.3f})")
        if top_dark <= 0.08 and bot_dark <= 0.08:
            report.append(f"  Looks clean — no obvious text strips detected")

    # Also check overall image characteristics
    arr = np.array(img.convert("RGB"))
    report.append(f"  Dominant color range: R={arr[:,:,0].mean():.0f} G={arr[:,:,1].mean():.0f} B={arr[:,:,2].mean():.0f}")

report_text = "\n".join(report)
print(report_text)

out = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-final-revision\figure-inspect-report.txt"
with open(out, "w", encoding="utf-8") as f:
    f.write(report_text)
print(f"\nReport saved to {out}")
