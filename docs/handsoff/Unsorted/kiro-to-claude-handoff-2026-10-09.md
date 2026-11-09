# Kiro → Claude Handoff — SmartSpend v3.0.3
**Date:** October 9, 2026
**From:** Kiro session (Oct 9, 2026)
**To:** Claude (or any AI continuing this project)
**Purpose:** Complete sync of everything that happened since the last Claude handoff (v2.9.96 → v3.0.3). Use `docs/reference/CAPSTONE_REFERENCE.md` as the single source of truth for capstone numbers. Use `docs/status/PROJECT_STATUS.md` as the master to-do list.

---

## 1 — CURRENT APP STATE (v3.0.3)

| Metric | Value | Notes |
|--------|-------|-------|
| Version string | **3.0.3** | pubspec: `3.0.3+101` |
| GitHub Release | https://github.com/Zushikina-kun/smartspend-app/releases/tag/v3.0.3 | APK + AAB built by CI |
| APK (arm64) | ~45 MB | `SmartSpend-v3.0.3-arm64-v8a.apk` |
| AAB | ~75 MB | Play Store bundle |
| Platform | Android (Flutter/Dart) | API 21–36 |
| Primary AI | **Gemini 3.5 Flash-Lite** | AQ. key via Firebase Remote Config |
| AI providers | **9** | 8 cloud + 1 custom local (Ollama/LM Studio/Jan) |
| Agentic actions | **34** | |
| Badges | **25** | |
| Daily AI limit | **150** | free limit: 30 (planned for v4.0) |
| Color themes | **11** | |
| Screens | **43** Dart files | |
| Services | **31** Dart files | |
| SQLite schema | **v14, 26 tables** | v14 adds chat_sessions + session_id on chat_history |
| GitHub | https://github.com/Zushikina-kun/smartspend-app | |
| Website | https://zushikina-kun.github.io/smartspend-app/ | support links in footer |
| Privacy Policy | https://zushikina-kun.github.io/smartspend-app/privacy.html | |

---

## 2 — NUMBERS TO UPDATE IN MANUSCRIPT (v2.9.96 → v3.0.3)

| Find (stale) | Replace with |
|-------------|-------------|
| v2.9.96 / 2.9.97 / 2.9.98 / 3.0.0 | **3.0.3** |
| SQLite v13, 25 tables | **SQLite v14, 26 tables** |
| 8 cloud providers | **9 providers** (8 cloud + 1 custom local) |
| Gemini 3.1 Flash-Lite | **Gemini 3.5 Flash-Lite** |

Everything else (34 actions, 25 badges, 11 themes, 43 screens, ~45 MB) is unchanged from the v2.9.96 handoff.

---

## 3 — WHAT SHIPPED SINCE v2.9.96 (for manuscript "Implemented Features" list)

### v2.9.97 — AI Backdating Fix
- AI context header now includes `Today: YYYY-MM-DD | Yesterday: YYYY-MM-DD`
- "yesterday" / "kahapon" → correctly resolved to yesterday's date (not today)
- NOT-RECORDED CHECK added: AI checks if item is already in DB before re-logging

### v2.9.98 — Screenshot Import Visibility
- `[screenshot]` source tag added to AI context for batch-imported items
- `_sessionSkippedLog` → `ALREADY IN DB` note fed to AI so it knows what was blocked by the duplicate guard
- Sort fix for 00:00 time items (screenshot imports now sort correctly)

### v3.0.0 — Four Major Feature Groups (all shipped Oct 9)
**A — Transaction Sort & Group:**
- 7 sort keys: Transaction date (default) · Logged date · Amount ↑/↓ · Name A→Z/Z→A · Source
- 5 group-by options: Transaction date · Logged date · Category (with ₱ subtotal) · Source · None
- Collapsible group headers (tap to expand/collapse)
- Category filter replaced with compact `DropdownButton` (no more 20+ overflowing chips)
- Want/Need/⚠️ chips consolidated into a single Row 2
- Sort + group persisted to SharedPreferences

