# UX Polish Plan

Four targeted UX improvements for the SmartSpend Flutter app. Each task is
independent — they can be implemented in any order without affecting one another.

---

## TASK 1 — Undo SnackBar after AI expense logging

**File:** `lib/screens/ai_screen.dart`

### Background

`UndoService.record()` is already called inside `_executeAction()` each time an
expense, budget, goal, debt, or recurring item is written to the DB (lines ~922,
~1097, ~1344, ~1418, ~1450, ~1503, ~1539, ~1721). The undo snackbar must fire
**once** at the outer response level — not inside the per-action loop — so the
user gets a single "Expense logged ✅ / Undo" banner per AI reply.

`UndoService` is already imported at line ~25:
```dart
import '../services/undo_service.dart';
```

### Insertion point

After a successful send, the code at lines **773–792** is:

```dart
if (mounted) {
  final resultItems = AIChatService.lastResponseItems;
  setState(() {
    _messages.add({
      "role": "ai",
      "text": reply,
      "ts": DateTime.now().toIso8601String().substring(0, 10),
    });
    _lastUserMessage = null; // clear retry on success
    // Show session summary card if any actions were logged/skipped
    if (resultItems.isNotEmpty) {
      _sessionSummaryItems = List.from(resultItems);
      _sessionSummaryDismissed = false;
    }
  });
  _scrollToBottom();
}
```

The undo snackbar should fire **after** `_scrollToBottom()` and **inside** the
`if (mounted)` block. Add it between `_scrollToBottom()` and the closing `}` of
`if (mounted)`.

### Code to add (after `_scrollToBottom();`)

```dart
// Show undo snackbar once if any expense/record actions were taken
if (resultItems.any((i) => i.status == AiItemStatus.recorded)) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      content: const Text('Expense logged ✅'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          final undone = await UndoService.undo();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              content: Text(undone ? 'Undone ✓' : 'Undo window expired'),
            ));
            if (undone) _loadContext(silent: true);
          }
        },
      ),
    ),
  );
}
```

> **Note on condition:** The task brief says to fire after all items are
> processed. Gating on `resultItems.any((i) => i.status == AiItemStatus.recorded)`
> ensures the snackbar only appears when something was actually written to the
> DB, not on advice-only replies. Import path: `AiItemStatus` is defined in
> `../services/ai_chat_service.dart` and is already in scope via
> `AIChatService.lastResponseItems`.

### Also apply in the silent auto-retry path

The fallback-retry block at lines **831–844** is a near-copy of the main path.
Apply the identical snackbar block there too — after `_scrollToBottom()` inside
that inner `if (mounted)` block — so retried responses also get the undo banner.

### Verify

```
flutter analyze lib/screens/ai_screen.dart
```
No new errors. Manually test: type "log ₱50 coffee" → confirm single snackbar
appears, tap Undo → confirm "Undone ✓" appears and context refreshes.

---

## TASK 2 — Swipe-to-delete on transaction list

**File:** `lib/screens/transactions_screen.dart`

### Background

- The list variable is `_filtered` (line 82). Both the flat list builder
  (line ~1088) and the grouped list builder (line ~1117) call `_buildTile(e)`
  at line **1175**.
- `_buildTile(Expense e)` returns an `ExpenseTile`. Wrapping here is the
  single-point change — both list renderers call it, so both get swipe-to-delete
  automatically.
- The existing `_delete(int id)` method (line **560**) already shows a confirm
  dialog, calls `DBService.deleteExpense`, fires `AppEvent.expenseChanged`, and
  sets state. The `Dismissible.onDismissed` must **not** call `_delete()` again
  (it would double-confirm); instead replicate the delete work inline in
  `onDismissed` after the confirm guard passes in `confirmDismiss`.
- Long-press behavior (lines ~1181–1196) lives inside `ExpenseTile` props and
  is unaffected by adding an outer `Dismissible`.

### Change: wrap `_buildTile` return value

Replace the `_buildTile` method body:

**Before (line 1175):**
```dart
Widget _buildTile(Expense e) {
  return ExpenseTile(
    expense: e,
    onEdit: _isSelecting ? null : () => _edit(e),
    onDelete: _isSelecting ? null : () => _delete(e.id!),
    isSelected: _selected.contains(e.id),
    onLongPress: () {
      ...
    },
    onTap: _isSelecting ? ... : null,
  );
}
```

