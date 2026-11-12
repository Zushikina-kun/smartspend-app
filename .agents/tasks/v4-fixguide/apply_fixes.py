#!/usr/bin/env python3
"""
Apply automatable fixes to V4 and save the fixed document as the new FINAL.
Source (read-only): V4 = docs/handsoff/1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx
Output (overwrite): FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx
V4 original is NEVER modified on disk.
"""
import sys
from copy import deepcopy
from docx import Document
from docx.oxml.ns import qn
from docx.text.paragraph import Paragraph

V4 = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx"
OUT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"

EM = "\u2014"  # em dash
APOS = "\u2019"  # right single quotation mark (curly apostrophe)

log = []
def L(*a): log.append(" ".join(str(x) for x in a)); print(*a)

doc = Document(V4)
paras = doc.paragraphs

def find_para(substr, must_be_one=True):
    hits = [i for i, p in enumerate(paras) if substr in p.text]
    if must_be_one:
        assert len(hits) == 1, f"expected 1 hit for {substr!r}, got {hits}"
    return hits

def set_run_text(para, idx, text):
    runs = para.runs
    assert idx < len(runs), f"para has {len(runs)} runs, need idx {idx}"
    runs[idx].text = text

def set_para_text(para, new_text):
    """Put all new text in run0 (keep its formatting), clear any extra runs."""
    assert len(para.runs) >= 1, "no runs"
    para.runs[0].text = new_text
    for r in para.runs[1:]:
        r.text = ""

def replace_in_para(para, old, new):
    """Substring replace across the paragraph's full run text; rewrite into run0."""
    full = "".join(r.text for r in para.runs)
    assert old in full, f"old not found: {old[:60]!r}"
    full2 = full.replace(old, new)
    para.runs[0].text = full2
    for r in para.runs[1:]:
        r.text = ""

# ---------- 1) Susan -> Avigail (2 instances) ----------
# Both paragraphs contain the Susan description; instance A also has "This review ensured".
susan_idxs = find_para("Susan C. Arquisal, a graduate", must_be_one=False)
assert len(susan_idxs) == 2, f"expected 2 Susan paras, got {susan_idxs}"
instA = [i for i in susan_idxs if "This review ensured" in paras[i].text]
assert len(instA) == 1, instA
instA = instA[0]
pA = paras[instA]
oldA = ("Susan C. Arquisal, a graduate of Bachelor of Science in Commerce major in "
        "Management and an active business owner with experience in financial management "
        "and business operations")
newA = ("Avigail Candevario, PFMe, a subject matter expert in financial management "
        "and business operations")
assert oldA in pA.text, "instance A substring not found"
# single run paragraph
assert len(pA.runs) == 1, f"instA runs={len(pA.runs)}"
pA.runs[0].text = pA.runs[0].text.replace(oldA, newA)
L("[1A] Susan->Avigail in validator paragraph (instance A)")

# Instance B (para 272): the OTHER Susan paragraph (stray truncated duplicate, lacks "This review ensured")
instB_idx = [i for i in susan_idxs if "This review ensured" not in paras[i].text]
assert len(instB_idx) == 1, instB_idx
pB = paras[instB_idx[0]]
assert pB.text.strip().endswith("prior to distribution."), repr(pB.text)
# DELETE the stray duplicate paragraph element
pB._p.getparent().remove(pB._p)
L(f"[1B] Deleted stray duplicate Susan paragraph (was para {instB_idx[0]})")

# ---------- 2) Qualitative paragraph (para 248): surveys -> interviews ----------
q_hits = find_para("structured survey questionnaires were used to collect", must_be_one=False)
assert len(q_hits) == 1, q_hits
pQ = paras[q_hits[0]]
newQ = (f"To address the qualitative aspect of the study, interviews were used to gather "
        f"respondents{APOS} views regarding the features and functionality of the developed "
        f"application. The qualitative data provided descriptive information that guided the "
        f"design and improvement of the application.")
assert len(pQ.runs) >= 1, f"qualitative runs={len(pQ.runs)}"
curQ = "".join(r.text for r in pQ.runs).strip()
assert curQ.startswith("To gather user input for the study, structured survey questionnaires"), repr(curQ)
set_para_text(pQ, newQ)
L(f"[2] Qualitative paragraph -> interviews (para {q_hits[0]})")

