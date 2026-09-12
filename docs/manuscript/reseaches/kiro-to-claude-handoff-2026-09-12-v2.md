# SmartSpend — Kiro → Claude Handoff (Session 2)
**Compiled:** September 12, 2026
**Covers:** All code changes from v2.9.43 through v2.9.47
**Previous handoff:** `kiro-to-claude-handoff-2026-09-12.md` covered v2.9.38–v2.9.42
**Purpose:** Give Claude the accurate picture of the app so manuscript/docs work is grounded in reality.

---

## Quick Summary

| Version | What changed |
|---------|-------------|
| v2.9.43 | Phase 0 pre-defense: hub tile count corrections, FHS sparkline, quick-access additions |
| v2.9.44 | Quick access hub overhaul — 22 tiles, WalletsSheet integration |
| v2.9.45 | Phase 1 UI polish sprint (9 tasks) |
| v2.9.46 | UI polish sprint Part 2 — profile, settings, hub, home |
| v2.9.47 | Full-app soft-UI polish — all 37 screens |

---

## 1. Current Authoritative Numbers (v2.9.47)

These replace everything in the previous handoff. Use these in all manuscript/doc updates:

| Field | Value |
|-------|-------|
| Version string | **2.9.47** |
| Build codes | `2.9.47+47` |
| APK sizes | arm64-v8a ~45 MB, armeabi-v7a ~37 MB, x86_64 ~48 MB (split, obfuscated) |
| AI providers (fallback chain) | **8** |
| Primary AI model | **Gemini 3.5 Flash-Lite** |
| Fallback chain | Gemini 3.5 Flash → GPT-OSS 120B (Groq) → Qwen3.6 27B → Qwen3.8 27B → GPT-OSS 20B → Compound Mini → GPT-OSS 120B (Cerebras) |
| Agentic actions | **34** |
| Achievement badges | **25** |
| Daily AI message limit | **150 messages/day** |
| SQLite schema | v11, **20 tables** |
| Screens | **37** |
| Services | **26+** |
| Hub tiles | **26** (not 22 — full count after v2.9.44 expansion) |
| Currencies | **57** |
| Batch screenshot platforms | **40+** |
| Filipino item catalog | **150+ items** |
| Log choice sheet options | **7** |
| PH banks in DB | **20 banks + 5 e-wallets** |
| Color themes | **10** (5 original + Crimson, Deep Navy, Midnight Teal, Rose Pink, Charcoal added v2.9.45) |
| Daily quests pool | **10** |
| About screen version | **Auto-synced from `kAppVersion`** — always accurate |

---

## 2. Phase 1 UI Polish Sprint (v2.9.45)

Nine tasks completed:

### 2a. Profile screen — appearance tiles removed
The 4 duplicate appearance tiles in Profile (Dark Mode toggle, App Theme picker, Text Size picker, High Contrast toggle) were removed. Replaced with a single **"App Settings"** nav tile that shows a live subtitle: `"Dark/Light · ThemeName · TextSize · Lite Mode, behavior & more"`. Taps → `SettingsScreen`.

The old `_showThemePicker()` and `_showTextSizePicker()` dead methods in `profile_screen.dart` were also deleted.

### 2b. Home screen — Customize shortcut
Added a `Icons.tune_outlined` icon button to the dashboard header (between the greeting and Log Expense button). Taps → `_showHomeCustomizeSheet` — a slim bottom sheet with 6 `SwitchListTile` toggles for all 6 home section visibility keys (`show_subscriptions`, `show_quick_log`, `show_badges`, `show_mood_home`, `show_forecast`, `show_prediction`). Each toggle writes to DBService and fires `AppEvent.incomeChanged`.

### 2c. AI chat — compact mode bubble sizing
When `themeService.compactMode == true`:
- Bubble vertical margin: 4px → 2px
- Bubble horizontal padding: 14px → 10px
- Bubble vertical padding: 10px → 7px

