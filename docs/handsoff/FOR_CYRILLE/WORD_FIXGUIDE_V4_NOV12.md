# SmartSpend — Word Fix Guide (V4 → FINAL)

**Defense: November 16, 2026**

**Source working file (Maam Ellen's group — keep untouched as backup):**
`c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx`

**New FINAL (V4 with Kiro's automated fixes already applied — edit THIS file from here):**
`c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx`

The new FINAL is built directly from V4's content, so its page numbers and paragraph
text match V4. Kiro read V4 with python-docx, applied the fixes below to it in memory,
and saved the result to the new FINAL path above. The original V4 file was **never
modified** — it stays as the backup.

> Open the file in **Microsoft Word only** (not LibreOffice/Google Docs — they break
> the embedded images and table formatting). Page numbers cited below are estimates
> from V4's Table of Contents; scroll to confirm exact spots.

---

## How to use this guide

- **DONE — Kiro automated these:** already in the new FINAL. Do not redo them. If you
  spot a problem in one of these, tell Kiro rather than editing blindly.
- **Remaining manual fixes:** grouped by priority. 🔴 = Maam Ellen flagged these (do
  first), 🟡 = data accuracy (confirm before changing), 🟢 = polish.
- Use **Ctrl+H** (Find & Replace) for the `FIND` / `REPLACE` pairs. Copy the text
  exactly, including punctuation. For table edits, follow the click-steps.

---

## ✅ DONE — Kiro automated these (already in the new FINAL)

1. **Susan C. Arquisal → Avigail Candevario, PFMe.** The validator paragraph
   (~Research Methodology, p. 30–31) now reads "reviewed by Avigail Candevario, PFMe, a
   subject matter expert in financial management and business operations." A stray
   duplicate of the old Susan sentence that sat in the Data Gathering Tools section
   was deleted (it was a misplaced copy not present in the reference doc).
2. **Table 2.1 — Distribution of Respondents and Validators** (p. ~31) restructured:
   - Parents (Ages 35–55): **16 → 13** (actual data)
   - Added **Both Groups: 3** and a needs-assessment **Total: 30**
   - **Total Validators: 1** (Avigail only — per Maam Ellen "wala po" / "pinag isa
     nalang"; no separate technical validator)
   - No "Technical Validator (System & SUS Process)" row
3. **Qualitative = interviews** (Research Design, p. ~26–28). The qualitative paragraph
   now says "interviews were used to gather respondents' views…" (per Maam Ellen:
   "qualitative e yng interview"). It previously said survey questionnaires.
4. **Acknowledgements panelists em-dashes** (front matter, p. ~iii): the panelist names
   are now wrapped in em-dashes — "To the panelists — Mr. Jeoffrey B. Layco, MIS,
   Mr. Shekiro R. Raposas, MTS, MIS, and Ms. Mary-Ann Mzana, MTS — the researchers…"
5. **Recommendations expanded 7 → 8** (Chapter IV, p. ~75). UI/UX refinement is now #1
   and Formal parsing evaluation is #2; the Google Play release was merged into the
   Backend API proxy item (#3); the rest renumbered 4–8.
6. **Abstract: Seven → Eight recommendations** (Abstract, p. ~viii). Now reads "Eight
   recommendations were identified for future development: UI/UX refinement, formal
   parsing evaluation, a backend API proxy followed by a Google Play release, SQLite
   encryption, an on-device AI tier, payday-cycle budgeting, household and remittance
   features, and a longitudinal evaluation."
7. **Figures 3.12, 3.13, 3.14** — verified already embedded in V4 with intact images
   (each sits immediately before its caption in the SUS results section). They were
   **not** re-embedded, because re-embedding would create duplicate charts. Visually
   confirm they render (not broken/placeholder) when you open the file — see Manual
   Task V1.
8. **Appendix D & E certificate images** — verified already embedded in V4 with intact
   images. Not re-embedded (would duplicate). See Manual Task V1 to confirm they render.
9. **Objectives** — left **unchanged**. Maam Ellen's shortened objectives (V4's version)
   were kept on purpose; they were NOT replaced with the longer version.
10. **Protected values verified intact:** SUS 61.83 (SD 17.58), N = 30, Grade D,
    adjective "OK", Objective 3 "partially achieved", demographics 13 parents + 14 YP
    + 3 both = 30, SUS sample 10 parents + 20 YP = 30, AI intent 96.7% (29/30), GCash
    93.3%, validator Avigail Candevario PFMe, and all four names (Jeoffrey B. Layco MIS,
    Shekiro R. Raposas MTS/MIS, Mary-Ann Mzana MTS, Ellen Flores Mangaoang DIT).

---

# Remaining MANUAL fixes

## 🔴 Maam Ellen — do these first

### Fix M1 — Resolve the "interviews vs. no interviews" contradiction [Priority: 🔴]

**Where:** Chapter III, SUS / user-feedback results section (p. ~70–72) — the paragraph
that currently says no interview data was collected. This contradicts the qualitative
paragraph Kiro already fixed (which now says interviews were used, per Maam Ellen).

**Background:** Maam Ellen said "qualitative e yng interview," and you replied "noted po
maam," so the qualitative paragraph now says interviews were used. But another paragraph
still says **"no open-ended or interview data were collected."** These two cannot both
be true. You must confirm which is correct, then make them agree.

**Step 1 — Confirm with Maam Ellen:** Were interviews actually conducted?
- If **YES** (interviews were the qualitative method) → do Option A below.
- If **NO** (only the structured survey was used) → tell Kiro; the qualitative paragraph
  may need to be reworded instead. Do **not** proceed with Option A unless interviews
  were really conducted.

**Step 2 (Option A — interviews WERE conducted):**
- **FIND:** `No formal open-ended Survey data was collected. The study used a structured quantitative survey instrument, and no open-ended or interview data were collected.`
- **REPLACE:** `The structured quantitative survey instrument captured the measurable data, while the interviews captured respondents' open-ended views on the features and functionality of the application.`
  (Adjust wording to match what you actually did. The point: remove "no interview data were collected.")

**Step 2 (Option B — only surveys were used):** Stop and confirm with Maam Ellen before
changing anything, because the qualitative paragraph already says interviews.

---

### Fix M2 — Remove the false "separate IT expert / Technical Validation Certificate" sentence [Priority: 🔴]

**Where:** Research Methodology, Population & Validators paragraph (p. ~31).

**Background:** Maam Ellen confirmed there is **no separate technical validator**
("wala po"; "pinag isa nalang"). Avigail Candevario, PFMe is the single validator, and
she covers the survey (Appendix D) and the FHS formula (Appendix E). There is **no**
"Technical Validation Certificate." But one paragraph still claims a separate IT expert
reviewed the SUS process and the system, documented in a "Technical Validation
Certificate." This is false and now contradicts Table 2.1 (Total Validators = 1).

**How:** Ctrl+H
- **FIND:** `The System Usability Scale (SUS) evaluation process and the overall technical functionality of the SmartSpend system was reviewed by a subject matter expert in information technology, whose qualifications were documented in the Technical Validation Certificate. This expert validation covered both the correctness of the SUS evaluation process and an independent assessment of the system's core technical features.`
- **REPLACE:** (leave blank — delete these two sentences)
  OR, if you prefer to keep a sentence there:
- **REPLACE:** `The System Usability Scale (SUS) evaluation process and the Financial Health Score formula were reviewed by the same content validator, Avigail Candevario, PFMe (Appendices D and E).`

After this, the paragraph should name only Avigail as the validator, matching Table 2.1.

---

### Fix M3 — Confirm Maam Ellen's shortened objectives are in place [Priority: 🔴 — verify only]

**Where:** Chapter I, Statement of Objectives (p. ~15).

**What:** Maam Ellen said "inedit ko dn yng sa objectives, ang haba" — she shortened the
objectives. Kiro **kept V4's version on purpose** and did not replace it with the longer
one. No edit needed — just **verify** the objectives are the short three-item version
(General aim + "Specifically, this study achieved the following:" + objectives 1–3).
If they look long, they are Maam Ellen's; leave them.

---

### Fix M4 — Verify the parents count is 13 everywhere [Priority: 🔴 — verify only]

**Where:** Table 2.1 (p. ~31, fixed) and the Population & Locale body text (p. ~28–30).

**What:** Maam Ellen asked "ilan lahat ang parents?" → answer is **13**. Kiro set Table 2.1
to 13 and the body already says "Thirteen (13) respondents were parents." Do a Ctrl+F for
`parents` and skim — every mention of the parents count should be 13 (not 16, not 20).
The 20 figure belongs only to the **SUS sample** (10 parents + 20 young professionals),
which is a separate group — do not "fix" the 20.

---

## 🟡 Data accuracy — confirm before changing

### Fix D1 — Provider chain count in the Abstract [Priority: 🟡]

**Where:** Abstract (p. ~viii), the sentence describing SmartSpend's architecture.

**Background:** V4 says "six-provider AI failover chain." The reference doc says
"eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven
fallbacks)." **Confirm the app's actual provider count** (count the models marked
"Primary"/"Fallback" in the LLM comparison table — Table 3.2 / 2.2), then update the
abstract to match. The SUS values are unaffected either way.

- **FIND:** `a six-provider AI failover chain`
- **REPLACE:** `an eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks)`
  (Use this only if you confirm eight is correct. If the real count is six, leave V4's text as-is.)

---

### Fix D2 — Step 1: wrong appendix reference + grammar + missing FHS sentence [Priority: 🟡]

**Where:** Data Gathering Procedure, "Step 1: Questionnaire Preparation and Validation
(Objective 1)" (p. ~35).

**Background:** The survey certificate is **Appendix D** (not A), and the same validator
also reviewed the FHS formula (**Appendix E**) — this is the "pinag isa nalang" combine.
There is also a grammar slip ("was recorded" → "were recorded").

- **FIND:** `The expert's credentials was recorded in the Content Validation Certificate (Appendix A). Revisions were made based on the feedback before distribution.`
- **REPLACE:** `The expert's credentials were recorded in the Content Validation Certificate (Appendix D). The same content validator also reviewed the Financial Health Score formula (Appendix E). Revisions were made based on the feedback before distribution.`

---

### Fix D3 — Wrong table reference in Chapter I [Priority: 🟡]

**Where:** Chapter I, Project Context, end of the feature-comparison paragraph (p. ~8).

- **FIND:** `Table 2.1 summarized the key feature differences.`
- **REPLACE:** `Table 1.2 summarized the key feature differences.`
  (The feature-comparison table is Table 1.2, not Table 2.1. Table 2.1 is the
  respondents/validators table.)

---

### Fix D4 — Research-design label (optional, confirm with Maam Ellen) [Priority: 🟡]

**Where:** Research Methodology, Research Design (p. ~26).

**Background:** V4 says "mixed-methods developmental" and "adopted a developmental
research approach." The reference doc uses "mixed methods" and "descriptive-developmental."
This is a label choice. **Only change if Maam Ellen wants** "descriptive-developmental";
otherwise leave V4's "developmental" — it is not wrong.

- Option (only if confirmed):
  - **FIND:** `Moreover, this study also adopted a developmental research approach`
  - **REPLACE:** `Moreover, this study adopted a descriptive-developmental research approach`

---

## 🟢 Polish — style and small wording

### Fix P1 — Tense corrections [Priority: 🟢]

**Good news:** V4 is already at **tense parity** with the reference doc. An automated
sweep of all 547 items in the tense-corrections list found **0 missing** past-tense
fixes in V4 — every correction that applies is already applied. No tense pass is needed.
(If a panelist flags a specific tense issue, send it to Kiro with the sentence and it
will be fixed; do not blanket-convert, you may introduce errors.)

---

### Fix P2 — Acknowledgements wording (low priority) [Priority: 🟢]

**Where:** Acknowledgements (p. ~iii).

- (a) **FIND:** `their instructor in charge, Mr. Shekiro R. Raposas, MTS, MIS,`
- **REPLACE:** `their Capstone Teacher-in-Charge, Mr. Shekiro R. Raposas, MTS, MIS,`
- (b) **FIND:** `the College of Computer Studies and Engineering Department for equipping`
- **REPLACE:** `the College of Computer Studies and Engineering faculty for equipping`

---

### Fix P3 — Title-page adviser label (cosmetic, optional) [Priority: 🟢]

**Where:** Title page (p. i).

- **FIND:** `Ellen Flores Mangaoang, DIT`
- **REPLACE:** `Adviser: Ellen F. Mangaoang, DIT`
  (Only if your school's format wants the "Adviser:" label. Both name forms are
  acceptable; do not change the name itself.)

---

### Fix P4 — Add the "purposive sampling" sentence to the Abstract (optional) [Priority: 🟢]

**Where:** Abstract (p. ~viii), first methodology sentence.

**Background:** The reference doc adds one sentence ("Purposive sampling was used to
select 30 respondents…"). V4's abstract omits it, though the body already says purposive
sampling was used. Optional — add for completeness.

- **FIND:** `The study employed a mixed-methods developmental research design. A validated survey questionnaire was administered`
- **REPLACE:** `The study employed a mixed-methods, developmental research design. Purposive sampling was used to select 30 respondents from the target population. A validated survey questionnaire was administered`

---

## ✋ Do-NOT-do notes (protect V4's good content)

- **Do NOT** replace V4's quantitative/SUS-protocol paragraph (Research Design, the long
  "On the other hand, the quantitative aspect…" paragraph) with the reference doc's
  version. The reference doc's version ends in a broken sentence. V4's is clean and
  complete.
- **Do NOT** expand the Population & Locale section to match the reference doc's long
  version. Maam Ellen preferred trimming ("ang haba"); V4's concise version is correct.
- **Do NOT** re-embed Figures 3.12/3.13/3.14 or the certificate images — they are already
  in the document. Re-embedding creates duplicates.
- **Do NOT** change any protected value (see list below).

---

## Manual verification task

### Task V1 — Visually confirm figures & certificates render [Priority: 🟢]

Open the new FINAL and scroll to:
- **SUS results section:** Figures 3.12 (SUS Score Distribution), 3.13 (SUS Scores by
  Respondent Group), and 3.14 (Demographic Distribution). Each chart should appear
  right above its caption and render cleanly (not a broken-image icon or blank box).
- **Appendix D** and **Appendix E:** the certificate images should be visible and
  readable.

If any image shows as broken/blank: Insert → Pictures → from
`FOR_CYRILLE\FIGURES\`:
- `Figure_SUS_Distribution.png` → Figure 3.12 spot
- `Figure_SUS_Subgroup.png` → Figure 3.13 spot
- `Figure_Demographic_Breakdown.png` → Figure 3.14 spot
- `FIGURES\certificates\AppendixD_Survey_Questionnaire_Certificate.jpg` → Appendix D
- `FIGURES\certificates\AppendixE_FHS_Formula_Certificate.jpg` → Appendix E

(Kiro confirmed all five images are present with valid file links, so this is just a
visual sanity check.)

---

## 🔒 Protected values — do NOT change any of these

| Value | Where |
|-------|-------|
| SUS mean **61.83**, SD **17.58**, **N = 30** | SUS results, Table 3.3/3.4 |
| Grade **D**, adjective **OK** | SUS interpretation |
| Objective 3 = **"partially achieved"** | Chapter III results + Chapter IV |
| Needs-assessment demographics: **13 parents + 14 YP + 3 both = 30** | Table 2.1 + body |
| SUS-sample demographics: **10 parents + 20 YP = 30** (separate group) | Table 2.1 + Figure 3.13/3.14 |
| AI intent **96.7% (29/30)**; GCash **93.3%** | Needs-assessment results |
| Validator = **Avigail Candevario, PFMe** (sole validator) | Chapter II + Step 1 |
| Jeoffrey B. Layco **MIS**; Shekiro R. Raposas **MTS, MIS**; Mary-Ann Mzana **MTS**; Ellen Flores Mangaoang **DIT** | Title/approval/ack |

---

*Guide generated by Kiro — built from V4. The new FINAL at
`FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx` has all "DONE" items applied; apply the
manual fixes above to that file.*
