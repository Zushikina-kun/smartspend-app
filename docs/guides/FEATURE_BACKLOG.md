# SmartSpend — Master Feature Backlog & Planning
**Version:** 2.9.41 | **Updated:** September 12, 2026
**Group:** Lucid Frame | **Academic Year:** 2026–2027, 1st Semester

> **Single consolidated planning document.** Fuses inputs from:
> `PROJECT_STATUS.md`, `FEATURE_DOCS.md`, `BENCHMARK.md`, `CAPSTONE_REFERENCE.md`,
> `DEFENSE_GUIDE.md`, `SYSTEM_OVERVIEW.md`, `SmartSpend_Ideas_Reference.pdf`,
> the 15-item recommendation list, and live online research (September 2026).
>
> **Nothing marked ❌ or 🔧 has been implemented.** Planning and documentation only.
>
> *Sources consulted: PSA OpenSTAT, BSP Monetary Policy Reports, World Bank Commodity Markets,
> PCMag 2026, Rocket Money Rowan press release, BudgetPH, PISO Budget Tracker, BunnyWise,
> Google Play SMS policy docs, OpenAI ChatGPT Finance announcement.*
> *Content from external sources paraphrased for compliance with licensing restrictions.*

---

## Part 0 — Authoritative Build Numbers (v2.9.41)

Use these everywhere. Many docs are stale.

| Metric | v2.9.41 value |
|--------|--------------|
| Version string | 2.9.41 |
| Platform | Android (Flutter/Dart) |
| Min SDK | Android 5.0 (API 21) |
| Target SDK | Android 16 (API 36) |
| Build size | ~45 MB arm64-v8a, split, obfuscated |
| SQLite schema | v11, 20 tables |
| AI providers in fallback chain | **8** (not 5 or 6) |
| Primary AI model | **Gemini 3.5 Flash-Lite** (not 3.1 — migrated Sep 10, 2026) |
| Agentic actions | **34** (not 31) |
| Input modalities | 7 |
| Screens | 37+ |
| Services | 26+ |
| Achievement badges | **25** (23 + No-Spend Day + No-Spend Streak) |
| Daily quests pool | 10 |
| Batch screenshot platforms | 40+ |
| Filipino item catalog | 150+ items |
| Log choice sheet options | 7 |
| Currencies | 57 |
| Hub tiles | 22 |
| PH banks in DB | 20 banks + 5 e-wallets |
| Daily AI message limit | **150** (raised from 60) |
| Paluwagan | ✅ **Implemented** v2.9.35 (update manuscript) |

---

## Part 1 — The 15 Recommended Features: Updated Status

### ✅ Already Fully Built

| # | Feature | Where |
|---|---------|-------|
| 5 | Budget rollover | Budget screen ↪ toggle; auto-applied monthly |
| 6 | Tags analytics "By Tag" | Analytics; tag filter in Transactions; in CSV export |
| 7 | "Afford This?" calculator | Home → Log Expense sheet |
| 8 | Offline AI insight cache | Home AI Insights (shows cached with date on quota error) |
| 9 | Net Worth tracker | Profile screen; wallet-based; FHS sparkline |
| 12 | Filtered export | Transactions → ⬇ exports current filtered list |

---

### 🔧 Partially Built — Needs Completion

| # | Feature | What exists | What's still missing | Priority |
|---|---------|-------------|---------------------|----------|
| 1 | Smart Recurring Detector | Quarterly/yearly/semi-annual detection (400-day lookback); insurance keyword → Bills | (a) Semester interval ~120–135 days; (b) "Add to Insurance Tracker?" UI prompt on insurance-keyword detection | 🟡 |
| 3 | Spending heatmap | Day-of-week 7-column heatmap + 5-week calendar in Analytics | Full monthly GitHub-style per-date grid (28–31 cells, date-specific coloring) | 🟡 |
| 4 | SMS/notification listener | Clipboard paste-to-parse; share-intent detection; clipboard nudge banner | **⚠️ READ_SMS is blocked by Google Play policy** — apps must be the default SMS handler. This is NOT feasible for a finance tracker on Play Store. Reframe as "GCash notification deep-link" via Android Notification Listener instead. | 🔴 Policy issue — redesign needed |
| 8 | Offline AI cache — Analytics | Home insight cached with date | Analytics "AI Advice" and "Monthly Summary" don't fall back to cache | 🔥 Quick |
| 9 | Net Worth trend chart | FHS sparkline as proxy | True net-worth-over-time chart using periodic snapshots (not FHS score proxy) | 🟡 |
| 15 | Expense photo gallery | photo_path field; inline thumbnail on tiles | Dedicated gallery GridView in Hub → "Receipts" | 🟢 |

