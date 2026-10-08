# SmartSpend — Project Status
**Version:** 3.0.2 | **Academic Year:** 2026–2027, 1st Semester
**Last Updated:** October 9, 2026
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag

> For full technical documentation see `docs/reference/CAPSTONE_REFERENCE.md`
> For feature backlog and planning see `docs/guides/FEATURE_BACKLOG.md`
> For the latest AI handoff see `docs/handsoff/kiro-to-kiro-handoff-v3.0.0-2026-10-09.md`

---

## AUTHORITATIVE BUILD NUMBERS (v3.0.0)

| Metric | Value |
|--------|-------|
| Version string | **3.0.2** |
| pubspec | `3.0.2+100` |
| GitHub Release | https://github.com/Zushikina-kun/smartspend-app/releases/tag/v3.0.2 |
| APK (arm64) | **~45 MB** — `SmartSpend-v3.0.2-arm64-v8a.apk` |
| AAB (Play Store) | **~75 MB** — `SmartSpend-v3.0.2.aab` |
| Platform | Android (Flutter/Dart) |
| Min SDK | API 21 (Android 5.0) |
| Target SDK | API 36 (Android 16) |
| SQLite schema | **v14, 26 tables** |
| AI providers | **9** (8 cloud + 1 custom local) |
| Primary AI model | Gemini 3.5 Flash-Lite (AQ. key via Firebase Remote Config) |
| Agentic actions | **34** |
| Input modalities | **7** |
| Screens | **43** Dart files |
| Services | **31** Dart files |
| Achievement badges | **25** |
| Daily AI message limit | **150** |
| Color themes | **11** |
| Daily quests pool | 10 |
| Batch screenshot platforms | 40+ |
| Filipino item catalog | 150+ items |
| PH banks in DB | 20 banks + 5 e-wallets |
| Log choice sheet options | 7 |
| Currencies | 57 |
| Hub tiles | 30+ |
| Optional home toggles | 14 |
| Optional analytics toggles | 4 |

---

## FINAL DEFENSE — CHECKLIST

### 🔴 Critical — Must be done before defense day

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Install **v3.0.2** on demo phone | Brix | ❌ | Download `SmartSpend-v3.0.2-arm64-v8a.apk` from GitHub Releases |
| Verify About screen shows **"Version 3.0.2"** | Brix | ❌ | kAppVersion in debug_service.dart |
| Reset AI daily limit before demo | Brix | ❌ | AI screen → ⋮ → Reset Daily Limit |
| Set AI model to **Auto** before demo | Brix | ❌ | Settings → AI MODEL → Auto (Recommended) |
| Turn on **Normal or Pro** preset | Brix | ❌ | Settings → Quick Presets — shows all features |
| Charge demo phone to 100%, do NOT re-open until demo | Brix | ❌ | Cold start required |
| Have WiFi ready | Brix | ❌ | AI needs internet; Gemini key fetched from Remote Config on first open |
| Rehearse demo flow (see script below) | All | ❌ | 10-min run-through the day before |
| Create **Figure 1.1** — PH financial literacy bar chart | Cyrille | ❌ | BSP CFIS 2025: 50% adults with formal accounts; 74% literacy rate |
| Create **Figure 1.2** — IPO conceptual framework diagram | Cyrille | ❌ | Input → Process → Output |
| Create **Figure 2.1** — SUS score interpretation chart | Cyrille | ❌ | Bangor et al. (2009) adjective scale; target ≥80 = Good |
| Create **Figure 2.2** — Kanban board / development methodology | Cyrille | ❌ | Agile Kanban: Backlog → In Progress → Done |
| Fill in **Compliance Matrix** | All | ❌ | `docs/capstone/SmartSpend_Master_Bug_Tracker.docx` |

### 🟠 Manuscript Updates (for Cyrille)

Use `docs/reference/CAPSTONE_REFERENCE.md` and the v3.0.0 handoff as the single source of truth.

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Update version throughout manuscript → **3.0.0** | Cyrille | ❌ | |
| Update SQLite schema → **v14, 26 tables** | Cyrille | ❌ | v14 adds chat_sessions + session_id on chat_history |
| Update AI section: 9 providers, Gemini 3.5 Flash-Lite primary, AQ. key format, Remote Config, Local AI private mode | Cyrille | ❌ | |
| Update FHS equations: 4 × 25pt components, soft/hard overspend | Cyrille | ❌ | |
| Update agentic action count → **34** | Cyrille | ❌ | |
| Update badge count → **25** | Cyrille | ❌ | |
| Update daily AI limit → **150** | Cyrille | ❌ | |
| Update color theme count → **11** | Cyrille | ❌ | |
| Update screens count → **43** | Cyrille | ❌ | |
| Update APK size → **~45 MB** (arm64, split, obfuscated) | Cyrille | ❌ | |
| Add to Implemented: Transaction sort/group, Chat sessions, AI recovery card, Analytics quick-jump (v3.0.0) | Cyrille | ❌ | Shipped Oct 9 |
| Add to Implemented: Peso mascot, Safe-to-Spend, Full audit trail, History viewers, Data Quality, Local AI private mode (v2.9.76–v2.9.92) | Cyrille | ❌ | |
| Add AI financial advice disclaimer (RA 11765) to Ch.2/Ch.3 | Cyrille | ❌ | One-time dialog before first advice response |
| Add Safe-to-Spend to features list | Cyrille | ❌ | BudgetPH differentiator |
| Add **Agila, PISO, BunnyWise, MayBudget** to competitor table | Cyrille | ❌ | See FEATURE_BACKLOG Part 10 + Part 3 |
| BSP citation update Ch.1: 2021 → CFIS 2025 | Cyrille | ❌ | |
| Move **Paluwagan** to Implemented | Cyrille | ✅ | Done |

