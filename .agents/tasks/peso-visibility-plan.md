# Implementation Plan — Peso Mascot Visibility

## Summary of findings

After reading all six target files and `peso_mascot.dart`:

| File | Current Peso state | Problem |
|------|--------------------|---------|
| `home_screen.dart` line 619 | `Icons.smart_toy_outlined` in quick-input bar | Generic icon — no Peso |
| `home_screen.dart` line 787 | `Icons.smart_toy` in `_navItem("Peso", 2)` | Generic icon — no Peso |
| `home_screen.dart` line 3007 | `Icons.smart_toy_outlined` in "Ask Peso (AI)" list tile inside `_QuickAccessHub` | Generic icon — no Peso |
| `ai_screen.dart` line 2969 | `PesoMascot(size: 28, mood: _pesoChatMood)` already in AppBar title ✅ | OK — no change |
| `ai_screen.dart` line 3604 | Typing indicator has only text "Peso" + `_TypingDots()` | Peso not shown while thinking |
| `ai_screen.dart` line 3495 | Welcome screen already uses `PesoMascot.withSpeech(size: 80)` ✅ | OK — no change |
| `ai_screen.dart` lines 3691+ | AI message bubbles have no Peso avatar prefix | Chat identity weak |
| `paluwagan_screen.dart` | AppBar — `InfoButton` only, no Peso; empty state uses 🏦 emoji | No Peso presence |
| `pca_calculator_screen.dart` | AppBar — `InfoButton` only, no Peso in body | No Peso presence |
| `log_due_bills_screen.dart` | AppBar — `InfoButton` only; empty state uses `Icons.check_circle_outline` | No Peso presence |
| `glossary_screen.dart` | AppBar — `InfoButton` only, no Peso | No Peso presence |
| `data_quality_screen.dart` | Clean state uses `Icons.check_circle_outline`; no mascot import | No Peso presence |

**PesoMascot API (confirmed from `peso_mascot.dart`):**
- `PesoMascot({ double size, PesoMood mood, VoidCallback? onTap, PesoMood? tapMood, String? tapSpeech })`
- `PesoMascot.withSpeech({ double size, PesoMood mood, required String text, Color? bubbleColor, TextStyle? textStyle })`
- All moods: `happy, neutral, thinking, sad, celebrating, excited, surprised, proud, embarrassed, winking, sleepy, worried`
- Import: `import '../widgets/peso_mascot.dart';`

---

## Implementation Plan

- [ ] 1. **`home_screen.dart` — quick-input bar: replace `Icons.smart_toy_outlined` with a small Peso mascot**

  In `_buildQuickInputBar()` (line ~618-620), the first child of the `Row` is:
  ```dart
  Icon(Icons.smart_toy_outlined, size: 18, color: cs.primary),
  ```
  Replace it with:
  ```dart
  PesoMascot(
    size: 20,
    mood: _quickInputLoading ? PesoMood.thinking : PesoMood.happy,
    onTap: () => setState(() => _index = 2), // navigate to AI tab on tap
  ),
  ```
  `_quickInputLoading` is already a field on `_HomeScreenState`. Wrapping it in a ternary mood change gives instant visual feedback while AI is working. `peso_mascot.dart` is already imported (`../widgets/peso_mascot.dart`).

  Files: `lib/screens/home_screen.dart`
  Verify: `flutter build apk --debug` (no compile errors) + visually confirm the bar shows Peso instead of the robot icon.

- [ ] 2. **`home_screen.dart` — bottom nav "Peso" tab: replace `Icons.smart_toy` icon with an actual `PesoMascot`**

  In `_navItem(Icons.smart_toy, "Peso", 2)` (line 787), the `_navItem` helper renders the `isAI` branch (line ~806-843). The branch currently draws a `Container` with a circle background and an `Icon(icon, ...)` child.

  Change the `Icon(icon, ...)` child in the `isAI` branch to:
  ```dart
  PesoMascot(
    size: selected ? 26 : 22,
    mood: selected ? PesoMood.happy : PesoMood.neutral,
  ),
  ```
  Remove the `IconData icon` argument from the call site for index 2 only — keep the `_navItem` signature backward-compatible by adding a `Widget? customIcon` optional parameter and checking it:
  ```dart
  Widget _navItem(IconData icon, String label, int idx, {VoidCallback? onTap, Widget? customIcon}) {
    // ...
    child: customIcon ?? Icon(icon, color: ..., size: 22),
  ```
  Then the call site becomes:
  ```dart
  _navItem(Icons.smart_toy, "Peso", 2,
    customIcon: PesoMascot(
      size: _index == 2 ? 26 : 22,
      mood: _index == 2 ? PesoMood.happy : PesoMood.neutral,
    ),
  ),
  ```
  `peso_mascot.dart` is already imported.

  Files: `lib/screens/home_screen.dart`
  Verify: `flutter build apk --debug` — no errors. The bottom nav "Peso" item now shows the mascot face instead of the generic robot icon.

