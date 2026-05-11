# Smart Spend — Final Status Report

**Build Date:** May 11, 2026
**Version:** 2.6.0
**APK:** ~44.0 MB (arm64-v8a) — May 11, 2026
**Status:** ✅ **COMPLETE** — Zero errors, all sync/data-safety issues resolved

---

## ✅ Session 12 — Full Cloud Sync Audit & Fixes (v2.6.0)

**Build:** May 11, 2026 — 44.0 MB arm64-v8a

### Sync Fixes (Data Safety)
- **Wallets fully synced** — `setWalletBalance`, `insertWallet`, `deleteWallet` now call `CloudService.pushDoc/deleteDoc`; wallets included in `pullAll`, `pushAll`, `SyncData`, `syncFromCloud`, `pushAllToCloud`; backup export + restore; `clearLocalData` now deletes rows (not zeros) so they restore cleanly from Firestore
- **Category rules fully synced** — `insertCategoryRule` and `deleteCategoryRule` now push to Firestore; added to `pullAll`, `pushAll`, `SyncData`, `syncFromCloud`, `pushAllToCloud`, and backup restore
- **Reset All Data fixed** — now clears all 14 tables (was only 6) AND pushes empty state to Firestore so data doesn't resurrect on next login
- **Demo data isolation** — `DemoService._isDemoLoading` flag added; `CloudService._shouldSkipSync` checks it; demo data never reaches Firestore even when a real user is logged in; `clearDemoData()` now wipes Firestore if a real user is logged in
- **Backup restore syncs to cloud** — `BackupService.restoreFromFile()` now calls `DBService.pushAllToCloud()` after all data is restored
- **Setup onboarding syncs** — `SetupScreen._finish()` now calls `pushAllToCloud()` after setup completes; new device login now works correctly
- **Register screen** — `_syncAfterRegister()` clears demo data if `was_demo_mode` was set before registration

### Logout Cleanup Fixes
- `installments` (old table) — now deleted in `clearLocalData()`
- `recurring_candidates` — now deleted in `clearLocalData()`
- `last_recurring_check` — now reset on logout
- Notification throttle keys (`last_weekly_notif`, `last_anomaly_check`, `last_velocity_check`, `last_want_alert`, `last_daily_briefing`) — all reset on logout so new accounts get first-day notifications

### Sync Event Fixes
- `syncFromCloud` now fires `AppEvent.goalChanged` after merging goals (was missing)

### Settings Sync Fixes
- `daily_limit`, `payday_date`, `manual_assets` added to `pushAllToCloud` settings sync list

### Undo Fixes
- `UndoService` `update_expense` case — now calls `CloudService.pushDoc` after restoring (was raw `db.update` with no Firestore sync)
- `ai_screen` `update_expense` action — now records undo snapshot BEFORE applying the change (was never recorded, making shake-to-undo silently do nothing for expense edits)

### Logic Fixes
- `renameExpenseCategory()` — now pushes all affected expense documents to Firestore after bulk rename
- `achievements_screen` `budget_boss` badge — now correctly resolves percentage-based budgets (was using `b.amount` which is 0 for % budgets)

### Security / Code Quality
- Groq API key centralized in `AppConfig` (`lib/services/app_config.dart`)
- Both `AIChatService` and `LLMService` now reference `AppConfig` instead of hardcoded strings
- `app_config.dart` added to `.gitignore`
- `app_config.dart.example` created for new developers

### Documentation
- `README.md` — updated to v2.6.0, added HOWTORUN.md and KIRO_CONTEXT.md references
- `HOWTORUN.md` — new file: full setup, run, and build instructions
- `KIRO_CONTEXT.md` — new file: complete architecture reference for AI assistant
- `DOCUMENTATION.md` — updated to v2.6.0, sync section updated
- `whats_new_screen.dart` — bumped to v2.6.0 with 11 new sync/fix entries
- `about_screen.dart` — bumped to v2.6.0, tech stack updated
- `help_screen.dart` — new "Cloud Sync & Data Safety" section added
- `pubspec.yaml` — bumped to 2.6.0+1



---

## ✅ Everything Fixed (Complete List)

### Session 1 — Core QA Fixes
- Radio/RadioListTile deprecated → custom icon tiles
- All hardcoded `Color(0xFF0066FF)` → theme-aware (12 screens)
- Budget screen currency format → `CurrencyService`
- Analytics income dialog → account-type aware title
- Tax card hidden for students/unemployed → Allowance Overview shown instead
- Profile tax row hidden for students/unemployed
- Forgot Password added to login
- Recurring detail dialog → human-readable dates
- Savings goals snackbar → fires on correct context
- `_loadingInsight` flicker fixed
- Chat history pull-to-refresh added
- Today's Spending card added to Home
- Account type change → fires event, all screens refresh
- Google button broken image hack removed
- Recurring start date shown in list + next due date picker added
- Monthly bar chart respects period filter
- Nav bar uses theme colors
- Budget nested dialog uses main context
- `syncFromCloud` fires events after sync

### Session 2 — Account Isolation & Mitigations
- **Account isolation** — logout clears local DB after cloud push
- **Demo isolation** — `was_demo_mode` flag prevents bleed on next login
- FAB keyboard overlap fixed in AI chat
- AI write actions require confirmation dialog
- AI language detection strengthened for Taglish
- **D2** — Groq API daily cap (60 msg/day) + remaining count in appbar
- **D4** — Last-write-wins sync via `updated_at` timestamp
- **D7** — This month vs last month category comparison table
- **D8** — Time-aware budget hints (day X of Y, pace indicators)
- **D9** — Pie chart drilldown (tap legend → see transactions)
- **D10** — Income frequency editable in Profile
- **D11** — Health score uses income-relative thresholds

### Session 32 — Scanner Improvements

**OCR noise filter fixed** — was accidentally removing valid price lines matching `^\d{10,}$` (e.g. barcode numbers with prices). Changed to only filter lines with 15+ pure digits.

**Better OCR error messages** — when no text is detected, now shows specific tips: ensure good lighting, hold steady, keep receipt flat, make sure text is in focus.

**OCR quality check** — if extracted text has fewer than 5 words or no numbers, prepends "[Low quality scan — edit before sending]" so user knows to review carefully before sending to AI.

**Receipt mode toggle** — new button in scanner AppBar (receipt icon). Switches the detection guide from 260×260 square (barcode mode) to 220×360 tall rectangle (receipt mode) with amber color. Status hint updates to "Receipt mode — tap shutter to capture".

**Barcode repeat detection** — when a barcode is scanned, checks scan_history to see if it was scanned before. If yes, adds "[Scanned X times before]" hint in the review screen so user knows it's a repeat item.

**Build:** May 3, 2026 — 5:59 PM (44.72 MB arm64-v8a)

**About screen** — added 5 missing features to the feature list:
- FHS Component Breakdown, Spending Forecast, Weekly Behavioral Summary, Anomaly Detection, Onboarding Quiz

**Help screen** — added 4 new sections (25 total now):
- Spending Forecast — explains the formula and how to use it
- FHS Component Breakdown — explains each component's progress bar and how to improve
- Weekly Notifications — covers both Weekly Behavioral Summary and Anomaly Detection
- Onboarding Quiz — explains what it does and how to change answers later

**Notification rate-limiting fix** — `checkAnomalyDetection()` was being called on every app open. Fixed to only run on Sundays and only once per week (same pattern as weekly summary). Uses `last_anomaly_check` settings key.