### 🟡 Post-Defense (before final submission)

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| SUS survey — 30 respondents | Djaunathan | ❌ | 20 parents + 10 young professionals |
| Google Play Console account ($25) | Brix | ❌ | Required for Play Store submission |
| AAB ready for Play Store | Brix | ✅ | `SmartSpend-v3.0.0.aab` on GitHub Releases |
| Privacy Policy hosted page | Cyrille | ✅ | https://zushikina-kun.github.io/smartspend-app/privacy.html |
| Firebase App Check enforcement | Brix | ❌ | Switch debug provider → Play Integrity before Play Store |
| Validator signatures — Appendix A | Brix | ❌ | |
| SUS survey results → manuscript Ch.3 | Cyrille | ❌ | |
| CV section — all three researchers | All | ❌ | |

---

## DEMO SCRIPT — Final Defense (v3.0.0)

### Night before
1. Download `SmartSpend-v3.0.2-arm64-v8a.apk` from https://github.com/Zushikina-kun/smartspend-app/releases/tag/v3.0.2
2. Install on demo phone (allow sideloading in Settings → Install unknown apps)
3. Open app — let it fully load to home screen (Remote Config fetches Gemini key on first open)
4. Verify About screen shows **"Version 3.0.0"**
5. Settings → Quick Presets → **Normal** or **Pro** (Lite Mode must be OFF)
6. Settings → AI MODEL → **Auto (Recommended)**
7. AI screen → ⋮ → **Reset Daily Limit**
8. Charge to 100%, do NOT open again until demo

### Demo flow (~10 minutes)

**1. Opening (1 min)**
- Cold-start the app → show Home screen with live data
- Point to: FHS score, this month's spending, Safe-to-Spend card, AI Insights

**2. Core feature — AI logging (2 min)**
- AI chat → type: `"I spent 60 for lunch and 30 for jeep"`
- Show 2 expenses logged in one message; appear in Recent list
- Show the session summary card (✅ 2 recorded) — new in v3.0.0
- Explain: 34 agentic actions, real writes to the local DB

**3. Safe-to-Spend (1 min)**
- Home → 💚 Safe to Spend card
- Explain: wallet balance minus upcoming bills/goals/debts before next payday — the one number that matters
- BudgetPH differentiator

**4. Import (2 min)**
- Log Expense → Batch Screenshots → show 40+ platform support
- Import a Shopee/GCash screenshot → AI parses the items
- Explain: OCR + AI, works offline for manual entry

**5. Financial Health Score (1 min)**
- Tap FHS score card → show breakdown dialog
- Explain 4 components — more meaningful than a simple budget tracker

**6. Analytics (1 min)**
- Analytics tab → Quick Jump chips (new v3.0.0) → pie chart, 50/30/20, DTI
- Category breakdown sort toggle → show sorting by amount / name / delta
- Point out: computed locally, no internet needed

**7. Transactions (1 min)**
- Transactions tab → tap ⇅ Sort/Group button (new v3.0.0)
- Group by category → show collapsible group headers with subtotals
- Show category dropdown (replaces old chip overflow)

**8. Competitive positioning (1 min)**
- Only free Filipino-English AI finance app with 34 agentic actions
- Only app with batch screenshot import (40+ platforms)
- Dual-mode FHS (full + lightweight), Safe-to-Spend, 9-provider AI fallback chain

---

## RECENT RELEASE HISTORY

| Version | Date | Key changes |
|---------|------|------------|
| **v3.0.2** | Oct 9, 2026 | Support links (Buy Me a Coffee, Ko-fi, PayPal, GCash) in About screen + website + README; `ProService` infrastructure for v4.0 freemium (everyone Pro in v3.x); `APP_FLAVOR` dart-define for dev vs prod builds; url_launcher added; demo account overhaul (18 tables seeded, Reset to Demo Defaults button) |
| **v3.0.0** | Oct 9, 2026 | Transaction sort/group (5 keys, 5 group-by, collapsible headers); Chat sessions (DB v14, New Chat, session list, archive/delete); AI recovery card (✅/⚠️/❌ per item, re-log helper); Analytics quick-jump anchors + period chip overflow fix + category sort toggle |
| v2.9.98 | Oct 2026 | Screenshot import visibility: `[screenshot]` tag in AI context; skipped-dup feedback loop; sort fix for 00:00 items |
| v2.9.97 | Oct 2026 | AI backdating fix: Today/Yesterday in context; "yesterday"/"kahapon" resolution; NOT-RECORDED CHECK before re-log |
| v2.9.92 | Oct 2026 | Local AI private mode (9th provider); Settings Local AI section; privacy banner |
| v2.9.90 | Oct 2026 | 10-item re-audit fixes: delete confirmations, archive bug, FHS tooltip, Peso empties, wallet history on home |
| v2.9.89 | Oct 2026 | DB v13 budget/goal/income/score history; full audit trail |
| v2.9.88 | Oct 2026 | Wallet balance change history; App Check debug token |
| v2.9.87 | Sep 2026 | Installment→Plans tab fix; DQ View navigates to Transactions; Fix All for case_dup/round_amount |
| v2.9.84 | Sep 2026 | Achievement celebrations, analytics interpretive labels, AI chat date dividers |
| v2.9.82 | Sep 2026 | App-wide QoL polish (43 screens): Peso empty states, delete confirmations, FAB fixes |
