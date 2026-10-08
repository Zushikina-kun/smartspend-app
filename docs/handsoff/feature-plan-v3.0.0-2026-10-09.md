# SmartSpend — Feature Planning Doc
## Four Feature Groups: Transaction UX · Analytics Overhaul · AI Recovery · Chat Wayback
**Target version band:** v3.0.x (post v2.9.98)  
**Authored:** October 9, 2026 | **Status:** Plan (not yet implemented)  
**Authored by:** Kiro (session Oct 9 2026)  
**Handoff target:** Kiro / Claude / any LLM continuing this session

---

## 0 — Current State Audit (what the code actually does today)

### 0.1 Transactions Screen (729 lines)
| Area | Current state | Pain point |
|------|--------------|------------|
| Sort | Fixed DB order: `date DESC, COALESCE(updated_at, date) DESC, id DESC` | No in-app sort toggle; user can't sort by name, amount, logged-date, source |
| Grouping | None — flat list only | No date headers, no "by category" grouping |
| Filters | Period chips (6 options) + category chips + tags + Want/Need + Low-Confidence | Two rows of chips is visually heavy; no sort indicator anywhere |
| Search | Searches itemName, category, shopName, notes, tags | Already exists, but no "sort results by relevance" |
| Transaction date vs logged date | `date` = transaction date; `updatedAt` = ISO timestamp when logged/edited | The "Logged Today" chip exists but the two dates are never shown *separately* in the list tile; users can't tell which is which |
| Source tracking | `source` field (manual / ai / screenshot / import) exists on Expense model | No filter or group-by source |
| Pagination | Load-more button at 30 items | Fine as-is |

### 0.2 Analytics Screen (5,610 lines — the big one)
| Area | Current state | Pain point |
|------|--------------|------------|
| Navigation | `SingleChildScrollView` + massive `Column` — everything on one scroll | Feels like a never-ending wall; no way to jump to a section |
| Period filter | 8 chips (All/Week/Month/LastMonth/Year/Payday/Pick Month/Custom) | Good options, but chips wrap off-screen and the payday/custom ones are buried |
| Charts | Pie, bar (monthly), line (savings rate + daily), heatmap, FHS sparkline, component bar, period comparison | Good coverage, but all rendered regardless of period relevance |
| 50/30/20 | Always shows current calendar month regardless of selected period filter | Disconnected from the period filter the user just set |
| Category breakdown | Listed below pie chart | No quick sort by amount / % / delta |
| D7 comparison | Only shown when period is `all` or `monthly` | Useful but hidden |
| No section anchors | User must scroll past 20+ sections to reach AI Advice or Period Comparison | |
| Advanced toggle | One global `_showAdvancedCharts` bool | Either everything or nothing |

### 0.3 AI Screen / Chat Service
| Area | Current state | Pain point |
|------|--------------|------------|
| Failure feedback | Error snackbar on send failure; retry button (`_lastUserMessage`) | Silent failures on OCR/screenshot imports with no user-facing re-log path |
| Skipped-dup guardrail | `_sessionSkippedLog` feeds `[ALREADY IN DB]` note into next message | Fixed in v2.9.98, but no UI that says "these 3 items from your last message were skipped" |
| Manual recovery | None beyond editing/adding in Transactions screen | No guided "re-log what AI missed" flow |
| Bulk review | None | After a screenshot import with 5 items, no summary of what was recorded vs skipped |

### 0.4 Chat History / Archiving
| Area | Current state | Pain point |
|------|--------------|------------|
| Storage | Flat `chat_history` SQLite table (id, role, message, timestamp) | No session concept; messages from Jan 2026 and Oct 2026 are in the same table |
| Load limit | `getChatHistory(limit: 200)` — only last 200 messages shown | Older messages silently disappear |
| Archive | None | Clear All = permanent delete |
| Sessions | None | No way to "start a new conversation" without wiping history |
| Export | Chat export exists in ai_screen (`Share` icon) | Only exports current in-memory messages, not the DB history |

---

## 1 — Group A: Transaction Sort, Group & Search Overhaul

