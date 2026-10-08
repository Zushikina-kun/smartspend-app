# SmartSpend — Kiro-to-Kiro Handoff
## v3.0.0 | October 9, 2026

**From:** Kiro session (Oct 9, 2026)  
**To:** Next Kiro session (or Claude)  
**Shipped:** v3.0.0+99  
**GitHub:** https://github.com/Zushikina-kun/smartspend-app  
**Previous handoffs in:** `docs/handsoff/`

---

## 1 — What shipped in v3.0.0

All four feature groups from `feature-plan-v3.0.0-2026-10-09.md` were implemented and pushed in a single commit (`112a635`).

### Group A — Transaction Sort & Group (`transactions_screen.dart`)
- **New enums:** `TxnSortKey` (7 options) and `TxnGroupKey` (5 options) at the top of the file
- **Sort keys:** Transaction date (default) · Logged date · Amount high→low · Amount low→high · Name A→Z · Name Z→A · Source
- **Group-by keys:** Transaction date · Logged date · Category (with ₱ subtotal) · Source (manual/AI/screenshot) · None (flat)
- **Sort/Group sheet:** Tapping ⇅ icon in AppBar opens a `ModalBottomSheet` with `FilterChip` radio-group for each; persisted to `SharedPreferences` (`txn_sort_key`, `txn_group_key`)
- **Group headers:** Collapsible — tap to expand/collapse; tracks state in `_collapsedGroups Set<String>`; shows item count + subtotal
- **Category filter:** Replaced the overflowing 20+ chip row with a compact `DropdownButton`; Want/Need/⚠️ chips consolidated into a single Row 2 below the period chips
- **Relevance search:** When search query is active, matches are ranked: itemName match > category/shop > notes/tags
- **`_sourceOf()`:** Detects source from expense notes — `'screenshot'` / `'ai'` / `'manual'`
- **No DB changes** for this group — all sorting/grouping done in-memory

### Group D — Chat Sessions / Wayback (`db_service.dart`, `ai_screen.dart`, `chat_history_screen.dart`)
- **DB v13 → v14:** New `chat_sessions` table (id, title, created_at, archived_at, is_current); `session_id INTEGER` added to `chat_history`
- **Migration:** All existing messages migrated to a "Previous chats" legacy session on first run after upgrade
- **`_ensureColumns`:** Also adds `session_id` column and creates `chat_sessions` table idempotently as a safety net for edge cases
- **New DB methods:** `createNewChatSession()`, `getCurrentSessionId()`, `_createSession()`, `getChatSessions()`, `autoTitleSession()`, `renameChatSession()`, `archiveChatSession()`, `deleteChatSession()`, `getChatHistoryBySession()`
- **`saveChatMessage`:** Now auto-resolves `session_id` — looks up current session, creates one if none exists
- **`ai_screen.dart`:** Added "New Chat" ➕ button in AppBar; on confirm: auto-titles current session, creates new session, clears `_messages` + context. "Clear chat" (🔄) now deletes the current session and creates a fresh one instead of wiping all history. `_loadContext` on screen open now loads messages from current session only (`getChatHistoryBySession`).
- **`chat_history_screen.dart`:** Completely rewritten. Session list view (Active · Recent · Older · Archived sections) → `_ChatSessionViewScreen` (read-only bubble view). Long-press session for rename/archive/delete sheet. Session title editable by tapping AppBar. Copy-to-clipboard export. Search within session. Day dividers.
- **Logout:** Both `chat_history` and `chat_sessions` tables cleared on logout

### Group C — AI Recovery (`ai_chat_service.dart`, `ai_screen.dart`)
- **New types:** `AiItemStatus` enum (recorded/skipped/failed) and `AiSessionResultItem` class — defined at the top of `ai_chat_service.dart` (outside the class)
- **`_lastResponseItems`:** Static list in `AIChatService`; cleared at start of each `sendMessage()` (non-retry); exposed as read-only via `lastResponseItems` getter
- **`recordSuccessItem()`:** Called immediately after `DBService.insertExpense()` in the `log_expense` action executor in `ai_screen.dart`
- **`recordSkippedDuplicate()`:** Already existed; now also appends to `_lastResponseItems` with `status: AiItemStatus.skipped`
- **Session summary card:** Rendered above the `LinearProgressIndicator` after each AI response. Shows ✅/⚠️/❌ per item with amounts and dates. Has a "Review & re-log" button that opens `_showRelogHelper()`. Dismissed by tapping ✕. State in `_sessionSummaryDismissed` (bool) and `_sessionSummaryItems` (List).
- **`_RelogHelperSheet`:** New `StatefulWidget` at the end of `ai_screen.dart`. Editable name/amount/date per item. "Log this" calls `DBService.insertExpense()` directly — bypasses AI and dup-guard. Auto-closes when all items are logged.

