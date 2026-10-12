import 'dart:math';

/// Centralized Peso speech lines — consistent Filipino/Taglish voice.
/// All messages are warm, non-judgmental, and brief (1–2 sentences max).
enum PesoContext {
  morningGreeting,
  afternoonGreeting,
  eveningGreeting,
  midnightGreeting,
  firstLogToday,
  noLogYet,
  endOfDaySummary,
  budgetWarning,
  budgetOver,
  budgetAllGreen,
  goalMilestone25,
  goalMilestone50,
  goalMilestone75,
  goalComplete,
  streak3,
  streak7,
  streak14,
  streak30,
  streakBroken,
  fhsImproved,
  fhsDropped,
  fhsExcellent,
  noSpendDay,
  wantExpenseLarge,
  generalEncouragement,
  afterScan,
  afterImport,
  afterBackup,
  newGoalAdded,
  debtPaidOff,
  firstLogin,
}

class PesoVoiceService {
  static final _rand = Random();

  /// Returns a contextual Peso speech line.
  /// [vars] can substitute placeholders like {category}, {amount}, {score}.
  static String get(PesoContext ctx, {Map<String, String> vars = const {}}) {
    final lines = _phrases[ctx];
    if (lines == null || lines.isEmpty) return '👋';
    var line = lines[_rand.nextInt(lines.length)];
    vars.forEach((k, v) => line = line.replaceAll('{$k}', v));
    return line;
  }

