# Month 2–6 Implementation Plan — SmartSpend v3.5.0

**Created:** November 2026  
**Base Version:** v3.4.0+127  
**Status of Prior Work:** Week 1 (WEEK1-001–006) and Month 1 FEAT-001–015 are COMPLETE. Do not re-implement.  
**Source Documents:** MASTER-IMPLEMENTATION-PLAN.md, COMPLETE-GAP-ANALYSIS.md, ALL-TASKS-COMPILED.md, peso-phase2-plan.md, plan.md  

---

## Confirmed File Locations

- **Main website:** `c:\xampp\htdocs\smartspend_app\index.html` (199 KB, confirmed present)  
- **No `docs/index.html`** — only one `index.html` exists at repo root. The `docs/` folder contains research documents, not a website copy.  
- **AndroidManifest.xml:** `c:\xampp\htdocs\smartspend_app\android\app\src\main\AndroidManifest.xml` (confirmed present)  

---

## Ambiguities Resolved

1. **Spending Heatmap (GROUP B-4):** A 5-week × 7-day heatmap already exists in `analytics_screen.dart` (~line 2966). The task calls for a "full month grid" with tap-day details and month navigation. Plan: add a **dedicated full-month calendar heatmap** as a new bottom-sheet widget triggered from the existing heatmap, expanding it to show any selected month.

2. **Smart Recurring Detector (GROUP B-5):** `recurring_helper.dart` only logs/advances recurring items. No auto-detect service exists. Plan: create `recurring_detector.dart` from scratch.

3. **Price Intelligence Phase 2 (GROUP B-7):** `price_intelligence_service.dart` already tracks per-product price comparisons but has no trend detection or chart. Plan: add `detectTrends()` method and a new Trends tab in the existing analytics screen.

4. **Government Receipt OCR (GROUP B-9):** `ocr_service.dart` has `scanReceipt()` and `scanDocument()` but no government-specific logic. Plan: add `detectGovernmentReceipt()` as a static method in the same file.

5. **Net Worth Tracker (GROUP B-10):** A `_NetWorthCard` widget already exists in `profile_screen.dart` (~line 3620) with a 6-month fl_chart. The task asks for a dedicated `net_worth_screen.dart` with assets/liabilities entry and nav entry. Plan: create the new screen, reuse the chart pattern from `_NetWorthCard`.

6. **Peso Phase 2:** Already implemented (10 badges in `achievements_screen.dart`, `peso_voice_service.dart` exists with full context enum, ai_screen.dart wired). The plan.md 9-step plan is fully executed. **Do NOT re-implement.**

---

## pubspec.yaml Additions Required

The following packages are not in `pubspec.yaml` and must be added when their feature is implemented:

| Package | Version | Required By |
|---------|---------|-------------|
| `flutter_sms_inbox` | `^1.1.1` | GROUP B-8 (GCash/Maya SMS Parser) |
| `permission_handler` | `^11.3.0` | GROUP B-8 (READ_SMS permission) |

All other features use packages already in pubspec: `fl_chart ^0.68.0`, `flutter_local_notifications ^17.2.2`, `shared_preferences ^2.3.2`, `sqflite ^2.3.0`, `http ^1.1.0`.

---

## GROUP A — P1 High Priority

---

- [ ] **A-1. Peso Phase 2** — ALREADY COMPLETE

  Verified in codebase: `lib/services/peso_voice_service.dart` exists with full `PesoContext` enum (38 contexts including all 4 greeting variants), `lib/screens/achievements_screen.dart` has all 10 Peso Companion badges in `_allBadges`, badge tracking logic is in `_computeEarned()`, and `ai_screen.dart` already imports `peso_voice_service.dart`. No work needed.

  **Verify:** `flutter analyze lib/services/peso_voice_service.dart lib/screens/achievements_screen.dart lib/screens/ai_screen.dart` — zero errors.

---

- [ ] **A-2. BIR Tax Reminders**

  ### A-2a. Extend `tax_service.dart` with quarterly deadline logic

  `tax_service.dart` currently only has `estimateTax()` and `suggestedSavings()`. Add:
  - `getUpcomingDeadlines()` — returns a `List<Map<String, dynamic>>` of Q1/Q2/Q3/Annual BIR deadlines (Form 1701Q due Apr 15, Jul 15, Oct 15; Form 1700/1701 due Apr 15; Form 2551Q due Apr 25, Jul 25, Oct 25, Jan 25) with `daysUntil` calculated from today.
  - `scheduleAllTaxReminders()` — calls `NotificationService` to schedule local notifications 7 days and 1 day before each deadline. Uses `flutter_local_notifications` already in pubspec.
  - `calculateAnnualTaxEstimate(double monthlyIncome)` — returns annual tax using existing TRAIN Law table logic (wrap the existing `estimateTax()` × 12 with itemized deduction option).
  - `calculateQuarterlyTax(double quarterIncome)` — returns estimated quarterly tax for Form 2551Q (percentage tax = quarterly income × 0.03 for non-VAT registered, or use TRAIN rates for 1701Q).

  **Files:** `lib/services/tax_service.dart`  
  **Verify:** `flutter analyze lib/services/tax_service.dart` — zero errors.

  ### A-2b. Create `tax_screen.dart`

  New screen with 3 tabs via `TabBar`:
  - **Calendar tab:** Shows a `ListView` of upcoming BIR deadlines from `TaxService.getUpcomingDeadlines()`. Each tile shows the form number (e.g., "1701Q — Q1"), due date, and a colored urgency chip (red <7 days, orange 7–30 days, green >30 days). A "Set Reminder" button at the bottom calls `TaxService.scheduleAllTaxReminders()`.
  - **Estimator tab:** `TextField` for monthly income input → shows estimated monthly tax, annual tax, and effective rate. Uses `TaxService.estimateTax()`. Add a "Quarterly (2551Q)" toggle for freelancers.
  - **Calculator tab:** Full-breakdown calculator. User inputs: gross annual income, SSS contributions (optional), PhilHealth contributions (optional), Pag-IBIG contributions (optional). Shows: taxable income, annual tax due, quarterly payments, net effective rate. All math is local — no API calls.

  UI pattern: follow `gov_contributions_screen.dart` (TabController, `SingleTickerProviderStateMixin`, same card/tile style with `cs.surfaceContainerHighest` backgrounds and `cs.primary` accents).

  **Files:** `lib/screens/tax_screen.dart` (create new, ~300 lines)  
  **Verify:** `flutter analyze lib/screens/tax_screen.dart` — zero errors.

  ### A-2c. Add "BIR Tax Reminders" to Tools menu in `home_screen.dart`

  In `_showQuickAccessHub`, find the `'TOOLS'` section list. After the `"Gov Contributions"` entry (~line 1950), insert:
  ```dart
  (
    Icons.calendar_today_outlined,
    "BIR Tax Reminders",
    "Quarterly deadlines, tax estimator, annual calculator",
    Colors.orange,
    () => _go(const TaxScreen())
  ),
  ```
  Add import: `import 'tax_screen.dart';` after the existing egov imports (~line 65).

  **Files:** `lib/screens/home_screen.dart`  
  **Verify:** Hot reload — Tools → BIR Tax Reminders opens the new screen without crash.

