# SmartSpend — Codex Briefing Document
**Compiled:** September 26, 2026
**Version:** 2.9.59
**For:** OpenAI Codex (or any AI coding agent starting fresh on this project)
**Purpose:** Everything Codex needs to understand the project, write correct code, and avoid breaking things.

---

## 1. What This Project Is

**SmartSpend** is an AI-assisted personal finance tracker for Android, built with Flutter/Dart.
It is a **capstone project** (college thesis) by team Lucid Frame at Lorma Colleges, Philippines.

**One-line description:**
> A user tells the app what they spent → AI understands it → stores it → analyzes it → gives a financial health score and personalised advice.

**Target users:** Filipino college students, young professionals, and parents.
**Platform:** Android only (Flutter). iOS/web are out of scope.
**Language:** Dart (Flutter 3.x stable).
**Version as of this briefing:** `2.9.59+53`

---

## 2. Project Structure

```
smartspend_app/
├── lib/
│   ├── main.dart                    # App entry, Firebase init, ThemeService
│   ├── models/
│   │   ├── expense.dart             # Expense model + fromMap/toMap
│   │   ├── budget.dart              # Budget model
│   │   └── user_profile.dart        # UserProfile model
│   ├── screens/                     # Screen widgets (see §4)
│   ├── services/                    # Service layer (see §5)
│   └── widgets/
│       ├── expense_tile.dart        # Reusable expense list tile
│       ├── info_button.dart         # ❓ tooltip button used across all screens
│       ├── feature_tour.dart        # Onboarding tour overlay
│       └── action_button.dart       # Reusable primary action button
├── assets/
│   ├── logo.png
│   ├── LucidFrameLogo.png
│   ├── ph_banks.json                # Philippines bank data (20 banks + 5 e-wallets)
│   └── Devs/                        # Developer photos (about screen)
├── android/                         # Android-specific config
├── docs/                            # Project documentation (not shipped in APK)
├── pubspec.yaml                     # Dependencies (see §3)
├── README.md
└── HOWTORUN.md
```

---

## 3. Dependencies (pubspec.yaml — v2.9.59)

Key packages and what they're used for:

| Package | Version | Used for |
|---------|---------|---------|
| `sqflite` | ^2.3.0 | Local SQLite database — all user data |
| `firebase_core` | ^3.6.0 | Firebase initialization |
| `firebase_auth` | ^5.3.0 | Email + Google Sign-In |
| `firebase_remote_config` | ^5.1.0 | Remote API keys (Groq, Gemini, Cerebras) |
| `cloud_firestore` | ^5.4.0 | Cloud sync of user data |
| `firebase_app_check` | ^0.3.2 | API abuse protection (monitoring mode) |
| `firebase_crashlytics` | ^4.1.0 | Crash reporting |
| `http` | ^1.1.0 | All LLM API calls |
| `flutter_local_notifications` | ^17.2.2 | Budget alerts, weekly summaries, nudges |
| `shared_preferences` | ^2.3.2 | Compact mode, theme, non-sensitive settings |
| `speech_to_text` | ^7.3.0 | Voice input |
| `google_mlkit_text_recognition` | ^0.13.0 | OCR receipt scanning |
| `google_mlkit_barcode_scanning` | ^0.12.0 | Barcode/QR product lookup |
| `google_mlkit_document_scanner` | ^0.1.0 | Document scanning |
| `mobile_scanner` | ^3.5.6 | Supplemental barcode scanning |
| `image_picker` | ^1.0.7 | Gallery / camera photo selection |
| `fl_chart` | ^0.68.0 | All charts (bar, line, pie) |
| `flutter_markdown` | ^0.7.4 | AI chat message rendering |
| `share_plus` | ^10.0.2 | Export CSV/JSON/chat/debug files |
| `path_provider` | ^2.1.4 | Temp directory for exports |
| `csv` | ^6.0.0 | Expense export as CSV |
| `local_auth` | ^2.3.0 | Biometric PIN lock |
| `file_picker` | ^8.0.0 | Import bank CSV files |
| `google_sign_in` | ^6.2.1 | Google OAuth |
| `shake` | ^2.2.0 | Shake phone → quick log |
| `intl` | ^0.19.0 | Date/number formatting |

**Do NOT add new dependencies without checking pubspec.yaml first.** Suggest additions in comments if you think one is needed.

---

## 4. All Screens

