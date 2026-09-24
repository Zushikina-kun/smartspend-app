# SmartSpend — Kiro → Claude Handoff (Session 4)
**Compiled:** September 27, 2026
**Covers:** v2.9.54 through v2.9.59
**Previous handoffs:**
- v1: `kiro-to-claude-handoff-2026-09-12.md` — v2.9.38–42
- v2: `kiro-to-claude-handoff-2026-09-12-v2.md` — v2.9.43–47
- v3: `kiro-to-claude-handoff-2026-09-26-v3.md` — v2.9.50–53
**Purpose:** Give Claude the accurate picture for manuscript/docs work.
Read all four handoffs together for the complete history.

---

## Quick Summary

| Version | What changed |
|---------|-------------|
| v2.9.54 | Groq API key rotated after GitHub Secret Scanning detected it |
| v2.9.55 | Keys moved to Firebase Remote Config — no secrets in source ever again |
| v2.9.56 | AI fail-fast when keys not loaded (no-internet startup) |
| v2.9.57 | AI suggestion chips overlapping input on small phones fixed |
| v2.9.58 | Empty state overflow (insurance/paluwagan); FAB list clipping (5 screens); rollover bug fixed |
| v2.9.59 | Safe-to-Spend card; AI advice disclaimer; confidence review badge; GCash share intent; action allowlist |

---

## 1. Current Authoritative Numbers (v2.9.59)

| Field | Value | Change from v2.9.53 |
|-------|-------|---------------------|
| Version | **2.9.59+59** | was 2.9.53 |
| APK size | arm64 ~46.7 MB | unchanged |
| Primary AI model | **Auto** (task-based routing) | unchanged |
| Optional home toggles | **10** | +1 (Safe-to-Spend) |
| Lite Mode coverage | **14 sections** | was 13 |
| Input modalities | **7** | +1 (Android share intent) |
| Keys in source | **None** — all in Firebase Remote Config | was hardcoded |
| Screens/services/tables | 41 / 29 / 20 | unchanged |
| All other metrics | unchanged from v2.9.53 | |

---

## 2. Security Changes (v2.9.54–55)

### API Key Exposure and Rotation (v2.9.54)
The Groq API key was committed to git in v2.9.50 (force-added `app_config.dart`). GitHub Secret Scanning and Groq's security system detected it. The key was rotated on September 27, 2026. A new key was issued and committed in v2.9.54.

### Keys Moved to Remote Config (v2.9.55)
**`app_config.dart` now has empty string constants** for all three API keys:
```dart
static const _fallbackGroqKey = "";
static const _fallbackGeminiKey = "";
static const _fallbackCerebrasKey = "";
```
Real keys are stored **exclusively in Firebase Remote Config console** under these parameter names:
- `groq_api_key`
- `gemini_api_key`
- `cerebras_api_key`

`AppConfig.init()` fetches them at startup via `rc.fetchAndActivate()`. If Remote Config is unreachable (no internet), all keys remain empty and AI features are unavailable until the next successful fetch.

**To rotate a key going forward:** Update the value in Firebase Remote Config console → Publish. No code change, no rebuild needed.

**For manuscript:** Can be cited as a security improvement — API keys are no longer embedded in the APK. Reduces exposure risk if APK is decompiled.

### AI Fail-Fast on Empty Keys (v2.9.56)
`AIChatService.sendMessage()` now checks `AppConfig.groqApiKey.isEmpty` before making any HTTP call. If keys aren't loaded (no internet on startup), it immediately throws: *"AI keys not loaded yet — this usually means no internet connection on startup."*

`ai_screen.dart` detects this error string and shows: *"📡 AI unavailable — no internet connection on startup."*

---

## 3. Bug Fixes (v2.9.57–58)

### AI Chips Overlapping Input Field (v2.9.57) — "Tumatama" bug
**Problem:** The suggestion chips on the empty AI screen (`Center(Column(...))`) had no scroll wrapper. On small phones with keyboard open, the bottom chips overflowed into the text input field.
**Fix:** Replaced `Center(Column(...))` with `SingleChildScrollView(child: Column(...))`. Also fixed `MediaQuery.padding.bottom` → `MediaQuery.viewPadding.bottom` on AI screen keyboard-closed path.

