# SmartSpend — Master To-Do List
**Compiled:** April 28, 2026 | **Last Updated:** May 11, 2026
**Version target:** 2.6.0+
**For:** Kiro (coding AI) — use this as the canonical backlog
**Status:** v2.6.0 sync audit complete. Open items below.

> **Read `KIRO_CONTEXT.md` before starting any task.**

---

## LEGEND
- `[NEW]`      = New item from brainstorm/competitor research session
- `[EXISTING]` = Was already in the backlog from previous sessions
- `[DEFERRED]` = Low priority, no action needed yet
- `[BLOCKED]`  = External dependency (paid plan, API, architecture risk)

**Tags used inline:**
- `(specced)`  = Full implementation spec already written by Claude
- `(DB v11)`   = Requires SQLite migration from v10 to v11
- `(DB v12+)`  = Requires future migration, don't touch yet
- `(AI)`       = Touches AI system prompt, normalizer, or context injection
- `(no DB)`    = Zero database changes needed
- `(new pkg)`  = Requires adding a new pubspec.yaml dependency
- `(blocked)`  = Cannot build yet — see reason in notes

---

## TIER 1 — DO NOW
*High impact, low risk, closes competitive gaps vs Tarsi/Bluecoins*

### ✅ #1 [EXISTING] I5 / S6 — Custom Expense Categories — DONE (Session 23)
### ✅ #2 [NEW] N-C — Shake to Undo — DONE (Session 23)
### ✅ #3 [EXISTING] S4 / R3 — Expense Photo Attachment — DONE (Session 23)

### #4 [EXISTING] I1 / S3 — CSV / Bank Import (GCash, BDO, BPI)
**Tags:** `(specced)` `(DB v11)` `(AI)`
Full spec written. Refer to Claude's Custom Categories spec document.

**Summary:**
- New `custom_categories` table in DB v11 migration
- New CategoryService — replaces ALL hardcoded category lists app-wide
- New CustomCategory model
- New ManageCategoriesScreen (add/edit/delete custom categories)
- Built-in 8 categories remain locked/uneditable
- AddExpenseScreen + EditExpenseScreen load categories dynamically
- BudgetScreen loads categories dynamically
- TransactionsScreen filter chips load dynamically
- AIChatService + LLMService normalizer updated to recognize custom cats
- AI context injection updated to include custom category names
- backup_service.dart extended to backup/restore custom_categories table
- cloud_service.dart syncs custom_categories to Firestore
- demo_service.dart seeds 3 sample custom categories
- Hub bottom sheet: new Categories tile with live custom count
- Profile screen: new Categories nav tile
- help_screen.dart: add 14th section "Custom Categories"
- export_service.dart: audit for hardcoded category assumptions
- **NOTE:** Original roadmap note said "store in settings table" — this spec intentionally uses a dedicated table instead. Do NOT use settings table.

**Implementation order:**
1. DB migration v11 + CustomCategory model
2. CategoryService with all CRUD methods
3. ManageCategoriesScreen
4. Update AddExpenseScreen + EditExpenseScreen
5. Update BudgetScreen + TransactionsScreen
6. Update AIChatService + LLMService normalizer + context injection
7. Hub tile + Profile tile
8. Backup/restore + cloud sync
9. Demo data seeds
10. help_screen + export_service audit

---

### #2 [NEW] N-C — Shake to Undo
**Tags:** `(specced)` `(no DB)`
Full spec written. Refer to Claude's Shake to Undo spec document.

**Summary:**
- New package: `shake ^2.2.0` (add to pubspec.yaml)
- New UndoService singleton (in-memory only, NOT persisted to DB)
- New UndoableAction model with 60-second undo window
- Shake detector lives on ai_screen.dart only
- Shows confirmation bottom sheet on shake (not auto-undo)
- Undoable actions: log_expense, log_expense_batch, add_goal, add_income, add_debt, add_recurring, set_budget, update_expense, update_goal
- NOT undoable: delete_expense, set_income, set_account_type
- AIChatService records UndoableAction after every successful action
- UndoService.clear() called on: new action recorded, screen dispose, logout
- Shake threshold: shakeThresholdGravity = 2.7 (firm shake, not accidental)
- After undo: fires AppEvent.expenseChanged + AppEvent.budgetChanged
- help_screen.dart: add shake to undo tip in Tips & Tricks section

