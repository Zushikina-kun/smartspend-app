import 'dart:math';
import 'db_service.dart';
import '../models/expense.dart';

class ForecastService {
  /// Generates a 30-day cash flow forecast based on historical spending and recurring transactions
  /// Returns a map containing:
  /// - 'dailyBalances': List<Map> with 'date', 'balance', 'events' for each day
  /// - 'confidence': String ('High', 'Medium', 'Low')
  /// - 'confidenceScore': double (0-100)
  /// - 'keyDates': List<Map> with significant balance changes
  static Future<Map<String, dynamic>> generate30DayForecast({
    required double startingBalance,
  }) async {
    // Query last 60 days of expenses
    final now = DateTime.now();
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    final expenses = await _getExpensesSince(sixtyDaysAgo);

    // Calculate daily average spending by category
    final categoryAverages = _calculateCategoryAverages(expenses);
    final dailyAverageSpending = categoryAverages.values.fold<double>(
      0.0,
      (sum, avg) => sum + avg,
    );

    // Get recurring transactions
    final recurring = await DBService.getRecurring();

    // Generate 30-day projection
    final dailyBalances = <Map<String, dynamic>>[];
    double runningBalance = startingBalance;

    for (int day = 0; day < 30; day++) {
      final date = now.add(Duration(days: day));
      final dateStr = date.toIso8601String().substring(0, 10);

      // Start with average daily spending
      double dayChange = -dailyAverageSpending / 30;
      final events = <Map<String, String>>[];

      // Check for recurring transactions on this date
      for (final r in recurring) {
        final nextDate = r['next_date'] as String?;
        if (nextDate == null) continue;

        try {
          final recDate = DateTime.parse(nextDate);
          // Check if recurring item falls on this day (or month/day match for monthly)
          final frequency = r['frequency'] as String? ?? 'monthly';
          final isExpense = (r['is_expense'] as int? ?? 1) == 1;
          final amount = (r['amount'] as num).toDouble();
          final title = r['title'] as String? ?? 'Transaction';

          bool matchesDate = false;
          if (frequency == 'monthly') {
            // Monthly: match day of month
            matchesDate = date.day == recDate.day;
          } else if (frequency == 'weekly') {
            // Weekly: match day of week
            matchesDate = date.weekday == recDate.weekday;
          } else if (frequency == 'daily') {
            matchesDate = true;
          } else {
            // Default: exact date match
            matchesDate = dateStr == nextDate;
          }

          if (matchesDate) {
            if (isExpense) {
              dayChange -= amount;
              events.add({
                'type': 'bill',
                'title': title,
                'amount': '-${amount.toStringAsFixed(2)}',
              });
            } else {
              dayChange += amount;
              events.add({
                'type': 'income',
                'title': title,
                'amount': '+${amount.toStringAsFixed(2)}',
              });
            }
          }
        } catch (_) {
          // Skip invalid dates
        }
      }

      runningBalance += dayChange;

      dailyBalances.add({
        'date': dateStr,
        'balance': runningBalance,
        'change': dayChange,
        'events': events,
      });
    }

    // Calculate confidence
    final confidenceData = _calculateConfidence(expenses, now);

    // Identify key dates (significant balance changes)
    final keyDates = _identifyKeyDates(dailyBalances);

    return {
      'dailyBalances': dailyBalances,
      'confidence': confidenceData['level'],
      'confidenceScore': confidenceData['score'],
      'keyDates': keyDates,
      'dailyAverage': dailyAverageSpending / 30,
      'dataPoints': expenses.length,
    };
  }

  /// Fetches expenses since a given date
  static Future<List<Expense>> _getExpensesSince(DateTime since) async {
    final db = await DBService.getDB();
    final sinceStr = since.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'expenses',
      where: 'date >= ?',
      whereArgs: [sinceStr],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  /// Calculates average daily spending per category
  static Map<String, double> _calculateCategoryAverages(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
      categoryCounts[expense.category] =
          (categoryCounts[expense.category] ?? 0) + 1;
    }

    final categoryAverages = <String, double>{};
    for (final category in categoryTotals.keys) {
      categoryAverages[category] = categoryTotals[category]! / max(1, categoryCounts[category]!);
    }

    return categoryAverages;
  }

