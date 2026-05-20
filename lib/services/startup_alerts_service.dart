import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_service.dart';
import 'currency_service.dart';
import 'score_service.dart';

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
class StartupAlertsService {
  static const _prefKeyLastAlert = 'last_startup_alert_date';

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
      final income = await DBService.getMonthlyIncome();
      final rawScore = ScoreService.calculateScore(
        expenseData,
        budgets: budgets,
        monthlyIncome: income,
      );
      final currentScore = await ScoreService.applyWarningDecay(rawScore);
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

      // 5. Check for idle wallets (unchanged 14+ days with significant balance)
      final wallets = await DBService.getWallets();
      final totalWalletBalance =
          wallets.fold<double>(0, (s, w) => s + (w['balance'] as num));
      if (totalWalletBalance > 5000) {
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
    } catch (_) {
      // Fail silently — alerts are non-critical
    }

    // Mark as shown today if we have alerts
    if (alerts.isNotEmpty) {
      await DBService.setSetting(_prefKeyLastAlert, today);
    }

    return alerts;
  }
}
