# -*- coding: utf-8 -*-
"""Targeted comparison of V4 vs FINAL for the 13 known issues + tense sweep."""
import re, unicodedata, os
from docx import Document

OUT = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\v4-fixguide"
V4P = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx"
FINP = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
TENSEP = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\SmartSpend_Tense_Corrections_List.docx"

def norm(s):
    s = s or ""
    # normalize various dash/quote chars to plain to aid matching
    s = s.replace("\u2014", "-").replace("\u2013", "-").replace("\u2011","-")
    s = s.replace("\u201c","\"").replace("\u201d","\"").replace("\u2018","'").replace("\u2019","'")
    s = s.replace("\u2026","...")  # ellipsis
    s = s.replace("\u00a0"," ")
    s = unicodedata.normalize("NFC", s)
    s = re.sub(r"\s+"," ", s).strip()
    return s

def load(path):
    d = Document(path)
    paras = [norm(p.text) for p in d.paragraphs]
    tables = []
    for t in d.tables:
        rows=[]
        for r in t.rows:
            rows.append([norm(c.text) for c in r.cells])
        tables.append(rows)
    return d, paras, tables

v4d, v4p, v4t = load(V4P)
fnd, fnp, fnt = load(FINP)
v4full = "\n".join(v4p)
fnfull = "\n".join(fnp)

def find_idx(paras, sub, start=0):
    sub=norm(sub)
    for i in range(start, len(paras)):
        if sub and sub in paras[i]:
            return i
    return -1

def ctx(paras, idx, w=1):
    a=max(0,idx-w); b=min(len(paras),idx+w+1)
    return "\n   ".join("[{}] {}".format(j, paras[j]) for j in range(a,b))

R = []
def sec(t): R.append("\n" + "="*70 + "\n" + t + "\n" + "="*70)
def line(s=""): R.append(s)

# ---------------- ISSUE 1 & 2 & 3: Table 2.1 ----------------
sec("ISSUE 1/2/3: TABLE 2.1 (Distribution of Respondents and Validators)")
# find the table with "Respondents" header
def find_table_with(tables, sub):
    sub=norm(sub)
    for ti,t in enumerate(tables):
        for r in t:
            for c in r:
                if sub in c:
                    return ti,t
    return -1,None

for label,tables in [("V4",v4t),("FINAL",fnt)]:
    ti,t = find_table_with(tables,"Respondents")
    line(">> {} Table index={}:".format(label, ti))
    if t:
        for ri,row in enumerate(t):
            line("   R{}: {}".format(ri, " || ".join(row)))
    line("")

# search bodies for parents counts and technical validator
sec("ISSUE 1: Parents count text (16 vs 13)")
for label,full in [("V4",v4full),("FINAL",fnfull)]:
    line(">> {}:".format(label))
    for m in re.finditer(r"(16|13)\s*(parents|Parents)", full):
        s=max(0,m.start()-80); e=min(len(full),m.end()+80)
        line("   ..."+full[s:e]+"...")
    line("")

sec("ISSUE 2: 'Both Groups' presence")
for label,full,paras in [("V4",v4full,v4p),("FINAL",fnfull,fnp)]:
    idx=find_idx(paras,"Both Groups")
    line(">> {} 'Both Groups' in body idx={} | in full={}".format(label, idx, "Both Groups" in norm(full)))
line("")

sec("ISSUE 3: Technical Validator (System & SUS Process) presence")
for label,full,paras in [("V4",v4full,v4p),("FINAL",fnfull,fnp)]:
    idx=find_idx(paras,"Technical Validator")
    line(">> {} 'Technical Validator' idx={} | 'System & SUS' in full={}".format(label, idx, "System & SUS" in norm(full)))
line("")

# ---------------- ISSUE 4: Susan C. Arquisal ----------------
sec("ISSUE 4: Susan C. Arquisal / Avigail Candevario")
for label,full,paras in [("V4",v4full,v4p),("FINAL",fnfull,fnp)]:
    line(">> {}:".format(label))
    line("   'Susan C. Arquisal' in full: {}".format("Susan C. Arquisal" in full))
    line("   'Susan' in full: {}".format("Susan" in full))
    line("   'Avigail Candevario' in full: {}".format("Avigail Candevario" in full))
    line("   'Avigail' in full: {}".format("Avigail" in full))
    for i,p in enumerate(paras):
        if "Susan" in p or "Avigail" in p:
            line("   [{}] {}".format(i,p[:300]))
line("")

# ---------------- ISSUE 5 & 6: Qualitative / interviews ----------------
sec("ISSUE 5/6: Qualitative aspect & 'surveys' vs 'interviews'")
for label,paras in [("V4",v4p),("FINAL",fnp)]:
    line(">> {}:".format(label))
    for i,p in enumerate(paras):
        if "qualitative" in p.lower():
            line("   [{}] {}".format(i, p[:320]))
    line("")

# ---------------- ISSUE 7 & 8: Recommendations count ----------------
sec("ISSUE 7/8: Recommendations (Seven vs Eight)")
for label,paras in [("V4",v4p),("FINAL",fnp)]:
    line(">> {}:".format(label))
    for i,p in enumerate(paras):
        if re.search(r"(seven|eight)\s+recommendations", p, re.I):
            line("   [{}] {}".format(i, p[:360]))
    line("")

sec("ISSUE 7: Recommendations CHAPTER list items")
# find headings 'Recommendations' and show following items
for label,paras in [("V4",v4p),("FINAL",fnp)]:
    line(">> {}:".format(label))
    ridx=-1
    for i,p in enumerate(paras):
        if p.strip().lower()=="recommendations":
            ridx=i; break
    if ridx>=0:
        for j in range(ridx, min(ridx+40, len(paras))):
            if paras[j]:
                line("   [{}] {}".format(j, paras[j][:200]))
    line("")

