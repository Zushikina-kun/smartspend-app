# SmartSpend — Kiro → Claude Handoff (Session 3 — Final Pre-Defense)
**Compiled:** September 12, 2026
**Covers:** Everything from Session 2 handoff onwards — doc fixes, gap analysis, new backlog items, pre-defense prep
**Previous handoffs:**
- `kiro-to-claude-handoff-2026-09-12.md` — v2.9.38–v2.9.42 (AI pipeline, FHS changes, RA 10173)
- `kiro-to-claude-handoff-2026-09-12-v2.md` — v2.9.43–v2.9.47 (Phase 1 UI polish, full-app soft-UI)
**Purpose:** Give Claude the complete, up-to-date picture for manuscript revisions.
**Read all three handoffs in order.** This is the final authoritative state as of pre-defense week.

---

## CRITICAL: Read This First

**All reference docs have been updated this session.** The following files are now accurate to v2.9.47 and should be treated as ground truth:

- `docs/reference/FEATURE_DOCS.md` — updated Sep 12, 2026
- `docs/reference/CAPSTONE_REFERENCE.md` — updated Sep 12, 2026
- `docs/reference/BENCHMARK.md` — updated Sep 12, 2026
- `docs/guides/DEFENSE_GUIDE.md` — updated Sep 12, 2026
- `docs/guides/FEATURE_BACKLOG.md` — updated Sep 12, 2026 (Parts 11–15 added)
- `docs/status/PROJECT_STATUS.md` — updated Sep 12, 2026

**Do NOT use older numbers from memory.** Always reference these files.

---

## Part 1 — Authoritative Numbers (v2.9.47, September 12, 2026)

These supersede everything in previous handoffs. Final values for the manuscript:

| Field | Value | Notes |
|-------|-------|-------|
| Version | **2.9.47** | pubspec + kAppVersion both confirmed |
| APK size | **45.1 MB** arm64-v8a | Previous docs said 44.7 — that was stale |
| AI providers | **8** | Full fallover chain — see below |
| Primary model | **Gemini 3.5 Flash-Lite** | Migrated from 3.1 Sep 10, 2026 |
| Agentic actions | **34** | Not 31 — was fixed in v2.9.19 |
| Achievement badges | **25** | Not 23 — No-Spend Day + No-Spend Streak added v2.9.42 |
| Daily AI limit | **150 messages/day** | Not 60 — raised in v2.9.25 |
| Color themes | **10** | Not 5 — 5 new added v2.9.45 |
| Hub tiles | **26** | Not 22 — expanded v2.9.44 |
| Quick Access grid shortcuts | **9** | Trimmed from 10 in v2.9.46 |
| SQLite schema | v11, **20 tables** | |
| Screens | **37** | |
| Currencies | **57** | |
| Batch screenshot platforms | **40+** | |
| Filipino item catalog | **150+ items** | |
| Log choice sheet options | **7** | |
| PH banks in DB | 20 banks + 5 e-wallets | |
| Daily quests pool | **10** | |
| Paluwagan | **✅ Implemented v2.9.35** | Remove from Future Work in ALL manuscript sections |

### Full Fallover Chain (8 providers — confirmed working Sep 2026)

```
1. gemini-3.5-flash-lite (Google, 500 RPD)
2. gemini-3.5-flash (Google, 250 RPD)
3. openai/gpt-oss-120b (Groq, 1000 RPD)
4. qwen/qwen3.6-27b (Groq, 1000 RPD)
5. qwen/qwen3.8-27b (Groq, 1000 RPD)
6. openai/gpt-oss-20b (Groq, 1000 RPD)
7. groq/compound-mini (Groq, 250 RPD)
8. openai/gpt-oss-120b (Cerebras, 1M tokens/day)
```

**⚠️ NEVER include these in the manuscript fallover chain — they return 404:**
LLaMA 4 Scout, LLaMA 3.3 70B, LLaMA 3.1 8B — all retired from Groq free/dev tier Feb–Aug 2026.

---

## Part 2 — What Was Fixed in Reference Docs This Session

All stale values that have been corrected. When revising the manuscript, these fixes have already been applied to the reference docs — but the manuscript Google Doc still needs these changes:

