# CAPSTONE PROJECT 2 — WEEK 1 PROGRESS REPORT
## Project Reorientation & Consultation

---

| | |
|---|---|
| **Project Title** | SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management Application for Filipino Users Using Agentic Large Language Model Architecture |
| **Group Name** | Lucid Frame |
| **Course** | Bachelor of Science in Information Technology (BSIT) — 4th Year, 1st Semester |
| **Institution** | Lorma Colleges, College of Computer Studies and Engineering (CCSE) |
| **Academic Year** | 2026–2027, 1st Semester |
| **Date Submitted** | August 11, 2026 — Week 1 |
| **Teacher-in-Charge** | Janelli M. Mendez, DIT |
| **Reference** | Capstone Project 2 Syllabus — 1st Sem AY2026-2027 (see docs/Capstone_Project_2_Syllabus_1st_Sem_AY2026-2027.docx) |

---

## GROUP MEMBERS

| Name | Role |
|------|------|
| Brix A. Directo | Lead Developer |
| Cyrille John M. Rubis | UI/UX Designer & Documentation Lead |
| Djaunathan Albert S. Madayag | Project Manager & QA Lead |

---

## 1. PROJECT OVERVIEW

**SmartSpend** is an AI-powered mobile personal finance tracker for Android built with Flutter. It helps everyday Filipino users — especially students and young professionals — track spending, set budgets, and get personalized financial advice using conversational AI.

**Key differentiator:** The only free, offline-capable Filipino-English financial app that combines voice/camera/screenshot input with 29 agentic AI actions, a dual-mode Financial Health Score, and Philippine-specific financial knowledge (SSS, PhilHealth, Pag-IBIG, BIR TRAIN Law, PH banks).

**Current Version:** 2.9.2
**Platform:** Android (Flutter/Dart)
**Status:** ✅ Development complete — entering documentation and defense phase

---

## 2. CURRENT SYSTEM STATUS

### 2.1 Application Build
- **Version:** 2.9.2
- **Build date:** August 2, 2026
- **APK size:** 44.7 MB (arm64-v8a release, split, obfuscated)
- **GitHub repository:** https://github.com/Zushikina-kun/smartspend-app
- **GitHub release:** https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.2
- **Repository visibility:** Public (August 2026) — with Non-Commercial LICENSE (Lucid Frame retains all commercial rights)

### 2.2 Development Completion Summary

| Module | Status | Notes |
|--------|--------|-------|
| Expense tracking (6 input methods) | ✅ Complete | Voice, OCR, Barcode, Screenshot Batch, Manual, AI Chat |
| AI Chat (29 agentic actions) | ✅ Complete | Multi-provider: Gemini 3.1/3.5, Groq, Cerebras |
| Financial Health Score (FHS) | ✅ Complete | Dual-mode: Full + Lightweight |
| Budget management | ✅ Complete | Category budgets + multi-period spending limits |
| Savings goals | ✅ Complete | With emergency fund calculator |
| Debt & lending tracker | ✅ Complete | With payment plans |
| Analytics & charts | ✅ Complete | 10+ chart types, 50/30/20, DTI |
| Wallet balances (30+ PH banks) | ✅ Complete | Auto-deduct, transfers |
| Insurance & contributions tracker | ✅ Complete | SSS, PhilHealth, Pag-IBIG |
| Firebase cloud sync | ✅ Complete | Full Firestore sync |
| App Lock (PIN + Biometric) | ✅ Complete | Cold-start only (no resume interruptions — matches GCash/Maya UX) |
| Smart Import (camera + gallery) | ✅ Complete | 40+ screenshot platform types, barcode from gallery, dark image enhancement |
| AI Model Selector | ✅ Complete | Manual selection from 5 providers in Settings |
| Spending Anomaly Alert Toggle | ✅ Complete | Enable/disable weekly spike notifications in Settings |
| Goal deadline + Debt due date via AI | ✅ Complete | AI can update deadline/due_date via chat |
| Achievements & Gamification | ✅ Complete | 23 badges, 10 daily quests |
| Unified Spending Limits | ✅ Complete | Daily/weekly/monthly/yearly |
| Lightweight Mode | ✅ Complete | FHS without income tracking |
| Logging Gap Detection | ✅ Complete | FHS gap penalty/bonus |
| Security | ✅ Complete | API keys excluded, LICENSE added |

