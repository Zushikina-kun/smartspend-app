# -*- coding: utf-8 -*-
"""Detail checks: inline images near fig 3.12-3.14, full rec/abstract text, appendix image presence."""
import os, re
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

def count_inline(d):
    n=0
    for pp in d.paragraphs:
        if has_img(pp): n+=1
    return n

R=[]
def line(s=""): R.append(s)
def sec(t): R.append("\n"+("="*60)+"\n"+t+"\n"+"="*60)

for label,path in [("V4",V4P),("FINAL",FINP)]:
    d=Document(path)
    paras=d.paragraphs
    line("== {} : inline-image paragraphs = {}".format(label, count_inline(d)))
    sec("{} FIGURE 3.1x REGION (paras with '3.1' or 'Figure 3.' and IMG flag, +-2 ctx)".format(label))
    targets=[]
    for i,pp in enumerate(paras):
        t=pp.text
        if re.search(r"3\.1[0-9]|Figure 3", t) or has_img(pp):
            targets.append(i)
    # print clustered regions around SUS/figures
    # find indices where Figure 3.1x caption or IMG appears, print with neighbors
    printed=set()
    for i in targets:
        if any(abs(i-j)<=2 for j in [x for x in range(len(paras)) if re.search(r"3\.1[234]|Figure 3\.1[234]", paras[x].text)]):
            for j in range(max(0,i-2),min(len(paras),i+3)):
                if j not in printed:
                    printed.add(j)
                    line("[{:04d}][img={}] {}".format(j, has_img(paras[j]), paras[j].text.replace("\t"," ")[:160]))
            line("")
    sec("{} APPENDIX D/E REGION (paras 695-720 / 760-780)".format(label))
    if label=="V4":
        rng=range(695,725)
    else:
        rng=range(760,785)
    for j in rng:
        if j<len(paras):
            line("[{:04d}][img={}] {}".format(j, has_img(paras[j]), paras[j].text.replace("\t"," ")[:160]))
    sec("{} ABSTRACT para 51-54 FULL".format(label))
    for j in range(50,55):
        if j<len(paras):
            line("[{:04d}] {}".format(j, paras[j].text))
    sec("{} RECOMMENDATIONS FULL (item lines)".format(label))
    for j,pp in enumerate(paras):
        if re.match(r"^\s*[1-8]\.\s", pp.text):
            # only near Recommendations heading
            line("[{:04d}] {}".format(j, pp.text[:400]))
    sec("{} QUALITATIVE/RESEARCH DESIGN paras 245-252 full".format(label))
    lo,hi=(243,253) if label=="V4" else (243,253)
    for j in range(lo,hi):
        if j<len(paras):
            line("[{:04d}] {}".format(j, paras[j].text[:400]))
    sec("{} SUS validator paragraph (259/272 region) full".format(label))
    lo,hi=(255,276) if label=="V4" else (253,274)
    for j in range(lo,hi):
        if j<len(paras):
            line("[{:04d}] {}".format(j, paras[j].text[:400]))

with open(os.path.join(OUT,"detail.txt"),"w",encoding="utf-8") as f:
    f.write("\n".join(R))
import os
print("wrote detail.txt")