| What was stale | Correct value | Files fixed |
|---------------|---------------|-------------|
| Badge count "23" | **25** | FEATURE_DOCS, CAPSTONE_REFERENCE (SDT + competitor table), BENCHMARK (main matrix + BudgetPH table), DEFENSE_GUIDE (key numbers + Q&A) |
| Build size "44.7 MB" | **45.1 MB** | DEFENSE_GUIDE, FEATURE_DOCS |
| Color themes "5" | **10** | CAPSTONE_REFERENCE (Settings section) |
| CAPSTONE_REFERENCE blurb "v2.9.41" | **v2.9.47** | CAPSTONE_REFERENCE line 9 |
| FEATURE_DOCS header "v2.9.41" | **v2.9.47** | FEATURE_DOCS header |
| BENCHMARK gamification row "✅ 23" | **✅ 25** | BENCHMARK main matrix |
| BENCHMARK BudgetPH paluwagan "❌ Not implemented" | **✅ Implemented v2.9.35** | BENCHMARK BudgetPH detail table |
| DEFENSE_GUIDE broken `$125` row | **Achievement badges \| 25 (23 original + No-Spend Day + No-Spend Streak)** | DEFENSE_GUIDE key numbers table |
| BudgetPH Q&A "23 badges" | **25 badges** | DEFENSE_GUIDE |
| Paluwagan in Future Work | **Implemented v2.9.35** | All manuscript sections — move to Implemented |

---

## Part 3 — Manuscript Changes Needed (Cyrille's Task List)

This is the complete, consolidated list for the manuscript Google Doc. Apply every item:

### Chapter 1 — Background/Introduction
- [ ] Update version to **v2.9.47** in all version mentions
- [ ] Update badge count **23 → 25** in all mentions
- [ ] Update daily limit **60 → 150** in all mentions
- [ ] Update agentic action count **31 → 34** in all mentions
- [ ] Update APK size **44.7 → 45.1 MB**
- [ ] Update color themes **5 → 10** (add names: Crimson Red, Deep Navy, Midnight Teal, Rose Pink, Charcoal)
- [ ] Update Hub tiles **22 → 26**
- [ ] Update Quick Access shortcuts **10 → 9**
- [ ] BSP citation: update 2021 stats → **BSP CFIS 2025** (50% formal accounts, 74% financial literacy)
- [ ] Remove exclusivity claims ("first/only") — soften to "novel integrated bundle"
- [ ] Remove commercial stats: "32% overspending reduction", "22% gamification boost", "$133/month subscriptions"

### Chapter 2 — Review of Related Literature/Systems
- [ ] Update competitor table to include **Agila, PISO Budget Tracker, BunnyWise, Lista PH, Kibo, GCash Pera Coach**
- [ ] Update BudgetPH row: Paluwagan = SmartSpend now has basic implementation (v2.9.35)
- [ ] Add **Wingman Money** (Australia 2026) — validates commercial viability of behavioral FHS
- [ ] Add **Finanzya** — 96% auto-categorization, FIRE calculator, multi-currency — international benchmark
- [ ] Update LLM/AI model table: remove LLaMA models; add GPT-OSS 120B, GPT-OSS 20B, Qwen3.6 27B, Qwen3.8 27B, Compound Mini (all Groq free/dev tier)
- [ ] Add note on GCash Pera Coach (March 2026, Microsoft): emphasize it's literacy-only, not expense tracking
- [ ] Add **RA 10173 PII Redaction** section in Security: mobile numbers and bank reference numbers stripped from OCR/paste text before cloud LLM transmission (implemented v2.9.42)

### Chapter 3 — Methodology/System Design
- [ ] Update FHS equations to v2.9.42 changes:
  - **Overspend Control:** `hardOverDays + softOverDays × 0.5` (one-off purchases get 0.5× penalty)
  - **Category Balance:** now exempts Bills, Health, Education from 40% concentration check
  - **Warning Decay:** only fires when a **discretionary** budget is exceeded — not Bills/Health/Education
- [ ] FHS positioning: "Prototype Observed Financial Health Indicator per **CBA-MI (2018)** + **UNSGSA (2021)** dual-scale model" — NOT CFPB (CFPB measures psychological states; SmartSpend measures behavioral transaction outcomes)
- [ ] AI architecture: use phrase "dynamic full-context injection" — not RAG. Justify: per-user data (~50 expenses, 10 budgets) fits in one prompt; RAG adds latency and fails on multi-hop queries
- [ ] Add "home screen customize shortcut" (tune icon → 6-section toggle sheet) to UI features
- [ ] Add "gradient profile header card" to UI features (primaryContainer gradient, avatar + stats)
- [ ] Add "settings grouped section cards" to UI features (soft-shadow card groups per section)
- [ ] Add "Hub search bar + 4 category groups" to UI features
- [ ] Describe "soft-UI card design system" — all 37 screens use consistent shadow/radius/fill