- [ ] 3. **`home_screen.dart` — Quick Access Hub "Ask Peso (AI)" list tile: replace `Icons.smart_toy_outlined` with Peso**

  Around line 3007, inside `_QuickAccessHub`, the `ListTile` leading container holds:
  ```dart
  child: Icon(Icons.smart_toy_outlined, color: Theme.of(context).colorScheme.primary, size: 20)
  ```
  Replace with:
  ```dart
  child: PesoMascot(size: 24, mood: PesoMood.happy),
  ```
  The container itself (`width: 40, height: 40`) can stay as-is; Peso at `size: 24` renders at `24 * 1.35 = 32.4px` wide and `24 * 1.25 = 30px` tall, which fits the 40×40 box.

  Files: `lib/screens/home_screen.dart`
  Verify: `flutter build apk --debug` — no errors. Quick Access Hub shows Peso face next to "Ask Peso (AI)".

- [ ] 4. **`ai_screen.dart` — typing indicator: prepend a small Peso mascot next to the "Peso" label**

  Around line 3604-3635, the `_sending` typing bubble `Row` contains:
  ```dart
  Text("Peso", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
  const SizedBox(width: 4),
  _TypingDots(),
  ```
  Add Peso before the text:
  ```dart
  PesoMascot(size: 22, mood: PesoMood.thinking),
  const SizedBox(width: 6),
  Text("Peso", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
  const SizedBox(width: 4),
  _TypingDots(),
  ```
  `peso_mascot.dart` is already imported in `ai_screen.dart`.

  Files: `lib/screens/ai_screen.dart`
  Verify: `flutter build apk --debug` — no errors. When AI is responding, the typing bubble shows the Peso coin face with `PesoMood.thinking` (purple eyes, thought bubble) alongside the dots.

- [ ] 5. **`ai_screen.dart` — AI message bubbles: add a small Peso avatar to the left of each AI bubble**

  In the `itemBuilder` around line 3691+, for AI messages (`!isUser`), the `Align/Container` bubble has no avatar. Before the `Align` widget that contains the bubble, add a small Peso face in a `Row`:

  Wrap the existing `Align(child: GestureDetector(child: Container(...)))` for AI messages in a `Row`:
  ```dart
  if (!isUser) Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 4, right: 4),
        child: PesoMascot(size: 22, mood: _pesoChatMood),
      ),
      Expanded(child: /* existing Align+Container bubble */)
    ],
  ) else /* existing user Align widget as-is */
  ```
  Size 22 keeps it unobtrusive. `_pesoChatMood` is already a field on `_AIScreenState` and changes dynamically with each reply.

  Files: `lib/screens/ai_screen.dart`
  Verify: `flutter build apk --debug` — no errors. Every AI response shows the small Peso coin face to its left; its mood animates based on the reply content.

- [ ] 6. **`paluwagan_screen.dart` — AppBar leading + empty state: add Peso**

  **a. AppBar** — `paluwagan_screen.dart` has no import for `peso_mascot.dart`. Add it:
  ```dart
  import '../widgets/peso_mascot.dart';
  ```
  Then, in the `AppBar`, set `leading:` to a small tappable Peso that shows a speech bubble:
  ```dart
  leading: Padding(
    padding: const EdgeInsets.only(left: 8),
    child: PesoMascot.withSpeech(
      size: 28,
      mood: PesoMood.winking,
      text: "Paluwagan tracks\nyour group savings!",
    ),
  ),
  ```
  The existing back-button navigation still works because `AppBar.leading` does NOT suppress the auto-back-button when `leading` already provides a widget — Flutter ignores the auto-back when `leading` is non-null, so use `automaticallyImplyLeading: false` and include a manual `BackButton` alongside Peso OR keep `leading` null and add Peso as the first item in `actions`. The cleaner approach for a screen that is pushed: **add Peso as the first `actions` item** so the auto-back still works:
  ```dart
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PesoMascot(
        size: 28,
        mood: PesoMood.happy,
        tapMood: PesoMood.excited,
        tapSpeech: "Paluwagan kayo? Nice!",
      ),
    ),
    const InfoButton(...), // existing
    IconButton(...),        // existing add button
  ],
  ```

  **b. Empty state** — replace the `🏦` Text emoji with Peso:
  ```dart
  // Before:
  const Text("🏦", style: TextStyle(fontSize: 48)),
  // After:
  PesoMascot.withSpeech(
    size: 56,
    mood: PesoMood.happy,
    text: "Start your first paluwagan group!",
  ),
  ```

  Files: `lib/screens/paluwagan_screen.dart`
  Verify: `flutter build apk --debug` — no errors. Paluwagan screen shows Peso in AppBar actions and in empty state.