---

## 3. PROOF OF PROGRESS

### 3.1 GitHub Repository Evidence
- **Total commits:** 110+ commits over the development period
- **Latest commit:** `529252f` — "fix: LICENSE copyright year + dead file refs cleanup"
- **Public repository:** https://github.com/Zushikina-kun/smartspend-app
- **Branch:** master (production-ready)

**Recent significant commits:**
| Commit | Description | Date |
|--------|-------------|------|
| `529252f` | LICENSE year fix, dead file refs removed from README/HOWTORUN | Aug 11, 2026 |
| `5887556` | Docs: fix table count 18→20, screens 31→36, services 23→26 (code-verified) | Aug 11, 2026 |
| `ac5e688` | Source: version 2.9.1 in pubspec, backup export, debug log, barcode UA | Aug 11, 2026 |
| `04f649f` | Final AY2026-2027 sweep — all 16 docs updated | Aug 11, 2026 |
| `a532927` | Add Capstone 2 syllabus + academic year fix | Aug 11, 2026 |
| `816f003` | Docs cleanup — Defense Reviewer, Progress Report, Security Guide | Aug 11, 2026 |
| `b9c38de` | Manuscript fix guide for Google Docs corrections | Aug 11, 2026 |
| `3c0fff0` | Week 1 Progress Report added | Aug 11, 2026 |
| `37e37ed` | Final v2.9.1 docs sweep — app lock, model names, version stamps | Aug 2, 2026 |
| `679fb45` | LICENSE added (Non-Commercial, Lucid Frame) | Aug 2, 2026 |
| `214f69a` | App lock simplified — cold-start only, no resume interruptions | Aug 2, 2026 |
| `95ae049` | AI model selector, anomaly toggle, Filipino terms, goal/debt date edit | Aug 1, 2026 |
| `890330a` | Capstone 2 documentation reference file | Aug 1, 2026 |
| `0eef294` | Security: google-services.json removed from tracking | Aug 1, 2026 |
| `f86b2fd` | FHS accuracy: logging consistency current-month only | Jul 28, 2026 |

### 3.2 System Prototype
The system is fully functional and deployed as a release APK.

**Download link:** https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.2

| APK File | Size | Target Device |
|----------|------|---------------|
| SmartSpend-v2.9.2-arm64-v8a.apk | 44.7 MB | Modern phones (2018+) |
| SmartSpend-v2.9.2-armeabi-v7a.apk | 37.0 MB | Older/32-bit phones |
| SmartSpend-v2.9.2-x86_64.apk | 47.6 MB | Emulators |

**Primary test device:** Poco X6 Pro (Android 16, HyperOS 2) — all features verified working.

### 3.3 Documentation Produced

