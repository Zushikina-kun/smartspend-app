# SmartSpend — Pending Issues & Feature Requests
**Last Updated:** May 11, 2026 (v2.6.0)

---

## SUMMARY TABLE

| # | Issue | Priority | Status |
|---|-------|----------|--------|
| 1 | Feature tour not showing for new accounts on same device | HIGH | ✅ Fixed (May 3) |
| 2 | Use Google profile picture as default avatar | MEDIUM | ❌ Open |
| 3 | Analytics: add Last Month + month picker | MEDIUM | ❌ Open |
| 4 | Backdated expenses: Component 4 scoring fairness | LOW | ❌ Open |
| 5 | CSV/Bank import (GCash, Maya, BDO, BPI) | HIGH (C2) | ❌ Capstone 2 |
| 6 | PIN and biometric lock are device-wide, not per-account | HIGH | ✅ Fixed (May 3) |
| 7 | Chat history visible across accounts (privacy) | HIGH | ✅ Fixed (May 3) |
| 8 | Wallets not syncing to Firestore | CRITICAL | ✅ Fixed (May 11) |
| 9 | Category rules not syncing to Firestore | HIGH | ✅ Fixed (May 11) |
| 10 | Reset All Data only cleared 6 of 14 tables, didn't wipe Firestore | HIGH | ✅ Fixed (May 11) |
| 11 | Demo data contaminating real user's Firestore | HIGH | ✅ Fixed (May 11) |
| 12 | Backup restore didn't push to Firestore | HIGH | ✅ Fixed (May 11) |
| 13 | Setup onboarding data never pushed to Firestore | HIGH | ✅ Fixed (May 11) |
| 14 | Undo expense edit didn't sync to Firestore | MEDIUM | ✅ Fixed (May 11) |
| 15 | Undo snapshot never recorded for expense edits | MEDIUM | ✅ Fixed (May 11) |
| 16 | renameExpenseCategory didn't sync to Firestore | MEDIUM | ✅ Fixed (May 11) |
| 17 | budget_boss badge broken for % budgets | MEDIUM | ✅ Fixed (May 11) |
| 18 | Notification throttle keys not reset on logout | MEDIUM | ✅ Fixed (May 11) |
| 19 | installments + recurring_candidates not cleared on logout | MEDIUM | ✅ Fixed (May 11) |
| 20 | daily_limit, payday_date, manual_assets not synced to Firestore | MEDIUM | ✅ Fixed (May 11) |
| 21 | syncFromCloud missing goalChanged event | LOW | ✅ Fixed (May 11) |
| 22 | API key hardcoded in two files | SECURITY | ✅ Fixed (May 11) |

---

## OPEN ISSUES

### ISSUE 2 — Profile Photo: Use Google/Gmail Profile Picture as Default

**What happens:** New accounts have no profile photo. Users expect their Google profile picture to appear automatically when they sign in with Google.

**Fix needed:** `login_screen.dart` → `_syncAfterLogin()` — check `user.photoURL` and save it to the profile if no photo is already set. Already partially implemented (the code is there but only runs for Google sign-in, not email/password).

**Priority:** MEDIUM — nice to have, improves first impression

---

### ISSUE 3 — Analytics Period Filter: Missing "Last Month" and Month Picker

**What happens:** No "Last Month" quick filter, no way to select a specific month like "January 2026".

**Fix needed:** `analytics_screen.dart` — add "Last Month" chip and a month/year grid picker.

**Priority:** MEDIUM

---

### ISSUE 4 — Backdated Expenses: Component 4 Scoring Fairness

**What happens:** Bulk-entering old expenses makes Component 4 (Logging Consistency) very low even though the user logged consistently.

**Current mitigation:** Already partially addressed — `activeDays` is capped at `2 × loggedDays` to prevent extreme penalties for retroactive entry.

**Priority:** LOW — edge case

---

### ISSUE 5 — CSV File Import (GCash, Maya, BDO, BPI)

**What's needed:** File picker → parse CSV → preview table → bulk import with duplicate detection.

**Note:** The text-paste bank import (`BankImportScreen`) already handles this via AI parsing. CSV file import is an additional convenience for users who have exported CSV files.

**Packages already in pubspec:** `csv`, `file_picker`

**Priority:** HIGH for Capstone 2

---

## FIXED ISSUES (v2.6.0 — May 11, 2026)