  /// Calculates confidence level based on data quality and volatility
  /// Returns 'High' (60+ days data, <20% volatility)
  ///         'Medium' (30-60 days OR 20-40% volatility)
  ///         'Low' (<30 days OR >40% volatility)
  static Map<String, dynamic> _calculateConfidence(
    List<Expense> expenses,
    DateTime referenceDate,
  ) {
    // Check data coverage (number of days with data)
    final uniqueDates = expenses.map((e) => e.date.substring(0, 10)).toSet();
    final daysCovered = uniqueDates.length;

    // Calculate spending volatility (coefficient of variation)
    if (expenses.isEmpty) {
      return {'level': 'Low', 'score': 0.0};
    }

    // Group by date and calculate daily totals
    final dailyTotals = <String, double>{};
    for (final expense in expenses) {
      final date = expense.date.substring(0, 10);
      dailyTotals[date] = (dailyTotals[date] ?? 0.0) + expense.amount;
    }

    final amounts = dailyTotals.values.toList();
    if (amounts.isEmpty) {
      return {'level': 'Low', 'score': 0.0};
    }

    final mean = amounts.fold<double>(0.0, (sum, a) => sum + a) / amounts.length;
    final variance = amounts.fold<double>(
          0.0,
          (sum, a) => sum + pow(a - mean, 2),
        ) /
        amounts.length;
    final stdDev = sqrt(variance);
    final coefficientOfVariation = mean > 0 ? (stdDev / mean) * 100 : 100.0;

    // Determine confidence level
    String level;
    double score;

    if (daysCovered >= 60 && coefficientOfVariation < 20) {
      level = 'High';
      score = 85.0 + min(15.0, (100 - coefficientOfVariation) / 5);
    } else if (daysCovered >= 30 && coefficientOfVariation < 40) {
      level = 'Medium';
      score = 50.0 + (daysCovered - 30) / 2 + (40 - coefficientOfVariation) / 2;
    } else if (daysCovered >= 30 || coefficientOfVariation < 40) {
      level = 'Medium';
      score = 50.0 + min(30.0, daysCovered.toDouble());
    } else {
      level = 'Low';
      score = min(49.0, daysCovered.toDouble() + (40 - coefficientOfVariation));
    }

    return {
      'level': level,
      'score': score.clamp(0.0, 100.0),
      'daysCovered': daysCovered,
      'volatility': coefficientOfVariation.toStringAsFixed(1),
    };
  }

  /// Identifies key dates with significant balance changes
  static List<Map<String, dynamic>> _identifyKeyDates(
    List<Map<String, dynamic>> dailyBalances,
  ) {
    final keyDates = <Map<String, dynamic>>[];

    for (int i = 0; i < dailyBalances.length; i++) {
      final day = dailyBalances[i];
      final balance = day['balance'] as double;
      final change = day['change'] as double;
      final events = day['events'] as List<Map<String, String>>;

      // Significant changes or negative balance
      if (change.abs() > 100 || balance < 0 || events.isNotEmpty) {
        final eventDescriptions = events.map((e) => e['title'] as String).toList();
        
        String reason;
        if (balance < 0) {
          reason = 'Balance goes negative';
        } else if (change < -100) {
          reason = eventDescriptions.isNotEmpty
              ? eventDescriptions.join(', ')
              : 'Large expense expected';
        } else if (change > 100) {
          reason = eventDescriptions.isNotEmpty
              ? eventDescriptions.join(', ')
              : 'Income expected';
        } else {
          reason = eventDescriptions.join(', ');
        }

        keyDates.add({
          'date': day['date'],
          'balance': balance,
          'change': change,
          'reason': reason,
          'isNegative': balance < 0,
        });
      }
    }

    return keyDates;
  }
}