| Document | Location | Status |
|----------|----------|--------|
| Application Documentation (DOCUMENTATION.md) | /DOCUMENTATION.md | ✅ Complete — v2.9.4 |
| How to Run & Build | /HOWTORUN.md | ✅ Complete |
| README | /README.md | ✅ Complete |
| Security Policy | /SECURITY.md | ✅ Complete |
| LICENSE | /LICENSE | ✅ Complete — 2026–2027 |
| Capstone 2 Documentation Reference | /docs/CAPSTONE_REFERENCE.md | ✅ Complete |
| Defense Reviewer (pre-defense cheat sheet) | /docs/DEFENSE_REVIEWER.md | ✅ Complete |
| Week 1 Progress Report (this document) | /docs/PROGRESS_REPORT_WEEK1.md | ✅ Complete |
| Competitor Analysis & Feature Ideas | /docs/BENCHMARK.md | ✅ Updated v2.9.4 |
| **App & LLM Benchmark (14 apps, 13 LLMs)** | /docs/BENCHMARK.md | ✅ New — Aug 2026 |
| **System Overview (adviser/panel reference)** | /docs/SYSTEM_OVERVIEW.md | ✅ New — Aug 2026 |
| **Research Basis (all feature academic citations)** | /docs/RESEARCH_BASIS.md | ✅ New — Aug 2026 |
| **Application Pipeline (how app works)** | /docs/APPLICATION_PIPELINE.md | ✅ New — Aug 2026 |
| Capstone 2 TODO & Feature Analysis | /docs/BENCHMARK.md | ✅ Updated v2.9.4 |
| LLM Comparison Table (Chapter 3) | /docs/BENCHMARK.md | ✅ Updated v2.9.4 |
| Paper Guide (Chapters 1–5) | /docs/PAPER_GUIDE.md | ✅ Updated v2.9.4 |
| Manuscript Fix Guide (Google Docs corrections) | /docs/MANUSCRIPT_FIXES.md | ✅ Complete |
| Demo Script | /docs/DEMO_SCRIPT.md | ✅ Updated v2.9.4 |
| Master Roadmap | /docs/PROJECT_STATUS.md | ✅ Updated v2.9.4 |
| Task List (complete status of all tasks) | /docs/PROJECT_STATUS.md | ✅ Updated v2.9.4 |
| Capstone 2 TODO | /docs/PROJECT_STATUS.md | ✅ Updated v2.9.4 |
| Play Store & Security Guide | /docs/PLAYSTORE_GUIDE.md | ✅ Updated v2.9.4 |
| Capstone Paper (manuscript draft) | /docs/SMARTSPEND Capstone Docs.md | ✅ Chapters 1–2 complete |
| Capstone 2 Syllabus | /docs/Capstone_Project_2_Syllabus_1st_Sem_AY2026-2027.docx | ✅ Reference copy |

### 3.4 Key Technical Metrics

| Metric | Value |
|--------|-------|
| Total screens | 36 screens |
| Total services | 26 services |
| AI agentic actions | 29 actions |
| LLM providers (auto-failover) | 5 providers |
| Expense categories | 14 built-in + unlimited custom |
| Achievement badges | 23 badges |
| Daily quests | 10 rotating |
| Screenshot platforms detected | 40+ types |
| PH banks in database | 20 banks + 5 e-wallets |
| SQLite schema | v11, 20 tables |
| Firebase services used | Auth, Firestore, Crashlytics, App Check, Remote Config |

---

## 4. FINANCIAL HEALTH SCORE — SYSTEM SPECIFICATION

This is the core academic contribution of SmartSpend.

### Full Mode (income tracking ON)
| Component | Measurement | Max Points |
|-----------|------------|------------|
| Savings Rate | Actual savings vs 20% income target | 25 |
| Overspend Control | Days within daily budget | 25 |
| Budget Adherence | % of category budgets on track | 25 |
| Logging Consistency | Logged days / active days (this month only) | 25 |

### Lightweight Mode (income tracking OFF)
| Component | Measurement | Max Points |
|-----------|------------|------------|
| Spending Restraint | vs self-set spending limit | 25 |
| Logging Consistency | Same formula as full mode | 25 |
| Category Balance | No single category > 40% of total | 25 |
| Habit Streak | Consecutive days logged (14-day target) | 25 |

**Score adjustments:** Warning Decay (−5/day, max −15) + Gap Adjustment (−3 or +2/day based on user confirmation)

---

## 5. REVISED PROJECT PLAN — REMAINING WORK

Based on the Capstone 2 timeline, here is the current plan for the remaining weeks:

| Week | Activity | Our Tasks | Responsible |
|------|----------|-----------|-------------|
| **Week 1** *(current)* | Project Reorientation | Submit progress report, consult with adviser | All |
| **Week 2** | Chapter 3 discussion | Finalize Chapter 3 (Methodology) — LLM selection justification, system architecture, FHS formula | Cyrille + Brix |
| **Week 3** | Chapter 4 development | Write Chapter 4 (Results & Discussion) — screenshots, FHS results, feature walkthrough | Cyrille |
| **Week 4** | Final software check | Final regression testing, bug fixes if needed | Brix |
| **Week 5** | Pre-Final Defense prep | Finalize presentation, rehearse demo flow | All |
| **Week 6** | Pre-Final Defense | Present to panel | All |
| **Week 7** | Testing & debugging | Address panel recommendations, run SUS survey | All |
| **Week 8–10** | Documentation | Complete manuscript Chapters 1–5, abstract, bibliography | Cyrille |
| **Week 11–13** | Final Defense | Present completed system + paper | All |
| **Week 15–17** | Revisions & submission | Revise based on panel feedback, final manuscript | All |

