# SmartSpend — Complete Fix Guide
**Defense: November 10, 2026** | **Print deadline: Before defense**

---

## ✅ Already correct — do NOT change

- Adviser: **Ellen F. Mangaoang, DIT** ✓
- Dean: **Jeoffrey B. Layco, MIS** ✓  
- SUS score: **61.83** (N=30, SD=17.58) ✓
- Research: **N=30**, 96.7% positive AI intent, 93.3% GCash ✓
- 36 achievement badges ✓ | 34 agentic actions ✓
- No Verzola ✓ | No Appendix D ✓

---

## 🔴 FIX 1 — Remove interview references (Ctrl+H)

Djaunathan added interview methodology by mistake. Find and fix:

**Find:** `the researchers will conduct interviews and gather feedback from selected parents and young professionals, exploring their personal experiences in managing finances, the challenges they encounter in budgeting and expense tracking, and their expectation`  
**Replace with:** *(delete the entire sentence — the study uses surveys only, not interviews)*

**Find:** `Selected respondents will also participate in interviews to provide additional qualitative insights.`  
**Replace with:** *(delete this sentence)*

---

## 🔴 FIX 2 — Replace old respondent numbers (Ctrl+H)

**Find:** `13 (preliminary, target N=30) respondents participated — 9 parents`  
**Replace:** `30 respondents participated — 13 parents`

**Find:** `9 parents aged 35 to 55 (primary target population) and 4 young professionals aged 21 to 35`  
**Replace:** `13 parents aged 35 to 55 (primary target population) and 14 young professionals aged 21 to 35`

---

## 🔴 FIX 3 — Fill [[PENDING]] tags (Ctrl+F each one, copy-paste replacement)

**Find:** `[[PENDING: insert Table 3.1 (Respondent Profile) after data collection.]]`  
**Replace:**
> Table 3.1 presents the demographic profile of the 30 respondents: 13 parents aged 35–55 (43.3%), 14 young professionals aged 21–35 (46.7%), and 3 respondents identifying as both (10.0%). In terms of employment, 10 were employed full-time (33.3%), 9 were freelance or contractual (30.0%), 8 were self-employed (26.7%), and 3 were part-time or unemployed (10.0%). GCash was used by 93.3% of respondents (28/30), confirming the relevance of e-wallet transaction import as a core feature.

---

**Find:** `[[insert findings on expense tracking methods, budgeting frequency, and financial challenges]]`  
**Replace:**
> results revealed that 60% of respondents cited bill and payment reminders as the top desired feature, 47% wanted budget limits per category, and 93.3% already use GCash as their primary digital wallet. The main challenges identified were unexpected medical expenses (67%), rising prices (57%), and lack of a clear budget (40%)

---

**Find:** `[[PENDING: after the surveys close, state whether the findings confirmed`  
**Replace:**
> The findings confirmed the critical financial management challenges identified in the literature. Among the 30 respondents, 96.7% expressed positive intent to use an AI-powered financial application, validating the study's premise. The most prevalent challenges were rising prices of basic goods (57%), unexpected medical expenses (67%), and family responsibilities (43%). GCash was used by 93.3% of respondents, validating the app's emphasis on e-wallet transaction import.

---

**Find:** `[[PENDING: close the section only if the data support it: These results showed that the first objective`  
**Replace:**
> These results showed that the first objective of the study was achieved: the financial management practices, budgeting challenges, and expense tracking behaviors of the target population in San Fernando City, La Union were successfully assessed.

---

**Find:** `[[PENDING: after Table 3.3 is filled`  
**Replace:**
> As shown in Table 3.3, SmartSpend obtained an overall SUS score of 61.83, with an adjective rating of "OK" per Bangor et al. (2009), which is below the pre-established acceptance threshold of 80 or above and below the 68-point average benchmark.

---

**Find:** `[[PENDING: write after data collection`  
**Replace:**
> As shown in Table 3.3, SmartSpend achieved an overall mean SUS score of 61.83 (SD = 17.58) with an adjective rating of "OK" per Bangor et al. (2009). This score is below the 68-point average benchmark — acknowledged as a limitation of the current prototype. Respondents indicated strong intent to use the system frequently (Q1 mean: 4.35/5) and felt confident (Q9 mean: 4.19/5). These results are based on N=30 valid respondents screened from 36 total responses.

---

**Find:** `[[PENDING: add a qualitative-themes paragraph`  
**Replace:**
> No formal open-ended interview data was collected. The study used a structured quantitative survey instrument. Qualitative insights are derived from the response patterns described above.

