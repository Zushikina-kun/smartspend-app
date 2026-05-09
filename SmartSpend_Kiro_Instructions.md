# SmartSpend — Kiro Task Instructions
# Version: 2.5.0 → 2.5.1
# Generated: May 5, 2026
# DO NOT BUILD until all tasks in a session are done. Run getDiagnostics after every change.

---

## TASK 1 — Fix Analytics blank/gray scrolling box
**Priority: Critical**
**Files likely affected:** `lib/screens/analytics_screen.dart`

### Problem
The Category Summary Panels section below the pie chart renders as a large blank gray box that infinitely scrolls on All Time, Last Month, and This Year filters. The pie chart loads correctly but the expandable category cards below it do not render any content.

### Root Cause
The expandable category card widget is building but the inner 4-week bar chart data query is returning null or an empty list. Instead of showing a fallback, it renders a blank unbounded container. This is a Flutter layout issue — a Column or ListView inside an unconstrained height widget inside a SingleChildScrollView causes infinite height.

### Fix

**Step 1 — Find the Category Summary Panels widget in `analytics_screen.dart`.**
Look for the section that builds an expandable card per category (likely a loop over categories building an ExpansionTile or custom card widget).

**Step 2 — Add a null/empty check on the 4-week data.**
Before building the inner bar chart, check if the data list is empty or null. If empty, show a simple placeholder instead:
```dart
// Before (broken — renders empty container):
Column(children: [
  _buildMiniBarChart(weeklyData),
])

// After (fixed — shows fallback if no data):
if (weeklyData == null || weeklyData.isEmpty)
  Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Text(
      'No data for this period.',
      style: TextStyle(fontSize: 12, color: Colors.grey),
    ),
  )
else
  _buildMiniBarChart(weeklyData),
```

**Step 3 — Fix the unbounded height issue.**
Any ListView or Column inside the expandable card that is inside a SingleChildScrollView must have bounded height. Wrap inner lists with:
```dart
ListView(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  children: [...],
)
```

**Step 4 — Add a global empty state for Category Summary Panels.**
If the expenses list for the selected period is completely empty (e.g. no expenses this year), the entire panel section should show:
```dart
Center(
  child: Padding(
    padding: EdgeInsets.all(24),
    child: Text(
      'No expenses recorded for this period.',
      style: TextStyle(color: Colors.grey),
      textAlign: TextAlign.center,
    ),
  ),
)
```
instead of an empty scrollable container.

**Step 5 — Run getDiagnostics. Then test all period filters** (All Time, This Week, This Month, Last Month) and confirm the gray box is gone on all of them.

---

## TASK 2 — Fix Recurring: Converge is flagged as income (is_expense = 0)
**Priority: High**
**Files likely affected:** `lib/screens/recurring_screen.dart`, `lib/services/database_service.dart`

### Problem
The recurring entry "Converge - Bida Internet" (Bills, ₱888/month) has `is_expense = 0` in the database, which means the app treats it as income. It shows a green `+₱888` on the Home screen upcoming card and is not being counted against the Bills budget. It should be `is_expense = 1` (an expense).

### Fix

**Step 1 — Direct DB fix for the existing record.**
In `database_service.dart`, or via a one-time migration in `_ensureColumns`, run:
```sql
UPDATE recurring SET is_expense = 1 WHERE title = 'Converge - Bida Internet' AND is_expense = 0;
```
Or better — run this as a general correction for any recurring entry that has a category of 'Bills', 'Food', 'Transportation', 'Education', 'Health', 'Shopping', 'Entertainment', 'Others' and is marked `is_expense = 0` (those are all expense categories by definition):
```sql
UPDATE recurring
SET is_expense = 1
WHERE category IN ('Bills','Food','Transportation','Education','Health','Shopping','Entertainment','Others')
AND is_expense = 0;
```

**Step 2 — Fix the Add/Edit Recurring dialog.**
In `recurring_screen.dart`, find the dialog that creates or edits a recurring entry. Make sure there is a clear toggle or dropdown for "Type: Expense / Income". The label must be obvious:
- If category is Bills, Food, Transportation, Education, Health, Shopping, Entertainment, Others → default `is_expense = 1`
- If category is Income-type (Salary, Allowance, Freelance) → default `is_expense = 0`
- User can override either way with the toggle

**Step 3 — Fix the Home screen upcoming card color.**
The upcoming card currently shows green `+₱888` for Converge because `is_expense = 0`. After the fix, expense recurring entries must show as red/orange with a `-` prefix:
```dart
// In home_screen.dart, upcoming card builder:
final isExpense = recurring.isExpense == 1;
Text(
  isExpense ? '-₱${recurring.amount}' : '+₱${recurring.amount}',
  style: TextStyle(color: isExpense ? Colors.redAccent : Colors.green),
)
```

