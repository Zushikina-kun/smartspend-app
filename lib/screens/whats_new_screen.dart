import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.9.8';
  static const _prefKey = 'whats_new_seen_2_9_8';

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
      '🤖',
      'AI Now Understands Filipino/Taglish for All Actions',
      'You can now set budgets, add debts, log income, create goals, and add recurring bills in Filipino. '
          '"Budget ko sa pagkain 3000", "may utang ako kay John ng 500", "sweldo ko 25000" — all work directly.'
    ),
    (
      '💰',
      'Set Spending Limits via AI',
      'Tell the AI "set daily limit to 200 pesos" or "limitahan ang gastos ko ng 500 kada araw" '
          'and it sets your spending cap directly — no need to go to App Settings.'
    ),
    (
      '🏥',
      'Add Insurance & Contributions via AI',
      'Say "SSS ko 560 monthly" or "add PhilHealth contribution 250 a month" and the AI creates '
          'the entry in your Insurance Tracker automatically. Works for life insurance too.'
    ),
    (
      '📋',
      'AI Knows Your Auto-Rules',
      'The AI can now see and describe your auto-categorization rules. '
          '"What rules do I have?" now gives a real answer.'
    ),
    (
      '✅',
      'Multi-Item Logging More Reliable',
      'Logging multiple expenses in one message is more robust — catches typos like "spen", '
          'handles commas and "and" connectors, and uses a smarter model for complex multi-item messages.'
    ),
    (
      '🔄',
      'Recurring Auto-Add from Pattern Card',
      'When SmartSpend detects a recurring pattern, tapping "Add Recurring" now saves '
          'the entry directly — no more navigating to an empty screen.'
    ),
    (
      '📊',
      'Financial Management Score on Home & Analytics',
      'The Financial Management Score (FMS) now appears on the Home screen as a compact strip '
          'and on the Analytics screen alongside the FHS breakdown. Tap the strip to see the full breakdown in Profile.'
    ),
    (
      '⚠️',
      'FHS Unmeasured Label',
      'When income is not set, the Savings Rate component now shows "Unmeasured" with a grey '
          'indicator instead of a silent partial score — more transparent and honest.'
    ),
    (
      '🛠️',
      'Duplicate ScanReviewScreen Fixed',
      'A latent code conflict (two classes with the same name) was resolved. '
          'The camera import flow is now cleaner and more stable.'
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
