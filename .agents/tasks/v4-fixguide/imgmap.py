# -*- coding: utf-8 -*-
"""Map every inline image to the caption that follows it, for both docs."""
from docx import Document
from docx.oxml.ns import qn

OUT = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\v4-fixguide"
V4P = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx"
FINP = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"

def has_img(pp):
    for run in pp.runs:
        if run._element.findall('.//'+qn('a:blip')):
            return True
    return False

R=[]
def line(s=""): R.append(s)

for label,path in [("V4",V4P),("FINAL",FINP)]:
    d=Document(path)
    paras=d.paragraphs
    line("="*60)
    line("{} inline images: {}".format(label, sum(1 for p in paras if has_img(p))))
    line("="*60)
    imgparas=[i for i,p in enumerate(paras) if has_img(p)]
    for k,idx in enumerate(imgparas):
        # next non-empty paragraph is the likely caption
        cap=""
        for j in range(idx+1, min(idx+4,len(paras))):
            if paras[j].text.strip():
                cap=paras[j].text.strip()[:90]
                break
        line("img#{} idx={:04d} -> next: {}".format(k+1, idx, cap))
    line("")

with open(OUT+"\\imgmap.txt","w",encoding="utf-8") as f:
    f.write("\n".join(R))
print("wrote imgmap.txt")