### Chapter 4 — Results, Discussion, and Recommendations
- [ ] Move from Future Work to Implemented:
  - Paluwagan tracker (v2.9.35)
  - Savings rate trend chart (v2.9.45)
  - Quick budget slider long-press (v2.9.45)
  - Analytics AI cache fallback (v2.9.45)
  - Day-in-Review card after 6pm (v2.9.36, verified v2.9.45)
  - Done Spending toggle in log sheet (v2.9.45)
  - Home section customize shortcut (v2.9.45)
  - 5 additional color themes / 10 total (v2.9.45)
  - Profile gradient header (v2.9.46)
  - Hub search + categories (v2.9.46)
  - Full-app soft-UI polish / all 37 screens (v2.9.47)
- [ ] Keep in Future Work (not implemented):
  - Safe-to-Spend number
  - Proactive AI nudge notifications
  - Auto-categorization evidence threshold
  - Income prediction / payday countdown
  - AI chat history export
  - Monthly delta notification
  - Monthly GitHub-style heatmap (full grid)
  - Receipt photo gallery
  - PSA Price Intelligence / Price Pulse
  - GCash Notification Listener
  - SQLite encryption
  - Backend API proxy
  - iOS version
- [ ] Add note on **OFxPERA readiness**: "SmartSpend is architecturally aligned with BSP's Open Finance / OFxPERA framework — when the API becomes available to app developers, the paste-to-import flow can be replaced with a secure, consented bank data API call"

---

## Part 4 — New Features Backlog Added This Session

The following were added to `FEATURE_BACKLOG.md` in Parts 11–15. Claude should know about these for context when discussing Future Work:

### From Research Gap Analysis (Part 15)

| ID | Feature | Priority | What it is |
|----|---------|----------|-----------|
| 15A | Chat history token compression | Before final defense | Keep last 8 turns full, summarize older — saves ~3–5× token quota |
| 15B | Action source restriction + allowlist | Before final defense | Block destructive actions (delete_expense, delete_by_date) from OCR/paste/barcode sources |
| 15C | First-time AI advice disclaimer | Before final defense | One-time AlertDialog before first financial_advice-tier response — RA 11765 compliance |
| 15D | GCash Share Intent receiver | Before final defense | Register `ACTION_SEND` in manifest — SmartSpend appears in GCash share sheet |
| 15H | AI confidence explainability | Before final defense | Banner on low-confidence AI expenses: "I wasn't fully sure — please verify" |
| 15I | OFxPERA readiness documentation | Before final defense | Manuscript note only, no code |
| 15E | Android home screen widget | Post-capstone | Quick balance/spend glance widget |
| 15F | Subscription cancellation workflow | Post-capstone | "Cancel?" button per detected subscription → AI chat deep-link |
| 15G | PSA FIES spending benchmarks | Post-capstone | "vs. average Filipino" per category using PSA Family Income and Expenditure Survey |
| 15J | FIRE calculator | Post-capstone | 25× annual expenses target, at-current-rate projection |
| 15K | Multi-currency OFW tracking | Post-capstone | Log expenses in USD/SGD/etc, store original + PHP conversion |
| 15L | Remittance tracker | Post-capstone | Track incoming OFW remittances as income type |

### New Feature Ideas from 2026 Research (Part 12)

| ID | Feature | Effort | What it is |
|----|---------|--------|-----------|
| 12A | Spending Accountability Partner | 2h | Weekly category check-in push notification |
| 12B | Quick Income Log chip | 1h | One-tap repeat salary/allowance from home dashboard |
| 12C | Expense Undo History card | 2h | Last 3 AI-logged expenses with inline undo, visible in Transactions |
| 12D | AI Provider Health Dashboard | 2h | Provider status row in Settings → AI MODEL section |
| 12E | "Translate My Receipt" shortcut | 1h | Entry point in log sheet → opens OCR camera in receipt mode |
| 12F | Payday Countdown Widget | 2h | Extends existing Daily Limit card with payday date + countdown |
| 12G | AI Model Upgrade Pathway | Research | Route `financial_advice` tier to Qwen3.8-27B (already in chain) |

---

## Part 5 — Competitor Intelligence (Final Update)

### Full competitor list for the manuscript competitor table

