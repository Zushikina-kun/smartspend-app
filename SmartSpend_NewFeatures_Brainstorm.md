# SmartSpend — New Feature Brainstorm (Reviewed & Improved)
# Based on GPT brainstorm doc, cross-referenced against current v2.5.0 build
# Status tags: [NEW] = not in app at all | [PARTIAL] = exists but incomplete | [DONE] = already built

---

## WHAT IS ALREADY DONE — Do not re-add these

The following from the brainstorm are already fully implemented in SmartSpend v2.5.0:
- Manual expense CRUD with categories and custom categories
- AI chat logging (voice, text, OCR)
- Google ML Kit OCR for receipt scanning
- SQLite local database + Firebase cloud sync
- Per-category budgets, daily spending limit, monthly challenge
- Savings goals with progress bars and milestone alerts
- Recurring transactions with bill calendar
- Analytics: pie chart, daily spending line chart, day-of-week heatmap,
  period comparison, category breakdown, long-range forecast, plain English summary
- Auto-categorization rules (keyword → category)
- CSV export
- Multi-currency display (34+ currencies via open.er-api.com)
- AI financial advisor with real-time DB actions
- Financial Health Score (0–100, 4 components)
- Debt & Lending tracking (I Owe / Owed to Me)
- Payment Plans / Installment tracker (ShopeePayLater, GCash Credit, etc.)
- Mood log with spending correlation
- Local push notifications (budget alerts, velocity, weekly briefing)
- Income tracking with windfall flag
- Subscription Summary card

---

## SECTION 1 — MULTI-WALLET SYSTEM [NEW — Major Feature]

### What the brainstorm proposed
A wallet-based system where each payment method (Cash, GCash, Maya, BPI, etc.)
has its own balance, its own transaction history, and all wallets roll up into
a Total Cash and Net Worth figure.

### Why SmartSpend doesn't have this yet
SmartSpend currently stores `payment_method` as a text label per expense
(Cash, GCash, Card, etc.) but there is no actual wallet balance — there is
no running balance per payment method. You can't see "I have ₱3,500 in GCash
right now" because the app never tracks wallet top-ups or starting balances.

### Improved version for SmartSpend

**New DB table: `wallets`**
```
id
name              (e.g. "GCash", "BPI Savings", "Cash")
type              (cash | ewallet | bank | savings | investment | liability)
balance           (current balance — manually set or derived from transactions)
currency          (default PHP)
icon              (emoji or icon name)
color             (hex)
is_active         (bool)
created_at
```

**New transaction field: `wallet_id`**
Replace the current free-text `payment_method` field with a foreign key to
the wallets table. This lets the app compute each wallet's running balance
from its transaction history.

**Wallet balance computation:**
```
wallet_balance = starting_balance
              + SUM(income WHERE wallet_id = this)
              - SUM(expenses WHERE wallet_id = this)
              - SUM(transfers_out WHERE from_wallet_id = this)
              + SUM(transfers_in WHERE to_wallet_id = this)
```

**Pre-loaded wallet options at onboarding:**
- Cash (always shown, default)
- GCash
- Maya
- ShopeePay
- GrabPay
- BPI / BDO / UnionBank / Landbank / RCBC (bank type)
- Custom (user-named)

**Wallet screen features:**
- List of all wallets with current balance
- Tap a wallet → see its transaction history filtered to that wallet only
- Edit balance (manual adjustment with an "adjustment" transaction type)
- Color + icon picker per wallet
- Archive wallet (hide without deleting)

**Dashboard update:**
- Show wallet balances as cards/chips on the Home screen
  (similar to how banks show account cards)
- Total Cash = sum of cash + ewallet + bank wallets
- This replaces the current "Monthly Allowance ₱6,600" display which is
  misleading since it doesn't reflect actual cash on hand

**Kiro note:**
This is a large migration. The `payment_method` text field in expenses already
stores the wallet name — use this to auto-assign `wallet_id` on migration by
matching payment_method text to wallet names. Do NOT wipe existing data.
Migration: create wallets for each unique payment_method found in expenses,
then link each expense to the matching wallet_id.

---

## SECTION 2 — TRANSFER TRANSACTIONS [NEW]

### What the brainstorm proposed
A transfer type that moves money between wallets without counting as an
expense or income. E.g. "Cash to GCash top-up ₱500" should not appear as
an expense in Food or any other category.

