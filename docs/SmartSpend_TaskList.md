# SmartSpend — Complete Task Status
**Version:** 2.7.0
**Last Updated:** June 11, 2026
**Purpose:** Definitive status of all tasks — done, deferred, blocked, and why.

---

## SECTION 1 — FULLY DONE ✅

Everything here is confirmed built, tested, and in the current build (v2.7.0 — June 11, 2026).

### Sessions 13–14 (May–June 2026) — New
- [x] 25 AI agentic actions (plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, compute_contribution, detect_subscriptions, suggest_idle_money, generate_monthly_plan, explain_fhs_breakdown, compare_periods, project_savings_timeline, transfer_wallet, delete_by_date)
- [x] Insurance & Contributions Tracker (InsuranceScreen + Firestore sync + demo data)
- [x] Startup Alerts — 6 on-open conditions (bills, budgets, debts, FHS drop, idle money, insurance overdue)
- [x] Date/time editing in Edit Expense (date picker + time picker)
- [x] AI can change/add expense dates via chat
- [x] Wallet-first design (gradient card, smart daily allowance, "Add Money to Wallet")
- [x] PH Banks Comparison Screen (4 tabs: Banks, Digital, E-Wallets, Investments)
- [x] Barcode product lookup (Open Food Facts API + local PH product DB + prefix inference)
- [x] High contrast mode (black/white toggle in Profile)
- [x] Text size accessibility (Normal/Large/Extra Large via MediaQuery.textScaler in MaterialApp.builder)
- [x] Round-up savings (auto ₱10 round-up to first savings goal)
- [x] Price memory (15%+ price increase alert per item)
- [x] Smart daily allowance (remaining budget ÷ days left shown on daily limit card)
- [x] 23 badges (was 16) — 7 categories including new: Spare Change Hero, Wallet Wizard, Insurance Aware, Century Club, Score Star, Financial Literate, App Explorer
- [x] 10 daily quests (was 6) — gacha rotation, 4 shown per day
- [x] DTI ratio card in Analytics (BSP-referenced, color-coded)
- [x] Emergency Fund Calculator in Analytics (excludes large one-time Want purchases)
- [x] Peso Cost Averaging Calculator (Hub → Peso Cost Averaging)
- [x] Financial Health Certificate (shareable score card via share sheet)
- [x] Expandable chat input (1→6 lines, multiline)
- [x] Firebase Remote Config for API key (not in APK binary)
- [x] App Check debug mode for sideloaded APKs (Google login fix)
- [x] SHA-1 fingerprint in debug log + HOWTORUN.md
- [x] AI personality warmth ("Got it, logged your jeepney fare 🚌")
- [x] Income frequency bimonthly for all account types + live monthly equivalent preview
- [x] Emergency fund outlier exclusion (3x category average + >₱1,000 + Want = excluded)
- [x] 7 debug log bugs fixed (wallet double-logging, ACTION regex, is_want coercion, duplicate income, low income warning, fallback parser exclusions, ACTION format fix)
- [x] Competitor analysis document (docs/Competitor_Analysis_and_Feature_Ideas.md)
- [x] LLM comparison table for Chapter 3 (docs/LLM_Comparison_Table_Ch3.md)
- [x] Play Store security guide (docs/PlayStore_Security_Guide.md)
- [x] Capstone 2 Feature Analysis (docs/SmartSpend_Capstone2_Feature_Analysis.md)
- [x] Backup v9 (includes insurance_policies)
- [x] RecurringHelper shared service (eliminates 40+ lines of duplication)
- [x] LLM service category normalization fixed (14 categories, was 8)
- [x] FHS empty state returns 50 (was misleading 100)
- [x] Notification currency uses CurrencyService.format() (was hardcoded ₱)

