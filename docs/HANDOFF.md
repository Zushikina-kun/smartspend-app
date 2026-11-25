# SmartSpend App — Complete Handoff Manual

**Version:** 3.5.8+136  
**Date:** Current  
**Authors:** Lucid Frame — Lorma Colleges CCSE, BSIT  
**Package:** `com.lucidframe.smartspend_app`

---

## Executive Summary

SmartSpend is a Filipino-first personal finance Android app built with Flutter. It combines offline SQLite storage with cloud sync (Firebase Firestore), multi-provider AI (up to 19 models across 6 providers), on-device OCR, voice input, and a rich feature set tailored to Philippine financial life: BIR tax deadlines, government contributions (SSS, PhilHealth, Pag-IBIG, LTO), OFW remittance tracking, paluwagan (ROSCA) groups, GCash/Maya SMS parsing, Philippine bank comparison, and peso-centric budget advice from an in-app mascot named Peso.

The app is at v3.5.8+136 — a major sprint that shipped 17 "critical/high" audit fixes on top of the v3.5.5 localization release. Those fixes include: expense soft-delete with 30-day recycle bin, flexible installment payment schedules with overpayment credit carry-forward, wallet audit/integrity checks with biometric lock on balance edits, taxpayer-type-aware BIR deadlines (non-VAT / VAT / professional / mixed-income), tax filing history, income-to-wallet allocation, round-up contribution reversal on expense delete, budget rollover auto-application, and phone OTP + email verification flows.

The AI subsystem routes every request through a 15-step ordered fallback chain: OpenRouter free models → Gemini (if key provided) → Groq free models → Cerebras. All keys are stored in Firebase Remote Config; the codebase carries compile-time fallbacks for Groq and Cerebras only. The Financial Health Score (FHS) is a 4-component (25 pts each) local formula covering savings rate, overspend control, budget adherence, and logging consistency. No PII leaves the device via analytics; Firebase Analytics logs only model IDs and boolean success flags.

---

## App Architecture

### Technology Stack

| Layer | Technology |
|-------|-----------|
| UI framework | Flutter 3.41.6 (stable), Dart SDK ≥3.0.0 |
| Local database | SQLite via `sqflite` v2.3.0 (db version 17) |
| Cloud sync | Firebase Firestore (`cloud_firestore`) |
| Auth | Firebase Auth — email/password + Google Sign-In |
| Crash reporting | Firebase Crashlytics |
| Analytics | Firebase Analytics (no PII) |
| App protection | Firebase App Check |
| Remote config | Firebase Remote Config (API keys, feature flags) |
| AI providers | Groq, Gemini (Google AI Studio), Cerebras, OpenRouter, Ollama/LM Studio (local) |
| OCR | Google ML Kit Text Recognition + Document Scanner |
| Barcode | Google ML Kit Barcode + `mobile_scanner` |
| Charts | `fl_chart` |
| Voice | `speech_to_text` |
| Biometrics | `local_auth` |
| Notifications | `flutter_local_notifications` |
| Currency rates | open.er-api.com (free, no key) |
| Price data | PSA Open Data (openstat.psa.gov.ph) + DOE HTML scrape |
| Localization | Flutter `intl` / ARB files — English, Tagalog, Cebuano |
| PWA | Flutter Web (`flutter build web`) — same codebase |

### Data Flow: User Action → AI → DB → UI Update

```
User Action (voice / text / scan / tap)
    │
    ├─ Voice: VoiceService (speech_to_text) → transcribed text
    ├─ Scan:  OCRService (ML Kit) → raw text; OCRService.preferredModelForOcr() switches to vision model
    ├─ Import: LLMService.parseReceipt() → structured JSON
    └─ Chat:  AIChatService.sendMessage()
                │
                ├─ AppConfig.groqApiKey / groqBaseUrl / groqModel  ← resolves active model
                ├─ HTTP POST to provider endpoint (OpenAI-compat format)
                │   On 401/429/timeout: AppConfig.autoFallback() → next chain model → retry (up to 16 attempts)
                ├─ Response parsed → AIAction list extracted
                └─ AIChatService.filterActionsBySource() (allowlist: 'chat' vs 'import')
                        │
                        └─ ai_screen.dart executor:
                               log_expense / log_multiple_expenses
                                 → DBService.insertExpense()
                                 → CloudService.upsertDoc()   ← Firestore push
                                 → fireEvent(AppEvent.expenseChanged)
                                     │
                                     └─ All screens listening (home, transactions, analytics, etc.) reload
```

### AI Context Building (AIChatService.setFullContext)

Before every AI request, the caller builds a context string containing:
- Recent 10 expenses (detailed) + older by category sum
- Budgets with current spending vs limit
- Savings goals progress
- Debts / installment plans remaining balance
- Recurring bills due status
- Wallet balances (skipped in lightweight mode)
- Last 3 months' spending totals
- Financial Health Score (FHS) with breakdown
- Want/Need ratio
- Spending limits (daily/weekly/monthly/yearly if set)
- Logging gap penalty information
- Insurance policies
- Mood log (optional)
- User-defined categorization rules

Conversation history is maintained as `_history` (static list). Every 10 messages, the history is summarized via `conversation_summaries` table to stay within model context windows.

### Wallet Auto-Deduction (v3.5.8)

When an expense is logged (via any path — AI, manual, scan, import):
1. If the expense has a `wallet_id` set, `DBService.insertExpense()` calls `DBService.updateWalletBalance(walletId, -amount)`.
2. A row is written to `wallet_history` with `source: 'expense'` and the old/new balance.
3. If the expense is later deleted, `DBService.deleteExpense()` reads `wallet_id` and reverses the debit (`+amount`).
4. If the expense is edited with a different amount, `DBService.updateExpense()` computes the delta and adjusts the wallet by the difference.
5. Sensitive wallet operations (balance edit, snapshot restore) require biometric / PIN confirmation via `AppLockService`.

### Financial Health Score Formula

```
FHS = comp1 (Savings Rate) + comp2 (Overspend Control) + comp3 (Budget Adherence) + comp4 (Logging Consistency)

comp1 = 25 × min(1, savingsRate / 0.20)
        savingsRate = (income − totalSpent) / income
        Full 25 pts when saving ≥ 20 % of income.

comp2 = 25 × (1 − overDays / periodDays)
        overDays = days where daily spending > (income / daysInMonth)
        Full 25 pts when no day exceeded the daily budget.

comp3 = 25 × (onBudgetCategories / totalBudgetCategories)
        If no budgets set: 25 pts (not penalized).

comp4 = 25 × (loggedDays / activeDays)
        activeDays = days since first expense or start of month.
        Full 25 pts when logging every active day.

Lightweight mode (no income/wallet tracking): uses a modified formula where
comp1 is replaced by a "spending limit adherence" measure; comp2 is based on
the user-set daily/weekly limit instead of income.

Payday-cycle mode: comp3 filters budget adherence to the period from the last
payday (1st or 15th for bi-monthly income; 1st-of-month otherwise).
```