Fixed: `ai_screen.dart` was missing the `import '../main.dart' show themeService;` — this caused 3 compile errors that were caught and fixed.

### 2d. 5 new color themes
Added to `AppTheme` enum in `theme_service.dart`:

| Enum | Label | Seed color | Primary |
|------|-------|-----------|---------|
| `crimson` | Crimson Red | `#BE0000` | `#BE0000` |
| `navy` | Deep Navy | `#1A237E` | `#1A237E` |
| `teal` | Midnight Teal | `#004D40` | `#004D40` |
| `rose` | Rose Pink | `#E91E8C` | `#E91E8C` |
| `charcoal` | Charcoal | `#37474F` | `#37474F` |

All 5 switch statements in `theme_service.dart` updated. Theme pickers in Settings and Profile auto-populate via `AppTheme.values` — no additional UI changes needed.

### 2e. Done Spending toggle in log sheet
`_DoneSpendingToggle` widget (already existed on Home dashboard) was also added to `_showLogExpenseSheetLocal` bottom sheet — appears below the last log-option tile, with a `Divider` above it.

### 2f. Savings rate trend chart (Analytics)
New 6-month `LineChart` (fl_chart) inserted in `analytics_screen.dart` before the "Daily Spending Trend" section. Shows monthly savings rate as % of income.

- **Gate:** Only shown when `_incomeWalletMode && _monthlyIncome > 0 && _cachedMonthlyTotals.length >= 2`
- **Target line:** Dashed green line at 20%
- **Dot colors:** Green ≥20%, primary color ≥0%, red <0%
- **Title:** "Savings Rate (last 6 months)" with subtitle "% of monthly income saved each month. Target: 20%+"
- **Legend:** Green line segment labeled "20% target"

### 2g. Budget tile long-press
In `budget_screen.dart`, each budget tile `Card` is wrapped in `GestureDetector(onLongPress: () => _showSetBudgetDialog(existing: b))`. Opens the edit dialog directly. Applies to all budget tiles regardless of fixed/% mode.

### 2h. Analytics AI cache fallback
Both AI sections in Analytics now cache their output and fall back to it on quota error — mirroring what Home screen already did:

**`_getAIAdvice()`** (Financial Advice card):
- On success: caches to `cached_ai_insight` + `cached_ai_insight_date` in DBService
- On error: reads those keys and shows `"⏳ AI quota reached — showing last insight (from DATE):\n\nCACHED_TEXT"`

**`_MonthlySummaryCard._generate()`** (Monthly Summary card):
- On success: caches to `cached_monthly_summary` + `cached_monthly_summary_date`
- On error: reads those keys and shows `"⏳ AI quota reached — showing last summary (from DATE):\n\nCACHED_TEXT"`

### 2i. Day-in-Review card — verified working
Confirmed: `home_screen.dart` line ~5094: `if (DateTime.now().hour >= 18) _buildDayInReviewCard(context)`. The card returns `SizedBox.shrink()` if no today expenses. No fix was needed.

---

## 3. Profile Header Redesign (v2.9.46)

`profile_screen.dart` — the old flat avatar + scattered name/email/stats layout replaced with a **gradient header card**:

- `Container` with `LinearGradient([cs.primaryContainer, cs.primaryContainer.withAlpha(0.55)])`, `borderRadius: 22`, `BoxShadow(primary.0.12, blur:16)`
- Contains: `CircleAvatar` (r:48) + inline edit button (taps `_openEditProfile`) + display name + email + stats row (with `Container(1px)` separators between stats)
- Stats row is now **inside** the header card, not below it

The old standalone `Text(displayName)`, `Text(email)`, and `Row(stats)` below the avatar were removed — they're all in the card now.

---

## 4. Quick Access Grid Redesign (v2.9.46)

`home_screen.dart` `_buildFeaturePortals()`:

