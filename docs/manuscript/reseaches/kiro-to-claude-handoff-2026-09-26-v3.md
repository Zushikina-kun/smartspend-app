# SmartSpend — Kiro → Claude Handoff (Session 3)
**Compiled:** September 26, 2026
**Covers:** All code changes from v2.9.48 through v2.9.53
**Previous handoffs:**
- `kiro-to-claude-handoff-2026-09-12.md` — covered v2.9.38–v2.9.42
- `kiro-to-claude-handoff-2026-09-12-v2.md` — covered v2.9.43–v2.9.47
**Purpose:** Give Claude the accurate picture of the app so manuscript/docs work is grounded in reality.
Read all three handoffs together for the complete picture.

---

## Quick Summary

| Version | What changed |
|---------|-------------|
| v2.9.48 | (internal — minor fixes, no manuscript impact) |
| v2.9.49 | (baseline before this sprint — stable release) |
| v2.9.50 | Nav bar overlap fixed (all 8 screens); Auto AI model mode; smarter failover |
| v2.9.51 | Critical fix: AI fallback chain was silently failing |
| v2.9.52 | Tier 1 features: 5 new features (see §4) |
| v2.9.53 | Settings refinement: 3 new home screen toggles; Lite Mode expanded to 13 |

---

## 1. Current Authoritative Numbers (v2.9.53)

These supersede the v2.9.47 numbers from the previous handoff. Use these everywhere in the manuscript:

| Field | Value | Change from v2.9.47 |
|-------|-------|---------------------|
| Version string | **2.9.53** | was 2.9.47 |
| Build code | **2.9.53+53** | was 2.9.47+47 |
| APK sizes | arm64-v8a ~46.7 MB, armeabi-v7a ~39.4 MB, x86_64 ~49.7 MB | slight increase |
| AI providers (fallback chain) | **8** | unchanged |
| Primary AI model | **Auto (Gemini 3.5 Flash-Lite by default)** | was Gemini 3.5 Flash-Lite fixed |
| AI model routing | **Dynamic per task type** (new Auto mode) | was fixed provider |
| Agentic actions | **34** | unchanged |
| Achievement badges | **25** | unchanged |
| Daily AI message limit | **150 messages/day** | unchanged |
| SQLite schema | v11, **20 tables** | unchanged |
| Screens | **37** | unchanged |
| Services | **26+** | unchanged |
| Hub tiles | **26** | unchanged |
| Currencies | **57** | unchanged |
| Batch screenshot platforms | **40+** | unchanged |
| Filipino item catalog | **150+ items** | unchanged |
| Log choice sheet options | **7** | unchanged |
| PH banks in DB | **20 banks + 5 e-wallets** | unchanged |
| Color themes | **10** | unchanged |
| Daily quests pool | **10** | unchanged |
| Optional home section toggles | **9** (was 6) | 3 new: payday countdown, monthly recap, challenges |
| Optional analytics section toggles | **4** | unchanged |
| Lite Mode coverage | **13 optional sections** (was 10) | 3 new added |
| About screen version | **Auto-synced from `kAppVersion`** | unchanged |

---

## 2. Nav Bar Overlap Fix (v2.9.50) — All 8 Screens

**Problem:** `main.dart` sets `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` + transparent nav bar. On 3-button navigation phones, the app draws behind the system nav bar, cutting off buttons and inputs.

**Root cause:** Code was using `MediaQuery.padding.bottom` which returns 0 when the keyboard is open in edgeToEdge mode. The correct property is `MediaQuery.viewPadding.bottom` which always reflects the physical nav bar height.

**Files fixed and how:**

