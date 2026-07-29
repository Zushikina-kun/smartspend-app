import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.9.0';
  static const _prefKey = 'whats_new_seen_2_9_0';

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
      '⚖️',
      'Lightweight Mode — No Income Needed',
      'Turn off income/wallet tracking in Settings → Tracking Mode. Works for anyone — just log spending. FHS recalculates using spending habits: Spending Restraint, Consistency, Category Balance, Habit Streak.'
    ),
    (
      '🎯',
      'Period Spending Limit',
      'Set one cap for your total spending per day, week, month, or year. Progress bar on home screen. Warns at 80%, alerts at 100%. Independent of tracking mode.'
    ),
    (
      '📅',
      'Logging Gap Detection',
      'On startup, app asks about days with no logs. Confirm spending (FHS penalty) or no spending (clean-day bonus). Score now reflects actual behaviour, not silence.'
    ),
    (
      '🤖',
      'AI Accuracy: Names, Dates, Duplicates',
      '"your jeepney fare for" cleaned to "Jeepney fare". Date corrections now always fire an update ACTION. 90-second DB-level duplicate guard. 503 errors silent-retry up to 3×.'
    ),
    (
      '📊',
      'Gemini 3.5 Flash + Smart Model Routing',
      'Updated models (2.5 → 3.x). Complex financial queries auto-route to the smartest model. New financial_advice tier for SSS/tax/debt-strategy questions.'
    ),
    (
      '🔄',
      'Transactions Auto-Sort',
      'Transaction list reloads automatically after any AI-driven edit — no more manual pull-to-refresh.'
    ),
    (
      '🔍',
      'Observability & Debug Traces',
      'Per-request trace (latency/tokens/retries) in debug export. Silent action fails logged. Groundedness check on financial advice replies.'
    ),
    (
      '📸',
      'Batch Screenshot Import',
      'Import from Steam, Shopee, Lazada, GCash, Grab, App Store, bank apps — up to 10 screenshots at once. AI detects platform type, extracts item name, price, date, time, and store automatically.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("What's New in v$_version"),
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