- **Trimmed from 10 to 9 items** — "Paste & Log" removed (redundant with Log Expense button)
- **Grid spacing:** 8px → 10px, `childAspectRatio` 1.15 → 1.1
- **Tile style:** Each tile now has:
  - `Container` with `cs.surface` fill (not tinted)
  - `BoxShadow` using the tile's accent color at 0.18 alpha + black at 0.04 alpha
  - `borderRadius: 18`
  - Icon wrapped in a 38×38 rounded container (`color.withAlpha(0.12)`, `r:11`) instead of bare icon
  - Label: `FontWeight.w600` (was `bold`), subtitle capped at 1 line

**9 items remaining:** Analytics, Bill Calendar, Goals, Debts & Plans, My Wallets, Budgets, Import, Recurring, Achievements.

---

## 5. Settings Screen Redesign (v2.9.46)

`settings_screen.dart` — full visual overhaul:

- Added `_sectionCard(List<Widget> children)` helper: `Container(surface fill, r:16, BoxShadow(black 0.06, blur:12)) + ClipRRect + Column` with `Divider(indent:16, alpha:0.12)` between rows
- Added `_sectionLabel` padding increased from `top:20` to `top:22`; font-size 12→11, letterSpacing 0.6→0.8
- `_tile()` widget updated: outer `Padding(vertical:3)` → `Padding(horizontal:16, vertical:10)` (card-friendly), `SizedBox(width:12)` → 14
- **Every section** (BEHAVIOR, DISPLAY, APPEARANCE, SECURITY, TRACKING MODE, NOTIFICATIONS, HOME SCREEN sections, ANALYTICS sections) wrapped in `_sectionCard([...])`
- **Lite Mode card:** Replaced flat grey container with `surface fill + BoxShadow`, keeps `border:` only when `liteMode == true`
- **AI MODEL tiles:** Individual cards with `surface fill + outline border + BoxShadow`, active tile gets primary-tinted border (1.5px) and check icon
- **Nav tiles** (Spending Limits, App Theme, Text Size, Display Currency, App Lock): Removed wrapping `Padding(vertical:3) + InkWell + Padding(vertical:6)` structure → now plain `InkWell + Padding(horizontal:16, vertical:12)` inside the parent `_sectionCard`
- `// Single source of truth: ThemeService` comment preserved in compact mode handler

---

## 6. Quick Access Hub Redesign (v2.9.46)

`home_screen.dart` `_QuickAccessHubState` — full rewrite:

### Search bar
`TextField` at the top of the sheet:
- `fillColor: cs.surfaceContainerLow`, `borderRadius: 14`, `borderSide: none` (no outline)
- `suffixIcon`: clear button when `_searchQuery.isNotEmpty`
- Filters all 26+ items by title and subtitle on every keystroke
- "No results" empty state when filter returns nothing

### Category grouping
Items organized into 4 named sections, each rendered as a `Container(surface, r:16, BoxShadow)` + `ClipRRect` + `Column` with `Divider(indent:56)` between rows:

| Group | Items |
|-------|-------|
| **FINANCES** | Savings Goals, Income, Debts & Lending, Installment & Plans, Budgets, Recurring, My Wallets, Insurance & Contributions, Paluwagan, Peso Cost Averaging, PH Banks & Investments |
| **TRANSACTIONS & DATA** | Transactions, Bill Calendar, Log Due Bills, Import from Bank/GCash, Batch Screenshot Import, Scan Receipt/Barcode, Batch Manual Entry, Display Currency |
| **TOOLS** | Categories, Auto-Categorization Rules, Merchant Cleanup, Spending by Merchant, Achievements, Financial Glossary, AI Chat History |
| **HELP** | Help & Guide |

### Tile style
Each item: `InkWell` → `Padding(h:14, v:11)` → `Row(icon-container + text + chevron)`.
Icon in a 36×36 `Container(color.withAlpha(0.12), r:10)`. Title `w600 13px`, subtitle `onSurface.0.5 11px` maxLines:1.

