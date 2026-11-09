# Implementation Plan — App Improvements (4 items)

## Codebase Notes

- **Build command**: `flutter build apk` (or `flutter run` for device testing)
- **Test/verify**: `flutter analyze` — no new errors/warnings is the baseline check
- **DB settings pattern**: `DBService.getSetting(key)` / `DBService.setSetting(key, value)` are static async methods (`lib/services/db_service.dart`, lines 1439–1452). They persist to SQLite `settings` table with `REPLACE` conflict resolution.
- **SharedPreferences pattern**: Used in `WhatsNewScreen` (`lib/screens/whats_new_screen.dart`) for one-time show flags — `shouldShow()` / `markSeen()` static async helpers returning `Future<bool>` / `Future<void>`.
- **ModalBottomSheet pattern**: `showModalBottomSheet` with `isScrollControlled: true`, transparent background, `Container` with `BorderRadius.vertical(top: Radius.circular(20–24))`, `cs.surface` background. The `_HomeScreenState._showStartupAlertSheet` (home_screen.dart ~line 185) is the canonical example for the hub.
- **ColorScheme pattern**: `final cs = Theme.of(context).colorScheme;` — used in every screen. `cs.surface` is the bottom-sheet background.
- **`_checkTour()` location**: `home_screen.dart` lines 123–136. The WhatsNewScreen block is inside the `if (!should)` guard (feature tour not shown). The Quick Tips insertion point is **after** the closing `}` of the inner `if (shouldShowNew && mounted)` block, still inside `if (!should)`.
- **`_QuickAccessHubState.allItems`**: defined around line 906. The `'TRANSACTIONS & DATA'` group starts ~line 1013. The 'Import from Bank / GCash' entry ends with a closing `}` at ~line 1047 (it uses an async lambda with `Navigator.pop`). The new 'Export & Backup' entry goes immediately after that closing `),`.
- **Offline banner location**: `home_screen.dart` ~lines 407–423. The `if (_isOffline) Container(...)` block sits inside a `Stack` or `Column` inside `_HomeScreenState.build()`. The exact text is `"😟 Peso can't connect — AI unavailable offline"`.
- **`ProfileScreen`** is already imported in `home_screen.dart` (line 29). No new import needed for improvement 3.
- **`_send()` method**: `ai_screen.dart` line 571. The advice disclaimer check starts at line 577 (`if (!_adviceDisclaimerShown)`). The privacy disclaimer check must be inserted BEFORE line 577.

---

## IMPROVEMENT 1: Privacy Disclosure on First AI Chat

**File**: `lib/screens/ai_screen.dart`

### What to do

1. **Add field** `bool _privacyDisclaimerShown = false;` directly below `bool _adviceDisclaimerShown = false;` (currently ~line 71).

2. **Add `_loadPrivacyDisclaimerState()` method** directly below `_loadAdviceDisclaimerState()` (~lines 124–131). Pattern mirrors the existing method exactly:
   ```dart
   Future<void> _loadPrivacyDisclaimerState() async {
     try {
       final seen = await DBService.getSetting('ai_privacy_disclosed');
       if (seen == 'true' && mounted) {
         setState(() => _privacyDisclaimerShown = true);
       }
     } catch (_) {}
   }
   ```

3. **Call it in `initState()`**: on the same line or line after `_loadAdviceDisclaimerState()` (~line 79):
   ```dart
   _loadPrivacyDisclaimerState(); // restore privacy disclaimer flag
   ```

