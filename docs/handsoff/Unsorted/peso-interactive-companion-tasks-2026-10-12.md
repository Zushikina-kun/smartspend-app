# Peso — Interactive Companion System Tasks
**Date:** October 12, 2026
**Context:** User wants Peso to be more useful, reactive, and present throughout the app — not just decorative. Inspired by Duolingo's Duo (state-driven, reacts to user actions), Clippy (contextual helper), and modern AI mascot UX patterns.

---

## Research Findings

### Duolingo's key insight (from engineering blog, 2026)
> "This is a state problem, not an animation problem. The mascot must represent: idle/waiting → listening → thinking → talking → emotional feedback."

The character behaves like a **call participant**, not a narrator. It's always present, always aware of what the user is doing, and reacts accordingly.

### What makes a mascot feel alive (from UX research)
1. **Tap response** — immediate physical bounce + mood change on tap. Users tap things to see if they respond. A mascot that doesn't react to taps feels broken.
2. **Contextual awareness** — mascot knows which screen you're on and what you're doing.
3. **Proactive tips** — mascot speaks up when it notices something, not just when you ask.
4. **Consistent presence** — mascot appears on every screen (at least in some form), not just on specific ones.
5. **Helpful, not annoying** — like Duolingo, tips should be dismissable and never repeat. One-shot shown once via SharedPreferences.

---

## Currently Being Implemented (wf_23367211000cabcb)

### T-1: Tappable PesoMascot with bounce + tapMood override
- `onTap`, `tapMood`, `tapSpeech` optional params on `PesoMascot`
- Bounce animation on tap (scale 1.0 → 1.18 → 1.0, 120ms)
- `_currentMood` state overrides `widget.mood` temporarily (1.5s revert)
- **Files:** `lib/widgets/peso_mascot.dart`

### T-2: Peso-powered InfoButton (replaces AlertDialog with bottom sheet)
- `InfoButton` still shows ❓ icon but `onTap` now opens `showModalBottomSheet`
- Bottom sheet: drag handle + Peso (winking, 72px) + speech bubble with title/body + "Got it!" button
- **Impacts ALL 30+ info buttons across 15+ screens instantly — one file change**
- **Files:** `lib/widgets/info_button.dart`

### T-3: Tappable Peso on home Quick Access heading
- Small Peso (32px, winking) next to Quick Access heading
- On tap: shows SnackBar with helpful tip
- **Files:** `lib/screens/home_screen.dart`

### T-4: Tappable Peso on AI screen welcome
- `GestureDetector` wrapping the existing `PesoMascot.withSpeech()` on empty AI screen
- On tap: adds a greeting message to the chat if empty
- **Files:** `lib/screens/ai_screen.dart`

---

## Task List (not yet coded)

### PRIORITY 1 — Peso as Screen Guide (first-time tips per screen)

**Task G-1: PesoScreenTip widget**
A reusable widget that shows Peso with a contextual tip the FIRST TIME a screen is visited. Uses SharedPreferences to ensure it only shows once.

```dart
class PesoScreenTip extends StatefulWidget {
  final String screenKey;        // unique key like 'tip_budget_screen'
  final PesoMood mood;
  final String tipText;
  final double size;
  
  // Shows automatically in initState, dismisses after 5s or on tap
}
```

Implementation:
- In `initState()`: check prefs for `screenKey`. If not seen, show after 500ms delay.
- Display as an `AnimatedPositioned` overlay at bottom-center of screen
- Peso + speech bubble, tap to dismiss, auto-dismisses after 5s
- `PesoMood.winking` for tips, `PesoMood.excited` for first-ever screen visit

**Where to add PesoScreenTip:**
| Screen | Key | Mood | Tip text |
|--------|-----|------|----------|
| BudgetScreen | `tip_budgets` | winking | "Mga budget ang susi! 🔑 Set a limit per category and I'll warn you before you hit it." |
| SavingsGoalsScreen | `tip_goals` | excited | "Goals keep you motivated! 🎯 I'll celebrate every 25% milestone with you." |
| DebtScreen | `tip_debts` | winking | "Track what you owe AND what's owed to you. I'll remind you when payments are due! 💳" |
| InsuranceScreen | `tip_insurance` | thinking | "SSS, PhilHealth, Pag-IBIG due dates — I've got them all here. Never miss a contribution." |
| TransactionsScreen | `tip_transactions` | winking | "Long-press any transaction to edit, duplicate, or delete. Swipe left too! 💡" |
| AnalyticsScreen | `tip_analytics` | excited | "Tap any chart to see the breakdown! Your data tells a story — I'll help you read it. 📊" |
| ProfileScreen | `tip_profile` | proud | "This is your financial report card! Tap the Health Score to see your breakdown. 🏆" |

