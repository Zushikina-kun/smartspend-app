# SmartSpend — Project Status
**Version:** 2.9.58 | **Academic Year:** 2026–2027, 1st Semester
**Last Updated:** September 26, 2026
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag

> For full technical documentation see `docs/reference/CAPSTONE_REFERENCE.md`
> For feature backlog and planning see `docs/guides/FEATURE_BACKLOG.md`
> For Claude AI handoff (latest) see `docs/manuscript/reseaches/kiro-to-claude-handoff-2026-09-26-v3.md`
> Previous handoffs: `kiro-to-claude-handoff-2026-09-12-v2.md` (v2.9.43–47), `kiro-to-claude-handoff-2026-09-12.md` (v2.9.38–42)

---

## PRE-FINAL DEFENSE — CHECKLIST

### 🔴 Critical — Must be done before defense day

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Install **v2.9.53** on demo phone | Brix | ❌ | Download `SmartSpend-v2.9.53-arm64-v8a.apk` from GitHub releases |
| Verify About screen shows **"Version 2.9.53"** | Brix | ❌ | kAppVersion constant auto-syncs |
| Reset AI daily limit before demo | Brix | ❌ | AI screen → ⋮ menu → Reset Daily Limit |
| Create **Figure 1.1** — PH financial literacy bar chart (BSP CFIS 2025 data) | Cyrille | ❌ | Key stats: 50% adults have formal accounts; 74% literacy rate |
| Create **Figure 1.2** — IPO conceptual framework diagram | Cyrille | ❌ | Input→Process→Output; use the table in CAPSTONE_REFERENCE.md §3 |
| Create **Figure 2.1** — SUS score interpretation chart | Cyrille | ❌ | Bangor et al. (2009) adjective scale; target ≥80 = Good |
| Create **Figure 2.2** — Kanban board / development methodology diagram | Cyrille | ❌ | Agile Kanban sprints; show Backlog → In Progress → Done |
| Fill in **Compliance Matrix** | All | ❌ | `docs/capstone/SmartSpend_Master_Bug_Tracker.docx` |
| Move **Paluwagan** from "Future Work" to "Implemented" in manuscript | Cyrille | ✅ | Implemented v2.9.35 |
| Update manuscript **model list** (remove LLaMA, add Auto mode + GPT-OSS/Qwen) | Cyrille | ❌ | See handoff v3 §3a for correct chain |
| Update manuscript **FHS equations** with v2.9.42 changes | Cyrille | ❌ | Overspend nuance + Category Balance exemptions + Decay exemptions |
| Update manuscript **agentic action count** to 34 | Cyrille | ❌ | Was 31 in some manuscript sections |
| Update manuscript **badge count** to 25 | Cyrille | ❌ | Was 23 in some sections |
| Update manuscript **daily limit** to 150 | Cyrille | ❌ | Was 60 in some sections |
| Update manuscript **color theme count** to 10 | Cyrille | ❌ | 5 new themes added v2.9.45 |
| Update manuscript **hub tile count** to 26 | Cyrille | ❌ | Expanded from 22 in v2.9.44 |
| Add **v2.9.50–53 features** to Implemented list in manuscript | Cyrille | ❌ | See handoff v3 §6 — 10 features to move |
| Update **settings toggles count** (9 home, 4 analytics, 13 Lite Mode) | Cyrille | ❌ | See handoff v3 §5 |
| Add **savings rate trend chart** to Implemented | Cyrille | ❌ | Added v2.9.45 |
| Add **quick budget slider** to Implemented | Cyrille | ❌ | Added v2.9.45 |
| Add **analytics AI cache fallback** to Implemented | Cyrille | ❌ | Added v2.9.45 |
| Add **RA 10173 PII redaction** section to manuscript (Ch.2 or Ch.3) | Cyrille | ❌ | Implemented v2.9.42 — mobile numbers stripped before LLM |
| Add **Agila, PISO, BunnyWise** to competitor table in manuscript | Cyrille | ❌ | See FEATURE_BACKLOG Part 10 |
| Update docs: **BENCHMARK.md** badge 23→25, paluwagan ❌→✅ | Brix | ✅ | Done Sep 12, 2026 |
| Update docs: **FEATURE_DOCS.md** version 2.9.41→2.9.53 | Brix | ❌ | |
| Update docs: **CAPSTONE_REFERENCE.md** version, Auto model, new features | Brix | ❌ | |
| Update docs: **DEFENSE_GUIDE.md** version, model names, new features | Brix | ❌ | |
| Rehearse demo flow with v2.9.53 | All | ❌ | See demo script below |
| Charge demo phone to 100% the night before — do NOT open the app | Brix | ❌ | Cold start required for demo |
| Move **Paluwagan** from "Future Work" to "Implemented" in manuscript | Cyrille | ✅ | Implemented v2.9.35 |
| Update manuscript **model list** (remove LLaMA, add GPT-OSS/Qwen) | Cyrille | ❌ | See kiro-to-claude-handoff-v2 for correct chain |
| Update manuscript **FHS equations** with v2.9.42 changes | Cyrille | ❌ | Overspend nuance + Category Balance exemptions + Decay exemptions |
| Update manuscript **agentic action count** to 34 | Cyrille | ❌ | Was 31 in some manuscript sections |
| Update manuscript **badge count** to 25 | Cyrille | ❌ | Was 23 in some sections |
| Update manuscript **daily limit** to 150 | Cyrille | ❌ | Was 60 in some sections |
| Update manuscript **color theme count** to 10 | Cyrille | ❌ | 5 new themes added v2.9.45 |
| Update manuscript **hub tile count** to 26 | Cyrille | ❌ | Expanded from 22 in v2.9.44 |
| Add **savings rate trend chart** to Implemented | Cyrille | ❌ | Added v2.9.45 — Analytics section |
| Add **quick budget slider** to Implemented | Cyrille | ❌ | Added v2.9.45 — Budget screen long-press |
| Add **analytics AI cache fallback** to Implemented | Cyrille | ❌ | Added v2.9.45 — both Advice + Monthly Summary |
| Add **RA 10173 PII redaction** section to manuscript (Ch.2 or Ch.3) | Cyrille | ❌ | Implemented v2.9.42 — mobile numbers stripped before LLM |
| Add **Agila, PISO, BunnyWise** to competitor table in manuscript | Cyrille | ❌ | See kiro-to-claude-handoff-v2 §13 for details |
| Add **Lista PH, Kibo, Finanzya** to competitor table | Cyrille | ❌ | New competitors from Sep 2026 research — see FEATURE_BACKLOG Part 14 |
| Add **OFxPERA readiness** note to manuscript Ch.2/Ch.4 | Cyrille | ❌ | "SmartSpend is architecturally OFxPERA-ready" — see FEATURE_BACKLOG 15I |
| Add **AI advice disclaimer** — first-time dialog note to manuscript | Cyrille | ❌ | RA 11765 responsible AI compliance — see FEATURE_BACKLOG 15C |
| Update docs: **BENCHMARK.md** badge 23→25, paluwagan ❌→✅ | Brix | ✅ | Done Sep 12, 2026 |
| Update docs: **FEATURE_DOCS.md** version 2.9.41→2.9.47, badge 23→25 | Brix | ✅ | Done Sep 12, 2026 |
| Update docs: **CAPSTONE_REFERENCE.md** v2.9.41 blurb, badge 23→25, themes 5→10 | Brix | ✅ | Done Sep 12, 2026 |
| Update docs: **DEFENSE_GUIDE.md** fix broken table row, badge, build size | Brix | ✅ | Done Sep 12, 2026 |
| Archive Qwen/OpenCode doc with deprecation notice | Brix | ✅ | Deprecated April 15, 2026 — notice added Sep 12 |
| Rehearse demo flow with v2.9.49 | All | ❌ | See demo script below |
| Charge demo phone to 100% the night before — do NOT open the app | Brix | ❌ | Cold start required for demo |