**Step 4 — Run getDiagnostics. Verify** the Converge entry now shows as a negative/expense on the Home upcoming card and is counted in the Bills budget.

---

## TASK 3 — Fix is_want always being 0 for all AI-logged expenses
**Priority: High**
**Files likely affected:** `lib/services/ai_chat_service.dart`

### Problem
Every expense logged through the AI has `is_want = 0` (Need) regardless of category. This includes Entertainment items like movie tickets and want-type purchases like energy drinks. This breaks the 50/30/20 tracker since all expenses are counted as Needs.

### Fix

**Step 1 — Find the action handler in `ai_chat_service.dart`.**
Look for where `log_expense` action is parsed and the expense is inserted into the DB. It will look something like:
```dart
await _dbService.insertExpense(Expense(
  itemName: action['item_name'],
  category: action['category'],
  amount: action['amount'],
  // ...
  isWant: 0, // ← THIS IS THE PROBLEM
));
```

**Step 2 — Replace the hardcoded `isWant: 0` with a category-based inference function.**
Add this helper function in `ai_chat_service.dart`:
```dart
int _inferIsWant(String category) {
  const wantCategories = [
    'Entertainment',
    'Shopping',
  ];
  const needCategories = [
    'Food',
    'Transportation',
    'Bills',
    'Education',
    'Health',
    'Others',
  ];
  final cat = category.trim();
  if (wantCategories.contains(cat)) return 1;
  return 0; // default to Need for anything else
}
```

**Step 3 — Use the function when inserting:**
```dart
await _dbService.insertExpense(Expense(
  itemName: action['item_name'],
  category: action['category'],
  amount: action['amount'],
  // ...
  isWant: _inferIsWant(action['category'] ?? ''),
));
```

**Step 4 — Apply the same fix to `edit_expense` action handler.**
When the AI edits an expense and changes its category, re-infer `is_want` based on the new category:
```dart
// In edit_expense handler:
if (action.containsKey('category')) {
  updatedExpense = updatedExpense.copyWith(
    category: action['category'],
    isWant: _inferIsWant(action['category']),
  );
}
```

**Step 5 — Run getDiagnostics. Test** by asking the AI to log an Entertainment expense and verify `is_want = 1` in the debug log export.

---

## TASK 4 — Fix AI chat running total wrong after expense edits
**Priority: Medium**
**Files likely affected:** `lib/services/ai_chat_service.dart`

### Problem
After the AI edits an expense (e.g. changes amount from ₱100 to ₱50), the AI's next message correctly confirms the edit but reports the wrong monthly total. It uses the old pre-edit total instead of re-querying the DB. Example from logs: after editing to ₱50, AI said "total is now ₱230" when the actual DB total was ₱180.

### Fix

**Step 1 — Find where the AI constructs its response after an `edit_expense` action.**
It likely computes the new total by adding/subtracting from a cached context value rather than re-querying.

**Step 2 — After any `edit_expense` or `delete_expense` action, always re-fetch the total from DB.**
Add a fresh query after the action completes:
```dart
// After edit_expense action is applied:
final thisMonthTotal = await _dbService.getTotalExpensesForMonth(
  DateTime.now().year,
  DateTime.now().month,
);
```
Then pass `thisMonthTotal` into the response context so the AI reports the correct number.

**Step 3 — Do the same after `log_expense` as well**, to keep it consistent. Never compute the total from context arithmetic — always re-query after any write operation.

**Step 4 — In the AI system prompt context injection (`setFullContext`), confirm that `total_this_month` is always pulled fresh from DB on every message**, not cached from a previous call. If it is cached, move it to a per-message fresh query.

**Step 5 — Run getDiagnostics. Test** by logging an expense via AI, then editing the amount, and checking that the AI's reported total matches the actual sum in the debug log.

---

## TASK 5 — Fix Debt total including "lent" amounts in the owed total
**Priority: Medium**
**Files likely affected:** `lib/screens/hub_screen.dart`, `lib/screens/analytics_screen.dart` (Feature Glance card)

### Problem
The Hub card for Debts & Lending shows "₱6,500 total" but this includes ₱500 that was lent TO someone (type = 'lent'). The actual amount the user owes is only ₱6,000. Mixing owed and lent into one total is misleading.

### Fix

**Step 1 — In `hub_screen.dart`, find the Debts & Lending glance card.**
It currently sums all debt amounts regardless of type.

