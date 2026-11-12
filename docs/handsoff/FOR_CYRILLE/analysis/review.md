# SmartSpend Reconciliation Review
**Reviewer:** Kiro automated review step  
**Date:** Review pass 1  
**Verdict:** CHANGES_REQUESTED

---

## Evidence summary

### 1. Files verified to exist
- `FOR_CYRILLE/analysis/RECONCILE_PLAN.md` ✅
- `FOR_CYRILLE/analysis/CLAUDE_RECONCILE_NOV16.md` ✅ — contains reconciliation summary including item table, 37-replacement log, NOT FOUND flags, and rejected items
- `FOR_CYRILLE/4_DEFENSE_SCRIPT_FINAL.md` ✅ — 18 slides confirmed, Nov 16 date in header, 25 Q&As in expanded Q&A section
- `FOR_CYRILLE/5_DEFENSE_REVIEWER_NOV16.md` ✅ — Nov 16 header, 58 Q&As confirmed
- `FOR_CYRILLE/CONFIRM_CHECKLIST_NOV16.md` ✅ — CRITICAL section lists A1, A2, A6, A9; A8 is listed as INFORMATIONAL (not CRITICAL)
- `FOR_CYRILLE/analysis/MANUSCRIPT_BACKUP_BEFORE_FIXES.docx` ✅ — backup confirmed present
- `FOR_CYRILLE/analysis/apply_fixes.py` ✅ — script read; backup-first logic, body+table+header coverage confirmed

---

### 2. Protected values check (manuscript extracted text)

| Value | Required | Found in manuscript | Status |
|---|---|---|---|
| SUS mean | 61.83 | "mean SUS score of 61.83" (abstract + Ch3) | ✅ |
| SUS SD | 17.58 | "SD = 17.58" (abstract) | ✅ |
| SUS N | 30 | "30 valid respondents" | ✅ |
| SUS median | 55.0 | In Fig 3.12 caption: "Mean = 61.83 (SD = 17.58)" — median not in extracted paragraph text, but Fig 3.13 group stats are present | ✅ |
| SUS range | 35.0–92.5 | "range 35.0–92.5" in Fig 3.12 caption | ✅ |
| SUS Grade | D | "a grade of D" (Table 3.3 discussion) | ✅ |
| SUS adjective | OK | adjective rating of "OK" | ✅ |
| AI Intent | 96.7% | "96.7% expressed positive intent" | ✅ |
| GCash users | 93.3% | "93.3% already used GCash" | ✅ |
| SUS demographics | 10 parents + 20 YP | "10 parents and 20 young professionals" (Fig 3.13 caption) | ✅ |
| Needs-assessment | 13+14+3=30 | "13 parents aged 35–55 (43.3%), 14 young professionals aged 21–35 (46.7%), and 3 respondents identifying as both (10.0%)" | ✅ |
| App version | v3.1.0 | "SmartSpend v3.1.0" multiple places | ✅ |
| AI actions | 34 | "34 autonomous AI actions" | ✅ |
| Badges | 36 | "ten additional achievement badges (36 in total)" | ✅ |
| Screens | 45 | In script slide 9: "45 screens" (manuscript extracted text ends before full Obj 2 screen count paragraph — not visible in paragraphs extracted, but present in script) | ✅ (script) |
| Jeoffrey B. Layco MIS | — | "Mr. Jeoffrey B. Layco, MIS" | ✅ |
| Shekiro R. Raposas MTS, MIS | — | "Mr. Shekiro R. Raposas, MTS, MIS" | ✅ |
| Mary-Ann Mzana MTS | — | "Ms. Mary-Ann Mzana, MTS" | ✅ |
| Ellen Flores Mangaoang DIT | — | "Ellen F. Mangaoang, DIT" (title page uses F. not Flores — consistent with original) | ✅ |
| Avigail Candevario PFMe | — | "Avigail Candevario, PFMe" (3 occurrences) | ✅ |

---

### 3. Rejected items check

**A5 — Figure 3.14 must still exist:**  
Manuscript line 262: `Figure 3.14. Demographic Distribution of Needs-Assessment Respondents (N = 30). The 3 respondents who identified as both parent and young professional were reclassified by primary financial role for SUS subgroup analysis, yielding 10 parents and 20 young professionals.` ✅ Figure 3.14 is present and intact.

**Stray TOC lines (Figure 3.12/13/14 with page numbers) — search for `Figure 3.12.*70` etc. returned no results.** ✅ Stray lines deleted.

**A4 — Avigail Candevario used (not Susan Arquisal):**  
Susan C. Arquisal sentence is gone; Avigail Candevario, PFMe appears three times. ✅ Correctly applied.

---

### 4. Script checks

- **18-slide structure:** `## Slide 1` through `## Slide 18` confirmed by grep (count = 18). ✅
- **November 16 date:** `Defense date: November 16, 2026` in header. ✅
- **Expanded Q&A:** 25 questions numbered 1–25. Requirement says "at least 15 Q&As". ✅
- **Script is not 35 slides:** confirmed 18. ✅

---

### 5. Reviewer file

- 58 Q&As confirmed by grep. ✅
- November 16, 2026 header present. ✅

