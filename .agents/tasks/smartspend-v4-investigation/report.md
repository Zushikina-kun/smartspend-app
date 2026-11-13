# SmartSpend V4(2) Manuscript — Investigation Findings Report

**Status:** READ-ONLY investigation. Nothing was edited. Findings only.
**Date:** Investigation run prior to any editing of the V4 main manuscript.
**Scope:** Analyze the new V4(2) manuscript against the LigTask reference and Ma'am Ellen's recorded instructions, to produce a complete, prioritized findings list before editing begins.

---

## 1. Summary (headline findings)

**The V4(2) manuscript is not a clean, finalized draft.** Despite being the newest file
(`docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (2).docx`, 768 paragraphs, 8 tables,
35 embedded images), it still contains numerous **unfilled placeholders and leftover
self-instructions** — blank fields, ALL-CAPS prompts-to-self ("EXPLAIN WHAT DID IN THE
DESIGN AND DEVELOPMENT", "fIGURE 3 PRESENTS THE DASHBOARD OF SMARTSPEND. WHAT? HOW TO
USE", "Ano meaning ng 7"), an **incomplete Conclusions section** (only Objective 2 is
written), and **figures with no descriptions**. These must be resolved before anything
else, because they make the document unreadable as-is.

Beyond the placeholders, three categories of substantive issues remain:

1. **Factual contradictions Ma'am Ellen already ruled on** — the validator identity
   ("Susan C. Arquisal" still appears at ¶250 and a blank-name duplicate at ¶265, while
   the correct "Avigail Candevario, PFMe" appears at ¶254) and the false
   "Technical Validation Certificate / IT expert" sentence (¶254) are all still present.
   Table 2.1 still shows **Parents = 16** (should be 13, per the body text at ¶248).

