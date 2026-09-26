import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '2.9.62';
  static const _prefKey = 'whats_new_seen_2_9_62';

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
      '💳',
      'Wallet Confirm-Before-Deduct Option (v2.9.62)',
      'New setting in Behavior: "Confirm before deducting" — when on, '
          'a dialog asks "Deduct ₱X from GCash?" before each expense. '
          'Off by default so logging stays fast. Turn it on in Settings → Behavior.',
    ),
    (
      '🎉',
      'Positive Savings Milestone Nudge (v2.9.62)',
      'When you\'re saving ≥20% of your income mid-month, the app sends '
          'a celebratory nudge: "Great progress — you\'ve saved 24% this month!" '
          'Not just alerts when things go wrong.',
    ),
    (
      '📊',
      'Cash Flow + Forecast in One Tabbed Card (v2.9.62)',
      'The Cash Flow and Spending Forecast cards are now combined into '
          'one "Outlook" card with two tabs — tap to switch between them. '
          'Reduces the home screen card count when both are enabled.',
    ),
    (
      '🔔',
      'Smart Suggestions (v2.9.62)',
      'The app now sends forward-looking push notifications once per day: '
          'upcoming bills (3-day warning), high spending pace, goal milestones, '
          'stale income, and shortfall risk. Toggle in Settings → Notifications.',
    ),
    (
      '🧹',
      'Data Quality (v2.9.62)',
      'New "Data Quality" tool in Hub → Tools scans your expenses for issues: '
          'missing timestamps, inconsistent item names, items stuck in Others, '
          'and suspicious round AI-logged amounts. One-tap Fix All.',
    ),
    (
      '💳',
      'Wallet Deduct Confirmation (v2.9.62)',
      'After manually logging an expense, a snackbar now confirms which '
          'wallet was deducted and the new balance — with an Undo button.',
    ),
    (
      '⚙️',
      'Settings Cleanup (v2.9.62)',
      'Removed duplicate mood toggle. Legacy daily limit auto-migrates to '
          'the new multi-period system. Minor dead code removed.',
    ),
    (
      '🤖',
      'Auto Model Now Default for All Users (v2.9.62)',
      'If you upgraded from v2.9.49 or earlier, the app now automatically '
          'switches you to Auto (Recommended) once. No need to manually go '
          'into Settings — Auto routes each task to the best available model.',
    ),
    (
      '💚',
      'Safe to Spend (v2.9.59)',
      'New card on the Home screen showing how much you can spend freely '
          'before your next payday, after reserving upcoming bills, savings '
          'goal contributions, and overdue debts. Green = comfortable, '
          'orange = tight, red = deficit. Toggle in Settings → Home Screen.',
    ),
    (
      '⚠️',
      'AI Advice Disclaimer (v2.9.62)',
      'A one-time dialog now appears before the first financial advice '
          'response — clarifying that Peso is not a licensed financial adviser. '
          'Shown once per account and never again.',
    ),
    (
      '🔍',
      'AI Confidence Review Badge (v2.9.62)',
      'Expense tiles logged by AI with low confidence (< 70%) now show '
          'a small "Review" badge. Tapping it explains why and opens Edit.',
    ),
    (
      '📤',
      'Share from GCash / Any App (v2.9.62)',
      'SmartSpend now appears in the Android share sheet. Share any '
          'transaction text from GCash, Maya, or your bank app directly '
          'into the AI chat — it routes to the same clipboard nudge flow.',
    ),
    (
      '📱',
      'Small Screen Overflow Fixes (v2.9.58)',
      'Fixed 6 more overflow/clipping issues found in the follow-up audit: '
          'Insurance and Paluwagan empty states now scroll instead of '
          'overflowing. FAB screens (Budget, Debt, Recurring, Insurance, '
          'Savings Goals) list padding now adds the system nav bar height '
          'so the last item is never hidden behind the nav bar on 3-button phones.',
    ),
    (
      '💬',
      'AI Chat Chips No Longer Overlap Input (v2.9.57)',
      'Fixed: on small screens, the suggestion chips ("How am I doing '
          'this month?", "What if I cut Food by ₱500/month?", etc.) would '
          'overlap the text input field when the keyboard was open. The '
          'chips area is now scrollable, and the input bar nav clearance '
          'was also corrected to use viewPadding instead of padding.',
    ),
    (
      '🛡️',
      'AI Resilience Fix (v2.9.56)',
      'Fixed: if the app opened without internet and Remote Config keys '
          'hadn\'t loaded yet, AI would silently burn through all 8 providers '
          'with empty keys before showing an error. Now shows a clear '
          '"no internet on startup" message immediately instead.',
    ),
    (
      '🔐',
      'Keys Moved to Remote Config (v2.9.55)',
      'API keys are no longer stored in the app build. They are now fetched '
          'from Firebase Remote Config at startup — future key rotations '
          'require zero code changes or app updates.',
    ),
    (
      '🔑',
      'Groq API Key Rotated (v2.9.54)',
      'The Groq API key was rotated after GitHub Secret Scanning detected '
          'the previous key in a public commit. AI features continue to work '
          'normally — no action needed on your end.',
    ),
    (
      '⚙️',
      'More Home Screen Toggles (v2.9.53)',
      'Three new optional cards can now be turned on/off in App Settings → '
          'Home Screen: Payday Countdown, Monthly Recap alert, and Daily & '
          'Weekly Challenges. All three are also covered by Lite Mode — one '
          'tap hides all 13 optional sections at once.',
    ),
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