| Screen | Fix applied |
|--------|------------|
| `home_screen.dart` (BottomAppBar) | Wrapped inner Row in `SafeArea(top:false)`, `padding:EdgeInsets.zero`, increased nav item vertical padding 6→8 |
| `ai_screen.dart` (input row) | `SafeArea(top:false)`, when keyboard closed: `bottom = MediaQuery.padding.bottom + 8` |
| `login_screen.dart` | `SingleChildScrollView` padding: `EdgeInsets.only(..., bottom: 28 + MediaQuery.of(context).viewPadding.bottom)` |
| `register_screen.dart` | Same as login_screen |
| `setup_screen.dart` | `body: SafeArea(top:false)` + `SizedBox(height: viewPadding.bottom > 0 ? 8 : 0)` after button row |
| `onboarding_screen.dart` | `Builder` wrapping `Positioned(bottom: 24 + MediaQuery.of(context).viewPadding.bottom, ...)` |
| `batch_manual_entry_screen.dart` | Footer: `EdgeInsets.fromLTRB(16, 8, 16, 12 + MediaQuery.of(context).viewPadding.bottom)` |
| `whats_new_screen.dart` | `body: SafeArea(top:false, child: Column(...))` |

**Design decision kept:** `SystemUiMode.edgeToEdge` intentionally preserved — modern full-bleed look. The fix is to add bottom clearance, not to disable edge-to-edge.

---

## 3. AI System Overhaul (v2.9.50–2.9.51)

### 3a. Auto Model Mode (v2.9.50)

A new `'auto'` entry was added as the first option in `AppConfig.availableModels`. It is now the default model for all new installs (previously defaulted to `gemini_flash_lite` fixed).

**How Auto routing works (`_autoActualModel()` in `app_config.dart`):**

| Task type | Routes to |
|-----------|-----------|
| `fast` (expense logging, quick queries) | Gemini 3.5 Flash-Lite |
| `financial_advice` (complex reasoning, tax, debt) | Gemini 3.5 Flash |
| `smart` (general chat, planning) | Gemini 3.5 Flash-Lite |

**`activeModelLabel` getter:** When in Auto mode, displays `"Auto · Gemini 3.5 Flash-Lite"` dynamically so users always see which model is actually running.

**In the model selector UI** (App Settings → AI MODEL): `Auto (Recommended)` appears first with description `"🤖 Picks the best model for each task — fast for logging, best for advice"`. All other 8 models still selectable manually.

### 3b. Smarter AI Failover (v2.9.50)

Three improvements to `ai_chat_service.dart`:

1. **500ms grace delay** before switching on 404/401/403 errors — gives slow connections time to stabilize before burning through providers
2. **Distinct error messages:**
   - Network timeout → `"Couldn't reach the AI — looks like a slow or unstable connection. Check your internet and try again."`
   - Auth failure → `"Couldn't authenticate with any AI provider (error 404). This is an API key issue, not your connection. Try the ⋮ menu → Reset Daily Limit, or check Settings."`
3. **`resetLimits()` called** when all providers exhausted — resets chain back to `'auto'` instead of staying permanently dead

### 3c. Critical Fallback Fix (v2.9.51)

**Bug:** `sendMessage()` was called recursively on each fallback attempt. Each recursive call re-ran `_checkAndIncrementLimit()` at line 1 of the function, double-counting the daily message slot. This caused the daily counter to hit its limit immediately, blocking every provider switch. The debug log confirmed this: the message "authentication failed on all providers" appeared 5+ consecutive times without any model switching.

**Fix:** Added `{bool isFallbackRetry = false}` named parameter to `sendMessage()`. When `true`, the function skips `_checkAndIncrementLimit()` and `_history.add()`. Both recursive fallback calls (`429` and `401/403/404` paths) now pass `isFallbackRetry: true`.

**Manuscript note:** This can be cited as a real-world API resilience fix. The fallback chain (8 providers) now actually functions as designed.

---

## 4. Tier 1 New Features (v2.9.52)

Five features shipped in one release. Each is documented below for manuscript integration.

### 4a. "What Changed?" Monthly Recap Alert

**Where:** `lib/services/startup_alerts_service.dart`, `checkAlerts()` method

**What it does:** On the first 3 days of each new month, the app surfaces a `StartupAlert` modal comparing last month's total spending vs the month before. Shows: total spent, ₱ difference, whether improved or worsened, and top spending category.