  static const Map<PesoContext, List<String>> _phrases = {
    PesoContext.morningGreeting: [
      'Magandang umaga! ☀️ Kumain ka na?',
      "Good morning! Let's make today count! 💚",
      'Umaga na! Fresh start — ready ka ba? ✨',
    ],
    PesoContext.afternoonGreeting: [
      'Hapon na! Kumain ka ba ng lunch? 🍱',
      "Good afternoon! How's the spending going? 📊",
      'Pwera araw! Kumusta ang gastos ngayon? 😄',
    ],
    PesoContext.eveningGreeting: [
      'Gabi na! Kamusta ang araw mo? 🌙',
      "Good evening! Time to log if you haven't yet! 📝",
      'Gabi na pala! Ano ang nangyari ngayon? 🌙',
    ],
    PesoContext.midnightGreeting: [
      "Gising ka pa? 😴 Rest up — I'll still be here!",
      'Late night logging? Respect. 🌙 Pero rest na after!',
    ],
    PesoContext.firstLogToday: [
      'Noted! ✅ Maayos tayo.',
      'Got it! First log of the day — nice! 🌟',
      "Logged! Peso's watching your budget. 💚",
      "Recorded! Keep tracking — you're doing great! 📝",
    ],
    PesoContext.noLogYet: [
      'Wala pa akong records ngayon 🤔 May nangyari ka ba?',
      'No logs yet today — anything to track? 📝',
      'Hoy! Wala pa tayong entry ngayon... okay ka lang? 😄',
    ],
    PesoContext.endOfDaySummary: [
      'Today: {count} expenses, ₱{total} total. {category} ang pinaka! 📊',
      'Day recap: ₱{total} spent across {count} items. Nice tracking! ✅',
    ],
    PesoContext.budgetWarning: [
      'Ay, malapit na sa limit ang {category}! 😬',
      'Heads up — {category} budget is at {pct}%! ⚠️',
      '{category} is getting close to the limit! Ingat tayo. 💡',
    ],
    PesoContext.budgetOver: [
      "{category} over budget na... 😬 But it's okay — we can adjust!",
      "Ay! {category} lampas na sa budget. Let's watch the rest! 💪",
    ],
    PesoContext.budgetAllGreen: [
      'All budgets in the green! Peso is satisfied. 😌',
      "Every budget on track! You're crushing it! 💚",
    ],
    PesoContext.goalMilestone25: [
      '25% na sa {goal}! Matagal pa pero kaya mo! 🎯',
      'First quarter done for {goal}! Simula palang! 💪',
    ],
    PesoContext.goalMilestone50: [
      'Kalahati na ng {goal}! Hindi na malayo! 🔥',
      '50% of {goal} done! Halfway there — keep going! 🎯',
    ],
    PesoContext.goalMilestone75: [
      '75%! Isang push na lang para sa {goal}! 💪',
      'Almost there for {goal}! 75% done! 🏆',
    ],
    PesoContext.goalComplete: [
      'NAKUHA MO NA ANG GOAL! 🏆 Peso is SO proud!',
      'GOAL COMPLETE! 🎉 Grabe — you actually did it! Taas kamay!',
      '{goal} REACHED! You set it, you saved it, you got it! 🥹',
    ],
    PesoContext.streak3: [
      '3-day streak! 🔥 Getting into the habit!',
      '3 days consistent! Galing mo! 💚',
    ],
    PesoContext.streak7: [
      '7-day streak! 💯 Week Warrior — consistent ka talaga!',
      'One full week of logging! Peso is impressed. 🙌',
    ],
    PesoContext.streak14: [
      "14 days! Half a month of consistency! 🔥 You're building a real habit.",
      'Two weeks straight! Galing — hindi ka tumitigil! 💪',
    ],
    PesoContext.streak30: [
      'ONE MONTH STREAK! 🏆 GRABE. Month Master. Peso bows. 🫡',
      '30 days! You did it — a full month of tracking. Nakaka-proud! 🥹',
    ],
    PesoContext.streakBroken: [
      'Ay... nawala ang streak. Simulan ulit tayo! 💪',
      'Streak broken. But starting over is still brave. 😊',
      "That's okay — new streak starts now! 🌱",
    ],
    PesoContext.fhsImproved: [
      'Score up to {score}! Consistent ka talaga! 📈',
      'FHS improved! Galing mo — {score}/100 na! 🌟',
    ],
    PesoContext.fhsDropped: [
      'Score dropped a bit to {score}. Huwag mag-alala — pwede nating ayusin! 💪',
      "FHS at {score} today. No biggie — let's get it back up! 🔄",
    ],
    PesoContext.fhsExcellent: [
      'EXCELLENT score! {score}/100! 🏆 Top tier ka na — Peso bows.',
      'Pinaka-mataas na tier! {score}/100 Excellent! Grabe ka! 🥇',
    ],
    PesoContext.noSpendDay: [
      'Zero spending today! No-Spend Day achieved! 💚',
      'ZERO expenses! No-spend day — Peso approves! 🎉',
    ],
    PesoContext.wantExpenseLarge: [
      "Malaking gusto 'yan (₱{amount})! Worth it? 😅",
      "Big 'Want' purchase — ₱{amount}. Sige, enjoy! Just logging it. 😄",
    ],
    PesoContext.generalEncouragement: [
      "You're doing great — keep it up! 💚",
      'Consistent ka! Peso is proud. 🌟',
      "One day at a time — you've got this! 💪",
    ],
    PesoContext.afterScan: [
      'Receipt scanned! Easy logging — love it. 🧾',
      'OCR done! All items extracted. Ganda ng tech natin! 📷',
    ],
    PesoContext.afterImport: [
      'Import complete! All items logged in one go. Efficient! ✅',
      "Batch import done! Madali lang 'yan with Peso. 📊",
    ],
    PesoContext.afterBackup: [
      'Backup saved! Your data is safe. 🔒',
      "Data backed up! Sleep easy — Peso's got it. 💚",
    ],
    PesoContext.newGoalAdded: [
      'New goal added! ₱{target} by {deadline}. Peso believes in you! 🎯',
      "Goal set! Now let's work toward it — one save at a time. 💪",
    ],
    PesoContext.debtPaidOff: [
      'UTANG PAID! 🎉 Debt-free on that one — feels good, right?',
      'Debt cleared! {name} done. One less thing to worry about! 💚',
    ],
    PesoContext.firstLogin: [
      'Kumusta! Ako si Peso — your money buddy! Magtayo tayo ng magandang financial future! 💚',
      "Hi! I'm Peso! Tell me what you spent, ask me anything, or let's set some goals! 😊",
    ],
  };
}
