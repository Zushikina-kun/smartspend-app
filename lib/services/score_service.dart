import '../models/budget.dart';
import 'db_service.dart';
import 'package:flutter/material.dart' show DateUtils;

// Gap DB setting keys — defined here so both ScoreService and
// StartupAlertsService can use them without creating a circular import.
// ScoreService reads them; StartupAlertsService writes them.
const kGapPenaltyKey = 'gap_penalty_days';
const kGapCleanKey = 'gap_clean_days';

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
    // Lightweight mode: when income/wallet tracking is off
    bool lightweightMode = false,
    double spendingLimit = 0, // period limit set by user
    String spendingLimitPeriod = 'monthly',
  }) {
    if (lightweightMode) {
      return _computeLightweight(expenses,
          budgets: budgets,
          spendingLimit: spendingLimit,
          spendingLimitPeriod: spendingLimitPeriod)['score'] as int;
    }
    return _compute(expenses,
        budgets: budgets, monthlyIncome: monthlyIncome)['score'] as int;
  }

  static List<Map<String, dynamic>> getBreakdown(
    List<Map<String, dynamic>> expenses, {
    List<Budget> budgets = const [],
    double monthlyIncome = 0,
    bool lightweightMode = false,
    double spendingLimit = 0,
    String spendingLimitPeriod = 'monthly',
  }) {
    if (lightweightMode) {
      return _computeLightweight(expenses,
              budgets: budgets,
              spendingLimit: spendingLimit,
              spendingLimitPeriod: spendingLimitPeriod)['breakdown']
          as List<Map<String, dynamic>>;
    }
    return _compute(expenses,
            budgets: budgets, monthlyIncome: monthlyIncome)['breakdown']
        as List<Map<String, dynamic>>;
  }

  // ── LIGHTWEIGHT MODE FHS (no income/wallet tracking) ─────────────────────
  //
  // When income_wallet_mode is OFF the user just wants to track spending habits.
  // The 4 components are redesigned to only use spending data:
  //
  // Component 1 — Spending Restraint (25 pts)
  //   Has the user stayed within their self-set spending limit this period?
  //   If no limit set: partial credit based on Want/Need ratio.
  //
  // Component 2 — Logging Consistency (25 pts)
  //   Logged days / active days in period (same formula as full mode).
  //
  // Component 3 — Category Balance (25 pts)
  //   No single category should dominate (> 60% of total spend is unbalanced).
  //
  // Component 4 — Habit Streak (25 pts)
  //   Consecutive days with at least one expense logged up to today.
  //
  static Map<String, dynamic> _computeLightweight(
    List<Map<String, dynamic>> expenses, {
    List<Budget> budgets = const [],
    double spendingLimit = 0,
    String spendingLimitPeriod = 'monthly',
  }) {
    final breakdown = <Map<String, dynamic>>[];

    if (expenses.isEmpty) {
      breakdown.add({
        'reason': 'No expenses recorded yet — start logging to see your score',
        'points': 0,
        'component': 'all',
      });
      return {'score': 50, 'breakdown': breakdown};
    }

    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final daysPassed = now.day.clamp(1, daysInMonth);

    // ── COMPONENT 1: SPENDING RESTRAINT (25 pts) ─────────────────────────────
    double comp1 = 25.0;
    String comp1Reason;
    if (spendingLimit > 0) {
      final totalSpent = expenses.fold(0.0, (s, e) => s + (e['amount'] as num));
      final ratio = totalSpent / spendingLimit;
      // Full 25 pts at ≤80% of limit; scales to 0 at 2× the limit
      comp1 =
          ((1.0 - ((ratio - 0.8) / 1.2).clamp(0.0, 1.0)) * 25).clamp(0.0, 25.0);
      if (ratio <= 0.8) {
        comp1Reason =
            'Spending within limit ✓ (${(ratio * 100).toStringAsFixed(0)}% of $spendingLimitPeriod limit)';
      } else if (ratio <= 1.0) {
        comp1Reason =
            'Approaching $spendingLimitPeriod limit — ${(ratio * 100).toStringAsFixed(0)}% used';
      } else {
        comp1Reason =
            '$spendingLimitPeriod limit exceeded by ${((ratio - 1) * 100).toStringAsFixed(0)}%';
      }
    } else {
      // No limit set — use Want/Need ratio as proxy
      double wantTotal = 0, needTotal = 0;
      for (final e in expenses) {
        final amt = (e['amount'] as num).toDouble();
        if ((e['is_want'] as int? ?? 0) == 1)
          wantTotal += amt;
        else
          needTotal += amt;
      }
      final total = wantTotal + needTotal;
      final wantRatio = total > 0 ? wantTotal / total : 0.0;
      // 25 pts at ≤30% wants; scales to 10 pts at 70% wants
      comp1 = ((1.0 - ((wantRatio - 0.3) / 0.4).clamp(0.0, 1.0)) * 15 + 10)
          .clamp(10.0, 25.0);
      comp1Reason = total > 0
          ? 'Wants: ${(wantRatio * 100).toStringAsFixed(0)}% of spending (set a limit for a better score)'
          : 'Set a spending limit to track restraint';
    }
    breakdown.add({
      'reason': comp1Reason,
      'points': comp1.round(),
      'component': 'spending_restraint',
    });

    // ── COMPONENT 2: LOGGING CONSISTENCY (25 pts) ────────────────────────────
    double comp2 = 25.0;
    String comp2Reason;
    final loggedDays = expenses
        .map((e) {
          try {
            return (e['date'] as String).substring(0, 10);
          } catch (_) {
            return '';
          }
        })
        .where((d) => d.isNotEmpty)
        .toSet()
        .length;
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
    if (loggedDays > 0 && activeDays > loggedDays * 2) {
      activeDays = loggedDays * 2;
    }
    final consistencyRatio = (loggedDays / activeDays).clamp(0.0, 1.0);
    comp2 = consistencyRatio * 25;
    comp2Reason = loggedDays >= activeDays
        ? 'Logging every active day ✓'
        : 'Logged $loggedDays of $activeDays days';
    breakdown.add({
      'reason': comp2Reason,
      'points': comp2.round(),
      'component': 'logging_consistency',
    });

    // ── COMPONENT 3: CATEGORY BALANCE (25 pts) ───────────────────────────────
    double comp3 = 25.0;
    String comp3Reason;
    final catTotals = <String, double>{};
    final totalAll = expenses.fold(0.0, (s, e) => s + (e['amount'] as num));
    for (final e in expenses) {
      final cat = e['category'] as String? ?? 'Others';
      catTotals[cat] = (catTotals[cat] ?? 0) + (e['amount'] as num);
    }
    if (totalAll > 0 && catTotals.isNotEmpty) {
      final topEntry =
          catTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      final topRatio = topEntry.value / totalAll;
      // Full 25 pts at ≤40% concentration; scales to 0 at 100%
      comp3 = ((1.0 - ((topRatio - 0.4) / 0.6).clamp(0.0, 1.0)) * 25)
          .clamp(0.0, 25.0);
      if (topRatio <= 0.4) {
        comp3Reason = 'Spending well balanced across categories ✓';
      } else if (topRatio <= 0.6) {
        comp3Reason =
            '${topEntry.key} is ${(topRatio * 100).toStringAsFixed(0)}% of spending — consider diversifying';
      } else {
        comp3Reason =
            '${topEntry.key} dominates at ${(topRatio * 100).toStringAsFixed(0)}% — very concentrated';
      }
    } else {
      comp3Reason = 'Not enough data yet';
    }
    breakdown.add({
      'reason': comp3Reason,
      'points': comp3.round(),
      'component': 'category_balance',
    });

    // ── COMPONENT 4: HABIT STREAK (25 pts) ───────────────────────────────────
    double comp4 = 25.0;
    String comp4Reason;
    // Count consecutive days ending today (or yesterday) with at least one log
    final loggedSet = expenses
        .map((e) {
          try {
            return DateTime.parse((e['date'] as String).substring(0, 10));
          } catch (_) {
            return null;
          }
        })
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    int streak = 0;
    var checkDay = DateTime(now.year, now.month, now.day);
    // If nothing logged today, start from yesterday
    if (!loggedSet.contains(checkDay)) {
      checkDay = checkDay.subtract(const Duration(days: 1));
    }
    while (loggedSet.contains(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }
    // Full 25 pts at 14+ day streak; scales proportionally below
    comp4 = (streak / 14.0).clamp(0.0, 1.0) * 25;
    if (streak == 0) {
      comp4Reason = 'No recent streak — log today to start one';
    } else if (streak >= 14) {
      comp4Reason = '$streak-day logging streak ✓';
    } else {
      comp4Reason = '$streak-day streak (14 days = full score)';
    }
    breakdown.add({
      'reason': comp4Reason,
      'points': comp4.round(),
      'component': 'habit_streak',
    });

    // ── BUDGET ADHERENCE BONUS ────────────────────────────────────────────────
    // Even in lightweight mode, category budgets still add value.
    // If the user has set budgets, replace Category Balance with Budget Adherence
    // for a more precise score (same formula as full mode).
    if (budgets.isNotEmpty) {
      int onBudget = 0, overBudget = 0;
      for (final b in budgets) {
        final spent = catTotals[b.category] ?? 0;
        final limit = b.isPercentage ? 0.0 : b.amount;
        if (limit <= 0) continue;
        if (spent <= limit)
          onBudget++;
        else
          overBudget++;
      }
      final valid = onBudget + overBudget;
      if (valid > 0) {
        final adherence = onBudget / valid;
        // Blend with category balance (budgets = more authoritative)
        comp3 = adherence * 25;
        breakdown[2] = {
          'reason': overBudget == 0
              ? 'All $onBudget budget${onBudget == 1 ? '' : 's'} on track ✓'
              : '$overBudget of $valid budgets exceeded',
          'points': comp3.round(),
          'component': 'budget_adherence',
        };
      }
    }

    final rawScore = (comp1 + comp2 + comp3 + comp4).round().clamp(0, 100);
    return {'score': rawScore, 'breakdown': breakdown};
  }

  static Map<String, dynamic> _compute(
    List<Map<String, dynamic>> expenses, {
    List<Budget> budgets = const [],
    double monthlyIncome = 0,
  }) {
    final breakdown = <Map<String, dynamic>>[];

    if (expenses.isEmpty) {
      breakdown.add({
        'reason':
            'No expenses recorded yet — start logging to see your real score',
        'points': 0,
        'component': 'all',
      });
      return {'score': 50, 'breakdown': breakdown};
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

  /// Apply gap-awareness adjustment to the score.
  ///
  /// When a user answers the logging-gap prompt, StartupAlertsService records
  /// either a penalty (had transactions but forgot) or a bonus (clean days).
  ///
  ///   Gap penalty  — each unlogged-but-spent day subtracts up to 3 pts,
  ///                  capped at −15 pts total so one bad week doesn't crater
  ///                  an otherwise healthy score.
  ///
  ///   Clean-day bonus — each confirmed no-spend day adds up to 2 pts to the
  ///                     logging consistency component, capped at +10 pts.
  ///                     Rewarding genuine frugal stretches makes the score
  ///                     reflect reality instead of penalising users who simply
  ///                     had nothing to log.
  ///
  /// This is applied on top of applyWarningDecay().
  static Future<int> applyGapAdjustment(int baseScore) async {
    try {
      final penaltyDays =
          int.tryParse(await DBService.getSetting(kGapPenaltyKey) ?? '0') ?? 0;
      final bonusDays =
          int.tryParse(await DBService.getSetting(kGapCleanKey) ?? '0') ?? 0;

      // 3 pts per unlogged-but-spent day, max −15
      final penalty = (penaltyDays * 3).clamp(0, 15);
      // 2 pts per confirmed clean day, max +10
      final bonus = (bonusDays * 2).clamp(0, 10);

      return (baseScore - penalty + bonus).clamp(0, 100);
    } catch (_) {
      return baseScore;
    }
  }

  /// Convenience: apply both decay and gap adjustment in one call.
  /// Use this everywhere instead of calling applyWarningDecay() alone.
  static Future<int> applyAllAdjustments(int rawScore) async {
    final afterDecay = await applyWarningDecay(rawScore);
    return applyGapAdjustment(afterDecay);
  }

  // ── DATA CONSISTENCY GUARDRAILS ───────────────────────────────────────────

  /// Validate an expense before it is saved to the database.
  /// Returns a [ValidationResult] with any warnings or a blocking error.
  ///
  /// Checks performed:
  ///  1. Amount sanity — negative, zero, or implausibly large amounts
  ///  2. Date sanity  — future dates more than 1 day ahead; dates before 2000
  ///  3. Duplicate detection — same item name + same amount within ±2 minutes
  ///     OR same item name + amount logged on the same date within the last
  ///     60 seconds (catches AI double-fire race condition)
  ///  4. Category mismatch — obvious mismatches (e.g. "jeepney" in Shopping)
  static ExpenseValidation validateExpense({
    required String itemName,
    required double amount,
    required String category,
    required String date,
    required List<Map<String, dynamic>> recentExpenses,
    String? time,
  }) {
    final warnings = <String>[];
    String? blockingError;

    // 1. Amount sanity
    if (amount <= 0) {
      blockingError = 'Amount must be greater than zero.';
    } else if (amount > 500000) {
      warnings.add(
          'Amount ₱${amount.toStringAsFixed(0)} is very high — double-check before saving.');
    } else if (amount < 1) {
      warnings.add('Amount ₱$amount looks unusually small.');
    }

    // 2. Date sanity
    try {
      final expenseDate = DateTime.parse(date.substring(0, 10));
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      if (expenseDate.isAfter(tomorrow)) {
        warnings.add('Date $date is in the future — is that correct?');
      }
      if (expenseDate.year < 2000) {
        warnings.add('Date $date seems too far in the past.');
      }
    } catch (_) {
      warnings.add('Date format "$date" could not be parsed.');
    }

    // 3. Duplicate detection
    // Fast path: look for exact (name + amount + date) within recent expenses
    final nameLower = itemName.trim().toLowerCase();
    final dateKey = date.substring(0, 10);
    final duplicates = recentExpenses.where((e) {
      final eName = (e['item_name'] as String? ?? '').trim().toLowerCase();
      final eAmt = (e['amount'] as num?)?.toDouble() ?? 0;
      final eDate = (e['date'] as String? ?? '').substring(
          0,
          10 < (e['date'] as String? ?? '').length
              ? 10
              : (e['date'] as String? ?? '').length);
      return eName == nameLower &&
          (eAmt - amount).abs() < 0.01 &&
          eDate == dateKey;
    }).toList();

    if (duplicates.isNotEmpty) {
      warnings.add(
          'Possible duplicate: "${itemName}" ₱${amount.toStringAsFixed(0)} was already logged on $dateKey. Log again?');
    }

    // 4. Obvious category mismatch hints
    final lowerName = itemName.toLowerCase();
    if (category == 'Shopping' &&
        (lowerName.contains('jeep') ||
            lowerName.contains('fare') ||
            lowerName.contains('bus') ||
            lowerName.contains('tricycle'))) {
      warnings.add(
          'Category "Shopping" may be wrong for "$itemName" — did you mean Transportation?');
    }
    if (category == 'Food' &&
        (lowerName.contains('load') ||
            lowerName.contains('bill') ||
            lowerName.contains('electric') ||
            lowerName.contains('internet'))) {
      warnings.add(
          'Category "Food" may be wrong for "$itemName" — did you mean Bills?');
    }

    return ExpenseValidation(
      isValid: blockingError == null,
      blockingError: blockingError,
      warnings: warnings,
    );
  }

  /// Cross-check that wallet balances are consistent with logged income minus
  /// logged expenses. Returns a discrepancy amount (positive = more spent than
  /// income on record; negative = unaccounted balance surplus).
  ///
  /// A large positive discrepancy suggests unreported income.
  /// A large negative discrepancy suggests unreported expenses or wallet top-ups.
  static double computeBalanceDiscrepancy({
    required double totalWalletBalance,
    required double totalIncome,
    required double totalSpent,
  }) {
    // Expected balance = income received − expenses logged
    final expected = totalIncome - totalSpent;
    return totalWalletBalance - expected;
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

  /// Get all financial milestones the user has achieved
  static List<Map<String, dynamic>> getMilestones(
    List<Map<String, dynamic>> expenses, {
    List<Budget> budgets = const [],
    double monthlyIncome = 0,
    int currentFHS = 50,
  }) {
    final milestones = <Map<String, dynamic>>[];

    if (expenses.isEmpty) return milestones;

    final totalSpent =
        expenses.fold<double>(0, (sum, e) => sum + (e['amount'] as num));
    final totalSaved = monthlyIncome > 0 ? monthlyIncome - totalSpent : 0;

    // Savings milestones
    if (totalSaved >= 100000)
      milestones.add({
        'icon': '💯',
        'title': '100K Savings Club',
        'description': 'Saved ₱100,000 or more',
        'category': 'savings'
      });
    if (totalSaved >= 50000)
      milestones.add({
        'icon': '💰',
        'title': '50K Milestone',
        'description': 'Saved ₱50,000 or more',
        'category': 'savings'
      });
    if (totalSaved >= 10000)
      milestones.add({
        'icon': '🎯',
        'title': '10K Goal',
        'description': 'Reached ₱10,000 in savings',
        'category': 'savings'
      });
    if (totalSaved >= 5000)
      milestones.add({
        'icon': '📈',
        'title': '5K Achievement',
        'description': 'Accumulated ₱5,000 in savings',
        'category': 'savings'
      });
    if (totalSaved >= 1000)
      milestones.add({
        'icon': '🌟',
        'title': '₱1K Saved',
        'description': 'First ₱1,000 milestone reached',
        'category': 'savings'
      });

    // Savings rate milestones
    if (monthlyIncome > 0) {
      final savingsRate = totalSaved / monthlyIncome;
      if (savingsRate >= 0.5)
        milestones.add({
          'icon': '🚀',
          'title': '50% Savings Rate',
          'description': 'Saving half your income — incredible!',
          'category': 'rate'
        });
      if (savingsRate >= 0.3)
        milestones.add({
          'icon': '✨',
          'title': '30% Savings Rate',
          'description': 'You\'re saving 30% of income',
          'category': 'rate'
        });
      if (savingsRate >= 0.2)
        milestones.add({
          'icon': '💎',
          'title': '20% Savings Rate',
          'description': 'Hitting the 20% savings target',
          'category': 'rate'
        });
    }

    // FHS milestones
    if (currentFHS >= 90)
      milestones.add({
        'icon': '👑',
        'title': 'Financial Champion',
        'description': 'FHS score 90+ — elite financial health',
        'category': 'fhs'
      });
    if (currentFHS >= 80)
      milestones.add({
        'icon': '🏆',
        'title': 'Excellent Health',
        'description': 'FHS score 80+ — strong financial habits',
        'category': 'fhs'
      });
    if (currentFHS >= 70)
      milestones.add({
        'icon': '⭐',
        'title': 'Good Financial Health',
        'description': 'FHS score 70+ — on the right track',
        'category': 'fhs'
      });
    if (currentFHS >= 60)
      milestones.add({
        'icon': '🌱',
        'title': 'Building Momentum',
        'description': 'FHS score 60+ — steady progress',
        'category': 'fhs'
      });

    // Spending discipline
    if (totalSpent > 0 && monthlyIncome > 0) {
      final wantSpending = expenses
          .where((e) => e['is_want'] == true || e['is_want'] == 1)
          .fold<double>(0, (sum, e) => sum + (e['amount'] as num));
      final wantRatio = wantSpending / totalSpent;
      if (wantRatio <= 0.1)
        milestones.add({
          'icon': '🎖️',
          'title': 'Minimalist',
          'description': 'Only 10% of spending on wants',
          'category': 'discipline'
        });
    }

    // Logging streak (simple: if has expenses across multiple days)
    if (expenses.length >= 30)
      milestones.add({
        'icon': '📝',
        'title': '30 Expenses Logged',
        'description': 'Consistent tracking habit',
        'category': 'logging'
      });
    if (expenses.length >= 50)
      milestones.add({
        'icon': '📋',
        'title': '50 Expenses Logged',
        'description': 'Dedicated financial tracker',
        'category': 'logging'
      });

    return milestones;
  }
}

// ── EXPENSE VALIDATION RESULT ─────────────────────────────────────────────────

/// Result of ScoreService.validateExpense().
/// [isValid]       — false means a blocking error; don't save.
/// [blockingError] — human-readable reason (null when isValid == true).
/// [warnings]      — non-blocking advisory messages to show the user.
class ExpenseValidation {
  final bool isValid;
  final String? blockingError;
  final List<String> warnings;

  const ExpenseValidation({
    required this.isValid,
    this.blockingError,
    this.warnings = const [],
  });

  bool get hasWarnings => warnings.isNotEmpty;
}
