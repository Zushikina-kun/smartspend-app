# Manuscript Review — 1_MAIN_MANUSCRIPT_FINAL.docx

## Verification Script Results
All 67/67 automated checks pass (verify_all_three.py, run against FOR_CYRILLE folder source).

## Manual Check Results

| Check | Result |
|---|---|
| MC1 No "mixed-methods" | PASS |
| MC2 "quantitative descriptive developmental" present | PASS |
| MC3a "random sampling" for respondents | PASS |
| MC3b "purposive sampling" for content validator | **FAIL — not present anywhere** |
| MC4 "nine recommendations" | PASS |
| MC5 All 9 recommendations present | PASS |
| MC6 eight-provider chain / Gemini 3.5 Flash-Lite primary / seven fallbacks | PASS |
| MC7 SUS 61.83 / SD 17.58 / N=30 / Grade D / "OK" / partially achieved | PASS |
| MC8 16 parents + 14 YP = 30 (needs-assessment) | **FAIL — prose says 13+14+3** |
| MC9 SUS sample 10 parents + 20 YP = 30 | PASS (58.25 mean confirmed) |
| MC10 96.7% and 93.3% | PASS |
| MC11 Avigail Candevario, PFMe | PASS |
| MC12 Panel members (Jeoffrey, Shekiro, Mary-Ann) | PASS |
| MC13 Adviser Ellen Flores Mangaoang DIT | PASS |
| MC14 Gemini 3.5 Flash-Lite (not 1.5) | PASS |
| MC15 8 LLM APIs evaluated | PASS (Table 6 has 10 models) |
| MC16 Figure 17 and Figure 18 present | PASS |
| MC17 Table 9 (Multimodal Import Parsing Performance) | **FAIL — absent from document** |
| MC18 No chapter-prefixed Figure/Table numbers in body | **FAIL — "Table 1.2" in body prose** |
| MC19 Figure captions "Figure N. Title" format | PASS (11 found) |
| MC20 Table captions "Table N: Title" format | PASS (9 found) |
| MC21 Word comments preserved | PASS (20 comments) |
| MC22 No "proposed SmartSpend" / "will be developed" | PASS |
| MC23 Table 3 note about content validator | PASS |
| MC24 No Figure 3.14 / no duplicate Demographic Distribution | PASS |

---

## Blockers

### BLOCKER 1 — Population prose contradicts Table 3 (checks E, F, MC8)
**File/Line:** `1_MAIN_MANUSCRIPT_FINAL.docx`, paragraph ~238 (Population and Locale section), paragraph ~275 (Table 5 intro), paragraph ~278 (Table 5 note)

**Evidence:**
- Para 238: *"A total of thirty (30) respondents were selected using random sampling. Thirteen (13) respondents were parents… Fourteen (14) respondents were young professionals… Three (3) respondents identified as both."*
- Para 275: *"The sample comprised 13 parents aged 35–55 (43.3%), 14 young professionals aged 21–35 (46.7%), and 3 respondents identifying as both (10.0%)."*
- Para 278 (Table 5 note): *"…percentages were computed within each group (parents n = 13, young professionals n = 14, both n = 3)…"*
- Table 3 (correctly updated) shows: Parents = 16, Young Professionals = 14, Total = 30.

**Consequence:** The needs-assessment description and Table 5 contradict the corrected Table 3. A reader sees 13+14+3 = 30 in Chapter III prose but 16+14 = 30 in Table 3, with no explanation of why they differ. This is an accuracy failure — the 3 respondents who identified as "both" were confirmed to be reclassified as parents (bringing parents to 16), but the population paragraph and Table 5 were not updated to match.

**Required fix:** Update paragraph ~238, the Table 5 intro (~275), and the Table 5 note (~278) to state 16 parents + 14 young professionals = 30, removing the "three (3) identified as both" language from the needs-assessment description. The reclassification note (para ~282) about the SUS subgroup (10 parents + 20 YP) should be retained as it correctly explains the SUS breakdown.

---

### BLOCKER 2 — "purposive sampling" for content validator never stated (check MC3b)
**File/Line:** `1_MAIN_MANUSCRIPT_FINAL.docx`, Population and Locale section (~paragraphs 236–241)

**Evidence:** Searching the full document text and table cells for `purposive` returns zero matches. The word does not appear anywhere in the document. The requirement specifies that "purposive sampling" must be used (stated) for the content validator, while "random sampling" is used for respondents.

**Consequence:** The sampling methodology for the content validator is undeclared. This violates the methodological accuracy requirement and leaves the validator's selection rationale unexplained.

**Required fix:** Add a sentence to the Population and Locale section explicitly stating that the content validator (Avigail Candevario) was selected using purposive sampling, e.g., *"The content validator was selected through purposive sampling based on her expertise in personal finance and financial education."*

---

