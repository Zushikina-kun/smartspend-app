# CAPSTONE PROJECT 2 — WEEK 5 PROGRESS REPORT
## Debug Analysis, Bug Fixes & Automated Release Pipeline

---

| | |
|---|---|
| **Project Title** | SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management Application for Filipino Users Using Agentic Large Language Model Architecture |
| **Group Name** | Lucid Frame |
| **Course** | Bachelor of Science in Information Technology (BSIT) — 4th Year, 1st Semester |
| **Institution** | Lorma Colleges, College of Computer Studies and Engineering (CCSE) |
| **Academic Year** | 2026–2027, 1st Semester |
| **Date Submitted** | September 4, 2026 — Week 5 |
| **Teacher-in-Charge** | Shekiro R. Raposas |
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

**SmartSpend** is an AI-powered mobile personal finance tracker for Android built with Flutter, targeting Filipino users — students, young professionals, and parents — with conversational AI, voice/camera/screenshot input, and a Financial Health Score system.

**Current Version:** 2.9.9
**Platform:** Android (Flutter/Dart)
**Status:** ✅ Development active — Week 5 focused on real-device debug analysis, targeted bug fixes, and automated release pipeline setup

---

## 2. CURRENT SYSTEM STATUS

### 2.1 Application Build

| Item | Value |
|------|-------|
| Version | 2.9.9+9 |
| Build date | September 3–4, 2026 |
| APK size (arm64-v8a) | 44.8 MB |
| GitHub repository | https://github.com/Zushikina-kun/smartspend-app |
| Latest release | https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.9 |
| CI/CD | ✅ GitHub Actions workflow — auto-builds + releases on version tag push |

### 2.2 Key Features Status (v2.9.9)

| Module | Status | v2.9.9 Changes |
|--------|--------|----------------|
| AI Chat (31 agentic actions) | ✅ Complete | Language detection (English/Filipino/Taglish auto-match) |
| Analytics — Lightweight Mode | ✅ Fixed | 50/30/20, Tax, Allowance cards now hidden when income tracking OFF |
| FHS/FMS Logging Consistency | ✅ Fixed | activeDays uses full daysPassed baseline (honest scoring) |
| FMS "See breakdown" navigation | ✅ Fixed | Auto-scrolls to FMS section in Profile on tap |
| Score history chart | ✅ Improved | Placeholder when <2 data points; InfoButton explains why sparse |
| GitHub Actions release pipeline | ✅ New | Auto-builds APKs and creates release on version tag push |

---

## 3. PROOF OF PROGRESS

### 3.1 GitHub Repository Evidence

- **Commits this week (Sep 2–4):**

| Commit | Description | Date |
|--------|-------------|------|
| `51088a9` | fix: 5 debug-identified issues from user device data | Sep 3 |
| Latest | chore: v2.9.8→2.9.9, GitHub Actions release workflow, docs | Sep 4 |

### 3.2 Debug-Driven Development

This week's development was driven by **real device debug data** (Debug Log, JSON backup, CSV export from the test device — Poco X6 Pro, Android 16). The debug log revealed 5 specific bugs/UX issues, all of which were fixed and verified:

#### Bug 1 — Analytics showing income-based cards in Lightweight Mode

**Root cause:** `_build503020Card()`, Tax & Savings card, and Allowance Overview in `analytics_screen.dart` only gated on `_monthlyIncome > 0`, not on whether income tracking was enabled. The stale `monthly_income = 650` stored in DB caused all three cards to render even when `income_wallet_mode = false`.

**Fix:** Added `_incomeWalletMode` state field to `AnalyticsScreen`, loaded from `DBService.getIncomeWalletMode()` in `_loadData()`. All 3 income-dependent cards now gated on `_incomeWalletMode && _monthlyIncome > 0`.

#### Bug 2 — Logging Consistency giving 25/25 for 1 entry on Sep 2

**Root cause:** `activeDays` was computed as the span from the user's first logged entry this month (`span = now - firstEntry + 1`). On Sep 2 with 1 entry: `span = 1`, `activeDays = 1`, `ratio = 1/1 = 100%` → 25/25. This made the formula lie — 1 day of logging out of 2 days elapsed should be ~50%.

**Fix (applied to 3 places in `score_service.dart`):** New logic: if the first entry was on day 1–7 of the month, use `daysPassed` as the baseline (honest). If the user started logging after day 7, still use `span` from their first entry (fairness for mid-month starters). Retroactive cap (2× loggedDays) preserved.

#### Bug 3 — "See breakdown →" tap navigated to Profile top, not FMS section

**Root cause:** `widget.onNavigate(4)` just switches the tab. No scroll-to behavior existed on `ProfileScreen`. The FMS section is buried below the long score breakdown list.

**Fix:** Added `static bool ProfileScreen.scrollToFMS`, `ScrollController _scrollCtrl`, and `GlobalKey _fmsKey` (a zero-height `SizedBox` before the FMS `FutureBuilder`). Home screen FMS strip tap sets the flag before calling `onNavigate(4)`. Profile checks the flag in both `initState` and after `_loadStats` completes, then calls `Scrollable.ensureVisible`.

#### Bug 4 — AI responding in Taglish even when user writes in English

**Root cause:** No language detection rule in the system prompt. The AI defaulted to Taglish/mixed due to the "Filipino-English companion" framing.

**Fix:** Added Rule 12 to `ai_chat_service.dart` system prompt: "Detect the language the user is writing in and ALWAYS reply in that same language. English → English, Filipino → Filipino, Taglish → match their mix. Honor explicit 'speak English' / 'mag-Tagalog ka' requests for the rest of the conversation." Also updated the persona line to include this instruction at the top level.

#### Bug 5 — Score history chart showed 2 dots with no explanation

