#!/usr/bin/env python3
"""Print paragraph context (text) around each image-bearing paragraph so we
can confirm the true caption of each embedded figure."""
from docx import Document
MANUSCRIPT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
doc = Document(MANUSCRIPT)
paras = doc.paragraphs

image_paras = [29, 127, 167, 186, 280, 284, 329, 331, 333, 343, 345, 347, 349, 351, 353, 355, 361, 675, 699, 734]

for pi in image_paras:
    print(f"\n===== IMAGE at para {pi} =====")
    for j in range(max(0, pi-1), min(len(paras), pi+5)):
        t = paras[j].text.strip()
        marker = " <== IMAGE PARA" if j == pi else ""
        if t:
            print(f"  [{j}]{marker}: {t[:140]}")
        else:
            print(f"  [{j}]{marker}: (empty)")
