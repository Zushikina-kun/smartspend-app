import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.9.22';
  static const _prefKey = 'whats_new_seen_2_9_22';

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
      '🔄',
      'AI Fallback Persists Across Restarts (v2.9.21)',
      'When the app switches to a backup AI model due to an expired key, '
          'it now remembers that choice after you close and reopen the app. '
          'No more retrying a failed Gemini key on every cold start.'
    ),
    (
      '🛡️',
      'Graceful AI Failure UX (v2.9.20)',
      'When all AI providers fail, the error bubble now shows three options: '
          'Retry, Try Different Model (auto-switches), and Log Manually '
          '(opens the form pre-filled with your message).'
    ),
    (
      '📊',
      'FHS Lightweight Mode Fixed (v2.9.21)',
      'The Financial Health Score in Lightweight mode now shows the correct '
          'four components: Spending Restraint, Logging Consistency, '
          'Category Balance, and Habit Streak. Budget Adherence no longer '
          'appears when income tracking is off.'
    ),
    (
      '📅',
      'Smarter Spending Comparisons (v2.9.21)',
      'The "329% vs last month" alert is now suppressed when last month had '
          'fewer than 5 expenses — no more false spike warnings from a month '
          'where you barely logged anything.'
    ),
    (
      '💡',
      'Exchange Rates Always Fresh (v2.9.21)',
      'PHP exchange rates now refresh silently every time you open the app, '
          'even if the Market Insights card is hidden in App Settings.'
    ),
    (
      '✅',
      'Payment Plan Archive on Completion (v2.9.21)',
      'When you log the final payment on an installment plan, a one-tap '
          '"Archive" button now appears in the confirmation so you can '
          'clear it from your list immediately.'
    ),
    (
      '🎯',
      'Daily Quests Respect Your Mode (v2.9.21)',
      'Wallet and income-related quests are now hidden when income tracking '
          'is turned off — replaced with habit-based quests you can '
          'actually complete.'
    ),
    (
      '🔔',
      'Mode Switch Now Explains Score Change (v2.9.21)',
      'Toggling income tracking in App Settings now shows a brief notice '
          'explaining why your FHS score may look different after switching.'
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