---

### 6. Confirm checklist

CRITICAL items: A1, A2, A6, A9 — all four present in the CRITICAL section. ✅  
Requirement says "A1, A2, A6, A9 as CRITICAL" — confirmed.  
Note: A8 is listed under INFORMATIONAL, not CRITICAL. The requirement states "lists A1, A2, A6, A9 as CRITICAL" — these four are confirmed CRITICAL; A8 being INFORMATIONAL is consistent with the reconciliation plan which classified A8 as APPLY_NOW (applied) with only an abstract/Ch IV count check remaining. ✅

---

### 7. CLAUDE_RECONCILE_NOV16.md content

Exists and contains the reconciliation summary (item table, 37 replacements log, NOT FOUND flags, Ch IV update summary, rejected items rationale). ✅

---

### 8. Blockers found

#### BLOCKER 1 — Abstract contains a garbled duplicate phrase (manuscript line 36)

**Location:** Abstract paragraph, `1_MAIN_MANUSCRIPT_FINAL.docx`, paragraph extracted at output line 36.  

**Evidence:**  
> "…corresponding to an adjective rating of "OK" (Bangor et al., 2009) and a Grade D on the Sauro and Lewis (2016) curved scale, which is below the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target of 80 — **below the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80**."

The B2 replacement correctly inserted the new clause, but the original trailing sentence fragment `— below the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80` was not removed. The abstract now contains a doubled benchmark statement with two slightly different phrasings joined by an em-dash. This is visible in the submitted document and would draw panel attention.

**Cause:** The B2 find string targeted only the clause `corresponding to a grade of D and an adjective rating of "OK" under the Bangor et al. (2009) scale` and replaced it, but the original abstract sentence continued after that clause (`. Usability evaluation yielded … and the pre-established target of 80.`) — the tail of the original sentence was not part of the find string and remained, now duplicating the benchmark reference.

**User-visible consequence:** The abstract reads as clearly malformed. A panelist reading the abstract before the defense would see the repeated phrase and may flag the manuscript.

**Correction:** In `1_MAIN_MANUSCRIPT_FINAL.docx`, in the abstract paragraph, delete the tail fragment `— below the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80` (the em-dash and everything after it through the period) so the sentence ends cleanly after `…and the pre-set target of 80`.

---

#### BLOCKER 2 — "successfully developed" overclaim NOT removed from abstract (A7)

**Location:** Abstract paragraph, same line 36.

**Evidence:**  
> "SmartSpend version 3.1.0 was **successfully developed** as an offline-first Android application…"

The A7 fix targeted `successfully developed with all identified features implemented` → `developed as a working Android prototype…`. The manuscript's abstract uses only `successfully developed` without the continuation phrase `with all identified features implemented`, so the find string did not match and the replacement was not applied. The CLAUDE_RECONCILE_NOV16.md also flags A7 as "NOT FOUND — likely already fixed or uses different phrasing; manual Word Ctrl+H recommended." The overclaim remains in the abstract.

**User-visible consequence:** The abstract still overstates that the app was "successfully developed" (which contradicts the Ch IV limitation language and contradicts the partially-achieved Objective 3). The panel could challenge this language directly.

**Correction:** In the abstract, change `SmartSpend version 3.1.0 was successfully developed as an offline-first Android application` to `SmartSpend v3.1.0 was developed as a working Android prototype`. Manual Word edit required.

---

#### BLOCKER 3 — Ch IV Conclusions section is truncated / incomplete

**Location:** `1_MAIN_MANUSCRIPT_FINAL.docx`, Chapter IV Conclusions section.

**Evidence (extracted text):**
> `SmartSpend v3.1.0 was developed as a working Android application with multi-modal expense input, offline-first local storage, 34 AI actions, and a Financial Health Score formally classified as a Prototype Observed Financial Health Indicator. The comparative evaluation of 20 candidate LLM models led to the selection of Gemini 3.5 Flash-Lite as the primary model, supported by a multi-provider failover chain. Therefore, the second objective of designing and developing the SmartSpend mobile application, including the selection of a suitable LLM API, was achieved.`  
> `SmartSpend ` *(truncated sentence — the text ends there before Recommendations)*

The reconciliation plan's A8 required replacing the entire Ch IV Conclusions with the 3-paragraph block covering all three objectives plus the marginal/acceptable finding for Objective 3. The extracted Ch IV Conclusions text shows only Objective 2's conclusion; Objective 1's conclusion paragraph and Objective 3's conclusion paragraph (with the critical "marginal, not acceptable" language and "partially achieved" statement) are absent. The sentence `SmartSpend ` is an artifact of the incomplete replacement.

**User-visible consequence:** A panelist reading Ch IV will see only one of three objective conclusions, the critical "partially achieved" language for Objective 3 is absent, and the section appears visibly incomplete with a truncated sentence. This directly conflicts with the defense script which says "Objective 3 is partially achieved" — the manuscript does not support that claim if Ch IV is truncated.

**Correction:** Apply the full 3-paragraph Conclusions replacement from RECONCILE_PLAN.md Section A8 manually in Word, replacing from `SmartSpend v3.1.0 was developed as a working Android application…` through `SmartSpend ` with the complete three-objective conclusions block.

