# Peso mascot visibility upgrade — 7 screens

Peso was previously invisible in the bottom nav, the quick-input bar, the AI screen's chat list and typing indicator, and five feature screens (Paluwagan, PCA Calculator, Log Due Bills, Glossary, Data Quality). This change wires the PesoMascot widget into all of those surfaces, replacing generic `Icons.smart_toy_outlined` placeholders and bare-emoji empty states with the actual mascot face. The approach is additive — no existing logic was removed, only Peso placements added.

Watch for: (1) The `_navItem` helper signature was never changed — `Icons.smart_toy` is still passed as the `icon` argument at the call site for the AI tab, even though that branch ignores it; harmless but inconsistent with the plan. (2) `data_quality_screen.dart` uses a hardcoded `PesoMood.proud` regardless of data quality score — the spec called for score-based mood, which was not implemented.

**Verdict**: NEEDS_CHANGES

---

## High-level view

The bottom nav's circular "Peso" button now renders `PesoMascot(size:28)` inside its Container, and the quick-input bar's leading icon has become `PesoMascot(size:20, mood:PesoMood.happy)`. Both are confirmed in the code. The `_navItem` helper signature was not modified, so `Icons.smart_toy` is still forwarded as the unused `icon` argument — the `isAI` branch renders PesoMascot regardless, so this is dead code rather than a bug, but it leaves the call site misleading.

The AI screen now shows Peso in three places: the AppBar title row, the typing indicator bubble, and as a left-side avatar on every AI chat message. User messages are untouched. The AppBar has `PesoMascot(size:32, mood:_pesoChatMood, tapMood:PesoMood.excited)` which satisfies the interactive-tap requirement from the original user request. The typing indicator has `PesoMascot(size:24, mood:PesoMood.thinking)` with "Peso is thinking..." text and `_TypingDots()`.

Five secondary screens (Paluwagan, PCA Calculator, Log Due Bills, Glossary, Data Quality) each received the `peso_mascot.dart` import and a Peso placement in AppBar `actions`. All five also received a Peso in their empty/clean state — except Data Quality, which placed `PesoMascot(size:64, mood:PesoMood.proud)` directly in the clean state but with a hardcoded mood rather than one derived from an actual score.

---

<details>
<summary>Issues (2)</summary>

1. **Dead `icon` argument in AI nav tab call** — `_navItem(Icons.smart_toy, "Peso", 2)` still passes the icon, even though the `isAI` branch never reads it. The plan called for either removing the argument or adding a `customIcon` parameter. Not a runtime bug, but it makes the call site misleading and will silently drift if someone refactors `_navItem` and forgets this. Fix: change the call to pass `Icons.smart_toy_outlined` (a documented placeholder) or add the `customIcon` parameter as the plan described.

2. **Hardcoded mood in Data Quality clean state** — Check #10 in the review spec requires `PesoMascot` with a "score-based mood". The implementation uses `mood: PesoMood.proud` unconditionally. If the screen is designed to reflect an actual data-quality score, the mood should vary (e.g. `celebrating` for zero issues, `proud` for few, `worried` for many). As implemented, Peso is always proud regardless of how many issues remain. Fix: pass the issue count into the clean-state builder and select the mood accordingly, or confirm that "score-based mood" was intentionally simplified to `proud` and update the spec.

</details>

<details>
<summary>Details</summary>

### Bottom nav AI tab — PesoMascot confirmed, dead icon arg remains

The `_navItem` `isAI` branch (line ~808–843) correctly renders:

```dart
child: PesoMascot(
  size: 28,
  mood: selected ? PesoMood.happy : PesoMood.neutral,
),
```

inside the circular Container — check #1 passes. The call site at line 788 still reads `_navItem(Icons.smart_toy, "Peso", 2)`, passing an `IconData` that the `isAI` branch never uses. The `_navItem` signature was not modified. The dead argument is confirmed: `grep "smart_toy"` in home_screen.dart returns only this line plus an unrelated `ElevatedButton.icon` further down.

### Quick-input bar — PesoMascot confirmed (check #2)