**Build:** May 3, 2026 — 3:34 PM (44.72 MB arm64-v8a)

Also fixed in this session:
- Demo mode banner text updated: "data is not saved to an account" → "sign up to sync data across devices" (more accurate after splash fix)
- Home Dashboard help item updated to mention Spending Forecast card
- Defense reviewer: Things to Practice updated with new features, Key Numbers updated (Help sections: 25, Features: 36, Screens: 37+)

**#3 — Weekly AI Behavioral Summary (proactive notification)**
- Fires every Sunday alongside the existing weekly summary
- Shows: Savings Rate %, days over daily budget, logged days this week
- Example: "Savings Rate 38% · 2 days over daily budget · Logged 5/7 days"
- No AI call needed — pure local math from expense history

**#8 — Anomaly Detection Alerts (proactive weekly)**
- Checks every Sunday for unusual spending spikes by category
- Compares this week's spending to the 4-week average per category
- Fires if any category is 2.5x above its usual weekly amount
- Example: "You spent ₱1,200 on Transport this week — 3x your usual ₱400"
- Only one alert per week (most anomalous category)

**#7 — Onboarding Financial Quiz (Step 4 in setup wizard)**
- New 4th step added to setup wizard (4-dot progress bar)
- Q1: "What's your biggest financial challenge?" — 4 options (Overspending / Saving / Debt / Tracking)
- Q2: "I have regular bills" — checkbox
- Q3: "I want to build an emergency fund" — checkbox
- Auto-creates budgets based on challenge type (tighter for overspending, savings-focused for saving)
- Auto-creates Emergency Fund goal (3-month target) if requested
- Existing users not affected (only runs on first setup)

**#4 — FHS Component Breakdown Chart (Analytics)**
- New card in Analytics below the score history chart
- Shows all 4 components as horizontal progress bars (X/25 pts each)
- Color-coded: green ≥20, orange ≥12, red <12
- Has InfoButton explaining each component
- Updates in real-time with current period data

**Build:** May 3, 2026 — 10:38 AM (44.71 MB arm64-v8a)

**Bug Fix 1 — Demo data vanishes after app restart (critical)**
- Root cause: In demo mode (`user == null`), splash screen was routing to `LoginScreen` on every restart. Tapping "Try Demo" again wiped all data.
- Fix: `splash_screen.dart` now checks `was_demo_mode` flag. If true and `setup_done` is set, goes directly to `HomeScreen` — demo data persists across restarts.

**Bug Fix 2 — FHS shows 100/100 in demo (misleading)**
- Root cause: It's early in the month with minimal spending — score is mathematically correct but looks wrong.
- Fix 1: `demo_service.dart` now seeds 14 days of score history (72–83 range) so the Analytics chart shows a realistic trend.
- Fix 2: `clearDemoData()` now also clears `score_history`.

**New Feature — Spending Forecast card on Home**
- Shows which budget categories will be exceeded by month-end at current spending pace
- Formula: (spent so far ÷ days elapsed) × days in month = projected total
- Only appears when 3+ days of data exist and at least one category is projected to overspend
- Has InfoButton explaining the formula

**New Feature — FHS Score History Chart improvements (Analytics)**
- Colored dots: 🟢 green (80+), 🟡 orange (60–79), 🔴 red (<60)
- Reference lines at 60 (Fair) and 80 (Good) with labels
- Y-axis labels (0, 20, 40, 60, 80, 100)
- Legend below chart explaining dot colors
- InfoButton explaining what the chart shows

**Build:** May 3, 2026 — 9:28 AM (44.65 MB arm64-v8a)

Full codebase audit found and fixed 7 real issues:

**Fix 1 — Missing `date` field in score calculation (all callers)**
- `home_screen.dart`, `profile_screen.dart`, `ai_screen.dart` — all now pass `'date': e.date` in the expense map passed to ScoreService
- Without this, Component 4 (Logging Consistency) had no dates and always returned 100% consistency

**Fix 2 — Component 4 formula improvement**
- `score_service.dart` — `activeDays` now calculated as span from first expense date to today, not full month elapsed
- Fairer: if you started logging on day 20 and today is day 25, activeDays = 6, not 25

**Fix 3 — Demo data score too low (~27–42 with new formula)**
- `demo_service.dart` — income changed from ₱6,600 to ₱10,000 (working student: allowance + part-time)
- Expected demo score now: ~70–80 (Fair to Good range) ✓

**Fix 4 — Decay system ignored percentage-based budgets**
- `score_service.dart` — `checkAndUpdateDecay()` now calculates actual budget amount for percentage budgets before comparing

**Fix 5 — Daily limit date comparison fragile**
- `home_screen.dart` — now uses `DateTime.parse(e.date)` with try-catch fallback instead of direct string comparison

**Fix 6 — Transactions screen missing orphan categories**
- `transactions_screen.dart` — now includes categories from expenses that aren't in the current category list (e.g. deleted custom categories)

**Fix 7 — Installments table not guaranteed to exist**
- `db_service.dart` — installments table now created in both `_createTables()` and `_ensureColumns()` with `CREATE TABLE IF NOT EXISTS`

**Build:** May 2, 2026 — 11:34 PM (44.59 MB arm64-v8a)

**FHS formula completely rewritten** to match the paper's 4-component weighted formula (25 pts each):

| Component | What it measures | Formula |
|-----------|-----------------|---------|
| Savings Rate | Actual savings vs 20% of income target | 25 × min(1, savingsRate / 0.20) |
| Overspend Control | Days where spending stayed within daily budget | 25 × (1 − overDays / activeDays) |
| Budget Adherence | % of budget categories that stayed within limit | 25 × (onBudget / totalBudgets) |
| Logging Consistency | Regularity of expense entries vs active days | 25 × (loggedDays / activeDays) |

Final score = sum of 4 components, clamped 0–100. If no income set, partial credit given for components that require income.

**Warning decay system implemented:**
- If a budget is exceeded and spending continues the next day: −5 pts/day, max 3 days (−15 pts total)
- Decay resets automatically when all budgets return to on-track
- Stored in settings table as `warning_decay_days` (0–3)
- Checked once per day on app open via `ScoreService.checkAndUpdateDecay()`

**3-tier escalation notifications** (`NotificationService.showDecayWarning()`):
- Day 1: Gentle nudge — "Budget tip: consider adjusting spending"
- Day 2: Strong alert — spending comparison summary, mentions FHS impact
- Day 3: Critical warning — projected monthly overspend figure, −15 pts penalty noted

**Build:** May 2, 2026 — 11:01 PM (44.59 MB arm64-v8a)

**"Manual — just enter my total" frequency option** added to all account types in both the Setup wizard and Profile → income dialog.

**How it works:**
- User selects "Manual — just enter my total" from the frequency options
- Field label changes to "How much money do you have right now?"
- Helper text says "Stored as-is — no conversion"
- Amount is stored directly — no ×22 (daily), ×4.33 (weekly), or ×2 (bimonthly) conversion
- Used for: irregular income, current balance tracking, "I just have ₱5,000 right now" scenarios

**Shown first (default) for:** General / Other and Unemployed account types
**Available to all types** as the last option in the frequency list

**Build:** April 30, 2026 — 1:48 PM (44.59 MB arm64-v8a)

### Session 25 — UX Clarity Pass: Info Buttons, Cleaner Cards, Dynamic Filters