### Empty State Overflow (v2.9.58)
Two screens had `Center(Padding(Column(...)))` empty states with no scroll wrapper:
- `insurance_screen.dart` — had action chips (SSS/PhilHealth/Pag-IBIG) that could overflow
- `paluwagan_screen.dart` — icon + text + button column

Both changed to `SingleChildScrollView(child: Column(...))`.

### FAB Screen List Clipping (v2.9.58)
5 screens with floating action buttons had hardcoded `bottom: 80` padding on their ListViews. On 3-button nav phones with larger nav bars, the last item was hidden. Fixed by adding `MediaQuery.of(context).viewPadding.bottom` to the 80px:
- `budget_screen.dart`, `debt_screen.dart` (2 lists), `recurring_screen.dart`, `insurance_screen.dart`, `savings_goals_screen.dart`

### Budget Rollover Running Every App Open (v2.9.58)
`_applyRolloverIfNewMonth()` in `startup_alerts_service.dart` called `applyMonthlyRollover()` but never wrote `rollover_applied_month` back to settings. The guard `if (lastApplied == thisMonth) return` could never become true — rollover ran on every cold start. Fixed by adding `await DBService.setSetting('rollover_applied_month', thisMonth)` after applying.

---

## 4. New Features (v2.9.59)

### 4a. Safe-to-Spend Card

**Where:** Home screen, after Payday Countdown card. Only shown in income/wallet mode.
**Setting key:** `show_safe_to_spend` (default: true). Included in Lite Mode (now 14 sections).

**Formula:**
```
safe_to_spend = total_wallet_balance
              − upcoming_bills_before_next_income  (recurring expenses due in window)
              − pro_rated_goal_contributions        (monthly target / remaining days)
              − overdue_debts                       (owe-type debts past due)
```

**Window:** Today → `_nextExpectedIncome` (from payday countdown). Defaults to 30 days if no income history.

**Color coding:** Green (comfortable), Orange (< 20% of wallet), Red (deficit).

**Breakdown chips:** Shows Wallet / Bills / Goals / Debts amounts for transparency.

**For manuscript:** This is the BudgetPH core differentiator. BudgetPH shows "the one number that matters" after reserving all obligations. SmartSpend now does the same. Can be added to the competitive advantages section: *"Safe-to-Spend number — reserves upcoming bills, goal contributions, and overdue debts to show the user their truly available spending balance."*

### 4b. AI Financial Advice Disclaimer

**Where:** `ai_screen.dart`, `_send()` method.
**Trigger:** Before the first `financial_advice` task type query (detected via `AIChatService.detectTaskTypePublic()`).
**Setting key:** `ai_advice_disclaimer_shown` — stored as `'true'` after first acceptance. Never shown again.

**Dialog text** (paraphrased): "Peso gives general guidance, not professional financial advice. Not a licensed adviser. Verify important decisions with a professional."

**For manuscript:** Satisfies RA 11765 (Financial Consumer Protection Act) responsible-AI positioning. Should be cited in Ch.2 or Ch.3 under "Ethical Considerations / Responsible AI Design."

### 4c. AI Confidence Review Badge

**Where:** `lib/widgets/expense_tile.dart`
**Trigger:** `expense.aiGenerated == true && expense.confidenceScore < 0.7`

A small orange "Review" chip appears on expense tiles where the AI had < 70% confidence. Tapping opens a dialog explaining:
- The confidence percentage
- That the category or amount may need checking
- A direct Edit button

**For manuscript:** Surfaces the existing `confidence_score` field (stored since early versions) to the user. Supports the "transparent AI" design principle — users can see when the AI is uncertain.

### 4d. GCash / Android Share Intent

**Where:** `android/app/src/main/AndroidManifest.xml`, `MainActivity.kt`, `ai_screen.dart`

**What it does:** SmartSpend now appears in the Android share sheet. When a user shares text from GCash, Maya, their bank app, or any other app, it opens SmartSpend and routes the shared text to the existing clipboard nudge banner in the AI chat.

