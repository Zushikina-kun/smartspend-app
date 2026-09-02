# CAPSTONE PROJECT 2 — WEEK 4 PROGRESS REPORT
## AI System Expansion, Documentation Audit & v2.9.8 Release

---

| | |
|---|---|
| **Project Title** | SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management Application for Filipino Users Using Agentic Large Language Model Architecture |
| **Group Name** | Lucid Frame |
| **Course** | Bachelor of Science in Information Technology (BSIT) — 4th Year, 1st Semester |
| **Institution** | Lorma Colleges, College of Computer Studies and Engineering (CCSE) |
| **Academic Year** | 2026–2027, 1st Semester |
| **Date Submitted** | September 3, 2026 — Week 4 |
| **Teacher-in-Charge** | Janelli M. Mendez, DIT |
| **Reference** | Capstone Project 2 Syllabus — 1st Sem AY2026-2027 |

---

## GROUP MEMBERS

| Name | Role |
|------|------|
| Brix A. Directo | Lead Developer |
| Cyrille John M. Rubis | UI/UX Designer & Documentation Lead |
| Djaunathan Albert S. Madayag | Project Manager & QA Lead |

---

## 1. PROJECT OVERVIEW

**SmartSpend** is an AI-powered mobile personal finance tracker for Android built with Flutter. It helps everyday Filipino users — students, young professionals, and parents — track spending, set budgets, manage debts and savings goals, and receive personalized financial advice through conversational AI in Filipino-English (Taglish).

**Current Version:** 2.9.8
**Platform:** Android (Flutter/Dart)
**Status:** ✅ Development active — Week 4 focused on AI coverage expansion, documentation audit, and release build

---

## 2. CURRENT SYSTEM STATUS

### 2.1 Application Build

| Item | Value |
|------|-------|
| Version | 2.9.8+8 |
| Build date | September 2, 2026 |
| APK size (arm64-v8a) | 44.8 MB (obfuscated, split, shrunk) |
| GitHub repository | https://github.com/Zushikina-kun/smartspend-app |
| Latest release | https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.8 |
| Flutter version | 3.41.6 • Dart 3.11.4 |

### 2.2 Development Status Summary

| Module | Status | Notes |
|--------|--------|-------|
| Expense tracking (6 input methods) | ✅ Complete | Voice, OCR, Barcode, Screenshot Batch, Manual, AI Chat |
| AI Chat (31 agentic actions) | ✅ Complete | +2 new actions this week: set_spending_limit, add_insurance_policy |
| Financial Health Score (FHS) | ✅ Complete | Dual-mode + Unmeasured label when income not set |
| Financial Management Score (FMS) | ✅ Complete | Now visible on Home + Analytics screens |
| Budget management | ✅ Complete | Category budgets + multi-period limits (AI-settable) |
| Spending limit management | ✅ Complete | AI can now set daily/weekly/monthly/yearly limits directly |
| Insurance & contributions tracker | ✅ Complete | AI can now add SSS/PhilHealth/Pag-IBIG entries directly |
| Auto-categorization rules | ✅ Complete | AI can now see and describe user rules in context |
| Recurring transactions | ✅ Complete | Auto-add from pattern card (one tap, no navigation) |
| AI Taglish coverage | ✅ Complete | All 31 actions have Filipino trigger examples in system prompt |
| Multi-item AI logging | ✅ Improved | Broader typo detection, smarter token scaling, better model routing |
| Documentation (all docs) | ✅ Updated | 30+ audit issues resolved; all docs at v2.9.8 |

---

## 3. PROOF OF PROGRESS

### 3.1 GitHub Repository Evidence

- **Total commits this week:** 14 commits (August 27 – September 2, 2026)
- **Latest commit:** `0014e57` — "fix: remove duplicate old feature entries from whats_new_screen.dart"
- **Public repository:** https://github.com/Zushikina-kun/smartspend-app
- **Latest release:** v2.9.8 (September 2, 2026)

**Commits this week (chronological):**

| Commit | Description | Date |
|--------|-------------|------|
| `ecddd56` | fix: SMARTSPEND_FINAL_V5.docx — correct spacing to match templates | Aug 27 |
| `11c4afa` | docs: comprehensive audit fixes — 30+ issues resolved (CRIT/IMP/MIN) | Aug 28 |
| `90d2b4f` | fix: app bugs + doc corrections (5 fixes) | Aug 28 |
| `aa13f3d` | feat: FMS on Home+Analytics, FHS unmeasured label (research-backed) | Aug 29 |
| `e90338d` | feat: AI coverage — 6 gaps closed (Taglish, routing, 2 new actions, fallback, rules) | Aug 29 |
| `b563ee0` | docs: update action count 29→31 across all docs + action lists | Aug 30 |
| `f23c0e6` | chore: bump version 2.9.7+7 → 2.9.8+8 | Sep 2 |
| `1919f76` | fix: restore broken fullContext string + add scan_review_screen import to ai_screen | Sep 2 |
| `0014e57` | fix: remove duplicate old feature entries from whats_new_screen.dart | Sep 2 |

