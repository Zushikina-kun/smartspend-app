import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'db_service.dart';
import 'currency_service.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    // Request notification permission on Android 13+ (API 33+)
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Show a weekly spending summary notification
  static Future<void> showWeeklySummary() async {
    await init();

    final now = DateTime.now();
    // Use a rolling 7-day window ending yesterday so the summary covers a
    // complete past week rather than the current (partial) week.
    final weekEnd = now.subtract(const Duration(days: 1));
    final weekStart = now.subtract(const Duration(days: 7));
    // Store the Sunday date as the key (not Monday) to match checkAndNotify
    final weekKey = DateFormat('yyyy-MM-dd').format(now);

    // Get this week's expenses
    final allExpenses = await DBService.getExpenses();
    final weekExpenses = allExpenses.where((e) {
      try {
        final d = DateTime.parse(e.date);
        return !d.isBefore(weekStart) && !d.isAfter(weekEnd);
      } catch (_) {
        return false;
      }
    }).toList();

    if (weekExpenses.isEmpty) return;

    final total = weekExpenses.fold<double>(0, (s, e) => s + e.amount);

    // Find top category
    final catTotals = <String, double>{};
    for (final e in weekExpenses) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }
    final topCat =
        catTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    const android = AndroidNotificationDetails(
      'weekly_summary',
      'Weekly Summary',
      channelDescription: 'Weekly spending summary',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    await _plugin.show(
      1,
      '📊 Weekly Spending Summary',
      'You spent ${CurrencyService.format(total)} this week. Top category: $topCat.',
      const NotificationDetails(android: android),
    );

    await DBService.setSetting('last_weekly_notif', weekKey);
  }

  /// Check if weekly notification should be shown (every Sunday)
  static Future<void> checkAndNotify() async {
    await init();
    final now = DateTime.now();
    if (now.weekday != DateTime.sunday) return;

    final lastKey = await DBService.getSetting('last_weekly_notif');
    // Use the Sunday date itself as the key (not Monday)
    final thisWeekKey = DateFormat('yyyy-MM-dd').format(now);

    if (lastKey != thisWeekKey) {
      await showWeeklySummary();
      await checkWeeklyBehavioralSummary();
    }
  }

  /// Weekly AI Behavioral Summary — fires every Sunday with FHS component breakdown.
  /// "Your week in review: Savings Rate 38%, 2 days over budget, logged 5/7 days."
  static Future<void> checkWeeklyBehavioralSummary() async {
    await init();
    try {
      final now = DateTime.now();
      // Rolling 7-day window (past 7 complete days, not the current calendar week)
      final weekStart = now.subtract(const Duration(days: 7));
      final weekEnd = now.subtract(const Duration(days: 1));
      final allExpenses = await DBService.getExpenses();
      final income = await DBService.getMonthlyIncome();

      // This week's expenses
      final weekExpenses = allExpenses.where((e) {
        try {
          final d = DateTime.parse(e.date);
          return !d.isBefore(weekStart) && !d.isAfter(weekEnd);
        } catch (_) {
          return false;
        }
      }).toList();

      if (weekExpenses.isEmpty) return;

      final totalSpent = weekExpenses.fold<double>(0, (s, e) => s + e.amount);
      final weeklyIncome = income / 4.33; // approximate weekly income
      final savingsRate = weeklyIncome > 0
          ? ((weeklyIncome - totalSpent) / weeklyIncome * 100).clamp(0.0, 100.0)
          : 0.0;

      // Count days over daily budget
      final dailyBudget = income > 0 ? income / 30 : 0.0;
      final dailySpend = <String, double>{};
      for (final e in weekExpenses) {
        dailySpend[e.date.substring(0, 10)] =
            (dailySpend[e.date.substring(0, 10)] ?? 0) + e.amount;
      }
      final overDays = dailyBudget > 0
          ? dailySpend.values.where((v) => v > dailyBudget).length
          : 0;

      // Logged days this week
      final loggedDays = dailySpend.length;
      final activeDays = now.weekday; // days elapsed this week

      // Build summary message
      final savingsStr = savingsRate >= 20
          ? "Savings Rate ${savingsRate.toStringAsFixed(0)}% ✓"
          : "Savings Rate ${savingsRate.toStringAsFixed(0)}% (target: 20%)";
      final overStr = overDays == 0
          ? "No days over budget ✓"
          : "$overDays day${overDays == 1 ? '' : 's'} over daily budget";
      final logStr = "Logged $loggedDays/$activeDays days";

      const android = AndroidNotificationDetails(
        'weekly_behavioral',
        'Weekly Behavioral Summary',
        channelDescription: 'Weekly AI behavioral insights',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      await _plugin.show(
        998,
        '📊 Your week in review',
        '$savingsStr · $overStr · $logStr',
        const NotificationDetails(android: android),
      );
    } catch (_) {}
  }

  /// Proactive anomaly detection — checks weekly for unusual spending spikes.
  /// "You spent ₱1,200 on Transport this week — that's 3x your usual ₱400."
  /// Runs locally, no AI call needed. Only fires once per week.
  static Future<void> checkAnomalyDetection() async {
    await init();
    try {
      final now = DateTime.now();
      // Only run on Sunday (same day as weekly summary)
      if (now.weekday != DateTime.sunday) return;

      final lastKey = await DBService.getSetting('last_anomaly_check');
      // Use Sunday date as key (consistent with checkAndNotify)
      final thisWeekKey = DateFormat('yyyy-MM-dd').format(now);
      if (lastKey == thisWeekKey) return; // already ran this week
      await DBService.setSetting('last_anomaly_check', thisWeekKey);
      final weekStart = now.subtract(const Duration(days: 7));
      final allExpenses = await DBService.getExpenses();

      // This week's spending by category
      final thisWeekCats = <String, double>{};
      for (final e in allExpenses) {
        try {
          final d = DateTime.parse(e.date);
          if (!d.isBefore(weekStart)) {
            thisWeekCats[e.category] =
                (thisWeekCats[e.category] ?? 0) + e.amount;
          }
        } catch (_) {}
      }

      if (thisWeekCats.isEmpty) return;

      // Last 4 weeks average by category (excluding this week)
      final fourWeeksAgo = now.subtract(const Duration(days: 28));
      final historyCats = <String, List<double>>{};
      for (final e in allExpenses) {
        try {
          final d = DateTime.parse(e.date);
          if (d.isBefore(weekStart) && !d.isBefore(fourWeeksAgo)) {
            historyCats[e.category] = historyCats[e.category] ?? [];
            historyCats[e.category]!.add(e.amount);
          }
        } catch (_) {}
      }

      // Find anomalies: this week > 2.5x the weekly average
      for (final entry in thisWeekCats.entries) {
        final cat = entry.key;
        final thisWeek = entry.value;
        final history = historyCats[cat];
        if (history == null || history.isEmpty) continue;
        final weeklyAvg = history.fold<double>(0, (s, v) => s + v) / 4;
        if (weeklyAvg > 0 && thisWeek > weeklyAvg * 2.5) {
          const android = AndroidNotificationDetails(
            'anomaly_detection',
            'Spending Anomaly',
            channelDescription: 'Unusual spending pattern alerts',
            importance: Importance.high,
            priority: Priority.high,
          );
          await _plugin.show(
            ('anomaly_$cat').hashCode,
            '⚠️ Unusual spending: $cat',
            'You spent ₱${thisWeek.toStringAsFixed(0)} on $cat this week — '
                '${(thisWeek / weeklyAvg).toStringAsFixed(1)}x your usual ₱${weeklyAvg.toStringAsFixed(0)}',
            const NotificationDetails(android: android),
          );
          break; // only one anomaly alert per week
        }
      }
    } catch (_) {}
  }

  /// Show budget alert notification — with loss aversion framing linked to top savings goal.
  /// "₱800 over in Food = ₱800 less toward your New Laptop goal."
  static Future<void> showBudgetAlert(
      String category, double spent, double budget) async {
    await init();
    const android = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Budget limit warnings',
      importance: Importance.high,
      priority: Priority.high,
    );

    final pct = (spent / budget * 100).toStringAsFixed(0);
    final over = spent - budget;

    // Loss aversion framing: link overspend to top savings goal
    String body;
    if (over > 0) {
      // Over budget — show goal impact
      final goals = await DBService.getGoals();
      final topGoal = goals.isEmpty
          ? null
          : goals.firstWhere(
              (g) => (g['current_amount'] as num) < (g['target_amount'] as num),
              orElse: () => goals.first,
            );
      if (topGoal != null) {
        final goalName = topGoal['name'] as String;
        body =
            '₱${over.toStringAsFixed(0)} over your $category budget = ₱${over.toStringAsFixed(0)} less toward "$goalName".';
      } else {
        body =
            'You\'ve used $pct% of your $category budget (₱${spent.toStringAsFixed(0)} / ₱${budget.toStringAsFixed(0)})';
      }
    } else {
      // Approaching limit (80%)
      body =
          'You\'ve used $pct% of your $category budget — ₱${(budget - spent).toStringAsFixed(0)} remaining.';
    }

    await _plugin.show(
      category.hashCode,
      over > 0 ? '⚠️ $category budget exceeded' : '💡 $category at $pct%',
      body,
      const NotificationDetails(android: android),
    );
  }

  /// Show daily spending limit alert
  static Future<void> showDailyLimitAlert(double spent, double limit) async {
    await init();
    const android = AndroidNotificationDetails(
      'daily_limit',
      'Daily Limit',
      channelDescription: 'Daily spending limit alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    final isOver = spent >= limit;
    await _plugin.show(
      9999,
      isOver ? '🚨 Daily Limit Exceeded' : '⚠️ Daily Limit Warning',
      isOver
          ? 'You\'ve spent ₱${spent.toStringAsFixed(0)} today — ₱${(spent - limit).toStringAsFixed(0)} over your ₱${limit.toStringAsFixed(0)} limit'
          : 'You\'ve used ${(spent / limit * 100).toStringAsFixed(0)}% of your ₱${limit.toStringAsFixed(0)} daily limit',
      const NotificationDetails(android: android),
    );
  }

  /// 3-tier escalating budget warning based on decay days.
  /// Day 1: Gentle nudge
  /// Day 2: Strong alert with spending comparison
  /// Day 3: Critical warning with projected overspend
  static Future<void> showDecayWarning({
    required int decayDays,
    required String category,
    required double spent,
    required double budget,
    double monthlyIncome = 0,
  }) async {
    if (decayDays <= 0) return;
    await init();

    String title;
    String body;
    Importance importance;

    final over = spent - budget;
    final overStr = '₱${over.toStringAsFixed(0)}';
    final pct = (spent / budget * 100).toStringAsFixed(0);

    switch (decayDays) {
      case 1:
        title = '💡 Budget tip: $category';
        body =
            'You\'re $overStr over your $category budget ($pct%). Consider adjusting your spending today.';
        importance = Importance.defaultImportance;
        break;
      case 2:
        title = '⚠️ Budget warning: $category';
        body = 'You\'ve exceeded your $category budget for 2 days in a row. '
            'Spent: ₱${spent.toStringAsFixed(0)} vs limit ₱${budget.toStringAsFixed(0)}. '
            'Your Financial Health Score is being affected.';
        importance = Importance.high;
        break;
      default: // day 3+
        final projected = monthlyIncome > 0
            ? '₱${(over * 30 / DateTime.now().day).toStringAsFixed(0)} projected overspend this month'
            : 'Continued overspending will lower your score further';
        title = '🚨 Critical: $category budget exceeded 3+ days';
        body = 'Your $category spending is $overStr over budget. $projected. '
            'Financial Health Score penalty: −15 pts.';
        importance = Importance.max;
    }

    await _plugin.show(
      ('decay_$category').hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_decay',
          'Budget Decay Warnings',
          channelDescription: 'Escalating budget warning notifications',
          importance: importance,
          priority: decayDays >= 3 ? Priority.max : Priority.high,
        ),
      ),
    );
  }

  /// Check for overdue or due-today recurring transactions and notify
  static Future<List<Map<String, dynamic>>> checkRecurringDue() async {
    await init();
    final recurring = await DBService.getRecurring();
    final due = <Map<String, dynamic>>[];

    for (final r in recurring) {
      final nextDate = r['next_date'] as String? ?? '';
      if (nextDate.isEmpty) continue;
      try {
        final d = DateTime.parse(nextDate);
        final diff = d.difference(DateTime.now()).inDays;
        if (diff <= 0) {
          // Overdue or due today
          due.add(r);
          const android = AndroidNotificationDetails(
            'recurring_due',
            'Recurring Due',
            channelDescription: 'Recurring transaction reminders',
            importance: Importance.high,
            priority: Priority.high,
          );
          final label = diff == 0 ? 'due today' : 'overdue';
          await _plugin.show(
            r['id'].hashCode,
            '🔁 ${r['title']} $label',
            '₱${(r['amount'] as num).toStringAsFixed(0)} — tap to log it',
            const NotificationDetails(android: android),
          );
        } else if (diff <= 3) {
          // Due in 1–3 days — advance warning
          due.add(r);
          const android = AndroidNotificationDetails(
            'recurring_due',
            'Recurring Due',
            channelDescription: 'Recurring transaction reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          );
          await _plugin.show(
            ('advance_${r['id']}').hashCode,
            '🔁 ${r['title']} due in $diff day${diff == 1 ? '' : 's'}',
            '₱${(r['amount'] as num).toStringAsFixed(0)} ${r['frequency']}',
            const NotificationDetails(android: android),
          );
        }
      } catch (_) {}
    }
    return due;
  }

  /// Check for upcoming or overdue debts and notify
  static Future<void> checkDebtsDue() async {
    await init();
    final debts = await DBService.getDebts();

    for (final d in debts) {
      final dueDate = d['due_date'] as String?;
      if (dueDate == null || dueDate.isEmpty) continue;
      final remaining = (d['amount'] as num) - (d['paid_amount'] as num);
      if (remaining <= 0) continue; // already paid

      try {
        final due = DateTime.parse(dueDate);
        final diff = due.difference(DateTime.now()).inDays;
        final isOwe = d['type'] == 'owe';
        final person = d['person'] as String;
        final title = d['title'] as String;
        final amtStr = '₱${remaining.toStringAsFixed(0)}';

        if (diff < 0) {
          // Overdue
          await _plugin.show(
            ('debt_${d['id']}').hashCode,
            isOwe
                ? '⚠️ Overdue payment to $person'
                : '⚠️ $person hasn\'t paid you back',
            '$title — $amtStr overdue',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'debt_alerts',
                'Debt Alerts',
                channelDescription: 'Debt and lending reminders',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
        } else if (diff == 0) {
          await _plugin.show(
            ('debt_${d['id']}').hashCode,
            isOwe ? '💳 Payment due today' : '💰 Payment expected today',
            '$title — $amtStr to ${isOwe ? person : 'receive from $person'}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'debt_alerts',
                'Debt Alerts',
                channelDescription: 'Debt and lending reminders',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
        } else if (diff <= 7) {
          // Due within a week
          await _plugin.show(
            ('debt_${d['id']}').hashCode,
            isOwe
                ? '📅 Payment due in $diff day${diff == 1 ? '' : 's'}'
                : '📅 Expected payment in $diff day${diff == 1 ? '' : 's'}',
            '$title — $amtStr to ${isOwe ? person : 'receive from $person'}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'debt_alerts',
                'Debt Alerts',
                channelDescription: 'Debt and lending reminders',
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
              ),
            ),
          );
        }
      } catch (_) {}
    }
  }

  /// Check savings goals approaching deadline
  static Future<void> checkGoalDeadlines() async {
    await init();
    final goals = await DBService.getGoals();

    for (final g in goals) {
      final deadline = g['deadline'] as String?;
      if (deadline == null || deadline.isEmpty) continue;
      final current = (g['current_amount'] as num).toDouble();
      final target = (g['target_amount'] as num).toDouble();
      if (current >= target) continue; // already reached

      try {
        final due = DateTime.parse(deadline);
        final diff = due.difference(DateTime.now()).inDays;
        final name = g['name'] as String;
        final remaining = target - current;

        if (diff < 0) {
          await _plugin.show(
            ('goal_${g['id']}').hashCode,
            '🎯 Goal deadline passed: $name',
            '₱${remaining.toStringAsFixed(0)} still needed',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'goal_alerts',
                'Goal Alerts',
                channelDescription: 'Savings goal reminders',
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
              ),
            ),
          );
        } else if (diff <= 7) {
          await _plugin.show(
            ('goal_${g['id']}').hashCode,
            '🎯 Goal deadline in $diff day${diff == 1 ? '' : 's'}: $name',
            '₱${remaining.toStringAsFixed(0)} still needed to reach ₱${target.toStringAsFixed(0)}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'goal_alerts',
                'Goal Alerts',
                channelDescription: 'Savings goal reminders',
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
              ),
            ),
          );
        }
      } catch (_) {}
    }
  }

  /// Category velocity alert — fires monthly when a category grows faster than income.
  /// "Food spending up 25% month-over-month while income is flat — early warning."
  /// Runs once per month on app open.
  static Future<void> checkCategoryVelocity() async {
    await init();
    try {
      final now = DateTime.now();
      final monthKey = DateFormat('yyyy-MM').format(now);
      final lastKey = await DBService.getSetting('last_velocity_check');
      if (lastKey == monthKey) return; // already ran this month
      await DBService.setSetting('last_velocity_check', monthKey);

      final allExpenses = await DBService.getExpenses();
      final income = await DBService.getMonthlyIncome();

      final thisMonthKey = DateFormat('yyyy-MM').format(now);
      final lastMonthKey =
          DateFormat('yyyy-MM').format(DateTime(now.year, now.month - 1));

      final thisCats = <String, double>{};
      final lastCats = <String, double>{};
      for (final e in allExpenses) {
        if (e.date.startsWith(thisMonthKey)) {
          thisCats[e.category] = (thisCats[e.category] ?? 0) + e.amount;
        } else if (e.date.startsWith(lastMonthKey)) {
          lastCats[e.category] = (lastCats[e.category] ?? 0) + e.amount;
        }
      }

      if (lastCats.isEmpty) return;

      // Find categories growing >25% month-over-month
      for (final entry in thisCats.entries) {
        final cat = entry.key;
        final thisAmt = entry.value;
        final lastAmt = lastCats[cat] ?? 0;
        if (lastAmt < 100) continue; // ignore tiny categories
        final growth = lastAmt > 0 ? (thisAmt - lastAmt) / lastAmt : 0.0;
        if (growth >= 0.25) {
          final pct = (growth * 100).toStringAsFixed(0);
          final incomeNote = income > 0 ? ' while income is flat' : '';
          await _plugin.show(
            ('velocity_$cat').hashCode,
            '📈 $cat spending up $pct%',
            '$cat is ₱${(thisAmt - lastAmt).toStringAsFixed(0)} higher than last month$incomeNote. Consider reviewing.',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'velocity_alerts',
                'Spending Velocity',
                channelDescription: 'Category growth rate alerts',
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
              ),
            ),
          );
          break; // one alert per month max
        }
      }
    } catch (_) {}
  }

  /// WN-2: Want/Need insight — fires when Want spending is unusually high this month.
  /// Only runs once per month.
  static Future<void> checkWantSpendingAlert() async {
    await init();
    try {
      final now = DateTime.now();
      final monthKey = DateFormat('yyyy-MM').format(now);
      final lastKey = await DBService.getSetting('last_want_alert');
      if (lastKey == monthKey) return;

      final expenses = await DBService.getExpenses();
      final thisMonth =
          expenses.where((e) => e.date.startsWith(monthKey)).toList();
      if (thisMonth.isEmpty) return;

      final wantTotal = thisMonth
          .where((e) => e.isWant == true)
          .fold(0.0, (s, e) => s + e.amount);
      final total = thisMonth.fold(0.0, (s, e) => s + e.amount);
      if (total <= 0) return;

      final wantPct = wantTotal / total * 100;
      if (wantPct >= 40) {
        await DBService.setSetting('last_want_alert', monthKey);
        await _plugin.show(
          9998,
          '🛍️ High discretionary spending',
          '${wantPct.toStringAsFixed(0)}% of your spending this month is on Wants. Consider reviewing.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'want_alerts',
              'Want Spending Alerts',
              channelDescription: 'Alerts when discretionary spending is high',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
          ),
        );
      }
    } catch (_) {}
  }

  /// GM-6: Financial Health Level-Up notification.
  /// Fires when FHS crosses 60, 70, 80, or 90 for the first time.
  static Future<void> checkLevelUp(int newScore) async {
    await init();
    final thresholds = [60, 70, 80, 90];
    for (final t in thresholds) {
      final key = 'level_up_$t';
      final already = await DBService.getSetting(key);
      if (already == null && newScore >= t) {
        await DBService.setSetting(key, 'true');
        final label = t >= 80 ? 'Good 🟢' : 'Fair 🟡';
        await _plugin.show(
          ('levelup_$t').hashCode,
          '🎉 Financial Health Level Up!',
          'Your score reached $t/100 — $label! Keep it up.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'level_up',
              'Level Up',
              channelDescription: 'Financial health milestone notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
        break; // one notification per app open
      }
    }
  }

  /// Daily morning briefing — shows remaining budget and upcoming bills
  /// Call this on app open; only fires once per day between 6AM-10AM
  static Future<void> checkDailyBriefing() async {
    await init();
    final now = DateTime.now();
    // Only show between 6AM and 10AM
    if (now.hour < 6 || now.hour >= 10) return;

    final todayKey = DateFormat('yyyy-MM-dd').format(now);
    final lastKey = await DBService.getSetting('last_daily_briefing');
    if (lastKey == todayKey) return; // already shown today

    try {
      final income = await DBService.getMonthlyIncome();
      if (income <= 0) return;

      final currentMonth = DateFormat('yyyy-MM').format(now);
      final expenses = await DBService.getExpenses(month: currentMonth);
      final spent = expenses.fold<double>(0, (s, e) => s + e.amount);
      final remaining = income - spent;

      final recurring = await DBService.getRecurring();
      final upcomingCount = recurring.where((r) {
        try {
          final d = DateTime.parse(r['next_date'] as String? ?? '');
          return d.difference(now).inDays <= 7 && d.difference(now).inDays >= 0;
        } catch (_) {
          return false;
        }
      }).length;

      final remainingStr = remaining >= 0
          ? '₱${remaining.toStringAsFixed(0)} remaining this month'
          : 'Over budget by ₱${(-remaining).toStringAsFixed(0)}';

      final billsStr = upcomingCount > 0
          ? ' · $upcomingCount bill${upcomingCount == 1 ? '' : 's'} due this week'
          : '';

      const android = AndroidNotificationDetails(
        'daily_briefing',
        'Daily Briefing',
        channelDescription: 'Morning financial summary',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      await _plugin.show(
        999,
        '☀️ Good morning! Here\'s your financial snapshot',
        '$remainingStr$billsStr',
        const NotificationDetails(android: android),
      );

      await DBService.setSetting('last_daily_briefing', todayKey);
    } catch (_) {}
  }
}