| Screen file | What it does |
|-------------|-------------|
| `splash_screen.dart` | Loading + Firebase init + auth check |
| `onboarding_screen.dart` | 3-page intro (first install only) |
| `login_screen.dart` | Email + Google sign-in |
| `register_screen.dart` | New account creation |
| `setup_screen.dart` | First-run: set income, account type, currency |
| `home_screen.dart` | **Main dashboard** — spending summary, FHS score, AI insights, all cards |
| `ai_screen.dart` | AI chat — "Peso" assistant, 34 agentic actions |
| `analytics_screen.dart` | Charts, 50/30/20, DTI, emergency fund, milestones, market insights |
| `transactions_screen.dart` | Full expense list with filters and export |
| `add_expense_screen.dart` | Manual expense entry form |
| `edit_expense_screen.dart` | Edit existing expense |
| `budget_screen.dart` | Set/edit category budgets |
| `profile_screen.dart` | User profile, FHS history, income, net worth |
| `income_screen.dart` | Log and manage income entries |
| `savings_goals_screen.dart` | Create/track savings goals and emergency fund |
| `debt_screen.dart` | Debts + lending tracker |
| `recurring_screen.dart` | Recurring bills and income management |
| `bill_calendar_screen.dart` | Calendar view of upcoming bills |
| `log_due_bills_screen.dart` | Quick-log overdue recurring items |
| `insurance_screen.dart` | Insurance + SSS/PhilHealth/Pag-IBIG tracker |
| `paluwagan_screen.dart` | Filipino rotating savings group tracker |
| `pca_calculator_screen.dart` | Peso Cost Averaging / MP2 investment calculator |
| `bank_comparison_screen.dart` | Philippine bank interest rate comparison |
| `bank_import_screen.dart` | Import from bank/GCash CSV |
| `batch_image_import_screen.dart` | Batch screenshot import (40+ platforms) |
| `batch_manual_entry_screen.dart` | Batch manual expense entry (up to 8 at once) |
| `scan_review_screen.dart` | OCR receipt review before logging |
| `smart_camera_screen.dart` | Unified camera: barcode/QR/receipt/screenshot |
| `achievements_screen.dart` | 25 badges + badge progress |
| `chat_history_screen.dart` | Full AI conversation history |
| `manage_categories_screen.dart` | Custom categories management |
| `manage_rules_screen.dart` | Auto-categorization keyword rules |
| `merchant_merge_screen.dart` | Merge duplicate merchant names |
| `currency_screen.dart` | Display currency selector (57 currencies) |
| `settings_screen.dart` | Full App Settings (20 toggles, 13 Lite Mode sections) |
| `glossary_screen.dart` | Financial terms glossary |
| `help_screen.dart` | In-app help guide |
| `about_screen.dart` | App version, team, open-source credits |
| `app_lock_screen.dart` | PIN/biometric lock entry |
| `pin_setup_screen.dart` | PIN setup/change |
| `whats_new_screen.dart` | What's New on version update |

---

## 5. All Services

| Service file | What it does |
|-------------|-------------|
| `db_service.dart` | **All SQLite operations** — single source of truth for all data. 20 tables. Never bypass this. |
| `ai_chat_service.dart` | LLM API calls, action parsing, history management, category resolution |
| `app_config.dart` | API keys, model routing, Auto mode, fallback chain. **IN .gitignore — never commit.** |
| `app_config.dart.example` | Safe template for new devs |
| `auth_service.dart` | Firebase Auth wrapper |
| `cloud_service.dart` | Firestore sync (push/pull user data) |
| `score_service.dart` | Financial Health Score calculation (4 components) |
| `startup_alerts_service.dart` | On-open alerts (budget exceeded, overdue bills, FHS drop, monthly recap) |
| `notification_service.dart` | flutter_local_notifications wrapper (weekly summary, budget alerts) |
| `insight_service.dart` | AI-powered home screen insight caching |
| `predict_service.dart` | Behavioral spending prediction (end-of-month forecast) |
| `behavioral_feedback_service.dart` | Score narrative + celebration events |
| `theme_service.dart` | ThemeService singleton — dark/light, compact, 10 color themes, text scale |
| `currency_service.dart` | Currency formatting (₱ default, 57 currencies) |
| `ocr_service.dart` | ML Kit text recognition wrapper |
| `voice_service.dart` | Speech-to-text wrapper |
| `export_service.dart` | CSV/JSON export logic |
| `backup_service.dart` | Full DB backup to JSON |
| `debug_service.dart` | Debug log export (settings + expenses + AI trace) |
| `llm_service.dart` | Lightweight LLM helper for non-chat tasks |
| `barcode_lookup_service.dart` | Product lookup from barcode scan |
| `merchant_normalization_service.dart` | Merchant name cleaning/dedup |
| `item_catalog_service.dart` | 150+ Filipino item catalog for autocomplete |
| `category_service.dart` | Category list + custom category management |
| `recurring_helper.dart` | Recurring transaction date advancement logic |
| `event_bus.dart` | AppEventBus — `AppEvent.expenseChanged / budgetChanged / incomeChanged / goalChanged` |
| `tax_service.dart` | Philippine tax estimation (TRAIN Law) |
| `undo_service.dart` | Undo last expense log |
| `demo_service.dart` | Demo mode data seeding |
| `app_lock_service.dart` | PIN storage + biometric lock |