4. **Add `_showPrivacyDisclaimer()` method** as a `Future<void>` (NOT `Future<bool>` — it does not block sending). Place it below `_showAdviceDisclaimer()` (~line 171). Use `showModalBottomSheet` (not `showDialog`) with these exact specs:
   - `isScrollControlled: true`, `backgroundColor: Colors.transparent`
   - Inner `Container`: `BorderRadius.vertical(top: Radius.circular(20))`, color `cs.surface`, padding `const EdgeInsets.all(24)`
   - Drag handle (40×4 grey `Container`, `BorderRadius.circular(2)`, centered) — matches the hub pattern
   - `Text('🔒 About Peso AI')` with `fontSize: 18, fontWeight: FontWeight.bold`
   - `SizedBox(height: 12)`
   - Body `Text` explaining: text goes to the AI provider (Gemini, Groq, or local server); expense data is summarized locally as context; no data is sold for advertising; Local AI mode keeps data on this device; user can switch provider in Settings → AI Model. Use `style: TextStyle(fontSize: 13, height: 1.5)`.
   - `SizedBox(height: 20)`
   - `FilledButton` labelled `'Got it'`, full width (`SizedBox(width: double.infinity, ...)`), `style: FilledButton.styleFrom(backgroundColor: Colors.green)`:
     ```dart
     onPressed: () async {
       setState(() => _privacyDisclaimerShown = true);
       await DBService.setSetting('ai_privacy_disclosed', 'true');
       if (mounted) Navigator.pop(context);
     },
     ```
   - `SizedBox(height: 8)`
   - `TextButton` labelled `'Switch to Local AI'` that just calls `Navigator.pop(context)` (user navigates themselves)

5. **Modify `_send()`**: Insert before the `if (!_adviceDisclaimerShown)` block (~line 577):
   ```dart
   // ── PRIVACY DISCLAIMER — show once on first ever AI chat ──
   if (!_privacyDisclaimerShown) {
     await _showPrivacyDisclaimer();
   }
   ```
   This does **not** block sending — execution continues regardless of how the sheet is dismissed.

### Risk
- `await _showPrivacyDisclaimer()` in `_send()` returns `void` so it can never block execution. Ensure the method itself never throws (wrap body in try/catch if needed).
- The `setState(() => _privacyDisclaimerShown = true)` inside the button callback fires inside the modal's closure. Check that `mounted` is still true on the parent widget before calling `setState` — the `if (mounted)` guard before `Navigator.pop` handles this.

### Verify
```
flutter analyze lib/screens/ai_screen.dart
```
Expect: no new errors. Then manually test: fresh install → open AI tab → type any message → send → privacy sheet appears → tap 'Got it' → message sends → reopen AI tab, send again → sheet does NOT appear again.

---

## IMPROVEMENT 2: Quick Tips Screen (shown once after first launch)

### Part A — Create `lib/screens/quick_tips_screen.dart`

**File to create**: `lib/screens/quick_tips_screen.dart`

The file is a self-contained `StatelessWidget`. Follow the `WhatsNewScreen` pattern exactly (SharedPreferences for the flag, `shouldShow()` / `markSeen()` static helpers, `_tips` constant list, `build()` returns a bottom-sheet `Container`).

Structure:
```
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickTipsScreen extends StatelessWidget {
  const QuickTipsScreen({super.key});

  static const _prefKey = 'quick_tips_seen_v1';

  static Future<bool> shouldShow() async { ... }   // reads _prefKey
  static Future<void> markSeen() async { ... }     // sets _prefKey = true

  static const _tips = [
    ('💬', 'Talk to Peso in Taglish',
     'Type "nag-gastos ako ng 65 sa canteen" or "spent 149 on Jollibee via GCash" — Peso understands Filipino and English. It auto-fills category, amount, and wallet.'),
    ('🏆', 'What is the Financial Health Score?',
     'Your FHS (0–100) measures 4 things: Savings Rate, Budget Adherence, Budget Setup, and Logging Consistency. Tap the score card on Home to see a full breakdown.'),
    ('📷', 'Import GCash & Shopee screenshots',
     'Tap Peso → 📷 camera icon → "Batch Screenshots". Select multiple GCash, Shopee, or Steam screenshots — SmartSpend reads them and logs everything at once.'),
    ('🔒', 'Works fully offline',
     'All core features — logging, analytics, budgets, goals — work without internet. Peso AI needs internet unless you set up Local AI mode in Settings → AI Model.'),
  ];

  @override
  Widget build(BuildContext context) { ... }
}
```

