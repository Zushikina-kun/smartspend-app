# Kiro → Kiro Handoff — SmartSpend v2.9.87
**Date:** October 5, 2026
**Session scope:** AI stack audit, full app-wide QoL polish (v2.9.82–v2.9.87), RC fix, data quality fixes, release build

---

## Current State

| Metric | Value |
|--------|-------|
| **Version** | 2.9.87+87 |
| **GitHub** | https://github.com/Zushikina-kun/smartspend-app |
| **Release APK** | `SmartSpend-v2.9.87-release.apk` on GitHub Releases |
| **Platform** | Android (Flutter/Dart) |
| **Min SDK** | API 21 (Android 5.0) |
| **Target SDK** | API 36 (Android 16) |
| **Screens** | 43 Dart files |
| **Services** | 31 Dart files |
| **AI providers** | 8 (full fallback chain verified working) |
| **Primary AI model** | Gemini 3.5 Flash-Lite via Google AI Studio (AQ. key format) |
| **AI key delivery** | Firebase Remote Config — `gemini_api_key`, `groq_api_key`, `cerebras_api_key` |
| **Agentic actions** | 34 |
| **Badges** | 25 |
| **Color themes** | 11 (Emerald is default for new installs) |
| **Daily AI limit** | 150 messages |
| **FHS components** | 4 × 25pts |

---

## What Was Done This Session (v2.9.78 → v2.9.87)

### v2.9.78 — AI timeout + debt QoL
- AI timeout 20s → 35s
- Installment plan date fix (lastDate DateTime(2030))
- Debt due date firstDate fix
- Log payment: payment method picker, partial payment, quick-pay chips
- Debt payment now logs as expense

### v2.9.79 — Gemini AQ. key
- New Gemini AQ. key stored in Firebase Remote Config
- Reverted bad AQ. format check

### v2.9.80 — Silent auto-fallback
- Catches TimeoutException in `_send()`, silently calls `autoFallback()` + `sendMessage()` before showing error buttons

### v2.9.81 — AI chat 13 fixes
- Enter sends, maxLines 4, FAB→IconButton.filled, model chip merged, history→⋮ menu
- Clear chat confirmation, suggestion chips fill input (not auto-send)
- `_topSpendingCategory` excludes Others/Bills/Education
- Voice 600ms pause, confidence_score 0.65 for Others, clipboard nudge uses theme
- Action failed = orange (not red)

### v2.9.82 — App-wide QoL: Peso empty states
- PesoMascot.withSpeech on: savings_goals, recurring, transactions, income, manage_categories, manage_rules
- Delete confirmations: savings_goals, recurring, income
- income_screen FAB hardcoded colors removed
- insurance_screen FAB heroTag added
- savings_goals deadline firstDate fixed to allow past year

### v2.9.83 — More delete confirmations
- budget_screen: delete budget → confirmation dialog
- debt_screen: delete debt → confirmation dialog
- debt_screen: delete installment plan → confirmation dialog
- debt empty state Colors.blue tip → Colors.grey

### v2.9.84 — Achievement celebration + analytics labels + AI dividers
- achievements_screen: SharedPreferences diff detects newly unlocked badges → amber SnackBar celebration
- analytics_screen: interpretive label after monthly bar chart (% above/below average)
- analytics_screen: interpretive label after savings rate chart (% vs 20% target)
- ai_screen: all `_messages.add()` calls include `"ts"` date key
- ai_screen: date dividers (Today/Yesterday/date) between message groups in chat

### v2.9.85 — More polish
- savings_goals_screen: "Add Contribution" OutlinedButton on each unfinished goal card
- income_screen: summary header gradient replaced with `primaryContainer` + `onPrimaryContainer` text
- budget_screen: over-budget cards get red left border (4px)
- whats_new_screen: version bumped to 2.9.84, 5 new entries for v2.9.82–84 features
- transactions_screen: `_selectedCategory` + `_period` persist via SharedPreferences across navigation

### v2.9.86 — Home priority banner + chat search + bank import
- home_screen: `_buildPriorityBanner()` — surfaces over-budget, negative safe-to-spend, low wallet warning at top
- `_PriorityBannerTile` widget added
- chat_history_screen: search bar with real-time filter on message content
- bank_import_screen: transaction count label appends "(credits/income skipped)"
- app_config.dart: `hasGeminiKey`, `hasGroqKey`, `hasCerebrasKey` public getters
- debug_service.dart: logs key load status + `rc_last_fetch_status`
- main.dart: error logging for Remote Config fetch failures

### Remote Config fix (between v2.9.86 and v2.9.87)
**Root cause:** `minimumFetchInterval = 1 hour` + `_fallbackGeminiKey = ""` meant app cached empty defaults and never re-fetched Gemini key.
**Fix:** Set `minimumFetchInterval = Duration.zero` temporarily, add `fetchAndActivate()` error logging, expose fetch status in debug log.
**Confirmed working:** Oct 5 debug log shows `gemini_key_loaded = YES`, `rc_last_fetch_status = fresh`, `model=auto`.
**Final state:** `minimumFetchInterval` restored to `Duration(hours: 1)` for production.

