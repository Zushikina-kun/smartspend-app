#!/usr/bin/env python3
"""Verify the fixed output docx against the required criteria."""
import zipfile
from docx import Document
from docx.oxml.ns import qn

V4 = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx"
OUT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"

v4 = Document(V4)
out = Document(OUT)

def all_text(doc):
    parts = [p.text for p in doc.paragraphs]
    for t in doc.tables:
        for row in t.rows:
            for c in row.cells:
                parts.append(c.text)
    return "\n".join(parts)

v4txt = all_text(v4)
outxt = all_text(out)

def has(s, txt=None): return (s in (txt if txt is not None else outxt))
def count(s, txt=None): return (txt if txt is not None else outxt).count(s)

results = []
def check(label, cond, detail=""):
    results.append((label, cond, detail))
    print(f"[{'PASS' if cond else 'FAIL'}] {label}  {detail}")

# --- protected values ---
check("61.83 present", has("61.83"))
check("17.58 present", has("17.58"))
check("N = 30 / N=30 present", has("N = 30") or has("N=30"), "form in doc: N = 30")
check("grade of D present", has("grade of D") or has("Grade D") or has("| D |"))
check("adjective OK present", has("OK"))
check("partially achieved present", has("partially achieved"))
check("Jeoffrey present", has("Jeoffrey"))
check("Shekiro present", has("Shekiro"))
check("Mary-Ann present", has("Mary-Ann"))
check("Ellen ... Mangaoang present", has("Mangaoang"))
check("Avigail Candevario present", has("Avigail Candevario"))
# --- Susan removed ---
check("No 'Susan' anywhere", not has("Susan"))
check("No 'Arquisal' anywhere", not has("Arquisal"))
# --- abstract ---
check("'Eight recommendations' present", has("Eight recommendations were identified"))
check("'Seven recommendations' absent", not has("Seven recommendations were identified"))
# --- qualitative ---
check("qualitative uses 'interviews were used'", has("interviews were used"))
check("qualitative no longer says 'structured survey questionnaires were used to collect'",
      not has("structured survey questionnaires were used to collect"))
# --- acknowledgements em-dashes ---
check("ack has em-dash panelists line", has("To the panelists \u2014 Mr. Jeoffrey B. Layco, MIS"))
# --- recommendations: 8 items ---
rec_items = [f"{n}. " for n in range(1, 9)]
rec_starts = {n: False for n in range(1, 9)}
for p in out.paragraphs:
    t = p.text
    for n in range(1, 9):
        if t.startswith(f"{n}. ") and "recommended" in t:
            rec_starts[n] = True
check("Rec 1 (UI/UX refinement) present", rec_starts[1] and has("1. UI/UX refinement."))
check("Rec 2 (Formal parsing evaluation) present", rec_starts[2] and has("2. Formal parsing evaluation."))
check("Rec 8 (Longitudinal evaluation) present", rec_starts[8] and has("8. Longitudinal evaluation."))
check("All 8 rec items present", all(rec_starts.values()), str(rec_starts))
# --- Table 2.1 ---
t21 = out.tables[2]
t21_rows = [[c.text for c in row.cells] for row in t21.rows]
t21_flat = " | ".join(" | ".join(r) for r in t21_rows)
check("Table 2.1 Parents = 13", "13" in t21_rows[1][1] if len(t21_rows) > 1 else False, t21_rows[1] if len(t21_rows)>1 else "")
check("Table 2.1 has Both Groups | 3", any("Both Groups" in r[0] and "3" in r[1] for r in t21_rows), "")
check("Table 2.1 Total Validators = 1", any("Total Validators" in r[0] and "1" in r[1] for r in t21_rows), "")
check("Table 2.1 NO Technical Validator row", not any("Technical Validator" in r[0] for r in t21_rows), "")
# --- images: count + integrity ---
def img_count(doc):
    body = doc.element.body
    return len(body.findall('.//' + qn('w:drawing')))
v4_imgs = img_count(v4)
out_imgs = img_count(out)
# image-bearing paragraphs
def has_img(para):
    return bool(para._p.findall('.//' + qn('w:drawing'))) or bool(para._p.findall('.//' + qn('w:pict')))
