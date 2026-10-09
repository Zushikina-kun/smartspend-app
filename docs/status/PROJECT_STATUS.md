# SmartSpend — Project Status & Master To-Do List
**Version:** 3.0.2 | **Academic Year:** 2026–2027, 1st Semester
**Last Updated:** October 9, 2026
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag

> Full docs index:
> - Technical reference → `docs/reference/CAPSTONE_REFERENCE.md`
> - Feature backlog → `docs/guides/FEATURE_BACKLOG.md`
> - Latest AI handoff → `docs/handsoff/kiro-to-kiro-handoff-v3.0.0-2026-10-09.md`
> - Freemium plan → `docs/handsoff/freemium-split-plan-2026-10-09.md`
> - Marketing plan → `docs/handsoff/marketing-and-demo-plan-2026-10-09.md`
> - Scale & risks → `docs/handsoff/scale-and-commercialization-risks-2026-10-09.md`

---

## AUTHORITATIVE BUILD NUMBERS (v3.0.2)

| Metric | Value |
|--------|-------|
| Version string | **3.0.4** |
| pubspec | `3.0.4+102` |
| GitHub Release | https://github.com/Zushikina-kun/smartspend-app/releases/tag/v3.0.4 |
| APK (arm64, demo phone) | **~45 MB** — `SmartSpend-v3.0.4-arm64-v8a.apk` |
| AAB (Play Store ready) | **~75 MB** — `SmartSpend-v3.0.4.aab` |
| Platform | Android (Flutter/Dart) |
| Min SDK | API 21 (Android 5.0) |
| Target SDK | API 36 (Android 16) |
| SQLite schema | **v14, 26 tables** |
| AI providers | **9** (8 cloud + 1 custom local) |
| Primary AI model | Gemini 3.5 Flash-Lite (AQ. key via Firebase Remote Config) |
| Agentic actions | **34** |
| Input modalities | **7** |
| Screens | **43** Dart files |
| Services | **31** Dart files |
| Achievement badges | **25** |
| Daily AI message limit | **150** |
| Color themes | **11** |
| Batch screenshot platforms | 40+ |
| Currencies | 57 |
| Optional home toggles | 14 |
| ProService | Exists — everyone is Pro in v3.x, gates activate in v4.0 |
| Build flavor | `APP_FLAVOR=dev` local · `APP_FLAVOR=prod` CI |

---

## PHASE 1 — CAPSTONE DEFENSE (do these first)

### 🔴 P0 — Must be done before defense day

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Install **v3.0.4** on demo phone | Brix | ❌ | Download `SmartSpend-v3.0.4-arm64-v8a.apk` from GitHub Releases |
| Verify About screen shows **"Version 3.0.4"** | Brix | ❌ | kAppVersion in debug_service.dart |
| Load demo data on phone | Brix | ❌ | "Try Demo" on login screen OR Profile → Load Demo Data |
| Reset AI daily limit before demo | Brix | ❌ | AI screen → ⋮ → Reset Daily Limit |
| Set AI model to **Auto** | Brix | ❌ | Settings → AI MODEL → Auto (Recommended) |
| Set preset to **Normal** or **Pro** | Brix | ❌ | Settings → Quick Presets — Lite Mode must be OFF |
| Charge phone to 100%, do NOT re-open until demo | Brix | ❌ | Cold start required |
| Have WiFi ready | Brix | ❌ | AI needs internet; Gemini key fetched from Remote Config on first open |
| Rehearse demo flow (see script below) | All | ❌ | 10-min run-through the day before |
| Create **Figure 1.1** — PH financial literacy bar chart | Cyrille | ❌ | BSP CFIS 2025: 50% adults with formal accounts; 74% literacy rate |
| Create **Figure 1.2** — IPO conceptual framework diagram | Cyrille | ❌ | Input → Process → Output |
| Create **Figure 2.1** — SUS score interpretation chart | Cyrille | ❌ | Bangor et al. (2009) adjective scale; target ≥80 = Good |
| Create **Figure 2.2** — Kanban board / development methodology | Cyrille | ❌ | Agile Kanban: Backlog → In Progress → Done |
| Fill in **Compliance Matrix** | All | ❌ | `docs/capstone/SmartSpend_Master_Bug_Tracker.docx` |

