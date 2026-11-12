# -*- coding: utf-8 -*-
"""Refined tense analysis: find corrections where V4 keeps present but FINAL has past (V4 behind FINAL)."""
import re, os
from docx import Document

OUT = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\v4-fixguide"
V4P = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx"
FINP = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
TENSEP = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\SmartSpend_Tense_Corrections_List.docx"

def norm(s):
    s=s or ""
    s=s.replace("\u2014","-").replace("\u2013","-").replace("\u2011","-")
    s=s.replace("\u201c",'"').replace("\u201d",'"').replace("\u2018","'").replace("\u2019","'")
    s=s.replace("\u2026","...").replace("\u00a0"," ")
    s=re.sub(r"\s+"," ",s).strip()
    return s

def loadfull(path):
    d=Document(path)
    return norm("\n".join(p.text for p in d.paragraphs))

v4full=loadfull(V4P); fnfull=loadfull(FINP)
td=Document(TENSEP); ctab=td.tables[1]

def strip_ell(s):
    s=re.sub(r"^\s*\.{2,}\s*","",s); s=re.sub(r"\s*\.{2,}\s*$","",s)
    s=re.sub(r"^\s*\.\.\.\s*","",s); s=re.sub(r"\s*\.\.\.\s*$","",s)
    return s.strip()

# categories
v4_present_fin_past=[]   # V4 keeps present, FINAL has past -> V4 BEHIND (needs fix)
both_present=[]          # both keep present (intentionally not applied)
both_past=[]             # both have past (applied)
v4_past_fin_present=[]   # odd
neither=[]               # neither exact (rewritten)
v4_only_present=[]       # V4 present, FINAL neither

for ri,row in enumerate(ctab.rows):
    cells=[norm(c.text) for c in row.cells]
    if ri==0 or len(cells)<5: continue
    num,section,tense,orig,corr=cells[0],cells[1],cells[2],cells[3],cells[4]
    o=strip_ell(orig); c=strip_ell(corr)
    if not o or not c: continue
    vp=o in v4full; vc=c in v4full; fp=o in fnfull; fc=c in fnfull
    rec=(num,section,tense,o,c)
    if vc and not vp:  # v4 has past, not present
        if fc: both_past.append(rec)
        elif fp: v4_past_fin_present.append(rec)
        else: neither.append(rec)
    elif vp and not vc:  # v4 present, not past
        if fc: v4_present_fin_past.append(rec)  # FINAL has past -> V4 BEHIND
        elif fp: both_present.append(rec)
        else: v4_only_present.append(rec)
    else:
        neither.append(rec)

print("v4_present_fin_past (V4 BEHIND FINAL, needs fix):", len(v4_present_fin_past))
print("both_present (intentionally not applied, V4==FINAL):", len(both_present))
print("both_past (applied in both):", len(both_past))
print("neither (rewritten/ctx differs):", len(neither))
print("v4_past_fin_present (odd):", len(v4_past_fin_present))
print("v4_only_present (V4 present, FINAL neither):", len(v4_only_present))
print()
print("=== V4 BEHIND FINAL (present in V4, past in FINAL) — these need applying ===")
for r in v4_present_fin_past:
    print("#{} [{}]".format(r[0],r[1]))
    print("   ORIG(present): {}".format(r[3][:120]))
    print("   CORR(past)   : {}".format(r[4][:120]))
print()
print("=== both_present (V4 and FINAL agree present tense — NOT a fix) count=",len(both_present))
for r in both_present[:25]:
    print("#{} [{}] {}".format(r[0],r[1],r[3][:90]))

with open(OUT+"\\tense2.txt","w",encoding="utf-8") as f:
    f.write("v4_present_fin_past(BEHIND)="+str(len(v4_present_fin_past))+"\n")
    f.write("both_present="+str(len(both_present))+"\n")
    f.write("both_past="+str(len(both_past))+"\n")
    f.write("neither="+str(len(neither))+"\n\n")
    f.write("=== V4 BEHIND FINAL ===\n")
    for r in v4_present_fin_past:
        f.write("#{} [{}]\n  ORIG: {}\n  CORR: {}\n".format(r[0],r[1],r[3][:160],r[4][:160]))
    f.write("\n=== both_present (agree, no fix) ===\n")
    for r in both_present:
        f.write("#{} [{}] {}\n".format(r[0],r[1],r[3][:130]))
print("\nWrote tense2.txt")
