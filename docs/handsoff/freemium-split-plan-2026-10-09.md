# SmartSpend — Free vs Pro Feature Split
## Design Spec & Implementation Plan
**Date:** October 9, 2026 | **Target version:** v4.0.0  
**Status:** Planning only — capstone defense first, then implement

---

## Core Philosophy

> Free tier solves job #1: "know where my money went."  
> Pro tier solves job #2: "take control of where it's going — and stay there."

Research: only 2–5% of freemium finance app users ever upgrade (Arbisoft). The fix is not aggressive gating — it's making the free tier genuinely useful (word-of-mouth volume) while gating *depth*, *automation*, and *history* — not *core function*.

**Rules:**
1. Never gate logging, viewing, or deleting data
2. Never gate the FHS score or its explanation
3. Never gate AI logging entirely — gate *volume* and *import methods*
4. Gate depth, automation, and history — not core function
5. Every Pro feature has a locked teaser in Free tier (drives upgrade awareness)
6. Offer one-time lifetime purchase alongside subscription (Filipino market preference)

---

## Free Tier — "SmartSpend Free"

### What's included

| Category | Free includes |
|----------|--------------|
| **Logging** | Manual entry, Edit, Delete, Transactions list, Search, Category filter, Period filter (Today/Week/Month only) |
| **AI** | Text chat — 30 messages/day, basic expense queries |
| **Budgets** | Up to 5 categories |
| **Goals** | Up to 3 |
| **Recurring** | Up to 3 entries |
| **Debts** | Up to 2 |
| **Wallets** | 1 (Cash on Hand only) |
| **Analytics** | Pie chart (current month), FHS current score + explanation, 50/30/20 overview |
| **Import** | Manual text only |
| **Export** | CSV — current month only |
| **Chat History** | Last 7 days only |
| **Themes** | 3 (Emerald, Slate, Light) |
| **Badges** | First 10 |
| **Daily quests** | 3/day |
| **Sync** | ✅ Basic cloud sync — expenses + budgets + goals (free user data is safe) |
| **Backup** | None (full backup/restore → Pro) |

---

## Pro Tier — "SmartSpend Pro"

Everything in Free, plus:

### AI — Full Power
- 150 messages/day (vs 30)
- Voice input
- Screenshot import (single + batch, 40+ platforms)
- Bank/GCash paste import
- Barcode scanner
- AI session summary card (✅/⚠️/❌)
- Re-log helper sheet
- AI financial advice tier
- AI monthly summary in Analytics
- AI financial advice in Analytics

### Analytics — Full Depth
- All period filters (All Time, This Year, Payday Cycle, Pick Month, Custom Range, Logged Today)
- Monthly bar chart (6-month trend)
- Daily spending trend (30 days)
- Day-of-week heatmap
- FHS score history (30-day sparkline)
- FHS component history with drill-down
- 50/30/20 with custom category assignment
- Period comparison (any two months)
- Mood vs spending correlation
- Spending forecast (3/6/12-month)
- Small purchases clustering
- DTI, Emergency Fund, Milestones cards
- Market Insights (live exchange rates + tips)
- Analytics Quick Jump anchors

### Wallets & Income
- Multiple wallets (GCash, BDO, Maya, 30+ banks — unlimited)
- Wallet change history
- Wallet-to-wallet transfers
- Safe-to-Spend card on home screen
- Auto-deduct from wallet on expense log
- Recurring income entries
- Windfall income flag
- Income history

### Tracking — Unlimited
- Unlimited budget categories
- Unlimited savings goals
- Unlimited recurring entries
- Unlimited debts

### Filipino Power Features
- Paluwagan tracker
- Insurance & Contributions (SSS, PhilHealth, Pag-IBIG, private)
- Installment Plans (HomeCredit, ShopeePay Later, BillEase)
- Bill Calendar (unified timeline)
- Log Due Bills screen
- PCA Calculator (Peso Cost Averaging)
- Debt Payoff Calculator (avalanche vs snowball)
- BIR Tax Breakdown
- Bank Comparison screen

### Data & Customization
- Unlimited custom categories
- Auto-categorization rules
- Data Quality screen
- Merchant Merge screen
- Batch manual entry
- Full CSV export (all time, all filters)
- **Full backup & restore** (free gets no backup)
- **Full cloud sync** — all tables: wallets, income, installments, chat history, insurance, paluwagan, category rules (free gets expenses + budgets + goals only)
- Full Chat History (all sessions, wayback)

### UI & Gamification
- All 11 themes
- All 25 achievement badges
- Full 10 daily quest pool
- Weekly + Monthly challenges
- Financial Health Certificate (shareable)
- App lock — biometric
- Compact mode
- Experience Presets (Pro mode)

---

## Limits Table