### Why this matters
Currently, if a user tops up their GCash from cash, they have no clean way
to record this. If they log it as an expense it inflates spending. If they
ignore it the wallet balances go out of sync.

### Implementation for SmartSpend

**New transaction type: `transfer`**
Add to the existing expenses-adjacent flow. A transfer has:
```
id
from_wallet_id
to_wallet_id
amount
date
notes
```

It does NOT appear in:
- Expense totals
- Category breakdown
- Analytics spending charts
- 50/30/20 tracker
- Budget calculations

It DOES appear in:
- Individual wallet transaction histories
- The unified transaction timeline (labeled "Transfer")
- Net worth (net effect is zero — just moves money between assets)

**UI:** Add "Transfer" as a 3rd option in the + Log Expense flow alongside
Expense and Income. Show a from/to wallet picker instead of a category picker.

**Common Filipino transfer scenarios to support:**
- Cash → GCash top-up
- GCash → bank transfer (GCash to BPI)
- Bank → GCash (instapay/pesonet)
- Savings to spending wallet
- Any wallet to any other wallet

---

## SECTION 3 — ANDROID NOTIFICATION LISTENER [NEW — High Value]

### What the brainstorm proposed
Automatically read financial notifications from GCash, Maya, Shopee, Lazada,
Grab, and banks to auto-create expense entries without manual logging.

### Why this is the biggest unlock for SmartSpend
The app's core promise is reducing manual input. OCR and voice already help.
But notification parsing is the most seamless: the user makes a GCash payment,
a notification pops, the app reads it and asks "Log this ₱249 Shopee payment?"
Zero extra effort from the user.

### Implementation for SmartSpend

**Android permission required:**
`android.permission.BIND_NOTIFICATION_LISTENER_SERVICE`
This requires the user to manually grant it in Android Settings →
Notifications → Notification Access. It cannot be requested via
normal `requestPermissions()`. Show a guided setup screen.

**How it works:**
1. A background `NotificationListenerService` runs in the app
2. When a new notification arrives from a financial app, it gets parsed
3. Parsed data → shown as a "Pending Transaction" prompt to the user
4. User confirms or dismisses → logs to DB or discards

**Notification templates to parse (Filipino context):**

GCash:
```
"You sent ₱[amount] to [name]."
"Cash In of ₱[amount] was successful."
"You paid ₱[amount] to [merchant]."
```

Maya:
```
"You sent ₱[amount] to [name]."
"Payment of ₱[amount] to [merchant] was successful."
```

BPI/UnionBank SMS-style:
```
"Your account ending [xxxx] was debited ₱[amount] for [description]."
```

Shopee:
```
"Your payment of ₱[amount] for order [ID] was successful."
```

Lazada:
```
"Payment confirmed: ₱[amount] for your Lazada order."
```

**Parsed fields per notification:**
- amount (required)
- merchant/recipient (best-effort)
- payment method / source wallet (inferred from which app sent the notification)
- date/time (from notification timestamp)
- transaction type (expense by default, income if "cash in" / "received")

**Pending transactions UI:**
A new "Pending" section on the Home screen or a dedicated Inbox screen showing
unconfirmed auto-detected transactions. Each shows:
- Source notification (GCash / Maya / Shopee etc.)
- Parsed amount and merchant
- Suggested category (auto-inferred, editable)
- Suggested wallet (inferred from source app)
- [Log It] / [Dismiss] buttons

**Kiro note:**
Add `NotificationListenerService` in `AndroidManifest.xml`. Create a
`notification_parser_service.dart` that handles the parsing logic per app.
Store pending transactions in a new `pending_transactions` SQLite table.
Add a setup wizard screen (only shown once) that explains what the permission
does and guides the user to enable it.

---

## SECTION 4 — CSV / FILE IMPORT [NEW — Partial exists]

### Current state
SmartSpend has CSV export. It does NOT have CSV import.

### What to add
Import transactions from CSV files exported by GCash, Maya, and bank apps.

**Supported import formats:**

GCash transaction history CSV columns:
```
Date, Description, Amount, Running Balance, Type, Reference Number
```

BPI eStatement CSV:
```
Date, Description, Debit, Credit, Balance
```