Scoring tiers:
- 85–100: Excellent (green)
- 65–84: Good (blue)
- 45–64: Fair (orange)
- 0–44: Needs Work (red)

---

## Feature Inventory

### Screens (63 total)

| Screen | File | Purpose |
|--------|------|---------|
| SplashScreen | `splash_screen.dart` | App entry, Firebase init, auth gate |
| OnboardingScreen | `onboarding_screen.dart` | First-launch walkthrough |
| LoginScreen | `login_screen.dart` | Email/password + Google Sign-In; shows email-unverified banner |
| RegisterScreen | `register_screen.dart` | New account creation |
| EmailVerificationScreen | `email_verification_screen.dart` | Post-registration email verification flow |
| PhoneOtpScreen | `phone_otp_screen.dart` | Firebase SMS OTP for phone number verification in profile |
| SetupScreen | `setup_screen.dart` | First-use income + budget setup |
| PinSetupScreen | `pin_setup_screen.dart` | 4-digit PIN creation for app lock |
| AppLockScreen | `app_lock_screen.dart` | PIN/biometric gate shown when app resumes |
| HomeScreen | `home_screen.dart` | Main hub: FHS card, wallet balance, Peso mascot, quick actions, goals, alerts |
| TransactionsScreen | `transactions_screen.dart` | Full expense list with filter, sort, multi-select delete, soft-delete recycle bin |
| AddExpenseScreen | `add_expense_screen.dart` | Manual expense entry with auto-categorization, catalog lookup, receipt photo |
| EditExpenseScreen | `edit_expense_screen.dart` | Expense editing with wallet adjustment on amount change |
| ScanReviewScreen | `scan_review_screen.dart` | Review AI-parsed scan before saving |
| SmartCameraScreen | `smart_camera_screen.dart` | Live camera OCR with real-time text overlay |
| BatchImageImportScreen | `batch_image_import_screen.dart` | Batch import of 40+ platform screenshots |
| BatchManualEntryScreen | `batch_manual_entry_screen.dart` | Paste bank statement text for AI parsing |
| BankImportScreen | `bank_import_screen.dart` | CSV/text bank statement import with AI normalization |
| AiScreen | `ai_screen.dart` | AI chat with Peso — expense logging, advice, queries; session summary card |
| ChatHistoryScreen | `chat_history_screen.dart` | Multi-session chat archive |
| AnalyticsScreen | `analytics_screen.dart` | Spending charts (weekly/monthly/yearly/custom), category breakdown, CSV export |
| InsightsScreen | `insights_screen.dart` | AI-generated spending insights |
| ForecastScreen | `forecast_screen.dart` | 30-day cash flow forecast |
| HeatmapScreen | `heatmap_screen.dart` | Calendar spending heatmap |
| BudgetScreen | `budget_screen.dart` | Per-category budgets, rollover credit, payday-cycle mode |
| IncomeScreen | `income_screen.dart` | Income log with edit, wallet-allocation split, history |
| RecurringScreen | `recurring_screen.dart` | Recurring bills/income with multi-month catch-up |
| DebtScreen | `debt_screen.dart` | Debt tracker (owe/lent) + installment plans with variable payment schedules |
| DebtPayoffScreen | `debt_payoff_screen.dart` | Avalanche vs snowball payoff simulation |
| DebtCalculatorScreen | `debt_calculator_screen.dart` | Standalone loan/interest calculator |
| SavingsGoalsScreen | `savings_goals_screen.dart` | Goal tracker with round-up savings, animated progress |
| InvestmentScreen | `investment_screen.dart` | Portfolio tracker — stocks/UITF/crypto PnL |
| NetWorthScreen | `net_worth_screen.dart` | Assets + liabilities (includes installment plans) = net worth |
| TaxScreen | `tax_screen.dart` | BIR deadlines by taxpayer type, income tax estimator, filing history |
| GovContributionsScreen | `gov_contributions_screen.dart` | SSS/PhilHealth/Pag-IBIG YTD summary + estimator |
| SssScreen | `egov/sss_screen.dart` | Detailed SSS contributions with pension estimator |
| PagibigScreen | `egov/pagibig_screen.dart` | Pag-IBIG contribution tracker |
| LtoScreen | `egov/lto_screen.dart` | LTO registration/renewal reminder |
| OFW RemittanceScreen | `ofw/remittance_screen.dart` | Remittance log with FX conversion (USD/SAR/AED/SGD/HKD) |
| BalikbayanTrackerScreen | `ofw/balikbayan_tracker_screen.dart` | Balikbayan box tracker |
| PalawaganScreen | `paluwagan_screen.dart` | ROSCA group tracker with round rotation |
| PriceIntelligenceScreen | `price_intelligence_screen.dart` | Per-product price history, trend charts, best-deal finder, manual entry |
| BankComparisonScreen | `bank_comparison_screen.dart` | PH bank interest rates/features comparison |
| PcaCalculatorScreen | `pca_calculator_screen.dart` | Per-capita allocation calculator |
| CurrencyScreen | `currency_screen.dart` | 57-currency FX converter (live rates) |
| BillCalendarScreen | `bill_calendar_screen.dart` | Calendar view of upcoming bill due dates |
| LogDueBillsScreen | `log_due_bills_screen.dart` | One-tap log for all overdue recurring bills |
| ProfileScreen | `profile_screen.dart` | User profile editor with photo, phone OTP, name |
| SettingsScreen | `settings_screen.dart` | Full settings: AI model, language, theme, app lock, notifications, spending limits, local AI |
| AboutScreen | `about_screen.dart` | App info, version, dev team credits |
| FeedbackScreen | `feedback_screen.dart` | In-app feedback submission |
| HelpScreen | `help_screen.dart` | FAQ and how-to guide |
| GlossaryScreen | `glossary_screen.dart` | Filipino personal finance glossary |
| QuickTipsScreen | `quick_tips_screen.dart` | Context-aware tip cards |
| AchievementsScreen | `achievements_screen.dart` | 36 achievement badges with progress |
| ChallengesScreen | `challenges_screen.dart` | Weekly spending challenges |
| WhatsNewScreen | `whats_new_screen.dart` | In-app changelog shown once per version |
| ManageCategoriesScreen | `manage_categories_screen.dart` | Add/delete custom expense categories |
| ManageRulesScreen | `manage_rules_screen.dart` | User-defined keyword → category auto-categorization rules |
| MerchantMergeScreen | `merchant_merge_screen.dart` | Merge near-duplicate merchant names |
| DataQualityScreen | `data_quality_screen.dart` | Scan for and fix data issues (dupes, wrong categories, round amounts) |
| InsuranceScreen | `insurance_screen.dart` | Insurance policy tracker |
| ProfileScreen | `profile_screen.dart` | User profile with photo, phone, Firebase sync |

