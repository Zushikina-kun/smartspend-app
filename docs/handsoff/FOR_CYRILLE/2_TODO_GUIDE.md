# SmartSpend — Final Manuscript Fix Guide
**Defense:** November 10, 2026 | **Print by:** Before defense

---

## ✅ What's already correct — do NOT change these

- Adviser: **Ellen F. Mangaoang, DIT** ✓
- Dean: **Jeoffrey B. Layco, MIS** ✓
- 36 achievement badges ✓
- 34 agentic actions ✓
- No Verzola ✓
- Defense date: November 10, 2026 ✓

---

## 🔴 CRITICAL — Fix these first (Ctrl+F in Word)

These are the things still broken that must be fixed before printing.

### 1. Replace old respondent numbers

**Find:** `13 (preliminary, target N=30) respondents participated — 9 parents`  
**Replace with:** `30 respondents participated — 13 parents`

**Find:** `9 parents aged 35 to 55 (primary target population) and 4 young professionals aged 21 to 35`  
**Replace with:** `13 parents aged 35 to 55 (primary target population) and 14 young professionals aged 21 to 35`

---

### 2. Fill `[[PENDING]]` and `[[insert ...]]` tags

Use Ctrl+F to find each one and replace with the text below.

**Find:** `[[PENDING: insert Table 3.1 (Respondent Profile) after data collection.]]`  
**Replace with:**
> Table 3.1 presents the demographic profile of the 30 respondents: 13 parents aged 35–55 (43.3%), 14 young professionals aged 21–35 (46.7%), and 3 respondents identifying as both (10.0%). In terms of employment, 10 were employed full-time (33.3%), 9 were freelance or contractual (30.0%), 8 were self-employed (26.7%), and 3 were part-time or unemployed (10.0%). GCash was used by 93.3% of respondents (28/30), confirming the relevance of e-wallet transaction import as a core feature.

---

**Find:** `[[insert findings on expense tracking methods, budgeting frequency, and financial challenges]]`  
**Replace with:**
> results revealed that 60% of respondents cited bill and payment reminders as the top desired feature, 47% wanted budget limits per category, and 93.3% already use GCash as their primary digital wallet. The main challenges identified were unexpected medical expenses (67%), rising prices (57%), and lack of a clear budget (40%)

---

**Find:** `[[PENDING: after the surveys close, state whether the findings confirmed`  
**Replace with:**
> The findings confirmed the critical financial management challenges identified in the literature. Among the 30 respondents, 96.7% expressed positive intent to use an AI-powered financial application, validating the study's premise. The most prevalent challenges were rising prices of basic goods (57%), unexpected medical expenses (67%), and family responsibilities (43%). GCash was used by 93.3% of respondents, validating the app's emphasis on e-wallet transaction import.

---

**Find:** `[[PENDING: close the section only if the data support it: These results showed that the first objective`  
**Replace with:**
> These results showed that the first objective of the study was achieved: the financial management practices, budgeting challenges, and expense tracking behaviors of the target population in San Fernando City, La Union were successfully assessed.

---

**Find:** `[[PENDING: after Table 3.3 is filled`  
**Replace with:**
> As shown in Table 3.3, SmartSpend obtained an overall SUS score of 61.83, with an adjective rating of "OK" per Bangor et al. (2009), which is below the pre-established acceptance threshold of 80 or above and below the 68-point average benchmark.

---

**Find:** `[[PENDING: write after data collection`  
**Replace with:**
> As shown in Table 3.3, SmartSpend achieved an overall mean SUS score of 61.83 (SD = 17.58) with an adjective rating of "OK" per Bangor et al. (2009). This score is below the 68-point average benchmark — acknowledged as a limitation of the current prototype. Respondents indicated strong intent to use the system frequently (Q1 mean: 4.35/5) and felt confident (Q9 mean: 4.19/5). These results are based on N=30 valid respondents screened from 36 total responses.

---

**Find:** `[[PENDING: add a qualitative-themes paragraph`  
**Replace with:**
> No formal open-ended interview data was collected. The study used a structured quantitative survey instrument. Qualitative insights are derived from the response patterns described above.

---

**Find:** `[[PENDING: confirm that a parsing-accuracy test`  
**Replace with:**
> Note: Multimodal import performance metrics are based on preliminary developer testing. Formal field evaluation using standardized test sets is recommended in future work (see Chapter IV Recommendations).

---

**Find:** `[[PENDING: summarize results only after Table 3.5`  
**Replace with:**
> Note: Multimodal import performance metrics (Table 3.5) are based on preliminary developer testing. A rigorous test methodology using standardized test sets is recommended as future work.