`build()` returns a `Container` with:
- `BorderRadius.vertical(top: Radius.circular(24))`
- `color: Theme.of(context).colorScheme.surface`
- `padding: const EdgeInsets.fromLTRB(24, 20, 24, 32)`
- Column children:
  1. Centered drag handle (40×4, grey, `BorderRadius.circular(2)`)
  2. `SizedBox(height: 16)`
  3. `Text('Quick Tips 💡', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))`
  4. `SizedBox(height: 4)`
  5. Subtitle: `Text('Here's how to get the most out of SmartSpend', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant))`
  6. `SizedBox(height: 20)`
  7. For each tip in `_tips` — a `Padding(bottom: 16)` `Row`:
     - `Text(tip.$1, style: TextStyle(fontSize: 28))` (emoji, fixed width ~40)
     - `SizedBox(width: 12)`
     - Expanded `Column` with `Text(tip.$2, fontWeight: FontWeight.w600, fontSize: 14)` and `Text(tip.$3, fontSize: 12.5, height: 1.4, color: cs.onSurfaceVariant)`
  8. `SizedBox(height: 8)`
  9. Full-width `FilledButton('Got it — let\'s go!', ...)`:
     ```dart
     onPressed: () async {
       await QuickTipsScreen.markSeen();
       if (context.mounted) Navigator.pop(context);
     },
     ```
     Wrap in `SizedBox(width: double.infinity)`.

### Part B — Modify `lib/screens/home_screen.dart`

Two changes:

1. **Add import** at the top of the imports block, alongside the other screen imports:
   ```dart
   import 'quick_tips_screen.dart';
   ```

2. **In `_checkTour()`**, after the closing `}` of the `if (shouldShowNew && mounted)` block (currently the last statement inside `if (!should) { ... }`), add:
   ```dart
   // Show Quick Tips once on very first launch
   final shouldShowTips = await QuickTipsScreen.shouldShow();
   if (shouldShowTips && mounted) {
     await Future.delayed(const Duration(milliseconds: 800));
     if (mounted) {
       await showModalBottomSheet(
         context: context,
         isScrollControlled: true,
         backgroundColor: Colors.transparent,
         builder: (_) => const QuickTipsScreen(),
       );
     }
   }
   ```
   This block is **inside** the `if (!should)` guard so it only runs when the feature tour is not being shown, same as WhatsNewScreen. It runs after WhatsNewScreen (800ms delay) to avoid stacking two sheets simultaneously.

### Risk
- The `if (!should)` guard means Quick Tips only appears when the feature tour is already completed. If a truly fresh install shows the tour first, Quick Tips will show on the next `_checkTour()` call (which is also triggered when tapping the Home nav item). This is acceptable — it avoids sheet stacking.
- `context.mounted` (not `this.mounted`) must be used inside the `FilledButton` callback because it's inside a `StatelessWidget` build context. The `StatelessWidget` context is valid as long as the widget is in the tree; using `context.mounted` is the correct guard per Flutter 3.7+.

### Verify
```
flutter analyze lib/screens/quick_tips_screen.dart lib/screens/home_screen.dart
```
Then manually test: fresh install (or clear SharedPreferences key `quick_tips_seen_v1`) → launch app → feature tour runs (or skip if already done) → Quick Tips sheet appears → tap 'Got it — let's go!' → sheet closes → relaunch → sheet does NOT appear again.

---

## IMPROVEMENT 3: Export & Backup Shortcut in Quick Access Hub

**File**: `lib/screens/home_screen.dart`

### What to do