---

- [ ] **A-3. LTO Vehicle Compliance**

  ### A-3a. Create `lto_service.dart`

  New service with SQLite-backed vehicle CRUD and renewal logic. The `vehicles` table does not exist yet — the service creates it via `DBService.getDB()` and an `ensureTable()` call that runs `CREATE TABLE IF NOT EXISTS`:
  ```
  vehicles(id INTEGER PRIMARY KEY AUTOINCREMENT, plate TEXT, model TEXT,
           year INTEGER, type TEXT, registration_month INTEGER,
           last_registered INTEGER, notes TEXT)
  ```

  Methods:
  - `ensureTable()` — idempotent `CREATE TABLE IF NOT EXISTS` call.
  - `addVehicle(Map<String, dynamic> data)` — insert row, return id.
  - `getVehicles()` — `SELECT * FROM vehicles ORDER BY id DESC`.
  - `updateVehicle(Map<String, dynamic> data)` — update by id.
  - `deleteVehicle(int id)` — delete by id.
  - `getRenewalStatus(Map<String, dynamic> vehicle)` → `Map<String, dynamic>`:
    - Computes months until `registration_month` (1–12) relative to current month.
    - Returns: `{'daysUntil': int, 'renewalMonth': String, 'isOverdue': bool, 'mvucFee': double}`.
    - MVUC fees are hardcoded per vehicle type: Private Car → ₱1,620, Motorcycle → ₱240, Truck (up to 3.5t) → ₱3,000, PUV (jeepney/bus) → ₱1,000. These are the 2024 MVUC rates from the planning docs — flag in code comments that these may change with LTO circulars.
  - `scheduleRenewalReminders()` — iterates all vehicles and uses `NotificationService` to push a reminder 60 and 30 days before `registration_month`.

  **Files:** `lib/services/lto_service.dart` (create new, ~120 lines)  
  **Verify:** `flutter analyze lib/services/lto_service.dart` — zero errors.

  ### A-3b. Create `lto_screen.dart`

  Screen with two sections:
  - **My Vehicles list:** `FutureBuilder` over `LtoService.getVehicles()`. Each tile shows plate number, model/year, renewal month, and a colored status chip (overdue = red, <30 days = orange, >30 days = green). Tap → edit dialog with plate/model/year/type/registration_month fields. FAB (`Icons.add`) opens the same dialog for adding.
  - **Renewal Calculator card:** Below the list. Static read-only table of MVUC fees per vehicle type. "Schedule Reminders" button calls `LtoService.scheduleRenewalReminders()` and shows a SnackBar confirmation.

  UI pattern: follow `sss_screen.dart` and `pagibig_screen.dart` in `lib/screens/egov/` for the tile and card style.

  **Files:** `lib/screens/lto_screen.dart` (create new, ~280 lines)  
  **Verify:** `flutter analyze lib/screens/lto_screen.dart` — zero errors.

  ### A-3c. Add "LTO Compliance" to eGov menu in `home_screen.dart`

  In the `'TOOLS'` section, after the `"BIR Tax Reminders"` entry added in A-2c, insert:
  ```dart
  (
    Icons.directions_car_outlined,
    "LTO Vehicle Compliance",
    "Registration renewal reminders & MVUC fee schedule",
    Colors.red,
    () => _go(const LtoScreen())
  ),
  ```
  Add import: `import 'lto_screen.dart';`

  **Files:** `lib/screens/home_screen.dart`  
  **Verify:** Hot reload — Tools → LTO Vehicle Compliance opens without crash.

---

## GROUP B — P2 Medium Priority

---

- [ ] **B-4. Spending Heatmap — Full Month Calendar**

  Extends the existing 5-week heatmap in `analytics_screen.dart` (~line 2966) with tap-day details and month navigation. The existing heatmap widget is a `Builder` inside a larger `Column`. The plan is to:
  
  1. Keep the existing 5-week heatmap as-is (do not remove it).
  2. Add a "View Full Calendar →" `TextButton` immediately below it.
  3. Tapping that button calls `_showFullMonthHeatmap(context)` — a new private method that opens a `showModalBottomSheet` with `isScrollControlled: true`.
  
  The bottom sheet contains:
  - **Month navigation row:** `<` arrow, "Month Year" label (e.g., "November 2026"), `>` arrow. Stateful via `StatefulBuilder`. Clamps at current month (cannot navigate to future) and earliest expense month.
  - **Full-month day grid:** 7-column grid (Mon–Sun headers). Each cell is a 36×36 rounded square colored by daily spend intensity (same 4-level color scale as existing heatmap). Cells outside the current month are transparent/dimmed.
  - **Tap-day detail panel:** Tapping a day shows a mini-panel below the grid with the date, total spent, and a `ListView` of expenses for that day (item_name, amount, category icon). Uses `DBService.getExpenses()` already loaded in `_expenses`.

  All data comes from `_expenses` already loaded in `_AnalyticsScreenState` — no new DB calls needed.

  **Files:** `lib/screens/analytics_screen.dart`  
  **Verify:** `flutter analyze lib/screens/analytics_screen.dart` — zero errors; tap "View Full Calendar" in app — bottom sheet opens, month nav changes grid, tapping a day shows expenses.

