import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UX-5: What's New screen — shown once after each version update.
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const _version = '3.0.3';
  static const _prefKey = 'whats_new_seen_3_0_3';

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
      '📱',
      'Use Without an Account (v3.0.3)',
      'Tap "Continue Without Account" on the login screen to start tracking your own finances with zero sign-up. '
          'Your data lives on this device. Back it up anytime with the CSV export or backup feature. '
          'Connect a free account later from Profile to sync across devices — your data stays intact.',
    ),
    (
      '☕',
      'Support the Developer (v3.0.2)',
      'About screen now has a "Support the Project" section — tap Buy Me a Coffee, Ko-fi, or PayPal to support. '
          'GCash/PayMaya number copies to clipboard with one tap. '
          'Free forever — support is optional and always appreciated.',
    ),
    (
      '🔍',
      'Transaction Sort & Grouping (v3.0.0)',
      'Sort transactions by date, logged date, amount, name, or source. '
          'Group by date, logged date, category, or source — with collapsible '
          'headers and subtotals. Category filter is now a dropdown. '
          'Transaction date and logged date are shown separately.',
    ),
    (
      '💬',
      'Chat Sessions & Wayback (v3.0.0)',
      'AI chats are now organized into sessions. Tap "New Chat" (+ icon) to '
          'start fresh — previous conversations are saved. Chat History shows a '
          'session list; tap any session to read it. Archive or delete anytime.',
    ),
    (
      '🤖',
      'AI Recovery: Session Summary Card (v3.0.0)',
      'After the AI logs expenses, a card shows which items were ✅ recorded, '
          '⚠️ skipped (already in DB), or ❌ failed. Tap "Review & re-log" to '
          'fix missing items directly — no need to re-describe them.',
    ),
    (
      '📊',
      'Analytics Quick Jump & Improvements (v3.0.0)',
      'Four Quick Jump chips let you jump to Overview, Trends, Health, or AI Advice. '
          'Period chips now have a "More" menu for Payday Cycle / Custom Range. '
          'Category breakdown has a sort toggle: Amount, Name, or Δ vs last month.',
    ),
    (
      '🏠',
      'Local AI — Private Mode (v2.9.92)',
      'Connect SmartSpend to your own LLM running on your PC/Mac. '
          'Your financial data never leaves your home network — '
          'no Gemini, no Groq, no cloud at all. '
          'Settings → AI Model → Local AI. Built-in setup guide walks you through '
          'Ollama, LM Studio, and Jan with hardware-matched model recommendations. '
          'Cloud AI remains as automatic fallback when your local server is offline.',
    ),
    (
      '🛡️',
      'Delete Confirmations Everywhere (v2.9.90)',
      'Paluwagan groups, insurance policies, wallets, and individual expenses '
          'now all ask for confirmation before deleting. Also fixed: completing '
          'a payment plan no longer destroys the record — it stays in the '
          'Completed section for reference.',
    ),
    (
      '📖',
      'Full Audit Trail (v2.9.89–90)',
      'Every change to your wallet balance, budget, savings goal, or monthly '
          'income is now logged with who made it (you, AI, salary split, undo). '
          'Long-press a budget card, tap the history icon on a goal, or tap '
          'the history icon in Income to see the full change log.',
    ),
    (
      '📈',
      'FHS Score Reason on Tap (v2.9.90)',
      'The Financial Health Score history chart in Analytics now shows a '
          'tooltip when you tap a dot: the date, score, and which component '
          'was lowest that day — e.g. "Oct 5: 75 — Lowest: Savings Rate (8/25 pts)".',
    ),
    (
      '💵',
      'Wallet History from Home Screen (v2.9.90)',
      'Long-press the wallet summary card on the home screen to view '
          'balance change history for any wallet — directly without going to Profile.',
    ),
    (
      '🏆',
      'Achievement Celebrations (v2.9.84)',
      'When you unlock a new badge for the first time — like a savings streak, '
          'reaching a goal, or scanning 10 receipts — a golden SnackBar now '
          'celebrates the moment with the badge emoji and what you earned.',
    ),
    (
      '📊',
      'Analytics Interpretive Labels (v2.9.84)',
      'The Monthly Spending chart now tells you if this month is above or below '
          'your average — e.g. "📈 This month is 23% above your average". '
          'The Savings Rate chart shows how far you are from the 20% target.',
    ),
    (
      '💬',
      'AI Chat Date Dividers (v2.9.84)',
      'Long chat sessions now show Today / Yesterday / date dividers '
          'between message groups so you can orient yourself in long conversations.',
    ),
    (
      '🛡️',
      'Delete Confirmations Everywhere (v2.9.83)',
      'Budget categories, debts, installment plans, recurring bills, savings '
          'goals, and income entries all now ask for confirmation before deleting. '
          'No more accidental data loss.',
    ),
    (
      '🎯',
      'Peso Empty States (v2.9.82)',
      'Empty screens now show Peso with a friendly Taglish tip instead of a '
          'plain grey icon. Covers Savings Goals, Recurring, Transactions, '
          'Income, Manage Categories, and Manage Rules.',
    ),
    (
      '🪙',
      'Meet Peso! (v2.9.76)',
      'SmartSpend now has a mascot — Peso the coin! A friendly round ₱ coin '
          'character who greets you in setup, pops up on empty screens with '
          'helpful tips in Filipino/English, and shows sad when offline. '
          'Look for Peso in the "Peso" tab at the bottom.',
    ),
    (
      '💚',
      'Emerald theme — Peso\'s color (v2.9.76)',
      'New "Emerald" theme (#00C896) is now the default for new installs. '
          'Fresh, modern, easy on the eyes. Change it anytime in Settings → Quick Presets.',
    ),
    (
      '📊',
      'Monthly Wrapped card (v2.9.76)',
      'On the first 3 days of each month, a shareable "Your Month in Review" '
          'card shows Peso celebrating your stats: total spent, top category, '
          'most-logged item, savings rate, and FHS score.',
    ),
    (
      '🚀',
      'Prepare Demo Phone (v2.9.73)',
      'Profile → Prepare Demo Phone: one tap before the defense fixes '
          'duplicate entries, corrects mislabeled categories, logs 12 weeks of '
          'income so all home screen features have real data, and resets the AI daily limit.',
    ),
    (
      '🔄',
      'Reset AI State (v2.9.73)',
      'AI screen → ⋮ → Reset AI State (green, top of menu): resets model to Auto, '
          'clears the daily message counter, and wipes in-memory chat history. '
          'One tap to clean demo state mid-presentation.',
    ),
    (
      '⚡',
      'Quick Income Log chip (v2.9.70)',
      'When your expected income is overdue, a green chip appears on the home '
          'screen with your last average amount. One tap logs it instantly — '
          'no form, no navigation.',
    ),
    (
      '↩️',
      'AI Undo History in Transactions (v2.9.70)',
      'Transactions now shows a card at the top with the last 3 AI-logged '
          'expenses from the past 24 hours. Each has a Remove button — '
          'faster than finding and deleting from the full list.',
    ),
    (
      '✏️',
      'Quick-Edit on Long-Press (v2.9.70)',
      'Long-press any expense on the home screen to instantly edit its '
          'amount and category — without opening the full edit form.',
    ),
    (
      '📊',
      'Weekly Accountability Check-In (v2.9.70)',
      'A new weekly push notification fires once per week showing your '
          'top spending category and whether you stayed under your '
          'weekly budget target.',
    ),
    (
      '💡',
      'Smart Budget Suggestions (v2.9.70)',
      'If you have expenses but no budgets set, the Budgets screen now '
          'shows suggested amounts based on your actual spending history — '
          'rounded to the nearest ₱50. Tap any to set it, or Apply All.',
    ),
    (
      '⭐',
      'Most Used shortcuts in Tools (v2.9.70)',
      'The Tools & Hub sheet now tracks which items you open most. After '
          'tapping any item twice, it appears in a Most Used row at the '
          'top for faster access.',
    ),
    (
      '🎛️',
      'Experience Presets (v2.9.69)',
      '🪶 Lite (essentials only), 😊 Casual (regular tracker), '
          '⚖️ Normal (balanced — recommended), and 🚀 Pro (everything on). '
          'Find them in Settings → Quick Presets. Individual toggles below still work.',
    ),
    (
      '🔧',
      'Hub renamed to Tools (v2.9.69)',
      'The bottom nav item is now labelled "Tools" instead of "Hub" — '
          'clearer for new users. The sheet title is "Tools & Hub".',
    ),
    (
      '🎨',
      'Slate Theme + Color Cleanup (v2.9.68)',
      'New "Slate" color theme added (#334155) — now the default for new '
          'installs. It\'s cleaner and easier on the eyes during demos. '
          'Decorative card colors (purple, teal, blue, orange) removed '
          'from the home screen — color is now reserved for status only.',
    ),
    (
      '🤖',
      'AI Quick-Input Bar on Home (v2.9.68)',
      'You can now ask the AI or log an expense without leaving the home '
          'screen — just type in the bar at the bottom and tap Send. '
          'The reply appears as a snackbar with a "Full Chat" button.',
    ),
    (
      '💳',
      'Debt Payoff Calculator (v2.9.68)',
      'Tools → Tools → Debt Payoff Calculator. Enter your monthly budget, '
          'and it simulates both avalanche (highest rate first) and snowball '
          '(lowest balance first) strategies — showing months to freedom '
          'and total interest paid for each.',
    ),
    (
      '🏁',
      'Goals Timeline on Home (v2.9.68)',
      'The home screen now shows a horizontal timeline of your active savings '
          'goals with projected completion dates based on your contribution rate.',
    ),
    (
      '📈',
      'True Net Worth Chart on Profile (v2.9.68)',
      'The Profile tab now shows a real Net Worth chart: '
          'wallet balances + goal savings − outstanding debts, '
          'plotted over the last 6 months using your actual income and expense data.',
    ),
    (
      '🔧',
      'Audit Fixes (v2.9.67)',
      'Home Customize shortcut now shows all 10 toggles (was missing '
          'Payday Countdown, Safe-to-Spend, Monthly Recap, Challenges). '
          'Groq limit indicator now correctly highlights all Groq models. '
          'Wallet confirm-before-deduct now works from AI chat too, not just manual entry.',
    ),
    (
      '🤖',
      'Auto Model Sticky Fix (v2.9.67)',
      'Fixed: after 3 consecutive AI failures, the app was saving the '
          'fallback model (Groq) to disk — permanently replacing Auto until '
          'the user manually switched back. Fallback is now session-only. '
          'Auto mode also self-restores on next cold start when Gemini keys '
          'load successfully from Remote Config.',
    ),
    (
      '💳',
      'Wallet Confirm-Before-Deduct Option (v2.9.67)',
      'New setting in Behavior: "Confirm before deducting" — when on, '
          'a dialog asks "Deduct ₱X from GCash?" before each expense. '
          'Off by default so logging stays fast. Turn it on in Settings → Behavior.',
    ),
    (
      '🎉',
      'Positive Savings Milestone Nudge (v2.9.67)',
      'When you\'re saving ≥20% of your income mid-month, the app sends '
          'a celebratory nudge: "Great progress — you\'ve saved 24% this month!" '
          'Not just alerts when things go wrong.',
    ),
    (
      '📊',
      'Cash Flow + Forecast in One Tabbed Card (v2.9.67)',
      'The Cash Flow and Spending Forecast cards are now combined into '
          'one "Outlook" card with two tabs — tap to switch between them. '
          'Reduces the home screen card count when both are enabled.',
    ),
    (
      '🔔',
      'Smart Suggestions (v2.9.67)',
      'The app now sends forward-looking push notifications once per day: '
          'upcoming bills (3-day warning), high spending pace, goal milestones, '
          'stale income, and shortfall risk. Toggle in Settings → Notifications.',
    ),
    (
      '🧹',
      'Data Quality (v2.9.67)',
      'New "Data Quality" tool in Tools → Tools scans your expenses for issues: '
          'missing timestamps, inconsistent item names, items stuck in Others, '
          'and suspicious round AI-logged amounts. One-tap Fix All.',
    ),
    (
      '💳',
      'Wallet Deduct Confirmation (v2.9.67)',
      'After manually logging an expense, a snackbar now confirms which '
          'wallet was deducted and the new balance — with an Undo button.',
    ),
    (
      '⚙️',
      'Settings Cleanup (v2.9.67)',
      'Removed duplicate mood toggle. Legacy daily limit auto-migrates to '
          'the new multi-period system. Minor dead code removed.',
    ),
    (
      '🤖',
      'Auto Model Now Default for All Users (v2.9.67)',
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
      'AI Advice Disclaimer (v2.9.67)',
      'A one-time dialog now appears before the first financial advice '
          'response — clarifying that Peso is not a licensed financial adviser. '
          'Shown once per account and never again.',
    ),
    (
      '🔍',
      'AI Confidence Review Badge (v2.9.67)',
      'Expense tiles logged by AI with low confidence (< 70%) now show '
          'a small "Review" badge. Tapping it explains why and opens Edit.',
    ),
    (
      '📤',
      'Share from GCash / Any App (v2.9.67)',
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