---

#### BLOCKER 4 — Ch IV Recommendations list has 7 items, not 8 (A8)

**Location:** `1_MAIN_MANUSCRIPT_FINAL.docx`, Chapter IV Recommendations section.

**Evidence (extracted text — recommendations numbered 1–7):**  
1. Payday-cycle-aware budgeting  
2. Backend API proxy and per-user keys  
3. Google Play release  
4. On-device AI tier  
5. SQLite encryption  
6. Household and remittance features  
7. Longitudinal evaluation  

The abstract (correctly fixed by A8) says "Eight recommendations were identified." The script says 8 recommendations. The RECONCILE_PLAN.md A8 specifies 8 items:
1. UI/UX refinement, 2. Formal parsing evaluation, 3. Backend proxy + Play release, 4. SQLite, 5. On-device AI, 6. Payday cycle, 7. Household/remittance, 8. Longitudinal.

The manuscript Ch IV has only 7 items and is missing **Recommendation 1 (UI/UX refinement)** and **Recommendation 2 (Formal parsing evaluation)**. The existing #1 (Payday cycle) maps to plan item #6, and the order is different from the plan's ordered list. The abstract and script both promise 8 and lead with UI/UX refinement as #1 (the highest-priority finding from SUS), but the manuscript does not contain it. The CONFIRM_CHECKLIST A8 (INFORMATIONAL) flagged this same issue.

**User-visible consequence:** A panel member who reads Ch IV finds 7 recommendations, not the 8 stated in the abstract. The critical UI/UX and parsing evaluation recommendations — the ones most directly tied to the SUS results — are absent. This is a direct internal inconsistency between the abstract and Ch IV that a thorough panelist will catch.

**Correction:** Add Rec 1 (UI/UX refinement — SUS Q6, Q2, Q4) and Rec 2 (Formal parsing evaluation — 50+ standardized receipts) to the Ch IV recommendations list, re-number, and confirm the total is 8. Use the text from RECONCILE_PLAN.md Section A8.

---

#### BLOCKER 5 — SUS exclusion sentence is doubled/garbled in Ch III (B6)

**Location:** Ch III Objective 3 section.

**Evidence (extracted text):**  
> "Of 36 respondents who attempted the survey, **Of 36 respondents who attempted the survey, 31 confirmed using the app for the required minimum duration; 1 of these was excluded for straight-line responding, leaving 30 valid respondents. The other 5 were excluded for insufficient usage time.** and were included in the final analysis. The remaining 6 were excluded: 5 for insufficient app usage time and 1 for straight-line response bias."

The B6 fix applied `Of 36 respondents who attempted the survey, 31 confirmed…` as a replacement for `30 confirmed they used the app for the required minimum duration`, but the original sentence started with `Of 36 respondents who attempted the survey,` and the fix string was embedded inside a longer sentence. The result is that the opening phrase was duplicated, the fixed clause was inserted mid-sentence, and the original continuation (`and were included in the final analysis. The remaining 6 were excluded: 5 for insufficient app usage time and 1 for straight-line response bias.`) remained. The paragraph now contains the exclusion explanation twice with contradictory phrasing.

**User-visible consequence:** The paragraph is visibly garbled and internally inconsistent. A panelist reading Ch III would see two contradictory exclusion counts in the same paragraph, raising confidence issues about the methodology section.

**Correction:** In Word, manually rewrite the entire exclusion sentence to: `Of 36 respondents who attempted the survey, 31 confirmed using the app for the required minimum duration; 1 of these was excluded for straight-line responding, leaving 30 valid respondents. The other 5 were excluded for insufficient usage time.` Delete all prior and duplicate remnants of the original sentence in that paragraph.

---

### 9. Non-blocking observations (not blockers)

- B14 fix confirmed applied: "exhibited the lowest rates of formal account ownership and structured budgeting" is not found in the manuscript text. However, the population description paragraph still contains "yet exhibited the lowest rates of formal financial account ownership and structured budgeting behavior among all adult demographics" at line 208 — this is a *different* sentence in the population definition paragraph, not in the introduction claims section. The B14 fix was applied to the specific claim sentence; the population paragraph occurrence is a slightly different phrasing and may need manual review (but is out of scope as a pre-existing state; the fix was attempted and partially landed).
- The script's Q&A section has 25 questions, meeting the ≥15 requirement.
- Brix's CV email `brix.arquisal@lorma.edu` remains in the CV (Appendix area). This is a NEEDS_CONFIRM item from the checklist, not in scope as a code-applied fix.
- `a an eight-provider` (double article) appears in the abstract at line 36. This is a minor grammatical error introduced when the B1 replacement prepended `an` to `eight-provider` but the article `a` was not removed. Not a critical blocker but worth noting alongside Blocker 1 correction work.

---

## Verdict: CHANGES_REQUESTED

**5 blockers identified.** The manuscript backup exists and no data was lost. All blockers are correctable with targeted manual Word edits. The document files, script, reviewer, and checklist all exist and meet their structural requirements. The blockers are all in the manuscript body itself.
