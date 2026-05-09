# SmartSpend — Pending Issues & Feature Requests
**Logged:** May 3, 2026
**Status:** Identified, not yet fixed. Work through these one by one.

---

## ISSUE 1 — Feature Tour Doesn't Show for New Accounts on Same Device

**What happens:** When a new account is created and logged in on a device that previously had the app installed, the feature tour never appears — even though it's a brand new account.

**Root cause:** `tour_done` is stored in `SharedPreferences` (device-local storage), not per Firebase user. So if any previous session (demo or another account) already set `tour_done = true`, new accounts on the same device never see the tour.

**Where to fix:** `lib/widgets/feature_tour.dart` — `shouldShow()` and `markDone()` methods. Change the key from `'tour_done'` to `'tour_done_${uid}'` so it's per-account. Also need to reset it on logout.

**Files affected:**
- `lib/widgets/feature_tour.dart`
- `lib/screens/profile_screen.dart` (Replay Tutorial option)
- `lib/services/auth_service.dart` or logout flow (reset on logout)

**Priority:** HIGH — affects every new user's first experience

**STATUS: ✅ FIXED (May 3, 2026)**
- `feature_tour.dart`: `shouldShow()`, `markDone()`, and new `reset()` now use `tour_done_${uid}` (or `tour_done_demo` for demo mode)
- `profile_screen.dart`: Replay Tutorial now calls `FeatureTour.reset()` instead of directly writing `tour_done`
- Demo mode: `_tryDemo()` in `login_screen.dart` calls `FeatureTour.markDone()` which resolves to `tour_done_demo` since no Firebase user is signed in

---

## ISSUE 2 — Profile Photo: Use Google/Gmail Profile Picture as Default

**What happens:** New accounts have no profile photo. The app shows a placeholder avatar. Users expect their Google profile picture to appear automatically when they sign in with Google.

