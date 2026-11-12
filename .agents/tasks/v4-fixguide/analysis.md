# V4 vs FINAL — Difference Analysis (PART 1)

**V4** = `docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx` (796 paragraphs, 9 tables, 28 inline body images)
**FINAL** = `docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx` (775 paragraphs, 9 tables, 31 inline body images)
**Tense list** = `docs\handsoff\SmartSpend_Tense_Corrections_List.docx` (547 correction rows)

Classification key:
- **APPLY_TO_V4** — FINAL (or Maam Ellen) has the correct version; V4 needs updating.
- **ALREADY_IN_V4** — V4 already matches the target; no change needed.
- **MAAM_ELLEN_INSTRUCTION** — driven by a direct Maam Ellen chat instruction (top priority).
- **CONFIRM_NEEDED** — needs the user to supply data / make a product decision before the guide can be finalized.

> **Important framing found during analysis:** V4 is NOT a "behind" draft relative to FINAL. V4 has already absorbed the bulk of the past-tense conversion (it is at tense parity with FINAL — see Issue 12). Most of the 13 issues are small, localized content/structure fixes. Two issues (3 and 5/6) reveal that **FINAL itself is internally inconsistent** in places, so the guide must follow Maam Ellen's intent, not blindly copy FINAL. Those are flagged below.

---

## ISSUE 1 — Table 2.1 Parents count 16 → 13
**Classification: APPLY_TO_V4**

V4 Table 2.1 (table index 2) row 1 reads `Parents (Ages 35-55) || 16`. FINAL reads `Parents (Ages 35-55) || 13`.

V4's *body* already states the correct figure — para 254: "Thirteen (13) respondents were parents…" and para (Step 4): "(13 parents, 14 young professionals, and 3 who identified as both)". So the table is the only place that is wrong.

**FIND (V4 Table 2.1):** `Parents (Ages 35-55) | 16`
**REPLACE:** `Parents (Ages 35-55) | 13`

---

## ISSUE 2 — Table 2.1 missing "Both Groups" row
**Classification: APPLY_TO_V4**

V4 Table 2.1 has no "Both Groups" row. FINAL has `Both Groups || 3`. V4 body already mentions the 3 (para 254 "Three (3) respondents identified as both").

V4's Table 2.1 is structurally malformed — it mixes needs-assessment respondents, a validator, and the SUS sample under a single header with one `Total | 30` (which is actually the SUS-sample total). It needs restructuring to FINAL's three-section layout (see Issue 3, which restructures the whole table).

**Target table (full rebuild), per FINAL structure:**
```
Category                          | Number of Respondents:
Parents (Ages 35-55)              | 13
Young Professionals (Ages 21-35)  | 14
Both Groups                       | 3
Total                             | 30
Validators / Experts:             | Number of Validators/Experts:
Content Validator (Survey)        | 1
Total Validators                  | 1        ← see Issue 3 (FINAL says 2; use 1 per Maam Ellen)
SUS evaluation sample:            |
Parents (35-55)                   | 10
Young Professionals (21-35)       | 20
Total                             | 30
```

---

## ISSUE 3 — Table 2.1 "Technical Validator (System & SUS Process)" row
**Classification: MAAM_ELLEN_INSTRUCTION (overrides FINAL — flag CONFIRM_NEEDED on the body sentence)**

This is the most important finding. The chat record is unambiguous:
- Maam Ellen: "sino yng technical validator nyo ng system and sus process?" / "meron ba nito Technical Validator (System & SUS Process)"
- User: "need po ba maam? tbh wala po eeh pwede sus results nalang po ba directly?" / "parang ginawa namin same nadin po sa fhs validator maam, parang pinag isa nalang"

Net intent: there is **no separate technical validator**. The SUS results stand on their own; Avigail Candevario (PFMe) is the single validator who covers the survey (Appendix D) and the FHS formula (Appendix E). Protected value confirms: `Validator: Avigail Candevario, PFMe` (singular).

**Table fix (APPLY_TO_V4):** Do **not** add a "Technical Validator (System & SUS Process)" row. Set `Total Validators = 1`.

⚠️ **FINAL diverges from Maam Ellen here.** FINAL's Table 2.1 lists `Technical Validator (System & SUS Process) | 1` and `Total Validators | 2`. That is **not** the target — the guide must use **1** validator (per Maam Ellen), not FINAL's 2.