| Resource | Free | Pro |
|----------|------|-----|
| AI messages/day | 30 | 150 |
| Budget categories | 5 | Unlimited |
| Savings goals | 3 | Unlimited |
| Recurring entries | 3 | Unlimited |
| Debts | 2 | Unlimited |
| Wallets | 1 | Unlimited |
| Import methods | Manual + text AI only | All 7 |
| Analytics period | This Month | All periods |
| Analytics charts | Pie + FHS | Everything |
| CSV export | Current month | All time |
| Chat History | Last 7 days | All sessions |
| Themes | 3 | 11 |
| Badges | 10 | 25 |
| Cloud sync | ✅ Basic (expenses + budgets + goals) | ✅ Full (all tables, wallets, income, chat) |
| Backup/restore | ❌ | ✅ |

---

## Pricing

| Plan | Price | Net to dev (after Play 15% cut) | Notes |
|------|-------|----------------------------------|-------|
| Pro Monthly | **₱59/month** | ~₱50/user/mo | Lowest friction. One Jollibee Value Meal. |
| Pro Yearly | **₱299/year** | ~₱254/user/yr | **Main plan.** ₱0.82/day. 7-day free trial. 58% off vs monthly×12 (₱708). |
| Pro Lifetime | **₱799 one-time** | ~₱679/user | Breaks even at ~13.5 months. Best for students, one-time PH preference. |

### Market context (researched Oct 9, 2026)