In `_QuickAccessHubState.build()`, inside the `allItems` list, locate the `'TRANSACTIONS & DATA'` group. Find the 'Import from Bank / GCash' entry — it ends with the async lambda:
```dart
          () async {
            Navigator.pop(context);
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BankImportScreen()));
          }
        ),
```
Immediately **after** that closing `),`, insert:
```dart
        (
          Icons.save_alt_rounded,
          'Export & Backup',
          'CSV export · JSON backup · Restore',
          Colors.brown,
          () => _go(const ProfileScreen()),
        ),
```

`_go()` is the hub's navigation helper (already used in the same class for items like `TransactionsScreen`). `ProfileScreen` is already imported at the top of `home_screen.dart` (line 29).

### Risk
- The `allItems` list is filtered by `_searchController` and also iterated in a separate `for` loop to find the "Most Used" shortcut. Adding one entry to the list is safe — both loops handle variable-length lists.
- `Colors.brown` matches the existing `BatchManualEntryScreen` entry in the same group, so it blends with the existing color palette.

### Verify
```
flutter analyze lib/screens/home_screen.dart
```
Then manually test: tap Tools nav item → scroll to TRANSACTIONS & DATA section → confirm 'Export & Backup' tile appears between 'Import from Bank / GCash' and 'Batch Screenshot Import' (or wherever it falls after the insert) → tap it → ProfileScreen opens.

---

## IMPROVEMENT 4: Offline Banner Improvement

**File**: `lib/screens/home_screen.dart`

### What to do

In `_HomeScreenState.build()`, locate the `if (_isOffline)` block (~lines 407–423). The current block is:
```dart
if (_isOffline)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    color: const Color(0xFF1C1C1E),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(width: 8),
        Text("😟 Peso can't connect — AI unavailable offline",
            style: TextStyle(color: Colors.white70, fontSize: 11.5)),
      ],
    ),
  ),
```

Replace the entire `if (_isOffline) Container(...)` block with:
```dart
if (_isOffline)
  GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Core features (logging, analytics, budgets, goals) work offline. '
            'Peso AI and market data need internet.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      color: const Color(0xFF1C1C1E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(width: 8),
          Text('📴 Offline — core features work. Peso AI needs internet.',
              style: TextStyle(color: Colors.white70, fontSize: 11.5)),
        ],
      ),
    ),
  ),
```

The `children: const [...]` list is changed — remove the `const` from `Row`'s `children` list since nothing inside it changes, but the outer widget is no longer const. The `Container` and `Row` remain `const`-free already because the `GestureDetector` wrapper is not const. Keep both `const` qualifiers on the `SizedBox` and `Text` as-is.

### Risk
- The `children: const [SizedBox..., Text(...)]` uses a const list. Since neither `SizedBox` nor `Text` with the new string need runtime values, the `const` keyword on the list is fine to keep — or remove it if the linter objects. Either way is correct.
- `ScaffoldMessenger.of(context)` must be called on a context that has a `Scaffold` ancestor. Since this banner lives inside `_HomeScreenState.build()` which returns a `Scaffold`, the context is valid.

### Verify
```
flutter analyze lib/screens/home_screen.dart
```
Then manually test: disable WiFi/mobile data → open app → banner reads '📴 Offline — core features work. Peso AI needs internet.' → tap banner → SnackBar appears with the longer explanation → re-enable network → banner disappears.

---

## Overall Verification

After all 4 improvements are implemented:

```
flutter analyze
```
Expected: 0 errors, 0 new warnings relative to the baseline.

For a full build check:
```
flutter build apk --debug
```
Expected: builds without compile errors.

Manual smoke test order:
1. Clear app data (or use a fresh emulator) to trigger first-launch flows.
2. Open app → Quick Tips sheet appears → dismiss.
3. Open AI tab → send a message → Privacy disclaimer sheet appears → tap 'Got it' → message sends. Send again → sheet does NOT reappear.
4. Open Tools → TRANSACTIONS & DATA → 'Export & Backup' entry present → tap → ProfileScreen opens.
5. Disable network → home screen shows new offline banner text → tap banner → SnackBar with offline-features explanation appears.