### Sheet sizing
`maxChildSize` bumped from 0.88 → 0.92. Handle now 36px wide (was 40px).

### `_showMerchantSummary` location
Method is inside `_QuickAccessHubState` (not a separate top-level function). The old Card-based `_tile(IconData, String, String, Color, VoidCallback)` method was removed entirely.

---

## 7. Home Dashboard Card Upgrades (v2.9.46–v2.9.47)

Key cards upgraded from flat/outline-border containers to soft-shadow style:

| Card | Old | New |
|------|-----|-----|
| Balance card (top gradient) | `borderRadius: 20` | `borderRadius: 22` + `BoxShadow(primary.0.30, blur:18, offset:(0,6))` |
| Day-in-Review | `surfaceContainerHighest.0.35 + border(outline.0.15)` | `surfaceContainerLow + BoxShadow(black.0.06, blur:12)` |
| AI Insights section | `surfaceContainerHighest.0.4, r:15` | `surfaceContainerLow, r:18 + BoxShadow(black.0.06)` |
| Weekly Category card | `surfaceContainerHighest.0.35 + border, r:14` | `surfaceContainerLow, r:18 + BoxShadow(black.0.05)` |
| Cash Flow Forecast | `surfaceContainerHighest.0.4, r:14` | `surfaceContainerLow, r:18 + BoxShadow(black.0.05)` |
| Done Spending toggle | `surfaceContainerHighest.0.4 + border, r:12` | `surfaceContainerLow, r:16 + BoxShadow (green-tinted when ON)` |
| Where Did My Money Go | `primaryContainer.0.3 + border(primary.0.15), r:14` | `primaryContainer.0.28, r:18 + BoxShadow(primary.0.10)` |

---

## 8. Full-App Soft-UI Polish (v2.9.47)

30 files changed. Every screen in the app now uses consistent soft-shadow card design.

### Group A — bare `Card()` → elevation 2 + soft shadow + r16
Files: `budget_screen`, `recurring_screen`, `savings_goals_screen`, `debt_screen` (2 cards), `batch_image_import_screen`, `manage_categories_screen`, `manage_rules_screen`, `merchant_merge_screen`, `log_due_bills_screen`, `paluwagan_screen`

Change: `Card(margin: ...)` → `Card(elevation: 2, shadowColor: Colors.black.withValues(alpha: 0.08), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), margin: ...)`

### Group B — `Card` with shape → add elevation + shadow
Files: `achievements_screen`, `bank_import_screen`, `insurance_screen`, `pca_calculator_screen`, `bank_comparison_screen` (3 cards), `glossary_screen`, `help_screen`

Change: Added `elevation: 2, shadowColor: Colors.black.withValues(alpha: 0.08)` to existing shaped Cards. Radius bumped to 14–16.

### Group C — flat tinted containers → `surfaceContainerLow` + shadow

**`analytics_screen`:** Batch regex replaced all `surfaceContainerHighest.withValues(alpha: 0.4/0.35/0.3)` + `borderRadius.circular(14)` → `surfaceContainerLow + r:16 + BoxShadow(black.0.05, blur:10)`.

**`about_screen`:** `_infoCard()`, `_featureList()`, `_teamCard()` containers: `surfaceContainerHighest.0.4, r:12` → `cs.surface, r:16 + BoxShadow(black.0.06, blur:12)`. Disclaimer container: `orange border` → `orange BoxShadow`.

**`income_screen`:** Gradient summary header: added `borderRadius: 16` + `BoxShadow(green.0.25, blur:14)`. Was `const BoxDecoration(gradient: ...)` with no radius.

**`whats_new_screen`:** Header container: `color: cs.primaryContainer` → `BoxDecoration(primaryContainer + shadow)`. Feature rows: plain `Row+Padding` → `Container(surface, r:14, BoxShadow(black.0.05))` cards.

**`transactions_screen`:** Summary bar: `primaryContainer, r:10` → `primaryContainer, r:14 + BoxShadow(primary.0.12)`.