**D — Chat Sessions / Wayback (DB v14):**
- New `chat_sessions` table; `session_id` column added to `chat_history`
- All existing messages migrated to "Previous chats" session on upgrade
- "New Chat" ➕ button in AI screen AppBar — saves current session, starts fresh
- `ChatHistoryScreen` redesigned: session list (Active · Recent · Older · Archived) → session detail view
- Per-session: rename, archive, delete, copy-to-clipboard export
- Logout clears both tables

**C — AI Recovery:**
- `AiSessionResultItem` + `AiItemStatus` types in `ai_chat_service.dart`
- Session summary card after each response with log_expense actions: ✅/⚠️/❌ per item
- "Review & re-log" button opens `_RelogHelperSheet` — editable name/amount/date, direct DB insert
- Fallback retry path also updates summary card

**B — Analytics:**
- Quick Jump anchor chips (Overview · Trends · Health · AI Advice) at top of screen
- Period chips: 4 primary + "More ▾" popup menu (Payday Cycle, Pick Month, Custom)
- Category breakdown sort toggle: ▼ Amount · ↑ Name · Δ vs last month
- Color dots in breakdown now match pie chart legend (uses original index)

### v3.0.1 — Demo Account Overhaul
- `demo_service.dart` completely rewritten — 18 tables seeded with realistic Filipino student data
- Profile, 3 wallets with history, 35 expenses across 3 months, 9 budgets, 3 goals, 4 recurring, 3 debts, 2 installment plans, 4 insurance/contributions, 2 paluwagan groups, 30-day score history, 14-day mood log, 25 category rules, chat seed
- "Reset to Demo Defaults" button (orange) in Profile → reloads full seed

### v3.0.2 — Support Links + ProService Infrastructure
- `url_launcher` added; About screen has "Support the Project" section (Buy Me a Coffee, Ko-fi, PayPal, GCash copy)
- Support links in website footer and README
- `ProService` + `ProFeature` enum created in `lib/services/pro_service.dart` — everyone is Pro in v3.x, gates activate in v4.0
- `APP_FLAVOR=dev` (local, always Pro) / `APP_FLAVOR=prod` (CI/release builds)
- CI passes `--dart-define=APP_FLAVOR=prod`

### v3.0.3 — Local Account Mode
- "Continue Without Account" button on login screen — permanent offline-first account
- Data lives on device only; user can export via CSV or backup anytime
- Profile screen shows "Local Account" card with "Connect Account" + "Register Free" buttons
- Home screen banner: Local Account (blue, dismissible) vs Demo Mode (orange) vs no banner (Firebase user)
- `auth_service.dart`: `enterLocalMode()`, `isLocalMode()`, `migrateLocalToFirebase()`
- `splash_screen.dart`: recognizes `local_mode` flag, routes to SetupScreen (first time) or Home
- Local mode register: pushes local data to new Firebase account BEFORE clearing (data preserved)
- Local mode login: cloud data replaces local (intentional — user chose login over register)

---

## 4 — ARCHITECTURE THAT CHANGED

### New SharedPreferences keys
| Key | Values | Meaning |
|-----|--------|---------|
| `local_mode` | `true` / not set | User chose "Continue Without Account" |
| `was_demo_mode` | `true` / not set | User tapped "Try Demo" (sample data) |
| `is_pro_cached` | `true`/`false` | RevenueCat entitlement cache (v4.0+) |
| `APP_FLAVOR` | `dev` / `prod` | Compile-time dart-define, not runtime |

### New DB tables (v14)
```sql
-- chat_sessions — one row per chat session
CREATE TABLE chat_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  created_at TEXT NOT NULL,
  archived_at TEXT,
  is_current INTEGER DEFAULT 0
);

-- chat_history gains session_id
ALTER TABLE chat_history ADD COLUMN session_id INTEGER;
```

### New services / key classes
| File | Purpose |
|------|---------|
| `lib/services/pro_service.dart` | ProService + ProFeature enum — freemium gate infrastructure |
| `lib/services/auth_service.dart` | Added `enterLocalMode()`, `isLocalMode()`, `migrateLocalToFirebase()` |

