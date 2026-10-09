# Kiro → Claude Handoff — SmartSpend v3.0.4
**Date:** October 10, 2026
**From:** Kiro session (Oct 9–10, 2026)
**To:** Claude — continuing all manuscript + research work
**Supersedes:** `kiro-to-claude-handoff-2026-10-09.md`, `kiro-to-claude-handoff-2026-10-06.md`, `claude-to-kiro-handoff-2026-09-12.md` (all now stale)

> **Single source of truth for numbers:** `docs/reference/CAPSTONE_REFERENCE.md`
> **Master to-do list:** `docs/status/PROJECT_STATUS.md`
> **Your previous sync back to Kiro:** `docs/handsoff/claude-to-kiro-sync-2026-10-10.md` — all issues in that doc have been resolved (see §3 below)

---

## 1 — CURRENT APP STATE (v3.0.4)

| Metric | Value | Notes |
|--------|-------|-------|
| Version string | **3.0.4** | pubspec: `3.0.4+102` |
| GitHub Release | https://github.com/Zushikina-kun/smartspend-app/releases/tag/v3.0.4 | APK + AAB built and live |
| APK (arm64, demo phone) | ~45 MB | `SmartSpend-v3.0.4-arm64-v8a.apk` |
| AAB (Play Store) | ~75 MB | `SmartSpend-v3.0.4.aab` |
| Platform | Android (Flutter/Dart) | API 21–36 |
| Primary AI | **Gemini 3.5 Flash-Lite** | AQ. key via Firebase Remote Config |
| AI providers | **9** | 8 cloud + 1 custom local (Ollama/LM Studio/Jan) |
| Agentic actions | **34** | |
| Badges | **25** | |
| Daily AI message limit | **150** (free: 30 — v4.0 gate) | |
| Color themes | **11** | |
| Screens | **43** Dart files | |
| Services | **31** Dart files | |
| SQLite schema | **v14, 26 tables** | added chat_sessions + session_id on chat_history |
| Freemium gates | **Not active yet** — everyone is Pro in v3.x | ProService exists, gates activate in v4.0 |

---

## 2 — NUMBERS TO FIND-AND-REPLACE IN MANUSCRIPT

| Find (stale) | Replace with |
|-------------|-------------|
| Any version ≤ v3.0.3 | **3.0.4** |
| SQLite v13, 25 tables | **SQLite v14, 26 tables** |
| 8 cloud providers / 8-provider chain | **9 providers** (8 cloud + 1 custom local) |
| Gemini 3.1 Flash-Lite | **Gemini 3.5 Flash-Lite** |
| "free forever" / "100% free" / "no subscription" | **"free to download and use"** (v4.0 adds paid tier) |
| 87% margin / $1,082 revenue at 500 Pro | Remove — math was wrong. See §3 for correction. |
| ~33 AI users exhaust Gemini quota / ~6 Pro users | Flag as "verify in AI Studio dashboard" — quota unconfirmed |
| RevenueCat threshold 585 or 2,350 | ~474 yearly purchases in one month (basis: ₱299/yr ÷ ₱56.7/USD = $5.27; $2,500 / $5.27) |
| Snapdragon 8 Gen 3 / Pixel 9 speed benchmark | Galaxy S26 Ultra benchmark: ~47 tok/sec CPU, ~52 GPU (Google AI Edge, 2026) |
| PhilPad/GadgetMatch market data | Remove — unverifiable. Use your own survey respondent data instead. |
| EY 49% stat | Remove — unverified in the comparative research report |
| "qualifies as sensitive personal information" (RA 10173 for financial transactions) | "personal information of a financial nature" — Sec 3(l) does not list financial transactions as sensitive |
| "RA 11765 requires transparency" | Soften — RA 11765 coverage of a capstone prototype is legally unresolved |

---

## 3 — RESOLVED ITEMS (from claude-to-kiro-sync-2026-10-10.md)

These were issues Claude flagged. All resolved:

