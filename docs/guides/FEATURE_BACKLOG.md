# SmartSpend — Master Feature Backlog & Planning
**Version:** 2.9.59 | **Updated:** September 2026 — Codex code-audit pass
**Group:** Lucid Frame | **Academic Year:** 2026–2027, 1st Semester

> **Single consolidated planning document.** Fuses inputs from:
> `PROJECT_STATUS.md`, `FEATURE_DOCS.md`, `BENCHMARK.md`, `CAPSTONE_REFERENCE.md`,
> `DEFENSE_GUIDE.md`, `SYSTEM_OVERVIEW.md`, `SmartSpend_Ideas_Reference.pdf`,
> the 15-item recommendation list, live online research (September 2026),
> and `LLM_Engineering_Cheatsheet_v6.md` (free API directory, new models).
>
> **Status note:** Older sections below may still include historical ❌ or 🔧 markers from earlier planning passes. Treat Part 0 and Part 0A as the current authority, then use the detailed sections for design notes.
>
> *Sources consulted: PSA OpenSTAT, BSP Monetary Policy Reports, World Bank Commodity Markets,
> PCMag 2026, Rocket Money Rowan press release, BudgetPH, PISO Budget Tracker, BunnyWise,
> Google Play SMS policy docs, OpenAI ChatGPT Finance announcement,
> Moonshot AI Kimi K3 release (July 2026), Qwen3.8 release (August 2026),
> OpenRouter free model directory (September 2026), Cisco NetAcad AI literacy curriculum.*
> *Content from external sources paraphrased for compliance with licensing restrictions.*

---

## Part 0 — Authoritative Build Numbers (v2.9.53)

Use these everywhere. Many docs are stale.

| Metric | v2.9.53 value |
|--------|--------------|
| Version string | **2.9.53** |
| Platform | Android (Flutter/Dart) |
| Min SDK | Android 5.0 (API 21) |
| Target SDK | Android 16 (API 36) |
| Build size | ~46.7 MB arm64-v8a, split, obfuscated |
| SQLite schema | v11, 20 tables |
| AI providers in fallback chain | **8** (not 5 or 6) |
| Primary AI model | **Auto (Gemini 3.5 Flash-Lite default)** — Auto mode added v2.9.50 |
| Agentic actions | **34** (not 31) |
| Input modalities | 7 |
| Screens | 41 Dart files |
| Services | 29 Dart files |
| Achievement badges | **25** (23 + No-Spend Day + No-Spend Streak) |
| Daily quests pool | 10 |
| Batch screenshot platforms | 40+ |
| Filipino item catalog | 150+ items |
| Log choice sheet options | 7 |
| Currencies | 57 |
| Hub tiles | **26** |
| PH banks in DB | 20 banks + 5 e-wallets |
| Daily AI message limit | **150** (raised from 60) |
| Color themes | **10** (5 new added v2.9.45) |
| Optional home toggles | **9** |
| Optional analytics toggles | **4** |
| Lite Mode coverage | **13 sections** |
| Paluwagan | ✅ **Implemented** v2.9.35 (update manuscript) |

### Recent releases
| Version | Key changes |
|---------|------------|
| v2.9.53 | Settings refinement: 3 new home toggles (payday countdown, monthly recap, challenges); Lite Mode expanded to 13 sections. |
| v2.9.52 | Tier 1 features: payday countdown, monthly recap alert, AI chat export, auto-categorization evidence threshold, semester recurring interval. |
| v2.9.51 | **Critical fix:** AI fallback chain was silently failing — recursive `sendMessage()` re-ran daily limit check on each retry, blocking every provider switch. Added `isFallbackRetry` flag. |
| v2.9.50 | Nav bar overlap fixed on all 8 screens (viewPadding.bottom); Auto model mode with task-based routing; 500ms grace delay on auth failures; distinct error messages |
| v2.9.49 | (previous baseline) |

---

## Part 0A — Codex Code-Audit Findings (v2.9.53)

This section records issues found by direct code inspection after the v2.9.53 Kiro handoff. Use this as the current fix/refine queue before adding more features.

### Fixed in this audit pass

| Finding | Evidence | Action |
|---------|----------|--------|
| App-facing version drift: `pubspec.yaml` and What's New say 2.9.53, but debug/About/backup exports used `kAppVersion = '2.9.49'`. | `pubspec.yaml`; `lib/services/debug_service.dart`; `lib/screens/whats_new_screen.dart` | Updated `kAppVersion` to `2.9.53`. |

### High-priority cleanup / refinement queue

| Priority | Item | Why it matters | Suggested files |
|----------|------|----------------|-----------------|
| 🔴 P0 | Run and clear `flutter analyze --no-pub` errors before release builds. | Large screens/services make regressions easy; analyzer is the cheapest guardrail. | Whole repo |
| 🔴 P0 | Reconcile docs that still say v2.9.40/2.9.41/2.9.49/2.9.51. | Defense/manuscript references are inconsistent with the current build. | `README.md`, `HOWTORUN.md`, `docs/reference/*`, `docs/status/PROJECT_STATUS.md` |
| 🔴 P0 | Keep the FHS formula documented from code, not from stale briefings. | `score_service.dart` currently uses four 25-point components; some docs mention other weights. This can confuse panel/manuscript claims. | `docs/reference/*`, manuscript drafts |
| 🟠 P1 | Implement action allowlist + source restrictions before expanding AI imports. | `AIChatService` validates fields, but an explicit allowlist/source policy would reduce prompt-injection and malformed OCR risk. | `ai_chat_service.dart`, `ai_screen.dart`, import flows |
| 🟠 P1 | Add first-time AI financial advice disclaimer. | About screen disclaimer is easy to miss; one-time advice-tier dialog helps RA 11765/responsible-AI positioning. | `ai_screen.dart`, `ai_chat_service.dart`, `DBService` setting |
| 🟠 P1 | Add low-confidence AI explanation/review prompt. | `confidence_score` exists, but users need clearer guidance when AI is uncertain. | `expense_tile.dart`, `edit_expense_screen.dart`, `ai_screen.dart` |
| 🟠 P1 | Build Safe-to-Spend card. | This remains the strongest BudgetPH/payday-cycle gap; payday countdown alone does not reserve bills/goals/debts. | `home_screen.dart`, `db_service.dart` |
| 🟡 P2 | Clarify Android share-intent status. | Code inspection found clipboard parsing, but no `ACTION_SEND` receiver or `receive_sharing_intent` package. Do not describe share intent as implemented until wired. | `android/app/src/main/AndroidManifest.xml`, `MainActivity.kt`, `ai_screen.dart` or `bank_import_screen.dart` |
| 🟡 P2 | Extract or test high-risk monoliths gradually. | `home_screen.dart`, `analytics_screen.dart`, `ai_screen.dart`, `db_service.dart`, and `ai_chat_service.dart` are very large; future changes need smaller helper methods and focused tests. | Same files, `test/` |
| 🟡 P2 | Replace placeholder tests with focused service tests. | Current widget test only checks `1 + 1`; no guard around FHS, recurring date advancement, category evidence, or backup schema. | `test/` |

---

## Part 1 — The 15 Recommended Features: Updated Status

### ✅ Already Fully Built

| # | Feature | Where |
|---|---------|-------|
| 5 | Budget rollover | Budget screen ↪ toggle; auto-applied monthly |
| 6 | Tags analytics "By Tag" | Analytics; tag filter in Transactions; in CSV export |
| 7 | "Afford This?" calculator | Home → Log Expense sheet |
| 8 | Offline AI insight cache | Home AI Insights (shows cached with date on quota error) |
| 8B | Analytics AI cache fallback | Analytics AI Advice + Monthly Summary cache fallback |
| 9 | Net Worth tracker | Profile screen; wallet-based; FHS sparkline |
| 12 | Filtered export | Transactions → ⬇ exports current filtered list |
| 13 | Income prediction / Payday countdown card | Home → `_buildPaydayCountdownCard()` (v2.9.52) |
| 14 | AI chat history export | AI screen → ⋮ → Export Chat History (v2.9.52) |

---

### 🔧 Partially Built — Needs Completion

| # | Feature | What exists | What's still missing | Priority |
|---|---------|-------------|---------------------|----------|
| 1 | Smart Recurring Detector | Quarterly/yearly/semi-annual/semester detection (400-day lookback); insurance keyword → Bills | "Add to Insurance Tracker?" UI prompt on insurance-keyword detection | 🟡 |
| 3 | Spending heatmap | Day-of-week 7-column heatmap + 5-week calendar in Analytics | Full monthly GitHub-style per-date grid (28–31 cells, date-specific coloring) | 🟡 |
| 4 | SMS/notification listener | Clipboard paste-to-parse; clipboard nudge banner | **⚠️ READ_SMS is blocked by Google Play policy** — apps must be the default SMS handler. Android share intent and Notification Listener are separate pending features. | 🔴 Policy issue — redesign needed |
| 9 | Net Worth trend chart | FHS sparkline as proxy | True net-worth-over-time chart using periodic snapshots (not FHS score proxy) | 🟡 |
| 15 | Expense photo gallery | photo_path field; inline thumbnail on tiles | Dedicated gallery GridView in Hub → "Receipts" | 🟢 |

**⚠️ READ_SMS redesign note:** Google Play requires apps to be the *default SMS handler* before accessing READ_SMS — a policy in place since 2019 and tightened further in 2026. A personal finance tracker will never qualify. The correct alternative is `NotificationListenerService` (requires user grant in Accessibility settings) which can read notification text without being the SMS handler. This is the approach used by apps like Walnut (India) and similar trackers. It still requires user opt-in but is Play Store compliant.

---

### ✅ Recently Completed From Original 15-Item List

| # | Feature | Priority | Est. effort |
|---|---------|----------|-------------|
| 2 | "Day in Review" end-of-day card | ✅ **Implemented v2.9.36, verified v2.9.45** | — |
| 10 | Savings rate trend chart (6-month line) | ✅ **Implemented v2.9.45** | — |
| 11 | Quick budget slider (long-press) | ✅ **Implemented v2.9.45** | — |
| 13 | Income prediction / Payday countdown card | ✅ **Implemented v2.9.52** | — |
| 14 | AI chat history export | ✅ **Implemented v2.9.52** | — |

---

## Part 2 — Features from Internal Docs Not in the 15-item List

### ✅ Already Built (confirmed from docs + code audit)

| Feature | Version | Where |
|---------|---------|-------|
| Paluwagan tracker | v2.9.35 | Hub → Paluwagan Tracker |
| Log Due Bills checklist | v2.9.35 | Hub → Log Due Bills |
| Merchant normalization + Merge tool | v2.9.34 | Hub → Merchant Cleanup |
| Budget envelope analytics | v2.9.35–36 | Analytics |
| Price trend chart per item | v2.9.35 | Edit Expense screen |
| Split Bill with auto-debt | v2.9.35 | Log choice sheet |
| Day-in-Review card (after 6pm) | v2.9.36 | Home screen |
| 5-week spending heatmap | v2.9.36 | Analytics |
| Budget rollover | v2.9.36 | Budget screen |
| Tags analytics | v2.9.36 | Analytics |
| Offline AI insight cache | v2.9.36 | Home |
| Clipboard SMS/bank nudge | v2.9.37 | AI screen |
| Manual Entry overhaul + autocomplete | v2.9.32–33 | Add Expense screen |
| Filipino item catalog (150+) | v2.9.33 | Add Expense → browse icon |
| Graceful AI failure UX | v2.9.20 | AI chat |
| FMS (Financial Management Score) | v2.9.5 | Profile screen |
| Weekly Category Card (High/Normal/Low) | v2.9.5 | Home + Analytics |
| Financial Health Certificate | Current | Hub → shareable FHS card |
| Impulse Pause mechanic | Current | Add Expense |
| Insurance & Contributions Tracker | Current | Hub → Insurance |
| PCA / investment calculator | Current | Analytics |
| Mood-spending correlation | Current | Analytics |
| Long-range forecast (3/6/12 months) | Current | Analytics |
| Period comparison tool | Current | Analytics |
| Spending personality profile | Current | Home |
| Logging Gap Detection | Current | Startup |
| Payday Cycle filter | Current | Analytics |
| Round-trip fare logger | Current | Log choice sheet |
| Multi-period spending limits | Current | Profile → Spending Limits |
| Auto-categorization evidence threshold | v2.9.52 | `DBService.getMostFrequentCategoryForItem()` + `AIChatService._resolveCategory()` |
| Monthly recap alert | v2.9.52 | `StartupAlertsService.checkAlerts()` |
| Semester recurring interval | v2.9.52 | `DBService.detectRecurringCandidates()` + `RecurringHelper._advanceDate()` |

---

### 🔧 Partially Built (from docs + research)

| Feature | What exists | What's missing | Priority |
|---------|-------------|----------------|----------|
| **15th/30th payday cycle budget** | `payday_date` in settings; Payday Cycle filter in Analytics | **"Safe-to-spend" number** — subtract all upcoming bills, goals, debt payments from wallet balance for the current pay period; show "You have ₱X safe to spend until [payday]". This is BudgetPH's core differentiator. | 🔥 High |
| Profile photo cross-device sync | Stored as local file path only | Firebase Storage upload (requires Blaze plan) | 🟢 Low |
| SQLite encryption | Plain SQLite | sqlcipher integration | 🟢 Post-capstone |
| Backend API proxy | Key in APK (mitigated by rate limit) | Cloud Functions proxy | 🟡 Pre–Play Store |
| App Check enforcement | Monitoring mode | Enforcement mode (before Play Store) | 🟡 Pre–Play Store |
| Notification Listener (replaces READ_SMS) | Clipboard paste; no Android share-intent receiver yet | `NotificationListenerService` — reads GCash/bank notification text non-destructively; user grants access in Android Accessibility settings; Play Store compliant | 🟡 Medium |