Generic CSV (user-mapped):
- User maps columns to: date, description, amount, type
- App auto-categorizes based on description + auto-categorization rules

**Import flow:**
1. User taps Import → picks CSV file
2. App detects format (GCash / BPI / generic)
3. Shows preview: first 10 rows with detected fields
4. User confirms mapping (or corrects it)
5. App checks for duplicates by amount + date + description match
6. Imports non-duplicate rows as expenses/income
7. Shows summary: "23 imported, 2 duplicates skipped"

**Duplicate detection logic:**
```dart
// Consider a duplicate if:
// same amount AND same date AND description similarity > 80%
bool isDuplicate(existing, incoming) {
  return existing.amount == incoming.amount
      && existing.date == incoming.date
      && similarity(existing.description, incoming.description) > 0.8;
}
```

**Kiro note:**
Use the existing `file_picker` package (already in pubspec). Parse with the
`csv` package (already in pubspec for export — reuse for import). Add an
Import option to Profile settings alongside Export to CSV.

---

## SECTION 5 — NET WORTH TRACKER [PARTIAL — Improve]

### Current state
Profile screen shows "Remaining Balance (This Month)" computed as
`monthly_income - this_month_expenses`. This is cash flow, not net worth.
The manual_assets setting exists but is barely used.

### What to add
A real Net Worth calculation once the wallet system is built:

```
Net Worth = Total Assets - Total Liabilities

Total Assets =
  sum of all wallet balances (cash + ewallet + bank + savings)
  + manual_assets (property, vehicle, etc. — user-entered)
  + investment wallet balances

Total Liabilities =
  sum of all debt balances remaining (from debts table)
  + sum of remaining installment plan balances
  + sum of remaining payment plan balances
```

**Net Worth screen / card:**
- Show as a dedicated card on Profile, below the health score
- Breakdown: Assets vs Liabilities pie
- Month-over-month net worth change (if score_history can be extended to
  also snapshot net worth daily)
- Simple sparkline: net worth trend over last 30 days

**Note:** This only becomes meaningful once the wallet system (Section 1)
is implemented, because without real wallet balances the asset side is empty.

---

## SECTION 6 — UNIFIED TRANSACTION INBOX [NEW]

### What the brainstorm proposed
A single chronological feed showing ALL financial activity regardless of
source — manual entries, AI-logged, notification-parsed, CSV-imported,
payment plan auto-logs, etc.

### Why SmartSpend needs this
Currently the Recent Transactions list on Home only shows manually/AI-logged
expenses. Payment plan installments, recurring auto-logs, and future
notification-parsed entries all need a home. A unified inbox gives users one
place to review everything.

### Implementation for SmartSpend

**Unified Transaction Timeline screen** (new screen, accessible from Hub):
- All expenses + income entries + transfers, sorted by date descending
- Filter chips: All | Expenses | Income | Transfers | Pending
- Source badge on each entry: 🤖 AI | 📷 OCR | 🔔 Notification | 📄 CSV | ✏️ Manual
- Search bar (by description, merchant, amount)
- Bulk actions: select multiple → delete, re-categorize, export

**Pending tab:**
Shows notification-parsed transactions waiting for user confirmation.
(Ties into Section 3 — Notification Listener)

**Kiro note:**
The existing Transactions screen in the Hub is close to this — extend it
rather than building from scratch. Add the source badge using the existing
`ai_generated` and `notes` fields to infer source type. Add a `source_type`
column to expenses: 'manual' | 'ai' | 'ocr' | 'notification' | 'csv' |
'payment_plan' | 'recurring'.

---

## SECTION 7 — SUBSCRIPTION / RECURRING AUTO-DETECTION [PARTIAL — Improve]

### Current state
SmartSpend has a Subscription Summary card on Home that shows manually-added
recurring entries. It does NOT auto-detect recurring patterns from expense
history.

### What to add
Auto-detect recurring expenses from transaction history:

**Detection logic:**
```
IF same description appears with similar amount
   at approximately the same interval (weekly/monthly)
   at least 2 times
THEN flag as potential recurring
```

**UI:**
A banner or prompt: "Looks like you pay ₱888 for Converge every month —
want to add it as a recurring transaction?"
User taps Yes → opens pre-filled Add Recurring dialog.