### Services (57 files)

| Service | File | Role |
|---------|------|------|
| AppConfig | `app_config.dart` | Multi-model AI router: 19 models, fallback chain, Firebase Remote Config key loading |
| AIChatService | `ai_chat_service.dart` | AI conversation engine: context building, action parsing, session history, duplicate guard |
| LLMService | `llm_service.dart` | Stateless AI call wrapper for OCR/analytics/receipt parsing (uses same AppConfig routing) |
| OCRService | `ocr_service.dart` | Google ML Kit OCR + image pre-processing for receipts and documents |
| DBService | `db_service.dart` | SQLite singleton — all CRUD, migrations (v1–17), wallet deduction, soft-delete |
| CloudService | `cloud_service.dart` | Firestore read/write; every local write pushes; on login pulls and merges |
| AuthService | `auth_service.dart` | Firebase Auth: email, Google Sign-In, phone OTP, biometric gate |
| AppLockService | `app_lock_service.dart` | PIN (base64-obfuscated, per-UID) + biometric lock via `local_auth` |
| ScoreService | `score_service.dart` | FHS computation — 4-component formula (normal + lightweight mode) |
| BudgetPeriodUtil | `budget_period_util.dart` | Payday-cycle period start (bi-monthly: 15th; others: 1st) |
| AnalyticsService | `analytics_service.dart` | Firebase Analytics: model usage, OCR, voice, feature entry (no PII) |
| RateLimitService | `rate_limit_service.dart` | Reads OpenRouter `x-ratelimit-remaining` header; exposes `showWarning` |
| ForecastService | `forecast_service.dart` | 30-day cash flow projection using historical average + recurring |
| InsightService | `insight_service.dart` | Thin wrapper — calls `LLMService.analyzeInsights()` |
| PriceIntelligenceService | `price_intelligence_service.dart` | Price history CRUD, trend analysis, best-deal finder, alert check |
| CurrencyService | `currency_service.dart` | 57-currency live rates from open.er-api.com; cached in SQLite |
| TaxReminderService | `tax_reminder_service.dart` | BIR deadline sets by taxpayer type; income tax + percentage tax estimators; local notification scheduling |
| NotificationService | `notification_service.dart` | `flutter_local_notifications` wrapper; channels for bills, tax, nudges; tap → deep link |
| ProactiveNudgeService | `proactive_nudge_service.dart` | Forward-looking daily push notifications (5 trigger conditions) |
| StartupAlertsService | `startup_alerts_service.dart` | Reactive alerts on app open: logging gaps, payday reminders, overdue bills |
| StreakService | `streak_service.dart` | Consecutive-day logging streak + weekly challenges |
| BehavioralFeedbackService | `behavioral_feedback_service.dart` | Plain-language FHS narratives, purchase commentary, coach reports (all local, no AI call) |
| AutoCategoryService | `auto_category_service.dart` | Keyword-based category suggestion (150+ Filipino expense keywords) |
| CategoryService | `category_service.dart` | 17 built-in categories + custom categories from DB |
| MerchantNormalizationService | `merchant_normalization_service.dart` | Auto-normalizes shop names; detects near-duplicate merchants |
| RecurringDetector | `recurring_detector.dart` | ML-free pattern detection: finds subscriptions from last 90 days of expenses |
| RecurringHelper | `recurring_helper.dart` | Date math for recurring period advancement |
| ItemCatalogService | `item_catalog_service.dart` | Offline catalog of 150+ common Filipino expense items with suggested prices |
| BarcodeLookupService | `barcode_lookup_service.dart` | Product info lookup from barcode via open API |
| DebtCalculator | `debt_calculator.dart` | Avalanche vs snowball payoff simulation (pure logic, no DB) |
| PredictService | `predict_service.dart` | Next-month spending prediction from historical averages |
| DataQualityService | `data_quality_service.dart` | Scan for zero-time imports, case duplicates, Others-category mis-tags, round AI amounts |
| ExportService | `export_service.dart` | CSV export of expenses; analytics summary export |
| BackupService | `backup_service.dart` | JSON full backup (expenses, budgets, goals, income, recurring, debts, installments, wallets, etc.) + restore |
| SmsParserService | `sms_parser_service.dart` | GCash/Maya SMS message parser via Android MethodChannel (hidden in non-debug until MethodChannel is wired) |
| NotificationListenerService | `notification_listener_service.dart` | Notification access listener (also gated behind debug for now) |
| PsoService | `psa_service.dart` | PSA Open Data API — rice and commodity retail prices for Metro Manila (cached 30 days) |
| DoeService | `doe_service.dart` | DOE fuel price scraper + PSA petroleum fallback (cached 7 days) |
| RemittanceService | `remittance_service.dart` | OFW remittance CRUD with static FX rates; Firestore sync |
| VoiceService | `voice_service.dart` | `speech_to_text` wrapper for AI screen microphone input |
| PesoVoiceService | `peso_voice_service.dart` | 51-context Taglish speech line library for Peso mascot |
| PesoSoundService | `peso_sound_service.dart` | Sound/vibration feedback for Peso reactions |
| PesoContextService | `peso_context_service.dart` | Maps current screen route → Peso context enum |
| PesoActivityLog | `peso_activity_log.dart` | In-memory log of Peso's recent reactions (prevents rapid repeat) |
| ProService | `pro_service.dart` | Freemium gate stub — everyone is Pro in v3.x; RevenueCat hook point for v4.0 |
| UpdateService | `update_service.dart` | GitHub Releases poller for in-app auto-update (arm64-v8a APK download via `dio`) |
| UndoService | `undo_service.dart` | In-memory undo for the last action (60-second window); batch delete undo |
| DemoService | `demo_service.dart` | Demo mode data loading (suppresses cloud sync while loading) |
| DebugService | `debug_service.dart` | Provides `kAppVersion` constant; debug overlay |
| ThemeService | `theme_service.dart` | 12 color themes with persistence |
| EventBus | `event_bus.dart` | Global stream bus: `expenseChanged`, `budgetChanged`, `incomeChanged`, `goalChanged` |
| EgovSssService | `egov/sss_service.dart` | SSS contribution calculations |
| EgovPagibigService | `egov/pagibig_service.dart` | Pag-IBIG contribution calculations |
| EgovPhilhealthService | `egov/philhealth_service.dart` | PhilHealth contribution calculations |
| EgovLtoService | `egov/lto_service.dart` | LTO renewal reminder logic |

### Reusable Widgets

