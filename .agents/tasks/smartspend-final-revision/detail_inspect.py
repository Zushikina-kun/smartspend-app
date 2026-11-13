"""
Detailed inspection: show the actual dark strip content and size,
and view each image to understand what needs cropping vs regenerating.
"""
import os
from PIL import Image
import numpy as np

IMAGES_DIR = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-final-revision\images"

# Images confirmed to have text strips
TO_CHECK = {
    "image3.png":  ("Figure 3",  "SUS Score Interpretation",   "TOP+BOTTOM"),
    "image4.png":  ("Figure 4",  "Agile Kanban Workflow",       "TOP+BOTTOM"),
    "image7.png":  ("Figure 6",  "System Flowchart",            "BOTTOM"),
    "image8.png":  ("Figure 7",  "Use Case Diagram",            "BOTTOM"),
    "image9.png":  ("Figure 8",  "Visual Table of Contents",    "BOTTOM"),
    "image17.png": ("Figure 16", "SUS Computation Table",       "MIDDLE? - confirmed Figure 3.14"),
}

for fname, (fig, title, strip_loc) in TO_CHECK.items():
    path = os.path.join(IMAGES_DIR, fname)
    img = Image.open(path)
    w, h = img.size
    arr = np.array(img.convert("L"))
    print(f"\n{'='*55}")
    print(f"{fname} — {fig}: {title}  ({w}x{h})")
    print(f"  Flagged strip: {strip_loc}")

    # Scan every 10px row for dark pixel density
    print(f"  Row-by-row dark pixel density (top 100px and bottom 100px):")
    print(f"  TOP:")
    for row in range(0, min(100, h), 5):
        density = np.mean(arr[row] < 80)
        bar = '#' * int(density * 40)
        print(f"    row {row:4d}: {density:.3f} {bar}")
    print(f"  BOTTOM:")
    for row in range(max(0, h-100), h, 5):
        density = np.mean(arr[row] < 80)
        bar = '#' * int(density * 40)
        print(f"    row {row:4d}: {density:.3f} {bar}")

    # For image17 (SUS table, confirmed Figure 3.14) - scan ALL rows
    if fname == "image17.png":
        print(f"  FULL SCAN for image17 (finding where Figure 3.14 text is):")
        densities = [(r, np.mean(arr[r] < 80)) for r in range(h)]
        high = [(r, d) for r, d in densities if d > 0.05]
        for r, d in high[:30]:
            bar = '#' * int(d * 40)
            print(f"    row {r:4d}: {d:.3f} {bar}")
