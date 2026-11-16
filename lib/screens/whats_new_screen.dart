import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/peso_mascot.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '3.2.4';
  static const _prefKey = 'whats_new_seen_3_2_4';

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
      '🌐',
      'OpenRouter AI Gateway (v3.2.3)',
      'SmartSpend now routes through OpenRouter — a unified gateway giving access to 100+ AI models. Auto mode intelligently picks the best available provider, with a 10-provider fallback chain for 24/7 reliability.',
    ),
    (
      '🔄',
      'Smarter AI fallback chain (v3.2.3)',
      'Fixed a critical issue where timeouts would not trigger provider fallback. Now when any provider times out or fails, Peso automatically switches to the next available provider — no more stuck retries.',
    ),
    (
      '🏛️',
      'Government Contributions Tracker (v3.2.0)',
      'Track your SSS, PhilHealth, and Pag-IBIG contributions year-to-date. The first Filipino finance app to treat mandatory government contributions as a first-class expense category. Includes an SSS pension estimator.',
    ),
    (
      '🔗',
      'Official gov portal links (v3.2.0)',
      'Tap any government contribution card to open the official portal — sss.gov.ph, philhealth.gov.ph, or pagibigfund.gov.ph — directly from the app.',
    ),
    (
      '🎨',
      'FHS tier ring (v3.1.2)',
      'Peso now wears a colored ring on the Home screen — green when your Financial Health Score is Good or better, orange for Fair, red for Poor.',
    ),
    (
      '🐛',
      'AI expenses now actually save (v3.1.1)',
      'Fixed a critical bug where Peso said "Got it, logged!" but nothing was saved. This is now fixed — every expense Peso confirms is saved instantly.',
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