---

## 6. Database — SQLite Schema (v11, 20 tables)

All data is local-first in SQLite. `DBService` is the only class that touches the DB.

```
expenses          — id, item_name, category, amount, date, time, payment_method,
                    notes, ai_generated, confidence_score, tags, shop_name,
                    is_want (nullable), receipt_photo_path
income            — id, title, amount, category, date, is_recurring, is_windfall, notes
budgets           — id, category, amount, is_percentage, percentage_value
savings_goals     — id, name, target_amount, current_amount, deadline, icon, color, created_at
debts             — id, title, person, amount, paid_amount, type, due_date, notes, created_at
recurring         — id, title, amount, category, frequency, next_date, is_expense, notes
recurring_candidates — id, description, category, avg_amount, frequency, last_seen, dismissed, created_at
installments      — id, name, total_amount, monthly_payment, months_total, months_paid,
                    interest_rate, start_date, notes
wallets           — id, name, icon, balance, created_at
chat_history      — id, role, message, timestamp
conversation_summaries — id, summary, message_count_at_summary, created_at
score_history     — id, score, date
scan_history      — id, barcode, scanned_at
user_profile      — uid, first_name, last_name, middle_name, email, birthdate, address, photo_url
custom_categories — id, name, icon
settings          — key TEXT PRIMARY KEY, value TEXT   ← KEY-VALUE STORE for all settings
tags              — id, name, color, created_at
expense_tags      — expense_id, tag_id
paluwagan         — id, name, total_amount, num_members, cycle_length_weeks, start_date,
                    your_slot, notes, created_at
insurance_policies — id, name, provider, type, premium_amount, frequency, next_due_date,
                     coverage_amount, notes, created_at
```

**Settings table key-value pairs (important ones):**

| Key | Default | What it controls |
|-----|---------|-----------------|
| `income_wallet_mode` | `'true'` | Full mode vs Lightweight mode |
| `active_model_id` | `'auto'` | Current AI model |
| `show_subscriptions` | `'true'` | Home: subscription card |
| `show_quick_log` | `'true'` | Home: quick-log chips |
| `show_badges` | `'true'` | Home: achievement badges row |
| `show_mood_home` | `'true'` | Home: mood check-in |
| `show_forecast` | `'true'` | Home: cash flow forecast |
| `show_prediction` | `'true'` | Home: behavioral prediction |
| `show_payday_countdown` | `'true'` | Home: payday countdown card |
| `show_monthly_recap` | `'true'` | Startup: monthly delta alert |
| `show_challenges` | `'true'` | Home: daily/weekly challenges |
| `show_dti` | `'true'` | Analytics: DTI ratio |
| `show_emergency_fund` | `'true'` | Analytics: emergency fund |
| `show_milestones` | `'true'` | Analytics: milestones |
| `show_market_insights` | `'true'` | Analytics: exchange rates |
| `mood_checkin_enabled` | `'true'` | Mood prompt system-wide |
| `impulse_pause_enabled` | `'true'` | Confirm before Want expenses |
| `budget_alerts_enabled` | `'true'` | Budget 80%/100% notifications |
| `wallet_auto_deduct` | `'true'` | Auto-deduct wallet on log |
| `anomaly_detection_enabled` | `'true'` | Weekly spike alerts |
| `compact_mode` | SharedPreferences, not settings table | UI density |
| `monthly_income` | `0.0` | User's monthly income/allowance |
| `account_type` | `'general'` | employed/student/unemployed/freelancer/pensioner/general |

---

## 7. AI System — How It Works

### 7a. API keys and model routing (`app_config.dart`)

