# SmartSpend — Demo, Marketing & Monetization Masterplan
**Version:** v3.0.1 | **Date:** October 9, 2026
**Audience:** Lucid Frame team — for capstone defense, website, social media, and future app growth

---

## Part 1 — Demo Account (v3.0.1 — shipped)

### What's seeded in the demo dataset

| Screen / Feature | What's there now |
|-----------------|-----------------|
| **Home** | FHS score 80/100, ₱9,869 spent this month, Safe-to-Spend card, AI Insights, 3 active goals on timeline |
| **Profile** | Brix Angelo S. Directo, Lorma email, avatar (green initials placeholder), San Fernando La Union |
| **Wallets** | Cash ₱547 · GCash ₱1,312.50 · BDO ₱4,250 — all with change history |
| **Transactions** | 35 expenses across 3 months, 9 categories, all sortable/groupable |
| **Analytics** | Pie chart (9 slices), 3-month bar comparison, daily trend, mood correlation, 50/30/20, FHS 30-day sparkline |
| **Budgets** | 9 budgets — Food ₱2,000 · Bills ₱5,000 · School ₱4,500 etc |
| **Savings Goals** | Laptop ₱12k/₱35k · Emergency Fund ₱3.5k/₱10k · Graduation Trip ₱1.5k/₱8k |
| **Recurring** | 4 entries — Tuition, Spotify, HomeCredit payment, Monthly Allowance |
| **Debts** | 3 entries — Kuya Mark owe ₱1,000 remaining · Trisha lent ₱200 · Djaunathan owe ₱350 |
| **Income** | 3 months allowance + ₱1,500 part-time freelance this month |
| **Installment Plans** | HomeCredit Poco F8 Ultra 3/18 mo · ShopeePay Later keyboard 1/3 mo |
| **Insurance & Contributions** | SSS · PhilHealth · Pag-IBIG MP2 · Sun Life student term |
| **Paluwagan** | Barkada ₱500 × 6 members (round 3) · Family ₱1,000 × 10 members |
| **Score History** | 30-day trend chart (68→85 arc) |
| **Mood Log** | 14 days with realistic student notes |
| **Chat History** | Demo session with 5 messages |
| **Category Rules** | 25 auto-categorization rules |
| **Settings** | account_type: student, payday_date: 1, income_wallet_mode: on, 50/30/20 categories mapped |

### Reset flow
- **Profile → Load Demo Data** — loads full seed
- **Profile → Reset to Demo Defaults** (orange) — wipes all 18 tables + reloads fresh
- Data persists across app restarts (normal SQLite — not cleared on exit)

---

## Part 2 — Screenshot & Video Guide

### Screen priority order

| Priority | Screen | Caption |
|----------|--------|---------|
| 🥇 1 | Home screen (full) | "Your finances at a glance" |
| 🥇 2 | AI Chat logging | "Just tell Peso what you spent" |
| 🥇 3 | Analytics pie + 50/30/20 | "Know exactly where your money goes" |
| 🥇 4 | Batch screenshot import | "Screenshot your receipts — AI does the rest" |
| 🥈 5 | Transactions grouped | "Sort. Group. Filter. Your way." |
| 🥈 6 | FHS score breakdown | "A score that actually explains itself" |
| 🥈 7 | Savings goals timeline | "Set goals. Track progress." |
| 🥈 8 | Paluwagan + Debts | "Built for how Filipinos actually manage money" |

### Screenshot specs (Google Play)
- Resolution: 1080 × 1920 px minimum (portrait), PNG or JPEG
- Minimum: 2; recommended: 8
- Device frame: optional — use Mockuphone.com (free)
- Text overlay: 1–2 lines, large font, bottom third
- Tools: Canva (free), Figma (free), Adobe Express (free)

### Demo video structure (60–90 seconds)
```
0:00–0:08  Cold open: phone → SmartSpend home screen reveal
0:08–0:18  AI logging: type 3 expenses → ✅ session summary card
0:18–0:30  Screenshot import: Shopee receipts → AI parses → review
0:30–0:42  Analytics: Quick Jump chips → pie chart → 50/30/20
0:42–0:52  FHS tap → 4-component breakdown dialog
0:52–1:00  End card: "Free on Android" + QR code → GitHub Releases
```

Recording tool: Android built-in screen recorder.
Editing: CapCut (free, mobile) or DaVinci Resolve (free, desktop).

---

## Part 3 — Google Play Store Listing

**Short description (80 chars):**
```
AI-powered personal finance for Filipinos — free, offline, Taglish-ready
```