### Pending documentation tasks:
- [ ] Complete Chapter 3 (System Design & Methodology) — FHS formula write-up, LLM architecture justification, database schema diagram
- [ ] Complete Chapter 4 (Results & Discussion) — screenshots per feature, testing results table
- [ ] SUS (System Usability Scale) survey — conduct with respondents, tabulate results
- [ ] Chapter 5 (Conclusions & Recommendations)
- [ ] Abstract, acknowledgements, bibliography (APA format)
- [ ] Appendices — survey instrument, source code snippets, user manual

---

## 6. WORK SCHEDULE

| Member | Primary Responsibility | Weekly Hours (estimate) |
|--------|----------------------|------------------------|
| Brix A. Directo | System maintenance, bug fixes, technical documentation | 10–15 hrs/week |
| Cyrille John M. Rubis | Manuscript writing (Chapters 1–5), formatting, layout | 12–15 hrs/week |
| Djaunathan Albert S. Madayag | Project coordination, SUS survey, testing documentation | 8–10 hrs/week |

---

## 7. SYSTEM SCREENSHOTS REFERENCE

*(For the actual presentation, use screenshots from the installed APK.
Key screens to show:)*

1. **Login screen** — Google Sign-In + Demo Mode option
2. **Home Dashboard** — FHS score card, spending summary, wallet card
3. **AI Chat** — conversation showing expense logging and financial advice
4. **Smart Import** — unified camera sheet (4 modes)
5. **Batch Screenshot Import** — showing Shopee/Steam detection
6. **Analytics** — pie chart, 50/30/20, FHS component breakdown
7. **Budgets screen** — category budgets with pace indicators
8. **Profile screen** — settings sheet with AI model selector
9. **Achievements** — badge grid
10. **Financial Health Certificate** — shareable score card

---

## 8. TESTING RESULTS SUMMARY

### 8.1 Build Testing
- ✅ Debug build — passes on Poco X6 Pro (Android 16)
- ✅ Release build — all 3 ABI variants (arm64-v8a, armeabi-v7a, x86_64) clean build
- ✅ Obfuscation + shrinking — no crashes from class name mangling
- ✅ Firebase services — Auth, Firestore, Crashlytics all operational

### 8.2 Feature Testing (manual, on primary device)
- ✅ AI chat — expense logging, all 29 actions verified
- ✅ Voice input — en-PH locale, parsing accuracy >90%
- ✅ OCR receipt scanning — Jollibee, SM receipts tested
- ✅ Batch screenshot import — Steam, Shopee, GCash tested
- ✅ FHS calculation — both Full Mode and Lightweight Mode verified
- ✅ Cloud sync — Firestore read/write verified
- ✅ App Lock — cold-start biometric verified (no loop)
- ✅ Spending limits — daily/weekly/monthly/yearly all trigger notifications

### 8.3 Known Issues / Limitations
- Voice input quality depends on microphone and ambient noise
- OCR accuracy drops on low-quality or crumpled receipts
- AI responses limited to 60/day per provider (rate limit)
- App Check in debug/monitoring mode — needs Play Integrity for Play Store

### 8.4 SUS Evaluation
- **Status:** Pending — to be conducted in Week 7 after Pre-Final Defense
- **Target score:** ≥ 80 (Good classification per Bangor et al., 2009)
- **Validator:** Subject matter expert in financial management (survey content validation) + subject matter expert in IT (system and SUS evaluation) — credentials documented in Appendix A validation certificates, names optional

---

## 9. MEETING RECORDS SUMMARY