**Logic:**
```
fires if: now.day <= 3
           AND show_monthly_recap setting != 'false'  (can be disabled in Settings)
           AND 'monthly_delta_notif_YYYY-MM' key not yet set
           AND both months have ≥3 expenses and >₱0 spent
```

**Example output:** `"📊 September Recap — You spent ₱2,085 — ₱420 less than August ✅. Top: Food."`

**For manuscript:** This is a proactive financial awareness feature — no AI call required, pure DB computation. Comparable to the monthly summaries in Mint and YNAB. First-time fires on day 1–3 of October for users with September data.

### 4b. Semester Interval in Recurring Detector

**Where:** `lib/services/db_service.dart` (recurring candidate detection), `lib/services/recurring_helper.dart` (`_advanceDate()`)

**What it does:** The recurring expense detector now recognizes a new interval: **120–135 days** (`'semester'` frequency), which covers school semester fees, trimestral billing, and quarterly-adjacent cycles.

**Before this fix:** `RecurringHelper._advanceDate()` only handled `daily`, `weekly`, and `yearly` — all other frequencies (biweekly, quarterly, semester, semi-annual) silently fell through to `default: monthly`. This was a silent bug causing incorrect next-due-date calculations for all non-weekly/non-monthly/non-yearly recurring items.

**Fixed cases:**

| Frequency | Advance logic |
|-----------|--------------|
| `biweekly` | +14 days |
| `quarterly` | +3 months (calendar-safe) |
| `semester` | +4 months (calendar-safe) |
| `semi-annual` | +6 months (calendar-safe) |
| `yearly` | +1 year |

**For manuscript:** Semester interval detection is directly relevant to the primary target demographic (Filipino college students). School tuition, enrollment fees, and library clearance fees follow a ~120-day semester cadence.

### 4c. AI Chat History Export

**Where:** `lib/screens/ai_screen.dart`, overflow menu (⋮)

**What it does:** New "Export Chat History" option in the AI screen menu. Fetches up to 500 messages from `chat_history` table, formats them as a timestamped plain-text file with role labels (`You:` / `Peso (AI):`), writes to temp directory, and shares via the device's share sheet (`share_plus`).

**Export format:**
```
SmartSpend AI Chat Export
Exported: 2026-09-26 14:32
Messages: 36
================================================

[Sep 23, 2026 11:41 AM]
You: yesterday sep 22, i spent 30 for jeep...

[Sep 23, 2026 11:41 AM]
Peso (AI): Got it, logged your jeepney fare 🚌...
```

**For manuscript:** Adds data portability — users can export their full AI conversation history. Supports RA 10173 data subject rights (right to data portability). Can be filed under "Data Management" features.

### 4d. Auto-Categorization Evidence Threshold

**Where:** `lib/services/db_service.dart` (`getMostFrequentCategoryForItem()`), `lib/services/ai_chat_service.dart` (`_resolveCategory()`)

**Problem it solves:** The AI occasionally miscategorizes a known item. For example, "Sting" (an energy drink) consistently logged as `Food` 10+ times, but on the 11th entry the AI suggests `Others`. Without this fix, the AI's wrong guess would override the user's established history.

**How it works:**

New `DBService.getMostFrequentCategoryForItem(String itemName)` method:
```sql
SELECT category, COUNT(*) AS cnt
FROM expenses
WHERE LOWER(item_name) = LOWER(?)
GROUP BY category
ORDER BY cnt DESC
LIMIT 5
```
Returns the dominant category only if:
- ≥3 total prior entries for that item name
- Top category accounts for ≥60% of those entries

New `AIChatService._resolveCategory(String aiCategory, String itemName)` async helper applies this priority order:
1. **Historical majority** (from `getMostFrequentCategoryForItem`) — highest priority
2. **AI's suggestion** (keyword-normalized via `_normalizeCategory`)
3. **Keyword fallback** on the item name