### v2.9.87 — Debt/Installment overlap + Data Quality fixes
- debt_screen: `initialTab` constructor param added (0=I Owe, 1=Owed to Me, 2=Plans)
- home_screen: "Installment & Plans" tool tile now opens `DebtScreen(initialTab: 2)` directly
- data_quality_screen: `_openTransactions()` now navigates to `TransactionsScreen(initialIds: ids)` (was showing useless SnackBar)
- data_quality_screen: added `_fixCaseDups()` and `_fixRoundAmounts()` handlers
- data_quality_screen: Fix All button for `case_dup` (merges to most-used casing)
- data_quality_screen: Fix All button for `round_amount` (confirmation dialog → delete)
- data_quality_service.dart: added `fixCaseDups()` and `deleteRoundAmounts()` methods
- transactions_screen: accepts `initialIds` param for filtered view from Data Quality

---

## AI Stack — Verified Working (Oct 5, 2026)

| Component | Status |
|-----------|--------|
| Gemini 3.5 Flash-Lite | ✅ Active (`gemini_key_loaded = YES`) |
| Groq fallback chain (6 providers) | ✅ Working |
| Cerebras fallback | ✅ Key loaded |
| Remote Config fetch | ✅ `fresh` on first open, `cached` thereafter |
| `isFallbackRetry` flag | ✅ Prevents daily limit double-counting |
| 35s timeout | ✅ |
| Silent auto-fallback on timeout | ✅ (v2.9.80) |
| Action JSON parsing | ✅ Brace-depth counter, unclosed brace recovery |
| Duplicate guard | ✅ 90s window + cross-session |
| `_resolveCategory` priority | ✅ User rules → historical → AI → keyword |
| `confidence_score` | ✅ 0.65 Others, 0.9 specific → Review chip at <0.70 |
| 34 action handlers | ✅ All wired in `_executeAction` |

**Model routing (Auto mode):**
- `fast` tasks (expense logging) → Gemini 3.5 Flash-Lite
- `financial_advice` → Gemini 3.5 Flash (best reasoning)
- `smart` (general) → Gemini 3.5 Flash-Lite

---

## Known Remaining Issues / Next Steps

### For defense prep
- **App Check debug token** — must register UUID from logcat in Firebase Console → App Check → Android app → Manage debug tokens. Get it by running app with `AndroidProvider.debug` and filtering logcat for `FirebaseAppCheck`.
- **Demo phone** — install `SmartSpend-v2.9.87-release.apk` from GitHub Releases
- **Remote Config** — keys are all published and working. No action needed.

### For manuscript (Cyrille)
- Update version to **2.9.87** throughout
- AI section: primary model is now **Gemini 3.5 Flash-Lite** (AQ. key from Firebase Remote Config); 8-provider fallback chain (Gemini Flash → Flash-Lite → GPT-OSS 120B → Qwen3.6 → Qwen3.8 → Compound → Compound Mini → Cerebras)
- Screens: **43**
- Agentic actions: **34**
- Badges: **25**
- Daily AI limit: **150**
- Color themes: **11**
- APK size: **~113 MB** (release, obfuscated)

### Still open from backlog (low priority)
- Monthly "Wrapped" shareable card (Feature 5D upgrade)
- Notification Listener for GCash (post-capstone)
- PSE/MP2/UITF investment tracker (post-capstone)
- iOS / web version (post-capstone)

---

## File Locations

| File | Purpose |
|------|---------|
| `lib/services/app_config.dart` | AI model routing, Remote Config, fallback chain |
| `lib/services/ai_chat_service.dart` | System prompt, action parsing, context building |
| `lib/screens/ai_screen.dart` | UI, action execution, send/retry logic |
| `lib/services/debug_service.dart` | Debug log generation (v2.9.87: key load status) |
| `lib/screens/debt_screen.dart` | `initialTab` param — use `DebtScreen(initialTab: 2)` for Plans |
| `lib/screens/data_quality_screen.dart` | Fix All handlers for all 4 issue types |
| `lib/services/data_quality_service.dart` | `fixCaseDups()`, `deleteRoundAmounts()`, `fixOthersCategory()` |
| `lib/screens/transactions_screen.dart` | `initialIds` param for filtered view |
| `lib/widgets/peso_mascot.dart` | `PesoMascot.withSpeech(mood:, text:)` — note: param is `text:` not `message:` |
| `docs/status/PROJECT_STATUS.md` | Defense checklist, demo script |
| `docs/reference/CAPSTONE_REFERENCE.md` | All numbers for manuscript |
| `docs/guides/FEATURE_BACKLOG.md` | Full feature planning, competitor analysis |

---

## Key Numbers for Manuscript (v2.9.87)

| Metric | Value | Source |
|--------|-------|--------|
| Version | 2.9.87 | pubspec.yaml |
| Platform | Android (Flutter/Dart) | — |
| Min SDK | API 21 (Android 5.0) | — |
| Target SDK | API 36 (Android 16) | — |
| Screens | 43 | lib/screens/ count |
| Services | 31 | lib/services/ count |
| AI providers | 8 | AppConfig.availableModels |
| Primary AI | Gemini 3.5 Flash-Lite | app_config.dart |
| Agentic actions | 34 | ai_chat_service.dart system prompt |
| Badges | 25 | achievements_screen.dart `_allBadges` |
| Daily quests | 10 | — |
| Color themes | 11 | theme_service.dart |
| Daily AI limit | 150 | ai_chat_service.dart `_dailyLimit` |
| FHS components | 4 × 25pts | score_service.dart |
| Filipino item catalog | 150+ items | add_expense_screen.dart |
| APK size (release) | ~113 MB | build output |
| PH banks in DB | 20 banks + 5 e-wallets | bank_comparison_screen.dart |
| Input modalities | 7 (text, voice, OCR, barcode, screenshot, CSV paste, share intent) | — |
| Currencies supported | 57 | currency_service.dart |
| SQLite schema version | v11, 20 tables | db_service.dart |
