# SmartSpend — Kiro Context & Architecture Reference

**Version:** 2.7.0
**Last Updated:** June 11, 2026
**For:** Kiro AI assistant — read this before making any changes to the codebase.

---

## Project Overview

Smart Spend is an AI-powered personal finance tracker for Android (Flutter/Dart). It is a **capstone project** by Lucid Frame at Lorma Colleges, BSIT, San Fernando La Union.

**Core concept:** User Input → AI Parsing → SQLite (local) → Firestore (cloud) → Analytics & Insights

**Not** a banking app. Does not process payments. It is a recorder, analyzer, and advisor.

---

## Team

| Name | Role |
|------|------|
| Brix A. Directo | Lead Developer |
| Cyrille John M. Rubis | UI/UX Designer & Documentation Lead |
| Djaunathan Albert S. Madayag | Project Manager & QA Lead |

---

## Architecture

```
Flutter UI (screens/) → Services (services/) → SQLite (sqflite v11)
                                             → Firestore (cloud_firestore)
                                             → Groq API (LLaMA 3.1 8B)
                                             → open.er-api.com (exchange rates)
```

### Key Services

| Service | Responsibility |
|---------|---------------|
| `DBService` | All SQLite CRUD. Every write also calls CloudService. |
| `CloudService` | All Firestore sync. `pushDoc`, `deleteDoc`, `pullAll`, `pushAll`. |
| `AIChatService` | Groq API chat. Context injection. Action parsing. |
| `LLMService` | Groq API for expense parsing, insights, receipt import. |
| `AppConfig` | Centralized API keys. **In `.gitignore` — do not commit.** |
| `AuthService` | Firebase Auth (email/password + Google). |
| `ScoreService` | Financial Health Score calculation (4-component, 25pts each). |
| `NotificationService` | All push notifications via flutter_local_notifications. |
| `BackupService` | JSON backup/restore (v9 — includes insurance_policies). |
| `BarcodeLookupService` | Product lookup: local PH DB + Open Food Facts API + prefix inference. |
| `StartupAlertsService` | On-open alerts: 6 conditions (bills, budgets, debts, FHS drop, idle money, insurance). |
| `RecurringHelper` | Shared log+advance logic for recurring transactions. |
| `InsuranceScreen` | Insurance & government contributions tracker with Firestore sync. |
| `BankComparisonScreen` | PH banks, digital banks, e-wallets, investments (from ph_banks.json). |
| `PCACalculatorScreen` | Peso Cost Averaging calculator with year-by-year breakdown. |
| `DemoService` | Sample data loading. **Never touches Firestore.** |
| `CategoryService` | Category list cache. Call `invalidate()` after any category change. |
| `CurrencyService` | Exchange rates + formatting. All amounts stored in PHP internally. |
| `UndoService` | In-memory 60-second undo for AI actions. |
| `EventBus` | Cross-screen refresh via `fireEvent(AppEvent.xxx)`. |

---

## Database — SQLite v11

**Tables and their Firestore sync status:**

| Table | Firestore Synced | Backup | Notes |
|-------|-----------------|--------|-------|
| `expenses` | ✅ Yes | ✅ Yes | Last-write-wins via `updated_at` |
| `budgets` | ✅ Yes | ✅ Yes | Full replace on pushAll (prevents resurrection) |
| `savings_goals` | ✅ Yes | ✅ Yes | |
| `income` | ✅ Yes | ✅ Yes | |
| `recurring` | ✅ Yes | ✅ Yes | |
| `debts` | ✅ Yes | ✅ Yes | |
| `custom_categories` | ✅ Yes | ✅ Yes | |
| `installment_plans` | ✅ Yes | ✅ Yes | Payment Plans tab in Debt screen |
| `wallets` | ✅ Yes | ✅ Yes | Cash, GCash, Maya, banks |
| `category_rules` | ✅ Yes | ✅ Yes | Keyword → category mappings |
| `installments` | ✅ Yes (legacy) | ✅ Yes | Old table, migrated to installment_plans |
| `score_history` | ❌ Local only | ❌ No | Device analytics |
| `mood_log` | ❌ Local only | ✅ Yes | Per-account, cleared on logout |
| `scan_history` | ❌ Local only | ✅ Yes | Barcode scan history |
| `chat_history` | ❌ Local only | ❌ No | Per-account, cleared on logout |
| `conversation_summaries` | ❌ Local only | ❌ No | AI token compression |
| `recurring_candidates` | ❌ Local only | ❌ No | Auto-detected patterns |
| `settings` | ✅ Partial | ❌ No | See synced keys below |
| `user_profile` | ✅ Yes | ❌ No | Via CloudService.saveProfile |
| `category_rules` | ✅ Yes | ✅ Yes | |

