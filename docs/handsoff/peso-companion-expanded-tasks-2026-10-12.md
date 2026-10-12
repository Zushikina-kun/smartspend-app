# Peso — Expanded Companion System & Achievements Tasks
**Date:** October 12, 2026
**Status:** Planning — comprehensive expansion of Peso's role
**Research basis:** Duolingo (streak psychology, mascot reactions), Alan Health (bear mascot UX), Wisey (patient friend model), nudge design research (Plotline 2026, MDPI)

---

## Research Findings Summary

### The "Patient Friend" principle (Wisey, 2026)
> "Supportive companion, not strict taskmaster. Traditional productivity apps trigger immediate stress responses. A patient friend understands life gets complicated."

Applied to Peso: he notices things but never demands. He asks, not tells. He celebrates more than he warns.

### Duolingo's key formula
1. **Streak = identity** — "I'm a person who logs every day" becomes part of self-image
2. **Loss aversion works better than gain** — fear of losing a 7-day streak > excitement of starting one
3. **Mascot shows disappointment, not anger** — Duo's sad face when you miss a day is subtle, not guilt-tripping
4. **One nudge max per day** — more = ignored/uninstalled

### Alan Health bear mascot (most relevant reference for finance apps)
> "The mascot does emotional work that no UI element could — makes a high-stakes financial product feel approachable. In any product where users dread engaging (taxes, insurance, banking), a friendly mascot reframes the entire emotional contract."

Peso's job is to make money management feel less scary and more like chatting with a friend who happens to know a lot about budgeting.

### Non-intrusive nudge rules (Plotline/MDPI research)
- Max **1 proactive in-app nudge per day** (separate from push notifications)
- **Context-triggered** not time-triggered — fire when user opens app, not on a schedule
- **Always dismissable** in one tap
- **Never repeat** the same nudge on the same day (prefs key per nudge per day)
- **Positive first** — celebrate before warning. If user did something good AND something bad today, lead with the good.

---

## SECTION A: Peso's Daily Check-In Behavior

### What already exists
- Home screen has time-of-day greeting ("Good Morning 👋")
- AI screen has Peso speech bubble greeting (Magandang umaga, Kumain ka na ba?, Good evening)
- `_MoodCheckInWidget` exists on home screen
- `ProactiveNudgeService.check()` runs on startup
- `StartupAlertsService` runs reactive checks

### What's missing: Peso as the check-in messenger

**Task C-1: Peso daily "how's your day?" card on home screen**
Currently the home screen has the mood widget (5 emoji faces). Enhance this to be Peso-delivered:
- Replace the plain emoji row with a Peso card that says something contextual based on time:
  - Morning (6-11): "Magandang umaga! ☀️ Kumain ka na? Pag may gastos ka, sabihin mo sa akin!"
  - Afternoon (12-17): "Hapon na! Kumain ka ba ng lunch? 🍱 Log mo na kung may gastos!"
  - Evening (18-22): "Gabi na! Kamusta ang gastos mo ngayon? 🌙"
  - Late (22-5): "Gising ka pa? 😴 Rest well — I'll still be here tomorrow!"
- After user logs today's first expense → Peso switches to `happy` and says "Noted! Keep it up!"
- **Files:** `home_screen.dart` — enhance `_MoodCheckInWidget` or add adjacent to it

