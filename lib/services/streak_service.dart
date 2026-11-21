import '../models/expense.dart';
import 'db_service.dart';

class WeeklyChallenge {
  final String title;
  final double progress; // 0.0 to 1.0
  final bool completed;
  final String progressLabel;
  const WeeklyChallenge({
    required this.title,
    required this.progress,
    required this.completed,
    required this.progressLabel,
  });
}

class StreakService {
  /// Count consecutive days ending today that have at least one expense.
  static Future<int> getLoggingStreak() async {
    final expenses = await DBService.getExpenses();
    final datesWithExpenses = <String>{};
    for (final e in expenses) {
      datesWithExpenses.add(e.date.substring(0, 10));
    }
    final now = DateTime.now();
    int streak = 0;
    for (int d = 0; d < 365; d++) {
      final day = DateTime(now.year, now.month, now.day - d);
      final key = day.toIso8601String().substring(0, 10);
      if (datesWithExpenses.contains(key)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Count consecutive days ending today where daily spending < daily budget.
  static Future<int> getSavingsStreak() async {
    final expenses = await DBService.getExpenses();
    final budgets = await DBService.getBudgets();

    double dailyBudget;
    if (budgets.isNotEmpty) {
      final total = budgets.fold<double>(0, (s, b) => s + b.amount);
      dailyBudget = total / 30;
    } else {
      final income = await DBService.getMonthlyIncome();
      dailyBudget = income > 0 ? income / 30 : 0;
    }

    if (dailyBudget <= 0) return 0;

    // Build a map of daily totals
    final dailyTotals = <String, double>{};
    for (final e in expenses) {
      final key = e.date.substring(0, 10);
      dailyTotals[key] = (dailyTotals[key] ?? 0) + e.amount;
    }

    final now = DateTime.now();
    int streak = 0;
    for (int d = 0; d < 365; d++) {
      final day = DateTime(now.year, now.month, now.day - d);
      final key = day.toIso8601String().substring(0, 10);
      final spent = dailyTotals[key] ?? 0;
      if (spent < dailyBudget) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Return 3 weekly challenges based on this week's (Mon–today) expenses.
  static Future<List<WeeklyChallenge>> getWeeklyChallenges() async {
    final expenses = await DBService.getExpenses();

    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    final thisWeekExpenses = expenses.where((e) {
      final d = DateTime.tryParse(e.date.substring(0, 10));
      return d != null && !d.isBefore(weekStart) && !d.isAfter(now);
    }).toList();

    // Challenge 1: Log every day this week
    final daysLogged = thisWeekExpenses
        .map((e) => e.date.substring(0, 10))
        .toSet()
        .length;
    final c1Progress = (daysLogged / 7).clamp(0.0, 1.0);
    final c1 = WeeklyChallenge(
      title: 'Log every day this week',
      progress: c1Progress,
      completed: daysLogged >= 7,
      progressLabel: '$daysLogged/7 days',
    );

    // Challenge 2: Keep Food under ₱500 this week
    final foodSpend = thisWeekExpenses
        .where((e) => e.category.toLowerCase().contains('food'))
        .fold<double>(0, (s, e) => s + e.amount);
    final c2Progress = ((500 - foodSpend) / 500).clamp(0.0, 1.0);
    final c2 = WeeklyChallenge(
      title: 'Keep Food under ₱500 this week',
      progress: c2Progress,
      completed: foodSpend <= 500,
      progressLabel: '₱${foodSpend.toStringAsFixed(0)} / ₱500',
    );

    // Challenge 3: No Entertainment this week
    final entSpend = thisWeekExpenses
        .where((e) => e.category.toLowerCase().contains('entertainment'))
        .fold<double>(0, (s, e) => s + e.amount);
    final c3Progress = entSpend == 0 ? 1.0 : 0.0;
    final c3 = WeeklyChallenge(
      title: 'No Entertainment this week',
      progress: c3Progress,
      completed: entSpend == 0,
      progressLabel:
          entSpend == 0 ? 'Clean! 🎉' : '₱${entSpend.toStringAsFixed(0)} spent',
    );

    return [c1, c2, c3];
  }
}