**Settings keys synced to Firestore** (via `pushAllToCloud` → `CloudService.pushSettings`):
- `monthly_income`, `account_type`, `income_frequency`, `currency`, `setup_done`
- `daily_limit`, `payday_date`, `manual_assets`

**Settings keys cleared on logout** (in `clearLocalData`):
- `monthly_income`, `account_type`, `income_frequency`, `payday_date`
- `spending_challenge`, `setup_done`, `manual_assets`, `quiz_challenge`
- `impulse_declines`, `level_up_60/70/80/90`, `warning_decay_days`, `last_decay_check`
- `done_spending_today`, `weekly_challenge_dismissed`, `last_recurring_check`
- `last_weekly_notif`, `last_anomaly_check`, `last_velocity_check`, `last_want_alert`, `last_daily_briefing`

---

## Sync Flow

### On Login
1. `DBService.syncFromCloud()` — pulls all Firestore collections, merges into SQLite
2. `DBService.pushAllToCloud()` — pushes local data to Firestore (ensures cloud is current)
3. Settings restored from Firestore if missing locally

### On Every Write
- Every `DBService.insertX/updateX/deleteX` calls `CloudService.pushDoc/deleteDoc` immediately
- `CloudService._shouldSkipSync` returns true if: demo is loading OR no user logged in

### On Logout
1. `DBService.pushAllToCloud()` — push everything to Firestore
2. `DBService.clearLocalData()` — wipe all per-account local data
3. `AIChatService.clearHistory()` — clear in-memory AI context
4. `UndoService.clear()` — clear undo buffer
5. `AuthService.logout()` — Firebase sign out

### Demo Mode
- `DemoService._isDemoLoading = true` during `loadSampleData()`
- `CloudService._shouldSkipSync` checks this flag — **demo data never reaches Firestore**
- `DemoService.clearDemoData()` also wipes Firestore if a real user is logged in

---

## AI Architecture

**Type:** Agentic AI with dynamic context injection (not RAG)

**Flow:** Every message → fresh DB query → inject full context into system prompt → Groq API → parse ACTION lines → execute directly on SQLite → Firestore sync

**Context includes:** Last 30 expenses (10 detailed + 20 summarized), budgets, income, health score (with FHS breakdown), goals, debts, recurring, installments, wallets, insurance policies, mood, custom categories, quiz challenge

**25 action types:** `log_expense`, `set_budget`, `set_income`, `add_goal`, `update_goal`, `delete_goal`, `add_income`, `add_debt`, `update_debt`, `add_recurring`, `delete_recurring`, `set_account_type`, `update_expense`, `delete_expense`, `delete_by_date`, `add_installment_plan`, `set_wallet_balance`, `transfer_wallet`, `plan_salary_split`, `analyze_goal_feasibility`, `suggest_debt_payoff`, `generate_monthly_plan`, `compare_periods`, `explain_fhs_breakdown`, `project_savings_timeline`, `detect_subscriptions`, `compute_contribution`, `suggest_idle_money`

**Daily limit:** 60 messages/day (SharedPreferences, device-wide, intentional)

**API key location:** `lib/services/app_config.dart` → `AppConfig.groqApiKey`

---

## Financial Health Score

4 components, 25 pts each, total 0–100:

| Component | Formula |
|-----------|---------|
| Savings Rate | `25 × min(1, savingsRate / 0.20)` |
| Overspend Control | `25 × (1 − overDays / activeDays)` |
| Budget Adherence | `25 × (onBudgetCategories / totalBudgets)` |
| Logging Consistency | `25 × (loggedDays / activeDays)` |

**Warning Decay:** −5 pts/day when budget exceeded and spending continues, max −15 pts (3 days). Resets when back on track.

**Fallback:** If no income set, partial credit given for income-dependent components.

**Percentage budgets:** Always resolve `percentageValue / 100 × monthlyIncome` before comparing — never use `b.amount` directly for percentage budgets.

---

## Coding Conventions

### Always do
- All DB writes fire `AppEvent` via `fireEvent()` for cross-screen refresh
- Theme colors: `Theme.of(context).colorScheme.primary` — never hardcode `Color(0xFF...)`
- Currency: `CurrencyService.format()` and `CurrencyService.symbol` — amounts stored in PHP
- Async: `try-catch` on all async operations, show `SnackBar` on error
- After category changes: call `CategoryService.invalidate()`
- After any write: `CloudService.pushDoc/deleteDoc` (already in DBService methods)
- Parallel DB reads: use `Future.wait([...])` pattern