**New `InfoButton` widget** (`lib/widgets/info_button.dart`) — a small `?` icon that shows a clear explanation dialog when tapped. Used consistently across all screens so any user can understand any feature without leaving the app.

**Info buttons added to 13 screens/sections:**
- Home: Financial Health Score, Quick Log chips, Cash Flow card, AI Insights, Recent Transactions, Achievements row
- Analytics: full screen explanation (all charts, period filter, custom range)
- Budgets: how budgets work, progress bar colors, pace indicator, % mode
- Savings Goals: what a goal is, emergency fund shield icon
- Debts & Lending: I Owe vs Owed to Me, due dates, installment tracker
- Recurring Transactions: what recurring means, Log Now, Log All Due, presets
- Transactions: search, filters, multi-select, export
- Income: what to log, how income affects score, how to update declared income

**Budget screen improvements:**
- Empty state now explains what budgets do (not just "tap +")
- Budget cards show a `% of income` badge when budget is set in percentage mode
- Cleaner layout: "Spent: ₱X" and "Limit: ₱X" instead of "₱X / ₱X"
- Pace indicator text improved: "ahead of expected pace" / "under expected pace"

**Transactions screen fix:**
- Category filter now loads custom categories dynamically — was hardcoded to 8 built-in categories

**Quick Log label** — "Quick log" → "Quick Log" with info button explaining it shows most frequent expenses

**Build:** April 30, 2026 — 10:05 AM (44.59 MB arm64-v8a)

**Want/Need toggle made visible** — replaced plain chip row with a highlighted card showing current tag state prominently; color-coded (blue = Need, orange = Want) with description text; impossible to miss now

**Custom date range in Analytics** — added "Custom Range" chip with calendar icon to period filter; opens Flutter's built-in date range picker; selected range shown in chip label (e.g. "4/1–4/29")

**Daily Spending Trend chart** — new line chart in Analytics showing spending per day for the last 30 days; appears between monthly bar chart and health score chart; dots on each data point, filled area below line

**3 new account types added:**
- **Freelancer** — project-based income, flexible frequency options (weekly/bimonthly/monthly), full income category list
- **Pensioner / Retiree** — pension income, monthly/bimonthly options, Health budget prioritized in suggestions
- **General / Other** — full flexibility, no assumptions, all income categories, no tax card

**Dynamic income labels everywhere** — Profile, Analytics, Income screen, Setup wizard all use correct label per type: Pension, Allowance, Budget, Income / Budget

**Income categories expanded** — added Pension, Commission, Side Job; each account type gets appropriate category subset

**AI updated** — knows all 8 account types, gives appropriate budget suggestions for each

**Help screen** — Financial Health Score gets its own dedicated section with exact step-by-step formula; Analytics 50/30/20 fully explained; Want/Need has 4 detailed items; Cash Flow shows exact formula; Net Worth shows all 5 components

**Build:** April 29, 2026 — 4:43 PM (44.59 MB arm64-v8a)

### Session 23 — Tier 1 & Tier 2 Features (Full Backlog Sprint) + Demo Data Cleanup

**Build:** April 29, 2026 — 11:48 AM | APK: 44.5 MB (arm64-v8a)

**DB v11 migration** — all new columns in one block:
- `custom_categories` table (new)
- `photo_path TEXT` on expenses
- `is_want INTEGER DEFAULT 0` on expenses
- `is_percentage INTEGER DEFAULT 0` + `percentage_value REAL DEFAULT 0` on budgets

**#1 Custom Expense Categories** — `CategoryService` replaces all hardcoded category lists app-wide; `ManageCategoriesScreen` (add/rename/delete); built-in 8 locked; custom categories backed up/restored; seeded in demo data (School, Personal Care, Allowance); Hub tile + Profile tile added; AI context-aware

**#2 Shake to Undo** — `shake ^2.2.0` added to pubspec; `UndoService` singleton (in-memory, 60-second window); shake detector on AI screen; confirmation bottom sheet; undoable: log_expense, add_goal, add_income, add_debt, add_recurring, set_budget; cleared on logout

**#3 Expense Photo Attachment** — `photo_path` column on expenses; camera/gallery picker on Add and Edit screens; thumbnail shown in `ExpenseTile` with tap-to-fullscreen; photo badge indicator on tile; local only (no Firebase Storage)

**#6 % of Income Budget Mode** — per-budget toggle Fixed ₱ / % of income in budget dialog; auto-calculates from monthly_income; `is_percentage` + `percentage_value` columns on budgets; `Budget` model updated

**#7 AI Timeout Retry Button** — error messages now show inline Retry button; detects timeout/connection errors; one tap resends last message without retyping; `_lastUserMessage` tracked in state

**#8 Recurring "Log All" Button** — "Log All Due" button in RecurringScreen AppBar; appears only when overdue items exist; batch logs all overdue/due-today items; single snackbar confirmation

**#9 Want vs Need Expense Tagging** — `is_want` column on expenses; Need/Want ChoiceChip toggle on Add and Edit screens; `isWant` field on Expense model; Analytics screen shows Wants vs Needs stacked bar card with percentages

**#12 Net Worth Installment Integration** — `getInstallmentsRemainingTotal()` added to DBService; installment remaining balances now included in net worth liabilities in Profile screen

**#13 Spending Streaks & Badges** — `_computeStreak()` derives streak from score_history; badges: 🔥 streak, 💯 week, 🏆 30-day, 💰 ₱1K saved, 🎯 goal reached, 📅 active tracker; shown as chips on home dashboard

**#14 Daily Spending Limit** — `daily_limit` setting key; `getDailyLimit()`/`setDailyLimit()` in DBService; Profile → Daily Spending Limit dialog; home dashboard shows progress bar with orange/red states; push notification at 80% and when exceeded via `NotificationService.showDailyLimitAlert()`

**#15 Bill Due Date Calendar** — `BillCalendarScreen` with month-view grid; orange dots on days with bills due; tap day → bottom sheet shows bill details; month navigation; accessible from Hub → Bill Calendar

**#16 SSS/PhilHealth/Pag-IBIG Tracker** — preset templates in RecurringScreen AppBar popup menu; one tap adds SSS (₱1,125), PhilHealth (₱500), or Pag-IBIG (₱200) as monthly recurring bills

**Help screen** — 8 new sections added: Custom Categories, Daily Spending Limit, Bill Calendar, Want vs Need Tagging, Achievements & Streaks, Government Contributions, Shake to Undo (in Tips), Want/Need (in Tips)

**Backup** — version bumped to 5; `custom_categories` included in backup/restore

**Demo data** — seeds 3 custom categories (School, Personal Care, Allowance); clears them on reset

**`ExpenseTile`** — photo thumbnail replaces category icon when photo attached; Want badge shown in subtitle; custom category colors for School/Personal Care added

**Demo data redesigned for clarity (Session 23)** — 58 cluttered entries → 20 clean, purposeful entries:
- This week (8): Jollibee, jeepney, Globe load, canteen, tricycle, notebook, Mang Inasal, Shopee
- This month (6): Tuition installment, SM grocery, Spotify, vitamins, printing, haircut
- Last month (6): Similar pattern for comparison charts
- Budgets: Food ₱2,000 | Transport ₱600 | School ₱4,500 | Bills ₱300 | Entertainment ₱300 | Shopping ₱500 | Health ₱300 | Personal Care ₱200
- Goals: New Laptop (₱12K/₱35K), Emergency Fund (₱3.5K/₱10K), Graduation Trip (₱1.5K/₱8K)
- Debts: Kuya Mark (capstone materials), Trisha (lent fare)
- Recurring: Tuition installment, Spotify, Monthly Allowance

