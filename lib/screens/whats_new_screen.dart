import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.8.0';
  static const _prefKey = 'whats_new_seen_2_8_0';

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
      'Multi-Model AI (Gemini + Groq + Cerebras)',
      'Auto-switches to next model when daily limit reached. Gemini 2.5 Flash-Lite is now default (1,000/day free, 1M context)'
    ),
    (
      '🔀',
      '29 AI Actions (was 25)',
      'New: suggest expense cuts, simulate what-if, create debt plan, split expense (auto-creates debt for the other person)'
    ),
    (
      '💬',
      'Typing Indicator',
      '"Peso is thinking..." with animated dots while AI processes'
    ),
    (
      '📋',
      'Long-Press Message Menu',
      'Long-press any AI message to copy, use as prompt, or share'
    ),
    (
      '💹',
      'Peso Cost Averaging Calculator',
      'Plan regular investments — MP2, UITFs, stocks — with year-by-year projections'
    ),
    (
      '🏅',
      'Financial Health Certificate',
      'Shareable monthly FHS score card — share via WhatsApp, social media'
    ),
    (
      '🏦',
      'BIR Tax Breakdown',
      'Tap income card → full monthly breakdown: BIR tax, SSS, PhilHealth, Pag-IBIG, take-home'
    ),
    (
      '🧠',
      'Philippine Financial Knowledge Base',
      'AI now knows SSS/PhilHealth/Pag-IBIG rates, BIR TRAIN Law brackets, digital bank rates, BSP Open Finance status'
    ),
    (
      '🎯',
      'Goal Deadline Alerts',
      'Startup alert when savings goal deadline is within 7 days'
    ),
    (
      '⚙️',
      '3 Income Frequencies for All',
      'Bimonthly (15th & 30th) now available for all account types with live monthly preview'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("What's New in v$_version — AI & Multi-Model"),
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
