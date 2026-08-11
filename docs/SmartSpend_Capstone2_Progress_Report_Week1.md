# CAPSTONE PROJECT 2 — WEEK 1 PROGRESS REPORT
## Project Reorientation & Consultation

---

| | |
|---|---|
| **Project Title** | SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management Application for Filipino Users Using Agentic Large Language Model Architecture |
| **Group Name** | Lucid Frame |
| **Course** | Bachelor of Science in Information Technology (BSIT) |
| **Institution** | Lorma Colleges, College of Computer Studies and Engineering (CCSE) |
| **Academic Year** | 2025–2026 |
| **Date Submitted** | August 2026 — Week 1 |
| **Teacher-in-Charge** | Janelli M. Mendez, DIT |

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

**Current Version:** 2.9.1 (Final Build)
**Platform:** Android (Flutter/Dart)
**Status:** ✅ Development complete — entering documentation and defense phase

---

## 2. CURRENT SYSTEM STATUS

### 2.1 Application Build
- **Version:** 2.9.1 (Final Release)
- **Build date:** August 2, 2026
- **APK size:** 44.7 MB (arm64-v8a release, split, obfuscated)
- **GitHub repository:** https://github.com/Zushikina-kun/smartspend-app
- **GitHub release:** https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.1
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
- **Total commits:** 100+ commits over the development period
- **Latest commit:** `37e37ed` — "docs: final v2.9.1 sweep"
- **Public repository:** https://github.com/Zushikina-kun/smartspend-app
- **Branch:** master (production-ready)

**Recent significant commits:**
| Commit | Description | Date |
|--------|-------------|------|
| `b9c38de` | Manuscript fix guide for Google Docs corrections | Aug 2, 2026 |
| `37e37ed` | Final v2.9.1 docs sweep — app lock, model names | Aug 2, 2026 |
| `679fb45` | LICENSE added (Non-Commercial, Lucid Frame) | Aug 2, 2026 |
| `214f69a` | App lock simplified (cold-start only, like GCash/Maya) | Aug 2, 2026 |
| `95ae049` | AI model selector, anomaly toggle, Filipino terms, goal/debt date edit | Aug 1, 2026 |
| `890330a` | Capstone 2 documentation reference file | Aug 1, 2026 |
| `0eef294` | Security: google-services.json removed from tracking | Aug 1, 2026 |
| `f86b2fd` | FHS accuracy: logging consistency current-month only | Jul 28, 2026 |
| `c810ca5` | Unified Smart Import (4-mode camera) | Jul 28, 2026 |
| `eeea0b6` | Historical entry date guards (no false alerts) | Jul 28, 2026 |

### 3.2 System Prototype
The system is fully functional and deployed as a release APK.

**Download link:** https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.1

| APK File | Size | Target Device |
|----------|------|---------------|
| SmartSpend-v2.9.1-arm64-v8a.apk | 44.7 MB | Modern phones (2018+) |
| SmartSpend-v2.9.1-armeabi-v7a.apk | 37.0 MB | Older/32-bit phones |
| SmartSpend-v2.9.1-x86_64.apk | 47.6 MB | Emulators |

**Primary test device:** Poco X6 Pro (Android 16, HyperOS 2) — all features verified working.

### 3.3 Documentation Produced

| Document | Location | Status |
|----------|----------|--------|
| Application Documentation (DOCUMENTATION.md) | /DOCUMENTATION.md | ✅ Complete — v2.9.1 |
| Capstone 2 Documentation Reference | /docs/SmartSpend_Capstone2_Documentation_Reference.md | ✅ Complete |
| Competitor Analysis & Feature Ideas | /docs/Competitor_Analysis_and_Feature_Ideas.md | ✅ Updated v2.9.1 |
| Capstone 2 TODO & Feature Analysis | /docs/SmartSpend_Capstone2_Feature_Analysis.md | ✅ Updated v2.9.1 |
| LLM Comparison Table (Chapter 3) | /docs/LLM_Comparison_Table_Ch3.md | ✅ Updated v2.9.1 |
| Paper Guide (Chapters 1–5) | /docs/SmartSpend_Capstone_Paper_Guide.md | ✅ Updated v2.9.1 |
| Demo Script | /docs/SmartSpend_Demo_Script.md | ✅ Updated v2.9.1 |
| Master Roadmap | /docs/SMARTSPEND_MASTER_ROADMAP.md | ✅ Updated v2.9.1 |
| How to Run & Build | /HOWTORUN.md | ✅ Complete |
| README | /README.md | ✅ Complete |
| Security Policy | /SECURITY.md | ✅ Complete |
| LICENSE | /LICENSE | ✅ Complete |

### 3.4 Key Technical Metrics

| Metric | Value |
|--------|-------|
| Total screens | 31 screens |
| Total services | 23 services |
| AI agentic actions | 29 actions |
| LLM providers (auto-failover) | 5 providers |
| Expense categories | 14 built-in + unlimited custom |
| Achievement badges | 23 badges |
| Daily quests | 10 rotating |
| Screenshot platforms detected | 40+ types |
| PH banks in database | 20 banks + 5 e-wallets |
| SQLite schema version | v11 (18 tables) |
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
- **Validator:** Susan C. Arquisal (survey design), Benjie G. Bucasas (SUS process)

---

## 9. MEETING RECORDS SUMMARY

| Date | Type | Participants | Topics Discussed |
|------|------|-------------|-----------------|
| June 2026 | Development session | Lucid Frame | Capstone 1 → 2 transition, feature prioritization |
| July 2026 | Development session | Lucid Frame | AI architecture, multi-model routing, FHS formula |
| July 28, 2026 | Development session | Lucid Frame | Debug session, gap detection, AI guardrails |
| August 1, 2026 | Development session | Lucid Frame | App lock fix, docs sweep, GitHub release |
| August 2, 2026 | Reorientation | Lucid Frame | Week 1 progress report, Capstone 2 timeline |

---

## 10. ADVISER CONSULTATION NOTES

*(To be filled in during/after Week 1 consultation with Janelli M. Mendez, DIT)*

**Consultation date:** _______________
**Adviser:** Janelli M. Mendez, DIT
**Issues raised:**
- _______________
**Recommendations:**
- _______________
**Action items:**
- _______________

---

## 11. DECLARATION

We, the members of Lucid Frame, hereby certify that the information in this progress report is accurate and reflects the current state of our Capstone Project 2. All group members have coordinated and verified the contents of this report.

| Name | Signature | Date |
|------|-----------|------|
| Brix A. Directo | | August 2026 |
| Cyrille John M. Rubis | | August 2026 |
| Djaunathan Albert S. Madayag | | August 2026 |

---

*SmartSpend v2.9.1 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT — Capstone Project 2, 2025–2026*
*Adviser: Janelli M. Mendez, DIT*