### 🟠 P1 — Manuscript Updates (for Cyrille)

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Update version throughout → **3.0.2** | Cyrille | ❌ | Use CAPSTONE_REFERENCE.md as source of truth |
| Update SQLite schema → **v14, 26 tables** | Cyrille | ❌ | v14 adds chat_sessions + session_id on chat_history |
| Update AI section: 9 providers, Gemini 3.5 Flash-Lite, AQ. key, Remote Config, Local AI private mode | Cyrille | ❌ | |
| Update FHS: 4 × 25pt components, soft/hard overspend distinction | Cyrille | ❌ | |
| Update agentic action count → **34** | Cyrille | ❌ | |
| Update badge count → **25** | Cyrille | ❌ | |
| Update daily AI limit → **150** | Cyrille | ❌ | |
| Update color theme count → **11** | Cyrille | ❌ | |
| Update screens count → **43** | Cyrille | ❌ | |
| Update APK size → **~45 MB** (arm64, split, obfuscated) | Cyrille | ❌ | |
| Add to Implemented: Transaction sort/group, Chat sessions, AI recovery card, Analytics quick-jump (v3.0.0) | Cyrille | ❌ | Shipped Oct 9 |
| Add to Implemented: Peso mascot, Safe-to-Spend, Full audit trail, History viewers, Data Quality, Local AI (v2.9.76–v2.9.92) | Cyrille | ❌ | |
| Add AI financial advice disclaimer (RA 11765) to Ch.2/Ch.3 | Cyrille | ❌ | |
| Add Safe-to-Spend to features list | Cyrille | ❌ | BudgetPH differentiator |
| Add **Agila, PISO, BunnyWise** to competitor table | Cyrille | ❌ | Agila = free, PISO = free, Tarsi = ~₱300 one-time |
| BSP citation update Ch.1: 2021 → CFIS 2025 | Cyrille | ❌ | |
| **Add Local LLM + on-device AI to manuscript** | Cyrille | ❌ | Copy-paste blocks in `manuscript-local-llm-sections-2026-10-09.md` — Blocks A–E for Ch.2, Ch.3, Ch.5 |
| Paluwagan moved to Implemented | Cyrille | ✅ | Done |

### 🟡 P2 — Post-Defense (before final submission)

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| SUS survey — 30 respondents | Djaunathan | ❌ | 20 parents + 10 young professionals |
| SUS survey results → manuscript Ch.3 | Cyrille | ❌ | |
| Validator signatures — Appendix A | Brix | ❌ | |
| CV section — all three researchers | All | ❌ | |

---

## PHASE 2 — PRE-LAUNCH (before Play Store + v4.0)

These must be done before any public release. See `docs/handsoff/scale-and-commercialization-risks-2026-10-09.md` for full details.

### 🔴 P0 — Critical infrastructure (blocks launch)

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| **Enable Firebase Blaze billing** with ₱500/month spending cap | Brix | ❌ | App breaks for sync at ~1,000 users on Spark free plan. Blaze costs ~₱55/month at 1,000 users. |
| **Google Play Console account** ($25 one-time) | Brix | ❌ | Required before any IAP or Play Store listing |
| **Fill Google Play data safety form** | Cyrille | ❌ | Declare: financial data (local), Firebase Auth (email/name), AI queries (third-party API), no data sold |
| **Switch App Check → Play Integrity** | Brix | ❌ | Test on Internal Testing track first. Current debug mode won't protect production. |
| **Add "Use your own Gemini key" setting** | Brix | ❌ | Settings → AI → paste own AQ. key. Fixes shared key exhaustion at scale. One free key per user = 1,000 RPD each. |
| **Remove Cerebras from shared pool / check trial status** | Brix | ❌ | Cerebras free tier is 30-day trial. Likely expired. Detect on init and log in debug. |

### 🟠 P1 — App Store listing & marketing

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Set up Google Play Internal Testing track | Brix | ❌ | Required to test real IAP purchases before public release |
| Create Play Store listing (metadata ready in marketing plan doc) | Cyrille | ❌ | Short desc, full desc, keywords, screenshots, category |
| Take 8 Play Store screenshots from demo phone | Brix | ❌ | Priority order + shot-by-shot guide in `demo-video-script-and-screenshot-guide-2026-10-09.md` |
| Make screenshot overlays in Canva | Cyrille | ❌ | Design specs (1080×1920, dark bg, Emerald accent) in guide doc |
| Record 60-second demo video | Brix | ❌ | Full 8-shot script with timing + recording tips in guide doc |
| Edit video in CapCut | Brix / Cyrille | ❌ | Editing steps in guide doc. Export 1080p MP4. |
| Upload video to YouTube (unlisted first) | Brix | ❌ | Review before making public |
| Add screenshots + video to website | Cyrille | ❌ | Website update checklist in guide doc |
| Post launch announcement on Facebook + TikTok | All | ❌ | Captions + TikTok script in guide doc |
| Post in r/PersonalFinancePhilippines | Brix | ❌ | Reddit post template in guide doc |
| Twitter/X launch thread | Brix | ❌ | 7-tweet thread template in guide doc |
| Set up Ko-fi page (already linked in app/website) | Brix | ❌ | https://ko-fi.com/zushikina143 — verify it's active |
| Enable email verification in Firebase Auth | Brix | ❌ | One config toggle in Firebase Console. Prevents fake accounts. |