**Root cause:** Chart was hidden when `_scoreHistory.length < 2`, leaving users confused. Scores are only recorded on days the app is opened — a user who opened the app twice in 30 days gets 2 data points.

**Fix:** Added a placeholder `Container` shown when `_scoreHistory.length < 2` — explains why history is sparse and shows the current score number. Updated `InfoButton` to include the explanation. Existing chart still renders normally when ≥2 points.

### 3.3 Automated Release Pipeline

Created `.github/workflows/release.yml` — a GitHub Actions CI/CD workflow that:

1. Triggers on any version tag push (`v*.*.*`, e.g. `git tag v2.9.9 && git push origin v2.9.9`)
2. Sets up Java 17 + Flutter 3.41.6 on Ubuntu runner
3. Decodes secrets (keystore, key.properties, google-services.json, app_config.dart) from GitHub Secrets
4. Runs `flutter build apk --release --split-per-abi --shrink --obfuscate`
5. Renames APKs to versioned names (`SmartSpend-v2.9.9-arm64-v8a.apk`)
6. Creates a GitHub Release with all 3 APKs attached using `softprops/action-gh-release@v2`

**Required secrets to configure in GitHub Settings → Secrets and variables → Actions:**
- `KEYSTORE_BASE64` — base64-encoded `smartspend-release.jks`
- `KEY_PROPERTIES` — full content of `android/key.properties`
- `GOOGLE_SERVICES_JSON` — full content of `android/app/google-services.json`
- `APP_CONFIG_DART` — full content of `lib/services/app_config.dart` (contains API keys)

Once secrets are configured, every future version release becomes a single command:
```bash
git tag v2.9.10 && git push origin v2.9.10
```

### 3.4 Key Technical Metrics (v2.9.9)

| Metric | Value |
|--------|-------|
| Total screens | 37 screens |
| Total services | 26 services |
| AI agentic actions | 31 |
| LLM providers (auto-failover) | 5 |
| AI rules in system prompt | 12 (Rule 12 = language detection) |
| Achievement badges | 23 |
| SQLite schema | v11, 20 tables |
| APK size (arm64-v8a, release) | 44.8 MB |
| CI/CD | GitHub Actions — auto-release on tag |

---

## 4. REMAINING WORK BEFORE PRE-FINAL DEFENSE

| Task | Status | Owner |
|------|--------|-------|
| Configure GitHub Actions secrets (keystore, keys) | 🔜 Pending | Brix |
| Apply remaining Google Docs fixes (MANUSCRIPT_GUIDE Fixes 11–16) | 🔜 Pending | Cyrille |
| Create and insert Figure 1.1 bar chart (BSP data) | 🔜 Pending | Cyrille |
| Obtain validator signatures on Appendix A | 🔜 Pending | Cyrille |
| Rehearse 8–9 minute demo flow | 🔜 Pending | All |
| SUS survey instrument printed and ready | 🔜 Pending | Djaunathan |
| Pre-Final Defense presentation slides | 🔜 Pending | All |

---

## 5. REVISED PROJECT TIMELINE

| Week | Activity | Status |
|------|----------|--------|
| Week 1 (Aug 11) | Project reorientation | ✅ Done |
| Week 2 (Aug 18) | Chapter 3 finalization | ✅ Done |
| Week 3 (Aug 25) | Chapter 4 draft | ✅ Done |
| Week 4 (Sep 1) | AI coverage expansion, v2.9.8 release | ✅ Done |
| **Week 5 (Sep 3)** | **Debug fixes, CI/CD pipeline, v2.9.9** | **✅ Done this week** |
| Week 6 (Sep 8) | Pre-Final Defense prep + rehearsal | 🔜 Next |
| Week 7 (Sep 15) | Pre-Final Defense | 🔜 Upcoming |
| Week 8 (Sep 22) | Address panel feedback, SUS survey | 🔜 Upcoming |
| Week 9–11 | Manuscript completion (Ch. 5, abstract) | 🔜 Upcoming |
| Week 12–14 | Final Defense | 🔜 Upcoming |

---

## 6. WORK LOG — WEEK 5

| Member | Work Done | Hours (est.) |
|--------|-----------|-------------|
| Brix A. Directo | Real-device debug analysis (Debug Log + JSON backup + CSV); 5 targeted bug fixes; GitHub Actions CI/CD workflow; v2.9.9 build + release; docs sweep | 15–18 hrs |
| Cyrille John M. Rubis | Documentation review; manuscript formatting preparation; defense slide preparation | 6–8 hrs |
| Djaunathan Albert S. Madayag | QA testing on Poco X6 Pro; SUS survey preparation; progress report | 5–7 hrs |

---

## 7. ADVISER CONSULTATION NOTES

**Consultation date:** _______________
**Teacher-in-Charge:** Shekiro R. Raposas

**Topics to raise:**
- v2.9.9 — real-device debug-driven fixes demonstrating rigorous QA process
- GitHub Actions CI/CD pipeline (demonstrates production-readiness)
- Pre-Final Defense schedule (target: Week 7)
- SUS survey respondent recruitment status

**Issues raised:**
- _______________

**Recommendations:**
- _______________

**Action items:**
- _______________

---

## 8. DECLARATION

We, the members of Lucid Frame, hereby certify that the information in this progress report is accurate and reflects the current state of our Capstone Project 2.

| Name | Signature | Date |
|------|-----------|------|
| Brix A. Directo | | September 2026 |
| Cyrille John M. Rubis | | September 2026 |
| Djaunathan Albert S. Madayag | | September 2026 |

---

*SmartSpend v2.9.9 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT — Capstone Project 2, 2026–2027 (1st Semester)*
*Teacher-in-Charge: Shekiro R. Raposas*