**Task C-2: "Did you log today?" gentle nudge — HOME SCREEN ONLY, once per day**
NOT a push notification — just an in-app Peso speech bubble that appears on the home screen:
- Check if today has 0 logged expenses AND it's past 2 PM
- If so: show small Peso (32px, `winking`) with speech bubble: "Wala pa akong nakita ngayon... may gastos ka ba? 👀"
- Tapping the bubble → focuses the quick-log input bar
- Tapping the ✕ → dismisses and marks `peso_nudge_no_log_{date}` in prefs (won't show again today)
- **Critical rule**: MAX ONCE PER DAY. Uses date-keyed pref to suppress after dismissal.
- **Files:** `home_screen.dart` — in the main content area, below the spending card

**Task C-3: End-of-day spending summary from Peso (optional, evening only)**
When user opens the app in the evening (6 PM+) and has logged expenses today:
- If NOT yet done, Peso shows a mini recap: "Ngayong araw: spent ₱[X] across [N] items. [Category] ang pinakamataas."
- This is a ONE-LINE contextual comment, not a full report — just a friendly summary
- Shown max once per day (evening). Uses `peso_eod_summary_{date}` pref key.
- **Files:** `home_screen.dart`

---

## SECTION B: Peso Transactions Awareness

**Task T-1: Peso reacts to first expense of the day**
When the user logs their first expense of the day (expense count goes from 0 to 1):
- Peso shows `happy` briefly with "First log of the day! 🌟 Nice — keep tracking!"
- Subsequent logs: just the existing warm logging tone (no extra Peso reaction)
- **Files:** Quick-log input handler in `home_screen.dart`, AI action handler in `ai_screen.dart`

**Task T-2: Peso notices Want vs Need balance**
At end of session (when app resumes from background or user navigates to Analytics):
- If >60% of today's spending is "Want" tagged → Peso shows `surprised` with "Grabe! Most of today's spending was Wants. Okay lang — just be aware! 😅"
- Shown max once per day
- **Files:** `home_screen.dart` `_checkStartupAlerts()` flow

**Task T-3: Peso celebrates a no-spend streak**
When user has 0 expenses on a day (no-spend day):
- Next morning: Peso shows `proud` with "Yesterday — ZERO spending! No-spend day complete! 💚"
- After 3 consecutive no-spend days: `celebrating` with "3 no-spend days in a row! Grabe!"
- **Files:** `startup_alerts_service.dart` or `home_screen.dart` init

**Task T-4: Peso notices unusual merchants (fun, not alarming)**
When a Shopee/Steam/Lazada expense is logged:
- Peso shows `winking` with a playful comment: "Shopee pala! 🛒 Baka may ibang pang darating?" (once per session, not per item)
- When a Jollibee/McDonalds/food expense is logged in the evening: "Late-night food? 🍔 Peso approves. Kain na!"
- These are personality moments, not alerts. Lightweight and dismissable.
- **Files:** `ai_screen.dart` action handler for `log_expense`

---

## SECTION C: Peso-Related Achievements (NEW BADGES)

The app has 25 badges. Propose 10 new Peso-themed badges:

### New badges to add to `achievements_screen.dart`:

```dart
// PESO COMPANION BADGES
_Badge('🤜', 'Peso Pal', 'Tap Peso 10 times across the app', 'peso_tap_10'),
_Badge('💬', 'Conversation Starter', 'Send 50 AI messages total', 'ai_50'),
_Badge('🌅', 'Morning Logger', 'Log an expense before 9 AM on 7 different days', 'morning_7'),
_Badge('🌙', 'Night Logger', 'Log an expense after 9 PM on 7 different days', 'night_7'),
_Badge('📆', 'Perfect Week', 'Log expenses every day for 7 consecutive days', 'log_7'),
_Badge('🎤', 'Peso Chatterbox', 'Have a 10-message conversation with Peso in one session', 'chat_10'),
_Badge('💚', 'Generous Soul', 'Record lending money to someone 3 times (I Lent tab)', 'lent_3'),
_Badge('🧩', 'Detail Detective', 'Use all 7 expense input methods at least once', 'all_inputs'),
_Badge('🏅', 'Peso Fan', 'Earn 15 badges total', 'badges_15'),
_Badge('⭐', 'App Veteran', 'Use SmartSpend for 30 calendar days since first expense', 'veteran_30'),
```

### Badge tracking additions needed in `_computeEarnedBadges()`:
- `peso_tap_10`: increment a counter in SharedPreferences each time Peso is tapped; check ≥10
- `ai_50`: count total chat messages (already tracked — check `DBService.getChatHistory()` count)
- `morning_7`: check expenses before 9 AM, count distinct dates with ≥1 such expense
- `night_7`: same but after 21:00
- `log_7`: 7-consecutive logging streak (separate from streak_3/streak_7 which are score-based)
- `chat_10`: count messages in current session (transient, reset on session start)
- `lent_3`: count debts with type='lent' (already in debt table)
- `all_inputs`: track a set of used input methods in SharedPreferences; full set = badge
- `badges_15`: `earned.length >= 15`
- `veteran_30`: `firstExpenseDate` to today >= 30 days

### When badges unlock: Peso-powered celebration
Currently badge unlocks show a plain `SnackBar`. Upgrade to:
- Show `PesoMascot.withSpeech(size:72, mood:PesoMood.excited/celebrating, text:"Badge unlocked: [name]! [description]")`
- In a brief modal bottom sheet that auto-dismisses after 3s (or tap to dismiss)
- Body color of Peso matches the badge category:
  - Streak badges → `excited` (gold body)
  - Savings badges → `proud` (emerald glow)
  - Fun/personality badges → `celebrating` (gold)
  - Discipline badges → `winking`
- **Files:** `achievements_screen.dart` — in the badge unlock loop

---

## SECTION D: Peso Screen Guide (First-Visit Tips)

**Task G-1: PesoScreenTip reusable widget**
```dart
class PesoScreenTip extends StatefulWidget {
  final String screenKey;        // SharedPrefs key: 'tip_budget_screen' etc.
  final PesoMood mood;
  final String tipText;
  final double size;
  final bool autoShow;           // true = shows automatically on first visit
  
  // On first visit: animates in from bottom, 5s auto-dismiss
  // Tap Peso: dismisses immediately
  // Tap outside: dismisses
}
```

Shown as `AnimatedPositioned` overlay at bottom-center. Peso + speech bubble. Fade out after 5s or on tap.

**Screen tips to add (12 screens):**
| Screen | Key | Tip |
|--------|-----|-----|
| BudgetScreen | `tip_budget` | "Set a limit per category — I'll warn you at 80% and 100%! 💡" |
| SavingsGoalsScreen | `tip_goals` | "Set goals with deadlines and I'll track your monthly contribution needed! 🎯" |
| DebtScreen | `tip_debts` | "Track what you owe AND what's owed to you. I'll remind you before due dates! 💳" |
| RecurringScreen | `tip_recurring` | "Add Netflix, GCash load, Meralco — I'll remind you before they're due! 🔁" |
| InsuranceScreen | `tip_insurance` | "SSS, PhilHealth, Pag-IBIG — never miss a contribution again! 🛡️" |
| TransactionsScreen | `tip_transactions` | "Long-press any transaction to edit or delete. Tap a category to filter! 💡" |
| AnalyticsScreen | `tip_analytics` | "Tap any chart for a breakdown! Your spending tells a story — let's read it. 📊" |
| PaluwaganeScreen | `tip_paluwagan` | "Track your rotating savings group here — whose turn, how much, when! 🤝" |
| BankComparisonScreen | `tip_banks` | "Compare PH banks and digital banks at a glance — rates, minimums, features! 🏦" |
| DebtPayoffScreen | `tip_debt_calc` | "See which debt to pay first to save the most interest! 📉" |
| ChatHistoryScreen | `tip_chat_history` | "All your Peso conversations saved here — search or start a new one! 💬" |
| AchievementsScreen | `tip_achievements` | "Earn badges by hitting financial milestones! Locked ones show what to aim for. 🏅" |

---

## SECTION E: Proactive Peso — Gentle Nudges (in-app only)

### Golden rules for ALL proactive nudges
1. **Max 1 nudge per day** — gate with `peso_nudge_shown_{date}` pref
2. **Always dismissable** — ✕ button or tap-outside
3. **Never guilt-trip** — frame as care, not judgment
4. **Positive > warning** — if both apply, show the positive one
5. **Only fire when app is actively open** — no mid-session pop-ups while user is typing

**Task E-1: No-log nudge (gentle, once per day)**
Already partially planned in C-2. Refined:
- Fires at home screen load if: today's expenses = 0 AND time ≥ 14:00
- Peso: `thinking` mood, speech: "Wala pa akong records ngayon 🤔 May nangyari ka ba?"
- Tap: focuses quick-log bar
- Dismiss: marks `peso_no_log_nudge_{date}`
- **NOT a push notification** — in-app speech bubble only

**Task E-2: Budget warning from Peso (replaces cold text)**
Currently `BehavioralFeedbackService` generates budget warnings as text. Route them through Peso:
- If any budget > 90%: home screen shows Peso `worried` with "Malapit na sa limit ang [category]! ⚠️"
- If any budget > 100%: Peso `embarrassed` with "[Category] over budget na... 😬 But you can fix this!"
- Shown at home screen load, max once per day per category

**Task E-3: Upcoming bill reminder from Peso**
`ProactiveNudgeService` already sends push notifications for this. Add an in-app version:
- If a recurring item/insurance payment is due in ≤3 days: home screen Peso speech bubble
- "Paalala: [item] due in [N] days — ₱[amount]. Log it when you pay! 📅"
- Shown once per item per due-cycle

**Task E-4: Good news celebration from Peso**
When positive events are detected at startup:
- Savings rate this month ≥ 20%: Peso `proud` + "Grabe! Saving [X]% of income this month! Keep it up! 💚"
- All budgets on track: Peso `winking` + "All budgets in the green! Peso is satisfied. 😌"
- FHS improved since yesterday: Peso `happy` + "Score up to [X] today! Consistent ka talaga! 📈"
- **Fire positive nudge BEFORE any warning** — end on encouragement

**Task E-5: Weekly Peso summary (Sunday evenings)**
On Sunday evenings (5 PM+) if user opens the app:
- Peso `happy` with a mini week summary card: "This week: ₱[total] spent. [Top category] ang pinaka. [Streak] days logged. [X] badges earned."
- More fun/encouraging than analytical — it's a "well done, here's your week" not a "here's what you spent"
- Separate from the existing weekly behavioral notification

---

## SECTION F: Peso Personality Moments (Fun, Non-Finance)

**Task F-1: Peso reacts to time of day on open**
When user opens the app at specific times (shown max once per session):
- Before 8 AM: "Maaga ka ah! ☀️ Early bird lang! Kumain ka na bago mag-class/trabaho?"
- 12-1 PM: "Lunch break! 🍱 Kumain ka? Log mo na kung may gastos!"
- After 11 PM: "Gising ka pa? 😴 Wag masyado ma-Shopee tonight... rest up!"
- Special: Halloween (Oct 31): "BOO! 👻 Peso nakalagay sa costume! Sana hindi puro treats ang gastos mo!"
- Christmas (Dec 25): "Maligayang Pasko! 🎄 Peso loves this season — pero bantayan natin ang gastos ha!"

**Task F-2: Peso reacts to milestone expense counts**
- Expense #10: "10 expenses na! Getting into the habit! 🌱"
- Expense #50: "50 na! Consistent ka talaga! 💪"
- Expense #100: "100 EXPENSES! 🎉 Century Club badge unlocked!" (triggers badge)
- Expense #500: "500 expenses! Grabe — you're a real tracker now! 🏆"

**Task F-3: Peso reacts to wallet additions**
When user adds a new wallet (Maya, GrabPay, etc.):
- "New wallet added! 💳 Now I can track [wallet name] for you too!"

**Task F-4: Seasonal/holiday messages (Filipino holidays)**
Store a map of PH holidays and show a one-time greeting:
- New Year (Jan 1): "Bagong taon! 🎆 Fresh start sa finances — set new goals tayo!"
- Valentine's (Feb 14): "Happy Hearts Day! 💕 Log those date expenses — kasali si Peso sa celebration!"
- Holy Week: "Holy Week na — mag-ipon tayo para sa pasyal! ⛪"
- Payday (if user has recurring income): "Sweldo day! 💵 Allocate first before spending — Peso's rule #1!"
- **Implementation:** Simple date-keyed check in `startup_alerts_service.dart`

---

## SECTION G: Peso Tap Counter for Achievement

**Task G-PesoTap: Track Peso taps for 'Peso Pal' badge**
Every time any `PesoMascot` is tapped (new `onTap` callback):
- Increment `peso_tap_count` in SharedPreferences
- Check if ≥ 10 → unlock `peso_tap_10` badge
- This is part of the achievement tracking in `achievements_screen.dart`

A shared static method: `PesoMascot.recordTap()` that does the prefs increment.

---

## SECTION H: PesoVoice Service (centralized speech lines)

**Task V-1: Create `lib/services/peso_voice_service.dart`**
All Peso speech lines in one place. Ensures consistent tone, Filipino flavor, and easy updating.

```dart
enum PesoContext {
  // Daily check-in
  morningGreeting, afternoonGreeting, eveningGreeting, midnightGreeting,
  firstLogToday, noLogYet, endOfDaySummary,
  // Transactions
  wantExpenseLarge, noSpendDay, noSpendStreak3,
  // Goals
  goalMilestone25, goalMilestone50, goalMilestone75, goalComplete,
  // Budgets
  budgetWarning80, budgetWarning100, budgetAllGreen,
  // Streaks
  streak3, streak7, streak14, streak30, streakBroken,
  // FHS
  fhsUp, fhsDown, fhsGood, fhsExcellent, fhsFair,
  // Fun
  shopeeExpense, foodLateNight, morningEarlyBird, nightOwl,
  expense10, expense50, expense100,
  // Milestones
  firstGoalComplete, firstDebtPaid, firstInsurance,
}

class PesoVoiceService {
  static String get(PesoContext ctx, {Map<String, String> vars = const {}}) {
    final lines = _all[ctx] ?? ['👋'];
    var line = lines[DateTime.now().millisecondsSinceEpoch % lines.length];
    vars.forEach((k,v) => line = line.replaceAll('{$k}', v));
    return line;
  }
  
  static const Map<PesoContext, List<String>> _all = {
    PesoContext.morningGreeting: [
      "Magandang umaga! ☀️ Kumain ka na?",
      "Good morning! Rise and shine — let's track today! ✨",
      "Umaga na! ☀️ Fresh start — ano ang plano natin ngayon?",
    ],
    PesoContext.noLogYet: [
      "Wala pa akong records ngayon 🤔 May nangyari ka ba?",
      "No logs yet today — anything to track? 📝",
      "Hoy! Wala pa tayong entry ngayon... buhay ka pa ba? 😄",
    ],
    PesoContext.firstLogToday: [
      "Noted! ✅ Maayos tayo.",
      "Got it! First log of the day — nice! 🌟",
      "Logged! Peso is watching over your budget. 💚",
    ],
    PesoContext.goalComplete: [
      "NAKUHA MO NA ANG GOAL! 🏆 Peso is SO proud of you!",
      "GOAL REACHED! 🎉 Grabe — you actually did it! Taas kamay!",
    ],
    PesoContext.streak7: [
      "7-day streak! 🔥 Week Warrior! Consistent ka talaga!",
      "One full week of logging! 💯 Peso is impressed.",
    ],
    PesoContext.streakBroken: [
      "Ay... nawala ang streak. Simulan ulit tayo! 💪",
      "Streak broken. But starting over is still brave. 😊",
      "That's okay — let's build a new one! 🌱",
    ],
    // ... (full set of ~40 contexts with 2-3 variants each)
  };
}
```

**Estimate:** ~2h (service + wire to existing PesoMascot.withSpeech calls throughout app)

---

## SECTION I: Peso Presence on Remaining Screens

Screens that should show Peso but currently don't:

| Screen | Placement | Mood | When |
|--------|-----------|------|------|
| `paluwagan_screen.dart` | Empty state | `winking` | "Wala pa tayong paluwagan! Mag-join ka na ng group." |
| `recurring_screen.dart` | Empty state | `thinking` | Already has Peso — upgrade to `winking` with better tip |
| `pca_calculator_screen.dart` | Header | `winking` | "Peso Cost Averaging — the Filipino investor's weapon! 📈" |
| `data_quality_screen.dart` | Results | `proud`/`worried` | Reflects quality score |
| `setup_screen.dart` step 3+ | Each step | varies | Already has Peso on steps 1-2; add to remaining steps |
| `login_screen.dart` | Below logo | `happy` | Friendly greeting on the login screen |

---

## SECTION J: Technical Considerations

### Peso tap tracking pattern
```dart
// In PesoMascot, in _handleTap():
static Future<void> _incrementTapCount() async {
  final prefs = await SharedPreferences.getInstance();
  final count = (prefs.getInt('peso_tap_count') ?? 0) + 1;
  await prefs.setInt('peso_tap_count', count);
}
```

### Daily nudge gate pattern (use everywhere)
```dart
static Future<bool> _shouldShowNudge(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final shown = prefs.getString('peso_nudge_${key}');
  if (shown == today) return false;
  await prefs.setString('peso_nudge_${key}', today);
  return true;
}
```

### Non-blocking overlay pattern
All Peso in-app nudges use `OverlayEntry` or a simple `AnimatedWidget` that sits OVER the content without blocking interaction:
```dart
OverlayEntry(
  builder: (_) => Positioned(
    bottom: 80, left: 16, right: 16,
    child: GestureDetector(
      onTap: () => entry.remove(),
      child: PesoMascot.withSpeech(size:56, mood:PesoMood.winking, text:tip),
    ),
  ),
)
// Auto-remove after 5s
Future.delayed(Duration(seconds:5), () => entry.remove());
```

---

## Priority Order

### Implement next (Phase 2, ~8h total)
1. **V-1** PesoVoice service (~2h) — foundation for consistent speech
2. **C-2** No-log daily nudge (~1h) — highest user value
3. **Achievement badges** (10 new) + Peso celebration upgrade (~2h)
4. **G-1** PesoScreenTip widget + 12 placements (~3h)

### Implement after (~8h)
5. **E-1 thru E-4** Proactive nudges (budget, bill, good news) (~3h)
6. **T-1 thru T-3** Transaction reactions (first log, no-spend, Want/Need) (~2h)
7. **F-1/F-2** Fun personality moments — time of day, milestone expenses (~2h)
8. **C-1** Enhanced daily check-in card (~1h)

### Later/Post-capstone (~4h)
9. **E-5** Weekly Peso summary
10. **F-3/F-4** Wallet additions, seasonal/holiday messages
11. **I** Remaining screen placements

---

*Compiled by Kiro — October 12, 2026*
*Research: Duolingo streak psychology, Alan Health bear mascot UX (beehiiv 2026), Wisey patient-friend model, MDPI digital nudge research, Plotline in-app nudge guide 2026.*