### 🟡 P2 — Nice to have before launch

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Export Firestore security rules to `firestore.rules` in repo | Brix | ❌ | Backup in case of accidental wipe |
| Add Firebase Analytics event tracking | Brix | ❌ | `ai_message_sent`, `pro_paywall_shown`, `pro_purchased`, `screenshot_import_used` |
| Set up Google Cloud billing budget alerts | Brix | ❌ | Alert at $5/mo and $20/mo — prevents surprise bills |
| Add Batch Write optimization for Firestore | Brix | ❌ | Group 10–20 writes per batch. Reduces costs + prevents quota spikes. |

---

## PHASE 3 — v4.0 FREEMIUM IMPLEMENTATION (post-defense)

See `docs/handsoff/freemium-split-plan-2026-10-09.md` for full spec.

**Pricing:** ₱59/month · ₱299/year (7-day trial) · ₱799 lifetime

### 🔴 P0 — Infrastructure before any gates

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Create 3 IAP products in Play Console | Brix | ❌ | `smartspend_pro_monthly`, `smartspend_pro_yearly`, `smartspend_pro_lifetime` |
| Create RevenueCat project | Brix | ❌ | Free at revenuecat.com. Link Play Console products. |
| Add `purchases_flutter: ^8.0.0` to pubspec | Brix | ❌ | RevenueCat Flutter SDK |
| Replace ProService.init() stub with real RevenueCat call | Brix | ❌ | See stub comments in `lib/services/pro_service.dart` |
| Build `ProPaywallScreen` widget | Brix | ❌ | Monthly / Yearly / Lifetime plans. Restore Purchase link. 7-day trial on yearly. |
| Build `ProGate` widget | Brix | ❌ | Wraps any Pro-only feature. Shows locked teaser if not Pro. |

### 🟠 P1 — Feature gates (phase by phase)

| Phase | Task | Status |
|-------|------|--------|
| v4.0.1 | Gate AI imports: screenshot, voice, barcode, bank paste | ❌ |
| v4.0.1 | 30 msg/day free vs 150 msg/day Pro | ❌ |
| v4.0.2 | Gate analytics depth: all period filters, monthly chart, daily trend, heatmap, FHS history | ❌ |
| v4.0.3 | Gate wallets (1 free vs unlimited Pro); budget/goal/recurring/debt caps (5/3/3/2 free) | ❌ |
| v4.0.4 | Gate power tools: paluwagan, insurance, installments, PCA, debt payoff, bill calendar | ❌ |
| v4.0.5 | Gate data: full cloud sync, backup/restore, full CSV export, unlimited custom categories, rules | ❌ |
| v4.0.6 | Gate UI/gamification: all themes, all badges, weekly/monthly challenges, biometric lock | ❌ |

### 🟡 P2 — Scale hardening for v4.0

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Build Cloud Functions AI proxy | Brix | ❌ | Server-side Gemini key. Enforces per-user limits. Replaces Remote Config key delivery. |
| Move daily AI limit counter to Firestore (server-side) | Brix | ❌ | Currently SharedPreferences — resettable by factory reset |
| Add per-user Gemini key support in Settings | Brix | ❌ | Users paste own free AQ. key. Distributes quota. |

---

## PHASE 4 — GROWTH & MONETIZATION (post v4.0)

