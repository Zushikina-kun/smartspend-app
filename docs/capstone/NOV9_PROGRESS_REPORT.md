# SmartSpend — Progress Report
## Capstone 2 | AY 2026–2027 | Lorma Colleges CCSE
## Reporting Date: November 9, 2026
## Final Defense: November 10, 2026
## Team: Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag
## Adviser: Ms. Ellen F. Mangaoang, DIT

---

## 1. Project Overview

SmartSpend is an offline-first Android mobile application that helps Filipino parents and young professionals in San Fernando City, La Union track their household and personal finances using Taglish natural language AI, multi-modal transaction input (including GCash and e-wallet screenshot import), and a real-time 0–100 Financial Health Score (FHS). The app is built on Flutter/Dart and targets respondents who lack access to formal banking infrastructure or find existing finance apps too complex for daily Philippine living. SmartSpend addresses three research objectives: assessing financial management practices, developing the system, and evaluating it through the System Usability Scale (SUS).

---

## 2. Development Accomplishments

SmartSpend **v3.1.2+110** is the production build presented at this defense. Completed features:

- **7 transaction input modalities:** Taglish AI chat, Voice (en_PH locale), on-device OCR receipt scan, Batch screenshot import (40+ platforms), Barcode lookup, Bank CSV paste, Manual entry
- **AI architecture:** Gemini 3.5 Flash-Lite as primary engine (upgraded September 10, 2026); 9-provider fallback chain including Groq LLaMA, Cerebras, and Local LLM option; **34 agentic actions**
- **Financial Health Score (FHS):** Dual-mode Prototype Observed FHI — Full Mode (4 components × 25 pts) and Lightweight Mode; Warning Decay (−5 pts/day, max −15); Logging Gap Adjustment (±2–3 pts/day)
- **36 achievement badges** with streak mechanics grounded in Self-Determination Theory
- **45 screens**, Peso AI mascot (12 mood states, 31 voice contexts), 12 color themes + high-contrast WCAG AA mode
- **RA 10173 compliance:** 5-pattern on-device PII redaction before cloud AI calls
- **Offline-first SQLite** (26 tables) with Firebase cloud sync; 100% data integrity in network dropout tests
- Public APK release at: https://github.com/Zushikina-kun/smartspend-app/releases/tag/v3.1.2

---

## 3. Research Progress

### Objective 1 — Needs Assessment (Descriptive Survey)

**Target:** N=30 (20 parents + 10 young professionals, San Fernando City, La Union)
**Preliminary:** N=13 as of November 2026

Key preliminary findings (N=13):
- **76.9%** of respondents struggle with overspending
- **53.8%** rely on manual notebook or no tracking at all; only **7.7%** use a mobile app
- **53.8%** want GCash/e-wallet integration as top feature priority
- **69.2%** expressed definite or probable intent to use an AI financial app
- Mean manual tracking difficulty: **3.08 / 5.00**; **61.5%** rate manual tracking as inconvenient or sometimes inconvenient

> *Final N=30 data collection is ongoing. These are directionally consistent with BSP CFIS 2025 national data.*

### Objective 2 — System Development

**Status: COMPLETE.** SmartSpend v3.1.2 is fully developed, deployed, and publicly available. All core features are functional. Engineering benchmarks achieved:
- OCR precision: **91.2%** / recall: **88.5%** across 50-receipt test corpus
- Taglish AI categorization accuracy: **94.6%** on a 150-prompt test corpus
- SQLite-to-Firebase sync data integrity: **100%** under 10 simulated network dropout tests
- Average AI response time: **< 1.8 seconds**

### Objective 3 — Usability Evaluation (SUS)

**Target:** N=30; **Preliminary:** N=5

Individual preliminary SUS scores: **60.0, 55.0, 55.0, 75.0, 67.5**
Preliminary combined mean: **62.50**
Adjective rating: **"OK"** per Bangor et al. (2009)
Status: Below the project target of ≥80 and below the 68-point average benchmark — documented as a prototype limitation. Full N=30 collection ongoing.

---

## 4. Manuscript Status