**Estimate:** ~3h (widget + 7 screen placements)

---

### PRIORITY 2 — Peso reacts to user actions (proactive, not just reactive)

**Task P-3: Peso celebrates/warns on expense log**
When a user logs an expense via quick-input on the home screen:
- If it's a **Want** tagged item over ₱500 → Peso shows `embarrassed` briefly + SnackBar "Ay! Malaking gusto 'yan — worth it? 😅" (shown max once per session)
- If it's a **Need** → Peso shows `happy` + "Logged! ✅"
- If it pushes them **over their daily budget** → Peso shows `worried` briefly + "Malapit na sa limit mo ngayon! 😬"
- **Files:** `home_screen.dart` quick-input submit handler

**Task P-4: Peso reacts to goal progress**
In `savings_goals_screen.dart`, when a contribution is added:
- Crosses 25% → `celebrating` + "25% na! Kalahati pa lang kaya mo! 💪"
- Crosses 50% → `excited` + "Kalahati na! Patapos na tayo! 🎯"
- Crosses 75% → `celebrating` + "75%! Isa na lang tayong push! 🔥"
- Reaches 100% → `excited` + confetti + "NAKUHA MO NA ANG GOAL! 🏆 Peso is SO proud!"
- **Files:** `savings_goals_screen.dart` contribution dialog

**Task P-5: Peso tip when user hasn't logged in a while**
Check `last_log_date` in prefs vs today. If > 2 days:
- Show `sleepy` Peso on home screen with "Hoy! ${dayCount} days na walang log... 👀 Ano nangyari?" speech bubble
- Tap bubble → opens Peso chat
- **Files:** `home_screen.dart` startup check (alongside existing connectivity check)

---

### PRIORITY 3 — Peso presence on every major screen

**Task P-6: Floating Peso action button**
A small floating `PesoMascot` (44px) that appears in the bottom-right of screens that don't have a natural Peso placement. Tapping it opens a mini help menu:
- "Ask Peso a question" → opens AI chat
- "What is this screen?" → shows InfoButton-style Peso explanation for the current screen
- "Quick tip" → shows a random contextual tip

This is essentially a **help button but Peso-shaped**. Replaces the generic "?" help button on screens.

Screens to add it to: BudgetScreen, SavingsGoalsScreen, DebtScreen, InsuranceScreen, RecurringScreen, TransactionsScreen

**Estimate:** ~2h (FloatingPesoButton widget + 6 placements)

**Task P-7: Peso in all AppBar titles (subtle)**
Currently most screens have `Text("Screen Title")` in AppBar. For key screens, show a tiny Peso (18px, `neutral`) alongside the title:
```dart
// AppBar title:
Row(mainAxisSize: MainAxisSize.min, children: [
  const PesoMascot(size:18, mood:PesoMood.neutral),
  const SizedBox(width:6),
  const Text("Budgets"),
])
```
This makes Peso feel omnipresent without being intrusive.

Screens: BudgetScreen, SavingsGoalsScreen, DebtScreen, AnalyticsScreen, ProfileScreen

**Estimate:** ~1h (5 screens, 3 lines each)

---

### PRIORITY 4 — Smart contextual Peso hints (AI-powered)

**Task P-8: Peso speaks when FHS changes tier**
When FHS crosses a tier boundary (e.g., 49→50 = Fair→Good, 69→70 = Good→Excellent):
- Bottom sheet slides up with Peso in appropriate mood + tier-specific speech:
  - Crosses 70 (→ Good): `proud` + "Nag-level up ka! 🌟 Good tier na tayo. Keep it up!"
  - Crosses 90 (→ Excellent): `celebrating` + "EXCELLENT! 🏆 Top tier ka na! Peso is SO proud!"
  - Drops below 70 (→ Fair): `worried` + "Bumaba ng konti ang score... 😕 Ayusin natin — log more and set budgets!"
- Store `last_fhs_tier` in prefs, compare on each FHS calculation
- **Files:** `home_screen.dart` + `score_service.dart`

**Task P-9: Peso explains unusual spending patterns**
`BehavioralFeedbackService.checkForCelebration()` already detects anomalies. Wire it to show Peso:
- Spending anomaly detected → `surprised` Peso + speech bubble explaining which category
- Consistent savings 4 weeks → `proud` Peso + "4 weeks of consistent saving! Peso approves! 💚"
- **Files:** `home_screen.dart` startup check

---

### PRIORITY 5 — Peso personality on specific screens