Both category-assignment sites in `ai_chat_service.dart` updated to use `await _resolveCategory()`:
- JSON `ACTION` block (structured AI responses)
- Fallback `"Logged: X ₱Y"` regex parser (unstructured responses)

**For manuscript:** This is a form of user preference learning — the app builds a per-item category profile from historical data and uses it to correct AI drift. Aligns with YNAB's June 2026 "auto-categorization evidence threshold" update (2-of-3 most recent entries must agree before changing a payee category). Our implementation requires ≥3 entries with 60%+ agreement.

### 4e. Income Prediction / Payday Countdown Card

**Where:** `lib/screens/home_screen.dart`, `_buildPaydayCountdownCard()`

**What it does:** A new card on the Home screen predicts when the user's next income or allowance will arrive, based on the average interval between their last 3–4 income entries.

**Computation:**
```
sorted = last 4 income entries by date (descending)
intervals = differences in days between consecutive entries
avgInterval = round(sum(intervals) / count(intervals))
avgAmount = sum(last 3 entry amounts) / 3
nextExpected = mostRecentEntry.date + avgInterval days
daysUntil = nextExpected - today
```

**Visibility logic:**
- Only shown when `incomeWalletMode == true` AND `show_payday_countdown` setting is not `'false'`
- Hidden if `_nextExpectedIncome == null` (fewer than 2 income entries with valid dates)
- Hidden if `daysUntil < -(avgInterval × 2)` (data is stale) or `daysUntil > avgInterval × 2`

**Color coding:**
- 🟢 Green — expected today (`daysUntil == 0`)
- 🔵 Blue — coming soon (`daysUntil 1–3`)
- 🟠 Orange — overdue (`daysUntil < 0`)
- Primary color — further away

**For manuscript:** Student accounts in the Philippines typically receive allowances on irregular schedules (weekly from parents, biweekly for boarders, etc.). This feature acknowledges that irregularity and gives students forward visibility into their cash flow without requiring a fixed payday date. Differentiates SmartSpend from apps that assume a monthly salary cycle.

---

## 5. Settings Refinement (v2.9.53)

### 5a. 3 New Home Screen Toggles

Three cards that were previously always-visible are now individually toggleable in **App Settings → Home Screen — Show/Hide Sections**:

| New toggle label | Setting key | What it hides |
|-----------------|-------------|--------------|
| Payday / income countdown | `show_payday_countdown` | `_buildPaydayCountdownCard()` |
| Monthly recap alert | `show_monthly_recap` | "What Changed?" alert in StartupAlertsService |
| Daily & weekly challenges | `show_challenges` | `_DailyChallengesWidget` + `_WeeklyChallengeWidget` |

### 5b. Lite Mode Expanded to 13 Sections

**Before v2.9.53:** Lite Mode covered 10 optional sections.
**After v2.9.53:** Lite Mode covers **13 optional sections**.

The 3 new toggles above are included in `_applyLiteMode()` and the `liteMode` computed getter.

**Complete Lite Mode coverage (13 sections):**

Home screen (9):
1. Subscription summary (`show_subscriptions`)
2. Quick-log chips (`show_quick_log`)
3. Achievement badges row (`show_badges`)
4. Mood check-in (`show_mood_home`)
5. Cash flow forecast (`show_forecast`)
6. Behavioral prediction card (`show_prediction`)
7. Payday / income countdown (`show_payday_countdown`) ← new
8. Monthly recap alert (`show_monthly_recap`) ← new
9. Daily & weekly challenges (`show_challenges`) ← new

Analytics (4):
10. Debt-to-Income ratio (`show_dti`)
11. Emergency fund calculator (`show_emergency_fund`)
12. Financial milestones (`show_milestones`)
13. Market insights / exchange rates (`show_market_insights`)

**Always-on core cards (NOT toggleable by design):**
- Spending summary card (main balance/month card)
- FHS score card
- Wallet balances card (when income mode on)
- Budgets warning banners (data-driven)
- Overdue recurring/debt banners (data-driven)
- Recent expenses list
- Done Spending Today toggle
- AI Insights card

