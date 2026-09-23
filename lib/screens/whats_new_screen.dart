import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.9.52';
  static const _prefKey = 'whats_new_seen_2_9_52';

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
      '📅',
      'Income Prediction & Payday Countdown (v2.9.52)',
      'A new card on the Home screen shows how many days until your next '
          'expected income, predicted from your last 3 entries. Works for '
          'both salaried and students with irregular allowances. Color-coded: '
          'green = today, blue = coming soon, orange = overdue.',
    ),
    (
      '📊',
      '"What Changed?" Monthly Recap (v2.9.52)',
      'On the first 3 days of each month the app shows a quick alert '
          'comparing last month vs the month before — total spent, whether '
          'you improved, and your top spending category. No AI call needed.',
    ),
    (
      '💬',
      'Export Chat History (v2.9.52)',
      'AI screen → ⋮ menu → "Export Chat History" saves your full '
          'conversation with Peso as a timestamped text file and shares it '
          'via your device\'s share sheet.',
    ),
    (
      '🧠',
      'Smarter AI Categorization (v2.9.52)',
      'The AI no longer drifts on items you\'ve logged many times. If an '
          'item like "Sting" has ≥3 prior entries with 60%+ in one category, '
          'that category wins — regardless of what the AI suggests.',
    ),
    (
      '🔁',
      'Semester Interval Detection (v2.9.52)',
      'The recurring expense detector now recognises semester-spaced '
          'payments (120–135 days) — useful for tuition, school fees, and '
          'other trimestral bills. All intervals now advance correctly.',
    ),
    (
      '🔧',
      'AI Fallback Chain Fixed (v2.9.51)',
      'Critical fix: fallback retries were re-checking the daily message '
          'limit and blocking every provider switch. The chain now walks '
          'through all 8 providers as intended.',
    ),
    (
      '🧭',
      'Nav Bar Overlap Fixed (v2.9.50)',
      'Buttons and inputs hidden behind the 3-button navigation bar on '
          'older Android phones are now fully accessible on all screens.',
    ),
    (
      '🤖',
      'Auto Model Mode (v2.9.50)',
      'New "Auto (Recommended)" AI option routes each task to the best '
          'available model — fast for logging, Flash for financial advice.',
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
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Header banner ──────────────────────────────────────────────
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.new_releases_outlined,
                      size: 40, color: cs.primary),
                  const SizedBox(height: 8),
                  Text(
                    "SmartSpend v$_version",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    "Here's what's new in this update",
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // ── Feature list ───────────────────────────────────────────────
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$1, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                f.$3,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Got it button ──────────────────────────────────────────────
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Let's go!"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