| Widget | File | Purpose |
|--------|------|---------|
| PesoMascot | `peso_mascot.dart` | Animated mascot with 12 moods, tap/double-tap/long-press interactions |
| ExpenseTile | `expense_tile.dart` | Standard expense list tile with swipe actions |
| ActionButton | `action_button.dart` | Styled CTA button used across screens |
| FeatureTour | `feature_tour.dart` | Guided overlay for first-time feature discovery |
| HistorySheet | `history_sheet.dart` | Bottom sheet for displaying audit history (wallets, goals, budgets) |
| InfoButton | `info_button.dart` | ⓘ icon button that shows a tooltip/explanation |
| LocalAiSetupSheet | `local_ai_setup_sheet.dart` | Bottom sheet to configure Ollama/LM Studio endpoint |
| PesoScreenTip | `peso_screen_tip.dart` | Contextual tip card shown by Peso once per session per screen |

---

## Database Schema

**SQLite file:** `smartspend.db` (via `sqflite`)  
**Current schema version:** 17

### Core Tables

#### `expenses`
Columns: `id` (PK), `date` TEXT, `category` TEXT, `amount` REAL, `note` TEXT, `item_name` TEXT, `time` TEXT, `payment_method` TEXT DEFAULT 'Cash', `shop_name` TEXT, `location` TEXT, `ai_generated` INT DEFAULT 1, `confidence_score` REAL DEFAULT 1.0, `notes` TEXT, `updated_at` TEXT, `photo_path` TEXT, `is_want` INT DEFAULT 0, `tags` TEXT, `split_with` TEXT, `round_up_goal_id` INT, `round_up_amount` REAL DEFAULT 0, `wallet_id` INT, `deleted_at` TEXT (soft-delete; NULL = active, timestamp = deleted)

The `deleted_at` column enables the 30-day recycle bin. Soft-deleted rows are excluded from all queries except the "Recently Deleted" filter. A purge job removes rows where `deleted_at` is > 30 days ago.

#### `budgets`
Columns: `id` (PK), `category` TEXT UNIQUE, `amount` REAL, `is_percentage` INT DEFAULT 0, `percentage_value` REAL DEFAULT 0

Rollover credit is stored in `settings` as `budget_rollover_<category>` (amount) and `budget_rollover_credit_<category>` (whether enabled). Applied automatically on month boundary.

#### `income`
Columns: `id` (PK), `title` TEXT, `amount` REAL, `category` TEXT DEFAULT 'Salary', `date` TEXT, `is_recurring` INT DEFAULT 0, `is_windfall` INT DEFAULT 0, `notes` TEXT, `wallet_allocations` TEXT (JSON array: `[{walletId, amount}]`)

#### `savings_goals`
Columns: `id` (PK), `name` TEXT, `target_amount` REAL, `current_amount` REAL DEFAULT 0, `deadline` TEXT, `icon` TEXT DEFAULT 'savings', `color` INT DEFAULT 4280391411, `created_at` TEXT, `start_date` TEXT, `purpose` TEXT

#### `recurring`
Columns: `id` (PK), `title` TEXT, `amount` REAL, `category` TEXT, `frequency` TEXT DEFAULT 'monthly', `next_date` TEXT, `is_expense` INT DEFAULT 1, `notes` TEXT, `start_date` TEXT

#### `debts`
Columns: `id` (PK), `title` TEXT, `person` TEXT, `amount` REAL, `paid_amount` REAL DEFAULT 0, `type` TEXT DEFAULT 'owe', `due_date` TEXT, `notes` TEXT, `created_at` TEXT, `interest_rate` REAL

#### `installment_plans`
Columns: `id` (PK), `title` TEXT, `provider` TEXT, `total_amount` REAL, `monthly_payment` REAL, `months_total` INT, `months_paid` INT DEFAULT 0, `due_day` INT DEFAULT 5, `interest_rate` REAL, `start_date` TEXT, `category` TEXT DEFAULT 'Bills', `notes` TEXT, `created_at` TEXT, `credit_balance` REAL DEFAULT 0, `payment_schedule_json` TEXT (overrides `monthly_payment` per period when set)

#### `installment_schedule`
Per-period payment schedule rows.  
Columns: `id` (PK), `plan_id` INT, `period_index` INT, `due_date` TEXT, `amount_due` REAL, `amount_paid` REAL DEFAULT 0, `credit_applied` REAL DEFAULT 0, `status` TEXT DEFAULT 'pending', `updated_at` TEXT

#### `installment_payments`
Individual payment ledger.  
Columns: `id` (PK), `plan_id` INT, `schedule_id` INT, `amount` REAL, `payment_date` TEXT, `payment_method` TEXT, `notes` TEXT, `expense_id` INT, `created_at` TEXT

#### `wallets`
Columns: `id` (PK), `name` TEXT, `type` TEXT DEFAULT 'cash', `balance` REAL DEFAULT 0, `icon` TEXT DEFAULT '💵', `updated_at` TEXT, `last_verified_balance` REAL, `last_verified_at` TEXT

Default seed (fresh install): Cash on Hand (💵) + GCash (📱), both at ₱0.

#### `wallet_history`
Columns: `id` (PK), `wallet_id` INT, `wallet_name` TEXT, `old_balance` REAL, `new_balance` REAL, `delta` REAL, `reason` TEXT, `source` TEXT DEFAULT 'manual', `timestamp` TEXT

#### `investments`
Columns: `id` (PK), `name` TEXT, `type` TEXT, `ticker` TEXT, `shares_or_units` REAL DEFAULT 0, `buy_price` REAL DEFAULT 0, `current_price` REAL DEFAULT 0, `buy_date` TEXT, `notes` TEXT

#### `net_worth_assets`
Columns: `id` (PK), `name` TEXT, `value` REAL, `category` TEXT, `date` TEXT

#### `prices` (Price Intelligence)
Columns: `id` (PK), `product_name` TEXT, `store_name` TEXT, `price` REAL, `date` TEXT, `category` TEXT, `expense_id` INT, `created_at` TEXT

#### `price_cache`
Columns: `id` (PK), `source` TEXT, `commodity` TEXT, `price_min` REAL, `price_max` REAL, `unit` TEXT DEFAULT 'per liter', `fetched_at` TEXT, `period_label` TEXT

Used by `PsaService` (source='psa', TTL 30 days) and `DoeService` (source='doe', TTL 7 days).

### History / Audit Tables

| Table | Purpose |
|-------|---------|
| `chat_history` | AI conversation messages (`role`, `message`, `timestamp`, `session_id`) |
| `chat_sessions` | Chat session archive (`title`, `created_at`, `archived_at`, `is_current`) |
| `conversation_summaries` | Compressed chat history for context efficiency |
| `score_history` | FHS snapshots over time (`score`, `date`, `reason`) |
| `budget_history` | Budget set/delete history with old/new amounts |
| `goal_contribution_history` | Savings goal contributions and reversals |
| `income_history` | Declared monthly income changes (not individual income entries) |
| `wallet_history` | Every wallet balance change with source |
| `scan_history` | Barcode scan log |
| `mood_log` | Daily mood check-ins (`date` UNIQUE, `mood_score`, `note`) |

