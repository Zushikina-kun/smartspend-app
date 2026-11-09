# Privacy disclosure bottom sheet, QuickTips screen, and home-screen additions

Three small, additive changes land together: a one-time privacy disclosure bottom sheet in the AI screen, a QuickTips onboarding screen shown once on first launch, and two additions to the home screen (Export & Backup hub tile, updated offline banner). All three are low-risk UI enhancements with no schema migrations.

Watch for: (1) **confirmed** — privacy disclaimer does NOT gate the send path; after the sheet is dismissed (including via the secondary "go to Settings" button without pressing "Got it"), `_privacyDisclaimerShown` is only set to `true` inside the `FilledButton` handler, so a user who taps "Switch to Local AI" and re-opens the screen will see the sheet again — which is arguably correct behavior but worth a conscious decision. (2) **confirmed** — Export & Backup tile routes to `ProfileScreen()`, not a dedicated export screen; anyone expecting a direct export flow will land on the full profile page.

**Verdict**: APPROVED

---

## High-level view

The privacy disclaimer is wired correctly: `_privacyDisclaimerShown` is declared alongside `_adviceDisclaimerShown`, `_loadPrivacyDisclaimerState()` is called in `initState`, and the check in `_send()` comes before the advice disclaimer check and does not block sending (no `return` after the `await`). The bottom sheet uses `showModalBottomSheet`, not `AlertDialog`.

`QuickTipsScreen` is a new `StatelessWidget` with `shouldShow()` and `markSeen()` backed by SharedPreferences key `'quick_tips_seen_v1'`. `home_screen.dart` imports it and calls `QuickTipsScreen.shouldShow()` inside `_checkTour()`, shown via `showModalBottomSheet` after the What's New gate.

The Export & Backup tile is present in the `TRANSACTIONS & DATA` section of `_QuickAccessHub` with the correct label, subtitle, color, and tap handler.

The offline banner is wrapped in a `GestureDetector` whose `onTap` fires a `SnackBar` with the expanded offline explanation. The banner text reads `'📴 Offline — core features work. Peso AI needs internet.'`.

---

<details>
<summary>Issues (2)</summary>

1. **Privacy sheet dismiss without "Got it"** — Tapping "Switch to Local AI — go to Settings" calls `Navigator.pop(context)` without setting `_privacyDisclaimerShown = true` or writing to the DB. On next send the sheet appears again. Decide whether partial-dismiss should also mark seen (likely yes, since the user has read it).

2. **Export & Backup routes to ProfileScreen** — The tile subtitle promises "CSV export · JSON backup · Restore" but the tap handler calls `_go(const ProfileScreen())`, which is the full profile page. Users expecting a direct export flow will need to find the export section within that screen. If a dedicated export screen exists or is planned, the route should point there.

</details>

<details>
<summary>Details</summary>

### Privacy disclaimer state and send-path ordering

`_privacyDisclaimerShown` is declared as a `bool` field alongside `_adviceDisclaimerShown` at line ~68. `_loadPrivacyDisclaimerState()` is called in `initState` immediately after `_loadAdviceDisclaimerState()` — criterion 1 **confirmed**.

`_showPrivacyDisclaimer()` uses `showModalBottomSheet<void>` with `isScrollControlled: true` and a transparent background wrapping a rounded `Container` — criterion 2 **confirmed**.

In `_send()`, the privacy check block appears first:

```dart
if (!_privacyDisclaimerShown) {
  await _showPrivacyDisclaimer();
}
// then advice disclaimer check follows
if (!_adviceDisclaimerShown) { ... }
```

There is no `return` or gate after the privacy await — execution continues into the advice check and then the send logic regardless of how the sheet was closed — criterion 3 **confirmed**.

The secondary button in the sheet calls only `Navigator.pop(context)`, leaving `_privacyDisclaimerShown` false and the DB unwritten. This means a user who taps "Switch to Local AI" and comes back to the AI screen will see the sheet again on next send. Whether that's intentional is worth documenting; the current behavior is consistent but may surprise users who read the sheet and want to keep their current provider.

### QuickTipsScreen: shouldShow / markSeen pattern

`quick_tips_screen.dart` is a `StatelessWidget` with a `static const _prefKey = 'quick_tips_seen_v1'`. `shouldShow()` reads `prefs.getBool(_prefKey) ?? false` and returns its negation; `markSeen()` writes `prefs.setBool(_prefKey, true)`. Both are `static Future<>` — criterion 4 **confirmed**.

`markSeen()` is called inside the `FilledButton.onPressed` callback of the widget's "Got it — let's go!" button, before `Navigator.pop`. This is the correct pattern — the flag is written before the sheet closes.

### home_screen.dart: import, _checkTour wiring, hub tile, offline banner

`import 'quick_tips_screen.dart'` is present in the import block — criterion 5 (import) **confirmed**.

`_checkTour()` calls `QuickTipsScreen.shouldShow()` after the What's New gate and shows the bottom sheet via `showModalBottomSheet` — criterion 5 (usage) **confirmed**. The 800ms delay before showing tips is a minor UX nicety that avoids stacking sheets.

In `_QuickAccessHub`, under the `'TRANSACTIONS & DATA'` group, the tuple `(Icons.save_alt_rounded, 'Export & Backup', 'CSV export · JSON backup · Restore', Colors.brown, () => _go(const ProfileScreen()))` is present after the "Import from Bank / GCash" entry — criterion 6 **confirmed**.

The offline banner is wrapped in `GestureDetector` with an `onTap` that calls `ScaffoldMessenger.of(context).showSnackBar(...)` with expanded text. The `Container` inside shows `'📴 Offline — core features work. Peso AI needs internet.'` — criterion 7 **confirmed**. The snackbar text says "Core features (logging, analytics, budgets, goals) work offline. Peso AI and market data need internet." which is slightly more detailed than the banner but consistent in meaning.

### Static analysis posture

No new imports added to `ai_screen.dart` beyond what was already present. `quick_tips_screen.dart` imports only `flutter/material.dart` and `shared_preferences/shared_preferences.dart`, both existing dependencies. `home_screen.dart` adds one import line for `quick_tips_screen.dart`. No type-unsafe casts, no obviously unused variables in the added code, no missing `async`/`await` pairings observed — criterion 8 assessed as passing. (Flutter analyze was run by the coder; no re-run performed per reviewer instructions.)

### Existing functionality

The additions are strictly additive. `_send()` logic below the two disclaimer checks is unchanged. `_checkTour()` adds the tips check after, not instead of, the existing feature tour and What's New gates. The hub tile list is append-only. No existing routes, services, or state fields were modified — criterion 9 **confirmed**.

</details>

---

<details>
<summary>File map</summary>

- `lib/screens/ai_screen.dart` — added `_privacyDisclaimerShown` field, `_loadPrivacyDisclaimerState()`, `_showPrivacyDisclaimer()` bottom sheet, and privacy check at top of `_send()`
- `lib/screens/quick_tips_screen.dart` — new file; `QuickTipsScreen` widget with `shouldShow()`/`markSeen()` and four onboarding tips
- `lib/screens/home_screen.dart` — added `quick_tips_screen.dart` import, QuickTips check in `_checkTour()`, Export & Backup tile in `_QuickAccessHub`, offline banner wrapped in `GestureDetector` with SnackBar

Full diff: `git diff main -- lib/screens/ai_screen.dart lib/screens/quick_tips_screen.dart lib/screens/home_screen.dart`

</details>
