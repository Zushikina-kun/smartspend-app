"""
Final crops and DOCX reinsert:
- fig5: crop top at row 100 (clear of both title lines + subtitle)
- fig4: crop bottom at row 739 (white gap before caption box)
Then reinsert into DOCX.
"""
import os
from PIL import Image
from docx import Document
from docx.oxml.ns import qn

FIGURES_DIR = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-final-revision\figures"
FIXED_DIR   = os.path.join(FIGURES_DIR, "fixed")
DOCX_PATH   = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"

# ── fig5: crop top 100px (removes both title lines cleanly) ─────────────────
img5 = Image.open(os.path.join(FIGURES_DIR, "fig5_demographic.png"))
w5, h5 = img5.size
img5_fixed = img5.crop((0, 100, w5, h5))
img5_fixed.save(os.path.join(FIXED_DIR, "fig5_demographic.png"), dpi=(150,150))
print(f"fig5: cropped top 100px → {img5_fixed.size}")

# ── fig4: crop at row 739 (removes bottom caption box) ──────────────────────
img4 = Image.open(os.path.join(FIGURES_DIR, "fig4_kanban.png"))
w4, h4 = img4.size
# Row 739 is the start of the white gap before the caption box
# Keep everything up to row 735 to leave a small clean margin
img4_fixed = img4.crop((0, 0, w4, 735))
img4_fixed.save(os.path.join(FIXED_DIR, "fig4_kanban.png"), dpi=(150,150))
print(f"fig4: cropped bottom → {img4_fixed.size} (removed {h4-735}px caption box)")

# ── Reinsert both into DOCX ─────────────────────────────────────────────────
doc = Document(DOCX_PATH)

PARA_FIXES = {
    232: ("fig4_kanban.png",     "image/png"),
    254: ("fig5_demographic.png","image/png"),
}

replaced = []
for para_idx, para in enumerate(doc.paragraphs):
    if para_idx not in PARA_FIXES:
        continue
    fname, mime = PARA_FIXES[para_idx]
    fixed_path = os.path.join(FIXED_DIR, fname)
    for run in para.runs:
        blips = run._r.findall('.//' + qn('a:blip'))
        for blip in blips:
            rEmbed = blip.get(qn('r:embed'))
            if rEmbed:
                rel = para.part.rels.get(rEmbed)
                if rel:
                    with open(fixed_path, 'rb') as f:
                        rel.target_part._blob = f.read()
                    replaced.append((para_idx, fname))
                    print(f"  Replaced para[{para_idx}] with {fname}")

doc.save(DOCX_PATH)
print(f"\nDOCX saved. Replaced: {replaced}")
print("All figure fixes complete.")