### Lookup / Config Tables

| Table | Purpose |
|-------|---------|
| `settings` | Key-value store (`key` TEXT PK, `value` TEXT) — persists all user preferences |
| `custom_categories` | User-defined categories (`name` UNIQUE, `icon`) |
| `category_rules` | Auto-categorization keyword rules (`keyword`, `category`, `created_at`) |
| `user_profile` | Local copy of profile (`uid` PK, `first_name`, `last_name`, etc.) |
| `recurring_candidates` | AI-detected subscription patterns pending user confirmation |

### Key `settings` Keys

| Key | Purpose |
|-----|---------|
| `active_model` | Last selected AI model ID |
| `monthly_income` | Declared monthly income |
| `income_frequency` | `monthly` / `bi-monthly` / `weekly` |
| `local_only_mode` | `true` = never fall back to cloud AI |
| `custom_local_url` / `model` / `key` | Local LLM endpoint config |
| `taxpayer_type` | `non_vat` / `vat` / `professional` / `mixed_income` |
| `app_theme` | Color theme name |
| `locale` | `en` / `tl` / `ceb` |
| `show_proactive_nudges` | Boolean |
| `spending_limit` / `spending_limit_period` | Daily/weekly/monthly/yearly cap |
| `income_wallet_mode` | Whether to show wallet tracking (vs lightweight mode) |
| `rollover_applied_month` | Last month rollover was auto-applied (yyyy-MM) |
| `budget_rollover_<cat>` | Rollover credit amount per category |
| `is_want_migrated` / `item_name_sanitized` / `education_need_fixed` | One-time migration flags |

---

## AI System

### Available Models (19 total, ordered best → fallback)

| Tier | ID | Label | API Name | Provider | isVision | isFast |
|------|----|----|--------|----------|---------|--------|
| Special | `auto` | Auto (Recommended) | — | Smart routing | — | — |
| Special | `custom_local` | Local AI | user-configured | Ollama/LM Studio | false | false |
| Tier 1 | `or_nemotron_ultra` | Nemotron 3 Ultra | nvidia/nemotron-3-ultra-550b-a55b:free | OpenRouter | false | false |
| Tier 1 | `or_llama33` | Llama 3.3 70B | meta-llama/llama-3.3-70b-instruct | OpenRouter | false | false |
| Tier 1 | `gemini_flash` | Gemini 3.5 Flash | gemini-3.5-flash | Gemini | **true** | false |
| Tier 1 | `gemini_flash_lite` | Gemini 3.5 Flash-Lite ⭐ | gemini-3.5-flash-lite | Gemini | **true** | **true** |
| Tier 2 | `or_gemma_4_31b` | Gemma 4 31B | google/gemma-4-31b-it:free | OpenRouter | false | false |
| Tier 2 | `or_nemotron_lightning` | Nemotron 3.5 Lightning | nvidia/nemotron-3.5-lightning:free | OpenRouter | false | **true** |
| Tier 2 | `or_qwen38` | Qwen 3.8 27B | qwen/qwen3.8-27b | OpenRouter | **true** | false |
| Tier 2 | `groq_llama4_scout` | GPT-OSS 120B | openai/gpt-oss-120b | Groq | false | false |
| Tier 3 | `or_nemotron_super_vl` | Nemotron 3.5 Super VL | nvidia/nemotron-3.5-super-vl:free | OpenRouter | **true** | false |
| Tier 3 | `or_gemma_4_26b` | Gemma 4 26B A4B | google/gemma-4-26b-a4b-it:free | OpenRouter | false | false |
| Tier 3 | `or_nemotron_nano` | Nemotron Nano 30B | nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free | OpenRouter | false | false |
| Tier 3 | `groq_kimi_k2` | Qwen3.6 27B | qwen/qwen3.6-27b | Groq | **true** | false |
| Tier 3 | `groq_qwen3` | Qwen3.8 27B | qwen/qwen3.8-27b | Groq | **true** | false |
| Tier 4 | `groq_70b` | Compound | groq/compound | Groq | false | **true** |
| Tier 4 | `groq_8b` | Compound Mini | groq/compound-mini | Groq | false | **true** |
| Tier 4 | `openrouter` | OpenRouter Gateway (Legacy) | nvidia/nemotron-3-ultra-550b-a55b:free | OpenRouter | false | false |
| Tier 5 | `cerebras_120b` | GPT-OSS 120B (Cerebras) | gpt-oss-120b | Cerebras | false | false |

**Vision models** (isVision=true): automatically selected for OCR receipt parsing.  
**Fast models** (isFast=true): automatically selected for voice command input.

### Auto-Mode Fallback Chain (best → worst)

```
or_nemotron_ultra → or_llama33 → or_gemma_4_31b → or_nemotron_lightning →
or_qwen38 → or_nemotron_nano → or_nemotron_super_vl → or_gemma_4_26b →
gemini_flash → gemini_flash_lite → groq_kimi_k2 → groq_qwen3 →
groq_70b → groq_8b → cerebras_120b
```

Each step is tried on 401, 403, or 429 status codes. The chain walk is session-only and resets after a successful response (`resetAutoChain()`). Up to 16 retry attempts per request.

### API Keys: Where They Live

| Provider | Remote Config Key | Compile-time Fallback |
|----------|------------------|----------------------|
| Groq | `groq_api_key` | Hardcoded in `app_config.dart` (not in git) |
| Gemini | `gemini_api_key` | Empty (Gemini skipped if no key) |
| Cerebras | `cerebras_api_key` | Hardcoded in `app_config.dart` |
| OpenRouter | `openrouter_api_key` | `--dart-define=OPENROUTER_API_KEY=sk-or-v1-...` at build time |

**Gemini key format note:** Since May 28, 2026, all new Google AI Studio keys start with `AQ.` (not `AIza...`). AQ. keys are permanent and do not expire.

### AI Action Allowlist

The AI can execute 34 action types in `'chat'` source context. In `'import'` context (OCR/batch screenshot/bank CSV), only these 4 are allowed:
- `log_expense`
- `log_multiple_expenses`
- `update_expense`
- `tag_expense`

This prevents prompt injection from malicious receipt text triggering `delete`, `set_income`, or other state-changing actions.

### Daily Usage Limit

`AIChatService` enforces a 150-message/day cap (tracked in `SharedPreferences`). The cap resets at UTC midnight. Remaining count is surfaced in the AI screen.

### Local AI Mode

Users can configure their own LLM endpoint (Ollama, LM Studio, Jan) in Settings → AI → Local AI:
- **URL:** e.g., `http://192.168.1.5:11434/v1`
- **Model:** e.g., `qwen3:7b`
- **Key:** usually blank for Ollama