**Step 2 — Split the query into two:**
```dart
final iOweTotal = debts
    .where((d) => d.type == 'owe')
    .fold(0.0, (sum, d) => sum + (d.amount - d.paidAmount));

final owedToMeTotal = debts
    .where((d) => d.type == 'lent')
    .fold(0.0, (sum, d) => sum + (d.amount - d.paidAmount));
```

**Step 3 — Update the card display to show both clearly:**
```dart
// Option A — two lines:
Text('₱${iOweTotal.toStringAsFixed(0)} owed'),
if (owedToMeTotal > 0)
  Text('₱${owedToMeTotal.toStringAsFixed(0)} receivable',
    style: TextStyle(color: Colors.green, fontSize: 12)),

// Option B — single line if only owe exists:
Text('${debts.length} items · ₱${iOweTotal.toStringAsFixed(0)} owed')
```

**Step 4 — Apply the same fix to the Analytics Feature Glance card** for Debts & Lending if it shows the same combined total.

**Step 5 — Run getDiagnostics. Verify** the Hub card shows ₱6,000 owed and ₱500 receivable separately.

---

## TASK 6 — Add budget over-income warning
**Priority: Medium**
**Files likely affected:** `lib/screens/budgets_screen.dart`

### Problem
The user's total budget percentages add up to 175% of income (Entertainment 10% + Transportation 25% + Bills 25% + Health 30% + Shopping 25% + Food 25% + Others 10% + Education 25% = 175%). The Budgets screen shows ₱11,550 Budgeted against ₱6,600 Income with no warning. This is confusing and mathematically impossible to stay within.

### Fix

**Step 1 — In `budgets_screen.dart`, after loading all budgets, compute the total budgeted amount and compare to monthly income:**
```dart
final totalBudgeted = budgets.fold(0.0, (sum, b) => sum + b.amount);
final monthlyIncome = await _dbService.getMonthlyIncome();
final isOverIncome = totalBudgeted > monthlyIncome;
final overBy = totalBudgeted - monthlyIncome;
```

**Step 2 — Show a warning banner at the top of the Budgets screen when over income:**
```dart
if (isOverIncome)
  Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange.withOpacity(0.4)),
    ),
    child: Row(
      children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Total budgets exceed your income by ₱${overBy.toStringAsFixed(0)}. '
            'Consider reducing some category limits.',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ),
      ],
    ),
  ),
```

**Step 3 — Also add a soft check when the user adds or edits a budget.**
After the user sets a budget amount, before saving, check if the new total would exceed income. If yes, show a dialog:
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('Budget exceeds income'),
    content: Text(
      'Adding this budget means your total budgets will be ₱${newTotal.toStringAsFixed(0)}, '
      'which is ₱${(newTotal - income).toStringAsFixed(0)} more than your income. '
      'Do you still want to save it?'
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      TextButton(onPressed: () { Navigator.pop(context); _saveBudget(); }, child: Text('Save anyway')),
    ],
  ),
);
```

**Step 4 — Run getDiagnostics. Verify** the warning banner appears on the Budgets screen with the current data.

---

## TASK 7 — Rework Income Frequency system
**Priority: High — careful, this touches FHS, Cash Flow, and budgets**
**Files likely affected:** `lib/screens/profile_screen.dart`, `lib/services/database_service.dart`, `lib/services/score_service.dart`, `lib/screens/home_screen.dart`, `lib/screens/budgets_screen.dart`

### Problem
`income_frequency` is stored as 'daily' in settings but the entire app treats income as monthly. The Profile screen always shows "Monthly Allowance", the Cash Flow card uses monthly income flat, and the FHS savings rate component uses `monthly_income` regardless of frequency. There is no way for users to set which day of the week/month they receive their income.

### Supported Frequency Modes to Implement

| Mode | Description | New settings fields needed |
|---|---|---|
| Daily | Fixed amount every day | `income_per_period` (daily amount) |
| Weekly | Fixed amount on a specific day of week | `income_per_period`, `income_day_of_week` (1=Mon…7=Sun) |
| Semi-monthly | Two releases per month (15th and last day, or two custom dates) | `income_per_period` (per release), `income_day1`, `income_day2` |
| Monthly | One release per month on a specific date | `income_per_period`, `income_day_of_month` |
| Irregular | No fixed schedule — user logs manually when received | `income_per_period = 0` |

### Fix

**Step 1 — Add new settings keys in `database_service.dart`.**
Add these to the settings table via `_ensureColumns` or direct insert if missing:
```
income_day_of_week    (int, 1–7, for weekly mode)
income_day_of_month   (int, 1–28, for monthly/semi-monthly mode)
income_day2           (int, 1–28, for semi-monthly second date)
income_per_period     (double, the amount received each payment)
```
Keep `monthly_income` for backward compatibility — it will be derived/computed from the above, not directly edited by the user anymore.

**Step 2 — Add a helper function to derive monthly income equivalent.**
Add this in `database_service.dart` or a new `income_service.dart`:
```dart
double getMonthlyIncomeEquivalent({
  required String frequency,
  required double perPeriod,
  int? dayOfWeek,
  int? month,
}) {
  switch (frequency) {
    case 'daily':
      // Use days in current month
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      return perPeriod * daysInMonth;
    case 'weekly':
      return perPeriod * 4.33; // average weeks per month
    case 'semimonthly':
      return perPeriod * 2;
    case 'monthly':
      return perPeriod;
    case 'irregular':
      // Use only actually logged income for the month from income table
      return 0; // will be fetched from DB separately
    default:
      return perPeriod;
  }
}
```

**Step 3 — Update the Profile screen income section.**
- Change "Monthly Allowance" label to dynamically reflect the frequency:
  - daily → "Daily Allowance"
  - weekly → "Weekly Allowance"
  - semimonthly → "Semi-Monthly Allowance"
  - monthly → "Monthly Allowance"
  - irregular → "Income (Irregular)"
- The edit (pencil) button should open a dialog with:
  1. Frequency picker: Daily / Weekly / Semi-Monthly / Monthly / Irregular
  2. Amount field: "How much do you receive per [period]?"
  3. Day picker (conditional):
     - If weekly → show day-of-week picker (Mon/Tue/Wed/Thu/Fri/Sat/Sun)
     - If monthly → show day-of-month picker (1–28)
     - If semi-monthly → show two date pickers (date 1 and date 2)
     - If daily or irregular → no day picker needed
  4. Optional toggle: "Show as monthly equivalent in summaries" (ON by default)
- Save: store `income_frequency`, `income_per_period`, and the relevant day fields. Compute and store `monthly_income` as the monthly equivalent for backward compatibility with other parts of the app.

**Step 4 — Update Cash Flow card on Home screen.**
When `income_frequency != 'monthly'`, show the per-period amount alongside the monthly equivalent:
```dart
// Example for daily:
Text('Daily: ₱220')
Text('This month: ₱6,820 expected', style: smallGrey)