### ISSUE 8 — Wallets Not Syncing to Firestore ✅ FIXED
- `setWalletBalance`, `insertWallet`, `deleteWallet` now call `CloudService.pushDoc/deleteDoc`
- Wallets included in `pullAll`, `pushAll`, `SyncData`, `syncFromCloud`, `pushAllToCloud`
- Backup export + restore now includes wallets
- `clearLocalData` now deletes wallet rows (not zeros) so they restore cleanly from Firestore
- Default wallets only seeded on truly fresh install (no user profile)

### ISSUE 9 — Category Rules Not Syncing to Firestore ✅ FIXED
- `insertCategoryRule` and `deleteCategoryRule` now push to Firestore
- Added to `pullAll`, `pushAll`, `SyncData`, `syncFromCloud`, `pushAllToCloud`
- Backup restore already had category_rules; now also syncs to Firestore after restore

### ISSUE 10 — Reset All Data Incomplete ✅ FIXED
- Now clears all 14 tables: expenses, budgets, savings_goals, income, recurring, debts, score_history, chat_history, installment_plans, installments, custom_categories, mood_log, recurring_candidates, conversation_summaries
- Wallets zeroed (not deleted — user keeps their account)
- Pushes empty state to Firestore via `CloudService.pushAll()` with empty lists

### ISSUE 11 — Demo Data Contaminating Firestore ✅ FIXED
- `DemoService._isDemoLoading` flag added
- `CloudService._shouldSkipSync` checks this flag — demo data never reaches Firestore
- `clearDemoData()` now wipes Firestore if a real user is logged in

### ISSUE 12 — Backup Restore Didn't Push to Firestore ✅ FIXED
- `BackupService.restoreFromFile()` now calls `DBService.pushAllToCloud()` after all data is restored

### ISSUE 13 — Setup Onboarding Data Never Pushed ✅ FIXED
- `SetupScreen._finish()` now calls `pushAllToCloud()` after setup completes
- `RegisterScreen._syncAfterRegister()` clears demo data if `was_demo_mode` was set

### ISSUE 14 & 15 — Undo Expense Edit Broken ✅ FIXED
- `UndoService` `update_expense` case now calls `CloudService.pushDoc` after restoring
- `ai_screen` `update_expense` action now records undo snapshot BEFORE applying the change

### ISSUE 16 — renameExpenseCategory Didn't Sync ✅ FIXED
- Now pushes all affected expense documents to Firestore after bulk rename

### ISSUE 17 — budget_boss Badge Broken for % Budgets ✅ FIXED
- Now resolves `percentageValue / 100 × monthlyIncome` before comparing (same as ScoreService)

### ISSUE 18 — Notification Throttle Keys Not Reset on Logout ✅ FIXED
- `last_weekly_notif`, `last_anomaly_check`, `last_velocity_check`, `last_want_alert`, `last_daily_briefing` all cleared in `clearLocalData()`

### ISSUE 19 — installments + recurring_candidates Not Cleared on Logout ✅ FIXED
- Both tables now deleted in `clearLocalData()`
- `last_recurring_check` also reset

### ISSUE 20 — Settings Not Fully Synced ✅ FIXED
- `daily_limit`, `payday_date`, `manual_assets` added to `pushAllToCloud` settings sync list

### ISSUE 21 — syncFromCloud Missing goalChanged Event ✅ FIXED
- `syncFromCloud` now fires `AppEvent.goalChanged` after merging goals

### ISSUE 22 — API Key Hardcoded in Two Files ✅ FIXED
- Centralized in `lib/services/app_config.dart`
- Both `AIChatService` and `LLMService` reference `AppConfig`
- `app_config.dart` added to `.gitignore`
- `app_config.dart.example` created for new developers

---

## FIXED ISSUES (v2.5.x — May 3–10, 2026)

### ISSUE 1 — Feature Tour Not Showing for New Accounts ✅ FIXED
- `feature_tour.dart`: uses `tour_done_${uid}` (per-account)

### ISSUE 6 — PIN/Biometric Lock Device-Wide ✅ FIXED
- `app_lock_service.dart`: uses `app_lock_pin_${uid}` and `app_lock_enabled_${uid}`

### ISSUE 7 — Chat History Visible Across Accounts ✅ FIXED
- `clearLocalData()` now deletes `chat_history`

---

*Updated by Kiro — May 11, 2026*
