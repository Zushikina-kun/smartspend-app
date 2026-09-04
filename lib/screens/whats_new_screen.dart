import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.9.11';
  static const _prefKey = 'whats_new_seen_2_9_11';

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
      '🧠',
      'Score Narrative & Coach Report (v2.9.10)',
      'The AI now generates a weekly summary card on your Home screen with '
          'context-aware feedback like "You\'re spending more than usual on Food." '
          'A full Coach Report is also available in Profile — your weekly financial '
          'letter with one habit recommendation.'
    ),
    (
      '🎉',
      'Score Celebrations & Milestone Toasts (v2.9.10)',
      'Get an animated celebration when your Financial Health Score crosses '
          'key milestones (50, 65, 75, 90). Goal progress also notifies you '
          'at 25%, 50%, 75%, and 100% of your savings target.'
    ),
    (
      '💬',
      'Purchase Commentary & Supportive Alerts (v2.9.10)',
      'The AI now adds a brief behavioral note to large Want purchases logged '
          'via receipt scan or voice. Budget overspend warnings now include a '
          'constructive follow-up suggestion instead of a plain red banner.'
    ),
    (
      '📊',
      'FMS Next-Step Guidance (v2.9.10)',
      'The Financial Management Score card now shows a single prioritized '
          'action tip when any sub-component is below 20/25 — so you always '
          'know exactly what to do next to improve your score.'
    ),
    (
      '❓',
      'Score Explanation Tooltips (v2.9.10)',
      'Tap the info button on your FHS card to open a plain-language '
          'explanation of why your score is what it is — one sentence '
          'per component.'
    ),
    (
      '✅',
      'Analytics Fixed for Lightweight Mode',
      'The 50/30/20 card, Tax & Savings card, and Allowance Overview no longer '
          'appear when income tracking is OFF — they were showing meaningless '
          'numbers based on stale old income data.'
    ),
    (
      '🎯',
      'Logging Consistency Score is Now Honest',
      'Fixed: logging just once on the 2nd of the month no longer gives 25/25 '
          '"Logging every active day ✓". Now correctly reflects how many days '
          'have passed vs. how many you actually logged.'
    ),
    (
      '🌐',
      'AI Replies in Your Language',
      'The AI now detects whether you\'re writing in English, Filipino, or '
          'Taglish and matches your language automatically. You can also say '
          '"speak English" or "mag-Tagalog ka" to explicitly switch.'
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