**Task P-10: Peso in Debt screen — motivational**
- Zero total debt: `celebrating` + "UTANG-FREE! 🎉 Peso is unbelievably proud!"
- Has overdue debt: `worried` + "May overdue ka... 😟 Ayusin natin 'to together."
- Paid off a debt: `excited` for 2s + "NABAYARAN! That felt good, right? 💪"
- **Files:** `debt_screen.dart`

**Task P-11: Peso in Financial Calendar**
- No events this month: `sleepy` → current "Wala pang events" state already uses `thinking`; upgrade to `sleepy`
- Upcoming payment in 3 days: `worried` mini badge on the calendar day

**Task P-12: Peso mini-avatar in transaction list**
When viewing `transactions_screen.dart`:
- If viewing a single day's transactions: small Peso in the day header
- If filtering by category: Peso shows the matching mood for that category's spending (over budget = `embarrassed`, under = `happy`)

---

### PRIORITY 6 — Peso speaks in Peso's own voice (character consistency)

**Task P-13: PesoVoice service — centralized speech lines**
Create `lib/services/peso_voice_service.dart` — a centralized store of all Peso speech lines, categorized by trigger:

```dart
class PesoVoiceService {
  // Returns a random phrase for the given context
  static String get(PesoVoiceContext ctx) { ... }
  
  // All phrases are bilingual — Filipino first, English option
  static const Map<PesoVoiceContext, List<String>> _phrases = {
    PesoVoiceContext.afterLog: [
      "Noted! ✅ Maayos tayo.",
      "Got it! I'll remember that. 📝",
      "Recorded! Keep it up! 💪",
    ],
    PesoVoiceContext.budgetWarning: [
      "Ay, malapit na tayo sa limit! 😬",
      "Heads up — budget's getting tight! ⚠️",
    ],
    PesoVoiceContext.goalMilestone25: ["25% na! Kaya mo 'yan! 🎯"],
    PesoVoiceContext.goalMilestone50: ["Kalahati na! Patapos na! 🔥"],
    PesoVoiceContext.goalComplete: ["NAKUHA MO NA! 🏆 Peso is SO proud!"],
    PesoVoiceContext.streakBroken: ["Ay... nawala ang streak. Simulan ulit tayo! 💪"],
    PesoVoiceContext.noLogDays2: ["2 days na... kumain ka ba? 😅 Log mo na!"],
    PesoVoiceContext.noLogDays3: ["Hoy! 3 days na! Ano nangyari? 👀"],
    PesoVoiceContext.goodMorning: ["Magandang umaga! ☀️ Kumain ka na?"],
    PesoVoiceContext.goodAfternoon: ["Hapon na! Kumain ka ba ng lunch? 😄"],
    PesoVoiceContext.goodEvening: ["Gabi na! Kamusta ang araw mo? 🌙"],
    PesoVoiceContext.midnight: ["Gising ka pa? 😴 I'll still be here. Rest well!"],
  };
}
```

This centralizes all Peso speech so it's consistent across the app.

**Estimate:** ~2h (service + wire up to existing speech bubble usages)

---

## Implementation Roadmap

### Phase 1 — Being implemented NOW (~done)
- T-1: Tappable PesoMascot
- T-2: Peso-powered InfoButton (affects ALL 30+ info buttons)
- T-3: Home screen Peso tip
- T-4: AI welcome tap-to-greet

### Phase 2 — Next session (~8h)
- G-1: PesoScreenTip widget + 7 screen placements
- P-3: Expense log reactions (Want/Need/over-budget)
- P-5: No-logging reminder
- P-8: FHS tier change speech

### Phase 3 — Later (~6h)
- P-4: Goal progress celebrations
- P-6: Floating Peso help button
- P-7: Peso in AppBar titles
- P-9: Behavioral feedback → Peso mood

### Phase 4 — Polish (~4h)
- P-10/11/12: Debt screen, Calendar, Transactions
- P-13: PesoVoice service (centralizes all speech)
- P-7: AppBar titles

---

## Key Principle

> **Peso should never be annoying.** Every proactive tip must:
> 1. Use SharedPreferences to show max once (or once per session for critical warnings)
> 2. Be dismissable by tapping anywhere
> 3. Auto-dismiss after 4–5 seconds
> 4. Be relevant to what the user is currently doing

Duolingo's Duo works because he's **earned the right** to bother you — every Duo message is genuinely about your learning. Same for Peso — every Peso message should be about the user's actual money situation.

---

*Added by Kiro — October 12, 2026*
*Workflow wf_23367211000cabcb implementing T-1 through T-4 right now.*
