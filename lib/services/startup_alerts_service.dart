import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_service.dart';
import 'currency_service.dart';
import 'score_service.dart';

// ── LOGGING GAP MODEL ────────────────────────────────────────────────────────

/// Represents a single gap period (one or more consecutive days without a log).
class LoggingGap {
  final DateTime startDate;
  final DateTime endDate;
  final int days;

  LoggingGap({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  String get label {
    final fmt = DateFormat('MMM d');
    if (days == 1) return fmt.format(startDate);
    return '${fmt.format(startDate)} – ${fmt.format(endDate)}';
  }
}

/// Result of a user's answer about a gap period.
class GapResponse {
  final LoggingGap gap;
  final bool
      hadTransactions; // true = had but forgot to log; false = truly no spending
  final String?
      roughDescription; // optional rough description if hadTransactions

  GapResponse({
    required this.gap,
    required this.hadTransactions,
    this.roughDescription,
  });
}

/// Alert data model for on-open notifications
class StartupAlert {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  StartupAlert({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.onAction,
  });
}

/// Service that checks for important alerts when the app opens.
/// Shows a modal card if: bills overdue, budget exceeded, debt due,
/// FHS dropped significantly, idle wallets, etc.
/// Also detects multi-day logging gaps and records the user's response
/// so the Financial Health Score can reflect reality accurately.
class StartupAlertsService {
  static const _prefKeyLastAlert = 'last_startup_alert_date';

  // ── GAP DETECTION KEYS ───────────────────────────────────────────────────
  // Gap threshold: only ask if the user hasn't logged for this many days
  static const _gapThresholdDays = 1;
  // Max gap size we'll ask about (don't interrogate 3-month blackouts)
  static const _maxGapDaysToAsk = 30;
  // DB setting keys — imported from score_service.dart top-level constants
  // so both services share the same key names without circular imports.
  static const prefKeyGapPenalty = kGapPenaltyKey;
  static const prefKeyGapBonus = kGapCleanKey;
  static const _prefKeyLastGapCheck = 'last_gap_check_date';

  /// Check all alert conditions and return any that should be shown.
  /// Returns empty list if no alerts or already shown today.
  static Future<List<StartupAlert>> checkAlerts() async {
    // Don't repeat alerts on the same day
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastShown = await DBService.getSetting(_prefKeyLastAlert);
    if (lastShown == today) return [];

    final alerts = <StartupAlert>[];
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

    try {
      // 0. Income sanity check — alert if monthly income looks wrong (< ₱1,000)
      // Only fires when income/wallet tracking is actually ON.
      final income = await DBService.getMonthlyIncome();
      final incomeWalletModeOn = await DBService.getIncomeWalletMode();
      final tightest = await DBService.getTightestLimit();
      final spendLimit = tightest['limit'] as double;
      final spendPeriod = tightest['period'] as String;
      final incomeCheckKey = 'income_sanity_check';
      final lastIncomeCheck = await DBService.getSetting(incomeCheckKey);
      final thisMonth = DateFormat('yyyy-MM').format(DateTime.now());
      if (incomeWalletModeOn &&
          income > 0 &&
          income < 1000 &&
          lastIncomeCheck != thisMonth) {
        await DBService.setSetting(incomeCheckKey, thisMonth);
        alerts.add(StartupAlert(
          title: '💰 Income Looks Too Low',
          message:
              'Your monthly income is set to ₱${income.toStringAsFixed(0)}. '
              'That seems too low — your Financial Health Score (especially savings rate) '
              'may be inaccurate. Tap Profile → Income to update it.',
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.deepOrange,
        ));
      }

      // 1. Check for exceeded budgets
      final budgets = await DBService.getBudgets();
      final expenses = await DBService.getExpenses(month: currentMonth);
      final catSpent = <String, double>{};
      for (final e in expenses) {
        catSpent[e.category] = (catSpent[e.category] ?? 0) + e.amount;
      }
      final exceededBudgets = <String>[];
      for (final b in budgets) {
        final spent = catSpent[b.category] ?? 0;
        if (b.amount > 0 && spent > b.amount) {
          exceededBudgets.add(b.category);
        }
      }
      if (exceededBudgets.isNotEmpty) {
        alerts.add(StartupAlert(
          title: '🚨 Budget Exceeded',
          message:
              '${exceededBudgets.length} budget${exceededBudgets.length > 1 ? 's' : ''} exceeded: ${exceededBudgets.take(3).join(', ')}${exceededBudgets.length > 3 ? '...' : ''}',
          icon: Icons.warning_amber_rounded,
          color: Colors.red,
        ));
      }

      // 2. Check for overdue recurring bills
      final recurring = await DBService.getRecurring();
      final overdueBills = <String>[];
      for (final r in recurring) {
        final nextDate = r['next_date'] as String?;
        if (nextDate != null && nextDate.isNotEmpty) {
          try {
            final due = DateTime.parse(nextDate);
            if (due.isBefore(DateTime.now()) &&
                (r['is_expense'] as int? ?? 1) == 1) {
              overdueBills.add(r['title'] as String);
            }
          } catch (_) {}
        }
      }
      if (overdueBills.isNotEmpty) {
        alerts.add(StartupAlert(
          title: '📅 Overdue Bills',
          message:
              '${overdueBills.length} bill${overdueBills.length > 1 ? 's' : ''} overdue: ${overdueBills.take(3).join(', ')}',
          icon: Icons.receipt_long,
          color: Colors.orange,
        ));
      }

      // 3. Check for debts due within 3 days
      final debts = await DBService.getDebts();
      final urgentDebts = <String>[];
      for (final d in debts) {
        final dueDate = d['due_date'] as String?;
        final paid = (d['paid_amount'] as num?)?.toDouble() ?? 0;
        final total = (d['amount'] as num?)?.toDouble() ?? 0;
        if (dueDate != null && dueDate.isNotEmpty && paid < total) {
          try {
            final due = DateTime.parse(dueDate);
            final daysLeft = due.difference(DateTime.now()).inDays;
            if (daysLeft <= 3 && daysLeft >= -7) {
              urgentDebts.add(
                  '${d['person']} (${CurrencyService.format(total - paid)})');
            }
          } catch (_) {}
        }
      }
      if (urgentDebts.isNotEmpty) {
        alerts.add(StartupAlert(
          title: '💸 Debt Due Soon',
          message: urgentDebts.take(2).join(', '),
          icon: Icons.money_off,
          color: Colors.deepOrange,
        ));
      }

      // 4. Check FHS drop (compare to stored previous score)
      final prevScoreStr = await DBService.getSetting('prev_fhs_score');
      final expenseData = expenses
          .map((e) =>
              {'amount': e.amount, 'category': e.category, 'date': e.date})
          .toList();
      // income already loaded above in sanity check (reuse it here)
      final rawScore = ScoreService.calculateScore(
        expenseData,
        budgets: budgets,
        monthlyIncome: incomeWalletModeOn ? income : 0,
        lightweightMode: !incomeWalletModeOn,
        spendingLimit: spendLimit,
        spendingLimitPeriod: spendPeriod,
      );
      final currentScore = await ScoreService.applyAllAdjustments(rawScore);
      if (prevScoreStr != null) {
        final prevScore = int.tryParse(prevScoreStr) ?? currentScore;
        if (prevScore - currentScore >= 10) {
          alerts.add(StartupAlert(
            title: '📉 Health Score Dropped',
            message:
                'Your Financial Health Score dropped from $prevScore to $currentScore. Check your spending.',
            icon: Icons.trending_down,
            color: Colors.red,
          ));
        }
      }
      // Store current score for next comparison
      await DBService.setSetting('prev_fhs_score', currentScore.toString());

      // 5. Check for idle wallets + balance discrepancy
      final wallets = await DBService.getWallets();
      final totalWalletBalance =
          wallets.fold<double>(0, (s, w) => s + (w['balance'] as num));
      if (incomeWalletModeOn && totalWalletBalance > 5000) {
        // Check if any expenses logged in last 14 days
        final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
        final recentExpenses = expenses.where((e) {
          try {
            return DateTime.parse(e.date).isAfter(twoWeeksAgo);
          } catch (_) {
            return false;
          }
        }).toList();
        if (recentExpenses.isEmpty) {
          alerts.add(StartupAlert(
            title: '💤 Idle Money Detected',
            message:
                'You have ${CurrencyService.format(totalWalletBalance)} sitting idle for 14+ days. Consider savings or investments.',
            icon: Icons.savings_outlined,
            color: Colors.blue,
          ));
        }
      }

      // 5b. Balance discrepancy check (ScoreService.computeBalanceDiscrepancy)
      // If wallet total vs income−spent gap is > ₱2,000, surface it once/month.
      // Large positive = unrecorded income (wallets have more than expected).
      // Large negative = unrecorded expenses or missing wallet top-ups.
      if (incomeWalletModeOn && income > 0 && totalWalletBalance > 0) {
        try {
          final totalIncome = await DBService.getTotalIncome();
          final totalSpent = await DBService.getTotalSpent();
          final discrepancy = ScoreService.computeBalanceDiscrepancy(
            totalWalletBalance: totalWalletBalance,
            totalIncome: totalIncome,
            totalSpent: totalSpent,
          );
          final discrepancyKey = 'balance_discrepancy_check';
          final lastCheck = await DBService.getSetting(discrepancyKey);
          final thisMonthCheck = DateFormat('yyyy-MM').format(DateTime.now());
          if (discrepancy.abs() > 2000 && lastCheck != thisMonthCheck) {
            await DBService.setSetting(discrepancyKey, thisMonthCheck);
            final isPositive = discrepancy > 0;
            alerts.add(StartupAlert(
              title: isPositive
                  ? '📊 Unrecorded Income Detected'
                  : '📊 Balance Gap Detected',
              message: isPositive
                  ? 'Your wallets have ${CurrencyService.format(discrepancy.abs())} more than income−expenses suggests. Any income not yet logged?'
                  : 'Your wallets have ${CurrencyService.format(discrepancy.abs())} less than expected. Any expenses or transfers not logged?',
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.indigo,
            ));
          }
        } catch (_) {}
      }

      // 6. Check for overdue insurance premiums
      final policies = await DBService.getInsurancePolicies();
      final overduePolicies = <String>[];
      for (final p in policies) {
        final nextDue = p['next_due_date'] as String?;
        if (nextDue != null && nextDue.isNotEmpty) {
          try {
            if (DateTime.parse(nextDue).isBefore(DateTime.now())) {
              overduePolicies.add(p['name'] as String? ?? 'Policy');
            }
          } catch (_) {}
        }
      }
      if (overduePolicies.isNotEmpty) {
        alerts.add(StartupAlert(
          title: '🛡️ Insurance Premium Overdue',
          message:
              '${overduePolicies.length} premium${overduePolicies.length > 1 ? 's' : ''} overdue: ${overduePolicies.take(2).join(', ')}',
          icon: Icons.shield_outlined,
          color: Colors.purple,
        ));
      }

      // 7. Check for savings goals with deadline within 7 days
      final goals = await DBService.getGoals();
      final urgentGoals = <String>[];
      for (final g in goals) {
        final deadline = g['deadline'] as String?;
        final current = (g['current_amount'] as num?)?.toDouble() ?? 0;
        final target = (g['target_amount'] as num?)?.toDouble() ?? 1;
        if (deadline != null && deadline.isNotEmpty && current < target) {
          try {
            final daysLeft =
                DateTime.parse(deadline).difference(DateTime.now()).inDays;
            if (daysLeft <= 7 && daysLeft >= 0) {
              urgentGoals.add('${g['name']} ($daysLeft days left)');
            }
          } catch (_) {}
        }
      }
      if (urgentGoals.isNotEmpty) {
        alerts.add(StartupAlert(
          title: '🎯 Goal Deadline Near',
          message: urgentGoals.take(2).join(', '),
          icon: Icons.savings_outlined,
          color: Colors.amber,
        ));
      }
      // 8. Logging gap detection — ask about days with no entries
      // Only fires once per day (guarded by _prefKeyLastGapCheck).
      final gaps = await _detectLoggingGaps();
      if (gaps.isNotEmpty) {
        // Format a short description of the gaps found
        final gapLabels = gaps.take(3).map((g) => g.label).join(', ');
        final totalDays = gaps.fold<int>(0, (s, g) => s + g.days);
        alerts.add(StartupAlert(
          title: '📅 Missed Log Days',
          message: totalDays == 1
              ? 'No transactions logged on $gapLabels. Did you spend anything that day?'
              : 'No transactions logged on $gapLabels ($totalDays days total). Did you spend on those days?',
          icon: Icons.edit_calendar_outlined,
          color: Colors.teal,
          actionLabel: 'Review',
          // The onAction callback is wired in HomeScreen after the sheet is shown
        ));
      }
    } catch (_) {
      // Fail silently — alerts are non-critical
    }

    // Mark as shown today if we have alerts
    if (alerts.isNotEmpty) {
      await DBService.setSetting(_prefKeyLastAlert, today);
    }

    return alerts;
  }

  // ── GAP DETECTION HELPERS ────────────────────────────────────────────────

  /// Detect contiguous day ranges where no expense was logged.
  /// Returns gaps sorted newest-first, capped at 3 most recent actionable periods.
  static Future<List<LoggingGap>> _detectLoggingGaps() async {
    try {
      // Rate-limit: only run the gap check once per day
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final lastCheck = await DBService.getSetting(_prefKeyLastGapCheck);
      if (lastCheck == today) return [];
      await DBService.setSetting(_prefKeyLastGapCheck, today);

      final now = DateTime.now();
      // Only look back within current month + previous month
      final lookbackStart = DateTime(now.year, now.month - 1, 1);

      final allExpenses = await DBService.getExpenses();
      final loggedDates = allExpenses
          .map((e) {
            try {
              return DateTime.parse(e.date.substring(0, 10));
            } catch (_) {
              return null;
            }
          })
          .whereType<DateTime>()
          .where((d) => !d.isBefore(lookbackStart) && !d.isAfter(now))
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();

      // Don't interrogate brand-new users with no data
      if (loggedDates.isEmpty) return [];

      final earliest = loggedDates.reduce((a, b) => a.isBefore(b) ? a : b);
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      if (yesterday.isBefore(earliest)) return [];

      // Walk every day in the window, collect unlogged stretches
      final gaps = <LoggingGap>[];
      DateTime? gapStart;
      int gapDays = 0;

      for (var d = earliest;
          !d.isAfter(yesterday);
          d = d.add(const Duration(days: 1))) {
        final key = DateTime(d.year, d.month, d.day);
        if (!loggedDates.contains(key)) {
          gapStart ??= key;
          gapDays++;
        } else {
          if (gapStart != null && gapDays >= _gapThresholdDays) {
            gaps.add(LoggingGap(
              startDate: gapStart,
              endDate: key.subtract(const Duration(days: 1)),
              days: gapDays,
            ));
          }
          gapStart = null;
          gapDays = 0;
        }
      }
      // Close any trailing gap that runs up to yesterday
      if (gapStart != null && gapDays >= _gapThresholdDays) {
        gaps.add(LoggingGap(
          startDate: gapStart,
          endDate: yesterday,
          days: gapDays,
        ));
      }

      // Drop huge blackouts (e.g. before user started using the app)
      return gaps
          .where((g) => g.days <= _maxGapDaysToAsk)
          .toList()
          .reversed // newest first
          .take(3)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Public accessor — called by HomeScreen to show the interactive gap dialog.
  static Future<List<LoggingGap>> getLoggingGaps() => _detectLoggingGaps();

  /// Record the user's response to a gap inquiry so ScoreService can apply
  /// the appropriate penalty or bonus to the Financial Health Score.
  ///
  /// [hadTransactions] = true  → user spent but forgot to log → adds penalty days
  /// [hadTransactions] = false → genuinely no spending        → adds clean-day credit
  static Future<void> recordGapResponse(GapResponse response) async {
    try {
      if (response.hadTransactions) {
        final current = int.tryParse(
                await DBService.getSetting(prefKeyGapPenalty) ?? '0') ??
            0;
        await DBService.setSetting(
            prefKeyGapPenalty, (current + response.gap.days).toString());
      } else {
        final current =
            int.tryParse(await DBService.getSetting(prefKeyGapBonus) ?? '0') ??
                0;
        await DBService.setSetting(
            prefKeyGapBonus, (current + response.gap.days).toString());
      }
    } catch (_) {}
  }

  /// Reset gap counters at the start of each calendar month.
  static Future<void> resetMonthlyGapCounters() async {
    await DBService.setSetting(prefKeyGapPenalty, '0');
    await DBService.setSetting(prefKeyGapBonus, '0');
  }
}
