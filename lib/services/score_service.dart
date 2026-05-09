import '../models/budget.dart';
import 'db_service.dart';
import 'package:flutter/material.dart' show DateUtils;

/// Financial Health Score — 4-component weighted formula (25% each)
///
/// Component 1 — Savings Rate (25 pts)
///   Measures: actual savings vs 20% of income target
///   Formula: 25 × min(1, savingsRate / 0.20)
///   savingsRate = (income − totalSpent) / income
///   Full 25 pts when saving ≥20% of income; scales down proportionally below that
///
/// Component 2 — Overspend Control (25 pts)
///   Measures: proportion of days where spending was within daily budget
///   Formula: 25 × (1 − overDays / periodDays)
///   overDays = days where daily spending exceeded (income / daysInMonth)
///   Full 25 pts when no days exceeded; 0 pts when every day exceeded
///
/// Component 3 — Budget Adherence (25 pts)
///   Measures: percentage of budget categories that stayed within limit
///   Formula: 25 × (onBudgetCategories / totalBudgetCategories)
///   Full 25 pts when all budgets on track; 0 pts when all exceeded
///   If no budgets set: 25 pts (not penalized for not having budgets)
///
/// Component 4 — Logging Consistency (25 pts)
///   Measures: regularity of expense entries vs active days in period
///   Formula: 25 × (loggedDays / activeDays)
///   activeDays = days elapsed since first expense or start of month
///   Full 25 pts when logging every day; scales down proportionally
///
/// Final score = sum of 4 components, clamped 0–100
/// Decay: if budget warnings were ignored (spending continued after alert),
///        score loses 5 pts per day, max 3 days (−15 pts total)

class ScoreService {
  static int calculateScore(
    List<Map<String, dynamic>> expenses, {
    List<Budget> budgets = const [],
    double monthlyIncome = 0,
  }) {
    return _compute(expenses,
        budgets: budgets, monthlyIncome: monthlyIncome)['score'] as int;
  }

  static List<Map<String, dynamic>> getBreakdown(
    List<Map<String, dynamic>> expenses, {
    List<Budget> budgets = const [],
    double monthlyIncome = 0,
  }) {
    return _compute(expenses,
            budgets: budgets, monthlyIncome: monthlyIncome)['breakdown']
        as List<Map<String, dynamic>>;
  }