### Group B — Analytics (`analytics_screen.dart`)
- **Quick Jump anchors:** `GlobalKey` fields `_keyOverview`, `_keyTrends`, `_keyHealth`, `_keyAiAdvice` + `_scrollController`. A `SingleChildScrollView` chip row at the very top calls `Scrollable.ensureVisible` per key. Zero-height `SizedBox(key: _key*)` widgets mark each section.
- **Period chip overflow fix:** Replaced 8 raw chips with 4 primary chips (All / This Month / Last Month / This Year) + `PopupMenuButton` ("More ▾") for the less-used options (This Week · Payday Cycle · Pick Month · Custom Range). Active state of the "More" popup is reflected in the chip label.
- **Category breakdown sort toggle:** `_catBreakdownSort` int (0=Amount, 1=Name, 2=Δ vs last month). Displayed as a tappable pill next to the section header. Delta sort uses `_lastMonthCategoryTotals` (already computed in `_loadData()`). Uses `sortedCats` list derived from `categories`.
- **`_scrollController`:** Added to `SingleChildScrollView`; disposed in `dispose()`.

---

## 2 — Authoritative build numbers (v3.0.0)

| Metric | Value |
|--------|-------|
| Version string | **3.0.0** |
| pubspec version | `3.0.0+99` |
| kAppVersion | `'3.0.0'` in `debug_service.dart` |
| Platform | Android (Flutter/Dart) |
| Min SDK | Android 5.0 (API 21) |
| Target SDK | Android 16 (API 36) |
| SQLite schema | **v14, 26 tables** |
| New tables in v14 | `chat_sessions` |
| New columns in v14 | `chat_history.session_id` |
| AI providers | **9** (8 cloud + 1 custom local) |
| Primary AI model | Gemini 3.5 Flash-Lite (AQ. key via Remote Config) |
| Agentic actions | **34** |
| Input modalities | **7** |
| Screens | **43** Dart files |
| Services | **31** Dart files |
| Achievement badges | **25** |
| Daily AI message limit | **150** |
| Color themes | **11** |
| APK size | ~45 MB (arm64-v8a, split, obfuscated) |
| AAB size | ~75 MB (Play Store bundle, CI-built) |
| GitHub | https://github.com/Zushikina-kun/smartspend-app |

---

## 3 — Files changed in v3.0.0

| File | Type of change |
|------|----------------|
| `lib/screens/transactions_screen.dart` | Major refactor — sort/group enums, `_applyFilterAndSort`, grouped list builder, category dropdown, chip row 2 consolidation |
| `lib/screens/analytics_screen.dart` | Quick Jump anchors, period chip "More" menu, category breakdown sort toggle, `_scrollController` |
| `lib/screens/ai_screen.dart` | Session summary card, Re-log helper sheet (`_RelogHelperSheet` + `_RelogItem`), New Chat button, session-aware `_loadContext`, session-safe Clear Chat |
| `lib/screens/chat_history_screen.dart` | Complete rewrite — session list + `_ChatSessionViewScreen` |
| `lib/screens/whats_new_screen.dart` | Version `3.0.0`, new 4 feature entries prepended |
| `lib/services/ai_chat_service.dart` | `AiItemStatus` enum, `AiSessionResultItem` class, `_lastResponseItems`, `recordSuccessItem()`, `_clearLastResponseItems()` |
| `lib/services/db_service.dart` | v14 migration, `chat_sessions` in onCreate + `_ensureColumns`, all session methods, updated `saveChatMessage`, logout clear |
| `lib/services/debug_service.dart` | Chat section now shows session summary (count, title, message count, current/archived flags) |
| `pubspec.yaml` | `2.9.98+98` → `3.0.0+99` |
| `docs/guides/FEATURE_BACKLOG.md` | Part 0 updated to v3.0.0, SQLite schema v14/26 tables, v3.0.0 in recent releases |
| `docs/reference/CAPSTONE_REFERENCE.md` | Version 3.0.0, DB v14/26 tables |
| `docs/status/PROJECT_STATUS.md` | Version 3.0.0, manuscript update items for v3.0.0 |
| `docs/handsoff/feature-plan-v3.0.0-2026-10-09.md` | Planning artifact (added) |

---

## 4 — Known gaps / next priorities

### Remaining audit issues
1. **`_applyFilter` nested setState** — when `initialIds` is set, `_applyFilter()` is called inside `_load`'s `setState`, then calls `setState` again for the `initialIds` branch. Pre-existing bug, low impact (only happens when TransactionsScreen is opened from DataQuality screen).
2. **Grouped list no pagination** — when a group-by key is active (not "None"), all items in all groups are rendered. For users with very large datasets (1000+ expenses) this could be slow. Acceptable for typical capstone dataset sizes (<300 expenses).
3. **`_sourceLabel` removed** — was defined but never used; cleaned up. If a future tile needs to display source as a label string, use `_sourceOf()` directly.