**Help screen audit** — 5 missing items added: daily limit bar on home, badges on home, % budget mode, Log All Due button, Wants vs Needs in analytics

**About screen updated** — Lorma Colleges info (CCSE, BSIT, San Fernando La Union), Lorma logo, v2.4.0, DB v11, 31 features listed
- **`LormaLogo.jpg`** — added to pubspec.yaml assets

### Session 21 — Claude Brainstorm Features
- **Recurring auto-log prompt** — overdue recurring bills show as tappable chips on home dashboard; one tap logs the expense/income and advances next_date automatically; no AI needed
- **Quick-log chips** — top 4 most frequently logged expenses appear as one-tap chips on dashboard; derived from expense history; zero friction for common expenses
- **AI context expanded 20→50** — recent 20 shown in detail; older 21-50 summarized by category total ("In the past month, ₱4,200 on Food across 18 transactions"); better AI advice
- **Contextual AI chips** — morning shows "Log breakfast", "What's due this week?"; evening shows "Log dinner", "How did I do today?"; midday shows general finance prompts; time-based, zero AI cost
- **Anomaly detection** — when AI logs an expense 2.5x above category average, shows orange warning: "That's higher than your usual Food spend of ₱80"; pure local math
- **Month-over-month insight sentence** — green/orange banner on home: "You're spending 12% less than last month 👍 — mostly on Food"; pulled from existing data, zero AI cost
- **Daily morning briefing notification** — fires once per day between 6–10 AM: "Good morning! ₱3,400 remaining this month · 2 bills due this week"; no AI needed

### Session 20 — Manual Entry Restored, Help Screen, Stability Pass
- **Manual entry button restored** — pencil icon in AI screen input bar opens `AddExpenseScreen` directly; no AI required; works offline
- **Manual entry form always visible** — fields show immediately without needing AI to analyze first; date picker added for backdating
- **`ai_generated` flag fixed** — manually filled entries correctly marked as not AI-generated (was always `1` before)
- **AI screen input buttons tightened** — smaller icons with proper spacing; text field no longer squeezed with 4 buttons
- **Help & Guide screen added** — `help_screen.dart`; searchable; 13 sections covering Getting Started to Tips & Tricks; expandable cards with example boxes; accessible from Profile → Help & Guide
- **AI delete clarification** — AI now states the specific item name before deleting when user uses vague references like "delete the last entry"
- **Dead code removed** — `barcode_screen.dart` and empty `scan_review_screen.dart` deleted
- **Hub const fix** — `_QuickAccessHub` constructor properly marked const