---

- [ ] **B-5. Smart Recurring Detector**

  ### B-5a. Create `recurring_detector.dart`

  New service that scans the last 90 days of expenses for recurring patterns. Place in `lib/services/`.

  `detectRecurringCandidates()` → `Future<List<Map<String, dynamic>>>`:
  1. Load last 90 days of expenses via `DBService.getExpenses()`.
  2. Group by normalized `item_name` (lowercase, strip punctuation).
  3. For each group with ≥3 occurrences, check if inter-occurrence gap is consistent: compute all consecutive-pair day-deltas, calculate mean and stddev. If stddev/mean < 0.3 (coefficient of variation <30%), it's a pattern.
  4. Classify frequency: mean delta 6–8 days → weekly; 13–16 days → biweekly; 27–33 days → monthly.
  5. Return candidates as `[{'item_name': String, 'amount': double, 'frequency': String, 'lastDate': String, 'occurrences': int}]`.
  6. Exclude items already in the `recurring` table (query `SELECT title FROM recurring` and filter out matches).

  **Files:** `lib/services/recurring_detector.dart` (create new, ~100 lines)  
  **Verify:** `flutter analyze lib/services/recurring_detector.dart` — zero errors.

  ### B-5b. Add suggestion cards to `home_screen.dart`

  In the home screen's dashboard `ListView`, after the existing recurring-bills chip row (search for `_buildRecurringChips` or similar), add a `FutureBuilder<List<Map<String, dynamic>>>` that calls `RecurringDetector.detectRecurringCandidates()`. If the result list is non-empty, show a horizontal scroll row of suggestion cards. Each card shows: "📌 {item_name} — ₱{amount} every {frequency}" with two buttons: "Add to Recurring" (calls `DBService.insertRecurring(...)` and `fireEvent`) and "Dismiss" (stores dismissed item names in `SharedPreferences` key `'recurring_dismissed'` as JSON list; re-filter on next load).

  Cap display at 3 cards to avoid overwhelming the home screen. Only call `detectRecurringCandidates()` once per app session (cache result in a static variable in the service).

  Add import: `import '../services/recurring_detector.dart';`

  **Files:** `lib/screens/home_screen.dart`  
  **Verify:** `flutter analyze lib/screens/home_screen.dart` — zero errors; add 3+ expenses with same name on roughly monthly intervals — suggestion card appears.

---

- [ ] **B-6. Savings Streak & Challenges**

  ### B-6a. Create `streak_service.dart`

  New service in `lib/services/`. Two responsibilities:
  
  **Savings streak logic:**
  - `getSavingsStreak()` → `Future<int>`: counts consecutive months (ending with current) where `income - expenses > 0` (positive net for the month). Queries `DBService.getTotalIncome(month:)` and `DBService.getTotalSpent(month:)` for each of the last 12 months. Returns the streak count.
  - `getCurrentStreakStatus()` → `Future<Map<String, dynamic>>`: returns `{'streak': int, 'savingsRateThisMonth': double, 'goalProgress': double, 'message': String}`. Message is from `PesoVoiceService.get(PesoContext.generalEncouragement)` for 0-streak, `PesoContext.streak3` for 3+, etc.

  **Monthly challenges:**
  - Hardcoded list of 4 monthly challenges (rotate by month number):
    - Month A: "No-spend weekends" — log zero expenses on 4 consecutive weekend days.
    - Month B: "Under-budget month" — stay under all category budgets for the full month.
    - Month C: "Save 20%" — net savings ≥ 20% of income.
    - Month D: "Log every day" — expense entry on every calendar day of the month.
  - `getCurrentChallenge()` → `Map<String, dynamic>`: returns active challenge for current month.
  - `getChallengeProgress()` → `Future<double>`: returns 0.0–1.0 progress for current challenge.

  **Files:** `lib/services/streak_service.dart` (create new, ~120 lines)  
  **Verify:** `flutter analyze lib/services/streak_service.dart` — zero errors.

  ### B-6b. Create `challenges_screen.dart`

  New screen in `lib/screens/`. Shows:
  - **Savings streak card at top:** Large number (streak months), flame emoji 🔥, Peso message.
  - **Current monthly challenge section:** Challenge name, description, animated `LinearProgressIndicator` showing `StreakService.getChallengeProgress()`.
  - **Past challenges row:** Last 3 months as small chips (✅ completed / ❌ missed), computed from `getSavingsStreak()` history.
  - **Streak milestone badges:** "3-month saver" 🥉, "6-month saver" 🥈, "12-month saver" 🥇 — shown earned/locked like `achievements_screen.dart` badges.

  **Files:** `lib/screens/challenges_screen.dart` (create new, ~220 lines)  
  **Verify:** `flutter analyze lib/screens/challenges_screen.dart` — zero errors.

  ### B-6c. Add streak widget to home screen and Tools entry

  In `home_screen.dart`:
  1. Add a small streak widget to the dashboard — a compact row card (height ~72px) showing "🔥 {n}-month savings streak" or "Start your savings streak!" if 0. Tap → navigates to `ChallengesScreen`. Position: after the Safe-to-Spend card (which is after the wallet card).
  2. Add to Tools menu (TOOLS section): `("Savings Streak & Challenges", ...)` → `_go(const ChallengesScreen())`.

  Add import: `import 'challenges_screen.dart';`, `import '../services/streak_service.dart';`

  **Files:** `lib/screens/home_screen.dart`  
  **Verify:** `flutter analyze lib/screens/home_screen.dart` — zero errors; streak card visible on home screen.

---

