import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.7.0';
  static const _prefKey = 'whats_new_seen_2_7_0';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefKey) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  static const _features = [
    (
      '🛡️',
      'Insurance & Contributions Tracker',
      'Track SSS, PhilHealth, Pag-IBIG, and private insurance — premiums, due dates, and overdue alerts'
    ),
    (
      '🤖',
      '24 AI Actions (was 16)',
      'New: salary split, goal feasibility, debt payoff strategy, monthly plan, period comparison, FHS explanation, savings projection, subscription detection, contribution calculator'
    ),
    (
      '📅',
      'Date & Time Editing',
      'Edit expense dates and times — tap the date/time field in Edit Expense. AI can also change dates via chat'
    ),
    (
      '🔔',
      'Smart Startup Alerts',
      'On-open notifications for: exceeded budgets, overdue bills, debts due soon, FHS drops, idle money, overdue premiums'
    ),
    (
      '💰',
      'Salary Split (50/30/20)',
      'Tell AI "split my salary 50/30/20" — auto-creates budgets for all 12 categories + savings goal'
    ),
    (
      '🔀',
      'Wallet Transfers',
      'Tell AI "move ₱500 from Cash to GCash" — instant wallet-to-wallet transfer'
    ),
    (
      '📊',
      'FHS Breakdown in AI',
      'Ask "why is my score low?" — AI now has full component-level breakdown data to explain your Financial Health Score'
    ),
    (
      '🗑️',
      'Bulk Delete by Date',
      'Tell AI "delete all expenses from January" — bulk delete with DELETE confirmation'
    ),
    (
      '🔍',
      'Subscription Detection',
      'Ask AI "find my subscriptions" — scans expenses for repeating patterns'
    ),
    ('💾', 'Backup v9', 'Insurance policies now included in backup/restore'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("What's New in v$_version — AI & Insurance"),
        actions: [
          TextButton(
            onPressed: () async {
              await markSeen();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Got it"),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: cs.primaryContainer,
            child: Column(
              children: [
                Icon(Icons.new_releases_outlined, size: 40, color: cs.primary),
                const SizedBox(height: 8),
                Text("Smart Spend v$_version",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer)),
                Text("Here's what's new in this update",
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _features.length,
              itemBuilder: (_, i) {
                final f = _features[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.$1, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.$2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(f.$3,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        cs.onSurface.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await markSeen();
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Let's go!"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