---

## 6. Things NOW Implemented — Move from Future Work to Implemented

The previous handoff (v2) listed these as "Not Implemented." They are now done:

| Feature | Implemented in | Where in app |
|---------|---------------|-------------|
| Auto-categorization evidence threshold | v2.9.52 | ai_chat_service.dart `_resolveCategory()` + db_service.dart `getMostFrequentCategoryForItem()` |
| Income prediction / Payday countdown card | v2.9.52 | Home screen → `_buildPaydayCountdownCard()` |
| AI chat history export | v2.9.52 | AI screen → ⋮ menu → "Export Chat History" |
| "What Changed?" monthly recap alert | v2.9.52 | StartupAlertsService → `checkAlerts()` |
| Semester interval recurring detection | v2.9.52 | db_service.dart recurring detector + recurring_helper.dart |
| Nav bar overlap fix (all 8 screens) | v2.9.50 | home, ai, login, register, setup, onboarding, batch_entry, whats_new |
| Auto AI model mode | v2.9.50 | app_config.dart → `_autoActualModel()` |
| AI failover resilience (delay + error messages) | v2.9.50 | ai_chat_service.dart |
| AI fallback chain bug fix | v2.9.51 | ai_chat_service.dart `isFallbackRetry` flag |
| 3 new settings toggles (payday, recap, challenges) | v2.9.53 | settings_screen.dart + home_screen.dart |

---

## 7. Things Still NOT Implemented — Accurate Future Work List

| Feature | Priority | Notes |
|---------|----------|-------|
| **Safe-to-Spend number** | 🔥 High | BudgetPH differentiator — wallet balance minus upcoming bills/goals/debts = spendable until next payday. Not yet built. |
| **Proactive AI nudge notifications** | 🟡 Medium | Push notification when AI spots actionable situation (subscription due, pace too high, goal milestone close). Not yet built. |
| **Expense Correction Suggestions** | 🟡 Medium | Background scan for data quality issues; Hub badge. Not yet built. |
| 15th/30th payday envelope budget reset | 🟡 Low | Deferred — Safe-to-Spend covers same UX |
| Notification Listener for GCash | 🟡 Medium | Android Accessibility permission; Play Store compliant replacement for READ_SMS |
| Monthly GitHub-style heatmap (full grid) | 🟢 Post-capstone | 28–31 cell per-date coloring |
| Receipt photo gallery | 🟢 Post-capstone | Hub → Receipts GridView |
| True net worth historical chart | 🟢 Post-capstone | Snapshot-based timeline |
| Price Intelligence / Price Pulse | 🟢 Post-capstone | PSA API + personal price history charts |
| SQLite encryption | 🟢 Post-capstone | sqlcipher |
| Backend API proxy | 🟡 Pre-Play Store | Cloud Functions |
| iOS / web version | 🟢 Post-capstone | |
| Investment portfolio tracker (PSE/MP2/UITFs) | 🟢 Post-capstone | |

---

## 8. Manuscript Numbers to Update

Apply these on top of the v2.9.47 corrections from the previous handoff. Use in ALL chapters:

| Find (stale) | Replace with (correct) |
|---|---|
| Any version ≤ 2.9.47 | **2.9.53** |
| `2.9.47+47` (build code) | **2.9.53+53** |
| "Primary model: Gemini 3.5 Flash-Lite (fixed)" | **"Auto mode — dynamically routes to Flash-Lite (fast tasks) or Flash (financial advice)"** |
| "6 optional home screen toggles" | **"9 optional home screen toggles"** |
| "Lite Mode hides 10 sections" | **"Lite Mode hides 13 sections"** |
| "AI fallback chain" described without issue | Add note: **"A critical bug in v2.9.51 was patched where recursive fallback calls double-counted the daily message limit, preventing provider switching. The 8-provider chain now operates as designed."** |
| Auto-categorization: not mentioned or "future work" | Move to **Implemented** — per-item category frequency tracking with 60% majority threshold |
| Income prediction: not mentioned or "future work" | Move to **Implemented** — avg interval of last 3 income entries; shown as Home card |
| Chat export: not mentioned or "future work" | Move to **Implemented** — ⋮ menu in AI screen |
| Monthly recap alert: not mentioned or "future work" | Move to **Implemented** — day 1–3 startup alert |
| Semester recurring detection: not mentioned or "future work" | Move to **Implemented** — 120–135 day interval |
| Nav bar overlap: not mentioned | Can add as **"Accessibility fix — all screens now properly clear the system navigation bar inset on 3-button navigation phones"** |