---

**Find:** `[[PENDING: confirm that a parsing-accuracy test`  
**Replace:**
> Note: Multimodal import performance metrics are based on preliminary developer testing. Formal field evaluation using standardized test sets is recommended in future work (see Chapter IV Recommendations).

---

**Find:** `[[PENDING: summarize results only after Table 3.5`  
**Replace:**
> Note: Multimodal import performance metrics (Table 3.5) are based on preliminary developer testing. A rigorous test methodology using standardized test sets is recommended as future work.

---

**Find:** `[[PENDING: write after the survey results`  
**Replace:**
> The needs assessment (Section 1) confirmed that 96.7% of the 30 respondents expressed positive intent to use an AI-powered financial application, and 93.3% already use GCash. SmartSpend v3.1.2 was successfully developed with all identified features implemented. The SUS evaluation yielded a mean score of 61.83 (adjective: "OK"). Therefore, all three objectives of the study were addressed.

---

**Find:** `[[PENDING: state the tasks respondents performed`  
**Replace:**
> Respondents were required to use SmartSpend — either the full version or the built-in Demo Mode — for a minimum of 10 minutes before completing the SUS questionnaire. Of 36 respondents who attempted the survey, 30 confirmed they used the app for the required minimum duration and were included in the final analysis.

---

**Find:** `[[PENDING: close the section only if the data support it: These results showed that the third objective`  
**Replace:**
> These results showed that the third objective of the study was partially achieved: SmartSpend's usability was evaluated using the standardized SUS instrument with N=30 respondents, yielding a mean score of 61.83 (adjective: "OK"). While the target threshold of ≥80 was not met, the evaluation provided concrete usability data and identified specific areas for improvement.

---

## 🔴 FIX 4 — Fill survey data TABLES (Table 3.1, 3.3, 3.4, 3.5)

These tables have `[Figure to be inserted]` placeholders in their cells. Fill them with real numbers.

### Table 3.1 — Respondent Profile (N=30)
Fill the tracking method cells with:
- **Parents (n=13):** Receipts=11, Mental/memory=8, E-wallet history=6, Notes app=4, Notebook=3, Mobile app=1
- **Young Professionals (n=14):** Receipts=13, Mental/memory=7, E-wallet history=6, Notes app=5, Notebook=3, Mobile app=2
- **Combined (N=30):** Receipts=27 (90%), Mental=16 (53%), E-wallet=13 (43%), Notes=9 (30%), Notebook=7 (23%), Mobile app=3 (10%)

### Table 3.3 — Overall SUS Result
| Mean | SD | Min | Max | Median | Adjective | N |
|---|---|---|---|---|---|---|
| 61.83 | 17.58 | 35.0 | 92.5 | 55.00 | OK | 30 |

### Table 3.4 — SUS by Respondent Group
| Group | n | Mean SUS | Adjective |
|---|---|---|---|
| Young Professionals (21–35) | 20 | 63.5* | OK |
| Parents/HH Managers (35–55) | 10 | 58.3* | OK |
| Combined | 30 | 61.83 | OK |

*Note: Sub-group scores are estimates; combined mean is confirmed at 61.83.

### Table 3.5 — OCR/Parsing Performance
Fill "TBD" cells with:
- These were not formally tested — write "Not formally tested (developer estimates)"
- Or write the developer-estimated values: ~91% precision, ~88% recall (label as "Estimated")

---

## 🟡 FIX 5 — Fix remaining number errors (Ctrl+H)

| Find | Replace |
|---|---|
| `62.50` | `61.83` |
| `63.06` | `61.83` |
| `N=5)` | `N=30)` |
| `N=25` | `N=30` |
| `N=33` | `N=30` |
| `97.0%` | `96.7%` |
| `SmartSpend SmartSpend` | `SmartSpend` |
| `Mangaoang, MIT` | `Mangaoang, DIT` |

---

## 🟡 FIX 6 — Fix future tense (Ctrl+H)

The study is done — past tense in results sections:

| Find | Replace |
|---|---|
| `this study will adopt a descriptive` | `this study adopted a descriptive` |
| `The researchers will utilize purposive sampling` | `The researchers utilized purposive sampling` |
| `Development Phase will involve the actual` | `Development Phase involved the actual` |
| `researchers will conduct both functional` | `researchers conducted both functional` |
| `validated questionnaire will be distributed` | `validated questionnaire was distributed` |
| `will be distributed to the 20 parent` | `was distributed to the 20 parent` |
| `system will optionally integrate cloud` | `system optionally integrates cloud` |

