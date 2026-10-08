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
| **Sync** | Local only (no cloud sync) |
| **Backup** | None |

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
- Backup & restore
- Cloud sync (Firestore)
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
| Cloud sync | ❌ | ✅ |
| Backup/restore | ❌ | ✅ |

---

## Pricing

| Plan | Price | Notes |
|------|-------|-------|
| Pro Monthly | ₱99/month | Low barrier to try |
| Pro Yearly | ₱799/year | Save 33% — push as default. 7-day free trial. |
| Pro Lifetime | ₱1,499 one-time | Best for PH market — no recurring friction |

Comparison: YNAB charges ~₱6,000/year. SmartSpend Pro at ₱799/year is dramatically cheaper with more PH-specific features.

---

## Implementation Architecture

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