- [ ] **B-7. Price Intelligence Phase 2 — Trend Detection + Trends Tab**

  `price_intelligence_service.dart` already has per-product price comparison. Phase 2 adds:

  ### B-7a. Add `detectTrends()` to `price_intelligence_service.dart`

  New static method `detectTrends()` → `Future<List<Map<String, dynamic>>>`:
  1. Load all prices via `getAllPrices()` (already exists).
  2. Group by normalized product name.
  3. For each product with ≥3 price records across ≥2 different months:
     - Compute linear regression slope (simple: (last_price - first_price) / days_between).
     - If slope > 0.05 per day (rising ≥₱5/100 days), classify as `'rising'`.
     - If slope < -0.05 per day, classify as `'falling'`.
     - Else `'stable'`.
  4. Return `[{'productName': String, 'trend': String, 'firstPrice': double, 'lastPrice': double, 'changePercent': double, 'bestTimeToBuy': String}]`.
  5. `bestTimeToBuy`: for `'rising'` items → "Buy now before prices increase further"; for `'falling'` items → "Consider waiting — price is dropping"; for `'stable'` → "Price is stable".

  **Files:** `lib/services/price_intelligence_service.dart`  
  **Verify:** `flutter analyze lib/services/price_intelligence_service.dart` — zero errors.

  ### B-7b. Add "Trends" tab to Price Intelligence in `analytics_screen.dart`

  The analytics screen already has a Price Intelligence alert card (search for `FEAT-002: Price Intelligence Alert Card` around line 6781 in home_screen.dart — the actual chart is in analytics). Add a "Trends" tab to the existing price-related section in `analytics_screen.dart`:
  
  - Find the `// FEAT-002` price section in analytics_screen. Convert the section from a plain `Builder` into a `DefaultTabController` with two tabs: "Alerts" (existing content) and "Trends" (new content).
  - The Trends tab shows a `FutureBuilder` over `PriceIntelligenceService.detectTrends()`. For each trending item, display: product name, trend direction emoji (📈/📉/➡️), change percentage, and an `fl_chart` `LineChart` showing price history. The LineChart uses `FlSpot(dayIndex, price)` pairs from `PriceIntelligenceService.getPriceTrend(productName)`. Show at most 5 trending items.
  - If no price data: show "No price history yet — scan receipts with itemized products to build your price database."

  **Files:** `lib/screens/analytics_screen.dart`  
  **Verify:** `flutter analyze lib/screens/analytics_screen.dart` — zero errors; analytics → price section → Trends tab shows trend list.

---

- [ ] **B-8. GCash/Maya SMS Parser**

  ### B-8a. Add pubspec dependencies

  Add to `pubspec.yaml` under `dependencies:`:
  ```yaml
  flutter_sms_inbox: ^1.1.1
  permission_handler: ^11.3.0
  ```
  Run `flutter pub get`.

  **Files:** `pubspec.yaml`  
  **Verify:** `flutter pub get` exits 0, no version conflicts.

  ### B-8b. Add READ_SMS permission to `AndroidManifest.xml`

  In `android/app/src/main/AndroidManifest.xml`, after the existing `POST_NOTIFICATIONS` permission line, add:
  ```xml
  <!-- Required for GCash/Maya SMS Parser feature (opt-in, user can disable) -->
  <uses-permission android:name="android.permission.READ_SMS"/>
  ```
  Note: READ_SMS is a sensitive permission. The feature is opt-in and gated behind a Settings toggle (see B-8d). The permission is declared but only requested at runtime when the user enables the toggle.

  **Files:** `android/app/src/main/AndroidManifest.xml`  
  **Verify:** File parses without error (open in browser or run `flutter build apk --debug` after all B-8 steps).

  ### B-8c. Create `sms_parser_service.dart`

  New service in `lib/services/`. Responsibilities:
  - `requestPermission()` → `Future<bool>`: uses `permission_handler` to request `Permission.sms`. Returns true if granted.
  - `fetchRecentSms({int days = 30})` → `Future<List<Map<String, dynamic>>>`: reads SMS inbox via `flutter_sms_inbox`, filters to messages from senders matching `RegExp(r'GCash|Maya|BPI|BDO|Metrobank|UnionBank|RCBC|Security Bank', caseSensitive: false)`, returns last `days` days worth.
  - `parseTransaction(String body)` → `Map<String, dynamic>?`: regex-based parser. Patterns:
    - GCash sent: `r'You sent ₱([\d,]+(?:\.\d{2})?) to (.+?) on'` → `{'type': 'sent', 'amount': double, 'recipient': String}`
    - GCash received: `r'You received ₱([\d,]+(?:\.\d{2})?) from (.+?)\.'` → `{'type': 'received', ...}`
    - Maya debit: `r'Your Maya account was debited ₱([\d,]+(?:\.\d{2})?) at (.+?)\.'` → `{'type': 'debit', ...}`
    - GCash cash-in: `r'Cash In of ₱([\d,]+(?:\.\d{2})?) via (.+?) was successful'` → `{'type': 'cash_in', ...}`
    - Returns `null` if no pattern matches.
  - `getParsedTransactions({int days = 30})` → `Future<List<Map<String, dynamic>>>`: calls `fetchRecentSms` then maps each message through `parseTransaction`, filters nulls, deduplicates by amount+date.

  **Files:** `lib/services/sms_parser_service.dart` (create new, ~120 lines)  
  **Verify:** `flutter analyze lib/services/sms_parser_service.dart` — zero errors.

  ### B-8d. Add Settings toggle and confirmation dialog in `settings_screen.dart`

  In `settings_screen.dart`, find the Notifications section (search for `billRemindersEnabled`). Add a new toggle after it:
  - State variable: `bool _smsParserEnabled = false`
  - Load from `DBService.getSetting('sms_parser_enabled')` in `_loadSettings()`.
  - Toggle tile: "GCash/Maya SMS Import" with subtitle "Read SMS to auto-detect transactions. Requires SMS permission."
  - On toggle ON: show `AlertDialog` confirmation:
    > "SmartSpend will read your SMS inbox to find GCash and Maya transactions. No messages are sent to any server — all parsing happens on your device. Only financial transactions from known senders are imported."
    > Buttons: "Enable" / "Cancel"
    > On "Enable": call `SmsParserService.requestPermission()`. If permission denied, show SnackBar "SMS permission denied — feature unavailable". If granted, save `'sms_parser_enabled'` = `'1'` in DB settings.
  - On toggle OFF: save `'0'`, no confirmation needed.

  Add import: `import '../services/sms_parser_service.dart';`

  **Files:** `lib/screens/settings_screen.dart`  
  **Verify:** `flutter analyze lib/screens/settings_screen.dart` — zero errors; toggle appears in Settings, confirmation dialog shows on enable.