⚠️ **A related body sentence exists in BOTH V4 and FINAL and is false.** V4 para 261 (= FINAL para 259), in the Population/Validators paragraph, says:
> "The survey questionnaire underwent content validation by Avigail Candevario, PFMe… The System Usability Scale (SUS) evaluation process and the overall technical functionality of the SmartSpend system was reviewed by **a subject matter expert in information technology, whose qualifications were documented in the Technical Validation Certificate.** This expert validation covered both the correctness of the SUS evaluation process and an independent assessment of the system's core technical features."

The second sentence claims a separate IT expert and a "Technical Validation Certificate" that does not exist (appendices are D = Survey cert, E = FHS cert; there is no Technical Validation Certificate). Per Maam Ellen's "pinag isa nalang," this sentence should be **removed** (or reworded so Avigail is the sole validator). FINAL did **not** remove it — so FINAL is also wrong here.

**CONFIRM_NEEDED:** Removing that body sentence is the consistent reading of Maam Ellen's instruction, but it changes written content present in BOTH docs. Confirm the user wants it removed (recommended: yes, to match "no separate technical validator").

---

## ISSUE 4 — Susan C. Arquisal → Avigail Candevario, PFMe
**Classification: APPLY_TO_V4 (driven by MAAM_ELLEN_INSTRUCTION — "ano ang ginawa ni susan?" / user "alisin ko nalang")**

V4 contains "Susan C. Arquisal" in **two** places. FINAL has zero Susan instances (all replaced by Avigail Candevario, PFMe).

**Instance A — V4 para 256 (Population/Validators paragraph):**
- V4: "The survey questionnaire was reviewed by **Susan C. Arquisal, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with experience in financial management and business operations**, prior to distribution. This review ensured that the questions were appropriate, relevant, and grounded in the actual financial management experiences of the target population."
- FINAL (254): "The survey questionnaire was reviewed by **Avigail Candevario, PFMe, a subject matter expert in financial management and business operations**, prior to distribution. This review ensured that the questions were appropriate, relevant, and grounded in the actual financial management experiences of the target population."
- **FIND (V4):** `Susan C. Arquisal, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with experience in financial management and business operations`
- **REPLACE:** `Avigail Candevario, PFMe, a subject matter expert in financial management and business operations`
- (Rest of paragraph is identical — only the name/description clause changes.)

**Instance B — V4 para 272 (stray duplicate in the Data Gathering Tools section):**
- V4: "The survey questionnaire was reviewed by Susan C. Arquisal, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with experience in financial management and business operations, prior to distribution."
- This is a truncated duplicate of Instance A, misplaced. FINAL has **no** paragraph here (it goes straight from the Data-Gathering intro to "Step 1"). 
- **Action: DELETE this V4 paragraph (272) entirely.**

---

## ISSUE 5 — Qualitative aspect: "surveys" → "interviews"
**Classification: MAAM_ELLEN_INSTRUCTION / APPLY_TO_V4 — with a CONFIRM_NEEDED contradiction flagged**