# ---------- 3) Acknowledgements panelists line: add em-dashes (para 61) ----------
ack_hits = find_para("To the panelists Mr. Jeoffrey", must_be_one=False)
assert len(ack_hits) == 1, ack_hits
pAck = paras[ack_hits[0]]
# Repurpose existing 6 runs (preserve bold formatting), set text, leave extras empty.
# r0 'To the '(F) r1 'panelists' r2 'Mr...MIS,'(T) r3 ' and '(F) r4 'Ms. Mary-Ann Mzana, MTS,'(T) r5 ' the researchers...'(F)
# Edit runs by matching their exact current text (robust to trailing/whitespace runs); preserves all formatting.
ack_edits = 0
for r in pAck.runs:
    t = r.text
    if t == "To the ":
        r.text = f"To the panelists {EM} "; ack_edits += 1
    elif t == "panelists":
        r.text = ""; ack_edits += 1
    elif t.startswith("Mr. Jeoffrey B. Layco, MIS, Mr. Shekiro R. Raposas, MTS, MIS,"):
        r.text = (f"Mr. Jeoffrey B. Layco, MIS, Mr. Shekiro R. Raposas, MTS, MIS, "
                  f"and Ms. Mary-Ann Mzana, MTS {EM}")
        ack_edits += 1
    elif t == " and ":
        r.text = ""; ack_edits += 1
    elif t == "Ms. Mary-Ann Mzana, MTS,":
        r.text = ""; ack_edits += 1
    # the ' the researchers expressed' run and any trailing empty run are left unchanged here
# clear any leftover pure-whitespace runs (e.g., a stray single-space run between 'panelists' and 'Mr.')
for r in pAck.runs:
    if r.text.strip() == "" and r.text != "":
        r.text = ""
assert ack_edits == 5, f"ack_edits={ack_edits} (run structure unexpected)"
ack_result = "".join(r.text for r in pAck.runs)
expected_ack = (f"To the panelists {EM} Mr. Jeoffrey B. Layco, MIS, Mr. Shekiro R. "
                f"Raposas, MTS, MIS, and Ms. Mary-Ann Mzana, MTS {EM} the researchers "
                f"expressed their gratitude for their time, effort, and constructive "
                f"feedback, which greatly contributed to improving the study.")
assert ack_result == expected_ack, f"MISMATCH:\n got: {ack_result!r}\n exp: {expected_ack!r}"
L(f"[3] Acknowledgements panelists em-dashes added (para {ack_hits[0]})")

# ---------- 4) Abstract: Seven -> Eight recommendations (para 54) ----------
abs_hits = find_para("Seven recommendations were identified for future development", must_be_one=False)
assert len(abs_hits) == 1, abs_hits
pAbs = paras[abs_hits[0]]
oldAbs = ("Seven recommendations were identified for future development, including UI/UX "
          "refinement, a backend API proxy, on-device AI, SQLite encryption, formal parsing "
          "evaluation, and a longitudinal study.")
newAbs = ("Eight recommendations were identified for future development: UI/UX refinement, "
          "formal parsing evaluation, a backend API proxy followed by a Google Play release, "
          "SQLite encryption, an on-device AI tier, payday-cycle budgeting, household and "
          "remittance features, and a longitudinal evaluation.")
assert oldAbs in pAbs.text, "abstract old sentence not found"
replace_in_para(pAbs, oldAbs, newAbs)
L(f"[4] Abstract Seven->Eight recommendations (para {abs_hits[0]})")

# ---------- 5) Recommendations: 7 -> 8 items ----------
rec_start_hits = find_para("1. Payday-cycle-aware budgeting. The researchers recommended", must_be_one=False)
assert len(rec_start_hits) == 1, rec_start_hits
rs = rec_start_hits[0]
recs = [paras[rs + k] for k in range(7)]
# sanity: they are the 7 numbered recs
for k, p in enumerate(recs):
    assert p.text.startswith(f"{k+1}. "), f"rec {k} unexpected: {p.text[:40]!r}"