---

- [ ] **B-9. Government Receipt OCR Enhancement**

  ### B-9a. Add `detectGovernmentReceipt()` to `ocr_service.dart`

  New static method in `OCRService`. Add after `scanDocument()`:
  ```dart
  /// Detects if OCR text is from a Philippine government receipt.
  /// Returns a map with keys: 'isGov' (bool), 'agency' (String?), 'orNumber' (String?),
  /// 'amount' (double?), 'payerName' (String?), 'date' (String?).
  static Map<String, dynamic> detectGovernmentReceipt(String ocrText) { ... }
  ```

  Detection logic (all regex against `ocrText.toLowerCase()`):
  - Agency patterns: `RegExp(r'bir|bureau of internal revenue')` → "BIR"; `RegExp(r'lto|land transportation office')` → "LTO"; `RegExp(r'bayad center')` → "Bayad Center"; `RegExp(r'sss|social security system')` → "SSS"; `RegExp(r'philhealth|phil health')` → "PhilHealth"; `RegExp(r'pag-?ibig|hdmf')` → "Pag-IBIG"; `RegExp(r'nbi|national bureau of investigation')` → "NBI".
  - OR number: `RegExp(r'o\.?r\.?\s*(?:no\.?|number)?\s*:?\s*(\d{4,})', caseSensitive: false)` — capture group 1.
  - Amount: `RegExp(r'(?:total|amount|paid)\s*:?\s*₱?\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false)` — capture group 1, parse double.
  - Date: `RegExp(r'\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}')` — first match.
  - Payer name: `RegExp(r'(?:name|taxpayer|payor)\s*:?\s*([A-Z][A-Z ,\.]+)', caseSensitive: false)` — capture group 1.

  Returns `{'isGov': true/false, 'agency': String?, 'orNumber': String?, 'amount': double?, 'payerName': String?, 'date': String?}`.

  **Files:** `lib/services/ocr_service.dart`  
  **Verify:** `flutter analyze lib/services/ocr_service.dart` — zero errors.

  ### B-9b. Wire detection into AI receipt scan flow in `ai_screen.dart`

  In `ai_screen.dart`, find the receipt scan result handler (search for `scanReceipt` call or `OCRService.scanReceipt`). After OCR text is retrieved, call:
  ```dart
  final govData = OCRService.detectGovernmentReceipt(ocrText);
  ```
  If `govData['isGov'] == true`:
  1. Prepend a banner to the scan review: "🏛️ Government receipt detected: {agency}. OR No: {orNumber}."
  2. Auto-populate category as `govData['agency']` (e.g., "BIR", "LTO").
  3. After the expense is logged, check if the user has the `'gov_receipt'` badge (new badge to add in B-9c).

  **Files:** `lib/screens/ai_screen.dart`  
  **Verify:** `flutter analyze lib/screens/ai_screen.dart` — zero errors.

  ### B-9c. Add government receipt badge to `achievements_screen.dart`

  Add one new badge to `_allBadges` after `'chat_session_10'`:
  ```dart
  _Badge('🏛️', 'Gov Receipts Pro', 'Scan 3 government receipts', 'gov_receipt_3'),
  ```
  Add tracking in `_computeEarned()`: query `DBService.getScanHistory(limit: 500)` and count entries where `source` or notes contain agency keywords. If ≥3, `earned.add('gov_receipt_3')`.

  Alternatively, since scan history may not tag gov receipts, track via `SharedPreferences` key `'gov_receipt_scan_count'` (incremented in B-9b when a gov receipt is logged).

  **Files:** `lib/screens/achievements_screen.dart`  
  **Verify:** `flutter analyze lib/screens/achievements_screen.dart` — zero errors.

---

- [ ] **B-10. Net Worth Tracker Screen**

  `profile_screen.dart` already has a `_NetWorthCard` widget with a 6-month fl_chart and wallet-based calculation. Create a dedicated full-screen version.

  ### B-10a. Create `net_worth_screen.dart`

  New screen in `lib/screens/`. Sections:
  - **Summary card at top:** Total net worth = wallet balances + logged income − total expenses − outstanding debts. Reuse calculation from `_NetWorthCardState` in `profile_screen.dart` (~line 3630). Display as large colored number.
  - **Assets section:** `ListView` of asset entries: wallets (from `DBService.getWallets()`), savings goals current amounts (from `DBService.getGoals()`). Total assets shown as section header.
  - **Liabilities section:** `ListView` of liability entries: debts owed (from `DBService.getDebts()` where `type == 'owe'`). Total liabilities shown as section header.
  - **Trend chart:** `fl_chart` `LineChart` showing 6-month net worth history. Data: for each of the last 6 months, compute net worth using the same formula. Each month's income/expense totals come from `DBService.getTotalIncome(month:)` and `DBService.getTotalSpent(month:)`. Use `FlSpot(monthIndex, netWorth)`. Pattern: copy `_NetWorthCardState._buildSpots()` logic from `profile_screen.dart`.
  - No manual entry needed — all data comes from existing DB tables. No new tables.

  **Files:** `lib/screens/net_worth_screen.dart` (create new, ~280 lines)  
  **Verify:** `flutter analyze lib/screens/net_worth_screen.dart` — zero errors.

  ### B-10b. Add nav entry in `home_screen.dart`

  In the Tools menu (TOOLS section), add after the `"Cash Flow Forecast"` entry:
  ```dart
  (
    Icons.account_balance_outlined,
    "Net Worth Tracker",
    "Assets, liabilities, and 6-month trend chart",
    Colors.indigo,
    () => _go(const NetWorthScreen())
  ),
  ```
  Add import: `import 'net_worth_screen.dart';`

  **Files:** `lib/screens/home_screen.dart`  
  **Verify:** `flutter analyze lib/screens/home_screen.dart` — zero errors; Tools → Net Worth Tracker opens without crash.