### Never do
- Never call `db.insert/update/delete` directly from screens — always go through `DBService`
- Never hardcode category lists — use `CategoryService.getAll()`
- Never store amounts in non-PHP currency — convert for display only
- Never push demo data to Firestore — `DemoService._isDemoLoading` flag handles this
- Never build APK unless explicitly asked by Brix

### Build command (when asked)
```bash
flutter build apk --release --split-per-abi --shrink --obfuscate --split-debug-info=build/debug-info
```
Outputs 3 APKs: `armeabi-v7a` (older phones), `arm64-v8a` (modern phones), `x86_64` (emulators).

### After every change
1. Run `getDiagnostics` on changed files
2. Fix any errors before moving to next task
3. Do NOT build unless explicitly requested

---

## File Structure

```
lib/
├── main.dart                          # App entry, lifecycle, app lock on resume
├── models/
│   ├── expense.dart                   # Expense model + toMap/fromMap
│   ├── budget.dart                    # Budget model (supports % mode)
│   └── user_profile.dart              # UserProfile model
├── screens/                           # 31 screens
│   ├── home_screen.dart               # Dashboard + Quick Access Hub
│   ├── ai_screen.dart                 # AI chat + all 15 action handlers
│   ├── analytics_screen.dart          # Charts, FHS, 50/30/20, predictions
│   ├── profile_screen.dart            # Profile, net worth, wallets, settings
│   ├── budget_screen.dart
│   ├── savings_goals_screen.dart
│   ├── income_screen.dart
│   ├── debt_screen.dart               # I Owe + Owed to Me + Payment Plans tabs
│   ├── recurring_screen.dart
│   ├── transactions_screen.dart
│   ├── bill_calendar_screen.dart
│   ├── achievements_screen.dart
│   ├── bank_import_screen.dart        # AI-powered bulk bank/GCash import
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── setup_screen.dart              # Onboarding wizard (4 steps)
│   ├── splash_screen.dart
│   ├── smart_camera_screen.dart       # Unified OCR + barcode scanner
│   ├── scan_review_screen.dart
│   ├── add_expense_screen.dart
│   ├── edit_expense_screen.dart
│   ├── currency_screen.dart
│   ├── manage_categories_screen.dart
│   ├── manage_rules_screen.dart
│   ├── help_screen.dart
│   ├── about_screen.dart
│   ├── whats_new_screen.dart          # v2.6.0 — shown once after update
│   ├── app_lock_screen.dart
│   ├── pin_setup_screen.dart
│   ├── chat_history_screen.dart
│   └── onboarding_screen.dart
├── services/                          # 23 services
│   ├── db_service.dart                # All SQLite CRUD (1700+ lines)
│   ├── cloud_service.dart             # All Firestore sync
│   ├── auth_service.dart              # Firebase Auth
│   ├── ai_chat_service.dart           # Groq chat + context injection
│   ├── llm_service.dart               # Groq for parsing/insights
│   ├── app_config.dart                # API keys (NOT in git)
│   ├── score_service.dart             # FHS calculation
│   ├── notification_service.dart      # All push notifications
│   ├── backup_service.dart            # JSON backup/restore
│   ├── demo_service.dart              # Sample data (never touches Firestore)
│   ├── category_service.dart          # Category list cache
│   ├── currency_service.dart          # Exchange rates + formatting
│   ├── undo_service.dart              # In-memory undo (60s window)
│   ├── event_bus.dart                 # Cross-screen AppEvent bus
│   ├── theme_service.dart             # Theme + dark mode
│   ├── app_lock_service.dart          # PIN + biometric (per-account keys)
│   ├── insight_service.dart           # AI insights wrapper
│   ├── predict_service.dart           # Spending prediction
│   ├── export_service.dart            # CSV export
│   ├── ocr_service.dart               # ML Kit OCR
│   ├── voice_service.dart             # Speech-to-text
│   ├── tax_service.dart               # PH BIR TRAIN Law estimates
│   └── debug_service.dart             # Debug log export
└── widgets/
    ├── expense_tile.dart
    ├── feature_tour.dart              # Per-account tour (tour_done_${uid})
    ├── action_button.dart
    └── info_button.dart
```

---

## SharedPreferences Keys

| Key | Scope | Notes |
|-----|-------|-------|
| `tour_done_${uid}` | Per-account | Feature tour shown flag |
| `app_lock_pin_${uid}` | Per-account | Obfuscated PIN |
| `app_lock_enabled_${uid}` | Per-account | Lock enabled flag |
| `dark_mode` | Device-wide | Intentional — theme is device preference |
| `app_theme` | Device-wide | Intentional |
| `ai_chat_count` | Device-wide | Daily limit counter — intentional (API key protection) |
| `ai_chat_date` | Device-wide | Daily limit date — intentional |
| `onboarding_done` | Device-wide | First-launch walkthrough — once per device is correct |
| `was_demo_mode` | Device-wide | Demo isolation flag |