**What's needed:**
- On Google Sign-In, fetch `user.photoURL` from Firebase Auth (it's already available — Google provides it)
- Store it as the profile photo URL in the user_profile table
- Display it in the profile screen avatar
- Allow manual override (user can still change it)
- For email/password accounts: keep the placeholder (no Google photo available)

**Where to fix:** `lib/screens/login_screen.dart` — `_syncAfterLogin()` method. After Google sign-in, check `user.photoURL` and save it to the profile if no photo is already set.

**Files affected:**
- `lib/screens/login_screen.dart`
- `lib/screens/profile_screen.dart` (display logic)
- `lib/services/db_service.dart` (saveProfile)

**Priority:** MEDIUM — nice to have, improves first impression

**Note:** Profile photo sync across devices still requires Firebase Storage (Blaze plan). This fix only uses the Google-provided URL which is already a remote HTTPS URL — no Storage needed.

---

## ISSUE 3 — Analytics Period Filter: Missing "Last Month", Specific Month, and Calendar Comparison

**What happens:** The period filter only has: All Time, This Week, This Month, This Year, Custom Range. There's no "Last Month" option, no way to select "January 2026" specifically, and no month-by-month calendar navigation.

**What's needed:**
- Add "Last Month" as a quick filter chip (most commonly needed comparison)
- Add a month picker (year + month selection) for specific month analysis
- The existing "Custom Range" covers arbitrary date ranges, but a month picker is more intuitive

**Where to fix:** `lib/screens/analytics_screen.dart` — period filter chips section and `_loadData()` filter logic.

**Files affected:**
- `lib/screens/analytics_screen.dart`

**Priority:** MEDIUM — directly addresses panel feedback about comparison

---

## ISSUE 4 — Backdated Expenses: How the App Handles Old Records

**What happens:** If a user logs an expense with a past date (e.g. recording January expenses in May), the app should handle it correctly across all features.

**Current behavior (verified):**
- ✅ Add Expense has a date picker — user can select any past date
- ✅ Expenses are stored with the selected date, not today's date
- ✅ Analytics filters by date correctly
- ✅ This Month vs Last Month comparison uses stored dates
- ✅ FHS Component 4 (Logging Consistency) uses the span from first expense to today

**Potential issue:** If a user bulk-enters 30 old expenses all at once, Component 4 (Logging Consistency) will show 1 logged day out of 30 active days = very low score. This is technically correct but may feel unfair.

**Suggested fix:** When calculating Component 4, if the user has expenses on many different past dates (suggesting retroactive entry), give partial credit rather than penalizing heavily. Or add a note in the score breakdown: "Score reflects logging regularity from [first expense date]."

**Files affected:**
- `lib/services/score_service.dart` (Component 4 logic)

**Priority:** LOW — edge case, not a blocker

---

## ISSUE 5 — CSV/Bank Import: GCash, PayMaya, BDO, BPI

**What happens:** Users want to import their transaction history from GCash, PayMaya/Maya, BDO, BPI, etc. as CSV files.

**GCash CSV format (from research):**
GCash exports transaction history as a PDF (not CSV directly). The PDF contains columns like:
- Date/Time (e.g. "Jan 11, 2025 10:30 AM")
- Reference No.
- Description (e.g. "Send Money to Juan Dela Cruz", "GCash Pay - Jollibee")
- Debit (amount sent/paid)
- Credit (amount received)
- Balance

GCash for Business has a direct CSV export with similar columns.

**Maya/PayMaya CSV format:**
Similar structure — Date, Description, Amount (positive = credit, negative = debit), Balance.

**BDO/BPI CSV format:**
More formal bank format — Date, Description, Debit, Credit, Balance. Dates in YYYY-MM-DD or MM/DD/YYYY format.

**What's needed:**
- File picker → user selects CSV file
- Auto-detect format (GCash vs Maya vs BDO vs BPI) based on column headers
- Parse rows: map Date → expense date, Description → item_name + category (via AI normalizer), Debit → amount
- Preview table — user can deselect rows before importing
- Bulk insert with duplicate detection (same date + amount + description = skip)
- Import summary: "47 transactions imported, 3 skipped (duplicates)"
- Handle date format variations (Jan 11 2025, 01/11/2025, 2025-01-11)
- Handle credit entries (income) vs debit entries (expenses) separately

**Files affected (new):**
- `lib/screens/csv_import_screen.dart` (new)
- `lib/services/csv_import_service.dart` (new)

**Files affected (existing):**
- `lib/screens/home_screen.dart` (Hub tile)
- `lib/services/ai_chat_service.dart` (category normalizer for imported descriptions)

**Priority:** HIGH for Capstone 2 — directly addresses "I just started, my history is empty" problem

**Note:** The `csv` and `file_picker` packages are already in pubspec.yaml. Main work is writing format-specific parsers and the preview UI.

**Sample formats to handle:**
```
GCash:
Date,Reference No.,Description,Debit,Credit,Balance
Jan 11 2025,REF123,Send Money to Juan,500.00,,4242.12
Jan 12 2025,REF124,GCash Pay - Jollibee,149.00,,4093.12

Maya:
Transaction Date,Description,Amount,Balance
2025-01-11,Transfer to Juan Dela Cruz,-500.00,4242.12
2025-01-12,Payment - Jollibee,-149.00,4093.12

BDO:
Date,Description,Debit,Credit,Balance
01/11/2025,FUND TRANSFER TO JUAN,500.00,,4242.12
01/12/2025,JOLLIBEE PAYMENT,149.00,,4093.12
```

---

## ISSUE 6 — PIN and Biometric Lock Are Device-Wide, Not Per-Account

**What happens:** The app lock PIN and biometric enabled state are stored in `SharedPreferences` with fixed keys (`app_lock_pin`, `app_lock_enabled`). This means:
- If Account A sets a PIN, Account B on the same device inherits that PIN automatically
- A new account on a device that had a PIN set will immediately be locked with someone else's PIN
- Disabling the lock on one account disables it for all accounts on that device

**Root cause:** `lib/services/app_lock_service.dart` uses hardcoded SharedPreferences keys:
```dart
static const _prefPin = 'app_lock_pin';
static const _prefEnabled = 'app_lock_enabled';
```

**Fix:** Make keys per-account by appending the Firebase UID:
```dart
static String _pinKey(String uid) => 'app_lock_pin_$uid';
static String _enabledKey(String uid) => 'app_lock_enabled_$uid';
```

All methods (`setPin`, `verifyPin`, `hasPin`, `removePin`, `isEnabled`, `setEnabled`) need to accept or fetch the current UID.

**Files affected:**
- `lib/services/app_lock_service.dart` — all methods
- `lib/screens/profile_screen.dart` — App Lock setup/disable UI
- `lib/screens/app_lock_screen.dart` — PIN verification
- `lib/screens/pin_setup_screen.dart` — PIN creation
- `lib/main.dart` — `_checkLockOnResume()` calls `AppLockService.isEnabled()`
- `lib/screens/splash_screen.dart` — checks lock on cold start

**Priority:** HIGH — security issue. A new user on a shared device could be locked out with someone else's PIN, or worse, bypass the lock entirely if the previous user disabled it.

**Note:** Biometric itself is device-level (the device's fingerprint/face) so biometric authentication doesn't need to change — only the enabled/disabled state and PIN need to be per-account.

**STATUS: ✅ FIXED (May 3, 2026)**
- `app_lock_service.dart`: All methods now use `app_lock_pin_${uid}` and `app_lock_enabled_${uid}` keys. Added `_getUid()` helper that returns `FirebaseAuth.instance.currentUser?.uid ?? 'demo'`. No changes needed in callers — the service resolves the UID internally.

---

## FULL SharedPreferences AUDIT

| Key | Location | Status | Action needed |
|-----|----------|--------|---------------|
| `tour_done_${uid}` | feature_tour.dart | ✅ FIXED — per-account | Was `tour_done` (device-wide) |
| `app_lock_pin_${uid}` | app_lock_service.dart | ✅ FIXED — per-account | Was `app_lock_pin` (device-wide) |
| `app_lock_enabled_${uid}` | app_lock_service.dart | ✅ FIXED — per-account | Was `app_lock_enabled` (device-wide) |
| `dark_mode` | theme_service.dart | ✅ Acceptable — device-wide | Theme preference is standard device-wide behavior |
| `app_theme` | theme_service.dart | ✅ Acceptable — device-wide | Same as above |
| `ai_chat_count` | ai_chat_service.dart | ✅ Correct — device-wide | Daily limit is per-device intentionally |
| `ai_chat_date` | ai_chat_service.dart | ✅ Correct — device-wide | Same |
| `onboarding_done` | splash/onboarding | ✅ Correct — device-wide | First-launch walkthrough, once per device is fine |
| `was_demo_mode` | login/splash | ✅ Correct — device-wide | Demo isolation flag, correct behavior |

---

## SUMMARY TABLE

| # | Issue | Priority | Effort | Status |
|---|-------|----------|--------|--------|
| 1 | Feature tour not showing for new accounts on same device | HIGH | Low | ✅ Fixed |
| 2 | Use Google profile picture as default avatar | MEDIUM | Low | ❌ Not fixed |
| 3 | Analytics: add Last Month + month picker | MEDIUM | Low | ❌ Not fixed |
| 4 | Backdated expenses: Component 4 scoring fairness | LOW | Low | ❌ Not fixed |
| 5 | CSV/Bank import (GCash, Maya, BDO, BPI) | HIGH (C2) | High | ❌ Capstone 2 |
| 6 | PIN and biometric lock are device-wide, not per-account | HIGH | Medium | ✅ Fixed |
| 7 | Chat history visible across accounts (privacy) | HIGH | Low | ✅ Fixed |

---

## ISSUE 7 — Chat History Visible Across Accounts (Privacy)

**What happens:** `clearLocalData()` in `db_service.dart` intentionally kept `chat_history` across logins with the comment "so AI remembers conversations". This means Account B can see Account A's entire conversation history after logging in on the same device.

**Fix applied:** `chat_history` is now cleared on logout alongside all other financial data. Each account starts with a fresh AI conversation. The AI daily limit (`ai_chat_count`, `ai_chat_date`) remains device-wide intentionally (API key protection).

**STATUS: ✅ FIXED (May 3, 2026)**
- `db_service.dart`: `clearLocalData()` now includes `await db.delete('chat_history')`

---

*Logged by Kiro — May 3, 2026*
*Work through these in order of priority. Issues 2, 3, 4 can be done before defense. Issue 5 is Capstone 2.*