### 3.2 System Prototype

**Download:** https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.8

| APK File | Size | Target Device |
|----------|------|---------------|
| SmartSpend-v2.9.8-arm64-v8a.apk | 44.8 MB | Modern phones (2018+) — primary |
| SmartSpend-v2.9.8-armeabi-v7a.apk | 37.1 MB | Older/32-bit phones |
| SmartSpend-v2.9.8-x86_64.apk | 47.8 MB | Emulators |

**Primary test device:** Poco X6 Pro (Android 16, HyperOS 2) — all features verified working on v2.9.8.

### 3.3 Key Work Done This Week

#### A — Comprehensive Documentation Audit (30+ Issues Resolved)

A full audit of all project documentation was conducted and all identified issues were fixed and committed:

**CRITICAL fixes:**
- `HOWTORUN.md` — corrected screen count (31→37) and service count (23→26) to match actual codebase
- `CAPSTONE_REFERENCE.md` — updated stale model names (GPT-4o → GPT-5.6, Claude 3.5 → Claude Fable 5); added "down from 56% in 2021" context to the BSP 50% stat; added Plaid 2026 market projection ($3.7B by 2033)
- `MANUSCRIPT_GUIDE.md` — corrected input modality count (7→6) with clarification that manual form is separate

**IMPORTANT fixes:**
- `RESEARCH_BASIS.md` — added Part 14 (Financial Management Score with full academic basis); added Mindfulsuite (2026) APA entry; added Perrig et al. (2024) citation for subscription auto-detection; all Gemini 2.5 Flash references updated to Gemini 3.5 Flash (7 occurrences in BENCHMARK.md)
- `CAPSTONE_REFERENCE.md` — added Wajid et al. (2025) gamification citation, Springer (2025/2026) nudge citations; fixed version history badge count (v2.7→v2.8)
- `DEFENSE_GUIDE.md` — added 6 new Q&A entries for likely panel questions; removed duplicate NARRATE line; removed developer comment from RECORDING ORDER
- `BENCHMARK.md` — added Wingman Money (Australia, 2026) with FHS comparison; added FrontierFinance (Arcila et al., 2026, arXiv:2608.11683) to benchmark section; corrected part numbering (was 1→2→3→6→4→5, now 1→2→3→4→5→6)
- `FEATURE_DOCS.md` — added sections 6a (Financial Management Score) and 6b (Weekly Category Card) with full formula tables and research basis
- FMS formula corrected across all docs: was documented as 3×33.3 pts, actually 4×25 pts — fixed to match `score_service.dart`
- Screen count 36→37 updated in all files (5 docs)

**MINOR fixes:**
- `SMARTSPEND_REVISED_MANUSCRIPT.md` — GPT-4 citation updated with GPT-5.6 context note
- Rebuilt `SMARTSPEND_FINAL_V5.docx` (17 sections, 5005KB, 63 refs, 7 images)
- Deleted obsolete files: `patch_script.py`, `update_working_docx.py`, `SMARTSPEND_UPDATED_MANUSCRIPT.docx`

#### B — Research-Backed App Improvements

Based on research recommendations in the audit (Khazneh 2026, AccountaPal, Elenvo AI 2026):

1. **FMS on Home screen** — compact strip between FHS/Budget cards and Spending Personality. Shows score/100, label chip, "See breakdown →" link. Taps to Profile. Basis: Khazneh (2026), AccountaPal — management score should be co-located with health outcome score.

2. **FMS on Analytics screen** — full mini-card with progress bar and 2-column component grid, placed after the FHS breakdown section. Uses `FutureBuilder` with same data pattern as Profile.

3. **FHS "Unmeasured" label** — when income is ₱0, the Savings Rate component now shows:
   - Grey italic text: "Unmeasured — set your income for accurate savings tracking"
   - `?/25` grey chip instead of a colored score
   - Dashed grey bar instead of a red `LinearProgressIndicator`
   Implemented in `score_service.dart` (added `'unmeasured': true` to breakdown map), `analytics_screen.dart`, and `profile_screen.dart`. Basis: Elenvo AI (2026) — missing data should be explicitly flagged, not silently penalized.

