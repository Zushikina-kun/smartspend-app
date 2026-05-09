import 'package:intl/intl.dart';

class PredictService {
  /// Predicts next month's spending based on average of past months.
  /// Falls back to current total * 1.1 if not enough history.
  static double predictMonthly(List<Map<String, dynamic>> expenses) {
    if (expenses.isEmpty) return 0;

    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);

    // Group by month
    final monthlyTotals = <String, double>{};
    for (final e in expenses) {
      try {
        final date = DateTime.parse(e['date'] as String? ?? '');
        final key = DateFormat('yyyy-MM').format(date);
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + (e['amount'] as num);
      } catch (_) {}
    }

    // Get current month spending and days elapsed
    final currentMonthTotal = monthlyTotals[currentMonth] ?? 0;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final daysRemaining = daysInMonth - daysPassed;

    if (monthlyTotals.length < 2) {
      // Not enough history — project from daily average only if we have 3+ days
      if (daysPassed >= 3 && currentMonthTotal > 0) {
        final dailyAvg = currentMonthTotal / daysPassed;
        return currentMonthTotal + (dailyAvg * daysRemaining);
      }
      // Too early in the month to project reliably — return 0 to hide the card
      return 0;
    }

    // Average of past complete months (exclude current month)
    final pastMonths = monthlyTotals.entries
        .where((e) => e.key != currentMonth)
        .map((e) => e.value)
        .toList();

    if (pastMonths.isEmpty) {
      if (daysPassed >= 3 && currentMonthTotal > 0) {
        final dailyAvg = currentMonthTotal / daysPassed;
        return currentMonthTotal + (dailyAvg * daysRemaining);
      }
      return 0;
    }

    final avgPastMonth = pastMonths.reduce((a, b) => a + b) / pastMonths.length;

    // Project current month: already spent + (daily avg × remaining days)
    // Daily avg is weighted: 60% current month pace, 40% historical average
    final currentDailyPace =
        daysPassed > 0 ? currentMonthTotal / daysPassed : 0;
    final historicalDailyAvg = avgPastMonth / daysInMonth;
    final projectedDailyRate =
        (currentDailyPace * 0.6) + (historicalDailyAvg * 0.4);

    return currentMonthTotal + (projectedDailyRate * daysRemaining);
  }

  /// Returns category-level predictions (reserved for future use)
  static Map<String, double> predictByCategory(
      List<Map<String, dynamic>> expenses) {
    final catTotals = <String, double>{};
    for (final e in expenses) {
      final cat = e['category'] as String? ?? 'Others';
      catTotals[cat] = (catTotals[cat] ?? 0) + (e['amount'] as num);
    }
    return catTotals.map((k, v) => MapEntry(k, v * 1.1));
  }

  /// Long-range forecast: projects total spending for 3, 6, and 12 months ahead.
  /// Uses the weighted daily rate from predictMonthly() as the monthly base.
  /// Returns a map of {months_ahead: projected_cumulative_total}.
  static Map<int, double> predictLongRange(
      List<Map<String, dynamic>> expenses) {
    if (expenses.isEmpty) return {};

    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);

    // Build monthly totals
    final monthlyTotals = <String, double>{};
    for (final e in expenses) {
      try {
        final date = DateTime.parse(e['date'] as String? ?? '');
        final key = DateFormat('yyyy-MM').format(date);
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + (e['amount'] as num);
      } catch (_) {}
    }

    final pastMonths = monthlyTotals.entries
        .where((e) => e.key != currentMonth)
        .map((e) => e.value)
        .toList();

    if (pastMonths.isEmpty) return {};

    // Monthly average from history
    final avgMonthly = pastMonths.reduce((a, b) => a + b) / pastMonths.length;

    // Current month projected total
    final currentTotal = monthlyTotals[currentMonth] ?? 0;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day.clamp(1, daysInMonth);
    final currentDailyPace = daysPassed > 0 ? currentTotal / daysPassed : 0;
    final historicalDailyAvg = avgMonthly / daysInMonth;
    final projectedMonthly =
        (currentDailyPace * 0.6 + historicalDailyAvg * 0.4) * daysInMonth;

    // Project forward using projected monthly as the base
    final result = <int, double>{};
    for (final months in [3, 6, 12]) {
      result[months] = projectedMonthly * months;
    }
    return result;
  }
}