| App | Platform | Key notes for manuscript |
|-----|---------|--------------------------|
| **BudgetPH** | Android/PWA | Closest PH competitor. Paluwagan ✅, payday cycle ✅, safe-to-spend ✅. No agentic AI, no voice, no OCR. SmartSpend paluwagan implemented v2.9.35. |
| **Agila: Finance Coach** v1.2.7 | Android + iOS | Business profile (invoices, inventory) strong. No FHS, no batch screenshots, no voice, no Taglish AI. |
| **PISO Budget Tracker** | Android | 100% offline, Filipino-made, no ads. No AI, no FHS, no gamification. |
| **Sentimo** | Android | "KBoy" carabao mascot, streaks, gamification. No AI chat, no OCR, no FHS. |
| **SweldoWise / SweldoTrack** | Android | Payday-cycle niche apps. No AI, no FHS. |
| **Lista PH** | Android | Simple tracker + credit score access. No AI, no FHS. |
| **Kibo** | Android | AI categorization from text/receipt/banking alerts. Limited PH context. |
| **BunnyWise** | Android (launching) | PSE stocks + UITFs + MP2 + crypto. Investment-focused. No AI expense tracking. |
| **MayBudget** | Android | Payday-cycle focus. Basic, no AI. |
| **GCash Pera Coach** | Android (inside GCash) | AI financial literacy Q&A in Filipino/English. NOT expense tracking. Advisory only. Developed with Microsoft, launched March 2026. |
| **Wingman Money** | iOS/Android (AU/NZ) | FHS 0–100 from behavioral transaction data — validates SmartSpend's approach commercially. Offline ❌, PH ❌. |
| **Finanzya** | Multi-platform | 96% auto-categorization, FIRE calculator, retirement projection, multi-currency. Strong international competitor — no PH localization yet. |
| **Cleo** | iOS + Web (US/UK) | Snarky AI advisor, gamification. No Filipino context, no offline. |
| **Monarch Money** | iOS + Android (US) | AI assistant, receipt scanning (July 2026), Goals 3.0. Bank API required (US only), paid subscription. |
| **YNAB** | All platforms | Zero-based budgeting gold standard. $14.99/mo, US-bank API required, no offline, no Filipino context. |

### SmartSpend's Unique Position (for manuscript Chapter 1/2)

**What no other app has combined:**
1. Free Filipino-English conversational AI + 34 agentic actions
2. Offline-first + Firebase cloud sync — simultaneously
3. Batch screenshot import (40+ platforms auto-detected)
4. Dual-mode FHS (Full + Lightweight) — score adapts to users without fixed income
5. Multi-modal input: voice + OCR + barcode + batch screenshots + paste text + manual

---

## Part 6 — AI / LLM Architecture Clarifications

### Context Injection vs RAG (for Chapter 3 justification)

SmartSpend uses **dynamic full-context injection**, not RAG. This is the correct architectural term and justification for the manuscript:

- Per-user data: ~50 expenses + 10 budgets + 5 goals + wallets = **1,000–5,000 tokens**
- Gemini 3.5 Flash-Lite context window: **1,000,000 tokens**
- Data fits in 0.5% of the window — no retrieval needed
- RAG adds vector-search latency and **fails on multi-hop queries**: "Can I afford this given my GCash, clothing budget, and savings goal?" requires all three data points simultaneously — a retriever would return only one

**Quote for paper (use verbatim):**
> "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines."

### PII Redaction (for Chapter 2 Security section — RA 10173)

Implemented in v2.9.42. Two call sites:
1. `AIChatService.sendMessage()` — strips PII before sending user chat messages to LLM
2. `LLMService.parseExpense()` — strips PII from OCR/paste text before sending to LLM

What is redacted:
- PH mobile numbers: `09XX-XXX-XXXX` and `+639XX` format → `[REDACTED_MOBILE]`
- GCash/bank reference numbers: 12–18 digit sequences → `[REDACTED_REF]`
- Bank account patterns: `XX-XXXXX-X` → `[REDACTED_ACCOUNT]`

Financial amounts (e.g., `₱1,500`) are **NOT** redacted — they are not PII.

### Theoretical Frameworks (correct badge count for SDT section)

The Self-Determination Theory (SDT) section must use **25 badges**, not 23:

> "*Competence* → **25 badges** + streaks reward skill growth..."

---

## Part 7 — AI Models Landscape Update (for Chapter 2/3 if needed)