**Keywords:** budget tracker, expense tracker, personal finance Philippines, GCash tracker, financial health score, Filipino money app, paluwagan, AI finance, peso tracker

**Category:** Finance | **Content rating:** Everyone

**Full description draft:** see the artifact in Kiro or in docs/handsoff/.

---

## Part 4 — Website Updates (GitHub Pages)

**Current:** https://zushikina-kun.github.io/smartspend-app/

### What to add
1. **"Download v3.0.1"** hero button → GitHub Releases link
2. **8 screenshots** in HTML carousel (Swiper.js — free)
3. **Comparison table** — SmartSpend vs BudgetPH vs Agila vs PISO
4. **60-second demo video** — YouTube embed
5. **Ko-fi / GCash QR** "Buy me a coffee" link
6. **Press kit** — screenshots ZIP, app icon, logo SVG

---

## Part 5 — Social Media Strategy

| Platform | Priority | Content | Frequency |
|----------|----------|---------|-----------|
| **Facebook** | 🥇 Primary | Short reels (30–60s), carousels | 3×/week |
| **TikTok** | 🥇 Primary | Screen demo with text overlay | 2–3×/week |
| **Instagram** | 🥈 Secondary | Carousel screenshots, Reels | 2×/week |
| **Reddit** | 🥈 Launch | r/PersonalFinancePhilippines, r/Philippines | Announce |

### First 4 weeks content
- Week 1: "We built a FREE AI finance app for Filipinos" — launch announcement
- Week 2: AI logging demo — "Just tell Peso what you spent"
- Week 3: Screenshot import — "I imported my Shopee history in 30 seconds"
- Week 4: Social proof — SUS score, student testimonials

### Hashtags
```
#SmartSpend #PersonalFinancePH #BudgetTracker #PinoyFinance
#GCashTracker #AIFinance #FlutterPH #IndieDevPH #LucidFrame
#FinancialLiteracyPH #BuildInPublic #PagiingMayaman
```

---

## Part 6 — Monetization Roadmap

### Context
- Philippines = **3rd fastest-growing finance app market** in SEA (MSN/AppsFlyer 2026)
- 33% of PH apps use in-app ads; 13% are paid; finance apps need **trust first**
- **Tarsi** (Filipino finance app) hit #1 Paid PH Play Store March 2026 — market exists
- Strategy: **build audience at v3.x, monetize at v4.0**

### Tiers (target: v4.0)

| Tier | Price | Includes |
|------|-------|---------|
| **Free** (forever) | ₱0 | All current features, 150 AI messages/day |
| **SmartSpend Pro** | ₱99/mo or ₱799/year | Unlimited AI · Cloud backup priority · Premium themes · Gemini Flash (not Lite) |
| **SmartSpend Teams** | ₱299/mo (5 users) | Shared budgets · Family expense view · Group goals |

### Now (before Play Store)
- Ko-fi / GCash QR "Buy me a coffee" on website — zero friction, zero setup
- GitHub Sponsors — positions Brix as an indie dev publicly
- Capstone showcase → department feature → organic reach

### Don'ts until v4.0
- No ads (kills UX and trust)
- No paywalled core features (alienates student market)
- No per-message microtransactions (too complex)

---

## Part 7 — Quick Action List (this week)

| Priority | Action | Owner | Effort |
|----------|--------|-------|--------|
| 🔴 P0 | Install v3.0.1, run demo script, verify all screens have data | Brix | 30 min |
| 🔴 P0 | Take 8 screenshots using Android Screen Record | Brix | 1 hour |
| 🟠 P1 | Make screenshot overlays in Canva | Cyrille | 2 hours |
| 🟠 P1 | Record 60-second demo video | Brix | 1 hour |
| 🟠 P1 | Add screenshots + video to website | Cyrille | 2 hours |
| 🟡 P2 | Post launch on Facebook + TikTok | All | 30 min |
| 🟡 P2 | Post in r/PersonalFinancePhilippines | Brix | 15 min |
| 🟡 P2 | Add Ko-fi link to website + README | Brix | 15 min |
| 🟢 P3 | Google Play Console account ($25) | Brix | 1-day wait |
| 🟢 P3 | Fill Play Store listing using metadata above | Cyrille | 1 hour |

---

*Sources consulted: AppsFlyer Philippines App Marketing Report 2026, Statista PH Finance App Rankings, MSN Philippines Finance App Market, ASOMobile Screenshot Guide, GummiCube Finance App Listings Guide, dev.to Filipino Indie Developer Report (March 2026). Content paraphrased for licensing compliance.*
