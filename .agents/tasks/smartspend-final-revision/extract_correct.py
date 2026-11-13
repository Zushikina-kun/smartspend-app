"""
Extract the actual diagram images by correct paragraph index,
save them with meaningful names, then display them.
"""
from docx import Document
from docx.oxml.ns import qn
from docx.opc.constants import RELATIONSHIP_TYPE as RT
import os, shutil

DOCX = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"
OUT  = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-final-revision\figures"
os.makedirs(OUT, exist_ok=True)

doc = Document(DOCX)

# Target paragraphs by index (from map_images.py output)
TARGETS = {
    4:  "fig3_sus_chart",        # para[227] Figure 3: SUS Score Interpretation
    5:  "fig4_kanban",           # para[232] Figure 4: Agile Kanban Workflow
    8:  "fig5_demographic",      # para[254] Figure 5: Demographic Distribution
    9:  "fig6_flowchart",        # para[277] Figure 6: System Flowchart
    10: "fig7_usecase",          # para[280] Figure 7: Use Case Diagram
    11: "fig8_navmap",           # para[285] Figure 8: Visual Table of Contents
    19: "fig16_sus_computation", # para[325] Figure 16: SUS Computation Table
}

# Map para index -> target name
PARA_TO_NAME = {
    227: "fig3_sus_chart",
    232: "fig4_kanban",
    254: "fig5_demographic",
    277: "fig6_flowchart",
    280: "fig7_usecase",
    285: "fig8_navmap",
    325: "fig16_sus_computation",
}

img_seq = 0
for para_idx, para in enumerate(doc.paragraphs):
    has_img = False
    for run in para.runs:
        if run._r.find('.//' + qn('wp:inline')) is not None or \
           run._r.find('.//' + qn('wp:anchor')) is not None or \
           run._r.find('.//' + qn('a:blip')) is not None:
            has_img = True
            break
    if has_img:
        img_seq += 1
        if para_idx not in PARA_TO_NAME:
            continue
        name = PARA_TO_NAME[para_idx]
        # Extract the image bytes from the relationship
        for run in para.runs:
            blips = run._r.findall('.//' + qn('a:blip'))
            for blip in blips:
                rEmbed = blip.get(qn('r:embed'))
                if rEmbed:
                    rel = para.part.rels.get(rEmbed)
                    if rel:
                        blob = rel.target_part.blob
                        # detect extension from magic bytes
                        if blob[:4] == b'\x89PNG':
                            ext = '.png'
                        elif blob[:2] == b'\xff\xd8':
                            ext = '.jpg'
                        else:
                            ext = '.png'
                        outpath = os.path.join(OUT, f"{name}{ext}")
                        with open(outpath, 'wb') as f:
                            f.write(rel.target_part.blob)
                        print(f"  Saved: {name}{ext}  ({len(rel.target_part.blob)//1024} KB)")

print("\nDone. Check figures/ folder.")