### 1.1 Goals
1. Allow sorting by: **transaction date** (default), **logged date**, **amount** (high→low, low→high), **name** (A→Z, Z→A), **source**.
2. Allow grouping by: **transaction date** (current default behavior), **logged date**, **category**, **source** (manual/AI/screenshot/import), **none** (flat).
3. Clearly distinguish "transaction date" from "logged date" in every tile and header.
4. Add sort and group picker that is fast to reach and visually unobtrusive.

### 1.2 Sort options spec

| Sort key | Ascending | Descending | Notes |
|----------|----------|-----------|-------|
| Transaction date | Oldest first | Newest first (default) | Uses `expense.date` |
| Logged date | Oldest logged | Newest logged | Uses `expense.updatedAt ?? expense.date` |
| Amount | Cheapest first | Most expensive first | |
| Name | A→Z | Z→A | Case-insensitive, uses `expense.itemName` |
| Source | — | — | Groups manual/ai/screenshot/import alphabetically |

### 1.3 Group options spec

| Group key | Header label example | Notes |
|-----------|---------------------|-------|
| Transaction date | "September 11, 2026" | One header per unique date |
| Logged date | "Logged Sep 11 · 3 items" | Uses `updatedAt` date portion |
| Category | "Food & Dining · ₱2,450" | With subtotal |
| Source | "AI 🤖 · 8 items" / "Screenshot 📷 · 3 items" | With item count |
| None | — | Flat list (current default feel) |

### 1.4 UI: Sort & Group picker
- **Entry point:** A small "Sort / Group" pill button in the AppBar (next to existing icons), using `Icons.swap_vert` icon + label that adapts: "Date ↓ · By Date" when defaults, updates to show active sort/group.
- **Opens a ModalBottomSheet** with two sections: "Sort by" (radio group) + "Group by" (radio group) + a "Reverse order" toggle at the bottom.
- Dismiss saves state. Persisted to `SharedPreferences` keys `txn_sort_key` and `txn_group_key`.
- The sort/group state is shown as a small subtitle under the AppBar title: e.g. "Sorted by amount ↓ · Grouped by category".

### 1.5 Group header widget
```
┌─────────────────────────────────────────────────────┐
│  [Icon]  Group label               N items · ₱total │
└─────────────────────────────────────────────────────┘
```
- Sticky headers using slivers (`SliverList` + `SliverPersistentHeader`) — replaces current `ListView.builder`.
- Collapsible (tap header to collapse/expand the group) — stored in a `Set<String> _collapsedGroups`.

### 1.6 Chip row cleanup
Current two rows of chips is cluttered. Proposed:
- **Row 1 (period):** Unchanged — All Time / Today / This Week / This Month / This Year / Logged Today
- **Row 2 (quick filters):** Category dropdown (single `DropdownButton` replacing the long chip row) + Want/Need toggle (2 chips) + Low-Confidence chip + Tags (overflow-expandable, hidden by default if > 3 tags)
- This turns 2+ overflowing rows into a cleaner 1+1 layout.

### 1.7 Tile date display
`ExpenseTile` should show both dates when they differ:
```
Casio Watch    ₱1,403
Food · manual
📅 Sep 9, 2026       🕓 Logged: Sep 11
```
Only show the "Logged:" line when `updatedAt?.date != expense.date`.

### 1.8 Search improvements
- Add **"Sort results by relevance"** when a search query is active — items where the query matches `itemName` rank above `category`/`notes` matches.
- Show the match highlight (bold the matched substring).

### 1.9 DB changes needed
- `getExpenses()` already returns all; sorting is done in-memory (fine for typical dataset sizes up to ~5,000 rows).
- No DB schema change needed for Group A.

### 1.10 Files to change
| File | Change |
|------|--------|
| `lib/screens/transactions_screen.dart` | Add `_sortKey`, `_groupKey`, `_sortDesc` state; refactor `_applyFilter()` into `_applyFilterAndSort()`; replace `ListView.builder` with `CustomScrollView`+Slivers; add sort/group bottom sheet; chip row cleanup |
| `lib/widgets/expense_tile.dart` | Add dual-date display (conditional) |
| `lib/services/db_service.dart` | No change needed |

---

## 2 — Group B: Analytics Screen Overhaul