**Also detect subscription price creep:**
IF a recurring expense (matched by description/merchant) has changed amount
compared to previous occurrences:
→ Alert: "Your Netflix payment was ₱149 last month but ₱169 this month —
price may have increased."

**Kiro note:**
Run this detection in a background task on app open (once per day).
Store detected candidates in a `recurring_candidates` table to avoid
re-prompting the user every day. User dismissing a suggestion marks it
as `dismissed = 1` permanently.

---

## SECTION 8 — TRANSACTION TAGS [NEW — Small but useful]

### What the brainstorm proposed
Tagging individual transactions with freeform labels beyond categories.

### Implementation for SmartSpend

**New field: `tags` (TEXT, comma-separated or JSON array)**
Add to the expenses table via `_ensureColumns`.

**Use cases:**
- Tag capstone-related expenses: `#capstone`
- Tag food as `#homemade` vs `#takeout`
- Tag shared expenses: `#shared-with-friends`
- Tag recurring context: `#monthly` `#weekly`

**UI:**
- Small tag chips below the category in the expense detail view
- Add/remove tags from the edit expense dialog
- Search by tag in the Transactions screen
- Analytics: filter by tag to see spending on a specific project/event

**AI integration:**
The AI can suggest tags: "This looks like a school expense — want to tag
it #capstone?" and can query by tag: "How much did I spend on #capstone
this month?"

**Kiro note:**
This is low effort — just a text field + chip display. Don't build a
separate tags table for v1. Store as comma-separated string in a `tags`
column. Parse and display as chips in the UI.

---

## SECTION 9 — DUPLICATE TRANSACTION DETECTION [NEW]

### Current state
No duplicate detection exists in SmartSpend. If a user logs a Jollibee
purchase manually AND it comes in via notification parsing, it will be
logged twice.

### Implementation

**Check on every new expense log (manual, AI, notification, CSV):**
```dart
bool isDuplicate(newExpense) {
  // Look for existing expense where:
  return expenses.any((e) =>
    e.amount == newExpense.amount &&
    e.date == newExpense.date &&
    e.category == newExpense.category &&
    timeDifference(e.time, newExpense.time) < 30.minutes
  );
}
```

**If potential duplicate found:**
Show a dialog before saving:
"This looks similar to [existing entry] logged at [time]. Is this a
duplicate?"
[Save anyway] [Cancel] [View existing]

**For CSV import:** Run duplicate check per row before importing.
**For notification parsing:** Run before adding to pending queue.
**For AI logging:** Already partially addressed — extend the AI prompt to
also check the DB context before logging same-day same-category same-amount.

---

## SECTION 10 — EMAIL RECEIPT PARSING [FUTURE — After notification listener]

### What the brainstorm proposed
Parse transaction emails from Shopee, Lazada, GCash, Maya, and banks to
auto-create expense entries.

### Reality check for SmartSpend's current context
This requires either:
(a) Gmail API OAuth access — complex, requires Google verification for
production apps
(b) IMAP email access — user provides email password, security risk
(c) User forwards emails to a dedicated parsing address — viable but adds friction

**Recommended approach for SmartSpend:**
Defer email parsing until after notification listener is working (Section 3).
Notification listener covers GCash, Maya, Shopee automatically. Email parsing
adds coverage for bank emails and Lazada invoices.

**If implementing:** Use Gmail API with limited scope
(`gmail.readonly`, filtered to financial senders only).
Never store email credentials. Use OAuth tokens only.
Parse subject + body for amount, merchant, date, transaction ID.

---

## SECTION 11 — IMPROVED INCOME SYSTEM [PARTIAL — Already tasked]

Note: This was already written up in detail in the previous Kiro instructions
file (Task 7 — Income Frequency Rework). Referring to that file for
implementation details. Summary of what still needs to be done:

- Frequency modes: daily / weekly / semi-monthly / monthly / irregular
- Day-of-week / day-of-month picker for non-monthly frequencies
- Cash Flow card shows per-period amount not just monthly equivalent
- FHS savings rate uses month-equivalent income baseline not flat monthly_income
- Profile label changes dynamically ("Daily Allowance" vs "Monthly Income" etc.)
- Irregular mode: FHS uses only logged income from income table

---

## SECTION 12 — SHARED / FAMILY WALLETS [FUTURE — Post-wallet system]