4. **`ScanReviewScreen` duplicate** — removed 295-line embedded class from `smart_camera_screen.dart`, replaced with import of `scan_review_screen.dart`. All 3 internal usages and the `ai_screen.dart` import chain resolve to a single definition.

#### C — AI Coverage Expansion (6 Gaps Closed)

A thorough AI/LLM coverage audit identified the following gaps and all were fixed:

| Gap | Fix Applied |
|-----|-------------|
| Budget queries routed to fast 8B model | `_detectTaskType` smart tier regex expanded: added `budget`, `limit`, `insurance`, `recurring`, `saving`, `ipon`, `utang`, `layunin`, `sweldo`, `kita`, `buwanang` |
| No Taglish examples for 28 of 29 actions | Rule 11 added to system prompt: explicit Filipino trigger phrases for set_budget, set_income, add_goal, add_debt, update_debt, add_recurring, set_spending_limit, add_insurance_policy |
| AI cannot set spending limits | New `set_spending_limit` action: executor calls `DBService.setLimitForPeriod(period, amount)`, supports daily/weekly/monthly/yearly, 0 = clear limit |
| AI cannot add insurance/contributions | New `add_insurance_policy` action: executor calls `DBService.insertInsurancePolicy`, computes `next_due_date` from frequency (monthly/quarterly/yearly) |
| `set_budget` silently dropped when JSON fails | Fallback parser added: catches "Budget set: Food ₱3,000" and "<category> budget to ₱3000" confirmation patterns |
| AI unaware of auto-categorization rules | `setFullContext` gains `categoryRules` parameter; rules injected as "Auto-rules: keyword→Category" in context string; `_loadContext` fetches and passes rules |

All changes validated with `dart analyze` — zero errors before building.

#### D — Version 2.9.8 Release

- `pubspec.yaml` bumped to `2.9.8+8`
- `whats_new_screen.dart` updated with 9 new feature cards (v2.9.8 changes)
- `backup_service.dart` app_version updated to `2.9.8`
- All docs updated: `2.9.7` → `2.9.8` across 13 files
- Version history rows added to `CAPSTONE_REFERENCE.md` (v2.9.7 and v2.9.8 entries)
- Release build successful: Flutter 3.41.6, all 3 ABI variants clean
- GitHub Release v2.9.8 published with 3 APKs attached

### 3.4 Key Technical Metrics (v2.9.8)

| Metric | Value |
|--------|-------|
| Total screens | 37 screens |
| Total services | 26 services |
| AI agentic action types | **31** (up from 29 last week) |
| LLM providers (auto-failover) | 5 providers |
| Expense categories | 14 built-in + unlimited custom |
| Achievement badges | 23 badges |
| Daily quests | 10 rotating |
| Screenshot platforms detected | 40+ types |
| PH banks in database | 20 banks + 5 e-wallets |
| SQLite schema | v11, 20 tables |
| Backup format | JSON v9 |
| Firebase services | Auth, Firestore, Crashlytics, App Check, Remote Config |
| APK size (arm64-v8a, release) | 44.8 MB |

---

## 4. FINANCIAL HEALTH SCORE — SYSTEM SPECIFICATION

### Full Mode (income tracking ON)
| Component | Measurement | Max Points |
|-----------|------------|------------|
| Savings Rate | Actual savings vs 20% income target. Shows "Unmeasured" when income not set. | 25 |
| Overspend Control | Days where daily spending stayed within (income ÷ days in month) | 25 |
| Budget Adherence | % of category budgets on track | 25 |
| Logging Consistency | Logged days / active days (current month only) | 25 |

### Lightweight Mode (income tracking OFF)
| Component | Measurement | Max Points |
|-----------|------------|------------|
| Spending Restraint | vs user-set spending limit (or Want/Need ratio if no limit) | 25 |
| Logging Consistency | Same formula as full mode | 25 |
| Category Balance | No single category > 40% of total spend | 25 |
| Habit Streak | Consecutive days logged (target: 14 days) | 25 |

**Score adjustments:** Warning Decay (−5/day, max −15) + Gap Adjustment (−3 or +2/day based on user confirmation)

### Financial Management Score (FMS) — Companion Metric
| Component | Measurement | Max Points |
|-----------|------------|------------|
| Logging Consistency | loggedDays / activeDays this month | 25 |
| Budget Setup | Number of category budgets configured (full at 5+) | 25 |
| Goal Tracking | Active savings goals with contribution progress | 25 |
| Data Completeness | Income set + wallet data entered (income mode) | 25 |

**Research basis:** Financial Health Network (2026), Elenvo AI (2026), MindsBudget methodology — financial health outcomes (FHS) and financial management behavior (FMS) should be measured separately.