// Example for weekly:
Text('Weekly: ₱1,500 (every Monday)')
Text('This month: ₱6,495 expected', style: smallGrey)

// For irregular:
Text('Income: ₱6,600 logged this month')
// (pulls from income table sum, not from monthly_income setting)
```

**Step 5 — Update FHS savings rate component in `score_service.dart`.**
The savings rate currently uses `monthly_income` flat. Change it to:
```dart
double getIncomeBaseline() {
  final frequency = settings['income_frequency'] ?? 'monthly';
  if (frequency == 'irregular') {
    // Use actually logged income for this month from income table
    return _dbService.getLoggedIncomeThisMonth();
  }
  // For all other modes, use the monthly equivalent
  return getMonthlyIncomeEquivalent(
    frequency: frequency,
    perPeriod: double.tryParse(settings['income_per_period'] ?? '0') ?? 0,
  );
}
```
Replace the hardcoded `monthly_income` reference in the savings rate sub-score calculation with `getIncomeBaseline()`.

**Step 6 — Update budget percentage calculations.**
Anywhere `monthly_income` is used to compute percentage-based budget limits (e.g. `budget.amount = income * budget.percentageValue / 100`), replace with `getMonthlyIncomeEquivalent(...)` so budgets scale correctly with the frequency setting.

**Step 7 — Handle irregular mode specially.**
For users who select Irregular:
- Remove the income amount field (they log income manually via the AI or income screen)
- FHS savings rate uses only logged income from the income table
- Cash Flow card shows "Log income when received" prompt if no income logged this month
- Do NOT show a projected income figure — only show what's actually been logged

**Step 8 — Migrate existing users.**
In `_ensureColumns` or app startup, check if `income_per_period` is missing. If so, derive it from existing `monthly_income` and `income_frequency`:
```dart
if (!settings.containsKey('income_per_period')) {
  final monthly = double.tryParse(settings['monthly_income'] ?? '0') ?? 0;
  final freq = settings['income_frequency'] ?? 'monthly';
  double perPeriod = monthly;
  if (freq == 'daily') perPeriod = monthly / 30;
  else if (freq == 'weekly') perPeriod = monthly / 4.33;
  else if (freq == 'semimonthly') perPeriod = monthly / 2;
  await _dbService.saveSetting('income_per_period', perPeriod.toString());
}
```

**Step 9 — Run getDiagnostics. Test each frequency mode** by changing it in Profile and verifying: (1) Profile label updates, (2) Cash Flow card shows correct figure, (3) FHS score doesn't break, (4) Budgets screen percentages recompute correctly.

---

## TASK 8 — Add Installment Plan system for credit/loan payments
**Priority: Medium**
**Files likely affected:** `lib/screens/debts_screen.dart`, `lib/services/database_service.dart`, `lib/screens/hub_screen.dart`, `lib/screens/bill_calendar_screen.dart`

### What to build
A structured installment plan tracker for services like ShopeePayLater, GCash Credit/GLoan, LazadaPayLater, HomeCredit, Globe/Smart postpaid plans, SSS/Pag-IBIG loans, and similar fixed monthly payment arrangements. These are different from open debts — they have a fixed monthly payment, a fixed number of months, and a specific due day each month.

### New DB table: `installment_plans`
Add this table via `_ensureColumns`:
```sql
CREATE TABLE IF NOT EXISTS installment_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  provider TEXT,
  total_amount REAL NOT NULL,
  monthly_payment REAL NOT NULL,
  months_total INTEGER NOT NULL,
  months_paid INTEGER DEFAULT 0,
  due_day INTEGER NOT NULL,
  interest_rate REAL,
  start_date TEXT NOT NULL,
  category TEXT DEFAULT 'Bills',
  notes TEXT,
  created_at TEXT
);
```

### UI changes

**Step 1 — Add "Payment Plans" tab to the Debts screen.**
The Debts & Lending screen currently has "I Owe" and "Owed to Me" tabs. Add a third tab: **Payment Plans**. This tab lists all installment_plans entries.

**Step 2 — Each plan card shows:**
- Plan name + provider (e.g. "Online Shopping — ShopeePayLater")
- Progress: `months_paid / months_total` (e.g. "2 of 6 months paid")
- Progress bar
- Monthly payment amount + due day (e.g. "₱1,000 due every 5th")
- Next due date (computed: find the next occurrence of `due_day` from today)
- Total remaining: `(months_total - months_paid) × monthly_payment`
- If `interest_rate` is set: show "Total interest: ₱X" computed as simple interest
- A **"Log Payment"** button

**Step 3 — "Log Payment" button behavior:**
When tapped, show a confirmation bottom sheet:
```
Log payment for [Plan Name]?
Amount: ₱1,000
Category: Bills
Date: Today