| Date | Type | Participants | Topics Discussed |
|------|------|-------------|-----------------|
| June 2026 | Development session | Lucid Frame | Capstone 1 → 2 transition, feature prioritization |
| July 2026 | Development session | Lucid Frame | AI architecture, multi-model routing, FHS formula |
| July 28, 2026 | Development session | Lucid Frame | Debug session, gap detection, AI guardrails |
| August 1, 2026 | Development session | Lucid Frame | App lock fix, docs sweep, GitHub release |
| August 2, 2026 | Reorientation | Lucid Frame | Week 1 progress report, Capstone 2 timeline |
| August 11, 2026 | Documentation session | Lucid Frame | Full docs sweep — AY2026-2027 update, version consistency audit, LICENSE fix, dead reference cleanup |

---

## 10. ADVISER CONSULTATION NOTES

*(To be filled in during/after Week 1 consultation)*

**Consultation date:** _______________
**Teacher-in-Charge:** Janelli M. Mendez, DIT
**Capstone Adviser:** Johnny Verzola, MTS *(note: adviser status pending — Verzola advised the group to seek a new adviser for Capstone 2 due to his expected resignation; reassignment to be confirmed with department)*
**Issues raised:**
- _______________
**Recommendations:**
- _______________
**Action items:**
- _______________

---

## 11. PANEL RECOMMENDATIONS STATUS

Status of all 29 panel recommendations from the Capstone 1 re-defense evaluation.

### ✅ FULLY ADDRESSED IN MANUSCRIPT (21 of 29)

| # | Recommendation | How It Was Addressed |
|---|---|---|
| 1 | Graphs — visual data (bar chart of PH financial literacy rates) | Figure 1.1 caption and placeholder inserted in manuscript (BSP, 2021; Inquiro, 2024) |
| 2 | Basis of study must have real evidence, not personal opinion | BSP 2021, PSA FIES 2021, Flores 2025, World Bank 2022, Inquiro 2024 — all cited throughout Project Context |
| 3 | Real financial problem identified with data | BSP: only 2% answered all 6 literacy questions; PSA FIES: households spend beyond income; Flores 2025: "come-what-may" attitude |
| 4 | International and national gap with evidence | Table 1.1 — Three-Level Gap Analysis (International / National PH / Demographic) |
| 5 | Solution follows naturally from identified problem | Narrative flows: gap → SmartSpend solution throughout Project Context |
| 6 | Compare to existing apps | Table 1.2 — Feature Comparison vs Tarsi, YNAB, Monarch, Copilot, PocketGuard, **BudgetPH**, **Alkansya AI** (Fix 17 in fix guide adds the two new Filipino app columns) |
| 7 | Find existing projects with results, gaps, and recommendations | Tarsi, YNAB, Monarch, Copilot, PocketGuard — each discussed; **BudgetPH and Alkansya AI added** in `docs/BENCHMARK.md` with full gap analysis |
| 8 | Articles proving financial problems exist (mahal ang gasolina, debt culture) | Flores 2025 (debt culture, come-what-may), BSP 2021, PSA FIES 2021, World Bank 2022 |
| 9 | Literature Review as separate objective | Correctly NOT added as separate objective — per Lorma template, RRL is integrated into Project Context (confirmed by adviser feedback v3/v4) |
| 10 | Comparative analysis of LLMs — justify best choice | Table 2.2 in Ch3 draft now covers **13 models** (Gemini 3.1 Flash-Lite primary + 4 fallbacks + 8 evaluated/rejected) across 6 criteria — see `docs/BENCHMARK.md` and Fix 18 in fix guide |
| 11 | LLM processing and feedback — explain how it works | Zero-shot/few-shot prompting paragraph present; user feedback for prompt refinement explained |
| 17 | Descriptive developmental label — correct terminology | "descriptive-developmental research approach" explicitly stated in Research Design section |
| 18 | FHS basis and computation — explain clearly | Full 4-component formula with weights, both modes (Full + Lightweight), detailed in Ch3 draft |
| 19 | FHS must be bounded — 0 floor, 100 cap | "The score is bounded at all times between 0 and 100" — explicitly stated in manuscript |
| 20 | Consequence for ignoring spending warning | FHS decay: −5 pts/day, max −15, with 3-tier escalation system — documented in manuscript |
| 21 | Behavioral analysis — system analyzes behavior patterns | Mood tracking, impulse pause, velocity alerts, spending correlation, behavioral intervention layer |
| 22 | Clarify scope — tracker, savings, investment, bank | Scope & Limitations: no bank integration (BSP reason), no investment features, no professional advice |
| 23 | SUS — how evaluated, who takes it, target score | Target ≥ 80, 30 respondents, Bangor et al. 2009 — stated in Research Design |
| 24 | Financial expert validator connected to target population | Susan C. Arquisal (BSC Management, active business owner) named with credentials and role |
| 28 | Specify each Kanban phase with concrete tasks and deliverables | Table 2.3 — all 7 phases with Key Tasks + Deliverable columns |
| 29 | Weekly, monthly, and yearly expense summaries | Weekly/monthly/yearly summaries documented; Period Comparison, Heatmap, Forecast in Analytics |

