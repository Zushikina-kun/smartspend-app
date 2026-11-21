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
  // Phase 2 contexts
  session5,
  session10,
  session20,
  lowBalance,
  overBudget,
  goalMilestone100,
  badgeUnlock,
  weeklyReview,
  bigExpense,
  recurringDue,
  savingsStreak,
  debtPaid,
  backupReminder,
  aiRateLimit,
  receiptScanned,
  voiceLogged,
  ocrSuccess,
  exportDone,
  newBudgetPeriod,
  paydayReminder,
  billOverdue,
  appBirthday,
  // Idle / screen-specific lines
  idleHome,
  idleAnalytics,
  idleGoals,
  idleBudget,
  idleDebts,
  idleRecurring,
  scrolledFar,
  holdGreeting,
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

  /// Returns all phrase options for a given context (for use as idleSpeeches).
  static List<String> getAll(PesoContext ctx) =>
      List.unmodifiable(_phrases[ctx] ?? const []);

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
    // ── Phase 2 phrases ───────────────────────────────────────────────────
    PesoContext.session5: [
      'Uy, 5 messages na tayo! 🎉 Lagi akong nandito para sa iyo!',
      "5 messages in — kumusta ang budget mo so far? 💚",
      'Huy, 5 na tayong kwentuhan! Sige, ituloy natin! 😄',
    ],
    PesoContext.session10: [
      '10 messages! Peso Fan badge on the way! 🎤 Maraming salamat sa chat!',
      "Double digits na tayo! 10 messages — you're a pro! 💬",
      'Wow, 10 na! Salamat sa pagsasabi sa akin ng lahat! 😊',
    ],
    PesoContext.session20: [
      '20 messages! Chatterbox level unlocked! 💬 Grabe ka talaga!',
      "20 messages! Peso is your biggest fan — keep it coming! 🎤",
      'Dalawampung usapan na tayo! Hindi ka tinatamad — love it! 🔥',
    ],
    PesoContext.lowBalance: [
      'Mababa na ang balance mo — ingat sa gastos! 💸',
      "Low balance alert! Baka time to hold off on big buys? 😬",
      'Piso na lang! Huwag muna mag-impulsive buy ha? 😅',
    ],
    PesoContext.overBudget: [
      'Over budget ka na ngayon — but no worries, kaya natin i-adjust! 💪',
      "Ay, lampas na sa budget! Let's see where we can cut back. 📊",
      'Budget exceeded — susunod na buwan mas maingat tayo! 🎯',
    ],
    PesoContext.goalMilestone100: [
      'GOAL COMPLETE! 🏆 Grabe — nabuo mo na ang {goal}! Taas kamay!',
      '100% na si {goal}! Ikaw talaga — goal getter! 🎉',
      'NAKUHA MO NA! {goal} fully funded! Peso is SO proud of you! 🥹',
    ],
    PesoContext.badgeUnlock: [
      'Badge unlocked! 🏅 Galing mo — isa pang achievement nabuksan!',
      "New badge! You're leveling up sa financial game! 🎖️",
      'Achievement unlocked! Peso claps for you! 👏 Keep going!',
    ],
    PesoContext.weeklyReview: [
      "It's review time! Kumusta ang linggo mo financially? 📊",
      'Weekly check-in: handa ka na bang i-review ang spending mo? 🗓️',
      "One week done — let's see how you did! Peso's proud either way. 💚",
    ],
    PesoContext.bigExpense: [
      'Malaking gastos yan — ₱{amount}! Worth it ba? 🤔',
      "Big purchase logged! ₱{amount} — sana enjoy mo! 😄",
      'Grabe, ₱{amount}! Okay lang — basta naka-budget! 💪',
    ],
    PesoContext.recurringDue: [
      'May recurring na due na! Huwag kalimutan bayaran. 🔁',
      "Recurring bill reminder! Check ka muna bago malate. 📅",
      'Due na ang recurring — Peso reminds you! 💡',
    ],
    PesoContext.savingsStreak: [
      'Savings streak! 💰 Consistent ka sa pag-iimpok — amazing!',
      "You're on a savings roll! Keep it going! 🔥",
      'Walang praning sa savings — steady ka! 🌱 Galing!',
    ],
    PesoContext.debtPaid: [
      'Utang paid off! 🎉 Pakiramdam mo ba yung relief? Grabe!',
      "Debt cleared! One less thing to worry about — Peso celebrates! 💚",
      'Bayad na! 🏆 Debt-free on that one — you did it!',
    ],
    PesoContext.backupReminder: [
      "Don't forget to backup your data! 🔒 Safety first!",
      'Backup mo na ang data mo — Peso worries about data loss! 😬',
      'Ilang linggo na walang backup — kaya mo naman mag-backup ngayon? 💾',
    ],
    PesoContext.aiRateLimit: [
      "Konting pahinga lang — AI limit reached for now. Try ulit mamaya! ⏳",
      "Daily AI limit hit! Rest muna si Peso — babalik agad! 😄",
      "Rate limit reached. Balik tayo mamaya — promise! 🙏",
    ],
    PesoContext.receiptScanned: [
      'Receipt scanned! 🧾 Easy logging — love the tech life!',
      "OCR done! Items extracted — no manual typing needed! 📷",
      "Scanned and logged! Mabilis lang 'yan with Peso! ✅",
    ],
    PesoContext.voiceLogged: [
      'Voice logged! 🎙️ Madali lang magsalita kaysa mag-type, diba?',
      "Expense logged via voice! Peso hears you loud and clear! 🎤",
      'Voice entry done! Salamat sa pagsasabi! 🗣️',
    ],
    PesoContext.ocrSuccess: [
      'OCR success! 📷 All text extracted — nice and clean!',
      'Receipt text naka-capture na! Ayos! 🧾 Peso approves.',
      'OCR done perfectly! Lahat ng items nakuha! ✅',
    ],
    PesoContext.exportDone: [
      'Export complete! 📤 Your data is ready to share!',
      "Data exported! Handa na — padala mo na kung kailangan! 💾",
      'Export done! Salamat sa pag-backup ng data mo! ✅',
    ],
    PesoContext.newBudgetPeriod: [
      "Bagong budget period! 🗓️ Fresh start — let's crush it!",
      "New month, new budget! Handa ka na ba? 💪",
      'New budget period starts now! Peso is excited for you! 🎯',
    ],
    PesoContext.paydayReminder: [
      'Payday na! 💸 Huwag kalimutang i-allocate ang budget mo agad!',
      "It's payday! Allot first, spend after — Peso's golden rule! 🏆",
      'Sweldo na! 🎉 Set aside savings agad bago pa maubos! 💰',
    ],
    PesoContext.billOverdue: [
      'May overdue na bill! ⚠️ Bayad na bago lumaki ang interest!',
      "Bill overdue alert! Huwag hayaang lumaki pa — Peso nag-aalala! 😬",
      'Overdue bill detected! Check mo na — Peso reminds you! 📅',
    ],
    PesoContext.appBirthday: [
      "Happy SmartSpend Anniversary! 🎂 Salamat sa trust mo sa Peso!",
      "It's our app birthday! 🥳 One more year of tracking together — grabe!",
      "Anniversary natin! 🎉 Ikaw at Peso — financial partners forever! 💚",
    ],
    // ── Idle / screen-specific lines ─────────────────────────────────────
    PesoContext.idleHome: [
      'Kamusta ang budget mo ngayon? Tap me to ask! 💬',
      "I can log expenses, check FHS, or answer anything! 😊",
      'Long-press me to go straight to AI chat! 💬',
    ],
    PesoContext.idleAnalytics: [
      'Want me to explain any chart? Just tap me! 📊',
      'Ask "where am I overspending?" for a deep dive! 💡',
      'Double-tap me for a quick summary! 📈',
    ],
    PesoContext.idleGoals: [
      'Set a goal with a deadline — I\'ll track it for you! 🎯',
      'Tip: Even small contributions add up fast! 💰',
      'Long-press me to chat about your goals! 💬',
    ],
    PesoContext.idleBudget: [
      'Set limits per category — I\'ll warn you at 80%! 💡',
      'Ask me "am I on track with my budgets?" anytime! 📊',
    ],
    PesoContext.idleDebts: [
      'Track what you owe AND what\'s owed to you! 💳',
      'Ask me "how much do I owe in total?" anytime! 💬',
    ],
    PesoContext.idleRecurring: [
      'Add Netflix, GCash load, Meralco — I\'ll remind you! 🔁',
      'Tap Log All Due to record all overdue items at once! ✅',
    ],
    PesoContext.scrolledFar: [
      'Still scrolling? I\'ll wait! 😄',
      'Found what you were looking for? 🔍',
    ],
    PesoContext.holdGreeting: [
      'Ay, hawak mo ako nang matagal! 😄 Sige, papasok tayo sa AI chat!',
      'Long press detected! Opening Peso AI... 💬',
    ],
  };
}