`_buildQuickInputBar` (line ~619) starts the Row with:

```dart
PesoMascot(size: 20, mood: PesoMood.happy),
```

The mood is hardcoded `happy` rather than the plan's ternary `_quickInputLoading ? PesoMood.thinking : PesoMood.happy`. The loading feedback improvement was skipped — Peso doesn't visually shift to thinking while the AI request is in flight. This is minor UX polish, not a blocking issue.

### AI screen — AppBar, typing indicator, chat bubbles (checks #3–5)

AppBar title row has `PesoMascot(size:32, mood:_pesoChatMood, tapMood:PesoMood.excited)` — check #3 passes. The subtitle column reads "Your money buddy 💚", which reinforces Peso's identity rather than generic "AI assistant".

Typing indicator at line ~3641 has `PesoMascot(size:24, mood:PesoMood.thinking)` followed by "Peso is thinking..." and `_TypingDots()` — check #5 passes exactly as specced.

AI chat bubbles (lines ~3883–3895): the `isUser` guard correctly wraps only AI messages (`if (!isUser)`) in a Row with the Peso avatar at left; user messages remain as plain `Align` — checks #4 and #12 both pass.

### Secondary screens — imports and placements (checks #6–10)

All five screens now import `'../widgets/peso_mascot.dart'`. AppBar `actions` in each file contain a `Padding`-wrapped `PesoMascot` before the existing `InfoButton`.

Paluwagan empty state (line ~216) uses `PesoMascot.withSpeech(size:64, mood:PesoMood.winking, ...)` — check #6 passes.

PCA Calculator has `PesoMascot.withSpeech(size:56, mood:PesoMood.winking)` near the top of the body column, above the input card — check #7 passes.

Log Due Bills empty state (line ~178) uses `PesoMascot.withSpeech(size:56, mood:PesoMood.celebrating, ...)` — check #8 passes.

Glossary AppBar actions contain `PesoMascot(size:28, mood:PesoMood.thinking)` — check #9 passes.

Data Quality clean state (line ~147) has `PesoMascot(size:64, mood:PesoMood.proud)` — Peso is present so check #10 partially passes, but the mood is hardcoded rather than score-based as specced.

### User bubble integrity (check #12)

The `isUser` guard (`if (!isUser)`) ensures the Row-with-avatar wrapping applies only to AI messages. User bubble alignment, color, and border-radius are untouched.

</details>

---

<details>
<summary>File map</summary>

- `lib/screens/home_screen.dart` — Quick-input bar leading replaced with PesoMascot(20); `_navItem` isAI Container child replaced with PesoMascot(28); Quick Access Hub "Ask Peso" tile leading replaced with PesoMascot(20)
- `lib/screens/ai_screen.dart` — AppBar title row already had PesoMascot; typing indicator now has PesoMascot(24, thinking) + "Peso is thinking..." text; AI message bubbles wrapped in Row with PesoMascot(22) avatar at left
- `lib/screens/paluwagan_screen.dart` — Added `peso_mascot.dart` import; AppBar actions PesoMascot(28, happy); empty state PesoMascot.withSpeech(64, winking)
- `lib/screens/pca_calculator_screen.dart` — Added `peso_mascot.dart` import; AppBar actions PesoMascot(28, proud); body top PesoMascot.withSpeech(56, winking)
- `lib/screens/log_due_bills_screen.dart` — Added `peso_mascot.dart` import; AppBar actions PesoMascot(28, thinking); empty state PesoMascot.withSpeech(56, celebrating)
- `lib/screens/glossary_screen.dart` — Added `peso_mascot.dart` import; AppBar actions PesoMascot(28, thinking)
- `lib/screens/data_quality_screen.dart` — Added `peso_mascot.dart` import; clean-state PesoMascot(64, proud) — hardcoded mood

Full diff: `git diff main -- lib/screens/home_screen.dart lib/screens/ai_screen.dart lib/screens/paluwagan_screen.dart lib/screens/pca_calculator_screen.dart lib/screens/log_due_bills_screen.dart lib/screens/glossary_screen.dart lib/screens/data_quality_screen.dart`

</details>