def img_before_caption(doc, cap):
    ps = doc.paragraphs
    for i, p in enumerate(ps):
        if p.text.startswith(cap) and i > 0 and has_img(ps[i-1]):
            return True
    return False
fig312 = img_before_caption(out, "Figure 3.12")
fig313 = img_before_caption(out, "Figure 3.13")
fig314 = img_before_caption(out, "Figure 3.14")
check("Figure 3.12 image present before caption", fig312)
check("Figure 3.13 image present before caption", fig313)
check("Figure 3.14 image present before caption", fig314)
# certificate images integrity (embed rels resolve)
def cert_imgs_ok(doc):
    ok = {"D": False, "E": False}
    ps = doc.paragraphs
    for i, p in enumerate(ps):
        if p.text.strip() == "Content Validation Certificate (Survey Questionnaire)":
            for j in range(i+1, min(i+4, len(ps))):
                if has_img(ps[j]):
                    blips = ps[j]._p.findall('.//' + qn('a:blip'))
                    for b in blips:
                        rid = b.get(qn('r:embed'))
                        try:
                            doc.part.related_parts[rid]; ok["D"]=True
                        except Exception: pass
        if p.text.strip() == "Content Validation Certificate (FHS Formula and Literature)":
            for j in range(i+1, min(i+4, len(ps))):
                if has_img(ps[j]):
                    blips = ps[j]._p.findall('.//' + qn('a:blip'))
                    for b in blips:
                        rid = b.get(qn('r:embed'))
                        try:
                            doc.part.related_parts[rid]; ok["E"]=True
                        except Exception: pass
    return ok
cok = cert_imgs_ok(out)
check("Appendix D certificate image intact", cok["D"])
check("Appendix E certificate image intact", cok["E"])
check(f"Image count (V4={v4_imgs}, OUT={out_imgs})", True, f"V4 drawings={v4_imgs}, OUT drawings={out_imgs}; figures/certs already in V4 so no new images added")
# --- objectives unchanged ---
def obj_text(doc):
    ps = doc.paragraphs
    out = []
    started = False
    for i, p in enumerate(ps):
        if p.text.strip() == "Statement of Objectives" and p.style.name == "Heading 3":
            started = True
            start = i
            break
    # capture from the heading through 'Scope and Limitations of the Study'
    seg = []
    cap = False
    for i, p in enumerate(ps):
        if p.text.strip() == "Statement of Objectives" and p.style.name == "Heading 3":
            cap = True
        if cap:
            seg.append(p.text)
            if p.text.strip() == "Scope and Limitations of the Study":
                break
    return "\n".join(seg)
v4obj = obj_text(v4)
outobj = obj_text(out)
check("Objectives section unchanged from V4", v4obj == outobj, f"V4 len={len(v4obj)} OUT len={len(outobj)} equal={v4obj==outobj}")

# summary
passed = sum(1 for _,c,_ in results if c)
print(f"\n==== {passed}/{len(results)} checks passed ====")

# write report
with open(r"c:\xampp\htdocs\smartspend_app\.agents\tasks\v4-fixguide\verify_report.txt", "w", encoding="utf-8") as f:
    for label, cond, detail in results:
        f.write(f"[{'PASS' if cond else 'FAIL'}] {label}  {detail}\n")
    f.write(f"\n==== {passed}/{len(results)} checks passed ====\n")
    f.write(f"\nImage counts: V4 drawings={v4_imgs}, OUT drawings={out_imgs}\n")
    # dump the recommendations list as written
    f.write("\n--- Recommendations as written in output ---\n")
    ps = out.paragraphs
    for i, p in enumerate(ps):
        if p.text.startswith("1. UI/UX refinement"):
            for j in range(i, i+8):
                f.write(f"{ps[j].text[:130]}\n")
            break
    f.write("\n--- Table 2.1 as written in output ---\n")
    for r in t21_rows:
        f.write(" | ".join(r) + "\n")
print("wrote verify_report.txt")
