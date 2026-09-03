import '../services/db_service.dart';
import '../services/currency_service.dart';

/// Centralizes all UX/behavioral feedback logic:
/// - Plain-language FHS score narratives (Item 2)
/// - Proactive praise/celebration detection (Item 1)
/// - Purchase commentary after logging (Item 3)
/// - FMS next-step guidance (Item 7)
/// - "What did I do right/wrong" coach report (Item 4)
///
/// None of these require an AI call — everything is computed from local data.
class BehavioralFeedbackService {
  // ─────────────────────────────────────────────────────────────────────────
  // ITEM 2 — Plain-language FHS narrative
  // Returns a 1–2 sentence plain-English summary of why the score is what it is.
  // Computed entirely from the getBreakdown() output — no API call needed.
  // ─────────────────────────────────────────────────────────────────────────
  static String scoreSummaryNarrative(
    int score,
    List<Map<String, dynamic>> breakdown,
    bool lightweightMode,
  ) {
    if (breakdown.isEmpty) return '';

    // Sort components by points ascending — weakest first
    final sorted = List<Map<String, dynamic>>.from(breakdown)
      ..sort((a, b) => (a['points'] as int).compareTo(b['points'] as int));

    final weakest = sorted.first;
    final weakPts = weakest['points'] as int;
    final weakComp = weakest['component'] as String? ?? '';

    // Find strongest component
    final strongest = sorted.last;
    final strongPts = strongest['points'] as int;
    final strongComp = strongest['component'] as String? ?? '';

    // Count how many are "good" (≥20/25)
    final goodCount = breakdown.where((c) => (c['points'] as int) >= 20).length;
    final allGood = goodCount == breakdown.length;
    final noneGood = goodCount == 0;

    // Score tier
    final tier = score >= 80
        ? 'great'
        : score >= 70
            ? 'good'
            : score >= 60
                ? 'fair'
                : 'low';

    // Component labels for human-readable output
    String _compLabel(String comp) {
      switch (comp) {
        case 'savings_rate':
          return 'savings rate';
        case 'overspend_control':
          return 'daily overspend control';
        case 'budget_adherence':
          return 'budget adherence';
        case 'logging_consistency':
          return 'logging consistency';
        case 'spending_restraint':
          return 'spending restraint';
        case 'category_balance':
          return 'category balance';
        case 'habit_streak':
          return 'habit streak';
        default:
          return comp.replaceAll('_', ' ');
      }
    }

    String _praise(String comp) {
      switch (comp) {
        case 'savings_rate':
          return "You're saving well";
        case 'overspend_control':
          return "You're staying within your daily budget";
        case 'budget_adherence':
          return "Your budgets are on track";
        case 'logging_consistency':
          return "You're logging consistently";
        case 'spending_restraint':
          return "You're controlling your spending";
        case 'category_balance':
          return "Your spending is well-balanced";
        case 'habit_streak':
          return "You're building a strong tracking habit";
        default:
          return "You're doing well";
      }
    }

    String _fix(String comp) {
      switch (comp) {
        case 'savings_rate':
          return "your savings rate needs work — try saving even a small amount each week";
        case 'overspend_control':
          return "some days are exceeding your daily budget — check which days and what you bought";
        case 'budget_adherence':
          return "some budget categories are over their limits";
        case 'logging_consistency':
          return "you're missing some days of logging — even one entry a day helps";
        case 'spending_restraint':
          return "spending is pushing your set limit";
        case 'category_balance':
          return "one category is dominating your spending";
        case 'habit_streak':
          return "your tracking streak is short — log something every day to build it";
        default:
          return "there's room to improve";
      }
    }

    if (score >= 80) {
      if (allGood) {
        return "You're doing great across all areas — keep this up! 🎉";
      }
      final weakLabel = _compLabel(weakComp);
      return "${_praise(strongComp)}. "
          "The one area still holding back a perfect score is your $weakLabel — ${_fix(weakComp)}.";
    }

    if (noneGood) {
      return "Your score is ${tier == 'fair' ? 'fair' : 'low'} — "
          "the main thing to fix is your ${_compLabel(weakComp)}: ${_fix(weakComp)}. "
          "Small improvements each day add up fast.";
    }

    // Mixed — some good, weakest dragging it down
    return "${_praise(strongComp)}, which is great. "
        "What's pulling your score down is your ${_compLabel(weakComp)} — ${_fix(weakComp)}.";
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ITEM 1 — Proactive praise / celebration detection
  // Returns a CelebrationEvent if something worth celebrating happened,
  // otherwise null. Compares current score to previous score in history.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<CelebrationEvent?> checkForCelebration({
    required int currentScore,
    required int logStreak,
    required List<Map<String, dynamic>> breakdown,
  }) async {
    // Check 1: Score improved by ≥5 pts since the previous recorded snapshot
    try {
      final history = await DBService.getScoreHistory(days: 7);
      if (history.length >= 2) {
        // previous = second-most-recent distinct-day entry
        final prevEntry = history.reversed.skip(1).firstOrNull;
        if (prevEntry != null) {
          final prevScore = prevEntry['score'] as int;
          final diff = currentScore - prevScore;
          if (diff >= 5) {
            return CelebrationEvent(
              emoji: '🎉',
              title: 'Score improved!',
              message:
                  'Your Financial Health Score went up $diff points — nice work! Keep the momentum going.',
              type: CelebrationEventType.scoreImproved,
            );
          }
        }
      }
    } catch (_) {}

    // Check 2: All budgets on track (budget_adherence = 25/25)
    final budgetComp = breakdown
        .where((c) => c['component'] == 'budget_adherence')
        .firstOrNull;
    if (budgetComp != null && (budgetComp['points'] as int) == 25) {
      // Only praise if score is decent (prevents praising when everything else is terrible)
      if (currentScore >= 55) {
        // Only show this once per day to avoid spam — use a DB setting flag
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final praiseKey = 'praised_budget_on_track_$today';
        final alreadyPraised = await DBService.getSetting(praiseKey);
        if (alreadyPraised == null) {
          await DBService.setSetting(praiseKey, 'true');
          return CelebrationEvent(
            emoji: '✅',
            title: 'All budgets on track!',
            message:
                'Every category budget is within its limit this month. Consistent budgeting like this is what builds real financial health.',
            type: CelebrationEventType.allBudgetsOnTrack,
          );
        }
      }
    }

    // Check 3: Logging streak milestone (3, 7, 14, 30 days)
    const milestones = [30, 14, 7, 3];
    for (final m in milestones) {
      if (logStreak == m) {
        final milestoneKey = 'praised_streak_$m';
        final already = await DBService.getSetting(milestoneKey);
        // Check if we've crossed this specific milestone before
        final prevMilestone = await DBService.getSetting('${milestoneKey}_date');
        final today = DateTime.now().toIso8601String().substring(0, 10);
        if (prevMilestone != today) {
          await DBService.setSetting('${milestoneKey}_date', today);
          final streakMessages = {
            3: 'You\'ve logged expenses 3 days in a row — you\'re building a real habit! 🔥',
            7: 'A full week of logging! Consistent tracking is the #1 habit of people who improve their finances. 💪',
            14: '14-day logging streak! Studies show people who track daily save 15–20% more. You\'re one of them. 🏅',
            30: '30 days of consistent logging! That\'s exceptional dedication — your financial awareness is at a new level. 🏆',
          };
          return CelebrationEvent(
            emoji: m >= 14 ? '🏅' : '🔥',
            title: '$m-Day Logging Streak!',
            message: streakMessages[m] ?? 'Great logging streak!',
            type: CelebrationEventType.streakMilestone,
          );
        }
        break; // only trigger once per check
      }
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ITEM 3 — Purchase commentary
  // Returns a PurchaseCommentary describing the logged expense in context.
  // Called immediately after an expense is saved.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<PurchaseCommentary?> getPurchaseCommentary({
    required String itemName,
    required String category,
    required double amount,
    required bool isWant,
    required String date,
  }) async {
    try {
      final currentMonth = date.substring(0, 7);
      final allExpenses = await DBService.getExpenses();
      final today = date.substring(0, 10);

      // Check 1: Is this a repeated category today?
      final todayInCategory = allExpenses
          .where((e) =>
              e.date.substring(0, 10) == today && e.category == category)
          .toList();
      final todayCount = todayInCategory.length;

      // Check 2: Budget status for this category
      final budgets = await DBService.getBudgets();
      final budget = budgets.where((b) => b.category == category).firstOrNull;
      String? budgetContext;
      double? remaining;
      if (budget != null && budget.amount > 0) {
        final catMonthly = allExpenses
            .where((e) =>
                e.date.startsWith(currentMonth) && e.category == category)
            .fold<double>(0, (s, e) => s + e.amount);
        remaining = budget.amount - catMonthly;
        final ratio = catMonthly / budget.amount;
        if (ratio >= 1.0) {
          budgetContext =
              'Your $category budget is now exceeded (${CurrencyService.format(catMonthly)} / ${CurrencyService.format(budget.amount)}).';
        } else if (ratio >= 0.8) {
          budgetContext =
              '${CurrencyService.format(remaining)} left in your $category budget this month.';
        }
      }

      // Check 3: Same item logged before at different price?
      final sameItem = allExpenses
          .where((e) =>
              e.itemName.toLowerCase() == itemName.toLowerCase() &&
              e.amount != amount &&
              e.date.substring(0, 10) != today)
          .toList();
      double? previousPrice;
      if (sameItem.isNotEmpty) previousPrice = sameItem.first.amount;

      // Build commentary
      String message;
      String emoji;
      CommentaryTone tone;

      if (budgetContext != null && remaining != null && remaining < 0) {
        // Over budget — supportive, not scolding
        emoji = '💡';
        tone = CommentaryTone.nudge;
        final goals = await DBService.getGoals();
        final topGoal = goals
            .where((g) =>
                (g['current_amount'] as num) < (g['target_amount'] as num))
            .firstOrNull;
        if (topGoal != null) {
          final goalName = topGoal['name'] as String;
          final over = (-remaining).toStringAsFixed(0);
          message =
              '₱$over over your $category budget. Every peso over is ₱$over less toward "$goalName" — try to stay within limits tomorrow.';
        } else {
          message =
              '$budgetContext Going over budget happens — the key is catching it early and adjusting for the rest of the month.';
        }
      } else if (todayCount >= 3 && category == 'Food') {
        emoji = '🍽️';
        tone = CommentaryTone.observe;
        message =
            "That's your ${_ordinal(todayCount)} food expense today — totaling ${CurrencyService.format(todayInCategory.fold<double>(0, (s, e) => s + e.amount))} on food so far.";
      } else if (isWant && amount >= 200) {
        emoji = '💭';
        tone = CommentaryTone.nudge;
        message =
            "Logged as Want — good self-awareness. Tagging Wants helps you see your discretionary spending clearly.";
      } else if (previousPrice != null && amount > previousPrice * 1.15) {
        emoji = '📈';
        tone = CommentaryTone.observe;
        final pctUp =
            ((amount / previousPrice - 1) * 100).toStringAsFixed(0);
        message =
            "$itemName was ${CurrencyService.format(previousPrice)} last time — up $pctUp% today. Worth noting for your budget.";
      } else if (budgetContext != null && remaining != null && remaining >= 0) {
        // Approaching limit — encouraging
        emoji = '📊';
        tone = CommentaryTone.encourage;
        message = budgetContext;
      } else {
        // Default: encouraging log confirmation
        emoji = '✅';
        tone = CommentaryTone.praise;
        message = "Logged! Every expense recorded keeps your Financial Health Score accurate.";
      }

      return PurchaseCommentary(
        emoji: emoji,
        message: message,
        tone: tone,
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ITEM 5 — Smart encouragement for negative decisions
  // Returns a supportive (not scolding) message when a budget is exceeded.
  // Used to replace the generic "budget alert" in-app card on home screen.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<String> getSupportiveBudgetMessage(
    String category,
    double spent,
    double budget,
  ) async {
    final over = spent - budget;
    final goals = await DBService.getGoals();
    final topGoal = goals
        .where((g) =>
            (g['current_amount'] as num) < (g['target_amount'] as num))
        .firstOrNull;

    if (over > 0) {
      // Over budget
      if (topGoal != null) {
        final goalName = topGoal['name'] as String;
        return "💡 $category is ${CurrencyService.format(over)} over — that's ${CurrencyService.format(over)} less toward \"$goalName\". You can still adjust the rest of the month.";
      }
      return "💡 $category is ${CurrencyService.format(over)} over budget — happens to everyone. Check what pushed it over and adjust going forward.";
    } else {
      // Approaching (80%+)
      final remaining = budget - spent;
      final pct = (spent / budget * 100).toStringAsFixed(0);
      return "📊 $category is at $pct% of budget — ${CurrencyService.format(remaining)} left. You're on track to stay within limits.";
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ITEM 7 — FMS next-step guidance
  // Returns a single actionable "what to do next" string based on the weakest
  // FMS component. Shown below the FMS score in Analytics and Profile.
  // ─────────────────────────────────────────────────────────────────────────
  static String getFmsNextStep(List<Map<String, dynamic>> fmsBreakdown) {
    if (fmsBreakdown.isEmpty) return '';
    // Find weakest FMS component
    final sorted = List<Map<String, dynamic>>.from(fmsBreakdown)
      ..sort((a, b) => (a['points'] as int).compareTo(b['points'] as int));
    final weakest = sorted.first;
    final pts = weakest['points'] as int;
    final label = weakest['label'] as String? ?? '';

    if (pts >= 22) {
      return '🎯 You\'re on top of everything — keep logging daily to maintain your score.';
    }

    if (label.toLowerCase().contains('logging')) {
      return '📝 Biggest gain available: log at least one expense every day. Even ₱0 "no-spend" days count.';
    }
    if (label.toLowerCase().contains('budget')) {
      return '💰 Add category budgets (Food, Transport, etc.) to unlock full budget adherence scoring — Settings → Budgets.';
    }
    if (label.toLowerCase().contains('goal')) {
      return '🎯 Create a savings goal and add some progress to it — even ₱1 activates goal tracking scoring.';
    }
    if (label.toLowerCase().contains('data') ||
        label.toLowerCase().contains('complete')) {
      return '📋 Set your monthly income amount to unlock income-based scoring — Profile → Edit → Income.';
    }
    return '💡 Improve your ${label.toLowerCase()} to raise your Management Score.';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ITEM 4 — "What did I do right/wrong?" coach report
  // Splits FHS components into two lists: strengths and improvements.
  // ─────────────────────────────────────────────────────────────────────────
  static CoachReport buildCoachReport(List<Map<String, dynamic>> breakdown) {
    final strengths = <String>[];
    final improvements = <String>[];

    for (final item in breakdown) {
      final pts = item['points'] as int;
      final comp = item['component'] as String? ?? '';
      final reason = item['reason'] as String? ?? '';
      final isUnmeasured = item['unmeasured'] == true;

      if (isUnmeasured) continue; // skip components without data

      if (pts >= 20) {
        // Strength
        switch (comp) {
          case 'savings_rate':
            strengths.add('✅ Savings rate — $reason');
            break;
          case 'overspend_control':
            strengths.add('✅ Daily spending control — $reason');
            break;
          case 'budget_adherence':
            strengths.add('✅ Budget adherence — $reason');
            break;
          case 'logging_consistency':
            strengths.add('✅ Logging habit — $reason');
            break;
          case 'spending_restraint':
            strengths.add('✅ Spending restraint — $reason');
            break;
          case 'category_balance':
            strengths.add('✅ Category balance — $reason');
            break;
          case 'habit_streak':
            strengths.add('✅ Habit streak — $reason');
            break;
          default:
            strengths.add('✅ $reason');
        }
      } else {
        // Improvement
        String tip;
        switch (comp) {
          case 'savings_rate':
            tip = pts == 0
                ? 'Set your income first, then try saving even 5% more each month.'
                : 'Aim for 20% savings rate — currently tracking below target.';
            break;
          case 'overspend_control':
            tip =
                'Check which specific days exceeded your daily budget and what was bought. Reducing just 1–2 overspend days lifts this significantly.';
            break;
          case 'budget_adherence':
            tip = pts == 0
                ? 'Create budgets for your top categories (Food, Transport) to start earning points here.'
                : 'One or more categories exceeded their budget — focus on the highest overspend category first.';
            break;
          case 'logging_consistency':
            tip =
                'Log at least one expense every day you spend money. Missing days drags this score down — even a ₱0 note counts.';
            break;
          case 'spending_restraint':
            tip =
                'Set a spending limit in Settings to accurately measure restraint, then try to stay within it.';
            break;
          case 'category_balance':
            tip =
                'One category is taking more than 60% of total spending. Try spreading it across more categories.';
            break;
          case 'habit_streak':
            tip =
                'Log every day to build your streak — full points at 14 consecutive days.';
            break;
          default:
            tip = reason;
        }
        improvements.add('🔧 ${_compTitle(comp)} — $tip');
      }
    }

    return CoachReport(strengths: strengths, improvements: improvements);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────
  static String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  static String _compTitle(String comp) {
    switch (comp) {
      case 'savings_rate':
        return 'Savings Rate';
      case 'overspend_control':
        return 'Overspend Control';
      case 'budget_adherence':
        return 'Budget Adherence';
      case 'logging_consistency':
        return 'Logging Consistency';
      case 'spending_restraint':
        return 'Spending Restraint';
      case 'category_balance':
        return 'Category Balance';
      case 'habit_streak':
        return 'Habit Streak';
      default:
        return comp.replaceAll('_', ' ');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

enum CelebrationEventType {
  scoreImproved,
  allBudgetsOnTrack,
  streakMilestone,
}

class CelebrationEvent {
  final String emoji;
  final String title;
  final String message;
  final CelebrationEventType type;

  const CelebrationEvent({
    required this.emoji,
    required this.title,
    required this.message,
    required this.type,
  });
}

enum CommentaryTone { praise, encourage, nudge, observe }

class PurchaseCommentary {
  final String emoji;
  final String message;
  final CommentaryTone tone;

  const PurchaseCommentary({
    required this.emoji,
    required this.message,
    required this.tone,
  });
}

class CoachReport {
  final List<String> strengths;
  final List<String> improvements;
  const CoachReport({required this.strengths, required this.improvements});
  bool get isEmpty => strengths.isEmpty && improvements.isEmpty;
}