| Issue | Resolution |
|-------|-----------|
| Local LLM "data never leaves network" — conditionally false | **Fixed in code (v3.0.4):** `_localOnlyMode` flag in AppConfig. Settings → AI → LOCAL AI → "Local-only mode" toggle. When ON, AI fails hard instead of falling back to cloud. |
| Login silently overwrites local account data (data-loss bug) | **Fixed in code (v3.0.4):** `_warnLocalModeIfNeeded()` dialog added to both email login and Google Sign-In. |
| Pricing/margin math wrong | **Fixed in docs:** Scale doc now shows correct ~38% margin at 30 msg/day avg; negative at 150 msg/day cap. |
| RevenueCat threshold inconsistent (585 vs 2,350) | **Fixed in docs:** ~474 yearly purchases/month at ₱299/yr. |
| "₱2,832" leftover text + wrong lifetime savings | **Fixed in docs:** ₱799 vs 4×₱299=₱1,196 → saves ₱397. |
| "₱99/mo CTA" leftover | **Fixed in docs:** ₱59/₱299 CTA. |
| Pixel 9 / Snapdragon 8 Gen 3 attribution | **Fixed in docs:** S26 Ultra benchmark from Google AI Edge. |
| PhilPad/GadgetMatch unverifiable source | **Removed from docs.** |
| EY 49% stat unverified | **Removed from docs.** |
| RA 10173 overclaim (Sec 3(l)) | **Fixed in manuscript blocks.** |
| RA 11765 overclaim | **Softened in manuscript blocks.** |
| 32-bit→14GB quantization error | **Fixed:** 16-bit→14GB. |
| "free forever" inconsistent with v4.0 freemium | **Fixed across website, templates, docs.** |
| Block A "no data transmitted" without condition | **Fixed:** "while the local server is reachable" added. |
| Weak blog/Gist citations in manuscript blocks | **Replaced** with official Google documentation URLs. |
| Insurance screen — stores SSS/PhilHealth ID numbers? | **Confirmed NO** — schema has only name, provider, premium, dates, notes. Safe. |

---

## 4 — OPEN ITEMS FROM SEPTEMBER 12 HANDOFF (still unresolved)

These were flagged in `claude-to-kiro-handoff-2026-09-12.md` and never resolved. Claude needs to either action them or confirm they're no longer needed:

### 4a — FHS Formula: three doc/code mismatches (§3 of Sept 12 handoff)

| Item | Doc says | Code status | Action needed |
|------|----------|-------------|---------------|
| **Budget Adherence** — no budgets → reweight | No active budgets → other 3 components reweight to 33.3 pts each | **Unknown — not verified** | Check `score_service.dart` — does it skip-and-reweight or auto-award 25? If not, either fix code or revert doc. |
| **Category Balance** — fixed-cost exemption | Rent/Tuition/Utilities/Medical excluded from 40% cap | **Unknown — not verified** | Check `score_service.dart` — is there a category exemption list? |
| **Warning Decay** — emergency suspension | Decay suspended for "verified emergency" category | **Likely doesn't exist** | Either build a minimal emergency flag on expenses, or tell Claude to revert to unconditional decay doc. |

### 4b — RA 10173 privacy code claims (§4 of Sept 12 handoff)

The manuscript was updated to say the app does these things. **Kiro has not confirmed if they exist in code:**

| Claim | Exists in code? |
|-------|----------------|
| On-device regex redaction of mobile numbers + e-wallet reference numbers before sending to cloud LLM | **Partial** — PII redaction exists in `ai_chat_service.dart` (phone numbers stripped). Confirm extent. |
| Separate consent toggles for local storage vs cloud backup | **Unknown** — check settings screen |
| Deletes cached receipt images immediately after transaction confirmed | **Unknown** — check `batch_image_import_screen.dart` |

### 4c — Benchmark TBD cells

LLM comparison table in Chapter III still has `TBD` for speed and Filipino-language accuracy on GPT-OSS 20B, Qwen 3.6/3.8, Compound, Compound Mini. Needs an actual benchmark run. Not something Claude can do — Brix needs to run this.

### 4d — Adviser/panel credits (§1 of Sept 12 handoff)

- Adviser: **Ellen F. Mangaoang, MIT** ✅ (confirmed correct)
- Chairperson: still TBA
- Panel: Shekiro R. Raposas + Mary-Ann Mzana (confirm still correct)
- Verzola: removed from current-facing credits — confirm this is done in the app's About screen

---

## 5 — WHAT SHIPPED SINCE CLAUDE'S LAST FULL CONTEXT (v2.9.96 → v3.0.4)

### App features (for manuscript "Implemented Features" section)