items = [
    ("1. UI/UX refinement.",
     " The researchers recommended that the developers address the main usability concerns "
     "identified in the SUS evaluation: consistency (Q6), complexity (Q2), and the need for "
     "technical support (Q4). Specific improvements include simplifying navigation for "
     "first-time users, improving visual consistency across the 45 screens, and adding "
     "contextual help or tooltips to reduce the need for technical assistance."),
    ("2. Formal parsing evaluation.",
     " The researchers recommended that the developers conduct a formal evaluation of the AI "
     "parsing and OCR features using at least 50 standardized receipts and GCash screenshots, "
     "replacing the preliminary developer testing figures of 91.2% precision and 88.5% recall "
     "(Performance was assessed only through preliminary developer testing; no formal "
     "performance evaluation was conducted, which is why Recommendation 2 proposes one.) "
     "with results from a reproducible test protocol."),
    ("3. Backend API proxy and per-user keys.",
     " The researchers recommended that the developers move LLM API key management to a "
     "server-side proxy (e.g., Firebase Cloud Function) to remove device-side key exposure "
     "and enforce per-user message limits, because the free-tier request quotas (Table 3.2) "
     "were shared by every user of the prototype. Letting users add their own key was an "
     "interim measure. Google Play release. The researchers recommended that, after the "
     "backend proxy and a privacy policy were in place, the developers submit  SmartSpend to "
     "the Google Play Store, since the prototype was currently distributed as a downloadable "
     "APK."),
    ("4. SQLite encryption.",
     " The researchers recommended that the developers implement SQLCipher-based encryption "
     "for the local database in a future schema migration, because the local database of the "
     "prototype was not encrypted."),
    ("5. On-device AI tier.",
     " The researchers recommended that the developers add  an opt-in on-device model (e.g., "
     "Gemma 4 E2B through Google's LiteRT-LM, about a 2.6 GB download) for users who wanted "
     "fully offline AI, routing only simple logging tasks to it and keeping complex financial "
     "advice on the cloud tier, because the current local AI mode required a separate "
     "computer on the same network."),
    ("6. Payday-cycle-aware budgeting.",
     " The researchers recommended that the developers implement budgeting resets aligned "
     "with the semi-monthly (15th and 30th) salary cycle common in the Philippines."),
    ("7. Household and remittance features.",
     " The researchers recommended that the developers add  shared couple and family wallets "
     "and inbound OFW remittance tracking as a distinct income category to serve more user "
     "groups."),
]
# rewrite the 7 existing rec paragraphs (run0 = bold lead, run1 = non-bold body; clear any extras)
for k, (lead, body) in enumerate(items):
    p = recs[k]
    assert len(p.runs) >= 1, f"rec {k} no runs"
    assert p.runs[0].bold is True, f"rec {k} lead not bold"
    p.runs[0].text = lead
    if len(p.runs) >= 2:
        p.runs[1].text = body
    else:
        p.add_run(body)
    for r in p.runs[2:]:
        r.text = ""
L("[5a] Rewrote rec paragraphs 1-7")

# Insert item 8 after the last rec paragraph (deepcopy to preserve pPr + run formatting)
last_rec = recs[6]
new_p_el = deepcopy(last_rec._p)
last_rec._p.addnext(new_p_el)
new_para = Paragraph(new_p_el, last_rec._parent)
assert len(new_para.runs) >= 1, f"new rec runs={len(new_para.runs)}"
assert new_para.runs[0].bold is True, "new rec lead not bold"
new_para.runs[0].text = "8. Longitudinal evaluation."
body8 = (
    " The researchers recommended that future researchers measure  SmartSpend's effect on "
    "financial behavior over three to six months with a larger sample, because the usability "
    "evaluation in this study measured usability at a single point in time.")
if len(new_para.runs) >= 2:
    new_para.runs[1].text = body8
else:
    new_para.add_run(body8)
for r in new_para.runs[2:]:
    r.text = ""
L("[5b] Inserted rec item 8 (Longitudinal evaluation)")

# ---------- 6) Table 2.1 restructure (table index 2) ----------
tbl = doc.tables[2]
# verify it's the respondents table
assert tbl.rows[0].cells[0].text.strip().startswith("Category"), tbl.rows[0].cells[0].text
assert "Parents" in tbl.rows[1].cells[0].text