### 2.1 Goals
1. Make the screen navigable — users should be able to jump to any section in ≤2 taps.
2. Fix the 50/30/20 card disconnection from the period filter.
3. Add sort control to category breakdown list.
4. Make the "advanced" toggle more granular (per-section, not one global toggle).
5. Reduce visual noise from the period filter row on small screens.
6. Smooth out the wall-of-content by grouping sections into logical tabs or an anchor index.

### 2.2 Proposed navigation model: Section Tabs + Quick Jump

Replace the current single `SingleChildScrollView` monolith with a `TabBar` + `TabBarView`:

| Tab | Contents |
|-----|---------|
| **Overview** | Period filter chips · Pie chart · Category breakdown · Monthly bar chart · 50/30/20 · Wants vs Needs |
| **Trends** | Daily trend line · Day-of-week heatmap · Savings rate · Spending forecast · Period comparison |
| **Health** | FHS score history sparkline · Component breakdown · Milestones · DTI · Emergency fund |
| **More** | Mood & Spending · Market Insights · AI Advice · Monthly Summary |

- Tabs are `DefaultTabController` with `TabBar` in the AppBar's `bottom`.
- Period filter chips stay at the top of the **Overview** tab and are also shown in **Trends** (the ones most affected by period).
- **Health** and **More** tabs ignore the period filter (they use all-time / current month data by definition).

### 2.3 Section anchor alternative (lighter option)
If the TabBar approach is too much of a rework for the capstone timeline, a lighter alternative is a **Quick Jump chip row** at the very top (sticky):
```
[Overview] [Trends] [Health] [AI Advice]
```
Each chip `Scrollable.ensureVisible`s a `GlobalKey`-anchored section. No tab state, no extra controllers. This is lower effort and fully backward-compatible.

**Recommendation: Quick Jump chips (lighter, safer for capstone).**

### 2.4 Category breakdown sort control
Currently the category breakdown list order mirrors the pie chart (sorted by total DESC). Add a small sort toggle above the list:
```
Category Breakdown  [▼ Amount]  [▲ Name]  [Δ vs last month]
```
Three toggle states cycling on tap. The `[Δ]` sort shows biggest over-spenders at top.

### 2.5 50/30/20 period-awareness fix
The card currently always uses `_thisMonthExpenses` (hardcoded to current calendar month). Fix: read expenses from the currently filtered `_expenses` list. Gate the card with a note if the selected period isn't a clean "month" (e.g., "This calculation is most accurate for a full calendar month").

### 2.6 Per-section advanced toggle
Replace the single `_showAdvancedCharts` bool with a `Set<String> _expandedSections` that starts with a defaults set. Each section has a show/hide chevron. The "Show more charts" AppBar button becomes "Expand all / Collapse all".

### 2.7 Period filter chip cleanup
The 8 chips overflow. Proposed: show 4 primary chips (All / This Month / Last Month / This Year) always, and put the rest (Payday Cycle / Pick Month / Custom / This Week) inside an `OverflowBar` that wraps, or behind a "More…" chip that opens a small popup menu.

### 2.8 Files to change
| File | Change |
|------|--------|
| `lib/screens/analytics_screen.dart` | Add tab/anchor system; fix 50/30/20 period; add category sort toggle; replace `_showAdvancedCharts` bool; chip overflow fix |

---

## 3 — Group C: AI Failure Recovery

### 3.1 Problem statement
When a user tells the AI about multiple transactions (e.g., pastes a screenshot) and the AI fails to record some of them (network error, duplicate guard, parsing failure, date confusion), there is currently **no clear UI path** to identify and fix the gap.

### 3.2 Proposed: "AI Session Summary" card
After each AI response that contained at least one `log_expense` action, show a **collapsible session result card** in the chat bubble area (not a snackbar — persistent until next message):

```
┌──────────────────────────────────────────────────────┐
│  ✅ Recorded 2 items   ⚠️ Skipped 1   ❌ Failed 1    │
│  ─────────────────────────────────────────────────── │
│  ✅ Casio Watch · ₱1,403 · Sep 9                     │
│  ✅ 8Bitdo Gamepad · ₱1,595 · Sep 9                  │
│  ⚠️ 8Bitdo Receiver · ₱995 — Already in DB           │
│  ❌ GCash Transfer · ₱500 — Parse error              │
│                                                        │
│  [Review skipped/failed items]                         │
└──────────────────────────────────────────────────────┘
```