### Session 19 — Comprehensive QA & Stability Pass
- **OCR Scan Review Screen** — new dedicated `scan_review_screen.dart`; shows scanned image (collapsible) + large editable text field; user reviews/edits before sending to AI; loading indicator during OCR processing
- **Barcode Review Screen** — barcode scan now routes through same review screen with pre-filled description prompt
- **AI nav button styled** — circular colored background in bottom nav bar; fills with primary color when active, tinted when inactive; fully theme-aware
- **Demo data enriched** — added recurring transactions (Netflix, PLDT, Salary), debts (owe/lent), third savings goal (Vacation Fund) for richer live demos
- **AI daily limit reset** — ⋮ menu in AI screen now has "Reset Daily Limit" option for presentation/testing use
- **AI context leakage fixed** — `AIChatService.clearHistory()` now explicitly clears `_fullContext`; called on logout to prevent previous user's financial data leaking to next user
- **Debt event bus fixed** — `insertDebt`, `updateDebt`, `deleteDebt` now fire `expenseChanged` event; dashboard and home screen banners now update immediately after debt changes
- **Recurring date month-end crash fixed** — monthly/yearly next-date calculation now clamps to last valid day of month (e.g. Jan 31 → Feb 28, not Feb 31 crash)
- **Backup restore events fixed** — after restore, fires all 4 events (expenseChanged, budgetChanged, incomeChanged, goalChanged) so every screen refreshes
- **AI remaining messages display** — FutureBuilder now uses `ValueKey(_sending)` to rebuild after each message sent, keeping count accurate
- **FutureBuilder key fix** — remaining messages counter rebuilds correctly after limit reset
- **Demo data clear fix** — `DemoService.loadSampleData()` and `clearDemoData()` now also clear recurring and debts tables; prevents duplicate stacking when demo is loaded multiple times
- **UX accessibility improvements** — "Log Expense" quick button in dashboard header navigates directly to AI; empty state has friendly message + "Open AI Assistant" button; Hub shows live summary counts (goals, debts total, recurring count)
- **Smart Camera Screen** — unified camera with 3 tabs: Auto (live barcode detection + shutter for OCR), Receipt (camera/gallery), Barcode; all route through Scan Review Screen
- **Scan Review Screen** — inlined into smart_camera_screen.dart; image preview (collapsible), editable text, character count warning, barcode format label, auto-focus
- **OCR improvements** — better receipt text cleaning (removes noise, prioritizes totals/amounts), image orientation fix via `image` package
- **Budget resurrection fix** — `pushAllToCloud()` now clears Firestore budget docs before re-pushing; deleted budgets no longer come back after logout/login
- **Barcode scanner fixed** — each tab (Auto/Receipt/Barcode) now has its own `MobileScannerController`; controllers stop/start on tab switch to prevent detection conflicts
- **Auto mode redesigned** — single tap captures photo, ML Kit barcode detection runs first; if barcode/QR found routes to barcode review; if not falls back to OCR receipt scanning; no more clunky live scanner + shutter combo
- **google_mlkit_barcode_scanning added** — enables image-based barcode detection in Auto mode
- **Smart Camera redesigned** — single Auto mode screen (no tabs); live viewfinder with animated pulsing detection box + corner brackets; barcode/QR detected live automatically; shutter button for receipt/document OCR; gallery button for image import; all routes through Scan Review → AI pipeline
- **AI-Centric UX** — AI is a dedicated nav item in the bottom bar (Home / Analytics / AI / Hub / Profile); no floating button
- **Camera & Scanner** — OCR + barcode fused into one button in AI screen; OCR now shows extracted text for review before sending; barcode restores description dialog; renamed from "Smart Camera" to "Camera & Scanner"
- **50/30/20 Rule Tracker** — Analytics screen; always uses this-month data with verdict line (on track / over by X)
- **Emergency Fund Goal** — Savings Goals AppBar; auto-calculates 3 or 6-month target from actual spending; shield icon for emergency goals
- **Installment Tracker** — New screen accessible from Debt & Lending AppBar and Hub; tracks phones/gadgets on installment with progress, remaining balance, interest
- **Cash Flow Forecast** — Home dashboard; shows Income / Spent / Bills Due / Remaining with upcoming bill preview and shortfall warning; hides when no data
- **Full Net Worth** — Profile; includes manual assets + debt liabilities; tap to manage assets
- **AI What-If Scenarios** — Dynamic chips use user's actual top spending category; system prompt updated for scenario analysis
- **Score tap dialog** — Home score card now shows full breakdown + actionable tips + "Full Details →" link to Profile
- **Score breakdown tips** — Profile breakdown shows actionable orange tip per negative factor
- **Installment Tracker in Debt screen** — correct placement as liability
- **Cash Flow moved to Home** — forward-looking info belongs on dashboard, not Analytics
- **50/30/20 fixed to monthly** — always uses this-month data regardless of Analytics period filter
- **Version bumped** — pubspec 2.3.0+1, debug log, backup export all updated
- **Backup includes installments** — backup/restore now covers installments table (version 4)
- **AI context includes installments** — AI can answer questions about installment balances
- **Analytics colors theme-aware** — filter chips, bar chart, line chart, AI advice icon all use colorScheme.primary
- **Savings goals snackbar** — contribution tip snackbar uses theme primary color
- **Feature tour updated** — reflects new AI-centric UX, Hub navigation, share-sheet backup
- **Profile nav tiles cleaned** — removed redundant Savings Goals, Income, Debts, Recurring, Currency tiles (all in Hub)
- **AI empty state** — no longer flashes before context loads
- **FAB position** — changed to centerFloat so it no longer overlaps AI chat input
- **Google Drive backup removed** — replaced with share-sheet based backup (same approach as CSV/debug log export)
- **`BackupService` rewritten** — generates timestamped JSON file, shares via system share sheet; user saves to phone, Drive, email, Dropbox, or anywhere
- **Restore** — file picker lets user select a `.json` backup file from device storage; `file_picker: ^8.0.0` added to pubspec
- **Profile screen** — "Backup to Google Drive" → "Backup Data"; "Restore from Google Drive" → "Restore from Backup"
- **No OAuth, no API keys, no permissions needed** — works immediately on any device
- `google_sign_in` package kept in pubspec (used for main auth) but Drive-specific code removed from BackupService
- **`POST_NOTIFICATIONS` permission** — added to AndroidManifest + runtime request on init; fixes silent notification blocking on Android 13+ (Poco X6 Pro, Android 16)
- **`VIBRATE` permission** — added to manifest
- **Storage permissions** — added with `maxSdkVersion` limits for older Android compatibility
- **Debt due alerts** — push notification for debts/lending due within 7 days or overdue; fires on app open
- **Savings goal deadline alerts** — push notification when goal deadline is within 7 days or passed
- **Recurring 3-day advance warning** — push notification 1–3 days before recurring item is due
- **Upcoming debt banner** — red in-app banner on home screen for debts due within 7 days
- **Home screen** — `debtsFuture` added to parallel fetch; `_upcomingDebts` state added
- **Team roles updated** — Cyrille: UI/UX Designer & Documentation Lead; Djaunathan: Project Manager & QA Lead (updated in About screen, DOCUMENTATION.md, QA Brief, README)
- **Google Drive backup fallback** — folder creation now falls back to Drive root if subfolder creation fails (handles `drive.file` scope limitations); `_findBackupFile` and `backup()` both handle empty folderId gracefully
- **APK rebuilt** — 42.5MB arm64, all changes included
- **N4** — AI context recurring amounts now show `888` not `888.0`
- **N5** — Home screen overdue recurring banner added (orange, links to Recurring screen)
- **N6** — Profile screen now uses `getExpenseCount()` DB query instead of loading all expenses
- **N7** — AI `add_recurring` next_date now calculated per frequency (daily→tomorrow, weekly→7d, monthly→30d, yearly→365d)
- **N8** — Debug log now includes app version (2.2.0)
- **Recurring in AI context** — recurring transactions added to AI context with formatted amounts and due labels
- **AI smart budget setup** — system prompt includes suggested splits by account type
- **Recurring due notifications** — fires on app open for overdue/due-today items
- **Recurring income Log Now** — now logs as income entry (was silently returning)
- **Home screen** — `recurringFuture` added to parallel fetch block
- **Recurring income logging** — `_logNow` now logs recurring income as an income entry instead of silently returning; snackbar says "logged as income" or "logged as expense"
- **Recurring due notifications** — `NotificationService.checkRecurringDue()` fires on app open; shows push notification for overdue/due-today recurring items
- **Recurring in AI context** — recurring transactions now included in AI context (up to 8 items with due date labels: OVERDUE / due today / in X days)
- **AI smart budget setup** — system prompt now includes suggested budget splits by account type when user asks "set up budgets for me"
- **AI context parallelized** — `recurringFuture` added to the parallel fetch block
- **Google Drive backup** — `backup()` now rethrows exceptions instead of swallowing them; actual Drive error message shown in snackbar for easier debugging
- **Backup error visibility** — users now see the real error (e.g. "Drive upload failed (403)") instead of generic "Backup failed"
- All remaining non-intentional `Color(0xFF0066FF)` hardcodes replaced with `Theme.of(context).colorScheme.primary` across: `savings_goals_screen`, `recurring_screen`, `profile_screen` (Load Demo, Restore, Backup icon, EditProfile avatar + save), `home_screen` (Voice tile, Budgets button, AI Insights icon), `chat_history_screen` (user bubble), `action_button`
- Intentionally kept: splash background, onboarding slide colors, chart data colors, category palette, savings tip snackbar
- **Delete safeguard** — AI requires user to type "DELETE" in chat before executing `delete_expense`; blocked with orange snackbar if confirmation missing
- **AI `_loadContext` parallelized** — 8 sequential DB calls now fire concurrently (futures started together, awaited after)
- **Home `_loadData` parallelized** — 6 sequential DB calls now fire concurrently
- **Profile `_loadStats` parallelized** — 7 sequential DB calls now fire concurrently; removed duplicate `accountType` fetch
- **Double `setState` in `_send` finally** — removed redundant second `setState({})`
- **PIN rate limiting** — 5 attempts max, then 30-second lockout; digit input blocked during lockout
- **Insight cache reset** — `_lastInsightExpenseCount` resets on `incomeChanged` event (covers logout/account switch)
- **`llm_service` normalizer** — expanded to match `ai_chat_service` (beverages, Filipino food brands, etc.)
- **`MainActivity.kt`** — changed from `FlutterActivity` to `FlutterFragmentActivity`; this is the required base class for `local_auth` biometric on Android — fixes the silent no-op on Poco X6 Pro and all Android devices
- **AI `update_expense`** — AI now edits existing entries in-place instead of deleting+re-adding; preferred action for all corrections
- **AI `delete_expense`** — last resort only; AI tells user to manually delete if it can't identify the entry
- **AI DB authority rule** — system prompt now explicitly states the provided context is the single source of truth; AI never uses conversation history to list or total expenses
- **Category normalizer** — beverages (Sting, Cobra, Red Bull, energy drinks, juice, soda) added to Food category in both `ai_chat_service` and `llm_service`
- **Google Drive backup** — fixed `$mimeType` typo in multipart body that was causing malformed upload requests
- **`llm_service` normalizer** — expanded to match `ai_chat_service` (was much shorter before)
- **Biometric fix** — switched to `isDeviceSupported()` check; works with optical in-display fingerprint (Poco X6 Pro), face unlock, and device PIN/pattern fallback
- **App lock grace period** — 3-minute background threshold before lock triggers; brief interruptions (share sheets, camera, file pickers) no longer trigger lock
- **Google Drive backup** — switched from `appDataFolder` (restricted, invisible) to `drive.file` scope; creates visible "Smart Spend Backups" folder in user's Drive root
- **CSV export filename** — now includes date+time: `SmartSpend_Expenses_YYYYMMDD_HHmmss.csv`
- **About screen team photos** — actual dev photos from `Devs/` folder now shown as circular avatars
- **Dev photos added to pubspec assets** — `Devs/BRIX A. DIRECTO.png`, `Devs/CYRILLE JOHN M. RUBIS.png`, `Devs/DJAUNATHAN ALBERT S. MADAYAG.png`
- **Health score** — now uses this-month expenses consistently across Home, Analytics, and Profile (was using all-time in Profile → score fluctuated)
- **Score breakdown label** — "Saving 20%+" renamed to "Spending within 80% of income (20%+ unspent)" — accurate and not misleading
- **AI Insights total** — actual DB total now injected into LLM prompt; AI can no longer hallucinate a different total
- **Income categories** — adapt to account type (students see Allowance/Freelance/Gift, not Salary)
- **App Lock** — full implementation: 4-digit PIN + biometric, lifecycle-aware (triggers on cold start and app resume), only when logged in, toggle from Profile → App Lock
- **`app_lock_service.dart`** — PIN storage (obfuscated), biometric auth, enable/disable
- **`app_lock_screen.dart`** — numpad UI + biometric button + "Not you? Log out"
- **`pin_setup_screen.dart`** — enter PIN → confirm PIN flow
- **`main.dart`** — `WidgetsBindingObserver` watches app lifecycle for lock trigger
- **`splash_screen.dart`** — checks lock on cold start before navigating to Home
- **AI language rule** — English is now the hard default; Filipino only triggers on full Filipino sentences or explicit demand
- **Social message handling** — "thanks", "ok", "next" etc. get short acknowledgments only, no ACTION lines
- **Scope rule relaxed** — "list my transactions", "show my expenses" etc. now work correctly
- **Biometric login removed from UI** — button and all related code removed from login screen; `local_auth` package kept for future app-lock feature
- **About screen** — Biometric Login removed from features list
- **Documentation updated** — biometric noted as planned future feature, app-lock rationale documented
- **Home screen FAB** → theme-aware (removed hardcoded blue)
- **Setup screen income field** → uses `CurrencyService.symbol` instead of hardcoded ₱
- **Analytics income dialog** → uses `CurrencyService.symbol`
- **AI language detection** — stricter Filipino trigger (requires multiple distinctive words, defaults to English)
- **Expense sort order** — now `date DESC, id DESC` so newest AI-logged items always appear at top
- **Settings sync to Firestore** — `monthly_income`, `account_type`, `income_frequency`, `currency` now pushed on logout and restored on login
- **Chat history preserved** — no longer cleared on logout; AI remembers conversations across sessions
- **AI token limit** — increased from 1500 → 2000 to prevent ACTION lines being cut off
- **Truncated ACTION recovery** — parser now attempts to close incomplete JSON before discarding
- **System prompt** — ACTION lines must be complete; response capped at 100 words
- **AI `update_goal`** — contribute amount to existing savings goal by name
- **AI `add_income`** — log one-time income entry (Salary, Allowance, Freelance, etc.)
- **AI `add_debt`** — log money owed or lent with person name
- **AI `add_recurring`** — create recurring transaction (daily/weekly/monthly/yearly)
- **AI actions execute immediately** — confirmation dialog removed (was blocking all writes)
- **Feature tour fixed** — `PageController` was never attached to a `PageView`; replaced with pure state-driven navigation + fade animation, back button, tappable dots, step counter
- **Debug Log Export** — new `DebugService` exports full DB + chat history as `.txt` via share sheet; accessible from AI screen ⋮ menu and Profile screen
- **AI system prompt updated** — all 9 action types documented with examples
- **AI actions not saving** — ACTION regex now handles `*ACTION:*` markdown bold wrapping
- **AI screen frozen after cancel** — `_sending` now reset in cancel path
- **Add/Edit expense amount shows `30.00`** → now shows `30` for whole numbers
- **Add expense Analyze button** → theme-aware
- **Edit expense Save button** → theme-aware, amount label uses currency symbol
- **Register screen** → theme-aware, name now saved to Firebase display name
- **Expense tile selected state** → theme-aware
- **Transactions filter chips** → theme-aware
- **Barcode overlay + avatar** → theme-aware
- **Debt FAB** → theme-aware, due date shows human-readable format
- **Income screen** → date picker added for backdating entries
- **Splash screen** → `const LoginScreen()` fixed
- **About screen** → Lucid Frame logo added, team card updated with group logo
- **`LucidFrameLogo.png`** → added to pubspec assets
- **AI duplicate blocking** — AI-logged expenses now use HH:mm:ss so multiple items in one batch all save
- **Default income** — changed from ₱30,000 to ₱0 (no false income shown to new users)
- **AI context expanded** — now includes savings goals + debts, 20 expenses instead of 10
- **DB schema** — `updated_at` column added to `CREATE TABLE expenses` for fresh installs
- **Insight caching** — home screen only calls Groq when expense count changes
- **PHP currency format** — now shows ₱30 instead of ₱30.00
- **Voice pause timeout** — reduced from 3s to 2s
- **Spending projection** — only shows after 3+ days of data

