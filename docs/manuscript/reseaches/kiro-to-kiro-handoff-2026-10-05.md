# Kiro → Kiro Handoff — SmartSpend v2.9.89
**Date:** October 5, 2026 (updated)
**Session scope:** AI stack audit, full app-wide QoL polish (v2.9.82–v2.9.89), RC fix, data quality fixes, wallet history, audit logging, website, App Check token, release automation

---

## Current State

| Metric | Value |
|--------|-------|
| **Version** | 2.9.89+89 |
| **GitHub** | https://github.com/Zushikina-kun/smartspend-app |
| **Website** | https://zushikina-kun.github.io/smartspend-app/ |
| **Privacy Policy** | https://zushikina-kun.github.io/smartspend-app/privacy.html |
| **Release APK** | GitHub Releases → v2.9.89 (arm64-v8a recommended) |
| **AAB** | GitHub Releases → `SmartSpend-v2.9.89.aab` (Play Store upload) |
| **Platform** | Android (Flutter/Dart) |
| **Min SDK** | API 21 (Android 5.0) |
| **Target SDK** | API 36 (Android 16) |
| **Screens** | 43 Dart files |
| **Services** | 31 Dart files |
| **AI providers** | 8 (full fallback chain verified working) |
| **Primary AI model** | Gemini 3.5 Flash-Lite via Google AI Studio (AQ. key) |
| **AI key delivery** | Firebase Remote Config — `gemini_api_key`, `groq_api_key`, `cerebras_api_key` |
| **Agentic actions** | 34 |
| **Badges** | 25 |
| **Color themes** | 11 |
| **Daily AI limit** | 150 |
| **FHS components** | 4 × 25pts |
| **SQLite schema** | v13, 25 tables |
| **App Check debug token** | `1e2e702b-9243-4fff-9744-91011adf7d58` (MuMu Player, registered in Firebase Console) |

---

## What Was Done This Session (v2.9.78 → v2.9.89)

### v2.9.78–v2.9.87 — See previous handoff notes
(AI timeout fix, debt QoL, Gemini AQ. key, silent fallback, AI chat 13 fixes, app-wide QoL polish, delete confirmations, achievement celebration, analytics labels, AI date dividers, goal contribution button, income theme, budget border, filter persistence, home priority banner, chat history search, bank import feedback, Installment/Debt overlap fix, Data Quality View/Fix buttons)

### v2.9.88 — Wallet history + website + AAB CI
- **wallet_history table** (DB v12): every `setWalletBalance` and `transferBetweenWallets` call logs old→new balance, delta, reason, source, timestamp
- **Wallet long-press history sheet**: tap a wallet tile to edit, long-press to see full change history with source icons (✏️ manual, 🤖 AI, ↔️ transfer, 💳 auto-deduct, 💰 income)
- **`setWalletBalance` signature**: now takes optional `reason` and `source` params — all callers (manual edit, AI action, auto-deduct, income log, undo) tagged
- **GitHub Pages website**: `index.html` + `privacy.html` live at https://zushikina-kun.github.io/smartspend-app/
- **AAB build added to CI**: every release tag now builds both split APKs AND `SmartSpend-vX.X.XX.aab` for Play Store upload
- **App Check debug token registered**: `1e2e702b-9243-4fff-9744-91011adf7d58` for MuMu Player emulator — 403 error resolved

### v2.9.89 — Audit logging for budget / goals / income / FHS score
- **DB v13** adds 4 new tables + 1 column:
  - `budget_history` — category, old_amount, new_amount, action (set/delete), source, timestamp
  - `goal_contribution_history` — goal_id, goal_name, old_amount, new_amount, delta, source, timestamp
  - `income_history` — old_amount, new_amount, delta, source, timestamp
  - `score_history.reason` — new column: worst FHS component label + pts each day
- **`setBudget(source:)`** — logs old→new amount; `salary_split` source for `plan_salary_split` AI action
- **`deleteBudget`** — logs deletion to budget_history
- **`updateGoal(source:)`** — logs current_amount delta; source tagged at all call sites (manual/ai/round_up/income_allocation)
- **`setMonthlyIncome(source:)`** — new wrapper replaces old stub; logs income changes; old bare `setSetting` calls eliminated
- **`saveScoreSnapshot(reason:)`** — home_screen derives worst FHS component as reason string ("Lowest: Savings Rate (8/25 pts)")
- **`plan_salary_split` AI action** — now passes `source: 'salary_split'` to both `setBudget` and `setMonthlyIncome`

---

## AI Stack — Verified Working (Oct 5, 2026)

| Component | Status |
|-----------|--------|
| Gemini 3.5 Flash-Lite | ✅ Active (`gemini_key_loaded = YES`, `rc_last_fetch_status = fresh`) |
| Remote Config interval | ✅ 1 hour (restored from `Duration.zero` test value) |
| Groq fallback chain (6 providers) | ✅ Working |
| Cerebras fallback | ✅ Key loaded |
| App Check (MuMu emulator) | ✅ Token registered, 403 error gone |
| `isFallbackRetry` flag | ✅ Prevents daily limit double-counting |
| 35s timeout + silent auto-fallback | ✅ |
| Action JSON parsing | ✅ |
| Duplicate guard | ✅ 90s window + cross-session |
| `_resolveCategory` priority | ✅ User rules → historical → AI → keyword |
| `confidence_score` | ✅ 0.65 Others, 0.9 specific |
| 34 action handlers | ✅ All wired |