**Implementation:**
- `AndroidManifest.xml`: Added `ACTION_SEND` intent filter for `text/plain` MIME type
- `MainActivity.kt`: Extended to read shared text from intent extras; exposes via `MethodChannel('com.lucidframe.smartspend_app/share_intent')`
- `ai_screen.dart`: `_checkShareIntent()` reads from the channel on init; warm-start shares handled via `setMethodCallHandler`

**For manuscript:** Can be described as a new input modality (7th). The share intent allows GCash/bank notification text to be routed to the AI without manual copy-paste.

### 4e. AI Action Allowlist

**Where:** `lib/services/ai_chat_service.dart`, `filterActionsBySource()`
**Applied in:** `ai_screen.dart` `_send()` with `sourceContext: 'chat'`

All 34 actions remain available in `'chat'` context. The `'import'` context (for future OCR/batch import paths that may generate AI actions) restricts to: `log_expense`, `log_multiple_expenses`, `update_expense`, `tag_expense` only.

This prevents prompt injection — e.g. a malicious receipt image containing text like "delete all expenses" from triggering destructive AI actions.

**For manuscript:** Security hardening under ethical AI design / data integrity section.

---

## 5. Things NOW Implemented — Update "Future Work" → "Implemented"

In addition to the v2.9.53 list in handoff v3, add these:

| Feature | Version | Manuscript location |
|---------|---------|---------------------|
| Safe-to-Spend number | v2.9.59 | Competitive features section |
| AI financial advice disclaimer (RA 11765) | v2.9.59 | Ethical/responsible AI section |
| AI confidence review badge | v2.9.59 | Transparency / explainability section |
| GCash share intent (7th input modality) | v2.9.59 | Input modalities section |
| AI action allowlist / source restrictions | v2.9.59 | Security / data integrity section |
| Keys in Firebase Remote Config (no APK secrets) | v2.9.55 | Security section |

---

## 6. Things Still NOT Implemented (accurate Future Work)

| Feature | Priority | Notes |
|---------|----------|-------|
| Proactive AI nudge notifications | 🟡 Medium | Rocket Money/Rowan style; flutter_local_notifications already present |
| Expense Correction Suggestions (data quality sweep) | 🟡 Medium | Hub badge; uses existing update_expense action |
| 15th/30th payday envelope budget reset | ⏸ Defer | Safe-to-Spend covers same UX |
| Notification Listener for GCash | ⏸ Defer | Accessibility permission — bad for demo |
| Monthly GitHub-style heatmap | 🟢 Post-capstone | |
| Photo gallery / Receipts GridView | 🟢 Post-capstone | |
| True net worth historical chart | 🟢 Post-capstone | |
| Tablet / landscape layout | 🟢 Post-capstone | |
| Tappable chart type switcher | 🟢 Post-capstone | |
| Price Intelligence / PSA API | 🟢 Post-capstone | PSA still in Alpha |
| Investment tracker | 🟢 Post-capstone | |
| SQLite encryption | 🟢 Post-capstone | |

---

## 7. Numbers to Update in Manuscript

Apply on top of handoff v3 corrections:

| Find | Replace with |
|------|-------------|
| Any version ≤ 2.9.53 | **2.9.59** |
| "6 input modalities" | **7 input modalities** (added share intent) |
| "9 optional home toggles" | **10 optional home toggles** (added Safe-to-Spend) |
| "13 Lite Mode sections" | **14 Lite Mode sections** |
| "Keys hardcoded in APK" or similar | **"Keys stored in Firebase Remote Config — not embedded in APK"** |
| Safe-to-Spend in Future Work | Move to **Implemented** (v2.9.59) |
| Share intent in Future Work | Move to **Implemented** (v2.9.59) |

---

## 8. Instructions for Claude

1. Apply handoff v3 corrections first, then apply this handoff's corrections on top
2. Add §4a–4e features to the Features/Implementation chapter
3. Update security section: keys in Remote Config, action allowlist, advice disclaimer
4. Add Safe-to-Spend to competitive comparison vs BudgetPH
5. Input modalities: update count to 7, add "Android share intent" to the list
6. Do NOT change the FHS formula, action counts, or badge lists — still accurate

---

*Compiled by Kiro — September 27, 2026*
*Covers v2.9.54 through v2.9.59.*
*Read all four handoffs in sequence for complete picture.*