---

## 9. Specific Manuscript Section Guidance

### Chapter 2 — System Design / Features

**AI Model Routing subsection** — update to describe Auto mode:
> SmartSpend uses a dynamic AI model routing system. In Auto mode (the default), the app selects the most appropriate model per task: Gemini 3.5 Flash-Lite for fast expense logging, Gemini 3.5 Flash for complex financial advice, with an 8-provider fallback chain if the primary model is unavailable. Users can also manually select any of the 8 available models in App Settings.

**Recurring Expense Detector subsection** — add semester interval:
> The detector identifies six frequency patterns: weekly (6–8 day avg), biweekly (13–16 days), monthly (25–35 days), semester (120–135 days — relevant for school tuition and trimestral billing), semi-annual (175–195 days), and yearly (350–380 days).

**Financial Health Score subsection** — no changes needed from this batch.

**Settings / User Control subsection** — update section counts:
> App Settings provides 13 individually toggleable optional sections (9 on the Home screen, 4 in Analytics), plus a one-tap "Lite Mode" that hides all 13 simultaneously for a clean, minimal view.

### Chapter 3 — Implementation / Methodology

**Data Quality / AI Accuracy subsection** — add auto-categorization evidence:
> To prevent AI categorization drift, SmartSpend implements an evidence-based category override: when an item has been logged 3 or more times with the same category in ≥60% of entries, that historical majority category overrides the AI's suggestion. This ensures user-established patterns are preserved even when the AI produces a different classification. The approach is analogous to YNAB's June 2026 auto-categorization update which requires 2-of-3 recent entries to agree before changing a payee category.

**User Engagement / Notifications subsection** — add monthly recap:
> A monthly recap alert fires on the first three days of each month, comparing total spending from the previous month against the month before. The alert requires no AI call — it is computed entirely from local expense data — and only fires when both months have sufficient data (≥3 expenses). This feature mirrors the "Monthly Recap" notifications in established apps like Mint and YNAB.

### Chapter 4 — Results / Discussion

**Competitive Analysis** — update the SmartSpend advantages column:
> New advantages to add: (1) Auto AI model routing — only Filipino finance app with per-task model selection; (2) Payday countdown for irregular income — addresses student/informal worker use case unserved by salary-cycle-based competitors; (3) 13 toggleable optional sections with one-tap Lite Mode for new-user friendliness.

---

## 10. Updated GitHub Releases (for reference)

All releases at: `https://github.com/Zushikina-kun/smartspend-app/releases`

| Tag | Title | arm64 APK size |
|-----|-------|---------------|
| v2.9.49 | (previous stable baseline) | ~45.1 MB |
| v2.9.50 | Nav bar overlap + Auto AI + smarter failover | 46.6 MB |
| v2.9.51 | Critical: AI fallback chain fix | 46.6 MB |
| v2.9.52 | Tier 1: 5 new features | 46.7 MB |
| v2.9.53 | Settings: 3 new toggles + Lite Mode 13 | 46.7 MB |

---

## 11. Non-Code Tasks Still Pending (Carry-Forward from Previous Handoffs)

These have NOT been done by the team yet and should still be addressed:

| # | Task | Owner | Notes |
|---|------|-------|-------|
| D1 | Install **v2.9.53** on demo phone | Brix | Download arm64 APK from GitHub |
| D2 | Verify About screen shows "Version 2.9.53" | Brix | kAppVersion auto-syncs |
| D3 | Reset AI daily limit before demo | Brix | AI screen → ⋮ → Reset Daily Limit |
| D4 | Update manuscript FHS equations (v2.9.42 changes) | Cyrille | Overspend nuance + Category Balance exemptions + Decay discretionary-only |
| D5 | Update manuscript color theme count → 10 | Cyrille | 5 new themes added v2.9.45 |
| D6 | Update manuscript hub tile count → 26 | Cyrille | Expanded v2.9.44 |
| D7 | Update manuscript model list (remove LLaMA, add Auto mode + GPT-OSS/Qwen) | Cyrille | See §3a above for correct chain |
| D8 | Update manuscript agentic action count → 34 | Cyrille | Was 31 in some sections |
| D9 | Update manuscript badge count → 25 | Cyrille | Was 23 in some sections |
| D10 | Update manuscript daily AI limit → 150 | Cyrille | Was 60 in some sections |
| D11 | Add v2.9.50–53 features to manuscript Implemented list | Cyrille | See §6 above for the complete list |
| D12 | Update manuscript settings toggles count (9 home, 4 analytics, 13 Lite Mode) | Cyrille | See §5 above |
| D13 | Add PISO, BunnyWise, MayBudget, Agila to competitor table | Cyrille | In FEATURE_BACKLOG.md Part 10 |
| D14 | BSP citation update Ch.1 (2021 → CFIS 2025) | Cyrille | |
| D15 | Create Figure 1.1 — PH financial literacy bar chart | Cyrille | BSP CFIS 2025: 50% adults formal accounts, 74% literacy rate |
| D16 | Create Figure 1.2 — IPO conceptual framework | Cyrille | Input→Process→Output |
| D17 | Create Figure 2.1 — SUS score interpretation chart | Cyrille | Bangor et al. 2009 adjective scale; target ≥80 = Good |
| D18 | Create Figure 2.2 — Kanban board diagram | Cyrille | Backlog → In Progress → Done |
| D19 | Fill Compliance Matrix | All | SmartSpend_Master_Bug_Tracker.docx |
| D20 | SUS survey — 30 respondents | Djaunathan | Post-defense |
| D21 | Validator signatures — Appendix A | Brix | |

---

## 12. What Claude Should NOT Change

These parts of the manuscript are correct as-is and should NOT be updated based on this handoff:

- The overall app architecture description (Flutter/Dart + Firebase + SQLite) — unchanged
- The FHS formula and component breakdown — unchanged since v2.9.42
- The 34 agentic actions list — unchanged
- The 25 achievement badges list — unchanged
- The 7 input modalities list — unchanged
- The 20-table SQLite schema — unchanged
- The Paluwagan feature description — already moved to Implemented in previous handoff
- Any data from the SUS survey or user testing — not yet conducted

---

## 13. Instructions for Claude

When updating the manuscript, follow these priorities:

1. **First**: Update all version numbers (any ≤2.9.47 → 2.9.53) and the authoritative numbers table (§1 above)
2. **Second**: Move the 10 features in §6 from "Future Work / Not Implemented" to "Implemented Features" in relevant chapters
3. **Third**: Apply the manuscript number corrections in §8
4. **Fourth**: Add the new paragraph content from §9 to the appropriate chapters
5. **Fifth**: Update the Lite Mode and toggle counts in §5

Do NOT change the FHS formula, action counts, badge lists, or survey data — those are stable.

When uncertain whether something has changed, **default to keeping the existing manuscript text** and flag it with a comment for Cyrille to verify. Better to flag than to introduce incorrect data.

---

*Compiled by Kiro (Kiro IDE) — September 26, 2026*
*Covers v2.9.50 through v2.9.53.*
*Read in conjunction with previous handoffs (v1: v2.9.38–v2.9.42, v2: v2.9.43–v2.9.47).*
*Treat all information here as ground truth for the current app state as of September 26, 2026.*