---

## 5. AI ARCHITECTURE — 31 AGENTIC ACTIONS

### Action Types (v2.9.8)

| Category | Actions |
|----------|---------|
| Expenses | log_expense, update_expense, delete_expense, delete_by_date |
| Income & Wallets | set_income, add_income, set_wallet_balance, transfer_wallet |
| Budgets | set_budget |
| Goals | add_goal, update_goal, delete_goal |
| Debts | add_debt, update_debt |
| Recurring | add_recurring, delete_recurring |
| Payment Plans | add_installment_plan |
| Analysis & Advisory | plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, generate_monthly_plan, compare_periods, explain_fhs_breakdown, project_savings_timeline, detect_subscriptions, compute_contribution, suggest_idle_money, suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense |
| **Settings & Limits** *(new)* | **set_spending_limit** |
| **Insurance & Contributions** *(new)* | **add_insurance_policy** |
| Account | set_account_type |

### Multi-Provider Failover Chain

| Priority | Provider | Model | Free Limit | Role |
|----------|----------|-------|------------|------|
| 1 (Primary) | Google | Gemini 3.1 Flash-Lite | 1,000 req/day | Best Filipino-English, 1M context |
| 2 | Google | Gemini 3.5 Flash | 250 req/day | Higher reasoning quality |
| 3 | Groq LPU | LLaMA 3.3 70B | 14,400 req/day | Best open-source reasoning |
| 4 | Groq LPU | LLaMA 3.1 8B | 14,400 req/day | Fastest simple queries |
| 5 | Cerebras WSE | LLaMA 3.1 70B | 1M tokens/day | Highest raw throughput fallback |

---

## 6. DOCUMENTATION STATUS

| Document | Location | Status |
|----------|----------|--------|
| README | /README.md | ✅ v2.9.8 |
| How to Run & Build | /HOWTORUN.md | ✅ v2.9.8 |
| Application Documentation | /docs/FEATURE_DOCS.md | ✅ v2.9.8 |
| Capstone 2 Reference | /docs/CAPSTONE_REFERENCE.md | ✅ v2.9.8 |
| Defense Guide | /docs/DEFENSE_GUIDE.md | ✅ v2.9.8 — 6 new Q&As added |
| Benchmark (14 apps, 13 LLMs) | /docs/BENCHMARK.md | ✅ v2.9.8 — Wingman Money + FrontierFinance added |
| Research Basis | /docs/RESEARCH_BASIS.md | ✅ v2.9.8 — Part 14 (FMS) added |
| System Overview | /docs/SYSTEM_OVERVIEW.md | ✅ v2.9.8 |
| Manuscript Guide | /docs/MANUSCRIPT_GUIDE.md | ✅ v2.9.8 |
| Application Pipeline | /docs/APPLICATION_PIPELINE.md | ✅ v2.9.8 |
| Project Status | /docs/PROJECT_STATUS.md | ✅ v2.9.8 |
| Revised Manuscript (Chapters 1–4) | /docs/manuscript/SMARTSPEND_REVISED_MANUSCRIPT.md | ✅ v2.9.8 |
| Final Manuscript DOCX | /docs/manuscript/SMARTSPEND_FINAL_V5.docx | ✅ Rebuilt — 17 sections, 63 refs, 7 images |

---

## 7. REVISED PROJECT PLAN — REMAINING WORK

| Week | Activity | Our Tasks | Status |
|------|----------|-----------|--------|
| Week 1 (Aug 11) | Project Reorientation | Progress report, adviser consultation | ✅ Done |
| Week 2 (Aug 18) | Chapter 3 discussion | Finalize Chapter 3 — LLM justification, architecture, FHS formula | ✅ Done — in SMARTSPEND_REVISED_MANUSCRIPT.md |
| Week 3 (Aug 25) | Chapter 4 development | Write Chapter 4 — screenshots, FHS, feature walkthrough | ✅ Done — draft complete |
| **Week 4 (Sep 1)** | **Final software check** | **AI coverage expansion, documentation audit, v2.9.8 release** | **✅ Done this week** |
| Week 5 (Sep 8) | Pre-Final Defense prep | Finalize presentation, rehearse demo flow | 🔜 Next |
| Week 6 (Sep 15) | Pre-Final Defense | Present to panel | 🔜 Upcoming |
| Week 7 (Sep 22) | Testing & debugging | Address panel feedback, SUS survey | 🔜 Upcoming |
| Week 8–10 | Documentation | Complete manuscript Chapters 1–5 | 🔜 Upcoming |
| Week 11–13 | Final Defense | Present completed system + paper | 🔜 Upcoming |
| Week 15–17 | Revisions & submission | Final manuscript revisions | 🔜 Upcoming |

