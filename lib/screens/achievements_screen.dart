import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../widgets/info_button.dart';

/// GM-2: Achievements screen showing all badges — earned and locked.
/// Locked badges shown as silhouettes so users know what to aim for.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Set<String> _earned = {};
  bool _loading = true;

  static const _allBadges = [
    // Getting Started
    _Badge('🌱', 'First Step', 'Log your first expense', 'first_expense'),
    _Badge('📱', 'App Explorer', 'Use 5 different features', 'explorer'),
    // Streaks
    _Badge(
        '🔥', '3-Day Streak', 'Score ≥60 for 3 consecutive days', 'streak_3'),
    _Badge(
        '💯', 'Week Warrior', 'Score ≥60 for 7 consecutive days', 'streak_7'),
    _Badge(
        '🏆', 'Month Master', 'Score ≥60 for 30 consecutive days', 'streak_30'),
    // Savings & Budget
    _Badge('💰', 'Saver', 'Save ≥20% of income for a full month', 'saver'),
    _Badge('🎯', 'Goal Getter', 'Complete a savings goal', 'goal_complete'),
    _Badge('📊', 'Budget Boss', 'All budgets on track for a full month',
        'budget_boss'),
    _Badge('🪙', 'Spare Change Hero', 'Save ₱100+ via round-up savings',
        'roundup_100'),
    // AI & Tech
    _Badge('🤖', 'AI Power User', 'Send 20 AI messages', 'ai_20'),
    _Badge('🧾', 'Receipt Scanner', 'Scan 10 receipts', 'scan_10'),
    _Badge('🔀', 'Wallet Wizard', 'Make 5 wallet transfers', 'transfers_5'),
    // Discipline
    _Badge('🚫', 'Impulse Control', 'Decline an impulse pause 5 times',
        'impulse_5'),
    _Badge('📅', 'Consistent Logger', 'Log every day for 14 days', 'log_14'),
    _Badge('🔍', 'Detail Oriented', 'Add notes to 10 expenses', 'notes_10'),
    _Badge('🛡️', 'Insurance Aware', 'Track at least 1 insurance policy',
        'insurance_1'),
    // Fun
    _Badge('🌙', 'Night Owl', 'Log an expense after 10 PM', 'night_owl'),
    _Badge('☀️', 'Early Bird', 'Log an expense before 8 AM', 'early_bird'),
    // Debt & Financial Health
    _Badge('💳', 'Debt Slayer', 'Pay off a debt completely', 'debt_paid'),
    _Badge('🏦', 'Emergency Ready', 'Emergency fund reaches 100%',
        'emergency_100'),
    // Milestones
    _Badge('💎', 'Century Club', 'Log 100 expenses total', 'expenses_100'),
    _Badge('⭐', 'Score Star', 'Reach FHS score of 80+', 'score_80'),
    _Badge('🎓', 'Financial Literate', 'Ask AI 5 financial advice questions',
        'advice_5'),
  ];

  @override
  void initState() {
    super.initState();
    _computeEarned();
  }

  Future<void> _computeEarned() async {
    final earned = <String>{};

    // First expense
    final expenses = await DBService.getExpenses();
    if (expenses.isNotEmpty) earned.add('first_expense');

    // Streaks from score history
    final history = await DBService.getScoreHistory(days: 60);
    int streak = 0;
    for (final h in history.reversed) {
      if ((h['score'] as int) >= 60)
        streak++;
      else
        break;
    }
    if (streak >= 3) earned.add('streak_3');
    if (streak >= 7) earned.add('streak_7');
    if (streak >= 30) earned.add('streak_30');

    // Goals
    final goals = await DBService.getGoals();
    for (final g in goals) {
      if ((g['current_amount'] as num) >= (g['target_amount'] as num)) {
        earned.add('goal_complete');
      }
      if ((g['name'] as String).toLowerCase().contains('emergency') &&
          (g['current_amount'] as num) >= (g['target_amount'] as num)) {
        earned.add('emergency_100');
      }
    }

    // Scan history
    final scans = await DBService.getScanHistory(limit: 200);
    if (scans.length >= 10) earned.add('scan_10');

    // Debts paid
    final debts = await DBService.getDebts();
    for (final d in debts) {
      if ((d['paid_amount'] as num) >= (d['amount'] as num)) {
        earned.add('debt_paid');
      }
    }

    // Night owl / early bird
    for (final e in expenses) {
      final time = e.time;
      if (time != null && time.isNotEmpty) {
        try {
          final hour = int.parse(time.substring(0, 2));
          if (hour >= 22) earned.add('night_owl');
          if (hour < 8) earned.add('early_bird');
        } catch (_) {}
      }
    }

    // Notes on 10 expenses
    final withNotes =
        expenses.where((e) => e.notes != null && e.notes!.isNotEmpty).length;
    if (withNotes >= 10) earned.add('notes_10');

    // 14-day logging streak
    final now = DateTime.now();
    int logStreak = 0;
    for (int d = 0; d < 60; d++) {
      final checkDate = DateTime(now.year, now.month, now.day - d)
          .toIso8601String()
          .substring(0, 10);
      if (expenses.any((e) => e.date == checkDate))
        logStreak++;
      else
        break;
    }
    if (logStreak >= 14) earned.add('log_14');

    // AI Power User — 20+ chat messages
    final chatHistory = await DBService.getChatHistory(limit: 200);
    if (chatHistory.length >= 20) earned.add('ai_20');

    // Budget Boss — all budgets on track for current month
    final budgets = await DBService.getBudgets();
    if (budgets.isNotEmpty) {
      final thisMonth = now.toIso8601String().substring(0, 7);
      final monthlyIncome = await DBService.getMonthlyIncome();
      bool allOnTrack = true;
      for (final b in budgets) {
        final catExpenses =
            await DBService.getExpensesByCategory(b.category, month: thisMonth);
        final catSpent = catExpenses.fold<double>(0.0, (s, e) => s + e.amount);
        // Resolve percentage-based budgets to their actual ₱ amount
        final budgetLimit = b.isPercentage
            ? (b.percentageValue / 100.0 * monthlyIncome)
            : b.amount;
        if (budgetLimit <= 0) continue; // skip unconfigured budgets
        if (catSpent > budgetLimit) {
          allOnTrack = false;
          break;
        }
      }
      if (allOnTrack) earned.add('budget_boss');
    }

    // Saver — saved ≥20% of income for current month
    final thisMonth = now.toIso8601String().substring(0, 7);
    final monthIncome = await DBService.getTotalIncome(month: thisMonth);
    final monthSpent = await DBService.getTotalSpent(month: thisMonth);
    if (monthIncome > 0 && (monthIncome - monthSpent) >= monthIncome * 0.2) {
      earned.add('saver');
    }

    // Impulse Control — declined impulse pause 5 times
    final impulseDeclines =
        int.tryParse(await DBService.getSetting('impulse_declines') ?? '0') ??
            0;
    if (impulseDeclines >= 5) earned.add('impulse_5');

    // NEW BADGES — v2.7.0

    // Century Club — 100+ total expenses
    if (expenses.length >= 100) earned.add('expenses_100');

    // Score Star — FHS score of 80+
    if (history.isNotEmpty && (history.last['score'] as int) >= 80) {
      earned.add('score_80');
    }

    // Spare Change Hero — round-up savings accumulated ₱100+
    // Check if any goal has received round-up contributions
    for (final g in goals) {
      if ((g['current_amount'] as num) >= 100) {
        earned.add('roundup_100'); // approximate — any goal with ₱100+ counts
        break;
      }
    }

    // Wallet Wizard — 5+ wallet transfers (check expenses with transfer notes)
    final transferCount =
        expenses.where((e) => e.notes?.contains('Transfer') ?? false).length;
    if (transferCount >= 5) earned.add('transfers_5');

    // Insurance Aware — at least 1 insurance policy tracked
    try {
      final policies = await DBService.getInsurancePolicies();
      if (policies.isNotEmpty) earned.add('insurance_1');
    } catch (_) {}

    // App Explorer — used 5+ different features (heuristic: has expenses + budgets + goals + chat + scan)
    int featuresUsed = 0;
    if (expenses.isNotEmpty) featuresUsed++;
    if (budgets.isNotEmpty) featuresUsed++;
    if (goals.isNotEmpty) featuresUsed++;
    if (chatHistory.length >= 5) featuresUsed++;
    if (scans.isNotEmpty) featuresUsed++;
    if (debts.isNotEmpty) featuresUsed++;
    if (featuresUsed >= 5) earned.add('explorer');

    // Financial Literate — asked AI 5+ advice questions
    final adviceMessages = chatHistory
        .where((m) =>
            (m['role'] as String) == 'user' &&
            RegExp(r'(how|why|should|can i|what if|explain|advice|suggest)',
                    caseSensitive: false)
                .hasMatch(m['message'] as String? ?? ''))
        .length;
    if (adviceMessages >= 5) earned.add('advice_5');

    if (mounted)
      setState(() {
        _earned = earned;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final earnedCount = _allBadges.where((b) => _earned.contains(b.id)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
        actions: [
          const InfoButton(
            title: "Achievements",
            body: "Earn badges by hitting financial milestones.\n\n"
                "🔒 Locked badges show what you're working toward.\n"
                "✅ Earned badges are highlighted.\n\n"
                "Badges are computed from your real data — streaks, goals, debts, scan history, and more.\n\n"
                "Pull down to refresh your progress.",
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "$earnedCount / ${_allBadges.length}",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: cs.primary),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _computeEarned(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: _allBadges.length,
                itemBuilder: (_, i) {
                  final badge = _allBadges[i];
                  final isEarned = _earned.contains(badge.id);
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    color: isEarned
                        ? cs.primaryContainer.withValues(alpha: 0.5)
                        : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isEarned ? badge.emoji : '🔒',
                            style: TextStyle(
                                fontSize: 28,
                                color: isEarned ? null : Colors.grey[400]),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            badge.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isEarned ? cs.onSurface : Colors.grey[400],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            badge.description,
                            style: TextStyle(
                                fontSize: 10,
                                color: isEarned
                                    ? cs.onSurface.withValues(alpha: 0.6)
                                    : Colors.grey[400]),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _Badge {
  final String emoji;
  final String name;
  final String description;
  final String id;
  const _Badge(this.emoji, this.name, this.description, this.id);
}