| App | Type | PH Price | Has AI? | Local LLM? | Screenshot import? |
|-----|------|----------|---------|------------|-------------------|
| **Agila** (PH, top rated 4.7★) | Free + cosmetics (₱29/item) | Free | Basic chat | ❌ | ❌ |
| **PISO Budget** (PH indie) | Completely free, no subscription | Free | ❌ | ❌ | ❌ |
| **Tarsi** (PH indie, #1 Paid PH Mar 2026) | One-time paid ~₱300–₱350 | ~₱300–₱350 | ❌ | ❌ | ❌ |
| **BunnyWise** (PH, investment focus) | Waitlist — not launched | TBD | ❌ | ❌ | ❌ |
| **Monarch Money** (US) | Subscription | ~₱5,800/year | Limited | ❌ | ❌ |
| **YNAB** (US) | Subscription | ~₱6,300/year | Limited | ❌ | ❌ |
| **ChatGPT Plus** | Subscription | ₱999/month | ✅ General | ❌ | ❌ |
| **SmartSpend Pro** | Freemium | ₱299/year | ✅ **34 actions** | ✅ **Yes** | ✅ **40+ platforms** |

### Why these prices work

**₱59/month** — One Jollibee Value Meal. The PH market context is important here: both Agila and PISO are completely free. We charge because we have features they simply don't have. ₱59 is low enough that the question becomes "why not try it?" not "can I afford this?"

**₱299/year** — Less than ₱1/day. Framed as "₱0.82/day — less than your tricycle fare." 58% off vs paying monthly (₱708/year). The anchor against ChatGPT Plus (₱999/month) makes this look like a steal: you get smarter AI specifically for your finances at 1/40th the cost of general AI.

**₱799 lifetime** — This is the strategically important one for a student market. A student who starts using SmartSpend in 1st year college and uses it through graduation (4 years) pays ₱799 for ~₱2,832 worth of yearly subscriptions (4 × ₱799 if they bought yearly each year — wait, actually 4 × ₱299 = ₱1,196, so lifetime saves ₱397 over 4 years). The psychological value is "I own it forever, no decision fatigue, no renewal anxiety."

### The differentiator argument (why we can charge when Agila and PISO don't)

These features exist in SmartSpend Pro and **nowhere else in any Filipino finance app**:

1. **Local LLM Private Mode** — Run AI on your own PC/Mac. Zero cloud. Your data never leaves your home network. No other finance app in the world has this as a feature.
2. **34 agentic AI actions** — Agila has basic expense logging via chat. SmartSpend AI sets budgets, creates payment plans, splits expenses, analyzes debt strategy, and more — 34 distinct database operations, all natural language.
3. **Batch screenshot import (40+ platforms)** — Shopee, Lazada, GCash, BPI, BDO, Grab, Steam, Codashop. Nobody else does this.
4. **Financial Health Score with 4-component breakdown** — Not just a number. Explains exactly why your score changed and what to fix.
5. **9-provider AI fallback** — The AI never goes down. Gemini → Flash → GPT-OSS → Qwen → Compound → Cerebras. Always finds a working model.

**Paywall copy that uses this:**
> "SmartSpend Pro includes Local AI mode — run Peso entirely on your own computer. Zero cloud. Zero data sharing. ₱0.82/day."

> "Import your entire GCash history in 30 seconds. Screenshot to expense — 40+ platforms. Only in SmartSpend Pro."

### Play Store fee reality
Google Play charges 15% for first $1M/year (99% of developers). RevenueCat is free until $2,500/month tracked revenue (~₱140K/month). At ₱299/year you'd need ~2,350 yearly Pro subscribers to hit RevenueCat's paid tier — an excellent problem to have.

### Upgrade messaging per plan
- Monthly: "Try Pro for ₱59 — one Jollibee meal gets you the full AI finance experience"
- Yearly: "Get Pro for ₱0.82/day — includes Local AI, screenshot import, and unlimited everything (7-day free trial)"
- Lifetime: "Own SmartSpend Pro forever — ₱799, one payment, yours for life including all future features"

---

## Implementation Architecture

### Current state (v3.x)
`ProService` exists in `lib/services/pro_service.dart`. It:
- Returns `isPro = true` for everyone — **no gates are active**
- Contains the full `ProFeature` enum documenting every gateable feature
- Has a compile-time `APP_FLAVOR` flag (dev/prod) via `--dart-define`
- Dev builds (`APP_FLAVOR=dev`) always return `isPro=true` — never blocked
- Prod builds (`APP_FLAVOR=prod`) also return `isPro=true` in v3.x — gates not implemented yet
- `ProService.init()` is called in `main.dart` — ready for RevenueCat in v4.0

**Bottom line: the app today works identically to before.** ProService is infrastructure only.

### Package: `purchases_flutter` (RevenueCat)
```yaml
purchases_flutter: ^8.0.0
```
- Free until $2,500/month tracked revenue (~₱140,000)
- Handles purchase, restore, entitlement verification
- Firebase Extension: mirrors to Firestore automatically
- No backend server required

### Why RevenueCat over raw `in_app_purchase`
RevenueCat handles receipt verification, entitlement management, and subscription status automatically. Raw `in_app_purchase` requires a backend server for secure receipt verification — RevenueCat eliminates that. Free until $2.5K/month MTR.

### Architecture
```
ProService          — singleton, checks entitlement, caches in SharedPreferences
ProFeature enum     — every gateable feature listed
ProGate widget      — wraps any widget: shows child if Pro, locked teaser if not
ProPaywallScreen    — paywall UI with 3 plan options + restore purchase
```

### ProService (sketch)
```dart
class ProService {
  static bool _isPro = false;
  static bool get isPro => _isPro;

  static Future<void> init() async {
    // Fast path: cached value (no delay)
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('is_pro_cached') ?? false;
    // Async: verify with RevenueCat, update cache
    try {
      final info = await Purchases.getCustomerInfo();
      _isPro = info.entitlements.active.containsKey('pro');
      await prefs.setBool('is_pro_cached', _isPro);
    } catch (_) {} // grace period on network failure
  }

  static bool canUse(ProFeature feature) =>
      _isPro || _freeFeatures.contains(feature);
}
```

---

## Implementation Phases

| Phase | Version | Work |
|-------|---------|------|
| 1 | v4.0.0 | `ProService` + `ProFeature` + `ProGate` + `ProPaywallScreen` — infrastructure only |
| 2 | v4.0.1 | Gate AI import features (voice, screenshot, batch, barcode, bank paste) |
| 3 | v4.0.2 | Gate analytics depth (charts, history, period filters) |
| 4 | v4.0.3 | Gate wallets, tracking limits (budgets/goals/recurring/debts caps) |
| 5 | v4.0.4 | Gate power tools (paluwagan, insurance, installments, PCA, debt payoff) |
| 6 | v4.0.5 | Gate data tools (cloud sync, backup, full export, categories, rules) |
| 7 | v4.0.6 | Gate gamification, themes, UI power features |

Deploy one phase at a time, measure conversion, adjust gates before the next.

---

## Natural Upgrade Triggers (conversion moments)

1. **Week 2** — tries to add a 6th budget → paywall
2. **Week 3** — tries to paste GCash history → paywall
3. **Month 1** — wants to compare months in analytics → paywall
4. **Month 1** — hits 30 AI messages → paywall
5. **Month 1** — tries to add a 2nd wallet → paywall
6. **Month 2** — wants to see FHS trend chart → paywall

Each paywall: shows what they were trying to do + concrete Pro benefit + ₱99/mo CTA + dismiss option. Never blocks the app.

---

## Play Store Prerequisites

1. Google Play Console account — $25 one-time ✅ pending
2. App signed with release keystore ✅ done
3. 3 in-app products created in Play Console: `smartspend_pro_monthly`, `smartspend_pro_yearly`, `smartspend_pro_lifetime`
4. App in Internal/Closed Testing (required to test purchases)
5. RevenueCat project created at revenuecat.com — link Play Console products
6. Firebase App Check → switch debug → Play Integrity

**Important: Finish capstone defense before implementing any of this.**

---

## Anti-patterns to Avoid

| Don't | Why |
|-------|-----|
| Gate the FHS score | #1 differentiator — kills word-of-mouth |
| Gate manual expense logging | Core function — users leave immediately |
| Show ads | Destroys trust for a finance app |
| Force hard "trial expired" wall | PH users distrust forced subscriptions |
| Make free tier unusable | Kills volume + word-of-mouth |
| Gate AI entirely | It's why users choose SmartSpend |
| Per-feature microtransactions | Too complex for PH market |

---

*Sources: Arbisoft freemium conversion research, vibecoder.me paywall patterns, stackmatix.com freemium-to-paid conversion guide, RevenueCat pricing documentation, emacintl.com finance app monetization analysis. Content paraphrased for licensing compliance.*