---

## 🔮 Future Roadmap & Wishlist

This section documents all planned features, deferred items, and new ideas — organized from oldest to newest.

---

### 🔴 PREVIOUSLY DEFERRED (Early Sessions)

---

### 🎯 Adviser Suggestion — Full Agentic AI (Autonomous Bill Payment)

**What was suggested:** "Baka pwede ring pang agentic, siya na magkusang magbayad ng bills" — the AI autonomously pays bills without user intervention.

**Why it cannot be implemented now:**

| Requirement | Blocker |
|-------------|---------|
| GCash/Maya API | Not publicly available — requires formal partnership agreement |
| Bank APIs (BPI, BDO, UnionBank) | Require BSP licensing and formal developer agreements |
| Bills payment APIs (Meralco, PLDT, etc.) | Require business registration + KYC verification |
| Security compliance | Requires PCI-DSS compliance, end-to-end encryption, fraud detection |
| Legal/regulatory | BSP license required to process payments |

**Future plan:** Business registration → payment aggregator partnership (PayMongo/DragonPay) → BSP compliance → GCash/Maya Open Finance API integration.

---

### 🔒 D3 — SQLite Database Encryption

**What it is:** Encrypt local SQLite DB using `sqlcipher_flutter_libs` so financial data is protected if device is compromised.

**Blockers:** DB migration risk, Android Keystore complexity, breaking change requiring reinstall.

**Future plan:** Post-capstone — `sqlcipher_flutter_libs` + migration script on first launch after update.

---

### 📸 D5 — Profile Photo Cross-Device Sync

**What it is:** Profile photos syncing across devices (currently local only).

**Blockers:** Firebase Storage requires Blaze (paid) plan.

**Future plan:** Upgrade to Blaze → Firebase Storage → sync `users/{uid}/profile.jpg`.

---

### ⏰ D6 — Cloud Functions & Scheduled Tasks

**What it is:** Auto-log recurring transactions at midnight, real-time sync triggers, daily spending summaries.

**Blockers:** Firebase Cloud Functions requires Blaze plan + Node.js backend.

**Future plan:** Blaze plan → Cloud Functions → scheduled recurring auto-log → Firestore real-time triggers.

---

### 🔄 D-A — Soft-Delete for Sync Resurrection

**What it is:** Prevent deleted records from resurrecting after login sync on another device.

**Blockers:** Requires DB migration to version 11, `deleted_at` column on all tables, sync logic changes.