[Cancel]  [Confirm]
```
On confirm:
1. Insert a new expense record: `item_name = plan.title + " payment"`, `category = plan.category`, `amount = plan.monthly_payment`, `date = today`
2. Increment `months_paid` by 1 in the installment_plans table
3. If `months_paid >= months_total`, mark plan as complete and show a celebration snackbar: "🎉 [Plan name] fully paid off!"

**Step 4 — Add/Edit plan dialog fields:**
- Plan name (text)
- Provider (text, e.g. ShopeePayLater, GCash GLoan, HomeCredit)
- Total amount (number)
- Monthly payment (number) — auto-compute if total and months are set: `total / months`
- Number of months (number picker: 1–60)
- Due day of month (number picker: 1–28)
- Interest rate % (optional, number)
- Start date (date picker)
- Category (dropdown, default Bills)
- Notes (optional)

**Step 5 — Bill Calendar integration.**
When loading bill calendar events, also load installment plan due dates. For each active plan (months_paid < months_total), add a recurring event on `due_day` each month going forward until `months_total` is reached. Show these in a distinct color (e.g. orange) on the calendar with the label "[Plan name] — ₱X".

**Step 6 — Hub card update.**
The Debts & Lending Hub card subtitle should include plan count if any exist:
```dart
// Example:
'3 debts · 2 plans · ₱6,000 owed'
```

**Step 7 — Run getDiagnostics. Test** by creating a ShopeePayLater plan with 6 months, ₱1,000/month, due on the 5th. Verify: (1) it appears in the Payment Plans tab, (2) the next due date is computed correctly, (3) tapping Log Payment creates an expense and increments months_paid, (4) it appears on the Bill Calendar.

---

## GENERAL REMINDERS FOR KIRO
- Always run `getDiagnostics` after every individual change before moving to the next task
- DB is at version 11 — use `_ensureColumns` pattern for any new tables or columns, no version bump needed for new tables
- Do NOT build the APK until explicitly told to
- Use `app-arm64-v8a-release.apk` for testing on the Poco X6 Pro
- Firebase Spark plan — no Storage, no Cloud Functions
- Amounts stored in PHP internally
- All async operations must have try-catch with SnackBar error handling