**After:**
```dart
Widget _buildTile(Expense e) {
  final tile = ExpenseTile(
    expense: e,
    onEdit: _isSelecting ? null : () => _edit(e),
    onDelete: _isSelecting ? null : () => _delete(e.id!),
    isSelected: _selected.contains(e.id),
    onLongPress: () {
      setState(() {
        final id = e.id!;
        if (_selected.contains(id)) {
          _selected.remove(id);
        } else {
          _selected.add(id);
        }
      });
    },
    onTap: _isSelecting
        ? () {
            setState(() {
              final id = e.id!;
              if (_selected.contains(id)) {
                _selected.remove(id);
              } else {
                _selected.add(id);
              }
            });
          }
        : null,
  );

  // Disable swipe while in multi-select mode — accidental swipe during
  // bulk-select would be confusing.
  if (_isSelecting) return tile;

  return Dismissible(
    key: Key('txn_${e.id}'),
    direction: DismissDirection.endToStart,
    background: Container(
      color: Colors.red.shade400,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 20),
          SizedBox(width: 6),
          Text('Delete',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    ),
    confirmDismiss: (_) async {
      return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete expense?'),
          content: Text(
              'Delete "${e.itemName}" (₱${e.amount.toStringAsFixed(0)})?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    },
    onDismissed: (_) async {
      await DBService.deleteExpense(e.id!);
      fireEvent(AppEvent.expenseChanged);
      if (mounted) {
        setState(() => _filtered.remove(e));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            content: Text('Deleted "${e.itemName}"'),
          ),
        );
      }
    },
    child: tile,
  );
}
```

> **`fireEvent` vs `AppEventBus`:** Check whether the file uses a top-level
> `fireEvent(AppEvent)` helper or `AppEventBus.instance.fire(event)` directly.
> The grep shows `fireEvent` is not visible in the imports; `event_bus.dart` is
> imported (line 10). Use `AppEventBus.instance.fire(AppEvent.expenseChanged)`
> to match the existing pattern from the rest of the file. The `_delete` method
> at line 560 will confirm the exact call form — read it before writing.

### Verify

```
flutter analyze lib/screens/transactions_screen.dart
```
No errors. Manually test: open Transactions, swipe left on any item → confirm
red delete background appears → confirm dialog appears → confirm delete removes
item and shows snackbar. Long-press still enters multi-select mode.

---

## TASK 3 — Wire PesoContextService.setScreen() to 6 screens

### Background

`PesoContextService` lives at `lib/services/peso_context_service.dart`. It is
currently imported only in `lib/screens/home_screen.dart` (line 61). All six
target screens need the import added and a `setScreen()` call in `initState`.

The `_tips` map in `peso_context_service.dart` already has entries for
`'recurring'` (lines ~80–84) and `'analytics'`, `'budget'`, `'goals'`,
`'debts'` (lines ~42–64). The task requires adding **new** tips for
`'transactions'` and updating `'recurring'` with the specified strings.

### Step A — Add/update tips in peso_context_service.dart

**File:** `lib/services/peso_context_service.dart`

1. Add a `'transactions'` entry to the `_tips` map (it does not exist yet):
   ```dart
   'transactions': [
     'Swipe left on any transaction to delete! 👈',
     'Long-press a transaction to edit, duplicate, or share! 💡',
     'Filter by category using the chips at the top! 🔍',
   ],
   ```
   Insert it between `'analytics'` and `'profile'` entries (or any location
   before the closing `}`; alphabetical is fine).

2. The existing `'recurring'` entry has two tips that are close but not
   identical to the spec. Replace both strings:
   ```dart
   // Current:
   'recurring': [
     'Add Netflix, GCash load, Meralco — I\'ll remind you before they\'re due! 🔁',
     'Tip: Semester interval is available for school-related recurring costs! 🎓',
   ],
   // Replace with:
   'recurring': [
     'Add your monthly bills here — I\'ll remind you before they\'re due! 🔁',
     'Semester interval is available for school costs! 🎓',
   ],
   ```

### Step B — Add import + setScreen() to each screen

For each file below, add the import (if absent) after the last existing
`import` line, then add the `setScreen()` call as the **first** statement after
`super.initState()`. Wrap in try/catch so failures never crash the screen.