**`edit_expense_screen`:** Price trend container: `surfaceContainerHighest.0.3 + border(outline.0.15), r:12` → `surfaceContainerLow, r:14 + BoxShadow(black.0.05)`.

**`currency_screen`:** Header bar: `color: cs.primaryContainer` → `BoxDecoration(primaryContainer + BoxShadow(primary.0.12))`.

### Auth screens
**`login_screen` + `register_screen`:** Error message container: `red border (Border.all(Colors.redAccent))` → `BoxShadow(red.0.12, blur:8)`. Radius 8→12.

### AI screen
**`ai_screen`:** Suggestion action tiles: `color.0.08 + border(color.0.25), r:12` → `color.0.08 + BoxShadow(color.0.12, blur:8), r:14`. Clipboard nudge banner: `teal border` → `BoxShadow(teal.0.12)`. Quick-action pill chips (r:20) left unchanged — intentional pill design.

---

## 9. What Wasn't Changed (by design)

- `ExpenseTile` widget — uses plain `ListTile`, no card wrapper. Leave as is.
- `bill_calendar_screen` — calendar cell containers are tiny grid cells, not cards. Leave as is.
- `chat_history_screen` — chat bubble containers are intentional (same radius + color as ai_screen). Leave as is.
- `onboarding_screen` / `splash_screen` / `scan_review_screen` — no meaningful card changes needed (dot indicators, camera overlays).
- `setup_screen` / `app_lock_screen` / `pin_setup_screen` — utility screens, minimal UI.

---

## 10. Feature Status — Updated for Manuscript

These items from the previous handoff have been implemented and should be moved from "Future Work" to "Implemented":

| Feature | Implemented in | Where in app |
|---------|---------------|-------------|
| Savings rate trend chart | v2.9.45 | Analytics → before Daily Spending Trend section |
| Quick budget slider (long-press) | v2.9.45 | Budget screen → long-press any tile |
| Analytics AI cache fallback | v2.9.45 | Analytics → Financial Advice card + Monthly Summary card |
| Day-in-Review card (6pm+) | v2.9.36 (verified v2.9.45) | Home screen → appears after 18:00 if today expenses exist |
| 5 additional color themes | v2.9.45 | Settings → APPEARANCE → App theme |
| Done Spending Today toggle (in log sheet) | v2.9.45 | Home → Log Expense → bottom of sheet |
| Home section customize shortcut | v2.9.45 | Home header → tune icon |

---

## 11. Things Still NOT Implemented (for accurate manuscript Future Work section)

Per the backlog, these remain unbuilt:

| Feature | Priority | Notes |
|---------|----------|-------|
| Safe-to-Spend number | 🔥 High | BudgetPH differentiator — reserved balance after bills/goals/debts |
| Proactive AI nudge notifications | 🟡 Medium | Rowan-style push on app open |
| Auto-categorization evidence threshold | 🟡 Medium | 3+ prior entries → majority category wins |
| Income prediction / Payday countdown card | 🟡 Medium | avg income interval → "next expected in N days" |
| AI chat history export | 🟡 Medium | Share as .txt |
| "What Changed?" monthly delta notification | 🟢 Low | On first open of new month |
| Monthly GitHub-style heatmap (full grid) | 🟢 Post-capstone | 28–31 cell per-date grid |
| Receipt photo gallery | 🟢 Post-capstone | Hub → Receipts GridView |
| True net worth historical chart | 🟢 Post-capstone | Snapshot-based |
| Price Intelligence / Price Pulse | 🟢 Post-capstone | PSA API + personal history charts |
| Notification Listener (replaces SMS plan) | 🟡 Medium | GCash notification → log prompt |
| Semester interval recurring detection | 🟡 Medium | ~120–135 day interval |
| SQLite encryption | 🟢 Post-capstone | sqlcipher |
| Backend API proxy | 🟡 Pre-Play Store | Cloud Functions |