**Future plan:** DB v11 migration → `deleted_at` timestamps → update `syncFromCloud` to respect soft-deletes.

---

### 📦 D-B — Typed Models for Goals, Debts, Income

**What it is:** Replace `Map<String, dynamic>` with proper Dart model classes (`SavingsGoal`, `Debt`, `Income`).

**Deferred:** High effort, no user-visible benefit, refactor risk mid-capstone.

**Future plan:** Post-capstone refactor with `fromMap`/`toMap` and compile-time type safety.

---

### 🟡 RECENTLY DEFERRED (This Session)

---

### 💡 N2 — AI Savings Plan (Budget Cut Suggestions)

**What it is:** When user says "help me save ₱10,000 in 3 months", AI analyzes spending and suggests specific budget cuts per category.

**Deferred:** Complex AI prompt logic, risk of incorrect financial advice.

**Future plan:** Add `suggest_savings_plan` action type with category-level cut recommendations.

---

### 📷 N4 — True Single-Screen Receipt Capture

**What it is:** `mobile_scanner` v5+ `captureImage()` → capture receipt from live viewfinder without opening system camera.

**Blockers:** v5 has major breaking API changes (`onDetect` removed, controller required, `autoStart` removed).

**Future plan:** Upgrade `mobile_scanner` from `^3.5.7` to `^7.x`, migrate controller API, replace `ImagePicker.camera`.

---

### 🎙️ N3 — AI Voice Response (Text-to-Speech)

**What it is:** AI responds with voice — full voice-in/voice-out like Siri.

**Blockers:** `flutter_tts` is free but robotic; cloud TTS (ElevenLabs/OpenAI) has usage costs; Groq has no TTS endpoint.

**Future plan:** `flutter_tts` for basic on-device voice → optional cloud TTS upgrade → Profile toggle → smart response truncation.

---

### 🟢 NEW IDEAS (Apr 27, 2026)

---

### I1 — CSV/Excel Transaction Import ⭐ (Most Achievable)

**What it is:** Import GCash, BDO, BPI, UnionBank transaction history exported as CSV. App reads rows, AI maps columns to our format, bulk-imports to DB.

**Why it's feasible:** Already have `file_picker` and CSV parsing tools. No new dependencies needed.

**Future plan:** File picker → CSV parse → preview table → AI column mapping → bulk insert with review screen.

---

### I2 — PDF Bank Statement Import

**What it is:** Import PDF statements from BDO, BPI, UnionBank. Extract text, AI parses transactions.

**Needs:** `syncfusion_flutter_pdf` or `pdf_text` package (~5MB APK increase).

**Future plan:** File picker → PDF text extraction → AI multi-transaction parsing → bulk import.

---

### I3 — Password-Protected PDF Import

**What it is:** Same as I2 but user enters the bank-provided password to decrypt before extraction.

**Needs:** Same PDF library — supports password decryption natively.

**Future plan:** Password input dialog → decrypt → extract → AI parse → bulk import.

---

### I4 — Multi-Transaction Screenshot Import

**What it is:** Screenshot of GCash transaction list or bank statement → OCR reads multiple transactions → AI bulk-logs them.

**Why it's feasible:** Works with current OCR pipeline — just needs a smarter multi-transaction AI prompt.

**Future plan:** Smart Camera → OCR → AI prompt: "Extract all transactions from this screenshot as a list" → bulk import.

---

### I5 — Custom Expense Categories

**What it is:** Let users add their own categories beyond the default 8 (e.g., "Tuition", "Church Offering", "Pet Care").

**Future plan:** Settings screen → manage categories → stored in SQLite settings → propagated to all category pickers.

---

### I6 — Net Worth Installment Integration

**What it is:** Include installment remaining balances in Net Worth liabilities (currently only counts debts).

**Future plan:** Query `installments` table in `_loadStats()` → add to liabilities side of net worth calculation.

---

### I7 — Spending Streaks & Badges

**What it is:** Gamification — "5 days under budget 🔥", "Saved ₱1,000 this week 🏆". Keeps casual users engaged.

**Future plan:** Track daily budget compliance in `score_history` → compute streaks → show badges on Home.

---

### I8 — Daily Spending Limit

**What it is:** Set a daily cap (e.g., ₱300/day). App warns when you're close or over.

**Future plan:** Setting in Profile → daily limit stored in settings → Home dashboard shows daily progress bar.

---

### I9 — Bill Due Date Calendar View

**What it is:** Render all recurring transactions on a monthly calendar with color coding.

**Future plan:** New screen in Hub → calendar widget → recurring items plotted by `next_date`.

---

### I10 — Business Course Partnership Features

**What it is:** Petty cash log, business vs personal expense toggle, simple invoice generator for freelancers.

**Future plan:** Add `is_business` flag to expenses → separate business analytics view → invoice template generator.

---

### I11 — Shared/Family Budget

**What it is:** Multiple users contributing to one shared budget (couple, family, org treasurer).

**Blockers:** Requires multi-user cloud architecture, shared Firestore collections, conflict resolution.

**Future plan:** Post-capstone — shared workspace concept with invite system.

---

### 🔵 ADDITIONAL RECOMMENDATIONS

---

### R1 — Recurring Transaction Auto-Log (No Cloud Functions)

**What it is:** On app open, silently auto-log any overdue recurring items instead of requiring manual "Log Now" tap.

**Why it's feasible:** No Cloud Functions needed — just check on `initState` in `main.dart`.

---

### R2 — AI Context Window Expansion

**What it is:** Increase from 20 to 50 expenses by summarizing older ones by category total instead of listing individually.

**Why it's feasible:** Pure prompt engineering change in `ai_chat_service.dart`.

---

### R3 — Expense Photo Attachment

**What it is:** Attach a receipt photo to any expense entry (stored locally). Currently OCR scans but doesn't save the image.

**Future plan:** Add `photo_path` column to expenses table → show thumbnail in expense tile.

---

### R4 — Offline AI Mode

**What it is:** When no internet, show pre-computed insights from last sync instead of failing silently.

**Future plan:** Cache last AI insights in SQLite → show cached version with "last updated" timestamp when offline.

---

### R5 — iOS Support

**What it is:** The app is Android-only. Flutter supports iOS — most code works as-is.

**Needs:** Firebase iOS config, ML Kit iOS setup, biometric iOS config, App Store developer account ($99/year).

---

### R6 — Play Store / App Store Release

**What it is:** Distribute the app publicly.

**Needs:** App signing, Play Store developer account ($25 one-time), privacy policy, screenshots, app review.

---

### 🆕 NEW — From Session 21 & 22 Brainstorm (Not Yet Implemented)

See `SmartSpend_Master_TODO.md` for the full canonical backlog with implementation details.
Below is a summary of all new items organized by tier.

---

### TIER 1 — DO NOW

**#1 I5/S6 — Custom Expense Categories** `(specced)` `(DB v11)` `(AI)`
Let users add their own categories beyond the default 8. Dedicated `custom_categories` table. CategoryService replaces all hardcoded lists app-wide. Full spec written by Claude.

**#2 N-C — Shake to Undo** `(specced)` `(no DB)`
Shake phone after an AI action → confirmation bottom sheet → undo within 60 seconds. New `shake ^2.2.0` package. UndoService singleton. Full spec written by Claude.