**v2.9.97:** AI backdating fix — Today/Yesterday dates in AI context; "kahapon" resolves correctly  
**v2.9.98:** Screenshot import visibility — `[screenshot]` tag in AI context; skipped-dup feedback; sort fix  
**v3.0.0:** Transaction sort/group (7 sort keys, 5 group-by, collapsible headers); Chat sessions DB v14; AI recovery card (✅/⚠️/❌ per item, re-log helper); Analytics Quick Jump + period chip cleanup + category sort toggle  
**v3.0.1:** Demo account overhaul — 18 tables seeded, Reset to Demo Defaults button  
**v3.0.2:** ProService freemium infrastructure (everyone Pro in v3.x); Support links in app/website; APP_FLAVOR build system  
**v3.0.3:** Local Account mode — "Continue Without Account"; data stays on device; Connect Account from Profile  
**v3.0.4:** Login warning dialog for local account users; Local-only mode toggle (Settings → AI → LOCAL AI) — when ON, AI never falls back to cloud if home server unreachable

### Architecture additions (for Chapter III methodology)

- `lib/services/pro_service.dart` — ProService + ProFeature enum (freemium infrastructure)
- `lib/services/auth_service.dart` — `enterLocalMode()`, `isLocalMode()`, `migrateLocalToFirebase()`
- `lib/services/app_config.dart` — `_localOnlyMode` flag + `setLocalOnlyMode()` + `localOnlyMode` getter
- SQLite v14: `chat_sessions` table + `session_id` on `chat_history`
- SharedPreferences keys: `local_mode`, `local_only_mode`, `is_pro_cached` (v4.0)
- `APP_FLAVOR=dev` (never blocks features) / `APP_FLAVOR=prod` (CI/release)

---

## 6 — PRIVACY ARCHITECTURE (updated — for manuscript §3 and defense Q&A)

Three-tier system, all confirmed in code:

| Tier | Status | What it means |
|------|--------|--------------|
| **Cloud AI (default)** | ✅ Implemented | Gemini/Groq/Cerebras via API. PII redacted on-device first. **Free-tier Gemini: Google may use content for product improvement** — Blaze billing changes this. |
| **Local LLM via WiFi** | ✅ Implemented (v2.9.92) | User's own PC running Ollama/LM Studio/Jan. While server reachable, data stays on home network. Local-only mode toggle prevents cloud fallback on failure. |
| **On-device AI** | ⏳ Planned (v5.0) | Firebase AI Logic hybrid inference — Gemini Nano on supported flagships, cloud fallback elsewhere. Experimental as of Oct 2026. |

**Critical for defense Q&A:** If panel asks about the free-tier Gemini privacy concern — confirm that enabling Blaze billing on the project switches to paid API terms which do not include the data-improvement clause. Blaze billing is on the pre-launch checklist.

---

## 7 — FREEMIUM PLAN (v4.0, post-defense)

### Pricing (final, confirmed)
| Plan | Price | Net after Play 15% |
|------|-------|-------------------|
| Monthly | ₱59/month | ~₱50 |
| Yearly | **₱299/year** | ~₱254 — push as default, 7-day trial |
| Lifetime | ₱799 one-time | ~₱679 |

### Economics (corrected — not in manuscript)
- At ₱299/year, ~38% margin if average AI usage is 30 msg/day
- At 150 msg/day cap: AI cost exceeds revenue — 150 is a hard ceiling, not expected average
- Real usage for an expense tracker is likely 10–30 msg/day → margin is viable
- Do NOT put these figures in the manuscript — they're planning numbers for a feature not yet implemented

### Free vs Pro split (summary)
- **Free:** Manual logging, AI chat 30/day, FHS score (always free), pie chart, 50/30/20, 5 budgets, 3 goals, 3 recurring, 2 debts, 1 wallet, basic cloud sync, CSV current month, 7-day chat history
- **Pro gates:** Screenshot/voice/barcode import, 150 AI/day, all analytics depth, multi-wallet, paluwagan/insurance/installments, full sync + backup, unlimited everything, Local LLM, biometric lock

---

## 8 — SCALE RISKS (summary for defense prep — not in manuscript)

1. **Shared Gemini key** exhausts at ~16–33 daily AI users (quota unconfirmed — verify in AI Studio). Fix: per-user keys OR paid Blaze tier.
2. **Firebase Firestore** free tier exhausts at ~1,000 users/day. Fix: enable Blaze billing (~₱55/month at 1,000 users — negligible).
3. **Cerebras** free trial likely expired (30-day trial). Remove from shared pool for new users.
4. **Firebase App Check enforcement** required Nov 2, 2026 for Firebase AI Logic.

Full analysis: `docs/handsoff/scale-and-commercialization-risks-2026-10-09.md`