---

### ❌ Not Built At All (from docs + research)

| Feature | Priority | Est. effort | Notes |
|---------|----------|-------------|-------|
| **Safe-to-Spend number** | 🔥 High | ~1 day | BudgetPH core concept: bills + goals + debt payments reserved first; remaining = safe-to-spend. Displayed prominently on Home. Strongest competitive gap to close. |
| **Proactive AI nudge notifications** | 🟡 Medium | ~2 days | Inspired by Rocket Money's "Rowan" (July 2026): AI sends push notification when it spots something actionable — "You have a ₱299 Netflix charge coming. Want to review your subscriptions?" — user taps to open AI chat. No SMS required. Uses existing flutter_local_notifications. |
| ScanReviewScreen rename refactor | 🟢 Low | 30 min | Rename to BatchScanReviewScreen vs SingleScanReviewScreen for code clarity |
| Mascot / personality layer | 🟢 Low | ~2 days | vs Sentimo's "KBoy" carabao; fun UX differentiator |
| Couple/family shared finances | 🟢 Post-capstone | ~2 weeks | Multi-account architecture; Monarch and Honeydue do this |
| iOS / web version | 🟢 Post-capstone | ~2 months | Flutter Web is feasible but out of capstone scope |
| Business mode AI actions | 🟢 Post-capstone | ~1 week | Invoice tracking, employee expense split |
| Investment portfolio tracker (PSE/MP2/UITFs/crypto) | 🟢 Post-capstone | ~2 weeks | BunnyWise (launching 2026) will target this exact gap; PCA calculator exists but not full tracking |

---

## Part 3 — Competitor Landscape Update (September 2026)

### New Competitors Found in Research (not in previous docs)

| App | Platform | Key differentiator | Threat level |
|-----|----------|-------------------|--------------|
| **PISO Budget Tracker** | Android | 100% offline, no ads, no subscription, Filipino-made, payday cycle | 🟡 Medium — positions as the "no-frills offline" alternative |
| **BunnyWise** (launching) | Android (offline-first) | PSE stocks + US stocks + UITFs + MP2 + gold + crypto tracking in one Filipino dashboard | 🟠 High post-launch — fills the investment gap SmartSpend doesn't touch |
| **MayBudget** | Android | Payday-cycle-focused budget tracker; "active cycle" view | 🟢 Low — basic tracker, no AI |
| **Rocket Money + Rowan** | iOS/Android | Agentic AI via SMS: proactively texts you about savings, cancels subscriptions, negotiates bills | 🟡 US market only but conceptually validates and raises the bar for what "agentic" means |
| **ChatGPT Finance** | iOS/Web (US only) | Links bank via Plaid; natural language Q&A grounded in real data | 🟢 US/Plaid only, no Philippines support — not a direct threat |

### Updated Competitive Position

**Where SmartSpend still leads:**
- Only free Filipino-English AI on Android with 34 agentic actions
- Only app with batch screenshot import (40+ platforms)
- Only FHS with dual-mode (Full + Lightweight)
- Only fully offline + cloud sync + free
- Most gamification depth (25 badges + 10 daily quests)
- Paluwagan tracker ✅ (BudgetPH has it; PISO does not)

**Gaps remaining after this research:**
- Safe-to-spend number (BudgetPH core) — highest priority gap
- Investment tracking — BunnyWise launching to fill this
- Proactive AI nudge push notifications (Rowan-style) — feasible now with existing notification system
- Payday envelope reset (15th/30th) — PISO, MayBudget, BudgetPH all have this

---

## Part 4 — Price Intelligence / "Price Pulse" Feature Plan

### Overview
Three views for any item tracked: historical (personal + PSA), present (CPI context), estimated future (trend projection). Not financial advice — labeled as estimates throughout.

### Data Sources

#### Layer 1 — Personal Transaction History (Offline, Always Available)
- Item-level price history: group by `item_name` + month, `AVG(amount)`
- Personal inflation rate per category: `(avg_this_year − avg_last_year) / avg_last_year × 100`
- Works with zero internet, zero API