**⚠️ READ_SMS redesign note:** Google Play requires apps to be the *default SMS handler* before accessing READ_SMS — a policy in place since 2019 and tightened further in 2026. A personal finance tracker will never qualify. The correct alternative is `NotificationListenerService` (requires user grant in Accessibility settings) which can read notification text without being the SMS handler. This is the approach used by apps like Walnut (India) and similar trackers. It still requires user opt-in but is Play Store compliant.

---

### ❌ Not Built At All

| # | Feature | Priority | Est. effort |
|---|---------|----------|-------------|
| 2 | "Day in Review" end-of-day card | 🔥 High | ~2h |
| 10 | Savings rate trend chart (6-month line) | 🔥 High | ~2h |
| 11 | Quick budget slider (long-press) | 🔥 High | ~1h |
| 13 | Income prediction / Payday countdown card | 🟡 | ~3h |
| 14 | AI chat history export | 🟡 | ~3h |

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

---

### 🔧 Partially Built (from docs + research)

| Feature | What exists | What's missing | Priority |
|---------|-------------|----------------|----------|
| **15th/30th payday cycle budget** | `payday_date` in settings; Payday Cycle filter in Analytics | **"Safe-to-spend" number** — subtract all upcoming bills, goals, debt payments from wallet balance for the current pay period; show "You have ₱X safe to spend until [payday]". This is BudgetPH's core differentiator. | 🔥 High |
| Profile photo cross-device sync | Stored as local file path only | Firebase Storage upload (requires Blaze plan) | 🟢 Low |
| SQLite encryption | Plain SQLite | sqlcipher integration | 🟢 Post-capstone |
| Backend API proxy | Key in APK (mitigated by rate limit) | Cloud Functions proxy | 🟡 Pre–Play Store |
| App Check enforcement | Monitoring mode | Enforcement mode (before Play Store) | 🟡 Pre–Play Store |
| Auto-categorization intelligence | Keyword-match rules + user-defined rules | YNAB-style "two-of-three evidence" before changing a category (YNAB June 2026 update) — prevents AI miscategorization from overriding a known category | 🟡 Medium |
| Notification Listener (replaces READ_SMS) | Clipboard paste; share-intent | `NotificationListenerService` — reads GCash/bank notification text non-destructively; user grants access in Android Accessibility settings; Play Store compliant | 🟡 Medium |

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

### 🔴 This Week — Before Pre-Final Defense (code)