### Pending tasks before Pre-Final Defense (Week 5):
- [ ] Apply remaining manuscript Google Docs fixes (Fixes 11–16 from MANUSCRIPT_GUIDE.md)
- [ ] Create and insert Figure 1.1 bar chart (BSP financial literacy data)
- [ ] Obtain validator signatures on Appendix A certificates
- [ ] Rehearse 8–9 minute demo flow per DEFENSE_GUIDE.md Part 2
- [ ] SUS survey instrument finalized and printed

---

## 8. TESTING RESULTS (v2.9.8)

### 8.1 Build Testing
- ✅ Debug build — passes on Poco X6 Pro (Android 16)
- ✅ Release build — all 3 ABI variants clean (arm64-v8a: 44.8MB, armeabi-v7a: 37.1MB, x86_64: 47.8MB)
- ✅ Obfuscation + shrinking — no crashes from class name mangling
- ✅ Firebase services — Auth, Firestore, Crashlytics all operational
- ✅ `dart analyze` — zero errors on all modified files before build

### 8.2 New Features Tested (manual, on primary device)
- ✅ Set spending limit via AI — "set daily limit to 200 pesos" writes to DB, limit card updates on home screen
- ✅ Add insurance via AI — "SSS ko 560 monthly" creates entry in Insurance Tracker with correct next_due_date
- ✅ Taglish budget — "budget ko sa pagkain 3000" triggers set_budget with correct category
- ✅ FMS strip on Home screen — visible between FHS/Budget row and Spending Personality card
- ✅ FMS mini-card on Analytics — appears after FHS breakdown section with 2-column component grid
- ✅ Unmeasured label — with no income set, Savings Rate shows grey `?/25` chip and dashed bar
- ✅ Recurring auto-add — "Add Recurring" on pattern card saves directly with green snackbar + View action

### 8.3 Known Issues / Limitations
- Voice input quality depends on microphone and ambient noise
- OCR accuracy drops on low-quality or crumpled receipts
- AI responses limited to 60/day per provider (rate limit protection)
- App Check in debug/monitoring mode — needs Play Integrity for Play Store submission

### 8.4 SUS Evaluation
- **Status:** Pending — to be conducted in Week 7 after Pre-Final Defense
- **Target score:** ≥ 80 (Good classification per Bangor et al., 2009)
- **Respondents:** 30+ target users (parents 35–55 and young professionals 21–35 in La Union)
- **Validators:** Subject matter expert in financial management (survey content) + IT expert (system validation) — credentials documented in Appendix A, names optional per ethical research standards

---

## 9. WORK LOG — WEEK 4

| Member | Work Done | Hours (est.) |
|--------|-----------|-------------|
| Brix A. Directo | AI coverage audit + 6 gap fixes (new actions, Taglish prompt, routing, fallback parser, rules context); research-backed app improvements (FMS surfacing, FHS unmeasured); bug fixes (ScanReviewScreen duplicate, fullContext string corruption from version bump); release build + GitHub Release v2.9.8 | 20–25 hrs |
| Cyrille John M. Rubis | Documentation audit review; manuscript formatting preparation; Google Docs fixes coordination | 8–10 hrs |
| Djaunathan Albert S. Madayag | Testing coordination; QA verification of v2.9.8 on test device; progress report preparation | 6–8 hrs |

---

## 10. ADVISER CONSULTATION NOTES

**Consultation date:** _______________
**Teacher-in-Charge:** Janelli M. Mendez, DIT
**Topics to raise:**
- v2.9.8 release — 31 agentic actions, Taglish AI coverage, FMS on Home/Analytics
- Pre-Final Defense scheduling (Week 6 target)
- SUS survey instrument approval
- Manuscript draft status — Chapters 1–4 complete; Chapter 5 pending

**Issues raised:**
- _______________

**Recommendations:**
- _______________

**Action items:**
- _______________

---

## 11. DECLARATION

We, the members of Lucid Frame, hereby certify that the information in this progress report is accurate and reflects the current state of our Capstone Project 2.

| Name | Signature | Date |
|------|-----------|------|
| Brix A. Directo | | September 2026 |
| Cyrille John M. Rubis | | September 2026 |
| Djaunathan Albert S. Madayag | | September 2026 |

---

*SmartSpend v2.9.8 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT — Capstone Project 2, 2026–2027 (1st Semester)*
*Teacher-in-Charge: Janelli M. Mendez, DIT*