### Behavior changes for local mode users
- `CloudService._shouldSkipSync` returns `true` when `currentUser == null` → already handled, no change
- `DBService.saveProfile()` now called with `uid='local_user'` for local mode users
- `demo_service.dart` uses `uid='demo_user'` for demo profiles — separate from local
- `app_lock_service.dart` uses `uid ?? 'demo'` — local mode users share the `'demo'` PIN key (acceptable, same device)

---

## 5 — FREEMIUM PLAN (planned for v4.0, post-defense)

Full spec: `docs/handsoff/freemium-split-plan-2026-10-09.md`

### Pricing
| Plan | Price | Net (after Play 15%) |
|------|-------|----------------------|
| Monthly | ₱59/month | ~₱50 |
| Yearly | **₱299/year** | ~₱254 — push as default, 7-day trial |
| Lifetime | ₱799 one-time | ~₱679 |

### Free tier (what stays free forever)
- Manual logging, AI text chat (30 msg/day), FHS score + explanation, pie chart (current month), 50/30/20 basic, 5 budgets/3 goals/3 recurring/2 debts/1 wallet, basic cloud sync (expenses + budgets + goals), CSV export (current month), Chat History (last 7 days), 3 themes, first 10 badges

### Pro gates (what requires payment)
- Screenshot/voice/barcode/bank import, 150 AI messages/day, all analytics depth, multi-wallet, paluwagan/insurance/installments, full cloud sync + backup, unlimited everything, all themes/badges, Local LLM, biometric lock

### Implementation
- `ProService` already exists — everyone is Pro in v3.x, no gates active
- `purchases_flutter` (RevenueCat) not yet added — do this in v4.0
- `ProPaywallScreen` not yet built — do this in v4.0

---

## 6 — SCALE & COMMERCIALIZATION RISKS

Full analysis: `docs/handsoff/scale-and-commercialization-risks-2026-10-09.md`

### Critical actions before launch (in priority order)
1. **Enable Firebase Blaze billing** with ₱500/month spending cap — app breaks at ~1,000 users on Spark free plan. Blaze costs ~₱55/month at 1,000 users.
2. **Fix shared Gemini key** — add "Use your own Gemini key" setting. 1,000 RPD free key exhausts at ~33 Pro users/day. Per-user keys = each user gets their own 1,000 RPD.
3. **Cerebras trial likely expired** — detect on init, log in debug, remove from shared pool for new users.
4. **Google Play Console** ($25) — before any IAP or Play Store listing.
5. **Data safety form** — declare financial data (local), Firebase Auth (email/name), AI queries (third-party), no data sold.
6. **App Check → Play Integrity** — test on Internal Testing track first; enforcement required November 2, 2026 for Firebase AI Logic.

### Cost at 1,000 MAUs
- Firestore: ~₱55/month (negligible)
- Gemini API: ~$135/month (if per-user keys used for free tier, ~$135 only for Pro users)
- RevenueCat: free until $2,500 MTR (~585 yearly Pro subscribers)
- **Revenue at 500 Pro × ₱299/year**: ~$1,082/month → **87% margin**

---

## 7 — ON-DEVICE LLM ROADMAP

Full research: `docs/handsoff/on-device-llm-research-2026-10-09.md`

### TL;DR
- **Gemini Nano v3** (on-device): requires 12 GB RAM + flagship chip — excludes 95%+ of PH student market
- **MediaPipe + Gemma 4 E2B** (on-device download): ~2.6 GB, needs 6 GB RAM Android 10+ — more accessible but still premium
- **Firebase AI Logic Hybrid** (experimental 2026): BEST PATH — auto-routes to Nano on supported devices, cloud fallback everywhere else. One SDK, no branching code. Wait for stable release.
- **Current LLM via WiFi tier** (Ollama/LM Studio): already shipped in v2.9.92 ✅

