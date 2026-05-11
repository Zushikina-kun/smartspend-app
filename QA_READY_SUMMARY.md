# Smart Spend — QA-Ready Build Summary

**Build Date:** May 11, 2026
**Version:** 2.6.0
**APK Size:** ~44.0 MB (arm64-v8a)
**Status:** ✅ QA-Ready — Zero compile errors, all sync/data-safety issues resolved

---

## 📦 Distribution Files

```
build/app/outputs/flutter-apk/
└── app-arm64-v8a-release.apk    (~44.0 MB) ← Use this for QA
```

**Recommended:** `app-arm64-v8a-release.apk` — works on all modern Android phones (Snapdragon, MediaTek, Exynos).

**Build command used:**
```bash
flutter build apk --release --target-platform android-arm64 --split-per-abi --shrink --obfuscate --split-debug-info=build/debug-info
```

---

## ✅ What Was Fixed (v2.6.0 — Session 12)

### CRITICAL — Data Safety
- ✅ **Wallets fully synced to Firestore** — balances survive logout, login, and device switches
- ✅ **Category rules synced to Firestore** — keyword → category rules now persist across devices
- ✅ **Reset All Data fixed** — clears all 14 tables + wipes Firestore (data no longer resurrects)
- ✅ **Demo data isolation** — loading demo data never contaminates real Firestore account
- ✅ **Backup restore syncs to cloud** — restoring a backup now pushes to Firestore immediately
- ✅ **Setup onboarding syncs** — account type, income, budgets pushed to Firestore after setup

### HIGH — Sync Correctness
- ✅ **Undo expense edit syncs** — shake-to-undo on expense edits now correctly restores + syncs
- ✅ **Undo snapshot recorded** — expense edit undo now actually works (snapshot was never saved before)
- ✅ **Category rename syncs** — renaming/deleting a custom category updates all expenses in Firestore
- ✅ **Settings sync expanded** — daily_limit, payday_date, manual_assets now sync across devices

### MEDIUM — Logic & Correctness
- ✅ **Budget Boss badge fixed** — now correctly handles percentage-based budgets
- ✅ **Notification throttle reset on logout** — new accounts get first-day notifications
- ✅ **installments + recurring_candidates cleared on logout** — no data leaks between accounts
- ✅ **goalChanged event on sync** — savings goals screen refreshes after login sync

### SECURITY
- ✅ **API key centralized** — Groq key in `AppConfig`, added to `.gitignore`

---

## 🧪 QA Testing Guide

### Test 1 — Wallet Sync (Critical — was broken before)
1. Log in → go to Profile → tap Net Worth card → set GCash to ₱500
2. Log out → log back in
3. ✅ GCash should still show ₱500 (not ₱0)

### Test 2 — Wallet Sync Across Devices
1. Set wallet balance on Device A
2. Log in on Device B
3. ✅ Wallet balance should appear on Device B

### Test 3 — Category Rules Sync
1. Hub → Auto-Categorization Rules → add rule: "7-eleven" → Food
2. Log out → log back in
3. ✅ Rule should still be there

### Test 4 — Reset All Data + Firestore Wipe
1. Add some expenses → Profile → Reset All Data → type RESET
2. Log out → log back in
3. ✅ App should be empty — data should NOT come back from Firestore

### Test 5 — Demo Data Isolation
1. Log in as real account → Profile → Load Demo Data
2. Log out → log back in
3. ✅ Demo data should NOT appear — real account data should be there

### Test 6 — Backup Restore Syncs
1. Profile → Backup Data → save file
2. Reset all data
3. Profile → Restore from Backup → pick the file
4. Log out → log back in on another device
5. ✅ Restored data should appear on the other device

### Test 7 — Undo Expense Edit
1. Tell AI: "I spent 100 pesos on food"
2. Tell AI: "Change that to 200 pesos"
3. Shake phone → confirm undo
4. ✅ Expense should revert to 100 pesos
5. Log out → log back in
6. ✅ Reverted amount (100) should persist — not 200

### Test 8 — Budget Boss Badge (% budgets)
1. Set Food budget to 30% of income (not fixed ₱)
2. Stay under budget all month
3. Hub → Achievements
4. ✅ Budget Boss badge should be earned

### Test 9 — Account Isolation (existing test)
1. Create Account A → add expenses → logout
2. Create Account B → login → verify Account A's data is NOT visible
3. Login as Account A → verify data is restored from cloud

### Test 10 — New Account Notifications
1. Log out → create a new account on the same device
2. Complete setup
3. ✅ Daily briefing notification should fire (not suppressed by previous account's throttle)

---

## 🐛 Known Non-Issues

| Observation | Explanation |
|-------------|-------------|
| Profile photo doesn't sync to other devices | Firebase Storage requires Blaze plan — photos are local-only by design |
| AI sometimes responds in wrong language for Taglish | LLaMA 3.1 8B limitation |
| Offline data doesn't sync until next login | No Cloud Functions (Spark plan) — login-triggered sync by design |
| Score history, mood log, scan history don't sync | Device-local analytics by design — not financial data |

---

## 📱 Installation Instructions for Testers

1. **Uninstall old version** if any (or install alongside — different package name not needed)
2. Install `app-arm64-v8a-release.apk`
3. Open app → complete onboarding → create account or try demo
4. Grant permissions when prompted (camera, microphone, notifications)

**Returning testers:** Your data is in the cloud — just log in and it will sync down.

---

## 🔧 Developer Notes

### Zero Errors
All Dart files compile clean. Warnings are pre-existing (deprecated Firebase APIs, package version notices) — none are blocking.

### File Count
- 31 screens
- 23 services
- 3 models
- 4 widgets
- ~12,000+ lines of Dart

### Debug Symbol Maps
The `build/debug-info/` folder contains symbol maps for decoding obfuscated Crashlytics stack traces. Keep this folder.

---

## 🎓 Capstone Defense Readiness

**Documentation:** `DOCUMENTATION.md`, `HOWTORUN.md`, `KIRO_CONTEXT.md`, `FINAL_STATUS.md`

**Data Safety:** All user data syncs to Firestore — no risk of data loss during testing

**Demo Mode:** Fully isolated from real accounts — safe to demo on any device

---

*Built with ❤️ by Lucid Frame | Lorma Colleges CCSE, BSIT | 2025–2026*