When `local_only_mode = true`, the app never falls back to cloud even if the local server is unreachable. This maintains the "data never leaves your network" guarantee.

---

## Localization

### Supported Languages

| Locale | File | Status |
|--------|------|--------|
| English | `lib/l10n/app_en.arb` | Template (190 keys) |
| Tagalog (Filipino) | `lib/l10n/app_tl.arb` | Complete (190 keys) |
| Cebuano (Bisaya) | `lib/l10n/app_ceb.arb` | Complete (190 keys) |

### Setup

The localization system uses Flutter's standard `flutter_localizations` + `intl` ARB workflow:
- Template: `app_en.arb` (declared in `l10n.yaml`)
- Generated output: `lib/l10n/app_localizations.dart` + per-locale delegates
- Generation command: `flutter gen-l10n`

The user selects a language in Settings; the choice persists in the `locale` settings key and is applied on restart via `MaterialApp.locale`.

### How to Add a New Language

1. Copy `lib/l10n/app_en.arb` to `lib/l10n/app_<code>.arb` (e.g., `app_es.arb`).
2. Replace every value string with the translation. Keep all keys identical.
3. Update `l10n.yaml` if needed (it only needs `arb-dir` and `template-arb-file` — no per-locale listing required).
4. Add the new locale to `supportedLocales` in `main.dart`.
5. Add a locale option to the language selector in `settings_screen.dart`.
6. Run `flutter gen-l10n` to regenerate `app_localizations.dart`.
7. Rebuild.

---

## Release Process

### Versioning

Version is declared in `pubspec.yaml` as `version: X.Y.Z+BUILD` (e.g., `3.5.8+136`). The semantic portion (`X.Y.Z`) is `kAppVersion` in code (now read dynamically via `package_info_plus` — no more hardcoded `kAppVersion`). The build number increments with every release.

To release a new version:
1. Update `version` in `pubspec.yaml`.
2. Commit and tag: `git tag v3.5.9 && git push origin v3.5.9`
3. GitHub Actions triggers `release.yml` automatically on a `v*.*.*` tag.

### GitHub Actions CI Workflows

**`.github/workflows/analyze.yml`** — runs on every push/PR to `master`:
1. Set up Flutter 3.41.6 (stable)
2. Use committed `app_config.dart` as-is (has empty keys but correct signatures); fall back to `app_config.dart.example` if missing
3. `flutter pub get`
4. `flutter test --no-pub`
5. `flutter analyze --no-fatal-infos --no-fatal-warnings`