---

## Known Pending Issues (as of v2.6.0)

| # | Issue | Priority | Status |
|---|-------|----------|--------|
| 2 | Google profile picture as default avatar | MEDIUM | ❌ Open |
| 3 | Analytics: Last Month + month picker | MEDIUM | ❌ Open |
| 4 | Backdated expenses: Component 4 fairness | LOW | ❌ Open |
| 5 | CSV file import (GCash, Maya, BDO, BPI) | HIGH (C2) | ❌ Capstone 2 |

All HIGH priority issues from previous sessions are resolved. See `SmartSpend_PendingIssues.md` for full history.

---

## Version History (Summary)

| Version | Date | Key Changes |
|---------|------|-------------|
| 2.7.0 | June 11, 2026 | 25 AI actions (30 planned), PCA calculator, Financial Health Certificate, expandable chat, income frequency fix (bimonthly for all), emergency fund outlier exclusion, AI personality warmth, 7 debug log bugs fixed (double-logging wallet, ACTION regex, is_want coercion, duplicate income, low income warning), barcode product lookup (Open Food Facts API), bank comparison screen, high contrast mode, text size, round-up savings, price memory, smart daily allowance, 23 badges + 10 daily quests, DTI ratio, emergency fund calculator, Firebase Remote Config API security, App Check debug mode (Google login fix), SHA-1 in debug log |
| 2.6.0 | May 11, 2026 | Full cloud sync audit — wallets, category_rules, demo isolation, backup restore sync, reset all data Firestore wipe, undo sync, setup push, notification throttle reset, budget_boss badge fix, API key centralized |
| 2.5.0 | May 10, 2026 | Wallet Balances, PH bank support, smart receipt import, unified calendar, achievements, mood check-in, auto-categorization rules, period comparison, installment plans, bank import |
| 2.4.0 | Apr 29, 2026 | Custom categories, shake-to-undo, expense photos, % budget mode, want/need tagging, streaks/badges, daily limit, bill calendar, onboarding quiz, FHS rewrite |
| 2.3.0 | Apr 28, 2026 | AI-centric UX, Hub navigation, 50/30/20 tracker, emergency fund, installment tracker, cash flow forecast, net worth |

---

## Firebase / Infrastructure Notes

- **Plan:** Spark (free) — no Firebase Storage, no Cloud Functions
- **Profile photos:** Local only — Storage requires Blaze plan
- **Real-time sync:** Login-triggered, not real-time (no Cloud Functions)
- **App Check:** Play Integrity for release builds
- **Crashlytics:** Enabled for release builds

---

## Release Signing

The app is signed with a dedicated release keystore (not the debug key).

**Files (NOT in git — get from Brix):**
- `android/app/smartspend-release.jks` — the keystore file
- `android/key.properties` — passwords (create locally, see HOWTORUN.md §6)

**SHA-1 fingerprints registered in Firebase:**
- Release: `9E:2E:EE:E5:0A:9D:80:66:4E:79:DF:22:8E:B9:79:8A:E0:C7:F2:28`
- Debug: `40:B2:1D:58:7A:95:93:55:6D:A2:B0:5A:22:43:D4:1B:D0:C0:D6:62`

Both registered in Firebase → Project Settings → Android app. Required for Google Sign-In.

`build.gradle.kts` reads `key.properties` at build time. Falls back to debug key if file is missing.

---

## Package Conflict Note

The `shake` package (`^2.2.0`) depends on `sensors_plus ^3.x`. Newer packages want `sensors_plus ^7.x`. The `dependency_overrides` in `pubspec.yaml` pins `sensors_plus: ^3.1.0` to keep `shake` working.

**This is intentional and correct.** Do NOT remove the override or upgrade `shake` without first checking if a newer version of `shake` supports `sensors_plus ^7.x`.

`flutter pub get` works fine. The `!` warning next to `sensors_plus` in pub output is expected — it means "overridden", not broken.

The 56 packages with newer incompatible versions are **not a problem** — they have breaking API changes that would require code rewrites. Leave them as-is for the capstone.

---

- `pubspec.yalm` — this is a stray typo file, ignore it (the real file is `pubspec.yaml`)
- `flutter` (file in root) — stray file, ignore
- `android/key.properties` — signing config, not in repo
- `lib/services/app_config.dart` — not in repo, must be created locally

---

*Generated by Kiro for Lucid Frame | May 11, 2026*