---

## GROUP C — P3 Low Priority

---

- [ ] **C-11. Investment Portfolio Tracker**

  ### C-11a. Create `investment_screen.dart`

  New screen in `lib/screens/`. Manual entry only — no external APIs. Three sections via `TabBar`:
  - **PSE Stocks tab:** Add/edit/delete stock holdings. Fields: ticker symbol (e.g., "BDO"), shares owned, average cost per share, current price (manual entry). Shows: total cost basis, current value, gain/loss amount and %, unrealized P&L color-coded green/red. Table stored in new SQLite table `investments` via `DBService.getDB()` with `CREATE TABLE IF NOT EXISTS investments(id, type TEXT, ticker TEXT, name TEXT, shares REAL, avg_cost REAL, current_price REAL, last_updated TEXT)`.
  - **MP2 tab:** Manual Pag-IBIG MP2 entries. Fields: contribution amount, start date, term (5-year). Shows: projected maturity value using 7.03% annual dividend rate (the 2023 MP2 declared dividend — hardcode and annotate that actual rates vary year to year). Uses PCA calculator logic from existing `pca_calculator_screen.dart`.
  - **UITF tab:** Manual UITF entries. Fields: fund name, number of units, NAVPU (Net Asset Value Per Unit) at purchase, current NAVPU. Shows: gain/loss. No live prices — user updates manually.

  **Files:** `lib/screens/investment_screen.dart` (create new, ~350 lines)  
  **Verify:** `flutter analyze lib/screens/investment_screen.dart` — zero errors.

  ### C-11b. Add Tools entry in `home_screen.dart`

  In TOOLS section, add: `("Investment Portfolio", ...) → _go(const InvestmentScreen())`.  
  Add import: `import 'investment_screen.dart';`

  **Files:** `lib/screens/home_screen.dart`  
  **Verify:** `flutter analyze lib/screens/home_screen.dart` — zero errors.

---

- [ ] **C-12. Multi-Currency Support**

  ### C-12a. Extend `currency_service.dart`

  `currency_service.dart` likely already handles display currency. Add:
  - Hardcoded exchange rates map (10 currencies vs PHP): USD, EUR, GBP, JPY, SGD, AUD, CAD, HKD, CNY, KRW. Comment: "Rates as of November 2026 — update manually each release."
  - `convertFromPHP(double amount, String currency)` → `double`: divides by rate.
  - `convertToPHP(double amount, String currency)` → `double`: multiplies by rate.
  - `getAvailableCurrencies()` → `List<String>`: returns the 10 currency codes plus `'PHP'`.

  **Files:** `lib/services/currency_service.dart`  
  **Verify:** `flutter analyze lib/services/currency_service.dart` — zero errors.

  ### C-12b. Add currency selector to `settings_screen.dart`

  The existing `currency_screen.dart` already handles display currency. Check if it already covers all 10 currencies. If the existing `CurrencyScreen` only supports a subset, add the missing currencies to its list. If it already covers 34+ currencies (as stated in the Tools entry "34+ currencies"), only add conversion rates to `currency_service.dart` for the 10 specified currencies (USD, EUR, GBP, JPY, SGD, AUD, CAD, HKD, CNY, KRW) if not already present.

  **Files:** `lib/services/currency_service.dart`, `lib/screens/currency_screen.dart` (modify only if needed)  
  **Verify:** `flutter analyze lib/screens/currency_screen.dart` — zero errors; Settings → Display Currency shows all 10 currencies plus PHP.

  ### C-12c. Update home and analytics displays

  In `home_screen.dart` and `analytics_screen.dart`, any `CurrencyService.formatNumber()` or `₱` hardcode is already the standard format. The existing `CurrencyService.formatNumber()` should already respect the selected currency. If it does not, update it to prefix with the selected currency symbol and apply the conversion rate from `convertFromPHP()`.

  **Files:** `lib/services/currency_service.dart` (update `formatNumber()` if needed)  
  **Verify:** Set display currency to USD → all amounts on home screen show "$" prefix with converted values.

---

- [ ] **C-13. Notification Listener (Android)**

  This feature requires a native Android `NotificationListenerService`. It is a significant Android-platform feature.

  ### C-13a. Create Android `NotificationListenerService`

  Create `android/app/src/main/kotlin/com/example/smartspend_app/NotificationService.kt` (or `java/` if the project uses Java). The service:
  - Extends `android.service.notification.NotificationListenerService`.
  - Overrides `onNotificationPosted(StatusBarNotification sbn)`.
  - Filters for GCash (`com.globe.gcash.android`) and Maya (`ph.paymaya.app`) package names.
  - Extracts notification title + text, sends to Flutter via `MethodChannel('smartspend/notifications')`.

  Add to `AndroidManifest.xml`:
  ```xml
  <service
      android:name=".NotificationService"
      android:label="SmartSpend Notification Listener"
      android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
      android:exported="true">
    <intent-filter>
      <action android:name="android.service.notification.NotificationListenerService"/>
    </intent-filter>
  </service>
  ```
  
  **Files:**  
  - `android/app/src/main/kotlin/com/example/smartspend_app/NotificationService.kt` (create new)  
  - `android/app/src/main/AndroidManifest.xml`  
  **Verify:** `flutter build apk --debug` exits 0 — Kotlin compiles without error.

  ### C-13b. Add MethodChannel handler in Flutter (new `notification_listener_service.dart`)

  New service in `lib/services/`. Sets up `MethodChannel('smartspend/notifications')` and `setMethodCallHandler`. On incoming `'onNotification'` call, routes the payload to `SmsParserService.parseTransaction()` (reuse regex from B-8c). If a transaction is parsed and the user has the toggle enabled, show a `flutter_local_notifications` confirmation notification: "SmartSpend detected a {GCash/Maya} transaction. Tap to review."

  Requires permission: `Notification access` (the user must grant it in Android Settings → Apps → Special App Access → Notification Access). Add a helper dialog in `settings_screen.dart` that opens the system settings page when the user enables the Notification Listener toggle: `AndroidIntent` or `url_launcher` to `android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS`.

  **Files:** `lib/services/notification_listener_service.dart` (create new, ~80 lines)  
  **Verify:** `flutter analyze lib/services/notification_listener_service.dart` — zero errors.

  ### C-13c. Add Settings toggle in `settings_screen.dart`

  After the SMS Parser toggle (B-8d), add a new toggle: "GCash/Maya Notification Listener". On enable: check if notification access is granted (query via platform channel). If not, open `android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS`. Same privacy confirmation dialog pattern as B-8d.

  **Files:** `lib/screens/settings_screen.dart`  
  **Verify:** `flutter analyze lib/screens/settings_screen.dart` — zero errors; toggle opens notification access settings when enabled.

