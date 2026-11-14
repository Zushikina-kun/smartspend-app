"""
Extract Figure 4 (Kanban), Figure 5 (demographic), and Figure 16 (receipt)
from the main manuscript for image fixing.
Uses the paragraph-to-image mapping we established earlier.
"""
from docx import Document
from docx.oxml.ns import qn
import os

DOCX = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"
OUT  = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\figures_to_fix"
os.makedirs(OUT, exist_ok=True)

doc = Document(DOCX)

# Map: paragraph text fragment → output filename
# We'll scan all image-containing paragraphs and their context
img_seq = 0
saved = []

for para_idx, para in enumerate(doc.paragraphs):
    has_img = False
    for run in para.runs:
        if (run._r.find('.//' + qn('wp:inline')) is not None or
            run._r.find('.//' + qn('wp:anchor')) is not None or
            run._r.find('.//' + qn('a:blip')) is not None):
            has_img = True
            break

    if has_img:
        img_seq += 1

        # Get context from nearby paragraphs
        ctx = para.text.strip()
        for j in range(para_idx+1, min(para_idx+3, len(doc.paragraphs))):
            t = doc.paragraphs[j].text.strip()
            if t: ctx = ctx + ' | ' + t[:80]; break

        # Determine which figure this is
        name = None
        if 'Kanban' in ctx or 'Figure 4' in ctx:
            name = 'fig4_kanban'
        elif 'Demographic' in ctx and ('Figure 5' in ctx or 'Needs-Assessment' in ctx):
            name = 'fig5_demographic'
        elif 'Receipt Scanning' in ctx or 'Figure 16' in ctx:
            name = 'fig16_receipt'

        if name:
            # Extract image bytes
            for run in para.runs:
                blips = run._r.findall('.//' + qn('a:blip'))
                for blip in blips:
                    rEmbed = blip.get(qn('r:embed'))
                    if rEmbed:
                        rel = para.part.rels.get(rEmbed)
                        if rel:
                            blob = rel.target_part.blob
                            ext = '.png' if blob[:4] == b'\x89PNG' else '.jpg'
                            outpath = os.path.join(OUT, name + ext)
                            with open(outpath, 'wb') as f:
                                f.write(blob)
                            saved.append(f"img_seq={img_seq} para[{para_idx}] -> {name}{ext} ({len(blob)//1024}KB)")

print(f"Saved {len(saved)} images:")
for s in saved:
    print(f"  {s}")