These are longer-term items for when the app has real users.

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Move to paid Gemini API tier | Brix | ❌ | Enable when Pro subscriptions cover the cost (~$135/month at 1,000 Pro users) |
| App Store submission for iOS (Swift/Kotlin wrapper) | TBD | ❌ | Significant effort — Flutter supports iOS but needs Apple Dev account ($99/year) |
| Explore BSP Open Finance API integration | Brix | ❌ | Would enable real bank feeds. Requires regulatory compliance (BSP Circular 1105). Not currently feasible. |
| **Firebase AI Logic hybrid inference** | Brix | ❌ | When stable (experimental Oct 2026): SDK auto-routes to Gemini Nano on-device for supported phones, cloud fallback for others. Zero code change for users. See `on-device-llm-research-2026-10-09.md` |
| **Opt-in On-Device AI download** | Brix | ❌ | Gemma 4 E2B INT4 (~2.6 GB) via LiteRT LM SDK. Settings → AI → "Download AI to phone". Viable when 6 GB RAM phones are majority of PH market (~2028). See research doc. |
| SmartSpend Teams plan (₱299/month, 5 users) | Brix | ❌ | Shared budgets, family expense view, group goals. Plan documented. |
| Notification Listener Service | Brix | ❌ | Alternative to READ_SMS (blocked by Play Policy). Captures GCash/bank notification text. Needs user opt-in in Accessibility settings. |
| Full monthly GitHub-style heatmap (analytics) | Brix | ❌ | 28–31 cell per-date spending grid. Partially built (week heatmap exists). |
| True net worth chart | Brix | ❌ | Snapshot-based over time (not FHS proxy). |
| Receipt photo gallery (Hub → Receipts) | Brix | ❌ | photo_path field exists on expenses; just needs a GridView UI. |

---

## DEMO SCRIPT — Final Defense (v3.0.2)

### Night before
1. Download `SmartSpend-v3.0.2-arm64-v8a.apk` from https://github.com/Zushikina-kun/smartspend-app/releases/tag/v3.0.2
2. Install on demo phone
3. Tap **"Try Demo"** on login screen → loads full dataset automatically
4. Verify Home shows FHS ~80, 3 goals, Safe-to-Spend card
5. Settings → Quick Presets → **Normal** or **Pro**
6. Settings → AI MODEL → **Auto (Recommended)**
7. AI screen → ⋮ → **Reset Daily Limit**
8. Charge to 100%, do NOT re-open until demo

### Demo flow (~10 minutes)

**1. Opening (1 min)** — Cold start → Home screen → FHS 80, Safe-to-Spend, AI Insights, goal timeline

**2. AI logging (2 min)** — Type `"I spent 65 for lunch and 30 for jeep"` → 2 expenses logged → session summary card (✅ 2 recorded)

**3. Safe-to-Spend (1 min)** — Home → 💚 card → "wallet minus upcoming bills = what's safe to spend"

**4. Screenshot import (2 min)** — Log → Batch Screenshots → pick Shopee/GCash → AI parses → review

**5. FHS breakdown (1 min)** — Tap score → 4-component dialog → explain savings rate, overspend control, etc.

**6. Analytics (1 min)** — Quick Jump → Overview → pie chart → 50/30/20 → category sort toggle

**7. Transactions (1 min)** — ⇅ Sort/Group → Group by category → collapsible headers

**8. Positioning (1 min)** — Only Filipino AI finance app with 34 agentic actions + Local LLM + 40+ platform screenshot import

---

## RECENT RELEASE HISTORY

| Version | Date | Key changes |
|---------|------|------------|
| **v3.0.4** | Oct 10, 2026 | Local-only mode toggle (Settings → AI → Local AI); login warning dialog for local account users; doc fixes from Claude sync (pricing math, Gemini quota warning, RA 10173 overclaim, Pixel 9/Snapdragon attribution, "free forever" removed) |
| **v3.0.3** | Oct 9, 2026 | Local Account mode (continue without Firebase account, data stays on device, connect later); profile screen loads for local users; local→Firebase migration preserves data on register |
| **v3.0.1** | Oct 9, 2026 | Demo account overhaul — full dataset across all screens, Reset to Demo Defaults button |
| **v3.0.2** | Oct 9, 2026 | ProService infra for freemium; APP_FLAVOR dev/prod; url_launcher + support links; demo account overhaul (18 tables, Reset button) |
| v2.9.98 | Oct 2026 | Screenshot import visibility; skipped-dup AI feedback; sort fix |
| v2.9.97 | Oct 2026 | AI backdating fix: yesterday/kahapon, NOT-RECORDED CHECK |
| v2.9.92 | Oct 2026 | Local AI private mode (9th provider) |
| v2.9.90 | Oct 2026 | 10-item re-audit fixes |
| v2.9.89 | Oct 2026 | DB v13 full audit trail |
| v2.9.88 | Oct 2026 | Wallet history, App Check debug token |
| v2.9.87 | Sep 2026 | Installment Plans tab fix, Data Quality fixes |
| v2.9.84 | Sep 2026 | Achievement celebrations, analytics interpretive labels |
| v2.9.82 | Sep 2026 | App-wide QoL polish (43 screens) |