**Files affected:**
pubspec.yaml, undo_service.dart (new), ai_chat_service.dart, ai_screen.dart, auth_service.dart, help_screen.dart

---

### #3 [EXISTING] S4 / R3 — Expense Photo Attachment
**Tags:** `(DB v11)`

**Summary:**
- Add `photo_path TEXT` column to expenses table in DB v11 migration (same migration block as custom_categories — both are v11)
- Camera/gallery picker on AddExpenseScreen and EditExpenseScreen
- Thumbnail shown on ExpenseTile widget
- Full-screen image view on thumbnail tap
- Local storage only (no Firebase Storage — Spark plan)
- Use existing `image` package for EXIF orientation correction
- photo_path included in backup JSON export/restore
- photo_path NOT synced to Firestore (local file paths are device-specific)
- Tarsi has this feature — direct head-to-head competitor

---

### #4 [EXISTING] I1 / S3 — CSV / Bank Import (GCash, BDO, BPI)
**Tags:** `(AI)`
Packages already in pubspec: csv, file_picker

**Summary:**
- file_picker → user selects CSV file
- Parse CSV rows into preview table
- AI column mapping: AI identifies which columns are date/amount/description
- Bulk insert with review screen (user can deselect rows before confirming)
- GCash CSV format first (most common for target users)
- BDO and BPI formats second
- UnionBank format third
- Category assignment via existing AI normalizer
- Bulk insert fires single AppEvent.expenseChanged after all rows done
- Show import summary: "47 transactions imported, 3 skipped (duplicates)"
- Duplicate detection: same date + same amount + same description = skip

---

### #5 [EXISTING] S13 — Spending Heatmap Calendar
**Tags:** `(no DB)`