| Chapter | Title | Status |
| :--- | :--- | :--- |
| Chapter I | Introduction, Problem Statement, Objectives, Significance, Scope | ✅ Complete |
| Chapter II | Review of Related Literature, Research Design, Methodology | ✅ Complete |
| Chapter III | Results and Discussion (Needs Assessment, System Dev, SUS) | ✅ Complete (preliminary data noted) |
| Chapter IV | Summary, Conclusions, Recommendations | ✅ Complete |
| Appendices | Survey instruments, SUS forms, FHS formula tables, screenshots | 🔄 Pending: figures, final N=30 data tables |
| Signature Pages | Adviser and panel approval pages | 🔄 Pending: final panel signatures |

> *3 printed manuscript copies are ready for submission. All `[[` placeholder tags have been removed.*

---

## 5. Validation Status

| Instrument | Validator | Status |
| :--- | :--- | :--- |
| FHS Questionnaire (Research Survey) | Ma'am Abby (FHS Validator) | 🔄 Instrument validated; signature pending |
| SUS Instrument | Brooke (1996) standardized — no custom validation needed | ✅ Standard instrument, no validator signature required |
| IT/Technical Validator | To be confirmed | 🔄 Pending |

---

## 6. Survey Status

| Survey | Target N | Current N | Link/Notes |
| :--- | :---: | :---: | :--- |
| Research Survey (Needs Assessment) | 30 | **13** | Active — collecting via Google Forms |
| SUS Evaluation | 30 | **5** | Active — requires 10-min app use before rating |

> *Both surveys are live. Respondents must use the app (Demo Mode or personal data) before completing the SUS.*

---

## 7. What's Ready for Defense

- ✅ SmartSpend v3.1.2 APK — fully functional, installable, demo-ready
- ✅ Demo Mode — pre-loaded with realistic Filipino household expense data
- ✅ All 7 input modalities functional and demo-tested
- ✅ FHS calculation, Warning Decay, Logging Gap Adjustment — all operational
- ✅ 36 achievement badges live in-app
- ✅ Manuscript Chapters I–IV — complete drafts
- ✅ Presentation slides (SmartSpend_Defense_Presentation.html) — 18 slides, complete
- ✅ Defense Presentation Script (DEFENSE_PRESENTATION_SCRIPT.md) — per-slide scripts for all 3 members
- ✅ Defense Q&A Prep (DEFENSE_QA_PREP.md) — panel question bank with prepared answers
- ✅ Competitor comparison matrix updated (Tarsi, BudgetPH, GCash, Alkansya AI)
- ✅ RA 10173 compliance architecture documented and implemented
- ✅ Engineering benchmarks complete (OCR, AI categorization, sync recovery, latency)
- ✅ Preliminary SUS (N=5) — documented honestly as below-benchmark prototype result

---

## 8. What's Still Pending

- 🔄 **N=30 research survey** — 13/30 collected; needed for final Chapter III tables
- 🔄 **N=30 SUS evaluation** — 5/30 collected; final usability score pending
- 🔄 **Figures** — some manuscript figures (screenshots, FHS charts) pending final insertion
- 🔄 **Validator signatures** — Ma'am Abby (FHS validator), IT validator pending
- 🔄 **Panel approval signatures** — collected at/after final defense
- 🔄 **Final N=30 data tables** — Appendices will be updated upon data completion

> *None of the pending items block the defense. The preliminary data is clearly labeled, the system is fully built, and all benchmarks are complete.*

---

## 9. Timeline to Defense (Nov 10)

| Time | Activity |
| :--- | :--- |
| **Nov 9 — Today (Progress Report)** | Present this progress report at the Nov 9 reporting session |
| **Nov 9 Evening** | Install v3.1.2 APK on demo phone; verify all 7 input methods; reset AI daily limit; charge to 100%; review Q&A prep; sleep before midnight |
| **Nov 10 Morning (Defense Day)** | Cold-start demo phone; bring printed manuscripts, signature pages, defense fee receipt, USB cable, backup hotspot |
| **Nov 10 — Final Defense** | 18-slide presentation + live demo + Q&A panel |
| **Post-Defense** | Collect panel signatures; finalize N=30 surveys; update manuscript with final data |

---

*Document generated: November 9, 2026*
*SmartSpend v3.1.2+110 · Flutter/Dart · Android · Lorma Colleges CCSE*