**`app_config.dart` is gitignored.** Codex will see `app_config.dart.example` instead. The real file contains API keys for Groq, Gemini, and Cerebras. Never hardcode keys anywhere else.

**Model chain (8 providers, best → fallback):**
1. `auto` — Dynamic routing (DEFAULT): fast tasks → Gemini Flash-Lite, advice → Gemini Flash
2. `gemini_flash` — Gemini 3.5 Flash (frontier reasoning)
3. `gemini_flash_lite` — Gemini 3.5 Flash-Lite (fast + cheap)
4. `groq_llama4_scout` — GPT-OSS 120B on Groq (1K RPD)
5. `groq_kimi_k2` — Qwen3.6 27B on Groq (1K RPD)
6. `groq_qwen3` — Qwen3.8 27B on Groq (1K RPD)
7. `groq_70b` — Groq Compound (250 RPD)
8. `groq_8b` — Groq Compound Mini (250 RPD)
9. `cerebras_120b` — GPT-OSS 120B on Cerebras (1M tokens/day, last resort)

**Important:** The `groqApiKey`, `groqBaseUrl`, `groqModel` getters handle routing for ALL providers — the names are legacy (everything goes through these 3 getters regardless of which provider is active).

### 7b. Agentic actions (34 total in `ai_chat_service.dart`)

The AI can perform these actions autonomously from natural language:

**Expense management:** `log_expense`, `update_expense`, `delete_expense`, `log_multiple_expenses`
**Income/wallet:** `set_income`, `add_income`, `set_wallet_balance`, `transfer_wallet`
**Budgets:** `set_budget`, `update_budget`
**Goals:** `add_goal`, `update_goal`, `log_goal_contribution`
**Debts:** `add_debt`, `update_debt`, `log_debt_payment`
**Recurring:** `add_recurring`, `update_recurring`
**Installments:** `add_installment_plan`, `log_installment_payment`
**Analysis:** `show_analytics`, `show_budget_summary`, `show_spending_by_category`
**Utility:** `split_expense`, `detect_subscriptions`, `tag_expense`, `undo_last_expense`
**Advisory:** `give_financial_advice`, `explain_fhs_score`, `suggest_savings_goal`
**Other:** `set_spending_limit`, `show_savings_goals`, `show_debts`

### 7c. Category resolution priority (v2.9.52+)

```
_resolveCategory(aiCategory, itemName):
  1. Historical majority — if item logged ≥3× and ≥60% agree on one category → use that
  2. AI's suggestion → keyword-normalized via _normalizeCategory()
  3. Keyword fallback on item name
```

### 7d. Daily message limit

**150 messages/day** per user (enforced in `_checkAndIncrementLimit()`). Tracked in SharedPreferences (`ai_chat_count` + `ai_chat_date`). Resets at midnight UTC. The `⋮ menu → Reset Daily Limit` in the AI screen lets users reset manually (demo use).

---

## 8. UI Conventions — Follow These Exactly