---

## 9 — ON-DEVICE LLM (for manuscript Chapter I background + Chapter IV future work)

See: `docs/handsoff/on-device-llm-research-2026-10-09.md`  
Manuscript blocks: `docs/handsoff/manuscript-local-llm-sections-2026-10-09.md` (Blocks A–E, corrected)

**Key facts for manuscript (all sourced to official Google pages):**
- Gemini Nano v3 requires 12 GB RAM + flagship SoC — excludes most PH student phones
- Gemma 4 E2B INT4 (~2.6 GB): 6 GB RAM, Android 10+, ~47 tok/sec CPU on Galaxy S26 Ultra (Google AI Edge, 2026)
- Firebase AI Logic hybrid (experimental Oct 2026): auto-routes Nano on-device where available, cloud elsewhere
- LiteRT LM SDK (July 2026): Flutter APIs now available — verify current status at ai.google.dev/edge/litert

**Roadmap for manuscript Chapter IV:**
- v5.0 (~2027): Firebase AI Logic hybrid — when stable
- v6.0 (~2028): Opt-in "Download AI to phone" when 6 GB phones are majority of PH market

---

## 10 — SUPPORT LINKS (live in app + website + README)

| Platform | Link |
|---------|------|
| Buy Me a Coffee | https://buymeacoffee.com/zushikina_kuroh143 |
| Ko-fi | https://ko-fi.com/zushikina143 |
| PayPal | https://paypal.me/BrixDirecto |
| GCash/PayMaya | 09953583040 |

---

## 11 — KEY FILE LOCATIONS

| What | Where |
|------|-------|
| Single source of truth (numbers) | `docs/reference/CAPSTONE_REFERENCE.md` |
| Master to-do | `docs/status/PROJECT_STATUS.md` |
| ProService + ProFeature enum | `lib/services/pro_service.dart` |
| Local mode auth helpers | `lib/services/auth_service.dart` (bottom) |
| Local-only mode toggle | `lib/services/app_config.dart` → `_localOnlyMode` |
| FHS formula | `lib/services/score_service.dart` |
| Demo dataset | `lib/services/demo_service.dart` |
| Freemium plan | `docs/handsoff/freemium-split-plan-2026-10-09.md` |
| Scale risks | `docs/handsoff/scale-and-commercialization-risks-2026-10-09.md` |
| On-device LLM research | `docs/handsoff/on-device-llm-research-2026-10-09.md` |
| Manuscript LLM blocks (corrected) | `docs/handsoff/manuscript-local-llm-sections-2026-10-09.md` |
| Marketing + video script | `docs/handsoff/demo-video-script-and-screenshot-guide-2026-10-09.md` |
| MANUAL_EDIT_GUIDE | `docs/handsoff/MANUAL_EDIT_GUIDE_v3.md` — Part 6 added by Claude (use fixes there) |

---

## 12 — WHAT CLAUDE SHOULD NOT CHANGE

- `docs/handsoff/FHS_Basis_and_Verification.docx` — locked, already verified
- `docs/handsoff/SmartSpend_Comparative_Research_Report.docx` — locked, research final
- `lib/services/score_service.dart` — FHS formula correct as-is; only touch after checking §4a open items with Brix
- Firebase Remote Config keys / `app_config.dart` — never hardcode, never commit to git
- `docs/handsoff/MANUAL_EDIT_GUIDE_v3.md` — Claude owns this file; Kiro should not overwrite it

---

## 13 — WHAT CLAUDE NEEDS FROM BRIX BEFORE NEXT SESSION

1. **FHS code check** (§4a) — confirm or deny: does `score_service.dart` skip-and-reweight when no budgets, have a category exemption list, and have an emergency flag? Answer per-item so Claude can either confirm the manuscript claims or revert them.
2. **RA 10173 code check** (§4b) — confirm: does batch import delete cached images after confirmation? Are there separate local/cloud storage consent toggles?
3. **Gemini quota** — log into AI Studio and check the actual RPD for your AQ. key. Report back so the "~16–33 users" estimate can be confirmed or corrected.
4. **Panel/chairperson** — is the Chairperson still TBA? Has Mary-Ann Mzana been confirmed?
5. **Benchmark TBD cells** — run the Filipino-language test corpus against the 5 unfilled models when you have time. Not urgent for defense but needed before final manuscript submission.

---

*This handoff supersedes all previous Kiro→Claude handoffs. Use v3.0.4 numbers throughout.*
