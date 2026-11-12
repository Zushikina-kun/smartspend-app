# -*- coding: utf-8 -*-
"""Check neither/v4_only_present buckets for hidden V4 misses (FINAL has past, V4 differs)."""
import re, os
from docx import Document
OUT = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\v4-fixguide"
V4P = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx"
FINP = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
TENSEP = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\SmartSpend_Tense_Corrections_List.docx"
def norm(s):
    s=s or ""
    s=s.replace("\u2014","-").replace("\u2013","-").replace("\u201c",'"').replace("\u201d",'"')
    s=s.replace("\u2026","...").replace("\u00a0"," ")
    return re.sub(r"\s+"," ",s).strip()
def loadfull(path):
    d=Document(path); return norm("\n".join(p.text for p in d.paragraphs))
v4full=loadfull(V4P); fnfull=loadfull(FINP)
td=Document(TENSEP); ctab=td.tables[1]
def strip_ell(s):
    s=re.sub(r"^\s*\.{2,}\s*","",s); s=re.sub(r"\s*\.{2,}\s*$","",s)
    s=re.sub(r"^\s*\.\.\.\s*","",s); s=re.sub(r"\s*\.\.\.\s*$","",s)
    return s.strip()
v4_only_present=[]; neither_fin_past=[]
for ri,row in enumerate(ctab.rows):
    cells=[norm(c.text) for c in row.cells]
    if ri==0 or len(cells)<5: continue
    num,section,tense,orig,corr=cells
    o=strip_ell(orig); c=strip_ell(corr)
    if not o or not c: continue
    vp=o in v4full; vc=c in v4full; fp=o in fnfull; fc=c in fnfull
    if vp and not vc and not fp and not fc: v4_only_present.append((num,section,o,c))
    if not vp and not vc and fc and not fp: neither_fin_past.append((num,section,o,c))
print("=== v4_only_present (V4 has present, FINAL has neither present nor past exact) ===",len(v4_only_present))
for r in v4_only_present:
    print("#{} [{}]".format(r[0],r[1]))
    print("  ORIG: {}".format(r[2][:110]))
    print("  CORR: {}".format(r[3][:110]))
print()
print("=== neither BUT FINAL has past (FINAL applied past via reword; V4 may differ) ===",len(neither_fin_past))
for r in neither_fin_past[:30]:
    print("#{} [{}]".format(r[0],r[1]))
    print("  ORIG: {}".format(r[2][:110]))
    print("  CORR: {}".format(r[3][:110]))