Pattern:
```dart
// import to add:
import '../services/peso_context_service.dart';

// in initState, right after super.initState():
try { PesoContextService.setScreen('KEY'); } catch (_) {}
```

| File | Line of `super.initState()` | Key |
|---|---|---|
| `lib/screens/budget_screen.dart` | line 32 | `'budget'` |
| `lib/screens/savings_goals_screen.dart` | line 26 | `'goals'` |
| `lib/screens/debt_screen.dart` | line 31 | `'debts'` |
| `lib/screens/transactions_screen.dart` | line 117 | `'transactions'` |
| `lib/screens/analytics_screen.dart` | line 106 | `'analytics'` |
| `lib/screens/recurring_screen.dart` | line 28 | `'recurring'` |

`budget_screen.dart` already imports `peso_screen_tip.dart` (line 9) and
`peso_mascot.dart` (line 10) — add `peso_context_service.dart` after them.
The other five screens: add the import after their last `import` line.

### Verify

```
flutter analyze lib/screens/budget_screen.dart lib/screens/savings_goals_screen.dart lib/screens/debt_screen.dart lib/screens/transactions_screen.dart lib/screens/analytics_screen.dart lib/screens/recurring_screen.dart lib/services/peso_context_service.dart
```
No errors. Confirm `PesoContextService.currentScreen` changes when navigating
to each screen (can be verified with a quick debug print or breakpoint in
`peso_context_service.dart`).

---

## TASK 4 — Profile screen section headers

**File:** `lib/screens/profile_screen.dart`

### Background

The settings card is a single `Column` of `ListTile + Divider` children inside
a `ClipRRect` / `Container` starting at line ~2274. The card is not broken into
sub-cards — all tiles live in one `children: [...]` list. Section headers must
be inserted **before** the appropriate `ListTile` without restructuring the
surrounding layout.

Key line anchors (confirmed from read):
- **Line 2292** — `ListTile` for "Account Type" (first tile in the settings card)
- **Line 2344** — `const Divider(height: 1)` before "Export to CSV" tile at 2346
- **Line 2383** — `const Divider(height: 1)` before "Send Feedback" tile at 2386

### Step A — Add `_sectionHeader` helper to the `State` class

Add this method inside `_ProfileScreenState` (not at the top level). A
convenient place is just above `build()` or after the last helper method before
the build method:

```dart
Widget _sectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
```

### Step B — Insert section headers in the settings card Column

The `Column(children: [...])` at line ~2288 contains all tiles. Insert the
headers as new list items in that `children` array:

1. **Before the "Account Type" tile (line 2292):**
   The first item in `children` is the Account Type `ListTile`. Insert
   `_sectionHeader('Account')` as the very first child, before that tile.
   Because this is the first tile and there is no `Divider` above it, just
   prepend without adding a divider.

2. **Before the "Export to CSV" tile (line 2346):**
   The sequence around this tile is:
   ```
   const Divider(height: 1),   // line ~2344
   ListTile(                   // line 2346 — Export to CSV
   ```
   Insert `_sectionHeader('Data')` **after** the `Divider` and **before** the
   `ListTile`. The visual result is: last item of "Account" group → divider →
   "DATA" header → Export to CSV tile. This keeps dividers between groups
   visually clean.

3. **Before the "Send Feedback" tile (line 2386):**
   The sequence is:
   ```
   const Divider(height: 1),   // line ~2383
   ListTile(                   // line 2386 — Send Feedback
   ```
   Insert `_sectionHeader('Support')` **after** the `Divider` and **before**
   the `ListTile`, same pattern as above.

### Verify

```
flutter analyze lib/screens/profile_screen.dart
```
No errors. Hot reload → navigate to Profile → confirm "ACCOUNT", "DATA", and
"SUPPORT" section labels appear in the primary color above their respective
tile groups.

---

## Execution order

All four tasks are independent. Suggested order:

1. **Task 3** (PesoContextService wiring) — pure additions, zero breakage risk.
2. **Task 4** (profile headers) — isolated to one file, additive only.
3. **Task 2** (swipe-to-delete) — wraps existing `_buildTile`, no logic deleted.
4. **Task 1** (undo snackbar) — adds a snackbar call, last because it touches
   the most complex method in the codebase.

Run `flutter analyze` after each task before moving to the next.