2. **The figure/table scheme is the opposite of what was requested.** V4(2) uses
   **chapter-prefixed** numbering (Figure 1.1, 1.2, 2.1, 2.2, 3.1…3.14; Table 1.1…3.4),
   while LigTask — the required style guide — uses **continuous** numbering (Figure 1–18,
   Table 1–17), which is exactly what the user asked for ("table and figure numbering are
   continuous, only 12345 onwards, no 1.1, 1.2, 2.1"). A full renumber is needed, plus
   regenerating the List of Figures and List of Tables (both are currently stale and
   inconsistent with the body).

3. **LigTask-style writing gaps** — Population & Locale (¶244–255) is a broken placeholder
   needing a full rewrite in LigTask's prose style; most Chapter III figures (3.1–3.10)
   have image + caption but **no descriptive text** (LigTask describes every figure); the
   Technical Background (¶220–234) is far more granular/technical than LigTask's concise
   per-tool paragraphs and should be condensed.

**Three decisions need the user before final edits** (flagged CONFIRM in §9): whether
interviews were actually conducted (the qualitative/interviews contradiction), the AI
provider count (six vs eight), and the recommendation count (seven vs eight).

---

## 2. What was read (evidence base)

- **V4(2) manuscript** — `docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (2).docx`.
  Full text extracted with python-docx (paragraphs with style + image markers, all 8
  tables). Dump: `.agents\tasks\smartspend-v4-investigation\V4_2_dump.txt`; structural
  summary: `V4_2_structure.txt`. Paragraph indices cited below as **¶NNN** match the
  `[NNNN]` lines in that dump.
- **LigTask reference** — `docs\manuscript\templates\Reference_LigTask_Manuscript.md`
  (full markdown conversion of the LigTask capstone manuscript). Read in full.
- **Prior analysis** — `.agents\tasks\v4-fixguide\analysis.md` (a V4(1)-vs-FINAL diff).
  Used only as orientation; all findings below were re-verified against V4(2) directly.

The LigTask reference patterns the user wants followed (verified from the .md):
continuous figure/table numbering; Population & Locale as flowing prose (named locale,
total spelled out, breakdown, "as presented in table X", sampling method, role of each
group); concise per-tool paragraphs in Technical Background (Unity / Figma / IbisPaint /
SQLite) plus tool mention again in Data Gathering; a description paragraph for every
figure; Results and Conclusions organized by objective.

---

## 3. Critical: unfilled placeholders and leftover self-instructions

These are the highest-priority items — the document literally contains unfinished
prompts. Each must be filled or removed.

| ¶ | Exact text in V4(2) | Issue |
|---|---|---|
| **245** | "The study was conducted in San Fernando City, La Union. There are a total of **__** respondents which comprise parents aged 35 to 55, young professionals aged 21 to 35, 1 content validator as seen in **Table _**" | Two blank fields (`__`, `Table _`) + present tense "There are". This is the Population & Locale opening sentence — never completed. |
| **263** | "For the second objective, the results obtained from the first objective served as the primary basis for system design and implementation. **Discuss how system was developed and tools**" | Raw instruction-to-self left in the body; the objective-2 data-gathering paragraph is unfinished. |
| **265** | "The survey questionnaire was reviewed by **,** a graduate of Bachelor of Science in Commerce major in Management…" | Validator **name is blank** (stray duplicate of ¶250 with the name deleted). |
| **270** | "…followed the Agile Kanban Software Development Methodology **as seen in Figure #**." | Placeholder figure reference (should point to the Kanban workflow figure). |
| **300** | "Designed and Developed of the SmartSpend Mobile Application **- see objective**" | Section heading with a leftover note. |
| **302** | "**EXPLAIN WHAT DID IN THE DESIGN AND DEVELOPMENT**" | ALL-CAPS placeholder; the objective-2 opening paragraph was never written. |
| **323** | "**DISCUSSION**" | Bare placeholder heading (between Figure 3.2 and Figure 3.3). |
| **338 / 339** | "**DESCRIPTION**" then "**fIGURE 3 PRESENTS THE DASHBOARD OF SMARTSPEND. WHAT? HOW TO USE**" | Placeholder for the Figure 3.5 (Home Dashboard) description, never written, in mixed case. |
| **357** | "**Ano meaning ng 7**" | Leftover question-to-self ("what is the meaning of 7?") before the Overall SUS table. |
| **374** | "**SmartSpend**" | Orphan fragment inside the Conclusions section (see §7). |

**Recommendation:** Fill every blank, replace every ALL-CAPS/placeholder prompt with
real prose, and delete the orphan fragments. Several of these (¶245, ¶263, ¶302, ¶338/339)
are not small typos — they are missing content paragraphs that must be authored.

---

## 4. Validator identity — contradictions Ma'am Ellen already resolved

Ma'am Ellen's chat is explicit: there is **no separate technical validator**; the SUS
results stand alone, and Avigail Candevario (PFMe) is the single content validator
("pinag isa nalang"). V4(2) does not yet reflect this.

- **Susan C. Arquisal still present** at **¶250**: "The survey questionnaire was reviewed
  by **Susan C. Arquisal, a graduate of Bachelor of Science in Commerce major in
  Management and an active business owner…**" This is the wrong/old name and must be
  replaced by Avigail Candevario, PFMe.
- **Blank-name duplicate** at **¶265** (see §3) — a truncated copy of the Susan sentence
  with the name removed. Should be deleted entirely (it duplicates the validator sentence).
- **Correct name appears at ¶254** ("Avigail Candevario, PFMe, a subject matter expert in
  financial management and business operations") — but the same paragraph then adds the
  **false technical-validator sentence**: *"The System Usability Scale (SUS) evaluation
  process and the overall technical functionality of the SmartSpend system was reviewed
  by a subject matter expert in information technology, whose qualifications were
  documented in the Technical Validation Certificate. This expert validation covered both
  the correctness of the SUS evaluation process and an independent assessment of the
  system's core technical features."* No such IT expert or "Technical Validation
  Certificate" exists (Appendix D = survey cert, Appendix E = FHS cert). **Remove this
  sentence** so Avigail is the sole validator.
- **Table 2.1 (table index 2)** has no technical-validator row (correct) — but it still
  shows **Parents (Ages 35–55) = 16** (row R1). The body text at ¶248 gives the true
  figure: "Thirteen (13) respondents were parents… Fourteen (14)… Three (3) identified
  as both." The table must read **13**, and it is missing the **Both Groups = 3** row and
  the SUS-sample breakdown that ¶252/¶297 reference.

**Recommendation:** Replace Susan → Avigail everywhere; delete the ¶265 duplicate; delete
the false technical-validator sentence at ¶254; fix Table 2.1 (Parents 16→13, add Both
Groups = 3, optionally add the SUS-sample rows). This makes table and body consistent and
matches Ma'am Ellen's "no separate technical validator."

---

## 5. Qualitative aspect — the "interviews vs surveys" contradiction (CONFIRM)

Ma'am Ellen (chat): "qualitative e yng interview" — the qualitative aspect is the
interview. The user replied "noted po ma'am." But the manuscript currently treats
qualitative as **survey-derived**, and the three relevant paragraphs contradict each
other:

- **¶240** (Research Design): "structured **survey questionnaires** were used to collect
  respondents' views regarding the features and functionality… The survey responses
  provided descriptive information…" — i.e., qualitative = surveys.
- **¶262** (Data Gathering): "**No surveys were conducted;** qualitative insights…
  were derived from the survey responses." — internally contradictory ("no surveys" then
  "from survey responses") and says surveys.
- **¶366** (Results): "No formal open-ended Survey data was collected… **no open-ended or
  interview data were collected.**" — explicitly states **no interviews** were done.

If interviews were **not** actually conducted, then Ma'am Ellen's correction rested on a
misunderstanding and the manuscript's "survey-derived qualitative" framing should stay
(but ¶262's "No surveys were conducted" must be fixed and the three paragraphs reconciled
to agree). If interviews **were** conducted, all three paragraphs must be rewritten to say
interviews were used, and an interview instrument/transcript appendix would be expected.

**This is the single most important decision for the user to make before editing** — it
changes content in three places and determines whether an appendix is needed. Flagged
CONFIRM in §9.

---

## 6. Population & Locale — rewrite in LigTask style (¶244–255)

LigTask's Population and Locale is a single flowing passage: it names the locale, spells
out the total ("one hundred sixty-two (162)"), gives the group breakdown, says
"as presented in table 1 (page 15)", then describes the sampling method and the role of
each respondent group. V4(2)'s version is the opposite: a broken one-sentence opener
with blanks (¶245, see §3), a validator sentence with the wrong name (¶250), a duplicate
validator sentence (¶254), and a sampling paragraph (¶255) that repeats "purposive
sampling" already stated at ¶248.

**Recommendation:** Rewrite ¶244–255 as one LigTask-style prose passage: locale
(San Fernando City, La Union) → total "thirty (30)" with breakdown (13 parents, 14 young
professionals, 3 both) → "as presented in Table X" (renumbered, see §8) → sampling method
(purposive) → role of each group → single validator sentence (Avigail). Remove the
duplicate validator sentences. Past tense throughout.

---

## 7. Conclusions section is incomplete (¶371–374)

LigTask's Conclusions are written **per objective** ("For the first objective…", "For the
second objective…", "For the third objective…"). V4(2) has only the **second-objective**
conclusion:

- **¶372** is blank; **¶373** = the Objective-2 conclusion ("SmartSpend v3.1.0 was
  developed… Therefore, the second objective… was achieved.") — and only this one.
- **¶374** = the orphan fragment "SmartSpend" (see §3).

The **Objective 1** conclusion (needs-assessment findings, 96.7% positive intent, GCash
93.3%) and the **Objective 3** conclusion (SUS 61.83, below target, "partially achieved"
per ¶367) are **missing entirely**.

**Recommendation:** Add Objective-1 and Objective-3 conclusion paragraphs in the LigTask
"per objective" form; delete the "SmartSpend" fragment at ¶374. (The raw material exists:
¶299 states Objective 1 was achieved; ¶367 states Objective 3 was *partially* achieved.)

---

## 8. Figure & Table numbering — convert to continuous, fix the stale lists

**Current scheme (chapter-prefixed), from the List of Figures (¶126–148) and List of
Tables (¶151–163):**
- Figures: 1.1, 1.2, 2.1, 2.2, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11,
  3.12, 3.13, 3.14 (17 listed).
- Tables: 1.1, 1.2, 2.1, 2.2, 3.1, 3.2, 3.3, 3.4, 3.5 (9 listed).

**Required scheme (continuous, per user + LigTask):** Figure 1, 2, 3…; Table 1, 2, 3…
with no chapter prefix.

**The lists are also stale / inconsistent with the body and must be regenerated:**
- **List of Tables** lists **Table 3.5 — "SmartSpend Multimodal Import: Field-Level
  Parsing Performance"** (¶162–163), but **no such table exists** (the doc has exactly 8
  tables, ending at 3.4). Stale entry — remove. The List of Tables also gives Table 2.2
  the title "Comparative Evaluation of LLM APIs" (¶155), but the actual Table 2.2 in the
  body (¶283) is **"Agile Kanban Workflow Phases and Deliverables"** — the LLM-APIs table
  is Table 3.2 (¶304). So the list mislabels 2.2.
- **List of Figures** lists **Figure 3.12 ("SUS Score Distribution") and Figure 3.13
  ("SUS Scores by Respondent Group")** (¶145–146), but **neither caption appears in the
  body.** The chart images are embedded (¶354, ¶355, ¶362) but **uncaptioned** — the SUS
  charts are present but unlabeled, so the body never references 3.12/3.13 by caption.
- **Figure 3.14 ("Demographic Distribution")** is captioned at **¶296**, but it appears
  **inside the Objective-1 results**, *before* Figure 3.1 (¶319) — i.e., it is numbered
  last but placed early. Under continuous renumbering it becomes an early figure
  (e.g., Figure 5), which fixes the out-of-order placement automatically.
- **Cross-reference errors in the body** (will need renumbering too):
  - **¶177**: "Table **2.1** summarized the key feature differences" — wrong; the feature
    comparison is Table 1.2 (caption at ¶180).
  - **¶444 / ¶445 / ¶446**: three near-identical notes citing "**Table 8**" — "Table 8"
    does not exist under any scheme (the SUS-by-group table is 3.4 / continuous). Stale
    reference repeated three times.

**Recommendation:** Renumber all figure and table captions and every in-text "Figure
X.Y" / "Table X.Y" reference to a single continuous sequence in document order; regenerate
the List of Figures and List of Tables from the final captions; add the missing captions
for the two SUS charts (or remove those charts — see §10); fix the Table 2.1→1.2 reference
at ¶177; replace the three "Table 8" notes (¶444–446) with the correct (renumbered) table
reference, keeping only one copy.

---

## 9. Missing figure descriptions / unnecessary figures (Chapter III)

LigTask gives **every** figure a caption **and** a descriptive paragraph explaining what
it shows. V4(2)'s Chapter III figures mostly have **image + caption only, no
description**:

- **¶319** Figure 3.1 System Flowchart — no description.
- **¶321** Figure 3.2 Use Case Diagram — no description.
- **¶325** Figure 3.3 Visual Table of Contents — no description (the following ¶326–332
  discuss development features, not the figure).
- **¶335** Figure 3.4 Login and Demo Mode — no description.
- **¶337** Figure 3.5 Home Dashboard — placeholder description (¶338–339, see §3).
- **¶341** Figure 3.6 Expense Logging Through Peso Chat — no description.
- **¶343** Figure 3.7 Receipt Scanning and Batch Screenshot Import — no description.
- **¶345** Figure 3.8 Financial Health Score Breakdown — no description.
- **¶347** Figure 3.9 Budgets, Safe-to-Spend, and Savings Goals — no description.
- **¶349** Figure 3.10 Local AI Mode Setup — no description.
- **¶356** Figure 3.11 SUS Computation Table — no description (and it is arguably a data
  table, not a figure).

The user's instruction was to **remove unnecessary figures/tables and simplify them into
sentences** where removed, and to **fill in descriptions** for figures that stay.
Standard development diagrams (system flowchart, use-case diagram, "visual table of
contents") are candidates for removal/condensing — LigTask carries only game/UI figures
with descriptions, not generic dev diagrams. Figure 3.11 (SUS Computation Table) is
really tabular data and could become a table or a sentence.

**Recommendation:** For each Chapter III figure, decide keep+describe, or remove and
condense into a sentence. For figures that stay, write a LigTask-style description
paragraph (what the screen shows, how it is used). Resolve the placeholder at ¶338–339.
Add captions for the two uncaptioned SUS charts (or remove them). This is the largest
content-authoring task in the revision.

---

## 10. Abstract inconsistencies

- **¶54** (abstract, last sentence): "Seven recommendations were identified for future
  development, including UI/UX refinement, a backend API proxy, on-device AI, SQLite
  encryption, formal parsing evaluation, and a longitudinal study." — says **seven** but
  lists only **six**, and the body (¶377–383) actually has **seven** recommendations
  (payday-cycle, backend proxy, Google Play, on-device AI, SQLite encryption, household &
  remittance, longitudinal). The abstract's list omits Google Play and payday-cycle.
  **CONFIRM (§13):** keep 7 (and fix the abstract list to match all 7) or adopt the 8-item
  version from the prior FINAL draft (adds UI/UX refinement + formal parsing evaluation).
  Per the user's "don't add more stuff," the safer path is keep 7 and make the abstract
  list all 7 — but this is the user's call.
- **¶53** (abstract): "a **six-provider** AI failover chain." The prior FINAL draft used
  "eight-provider." ¶227 (Technical Background) says "seven automatic fallback providers"
  plus the primary = eight total. **CONFIRM (§13):** the app's actual provider count
  (six vs eight). The body (¶227) reads as eight (1 primary + 7 fallbacks), so the
  abstract's "six" is likely the stale figure — verify against the app before changing.

---

## 11. Appendix labeling mismatch + empty Photo Documentation

- **Appendix labels disagree with the Table of Contents.** TOC (¶114–118) says:
  A = Survey Questionnaire, B = SUS Questionnaire, C = SUS Individual Scores, D = Survey
  cert, E = FHS cert. The **actual** appendices are: A = Survey Questionnaire (¶459),
  B = **Informed Consent Form** (¶606), C = **SUS Questionnaire** (¶632), D = Survey cert
  (¶674), E = FHS cert (¶677). So Appendix B and C are swapped vs the TOC, and the "SUS
  Individual Scores" appendix listed in the TOC does not exist. The body cross-reference
  at **¶264** ("SUS (see Appendix B)") is also wrong — the SUS questionnaire is Appendix C.
  **Recommendation:** Make the TOC match the actual appendices (or relabel the appendices)
  and fix the ¶264 cross-reference to Appendix C.
- **Photo Documentation (¶681)** is an empty heading — ¶682–686 are blank. LigTask has a
  populated photo-documentation section. **Recommendation:** either populate it with the
  defense/testing photos or remove the heading. (Given "don't add stuff," removing the
  empty heading is the lower-risk option unless photos are supplied.)

---

## 12. Other concrete errors

- **Citation URL error — ¶386:** "Ariely, D. (2008). Predictably irrational… HarperCollins.
  **https://www.anthropic.com/claude**" — the URL points to Anthropic's Claude, clearly a
  paste error. Fix or remove the URL.
- **Table 3.1 header row (table index 4, R0):** the row label "A. Demographic profile,
  f (%)" is repeated in all five columns — a malformed/merged header. Fix to a single
  header label.
- **Stray references out of place — ¶447–449:** Bangor et al. (2008), Deci & Ryan (2000),
  and Sauro & Lewis (2016) appear *after* the main reference list ends (¶433) and mixed in
  with the duplicated table notes — they should be folded into the alphabetical reference
  list.
- **¶308 / ¶311 FHS formula numbering:** ¶310 is item 1 (Savings Rate); ¶311 jumps
  straight into the body of item 2 (Overspend Control) with **no "2. Overspend Control"
  heading**, then ¶312 is item 3. Add the missing item-2 heading.

---

## 13. Tense — "proposed" → "developed" + remaining present-tense leaks

Ma'am Ellen: "basta bakapast tense na" and "yng proposed magiging developed." V4(2) is
largely past tense already, but specific leaks remain:

- **"proposed" instances to convert to "developed/was developed":**
  - **¶166** — "development of the **proposed** AI-powered financial assistant."
  - **¶184** — "This study **proposed** SmartSpend…" → "This study developed SmartSpend…"
  - **¶213** — "The **proposed** solution provided benefits…" → "The developed solution…"
- **Present/future-tense leaks in the narrative:**
  - **¶245** — "There **are** a total of __ respondents" (also a blank — see §3).
  - **¶209** — "Voice recognition accuracy **will be** affected by background noise" — a
    forward-looking limitation; reword to past/conditional ("would be affected") to match
    the past-tense narrative.
  - **¶329 / ¶330** — present tense describing live app behavior ("requests go through…",
    "The mascot has 12 animated moods… appears… changes…"). The prior V4(1) analysis
    judged these **intentional** (they describe the running application's live features,
    matching FINAL). **Recommendation:** leave the live-feature present tense, but make
    the surrounding study-narrative verbs past tense. Confirm consistency.

---

## 14. Technical Background — condense toward LigTask style (¶220–234)

LigTask's Technical Background is a short, plain paragraph per tool (Unity, Figma,
IbisPaint, SQLite) stating what each was used for. V4(2)'s Technical Background
(¶220–234) is far more granular — 14 subsections including package names/versions
(sqflite v11), schema details, routing logic, and the full FHS dual-mode design. The
user asked to "not make too much overly technical or detailed" content and to follow
LigTask's "just telling which tools they used and how they used them."

**Recommendation:** Condense to LigTask-style concise tool paragraphs (Flutter, SQLite,
Firebase Firestore/Auth/Crashlytics, LLM API, Speech-to-Text, ML Kit OCR, mobile_scanner,
fl_chart, local_auth). Move the detailed FHS dual-mode design content (¶234) into the
Chapter III FHS section where it is already discussed (¶307–313), and trim package-level
specifics. Keep enough to satisfy "which tools and how used" without the implementation
detail.

---

## 15. Confirmed already-correct items (no change needed)

To avoid re-editing things V4(2) already has right:
- **Results are organized by objective**, each ending with "These results showed that the
  X objective… was achieved" (¶299, ¶350) / "partially achieved" (¶367) — matches LigTask.
- **Objective-2 SUS exclusion logic** (¶352: 36 attempted, 30 valid, 5 insufficient time,
  1 straight-line bias) is consistent and well-stated.
- **SUS values are internally consistent**: 61.83 / SD 17.58 / N=30 / Grade D / "OK"
  (¶53, ¶359, Table idx 6, Table idx 7) — all agree.
- **Past tense is already applied** across most of the manuscript; the leaks above are
  the exceptions, not the rule.

---

## 16. Conclusions

V4(2) is the right "main" to finalize, but it is not yet finalizable as-is. The work
splits into three tiers:

- **Tier 1 — must fix before anything else (document is unfinished):** all §3
  placeholders/blanks, the incomplete Conclusions (§7), and the missing figure
  descriptions / placeholder caption (§9). These are authoring tasks, not edits.
- **Tier 2 — Ma'am Ellen's already-decided corrections:** validator identity (§4),
  Table 2.1 Parents 16→13 + structure, the false technical-validator sentence, the
  Ariely URL (§12), and the "proposed → developed" wording (§13).
- **Tier 3 — LigTask-style restructuring:** continuous figure/table renumbering + list
  regeneration (§8), Population & Locale rewrite (§6), Technical Background condensing
  (§14), appendix-label/TOC fix (§11), and removing/condensing unnecessary figures (§9).

No editing should begin until the three CONFIRM items (§9 references, plus §5, §10) are
answered by the user, because they change what gets written.

---

## 17. Recommendations to the user (prioritized, implement nothing here)

1. **Answer the three CONFIRM items first:**
   - **(CONFIRM-A, §5)** Were interviews actually conducted? This decides the
     qualitative framing in ¶240/¶262/¶366 and whether an interview appendix is needed.
   - **(CONFIRM-B, §10)** Recommendation count — keep 7 (fix abstract to list all 7) or
     adopt 8?
   - **(CONFIRM-C, §10)** AI provider count — six or eight? Verify against the running
     app (§14 Technical Background implies eight: 1 primary + 7 fallbacks).
2. **Resolve all §3 placeholders** (fill or delete) — the document cannot be reviewed
   with blanks and ALL-CAPS prompts remaining.
3. **Author the missing content:** Objective-1 and Objective-3 Conclusions (§7);
   descriptions for each kept Chapter III figure (§9); the objective-2 data-gathering
   paragraph (¶263) and objective-2 opening (¶302).
4. **Apply Ma'am Ellen's decisions:** Susan → Avigail; remove the technical-validator
   sentence; Table 2.1 Parents 16→13 + Both Groups row; "proposed → developed."
5. **Renumber figures/tables to continuous**, regenerate both Lists, fix the ¶177 and
   ¶444–446 cross-references, add/remove the two uncaptioned SUS charts (§8).
6. **Rewrite Population & Locale** in LigTask prose style (§6); **condense Technical
   Background** (§14); **fix appendix labels vs TOC** (§11); **remove empty Photo
   Documentation** or populate it (§11); fix the Ariely URL and Table 3.1 header (§12).

---

## Appendix: open decisions requiring user input (summary)

| ID | Location | Decision needed |
|----|----------|-----------------|
| CONFIRM-A | ¶240, ¶262, ¶366 | Were interviews conducted? (drives qualitative framing + possible appendix) |
| CONFIRM-B | ¶54, ¶377–383 | Recommendation count: 7 (fix abstract list) or 8 (adopt FINAL's two extra)? |
| CONFIRM-C | ¶53, ¶227 | AI provider count: six or eight? (verify against app) |
| DECIDE-D | §9, Figure 3.1/3.2/3.3 | Remove generic dev diagrams (flowchart, use-case, visual TOC) and condense to sentences, or keep + describe? |
| DECIDE-E | §9, Figure 3.11 | Keep "SUS Computation Table" as a figure, convert to a table, or condense to a sentence? |
| DECIDE-F | §11, ¶681 | Remove empty Photo Documentation heading, or populate with photos? |

*This report recommends fixes only; nothing was implemented.*
