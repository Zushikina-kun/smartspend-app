import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import 'db_service.dart';
import 'currency_service.dart';
import 'notification_service.dart';

/// Proactive AI nudge notifications — Rowan-style forward-looking alerts.
///
/// Runs once per day on app open. Checks 5 trigger conditions and fires
/// a local push notification when something actionable is detected.
/// Each condition has its own "last notified" key to prevent repeat nudges.
///
/// Gated by 'show_proactive_nudges' setting (default: true).
/// Separate from startup alerts (reactive). These are forward-looking.
class ProactiveNudgeService {
  static const _channelId = 'proactive_nudges';
  static const _channelName = 'Smart Suggestions';
  static const _channelDesc =
      'Forward-looking tips: upcoming bills, pace alerts, goal milestones';

  static const _idSubscriptionDue = 2001;
  static const _idPaceHigh = 2002;
  static const _idGoalClose = 2003;
  static const _idIncomeStale = 2004;
  static const _idShortfallRisk = 2005;

  static Future<void> check() async {
    try {
      final enabled =
          (await DBService.getSetting('show_proactive_nudges')) != 'false';
      if (!enabled) return;

      // Rate limit: only run once per day
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final lastCheck =
          await DBService.getSetting('last_proactive_nudge_check');
      if (lastCheck == today) return;
      await DBService.setSetting('last_proactive_nudge_check', today);

      await NotificationService.init();

      final now = DateTime.now();
      final currentMonth =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final recurring = await DBService.getRecurring();
      final goals = await DBService.getGoals();
      final income = await DBService.getMonthlyIncome();
      final expenses = await DBService.getExpenses(month: currentMonth);
      final wallets = await DBService.getWallets();
      final walletTotal =
          wallets.fold<double>(0, (s, w) => s + (w['balance'] as num));
      final incomeWalletMode = await DBService.getIncomeWalletMode();
      final accountType =
          await DBService.getSetting('account_type') ?? 'general';

      await _checkUpcomingBill(recurring, now);

      if (incomeWalletMode && income > 0) {
        await _checkHighPace(expenses, income, now);
      }

      await _checkGoalMilestone(goals);

      if (accountType == 'student' || accountType == 'general') {
        await _checkStaleIncome(income, now);
      }

      if (incomeWalletMode && income > 0 && walletTotal > 0) {
        await _checkShortfallRisk(expenses, income, walletTotal, now);
      }
    } catch (_) {
      // Best-effort — never crash the app
    }
  }

  // ── Trigger 1: Recurring bill due in 3 days ─────────────────────────────
  static Future<void> _checkUpcomingBill(
      List<Map<String, dynamic>> recurring, DateTime now) async {
    final today = DateFormat('yyyy-MM-dd').format(now);
    final lastKey = 'nudge_sub_due_$today';
    if (await DBService.getSetting(lastKey) != null) return;

    for (final r in recurring) {
      if ((r['is_expense'] as int? ?? 1) != 1) continue;
      try {
        final nextDate = DateTime.parse(r['next_date'] as String);
        final daysUntil = nextDate.difference(now).inDays;
        if (daysUntil >= 0 && daysUntil <= 3) {
          final title = r['title'] as String;
          final amount = (r['amount'] as num).toDouble();
          await DBService.setSetting(lastKey, 'true');
          await _show(
            _idSubscriptionDue,
            '📅 Bill due ${daysUntil == 0 ? 'today' : 'in $daysUntil day${daysUntil == 1 ? '' : 's'}'}',
            '$title — ${CurrencyService.format(amount)}. Tap to review.',
          );
          return;
        }
      } catch (_) {}
    }
  }