### New Models Released After Original Manuscript Was Written

These appeared after the original manuscript draft and should be mentioned if the manuscript covers the AI landscape:

| Model | Released | Key specs | Relevance to SmartSpend |
|-------|---------|-----------|------------------------|
| **Kimi K3** (Moonshot AI) | July 16, 2026 | 2.8T MoE, 104B active, 1M context — #1 open-weight on Artificial Analysis Index | Not in SmartSpend chain (no permanent free API), but validates that open-weight models now match closed-model quality |
| **Kimi K2.6** (Moonshot AI) | April 20, 2026 | 1T MoE, 32B active, 256K context, 80.2% SWE-Bench | Context: used to validate that open-weight agentic models are viable; K2.6 has Agent Swarm (300 sub-agents) — supports SmartSpend's agentic AI positioning |
| **Qwen3.8-27B** (Alibaba) | Aug 14, 2026 | Dense 27B, Apache 2.0, vision+video, 262K context | **Already in SmartSpend's chain** as Tier 5 (`qwen/qwen3.8-27b` on Groq) |
| **Qwen3.8-Max** (Alibaba) | Aug 3, 2026 | 2.4T MoE, 95B active, 1M context | Not in SmartSpend chain (paid only) |
| **DeepSeek V4 Flash** (DeepSeek) | April 23, 2026 | MIT licensed, $0.14/MTok — cheapest frontier | Not in SmartSpend chain but cheapest paid upgrade path post-capstone |
| **Gemini 3.7 Flash** (Google) | Aug 2026 | Paid only, $0.75/1M input | Not in SmartSpend chain — paid |

### Retired Models (MUST NOT appear in manuscript)

- `gemini-3.1-flash-lite` — returns 404 on most accounts; migrated to 3.5 on Sep 10, 2026
- `gemini-2.5-flash` — shutting down Oct 16, 2026
- `llama-4-scout`, `llama-3.3-70b`, `llama-3.1-8b` — all retired from Groq free/dev tier

### Qwen Free OAuth Proxy — DEPRECATED (important note)

A document in the repo (`Using Qwen Models Free with OpenCode.md`) described a method to use Qwen models via a localStorage token extraction and a third-party proxy (`qwen.aikit.club`). **This method was shut down on April 15, 2026** when Alibaba discontinued the free OAuth tier.

