# SmartSpend — Project Status
**Version:** 2.9.59 | **Academic Year:** 2026–2027, 1st Semester
**Last Updated:** September 27, 2026
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag

> For full technical documentation see `docs/reference/CAPSTONE_REFERENCE.md`
> For feature backlog and planning see `docs/guides/FEATURE_BACKLOG.md`
> For Claude AI handoff (latest) see `docs/manuscript/reseaches/kiro-to-claude-handoff-2026-09-26-v3.md`
> For Codex briefing see `docs/manuscript/reseaches/codex-briefing-2026-09-26.md`

---

## PRE-FINAL DEFENSE — CHECKLIST (Tuesday)

### 🔴 Critical — Must be done before defense day

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Install **v2.9.59** on demo phone | Brix | ❌ | Download `SmartSpend-v2.9.59-arm64-v8a.apk` from GitHub releases |
| Verify About screen shows **"Version 2.9.59"** | Brix | ❌ | kAppVersion auto-syncs from debug_service.dart |
| Reset AI daily limit before demo | Brix | ❌ | AI screen → ⋮ menu → Reset Daily Limit |
| Set AI model to **Auto** before demo | Brix | ❌ | Settings → AI MODEL → Auto (Recommended) |
| Turn on **Lite Mode OFF** for demo (show all features) | Brix | ❌ | Settings → Quick Presets → Lite Mode = OFF |
| Charge demo phone to 100% the night before — do NOT open app | Brix | ❌ | Cold start required for the demo |
| Have WiFi ready for demo | Brix | ❌ | AI needs internet for first message |
| Rehearse demo flow (see script below) | All | ❌ | 10-minute run-through the day before |
| Create **Figure 1.1** — PH financial literacy bar chart | Cyrille | ❌ | BSP CFIS 2025: 50% adults formal accounts; 74% literacy rate |
| Create **Figure 1.2** — IPO conceptual framework diagram | Cyrille | ❌ | Input→Process→Output |
| Create **Figure 2.1** — SUS score interpretation chart | Cyrille | ❌ | Bangor et al. (2009) adjective scale; target ≥80 = Good |
| Create **Figure 2.2** — Kanban board / development methodology | Cyrille | ❌ | Agile Kanban: Backlog → In Progress → Done |
| Fill in **Compliance Matrix** | All | ❌ | `docs/capstone/SmartSpend_Master_Bug_Tracker.docx` |

### 🟠 Manuscript Updates (for Cyrille — use handoff v3 as reference)

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Update version throughout manuscript → **2.9.59** | Cyrille | ❌ | |
| Update manuscript **AI model section**: remove LLaMA, add Auto mode + 8-provider chain | Cyrille | ❌ | See handoff v3 §3a — GPT-OSS/Qwen/Compound/Cerebras |
| Update manuscript **FHS equations** (v2.9.42 changes) | Cyrille | ❌ | 4 × 25pt components; overspend nuance; category exemptions |
| Update manuscript **agentic action count** → 34 | Cyrille | ❌ | Was 31 in some sections |
| Update manuscript **badge count** → 25 | Cyrille | ❌ | +No-Spend Day + No-Spend Streak |
| Update manuscript **daily AI limit** → 150 | Cyrille | ❌ | Was 60 |
| Update manuscript **color theme count** → 10 | Cyrille | ❌ | +5 new themes v2.9.45 |
| Update manuscript **hub tile count** → 26 | Cyrille | ❌ | Expanded v2.9.44 |
| Update **settings toggles** → 10 home, 4 analytics, 14 Lite Mode | Cyrille | ❌ | New in v2.9.53–59: payday countdown, monthly recap, challenges, safe-to-spend |
| Add to Implemented: savings rate chart, quick budget slider, analytics cache | Cyrille | ❌ | All v2.9.45 |
| Add to Implemented: nav bar fix, Auto AI, chat export, payday countdown, monthly recap, semester interval, auto-cat evidence, safe-to-spend, share intent, AI disclaimer | Cyrille | ❌ | v2.9.50–2.9.59 — see handoff v3 §6 |
| Add **RA 10173 PII redaction** to Ch.2/Ch.3 | Cyrille | ❌ | Mobile numbers stripped before LLM — v2.9.42 |
| Add **AI financial advice disclaimer** to Ch.2/Ch.3 | Cyrille | ❌ | RA 11765 — one-time dialog added v2.9.59 |
| Add **Safe-to-Spend** to features list | Cyrille | ❌ | BudgetPH differentiator — implemented v2.9.59 |
| Add **Agila, PISO, BunnyWise, MayBudget** to competitor table | Cyrille | ❌ | See FEATURE_BACKLOG Part 10 + Part 3 |
| BSP citation update Ch.1: 2021 → CFIS 2025 | Cyrille | ❌ | |
| Move **Paluwagan** to Implemented | Cyrille | ✅ | Done |