### 🟡 After pre-final defense (before final)

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| SUS survey — 30 respondents (20 parents, 10 young professionals) | Djaunathan | ❌ | See Deployment Roadmap for respondent recruitment via Internal Testing |
| Google Play Internal Testing — invite 12+ testers via Gmail | Brix | ❌ | Requires Play Console ($25) + Privacy Policy first |
| Run Internal Testing 14 days minimum | Djaunathan | ❌ | Required before production eligibility |
| Create Google Play Console account ($25 USD) | Brix | ❌ | One-time fee — see Deployment Roadmap |
| Build AAB: `flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info` | Brix | ❌ | 5 min — produces `app-release.aab` |
| Create Privacy Policy hosted page (GitHub Pages) | Cyrille | ❌ | Required Play Store field — template in Deployment Roadmap |
| Enforce Firebase App Check | Brix | ❌ | Firebase Console → App Check → Enforce (currently monitoring only) |
| Validator signatures — Appendix A certificates | Brix | ❌ | |
| BSP citation update: Ch.1 stats from BSP 2021 → BSP CFIS 2025 | Cyrille | ❌ | |
| Insert survey results + SUS scores into manuscript Ch.3 | Cyrille | ❌ | |
| Update comparative research in manuscript with new competitors | Cyrille | ❌ | Use `SmartSpend_Comparative_Research_Updated_Sep2026.md` — new: Tarsi, Alkansya AI, ChatGPT Finance, Cleo 3.0, Origin, Finanzya |
| Update FHS formula section in manuscript with v2.9.42 changes | Cyrille | ❌ | Overspend soft/hard penalty, Category Balance exemptions, Warning Decay discretionary-only |
| CV section for all three researchers | All | ❌ | |

