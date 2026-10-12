import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/peso_mascot.dart';

/// Shown once after the first app launch — teaches 4 essential tips.
class QuickTipsScreen extends StatelessWidget {
  const QuickTipsScreen({super.key});

  static const _prefKey = 'quick_tips_seen_v1';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefKey) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  static const _tips = [
    (
      '💬',
      'Talk to Peso in Taglish',
      'Type "nag-gastos ako ng 65 sa canteen" or "spent 149 on Jollibee via GCash" — Peso understands Filipino and English. It auto-fills category, amount, and wallet.',
    ),
    (
      '🏆',
      'What is the Financial Health Score?',
      'Your FHS (0–100) measures 4 things: Savings Rate, Budget Adherence, Budget Setup, and Logging Consistency. Tap the score card on Home to see a full breakdown.',
    ),
    (
      '📷',
      'Import GCash & Shopee screenshots',
      'In the Peso chat screen, tap the 📷 camera icon in the input bar → select "Batch Screenshots". Pick multiple GCash, Shopee, or Steam screenshots — SmartSpend reads them all and logs every item at once.',
    ),
    (
      '🔒',
      'Works fully offline',
      'All core features — logging, analytics, budgets, goals — work without internet. Peso AI needs internet unless you set up Local AI mode in Settings → AI Model.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Center(
              child: PesoMascot(size: 72, mood: PesoMood.winking),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 20),
            Text(
              'Quick Tips 💡',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'A few things that make SmartSpend click',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 20),
            ...QuickTipsScreen._tips.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.$1, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.$2,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t.$3,
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.65),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await QuickTipsScreen.markSeen();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Got it — let's go!"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