  static Map<String, dynamic> _compute(
    List<Map<String, dynamic>> expenses, {
    List<Budget> budgets = const [],
    double monthlyIncome = 0,
  }) {
    final breakdown = <Map<String, dynamic>>[];

    if (expenses.isEmpty) {
      breakdown.add({
        'reason': 'No expenses recorded yet',
        'points': 0,
        'component': 'all',
      });
      return {'score': 100, 'breakdown': breakdown};
    }

    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final daysPassed = now.day.clamp(1, daysInMonth);

    // ── COMPONENT 1: SAVINGS RATE (25 pts) ───────────────────────────────────
    double comp1 = 25.0;
    String comp1Reason;
    if (monthlyIncome > 0) {
      final totalSpent =
          expenses.fold(0.0, (sum, e) => sum + (e['amount'] as num));
      final savingsRate = (monthlyIncome - totalSpent) / monthlyIncome;
      // Scale: 25 pts at ≥20% savings, proportional below
      final savingsScore = (savingsRate / 0.20).clamp(0.0, 1.0) * 25;
      comp1 = savingsScore;
      if (savingsRate >= 0.20) {
        comp1Reason = "Savings rate ≥20% of income ✓";
      } else if (savingsRate > 0) {
        comp1Reason =
            "Savings rate ${(savingsRate * 100).toStringAsFixed(1)}% (target: 20%)";
      } else {
        comp1Reason = "Spending exceeds income — no savings";
      }
    } else {
      // No income set — give partial credit based on spending level
      final totalSpent =
          expenses.fold(0.0, (sum, e) => sum + (e['amount'] as num));
      comp1 = totalSpent < 5000
          ? 20.0
          : totalSpent < 10000
              ? 15.0
              : 10.0;
      comp1Reason = "Set your income for accurate savings tracking";
    }
    breakdown.add({
      'reason': comp1Reason,
      'points': comp1.round(),
      'component': 'savings_rate',
    });

    // ── COMPONENT 2: OVERSPEND CONTROL (25 pts) ──────────────────────────────
    double comp2 = 25.0;
    String comp2Reason;
    if (monthlyIncome > 0 && daysPassed > 0) {
      final dailyBudget = monthlyIncome / daysInMonth;
      // Group expenses by date
      final dailySpend = <String, double>{};
      for (final e in expenses) {
        final date = (e['date'] as String).substring(0, 10);
        dailySpend[date] = (dailySpend[date] ?? 0) + (e['amount'] as num);
      }
      // Count days where spending exceeded daily budget
      int overDays = 0;
      for (final entry in dailySpend.entries) {
        if (entry.value > dailyBudget) overDays++;
      }
      final activeDays = dailySpend.length.clamp(1, daysPassed);
      final overRatio = overDays / activeDays;
      comp2 = (1.0 - overRatio).clamp(0.0, 1.0) * 25;
      if (overDays == 0) {
        comp2Reason = "No days exceeded daily budget ✓";
      } else {
        comp2Reason =
            "$overDays of $activeDays logged days exceeded daily budget";
      }
    } else {
      comp2 = 20.0; // partial credit when no income set
      comp2Reason = "Set your income to track daily overspend";
    }
    breakdown.add({
      'reason': comp2Reason,
      'points': comp2.round(),
      'component': 'overspend_control',
    });

    // ── COMPONENT 3: BUDGET ADHERENCE (25 pts) ───────────────────────────────
    double comp3 = 25.0;
    String comp3Reason;
    if (budgets.isNotEmpty) {
      final catTotals = <String, double>{};
      for (final e in expenses) {
        final cat = e['category'] as String;
        catTotals[cat] = (catTotals[cat] ?? 0) + (e['amount'] as num);
      }
      int onBudget = 0;
      int overBudget = 0;
      for (final b in budgets) {
        final spent = catTotals[b.category] ?? 0;
        // Resolve percentage-based budgets to their actual ₱ amount.
        // b.amount is 0 for % budgets — use percentageValue × income instead.
        final budgetLimit = b.isPercentage
            ? (b.percentageValue / 100.0 * monthlyIncome)
            : b.amount;
        if (budgetLimit <= 0) continue; // skip unconfigured budgets
        if (spent <= budgetLimit) {
          onBudget++;
        } else {
          overBudget++;
        }
      }
      final validBudgets = onBudget + overBudget;
      if (validBudgets == 0) {
        comp3 = 25.0;
        comp3Reason = "No budgets set (add budgets for better tracking)";
      } else {
        final adherenceRatio = onBudget / validBudgets;
        comp3 = adherenceRatio * 25;
        if (overBudget == 0) {
          comp3Reason =
              "All $onBudget budget${onBudget == 1 ? '' : 's'} on track ✓";
        } else {
          comp3Reason =
              "$overBudget of $validBudgets budget${validBudgets == 1 ? '' : 's'} exceeded";
        }
      }
    } else {
      comp3 = 25.0; // not penalized for not having budgets
      comp3Reason = "No budgets set (add budgets for better tracking)";
    }
    breakdown.add({
      'reason': comp3Reason,
      'points': comp3.round(),
      'component': 'budget_adherence',
    });

    // ── COMPONENT 4: LOGGING CONSISTENCY (25 pts) ────────────────────────────
    double comp4 = 25.0;
    String comp4Reason;
    if (expenses.isNotEmpty) {
      // Count unique days with at least one expense logged
      final loggedDays = expenses
          .map((e) => (e['date'] as String).substring(0, 10))
          .toSet()
          .length;
      // Active days = span from first expense to today (more accurate than full month)
      int activeDays = daysPassed.clamp(1, daysInMonth);
      try {
        final dates = expenses
            .map((e) => (e['date'] as String).substring(0, 10))
            .toList()
          ..sort();
        final firstDate = DateTime.parse(dates.first);
        final span = now.difference(firstDate).inDays + 1;
        activeDays = span.clamp(1, daysPassed);
      } catch (_) {}

      // Backdated bulk-entry fairness: if the user logged expenses on many
      // different past dates in a short time (retroactive entry), the raw
      // loggedDays/activeDays ratio would be very low even though they did
      // log consistently. Cap activeDays at 2× loggedDays so retroactive
      // entry doesn't tank the score unfairly.
      if (loggedDays > 0 && activeDays > loggedDays * 2) {
        activeDays = loggedDays * 2;
      }

      final consistencyRatio = (loggedDays / activeDays).clamp(0.0, 1.0);
      comp4 = consistencyRatio * 25;
      if (loggedDays >= activeDays) {
        comp4Reason = "Logging every active day ✓";
      } else {
        comp4Reason = "Logged $loggedDays of $activeDays days";
      }
    } else {
      comp4 = 0.0;
      comp4Reason = "No expenses logged yet";
    }
    breakdown.add({
      'reason': comp4Reason,
      'points': comp4.round(),
      'component': 'logging_consistency',
    });

    // ── FINAL SCORE ───────────────────────────────────────────────────────────
    final rawScore = comp1 + comp2 + comp3 + comp4;
    final score = rawScore.round().clamp(0, 100);

    return {'score': score, 'breakdown': breakdown};
  }