---

### ⚠️ ADDRESSED — STILL NEEDS GOOGLE DOCS UPDATE (7 of 29)

These are done in the fix guide (`docs/MANUSCRIPT_FIXES.md`) — Cyrille needs to apply them in Google Docs.

| # | Recommendation | Fix # | What to Apply in Google Docs |
|---|---|---|---|
| 12 | Make it general — remove rigid account type classifications | Fix 11 | Add paragraph explaining account types are flexible adaptive labels, not restrictions |
| 13 | Who is really the best target population? | Fix 12 | Reframe main objective sentence — parents PRIMARY, young professionals secondary |
| 14 | Parents as primary target | Fix 12 | Rewrite Population and Locale opening paragraph — parents framed as primary |
| 15 | Proper respondents — define screening criteria | Fix 13 | Add two bulleted inclusion criteria lists (parents and young professionals) |
| 16 | References to support why these respondents were chosen | Fix 14 | Expand age definition sentence with BSP 2021 + PSA 2021 citations for both groups |
| 26 | Experts must validate the system itself, not just questionnaire | Fix 15 | Update Table 2.1 label + expand Benjie G. Bucasas paragraph to include system validation |
| 27 | Data gathering tools and procedures — step by step | Fix 16 | Add new "Step-by-Step Data Gathering Procedure" sub-section (6 numbered steps) |

**Reference:** All fix text is in `docs/MANUSCRIPT_FIXES.md` (Fixes 11–16). Use CTRL+F in Google Docs to find the exact location for each fix.

---

### ❌ STILL PENDING — REQUIRES PHYSICAL ACTION (2 of 29)

| # | Recommendation | What Is Needed | Who |
|---|---|---|---|
| 1 | Figure 1.1 — actual bar chart image | The caption placeholder exists in the manuscript. The actual bar chart graphic (financial literacy rates by demographic group, from BSP 2021 and Inquiro 2024 data) must be created and inserted in Google Docs | Cyrille — create chart in Google Sheets or Canva, paste into Google Docs at Figure 1.1 |
| 25 | Validator signature | Appendix A validation certificates redesigned — credential-based format (degree, occupation, years of experience). Name field is **optional**. Physical signing still needed but name disclosure is not required. See Fix 19 in fix guide | Cyrille — have validators fill in credentials and sign |

---

### SUMMARY

| Status | Count |
|--------|-------|
| ✅ Fully addressed in manuscript | 21 |
| ⚠️ Fix written — needs Google Docs update | 7 |
| ❌ Requires physical action | 2 |
| **Total** | **29** |

---

## 12. DECLARATION

We, the members of Lucid Frame, hereby certify that the information in this progress report is accurate and reflects the current state of our Capstone Project 2. All group members have coordinated and verified the contents of this report.

| Name | Signature | Date |
|------|-----------|------|
| Brix A. Directo | | August 2026 |
| Cyrille John M. Rubis | | August 2026 |
| Djaunathan Albert S. Madayag | | August 2026 |

---

*SmartSpend v2.9.2 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT — Capstone Project 2, 2026–2027 (1st Semester)*
*Teacher-in-Charge: Janelli M. Mendez, DIT*
*Capstone Adviser: Johnny Verzola, MTS (reassignment pending)*