### 🟡 Post-Defense (before final)

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| SUS survey — 30 respondents | Djaunathan | ❌ | 20 parents + 10 young professionals |
| Google Play Console account ($25) | Brix | ❌ | Required for Play Store |
| Build AAB: `flutter build appbundle --release --obfuscate` | Brix | ❌ | For Play Store submission |
| Privacy Policy hosted page | Cyrille | ❌ | Required by Play Store |
| Firebase App Check enforcement | Brix | ❌ | Switch from monitoring to enforcement |
| Validator signatures — Appendix A | Brix | ❌ | |
| SUS survey results → manuscript Ch.3 | Cyrille | ❌ | |
| CV section all three researchers | All | ❌ | |

---

## DEMO SCRIPT — Pre-Final Defense (v2.9.59)

### Night before
1. Download `SmartSpend-v2.9.59-arm64-v8a.apk` from https://github.com/Zushikina-kun/smartspend-app/releases
2. Install on demo phone
3. Open app → verify About screen shows **"Version 2.9.59"**
4. Settings → Quick Presets → **Lite Mode OFF** (show all features)
5. Settings → AI MODEL → **Auto (Recommended)**
6. AI screen → ⋮ → **Reset Daily Limit**
7. Charge to 100%, do NOT open the app again until demo

### Demo flow (~10 minutes)

**1. Opening (1 min)**
- Open app cold → show Home screen with live data
- Point out: FHS score, this month's spending, Safe-to-Spend card, AI Insights

**2. Core feature — AI logging (2 min)**
- Tap AI chat → type: `"I spent 60 for lunch and 30 for jeep"`
- Show AI logging 2 expenses in one message
- Show the expenses appear in Recent list
- Explain: 34 agentic actions, not just chat

**3. Safe-to-Spend card (1 min)**
- Go back to Home → point to the 💚 Safe to Spend card
- Explain: wallet balance minus upcoming bills/goals/debts before next payday
- BudgetPH differentiator — the one number that matters

**4. Import feature (2 min)**
- Tap Log Expense → Batch Screenshots → show the 40+ platform support
- Import a Shopee screenshot → show AI parsing the items
- Explain: OCR + AI, works offline for manual entry

**5. Financial Health Score (1 min)**
- Tap the FHS score card → show breakdown dialog
- Explain the 4 components and why it's more meaningful than a simple budget tracker

**6. Analytics (1 min)**
- Tap Analytics tab → show pie chart, 50/30/20, DTI, Want vs Need
- Point out: these are computed locally, no internet needed

**7. Competitive positioning (1 min)**
- Only free Filipino-English AI finance app with 34 agentic actions
- Only app with batch screenshot import (40+ platforms)
- Only dual-mode FHS (full + lightweight)
- Safe-to-Spend closes the BudgetPH gap

**8. Settings / user control (1 min)**
- Settings → Quick Presets → show Lite Mode (hides 14 optional sections)
- Explain: designed for new users — not overwhelming

---

## AUTHORITATIVE BUILD NUMBERS (v2.9.59)

| Metric | Value |
|--------|-------|
| Version | **2.9.59+59** |
| APK sizes | arm64-v8a ~46.7 MB, armeabi-v7a ~39.4 MB, x86_64 ~49.7 MB |
| SQLite schema | v11, 20 tables |
| AI providers | **8** (Gemini Flash, Flash-Lite, GPT-OSS 120B Groq, Qwen3.6, Qwen3.8, Compound, Compound Mini, Cerebras) |
| Default AI model | **Auto** (task-based routing) |
| Agentic actions | **34** |
| Input modalities | **7** (voice, text, camera, screenshots, barcode, OCR, share intent) |
| Screens | 41 Dart files |
| Services | 29 Dart files |
| Achievement badges | **25** |
| Daily AI limit | **150 messages/day** |
| Color themes | **10** |
| Daily quests | **10** |
| Hub tiles | **26** |
| Currencies | **57** |
| Batch platforms | **40+** |
| Filipino item catalog | **150+ items** |
| Optional home toggles | **10** |
| Optional analytics toggles | **4** |
| Lite Mode coverage | **14 sections** |
| PH banks in DB | 20 banks + 5 e-wallets |
| Log choice options | **7** |
| Min Android SDK | API 21 (Android 5.0) |
| Target Android SDK | API 36 |

---

## RECENT RELEASE HISTORY (for reference)

| Version | Key changes |
|---------|------------|
| v2.9.59 | Safe-to-Spend card, AI advice disclaimer, confidence badge, GCash share intent, action allowlist |
| v2.9.58 | Empty state overflow fixes (insurance, paluwagan); FAB list clipping (5 screens); rollover bug |
| v2.9.57 | AI chat chips overlapping input fixed; viewPadding on AI screen |
| v2.9.56 | AI fail-fast when Remote Config keys not loaded |
| v2.9.55 | Keys moved to Firebase Remote Config — no secrets in git |
| v2.9.54 | Groq API key rotated after exposure |
| v2.9.53 | 3 new home screen toggles; Lite Mode → 13 sections |
| v2.9.52 | Tier 1: payday countdown, monthly recap, chat export, auto-cat evidence, semester interval |
| v2.9.51 | Critical: AI fallback chain silently failing |
| v2.9.50 | Nav bar overlap all 8 screens; Auto AI model; smarter failover |