  /// Apply warning decay: if budget warnings were ignored (spending continued
  /// in an over-budget category after a warning was issued), reduce score by
  /// 5 pts per consecutive day, max 3 days (−15 pts total).
  ///
  /// Called after calculateScore() to apply the decay penalty.
  /// Returns the adjusted score.
  static Future<int> applyWarningDecay(int baseScore) async {
    try {
      final decayDaysStr = await DBService.getSetting('warning_decay_days');
      final decayDays = int.tryParse(decayDaysStr ?? '0') ?? 0;
      if (decayDays <= 0) return baseScore;
      final penalty = (decayDays.clamp(0, 3) * 5);
      return (baseScore - penalty).clamp(0, 100);
    } catch (_) {
      return baseScore;
    }
  }

  /// Check if any budget warnings should trigger decay.
  /// Call this on app open after loading expenses and budgets.
  /// If a budget was exceeded yesterday AND spending continued today in that
  /// category, increment the decay counter.
  static Future<void> checkAndUpdateDecay({
    required List<Map<String, dynamic>> expenses,
    required List<Budget> budgets,
  }) async {
    if (budgets.isEmpty) {
      await DBService.setSetting('warning_decay_days', '0');
      return;
    }

    final now = DateTime.now();
    final today = now.toIso8601String().substring(0, 10);
    final lastDecayCheck = await DBService.getSetting('last_decay_check');

    // Only run once per day
    if (lastDecayCheck == today) return;
    await DBService.setSetting('last_decay_check', today);

    // Fetch income once — used for percentage-based budget resolution
    final income = await DBService.getMonthlyIncome();

    // Check if any budget is exceeded
    final catTotals = <String, double>{};
    for (final e in expenses) {
      final cat = e['category'] as String;
      catTotals[cat] = (catTotals[cat] ?? 0) + (e['amount'] as num);
    }

    bool anyExceeded = false;
    for (final b in budgets) {
      final spent = catTotals[b.category] ?? 0;
      // Handle percentage-based budgets — use actual calculated amount
      final budgetAmount =
          b.isPercentage ? (b.percentageValue / 100.0 * income) : b.amount;
      if (spent > budgetAmount) {
        anyExceeded = true;
        break;
      }
    }

    if (anyExceeded) {
      // Increment decay counter (max 3)
      final current = int.tryParse(
              await DBService.getSetting('warning_decay_days') ?? '0') ??
          0;
      final newVal = (current + 1).clamp(0, 3);
      await DBService.setSetting('warning_decay_days', newVal.toString());
    } else {
      // Reset decay when all budgets are back on track
      await DBService.setSetting('warning_decay_days', '0');
    }
  }