**`.github/workflows/release.yml`** — runs on `v*.*.*` tag push:
1. Set up Java 17 + Flutter 3.41.6
2. Decode `KEYSTORE_BASE64` → `android/app/smartspend-release.jks`
3. Decode `KEY_PROPERTIES` → `android/key.properties`
4. Decode `GOOGLE_SERVICES_JSON` → `android/app/google-services.json`
5. Decode `APP_CONFIG_DART_A + APP_CONFIG_DART_B` → `lib/services/app_config.dart` (split into 2 secrets because the file exceeds GitHub's 48 KB base64 secret limit)
6. `flutter pub get`
7. Build 3 release APKs (`--split-per-abi --shrink --obfuscate --split-debug-info --dart-define=APP_FLAVOR=prod`)
8. Build AAB for Google Play
9. Create GitHub Release with versioned APK filenames + stable `SmartSpend-latest-*.apk` aliases

### Required GitHub Secrets

| Secret | Contents |
|--------|---------|
| `KEYSTORE_BASE64` | Base64-encoded `smartspend-release.jks` |
| `KEY_PROPERTIES` | Base64-encoded `android/key.properties` with store/key passwords and alias |
| `GOOGLE_SERVICES_JSON` | Base64-encoded `android/app/google-services.json` |
| `APP_CONFIG_DART_A` | First half of base64-encoded `lib/services/app_config.dart` |
| `APP_CONFIG_DART_B` | Second half of base64-encoded `lib/services/app_config.dart` |
| `GITHUB_TOKEN` | Auto-provided by GitHub Actions |

### How to Regenerate APP_CONFIG_DART_A / B Secrets (PowerShell)

```powershell
$bytes = [IO.File]::ReadAllBytes("lib/services/app_config.dart")
$b64   = [Convert]::ToBase64String($bytes, [Base64FormattingOptions]::None)
$half  = [Math]::Ceiling($b64.Length / 2)
$b64.Substring(0, $half) | gh secret set APP_CONFIG_DART_A
$b64.Substring($half)    | gh secret set APP_CONFIG_DART_B
```

Requires `gh` CLI authenticated to the repo.

### Firebase Remote Config Keys

| Key | Purpose |
|-----|---------|
| `groq_api_key` | Groq API key (rotates without code change) |
| `gemini_api_key` | Google AI Studio key (AQ. prefix, May 2026+) |
| `cerebras_api_key` | Cerebras API key |
| `openrouter_api_key` | OpenRouter key (sk-or-v1-..., $100 credit, expires May 14, 2027) |

Update these in Firebase Console → Remote Config. The app fetches them on startup; a 5-minute minimum interval applies on cold start.

---

## Developer Setup

### Prerequisites

| Tool | Required Version | Notes |
|------|----------------|-------|
| Flutter | 3.41.6 (stable) | `flutter channel stable && flutter upgrade` |
| Dart | Included with Flutter | ≥3.0.0 |
| Java JDK | 17 | Required by Gradle |
| Android SDK | API 33+ target, API 36 recommended | Via Android Studio |

### Local Dev Setup (Step by Step)

**1. Clone**
```bash
git clone https://github.com/Zushikina-kun/smartspend-app.git
cd smartspend-app
```

**2. Add Firebase config (not in git)**
```
android/app/google-services.json  ← download from Firebase Console
```
Package name: `com.lucidframe.smartspend_app`

**3. Add app_config.dart (not in git)**
```bash
cp lib/services/app_config.dart.example lib/services/app_config.dart
```
Then fill in at minimum the Groq key. Get a free key at https://console.groq.com.

**4. Add keystore (for release builds only)**
```
android/app/smartspend-release.jks   ← get from Brix
android/key.properties               ← see HOWTORUN.md for format
```

**5. Install dependencies**
```bash
flutter pub get
```

**6. Run (debug)**
```bash
flutter run --dart-define=APP_FLAVOR=dev
```
`APP_FLAVOR=dev` unlocks all Pro features for testing. Omitting it also defaults to dev behavior.

**7. Build release APK**
```bash
flutter build apk --release --split-per-abi --shrink --obfuscate \
  --split-debug-info=build/debug-info --dart-define=APP_FLAVOR=prod
```
Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (and armeabi-v7a, x86_64).

### Gitignored Files That Must Exist Locally

| File | How to Get |
|------|-----------|
| `lib/services/app_config.dart` | Copy `.example`; fill in keys |
| `android/app/google-services.json` | Download from Firebase Console |
| `android/app/smartspend-release.jks` | Get from Brix (do not regenerate — loses Play Store signing) |
| `android/key.properties` | Create manually (see HOWTORUN.md) |

### Adding a New AI Model

1. Add a constant for the model's API name in `app_config.dart` (e.g., `static const _newModel = 'provider/model-id'`).
2. Add an entry to `availableModels` list with `(id, label, description, isVision, isFast)`.
3. Add a `case 'new_model_id':` in `_modelNameFor()`, `_baseUrlFor()`, and `_apiKeyFor()`.
4. Add to the `_autoFallbackChain` list at the appropriate priority.
5. Add to the `autoFallback()` switch-case chain.
6. Regenerate CI secrets (steps above).

### Adding a New DB Table (with Migration)

1. Add a `CREATE TABLE IF NOT EXISTS` block in `DBService._ensureColumns()` (runs on every app open — idempotent).
2. If the table needs to exist before `_ensureColumns` runs, also add it to `_createTables()` and increment `version:` in `openDatabase()`.
3. Add a migration block: `if (oldVersion < N) { ... }` for the new version.
4. Add any new columns to the `_ensureColumns` ALTER TABLE block so existing installs get them without a full migration.

### Adding a New Language

1. Copy `lib/l10n/app_en.arb` → `lib/l10n/app_<code>.arb` and translate all values.
2. Add the locale to `supportedLocales` in `main.dart`.
3. Add a language option in `settings_screen.dart` → language selector.
4. Run `flutter gen-l10n`.
5. Rebuild.

---

## Tax System

### Taxpayer Types

| Type | Deadlines |
|------|----------|
| `non_vat` (default) | Q1–Q4 2551Q (Percentage Tax) + Annual ITR (Apr 15) |
| `vat` | Q1–Q4 2550Q (VAT Return, 25th of month after quarter) + Annual ITR |
| `professional` | Q1–Q4 2551Q + Q1–Q4 1701Q (Quarterly ITR) + Annual ITR |
| `mixed_income` | Same as `professional` |

Deadlines that have already passed are rolled forward one year. Notifications are scheduled at 30, 7, and 1 day before each deadline.

### Tax Filing History (v3.5.8)

A `tax_filings` table tracks whether each deadline was actually filed:  
Columns: `id`, `period_label`, `deadline_date`, `filed_date`, `amount_paid`, `reference_number`, `notes`, `taxpayer_type`

The Tax screen shows each upcoming deadline with a "Mark as Filed" button. Past filings display a checkmark.

### Income Tax Estimator

`TaxReminderService.estimateIncomeTax(annualIncome)`:
- Income ≤ ₱250,000: Tax Exempt
- Income ₱250,001–₱3,000,000: Returns lower of 8% flat rate or graduated rates
- Income > ₱3,000,000: Graduated rate only

Graduated brackets (TRAIN Law):
| Excess over | Base tax | Rate |
|------------|---------|------|
| ₱250,000 | 0 | 15% |
| ₱400,000 | ₱22,500 | 20% |
| ₱800,000 | ₱102,500 | 25% |
| ₱2,000,000 | ₱402,500 | 30% |
| ₱8,000,000 | ₱2,202,500 | 35% |

---

## Known Remaining Work

These items were audited but NOT shipped in v3.5.8. They come from `.agents/tasks/feature-audit/comprehensive-audit.md`.

### Next Sprint — Medium effort items

| # | Gap | Feature | Issue |
|---|-----|---------|-------|
| R-1 | Recurring | No skip/pause per period; limited frequency options (no biweekly, quarterly, every-N-days) | High severity |
| A-1 | Analytics | No year-over-year comparison mode (same month last year) | Medium |
| G-2 | Goals | No scheduled monthly contribution target / auto-log | Medium |
| R-2 | Recurring | No execution history table (recurring_log) linking recurring entries to their generated expenses | Medium |
| N-1 | Net Worth | Monthly snapshot gated to 1st — if app not opened on 1st, no snapshot | Medium |
| N-3 | Net Worth | Asset value changes not tracked historically (manual edit overwrites, no history) | Medium |
| P-2 | Prices | Price alert has no background notification — fires only on screen open | Medium |
| D-2 | Debt | Debt payment history not persisted per individual payment | Medium |
| E-3 | Expenses | No field-level edit history / audit trail for expense edits | Medium |
| B-1 | Budgets | Strictly monthly — no weekly or custom-period budgets | Medium |
| E-2 | Expenses | No expense split across categories/payment methods (one receipt = three entries problem) | High, Large effort |
| B-2 | Budgets | No sub-category budget hierarchy (Food → Groceries + Dining Out) | Medium, Large effort |
| INV-1 | Investments | Manual-only price updates, no price history table | Medium, Large effort |

### Backlog — Low severity

| # | Gap | Feature | Issue |
|---|-----|---------|-------|
| B-4 | Budgets | No warning when backdating expense affects current budget period |
| A-2 | Analytics | Category comparison baseline not configurable (3-month avg, YoY dropdown) |
| PAL-1 | Paluwagan | Fixed contribution per round — no per-member variable amounts |

### Architecture Gaps (not in audit, inferred)

- **SMS MethodChannel not wired:** `SmsParserService` and `NotificationListenerService` are hidden behind `kDebugMode` because the Android-side MethodChannel (`com.smartspend/sms`) is not implemented in `MainActivity.kt`. When ready to ship, implement the MethodChannel, remove the debug gate, and enable the SMS Auto-sync toggle in Settings.
- **RevenueCat not integrated:** `ProService` returns `isPro=true` for everyone. The freemium gates planned for v4.0 (RevenueCat SDK, `ProGate` widget) are not implemented.
- **App Check enforcement:** App Check is in monitoring/debug mode. Before Play Store submission, switch to `PlayIntegrityProvider` in `main.dart` and register the release SHA-256 in Firebase Console.
- **Investment live prices:** `investments.current_price` is manually updated. No background price feed exists; `InvestmentScreen` shows gain/loss against a potentially stale manual price.

---

## Recent Changes (v3.5.7 → v3.5.8)

**Version:** 3.5.7+135 → 3.5.8+136  
**Commits:** 22 commits (d086590 → f462a60)

### New Features

**Security / Auth:**
- **Email verification flow** (`EmailVerificationScreen`): After registration, users are prompted to verify email. Unverified users see a dismissible banner in `LoginScreen`.
- **Phone OTP verification** (`PhoneOtpScreen`): Firebase SMS OTP flow to verify/add a phone number in Profile.

**Wallet Integrity:**
- **Wallet-linked expenses:** Every expense can be linked to a wallet. `insertExpense` auto-debits; `deleteExpense` auto-reverses; `updateExpense` adjusts the delta.
- **Biometric lock on wallet edits:** Balance edits and snapshot restores require biometric / PIN confirmation via `AppLockService`.
- **Wallet audit / divergence indicator:** `last_verified_balance` and `last_verified_at` columns on `wallets`. UI shows a divergence indicator when current balance differs from last verification. "Restore to snapshot" action available.

**Flexible Installment Schedules:**
- `payment_schedule_json` column on `installment_plans` overrides `monthly_payment` per period for variable-amount BNPL (ShopeePayLater promo months, etc.).
- Overpayment credit carry-forward: excess payment this period reduces next period's due amount via `credit_balance`.
- Full payment ledger in `installment_schedule` and `installment_payments` tables.

**Tax System:**
- **Taxpayer type selector** in Tax screen header (non-VAT / VAT / professional / mixed-income).
- **VAT and professional deadlines:** `TaxReminderService.getUpcomingDeadlines()` now accepts `taxpayerType` parameter with correct deadline sets per type.
- **Tax filing history** (`tax_filings` table): "Mark as Filed" button on each deadline; past filings show checkmark and reference number.

**15 Audit Fixes (from comprehensive-audit.md "Ship Now" items):**
- T-3 (Critical): Fixed BIR Q4/Annual ITR deadline year double-increment — was showing 2027 dates in January–April.
- N-2 (Critical): Installment plan remaining balances now included in Net Worth liabilities calculation.
- B-3 (High): Budget rollover credit now auto-applied on month boundary (checks `rollover_applied_month` setting vs current month).
- G-3 (High): Savings goal edit dialog protects current_amount — "Already Saved" field is read-only when editing; separate Adjust/Withdraw action with confirmation required.
- E-4 (High): Bulk expense delete now fully undoable — `UndoService` extended to `delete_expense_batch` type with `ids: List<int>`.
- G-1 (High): Round-up contribution reversed when triggering expense is deleted (`round_up_goal_id` + `round_up_amount` on expense; `deleteExpense` reads and reverses).
- I-1 (High): Individual income entries now have audit history; delete is logged; undo window extended.
- I-2 (High): Income entries support wallet allocation split (`wallet_allocations` JSON on income row); `insertIncome` updates wallets accordingly.
- T-1 (High): `getUpcomingDeadlines()` accepts `taxpayerType` — VAT-registered users now get correct 2550Q deadlines.
- T-2 (High): `tax_filings` table + filing history UI.
- D-1 (High): `payment_schedule_json` on installment plans — variable per-period amounts.
- E-1 (High): `deleted_at` column on expenses enables 30-day soft-delete recycle bin.
- I-3 (Medium): Income entries now editable — `DBService.updateIncome()` added; IncomeScreen shows edit icon.
- A-3 (Medium): Analytics CSV export now scoped to current chart period (not all-time).
- P-1 (Medium): Per-product price trend `LineChart` added in `PriceIntelligenceScreen`.
- P-3 (Medium): Manual price entry FAB added to `PriceIntelligenceScreen._ProductsTab`.
- R-3 (Medium): Recurring "Log All Due" now loops until `next_date > now` (catches multi-month overdue).

### Bug Fixes

- Controller disposal memory leaks fixed in installment screen.
- Restore snapshot correctly re-applies wallet and goal reversals.
- Soft-deleted expense tombstones are purged from Firestore cloud on 30-day cleanup.
- Deduplication logic excludes soft-deleted rows.
- Composite primary key on `tax_filings` prevents duplicate filing records.
- UI filed-status lookup uses correct composite key.
- Amount validation added to tax filing form.

---

## Configuration Reference

### Firebase Project

| Setting | Value |
|---------|-------|
| Android package | `com.lucidframe.smartspend_app` |
| Firebase project | SmartSpend (Lucid Frame) |
| Auth providers | Email/Password, Google Sign-In, Phone |
| Firestore collections | `users/{uid}` (profile + settings + expenses + budgets + goals + income + recurring + debts + wallets + installments) |
| Crashlytics | Enabled in release builds |
| App Check | Debug/monitoring mode (switch to PlayIntegrity before Play Store) |

### SHA Fingerprints Registered in Firebase

| Type | SHA-1 |
|------|-------|
| Release | `9E:2E:EE:E5:0A:9D:80:66:4E:79:DF:22:8E:B9:79:8A:E0:C7:F2:28` |
| Debug (machine 1) | `40:B2:1D:58:7A:95:93:55:6D:A2:B0:5A:22:43:D4:1B:D0:C0:D6:62` |
| Debug (machine 2 — Brix) | `4D:1C:67:D4:78:7A:30:20:6D:5B:D5:97:6E:F6:EF:87:3D:91:12:E8` |

For Google Sign-In on a new dev machine, generate your debug SHA-1 and add it in Firebase Console → Project Settings → Android app → Add fingerprint, then re-download `google-services.json`.

### Key External APIs

| API | URL | Auth | Usage |
|-----|-----|------|-------|
| Groq | `https://api.groq.com/openai/v1/chat/completions` | Bearer (gsk_...) | Primary AI (1,000 req/day free) |
| Gemini | `https://generativelanguage.googleapis.com/v1beta/openai/chat/completions` | Bearer (AQ...) | Best quality AI if key provided |
| Cerebras | `https://api.cerebras.ai/v1/chat/completions` | Bearer (csk_...) | Last-resort AI (1M tokens/day) |
| OpenRouter | `https://openrouter.ai/api/v1/chat/completions` | Bearer (sk-or-v1-...) | Multi-model gateway (50 free req/day, or 1000/day with $10 credit) |
| Exchange rates | `https://open.er-api.com/v6/latest/PHP` | None | Live FX rates, 57 currencies |
| PSA Open Data | `https://openstat.psa.gov.ph/PXWeb/api/v1/en` | None | Rice/commodity retail prices |
| DOE fuel prices | `https://www.doe.gov.ph/...` | None | Fuel price scrape (HTML) |

### Build Flags

| Flag | Usage | Effect |
|------|-------|--------|
| `--dart-define=APP_FLAVOR=dev` | Local dev | ProService.isPro = true; debug gates open |
| `--dart-define=APP_FLAVOR=prod` | CI release builds | ProService reads real entitlement (placeholder until v4.0) |
| `--dart-define=OPENROUTER_API_KEY=sk-or-v1-...` | Build with OR key baked in | Compile-time fallback for OpenRouter |

### Flutter Asset Files

| Asset | Purpose |
|-------|---------|
| `assets/logo.png` | SmartSpend logo |
| `assets/LucidFrameLogo.png` | Team logo |
| `assets/LormaLogo.jpg` | University logo |
| `assets/ph_banks.json` | Philippine banks data for `BankComparisonScreen` |
| `assets/Devs/*.png` | Developer profile photos for About screen |

---

*Last updated: v3.5.8+136 — Lucid Frame / Lorma Colleges CCSE*
