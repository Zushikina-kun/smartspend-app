import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.9.4';
  static const _prefKey = 'whats_new_seen_2_9_4';

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
      '⚙️',
      'Minimal Mode — Hide Any Section',
      'App Settings now has "Home Screen" and "Analytics" sections where you can individually hide cards you don\'t need: subscription summary, quick-log chips, badges, mood check-in, forecast, prediction, DTI, emergency fund, milestones, and market insights. Core sections always stay visible.'
    ),
    (
      '🔧',
      'Cleaner Home Screen',
      'Subscription summary and auto-detection prompt no longer show at the same time. Gap dialog now refreshes your FHS score immediately after you answer. Analytics FHS breakdown now matches the home screen score exactly.'
    ),
    (
      '📷',
      'Unified Smart Import',
      'One camera button now opens a 2×2 sheet: Live Camera, Single Photo, Batch Screenshots, Paste Text. Single Photo auto-detects barcodes, receipts, and app screenshots — routes to the right screen automatically.'
    ),
    (
      '🔍',
      'Barcode Detection from Gallery',
      'Pick a photo of a barcode or QR code from your gallery — decoded and sent to AI chat for product lookup, just like the live camera.'
    ),
    (
      '🧠',
      'FHS Explained — Two Modes',
      'Full mode: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency. Lightweight mode: Spending Restraint, Consistency, Category Balance, Habit Streak. Score adjusts automatically for gap days and budget decay.'
    ),
    (
      '📸',
      '40+ Screenshot Types Auto-Detected',
      'Steam, Shopee, Lazada, GCash, Maya, GrabFood, Grab rides, Netflix, Spotify, BPI, BDO, GoTyme, App Store, Google Play, and 30+ more — each gets its own AI extraction prompt.'
    ),
    (
      '🕐',
      'Time Extracted from Screenshots',
      'GCash, Maya, Grab, and bank receipts now include the exact transaction time — not just the date.'
    ),
    (
      '⚖️',
      'FHS Uses Tightest Spending Limit',
      'Set a daily limit? Spending Restraint uses it. Set weekly only? That gets used. The tightest active period always wins.'
    ),
    (
      '🔒',
      'App Lock Fixed for Gallery / Image Picker',
      'Browsing your gallery to pick screenshots no longer triggers the lock screen. The 3-minute timer only starts when the app is actually backgrounded — not when the gallery overlay is open.'
    ),
    (
      '📅',
      'Historical Entries No Longer Trigger Current Alerts',
      'Logging a past-month transaction no longer fires budget alerts, spending limit warnings, impulse pause, wallet deductions, or round-up savings. All those are now correctly scoped to today / this month only.'
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