---

## GROUP D — Website Redesign

---

- [ ] **D-14. Website Redesign** (`index.html` at repo root)

  The `plan.md` file contains a 9-item detailed specification. The items below summarize what to do and reference exact sections from that document.

  > **Critical constraint:** Do NOT touch the 23 `<div class="swiper-slide"` carousel slides, any Swiper CDN links, or any JS functions listed in plan.md's DO-NOT-TOUCH table.

  ### D-14a. Items 1–3: CSS Variables + Fonts, Peso SVG Sprite, Nav

  - **Item 1 (CSS Variables + Fonts):** Replace `:root` and `[data-theme="light"]` blocks with the new color system from plan.md Item 1. Add Google Fonts preconnect links before the Swiper CSS. Update `body` font-family to `'Inter'`. Add `h1, h2, h3` rule using `'Plus Jakarta Sans'`. Update theme-toggle JS IIFE: `#0f1117` → `#0d1a0f` (dark), `#f8f9fa` → `#f4f0e6` (light).
  - **Item 2 (Peso SVG Sprite):** Insert hidden `<svg id="peso-sprite">` element immediately after `<body>`, before `<nav>`. Add `.peso-mascot` CSS rule. Full SVG content in plan.md Item 2.
  - **Item 3 (Nav):** Update nav backdrop-filter to `blur(16px)`. Update `.nav-brand` to blue + Plus Jakarta Sans. Replace `.nav-cta` with gradient pill style. Add `<a href="#privacy-ai">Privacy</a>` link in both desktop nav-links and mobile menu.

  **Files:** `index.html`  
  **Verify:** `Select-String -Path index.html -Pattern "0d1a0f" | Measure-Object` → Count ≥ 2; `Select-String -Path index.html -Pattern "Plus Jakarta" | Measure-Object` → Count ≥ 2.

  ### D-14b. Items 4–6: Hero, Stats Bar, Features Grid

  - **Item 4 (Hero Section):** Remove `.hero-orb` divs and their CSS. Rewrite hero to two-column flex layout. Left column: badge, h1, p, buttons, meta. Right column: Peso SVG (120px) + app icon. Mobile: flex-direction column, mascot on top. Full HTML/CSS in plan.md Item 4.
  - **Item 5 (Stats Bar):** Wrap `<div class="stats">` in a `<div class="stats-card">`. Remove individual stat backgrounds — use right-border dividers. Update `.stat-number` font to Plus Jakarta Sans.
  - **Item 6 (Features Grid):** Wrap each feature emoji in `<div class="feature-icon-wrap">`. Add `.feature-icon-wrap` CSS (green glow circle). Add two new feature cards at end of grid: `📴 Full Offline Mode` and `🗂️ Smart Export & Backup`. Update existing `🔒 Local AI` card description per plan.md spec.

  **Files:** `index.html`  
  **Verify:** Open in browser. Desktop hero shows two columns. Stats render in a single card. All existing feature cards visible. Two new cards appear at end of features grid.

  ### D-14c. Items 7–9: AI Section, Privacy-AI Section, Verification

  - **Item 7 (AI / Peso Section Restyle):** Update `.ai-section` CSS. Replace h2 with `<div class="ai-heading">` containing 48px Peso SVG + h2 text. Add `bubble-you` / `bubble-peso` classes to chat example divs. Add small Peso avatar to Peso reply bubble.
  - **Item 8 (New Privacy-AI Section):** Insert new `<section class="privacy-ai-section" id="privacy-ai">` between the closing `</section>` of `#ai` and the `<section class="screenshots-section" id="screenshots">`. Full HTML + CSS in plan.md Item 8. This section has: Part A (current local AI features, architecture diagram), Part B (on-device roadmap card with model chips).
  - **Item 9 (Verification):** Confirm all swiper slides are intact (count: `Select-String -Path index.html -Pattern 'swiper-slide' | Measure-Object` → Count ≥ 23). Confirm Privacy nav link scrolls to `#privacy-ai`. Confirm lightbox/theme toggle/hamburger JS functions unchanged.

  **Files:** `index.html`  
  **Verify:** `Select-String -Path index.html -Pattern "privacy-ai" | Measure-Object` → Count ≥ 3 (section id, nav link, mobile nav). Browser: dark/light mode toggle works. Carousel still scrolls.

---

## Digest

### Files Modified