### Capstone manuscript updates still needed (for Cyrille)
- Update DB schema reference: `v13, 25 tables` → `v14, 26 tables`
- Update version throughout manuscript: `2.9.92` → `3.0.0`
- Add to Features Implemented: Transaction sort/group, Chat sessions, AI recovery card, Analytics quick-jump

### Feature ideas for future sessions
- **50/30/20 period-awareness fix** — currently hardcoded to `_thisMonthExpenses` regardless of period filter. Plan doc says to read from `_expenses` (filtered list) + add a caveat note. Medium risk change in a 5,610-line file.
- **Analytics full tab structure** — plan doc still has TabBar as an option (heavier, but cleaner). Current Quick Jump anchors are the "lighter, safer" choice for capstone timeline.
- **Screenshot import result sheet** — reuse `ScanReviewScreen` UI to show per-item recorded/skipped/failed after batch imports. The data is already tracked in `_lastResponseItems`; just needs a sheet trigger after `_executeBatchImport`.
- **Transaction tile dual-date** — `ExpenseTile` already shows `loggedDateStr` when dates differ (existing code from pre-v3.0.0). No change needed.
- **Grouped list pagination** — if dataset grows, add per-group "Load more" or virtual scrolling.

---

## 5 — Codebase key locations

| What | Where |
|------|-------|
| DB migration | `db_service.dart` `onUpgrade` — `if (oldVersion < 14)` block |
| Session management methods | `db_service.dart` lines ~1650–1780 |
| AI result tracking | `ai_chat_service.dart` lines ~76–140 (after the class-level vars) |
| Session summary card | `ai_screen.dart` `_buildSessionSummaryCard()` method |
| Re-log helper sheet | `ai_screen.dart` `_RelogHelperSheet` class at end of file |
| Transaction sort/group | `transactions_screen.dart` — `TxnSortKey` enum, `_sortExpenses()`, `_buildGroups()`, `_showSortGroupSheet()` |
| Analytics Quick Jump | `analytics_screen.dart` — `_keyOverview` etc GlobalKeys + Quick Jump chip row in body |
| Chat session list | `chat_history_screen.dart` — `ChatHistoryScreen` + `_ChatSessionViewScreen` |

---

## 6 — Verified working (post-build checks)
- `flutter analyze --no-pub` → **0 errors** (442 info/warnings, pre-existing)
- `flutter build apk --debug --target-platform android-arm64` → **✅ Built successfully**
- DB migration is idempotent (all `ALTER TABLE` wrapped in `try/catch`, all `CREATE TABLE IF NOT EXISTS`)
- `_ensureColumns` adds `session_id` and creates `chat_sessions` as safety net for all migration paths

---

*This document is the current authoritative handoff as of October 9, 2026.*  
*Previous: `kiro-to-kiro-handoff-2026-10-05.md`, `kiro-to-claude-handoff-2026-10-06.md`, `claude-to-kiro-sync-2026-10-07.md`*

---

## 7 — Second-pass audit fixes (commit `07c9371`)

Three issues found and fixed after the initial ship:

| # | File | Issue | Fix |
|---|------|-------|-----|
| 1 | `ai_screen.dart` | The **fallback retry path** (silent provider switch on timeout/auth error) executed actions but never updated `_sessionSummaryItems` — summary card would stay hidden even if a retry succeeded with log_expense actions | Added `retryResultItems = AIChatService.lastResponseItems` capture + setState update in the fallback success block |
| 2 | `ai_screen.dart` (`_RelogHelperSheet`) | `_logItem()` called `DBService.insertExpense()` directly but never fired `AppEvent.expenseChanged` — home screen, transactions screen, and analytics would NOT auto-refresh after a re-log | Added `fireEvent(AppEvent.expenseChanged)` after the insert |
| 3 | `analytics_screen.dart` | Category breakdown sort toggle used `sortedCats.asMap().entries` index `i` for color dots — when sorted by Name or Delta, the dot colors in the breakdown table didn't match the pie chart legend colors | Changed color lookup to `categories.indexOf(cat)` (original unsorted index) so colors always match the pie chart |

*All three were logic/UX gaps not caught by the analyzer. Second-pass audit complete. No further issues found.*

---

## 8 — Post-v3.0.0 work (v3.0.1 / v3.0.2 / freemium planning)

