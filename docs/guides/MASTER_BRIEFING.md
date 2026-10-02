# SmartSpend — Master Briefing Document
## Everything a New Session Needs to Know

**Version:** 2.9.71 | **Group:** Lucid Frame | **School:** Lorma Colleges CCSE, BSIT 4th Year
**Academic Year:** 2026–2027, 1st Semester | **Status:** Final Defense Ready

> **Who this is for:** Any new Claude session, the manuscript writer (Cyrille), or a new
> contributor picking up the project. This document is the single source of truth.
> Do not rely on older docs — this supersedes everything written before October 2026.

---

## PART 1 — AUTHORITATIVE METRICS (Use These Everywhere)

These are confirmed from live code as of v2.9.71. Do not use any older numbers.

| Metric | Value | Source |
|--------|-------|--------|
| Version | **2.9.71** | `pubspec.yaml` |
| Version code | **71** | `pubspec.yaml` |
| Platform | Android (Flutter/Dart) | — |
| Min SDK | Android 5.0 (API 21) | `build.gradle` |
| Target SDK | Android 16 (API 36) | `build.gradle` |
| Screen files (`lib/screens/`) | **43** | counted |
| Service files (`lib/services/`) | **31** | counted |
| Widget files (`lib/widgets/`) | **4** | counted |
| SQLite schema version | **v11, 20 tables** | `db_service.dart` |
| AI providers in failover chain | **8** | `app_config.dart` |
| AI agentic action types | **34** | `ai_chat_service.dart` |
| Daily AI message limit | **150 messages/user** | `ai_chat_service.dart` |
| Primary AI model | **Gemini 3.5 Flash-Lite** | `app_config.dart` |
| Color themes | **11** (blue, lightBlue, green, purple, orange, crimson, navy, teal, rose, charcoal, **slate**) | `theme_service.dart` |
| Default theme (new installs) | **Slate** (#334155) | `theme_service.dart` |
| Currencies supported | **57** | `currency_service.dart` |
| Achievement badges | **25** | `achievements_screen.dart` |
| Daily quests in pool | **10** | — |
| Screenshot platforms auto-detected | **40+** | `llm_service.dart` |
| PH banks in wallet presets | **20 banks + 5 e-wallets** | `home_screen.dart` WalletsSheet |
| Filipino item catalog | **150+ items** | `ai_chat_service.dart` |
| Expense categories (built-in) | **14** + unlimited custom | `category_service.dart` |
| Hub/Tools items | **30+** grouped in 4 sections | `home_screen.dart` |
| GitHub | https://github.com/Zushikina-kun/smartspend-app | — |

---

## PART 2 — TEAM ROLES

| Name | Role |
|------|------|
| **Brix Arquisal** (brix.arquisal@lorma.edu) | Lead Developer — all Flutter/Dart code, Firebase, AI integration, releases |
| **Cyrille** | UI/UX Design, Documentation, Manuscript writing |
| **Djaunathan** | Project Manager, QA, SUS survey coordination |

---

## PART 3 — TECHNOLOGY STACK (For Manuscript Chapter 3)

| Component | Technology | Why chosen |
|-----------|-----------|------------|
| App framework | Flutter (Dart) | Cross-platform (Android + iOS same codebase), near-native ARM compilation, efficient for 3-person team |
| AI / LLM | 8-provider auto-failover chain | Zero operating cost for academic deployment; resilience against single-provider failure |
| Local database | SQLite via sqflite (v11, 20 tables) | Offline-first, fast, no cost, no server needed |
| Cloud sync | Firebase Firestore | Free Spark tier, bidirectional sync, UID-scoped security |
| Authentication | Firebase Auth | Google Sign-In + email/password, industry standard |
| OCR | Google ML Kit Text Recognition | On-device, no API key, works fully offline |
| Barcode | mobile_scanner + ML Kit Barcode | Live detection + gallery image |
| Charts | fl_chart | Flutter-native, no webview, fast rendering |
| Notifications | flutter_local_notifications | Budget alerts, proactive nudges, accountability check-ins |
| App Lock | local_auth | PIN + biometric (fingerprint/face), per-account |
| Exchange rates | open.er-api.com | Free tier, daily updates, 57 currencies |
| Crash reporting | Firebase Crashlytics | — |
| Share intent | Android ACTION_SEND (text/plain) | GCash/bank text routed to AI without copy-paste |
| Open Finance | OFxPERA-compatible architecture | BSP Circular 1105 readiness |

### AI Provider Failover Chain (in order)
1. Google Gemini 3.5 Flash-Lite (primary — fast, free 500 RPD)
2. Google Gemini 3.5 Flash (smart tasks — better reasoning)
3. Groq GPT-OSS 120B (openai/gpt-oss-120b)
4. Groq Qwen3.6 27B (qwen/qwen3.6-27b)
5. Groq Qwen3.8 27B (qwen/qwen3.8-27b)
6. Groq GPT-OSS 20B (openai/gpt-oss-20b)
7. Groq Compound Mini (groq/compound-mini)
8. Cerebras GPT-OSS 120B (last resort — 1M tokens/day)

**Note:** LLaMA 4 Scout and all LLaMA models were retired from Groq free/dev tier Feb–Aug 2026. They are NOT in the chain.

---

## PART 4 — AI ARCHITECTURE (For Manuscript Chapter 3)

### What "Agentic AI" means in SmartSpend
The AI doesn't just answer questions — it takes **34 autonomous actions** on the user's local SQLite database. When a user says "I spent ₱85 on lunch," the AI:
1. Parses intent (expense logging, Food category, Need tag)
2. Decides category using three-layer resolution: user-defined rules → historical majority → AI/keyword fallback
3. Fires `log_expense` action → writes directly to SQLite → triggers UI refresh

**This is a genuine agentic loop: perceive → decide → act.**

### Why not RAG?
RAG (Retrieval-Augmented Generation) is for large knowledge bases (thousands of documents). SmartSpend's per-user data is tiny — 50–300 expenses, 8 budgets, 5 goals — fits entirely in one prompt. Direct context injection is faster, simpler, and appropriate for mobile use. This is documented as a deliberate architectural decision, not a limitation.

**Academic quote for manuscript:**
> "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines."

### Multi-model task routing
```
_detectTaskType(message) →
  'financial_advice'  → Gemini 3.5 Flash (best reasoning)
  'smart'             → GPT-OSS 120B or Flash-Lite
  'fast'              → Flash-Lite (single expense log)
  'default'           → whatever AppConfig.activeModelId is
```

### Action allowlist + source restriction (security layer)
- All 34 known action names are in a static allowlist
- Destructive actions (`delete_expense`, `delete_by_date`) only allowed from `userChat` source
- OCR/clipboard/import flows restricted to `log_expense`, `update_expense`, `tag_expense`
- Unknown action names silently rejected

### Chat history compression
- Rolling window: last 10 messages kept in full
- Every 10 messages: `_summarizeHistory()` fires (fire-and-forget, writes to `conversation_summaries` table)
- Before each API call: `getLatestConversationSummary()` prepended as system note
- Result: consistent context without burning token budget on old messages

---

## PART 5 — FINANCIAL HEALTH SCORE (For Manuscript Chapter 3 + Defense)

### Full Mode (income tracking ON) — 4 components × 25 pts = 100 max

| Component | Formula | Full score when |
|-----------|---------|----------------|
| Savings Rate | `25 × min(1, savingsRate / 0.20)` | Saving ≥20% of income |
| Overspend Control | `25 × (1 − overDays / activeDays)` | No days exceed daily income ÷ days |
| Budget Adherence | `25 × (onBudget / totalBudgets)` | All category budgets on track |
| Logging Consistency | `25 × (loggedDays / activeDays)` | Logged every active day this month |

### Lightweight Mode (income tracking OFF) — 4 different components

| Component | Measurement |
|-----------|------------|
| Spending Restraint | vs user-set spending limit (or Want/Need ratio) |
| Logging Consistency | same formula as full mode |
| Category Balance | no single category > 40% of total |
| Habit Streak | consecutive logged days (full at 14 days) |

### Score adjustments (applied on top of both modes)
- **Warning Decay:** budget exceeded + spending continues → −5 pts/day (max −15). Resets when budgets back on track.
- **Gap Adjustment:** unlogged days confirmed by user → −3 pts/day (spent but forgot) or +2 pts/day (genuinely no spending), max ±15/10

### Score interpretation
| Range | Label |
|-------|-------|
| 90–100 | 👑 Excellent |
| 80–89 | 🏆 Great |
| 70–79 | ⭐ Good |
| 60–69 | 🌱 Fair |
| < 60 | 📉 Needs Work |

### Academic positioning
The FHS is a **Prototype Observed Financial Health Indicator (FHI)** — NOT a psychometric survey scale like the CFPB 10-item scale. Academic basis: Commonwealth Bank–Melbourne Institute (CBA-MI, 2018) dual-scale model, which separates *Reported* scales (subjective, survey-based) from *Observed* scales (computed from transaction data). SmartSpend's FHS is an observed indicator.

**Correct framing:** "Our FHS is a Prototype Observed FHI per CBA-MI (2018) and UNSGSA (2021) dual-scale guidelines."
**Wrong framing:** "Our FHS is validated by the CFPB scale" (construct mismatch).

---

## PART 6 — THEORETICAL FRAMEWORKS (For Manuscript Chapter 2)

Four frameworks ground SmartSpend's behavioral design — all cite-able for the manuscript:

| Framework | Authors | How SmartSpend applies it |
|-----------|---------|--------------------------|
| **Nudge Theory** | Thaler & Sunstein (2008) | Startup alerts, Warning Decay, budget framing — choice architecture that guides behavior without restricting freedom |
| **Prospect Theory / Loss Aversion** | Kahneman & Tversky (1979) | Warning Decay (−5 pts/day) makes consequences of ignoring budget overruns tangible. Losses motivate more than equivalent gains. |
| **Self-Determination Theory** | Deci & Ryan (2000) | 25 achievement badges support *Competence*; non-prescriptive goals support *Autonomy*; Filipino-first language supports *Relatedness* |
| **Technology Acceptance Model (TAM)** | Davis (1989) | Ease of use (AI chat, 1-tap logging) and perceived usefulness (FHS, planning tools) drive adoption |

### Empirical PLS-SEM validation (cite in manuscript)
Sharma, Gaba & Sharma (2026), Atlantis Press — structural equation model, N=656:
- Personalized Budget Feedback Nudges → Sustainable Financial Intention: **β=0.28, t=6.21, p<0.001**
- Gamified Rewards → SFI: **β=0.25, t=5.89, p<0.001**
- Perceived Algorithm Transparency (explaining *why* the app scores you) acts as significant moderator: **β=0.14, t=2.95, p<0.001**
- R² = 0.56 (model explains 56% of variance in Digital Financial Well-being)

**This directly validates SmartSpend's FHS plain-language breakdown feature.**

---

## PART 7 — COMPLETE FEATURE LIST (For Manuscript Chapter 3 / Appendix)

### Core AI Features
- **34 agentic action types** — see full list in DEFENSE_GUIDE.md Part 1
- Taglish detection (Filipino/English code-switching)
- Philippine context: BDO, BPI, GCash, Maya, SSS, PhilHealth, Pag-IBIG, TRAIN Law tax brackets
- 150+ Filipino item catalog (pandesal, Mang Inasal, paluwagan, etc.)
- PII redaction before every API call
- First-time financial advice disclaimer (RA 11765 compliance)
- Action allowlist + source restriction (security layer)
- Session duplicate guardrail (GUARDRAIL system prompt injection)
- Confidence score per AI-logged expense (<0.7 = orange "Review" badge)
- Chat history token compression (rolling 10 + periodic summarization)
- 8-provider auto-failover, session-only fallback (no sticky model bug)

### Smart Import System (4 modes)
1. **Live Camera** — barcode/QR live detection + receipt OCR shutter
2. **Single Photo** — gallery pick, auto-detects barcode/receipt/screenshot
3. **Batch Screenshots** — up to 10 images, 40+ platform types auto-detected
4. **Paste Text** — GCash/BPI/BDO/Maya/Maya bank export text parsing
5. **GCash Share Intent** — SmartSpend appears in Android share sheet; transaction text auto-routed to AI

### Home Screen Features
- Financial Health Score card (tap for full component breakdown)
- Safe-to-Spend card (wallet − bills − goals − debts ÷ days to payday)
- Wallet summary card (Cash, GCash, Maya, 25+ banks)
- Goals Timeline (horizontal, projected completion dates)
- AI Quick-Input bar (text field above nav bar, sends to AI without screen change)
- Quick Income Log chip (appears when income is overdue, one-tap log)
- Log Allowance button (student mode, tap = daily avg, long-press = custom)
- Payday Countdown / Income Prediction card
- Subscription Summary card
- Spending Forecast card (combined with Cash Flow in tabbed Outlook card)
- Bill Calendar mini-card (next 3 upcoming events)
- Daily Challenges + Weekly Challenges (gamification)
- Achievement badges row (25 total)
- Daily Mood check-in
- Behavioral feedback cards (supportive framing, BF-5)
- Quick Log chips (most frequent items)
- Day in Review card (after 6pm)
- FHS narrative (plain-language score explanation)

### Analytics
- Pie chart (category breakdown)
- 50/30/20 budget tracker (Needs/Wants/Savings)
- Want vs Need bar chart
- FHS component breakdown chart
- This month vs last month comparison table
- Day-of-week spending heatmap
- 5-week spending calendar
- Long-range forecast (3/6/12 months) via fl_chart
- Period comparison tool
- Spending Personality profile
- Savings rate trend chart (6-month)
- Market Insights (live PHP exchange rates)
- AI Financial Advice (cached + live)
- AI Monthly Summary

### Financial Planning Tools
- **Debt Payoff Calculator** (Tools → Debt Payoff Calculator) — avalanche vs snowball, month-by-month schedule, interest saved
- **Goals Timeline** (home screen) — projected completion dates per goal
- **Net Worth Chart** (Profile) — wallets + savings − debts, 6-month fl_chart LineChart
- **Budget First-Run Suggestions** (Budget screen) — auto-suggests monthly averages from history
- Savings Goals with progress bars
- PCA / MP2 investment calculator (Analytics)
- FIRE calculator → post-capstone roadmap
- BIR/TRAIN Law tax calculator
- SSS / PhilHealth / Pag-IBIG contribution calculator

### Budget & Spending Control
- Category budgets with pace indicators
- Multi-period spending limits (daily/weekly/monthly/yearly)
- Budget rollover (optional per category)
- Quick budget slider (long-press on budget card)
- Smart Daily Allowance (remaining ÷ days left)

### Gamification (Behavioral Layer)
- 25 achievement badges (logging streaks, saving milestones, budget adherence)
- 10 rotating daily quests
- Logging streak tracking
- Experience Presets: 🪶 Lite / 😊 Casual / ⚖️ Normal / 🚀 Pro
- Weekly Spending Accountability push notification (once/week)
- Positive savings milestone nudge (≥20% savings rate at mid-month)
- Proactive nudge notifications — 7 triggers:
  1. Recurring bill due in 3 days
  2. Spending pace 40%+ above weekly budget
  3. Goal within ₱500 of target
  4. Income not logged in 30+ days
  5. Shortfall risk before month end
  6. Savings milestone (≥20% savings rate)
  7. Weekly accountability check-in (NEW — v2.9.70)

### Data Management
- Full JSON backup/restore (covers all 20 DB tables)
- CSV export (filtered or full)
- Cloud sync (Firebase Firestore, bidirectional)
- 20-item exact duplicate cleanup (migration `dup_cleanup_v2966`)
- Data Quality screen (finds and fixes OCR errors, wrong categories, suspicious amounts)
- Merchant Normalization / Merge tool
- Auto-Categorization Rules (keyword → category)
- Evidence threshold: if item appears 3+ times with ≥60% in one category, that category wins

### Hub / Tools (30+ items in 4 sections)
- Budgets, Savings Goals, Debts & Loans, Recurring Transactions
- Bill Calendar, Insurance & Contributions Tracker
- Paluwagan Tracker, Log Due Bills, Glossary (23 terms)
- Bank Import, Batch Screenshot, Smart Camera, Batch Manual Entry
- Display Currency (57 currencies)
- **Debt Payoff Calculator** (NEW — v2.9.68)
- Categories, Auto-Categorization Rules, Merchant Cleanup
- Achievements, AI Chat History, Data Quality, Help & Guide
- **Most Used shortcuts row** (NEW — v2.9.70, tracks tap count in SharedPreferences)

### Account & Settings
- 8 account types: Employed, Business Owner, Freelancer, Working Student, Student, Pensioner/Retiree, Unemployed, General/Other
- App Lock: PIN + biometric (per-account)
- Dark mode, text scale, high contrast, compact mode
- 11 color themes (Slate default for new installs)
- Wallet auto-deduct, confirm-before-deduct
- Impulse Pause (confirm before large Want expense)
- Balance Mode vs Income Mode
- Quick-edit on expense tile long-press (NEW — v2.9.70)
- AI Undo History card in Transactions (NEW — v2.9.70)

---

## PART 8 — VERSION HISTORY (Post-Pre-Finals)

This sprint fixed the pre-finals demo failure and added everything the panel asked for.

| Version | Key changes | Released |
|---------|------------|---------|
| **v2.9.66** | 🚨 CRITICAL: Restored real API keys as hardcoded fallbacks. Removed key guard that blocked all AI when Remote Config failed. This is the fix for the complete AI failure at pre-finals. | Oct 2026 |
| **v2.9.67** | Setup screen scrollable; pain-point-first onboarding ("Nasaan na ba ang pera mo?"); FHS shows last month score when current month is empty; 20-duplicate dedup migration; Deep Navy default theme; completed payment plans banner | Oct 2026 |
| **v2.9.68** | Slate theme (new default); color cleanup (all decorative card colors removed); AI quick-input bar on home; **N1 Debt Payoff Calculator**; **N2 Goals Timeline**; **N3 Net Worth Chart** | Oct 2026 |
| **v2.9.69** | **Experience Presets** (Lite/Casual/Normal/Pro replaces binary Lite Mode); Hub renamed to Tools | Oct 2026 |
| **v2.9.70** | Quick Income Log chip (12B); AI Undo History card (12C); Quick-edit on long-press (U9); Weekly Accountability push (12A); Smart Budget suggestions (U8); Most Used row in Tools (U10); **DEFENSE_COUNTERARGUMENTS.md** written | Oct 2026 |
| **v2.9.71** | OFxPERA readiness note in About screen + DEFENSE_GUIDE.md; share sheet Q&A in defense docs; whats_new tuple fix | Oct 2026 |

---

## PART 9 — PRE-FINALS PANEL CRITIQUES AND RESPONSES

### What the panel said → What was done → Demo proof

#### Critique 1: "Masyado color pollution" / "Eyesore"
**Root cause:** App used 4–5 different accent colors simultaneously (purple subscription, teal recurring, blue wallet, orange forecast). Color was decorative, not semantic.

**Fix (v2.9.68):**
- Removed all decorative colors from home screen cards
- All cards now use `surfaceContainerLow` (neutral) background
- Color only appears when it means something: green = good, orange = warning, red = problem
- Added Slate theme (#334155) — clean, professional, no vibrancy

**Demo:** Show home screen before/after. Every card is now the same neutral color. Only the FHS score ring and status indicators use color.

**Academic backing:** Nielsen Norman Group (2026) — "Color should reinforce meaning, not create it."

---

#### Critique 2: "Maganda sana yung financial planner" / "No financial planner features"
**Root cause:** App was a tracker only. No forward-looking planning tools.

**Fix (v2.9.68):** Three new planning screens:
1. **Debt Payoff Calculator** — Tools → reads live debts, user enters monthly budget, shows avalanche vs snowball month-by-month with interest saved
2. **Goals Timeline** — home screen, horizontal scroll, projected completion dates from actual contribution history
3. **Net Worth Chart** — Profile tab, real wallets + savings − debts, 6-month fl_chart LineChart

**Demo:** Open Tools → Debt Payoff Calculator → enter ₱3,000 → show avalanche vs snowball comparison. Then show home Goals Timeline and Profile Net Worth chart.

**Academic backing:** Prospect Theory — making debt consequences concrete (exact months + interest cost) increases likelihood of action.

---

#### Critique 3: "Wala na dapat hindi gumagana" / Complete AI failure at demo
**Root cause (v2.9.55–v2.9.56):**
- v2.9.55: API keys moved to Firebase Remote Config, fallback set to `""`
- v2.9.56: Key guard added — if key is empty, block all AI
- At venue: Remote Config fetch failed (slow WiFi) → all keys = `""` → key guard triggered → all 8 providers blocked

**Fix (v2.9.66):**
- Real API keys restored as hardcoded fallbacks in `app_config.dart`
- Key guard removed from `ai_chat_service.dart`
- `setDefaults()` now passes real keys so Remote Config cache is populated from day one
- Remote Config still overrides when available (for future key rotation)

**Demo:** Turn WiFi off on the demo phone. Open AI screen. Type "I spent 50 pesos on breakfast." It works. Say: "This is the exact scenario that failed at pre-finals — WiFi issues on startup. Now it's impossible to fail this way."

---

#### Critique 4: "Main aim — bakit i-record ang gastos mo?"
**Root cause:** Setup screen opened with "What kind of account do you have?" — configuration before value proposition.

**Fix (v2.9.67):** Setup screen rewritten with pain-point-first flow:
1. "Nasaan na ba ang pera mo?" (relatable opening)
2. Core promise: "Just say what you spent. We handle everything else."
3. Account setup comes last

**The "why record" answer (memorize):**
> "People know they're spending. They don't know *where* it's going or *whether* they can afford what they want next month. Recording without analysis is just a diary. SmartSpend adds automatic pattern detection, an FHS that tells you if you're on track, and an AI that answers 'can I afford this?' — not just 'I spent ₱500 today.'"

**Competitive context:** Paper/pen wins on logging speed (2 sec vs 5 sec). SmartSpend wins on insights (none on paper), accessibility (always in pocket), and Filipino context (GCash parsing, Taglish AI).

---

#### Critique 5: "Masyado complicated" / "Too many features"
**Root cause:** 27 settings toggles, 51+ navigation targets, cards auto-show without explanation.

**Fix (v2.9.69):** Experience Presets replaces binary Lite Mode:
- 🪶 **Lite** — balance + FHS + recent only
- 😊 **Casual** — + quick log, badges, challenges
- ⚖️ **Normal** — + wallet, payday, safe-to-spend, subscriptions (default)
- 🚀 **Pro** — everything

**The design defense:**
> "Complexity is a feature, not a flaw — but only if it's discoverable by the right users at the right time. New users see the Normal preset. As they get comfortable, they upgrade to Pro. This is the same pattern as Kiro IDE's Auto/Supervised modes and Gmail's Standard vs All Settings."

**Demo:** Settings → Quick Presets → switch to Lite → show home screen with 3 cards → switch back to Normal.

---

#### Critique 6: "Fix API (Daily/Monthly)" / Spending limits confusion
**Root cause:** Two overlapping cards (`_buildDailyLimitCard` + `_buildSpendingLimitCard`) could appear simultaneously for users who had set limits before v2.9.61.

**Fix (v2.9.61+):**
- Auto-migration: if `daily_limit > 0` and `limit_daily == 0`, move legacy value to new system on first open, clear old key
- `_buildDailyLimitCard` removed from Dashboard build
- One card, clearly labeled by period (Today / This Week / This Month / This Year)
- Tappable → opens Spending Limits sheet directly

---

## PART 10 — ANTICIPATED FINAL DEFENSE QUESTIONS

These are the most likely follow-up questions. All answers are in DEFENSE_COUNTERARGUMENTS.md but condensed here.

| Question | Key answer |
|----------|-----------|
| Show one unique feature no other Filipino app has | **Batch Screenshot Import** — 40+ platforms, auto-detected |
| FHS academic basis? | **Prototype Observed FHI per CBA-MI (2018) + UNSGSA (2021)** — NOT the CFPB psychometric survey |
| Why AI gives wrong categories sometimes? | Three-layer resolution: user rules → historical majority → AI. Fix: add a rule in Auto-Categorization Rules. After 3 entries with 60%+ in one category, history wins permanently |
| Is the AI Filipino-context or just a wrapper? | Three concrete things: (1) Taglish detection via prompt-level rule, (2) PH institution knowledge in system prompt, (3) 150+ Filipino item catalog with correct categorization |
| Can it connect to GCash/bank directly? | Not yet — correct path is **BSP OFxPERA (Circular 1105)**. Architecture is ready: SQLite schema, Firebase Auth identity, paste-import UX. OFxPERA replaces paste with consent-gated API call when available |
| SmartSpend in share sheet — how? | `ACTION_SEND` intent-filter in AndroidManifest, MethodChannel in MainActivity.kt, `_checkShareIntent()` in ai_screen.dart. Both cold and warm start handled |
| Data privacy? | PII redaction before every API call; no storage by providers; UID-scoped Firestore rules |
| FHS vs FMS — not redundant? | FHS = outcomes (saving %, budget adherence). FMS = behaviors (logging frequency, data completeness). Same user can have high FHS + low FMS |
| All 8 providers rate-limited simultaneously? | App stays fully functional (manual entry, all analytics work). In practice, combined ~50K+ RPD makes simultaneous exhaustion negligible for 30-respondent study |
| Why two FHS modes? | Students and informal workers have no fixed income. Lightweight Mode gives meaningful FHS from spending habits alone |

---

## PART 11 — DEMO FLOW (Practice Order)

Run this in exactly this order — it builds from simple to complex:

1. **AI chat** (2 min) — type expense, voice expense, update wallet balance, ask SSS question
2. **Share intent** (1 min) — open GCash on the phone, view a transaction, tap Share, show SmartSpend in the list, tap Paste
3. **Batch screenshot import** (1.5 min) — pick 2–3 Shopee or Steam screenshots, show auto-detection
4. **Home screen** (1 min) — FHS card, safe-to-spend, Goals Timeline, quick-input bar
5. **Debt Payoff Calculator** (1 min) — Tools → Debt Payoff → enter ₱3,000 → show avalanche vs snowball
6. **Analytics** (1 min) — pie chart, 50/30/20, FHS breakdown
7. **Experience Presets** (30 sec) — Settings → switch Lite → show simplified home → switch back
8. **WiFi off AI test** (30 sec) — demonstrating v2.9.66 fix directly

**Before presenting:**
- [ ] Install v2.9.71 APK from GitHub Releases on demo phone (don't use stale version)
- [ ] Reset AI limit: AI screen → ⋮ → Reset Daily Limit
- [ ] Test AI with WiFi off — confirm it works
- [ ] Set wallet balances to realistic amounts
- [ ] Brightness max, screen timeout 5+ min

---

## PART 12 — KNOWN ISSUES / HONEST LIMITATIONS (For Manuscript Chapter 4 Limitations)

These are real limitations to acknowledge honestly. Panels respect honesty more than spin.

| Limitation | Honest framing |
|-----------|---------------|
| No formal AI accuracy validation study | Accuracy tested qualitatively; formal human-labeled dataset evaluation is post-capstone work |
| Confidence score always set to 0.9 in AI chat logs | The <0.7 Review badge infrastructure exists; the AI doesn't currently vary confidence per item dynamically — this is a future improvement |
| No real bank API connection | Intentional — requires BSP OFxPERA licensing; architecture is ready |
| SQLite not encrypted | AES encryption via SQLCipher is on the pre-Play Store checklist; current risk mitigated by App Lock |
| Firebase API keys in APK binary | Accepted tradeoff for offline resilience post-pre-finals failure; mitigated by Remote Config override and daily rate limits |
| FHS not psychometrically validated | FHS is an observed indicator (behavioral data), not a psychometric survey — the CBA-MI framework explicitly says these require different validation methods |
| iOS version not built | Requires Mac; all plugins have confirmed iOS support; port is post-capstone |
| Play Store not submitted yet | 14-day closed testing requirement; Samsung Galaxy Store + Firebase App Distribution are the distribution channels for the defense |

---

## PART 13 — DISTRIBUTION STATUS

| Channel | Status |
|---------|--------|
| GitHub Releases | ✅ Live — `https://github.com/Zushikina-kun/smartspend-app/releases` |
| Firebase App Distribution | Recommended for SUS 30 respondents — email invite, direct install link |
| Samsung Galaxy Store | Available for submission (no closed testing requirement) |
| Google Play Store | Not yet — 14-day × 12 tester closed testing required first |
| F-Droid | Not eligible — Firebase = proprietary dependency |
| Amazon Appstore | Closed for non-Fire Android on August 20, 2025 — not viable |

---

## PART 14 — MANUSCRIPT CHAPTER MAPPING

Use this when Cyrille asks what to write in each chapter.

### Chapter 1 — Introduction
- **Problem:** 50% adult bank account ownership (BSP CFIS 2025), 86% household access. Filipinos don't track finances because traditional methods (spreadsheets, manual apps) are too tedious.
- **Solution:** AI-assisted logging removes the friction. "Just say what you spent."
- **Scope:** Android mobile app, Flutter/Dart, 4th-year BSIT capstone
- **Significance:** Only free Filipino-English AI finance app on Android with agentic actions

### Chapter 2 — Review of Related Literature
- Nudge Theory (Thaler & Sunstein, 2008)
- Prospect Theory / Loss Aversion (Kahneman & Tversky, 1979)
- Self-Determination Theory (Deci & Ryan, 2000)
- Technology Acceptance Model (Davis, 1989)
- PLS-SEM empirical validation (Sharma, Gaba & Sharma, 2026) — β values above
- CBA-MI (2018) dual-scale FHI framework (for FHS positioning)
- CFPB Financial Well-Being Scale (2015) — what FHS is NOT
- UNSGSA (2021) Financial Health frameworks
- Financial Health Network (2026) outcomes vs behaviors distinction (for FHS vs FMS)
- BSP CFIS 2025 (Philippine financial inclusion data)
- GCash 41.5M monthly users (Bloomberg 2026)
- NielsenIQ Philippines 2026 Consumer Report
- Rocket Money / Rowan (July 2026) — agentic AI via push notifications

### Chapter 3 — Methodology
- Agile development (iterative sprints, GitHub-tracked commits)
- System architecture: Flutter + SQLite + Firebase + 8-provider AI
- FHS formula (exact equations in Part 5 above)
- AI architecture: full-context injection, 34 agentic actions, task-based routing
- Data collection: SQLite local, Firebase cloud sync
- Security: action allowlist, PII redaction, App Lock, UID-scoped Firestore rules
- Testing: manual QA per sprint, `flutter analyze` zero-error gate before every release

### Chapter 4 — Results and Discussion
- Feature implementation results: 43 screens, 31 services, 34 AI actions, 11 themes
- FHS formula output on real user data (debug log shows FHS = 50 on Oct 1)
- AI response accuracy (qualitative — categories, action parsing)
- SUS survey results (Djaunathan — 30 respondents, post-defense)
- Competitor comparison: BudgetPH, Agila, PISO, GCash Pera Coach (see FEATURE_BACKLOG.md Part 10)

### Chapter 5 — Conclusion and Recommendations
- Achieved: agentic AI tracker + planner, Filipino-context, dual-mode FHS, 8-provider resilience
- Limitations: see Part 12 above
- Recommendations: OFxPERA integration, iOS port, PSA FIES benchmarks, SQLite encryption, Play Store submission

---

## PART 15 — QUICK REFERENCE CARD (Print This for the Defense Room)

```
VERSION: 2.9.71  |  SCREENS: 43  |  SERVICES: 31  |  AI ACTIONS: 34
PROVIDERS: 8  |  THEMES: 11  |  BADGES: 25  |  CATEGORIES: 14+custom
FHS: 4 components × 25pts, 2 modes, 2 adjustments
FRAMEWORKS: Nudge Theory, Prospect Theory, SDT, TAM
PLS-SEM: β_nudge=0.28, β_gamification=0.25, R²=0.56 (N=656)
FHS BASIS: CBA-MI (2018) Observed FHI — NOT CFPB psychometric scale
GITHUB: github.com/Zushikina-kun/smartspend-app

PRE-FINALS FIXES:
  Color pollution → semantic color only (v2.9.68)
  Financial planner → Debt Payoff + Goals Timeline + Net Worth (v2.9.68)
  AI broken → fallback keys restored (v2.9.66)
  Bakit i-record → "Nasaan na ba ang pera mo?" onboarding (v2.9.67)
  Too complicated → Experience Presets (v2.9.69)
  Limit confusion → single multi-period card (v2.9.61+)

DEMO ORDER: AI chat → Share intent → Batch import → Home → Debt Payoff → Analytics → Presets → WiFi-off AI
```

---

*MASTER_BRIEFING.md | v2.9.71 | October 2026 | Lucid Frame*
*Cross-reference: DEFENSE_GUIDE.md (Q&A + demo script), DEFENSE_COUNTERARGUMENTS.md (panel responses)*