---

**Find:** `[[PENDING: write after the survey results`  
**Replace with:**
> The needs assessment (Section 1) confirmed that 96.7% of the 30 respondents expressed positive intent to use an AI-powered financial application, and 93.3% already use GCash. SmartSpend v3.1.2 was successfully developed with all identified features implemented. The SUS evaluation yielded a mean score of 61.83 (adjective: "OK"). Therefore, all three objectives of the study were addressed.

---

**Find:** `[[PENDING: state the tasks respondents performed`  
**Replace with:**
> Respondents were required to use SmartSpend — either the full version or the built-in Demo Mode — for a minimum of 10 minutes before completing the SUS questionnaire. Of 36 respondents who attempted the survey, 30 confirmed they used the app for the required minimum duration and were included in the final analysis.

---

**Find:** `[[PENDING: close the section only if the data support it: These results showed that the third objective`  
**Replace with:**
> These results showed that the third objective of the study was partially achieved: SmartSpend's usability was evaluated using the standardized SUS instrument with N=30 respondents, yielding a mean score of 61.83 (adjective: "OK"). While the target threshold of ≥80 was not met, the evaluation provided concrete usability data and identified specific areas for improvement.

---

### 3. Fix remaining old numbers (Ctrl+H — Replace All)

| Find | Replace with |
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

### 4. Fix future tense in methodology/results (Ctrl+H)

These should be past tense since the work is done:

| Find | Replace with |
|---|---|
| `this study will adopt a descriptive` | `this study adopted a descriptive` |
| `researchers will utilize a Kanban` | `researchers utilized a Kanban` |
| `Development Phase will involve the actual` | `Development Phase involved the actual` |
| `validated questionnaire will be distributed` | `validated questionnaire was distributed` |
| `will be distributed to the 20 parent` | `was distributed to the 20 parent` |

---

## 🟡 FIGURES — Insert these in Word

For each placeholder, search using Ctrl+F and replace with an actual image.

| Search for | What to insert |
|---|---|
| `Figure 3.1` placeholder | System flowchart (draw in Canva → export PNG) |
| `Figure 3.2` placeholder | Use case diagram (draw in Canva → export PNG) |
| `Figure 3.3` placeholder | Screen navigation map (draw in Canva → export PNG) |
| `Figure 3.4` placeholder | Login screen screenshot |
| `Figure 3.5` placeholder | Home screen (FHS ring + Peso) |
| `Figure 3.6` placeholder | AI chat logging expense in Taglish |
| `Figure 3.7` placeholder | Batch screenshot import screen |
| `Figure 3.8` placeholder | FHS breakdown screen |
| `Figure 3.9` placeholder | Budgets or Savings Goals screen |
| `Figure 3.10` placeholder | Analytics or Settings screen |

Caption below each figure: `Figure 3.X. [Title]. Source: Authors' own development.`

Screenshots are in `docs/debug/screenshots/` folder — use those.

---

## 🟡 AFTER ALL FIXES

1. **Ctrl+F `[[`** → must find **0 results**
2. **Update TOC** → References tab → Update Table → Update entire table
3. **Check approval sheet names:**
   - Adviser: Ms. Ellen F. Mangaoang, DIT
   - Chairperson: Ms. Ellen F. Mangaoang, DIT
   - Member 1: Mr. Jopher F. Reyes, MIT
   - Member 2: Mr. Gelo Ryann M. Carbonell
   - Dean: Mr. Jeoffrey B. Layco, MIS
4. **File → Save As → PDF** → scroll through, check formatting
5. **Print 3 copies** (Word only, not LibreOffice)

---

## 🟡 SIGNATURES TO GET

- [ ] Ma'am Abby signs: `FOR_MAAM_ELLEN/6_CERT_A1...pdf` + `7_CERT_A3...pdf`
- [ ] Ma'am Ellen signs: `FOR_MAAM_ELLEN/5_REVISED_QUESTIONNAIRE...pdf`

---

## 🎯 5 things to say at the defense

1. **"96.7% of our 30 respondents want an AI financial app"** — and SmartSpend delivers exactly that
2. **"93.3% use GCash"** — our batch import reads GCash screenshots automatically, no typing needed
3. **"Our FHS is adapted from the CBA-Melbourne Institute framework"** — not invented, academically grounded
4. **"SUS score is 61.83 — adjective 'OK' per Bangor 2009"** — below benchmark, acknowledged as prototype limitation
5. **"The app is free, offline, runs on budget phones"** — not for rich people only

---

*Defense: November 10, 2026. You got this. 🎯*