---

## 12. Manuscript Numbers to Update

Replace these stale values everywhere in the manuscript with the correct ones:

| Find (stale) | Replace with (correct) |
|---|---|
| v2.9.41 / v2.9.42 / v2.9.43 (any old version) | **v2.9.47** |
| "31 agentic actions" | **34 agentic actions** |
| "23 achievement badges" | **25 achievement badges** (No-Spend Day + No-Spend Streak added) |
| "5 color themes" | **10 color themes** |
| "22 Hub tiles" | **26 Hub tiles** (full hub count after v2.9.44 expansion) |
| "9 Quick Access shortcuts" | **9 Quick Access shortcuts** ✅ (trimmed from 10 in v2.9.46) |
| Hub described as "flat list" | Hub has **search bar + 4 category groups** (FINANCES, TRANSACTIONS & DATA, TOOLS, HELP) |
| Settings described as "scrollable list of toggles" | Settings has **grouped section cards** with dividers |
| Profile header described as "avatar + name + stats" | Profile header is a **gradient card** (primaryContainer gradient) with avatar, name, email, stats |
| LLaMA models in fallback chain | **REMOVED** — retired Feb–Aug 2026, return 404. Do not list them. |
| "Gemini 3.1 Flash-Lite" anywhere | **Gemini 3.5 Flash-Lite** (migrated Sep 10, 2026) |
| "60 messages/day limit" | **150 messages/day** |
| Paluwagan in Future Work | Move to Implemented (v2.9.35) |
| Savings rate chart in Future Work | Move to Implemented (v2.9.45) |
| Quick budget slider in Future Work | Move to Implemented (v2.9.45) |
| Analytics AI cache in Future Work | Move to Implemented (v2.9.45) |

---

## 13. GitHub Releases (for reference)

| Tag | Title | APK sizes |
|-----|-------|-----------|
| v2.9.43 | Pre-defense final polish | arm64 ~45MB |
| v2.9.44 | Quick Access Hub overhaul | arm64 ~45MB |
| v2.9.45 | Phase 1 UI Polish | arm64 45.1MB |
| v2.9.46 | UI Polish Sprint | arm64 45.1MB |
| v2.9.47 | Full-App Soft-UI Polish | arm64 45.1MB |

All releases at: `https://github.com/Zushikina-kun/smartspend-app/releases`

---

## 14. Open Items — Human Action Required

These carry over from the previous handoff plus new ones:

| Item | Owner | Notes |
|------|-------|-------|
| Update FEATURE_BACKLOG.md version header (still says v2.9.41) | Brix | Trivial text edit |
| Update DEFENSE_GUIDE.md (version, model names, action count 34, 25 badges, 10 themes) | Brix | Before defense |
| Update BENCHMARK.md (version, add PISO/BunnyWise/Lista PH/Kibo/Agila) | Brix | Before defense |
| Update APPLICATION_PIPELINE.md (remove retired LLaMA models, update version) | Brix | Before defense |
| Update CAPSTONE_REFERENCE.md (2.9.42 → 2.9.47, model table) | Brix | Before defense |
| Update PROJECT_STATUS.md (version) | Brix | Before defense |
| Figures 1.1, 1.2, 2.1, 2.2 | Cyrille | Still not created |
| Compliance Matrix | All | Still not filled |
| LLM benchmark TBD cells | Brix | Actual Taglish corpus test |
| SUS survey (30 respondents) | Djaunathan | Post-defense |
| Play Store closed testing | Brix | 12 testers × 14 days, post-defense |
| Privacy policy hosted URL | Cyrille | Needed for Play Store |

---

*Compiled by Kiro (Kiro IDE) — September 12, 2026*
*Covers v2.9.43 through v2.9.47.*
*Read in conjunction with `kiro-to-claude-handoff-2026-09-12.md` (covers v2.9.38–v2.9.42).*
*Treat all information here as ground truth for the current app state.*