### BLOCKER 3 — Table 9 (Multimodal Import Parsing Performance) absent (check MC17)
**File/Line:** `1_MAIN_MANUSCRIPT_FINAL.docx` — no "Table 9:" caption exists anywhere in the body or table cells

**Evidence:**
- Searching full document: `"Table 9" in body text: False`, `"Table 9" in table cells: False`
- Table of Contents line 155–156 references section *"3.5. SmartSpend Multimodal Import: Field-Level Parsing Performance … 72"*
- The highest-numbered table caption in the body is `Table 8: System Usability Scale (SUS) Results by Respondent Group`
- Recommendation #9 (para 372) mentions "Formal parsing evaluation" and references OCR/AI parsing, implying this results section was expected

**Consequence:** A required table is missing. The TOC advertises it at page 72, but it is absent from the merged output. Any reader following the TOC or looking for parsing performance data finds nothing.

**Required fix:** Insert Table 9 (Multimodal Import Parsing Performance) with its data and caption in the body of the document at the location indicated by the TOC (after Chapter III results for Objective 2, before the SUS evaluation). The caption must follow the `Table 9: Title` format.

---

### BLOCKER 4 — "Table 1.2" chapter-prefixed reference in body prose (check MC18)
**File/Line:** `1_MAIN_MANUSCRIPT_FINAL.docx`, paragraphs ~171–172 (Review of Related Literature / Chapter I body)

**Evidence:**
- Para 171: *"Beyond the applications summarized in Table 1.2, several other Philippine-context finance apps competed in this space…"*
- Para 172: *"…None of these offered SmartSpend's combination of Taglish NLP…"* (also in context of Table 1.2 reference)
- The actual table caption in the document is `Table 2: Feature Comparison of SmartSpend with Existing Financial Applications`

**Consequence:** The body prose references "Table 1.2" (a chapter-prefixed number) but the actual table is numbered "Table 2" (sequential). This is a broken cross-reference — a reader following "Table 1.2" finds no such table, since only "Table 2" exists. The requirement explicitly prohibits chapter-prefixed table numbers in body text.

**Required fix:** Replace both occurrences of "Table 1.2" in paragraphs 171–172 with "Table 2".

---

### BLOCKER 5 — Scope and Limitations not condensed to 1 paragraph (check D)
**File/Line:** `1_MAIN_MANUSCRIPT_FINAL.docx`, paragraphs ~198–201 (Scope and Limitations section)

**Evidence:**
- Para 198: Scope paragraph describing Android platform, online/offline functionality, cloud services ("The system optionally integrated cloud-based storage and authentication services…")
- Para 199: Long limitations paragraph covering OCR, voice, banking, investment, financial advice, Firebase Spark tier, Android-only
- Para 200: Separate technical paragraph on LLM API key management, Firebase Remote Config, decompilation risk, daily rate limit
- Para 201: Separate paragraph on RA 10173, Philippine Data Privacy Act, regex-based PII redaction

**The requirement** (Cyrille's comment): one paragraph covering what the system has and doesn't have, not too technical, no API key management details, no RA 10173 details.

**Consequence:** The scope section is 4 paragraphs. Paragraphs 200 and 201 contain highly technical content (Remote Config decompilation risk, regex redaction) that was explicitly flagged for removal.

**Required fix:** Merge paragraphs 198–201 into a single condensed paragraph covering: Android only, survey-based methodology, no banking integration, no professional financial advice, OCR depends on image quality, AI features require internet, no interviews conducted. Remove the Remote Config/API key and RA 10173 technical detail paragraphs.

---

## Items Investigated but Not Blocking

- **Flutter/SQLite citations (check A):** Flutter paragraph (para 212) has zero citations. SQLite paragraph (para 213) contains `(version 11)` which is a package version number, not a source citation. Both are citation-free as required.
- **Data Gathering numbered steps (check B):** No "Step 1:", "Step 2:" etc. found anywhere. Section is prose per objective. Passes.
- **"No interviews" statement (check C):** Para 353 states *"The study used a structured quantitative survey instrument, and no open-ended or interview data were collected."* This satisfies the requirement.
- **Table 1.2 in TOC area:** Lines 89–158 are TOC entries (not body prose). The only body occurrences of "Table 1.2" are lines 171–172, which are the blocker identified above.
- **SQLite `(version 11)` bracket:** This is a package version annotation, not an author-year citation. Does not violate the citation requirement.
- **LLM table row count (10 models) vs. "eight providers" claim:** The text says "eight providers" for the failover chain providers; Table 6 lists 10 individual models from 4 providers. The failover-chain description (abstract, Tech BG) is consistent internally. MC15 asks for "8 LLM APIs evaluated" — Table 6 shows 10 models were evaluated, which exceeds 8. No blocker.
- **MC18 Figure X.Y:** No chapter-prefixed figure numbers found. Only Table 1.2 is a problem.