### Core App (Sessions 1–27)
- [x] All deprecated widgets replaced (Radio, Color hardcodes, etc.)
- [x] Account isolation — logout clears local DB after cloud push
- [x] Demo mode isolated from real accounts
- [x] Feature tour per-account (`tour_done_${uid}`)
- [x] App lock PIN per-account (`app_lock_pin_${uid}`)
- [x] Chat history cleared on logout (privacy)
- [x] AI daily cap (60 msg/day) + remaining count in appbar
- [x] FHS formula matches paper (4-component, 25pts each)
- [x] Warning decay system (−5pts/day, max 3 days)
- [x] Custom expense categories (CategoryService, ManageCategoriesScreen)
- [x] Shake to Undo (UndoService, 60-second window)
- [x] Expense photo attachment (local only)
- [x] % of income budget mode
- [x] AI timeout retry button
- [x] Recurring Log All Due button
- [x] Want vs Need expense tagging (is_want column)
- [x] Net Worth installment integration
- [x] Spending streaks & badges (16 badges)
- [x] Daily spending limit (progress bar + notifications)
- [x] Bill Calendar (BillCalendarScreen)
- [x] SSS/PhilHealth/Pag-IBIG presets in Recurring
- [x] 8 account types with dynamic income labels
- [x] InfoButton widget across all screens
- [x] Manual income mode
- [x] Analytics: Last Month, Pick Month, Payday Cycle, Custom Range
- [x] Period Comparison Tool
- [x] Day-of-Week Heatmap
- [x] Long-Range Forecast (3/6/12 months)
- [x] Small Purchases Add Up card
- [x] Monthly Plain-English AI Summary
- [x] Mood & Spending Correlation
- [x] FHS Component Breakdown with literacy tips
- [x] Feature Glance Cards (Goals/Debts/Budgets/Recurring/Income/Mood)
- [x] Behavioral layer (Impulse Pause, Loss Aversion, Velocity Alerts, Windfall)
- [x] Daily Mood Check-In (mood_log table)
- [x] Payment Plans tab in Debts screen (installment_plans table)
- [x] Payment Plans synced to Firestore (fixed May 9)
- [x] Backup v8 (includes installment_plans, mood_log, category_rules)
- [x] Mood log restore uses original dates (not today)
- [x] AI daily limit counter cleared on logout
- [x] Chat history restores latest 50 messages (not oldest)
- [x] AI uses authoritative DB totals (no ghost totals)
- [x] Transaction Tags (#hashtags on expenses, filter in Transactions)
- [x] Subscription Auto-Detection (recurring_candidates table)
- [x] Market Insights card (live PHP exchange rates, auto-refresh)
- [x] Spending Personality card (computed from data, no AI call)
- [x] "Ask AI to explain my score" link on FHS card
- [x] Filipino Financial Calendar awareness in AI
- [x] AI as broader financial companion (banking, SSS, investments, prices)
- [x] Proactive budget alerts after expense logging (80%/100%)
- [x] Dynamic max_tokens per message type (200/400/600)
- [x] Conversation summarization (every 10 messages, token-efficient)
- [x] Bank/GCash import (AI-powered, any format, real dates preserved)
- [x] CSV file import button in bank import screen
- [x] OCR document mode (bypasses receipt cleaning for transaction tables)
- [x] Category auto-suggest in Add Expense (keyword matching as you type)
- [x] Quick Access Portals grid on Home screen
- [x] Analytics navigation chips (replaced Feature Glance)
- [x] Feature Tour updated (5 steps covering new features)
- [x] Help screen: 32+ sections covering all features
- [x] About screen: 75+ features listed
- [x] Demo script: SmartSpend_Demo_Script.md
- [x] AI actions: 15 types (added add_installment_plan, update_debt, delete_goal, delete_recurring)
- [x] Bulk rename fix (AI fires ACTION lines, not just text)
- [x] Nestea, C2 added to Food keywords
- [x] Weekly notification bug fixed (was using wrong week key)
- [x] Anomaly detection bug fixed (same week key issue)
- [x] Receipt OCR smart routing — multi-item receipts go to Import screen, not AI chat
- [x] LLMService.parseReceipt() — dedicated receipt parser with item extraction
- [x] BankImportScreen receipt mode — auto-parses OCR text, shows review table
- [x] Scan Review Screen "Import Items" button for multi-item receipts
- [x] AI bulk rename max_tokens fix (800 for rename requests)
- [x] AI bulk rename system prompt — explicit warning about ACTION lines requirement
- [x] home_screen _loadData missing mounted check (crash fix)
- [x] app_lock_screen logout — now runs pushAllToCloud + clearLocalData (data loss fix)
- [x] income_screen _load missing mounted check (crash fix)
- [x] currency_screen _select missing mounted check (crash fix)
- [x] chat_history_screen clear missing mounted check (crash fix)
- [x] income_screen Switch.activeColor → activeThumbColor (deprecated API fix)
- [x] Categories expanded: Gaming, Personal Care, Clothing, Gifts, Travel, Pets (14 total)
- [x] Payment methods expanded: GCash, Maya, GrabPay, ShopeePay, Debit Card, Credit Card, Bank Transfer
- [x] Currencies expanded: 57 total (added TWD, BHD, OMR, ILS, CZK, PLN, HUF, CLP, COP, PEN, UAH, RON, HRK, BGN, LKR, NPR, MMK, KHR, LAK, BND, MOP)
- [x] Home Quick Access grid: 9 portals (added Wallets, Budgets, Achievements)
- [x] Wallet card always visible on home (setup prompt when empty)
- [x] Net worth card: "Tap to manage wallets" hint
- [x] Profile: Manage Rules tile added
- [x] Analytics: Wallets + Calendar chips added to nav row
- [x] Crashlytics crash 1: analytics firstWhere null → .where().firstOrNull
- [x] Crashlytics crash 2: ShakeDetector MissingPluginException → try/catch
- [x] AI logging fix: max_tokens 200→300, LOGGING RULE added
- [x] AI wallet rule: never log wallet balances as income
- [x] AI action fallback parser: auto-generates log_expense when AI says "Logged" but fires no ACTION
- [x] Wallet auto-deduction on expense logging (Cash/GCash/Maya/GrabPay/ShopeePay)
- [x] App Settings sheet: 5 toggles (wallet auto-deduct, mood, impulse, budget alerts, balance mode)
- [x] Balance Mode: shows wallet total as primary balance in Profile
- [x] Settings toggles wired up: mood/impulse/budget alerts now respect their toggle state
- [x] Home screen rearranged: wallet + daily limit moved up, logical flow
- [x] Profile photo: Google account photo as fallback when local file missing
- [x] Daily Quests enhanced: 4 rotating from pool of 6, progress bar, streak counter
- [x] Feature tour updated: 5 steps covering wallets, 9-grid, 14 categories, settings
- [x] Log Allowance button: tap for daily amount, long-press for custom (irregular schedules)
- [x] AI payment_method fix: now uses AI's response instead of hardcoded 'Cash'
- [x] AppConfig.dart created (API key centralized, .gitignore'd)
- [x] 429 error message: suggests manual entry as alternative

---

## SECTION 2 — DEFENSE CRITICAL ⬜

These need physical device testing — not code changes.

| Check | Status | How to test |
|-------|--------|-------------|
| FHS formula matches paper | ✅ Done | score_service.dart verified |
| Demo mode FHS 60–85 range | ⬜ Test | Load demo → check score |
| Groq API fails gracefully | ⬜ Test | Turn off WiFi → send AI message → verify friendly error + retry button |
| Offline mode works | ⬜ Test | WiFi off → add expense manually → verify saves → WiFi on → verify syncs |
| Weekly notification fires | ⬜ Test | Wait until Sunday (May 10) → verify notification appears |
| Recurring candidate buttons work | ⬜ Test | Check if Dismiss/Add Recurring respond |
| AI chat works | ⬜ Test | Send "spent 30 for jeepney" → verify it logs |

---

## SECTION 3 — CAPSTONE 2 BACKLOG 📅

Do NOT build before defense. These are future work.

### From Original Backlog (now partially done)
| # | Feature | Status | Notes |
|---|---------|--------|-------|
| #4 | CSV/Bank import | ✅ DONE | Implemented as AI-powered text import (Sessions 5–8) |
| #5 | Spending heatmap calendar | ❌ Not done | Bill Calendar exists; heatmap is different (intensity coloring) |
| #17 | Debt payment timeline | ❌ Not done | Visual payoff projection chart |
| #18 | Quick-log chip customization | ❌ Not done | Let users pin specific expenses |
| #19 | Onboarding financial quiz | ✅ DONE | Implemented as setup wizard with quiz_challenge setting |
| #20 | Export to PDF monthly summary | ❌ Not done | Needs `pdf` package |
| #21 | Biometric lock for sensitive screens | ❌ Not done | App-level lock exists; per-screen is extra |
| #22 | AI conversation export | ❌ Not done | Export chat history as text file |
| #24 | PDF bank statement import | ❌ Not done | Needs PDF parsing package |

### New Capstone 2 Targets
| Feature | Why deferred | Complexity |
|---------|-------------|-----------|
| Multi-wallet system | Major DB schema change (account_id on expenses, DB v12+) | Very High |
| Transfer transactions | Needs wallet system first | High |
| Notification listener (auto-parse GCash) | Requires `BIND_NOTIFICATION_LISTENER_SERVICE` — sensitive Android permission, needs manual user setup in Settings | High |
| Spending heatmap calendar | Custom Flutter widget, no DB needed | Medium |
| Debt payment timeline | Visual payoff projection chart | Medium |
| FHS trend annotations | Markers on score chart showing what caused drops | Low |
| PDF export (monthly summary) | Needs `pdf` + `printing` packages | Medium |
| Quick-log chip customization | Settings table JSON array | Low |
| AI conversation export | share_plus + chat_history formatting | Low |
| Investment tracking (MP2, stocks) | New wallet type, manual balance updates | Low (after wallet system) |
| Shared/family wallets | Multi-user Firestore architecture | Very High |

---

## SECTION 4 — BLOCKED / POST-CAPSTONE 🚫

These cannot be done before defense for valid technical or business reasons.

| Item | Reason blocked | Can it be done later? |
|------|---------------|----------------------|
| **SQLite encryption** | SQLCipher requires native plugin + full DB migration. Breaking change to v11 schema. | Yes, post-capstone with DB v12 |
| **Profile photo cross-device sync** | Firebase Storage requires Blaze (paid) plan. Photos are local-only by design. | Yes, if budget allows |
| **Cloud Functions & scheduled tasks** | Firebase Blaze plan required. Currently using client-side triggers. | Yes, with paid Firebase |
| **Backend API proxy (hide Groq key)** | Needs a backend server. Currently key is in APK, mitigated by 60 msg/day cap. | Yes, post-capstone |
| **Bank notification auto-parsing** | `BIND_NOTIFICATION_LISTENER_SERVICE` is flagged as sensitive by Google Play. Requires manual user setup in Android Settings. Fragile — notification formats change. | Unlikely for Play Store |
| **Agentic bill payment (GCash/Maya)** | Requires BSP license for payment processing. GCash/Maya APIs are not public. PCI-DSS compliance required. | Blocked indefinitely |
| **Offline AI mode** | Would need a local LLM model — not feasible on budget phones (Poco X6 Pro has 8GB RAM but local models need 4–8GB just for the model). | Possible post-capstone with quantized models |
| **Soft-delete for sync resurrection** | Requires `deleted_at` column on all tables — major schema migration. Edge case: deleted item reappears on other device after sync. | Yes, with DB v12 planning |
| **Privacy policy** | Required for Google Play publishing. Not needed for academic defense. | Yes, before Play Store submission |
| **Data anonymization** | Required for formal data collection beyond academic use. | Yes, post-capstone |
| **True single-screen receipt capture** | mobile_scanner v5 has breaking API changes from v3.5.7 we use. | Yes, when v5 is stable |
| **AI voice response / TTS** | flutter_tts sounds robotic. Cloud TTS has cost. Groq has no TTS endpoint. | Yes, with cloud TTS budget |
| **Email receipt parsing** | Gmail API requires Google app verification for production. IMAP requires user password (security risk). | Yes, post-capstone with Gmail OAuth |

---

## SECTION 5 — KNOWN LIMITATIONS (for defense Q&A)

These are not bugs — they're intentional design decisions or platform constraints.

| Limitation | Explanation | Mitigation |
|-----------|-------------|-----------|
| Groq API key in APK | Free-tier key exposed in compiled code | 60 msg/day cap limits abuse; backend proxy planned post-capstone |
| 429 rate limit errors | Groq free tier limits rapid-fire requests | Wait 2–3 seconds between messages; shown as friendly error |
| Profile photo local-only | Firebase Storage requires paid plan | Photos stored on device; sync planned post-capstone |
| Offline AI | Groq API requires internet | Manual entry works fully offline; AI features degrade gracefully |
| Last-write-wins sync | No CRDT conflict resolution | Acceptable for single-user app; multi-device edge cases documented |
| SQLite not encrypted | SQLCipher migration too risky | Data is behind Firebase Auth + app lock PIN |
| 60 AI messages/day | Shared API key protection | Resets at midnight; Reset Daily Limit option in ⋮ menu |

---

## SECTION 6 — PENDING ISSUES FROM SmartSpend_PendingIssues.md

| # | Issue | Status |
|---|-------|--------|
| 1 | Feature tour not showing for new accounts on same device | ✅ Fixed (tour_done_${uid}) |
| 2 | Use Google profile picture as default avatar | ❌ Not done — MEDIUM priority |
| 3 | Analytics: add Last Month + month picker | ✅ Fixed (Last Month chip + Pick Month grid) |
| 4 | Backdated expenses: Component 4 scoring fairness | ❌ Not done — LOW priority, edge case |
| 5 | CSV/Bank import | ✅ Done (AI-powered text import) |
| 6 | PIN and biometric lock device-wide | ✅ Fixed (app_lock_pin_${uid}) |
| 7 | Chat history visible across accounts | ✅ Fixed (cleared on logout) |

**Issue 2 (Google profile picture)** — still not done. Low effort, medium value. Can be done before defense if time allows: in `login_screen.dart` `_syncAfterLogin()`, check `user.photoURL` and save to profile if no photo is set.

**Issue 4 (backdated expenses scoring)** — intentionally left. The current behavior is technically correct. Adding a note in the score breakdown ("Score reflects logging regularity from [first expense date]") would be the fix if needed.

---

## DB VERSION ROADMAP

| Version | Status | Contents |
|---------|--------|----------|
| v10 | Previous | Base schema |
| v11 | ✅ Current | custom_categories + photo_path + is_want + is_percentage/percentage_value + all new tables via _ensureColumns |
| v12 | Future (Capstone 2) | account_id on expenses — needed for multi-wallet system |

**New tables added via _ensureColumns (no version bump):**
- `category_rules` — user-defined keyword → category mappings
- `mood_log` — daily mood check-in
- `installment_plans` — Payment Plans tab
- `recurring_candidates` — subscription auto-detection
- `conversation_summaries` — AI chat compression

**New columns added via _ensureColumns:**
- `expenses.tags` — comma-separated custom tags
- `income.is_windfall` — one-time income flag

---

## CODING CONVENTIONS

- All DB writes fire AppEvent via event_bus for cross-screen refresh
- Theme colors: always `Theme.of(context).colorScheme.primary` — never hardcode hex
- Currency: always `CurrencyService.format()` and `CurrencyService.symbol`
- Amounts stored in PHP internally, converted for display only
- AI context injected before every message via `AIChatService.setFullContext()`
- Parallelized DB reads using Future.wait pattern
- Error handling: try-catch on all async operations, show SnackBar on error
- Run `getDiagnostics` after every change before building
- Build command: `flutter build apk --release --split-per-abi`
- Test APK: `app-arm64-v8a-release.apk` (Poco X6 Pro)
- NEVER put await inside setState()
- NEVER build unless explicitly told to build

---

*SmartSpend v2.5.0 — Lucid Frame*
*Brix A. Directo (Lead Developer), Cyrille John M. Rubis (UI/UX), Djaunathan Albert S. Madayag (PM/QA)*
*Lorma Colleges — CCSE, BSIT, City of San Fernando, La Union — 2025–2026*