# ---------------- ISSUE 9: Acknowledgements panelists em-dashes ----------------
sec("ISSUE 9: Acknowledgements panelists line (em-dashes)")
for label,paras in [("V4",v4p),("FINAL",fnp)]:
    line(">> {}:".format(label))
    for i,p in enumerate(paras):
        if "panelists" in p.lower() or "panelist" in p.lower():
            line("   [{}] {}".format(i, p[:320]))
line("")

# ---------------- ISSUE 10: Figures 3.12/3.13/3.14 ----------------
sec("ISSUE 10: Figures 3.12/3.13/3.14 presence (LOF + body captions)")
for label,paras in [("V4",v4p),("FINAL",fnp)]:
    line(">> {}:".format(label))
    for i,p in enumerate(paras):
        if re.search(r"3\.1[234]", p):
            line("   [{}] {}".format(i, p[:200]))
line("")

# ---------------- ISSUE 11: Certificates Appendix D/E ----------------
sec("ISSUE 11: Appendix D/E certificate references & nearby images")
from docx.oxml.ns import qn
def has_img(paragraph):
    for run in paragraph.runs:
        if run._element.findall('.//'+qn('a:blip')):
            return True
    return False
for label,d,paras in [("V4",v4d,v4p),("FINAL",fnd,fnp)]:
    line(">> {}:".format(label))
    for i,pp in enumerate(d.paragraphs):
        tx=norm(pp.text)
        if "APPENDIX D" in tx or "APPENDIX E" in tx or "Content Validation Certificate" in tx or "FHS Formula" in tx:
            line("   [{}] (img={}) {}".format(i, has_img(pp), tx[:160]))
    # show paragraphs with IMG near appendix region
    line("")

# ---------------- ISSUE 13: Step 1 Questionnaire Preparation ----------------
sec("ISSUE 13: Step 1 Questionnaire Preparation and Validation")
for label,paras in [("V4",v4p),("FINAL",fnp)]:
    line(">> {}:".format(label))
    for i,p in enumerate(paras):
        if "Questionnaire Preparation" in p or "Step 1" in p or "Step 1:" in p:
            line("   [{}] {}".format(i, p[:300]))
line("")

# ---------------- TENSE SWEEP ----------------
sec("TENSE SWEEP: check which corrections are present (past) vs still present-tense in V4")
td = Document(TENSEP)
# Table 1 is the corrections
ctab = td.tables[1]
orig_full_present = []
missing_in_v4 = []
applied_in_v4 = []
ambiguous = []
for ri,row in enumerate(ctab.rows):
    cells=[norm(c.text) for c in row.cells]
    if ri==0: continue
    if len(cells)<5: continue
    num, section, tense, orig, corr = cells[0],cells[1],cells[2],cells[3],cells[4]
    # strip ellipsis context markers
    def strip_ell(s):
        s = re.sub(r"^\s*\.{2,}\s*","",s)  # leading ...
        s = re.sub(r"\s*\.{2,}\s*$","",s)   # trailing ...
        s = re.sub(r"^\s*\.\.\.\s*","",s)
        s = re.sub(r"\s*\.\.\.\s*$","",s)
        return s.strip()
    o=strip_ell(orig); c=strip_ell(corr)
    if not o or not c: continue
    # Use the corrected fragment to test applied; original fragment to test missing
    # Take a window: first 40 chars-ish signature may be too long; try full fragment
    def find_any(full, frag):
        return frag in full
    v4_corr = find_any(v4full, c)
    v4_orig = find_any(v4full, o)
    fin_corr = find_any(fnfull, c)
    rec={"num":num,"section":section,"tense":tense,"orig":o[:120],"corr":c[:120],"v4_corr":v4_corr,"v4_orig":v4_orig,"fin_corr":fin_corr}
    if v4_corr and not v4_orig:
        applied_in_v4.append(rec)
    elif v4_orig and not v4_corr:
        missing_in_v4.append(rec)
    else:
        ambiguous.append(rec)

line("Total correction rows parsed: {}".format(len(applied_in_v4)+len(missing_in_v4)+len(ambiguous)))
line("APPLIED in V4 (past-tense present, present-tense absent): {}".format(len(applied_in_v4)))
line("MISSING in V4 (present-tense still present, past-tense absent): {}".format(len(missing_in_v4)))
line("AMBIGUOUS (both or neither found): {}".format(len(ambiguous)))
line("")
line("--- MISSING (still present tense) in V4, first 80: ---")
for r in missing_in_v4[:80]:
    line("#{} [{}]".format(r["num"], r["section"]))
    line("   ORIG : {}".format(r["orig"]))
    line("   CORR : {}".format(r["corr"]))
line("")
line("--- MISSING (still present tense) in V4 that ARE corrected in FINAL: ---")
fin_also_ok=[r for r in missing_in_v4 if r["fin_corr"]]
line("count: {}".format(len(fin_also_ok)))
for r in fin_also_ok[:40]:
    line("#{} [{}] ORIG='{}' -> CORR='{}'".format(r["num"], r["section"], r["orig"][:70], r["corr"][:70]))

with open(os.path.join(OUT,"checks.txt"),"w",encoding="utf-8") as f:
    f.write("\n".join(R))
import os
print("Wrote checks.txt ; missing_in_v4=", len(missing_in_v4), "applied=", len(applied_in_v4), "ambig=", len(ambiguous))