### Roadmap
- v5.0 (~2027): Firebase AI Logic hybrid — when stable
- v6.0 (~2028): Opt-in "Download AI to phone" — when 6 GB phones are majority of PH market

---

## 8 — MARKETING & SUPPORT

Full plan: `docs/handsoff/marketing-and-demo-plan-2026-10-09.md`

### Support links (live in app, website, README)
| Platform | URL |
|---------|-----|
| Buy Me a Coffee | https://buymeacoffee.com/zushikina_kuroh143 |
| Ko-fi | https://ko-fi.com/zushikina143 |
| PayPal | https://paypal.me/BrixDirecto |
| GCash/PayMaya | 09953583040 |

### Competitor pricing (researched Oct 2026)
- **Agila** (PH, 4.7★): Free (cosmetics ₱29 only)
- **PISO Budget** (PH): Completely free
- **Tarsi** (PH, #1 Paid Mar 2026): ~₱300–350 one-time
- **Monarch**: ~₱5,800/year (USD)
- **YNAB**: ~₱6,300/year (USD)

SmartSpend Pro at ₱299/year is cheaper than one month of ChatGPT Plus (₱999/month).

---

## 9 — PENDING TASKS (from PROJECT_STATUS.md)

### Must do before defense
- [ ] Install v3.0.3 APK on demo phone
- [ ] Verify About shows "Version 3.0.3"
- [ ] Load demo data ("Try Demo" on login screen)
- [ ] Cyrille: update manuscript to v3.0.3 numbers (SQLite v14/26 tables, 9 providers)
- [ ] Create Figures 1.1, 1.2, 2.1, 2.2

### Must do before Play Store
- [ ] Enable Firebase Blaze billing (most important)
- [ ] Add "Use your own Gemini key" setting
- [ ] Google Play Console account ($25)
- [ ] Data safety form
- [ ] 8 Play Store screenshots
- [ ] 60-second demo video

### After defense (v4.0)
- [ ] RevenueCat integration
- [ ] ProPaywallScreen + ProGate widget
- [ ] 6-phase feature gating

---

## 10 — FILE LOCATIONS (key files)

| What | Where |
|------|-------|
| ProService + ProFeature enum | `lib/services/pro_service.dart` |
| Auth mode helpers | `lib/services/auth_service.dart` (bottom of file) |
| Demo dataset | `lib/services/demo_service.dart` |
| Session summary card | `lib/screens/ai_screen.dart` → `_buildSessionSummaryCard()` |
| Re-log helper | `lib/screens/ai_screen.dart` → `_RelogHelperSheet` class |
| Chat history screen | `lib/screens/chat_history_screen.dart` |
| Transaction sort/group | `lib/screens/transactions_screen.dart` → `TxnSortKey`, `TxnGroupKey`, `_showSortGroupSheet()` |
| Freemium plan | `docs/handsoff/freemium-split-plan-2026-10-09.md` |
| Scale risks | `docs/handsoff/scale-and-commercialization-risks-2026-10-09.md` |
| On-device LLM | `docs/handsoff/on-device-llm-research-2026-10-09.md` |
| Marketing plan | `docs/handsoff/marketing-and-demo-plan-2026-10-09.md` |
| Master to-do | `docs/status/PROJECT_STATUS.md` |
| Single source of truth (capstone) | `docs/reference/CAPSTONE_REFERENCE.md` |

---

## 11 — WHAT CLAUDE SHOULD NOT CHANGE

- `docs/handsoff/FHS_Basis_and_Verification.docx` — already verified and locked
- `docs/handsoff/SmartSpend_Comparative_Research_Report.docx` — research is final
- `lib/services/score_service.dart` — FHS formula is correct, don't touch without running through the full component breakdown tests
- Firebase Remote Config keys — never hardcode in source, never commit to git

---

*This handoff supersedes `kiro-to-claude-handoff-2026-10-06.md`. All numbers in that doc are now stale. Use v3.0.3 numbers from this doc and `CAPSTONE_REFERENCE.md`.*