| Feature | Effort | Notes |
|---------|--------|-------|
| Verify Day-in-Review card works after 6pm | 30 min | PROJECT_STATUS says added v2.9.36; demo script references it; confirm in actual runtime |
| Savings rate trend chart (#10) | ~2h | 6-month % line chart; fl_chart in use; data in DB |
| Quick budget slider (#11) | ~1h | Long-press → Slider; fixed ₱ mode only |
| Analytics AI cache fallback (#8 partial) | ~1h | Mirror what Home screen already does |

### 🟠 Post-Defense Priority 1 (before final defense)

| Feature | Effort |
|---------|--------|
| Safe-to-Spend number (5A) | ~1 day |
| 15th/30th payday envelope budget reset | ~1 day |
| Income prediction / Payday countdown (#13) | ~3h |
| AI chat history export (#14) | ~3h |
| Proactive AI nudge notifications (5B) | ~2 days |
| Auto-categorization evidence threshold (5C) | ~1 day |
| Semester interval in recurring detector (#1a) | ~1h |
| Insurance Tracker auto-link (#1b) | ~2h |
| "What Changed?" monthly delta notification (5D) | ~2h |
| Notification Listener for GCash (replaces SMS plan) | ~2 days |

### 🟢 Post-Capstone Roadmap (v3.x)

| Feature | Effort | Notes |
|---------|--------|-------|
| Price Intelligence / Price Pulse (Part 4) | ~2 weeks | PSA API + 5 sub-features |
| Monthly GitHub-style heatmap calendar (#3) | ~1 day | Full per-date grid |
| Photo gallery screen (#15) | ~3h | Hub → Receipts GridView |
| Expense Correction Suggestions (5E) | ~1 day | Data quality sweep |
| True net worth historical chart (#9) | ~3h | Snapshot-based, not FHS proxy |
| Custom date range in export (#12 partial) | ~2h | Date-range picker in Transactions |
| PSE/MP2/UITF investment tracker (5F) | ~2 weeks | After BunnyWise launches — assess overlap |
| ScanReviewScreen rename | 30 min | Code hygiene |
| SQLite encryption | ~2 days | sqlcipher |
| Backend API proxy | ~3 days | Cloud Functions |
| App Check enforcement | ~2h | Before Play Store |
| iOS / web version | ~2 months | Post-capstone only |
| Business mode AI actions | ~1 week | Invoice tracking |
| Couple/family shared finances | ~2 weeks | Multi-account architecture |
| Mascot / personality (vs Sentimo KBoy) | ~1 week | Fun differentiator |
| Profile photo cross-device sync | ~1 day | Requires Firebase Blaze |

---

## Part 9 — Feature Conflict & Contradiction Check

This section documents potential contradictions between new planned features and existing implemented ones.

| New Feature | Potential Conflict | Resolution |
|-------------|-------------------|-----------|
| Safe-to-Spend (5A) | May confuse users vs existing Cash Flow card and Net Worth card | Cash Flow = month view; Net Worth = all-time; Safe-to-Spend = current pay cycle. Show Safe-to-Spend only in income/wallet mode, only when payday_date is set. Add a clear label distinguishing it from other cards. |
| Proactive nudge notifications (5B) | Startup alerts already fire on app open for budget/overdue/score-drop | Startup alerts = reactive (something already happened). Proactive nudges = forward-looking (something is coming). Keep them in separate notification channels. Add "Proactive Nudges" toggle in App Settings separate from existing alert toggles. |
| Auto-categorization evidence threshold (5C) | User-defined rules in the Auto-Categorization Rules screen | Priority order: (1) User-defined rules (highest), (2) Historical majority category (new), (3) AI suggestion. This never overrides user rules — only adds a safety net against AI drift. |
| Notification Listener (revised #4) | Clipboard nudge banner already exists | These are different: clipboard = user manually copied text; notification listener = automatic detection of incoming app notifications. Both can coexist. If notification listener is active, the clipboard banner can be suppressed for the same transaction. |
| Quick budget slider (#11) | % of income budget mode | Slider only activates for fixed ₱ budgets. % mode uses existing dialog. Long-press on a % budget shows a tooltip explaining why the slider is not shown. |
| Savings rate trend chart (#10) | FHS score history line chart already in Analytics | These are different metrics on different scales. FHS is 0–100; savings rate % is 0–100% but means something different. They can coexist in Analytics. Consider putting savings rate chart inside the FHS section as a drill-down. |
| Monthly heatmap calendar (#3) | Existing 5-week heatmap and day-of-week heatmap | The 5-week version shows actual calendar weeks. The day-of-week version shows aggregate averages. A full monthly GitHub-style view would replace/upgrade the 5-week version, not conflict with the day-of-week aggregate. |
| Price Pulse / PSA API (Part 4) | Exchange rate fetching already uses a similar caching pattern | Price cache uses the same `settings` table pattern as exchange rates. Just add a new set of keys. No structural conflict. |
| "What Changed?" notification (5D) | Rollover logic runs at month start and already fires alerts | This notification is a single summary push, not an interactive alert. Use the existing `rollover_applied_month` detection as the trigger but fire a notification instead of (or in addition to) the rollover calculation. |
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
