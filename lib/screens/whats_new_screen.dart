import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/peso_mascot.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '3.3.4';
  static const _prefKey = 'whats_new_seen_3_3_4';

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
      'In-App Auto-Update (v3.3.2)',
      'SmartSpend now detects new releases automatically. Tap Update to download the APK directly with a progress bar — no browser needed. Android installer opens when done.',
    ),
    (
      '📅',
      'Payday-cycle budgeting (v3.3.0)',
      'Budgets now reset on your actual payday cycle. If you receive salary on the 15th and 30th (bi-monthly), your budget period starts on the 15th — not the 1st. Budget screen, FHS score, home alerts, and the add-expense bar all use your real pay cycle.',
    ),
    (
      '📊',
      'Quick Stats — This Month at a Glance (v3.3.0)',
      'A new home screen card shows your monthly snapshot instantly: total spent, average per day, top spending category, and days logged this month.',
    ),
    (
      '🔥',
      'Logging streak badge (v3.3.0)',
      'Log expenses every day and build a streak! The home screen now shows your consecutive daily logging streak.',
    ),
    (
      '🏷️',
      'Home screen section headers (v3.3.0)',
      'The home screen now has clear section labels — YOUR FINANCES, QUICK ACTIONS, GOALS & TRACKING — so you always know what each area is for.',
    ),
    (
      '🌐',
      'OpenRouter AI Gateway (v3.2.5)',
      'SmartSpend now uses openrouter/free — auto-routes to the best available free AI model (Nemotron 550B, Gemma 4, etc.) with a 10-provider fallback chain for 24/7 reliability.',
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
                  // ignore: prefer_const_constructors
                  PesoMascot(size: 80, mood: PesoMood.excited),
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


