# FHS-reactive Peso mood on home, Peso on profile, feedback_screen lint fixes

This commit places `PesoMascot` in two screens and cleans up lint warnings in a third. On the home screen, Peso appears inside the existing Financial Health Score card with its mood driven by a four-band FHS threshold cascade. On the profile screen, Peso is added as a decorative greeting near the avatar. In `feedback_screen.dart`, all single-line `if` bodies are wrapped in braces, the hardcoded version string is replaced with `kAppVersion`, and two `Row` constructors gain `const`.

Watch for: The `const Row(children: [PesoMascot(...), ...])` promotion in `feedback_screen.dart` is a compile error — `PesoMascot` extends `StatefulWidget` with no `const` constructor. **Confirmed**.

**Verdict**: NEEDS_CHANGES

---

## High-level view

The home screen mascot placement is inside the FHS card, after the score bar, guarded by `_score > 0`, using all four moods (proud ≥ 90, happy ≥ 70, neutral ≥ 50, worried < 50). `peso_mascot.dart` is imported exactly once in `home_screen.dart`. The profile screen adds the import and places `PesoMascot(size: 40, mood: PesoMood.happy)` above the display name in the header.

The feedback screen lint work is mostly correct — all five single-line `if` bodies now have braces and the hardcoded `'3.0.4'` is replaced with `kAppVersion`. The blocking issue is `const Row` promotion: `PesoMascot` is a `StatefulWidget` and cannot be a compile-time constant, so both app bar `title` constructions will fail to compile.

---

<details>
<summary>Issues (1)</summary>

1. **`const Row` with non-const `PesoMascot`** — Both app bar `title` widgets in `feedback_screen.dart` were promoted to `const Row(children: [PesoMascot(size: 28, mood: PesoMood.happy), SizedBox(...), Text(...)])`. `PesoMascot` extends `StatefulWidget` and has no `const` constructor, so `const Row` is invalid and the file won't compile. Remove `const` from both `Row` constructors and restore it on the `SizedBox` and `Text` children individually: `Row(children: [PesoMascot(...), const SizedBox(width: 8), const Text('Send Feedback')])`. Confidence: **confirmed** — `class PesoMascot extends StatefulWidget` with no `const` constructor in `lib/widgets/peso_mascot.dart`.

</details>

<details>
<summary>Details</summary>

### `const Row` promotion breaks feedback_screen compilation

The diff changed both app bar `title` widgets from `Row(children: [PesoMascot(...), const SizedBox(...), const Text(...)])` to `const Row(children: [PesoMascot(...), SizedBox(...), Text(...)])`. Hoisting `const` to the `Row` requires every child to be a compile-time constant. `PesoMascot` is a `StatefulWidget` — its constructor is not `const` — so the promotion is illegal. Flutter's analyzer will flag this as an error before it reaches the compiler. The fix is to revert the `Row` to non-const and keep `const` on the leaf widgets.

The brace-wrapping of the five bare `if` bodies and the `kAppVersion` substitution are correct and complete; those parts of the lint pass introduce no regressions.

</details>

---

<details>
<summary>File map</summary>

- `lib/screens/home_screen.dart` — Added FHS-reactive `PesoMascot` inside the score card; added a TODO comment for a future celebrating mood on the score-improvement snackbar.
- `lib/screens/profile_screen.dart` — Added `peso_mascot.dart` import; added `PesoMascot(size: 40, mood: PesoMood.happy)` in the profile header.
- `lib/screens/feedback_screen.dart` — Wrapped five bare `if` bodies in braces; replaced hardcoded version string with `kAppVersion`; promoted two `Row` constructors to `const` (blocking — see Issues).

Full diff: `git show 423b9111c8a85d01e1551a2f592a8fa3cb8af980`

</details>