  // ── Trigger 2: Spending pace 40%+ above weekly budget ──────────────────
  static Future<void> _checkHighPace(
      List<Expense> expenses, double income, DateTime now) async {
    final weekKey = 'nudge_pace_${DateFormat('yyyy-ww').format(now)}';
    if (await DBService.getSetting(weekKey) != null) return;

    final weekStart = now.subtract(const Duration(days: 7));
    double weekTotal = 0;
    final catTotals = <String, double>{};
    for (final e in expenses) {
      try {
        final d = DateTime.parse(e.date);
        if (!d.isBefore(weekStart)) {
          weekTotal += e.amount;
          catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
        }
      } catch (_) {}
    }
    if (weekTotal == 0) return;

    final weeklyBudget = income / 4.33;
    if (weekTotal > weeklyBudget * 1.4) {
      final topCat = catTotals.isEmpty
          ? null
          : (catTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first;
      final overage = ((weekTotal / weeklyBudget - 1) * 100).toStringAsFixed(0);
      await DBService.setSetting(weekKey, 'true');
      await _show(
        _idPaceHigh,
        '⚠️ Spending ${overage}% above your usual this week',
        topCat != null
            ? '${topCat.key} is your biggest driver — ${CurrencyService.format(topCat.value)}. Tap to review.'
            : 'You\'ve spent ${CurrencyService.format(weekTotal)} this week.',
      );
    }
  }

  // ── Trigger 3: Goal within ₱500 of target ──────────────────────────────
  static Future<void> _checkGoalMilestone(
      List<Map<String, dynamic>> goals) async {
    final monthKey = DateTime.now().toIso8601String().substring(0, 7);
    for (final g in goals) {
      final target = (g['target_amount'] as num).toDouble();
      final current = (g['current_amount'] as num).toDouble();
      if (current >= target) continue;
      final gap = target - current;
      if (gap <= 500 && gap > 0) {
        final milestoneKey = 'nudge_goal_${g['id']}_$monthKey';
        if (await DBService.getSetting(milestoneKey) != null) continue;
        await DBService.setSetting(milestoneKey, 'true');
        await _show(
          _idGoalClose,
          '🎯 Almost there — ${g['name']}',
          'Only ${CurrencyService.format(gap)} away from your goal! Tap to add a contribution.',
        );
        return;
      }
    }
  }

  // ── Trigger 4: Income not logged in 30+ days ───────────────────────────
  static Future<void> _checkStaleIncome(double income, DateTime now) async {
    if (income <= 0) return;
    final monthKey = DateFormat('yyyy-MM').format(now);
    final staleKey = 'nudge_stale_income_$monthKey';
    if (await DBService.getSetting(staleKey) != null) return;

    final allIncome = await DBService.getIncome();
    if (allIncome.isEmpty) return;

    try {
      final lastDate = DateTime.parse(allIncome.first['date'] as String);
      final daysSince = now.difference(lastDate).inDays;
      if (daysSince >= 30) {
        await DBService.setSetting(staleKey, 'true');
        await _show(
          _idIncomeStale,
          '💸 No allowance logged in $daysSince days',
          'Have you received money recently? Log it to keep your Financial Health Score accurate.',
        );
      }
    } catch (_) {}
  }

  // ── Trigger 5: Shortfall risk before end of month ──────────────────────
  static Future<void> _checkShortfallRisk(List<Expense> expenses, double income,
      double walletTotal, DateTime now) async {
    final monthKey = DateFormat('yyyy-MM').format(now);
    final riskKey = 'nudge_shortfall_$monthKey';
    if (await DBService.getSetting(riskKey) != null) return;

    final daysElapsed = now.day.toDouble();
    if (daysElapsed < 5) return; // too early in the month
    final totalSpent = expenses.fold<double>(0, (s, e) => s + e.amount);
    final dailyRate = totalSpent / daysElapsed;
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;
    final projectedRemaining = walletTotal - (dailyRate * daysLeft);

    if (projectedRemaining < 0) {
      final shortfall = -projectedRemaining;
      await DBService.setSetting(riskKey, 'true');
      await _show(
        _idShortfallRisk,
        '📉 At this pace, you may run short',
        'Projected shortfall: ${CurrencyService.format(shortfall)} before month end. Tap to check your spending.',
      );
    }
  }

  // ── Internal: fire a local push notification ────────────────────────────
  static Future<void> _show(int id, String title, String body) async {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await NotificationService.plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android),
    );
  }
}