---

## DEMO SCRIPT — Pre-Final Defense (v2.9.49)

### Setup (night before)
1. Download `SmartSpend-v2.9.49-arm64-v8a.apk` from GitHub releases
2. Install on demo phone; verify About screen shows **"Version 2.9.49"**
3. Charge phone to 100%, do NOT open the app again until demo
4. Have WiFi ready (AI needs internet for first message)

### Opening (2 min)
- Open app cold → show Home screen with live data
- Point out: FHS score card, spending card, wallet card, AI Insights
- If after 6pm: show Day-in-Review card at bottom of home

### Core Demo Flow (10 min)
1. **AI Chat** — type `"on september 9 I spent 90 for lunch, 30 for jeep, 500 for Nintendo Wii, and 150 for plushie"` → show 4 items logged in one message, correct Want/Need tagging
2. **Smart Import** → tap camera icon → show 4-mode sheet → demo batch screenshot import (Steam receipt or Shopee)
3. **Manual Entry** — tap Log Expense → show choice sheet (AI/Manual/Batch/Voice/Round-Trip/Split/Afford?)
4. **Financial Health Score** — tap FHS card → show breakdown with component explanations + "one-off purchase penalty" note
5. **Analytics** — pie chart, 50/30/20 tracker, heatmap, budget envelope, By Tag view
6. **Hub** — scroll through: Goals, Debts, Recurring, **Paluwagan** (highlight as Filipino-specific), **Log Due Bills**, **Merchant Cleanup**
7. **Profile** — show FMS score, FHS breakdown with tips, achievement badges (25), Insurance Tracker

### Panel Q&A — Updated Answers (v2.9.49)