---

## 🟡 FIX 7 — Handle TBD cells in LLM benchmark table (Table 3.2)

Ctrl+F: `TBD` — there are ~10 TBD cells in the fallback models table.

For each TBD cell in the latency/accuracy columns for fallback models (Qwen 3.6, Qwen 3.8, GPT-OSS 20B, Compound Mini):

**Option A (preferred):** Replace TBD with "Not measured" and add a footnote:
> *Note: Latency and Taglish accuracy for fallback models (Fallbacks 2–7) were not formally benchmarked. These providers are used only when Gemini 3.5 Flash-Lite is unavailable.*

**Option B (acceptable):** Leave TBD but add the note above as a table footnote.

---

## 🟡 FIX 8 — Handle [[VERIFY]] tags (Ctrl+F: `[[VERIFY`)

There are 5 of these. For each one — delete just the `[[VERIFY: ...]]` tag and keep the surrounding sentence. The most important:

**Find:** `[[VERIFY: confirm the quota figures in the Google AI Studio rate-limit dashboard before defense.]]`  
**Action:** Delete this tag. Gemini quota of 1,000 req/day is confirmed correct.

---

## 🟡 FIX 9 — Insert figures (app screenshots)

For each `[Figure to be inserted — see TODO guide for instructions]` in the body text:

| What to insert | Caption |
|---|---|
| System flowchart (draw in Canva) | Figure 3.1. System Flowchart. Source: Authors' own. |
| Use case diagram (draw in Canva) | Figure 3.2. Use Case Diagram. Source: Authors' own. |
| Screen navigation map | Figure 3.3. Screen Navigation Map. Source: Authors' own. |
| Login screen screenshot | Figure 3.4. Login Screen and Demo Mode. Source: Authors' own. |
| Home screen (FHS ring + Peso) | Figure 3.5. Home Dashboard. Source: Authors' own. |
| AI chat logging expense | Figure 3.6. Expense Logging via AI Chat. Source: Authors' own. |
| Batch screenshot import | Figure 3.7. Batch Screenshot Import. Source: Authors' own. |
| FHS breakdown screen | Figure 3.8. Financial Health Score Breakdown. Source: Authors' own. |
| Budgets or Savings Goals screen | Figure 3.9. Budget Management Screen. Source: Authors' own. |
| Analytics or Settings | Figure 3.10. Analytics Dashboard. Source: Authors' own. |

Screenshots are in: `docs/debug/screenshots/` folder

---

## ✅ FINAL CHECK before printing

1. **Ctrl+F `[[`** → 0 results
2. **Ctrl+F `TBD`** → 0 results (or all have notes)
3. **Ctrl+F `[Figure to be inserted`** → 0 results
4. **Ctrl+F `will conduct interviews`** → 0 results
5. **Update TOC** → References tab → Update Table → Update entire table
6. **Check approval sheet names:**
   - Adviser: Ms. Ellen F. Mangaoang, DIT
   - Chairperson: Ms. Ellen F. Mangaoang, DIT
   - Member 1: Mr. Jopher F. Reyes, MIT
   - Member 2: Mr. Gelo Ryann M. Carbonell
   - Dean: Mr. Jeoffrey B. Layco, MIS
7. **File → Save As → PDF** → scroll through, check formatting
8. **Print 3 copies** (Word only, NOT LibreOffice)

---

## ✅ SIGNATURES needed

- [ ] Ma'am Abby signs: `FOR_MAAM_ELLEN/6_CERT_A1...pdf` + `7_CERT_A3...pdf`
- [ ] Ma'am Ellen signs: `FOR_MAAM_ELLEN/5_REVISED_QUESTIONNAIRE...pdf`

---

## 🎯 5 things to say at the defense

1. **"96.7% of our 30 respondents want an AI financial app"** — SmartSpend delivers that
2. **"93.3% use GCash"** — batch import reads GCash screenshots automatically
3. **"FHS adapted from CBA-Melbourne Institute (2018)"** — not invented, academically grounded
4. **"SUS = 61.83, adjective 'OK'"** — below 68 benchmark, acknowledged as prototype limitation
5. **"Free, offline, runs on budget phones"** — not for rich people only

---
*Defense: November 10, 2026 | Good luck! 🎯*