**Summary:**
- Month-view calendar grid widget (custom Flutter widget, not a package)
- Each day cell colored by spend intensity:
  - No spend = background color
  - Low spend = light accent
  - Medium spend = medium accent
  - High spend = strong accent (relative to user's daily average)
- Tap any day → shows list of that day's expenses in a bottom sheet
- Add to AnalyticsScreen as a new tab/section OR as a new Hub screen
- No new DB queries — uses existing expenses table filtered by month
- Month navigation: swipe or prev/next arrows
- Tarsi has this — direct competitor feature

---

### ✅ #6 [NEW] N-H — % of Income Budget Mode — DONE (Session 23)

---

## TIER 2 — DO NEXT
*Good improvements, medium effort, most need no DB changes*

### ✅ #7 [EXISTING] S1 — AI Timeout Retry Button — DONE (Session 23)

### ✅ #8 [EXISTING] S2 — Recurring "Log All" Button — DONE (Session 23)

### ✅ #9 [EXISTING] S5 — Want vs Need Expense Tagging — DONE (Session 23)
**Tags:** `(no DB)`

**Summary:**
- Per-budget row toggle on BudgetScreen: "Fixed ₱ amount" OR "% of income"
- When % mode selected: budget auto-calculates based on monthly_income setting
- Example: Food set to 30% → if income = ₱10,000 → budget = ₱3,000
- Budget auto-updates when income changes (re-query on BudgetScreen init)
- Store mode flag per budget row: add `is_percentage` + `percentage_value` columns to budgets table (DB v11 or handle via JSON in existing amount field)
- Natural extension of existing 50/30/20 tracker logic
- Tarsi has this feature

---

## TIER 2 — DO NEXT
*Good improvements, medium effort, most need no DB changes*

### #7 [EXISTING] S1 — AI Timeout Retry Button
**Tags:** `(no DB)`

**Summary:**
- When Groq API times out, show inline retry button in chat bubble instead of a dead error state
- Retry button resends the exact last user message automatically
- No new DB changes — purely UI + LLMService retry logic
- Critical UX fix for Groq free tier timeouts (known limitation)

---

### #8 [EXISTING] S2 — Recurring "Log All" Button
**Tags:** `(no DB)`

**Summary:**
- Single "Log All Due" button on RecurringScreen
- Logs all overdue + due-today recurring items in one tap
- Currently requires tapping "Log Now" per item individually
- Batch insert → single AppEvent.expenseChanged fire after all done
- Show confirmation: "3 recurring bills logged"

---

### #9 [EXISTING] S5 — Want vs Need Expense Tagging
**Tags:** `(DB v11)` `(AI)`

**Summary:**
- Add `is_want INTEGER DEFAULT 0` boolean column to expenses table (DB v11)
- Toggle on AddExpenseScreen + EditExpenseScreen: Need / Want
- AI can tag via chat: "I bought a new game (want) for ₱800"
- AnalyticsScreen: new breakdown — "₱X on Needs, ₱Y on Wants (Z%)"
- Feeds into 50/30/20 tracker Wants/Needs categorization
- Default = Need (0) so existing expenses are unaffected by migration

---

### ✅ #10 [EXISTING] R1 — Recurring Auto-Log on App Open — DONE (chips + Log All)

### ✅ #11 [EXISTING] R2 — AI Context Window Expansion (20 → 50 expenses) — DONE (Session 21)

### ✅ #12 [EXISTING] I6 — Net Worth Installment Integration — DONE (Session 23)

### ✅ #13 [EXISTING] I7 — Spending Streaks & Badges (Gamification) — DONE (Session 23)

### ✅ #14 [EXISTING] I8 — Daily Spending Limit — DONE (Session 23)

### ✅ #15 [EXISTING] I9 — Bill Due Date Calendar View — DONE (Session 23)

### ✅ #16 [NEW] N-B — SSS / PhilHealth / Pag-IBIG Contribution Tracker — DONE (Session 23)
**Tags:** `(no DB)`

**Summary:**
- On app open (main.dart initState or HomeScreen initState), query recurring table for items where next_date <= today
- If any found: show a dismissible card on HomeScreen: "2 bills are due today — log them all?"
- "Log All" button → batch insert → dismiss card
- "Dismiss" → snooze until next app open
- No Cloud Functions needed — pure local date comparison
- Complements #8 (Log All button) and reduces manual work

---

### #11 [EXISTING] R2 — AI Context Window Expansion (20 → 50 expenses)
**Tags:** `(AI)` `(no DB)`

**Summary:**
- In AIChatService.setFullContext(), change expense fetch limit from 20 to 50
- For expenses beyond the most recent 20: summarize by category total e.g. "Last month: ₱4,200 on Food (18 transactions), ₱1,100 on Transport"
- Recent 20 still listed individually with full detail
- Pure prompt engineering change — no DB or UI changes
- Improves AI advice quality significantly for active users

---

### #12 [EXISTING] I6 — Net Worth Installment Integration
**Tags:** `(no DB)`

**Summary:**
- Include installment remaining balances in Net Worth liabilities
- Currently Net Worth = income + manual_assets - expenses - debts
- New formula: also subtract sum of remaining installment balances
- Query installments table in _loadStats() → add to liabilities
- Single function change in the relevant service/screen
- No migration — installments table already exists

---

### #13 [EXISTING] I7 — Spending Streaks & Badges (Gamification)
**Tags:** `(no DB)`

**Summary:**
- Track daily budget compliance from score_history table
- Compute streaks: consecutive days under budget
- Badge types:
  - 🔥 X-day under budget streak
  - 🏆 First ₱1,000 saved
  - 📅 30 days of logging
  - 💯 Health score reached 80+
  - 🎯 Budget not exceeded for a full month
- Badge display as a horizontal scroll row on HomeScreen
- Streak data derived from existing score_history — no new table needed
- Store earned badges in settings table as JSON array

---

### #14 [EXISTING] I8 — Daily Spending Limit
**Tags:** `(no DB)`

**Summary:**
- User sets a daily cap in Profile settings (e.g. ₱300/day)
- Stored in settings table under key `daily_limit`
- HomeScreen shows a daily progress bar: "₱180 / ₱300 today"
- Push notification (flutter_local_notifications) when 80% reached
- Push notification when limit exceeded
- If daily_limit = 0 or not set → feature hidden (opt-in)

---

### #15 [EXISTING] I9 — Bill Due Date Calendar View
**Tags:** `(no DB)`

**Summary:**
- New screen accessible from Hub: "Bill Calendar"
- Monthly calendar view plotting recurring transactions by next_date
- Color coding by category or amount
- Tap a day → see which bills are due
- No new DB queries — uses existing recurring table filtered by next_date
- Month navigation: prev/next arrows

---

### #16 [NEW] N-B — SSS / PhilHealth / Pag-IBIG Contribution Tracker
**Tags:** `(no DB)`

**Summary:**
- Implement as recurring transactions with a special "Government" category
- Preset templates on RecurringScreen for quick setup:
  - SSS Monthly Contribution
  - PhilHealth Monthly Contribution
  - Pag-IBIG Monthly Contribution
- Shows as recurring bills with standard due-date tracking
- No new table — uses existing recurring table
- Relevant for employed users and working students
- Moneygment and Tarsi both have government contribution tracking

---

## TIER 3 — PLAN & BUILD LATER
*Higher complexity or architectural risk — spec before building*

### #17 [EXISTING] S7 — Debt Payment Timeline
- Visual timeline/chart showing projected payoff date per debt
- Based on current payment rate (total paid ÷ months active = monthly rate)
- Tap a debt → see trajectory chart (fl_chart line chart)
- Forward-looking view — currently debts have no projection

### #18 [EXISTING] S8 — Quick-Log Chip Customization
- Currently home chips are auto-derived from top frequent expenses
- Let users pin/unpin specific expenses as permanent quick-log chips
- Stored in settings table as JSON array of expense templates
- Settings screen: "Manage Quick-Log Chips"

### #19 [EXISTING] S9 — Onboarding Financial Quiz
- During setup wizard, collect:
  - Allowance frequency (daily/weekly/monthly)
  - Main spending categories
  - Regular expenses (auto-create as recurring)
  - Existing debts and goals
  - Notification preferences
- Feed answers into AI system prompt for personalized first session
- Adds a setup_quiz_screen or extends existing setup_screen

### #20 [EXISTING] S10 — Export to PDF Monthly Summary
**Tags:** `(new pkg)`
- Clean PDF: total per category, savings, biggest expenses, health score
- Needs `pdf` package + `printing` package (~2MB APK increase)
- More presentable than CSV for semester summary use case
- Share via existing share_plus

### #21 [EXISTING] S11 — Biometric Lock for Sensitive Screens
- Require biometric re-auth before viewing: Debt screen, Net Worth, Export
- Already have local_auth package
- Opt-in toggle per screen in Profile → Security settings

### #22 [EXISTING] S12 — AI Conversation Export
- Export full chat_history as PDF or plain text
- Share via share_plus
- chat_history table already has all data — just formatting needed

### #23 [NEW] N-A — Multiple Account Wallets
**Tags:** `(DB v12+)`
- Named accounts: Cash, GCash, BDO, BPI, Credit Card, etc.
- Each expense tagged to an account (account_id FK on expenses table)
- Balance per account shown in Hub
- Transfer between accounts as a special transaction type
- **MAJOR architectural change** — touches entire expense schema
- **Plan for v2.5+ only. Do NOT attempt during v2.4 development.**

### #24 [EXISTING] I2 — PDF Bank Statement Import
**Tags:** `(new pkg)` `(AI)`
- Import BDO, BPI, UnionBank PDF statements
- Needs syncfusion_flutter_pdf or pdf_text (~5MB APK increase)
- file_picker → extract text → AI multi-transaction parse → bulk import
- Depends on #4 (CSV import) patterns being established first

### #25 [EXISTING] I3 — Password-Protected PDF Import
**Tags:** `(AI)`
- Same as #24 but user enters bank-provided password to decrypt PDF
- Same PDF library handles decryption natively
- Depends on #24 being done first

### #26 [EXISTING] I4 — Multi-Transaction Screenshot Import
**Tags:** `(AI)`
- GCash/bank app screenshot → OCR reads multiple transactions
- AI prompt: "Extract all transactions from this screenshot as a list"
- Bulk import review screen
- Uses existing OCR pipeline (google_mlkit_text_recognition)
- Smarter multi-transaction AI prompt is the main work

---

## TIER 4 — DEFERRED / POST-CAPSTONE
*Blocked by external dependency, paid plan, or too risky now*

| Item | Status | Reason |
|------|--------|--------|
| N-D — Bank Notification Auto-Parsing | BLOCKED | Sensitive Android permission, fragile |
| N2 — AI Savings Plan | DEFERRED | Complex AI logic, advice risk |
| N3 — AI Voice Response / TTS | DEFERRED | flutter_tts robotic; cloud TTS has cost; Groq no TTS |
| N4 — True Single-Screen Receipt Capture | DEFERRED | mobile_scanner v5+ breaking API changes |
| R4 — Offline AI Mode | DEFERRED | Cache last AI insights. Medium effort. |
| I10 — Business / Freelancer Features | DEFERRED | Petty cash, invoice generator. Out of scope now. |
| I11 — Shared / Family Budget | BLOCKED | Multi-user Firestore architecture + invite system |
| D3 — SQLite Encryption | BLOCKED | sqlcipher_flutter_libs — breaking change, requires reinstall |
| D5 — Profile Photo Cross-Device Sync | BLOCKED | Firebase Storage requires Blaze (paid) plan |
| D6 — Cloud Functions & Scheduled Tasks | BLOCKED | Firebase Blaze plan required |
| D-A — Soft-Delete for Sync Resurrection | BLOCKED | deleted_at on all tables — major schema migration |
| Agentic Bill Payment | BLOCKED INDEFINITELY | BSP license + GCash/Maya API not public + PCI-DSS |
| D-B — Typed Models for Goals/Debts/Income | PARKED | No user-visible benefit, high breakage risk |
| P1 — Backend API Proxy | POST-CAPSTONE | Needs backend server |
| P2 — Privacy Policy | POST-CAPSTONE | Needed for Play Store |
| P3 — Data Anonymization | POST-CAPSTONE | Nice to have |

---

## SPECS ALREADY WRITTEN
*(Reference these before coding — do not re-spec)*

- **#1 Custom Categories** → Claude spec: "Feature Spec: Custom Expense Categories"
- **#2 Shake to Undo** → Claude spec: "Feature Spec: Shake to Undo"

All other items (#3–#26) still need full specs written by Claude before Kiro begins implementation.

---

## DB VERSION ROADMAP

| Version | Status | Contents |
|---------|--------|----------|
| v10 | ✅ Live | Previous production DB |
| v11 | ✅ Live | `custom_categories` table + `photo_path` on expenses + `is_want` on expenses + `is_percentage`/`percentage_value` on budgets — deployed Session 23 |
| v12 | 📅 Future | `account_id` on expenses (for #23, plan later) |

**Do NOT split v11 into separate migrations. Bundle everything into one `onUpgrade` block.**

---

## CODING CONVENTIONS REMINDER
- All DB writes fire AppEvent via event_bus for cross-screen refresh
- Theme colors: always use `Theme.of(context).colorScheme.primary` (never hardcode)
- Currency: always use `CurrencyService.format()` and `CurrencyService.symbol`
- Amounts stored in PHP internally, converted for display only
- AI context injected before every message via `AIChatService.setFullContext()`
- Parallelized DB reads using Future.wait pattern
- Error handling: try-catch on all async operations, show SnackBar on error
- **No builds unless explicitly requested by Brix**
- Always run getDiagnostics after changes before building
- Always use: `flutter build apk --release --split-per-abi`
- Test device: `app-arm64-v8a-release.apk` (Poco X6 Pro)

---

*Compiled by Claude for Lucid Frame | April 28, 2026*
*SmartSpend v2.4.0 — Brix A. Directo, Cyrille John M. Rubis, Djaunathan Albert S. Madayag*