Maam Ellen (chat, message #4): "qualitative e yng interview" (the qualitative aspect is the interview). The user accepted ("noted po maam").

V4 **does** have the qualitative sentence (contrary to Issue 6's premise "no qualitative sentence at all") — it just says "survey questionnaires" instead of "interviews":
- V4 para 248: "To gather user input for the study, structured survey questionnaires were used to collect respondents' views regarding the features and functionality of the developed application. The survey responses provided descriptive information that guided the design and improvement of the application."
- FINAL para 246: "To address the qualitative aspect of the study, interviews were used to gather respondents' views regarding the features and functionality of the developed application. The qualitative data provided descriptive information that guided the design and improvement of the application."

**FIND (V4 para 248):** `To gather user input for the study, structured survey questionnaires were used to collect respondents' views regarding the features and functionality of the developed application. The survey responses provided descriptive information that guided the design and improvement of the application.`
**REPLACE:** `To address the qualitative aspect of the study, interviews were used to gather respondents' views regarding the features and functionality of the developed application. The qualitative data provided descriptive information that guided the design and improvement of the application.`

⚠️ **CONFIRM_NEEDED — FINAL contradicts itself.** FINAL para 246 says "interviews were used," but FINAL para 267 says "**No interviews or focus groups were conducted;** qualitative insights into respondents' experiences and difficulties were derived from the survey responses," and FINAL para 385 says "qualitative insights were derived from survey response patterns." If the study did **not** actually conduct interviews, the "interviews were used" claim would be inaccurate and Maam Ellen's correction may have rested on a misunderstanding. **The user must confirm whether interviews were actually conducted** so all three paragraphs can be made consistent. Per the prompt's established fact (Maam Ellen: qualitative = interviews) the guide should use "interviews were used," but paras 267 and 385 must then be reconciled to agree (remove the "no interviews conducted" wording).

---

## ISSUE 6 — "No qualitative sentence at all in V4"
**Classification: ALREADY_IN_V4 (partially) — merged into Issue 5**

V4 *does* contain the qualitative sentence (para 248); it just uses "survey questionnaires" instead of "interviews." So this issue is the same edit as Issue 5 — no separate "add a sentence" action is needed. (If the user instead decides the study used only surveys, then V4's para 248 is already correct and no change is made — see the CONFIRM in Issue 5.)

---

## ISSUE 7 — Recommendations: 7 items → 8 items
**Classification: APPLY_TO_V4**

V4 (paras 405–411) has 7 recommendations. FINAL (paras 401–408) has 8: it inserts **UI/UX refinement (#1)** and **Formal parsing evaluation (#2)** at the top, **merges "Google Play release" into the Backend API proxy item**, and renumbers the rest.

V4 order: 1 Payday-cycle, 2 Backend API proxy, 3 Google Play release, 4 On-device AI tier, 5 SQLite encryption, 6 Household & remittance, 7 Longitudinal.
FINAL order: 1 UI/UX refinement, 2 Formal parsing evaluation, 3 Backend API proxy + Google Play release (merged), 4 SQLite encryption, 5 On-device AI tier, 6 Payday-cycle, 7 Household & remittance, 8 Longitudinal.

**Action:** Replace V4 paras 405–411 with FINAL's 8 items verbatim:

1. UI/UX refinement. The researchers recommended that the developers address the main usability concerns identified in the SUS evaluation: consistency (Q6), complexity (Q2), and the need for technical support (Q4). Specific improvements include simplifying navigation for first-time users, improving visual consistency across the 45 screens, and adding contextual help or tooltips to reduce the need for technical assistance.
2. Formal parsing evaluation. The researchers recommended that the developers conduct a formal evaluation of the AI parsing and OCR features using at least 50 standardized receipts and GCash screenshots, replacing the preliminary developer testing figures of 91.2% precision and 88.5% recall (Performance was assessed only through preliminary developer testing; no formal performance evaluation was conducted, which is why Recommendation 2 proposes one.) with results from a reproducible test protocol.
3. Backend API proxy and per-user keys. The researchers recommended that the developers move LLM API key management to a server-side proxy (e.g., Firebase Cloud Function) to remove device-side key exposure and enforce per-user message limits, because the free-tier request quotas (Table 3.2) were shared by every user of the prototype. Letting users add their own key was an interim measure. Google Play release. The researchers recommended that, after the backend proxy and a privacy policy were in place, the developers submit SmartSpend to the Google Play Store, since the prototype was currently distributed as a downloadable APK.
4. SQLite encryption. The researchers recommended that the developers implement SQLCipher-based encryption for the local database in a future schema migration, because the local database of the prototype was not encrypted.
5. On-device AI tier. The researchers recommended that the developers add an opt-in on-device model (e.g., Gemma 4 E2B through Google's LiteRT-LM, about a 2.6 GB download) for users who wanted fully offline AI, routing only simple logging tasks to it and keeping complex financial advice on the cloud tier, because the current local AI mode required a separate computer on the same network.
6. Payday-cycle-aware budgeting. The researchers recommended that the developers implement budgeting resets aligned with the semi-monthly (15th and 30th) salary cycle common in the Philippines.
7. Household and remittance features. The researchers recommended that the developers add shared couple and family wallets and inbound OFW remittance tracking as a distinct income category to serve more user groups.
8. Longitudinal evaluation. The researchers recommended that future researchers measure SmartSpend's effect on financial behavior over three to six months with a larger sample, because the usability evaluation in this study measured usability at a single point in time.

(Items 4–8 are essentially V4's existing 5/4/1/6/7 with renumbering; #3 is V4's #2 + #3 merged.)

---

## ISSUE 8 — Abstract: "Seven" → "Eight recommendations"
**Classification: APPLY_TO_V4**

V4 abstract para 54 ends: "Seven recommendations were identified for future development, including UI/UX refinement, a backend API proxy, on-device AI, SQLite encryption, formal parsing evaluation, and a longitudinal study." (Says "Seven" but lists only 6 — internally inconsistent.)
FINAL para 54 ends: "Eight recommendations were identified for future development: UI/UX refinement, formal parsing evaluation, a backend API proxy followed by a Google Play release, SQLite encryption, an on-device AI tier, payday-cycle budgeting, household and remittance features, and a longitudinal evaluation." (Says "Eight," lists 8 — consistent.)

**FIND (V4 para 54, last sentence):** `Seven recommendations were identified for future development, including UI/UX refinement, a backend API proxy, on-device AI, SQLite encryption, formal parsing evaluation, and a longitudinal study.`
**REPLACE:** `Eight recommendations were identified for future development: UI/UX refinement, formal parsing evaluation, a backend API proxy followed by a Google Play release, SQLite encryption, an on-device AI tier, payday-cycle budgeting, household and remittance features, and a longitudinal evaluation.`

---

## ISSUE 9 — Acknowledgements panelists line: add em-dashes
**Classification: APPLY_TO_V4**

V4 para 61 (no dashes): `To the panelists Mr. Jeoffrey B. Layco, MIS, Mr. Shekiro R. Raposas, MTS, MIS, and Ms. Mary-Ann Mzana, MTS, the researchers expressed their gratitude…`
FINAL para 61 (em-dashes): `To the panelists — Mr. Jeoffrey B. Layco, MIS, Mr. Shekiro R. Raposas, MTS, MIS, and Ms. Mary-Ann Mzana, MTS — the researchers expressed their gratitude…`

**FIND (V4):** `To the panelists Mr. Jeoffrey B. Layco, MIS, Mr. Shekiro R. Raposas, MTS, MIS, and Ms. Mary-Ann Mzana, MTS, the researchers expressed`
**REPLACE:** `To the panelists — Mr. Jeoffrey B. Layco, MIS, Mr. Shekiro R. Raposas, MTS, MIS, and Ms. Mary-Ann Mzana, MTS — the researchers expressed`
(Use em-dashes — U+2014.)

---

## ISSUE 10 — Figures 3.12 / 3.13 / 3.14
**Classification: ALREADY_IN_V4 (premise of "missing" is false) — verify images aren't broken**

V4 **already embeds** all three chart images, each immediately before its caption:
- Figure 3.14 (Demographic Distribution) — V4 image at para 314 → caption 315
- Figure 3.12 (SUS Score Distribution) — V4 image at para 381 → caption 382
- Figure 3.13 (SUS Scores by Respondent Group) — V4 image at para 384 → caption 385

V4's List of Figures also lists 3.12/3.13/3.14 (paras 145–148). So no new embedding is required for these three charts.

**Where the 3-image gap (28 vs 31) actually is:**
1. **Certificates (Appendix D/E):** V4 has **1** image per appendix (D: para 704; E: para 707). FINAL has **2** per appendix (D: 768,769; E: 772,773). → 2-image difference (see Issue 11).
2. **SUS-results gap:** After the Figure 3.13 caption, FINAL has 2 stacked images before Table 3.4 (paras 381, 382); V4 has 1 (para 386). → 1-image difference. This is an extra/duplicate image in FINAL; unclear what it represents without rendering. **CONFIRM_NEEDED** whether V4 should add a second image there.

Recommendation: do **not** re-embed 3.12/3.13/3.14 (present). Just visually confirm V4's three chart images render correctly (not broken/placeholder) when the docx is opened. Manual-only verification task.

---

## ISSUE 11 — Certificate images in Appendix D and E
**Classification: ALREADY_IN_V4 for the primary cert (present & correctly placed); CONFIRM_NEEDED for the extra image**

V4 Appendix D (para 702–704): heading "APPENDIX D / Content Validation Certificate (Survey Questionnaire)" followed by **1** image (para 704).
V4 Appendix E (para 705–707): heading "APPENDIX E / Content Validation Certificate (FHS Formula and Literature)" followed by **1** image (para 707).

FINAL Appendix D (766–769): heading + **2** images (768, 769). FINAL Appendix E (770–773): heading + **2** images (772, 773).

So V4 has the certificate image in each appendix, placed correctly. FINAL has an **extra** image in each appendix (2 instead of 1). The `FIGURES/certificates/` folder contains exactly one jpg per appendix (`AppendixD_Survey_Questionnaire_Certificate.jpg`, `AppendixE_FHS_Formula_Certificate.jpg`), so the "second" image in FINAL is not a separate source file — it is most likely a **duplicate/split** of the same certificate (or a second page).

**CONFIRM_NEEDED:** Should V4 add a second image in each appendix to match FINAL? Recommendation: keep V4 as-is (one cert image per appendix is correct) unless the user confirms the certificate genuinely has two pages. Mark this MANUAL.

---

## ISSUE 12 — Tense corrections sweep (547 items)
**Classification: ALREADY_IN_V4 — V4 is at tense parity with FINAL**

Programmatic sweep result (full-text fragment matching, dash/quote-normalized):
- Corrections where **V4 keeps present-tense but FINAL has past-tense (V4 behind FINAL): 0**
- Applied (past-tense present) in **both** V4 and FINAL: **430**
- Kept present-tense in **both** V4 and FINAL (intentional): **13**
- Neither fragment matched exactly (sentence reworded / table-number differs): 100

The 13 "both present" are intentional and correct — they describe the **running application's live features** in present tense (mascot moods, voice service, haptic service, notification behavior, "Voice recognition accuracy will be affected by background noise" as a forward-looking limitation, etc.). Both docs agree, so these are **not** fixes.

The 100 "neither" cases were verified by spot-check to be **matching artifacts**, not genuine misses: V4 reworded several sections (e.g., a condensed Population & Locale section) and already uses past tense, but the surrounding wording (table numbers like "Table 2.1 summarized" vs the list's "Table 1.2 summarized"; em-dash spacing) differs from the tense list's older draft fragments. Spot-checks confirmed past-tense verbs are present in V4 for these (e.g., "study aimed to" ✓, "integrated both qualitative" ✓, "was broadening" ✓, "served as primary household financial decision-makers" ✓, "group included individuals who aimed" ✓). One confirmed non-tense error surfaced: V4 para 177 says "Table **2.1** summarized the key feature differences" — the table number is wrong (should be **1.2**); that is a reference fix, not a tense fix.

**Missing critical tense corrections in V4 (relative to FINAL): 0.** V4 does not need a tense pass. The only tense-adjacent cleanup is the table-reference error (Table 2.1 → 1.2 at the "summarized the key feature differences" spot).

---

## ISSUE 13 — "Step 1: Questionnaire Preparation and Validation"
**Classification: APPLY_TO_V4**

V4 para 273 heading is fine. V4 para 274 (the Step 1 body) differs from FINAL para 272 in three ways:
- Grammar: V4 "The expert's credentials **was** recorded" → FINAL "**were** recorded"
- Appendix reference: V4 "Content Validation Certificate **(Appendix A)**" → FINAL "**(Appendix D)**"
- Missing sentence: FINAL adds "The same content validator also reviewed the Financial Health Score formula (Appendix E)." (This is the "pinag isa nalang" combine — Avigail validates both the survey and the FHS formula.)

**FIND (V4 para 274):** `The survey questionnaire was drafted by the research team and submitted to Avigail Candevario, PFMe, a subject matter expert in financial management, for content validation. The expert's credentials was recorded in the Content Validation Certificate (Appendix A). Revisions were made based on the feedback before distribution.`
**REPLACE:** `The survey questionnaire was drafted by the research team and submitted to Avigail Candevario, PFMe, a subject matter expert in financial management, for content validation. The expert's credentials were recorded in the Content Validation Certificate (Appendix D). The same content validator also reviewed the Financial Health Score formula (Appendix E). Revisions were made based on the feedback before distribution.`

Also delete the stray duplicate Susan sentence at V4 para 272 (see Issue 4, Instance B).

---

# ADDITIONAL DIFFERENCES FOUND (beyond the 13 — for the comprehensive guide)

These were not in the original 13-issue list but differ between V4 and FINAL. They are needed to bring V4 fully to FINAL's level. Each is low-risk except where flagged.

**A. Abstract — add purposive-sampling sentence (APPLY_TO_V4)**
- V4 para 52: "The study employed a mixed-methods developmental research design. A validated survey questionnaire was administered…"
- FINAL para 52: "The study employed a mixed-methods, developmental research design. **Purposive sampling was used to select 30 respondents from the target population.** A validated survey questionnaire was administered…"
- **FIND:** `The study employed a mixed-methods developmental research design. A validated survey questionnaire was administered`
- **REPLACE:** `The study employed a mixed-methods, developmental research design. Purposive sampling was used to select 30 respondents from the target population. A validated survey questionnaire was administered`

**B. Abstract — provider chain + grade phrasing (APPLY_TO_V4 — flag: provider count is NOT in protected values; confirm against app)**
- V4 para 53: "SmartSpend version 3.1.0 was successfully developed as an offline-first Android application… and a **six-provider** AI failover chain. Usability evaluation yielded a mean SUS score of 61.83 (SD = 17.58), corresponding to **a grade of D and an adjective rating of "OK" under the Bangor et al. (2009) scale** below the 68-point benchmark (Sauro & Lewis, 2016)…"
- FINAL para 53: "SmartSpend v3.1.0 was developed as a working Android prototype… and an **eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks) plus an optional private local model**. Usability evaluation yielded a mean SUS score of 61.83 (SD = 17.58), corresponding to **an adjective rating of "OK" (Bangor et al., 2009) and a Grade D on the Sauro and Lewis (2016) curved scale, which is** below the 68-point average benchmark (Sauro & Lewis, 2016)…"
- Protected SUS values (61.83 / 17.58 / N=30 / Grade D / OK) are preserved in both. The provider count (six→eight) is a factual change. **Recommend confirming the app's actual provider count before applying; FINAL's "eight-provider" is the more recent figure.**

**C. Research Design — drop "developmental" from mixed-methods label (APPLY_TO_V4)**
- V4 para 247: "This study applied a **mixed methods developmental** research design, which integrated both qualitative and quantitative approaches…"
- FINAL para 245: "This study applied a **mixed methods** research design, which integrated both qualitative and quantitative approaches… This approach, the researchers were able to capture both measurable trends and deeper insights into user behavior, preferences, and challenges."
- (FINAL also appends a "Through this approach…" sentence.)

**D. Research Design — "developmental" → "descriptive-developmental" (APPLY_TO_V4)**
- V4 para 250: "Moreover, this study **also adopted a developmental** research approach, which focused on…"
- FINAL para 248: "Moreover, this study **adopted a descriptive-developmental** research approach, which focused on…"

**E. Research Design — quantitative paragraph expanded with SUS protocol (APPLY_TO_V4 with cleanup caveat)**
- V4 para 249 is a short quantitative paragraph. FINAL para 247 expands it to append the SUS protocol detail: "In addition, the System Usability Scale (SUS) questionnaire was utilized… administered to the thirty (30) valid respondents after respondents used the SmartSpend application… for at least 10 minutes… A target SUS score of 80 or above… 68 average benchmark (Sauro & Lewis, 2016)…"
- ⚠️ FINAL's appended last sentence is **grammatically broken** ("A target SUS score of 80 or above, which lies between the Good (about 71) and Excellent (about 85) adjective anchors of Bangor et al. (2009); it was set as an aspirational threshold…, was set as the acceptance threshold…"). If V4 adopts this paragraph, **clean up that sentence** rather than copying the broken version verbatim. This is a "previously applied fix" that introduced a grammar error; flag for the user.

**F. Population & Locale — V4 is condensed; FINAL is expanded (CONFIRM_NEEDED / optional)**
- V4 paras 253–255 are a short, past-tense, correct (13/14/3) version.
- FINAL paras 251–253 expand with detailed demographic definitions ("parents were defined as…", "Young professionals were defined as…", BSP/PSA citations).
- V4's condensed version is accurate and past-tense. Whether to expand V4 to match FINAL is a length/style decision — Maam Ellen expressed a preference for trimming overly long sections ("inedit ko dn yng sa objectives, ang haba"). **Recommend keeping V4's concise version unless the user wants the expanded definitions.** Mark optional/MANUAL.

**G. Acknowledgements — two minor wording fixes (APPLY_TO_V4, low priority)**
- V4 para 60: "their **instructor in charge**, Mr. Shekiro R. Raposas" → FINAL: "their **Capstone Teacher-in-Charge**, Mr. Shekiro R. Raposas"
- V4 para 62: "the College of Computer Studies and Engineering **Department** for equipping" → FINAL: "the College of Computer Studies and Engineering **faculty** for equipping"

**H. Title page — adviser line (APPLY_TO_V4, low priority / cosmetic)**
- V4 para 20: "Ellen Flores Mangaoang, DIT"
- FINAL para 20: "Adviser: Ellen F. Mangaoang, DIT"
- (Protected name: "Ellen Flores Mangaoang DIT" — both are acceptable renderings; FINAL adds the "Adviser:" label. Optional.)

**I. Table-reference error in body (APPLY_TO_V4 — found during tense sweep)**
- V4 para 177: "Table **2.1** summarized the key feature differences." → should be "Table **1.2** summarized the key feature differences." (The feature-comparison table is 1.2, not 2.1.)

---

# SUMMARY TABLE

| # | Issue | Classification | Action |
|---|-------|---------------|--------|
| 1 | Table 2.1 Parents 16→13 | APPLY_TO_V4 | Fix table cell |
| 2 | Table 2.1 add "Both Groups 3" row | APPLY_TO_V4 | Restructure table |
| 3 | Technical Validator row | MAAM_ELLEN_INSTRUCTION (+ CONFIRM on body sentence) | No technical-validator row; Total Validators=1; remove false IT-expert body sentence |
| 4 | Susan C. Arquisal → Avigail Candevario | APPLY_TO_V4 / MAAM_ELLEN | Replace 2 instances; delete stray duplicate |
| 5 | Qualitative "surveys"→"interviews" | MAAM_ELLEN_INSTRUCTION (+ CONFIRM contradiction) | Replace para 248; reconcile paras 267 & 385 |
| 6 | "No qualitative sentence in V4" | ALREADY_IN_V4 (merged into #5) | Same edit as #5 |
| 7 | Recommendations 7→8 | APPLY_TO_V4 | Replace list with 8 items |
| 8 | Abstract "Seven"→"Eight" | APPLY_TO_V4 | Replace last sentence |
| 9 | Acknowledgements em-dashes | APPLY_TO_V4 | Add em-dashes |
| 10 | Figures 3.12/3.13/3.14 | ALREADY_IN_V4 | Verify images render (manual) |
| 11 | Appendix D/E certificates | ALREADY_IN_V4 (primary) / CONFIRM (2nd image) | Keep 1 cert/appendix unless 2 pages confirmed |
| 12 | Tense corrections sweep | ALREADY_IN_V4 | 0 missing; no tense pass needed |
| 13 | Step 1 Questionnaire Preparation | APPLY_TO_V4 | Fix grammar + Appendix A→D + add FHS sentence |

**Additional (beyond 13):** A (purposive sampling sentence), B (provider chain — CONFIRM), C/D (research-design labels), E (SUS protocol — has broken sentence to clean up), F (Population expansion — optional), G (acknowledgement wording), H (title-page adviser label), I (Table 2.1→1.2 reference).

**Missing critical tense corrections: 0.** V4 is at tense parity with FINAL.

**Two CONFIRM_NEEDED decisions for the user (block the guide from being fully authoritative until answered):**
1. **Issue 3 / body:** Remove the false "subject matter expert in information technology… Technical Validation Certificate" sentence (present in both V4 and FINAL)? Recommended: yes (matches "no separate technical validator"). This also confirms Total Validators = 1 (not FINAL's 2).
2. **Issue 5:** Were interviews actually conducted? FINAL says both "interviews were used" (para 246) and "no interviews conducted" (paras 267, 385). The user must resolve this so all three paragraphs agree.