def set_cell(cell, text, bold=None):
    # keep only first paragraph, preserve its pPr; clear runs; add one run
    tc = cell._tc
    paras_in = cell.paragraphs
    for pa in paras_in[1:]:
        pa._p.getparent().remove(pa._p)
    first = cell.paragraphs[0]
    for r in list(first.runs):
        r._r.getparent().remove(r._r)
    run = first.add_run(text)
    if bold is not None:
        run.bold = bold
    return run

# Target rows (FINAL structure minus Technical Validator row; Total Validators = 1)
ENDASH = "\u2013"
target = [
    ("Category:", True, "Number of Respondents:", True),
    (f"Parents (Ages 35{ENDASH}55)", None, "13", None),
    (f"Young Professionals (Ages 21{ENDASH}35)", None, "14", None),
    ("Both Groups", None, "3", None),
    ("Total", True, "30", None),
    ("Validators / Experts:", True, "Number of Validators/Experts:", True),
    ("Content Validator (Survey)            ", None, "1", None),
    ("Total Validators", True, "1", None),
    ("SUS evaluation sample:", None, "", None),
    ("  Parents (35-55)", None, "10", None),
    ("  Young Professionals (21-35)", None, "20", None),
    ("  Total", None, "30", None),
]

# rewrite existing 7 rows to target rows 0-6
existing_rows = tbl.rows
assert len(existing_rows) == 7, f"table2 rows={len(existing_rows)}"
for ri in range(7):
    c0, b0, c1, b1 = target[ri]
    set_cell(existing_rows[ri].cells[0], c0, b0)
    set_cell(existing_rows[ri].cells[1], c1, b1)
# append target rows 7-11 (5 new rows)
for ri in range(7, len(target)):
    c0, b0, c1, b1 = target[ri]
    nr = tbl.add_row()
    set_cell(nr.cells[0], c0, b0)
    set_cell(nr.cells[1], c1, b1)
L(f"[6] Table 2.1 restructured to {len(target)} rows (Parents 13, Both Groups 3, Total Validators 1, no Technical Validator)")

# ---------- Figures & certificates: ALREADY PRESENT in V4 -> verify, do NOT duplicate ----------
def has_img(para):
    return bool(para._p.findall('.//' + qn('w:drawing'))) or bool(para._p.findall('.//' + qn('w:pict')))
# verify the 3 figure captions each have a preceding image, and certs present
fig_caps = {"Figure 3.12": False, "Figure 3.13": False, "Figure 3.14": False}
for i, p in enumerate(paras):
    for fc in fig_caps:
        if p.text.startswith(fc + ".") and "SUS" in p.text or p.text.startswith(fc + ".  ") or (p.text.startswith(fc) and "Demographic" in p.text):
            if i > 0 and has_img(paras[i-1]):
                fig_caps[fc] = True
# simpler robust check: image-bearing paras near each caption
def img_before_caption(cap_prefix):
    for i, p in enumerate(paras):
        if p.text.startswith(cap_prefix) and i > 0 and has_img(paras[i-1]):
            return True
    return False
fig_ok = all(img_before_caption(fc) for fc in ["Figure 3.12", "Figure 3.13", "Figure 3.14"])
# certificates: image present in appendix D and E regions
def img_in_appendix(heading):
    for i, p in enumerate(paras):
        if p.text.strip() == heading and i+1 < len(paras):
            # find next image within 3 paras
            for j in range(i+1, min(i+4, len(paras))):
                if has_img(paras[j]):
                    return True
    return False
cert_ok = img_in_appendix("Content Validation Certificate (Survey Questionnaire)") and \
          img_in_appendix("Content Validation Certificate (FHS Formula and Literature)")
L(f"[7/8] Figures 3.12/3.13/3.14 present-with-image: {fig_ok}; certificates present-with-image: {cert_ok}")
L("      (Already embedded in V4 — not re-embedded to avoid duplicates.)")

# ---------- save ----------
doc.save(OUT)
L("SAVED:", OUT)
# write log
with open(r"c:\xampp\htdocs\smartspend_app\.agents\tasks\v4-fixguide\apply_log.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(log))