### 8a. Card style (every card in the app uses this pattern)

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: cs.surfaceContainerLow,          // NOT surfaceContainerHighest
    borderRadius: BorderRadius.circular(18), // 16–18 for cards, 12–14 for small
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: ...
)
```

**Do NOT use `Card()` widget for new cards** — the app uses raw `Container` with manual decoration for consistency. `Card()` is only used in older screens that haven't been migrated yet.

### 8b. Color system

Always use `Theme.of(context).colorScheme` (abbreviated as `cs`):
- Card backgrounds: `cs.surfaceContainerLow`
- Surface containers: `cs.surfaceContainerHighest` (for inner elements only)
- Primary tint: `cs.primary.withValues(alpha: 0.08–0.12)` for accent backgrounds
- Text primary: `cs.onSurface`
- Text secondary: `cs.onSurface.withValues(alpha: 0.55–0.65)`
- Text muted: `cs.onSurface.withValues(alpha: 0.42)`

**Use `.withValues(alpha: x)` NOT `.withOpacity(x)`** — `withOpacity` is deprecated in this codebase.

### 8c. InfoButton pattern

Every non-obvious card gets an `InfoButton` tooltip:

```dart
Row(children: [
  const Text("Card Title",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  const SizedBox(width: 4),
  const InfoButton(
    title: "Card Title",
    body: "Explanation of what this card shows and why it matters.",
    size: 13,
  ),
]),
```

### 8d. Settings toggle pattern (`_tile()`)

All toggles in `settings_screen.dart` use the `_tile()` helper:

```dart
_tile(
  icon: Icons.some_icon_outlined,
  title: 'Setting label',
  subtitle: 'Brief description',
  value: boolStateVar,
  onChanged: (v) {
    setState(() => boolStateVar = v);
    _saveAndRefresh('setting_key', v); // or _save() if no UI refresh needed
  },
),
```

**When adding a new home-screen toggle:** also add it to `_applyLiteMode()` and the `liteMode` getter in `settings_screen.dart`.

### 8e. Nav bar clearance (edgeToEdge mode)

The app uses `SystemUiMode.edgeToEdge`. All screens that have buttons/inputs near the bottom **must** account for the system nav bar:

```dart
// For scrollable screens
padding: EdgeInsets.only(bottom: 28 + MediaQuery.of(context).viewPadding.bottom)

// For fixed bottom elements
bottom: 24 + MediaQuery.of(context).viewPadding.bottom

// For bottom bars / footers
SafeArea(top: false, child: ...)  // wraps the bottom content
```

**Use `viewPadding.bottom` NOT `padding.bottom`** — `padding.bottom` returns 0 when the keyboard is open in edgeToEdge mode.

### 8f. EventBus — trigger UI refreshes

When any data changes, fire the appropriate event so all listening screens refresh:

```dart
import '../services/event_bus.dart';
fireEvent(AppEvent.expenseChanged);   // for expense changes
fireEvent(AppEvent.budgetChanged);    // for budget changes
fireEvent(AppEvent.incomeChanged);    // for income, settings, wallet changes
fireEvent(AppEvent.goalChanged);      // for savings goal changes
```

---

## 9. Coding Rules — Non-Negotiable

1. **Never bypass `DBService`** — all reads and writes go through it. No raw SQLite calls outside `db_service.dart`.

2. **Never commit `app_config.dart`** — it contains real API keys. It is in `.gitignore`. Use `app_config.dart.example` as reference only.

3. **Never commit `google-services.json`** — Firebase config file in `android/app/`. Also gitignored.

4. **No new packages without discussion** — the pubspec is locked. Suggest additions in comments.

5. **Use `const` everywhere possible** — the analyzer enforces `prefer_const_constructors`. New widgets should be `const` where the constructor allows.

6. **No `withOpacity()`** — use `.withValues(alpha: x)` instead. `withOpacity` was replaced globally in v2.9.47.

7. **No hardcoded colors** — always use `Theme.of(context).colorScheme` values. No `Colors.blue` directly in cards (ok in icons with explicit meaning like `Colors.green` for positive).

8. **Always handle `mounted` after async gaps:**
   ```dart
   await someAsyncCall();
   if (!mounted) return;
   setState(() { ... });
   ```

9. **Always use `DBService.getSetting()` for persisted flags** — not SharedPreferences directly (except compact_mode and theme which live in ThemeService).

10. **Run `flutter analyze` before declaring anything done.** Zero errors is the requirement. Info-level warnings (style) are acceptable.

---

## 10. Financial Health Score (FHS) — Do Not Touch

The FHS formula is academic-validated and critical to the capstone thesis. **Do not modify `score_service.dart` without explicit instruction.**

**Current code uses four 25-point components.**

Full mode (`incomeWalletMode: true`):
- Savings Rate
- Overspend Control
- Budget Adherence
- Logging Consistency

Lightweight mode (`incomeWalletMode: false`):
- Spending Restraint
- Logging Consistency
- Category Balance
- Habit Streak

The formula also applies warning decay and logging-gap adjustments in supporting methods/settings. When documentation disagrees, treat `score_service.dart` as the source of truth.

---

## 11. Known Files That Are Stale / Have Wrong Version Numbers

These files have not been updated to v2.9.59 yet — treat the version numbers in them as wrong:

| File | Stale version | Correct version |
|------|--------------|----------------|
| `README.md` | 2.9.40 | 2.9.59 |
| `HOWTORUN.md` | 2.9.40 | 2.9.59 |
| `docs/reference/SYSTEM_OVERVIEW.md` | 2.9.41 | 2.9.59 |
| `docs/reference/APPLICATION_PIPELINE.md` | 2.9.47 | 2.9.59 |
| `docs/reference/FEATURE_DOCS.md` | 2.9.41 | 2.9.59 |
| `docs/reference/CAPSTONE_REFERENCE.md` | 2.9.41–47 | 2.9.59 |

**Authoritative source for current state:** `docs/manuscript/reseaches/kiro-to-claude-handoff-2026-09-26-v3.md`

---

## 12. What's Currently on the To-Do List (Pending Code Work)

These are the features that should be built next, in priority order:

### 🔥 Tier 2 — Build before final defense

| # | Feature | Est. effort | Key files to touch |
|---|---------|------------|-------------------|
| 1 | **Safe-to-Spend number** | ~1 day | `home_screen.dart` (new card), `db_service.dart` (query upcoming bills/goals), `startup_alerts_service.dart` (optional alert) |
| 2 | **Proactive AI nudge notifications** | ~2 days | New `proactive_nudge_service.dart`, `notification_service.dart`, `startup_alerts_service.dart` |
| 3 | **Expense Correction Suggestions** | ~1 day | New Hub badge in `home_screen.dart` or Hub screen, `db_service.dart` (scan for data quality issues), `ai_chat_service.dart` (update_expense action) |

### ⏸ Tier 3 — Defer for now

15th/30th payday reset, GCash Notification Listener, heatmap, photo gallery, net worth chart — all deferred. Do not start these unless asked.

---

## 13. GitHub Repository

**URL:** `https://github.com/Zushikina-kun/smartspend-app`
**Branch:** `master` (single branch workflow)
**Release tags:** v2.9.50 through v2.9.59 on GitHub Releases

**Build commands:**
```bash
# Run on device/emulator
flutter run

# Build split APKs (release)
flutter build apk --split-per-abi --release

# Build AAB (Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Analyze (must be zero errors)
flutter analyze --no-pub
```

**APK outputs:** `build/app/outputs/flutter-apk/`
- `app-arm64-v8a-release.apk` — ~46.7 MB (most modern phones)
- `app-armeabi-v7a-release.apk` — ~39.4 MB (older phones)
- `app-x86_64-release.apk` — ~49.7 MB (emulators)

---

## 14. App Config Setup (for Codex to run the project)

The real `app_config.dart` is gitignored. To run locally:

1. Copy `lib/services/app_config.dart.example` → `lib/services/app_config.dart`
2. Fill in API keys:
   - Groq: free key at https://console.groq.com
   - Gemini: free key at https://aistudio.google.com
   - Cerebras: free key at https://cloud.cerebras.ai
3. Firebase: `android/app/google-services.json` is also gitignored — get from Firebase Console → Project Settings → Android app

Without these files, the app will compile but AI features will not work. The app degrades gracefully — all manual entry features still work offline.

---

## 15. Quick Reference — Key Numbers (v2.9.59)

| Metric | Value |
|--------|-------|
| Version | 2.9.59+53 |
| Screens | 41 Dart files |
| Services | 29 Dart files |
| SQLite tables | 20 |
| AI providers in chain | 8 |
| Agentic actions | 34 |
| Achievement badges | 25 |
| Daily AI message limit | 150 |
| Color themes | 10 |
| Daily quests pool | 10 |
| Hub tiles | 26 |
| Currencies | 57 |
| Filipino item catalog | 150+ items |
| Batch screenshot platforms | 40+ |
| PH banks in DB | 20 + 5 e-wallets |
| Optional home toggles | 9 |
| Optional analytics toggles | 4 |
| Lite Mode coverage | 13 sections |
| Input modalities | 7 user-facing paths (voice, text, camera, screenshot batch, barcode, OCR/receipt, paste/import). Android share intent is planned, not yet wired. |
| Min Android SDK | API 21 (Android 5.0) |
| Target Android SDK | API 36 |

---

## 16. What Codex Should NOT Change

- `score_service.dart` — FHS formula is thesis-validated, do not touch
- `db_service.dart` — schema migrations (onCreate/onUpgrade) — only add, never modify existing
- `app_config.dart` — do not create or modify (gitignored, contains keys)
- `google-services.json` — do not create or modify (gitignored, contains Firebase config)
- Any file in `docs/` — documentation only, no code
- `assets/` files — no changes to images, JSON data, or logos
- Firebase configuration in `main.dart` — do not change Firebase init order
- The `kAppVersion` constant in `lib/services/debug_service.dart` — this feeds About screen, debug logs, and backup metadata

---

*Compiled by Kiro — September 26, 2026*
*Authoritative for project state as of v2.9.59.*
*Read alongside: `kiro-to-claude-handoff-2026-09-26-v3.md` (for feature history and manuscript context)*