- The card reads from `_sessionActionLog` (already tracked) and `_sessionSkippedLog` (v2.9.98).
- "Review" button opens a bottom sheet with each problematic item pre-filled in a mini form.

### 3.3 Proposed: "Re-log helper" bottom sheet
Opened from the session summary card's "Review" button. Shows a list of items that were skipped or failed, each with:
- Item name (editable)
- Amount (editable)
- Date (defaulting to the session's detected date — critical for backdated items)
- A "Log this" button per item

This calls `DBService.insertExpense()` directly (bypassing the AI entirely — a "manual override" path). It also clears those items from `_sessionSkippedLog` after logging.

### 3.4 Proposed: Undo-aware re-log
The "Recently AI-logged" card in `TransactionsScreen` already exists (12C). Strengthen it:
- Show items from the **last session** (not just last 24h) — use a new `_sessionLoggedIds` list in AIChatService.
- Add "Something missing?" link below the card that opens the Re-log helper with the session's pending items.

### 3.5 Proposed: Screenshot import result sheet
When the user triggers batch screenshot import and AI processes it, show a `ScanReviewScreen`-like result sheet:
- Items successfully logged (green checkmark)
- Items skipped as duplicate (yellow warning, with "Force re-log" option)
- Items that failed to parse (red X, with "Add manually" button per item)

This reuses the existing `ScanReviewScreen` UI pattern.

### 3.6 DB changes needed
- New helper in `AIChatService`: `getSessionSummary()` → returns `{recorded: [...], skipped: [...], failed: [...]}`.
- `_sessionActionLog` already captures what was recorded. Need to also capture failures with reason.
- No schema change needed.

### 3.7 Files to change
| File | Change |
|------|--------|
| `lib/services/ai_chat_service.dart` | Expand `_sessionActionLog` to include a `status` field (recorded/skipped/failed) + `reason`; expose `getSessionSummary()` |
| `lib/screens/ai_screen.dart` | Add session summary card widget after each response containing actions; add Re-log helper sheet |
| `lib/screens/transactions_screen.dart` | Strengthen "Recently AI-logged" card with session link |

---

## 4 — Group D: Chat Wayback / Session Archiving

### 4.1 Problem statement
The `chat_history` table has no session concept. It is a flat append-only log. After a few weeks of daily use (at ~20 messages/day = 140/week), the 200-message load limit means the user loses visibility into chats older than 10 days. And "Clear All" is permanent.

### 4.2 Design: Chat sessions

Introduce a `chat_sessions` table (DB v14 migration):
```sql
CREATE TABLE chat_sessions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT,
  created_at  TEXT NOT NULL,
  archived_at TEXT,
  is_current  INTEGER DEFAULT 0
);
```

Add `session_id INTEGER` column to `chat_history`:
```sql
ALTER TABLE chat_history ADD COLUMN session_id INTEGER;
```

Existing rows get `session_id = 0` (virtual "Previous Chats" session).

### 4.3 Session lifecycle

| Action | What happens |
|--------|-------------|
| App first launch after migration | All legacy messages get `session_id` of the inserted legacy session row. |
| User taps "New Chat" | Current session gets `is_current = 0`; new session row inserted with `is_current = 1`. The `_messages` list in `ai_screen.dart` is cleared, AI context is refreshed. |
| New Chat auto-naming | After the session ends (next New Chat), the title auto-generates from the first user message (truncated to 40 chars). |
| User opens Chat History | Shows **session list** first (WhatsApp-style conversation list), not a flat message dump. |
| User taps a session | Opens a read-only message view for that session. |
| User archives a session | Sets `archived_at`; moves to "Archived" section. |
| User deletes a session | Deletes session row + all messages with that `session_id`. |

### 4.4 ChatHistoryScreen redesign

**Screen 1 — Session list:**
```
Chat History
[Search sessions…]

● Active
  ─ Current Chat (today, N messages)

● Recent (last 30 days)
  ─ Oct 8 · "Screenshot from Shopee" · 22 msgs
  ─ Oct 5 · "Budget check for Lazada haul" · 15 msgs

● Older
  ─ Sep 15 · "Starting September budget" · 31 msgs

● Archived
  ─ Aug 2026 — Summer spending (archived)
```

**Screen 2 — Session view (read-only):**
- Same bubble layout as today
- AppBar shows session title (editable on tap)
- "Load more" pagination within session
- Copy, share session export buttons

### 4.5 "New Chat" button
- Added to `ai_screen.dart` AppBar as `Icons.add_comment_outlined`
- Confirm dialog: "Start a new chat? Your current conversation will be saved and you can come back to it anytime."
- On confirm: creates new session, clears `_messages`, reloads context.

### 4.6 DB migration (v14)
```dart
if (oldVersion < 14) {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS chat_sessions (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      title       TEXT,
      created_at  TEXT NOT NULL,
      archived_at TEXT,
      is_current  INTEGER DEFAULT 0
    )
  ''');
  try {
    await db.execute('ALTER TABLE chat_history ADD COLUMN session_id INTEGER');
  } catch (_) {}
  // Insert legacy session, get its id, update all null session_id rows
  final legacyId = await db.insert('chat_sessions', {
    'title': 'Previous chats',
    'created_at': DateTime.now().toIso8601String(),
    'is_current': 0,
  });
  await db.execute(
    'UPDATE chat_history SET session_id = ? WHERE session_id IS NULL',
    [legacyId],
  );
}
```

### 4.7 Files to change
| File | Change |
|------|--------|
| `lib/services/db_service.dart` | DB v14 migration; `createSession()`, `getCurrentSession()`, `getSessionList()`, `archiveSession()`, `deleteSession()`, `getChatHistoryBySession()` |
| `lib/screens/chat_history_screen.dart` | Redesign to session list → session view two-screen flow |
| `lib/screens/ai_screen.dart` | Add "New Chat" button; write to current `session_id` on `insertChatMessage()`; on `clearChat()` create new session instead of delete all |

---

## 5 — Implementation Order (suggested)

| Phase | Version target | Work |
|-------|---------------|------|
| 1 | v3.0.0 | **Group C (AI Recovery)** — smallest scope, highest value right now (post v2.9.98 screenshots issue) |
| 2 | v3.0.1 | **Group D (Chat Wayback)** — DB migration before data grows too large; foundational |
| 3 | v3.0.2 | **Group A (Transaction Sort/Group)** — clean code, self-contained, good for capstone demo |
| 4 | v3.0.3 | **Group B (Analytics Overhaul)** — biggest file, needs careful refactor; save for last |

---

## 6 — Version number mapping

| Version | Group | What ships |
|---------|-------|-----------|
| v3.0.0 | C | Session summary card, Re-log helper sheet, screenshot import result sheet |
| v3.0.1 | D | Chat sessions table (DB v14), session list screen, New Chat button |
| v3.0.2 | A | Sort/Group bottom sheet, slivers group headers, ExpenseTile dual-date, chip cleanup |
| v3.0.3 | B | Analytics quick-jump anchors, 50/30/20 fix, category sort toggle, chip overflow fix |

---

## 7 — Open questions (decide before implementation)

| # | Question | Recommendation |
|---|---------|---------------|
| 1 | Analytics navigation: tabs or anchor chips? | **Quick Jump chips** for capstone timeline |
| 2 | Default sort for transactions: keep transaction date DESC or switch? | **Keep transaction date DESC** — matches user mental model |
| 3 | Chat sessions: auto-name from first message or let user name at creation? | **Auto from first user message**, user can rename |
| 4 | Group B period-filter scope: do all charts respond, or only spending charts? | **Spending charts only** — health/FHS always uses current month |
| 5 | Re-log helper: go through AI (re-prompt) or directly insert? | **Direct insert** — avoids recursive dup-guard problem |

---

## 8 — Capstone documentation impact

- **AI Recovery (C):** Demonstrates transparent AI accountability. Cites responsible-AI transparency principles.
- **Chat Wayback (D):** Shows system design thinking — session management, data lifecycle, migration safety.
- **Transaction Sort (A):** Directly addresses a known finance app UX pain point.
- **Analytics Tabs (B):** Shows information architecture skill — structuring dense data for usability.

---

*This document is a planning artifact only. No code has been changed as of Oct 9, 2026.*  
*Current shipped version: v2.9.98+98*