| Question | Answer |
|---|---|
| "GCash already has Pera Coach" | Pera Coach = financial literacy Q&A embedded in GCash. SmartSpend = **34 autonomous agentic actions**, offline-first SQLite, dual-mode FHS with 4-component formula, multi-modal input (voice/OCR/barcode/batch screenshots), gamification (25 badges). They solve different problems — Pera Coach teaches; SmartSpend manages and tracks. |
| "Agila is similar — how are you different?" | Agila has a business profile (invoices, inventory) but no Taglish AI, no FHS, no voice input, no barcode/OCR, no batch screenshot import, no PH government contributions. SmartSpend leads on AI depth, multi-modal entry, and the FHS scoring system. |
| "Your sample is too small" | N=30 purposive is standard for formative usability testing. Nielsen & Landauer (1993) and Faulkner (2003) show 20–30 participants uncover 90–95% of usability defects. Not a population study — a prototype evaluation. |
| "Is the CFPB scale your FHS basis?" | No. The CFPB scale is a 10-item **subjective** psychometric survey measuring psychological states (worry, anxiety, perceived freedom). SmartSpend's FHS is an **objective transaction-derived indicator** — computed programmatically from SQLite data. Grounded in CBA-MI (2018) Observed Financial Well-being Scale and UNSGSA (2021) guidelines. We call it a Prototype Observed Financial Health Indicator. |
| "What if the API goes down?" | 8-provider automatic failover: Gemini 3.5 Flash-Lite → Gemini 3.5 Flash → GPT-OSS 120B (Groq) → Qwen3.6 27B → Qwen3.8 27B → GPT-OSS 20B → Compound Mini → GPT-OSS 120B (Cerebras). Manual entry, OCR, barcode, and item catalog work **100% offline**. |
| "Why not RAG?" | Per-user data (50 expenses, 10 budgets, 5 goals) fits entirely in one prompt — ~1,000–5,000 tokens. RAG adds vector-search latency and fails on multi-hop queries like "Can I afford this given my GCash, clothing budget, and savings goal?". Direct context injection gives 100% accurate, always-current data. |
| "AI gives financial advice — legal?" | General financial guidance and education only — not personalized professional advice. Explicit disclaimer in About screen and embedded in every AI response. Same approach as Mint, YNAB, and Cleo globally. |
| "How does FHS work?" | 4 components × 25pts = 100. **Full Mode** (income tracking ON): Savings Rate, Overspend Control, Budget Adherence, Logging Consistency. **Lightweight Mode** (income tracking OFF): Spending Restraint, Consistency, Category Balance, Habit Streak. Plus Warning Decay (−5 pts/day, max −15 for ignoring discretionary budget overruns) and Gap Adjustment (−3/+2 pts for unlogged days). |
| "What's new in FHS since the previous version?" | Three improvements: (1) Overspend Control now distinguishes one-off large purchases (half-penalty) from habitual daily overspend (full penalty). (2) Category Balance now exempts Bills/Health/Education from the concentration check — essential costs don't unfairly reduce the score. (3) Warning Decay is suspended when only essential categories are over budget. |
| "How many agentic actions?" | **34** — log/update/delete expense, delete_by_date, set_income, add_income, set_wallet_balance, transfer_wallet, set_budget, add/update/delete goal, add/update debt, add/delete recurring, add_installment_plan, plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, generate_monthly_plan, compare_periods, explain_fhs_breakdown, project_savings_timeline, detect_subscriptions, compute_contribution, suggest_idle_money, suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense, set_spending_limit, add_insurance_policy, set_account_type |
| "What about data privacy — RA 10173?" | On-device regex redaction strips Philippine mobile numbers and bank reference numbers from OCR/paste text **before** anything is sent to the cloud LLM. Core financial data stays in SQLite on-device. Firebase Firestore sync is UID-scoped. Firebase Remote Config delivers API keys at runtime — not embedded in APK. |
| "Why Flutter?" | Single codebase for Android (and iOS post-capstone). Near-native performance (compiled to ARM). Dart's strong typing suits financial calculations. The entire team could maintain it as a 3-person group. |

---

## CAPSTONE 2 TIMELINE

| Week | Activity | Status |
|------|----------|--------|
| Week 1 | Project Reorientation | ✅ Done |
| Week 2 | Chapter 3 | ⚠️ Draft exists — needs figures + model/FHS corrections |
| Week 3 | Chapter 4 | ⚠️ Draft exists — needs survey data |
| Week 4 | Final software check | ✅ Done (v2.9.49 is stable) |
| **Week 5–6** | **Pre-Final Defense** | 🔴 **Next week** |
| Week 7 | SUS survey (30 respondents) + Play Store closed testing start | ❌ Pending |
| Week 8–10 | Complete manuscript + Play Store submission | ❌ Pending |
| Week 11–13 | Final Defense | ❌ Pending |
| Week 15–17 | Revisions + submission | ❌ Pending |

---

## APP STATUS — v2.9.49 (Current — Defense Build)

### AI System
- **Primary model**: Gemini 3.5 Flash-Lite (GA stable — migrated from 3.1 on Sep 10, 2026 due to 404 errors in production)
- **Fallback chain** (8 providers): Gemini 3.5 Flash → GPT-OSS 120B (Groq) → Qwen3.6 27B → Qwen3.8 27B → GPT-OSS 20B → Compound Mini → GPT-OSS 120B (Cerebras)
- **LLaMA models**: Retired from Groq free/dev tier Feb–Aug 2026 — NOT in chain
- **Daily limit**: 150 messages
- **Language**: English-default; switches to Filipino only when user writes multiple full Filipino sentences