| File | Block / Signature | Covered By | Verified Today |
|------|------------------|------------|----------------|
| `lib/services/tax_service.dart` | Add `getUpcomingDeadlines()`, `scheduleAllTaxReminders()`, `calculateAnnualTaxEstimate()`, `calculateQuarterlyTax()` | A-2a | `flutter analyze` — zero errors |
| `lib/screens/tax_screen.dart` | New file — `TaxScreen`, `TabController` with 3 tabs | A-2b | `flutter analyze` — zero errors |
| `lib/screens/home_screen.dart` | `_showQuickAccessHub` TOOLS list (~line 1922); imports block (~line 63) | A-2c, A-3c, B-5b, B-6c, B-10b, C-11b, C-12c | `flutter analyze` — zero errors |
| `lib/services/lto_service.dart` | New file — `LtoService`, `vehicles` table CRUD | A-3a | `flutter analyze` — zero errors |
| `lib/screens/lto_screen.dart` | New file — `LtoScreen`, vehicle list + calculator | A-3b | `flutter analyze` — zero errors |
| `lib/screens/analytics_screen.dart` | Existing heatmap Builder (~line 2966): add "View Full Calendar" button + `_showFullMonthHeatmap()`; Price section: add Trends tab | B-4, B-7b | `flutter analyze` — zero errors |
| `lib/services/recurring_detector.dart` | New file — `RecurringDetector.detectRecurringCandidates()` | B-5a | `flutter analyze` — zero errors |
| `lib/services/streak_service.dart` | New file — `StreakService.getSavingsStreak()`, `getCurrentChallenge()`, `getChallengeProgress()` | B-6a | `flutter analyze` — zero errors |
| `lib/screens/challenges_screen.dart` | New file — `ChallengesScreen` with streak + challenges | B-6b | `flutter analyze` — zero errors |
| `lib/services/price_intelligence_service.dart` | Add `detectTrends()` after `getAllPrices()` (last method in file) | B-7a | `flutter analyze` — zero errors |
| `pubspec.yaml` | Add `flutter_sms_inbox: ^1.1.1`, `permission_handler: ^11.3.0` under `dependencies` | B-8a | `flutter pub get` exits 0 |
| `android/app/src/main/AndroidManifest.xml` | Add `READ_SMS` permission; Add `NotificationListenerService` service entry (C-13) | B-8b, C-13a | `flutter build apk --debug` exits 0 |
| `lib/services/sms_parser_service.dart` | New file — `SmsParserService` with `requestPermission()`, `parseTransaction()`, `getParsedTransactions()` | B-8c | `flutter analyze` — zero errors |
| `lib/screens/settings_screen.dart` | Add `_smsParserEnabled` toggle + confirmation dialog (~after `billRemindersEnabled`); add notification listener toggle (C-13c) | B-8d, C-13c | `flutter analyze` — zero errors |
| `lib/services/ocr_service.dart` | Add `detectGovernmentReceipt(String ocrText)` after `scanDocument()` | B-9a | `flutter analyze` — zero errors |
| `lib/screens/ai_screen.dart` | Find OCR result handler: call `detectGovernmentReceipt()` and handle banner + badge increment | B-9b | `flutter analyze` — zero errors |
| `lib/screens/achievements_screen.dart` | Add `gov_receipt_3` badge to `_allBadges`; add tracking in `_computeEarned()` | B-9c | `flutter analyze` — zero errors |
| `lib/screens/net_worth_screen.dart` | New file — `NetWorthScreen` with assets/liabilities list + fl_chart trend | B-10a | `flutter analyze` — zero errors |
| `lib/screens/investment_screen.dart` | New file — `InvestmentScreen` with PSE/MP2/UITF tabs | C-11a | `flutter analyze` — zero errors |
| `lib/services/currency_service.dart` | Add hardcoded exchange rates map + `convertFromPHP()`, `convertToPHP()` | C-12a | `flutter analyze` — zero errors |
| `lib/screens/currency_screen.dart` | Add missing currencies to list if needed | C-12b | `flutter analyze` — zero errors |
| `android/app/src/main/kotlin/.../NotificationService.kt` | New file — Android NotificationListenerService extending class | C-13a | `flutter build apk --debug` exits 0 |
| `lib/services/notification_listener_service.dart` | New file — Flutter MethodChannel handler for notification intercept | C-13b | `flutter analyze` — zero errors |
| `index.html` (repo root) | CSS `:root` / `[data-theme="light"]`; `<body>` SVG sprite; nav HTML; hero HTML; stats-card wrapper; features-grid additions; ai-section heading/bubbles; new privacy-ai section | D-14a–c | Browser visual check + `Select-String` counts |

### Build + Test Commands

**Analyze (run after every file change):**
```powershell
cd c:\xampp\htdocs\smartspend_app
flutter analyze
```
Expected: `No issues found!` (or only pre-existing warnings from files not touched by this plan).

**Build verification (run after each group is complete):**
```powershell
flutter build apk --debug
```
Expected: exits 0, `build\app\outputs\flutter-apk\app-debug.apk` produced.

**After pubspec changes (B-8a):**
```powershell
flutter pub get
```
Expected: exits 0, `pubspec.lock` updated.

**Website verification (D-14):**
```powershell
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "swiper-slide" | Measure-Object | Select-Object Count
# Count must be >= 46 (each of 23 slides appears twice: opening + closing div)
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "0d1a0f" | Measure-Object | Select-Object Count
# Count must be >= 2
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "privacy-ai" | Measure-Object | Select-Object Count
# Count must be >= 3
```

### Dependency Order

GROUP A must be implemented in order: A-2 → A-3 (both depend on `home_screen.dart` Tools menu, so do them sequentially to avoid merge conflicts in the same list).

GROUP B items are independent of each other and of GROUP A. Any order within GROUP B is valid, with one exception: B-8a (pubspec) must precede B-8b/B-8c/B-8d. B-9a must precede B-9b.

GROUP C items are independent of each other and of GROUP B.

GROUP D (website) is entirely independent of Groups A/B/C.

Suggested implementation order for minimum re-opening of files:
1. A-2 (tax) → A-3 (LTO) — both add to home_screen.dart once at the end
2. B-5 (recurring detector) → B-6 (streak) → B-10 (net worth) → B-4 (heatmap) → B-7 (price trends) — these all modify different files
3. B-8 (SMS) → B-9 (OCR) → C-13 (notification) — permission/Android changes together
4. C-11 (investment) → C-12 (currency)
5. D-14 (website) — isolated, do last