The document has been updated with a deprecation notice. The correct free path to Qwen models is via **Groq** (`qwen/qwen3.6-27b` and `qwen/qwen3.8-27b` — already in SmartSpend's chain).

---

## Part 8 — Pre-Final Defense Checklist Status

### ✅ Done (Code + Docs — by Kiro this session)

- All reference docs updated to v2.9.47 with correct numbers
- BENCHMARK.md: 23→25 badges, paluwagan ❌→✅
- DEFENSE_GUIDE.md: broken table row fixed, build size, color themes, badge count
- FEATURE_DOCS.md: header version, APK size, badge count, new features list
- CAPSTONE_REFERENCE.md: blurb fixed, badges, color themes
- PROJECT_STATUS.md: 5 doc tasks marked ✅, 3 new manuscript tasks added
- Qwen/OpenCode.md: deprecation notice added
- FEATURE_BACKLOG.md: Parts 11–15 added (AI models, 7 new features, gap analysis, defense timeline, competitor intel)
- LLM Engineering Cheatsheet v6: written (2,455 lines, Appendix A free API directory, Appendix B AI literacy)
- kiro-to-claude-handoff-v2.md: written (covers v2.9.43–v2.9.47)
- kiro-to-claude-handoff-v3.md: this document

### ❌ Still Needed Before Defense Day (Human Tasks)

| Task | Owner | Critical? |
|------|-------|-----------|
| Install v2.9.47 APK on demo phone | Brix | 🔴 Yes |
| Reset AI daily limit before demo | Brix | 🔴 Yes |
| Charge demo phone 100% night before | Brix | 🔴 Yes |
| Create Figure 1.1 — PH financial literacy bar chart | Cyrille | 🔴 Yes |
| Create Figure 1.2 — IPO conceptual framework | Cyrille | 🔴 Yes |
| Create Figure 2.1 — SUS score interpretation chart | Cyrille | 🔴 Yes |
| Create Figure 2.2 — Kanban board diagram | Cyrille | 🔴 Yes |
| Fill in Compliance Matrix | All | 🔴 Yes |
| All Chapter 1–4 manuscript corrections (Part 3 of this doc) | Cyrille | 🔴 Yes |
| Rehearse demo flow | All | 🟠 Important |
| Add Lista PH, Kibo, Finanzya to competitor table | Cyrille | 🟠 Important |
| Add OFxPERA readiness note to Ch.4 | Cyrille | 🟡 Nice to have |
| Add first-time AI advice disclaimer note to Ch.2 Security | Cyrille | 🟡 Nice to have |

---

## Part 9 — Demo Script Quick Reference

**Setup night before:**
1. Download `SmartSpend-v2.9.47-arm64-v8a.apk` from `https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.47`
2. Install → open → verify About shows "Version 2.9.47"
3. Load demo data if needed: Profile → Load Demo Data
4. Reset AI limit: AI screen → ⋮ → Reset Daily Limit
5. Charge to 100%, do not open again until defense

**10-minute demo flow:**
1. **Home** — balance card, AI insights, quick access 9-grid, wallet card
2. **AI Chat** — type `"Sept 9 I spent 90 for lunch, 30 for jeep, 500 for Nintendo Wii, 150 for plushie"` → 4 items, correct Want/Need
3. **Smart Import** → 4-mode sheet → demo batch screenshots
4. **FHS breakdown** → tap score card → explain 4 components
5. **Analytics** → pie chart, 50/30/20, savings rate trend chart (new v2.9.45)
6. **Hub** → search bar demo, Paluwagan (highlight Filipino-specific), Log Due Bills
7. **Profile** → gradient header card, 25 badges, Insurance Tracker
8. **Settings** → grouped card sections, 10 color themes

**Quick panel answers:**
- "GCash has Pera Coach" → Pera Coach = literacy Q&A only. SmartSpend = 34 autonomous actions, expense tracking, offline FHS, gamification. Different tools.
- "How many agentic actions?" → **34**. List 5: log_expense, set_budget, add_goal, detect_subscriptions, simulate_what_if
- "Why not RAG?" → Per-user data fits in 0.5% of Gemini's 1M context window. RAG adds latency and breaks multi-hop queries.
- "What if API goes down?" → **8-provider** automatic failover. Manual entry works 100% offline.
- "How does FHS work?" → 4 components × 25 pts = 100. Full mode: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency.
- "RA 10173?" → PII redacted on-device before cloud LLM. Mobile numbers, reference numbers stripped. Core financial data never leaves SQLite.
- "Paluwagan?" → ✅ Implemented v2.9.35. Hub → Paluwagan Tracker. Member management, payout order, contribution logging, round tracking.

---

## Part 10 — What Claude Should Do With This Handoff

When Claude receives this document and the previous two handoffs, the workflow for manuscript revisions should be:

1. **Read all three handoffs first.** v1 covers v2.9.38–v2.9.42 (AI pipeline, FHS formulas, RA 10173). v2 covers v2.9.43–v2.9.47 (UI polish). v3 (this) covers doc fixes, gap analysis, new backlog.

2. **Use Part 3 of this document** as the checklist for manuscript changes — it is the complete, consolidated list.

3. **Reference `CAPSTONE_REFERENCE.md`** for exact FHS formulas, competitor tables, and architecture descriptions. It is now current to v2.9.47.

4. **Reference `BENCHMARK.md`** for the competitor comparison matrix. All badge counts and paluwagan status are now correct.

5. **Reference `FEATURE_BACKLOG.md`** Part 0 for authoritative numbers. It is the single source of truth for all metrics.

6. **Do not** update references to LLaMA models, Gemini 3.1 Flash-Lite, or any model with an old ID. See Part 6 of this document for the correct model list.

7. **When discussing Future Work** in Chapter 4: use Part 3 bullet lists — they are sorted into "Implemented" (move from Future Work) and "Keep in Future Work."

8. **The app is called "SmartSpend"** (two words, title case) in the manuscript. The package name is `smartspend_app`. The GitHub repo is `smartspend-app`. These are all correct and consistent.

---

*Compiled by Kiro (Kiro IDE) — September 12, 2026*
*This is Session 3, the final pre-defense handoff.*
*Read with: `kiro-to-claude-handoff-2026-09-12.md` (v2.9.38–v2.9.42) and `kiro-to-claude-handoff-2026-09-12-v2.md` (v2.9.43–v2.9.47)*
*All information here supersedes previous handoffs where there is conflict.*
*Treat all numbers, feature statuses, and model lists in this document as ground truth.*