**Debug log fields added (v2.9.86–87):**
- `gemini_key_loaded = YES/NO`
- `cerebras_key_loaded = YES/NO`
- `groq_key_loaded = YES/NO`
- `rc_last_fetch_status = fresh/cached/ERROR:...`

---

## ADB / MuMu Setup (for future debug sessions)

```powershell
$adb = "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"
& $adb connect 127.0.0.1:7555          # MuMu Player 12 default ADB port
& $adb devices                          # confirm connected
& $adb -s 127.0.0.1:7555 install -r "path\to\app-debug.apk"
& $adb -s 127.0.0.1:7555 shell am start -n "com.lucidframe.smartspend_app/.MainActivity"
& $adb -s 127.0.0.1:7555 logcat -d | Select-String "AppCheck|firebase|smartspend"
```

Note: If existing release APK blocks debug install, uninstall first:
```powershell
& $adb -s 127.0.0.1:7555 uninstall com.lucidframe.smartspend_app
```

---

## Deployment Status

| Channel | Status |
|---------|--------|
| GitHub Releases | ✅ Live — v2.9.89 (APKs + AAB) |
| GitHub Pages | ✅ https://zushikina-kun.github.io/smartspend-app/ |
| Privacy Policy | ✅ https://zushikina-kun.github.io/smartspend-app/privacy.html |
| APKPure | ⏳ Submit manually — use arm64-v8a APK from GitHub Releases |
| Uptodown | ⏳ Submit manually — use arm64-v8a APK from GitHub Releases |
| Google Play Store | ❌ Post-defense — needs $25 + identity verification + 14-day closed testing |
| App Check debug token | ✅ Registered for MuMu (`1e2e702b-9243-4fff-9744-91011adf7d58`) |
| AAB in CI | ✅ Every tag push auto-builds `SmartSpend-vX.X.XX.aab` |

**For APKPure/Uptodown submission:**
- App name: SmartSpend
- Package: com.lucidframe.smartspend_app
- Category: Finance
- Description: Free AI-assisted personal finance app for Filipino users...
- Privacy Policy URL: https://zushikina-kun.github.io/smartspend-app/privacy.html
- APK: download arm64-v8a from https://github.com/Zushikina-kun/smartspend-app/releases

---

## Remaining Items (Next Session)

### High priority (code — do now)
- Budget history viewer: show budget_history on long-press in budget screen (same pattern as wallet history sheet)
- Goal contribution viewer: show goal_contribution_history on goal card tap or long-press
- Income history viewer: show income_history somewhere in income screen

### Medium priority (manual — Brix)
- Google Play Store: pay $25, create developer account, complete identity verification (takes 1–2 days)
- APKPure submission: https://developer.apkpure.com/
- Uptodown submission: https://developers.uptodown.com/

### Low priority (post-defense)
- App Check enforcement: Firebase Console → App Check → switch from monitoring to enforcement
- Firebase App Check on physical phone: fix Poco X6 Pro USB (Developer Options → Default USB config = MTP) or register another emulator token

---

## Key Numbers for Manuscript (v2.9.89)

| Metric | Value |
|--------|-------|
| Version | 2.9.89 |
| Platform | Android (Flutter/Dart) |
| Min SDK | API 21 (Android 5.0) |
| Target SDK | API 36 (Android 16) |
| Screens | 43 |
| Services | 31 |
| AI providers | 8 |
| Primary AI | Gemini 3.5 Flash-Lite |
| Agentic actions | 34 |
| Badges | 25 |
| Daily quests | 10 |
| Color themes | 11 |
| Daily AI limit | 150 |
| FHS components | 4 × 25pts |
| SQLite schema | v13, 25 tables |
| APK size (release arm64) | ~45 MB |
| AAB size | ~75 MB |
| PH banks in DB | 20 banks + 5 e-wallets |
| Input modalities | 7 |
| Currencies supported | 57 |

## Key File Locations

| File | Purpose |
|------|---------|
| `lib/services/app_config.dart` | AI model routing, Remote Config, fallback chain |
| `lib/services/ai_chat_service.dart` | System prompt, action parsing, context building |
| `lib/services/db_service.dart` | All DB operations — v13 schema, history tables |
| `lib/screens/ai_screen.dart` | UI, action execution, send/retry logic |
| `lib/services/debug_service.dart` | Debug log (key load status, RC fetch status) |
| `lib/screens/debt_screen.dart` | `initialTab` param — `DebtScreen(initialTab: 2)` for Plans |
| `lib/screens/data_quality_screen.dart` | Fix All for all 4 issue types, View navigates to transactions |
| `lib/screens/transactions_screen.dart` | `initialIds` param for filtered view |
| `lib/screens/profile_screen.dart` | `WalletsSheet` — long-press wallet for history |
| `lib/widgets/peso_mascot.dart` | `PesoMascot.withSpeech(mood:, text:)` — param is `text:` not `message:` |
| `index.html` | GitHub Pages landing page |
| `privacy.html` | Privacy Policy (required for Play Store) |
| `.github/workflows/release.yml` | CI — builds APKs + AAB on every tag push |
| `docs/status/PROJECT_STATUS.md` | Defense checklist, demo script |
| `docs/reference/CAPSTONE_REFERENCE.md` | All numbers for manuscript |