### Feature Count (v2.9.47)
| Metric | Count |
|--------|-------|
| Agentic AI actions | **34** |
| Input modalities | 7 |
| Hub tiles | **26** |
| Achievement badges | **25** |
| Color themes | **10** |
| Daily quests pool | 10 |
| Batch screenshot platforms | 40+ |
| Filipino item catalog | 150+ |
| Log choice sheet options | 7 |
| Currencies | 57 |
| SQLite tables | 20 |
| Quick Access grid shortcuts | 9 |

### Key Features Added Since v2.9.42 (defense-relevant)
| Feature | Version | Where |
|---|---|---|
| Savings rate trend chart (6-month line) | 2.9.45 | Analytics → before Daily Spending Trend |
| Quick budget slider (long-press) | 2.9.45 | Budget screen |
| Analytics AI cache fallback | 2.9.45 | Analytics → Advice + Monthly Summary cards |
| Day-in-Review card (verified) | 2.9.45 | Home screen → appears after 18:00 |
| 5 new color themes | 2.9.45 | Settings → Appearance → App theme |
| Done Spending toggle in log sheet | 2.9.45 | Home → Log Expense → bottom |
| Home section customize shortcut | 2.9.45 | Home header → tune icon |
| Profile gradient header card | 2.9.46 | Profile screen |
| Quick Access grid redesign (9 tiles, soft shadow) | 2.9.46 | Home screen |
| Settings grouped section cards | 2.9.46 | Settings screen |
| Hub search bar + 4 category groups | 2.9.46 | Quick Access hub |
| Full-app soft-UI card polish (30 files) | 2.9.47 | All screens |

---

## PEOPLE REFERENCE

| Name | Role | Appears On |
|---|---|---|
| **Directo, Brix A.** | Lead Developer | All author pages |
| **Rubis, Cyrille John M.** | UI/UX + Documentation | All author pages |
| **Madayag, Djaunathan Albert S.** | Project Manager + QA | All author pages |
| **Ellen F. Mangaoang, MIT** | Capstone Adviser | Title page, Approval sheet, Acknowledgement |
| **Shekiro R. Raposas** | Panel Member | Defense panel |
| **Mary-Ann Mzana** | Panel Member | Defense panel |
| **Dr. Janelli M. Mendez, MIT** | Course Instructor | Acknowledgement only |
| **Jeoffrey B. Layco, MIS** | Dean of CCSE | Approval sheet |
| **Jopher F. Reyes, MIT** | Oral Committee Member | Approval sheet |
| **Gelo Ryann M. Carbonell** | Oral Committee Member | Approval sheet |
| **Johnny Flores Verzola, MTS** | Former Adviser (Capstone 1 only) | Acknowledgement only — **NOT on title page, NOT current adviser** |

**Birthdates (for CVs):**
- Brix A. Directo: September 4, 1999
- Cyrille John M. Rubis: August 26, 2005
- Djaunathan Albert S. Madayag: March 8, 2005

---

## MANUSCRIPT CORRECTIONS NEEDED (for Cyrille)

The following corrections are NOT yet applied in the manuscript Google Doc. Apply them before printing:

| # | What to fix | Where in manuscript | Detail |
|---|-------------|---------------------|--------|
| 1 | Version → 2.9.47 | All headers | |
| 2 | Primary model → Gemini 3.5 Flash-Lite | Ch.2/3 AI section | Not 3.1, not LLaMA |
| 3 | Remove LLaMA from fallback chain | Ch.2/3 LLM table | Retired on Groq Feb–Aug 2026 |
| 4 | 34 agentic actions (not 31) | All mentions | |
| 5 | 25 badges (not 23) | All mentions | |
| 6 | 150 messages/day (not 60) | All mentions | |
| 7 | 8 providers (not 5 or 6) | All mentions | |
| 8 | 10 color themes (not 5) | All mentions | 5 new themes added v2.9.45 |
| 9 | 26 Hub tiles (not 22) | All mentions | Expanded v2.9.44 |
| 10 | Paluwagan → Implemented | Ch.4 Recommendations | Remove from Future Work |
| 11 | Savings rate chart → Implemented | Ch.4 Recommendations | Added v2.9.45 |
| 12 | Quick budget slider → Implemented | Ch.4 Recommendations | Added v2.9.45 |
| 13 | FHS = Prototype Observed FHI (not CFPB-validated) | Ch.1/3 FHS section | Grounded in CBA-MI + UNSGSA |
| 14 | Remove "32% overspending" claim | Ch.1 | Commercial stat, not peer-reviewed |
| 15 | Remove "22% gamification boost" claim | Ch.1 | Same |
| 16 | Remove "$133/month subscription" claim | Ch.1 | US market, not PH |
| 17 | Soften "first/only" exclusivity claims | Ch.1 | "novel integrated bundle" |
| 18 | FHS Overspend Control formula updated | Ch.3 | Add soft/hard penalty explanation |
| 19 | FHS Category Balance exempts Bills/Health/Education | Ch.3 | New in v2.9.42 |
| 20 | FHS Warning Decay: only discretionary categories | Ch.3 | New in v2.9.42 |
| 21 | Add RA 10173 PII redaction | Ch.2 Security section | Mobile numbers redacted before LLM |
| 22 | Add Agila as competitor | Ch.2 competitor table | Android + iOS; business profile strength |
| 23 | Add PISO Budget Tracker as competitor | Ch.2 competitor table | Offline-first, Filipino-made |
| 24 | Adviser = Ellen F. Mangaoang MIT | Title page | Verzola = Capstone 1 only |

---

## DEPLOYMENT ROADMAP

> Added September 21, 2026. Full deployment options and task list.

---

### ✅ DONE RIGHT NOW — Direct APK (No setup needed)

The APK is already installable by anyone. This is sufficient for:
- Defense demo
- Validator installations
- SUS survey respondents
- Classmates testing

| How | Link |
|-----|------|
| Download APK | https://github.com/Zushikina-kun/smartspend-app/releases/tag/v2.9.49 |
| File to use | `SmartSpend-v2.9.49-arm64-v8a.apk` (most phones) |
| Install step | Enable "Install from unknown sources" on phone → tap APK |

---

### 🟠 BEFORE FINAL DEFENSE — Google Play Internal Testing

This is the path for getting 30 SUS survey respondents on the official Play Store version. Does NOT require waiting for Play Store review.

| # | Task | Owner | Est. time | Status |
|---|------|-------|-----------|--------|
| 1 | **Create Privacy Policy page** (GitHub Pages) — required field in Play Console | Cyrille | 2h | ❌ |
| 2 | **Create Google Play Console account** — $25 USD one-time fee | Brix | 30min | ❌ |
| 3 | **Enforce Firebase App Check** — currently monitoring mode; enforce before upload | Brix | 15min | ❌ |
| 4 | **Build AAB** (Android App Bundle — Play Store requires this, not APK) | Brix | 5min | ❌ |
| 5 | **Upload to Internal Testing track** — immediate access, no review wait | Brix | 30min | ❌ |
| 6 | **Invite SUS respondents** via Gmail to Internal Testing | Brix/Djaunathan | 30min | ❌ |
| 7 | **Run 14-day closed test** (12 testers minimum for production eligibility) | Djaunathan | 2 weeks | ❌ |

**Commands:**
```bash
# Step 3 — Enforce App Check (Firebase Console → App Check → SmartSpend → Enforce)
# (done in Firebase Console, not terminal)

# Step 4 — Build AAB
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
# Output: build/app/outputs/bundle/release/app-release.aab

# Upload app-release.aab to Play Console → Internal Testing
```

**Privacy Policy template content (for Cyrille to host on GitHub Pages):**

```
SmartSpend Privacy Policy

Data collected: Email address (Firebase Auth), expense and financial data,
usage data (AI message count, feature interactions).

Data storage: Primarily on-device (SQLite). Optionally synced to Firebase
Firestore, scoped to your user account (UID). No third party can access
your data.

AI processing: When you use AI features, expense text is sent to third-party
AI providers (Google, Groq, Cerebras). Personal identifiers (phone numbers,
reference numbers) are stripped before transmission.

Data deletion: Logout clears local data. You may request Firestore deletion
by contacting us.

Contact: [team email]
Last updated: September 2026
```