- [ ] 7. **`pca_calculator_screen.dart` — AppBar + results area: add Peso**

  `pca_calculator_screen.dart` does not import `peso_mascot.dart`. Add:
  ```dart
  import '../widgets/peso_mascot.dart';
  ```

  **a. AppBar** — add Peso as first action before the existing `InfoButton`:
  ```dart
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PesoMascot(
        size: 28,
        mood: PesoMood.proud,
        tapMood: PesoMood.excited,
        tapSpeech: "Invest regularly, grow steadily!",
      ),
    ),
    const InfoButton(...), // existing
  ],
  ```

  **b. Result card** — after `_calculate()` runs, the green gradient `Container` shows the totals. Add Peso above the results summary, between the top of the green container's `Column` and the "After X years" text:
  ```dart
  PesoMascot(size: 36, mood: PesoMood.celebrating),
  const SizedBox(height: 4),
  const Text("After ${0} years", ...), // existing
  ```
  (The `${0}` bug is pre-existing — do not fix it here; focus only on Peso.)

  Files: `lib/screens/pca_calculator_screen.dart`
  Verify: `flutter build apk --debug` — no errors. PCA screen shows Peso in AppBar; after calculating, a celebrating Peso appears in the result card.

- [ ] 8. **`log_due_bills_screen.dart` — AppBar + empty state: add Peso**

  `log_due_bills_screen.dart` does not import `peso_mascot.dart`. Add:
  ```dart
  import '../widgets/peso_mascot.dart';
  ```

  **a. AppBar** — add Peso as first action before the existing `InfoButton` and `TextButton("Save All")`:
  ```dart
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PesoMascot(
        size: 28,
        mood: PesoMood.thinking,
        tapMood: PesoMood.happy,
        tapSpeech: "Check off your bills!",
      ),
    ),
    const InfoButton(...), // existing
    TextButton(...),        // existing Save All
  ],
  ```

  **b. Empty state** — replace `Icon(Icons.check_circle_outline, size: 56, color: Colors.green[400])` with Peso:
  ```dart
  // Before:
  Icon(Icons.check_circle_outline, size: 56, color: Colors.green[400]),
  // After:
  PesoMascot.withSpeech(
    size: 56,
    mood: PesoMood.celebrating,
    text: "No bills due! Peso is happy! 🎉",
  ),
  ```

  Files: `lib/screens/log_due_bills_screen.dart`
  Verify: `flutter build apk --debug` — no errors. When bills screen is empty, Peso celebrates.

- [ ] 9. **`glossary_screen.dart` — AppBar: add Peso before `InfoButton`**

  `glossary_screen.dart` does not import `peso_mascot.dart`. Add:
  ```dart
  import '../widgets/peso_mascot.dart';
  ```

  In the AppBar `actions` list, add Peso first:
  ```dart
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PesoMascot(
        size: 28,
        mood: PesoMood.thinking,
        tapMood: PesoMood.winking,
        tapSpeech: "Financial terms made simple!",
      ),
    ),
    const InfoButton(...), // existing
  ],
  ```

  Files: `lib/screens/glossary_screen.dart`
  Verify: `flutter build apk --debug` — no errors. Glossary AppBar shows Peso with a winking tap reaction.

- [ ] 10. **`data_quality_screen.dart` — clean state: replace generic icon with Peso**

  `data_quality_screen.dart` does not import `peso_mascot.dart`. Add:
  ```dart
  import '../widgets/peso_mascot.dart';
  ```

  In `_buildClean()` (~line 133), replace:
  ```dart
  Icon(Icons.check_circle_outline, size: 64, color: Colors.green[400]),
  const SizedBox(height: 16),
  const Text('All clean!', ...),
  ```
  with:
  ```dart
  PesoMascot.withSpeech(
    size: 64,
    mood: PesoMood.proud,
    text: "All clean! Your data\nlooks great! 💚",
  ),
  const SizedBox(height: 16),
  const Text('All clean!', ...),
  ```

  Files: `lib/screens/data_quality_screen.dart`
  Verify: `flutter build apk --debug` — no errors. Data Quality "clean" state shows a proud Peso with speech bubble instead of the generic check icon.

---

## Dependency order

Items 1–5 touch files that already import `peso_mascot.dart` — no import needed. Items 6–10 each need the import added first (noted within each item). All items are independent of each other and can be implemented in any order. Each item leaves the codebase buildable on its own.

## Import reference

Files that already have `import '../widgets/peso_mascot.dart';`:
- `lib/screens/home_screen.dart` ✅
- `lib/screens/ai_screen.dart` ✅

Files that need the import added:
- `lib/screens/paluwagan_screen.dart`
- `lib/screens/pca_calculator_screen.dart`
- `lib/screens/log_due_bills_screen.dart`
- `lib/screens/glossary_screen.dart`
- `lib/screens/data_quality_screen.dart`

## Verification command (all items)

```
flutter build apk --debug
```

Run from `c:\xampp\htdocs\smartspend_app`. Zero compile errors is the pass criterion. Each item's Peso placement can then be visually verified on a device or emulator.