**#3 S4/R3 — Expense Photo Attachment** `(DB v11)`
Attach receipt photo to any expense. `photo_path` column in expenses table. Thumbnail in ExpenseTile. Local only (no Firebase Storage). Tarsi has this.

**#4 I1/S3 — CSV / Bank Import** `(AI)`
Import GCash, BDO, BPI, UnionBank CSV exports. AI column mapping. Bulk insert with review screen. Duplicate detection. Packages already in pubspec.

**#5 S13 — Spending Heatmap Calendar** `(no DB)`
Month-view calendar with color intensity per day. Tap day → see transactions. Custom Flutter widget. Tarsi has this.

**#6 N-H — % of Income Budget Mode** `(DB v11)`
Per-budget toggle: fixed ₱ amount OR % of income. Auto-calculates from monthly_income. `is_percentage` + `percentage_value` columns on budgets table.

---

### TIER 2 — DO NEXT

**#7 S1 — AI Timeout Retry Button** `(no DB)` — Inline retry in chat on Groq timeout.

**#8 S2 — Recurring "Log All" Button** `(no DB)` — Batch log all overdue recurring in one tap.

**#9 S5 — Want vs Need Expense Tagging** `(DB v11)` `(AI)` — `is_want` column + toggle in add/edit + analytics breakdown.

**#10 R1 — Recurring Auto-Log on App Open** `(no DB)` — Partially done (chips exist). Still needs "Log All" batch button.

**#11 R2 — AI Context Window Expansion 20→50** `(AI)` `(no DB)` — ✅ DONE in Session 21.

**#12 I6 — Net Worth Installment Integration** `(no DB)` — Include installment remaining balances in liabilities.

**#13 I7 — Spending Streaks & Badges** `(no DB)` — Gamification: 🔥 streak, 🏆 savings, 📅 logging, 💯 score, 🎯 budget badges.

**#14 I8 — Daily Spending Limit** `(no DB)` — Daily cap setting + progress bar on Home + push notification.

**#15 I9 — Bill Due Date Calendar View** `(no DB)` — Monthly calendar of recurring transactions by next_date.

**#16 N-B — SSS/PhilHealth/Pag-IBIG Tracker** `(no DB)` — Preset recurring templates for government contributions.

---

### TIER 3 — PLAN LATER

**#17 S7** — Debt payment timeline (projected payoff chart)
**#18 S8** — Quick-log chip customization (pin/unpin)
**#19 S9** — Onboarding financial quiz
**#20 S10** — Export to PDF monthly summary `(new pkg)`
**#21 S11** — Biometric lock for sensitive screens
**#22 S12** — AI conversation export
**#23 N-A** — Multiple account wallets `(DB v12+, major architecture — v2.5+ only)`
**#24 I2** — PDF bank statement import `(new pkg)`
**#25 I3** — Password-protected PDF import
**#26 I4** — Multi-transaction screenshot import

---

### 🔐 PRIVACY & SECURITY (Post-Capstone)

**P1 — Backend Proxy for LLM API Key**
Move Groq API key to a backend server. Current 60-msg/day cap mitigates abuse. Needs Node.js/Python backend + hosting (Vercel, Railway free tiers).

**P2 — Privacy Policy & Terms of Service**
Required for Play Store submission. Cover: local SQLite, Firestore sync, Groq API data handling.

**P3 — Data Anonymization for AI Context**
Strip/hash PII (shop names, person names in debts) before sending to Groq API.

**Why it matters:** Instant visual pattern — users can see "I always overspend on weekends" without reading numbers.

**Needs:** Custom Flutter grid widget. No new packages needed.

---

## ⚠️ Important Notes for Future Development

1. **Do not upgrade Firebase plan mid-capstone** — wait until after defense to avoid unexpected billing
2. **Do not attempt DB migration (version 11) without a backup** — always test on a fresh install first
3. **GCash/Maya API** — monitor their developer portal; they announced Open Finance API in 2024 but it's still in limited beta
4. **The current architecture supports all these features** — the app is designed to be extended; none of these require a rewrite

---

## 🐛 Known Issues (Expected Behavior)

| Observation | Explanation |
|-------------|-------------|
| Income shows as monthly even if you set daily | **By design** — all income is stored as monthly equivalent for consistent calculations. The frequency selector is for input convenience only. The helper text now clarifies this. |
| Profile photo doesn't sync to other devices | Firebase Storage requires Blaze plan — photos are local-only by design |
| AI sometimes responds in wrong language for Taglish | LLaMA 3.1 8B limitation — strengthened with keyword list but not 100% |
| Offline data doesn't sync until next login | Real-time sync requires Cloud Functions (Blaze plan) — current design is login-triggered |
| Editing same expense on two devices while offline → last login wins | Last-write-wins is the mitigation — full CRDT is deferred |

---

## 📦 Distribution

```
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk    (42.2MB) ← Distribute this
├── app-armeabi-v7a-release.apk  (34.6MB)
└── app-x86_64-release.apk       (45.3MB)
```

---

## 🧪 Critical Test Scenarios for QA

### 1. AI Actions (Critical — just fixed)
- Tell AI: "I spent 30 pesos on ice cream and 30 on jeepney"
- Verify confirmation dialog appears with both items
- Tap Confirm → verify green snackbars appear
- Go to Transactions → verify both expenses are saved
- **Expected:** 2 separate expenses, not one combined

### 2. Income Frequency (just fixed)
- Go to Profile → tap Income card
- Select "Daily" → enter 300
- Tap Save → verify it shows ₱6,600/mo (300 × 22)
- **Expected:** The conversion is correct — daily allowances are stored as monthly equivalents

### 3. Google Drive Backup (just fixed)
- Go to Profile → Backup to Google Drive
- If it fails, tap again — it will re-auth with Drive scope
- **Expected:** Success message after 2nd attempt if 1st fails

### 4. Account Switching
- Create Account A → add expenses → logout (confirm dialog)
- Create Account B → login → verify Account A's data is NOT visible
- Login as Account A again → verify data restored from cloud

### 5. Demo → Real Account
- Tap "Try Demo" → verify sample data loads
- Logout → login as real account → verify demo data is gone

---

## 📊 Final Statistics

- **41 Dart files** — zero compile errors
- **12 screens** — all theme-aware, all pull-to-refresh
- **15 services** — all functional
- **88 bugs fixed** from Master Reference v4
- **54 improvements implemented**
- **3 items deferred** (paid plan / native plugin)

---

## 🎓 Capstone Defense Status

✅ **Proposal defense ready** — Chapter 1 & 2 complete  
✅ **App demonstration ready** — fully functional, QA-tested  
✅ **Documentation complete** — `DOCUMENTATION.md` + `QA_READY_SUMMARY.md`  
✅ **Zero blocking bugs** — all critical issues resolved  
✅ **Data safety** — Firestore sync + Google Drive backup working  

---

## 🔧 For Future Development (Post-Capstone)

If you upgrade to Firebase Blaze plan ($0 until you exceed free limits):
1. Enable Firebase Storage → profile photos sync across devices
2. Enable Cloud Functions → real-time sync, scheduled tasks, recurring auto-log
3. Add Cloud Firestore triggers → instant cross-device updates

If you want SQLite encryption:
1. Add `sqlcipher_flutter_libs` dependency
2. Migrate existing DB to encrypted version
3. Handle key management securely

---

*Built by Lucid Frame — Brix A. Directo, Cyrille John M. Rubis, Djaunathan Albert S. Madayag*