---

### 🟡 ZERO-COST ALTERNATIVES (Before or Instead of Play Store)

These require no fee and can be done immediately:

| Platform | How | Effort | Audience |
|----------|-----|--------|----------|
| **APKPure** | Upload APK at apkpure.com/developer | 30min | Global Android users |
| **F-Droid** | Submit to f-droid.org (open source required) | 1–3 week review | Developer/privacy community |
| **Amazon Appstore** | Free developer account at developer.amazon.com | 1–3 day review | Android + Kindle |
| **Samsung Galaxy Store** | Free at seller.samsungapps.com | 3–5 day review | Samsung users (PH heavy) |
| **Direct link + QR code** | Host APK on GitHub, generate QR → print for defense | 15min | Panel, validators, classmates |

**For the defense specifically:** Generate a QR code pointing to the GitHub release APK. Panel members can scan and install during or after the demo. Zero cost, instant.

---

### 🟢 POST-CAPSTONE — Full Play Store Production Release

After the final defense and SUS survey are complete:

| # | Task | Owner | Est. time | Notes |
|---|------|-------|-----------|-------|
| 1 | **Prepare 8 screenshots** (1080×1920 or 1440×2560) | Cyrille | 2–4h | Show: Home, AI chat, Analytics, FHS, Hub, Settings, Profile, Achievements |
| 2 | **Feature graphic** (1024×500 PNG) | Cyrille | 1h | App banner image for Play Store listing |
| 3 | **App icon** (512×512 PNG, no transparency) | Cyrille | 30min | Use existing logo.png, resize |
| 4 | **Short description** (80 chars max) | Cyrille | 30min | e.g. "AI-powered Filipino personal finance tracker. Free, offline-first." |
| 5 | **Full description** (4,000 chars max) | Cyrille | 1–2h | Feature list, FHS explanation, Filipino context |
| 6 | **Complete Data Safety form** | Brix | 1h | Declare: email, financial data, usage. No ads. |
| 7 | **Content rating** (IARC questionnaire) | Brix | 20min | Finance app, 18+, no violence/gambling |
| 8 | **Rotate API keys before public launch** | Brix | 30min | Generate new Groq API key → update Firebase Remote Config |
| 9 | **Submit to Production track** | Brix | 30min | After Internal Testing ≥14 days |
| 10 | **Wait for Play Store review** | — | 3–7 days | Google reviews all production submissions |

**Security tasks before production launch:**
- [ ] **Enforce Firebase App Check** (currently monitoring mode) — blocks sideloaded/modified APKs
- [ ] **Cloud Functions proxy** for API keys (optional but recommended — key never in APK) — ~3 days work
- [ ] **SQLite encryption** (sqlcipher) — optional but adds data-at-rest protection — ~2 days work
- [ ] **Backend rate limiting** upgrade — optional enhancement

---

### 📋 DEPLOYMENT SUMMARY

| Path | Cost | Time to users | Requirements | Best for |
|------|------|---------------|-------------|----------|
| **Direct APK (GitHub)** | Free | Now | None | Defense demo, validators, classmates |
| **QR code to APK** | Free | Now | None | Defense day, printed handout |
| **APKPure** | Free | 30min | APK file | Global visibility |
| **Play Internal Testing** | $25 one-time | Same day | Play Console account + Privacy Policy | SUS survey respondents |
| **Samsung Galaxy Store** | Free | 3–5 days | Samsung dev account | PH Samsung users |
| **F-Droid** | Free | 1–3 weeks | Open source license | Privacy-conscious users |
| **Play Store Production** | Included with $25 | 3–7 days | Screenshots + data safety + 14-day test | General public |

**Recommended sequence:**
1. Now → Use GitHub APK for defense + validators
2. After pre-final defense → Pay $25 + create Privacy Policy → Internal Testing for SUS survey
3. After final defense → Submit screenshots/listing → Production release

---

*Deployment section added September 21, 2026.*