  /// Get the current decay days count (0–3)
  static Future<int> getDecayDays() async {
    final val = await DBService.getSetting('warning_decay_days');
    return int.tryParse(val ?? '0') ?? 0;
  }

  /// Compute a spending personality label based on expense history and savings rate.
  /// Returns a (emoji, label, description) tuple.
  static (String, String, String) getSpendingPersonality({
    required List<Map<String, dynamic>> expenses,
    required double monthlyIncome,
    required double totalSpent,
  }) {
    if (expenses.isEmpty || monthlyIncome <= 0) {
      return (
        '🌱',
        'New Tracker',
        'Keep logging to discover your spending style!'
      );
    }

    // Compute category totals
    final catTotals = <String, double>{};
    for (final e in expenses) {
      final cat = e['category'] as String? ?? 'Others';
      catTotals[cat] = (catTotals[cat] ?? 0) + (e['amount'] as num);
    }
    final sorted = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCat = sorted.isNotEmpty ? sorted.first.key : 'Others';
    final topAmt = sorted.isNotEmpty ? sorted.first.value : 0.0;
    final topPct = totalSpent > 0 ? topAmt / totalSpent : 0.0;

    // Savings rate
    final savingsRate = totalSpent < monthlyIncome
        ? (monthlyIncome - totalSpent) / monthlyIncome
        : 0.0;

    // Want vs Need ratio
    double wantTotal = 0;
    for (final e in expenses) {
      if ((e['is_want'] as int? ?? 0) == 1) {
        wantTotal += (e['amount'] as num).toDouble();
      }
    }
    final wantRatio = totalSpent > 0 ? wantTotal / totalSpent : 0.0;

    // Personality logic
    if (savingsRate >= 0.3) {
      return (
        '💰',
        'Consistent Saver',
        'You save 30%+ of your income. Keep it up!'
      );
    }
    if (topCat == 'Food' && topPct >= 0.4) {
      return (
        '🍜',
        'Foodie Spender',
        'Food is your biggest expense. Consider meal prepping to save more.'
      );
    }
    if (topCat == 'Entertainment' && topPct >= 0.3) {
      return (
        '🎮',
        'Entertainment Lover',
        'You spend a lot on fun. Balance it with savings goals.'
      );
    }
    if (topCat == 'Shopping' && topPct >= 0.3) {
      return (
        '🛍️',
        'Shopaholic',
        'Shopping is your top category. Try the 24-hour rule before buying.'
      );
    }
    if (topCat == 'Transportation' && topPct >= 0.3) {
      return (
        '🚌',
        'Commuter',
        'Transport takes a big chunk. Consider carpooling or route optimization.'
      );
    }
    if (topCat == 'Education' && topPct >= 0.25) {
      return (
        '📚',
        'Invested Learner',
        'You invest in education. That pays off long-term.'
      );
    }
    if (wantRatio <= 0.15 && savingsRate >= 0.15) {
      return (
        '🎯',
        'Disciplined Spender',
        'You keep wants low and save consistently. Great habits!'
      );
    }
    if (wantRatio >= 0.5) {
      return (
        '🎉',
        'Impulse Buyer',
        'More than half your spending is on wants. Try tagging expenses to stay aware.'
      );
    }
    if (savingsRate >= 0.2) {
      return (
        '📈',
        'Smart Budgeter',
        'You save 20%+ of income. You\'re on the right track.'
      );
    }
    return (
      '⚖️',
      'Balanced Spender',
      'Your spending is fairly balanced across categories.'
    );
  }
}
