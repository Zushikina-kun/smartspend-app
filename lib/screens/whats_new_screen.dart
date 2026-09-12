import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.9.30';
  static const _prefKey = 'whats_new_seen_2_9_30';

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
      '✏️',
      'Manual Mode Overhaul (v2.9.26)',
      '"Log Expense" now opens a choice sheet: AI Chat, Manual Form, '
          'Batch Add (up to 8 expenses at once), or Voice → Form. '
          'Manual entry is now a first-class feature — works 100% offline.'
    ),
    (
      '🤖',
      'AI Works Again — New Models & Keys (v2.9.29)',
      'Fixed: Gemini 3.5 Flash-Lite is now the primary model (the old '
          'gemini-3.1-flash-lite was shut down by Google). Groq fallback '
          'now uses models verified on your account tier.'
    ),
    (
      '🔄',
      'AI Fallback Persists Across Restarts (v2.9.21)',
      'When the app switches to a backup AI model, it remembers that choice '
          'after you close and reopen. No more retrying a failed key on every cold start.'
    ),
    (
      '📊',
      'FHS Lightweight Mode Fixed (v2.9.21)',
      'Lightweight mode now shows the correct four components: Spending '
          'Restraint, Logging Consistency, Category Balance, and Habit Streak.'
    ),
    (
      '⚠️',
      'Smarter Alerts (v2.9.21–2.9.22)',
      '330%+ velocity alerts suppressed when last month had fewer than 5 '
          'expenses. Student accounts no longer get an "income too low" warning.'
    ),
    (
      '💡',
      'Exchange Rates Always Fresh (v2.9.21)',
      'PHP exchange rates now refresh silently on every app open, even if '
          'the Market Insights card is hidden in App Settings.'
    ),
    (
      '✅',
      'Payment Plan Archive on Completion (v2.9.21)',
      'When you log the final payment on an installment plan, an "Archive" '
          'button lets you clear it from the list immediately.'
    ),
    (
      '🎯',
      'Daily Quests Respect Lightweight Mode (v2.9.21)',
      'Wallet and income quests are now hidden when income tracking is off '
          '— replaced with habit-based quests you can actually complete.'
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
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
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
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
