import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.5.0';
  static const _prefKey = 'whats_new_seen_2_5_0';

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
      '💵',
      'Wallet Balances',
      'Track Cash on Hand, GCash, Maya, BDO, BPI, and 30+ PH banks — tap the net worth card in Profile'
    ),
    (
      '🏦',
      'Full PH Bank & E-Wallet Support',
      'Import from BDO, BPI, Metrobank, Landbank, RCBC, GoTyme, Tonik, GrabPay, ShopeePay, and more'
    ),
    (
      '🧾',
      'Smart Receipt Import',
      'Scan a receipt → AI extracts each item individually → review & bulk import'
    ),
    (
      '🗓️',
      'Unified Financial Calendar',
      'Bills, debts, goals, installments, income — all on one calendar with score dots'
    ),
    (
      '🏆',
      'Achievements Screen',
      '16 earnable badges — find them in Hub → Achievements'
    ),
    (
      '😊',
      'Mood Check-In + Notes',
      'Track mood with optional notes — see spending correlation in Analytics'
    ),
    ('📊', 'Category Breakdown', 'Expandable charts per category in Analytics'),
    ('🔀', 'Auto-Categorization Rules', 'Set keyword → category rules in Hub'),
    ('🆚', 'Period Comparison Tool', 'Compare any two months side by side'),
    (
      '📅',
      'Installment & Payment Plans',
      'Track phones, gadgets, ShopeePayLater, GCash GLoan & more'
    ),
    (
      '🏪',
      'Import from Bank / GCash',
      'Paste any bank or e-wallet history — AI parses & bulk imports with real dates'
    ),
    (
      '🏷️',
      'Transaction Tags',
      'Tag expenses with #hashtags (e.g. #capstone, #shared) — filter by tag in Transactions'
    ),
    (
      '🔄',
      'Subscription Auto-Detection',
      'Automatically detects recurring expense patterns and suggests adding them as recurring transactions'
    ),
    (
      '🌍',
      'Market Insights',
      'Live PHP exchange rates (USD, EUR, GBP, JPY, SGD) + financial literacy tips in Analytics'
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
