import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App logo + name
            Image.asset(
              'logo.png',
              width: 90,
              height: 90,
              errorBuilder: (_, __, ___) => Icon(Icons.account_balance_wallet,
                  size: 80, color: cs.primary),
            ),
            const SizedBox(height: 12),
            Text(
              "Smart Spend",
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: cs.primary),
            ),
            const Text(
              "Version 2.6.0",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text(
              "AI-Assisted Financial Tracking & Advisory",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),
            _dividerLabel("About the App"),
            const SizedBox(height: 12),

            _infoCard(context, [
              "Smart Spend is an AI-powered mobile financial assistant designed to help users automatically record, analyze, and manage their personal finances with minimal effort.",
              "",
              "Using voice input, OCR receipt scanning, barcode scanning, and natural language processing, Smart Spend converts everyday spending into structured financial data — giving users real-time insights, budget alerts, and personalized AI advice.",
            ]),

            const SizedBox(height: 20),
            _dividerLabel("Key Features"),
            const SizedBox(height: 12),

            _featureList(context, [
              ("🎙️ Voice Input", "Speak your expenses naturally"),
              ("📷 OCR Receipt Scanner", "Scan receipts with your camera"),
              ("📦 Barcode Scanner", "Scan + save barcode history"),
              ("✏️ Manual Entry", "Type expenses in plain language"),
              ("🤖 AI Chat Assistant", "Powered by Groq LLaMA 3.1"),
              (
                "🧾 AI Expense Logging",
                "AI logs expenses, debts, income & goals"
              ),
              ("↩️ Shake to Undo", "Shake phone to undo last AI action"),
              ("📊 Analytics & Charts", "Pie, bar, daily trend + comparison"),
              (
                "🧠 Financial Health Score",
                "4-component formula: Savings, Overspend, Budget, Logging"
              ),
              (
                "📈 FHS Component Breakdown",
                "Score breakdown with contextual literacy tips"
              ),
              (
                "🔮 Spending Forecast",
                "Next month + 3/6/12-month long-range projections"
              ),
              ("💰 Budget Management", "Fixed ₱ or % of income per category"),
              ("🏷️ Want vs Need Tagging", "Tag expenses as Need or Want"),
              ("🎯 Savings Goals", "Track progress toward financial goals"),
              ("💳 Debt & Lending", "Monitor money owed and lent"),
              (
                "🔁 Recurring Transactions",
                "Bills, subscriptions + Log All Due"
              ),
              (
                "📅 Bill Calendar",
                "Unified timeline: bills, debts, goals, installments, income — color-coded by type"
              ),
              (
                "🏆 Achievements & Badges",
                "16 earnable badges for financial milestones"
              ),
              (
                "🎮 Daily Challenges",
                "New challenge every day — complete for bonus score"
              ),
              (
                "📅 Weekly Challenge",
                "Weekly spending or logging challenge with progress tracking"
              ),
              (
                "🏅 Monthly Spending Challenge",
                "Set a monthly spending cap and track progress"
              ),
              (
                "⬆️ Level-Up Notifications",
                "Get notified when your financial health score improves"
              ),
              ("📆 Daily Spending Limit", "Set a daily cap with notifications"),
              (
                "🗂️ Custom Categories",
                "14 built-in + unlimited custom categories (Gaming, Travel, Pets, Gifts & more)"
              ),
              (
                "🔀 Auto-Categorization Rules",
                "Keyword → category rules for faster logging"
              ),
              ("📸 Receipt Photos", "Attach photos to any expense"),
              ("💱 Multi-Currency", "Live exchange rates for 34+ currencies"),
              ("📋 Transactions Log", "Full searchable expense history"),
              ("💾 Backup & Restore", "Export/import data via share sheet"),
              ("🔐 Google Sign-In", "Sign in with your Google account"),
              ("🔒 App Lock", "PIN + biometric lock per account"),
              ("🌙 Dark Mode + Themes", "5 color themes, light & dark mode"),
              ("📤 CSV Export", "Export your data anytime"),
              (
                "📊 50/30/20 Rule",
                "Track Needs/Wants/Savings against the rule"
              ),
              ("🆘 Emergency Fund", "Auto-calculated emergency fund goal"),
              (
                "📅 Installment & Payment Plans",
                "Track phones, gadgets, ShopeePayLater, GCash GLoan & more"
              ),
              (
                "🏦 Import from Bank / GCash",
                "Paste history from GCash, Maya, BDO, BPI, Metrobank, Landbank, RCBC, GoTyme, Tonik, Seabank, GrabPay, ShopeePay & more — AI parses & bulk imports"
              ),
              (
                "🧾 Smart Receipt Import",
                "Scan receipt → AI extracts each item individually → review & bulk import"
              ),
              (
                "🏷️ Transaction Tags",
                "Tag expenses with #hashtags (e.g. #capstone, #shared) — filter by tag in Transactions"
              ),
              (
                "🔄 Subscription Auto-Detection",
                "Automatically detects recurring expense patterns and suggests adding them as recurring transactions"
              ),
              (
                "🌍 Market Insights",
                "Live PHP exchange rates (USD, EUR, GBP, JPY, SGD) + financial literacy tips in Analytics"
              ),
              (
                "🧠 Spending Personality",
                "Auto-computed label from your data — Foodie Spender, Consistent Saver, Disciplined Spender, etc."
              ),
              (
                "🗜️ Conversation Summarization",
                "AI compresses older chat history every 10 messages — stays efficient without losing context"
              ),
              (
                "📅 Payment Plans via AI",
                "Tell the AI about ShopeePayLater, GCash GLoan, or any installment — it creates the plan automatically"
              ),
              (
                "✏️ Bulk Rename via AI",
                "Ask AI to fix capitalization of all expenses — fires update actions for each one"
              ),
              (
                "🔒 App Lock Bypass Fixed",
                "Back button on lock screen no longer bypasses PIN/biometric authentication"
              ),
              (
                "📋 Copy AI Insights",
                "Long-press AI advice or monthly summary to copy to clipboard"
              ),
              (
                "🔍 Enhanced Debug Log",
                "Full diagnostics: FHS breakdown, payment plans, notification state, AI context"
              ),
              ("🔮 Cash Flow Forecast", "30-day projected balance from bills"),
              (
                "💎 Net Worth Tracker",
                "Wallet balances + income − expenses − debts"
              ),
              (
                "💵 Wallet Balances",
                "Cash on Hand, GCash, Maya, BDO, BPI, 30+ PH banks & e-wallets"
              ),
              ("⚙️ App Settings", "Toggle wallet auto-deduct, mood, impulse pause, budget alerts, balance mode"),
              ("📷 Smart Profile Photo", "Google account photo fallback — works across devices without re-picking"),
              ("🤔 AI What-If Scenarios", "Ask 'What if I cut food by ₱500?'"),
              (
                "🔔 Weekly Behavioral Summary",
                "Sunday notification with spending insights"
              ),
              ("⚠️ Anomaly Detection", "Alerts when spending spikes unusually"),
              ("📝 Onboarding Quiz", "Personalizes budgets on first setup"),
              (
                "🆚 Period Comparison Tool",
                "Compare any two months side by side"
              ),
              (
                "📅 Last Month + Month Picker",
                "Filter analytics by any specific month"
              ),
              (
                "📅 Payday Cycle Filter",
                "Analyze spending by your salary cycle"
              ),
              (
                "😊 Daily Mood Check-In",
                "Track mood and correlate with spending"
              ),
              (
                "🧠 Mood-Spend Correlation",
                "See how mood affects your spending patterns"
              ),
              ("📝 Mood Notes", "Add a personal note to each daily mood entry"),
              (
                "🎯 Impulse Pause Mechanic",
                "Reflection prompt for large Want purchases"
              ),
              (
                "📢 Loss Aversion Alerts",
                "Budget alerts linked to your savings goals"
              ),
              (
                "📈 Category Velocity Alerts",
                "Warns when a category grows faster than income"
              ),
              (
                "⭐ Windfall Income Flag",
                "Mark one-time income separately from regular"
              ),
              (
                "☕ Micro-Expense Clustering",
                "See how small frequent purchases add up"
              ),
              (
                "🔔 Subscription Summary",
                "Total monthly subscription cost at a glance"
              ),
              (
                "📝 Monthly Plain-English Summary",
                "AI writes a paragraph summary of your month"
              ),
              (
                "💡 Financial Literacy Tips",
                "Contextual tips when score components are low"
              ),
              ("📊 Day-of-Week Heatmap", "See which days you spend the most"),
              (
                "🔍 Confidence Filter",
                "Filter transactions by AI confidence score"
              ),
              (
                "💳 Payment Method Chart",
                "See spending breakdown by Cash/GCash/Card"
              ),
              (
                "🏪 Top Merchants",
                "See your most-visited shops and restaurants"
              ),
              (
                "📈 Income Analytics",
                "Charts and breakdown of all income sources"
              ),
              (
                "📊 Score History Annotations",
                "See what caused score changes on the history chart"
              ),
              (
                "🔗 Scan History Linked to Expenses",
                "Tap any scan to see the expense it created"
              ),
              (
                "✅ Done Spending Today Toggle",
                "Commit to no more spending — get a gentle reminder if you do"
              ),
              (
                "🎯 Goal Pace Indicator",
                "See if you're on track to hit your savings goal by deadline"
              ),
              (
                "💸 Net Worth Sparkline",
                "Mini trend chart of your net worth over time"
              ),
              (
                "📋 Where Did My Money Go?",
                "Quick summary card of top spending categories"
              ),
            ]),

            const SizedBox(height: 20),
            _dividerLabel("Technology Stack"),
            const SizedBox(height: 12),

            _infoCard(context, [
              "Framework: Flutter (Dart)",
              "AI Engine: Groq API — LLaMA 3.1 8B Instant",
              "Local Database: SQLite (sqflite) v11",
              "Cloud Auth & Sync: Firebase Auth + Firestore",
              "Synced collections: expenses, budgets, goals, income, recurring, debts, custom_categories, installment_plans, wallets, category_rules",
              "OCR: Google ML Kit Text Recognition",
              "Charts: fl_chart",
              "Backup v8: System share sheet — expenses, budgets, goals, income, recurring, debts, payment plans, categories, rules, mood log, wallets (file_picker for restore)",
              "App Lock: local_auth (PIN + biometric, per-account)",
              "Exchange Rates: open.er-api.com",
              "Crash Reporting: Firebase Crashlytics",
              "API Config: AppConfig (centralized, .gitignore protected)",
            ]),

            const SizedBox(height: 20),
            _dividerLabel("Developed By"),
            const SizedBox(height: 12),

            _teamCard(context),

            const SizedBox(height: 20),
            _dividerLabel("Academic Information"),
            const SizedBox(height: 12),

            _infoCard(context, [
              "Group Name: Lucid Frame",
              "Project Type: Capstone / Thesis Project",
              "Platform: Android Mobile Application",
              "Academic Year: 2025–2026",
              "School: Lorma Colleges — CCSE, BSIT",
              "Location: City of San Fernando, La Union",
            ]),

            const SizedBox(height: 12),
            // Lorma Colleges logo
            Image.asset(
              'LormaLogo.jpg',
              height: 48,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),
            _dividerLabel("Disclaimer"),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Text(
                "Smart Spend is an academic project intended for educational and demonstration purposes. "
                "Tax estimations are approximations only and do not constitute official financial or tax advice. "
                "AI-generated insights are based on user-provided data and should not replace professional financial consultation.",
                style: TextStyle(fontSize: 12, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Lucid Frame group logo
            Image.asset(
              'LucidFrameLogo.png',
              height: 56,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),

            Text(
              "© 2026 Lucid Frame. All rights reserved.",
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.4), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _dividerLabel(String label) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _infoCard(BuildContext context, List<String> lines) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          if (line.isEmpty) return const SizedBox(height: 6);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child:
                Text(line, style: const TextStyle(fontSize: 13, height: 1.5)),
          );
        }).toList(),
      ),
    );
  }

  Widget _featureList(BuildContext context, List<(String, String)> features) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final i = entry.key;
          final f = entry.value;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(f.$1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(f.$2,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.6))),
                    ),
                  ],
                ),
              ),
              if (i < features.length - 1)
                Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _teamCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final members = [
      ("Brix A. Directo", "Lead Developer", "Devs/BRIX A. DIRECTO.png"),
      (
        "Cyrille John M. Rubis",
        "UI/UX Designer & Documentation Lead",
        "Devs/CYRILLE JOHN M. RUBIS.png"
      ),
      (
        "Djaunathan Albert S. Madayag",
        "Project Manager & QA Lead",
        "Devs/DJAUNATHAN ALBERT S. MADAYAG.png"
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Lucid Frame group logo at top of team card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Image.asset(
                  'LucidFrameLogo.png',
                  height: 32,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 10),
                Text(
                  "Lucid Frame",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: cs.primary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
          ...members.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.primary,
                    backgroundImage: AssetImage(m.$3),
                    onBackgroundImageError: (_, __) {},
                  ),
                  title: Text(m.$1,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(m.$2,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.6))),
                ),
                if (i < members.length - 1)
                  Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
              ],
            );
          }),
        ],
      ),
    );
  }
}