#### Layer 2 — PSA OpenSTAT (Philippines Official, Free, No Auth)
- URL: `https://openstat.psa.gov.ph` — **still marked "Alpha Version"**
- Relevant datasets: `DB/DB__2M__2018NEW` (retail prices), `DB/DB__2M__PI` (CPI by category)
- Updated monthly; 3–4 week lag
- **Coverage:** ~33 agricultural staples only (rice, pork, chicken, eggs, cooking oil, sugar, vegetables, gasoline, diesel)
- **Confirmed commodity prices for July 2026:** Rice well-milled ~₱50/kg ([PSA Price Situationer](https://psa.gov.ph))
- **Confirmed CPI Jan–Jul 2026:** Headline avg 5.0%; peaks at 7.2% in April 2026
- **Fallback:** If API unavailable → Layer 1 only, no crash, no error shown to user

#### Layer 3 — World Bank Pink Sheet (Global Context, Free)
- URL: `https://thedocs.worldbank.org` → commodity price data
- Global wholesale USD prices; use only for "why prices are moving" explanation
- Convert via existing exchange rate cache (already daily-updated in app)
- **2026 context:** Energy prices rose 8.8% in August 2026; food prices +1.4%; global commodities projected +16% for full year 2026

### PSA Commodity Mapping

| SmartSpend item keyword | PSA commodity | Unit |
|------------------------|---------------|------|
| rice / bigas | RICE, WELL-MILLED | ₱/kg |
| pork / baboy / kasim | PORK, KASIM | ₱/kg |
| chicken / manok | CHICKEN, WHOLE | ₱/kg |
| egg / itlog | EGGS, MEDIUM | ₱/pc |
| cooking oil / mantika | COOKING OIL, REFINED | ₱/L |
| sugar / asukal | SUGAR, REFINED | ₱/kg |
| gasoline / gasolina | GASOLINE, UNLEADED | ₱/L |
| diesel | DIESEL | ₱/L |
| tomato / kamatis | TOMATOES | ₱/kg |
| onion / sibuyas | ONION, RED | ₱/kg |
| garlic / bawang | GARLIC, IMPORTED | ₱/kg |

### CPI Sub-Index → SmartSpend Category

| PSA CPI component | SmartSpend category |
|-------------------|---------------------|
| Food and Non-Alcoholic Beverages | Food |
| Transport | Transportation |
| Housing, Water, Electricity, Gas | Bills |
| Education | Education |
| Health | Health |
| All Items (Headline) | Overall / context |

### Sub-Features

#### 4A — Personal Price History Chart
- **Where:** Analytics → "Price Pulse" card
- **Trigger:** Auto-shows for items logged 3+ times
- **Shows:** Line chart (X=months, Y=avg price paid); lowest/highest/current labels; personal inflation rate label
- **Data:** Local only — `GROUP BY item_name, strftime('%Y-%m', date); AVG(amount)`
- **Effort:** Low — fl_chart already used; pure SQLite query

#### 4B — National CPI Context
- **Where:** Inside Price Pulse card
- **Shows:** "Food CPI this month: +4.8% YoY | Your food: +6.2% — outpacing inflation by 1.4pts" or "underperforming — well done"
- **Data:** PSA API → cached as `psa_cpi_food_YYYY-MM` in settings (same pattern as exchange rates)
- **Effort:** Medium — new HTTP service + caching

#### 4C — Item-Level Benchmark
- **Where:** Expense detail screen → "Price Benchmark" tile
- **Shows:** "PSA national avg: ₱52/kg | You paid: ₱55/kg (+₱3) | Data: July 2026"
- **Fallback:** "No national benchmark available — showing personal history only"
- **Effort:** Medium — keyword matching + PSA retail price dataset

#### 4D — Future Price Estimate (Collapsible)
- **Where:** Price Pulse card, collapsed by default
- **Formula:** `estimated = current_avg × (1 + avg_monthly_cpi_change_last_3_months)`
- **Label:** "Estimate only — based on PSA trend data. Actual prices may vary."
- **Effort:** Low (depends on 4B)

#### 4E — Personal Inflation Rate Summary
- **Where:** Analytics → standalone card OR Profile → below FHS
- **Shows:** "Your personal inflation rate this year: +7.2% vs national +5.0% — you're outpacing by 2.2 pts" + category breakdown
- **Why valuable:** Students/low-income users spend more on food/transport, which inflated faster than headline in 2026 (food CPI peaked at 7.2% in April)
- **Effort:** Low — entirely local computation + 1 API call for headline CPI

### New DB Table: `price_cache`

```sql
CREATE TABLE price_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  source TEXT NOT NULL,       -- 'psa_cpi', 'psa_retail', 'worldbank'
  commodity TEXT NOT NULL,    -- 'food', 'transport', 'rice_wellmilled'
  period TEXT NOT NULL,       -- 'YYYY-MM'
  value REAL NOT NULL,        -- index value or PHP price
  unit TEXT,                  -- 'index_2018=100', 'php_per_kg', 'pct_change'
  fetched_at TEXT NOT NULL,
  UNIQUE(source, commodity, period)
);
```

### New Settings Keys
- `psa_last_fetch` — ISO date of last PSA fetch (refresh once/month max)
- `price_intelligence_enabled` — user toggle (default: true)

### Caveats to Display in UI
1. PSA covers commodity staples only — branded goods (Sting, Lucky Me, Jollibee) use personal history only
2. PSA data is 3–4 weeks behind; labeled with data-as-of date
3. World Bank data is in USD converted via exchange rate cache
4. Personal inflation rate needs ≥13 months for year-over-year; <13 months shows month-over-month only
5. All projections labeled "Estimate — not financial advice"
6. If PSA API unavailable → degrade silently to personal history only

---

## Part 5 — New Feature Ideas from 2026 Research

These are new ideas surfaced from researching the competitive landscape this month. None existed in previous planning docs.

### 5A — Safe-to-Spend Number (Priority: 🔥 HIGH)
**Inspired by:** BudgetPH's core concept ("reserves every bill and goal first, then tells you the one number that matters")

**What it is:** A prominently displayed number on the Home screen showing how much money the user can safely spend before their next payday, after all known obligations are reserved.

**Formula:**
```
safe_to_spend = total_wallet_balance
  − upcoming_bills_before_payday        (recurring transactions)
  − upcoming_debt_payments_before_payday
  − monthly_goal_contributions_remaining
  − (income − current_month_spend) if negative (deficit warning)
```

**Where:** Large card on Home screen, below wallet card. Only shown in income/wallet mode.

**Example display:**
```
💚 Safe to Spend: ₱1,240
   Until Sep 30 (payday in 18 days)
   Reserved: Bills ₱907 · Goals ₱200 · Debts ₱0
```

**Conflicts to check:**
- Must read `payday_date` from settings (already stored)
- Must query upcoming recurring bills within the payday window
- Should NOT conflict with existing Cash Flow card (they complement each other — Cash Flow shows income/spent/remaining; Safe-to-Spend shows spendable after reserves)
- For students: use "allowance cycle" (weekly/monthly) instead of payday

**Effort:** ~1 day

---

### 5B — Proactive AI Nudge Notifications (Priority: 🟡 MEDIUM)
**Inspired by:** Rocket Money's "Rowan" agent (July 2026) — proactively watches spending and sends alerts via SMS

**What it is:** The AI periodically (once per day, on app open) checks for actionable situations and sends a local push notification. User taps notification → opens AI chat with a pre-filled message.

**Trigger conditions (run daily, on app open):**
1. A subscription is due in 3 days — "Your Netflix ₱299 is due in 3 days. Review subscriptions?"
2. Spending pace is unusually high — "You've spent ₱1,200 on Food this week — 40% above your usual"
3. A savings goal milestone is close — "You're ₱150 away from your Emergency Fund target!"
4. Income not logged for 30+ days (student users) — "You haven't logged allowance in 30 days. Update your income?"
5. Wallet balance and spending suggest a shortfall before payday — "At this pace you'll run out 4 days before payday"

**Implementation notes:**
- Uses existing `flutter_local_notifications` (already in the app)
- Runs in `StartupAlertsService` or a dedicated `ProactiveNudgeService`
- Deep-links into AI chat with a pre-filled message (e.g. "detect_subscriptions" action)
- NOT an SMS/text feature — pure in-app push notification
- Gated by a user toggle in App Settings
- Respects "last notified" timestamps to avoid repeat nudges

**No conflict:** Startup alerts already fire budget/overdue alerts on app open. Proactive nudges are a separate, scheduled daily check targeting forward-looking situations.

---

### 5C — Auto-Categorization Evidence Threshold (Priority: 🟡 MEDIUM)
**Inspired by:** YNAB's June 2026 update — "auto-categorization now waits for evidence before it changes its mind; your payee keeps its established default until two of the three most recent categorizations agree on something new"

**Problem in SmartSpend:** The AI sometimes recategorizes a known item (e.g. it has logged "Sting" as Food 10 times, then on the 11th time classifies it as Others). The user's auto-categorization rules prevent this for exact keyword matches, but the AI can still override them.

**What to add:**
- Track `(item_name, category)` frequency in a new lightweight table or via existing expense data
- Before saving an AI-logged expense: if the item has ≥3 prior logged instances and >60% of them share the same category, override the AI's category suggestion with the historical majority category
- Show the user: "Category changed to Food (based on your 8 previous Sting entries)"

**No conflict:** Works alongside existing user-defined category rules. User rules take priority, then historical majority, then AI suggestion.

---

### 5D — "What Changed?" Monthly Delta Notification (Priority: 🟢 LOW-MEDIUM)
**What it is:** At the start of each new month, a single push notification summarizing last month vs the month before:
"📊 September recap: You spent ₱1,755 — ₱420 less than August (✅ improving). Food was your biggest category."

This is a stripped-down version of the existing Monthly Summary AI card — the difference is it fires as a notification even if the user doesn't open Analytics.

**Implementation:** Add to StartupAlertsService, fire once at start of new month using rollover detection (`rollover_applied_month` already tracked). No AI call needed — pure DB computation.

---

### 5E — Expense Correction Suggestions (Priority: 🟡 MEDIUM)
**What it is:** A periodic background check (weekly) that scans for data quality issues and surfaces them as a dismissible banner or card:
- Expenses with `time = '00:00'` (imported, no real time)
- Duplicate item names with different capitalizations: "jeepney fare" vs "Jeepney Fare" vs "Jeepney fare"
- Items categorized as "Others" that could map to a built-in category
- Amounts that are unusually round (₱1000, ₱5000) logged as AI — may be wallet balance updates mislogged as expenses

**Where:** Hub → new "Data Quality" badge that shows when issues are found. Tapping opens a list with "Fix All" button that fires AI update_expense actions.

**No conflict with AI:** These corrections use the existing `update_expense` AI action. The suggestions are deterministic (no AI call) — the AI is only invoked when user confirms a fix.

---

### 5F — PSE Stock / UITF / MP2 Investment Tracker (Priority: 🟢 Post-Capstone)
**Research finding:** BunnyWise (launching 2026) is building exactly this for Philippines. SmartSpend already has a PCA/MP2 calculator. Investment tracking is the next logical expansion.

**What it would cover:**
- Track MP2 contributions (manual entry, no API — PAG-IBIG doesn't have a public API)
- Track UITF fund values (manual or via fund house apps' exported data)
- PSE stock portfolio (manual entry; PSE has a market data feed but no public retail API)
- Crypto holdings (manual; or via CoinGecko free API for PHP prices)
- Net worth tracker would auto-include investment values

**Why defer:** BunnyWise is coming; the market will have a dedicated tool. SmartSpend should integrate investment *context* (e.g. "you have ₱5,000 idle in your wallet — you could put it in MP2 at 6–9%/yr") rather than compete on full portfolio tracking.

---

## Part 6 — Corrections to Existing Backlog Items

Based on research and internal audit, these items from the previous backlog need to be updated:

### #4 SMS Listener → Redesign as Notification Listener
**Previous plan:** READ_SMS Android permission + background SMS listener
**Problem:** Google Play policy explicitly states apps must be the *default SMS handler* to access READ_SMS. Finance trackers will never qualify. Confirmed via Google Play policy docs (2026).
**Revised plan:** `NotificationListenerService` (Android Accessibility permission) reads notification text from GCash, BPI, Maya, etc. without being the SMS handler. Play Store compliant. User grants access manually. Same UX result: "GCash notification detected: ₱500 debited. Log it?"
**Status change:** From "🟢 Low (policy risk)" to "🟡 Medium (feasible, needs Accessibility permission UX)"

### #4 PSA OpenSTAT Stability Warning
**Previous plan:** Treat as stable API
**Research finding:** PSA OpenSTAT is explicitly marked "Alpha Version" on their website as of September 2026. The app MUST implement a full degradation path — if the API returns any error, silently fall back to personal history only. Do NOT show an API error to the user.

### #10 Savings Rate Trend Chart — No Contradiction
**Concern checked:** Does this conflict with the existing FHS component breakdown chart or the existing monthly bar chart?
**Conclusion:** No conflict. The existing bar chart shows total monthly spend. The existing FHS chart shows score over time. A savings rate % line chart is a new metric (income − spend / income, monthly) not shown anywhere currently. Safe to add.

### #11 Quick Budget Slider — Needs Constraint Check
**Concern:** Will a slider conflict with the existing percentage-based budget mode?
**Design note:** Budget screen has two modes per category — fixed ₱ amount and % of income. The slider should only apply to the fixed ₱ mode. If a category is in % mode, long-press opens the existing edit dialog (not a slider). Add a small indicator so the user knows which mode is active.

### #13 Income Prediction — Clarify for Student Account Type
**Concern:** Students have irregular/manual allowance, not a fixed salary payday date.
**Design note:** For students: show "Last allowance: N days ago. Based on your last 3 allowances, you typically receive ₱X every Y days. Next expected: around [date]" — averages the income entry dates and amounts. For employed: use `payday_date` setting directly. Account type detection already exists.

---

## Part 7 — Document Maintenance Tasks (Non-Code)

### 🔴 Before Pre-Final Defense

| Task | Owner |
|------|-------|
| Move Paluwagan to "Implemented" in manuscript | Cyrille |
| Update FEATURE_DOCS.md version (2.9.11 → 2.9.41) | Brix |
| Update CAPSTONE_REFERENCE.md (2.9.37 → 2.9.41, model table, daily limit 150) | Brix |
| Update APPLICATION_PIPELINE.md (2.9.11 → 2.9.41, remove retired LLaMA models) | Brix |
| Update DEFENSE_GUIDE.md (version, model names, action count 34 not 31, 25 badges not 23) | Brix |
| Update PROJECT_STATUS.md (version 2.9.37 → 2.9.41) | Brix |
| Update BENCHMARK.md (version, agentic actions 34 not 31, add PISO/BunnyWise/MayBudget) | Brix |
| Add PISO Budget Tracker, BunnyWise, MayBudget to competitor comparison matrix | Brix/Cyrille |
| Create Figure 1.1 — PH financial literacy bar chart | Cyrille |
| Create Figure 1.2 — IPO conceptual framework | Cyrille |
| Create Figure 2.1 — SUS score interpretation chart | Cyrille |
| Create Figure 2.2 — Kanban board diagram | Cyrille |
| Fill Compliance Matrix | All |
| Rehearse demo flow | All |

### 🟡 Post-Defense (before final)

| Task | Owner |
|------|-------|
| SUS survey — 30 respondents | Djaunathan |
| Validator signatures — Appendix A | Brix |
| BSP citation update Ch.1 (2021 → CFIS 2025) | Cyrille |
| Insert survey results into manuscript Ch.3 | Cyrille |
| CV section all three researchers | All |

---

## Part 8 — Complete Priority Queue

### ✅ Done (v2.9.50–2.9.51)

| Feature | Version | Notes |
|---------|---------|-------|
| Nav bar overlap — all 8 screens | v2.9.50 | viewPadding.bottom on all affected screens |
| Auto model mode | v2.9.50 | Dynamic task routing: fast→Flash-Lite, advice→Flash |
| Smarter AI failover (delay + error messages) | v2.9.50 | 500ms grace, distinct slow-connection vs auth errors |
| AI fallback chain critical fix | v2.9.51 | isFallbackRetry flag — chain now actually works |

### 🔥 Do Next — Before Final Defense (high impact, feasible)

| Feature | Effort | Why now |
|---------|--------|---------|
| **Safe-to-Spend number (5A)** | ~1 day | Biggest competitive gap vs BudgetPH; prominent on Home; strong demo talking point |
| **Action allowlist + source restrictions (15B)** | ~3h | Hardens AI actions before adding more OCR/share/import entry points |
| **First-time AI advice disclaimer (15C)** | 30min | Quick compliance/trust win for financial advice responses |
| **AI confidence explainability banner (15H)** | ~1h | Uses existing `confidence_score`; helps users review uncertain logs |
| **Document/version reconciliation** | ~1–2h | README/HOWTORUN/reference docs still disagree with v2.9.53 |

### 🟠 Queue After Above — Also Before Final Defense

| Feature | Effort | Notes |
|---------|--------|-------|
| Proactive AI nudge notifications (5B) | ~2 days | Rocket Money/Rowan comparison; uses existing flutter_local_notifications |
| Expense Correction Suggestions (5E) | ~1 day | Data quality sweep; Hub badge; uses existing update_expense action |
| GCash/Bank share intent receiver (15D) | ~3h | Register Android `ACTION_SEND`, route shared text into existing import/parse flow |
| Chat history token compression (15A) | ~2h | Current summarization exists, but token-window compression before each request still needs verification/refinement |

### ⏸ Defer — Medium/Low Priority

| Feature | Reason to defer |
|---------|----------------|
| Notification Listener for GCash | Accessibility permission dialog confusing for demo; high setup friction |
| 15th/30th payday envelope budget reset | Overlaps with Safe-to-Spend (5A); do that first |
| Insurance Tracker auto-link (#1b) | Niche; low demo value |
| Monthly GitHub-style heatmap (#3) | Nice-to-have; existing 5-week heatmap sufficient |
| Photo gallery screen (#15) | Hub addition; low capstone relevance |
| True net worth historical chart (#9) | ~3h; existing FHS sparkline adequate for defense |

### 🟢 Post-Capstone Roadmap (v3.x)

| Feature | Effort | Notes |
|---------|--------|-------|
| **Tablet / large-screen layout** | ~1 week | App currently works on tablets but doesn't use the extra space — all screens are single-column. Add responsive breakpoints: side-by-side panels on tablets (e.g. Home + Analytics side by side), wider card grids, larger chart areas. Use `LayoutBuilder` + breakpoint at ~600dp. |
| **Tappable chart type switcher** | ~1 day | Analytics charts are fixed types. Let users tap a chart to cycle through types: pie → bar → line → donut. Each tap rotates to next type, saves preference per chart. Low effort since fl_chart already handles all types; just need state + animation. |
| **Landscape orientation support** | ~2 days | App is portrait-locked (no explicit lock, but layouts assume portrait). Landscape mode breaks the home screen card stack. Add `OrientationBuilder` guards on key screens or set preferred orientations per screen. |
| Price Intelligence / Price Pulse (Part 4) | ~2 weeks | Wait for PSA OpenSTAT to exit "Alpha" status |
| PSE/MP2/UITF investment tracker (5F) | ~2 weeks | After BunnyWise launches — assess overlap first |
| ScanReviewScreen rename | 30 min | Code hygiene only |
| SQLite encryption | ~2 days | sqlcipher; post-Play Store |
| Backend API proxy | ~3 days | Cloud Functions; pre-Play Store enforcement |
| App Check enforcement | ~2h | Before Play Store submission |
| iOS / web version | ~2 months | Post-capstone only |
| Business mode AI actions | ~1 week | Invoice tracking |
| Couple/family shared finances | ~2 weeks | Multi-account architecture |
| Mascot / personality (vs Sentimo KBoy, Agila) | ~1 week | Fun differentiator |
| Profile photo cross-device sync | ~1 day | Requires Firebase Blaze plan |

---

## Part 9 — Feature Conflict & Contradiction Check

This section documents potential contradictions between new planned features and existing implemented ones.

| New Feature | Potential Conflict | Resolution |
|-------------|-------------------|-----------|
| Safe-to-Spend (5A) | May confuse users vs existing Cash Flow card and Net Worth card | Cash Flow = month view; Net Worth = all-time; Safe-to-Spend = current pay cycle. Show Safe-to-Spend only in income/wallet mode, only when payday_date is set. Add a clear label distinguishing it from other cards. |
| Proactive nudge notifications (5B) | Startup alerts already fire on app open for budget/overdue/score-drop | Startup alerts = reactive (something already happened). Proactive nudges = forward-looking (something is coming). Keep them in separate notification channels. Add "Proactive Nudges" toggle in App Settings separate from existing alert toggles. |
| Auto-categorization evidence threshold (5C) | User-defined rules in the Auto-Categorization Rules screen | ✅ Implemented v2.9.52. Current priority order: user-defined rules first, then historical majority, then AI/keyword fallback. |
| Notification Listener (revised #4) | Clipboard nudge banner already exists | These are different: clipboard = user manually copied text; notification listener = automatic detection of incoming app notifications. Both can coexist. If notification listener is active, the clipboard banner can be suppressed for the same transaction. |
| Quick budget slider (#11) | % of income budget mode | Slider only activates for fixed ₱ budgets. % mode uses existing dialog. Long-press on a % budget shows a tooltip explaining why the slider is not shown. |
| Savings rate trend chart (#10) | FHS score history line chart already in Analytics | These are different metrics on different scales. FHS is 0–100; savings rate % is 0–100% but means something different. They can coexist in Analytics. Consider putting savings rate chart inside the FHS section as a drill-down. |
| Monthly heatmap calendar (#3) | Existing 5-week heatmap and day-of-week heatmap | The 5-week version shows actual calendar weeks. The day-of-week version shows aggregate averages. A full monthly GitHub-style view would replace/upgrade the 5-week version, not conflict with the day-of-week aggregate. |
| Price Pulse / PSA API (Part 4) | Exchange rate fetching already uses a similar caching pattern | Price cache uses the same `settings` table pattern as exchange rates. Just add a new set of keys. No structural conflict. |
| "What Changed?" monthly recap (5D) | Rollover logic runs at month start and already fires alerts | ✅ Implemented v2.9.52 as a startup alert gated by `show_monthly_recap`. Future work: optional push notification variant. |
| Investment tracker (5F) | PCA/MP2 calculator already exists in Analytics | PCA calculator is a planning tool (how much to contribute). An investment tracker is a balance tracker (how much you have). They answer different questions and don't conflict. |

---

*Content was paraphrased and synthesized from official sources. Sources: PSA OpenSTAT ([openstat.psa.gov.ph](https://openstat.psa.gov.ph)), BSP ([bsp.gov.ph](https://www.bsp.gov.ph)), World Bank ([worldbank.org](https://www.worldbank.org/en/research/commodity-markets)), Rocket Money Rowan announcement ([rocketcompanies.com](https://www.rocketcompanies.com)), BudgetPH ([budget.kindlyf.com](https://budget.kindlyf.com)), PISO Budget Tracker ([pisobudget.com](https://pisobudget.com)), BunnyWise ([bunnywise.io](https://bunnywise.io)), Google Play SMS policy ([support.google.com](https://support.google.com/googleplay/android-developer/answer/9876150)), PCMag 2026 finance app reviews.*

---

## Part 10 — Agila: Finance Coach — Competitive Analysis

**App:** Agila: Finance Coach (`com.janj.agila`)
**Developer:** Teodore Renzo Alcazar
**Platform:** Android + iOS
**Price:** Free (cosmetic mascot IAP ~₱50 each — purely optional)
**Current version:** 1.2.7 (as of September 2026)
**Data collection:** None declared — fully offline-first
**Available on:** Google Play + App Store (Philippines and international)

*Sources: App Store listing, Google Play listing — content paraphrased for compliance.*

---

### What Agila Does

Agila is the most direct and feature-rich Filipino-made personal finance app found in this research. It is designed for both personal users and small business owners, and is explicitly offline-first with no mandatory account creation.

**Personal Finance Features:**
- Track income and expenses with "Agila Chat" (AI-assisted conversational entry)
- Installment and recurring expense management
- Savings goals with progress tracking
- "Who Owe You" — lending/collections tracker
- 50/30/20 budget dashboard
- Wallet management (cash, banks, e-wallets)
- Calendar-based finance tracking
- Financial forecasting and upcoming payment reminders
- Monthly "Wrapped" reports with achievements and financial milestones
- Custom icons and logos per transaction (aesthetic/personality layer)
- Detailed reports, trends, and financial insights

**Business Profile Features (unique to Agila among Filipino apps):**
- Business sales and expense tracking
- Customer and collection management
- Quotations and invoices
- Inventory management
- Business cash flow monitoring
- CSV and JSON export/backup
- Separate Personal and Business profiles in a single app

**Technical:**
- Offline-first — core features work without internet
- No mandatory cloud account
- Optional iCloud Sync (iOS) and Google Drive backup (encrypted)
- Import from other apps: Money Manager, Bluecoins, Spending Tracker

---

### Head-to-Head: SmartSpend vs Agila

| Feature | SmartSpend v2.9.41 | Agila v1.2.7 |
|---------|-------------------|--------------|
| AI agentic actions | ✅ 34 actions | ⚠️ "Agila Chat" — logging only, not confirmed agentic |
| Voice input | ✅ | ❌ |
| OCR receipt scanning | ✅ | ❌ |
| Barcode scanning + product lookup | ✅ | ❌ |
| Batch screenshot import (40+ platforms) | ✅ | ❌ |
| Filipino-English (Taglish) AI | ✅ | Unknown (English only in store listing) |
| Financial Health Score (FHS) | ✅ 4-component, dual-mode, 0–100 | ❌ |
| Financial Management Score (FMS) | ✅ | ❌ |
| Gamification (badges, quests, streaks) | ✅ 25 badges, 10 quests | ⚠️ Achievements in Monthly Wrapped |
| Offline-first | ✅ | ✅ |
| No mandatory account | ✅ Demo mode | ✅ Core works without account |
| Firebase cloud sync | ✅ | ❌ (Google Drive / iCloud) |
| Paluwagan tracker | ✅ | ❌ |
| SSS/PhilHealth/Pag-IBIG tracker | ✅ | ❌ |
| PH government contributions AI | ✅ | ❌ |
| 50/30/20 tracker | ✅ | ✅ |
| Savings goals | ✅ | ✅ |
| Debt / lending tracker | ✅ full debt + payment plans | ✅ "Who Owe You" + collections |
| Installment plans (ShopeePayLater, GLoan) | ✅ | ✅ |
| Business profile (sales, inventory, invoices) | ❌ | ✅ Major differentiator |
| Import from other apps | ❌ | ✅ Money Manager, Bluecoins, Spending Tracker |
| Custom transaction icons/logos | ❌ | ✅ |
| Monthly "Wrapped" / year-in-review | ❌ | ✅ |
| Mascot / cosmetic layer | ❌ (planned) | ✅ Paid mascot pets |
| Multi-currency | ✅ 57 currencies | Unknown |
| BIR/tax calculator | ✅ TRAIN Law | ❌ |
| App Lock (PIN + biometric) | ✅ | ❌ |
| Free (no subscription) | ✅ Always | ✅ Core free |
| iOS version | ❌ | ✅ |

---

### Key Takeaways from Agila

**1. The Business Profile is a genuine gap SmartSpend doesn't have.**
Agila covers small business owners (sari-sari stores, freelancers, side hustlers) with invoices, inventory, and customer/collection tracking. SmartSpend's audience is personal finance only. This is a post-capstone expansion opportunity — the existing debt/installment infrastructure could be extended toward business use.

**2. "Monthly Wrapped" is a high-value low-effort feature SmartSpend is missing.**
Agila shows a monthly summary with achievements and milestones — similar to Spotify Wrapped. This is exactly Feature 5D ("What Changed?" monthly delta notification) in this backlog, but presented as a full in-app screen rather than a push notification. Upgrade 5D to also include a shareable monthly Wrapped card.

**3. Import from other apps gives Agila a migration advantage.**
Users switching from Money Manager, Bluecoins, or Spending Tracker can bring their data. SmartSpend only imports from banks/GCash (paste text), not from other personal finance apps. A CSV import from generic finance apps would reduce switching friction.

**4. Custom icons and mascots — cosmetic engagement.**
Agila lets users customize transaction icons and offers paid mascot pets (₱50 each). This is a monetization and engagement mechanic SmartSpend doesn't have. Low priority but interesting as a post-capstone revenue model.

**5. No confirmed Taglish AI, no FHS, no voice, no OCR, no barcode.**
Despite being more feature-rich on the business side, Agila lacks SmartSpend's core academic contributions: multi-modal input, agentic AI, FHS dual-mode scoring. SmartSpend's academic differentiators remain intact.

**6. Agila has no PH government contributions (SSS/PhilHealth/Pag-IBIG) — SmartSpend leads here.**

---

### Revised Feature Gaps vs Agila (New Items for Backlog)

| Gap | Feature | Priority |
|-----|---------|----------|
| Business profile (sales, inventory, invoices) | Feature 5G — basic business expense separation | 🟢 Post-capstone |
| Import from other apps (CSV) | Feature 5H — generic CSV import from Money Manager, etc. | 🟡 Medium |
| Monthly Wrapped shareable card | Upgrade Feature 5D | 🟡 Medium |
| Custom transaction icons | Feature 5I — cosmetic icons per category or transaction | 🟢 Low |

---

### Updated Benchmark Competitor Table Note

Add Agila to all competitor comparison tables in docs with:
- Package: `com.janj.agila`
- Platform: Android + iOS
- Key strength: Business profile; offline-first; import from other apps; Monthly Wrapped
- Key weakness: No Taglish AI; no FHS; no voice/OCR/barcode; no PH gov contributions
- Price: Free (cosmetic IAP)

---

## Part 11 — Google Play Store Deployment Plan

> **Why this is in the backlog:** Google Play submission is required for Capstone 2 final defense
> (per the Lorma Colleges CCSE BSIT program requirements). The process now takes 4–8 weeks
> in 2026 due to new mandatory closed testing requirements. Planning must start immediately
> after pre-final defense.

---

### 2026 Requirements Overview

Google Play's submission process changed significantly in 2024–2026. The old "upload APK, go live" workflow is gone. Key new requirements as of September 2026:

| Requirement | Details |
|-------------|---------|
| Developer account | Google Play Console personal account; one-time **$25 USD** fee (~₱1,400) |
| Identity verification | Legal name, address, contact email, phone number — Google verifies identity |
| Android developer verification | Starting September 2026 in selected countries (Brazil, Indonesia, Singapore, Thailand first; global rollout 2027). Apps must be registered by a verified developer. Verify at play.google.com/console. |
| **Closed testing (MANDATORY)** | **≥12 active testers must use the app for ≥14 consecutive days** before production access is granted. This is non-negotiable for new personal developer accounts. |
| App Bundle (AAB) format | Must submit as `.aab` (Android App Bundle), not `.apk`. SmartSpend currently builds split APKs — need to add AAB build. |
| Target API level | Must target Android 14+ (API 34+). SmartSpend targets API 36 ✅ |
| Privacy policy | Must be hosted at a live URL, linked in Play Console AND inside the app |
| Data Safety form | Must declare what data is collected, shared, and how it's protected |
| Store listing | Title, short description, full description, 8+ screenshots (different sizes), feature graphic (1024×500px), icon (512×512px) |
| Content rating | Must complete IARC questionnaire (SmartSpend: Finance, 18+, no violence/gambling) |
| Financial services policy | Apps that "facilitate access to financial products" have extra review scrutiny. SmartSpend is a tracker/advisor — not a lender or payment processor — which reduces risk. |

*Sources: Google Play Console requirements docs, gadgethacks.com 2026 changes guide, testerscommunity.com publish guide, BetaCircle product page — content paraphrased for compliance.*

---

### Timeline (Start Post-Pre-Final Defense)

| Week | Task | Owner |
|------|------|-------|
| Week 1 (post-defense) | Create Google Play Console account; pay $25; complete identity verification | Brix |
| Week 1 | Build AAB: `flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info` | Brix |
| Week 1 | Create Privacy Policy page (GitHub Pages or simple HTML on GitHub) | Cyrille |
| Week 1 | Prepare store listing assets (screenshots, feature graphic, icon, descriptions) | Cyrille |
| Week 1–2 | Set up **Closed Testing track** in Play Console; invite ≥12 testers | All + respondents |
| Week 1–14 | **Testers use the app for 14 consecutive days** (can be the 30 SUS survey respondents) | Djaunathan |
| Week 2 | Complete Data Safety form in Play Console | Brix |
| Week 2 | Complete IARC content rating questionnaire | Brix |
| Week 2 | Switch App Check to enforcement mode (PlayIntegrityProvider) | Brix |
| Week 2 | Register release SHA-256 fingerprint in Firebase Console | Brix |
| Week 3 | Upload AAB to Internal Testing track first; verify on real device | Brix |
| Week 3 | Submit for production review | Brix |
| Week 4–6 | Google review period (~7 days for new apps, up to 3 weeks if flagged) | Wait |
| Week 6+ | Live on Play Store ✅ | — |

**Critical path:** The 14-day closed testing with 12 testers is the longest step and cannot be skipped. Start it in Week 1. The SUS survey (30 respondents) can double as the tester pool — they use the app for 2 weeks, then complete the SUS.

---

### Pre-Submission Technical Checklist

**App build:**
- [ ] Build AAB (not APK): `flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info`
- [ ] Verify AAB signs with release keystore (`android/app/smartspend-release.jks`)
- [ ] Test AAB on physical device via `bundletool` or internal testing track
- [ ] Min SDK still 21 (Android 5.0) ✅
- [ ] Target SDK 36 ✅ (Google requires 34+)
- [ ] Version code incremented from 41 (each Play Store release needs a higher versionCode)

**App Check:**
- [ ] Switch `PlayIntegrityProvider` enforcement ON in Firebase Console → App Check → SmartSpend Android → Enforce
- [ ] Register release SHA-256 (not SHA-1) in Firebase Console
  - Get SHA-256: `keytool -list -v -keystore android/app/smartspend-release.jks -alias smartspend -storepass SmartSpend2026!`
  - Add to Firebase Console → Project Settings → Android app → SHA certificate fingerprints
- [ ] Re-download `google-services.json` after adding SHA-256

**Firebase Remote Config:**
- [ ] Rotate Groq API key before publishing (current fallback key in APK becomes public)
- [ ] Set up proper Remote Config parameters with new key values
- [ ] Verify Remote Config is the actual runtime key source (not the fallback)

**Privacy policy:**
- [ ] Create privacy policy URL (e.g. `https://zushikina-kun.github.io/smartspend-privacy`)
- [ ] Policy must cover: data types collected (email, financial transactions), how stored (local SQLite + Firebase), third-party processors (Firebase, Groq API), user rights, contact info
- [ ] Add link to About screen and README
- [ ] Add Privacy Policy tile in Settings screen

**Store listing assets needed:**
- [ ] App icon: 512×512px PNG (already exported from Flutter — verify)
- [ ] Feature graphic: 1024×500px (Cyrille to create — promotional banner)
- [ ] Screenshots: minimum 2, recommended 8 — portrait phone screenshots (1080×1920 or 1080×2340)
  - Home screen with FHS
  - AI chat in action
  - Analytics pie chart
  - Smart Import / batch screenshots
  - Hub screen
  - Budget screen
  - Recurring / Goals
  - About screen showing version
- [ ] Short description (80 chars max): "AI-powered expense tracker for Filipinos — chat to log, track, and plan"
- [ ] Full description (4,000 chars max): based on FEATURE_DOCS.md feature list

**Data Safety form (Play Console):**
- [ ] Data collected: Email address (optional, Firebase Auth), financial transactions (local only — NOT shared), usage data (Firebase Crashlytics)
- [ ] Data shared: Anonymized financial summary text sent to Groq API (not identifiable)
- [ ] Data not collected: Name, phone, location, contacts
- [ ] Security practices: Data encrypted in transit (HTTPS), optional account deletion in app

---

### AAB Build Command

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Keep `build/debug-info/` — needed for decoding Crashlytics stack traces from the obfuscated release.

Upload symbols to Crashlytics:
```bash
firebase crashlytics:symbols:upload --app=YOUR_FIREBASE_APP_ID build/debug-info/
```

---

### Financial Services Policy Notes

SmartSpend falls under Google Play's **Personal Finance** app category. Key notes:

- SmartSpend does NOT offer loans, transfers, or payment processing → lower scrutiny
- SmartSpend DOES show financial data and give AI-generated advice → must include disclaimer
- The disclaimer already exists in the About screen and AI system prompt
- Do NOT advertise APRs, loan terms, or investment returns in store listing
- IARC rating will be 18+ (financial app for adults)
- Target audience section: 18+ only

---

### Post-Submission Monitoring

After going live:
- Monitor Firebase Crashlytics for production crashes
- Monitor Firebase App Check for unauthorized access attempts
- Monitor Google Play Console for policy violations or user reviews
- Rotate API keys in Remote Config if any are flagged or leaked

---

### Play Store Listing Draft

**Title:** Smart Spend — AI Finance Tracker
*(30 char limit — "Smart Spend" is 11 chars + subtitle)*

**Short description (80 chars):**
> AI-powered expense tracker for Filipinos. Chat to log, track & plan your money.

**Category:** Finance

**Tags:** personal finance, budget tracker, expense tracker, AI finance, Filipino finance

**Content rating:** Everyone (no violence/gambling/adult content) — but restrict to 18+ via Target Audience

---

### Cost Summary

| Item | Cost |
|------|------|
| Google Play Developer account | $25 USD (~₱1,400) one-time |
| Privacy policy hosting | Free (GitHub Pages) |
| Store assets (screenshots, feature graphic) | Free (design tools) |
| Closed testing tester pool | Free (use SUS survey respondents) |
| App Check enforcement | Free (Firebase Spark plan) |
| **Total** | **~₱1,400** |

No ongoing costs. SmartSpend uses Firebase Spark (free) and free-tier AI providers — no server costs.

---

## Part 12 — iOS / App Store Deployment Plan

> **Why this is in the backlog:** Every competitor (Agila, BudgetPH, YNAB, Monarch) has iOS. Agila already ships on both platforms. The target respondent demographic (parents 35–55, young professionals 21–35) has significant iOS penetration in the Philippines. Flutter was specifically chosen as the framework partly because it supports iOS with the same codebase.

*Sources: Flutter docs (docs.flutter.dev), Firebase iOS setup (firebase.google.com/docs/ios/setup), Apple Developer Program (developer.apple.com), FlutterFire iOS requirements (yespo.io Aug 2026). Content paraphrased for compliance.*

---

### Requirements Overview

| Requirement | Detail |
|-------------|--------|
| **Mac computer** | **Required** — Xcode only runs on macOS. iOS builds cannot be done from Windows. This is the only hard blocker for the whole team. |
| **Xcode** | Version 26.2+ (August 2026 requirement per FlutterFire Firebase Apple SDK 12.x) |
| **CocoaPods** | 1.12.0+ (for plugin dependency management) |
| **Minimum iOS target** | **iOS 15.0** — required by Firebase Apple SDK 12.x (confirmed Firebase docs September 2026) |
| **Apple Developer Program** | **$99 USD/year** (~₱5,500) — needed for App Store distribution and TestFlight |
| **Physical iPhone or Simulator** | For testing. Simulator can run on Mac. |
| **GoogleService-Info.plist** | iOS equivalent of `google-services.json` — download from Firebase Console after registering iOS app |
| **Bundle ID** | Must match what's registered in Firebase — suggest `com.lucidframe.smartspend_app` (same as Android) |

---

### Plugin iOS Compatibility Check

All major SmartSpend plugins support iOS:

| Plugin | iOS support | Notes |
|--------|------------|-------|
| `sqflite` | ✅ iOS + Android + macOS | Full support |
| `firebase_core` / `firebase_auth` / `cloud_firestore` | ✅ iOS 15+ | Requires `GoogleService-Info.plist` |
| `firebase_crashlytics` | ✅ | |
| `firebase_remote_config` | ✅ | |
| `google_mlkit_text_recognition` | ✅ iOS | Uses AVFoundation on iOS (not just Android) |
| `google_mlkit_barcode_scanning` | ✅ iOS | |
| `mobile_scanner` | ✅ iOS | Uses AVFoundation/Apple Vision on iOS |
| `local_auth` | ✅ iOS | Face ID + Touch ID |
| `flutter_local_notifications` | ✅ iOS | Requires `UNUserNotificationCenter` permission in `AppDelegate.swift` |
| `speech_to_text` | ✅ iOS | Requires `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` in `Info.plist` |
| `image_picker` | ✅ iOS | Requires `NSPhotoLibraryUsageDescription` + `NSCameraUsageDescription` |
| `share_plus` | ✅ iOS | |
| `path_provider` | ✅ iOS | |
| `shared_preferences` | ✅ iOS | |
| `shake` | ✅ iOS | Uses accelerometer |
| `file_picker` | ✅ iOS | |

**No blocking iOS incompatibilities found.** All plugins used by SmartSpend have confirmed iOS support.

---

### Key iOS-Specific Differences vs Android

| Feature | Android behavior | iOS behavior |
|---------|-----------------|--------------|
| Notifications | `flutter_local_notifications` works out-of-box | Must request `UNUserNotificationCenter` permission + add to `AppDelegate.swift` |
| Voice/Speech | `speech_to_text` with `en_PH` locale | Same plugin; requires `NSMicrophoneUsageDescription` in Info.plist |
| Camera/OCR | ML Kit `google_mlkit_text_recognition` | Same plugin; uses on-device CoreML/Vision on iOS |
| Barcode | `mobile_scanner` with CameraX | Same plugin; uses AVFoundation/Apple Vision on iOS |
| App Lock biometric | `local_auth` (fingerprint/face) | Same plugin; uses Face ID or Touch ID |
| File paths | Android `getExternalStorageDirectory()` | iOS uses `getApplicationDocumentsDirectory()` — already handled by `path_provider` |
| Deep links | Android Intent filters | iOS requires `Info.plist` Universal Links setup |
| Background notifications | Android foreground service | iOS background fetch + silent push |
| Google Sign-In | SHA-1 fingerprint in Firebase | iOS uses URL scheme (`REVERSED_CLIENT_ID`) in `Info.plist` |
| SQLite encryption (future) | SQLCipher on Android | SQLCipher also supports iOS (same plugin) |

---

### iOS Setup Steps (When Ready)

**Step 1 — Firebase iOS Registration**
1. Firebase Console → Project Settings → Add App → iOS
2. Bundle ID: `com.lucidframe.smartspend_app`
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/` in Xcode (drag into Runner target)
5. Register iOS App Check (DeviceCheck for iOS)

**Step 2 — Info.plist Permissions**
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>SmartSpend needs microphone access for voice expense logging.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>SmartSpend uses speech recognition to parse expense descriptions.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>SmartSpend accesses your photo library for receipt import.</string>
<key>NSCameraUsageDescription</key>
<string>SmartSpend uses the camera for receipt scanning and barcode detection.</string>
<key>NSFaceIDUsageDescription</key>
<string>SmartSpend uses Face ID as an optional app lock.</string>
```

**Step 3 — Google Sign-In URL Scheme**
In `ios/Runner/Info.plist`, add `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string><!-- REVERSED_CLIENT_ID from GoogleService-Info.plist --></string>
    </array>
  </dict>
</array>
```

**Step 4 — Minimum iOS Version**
In `ios/Podfile`, ensure:
```ruby
platform :ios, '15.0'
```

**Step 5 — Notifications in AppDelegate.swift**
```swift
import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Step 6 — Build and Test**
```bash
flutter build ios --release --obfuscate --split-debug-info=build/debug-info-ios
# Or for simulator testing (no signing needed):
flutter build ios --simulator
```

**Step 7 — App Store Submission**
1. Open Xcode → Product → Archive
2. Distribute App → App Store Connect
3. Upload to TestFlight first (beta testing with up to 10,000 users)
4. Submit for App Review (~24–48h review time for first submission)

---

### Apple Developer Program vs Google Play — Cost Comparison

| Item | Google Play | Apple App Store |
|------|-------------|-----------------|
| Developer account | $25 USD one-time | **$99 USD/year** (~₱5,500/year recurring) |
| Review time | 7 days (new apps) | 24–48h |
| Closed testing requirement | ≥12 testers × 14 days | TestFlight (no minimum days) |
| Physical Mac required | No | **Yes** |
| iOS build from Windows | No (impossible) | No (impossible) |

---

### iOS Backlog Priority

| Task | Phase | Effort | Blocker |
|------|-------|--------|---------|
| Get access to a Mac (borrow/use school lab) | iOS Phase 1 | Low | **Critical prerequisite** |
| Register iOS app in Firebase Console + download GoogleService-Info.plist | iOS Phase 1 | 30 min | Needs Mac + Xcode |
| Add Info.plist permissions (mic, camera, Face ID, photo) | iOS Phase 1 | 30 min | |
| Set `platform :ios, '15.0'` in Podfile | iOS Phase 1 | 5 min | |
| Add Google Sign-In URL scheme to Info.plist | iOS Phase 1 | 15 min | |
| Update AppDelegate.swift for notifications | iOS Phase 1 | 30 min | |
| Build and test on iOS Simulator | iOS Phase 1 | ~2h (debug) | |
| Test on physical iPhone | iOS Phase 1 | ~1h | Need iPhone |
| Enroll in Apple Developer Program ($99/yr) | iOS Phase 2 | Administrative | ₱5,500/yr cost |
| Build release IPA via Xcode Archive | iOS Phase 2 | ~1h | Needs signing cert |
| Upload to TestFlight | iOS Phase 2 | 30 min | |
| Submit to App Store Review | iOS Phase 2 | 30 min + 24–48h wait | |
| App Store listing (same assets as Google Play) | iOS Phase 2 | ~2h | Cyrille to create App Store screenshots |
| Register iOS App Check (DeviceCheck) in Firebase | iOS Phase 2 | 30 min | |

**Total estimated effort:** ~1 day of work on a Mac to get a working iOS build + 2 days for App Store submission prep.

**Key difference from Android:** The 14-day closed testing requirement does NOT exist on iOS. TestFlight allows immediate distribution to up to 10,000 beta testers with no minimum time window. This means iOS App Store submission can happen faster than Google Play once a Mac is available.

---

### iOS vs Android Feature Parity Check

After porting, these items need specific iOS testing:

| Feature | Risk level | Reason |
|---------|-----------|--------|
| Voice input (`speech_to_text`) | 🟡 Medium | Locale `en_PH` availability on iOS — test Filipino English recognition |
| OCR batch screenshots | 🟡 Medium | ML Kit Vision uses CoreML on iOS — accuracy may differ from Android |
| Shake-to-undo | 🟢 Low | `shake` plugin uses accelerometer — same behavior on iOS |
| App Lock (biometric) | 🟢 Low | `local_auth` works; Face ID instead of fingerprint on iPhone X+ |
| GCash/Maya notification detection | 🔴 High | `NotificationListenerService` is Android-only. iOS equivalent = Share Extension or shortcut integration — requires separate implementation |
| Push notifications | 🟡 Medium | iOS requires APNs (Apple Push Notification service) — different setup than Android FCM |
| File sharing/export | 🟢 Low | `share_plus` works on iOS |

**Most critical iOS-specific issue:** The Notification Listener for GCash detection (planned feature) is Android-only. On iOS, the same functionality would require a **Share Sheet Extension** (user manually shares a GCash notification from Notification Center to SmartSpend) or an **iOS Shortcut** — both are much more limited than the Android `NotificationListenerService`. This should be documented as an iOS limitation.

---

### Updated Competitor Context After iOS Port

Once iOS is live, the competitive position improves significantly:

| App | Android | iOS | Notes |
|-----|---------|-----|-------|
| SmartSpend (post-iOS) | ✅ | ✅ | Closes the platform gap |
| Agila | ✅ | ✅ | Already on iOS |
| BudgetPH | ✅ PWA | ✅ PWA | Web-based — works on iOS via browser |
| Alkansya AI | ❌ | ✅ | iOS-only competitor; iOS port closes this gap directly |
| GCash Pera Coach | ✅ | ✅ | Inside GCash app |
| PISO Budget Tracker | ✅ | ❌ | Android-only — SmartSpend would lead on iOS |
| BunnyWise | ✅ (launching) | ❌ (TBD) | |

An iOS version directly outcompetes Alkansya AI on their own platform.

---

## Part 13 — UI / Customization / Settings Remaining Items

*Found during v2.9.44 settings audit — September 12, 2026.*

### ✅ Already done in v2.9.44
- APPEARANCE section in Settings: Dark Mode, App Theme (5 colors), Text Size, High Contrast, Compact Mode, Display Currency nav
- SECURITY section in Settings: App Lock tile with live state
- Spending Limits nav tile in Settings BEHAVIOR
- Notification permission hint banner in Settings NOTIFICATIONS
- compact_mode dual-store fixed (ThemeService = single source)
- Hub tile renamed "Currency Exchange" → "Display Currency"

---

### 13A — Remove duplicate appearance settings from Profile screen (Priority: 🔥 Quick win)
**Problem:** Dark Mode toggle, App Theme picker, Text Size picker, High Contrast toggle all exist in **both** the Profile screen settings card AND the new Settings APPEARANCE section. Users will find them in Settings now and not realize Profile also has them, or vice versa.

**Fix:** Remove the four duplicated items from the Profile settings card (Dark Mode, App Theme, Text Size, High Contrast). Replace with a single "Appearance →" nav tile that opens Settings screen scrolled to APPEARANCE. This makes Profile the place for account/financial data and Settings the place for all app customization.

**Effort:** ~1h | **Risk:** Low — just removing/replacing UI tiles, no logic change

---

### 13B — Home screen "Customize" shortcut (Priority: 🟡 Medium)
**Problem:** To hide/show home screen sections (subscriptions, forecast, badges, etc.), users must navigate: Profile → App Settings → scroll to HOME SCREEN section. That's 3 taps + a scroll on a long page. Most users won't find it.

**Fix:** Add a small customize icon (⚙ or 🎛) in the home screen's AppBar actions. Tapping it scrolls/navigates directly to the "HOME SCREEN — SHOW/HIDE SECTIONS" part of Settings. Can be done as a direct `Navigator.push` to `SettingsScreen` — or even better, open a slim bottom sheet with just the 6 home-section toggles inline.

**Effort:** ~2h | **Risk:** Low

---

### 13C — Profile settings card cleanup (Priority: 🟡 Medium)
**Problem:** The Profile screen acts as a "super settings" dumping ground. It currently contains: financial data (avatar, scores, net worth, income) at the top AND a long card list with account type, theme, app lock, spending limits, app settings nav, export, backup, etc. all mixed together. The split is confusing — profile data and app settings share one screen.

**Fix:** Re-organize the Profile card list into clear sections with dividers or headers:
- **Account** — Account Type, Income settings
- **Security** — App Lock (can stay here for discoverability), App Settings nav tile
- **Data** — Export CSV, Backup/Restore, Reset All Data
- **About** — Financial Health Certificate, Debug Log, Help, About, What's New

Remove duplicate: Dark Mode / App Theme / Text Size / High Contrast → handled by 13A above.

**Effort:** ~2h | **Risk:** Low

---

### 13D — Home screen card reordering (Priority: 🟢 Low)
**Problem:** Home screen card order is hardcoded. Users can't move the FHS card before the spending card, or put Quick Log chips at the top, etc.

**Fix:** Add a "Reorder cards" mode — long-press the home screen or a dedicated drag handle to enter reorder mode, drag cards up/down, tap Done. Store order in DB as a JSON array of card IDs.

**Effort:** ~2 days | **Risk:** Medium (needs drag-reorder widget + order persistence)

---

### 13E — Additional color themes (Priority: 🟢 Low)
**Problem:** Only 5 seed colors. Material 3 supports any seed color. Users with strong color preferences (e.g. pink, red, navy) have no option.

**Fix options:**
- (A) Add 3–5 more preset themes: Crimson Red, Deep Navy, Midnight Teal, Rose Pink
- (B) Add a custom color picker using a `ColorPicker` package

**Effort:** (A) ~30 min | (B) ~2h | **Risk:** Very low

---

### 13F — Font family option (Priority: 🟢 Low)
**Problem:** `ThemeService` hardcodes `fontFamily: 'Roboto'`. Some users prefer a rounded or serif font.

**Fix:** Add 2–3 bundled font options to `ThemeService` and a font picker in the APPEARANCE section. Options: Roboto (default), Nunito (rounded, friendlier), DM Sans (modern clean).

**Effort:** ~1h (add font assets + picker UI) | **Risk:** Low

---

### 13G — AI chat compact density option (Priority: 🟢 Low)
**Problem:** The global Compact Mode reduces list density across all screens but the AI chat message bubbles don't have their own density option. On long conversations, messages can feel spaced out.

**Fix:** Apply `compactMode` from `themeService` to reduce message bubble padding and avatar size in the AI chat list. No new settings needed — just honor the existing compact mode flag in the chat UI.

**Effort:** ~30 min | **Risk:** Very low

---

### 13H — "Done spending today" and spending commitment UX (Priority: 🟢 Low)
**Problem:** `done_spending_today` is a setting key that exists in the code (checked in add_expense_screen) but there's no visible UI to set/clear it. Users can't consciously commit to "no more spending today".

**Fix:** Add a "Done spending today" toggle to the Daily Summary card or as a quick action in the log choice sheet. When toggled ON, logging an expense shows the "⚠️ You said you were done spending today" nudge. Clear automatically at midnight.

**Effort:** ~1h | **Risk:** Low

---

## Part 11 — AI Provider & Model Updates (September 2026)

> Based on research from LLM_Engineering_Cheatsheet_v6.md, adviser conversation (Kimi K2.6, Qwen 3.8 mentions), and online research.
> See the cheatsheet Appendix A for full provider code examples.

### 11A — Current Fallback Chain Status

SmartSpend's 8-provider failover chain (v2.9.24+) is still valid but needs a note on model updates:

| Priority | Provider | Model ID | Status |
|---|---|---|---|
| 1 | Google | `gemini-3.5-flash-lite` | ✅ Current, GA stable |
| 2 | Google | `gemini-3.5-flash` | ✅ Current, GA stable |
| 3 | Groq | `openai/gpt-oss-120b` | ✅ Active on free/dev tier |
| 4 | Groq | `qwen/qwen3.6-27b` | ✅ Active on free/dev tier |
| 5 | Groq | `qwen/qwen3.8-27b` | ✅ Active on free/dev tier |
| 6 | Groq | `openai/gpt-oss-20b` | ✅ Active on free/dev tier |
| 7 | Groq | `groq/compound-mini` | ✅ Active on free/dev tier |
| 8 | Cerebras | `openai/gpt-oss-120b` | ✅ 1M tokens/day |

> ⚠️ **Do NOT add to chain:** `gemini-3.7-flash` (paid only, $0.75/1M), Kimi K2.6/K3 (no free API), GitHub Models (retired July 30, 2026), any LLaMA model (retired from Groq Feb–Aug 2026).

---

### 11B — Notable New Models (Not in SmartSpend Chain, Worth Knowing)

These are NOT in SmartSpend's current failover chain (no free programmatic API or not yet suitable), but are worth tracking for future upgrades:

#### Kimi K3 — Moonshot AI (July 16, 2026)
- **Architecture:** 2.8T MoE, 104B active per token, 1M context window
- **License:** Open weights on Hugging Face (July 27, 2026)
- **Benchmarks:** #1 open-weight model on Artificial Analysis Intelligence Index (v4)
- **Specs:** 896 experts, 16 selected per token; Kimi Delta Attention; native vision
- **Notable:** Largest open-weight model ever released; outperforms closed models on coding
- **Free access:** NVIDIA NIM (free allocation), OpenRouter (not currently `:free`)
- **Paid API:** Moonshot AI platform — tiered by account top-up
- **Why not in chain:** No permanent free API tier; NVIDIA NIM free allocation runs out quickly
- **Future consideration:** Post-capstone v3.x upgrade for `financial_advice` tier

#### Kimi K2.6 — Moonshot AI (April 20, 2026)
- **Architecture:** 1T MoE, 32B active, 256K context
- **Benchmarks:** 80.2% SWE-Bench Verified, 96.4% AIME 2026
- **Agent Swarm:** 300 sub-agents, 4,000 coordinated steps per run
- **Pricing:** $0.60/$2.50 per MTok on Moonshot; $0.60/$2.80 on OpenRouter
- **Free access:** OpenRouter `:free` tier (availability varies, not permanent)
- **Note:** Original Kimi K2 API discontinued May 25, 2026

#### Qwen3.8-27B — Alibaba (August 14, 2026)
- **Architecture:** Dense (all 27B parameters active), Apache 2.0
- **Context:** 262,144 tokens (extendable to 1M)
- **Modalities:** Text + images + video
- **Benchmarks:** 52 on Artificial Analysis Intelligence Index, 61.7% SWE-bench Pro
- **Local:** ~17GB VRAM at Q4_K_M — fits RTX 4090; best locally runnable ~30B VLM
- **Free API access:** Groq (`qwen/qwen3.8-27b` — **already in our chain!**), NVIDIA NIM
- **Already in chain:** ✅ Yes — Tier 5 in SmartSpend's fallover

#### Qwen3.8-Max — Alibaba (August 3, 2026)
- **Architecture:** 2.4T MoE, ~95B active, 1M context, text + images + video
- **Pricing:** $2/$6 per MTok — not free
- **Open weights:** Released on Hugging Face ~1 week after API launch
- **Significance:** Alibaba's frontier flagship; strong competition for GPT-5 class models

#### DeepSeek V4 Family (April 23, 2026)
- **Models:** `deepseek-v4-flash` (163K context, $0.14/MTok), `deepseek-v4-pro` ($0.66/MTok)
- **License:** MIT — fully open weights
- **Free access:** 5M token grant on new account signup; also via NVIDIA NIM
- **Why not in chain:** No permanent free daily quota; trial credit depletes
- **Best use:** Cheapest paid upgrade path if Gemini free tier is insufficient (10–30× cheaper than OpenAI/Anthropic)

---

### 11C — Qwen Free Proxy via OpenCode — STATUS UPDATE

The `Using Qwen Models Free with OpenCode.md` document in this repo describes a method using `qwen.aikit.club` to access Qwen models through a localStorage token extraction from `chat.qwen.ai`.

**⚠️ This method is OUTDATED and unreliable:**
- The Qwen free OAuth tier that powered this approach was **shut down on April 15, 2026**
- Direct proxy services like `qwen.aikit.club` are third-party, not official, and can disappear without notice
- Extracting localStorage tokens is technically a violation of Qwen's Terms of Service
- The official Qwen Code free tier was reduced from 1,000 req/day → 100 req/day → discontinued

**Current free access to Qwen models:**
- **Groq free/dev tier:** `qwen/qwen3.6-27b` and `qwen/qwen3.8-27b` — 1,000 RPD each — **this is the real free path**
- **NVIDIA NIM:** Free allocation on signup

**For AI coding tools (the actual use case from the video):**
- **OpenCode:** $10/month Go subscription for reliable access; free tier is limited (~200 req/5h)
- **Alternative:** Use Kiro IDE (which you're already using), Cursor, or VS Code + Continue with Groq API key (free)

**Recommendation:** Delete or archive `Using Qwen Models Free with OpenCode.md` — it describes a deprecated method. The accurate current approach is documented in `LLM_Engineering_Cheatsheet_v6.md` Appendix A.

---

## Part 12 — New Feature Ideas (September 2026 Research)

> Based on: fintech 2026 research, NielsenIQ Philippines report, SmartOSC digital banking trends, competitor analysis.

### 12A — Spending Accountability Partner (Priority: 🟡 Medium)
**Inspired by:** NielsenIQ 2026 finding — "consumers want digital services that are fast, easy, secure, and **human-supported**"

**What it is:** Optional "check-in" feature where the user sets a weekly spending target, and gets a single no-judgment push notification at the end of the week:

```
📊 Week Check-In
You set a ₱2,000/week Food goal.
This week: ₱1,840 — ₱160 under. ✅ Nice work!
```

- No AI call needed — pure DB computation
- Only fires if user has set a weekly budget for that category
- No guilt framing — uses positive language ("nice work!" not "you failed")
- Based on behavioral finance: accountability + positive reinforcement improves adherence
- **Effort:** ~2h. Pure StartupAlerts + flutter_local_notifications

**Conflict check:** Different from existing "What Changed?" (5D) — this is weekly, category-specific, and requires the user to have set a target. Complements existing budget alerts (which fire when you exceed limits — this fires to celebrate or note progress).

---

### 12B — Quick Income Log Shortcut (Priority: 🟡 Medium)
**What it is:** A persistent floating chip on the home screen (below the wallet card) for the user's most recent income source. One tap → confirms income received → adds to income + updates wallet.

**Example:** If the user's last income entry was "Salary ₱12,000", the chip shows:
```
[💰 Received Salary ₱12,000?  Log it →]
```

- Shown only for students/employed users when last income was > 25 days ago
- Works alongside the existing "Log Allowance" button (which is for custom amount)
- This is for repeat-same-amount income (salary, allowance) — the common case
- **Effort:** ~1h. New chip in home dashboard, reads last income entry from DB

---

### 12C — Expense "Undo" History Card (Priority: 🟡 Medium)
**What it is:** A dismissible card at the top of Transactions that shows the last 3 AI-logged expenses with a simple "Undo?" button for each. Appears for 24 hours after logging.

**Why:** Users frequently tell AI "I spent 500" then realize it was logged wrong (wrong category, wrong amount). Currently they have to navigate to Edit Expense. This surface brings the undo action directly to where they look — the expense list.

- Already exists: shake-to-undo and the snackbar undo in AI chat
- This is a **complementary surface** for users who don't know about shake
- Uses existing undo infrastructure — no new logic needed, just new UI surface
- **Effort:** ~2h. New card widget in transactions_screen reading last 3 AI-logged entries

---

### 12D — AI Provider Health Dashboard (Priority: 🟢 Low)
**What it is:** A small status row in Settings → App Settings → AI MODEL section showing which providers are currently responding, which have hit their daily limit, and which are flagged:

```
AI Providers
✅ Gemini 3.5 Flash-Lite   Active (primary)
✅ Groq GPT-OSS 120B       Active
⚠️ Groq Qwen3.6-27B       Rate-limited
⚡ Cerebras                Last resort
```

- Reads from `ai_request_trace` in settings (already logged per request)
- Purely informational — no backend ping needed
- Helps users understand why responses might feel slower on some days
- **Effort:** ~2h. New widget in settings_screen reading from existing trace data

---

### 12E — "Translate My Receipt" Shortcut (Priority: 🟢 Low)
**What it is:** An AI shortcut in the Log Expense sheet: "📷 Translate Receipt" — specifically aimed at Japanese, Korean, or English receipts common for online shopping. AI reads the receipt OCR text and reformats it into a set of Filipino-contextualized expense items.

- Already exists: batch screenshot import + OCR
- This is a **friendlier entry point** for the common "I bought from Shopee/Lazada/AliExpress" use case
- Pre-fills the "Import" source in the log sheet with a single button
- **Effort:** ~1h. New option in _showLogExpenseSheetLocal → opens SmartCameraScreen with receipt mode preset

---

### 12F — Payday Countdown Widget (Priority: 🟡 Medium)
**What it is:** Replaces or augments the existing "Smart Daily Allowance" card with a payday countdown when `payday_date` is set:

```
📅 Payday in 12 days  (Oct 15)
Safe to spend today: ₱420
At this pace: ₱11,200 by payday (under ₱12,000 ✅)
```

- Directly addresses BudgetPH's payday-cycle feature gap
- Works for 15th/30th and custom payday dates
- Falls back to Smart Daily Allowance display when no payday date set
- Related to Safe-to-Spend (5A) but simpler — just shows the countdown + daily budget
- **Effort:** ~2h. Modify existing `_buildDailyLimitCard` in home_screen

---

### 12G — AI Model Upgrade Pathway (Priority: 🟢 Low / Research)
**Context:** As Kimi K3 and Qwen3.8-Max become cheaper/more accessible, SmartSpend could route specific high-value queries to better models while keeping the bulk on the free chain.

**Proposed tiered routing upgrade for v3.x:**

| Tier | Current model | Potential upgrade |
|---|---|---|
| `fast` — expense parsing | Gemini 3.5 Flash-Lite | Keep (best free) |
| `smart` — analysis | GPT-OSS 120B (Groq) | Kimi K2.6 or K3 if free tier emerges |
| `financial_advice` | Gemini 3.5 Flash | Qwen3.8-27B (already in chain!) or Kimi K3 |

**Current assessment (September 2026):**
- Gemini 3.5 Flash-Lite is still the best free-tier primary — GA stable, 500 RPD, low latency
- Qwen3.8-27B on Groq (already Tier 5) could be promoted to `financial_advice` tier given its strong reasoning
- Kimi K3 → post-capstone only (no permanent free API)
- DeepSeek V4 Flash → best paid upgrade path (~$0.14/MTok = ~₱8 per 1M tokens)

---

## Part 13 — Defense Preparation Timeline (Updated)

### Before Pre-Final Defense (This Week)

**Code — DONE ✅**
- All 9 Phase 1 tasks completed (v2.9.45)
- Full UI polish across all 37 screens (v2.9.46–v2.9.47)
- App is at v2.9.47, release on GitHub

**Docs — Still Needed (Brix/Cyrille)**
- [ ] Install v2.9.47 APK on demo phone
- [ ] Update FEATURE_DOCS.md (still on v2.9.11)
- [ ] Rehearse demo flow (see DEFENSE_GUIDE.md Part 2)
- [ ] Create Figures 1.1, 1.2, 2.1, 2.2 (Cyrille)
- [ ] Fill Compliance Matrix

---

### After Pre-Final Defense → Before Final Defense

**Code priority (sorted by impact on final defense demo + manuscript):**

| Priority | Feature | Effort | Why it matters |
|---|---|---|---|
| 🔥 1 | **Safe-to-Spend number** (5A) | ~1 day | Closes BudgetPH's biggest gap; strong demo moment |
| 🔥 2 | **Action allowlist + source restrictions** (15B) | ~3h | Security hardening before more import surfaces |
| 🔥 3 | **First-time AI advice disclaimer** (15C) | 30min | Trust/compliance for financial advice |
| 🟠 4 | **AI confidence explainability banner** (15H) | ~1h | Makes low-confidence AI logs reviewable |
| 🟠 5 | **Proactive AI nudge notifications** (5B) | ~2 days | Rowan-style; strong competitive differentiator |
| 🟠 6 | **GCash/Bank share intent receiver** (15D) | ~3h | Lets users share transaction text into SmartSpend instead of manual copy/paste |
| 🟡 7 | **Quick Income Log chip** (12B) | ~1h | Student UX — easy win |
| 🟡 8 | **Expense Undo History card** (12C) | ~2h | Reduces user frustration with AI logging |
| 🟡 9 | **Spending Accountability Partner** (12A) | ~2h | Gamification layer; supports behavioral theory |

**Already implemented since this table was first drafted:** Payday Countdown Widget / Income Prediction (#13), "What Changed?" monthly recap (5D), AI chat history export (#14), auto-categorization evidence threshold (5C), semester recurring detection (#1a).

**Docs:**
- [ ] SUS survey — 30 respondents (Djaunathan)
- [ ] Play Store closed testing — 12 testers × 14 days (Brix)
- [ ] Insert survey + SUS results into manuscript Ch.3 (Cyrille)
- [ ] Update all FHS equations in manuscript (v2.9.42 changes)
- [ ] Add Agila, Lista PH, Kibo to competitor table

---

### Post-Final Defense → v3.x Roadmap

| Feature | Effort | Notes |
|---|---|---|
| Price Intelligence / Price Pulse (Part 4) | ~2 weeks | PSA API + personal inflation; strong academic contribution |
| Notification Listener for GCash | ~2 days | Play Store compliant alternative to READ_SMS |
| Monthly GitHub-style heatmap (#3) | ~1 day | Full per-date grid |
| Photo gallery screen (#15) | ~3h | Hub → Receipts GridView |
| Expense Correction Suggestions (5E) | ~1 day | Data quality sweep |
| True net worth historical chart (#9) | ~3h | Snapshot-based |
| SQLite encryption | ~2 days | Pre-Play Store |
| Backend API proxy (Cloud Functions) | ~3 days | Pre-Play Store |
| App Check enforcement | ~2h | Pre-Play Store |
| Kimi K3 / Qwen3.8-27B routing upgrade | ~1 day | When free tier emerges |
| Investment tracker (PSE/MP2/UITF/crypto) | ~2 weeks | After BunnyWise launches |
| iOS version | ~2 months | Post-capstone |
| Business mode AI actions | ~1 week | Invoice/inventory |
| Couple/family shared finances | ~2 weeks | Multi-account architecture |
| Mascot / personality layer | ~1 week | vs Sentimo KBoy |
| AI Provider Health Dashboard (12D) | ~2h | Nice dev-facing feature |
| "Translate My Receipt" shortcut (12E) | ~1h | Quick usability win |
| AI Model Upgrade Pathway (12G) | ~1 day | Route financial_advice to Qwen3.8-27B |

---

## Part 14 — Competitor Intelligence Update (September 2026)

### Updated Competitor List

| App | Status | Key gap vs SmartSpend |
|-----|--------|----------------------|
| BudgetPH | Active | No agentic AI, no multi-modal, no voice |
| PISO Budget Tracker | Active | No AI whatsoever |
| Agila: Finance Coach | Active v1.2.7 | Business profile strong; no FHS, no batch screenshots |
| BunnyWise | Launching | Investment-focused; no AI, no expense tracking |
| MayBudget | Active | Basic tracker only |
| Lista PH | Active | Credit score access; no AI, no FHS |
| Kibo | Active | AI categorization; limited PH context |
| GCash Pera Coach | Active (Mar 2026) | Literacy Q&A only; no expense tracking |
| Rocket Money + Rowan | US only | Agentic AI via SMS (conceptual benchmark) |

**New threats to monitor (not yet launched in PH):**
- **Finanzya** (dupple.com 2026 review) — 96% auto-categorization accuracy, retirement/FIRE forecast, 31 currencies — strong international competitor if it localizes for PH
- **ChatGPT Finance** — US/Plaid only now, but OpenAI's expansion pace means PH entry is possible within 1–2 years

### SmartSpend's Widening Lead

With v2.9.47 UI polish, SmartSpend now competes not just on features but on **visual design quality** — the soft-shadow card system, gradient profile header, and grouped settings cards put it closer to production-quality apps like GCash and Maya in terms of visual polish.

Remaining gaps to close for Play Store submission:
1. Safe-to-Spend / payday cycle (BudgetPH gap)
2. SQLite encryption (pre-Play Store requirement)
3. Backend API proxy (security hardening)
4. App Check enforcement
5. Privacy policy hosted URL

---

*Updated September 12, 2026. New in this revision: Parts 11–14 — AI provider updates, Kimi K3/Qwen3.8 models, Qwen free proxy deprecation notice, 7 new feature ideas (12A–12G), defense timeline, updated competitor intelligence.*
*Content paraphrased for compliance with licensing restrictions.*

---

## Part 15 — Gap Analysis: Research-Identified Missing Items (September 2026)

> Identified from cross-referencing LLM engineering research (v6 cheatsheet), competitor analysis,
> Philippine market data (NielsenIQ, BSP, PSA FIES), and responsible AI frameworks (Cisco/Mapua).
> Organized by phase: before final defense → post-capstone.

---

### Gap Category 1 — AI Engineering Gaps (from LLM Cheatsheet Research)

---

#### 15A — Chat History Token Compression (Priority: 🟠 Before Final Defense)
**Gap identified from:** §49 Token Budget for Mobile Apps (LLM Cheatsheet v6)

**Problem:** SmartSpend sends the **full chat history** on every AI message. A user with a 30-turn conversation is sending ~15,000 tokens of old context every single message — burning through the 150/day limit 3–5× faster than needed, and hitting the "lost in the middle" degradation zone where the model ignores middle context.

**What to add:**
- Keep last 8 turns in full detail
- Summarize everything older into a single 2–3 sentence briefing (one cheap AI call)
- Store the summary as `chat_context_summary` in settings, update it when history grows past 8 turns

**Implementation in Dart (AIChatService):**
```dart
// Before building the messages array for an API call:
if (_history.length > 8) {
  final summary = await _summarizeOldTurns(_history.sublist(0, _history.length - 8));
  final compressed = [
    {'role': 'user',  'content': 'Earlier conversation summary: $summary'},
    ..._history.sublist(_history.length - 8),
  ];
  return compressed;
}
return _history;
```

**Effort:** ~2h  
**Conflict check:** None — purely internal to `AIChatService.sendMessage()`. Users don't see the compression. The summary is generated with a minimal prompt costing ~100 tokens total.

---

#### 15B — Action Source Restriction + Allowlist (Priority: 🟠 Before Final Defense)
**Gap identified from:** §47 Agentic Action Parsing & Hardening + §50 Prompt Injection in Mobile Contexts

**Problem:** SmartSpend executes any parsed action from any source — AI chat, OCR text, clipboard paste, barcode. This means:
1. A malicious/malformed receipt or barcode could theoretically trigger `delete_by_date` or `delete_expense`
2. There's no explicit allowlist — unknown action names could be attempted

**What to add:**
1. **Action allowlist** — a `Set<String>` of known valid action names; reject anything not on it
2. **Source-based action blocking** — destructive actions only allowed from `userChat` source, never from OCR/paste/barcode

```dart
// In LLMService or AIChatService:
const _allowedActions = {
  'log_expense', 'update_expense', 'delete_expense', 'delete_by_date',
  'set_income', 'add_income', 'set_wallet_balance', 'transfer_wallet',
  'set_budget', 'add_goal', 'update_goal', 'delete_goal',
  'add_debt', 'update_debt', 'add_recurring', 'delete_recurring',
  'add_installment_plan', 'plan_salary_split', 'analyze_goal_feasibility',
  'suggest_debt_payoff', 'generate_monthly_plan', 'compare_periods',
  'explain_fhs_breakdown', 'project_savings_timeline', 'detect_subscriptions',
  'compute_contribution', 'suggest_idle_money', 'suggest_expense_cuts',
  'simulate_what_if', 'create_debt_payment_plan', 'split_expense',
  'set_spending_limit', 'add_insurance_policy', 'set_account_type',
};

const _destructiveActions = {
  'delete_expense', 'delete_by_date', 'delete_goal',
  'delete_recurring',
};

enum ActionSource { userChat, ocrText, clipboardPaste, barcodeScanner }

bool isAllowedAction(String name, ActionSource source) {
  if (!_allowedActions.contains(name)) return false; // reject unknown
  if (_destructiveActions.contains(name) && source != ActionSource.userChat) {
    return false; // destructive only from chat
  }
  return true;
}
```

**Effort:** ~3h  
**Conflict check:** None — purely additive guard. All existing flows continue working. The check runs after parsing, before executing.

---

#### 15C — First-Time AI Advice Disclaimer (Priority: 🟡 Before Final Defense)
**Gap identified from:** Appendix B AI Ethics Checklist (LLM Cheatsheet v6) + RA 11765 (Financial Products Consumer Protection Act)

**Problem:** The financial advice disclaimer is in `about_screen.dart` only. Most users never read About. When AI generates financial advice (salary split, debt payoff, investment suggestion), there's no user-facing disclosure that this is general information, not professional advice.

**Best practice** (Mint, YNAB, Cleo global standard): one-time in-app dialog on first financial_advice-tier response.

**What to add:**
- DB settings key `ai_advice_disclaimer_shown` — checked before first financial_advice response
- If not shown: brief `AlertDialog` with one "Got it" button
- Never shown again after first dismissal

**Dialog text:**
```
ℹ️ About AI Financial Advice

SmartSpend's AI provides general financial information for
educational purposes only.

It is NOT a licensed financial advisor, and its suggestions
are not personalized professional advice.

For major financial decisions, consult a licensed professional.
```

**Effort:** ~30min  
**Conflict check:** None. The existing `financial_advice` model tier routing already exists — just add the dialog trigger before it fires for the first time.

---

### Gap Category 2 — UX & Platform Gaps

---

#### 15D — GCash Share Intent Receiver (Priority: 🟠 Before Final Defense)
**Gap identified from:** Philippine market research — NielsenIQ 2026 "99% of Filipinos shopped online; only 52% use mobile banking apps actively" — reducing friction for GCash users is high value

**Problem:** GCash (and BPI, BDO, Maya) have a "Share" button on every transaction. This triggers Android's `ACTION_SEND` intent with the transaction text as a string. SmartSpend already handles clipboard paste, but **does not register as a share target**, so it never appears in the share sheet.

**What to add:**
1. Register `android.intent.action.SEND` in `AndroidManifest.xml` with `text/plain` MIME type
2. Handle the incoming intent in `MainActivity.kt` / Flutter — extract the text and open the import/parse flow

```xml
<!-- AndroidManifest.xml — inside the existing MainActivity <intent-filter> -->
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
</intent-filter>
```

```dart
// In main.dart or home_screen — handle the share intent:
// Use the 'receive_sharing_intent' package or platform channels
// When text arrives → pass to BankImportScreen or AI parse flow
```

**User experience:**
1. User opens GCash → views a transaction → taps Share
2. SmartSpend appears in the share sheet
3. User taps SmartSpend → app opens with the transaction text pre-filled in the import/parse screen
4. AI parses and confirms

**Effort:** ~3h (manifest change + intent handler + route to existing import flow)  
**Conflict check:** None. The clipboard paste flow already exists — this just adds a second entry point into the same flow. The `receive_sharing_intent` Flutter package handles the Android intent bridging. Uses existing `BankImportScreen` / paste-to-parse infrastructure.

> ⚠️ **No server needed.** This is a pure Android client feature — no backend, no new permissions beyond what the existing clipboard paste already does conceptually.

---

#### 15E — Android Home Screen Widget (Priority: 🟡 Post-Capstone, v3.x)
**Gap identified from:** User expectation benchmarking — all top-ranked finance apps (Mint, YNAB, Monarch, Simplifi) have home screen widgets. None of the Filipino competitors do.

**What it shows:**
```
┌────────────────────────┐
│  SmartSpend            │
│  This month: ₱8,450    │
│  Today: ₱240  │  FHS: 72│
└────────────────────────┘
```

**Implementation:** Flutter `home_widget` package (pub.dev) — writes widget data to shared preferences readable by a native Android widget.

**Effort:** ~1 day  
**Conflict check:** None — entirely separate from app. Widget reads from shared prefs that the app writes on load.

> **Why defer to post-capstone:** Requires native Android widget XML + Kotlin/Java, which adds complexity. Not needed for defense demo. High polish value for Play Store launch.

---

#### 15F — Subscription Cancellation Workflow (Priority: 🟡 Post-Capstone)
**Gap identified from:** Rocket Money Rowan analysis + PCMag 2026 top finance app features

**Problem:** SmartSpend detects recurring subscriptions (`detect_subscriptions` AI action) but has no "help me cancel this" flow. Users find forgotten subscriptions but then have no in-app path to act on them.

**What to add:**
- In the Subscriptions card on Home and in RecurringScreen: "Cancel?" button per subscription
- Tapping "Cancel?" opens AI chat pre-filled with: "Help me cancel [subscription name]. What steps do I take?"
- AI provides the cancellation steps (GCash GSubscriptions, Netflix account settings, etc.)
- User can also mark it "Cancelled" which removes it from subscriptions and keeps it in history

**Effort:** ~1 day  
**Conflict check:** Uses existing AI chat deep-link pattern and `delete_recurring` action. No new infrastructure needed — just new UI flow.

---

#### 15G — PSA FIES Spending Benchmarks ("vs. average Filipino") (Priority: 🟡 Post-Capstone)
**Gap identified from:** Competitor analysis — Finanzya has "96% auto-categorization accuracy" and peer benchmarking. Simplifi, Monarch benchmark against anonymized users.

**What it is:** Add a "vs. average" indicator to each spending category in Analytics:
```
Food:  ₱2,800/month
📊 NCR avg (FIES 2024): ₱3,100/month — you spend ₱300 less ✅
```

**Data source:** PSA Family Income and Expenditure Survey (FIES) 2024 — published publicly, free, by region (NCR, Luzon, Visayas, Mindanao). Average monthly household food expenditure, transport, bills, etc.

**Implementation:**
- Hardcode FIES 2024 regional averages as Dart constants (the data is published, doesn't change often)
- User sets their region in profile (already has `accountType` — extend to include region)
- Show delta in Analytics "By Category" view
- Refresh every FIES survey cycle (~every 3 years) — update by hardcoded constant

**Effort:** ~1 day (data lookup + UI additions)  
**Conflict check:** Purely additive to existing analytics. The FIES data is a one-time lookup, no API needed.

---

### Gap Category 3 — Security & Compliance Gaps

---

#### 15H — AI Confidence Explainability (Priority: 🟡 Before Final Defense — Quick)
**Gap identified from:** AI literacy framework (§B2, B4) — "transparency" principle requires users understand when AI is uncertain

**Problem:** Low-confidence AI-logged expenses show an orange dot on the tile (existing feature). But there's no explanation *why* the AI was uncertain, and no prompt to the user to verify.

**What to add:**
- When `confidence_score < 0.7`, show a small banner on the ExpenseTile detail (Edit screen):
  `"⚠️ AI logged this with low confidence — please verify the amount and category"`
- In `ai_screen.dart`, after logging a low-confidence batch, show:
  `"I wasn't fully sure about 2 items — tap to review"`

**Effort:** ~1h  
**Conflict check:** The `confidence_score` and `ai_generated` fields already exist on every expense. This is purely a display addition.

---

#### 15I — OFxPERA Framework Readiness Note (Priority: 🟢 Research / Documentation)
**Gap identified from:** BSP Open Finance PH / OFxPERA framework research

**What it is:** BSP Circular 1105 and the Open Finance Exchange for Personal Finance Management (OFxPERA) framework defines how licensed apps can receive standardized transaction data from banks/e-wallets with user consent — without SMS reading or screen scraping.

**SmartSpend is architecturally ready for this** because:
- It already has a SQLite schema for expenses with all required fields
- Firebase Auth provides the user identity layer
- The import/paste flow is the exact UX pattern OFxPERA would replace with an API call

**What to add to docs/backlog (not code):**
- Note in manuscript Ch.2 and Ch.4: "SmartSpend is designed to be OFxPERA-compatible — when BSP's Open Finance framework becomes available to app developers, the paste-to-import flow can be replaced with a secure API call to the user's consented bank data"
- Add `ofxpera_ready` to the About screen's tech stack listing
- This is a **documentation and positioning** item, not a code change

**Effort:** 30min (manuscript note + About screen addition)  
**Conflict check:** None — purely additive documentation.

---

### Gap Category 4 — Post-Capstone Roadmap Additions

---

#### 15J — FIRE Calculator (Priority: 🟢 Post-Capstone)
**Gap identified from:** Finanzya competitor analysis (top-ranked personal finance tool 2026)

**What it is:** Financial Independence, Retire Early calculator — the most requested feature missing from Filipino finance apps according to 2026 personal finance app reviews.

**What it shows:**
```
🔥 FIRE Calculator
Current savings: ₱45,000
Monthly savings rate: ₱2,200
Target: 25× annual expenses (4% rule)
Annual expenses: ₱96,000 → FIRE target: ₱2,400,000

At current rate: FIRE in ~32 years (age 52)
With 20% more savings/month: 26 years (age 46)
```

**Formula:** `FIRE Number = annual_expenses × 25` (the 4% safe withdrawal rule)

**Data needed:** Already in SmartSpend — monthly expenses, income, savings rate

**Effort:** ~1 day  
**Where:** Analytics screen, new "FIRE" card, shown only in income/wallet mode

---

#### 15K — Multi-Currency Expense Tracking for OFW (Priority: 🟢 Post-Capstone)
**Gap identified from:** Philippine market context — OFW (Overseas Filipino Workers) segment; GCash supports international remittance; NielsenIQ 2026 notes Filipino users want comprehensive financial tools

**Problem:** SmartSpend stores all amounts in PHP and converts for display only. A user who spent $150 abroad can't log it as USD — they have to manually convert first.

**What to add:**
- Optional currency selector on the Add Expense screen (default: current display currency)
- Store `original_amount` and `original_currency` alongside `amount` (PHP)
- Auto-convert at log time using the cached exchange rate
- Show in expense history: "₱8,400 (was $150)"

**Effort:** ~2 days (schema migration for two new fields + UI update)  
**Conflict check:** Non-breaking — `amount` remains PHP always. New fields are additive. FHS, budgets, analytics all continue using PHP `amount` unchanged.

---

#### 15L — GCash Deeplink / OFW Remittance Tracker (Priority: 🟢 Post-Capstone)
**Gap identified from:** GCash 41.5M monthly users (Bloomberg 2026); remittance is a major financial flow for Filipino families

**What it is:** A dedicated "Remittance" income category + tracking card showing:
- Incoming remittances logged (from family abroad)
- Running total this year
- Source currency + conversion rate at time of receipt

**Effort:** ~3h (new category + home card variant)  
**Where:** Income screen + Home wallet card

---

### Updated Priority Queue (Full, Including Part 15)

#### 🟠 Before Final Defense (code, sorted by effort asc)

| # | Feature | Effort | Phase |
|---|---------|--------|-------|
| 15C | First-time AI advice disclaimer | 30min | Security/compliance |
| 15H | AI confidence explainability banner | 1h | UX/trust |
| 15I | OFxPERA readiness note (docs only) | 30min | Documentation |
| 15A | Chat history token compression | 2h | Performance |
| 12B | Quick Income Log chip | 1h | UX |
| 12A | Spending Accountability Partner (weekly push) | 2h | Gamification |
| 12C | Expense Undo History card | 2h | UX |
| 15D | GCash Share Intent receiver | 3h | Platform |
| 15B | Action source restriction + allowlist | 3h | Security |
| 5A | Safe-to-Spend number | 1 day | Feature (BudgetPH gap) |
| 5B | Proactive AI nudge notifications | 2 days | Engagement |

**Moved out of this queue as already implemented:** `12F` / `13` Payday Countdown, `14` AI chat history export, `5C` auto-categorization evidence threshold, `5D` monthly recap alert, semester recurring interval, Analytics AI cache fallback.

#### 🟢 Post-Capstone v3.x (sorted by effort asc)

| # | Feature | Effort |
|---|---------|--------|
| 12D | AI Provider Health Dashboard | 2h |
| 12E | "Translate My Receipt" shortcut | 1h |
| 5D | "What Changed?" monthly notification | 2h |
| 5E | Expense Correction Suggestions | 1 day |
| 9 | True net worth historical chart | 3h |
| 15 | Photo gallery screen | 3h |
| 15L | Remittance tracker | 3h |
| 15G | PSA FIES spending benchmarks | 1 day |
| 3 | Monthly GitHub-style heatmap | 1 day |
| 15F | Subscription cancellation workflow | 1 day |
| 12G | AI Model Upgrade Pathway (Qwen routing) | 1 day |
| 15E | Android home screen widget | 1 day |
| 15J | FIRE calculator | 1 day |
| 15K | Multi-currency OFW tracking | 2 days |
| 4 | Notification Listener (GCash) | 2 days |
| SQLite encryption | 2 days | |
| Backend API proxy | 3 days | |
| App Check enforcement | 2h | |
| 5F | PSE/MP2/UITF investment tracker | 2 weeks |
| iOS version | 2 months | |
| Couple/family shared finances | 2 weeks | |
| Business mode AI actions | 1 week | |
| Mascot / personality layer | 1 week | |

---

### Conflict Check — Part 15 New Items

| Feature | Potential conflict | Resolution |
|---------|-------------------|-----------|
| 15A Token compression | Long-running AI chat context may lose details | Summary explicitly says "earlier conversation summary" — model treats it as context, not fact. Users can scroll history to see full prior turns. |
| 15B Action allowlist | If a new action is added to the AI system prompt but not to the Dart allowlist, it silently fails | **Fix:** Keep allowlist in a shared constant. When adding a new action to the AI system prompt, ALWAYS update the Dart allowlist simultaneously. Document this in the development checklist. |
| 15C AI advice disclaimer | Fires too frequently if user switches accounts or reinstalls | Key: `ai_advice_disclaimer_shown` stored per-account in Firestore (synced) so it follows the user across devices. |
| 15D Share intent receiver | Conflicts with clipboard paste if both fire for same transaction | Intent receiver route takes priority over clipboard nudge when the share source is detected. The clipboard nudge is suppressed if a share intent was just handled (add a 5-second debounce flag). |
| 15G PSA FIES benchmarks | FIES data is household-level, not individual | Clearly label: "Based on PSA FIES 2024 average household expenditure — individual spending varies." Divide household figure by 3.7 (average PH household size) to get per-person estimate. |
| 15H Confidence explainability | Showing "AI was uncertain" may erode trust | Frame positively: "I wasn't fully sure — please verify" rather than "Warning: AI may be wrong." Same information, lower anxiety. |
| 15K Multi-currency | Amount field is currently a single PHP double | `amount` remains PHP always. New fields `original_amount` (double) + `original_currency` (String) are additive. All existing code that reads `amount` is unaffected. Migration: `ALTER TABLE expenses ADD COLUMN original_amount REAL; ADD COLUMN original_currency TEXT;` — safe, non-breaking. |

---

*Part 15 added September 12, 2026.*
*Gap analysis cross-referenced from: LLM Engineering Cheatsheet v6 (§47, §49, §50, Appendix B),
NielsenIQ Philippines 2026 Consumer Report, BSP Open Finance/OFxPERA framework,
PSA FIES 2024, Competitor analysis (Finanzya, Rocket Money Rowan),
Cisco AI Literacy Framework (responsible AI principles).*
*Content paraphrased for compliance with licensing restrictions.*