### What the brainstorm proposed
Multiple users contributing to a shared wallet — family budgets, group savings,
business funds.

### Reality check
This requires real-time multi-user sync (Firebase Firestore), conflict
resolution, and user authentication per shared space. It's architecturally
significant and should only be attempted after:
1. The wallet system (Section 1) is fully built
2. Firebase sync is rock-solid
3. The app has cleared defense/capstone requirements

### Lightweight version to consider first
Instead of full multi-user: a "Shared Expense" flag on individual transactions
with a split amount. This already partially exists via the `split_group_id`
brainstorm item. A user can mark an expense as shared, record who split it
with them, and track whether the split amount was received back. This works
without multi-user sync.

---

## SECTION 13 — INVESTMENT ACCOUNT TRACKING [FUTURE]

### What the brainstorm proposed
Track stocks, crypto, MP2, mutual funds, time deposits as part of net worth.

### Implementation for SmartSpend (simple version first)

**New wallet type: `investment`**
(Covered by the wallet system in Section 1 — just needs a new wallet type)

Fields:
```
name          (e.g. "GCrypto BTC", "MP2 2026", "FMETF Stocks")
type          investment
balance       (manually updated by user — no live price feeds yet)
currency      (PHP or USD for crypto)
notes         (e.g. "matures December 2026")
```

**No live price feeds in v1** — user manually updates the balance when they
check their portfolio. This is the pragmatic version that requires no API keys
or external data.

**Show in:**
- Net Worth calculation (as an asset)
- Wallet list (separate section: "Investments")
- NOT in day-to-day expense analytics (investment deposits are transfers,
  not expenses)

---

## PRIORITY ORDER FOR IMPLEMENTATION

Ranked by effort vs. value for SmartSpend's current stage:

| Priority | Feature | Effort | Value |
|---|---|---|---|
| 1 | CSV Import (Section 4) | Low | High — reuses existing packages |
| 2 | Transaction Tags (Section 8) | Low | Medium — searchability |
| 3 | Duplicate Detection (Section 9) | Low | High — data quality |
| 4 | Subscription Auto-Detection (Section 7) | Medium | High — reduces manual work |
| 5 | Multi-Wallet System (Section 1) | High | Very High — core architecture change |
| 6 | Transfer Transactions (Section 2) | Medium | High — needs wallet system first |
| 7 | Net Worth Tracker (Section 5) | Medium | High — needs wallet system first |
| 8 | Unified Transaction Inbox (Section 6) | Medium | High — extend existing screen |
| 9 | Notification Listener (Section 3) | High | Very High — most impactful for zero-entry |
| 10 | Email Receipt Parsing (Section 10) | Very High | Medium — notification covers most cases |
| 11 | Shared Wallets (Section 12) | Very High | Low for now — post-capstone |
| 12 | Investment Tracking (Section 13) | Low (after wallet) | Medium |

---

## IMPROVEMENTS TO EXISTING BRAINSTORM IDEAS

The original GPT brainstorm was good but had some gaps for SmartSpend's
specific context. Here's what was tweaked or added:

1. **Wallet migration strategy** — The brainstorm didn't address how to
   migrate existing `payment_method` text data to a real wallet system.
   Added auto-migration logic above.

2. **Notification listener reality** — The brainstorm listed this as a simple
   feature. In practice it requires `NotificationListenerService` which needs
   manual user setup in Android Settings. Added the guided setup flow.

3. **CSV import column mapping** — The brainstorm said "auto column detection"
   without specifying how. Added specific GCash and BPI CSV column formats
   since those are the most relevant for Filipino users.

4. **Duplicate detection specifics** — Added time-window matching (within 30
   minutes) because same-day same-amount different-time is legitimate
   (e.g., two separate Jollibee trips on the same day).

5. **Email parsing deferred** — The brainstorm treated this as easy. In practice
   Gmail API requires Google app verification for production use. Notification
   listener is strictly better for the same use cases and much easier to ship.

6. **Investment tracking simplified** — No live price feeds for v1. Manual
   balance updates only. This makes it shippable without requiring crypto or
   stock API keys.

7. **Transfer type clarified** — Explicitly noted that transfers must NOT
   appear in expense analytics, 50/30/20 tracker, or budget calculations —
   something the brainstorm mentioned but didn't specify which calculations
   to exclude them from.