### v3.0.1 — Demo account overhaul
`demo_service.dart` completely rewritten. 18 tables seeded:
- Profile (Brix Angelo S. Directo, Lorma email, green avatar URL)
- 3 wallets (Cash ₱547, GCash ₱1,312.50, BDO ₱4,250) + wallet_history
- 35 expenses across 3 months, 9 categories
- 9 budgets, 3 goals, 4 recurring, 3 debts
- 2 installment plans (HomeCredit + ShopeePay Later)
- 4 insurance/contributions (SSS, PhilHealth, Pag-IBIG, Sun Life)
- 2 paluwagan groups
- 30-day score history, 14-day mood log
- 25 category rules, 5 scan history entries
- Chat seed (demo session with 5 messages so Chat History isn't empty)
- All settings pre-configured (account_type: student, payday_date: 1, etc.)
- `_clearAll()` wipes ALL 18 tables including wallet_history, chat_sessions, paluwagan

`profile_screen.dart`: new `_resetDemoDefaults()` method + orange "Reset to Demo Defaults" ListTile below the existing "Load Demo Data" tile.

### v3.0.2 — Support links + url_launcher
- `pubspec.yaml`: added `url_launcher: ^6.3.1`
- `AndroidManifest.xml`: `<queries>` block for https/http URL intents (Android 11+)
- `about_screen.dart`: "Support the Project" section — Buy Me a Coffee, Ko-fi, PayPal buttons (open browser), GCash/PayMaya tile (copies 09953583040 to clipboard)
- `index.html`: version v3.0.1, 9 AI providers, download links updated, support row in footer
- `README.md`: version 3.0.1, support table at top, tech stack corrected

### Freemium planning (v4.0 target — post-capstone defense)
Full plan in `docs/handsoff/freemium-split-plan-2026-10-09.md`.

**Pricing:** ₱59/month · ₱299/year (7-day free trial, push as default) · ₱799 lifetime  
**Infrastructure:** `pro_service.dart` created — everyone is Pro in v3.x, full ProFeature enum documented  
**Build flavors:** `APP_FLAVOR=dev` (local, always Pro) / `APP_FLAVOR=prod` (CI/release)  
**CI updated:** `--dart-define=APP_FLAVOR=prod` added to both APK and AAB build steps  
**HOWTORUN.md:** updated with `flutter run --dart-define=APP_FLAVOR=dev` + flavor explanation  

**Key freemium decisions made:**
- Free tier: manual logging + AI text chat (30/day) + FHS score (always free) + current-month pie chart + 5 budgets/3 goals/3 recurring/2 debts/1 wallet + **basic cloud sync** (expenses + budgets + goals — free data is never at risk)
- Pro gates: screenshot/voice/barcode imports, 150 AI msg/day, all analytics depth, multi-wallet, all Filipino features (paluwagan/insurance/installments), full cloud sync, backup/restore, unlimited everything
- AI text logging ("I spent 65 for lunch") **always stays free** — this is the core feature
- Local LLM private mode is Pro — our unique differentiator, justifies the price
- Competitor research: Agila (free), PISO (free), Tarsi (~₱300–350 one-time) — we charge more but have features they don't

**Support links (live across app + website + README):**
- Buy Me a Coffee: https://buymeacoffee.com/zushikina_kuroh143
- Ko-fi: https://ko-fi.com/zushikina143
- PayPal: https://paypal.me/BrixDirecto
- GCash/PayMaya: 09953583040

### Files changed since v3.0.0
| File | Change |
|------|--------|
| `lib/services/demo_service.dart` | Complete rewrite — 18 tables, full demo dataset |
| `lib/screens/profile_screen.dart` | `_resetDemoDefaults()` + orange reset tile |
| `pubspec.yaml` | Added `url_launcher: ^6.3.1`; version bumped to `3.0.2+99` |
| `android/app/src/main/AndroidManifest.xml` | `<queries>` for https/http intents |
| `lib/screens/about_screen.dart` | Support links section (url_launcher + Clipboard) |
| `lib/services/pro_service.dart` | New — ProService + ProFeature enum (everyone Pro in v3.x) |
| `lib/main.dart` | `import pro_service.dart` + `ProService.init()` call after AppConfig.init() |
| `.github/workflows/release.yml` | `--dart-define=APP_FLAVOR=prod` on build steps |
| `HOWTORUN.md` | Version 3.0.2; `flutter run --dart-define=APP_FLAVOR=dev` |
| `index.html` | v3.0.1, 9 providers, updated download links, support footer |
| `README.md` | v3.0.1, support table at top, corrected tech stack |
| `docs/guides/FEATURE_BACKLOG.md` | Part 0B expanded with shipped v3.0.x + v4.0 roadmap |
| `docs/handsoff/freemium-split-plan-2026-10-09.md` | Created — full freemium spec with pricing |
| `docs/handsoff/marketing-and-demo-plan-2026-10-09.md` | Updated pricing ₱59/299/799 |

*Appended October 9, 2026 — current shipped version v3.0.2+99*
