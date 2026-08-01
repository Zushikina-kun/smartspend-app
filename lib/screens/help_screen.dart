import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _sections
        .where((s) =>
            _search.isEmpty ||
            s.title.toLowerCase().contains(_search.toLowerCase()) ||
            s.items.any((i) =>
                i.title.toLowerCase().contains(_search.toLowerCase()) ||
                i.body.toLowerCase().contains(_search.toLowerCase())))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Guide"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: "Search features...",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        })
                    : null,
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text("No results for \"$_search\"",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: filtered.length,
              itemBuilder: (_, si) {
                final section = filtered[si];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Row(
                        children: [
                          Icon(section.icon, size: 18, color: section.color),
                          const SizedBox(width: 8),
                          Text(section.title,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: section.color)),
                        ],
                      ),
                    ),
                    ...section.items.map((item) => _HelpCard(item: item)),
                  ],
                );
              },
            ),
    );
  }
}

class _HelpCard extends StatefulWidget {
  final _HelpItem item;
  const _HelpCard({required this.item});

  @override
  State<_HelpCard> createState() => _HelpCardState();
}

class _HelpCardState extends State<_HelpCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(widget.item.body,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: cs.onSurface.withValues(alpha: 0.75))),
                if (widget.item.example != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 14, color: cs.primary.withValues(alpha: 0.7)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(widget.item.example!,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: cs.onSurface.withValues(alpha: 0.7))),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── DATA ──────────────────────────────────────────────────────

class _HelpSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<_HelpItem> items;
  const _HelpSection(
      {required this.title,
      required this.icon,
      required this.color,
      required this.items});
}

class _HelpItem {
  final String title;
  final String body;
  final String? example;
  const _HelpItem({required this.title, required this.body, this.example});
}

const _sections = [
  _HelpSection(
    title: "Getting Started",
    icon: Icons.rocket_launch_outlined,
    color: Colors.blue,
    items: [
      _HelpItem(
        title: "What is Smart Spend?",
        body:
            "Smart Spend is an AI-powered financial assistant for your phone. It helps you track expenses, manage budgets, set savings goals, and get personalized financial advice — all by just talking to it naturally.",
        example:
            "Think of it as a smart money diary that understands plain language.",
      ),
      _HelpItem(
        title: "How do I set up my account?",
        body:
            "On first launch, choose your account type (Student, Employed, Business Owner, etc.) and enter your monthly income or allowance. This helps the AI give you relevant advice and set appropriate budget suggestions.",
        example:
            "Student with ₱6,600/month allowance → AI suggests food budget of ₱1,980 (30%).",
      ),
      _HelpItem(
        title: "Demo Mode",
        body:
            "Don't have an account yet? Tap 'Try Demo' on the login screen. It loads realistic sample data so you can explore all features without signing up. Demo data is automatically cleared when you log in with a real account.",
      ),
    ],
  ),
  _HelpSection(
    title: "AI Assistant",
    icon: Icons.smart_toy_outlined,
    color: Color(0xFF7C3AED),
    items: [
      _HelpItem(
        title: "How do I log an expense?",
        body:
            "Tap the AI button in the bottom bar. Just type or speak what you spent — the AI understands natural language and logs it automatically.",
        example:
            '"I spent 150 pesos on lunch at Jollibee" → AI logs ₱150 under Food.',
      ),
      _HelpItem(
        title: "What else can the AI do?",
        body:
            "The AI can manage almost everything in the app via chat. It supports 29+ action types:\n\n"
            "📝 Expenses: log, update (fix category/amount/name/date), delete (requires typing DELETE)\n"
            "💰 Income: set monthly income, log income entries\n"
            "📊 Budgets: set or update category budgets\n"
            "🎯 Goals: add savings goals, contribute to goals, delete goals\n"
            "💳 Debts: add debts/lending, record payments toward debts\n"
            "🔁 Recurring: add recurring bills/subscriptions, delete recurring\n"
            "📅 Payment Plans: add installment plans (ShopeePayLater, GCash GLoan, etc.)\n"
            "👤 Account: change account type (student, employed, etc.)\n\n"
            "Beyond the app, the AI can also discuss:\n"
            "🏦 Philippine banking (GCash, Maya, BDO, BPI)\n"
            "📋 SSS, PhilHealth, Pag-IBIG — how to apply, benefits\n"
            "📈 Investments — MP2, time deposits, stocks, crypto basics\n"
            "🛒 Prices & deals in the Philippines\n"
            "💡 Financial literacy and budgeting strategies",
        example:
            '"Add a ShopeePayLater plan, ₱373/month for 3 months due on the 5th" → Payment Plan created instantly.',
      ),
      _HelpItem(
        title: "How do I fix a wrong entry?",
        body:
            "Just tell the AI what to fix. It will update the existing entry instead of creating a new one.\n\n"
            "You can fix: category, amount, item name, or all three at once.",
        example:
            '"Change the Sting drink from Others to Food" → Category updated.\n"Rename jeepney fare to Jeepney Fare" → Name updated.',
      ),
      _HelpItem(
        title: "How do I fix capitalization of multiple expenses?",
        body:
            "Tell the AI to fix the capitalization of your expenses and it will update all of them at once.\n\n"
            "The AI fires one update action per expense — you'll see green snackbars for each one.",
        example:
            '"Fix the capitalization of my expenses this week" → AI renames all expenses with proper capitalization.',
      ),
      _HelpItem(
        title: "How do I delete an entry?",
        body:
            "Ask the AI to delete it, then type DELETE (in caps) to confirm. This is a safety measure to prevent accidental deletions. Always specify the item name clearly.",
        example: '"Delete the movie ticket entry: DELETE" → Entry removed.',
      ),
      _HelpItem(
        title: "What-If scenarios",
        body:
            "Ask the AI to calculate the impact of spending changes. It projects savings over 3, 6, and 12 months.",
        example:
            '"What if I cut my food spending by 500 pesos a month?" → AI shows projected savings.',
      ),
      _HelpItem(
        title: "Daily message limit",
        body:
            "The AI has a limit of 60 messages per day to protect the shared API key. The remaining count is shown in the top bar. It resets at midnight UTC. You can reset it manually via the ⋮ menu → Reset Daily Limit.",
      ),
      _HelpItem(
        title: "Language",
        body:
            "The AI defaults to English. It switches to Filipino only if you write full Filipino sentences or explicitly ask it to. To switch back: 'Please respond in English only.'",
      ),
    ],
  ),
  _HelpSection(
    title: "Tracking Mode & Spending Limit",
    icon: Icons.tune_outlined,
    color: Colors.teal,
    items: [
      _HelpItem(
        title: "What is Lightweight Mode?",
        body:
            "Lightweight Mode lets you use Smart Spend without entering any income or managing wallets. "
            "It's designed for users who just want to track spending habits.\n\n"
            "To enable: Profile → ⚙️ App Settings → Tracking Mode → Turn off 'Track income & wallets'\n\n"
            "When OFF:\n"
            "• Wallet card, allowance button, and income card are hidden on the home and profile screens\n"
            "• The AI skips income and wallet advice\n"
            "• Financial Health Score recalculates using 4 new habit-based components\n\n"
            "When ON (default for existing users):\n"
            "• Full experience — wallets, income, savings rate, net worth all visible",
        example:
            "New user with no steady income → turn off income tracking → app still gives a meaningful FHS based on spending consistency.",
      ),
      _HelpItem(
        title: "Financial Health Score in Lightweight Mode",
        body:
            "When income/wallet tracking is OFF, the 4 FHS components change:\n\n"
            "1. Spending Restraint (25pts) — Did you stay within your spending limit this period? If no limit set, uses your Want/Need ratio instead.\n\n"
            "2. Logging Consistency (25pts) — How many days did you log at least one expense vs active days?\n\n"
            "3. Category Balance (25pts) — Is spending spread across categories? Full score when no single category exceeds 40% of total.\n\n"
            "4. Habit Streak (25pts) — How many consecutive days did you log expenses? Full score at 14 days.",
        example:
            "You logged 10 of 14 days, stayed under your limit, and spread spending across 5 categories → ~75/100 FHS.",
      ),
      _HelpItem(
        title: "What is the Spending Limit?",
        body:
            "The Spending Limit lets you set a single total cap for your spending over a chosen period — without needing to set per-category budgets.\n\n"
            "To set: Profile → ⚙️ App Settings → Spending Limit → pick a period (Day/Week/Month/Year) → enter an amount → tap ✓\n\n"
            "A progress bar appears on the home screen showing how much of your limit you've used.\n\n"
            "Warnings:\n"
            "• At 80%: orange warning — 'X% of limit used'\n"
            "• At 100%+: red alert — 'Limit exceeded by ₱X'\n\n"
            "Works in both full mode and lightweight mode. You can also have category budgets AND a spending limit — they operate independently.",
        example:
            "Set ₱500/day limit → spent ₱420 → bar shows 84%, orange warning.\nSet ₱5,000/month → spent ₱5,100 → red 'exceeded by ₱100'.",
      ),
      _HelpItem(
        title: "How does the Logging Gap check work?",
        body:
            "On app startup (once per day), Smart Spend checks if you had any days without logged expenses since your last session.\n\n"
            "If gaps are found, a dialog appears per gap asking:\n"
            "• 'Yes, I spent' — you spent but forgot to log → FHS gets a small penalty (−3 pts per day, max −15)\n"
            "• 'Nope, nothing' — genuinely no spending → FHS gets a bonus (+2 pts per day, max +10)\n\n"
            "This makes your score reflect reality instead of penalising you for days you simply had nothing to log.\n\n"
            "You can tap 'Skip' to answer later. Gap counters reset at the start of each month.",
        example:
            "Didn't log for 3 days. App asks. You say 'clean days' → FHS +6 pts bonus for confirmed no-spending.",
      ),
      _HelpItem(
        title: "Batch Screenshot Import — How does it work?",
        body:
            "Tap the 📷 photo library icon in the AI chat (or Profile → Batch Screenshot Import) to import purchases from multiple screenshots at once.\n\n"
            "Supported platforms (40+ types auto-detected):\n"
            "• 🎮 Gaming: Steam, Google Play, App Store, Codashop, UniPin, Garena, MLBB, Genshin, Valorant, PlayStation, Xbox, Nintendo\n"
            "• 🛍️ PH Shopping: Shopee, Lazada, Zalora, TikTok Shop, Carousell\n"
            "• 🌐 International: Amazon, AliExpress, Shein, Temu, eBay, Etsy, Taobao\n"
            "• 🍔 Food Delivery: GrabFood, Foodpanda, Shopee Food\n"
            "• 🚗 Transport: Grab rides, Angkas, Lalamove, Maxim\n"
            "• 💳 E-wallets: GCash, Maya, GrabPay, ShopeePay, Coins.ph, PayPal, Wise\n"
            "• 🏦 Banks: BPI, BDO, Metrobank, UnionBank, GoTyme, Tonik, SeaBank\n"
            "• 📺 Streaming: Netflix, Spotify, YouTube, Disney+, Viu, Vivamax\n"
            "• 🧾 Physical receipts: fast food, grocery, pharmacy, utility bills\n\n"
            "How to use:\n"
            "1. Tap the photo library icon in the AI chat\n"
            "2. Pick up to 10 screenshots from your gallery\n"
            "3. Tap 'Extract' — the app OCRs each image and calls the AI\n"
            "4. Review the extracted items — edit name, amount, category, date, or want/need tag\n"
            "5. Tap 'Import' to add all selected items to your expenses\n\n"
            "Tip: GCash, bank apps, and Grab show exact transaction times — the app extracts these too, not just the date.",
        example:
            "Pick 5 Steam purchase screenshots → Extract → AI finds 5 game purchases with titles, prices, dates → review → import all at once.",
      ),
    ],
  ),
  _HelpSection(
    title: "Financial Health Score (FHS)",
    icon: Icons.health_and_safety_outlined,
    color: Colors.green,
    items: [
      _HelpItem(
        title: "What is the Financial Health Score?",
        body:
            "The Financial Health Score (FHS) is a 0–100 score calculated from your current month's expense data. It appears on your home screen, profile, analytics, and the shareable Financial Health Certificate.\n\n"
            "The score is made of 4 components, each worth up to 25 points. The components depend on which tracking mode you're using in Settings:\n\n"
            "───────────────────────────────\n"
            "FULL MODE (Track income & wallets: ON)\n"
            "───────────────────────────────\n"
            "1. Savings Rate (25pts)\n"
            "   How much of your income you save vs the 20% target.\n"
            "   Full score when saving ≥20% of income. Scales down below that.\n\n"
            "2. Overspend Control (25pts)\n"
            "   Days where your spending stayed within your daily budget.\n"
            "   Full score when no days exceeded. 0 pts when every day exceeded.\n\n"
            "3. Budget Adherence (25pts)\n"
            "   Percentage of your category budgets that stayed within their limit.\n"
            "   Full score when all budgets are on track. No budgets set = full score (not penalised).\n\n"
            "4. Logging Consistency (25pts)\n"
            "   How regularly you log expenses vs active days in the period.\n"
            "   Full score when logging every day.\n\n"
            "───────────────────────────────\n"
            "LIGHTWEIGHT MODE (Track income & wallets: OFF)\n"
            "───────────────────────────────\n"
            "1. Spending Restraint (25pts)\n"
            "   Did you stay within your spending limit this period?\n"
            "   If no limit is set, uses your Want/Need ratio instead.\n\n"
            "2. Logging Consistency (25pts)\n"
            "   Same formula as full mode — logged days vs active days.\n\n"
            "3. Category Balance (25pts)\n"
            "   Is spending spread across categories? Full score when no single category exceeds 40% of total.\n\n"
            "4. Habit Streak (25pts)\n"
            "   Consecutive days with at least one expense logged. Full score at 14 days.",
        example:
            "Full mode: Income ₱15,000, spent ₱12,000, saved ₱3,000 (20%) = 25 pts Savings Rate.\nLightweight mode: 12-day streak = 21/25 pts Habit Streak.",
      ),
      _HelpItem(
        title: "What adjustments are applied to the score?",
        body:
            "After the 4 components are totalled (0–100), two adjustments are applied:\n\n"
            "1. Warning Decay (−5 pts/day, max −15)\n"
            "   If you exceeded a budget and spending continued the next day, the score loses 5 pts/day.\n"
            "   Resets when all budgets return to on-track.\n\n"
            "2. Gap Adjustment (−3 or +2 pts/day)\n"
            "   When the app detects days with no logged expenses, it asks you on startup:\n"
            "   • If you say 'Yes I spent but forgot to log' → −3 pts per gap day (max −15)\n"
            "   • If you say 'No spending, clean days' → +2 pts per clean day (max +10)\n"
            "   This makes the score reflect reality instead of penalising silence.\n\n"
            "Both adjustments are cleared at the start of each month.",
        example:
            "Raw score 75 → budget warning ignored 2 days (−10) → confirmed 3 clean no-spend days (+6) = Final score 71.",
      ),
      _HelpItem(
        title: "How do I improve my score?",
        body: "Full Mode:\n"
            "• Save at least 20% of your income\n"
            "• Stay within your daily budget (income ÷ days in month)\n"
            "• Set category budgets and keep spending below them\n"
            "• Log expenses every day — even ₱0 days count for consistency\n\n"
            "Lightweight Mode:\n"
            "• Set a spending limit (Profile → Spending Limits) — Spending Restraint gets a real benchmark\n"
            "• Log something every day — Habit Streak is the fastest way to boost your score\n"
            "• Spread spending across categories — avoid one category dominating\n\n"
            "Both modes:\n"
            "• When asked about logging gaps, be honest — confirmed clean days give bonus points\n"
            "• Don't ignore budget warnings — the Warning Decay resets when you get back on track",
      ),
      _HelpItem(
        title: "Where does the score appear?",
        body: "The FHS score appears in multiple places:\n\n"
            "• Home screen — main score card with a tap for full breakdown\n"
            "• Profile screen — score card with component breakdown and tips\n"
            "• Analytics screen — score history chart + component breakdown chart\n"
            "• AI chat — AI knows your current score and can explain it\n"
            "• Financial Health Certificate — shareable monthly score card\n"
            "• Achievements screen — badges for reaching 60/70/80/90+\n"
            "• Startup alert — notifies you if score drops 10+ points overnight",
      ),
    ],
  ),
  _HelpSection(
    title: "Smart Import",
    icon: Icons.camera_enhance_outlined,
    color: Colors.teal,
    items: [
      _HelpItem(
        title: "What is Smart Import?",
        body:
            "Smart Import is a single unified entry point for importing expenses from any source — camera, gallery, screenshots, or pasted text.\n\n"
            "Tap the 📷 camera icon in the AI chat to open it. You'll see 4 options:\n\n"
            "1. Live Camera — Point at a barcode/QR or tap the shutter to scan a receipt or transaction document\n\n"
            "2. Single Photo — Pick one image from your gallery. The app automatically detects what it is:\n"
            "   • Barcode/QR code → product lookup → describe in AI chat\n"
            "   • App screenshot (Steam/Shopee/GCash/etc.) → AI extracts items\n"
            "   • Receipt or transaction history → text-based import screen\n\n"
            "3. Batch Screenshots — Pick up to 10 screenshots at once. Each is analysed independently with a platform-specific AI prompt. Supports 40+ platforms.\n\n"
            "4. Paste Text — Open the import screen to paste GCash history, BPI CSV, or any bank statement text.",
        example:
            "Tap 📷 → Single Photo → pick a GCash screenshot → app detects it's GCash → extracts your payments automatically.",
      ),
      _HelpItem(
        title: "What platforms does Batch Screenshots support?",
        body: "The app auto-detects 40+ platform types from OCR text:\n\n"
            "🎮 Gaming: Steam, Google Play, App Store, Codashop, UniPin, Garena, Mobile Legends, Genshin Impact, Valorant, PlayStation, Xbox, Nintendo, Epic Games\n\n"
            "🛍️ PH Shopping: Shopee, Lazada, Zalora, TikTok Shop, Carousell, FB Marketplace\n\n"
            "🌐 International: Amazon, AliExpress, Shein, Temu, eBay, Etsy, Taobao, ASOS, Zalando, Wish\n\n"
            "🍔 Food Delivery: GrabFood, Foodpanda, Shopee Food\n\n"
            "🚗 Rides: Grab, Angkas, Lalamove, Maxim\n\n"
            "💳 E-wallets: GCash, Maya, GrabPay, ShopeePay, Coins.ph, PayPal, Wise, remittance services\n\n"
            "🏦 PH Banks: BPI, BDO, Metrobank, UnionBank, GoTyme, Tonik, SeaBank, RCBC\n\n"
            "📺 Streaming: Netflix, Spotify, YouTube Premium, Disney+, Viu, Vivamax\n\n"
            "📱 Telco: Smart, Globe, DITO\n\n"
            "🧾 Physical Receipts: fast food, grocery, pharmacy, bookstore, utility bills\n\n"
            "Each type gets its own AI extraction prompt — for example, GCash extracts outgoing transactions only and includes the exact time; Steam extracts game names and prices; Shopee extracts each order item separately.",
        example:
            "Pick 3 screenshots: 1 Steam purchase, 1 Shopee order, 1 GCash send — each gets analysed by a different AI prompt tuned to that platform.",
      ),
    ],
  ),
  _HelpSection(
    title: "Wallet Balances",
    icon: Icons.account_balance_wallet_outlined,
    color: Colors.green,
    items: [
      _HelpItem(
        title: "What are Wallet Balances?",
        body:
            "Wallet Balances let you track how much money you actually have right now across all your accounts — separate from your income and expenses.\n\n"
            "Note: Wallet Balances are only shown when 'Track income & wallets' is ON in Settings. If you're using Lightweight Mode, wallets are hidden to simplify the interface.\n\n"
            "Supported wallets:\n"
            "• 💵 Cash on Hand — physical money in your pocket\n"
            "• 📱 GCash, 💜 Maya, 🟢 GrabPay, 🟠 ShopeePay, 🪙 Coins.ph\n"
            "• 🏦 BDO, BPI, Metrobank, Landbank, PNB, RCBC, Security Bank, Chinabank, UnionBank, EastWest, PSBank, Maybank\n"
            "• 🏦 Digital banks: GoTyme, Tonik, UNObank, UnionDigital, Seabank\n"
            "• 🏪 Remittance: Cebuana, M Lhuillier, Palawan, Western Union, LBC, Tambunting, USSC\n\n"
            "Access: Profile → tap the Net Worth / Balance card → Wallets sheet.",
      ),
      _HelpItem(
        title: "How do I update my wallet balance?",
        body: "Two ways:\n\n"
            "1. Manual: Profile → tap Net Worth card → tap any wallet → enter current balance → Save\n\n"
            "2. Via AI: Just tell the AI your balance naturally:\n"
            "   • 'my cash on hand is ₱697'\n"
            "   • 'GCash balance is ₱217'\n"
            "   • 'I have ₱5,000 in BDO'\n"
            "   The AI will update the wallet automatically.\n\n"
            "You can also add new wallets by tapping the preset chips at the bottom of the Wallets sheet.",
        example:
            "Say 'my GCash is ₱500' → AI updates GCash wallet to ₱500 instantly.",
      ),
      _HelpItem(
        title: "How do wallets affect Net Worth?",
        body:
            "Wallet balances are used as your 'liquid assets' in the net worth calculation:\n\n"
            "Net Worth = Wallet Total + Income logged − Expenses − Debts − Installments\n\n"
            "Wallet balances are NOT income — they don't affect your FHS score, budgets, or 50/30/20 breakdown. They're purely for net worth tracking.\n\n"
            "Wallet balances sync to Firebase automatically — they survive logout and restore when you log back in on any device.",
      ),
      _HelpItem(
        title: "How does wallet auto-deduct work?",
        body:
            "When enabled (Profile → App Settings → Auto-deduct wallets), logging an expense automatically reduces the matching wallet balance:\n\n"
            "• Payment method 'Cash' → deducts from Cash on Hand\n"
            "• Payment method 'GCash' → deducts from GCash wallet\n"
            "• Payment method 'Maya' → deducts from Maya wallet\n"
            "• Same for GrabPay, ShopeePay\n\n"
            "This keeps your wallet balances accurate without manual updates.\n\n"
            "Note: Auto-deduct only applies to today's expenses. If you're logging a backdated purchase (from a past day or past month), no deduction happens — your current wallet balance has nothing to do with money you spent months ago.\n\n"
            "You can disable this in App Settings if you prefer to update wallets manually.",
        example:
            "Log ₱30 jeepney fare today (Cash) → Cash on Hand goes from ₱697 to ₱667 automatically.\nLog the same fare from last Tuesday → no deduction, wallet stays the same.",
      ),
      _HelpItem(
        title: "Log Allowance button",
        body:
            "The blue 'Log Allowance' card on the home screen lets you quickly record when you receive your allowance.\n\n"
            "• Tap: adds your daily allowance (income ÷ 22 school days) to Cash on Hand + logs as income\n"
            "• Long-press: enter a custom amount (for 2-3 days' worth, or irregular amounts)\n\n"
            "This is designed for students with irregular allowance schedules — no allowance on weekends, absences, or online class days. Just tap it on the days you actually receive money.\n\n"
            "It does NOT change your monthly income setting (₱6,600) — that stays fixed for FHS calculations. It only adds to your actual cash balance.",
        example:
            "Got 2 days' allowance today (₱660) → long-press → enter 660 → Cash on Hand goes up by ₱660.",
      ),
      _HelpItem(
        title: "Profile photo across devices",
        body: "Your profile photo works with a smart fallback system:\n\n"
            "1. If you picked a photo from gallery → that local file is used\n"
            "2. If the local file is missing (new device, reinstall) → your Google account photo is used automatically\n"
            "3. If no Google photo → your initials are shown\n\n"
            "This means your profile picture 'just works' on any device as long as you're signed in with Google — no need to re-pick a photo.",
      ),
    ],
  ),
  _HelpSection(
    title: "Cloud Sync & Data Safety",
    icon: Icons.cloud_sync_outlined,
    color: Colors.blueGrey,
    items: [
      _HelpItem(
        title: "What data syncs to the cloud?",
        body: "Everything syncs automatically to Firebase Firestore:\n\n"
            "✅ Expenses, Budgets, Savings Goals\n"
            "✅ Income entries, Recurring transactions\n"
            "✅ Debts & Lending, Payment Plans\n"
            "✅ Custom Categories, Auto-Categorization Rules\n"
            "✅ Wallet Balances\n"
            "✅ Key settings: account type, income, currency, daily limit, payday date\n\n"
            "Not synced (device-local by design):\n"
            "• Score history, Mood log, Scan history — these are device analytics\n"
            "• Chat history — private per account, cleared on logout\n"
            "• Profile photo — requires Firebase Storage (Blaze plan)",
        example:
            "Set your GCash balance on your phone → log in on a tablet → GCash balance is there.",
      ),
      _HelpItem(
        title: "What happens when I log out?",
        body:
            "Before logging out, all your data is pushed to Firestore. Then local data is cleared so the next account on the same device starts clean — no data mixing between accounts.\n\n"
            "When you log back in, your data is pulled from Firestore and restored automatically.",
      ),
      _HelpItem(
        title: "What happens when I log in on a new device?",
        body:
            "On login, the app pulls all your data from Firestore and merges it into the local database. Your expenses, budgets, goals, wallets, rules — everything is restored.\n\n"
            "It also pushes any local data to Firestore to ensure the cloud is up to date.",
      ),
      _HelpItem(
        title: "Does Reset All Data also clear the cloud?",
        body:
            "Yes. Profile → Reset All Data now clears all 14 local tables AND pushes the empty state to Firestore. Your data won't resurrect on next login from another device.",
      ),
      _HelpItem(
        title: "Is demo data kept separate from my real account?",
        body:
            "Yes. Demo data is completely local — it never touches your Firestore account. Loading demo data from Profile → Load Demo Data is safe even when logged in.",
      ),
    ],
  ),
  _HelpSection(
    title: "Camera & Scanner",
    icon: Icons.camera_enhance,
    color: Colors.orange,
    items: [
      _HelpItem(
        title: "How does the Smart Scanner work?",
        body:
            "Tap the camera icon in the AI screen. The live viewfinder automatically detects barcodes and QR codes — just point and it reads them instantly. For receipts, tap the shutter button to capture a photo.\n\n"
            "Use the mode toggle button (top bar) to switch between:\n"
            "• Barcode mode — square guide, blue border (default)\n"
            "• Receipt mode — tall guide, amber border (better for long receipts)",
      ),
      _HelpItem(
        title: "Scanning a barcode or QR code",
        body:
            "Open the Smart Scanner and point at any barcode or QR code. It detects it automatically, saves it to scan history, then opens a review screen where you describe what you bought and the price before the AI processes it.",
        example:
            'Point at a Kopiko barcode → "I bought Kopiko 78°C for 25 pesos" → AI logs it.',
      ),
      _HelpItem(
        title: "Scanning a receipt",
        body:
            "Tap the shutter button in the Smart Scanner. It opens the camera — take a clear, well-lit photo of the receipt. ML Kit extracts the text.\n\n"
            "Smart routing:\n"
            "• If the receipt has 3+ prices or a 'Total' line → shows 'Import Items' button → routes to the Import screen where AI extracts each item individually with categories and Want/Need tags\n"
            "• Simple receipts or single items → 'Send to AI' button → logs via chat\n\n"
            "The Import Items flow is better for grocery/supermarket receipts with multiple items.",
        example:
            'Scan Jollibee receipt → "Import Items" → AI extracts Chickenjoy ₱149, Fries ₱59, Coke ₱39 → review → import all at once.',
      ),
      _HelpItem(
        title: "Gallery import",
        body:
            "Tap the gallery icon (top right of scanner). Pick any photo from your gallery — it auto-detects barcodes first, then falls back to OCR if no barcode is found.",
      ),
      _HelpItem(
        title: "Tips for better OCR accuracy",
        body: "• Switch to Receipt mode (amber guide) for tall receipts\n"
            "• Hold the phone steady and ensure good lighting\n"
            "• Keep the receipt flat and uncrumpled\n"
            "• Make sure the text is in focus\n"
            "• The app auto-corrects image orientation\n"
            "• If the scan quality is low, the app will warn you — edit the text before sending to AI",
      ),
    ],
  ),
  _HelpSection(
    title: "Home Dashboard",
    icon: Icons.home_outlined,
    color: Colors.teal,
    items: [
      _HelpItem(
        title: "What does the dashboard show?",
        body:
            "The home screen shows: this month's total spending, comparison to last month, income progress bar, cash flow forecast (income vs spent vs upcoming bills), budget alerts, overdue recurring bills, upcoming debt payments, spending forecast (if any budget is projected to overspend), and achievements/badges.",
      ),
      _HelpItem(
        title: "Cash Flow card",
        body:
            "Shows your projected financial position for the month using this formula:\n"
            "Income − Already Spent − Upcoming Bills (next 30 days) = Projected Remaining\n\n"
            "Upcoming Bills are pulled from your recurring transactions — any bill with a due date in the next 30 days is counted. If the projected remaining goes negative, a red shortfall warning appears.",
        example:
            "Income ₱6,600 − Spent ₱2,000 − Tuition ₱3,500 + Spotify ₱129 = ₱971 remaining.",
      ),
      _HelpItem(
        title: "Financial Health Score",
        body:
            "A score from 0–100 based on how well you're managing your money this month. It's calculated from your spending vs income, budget compliance, and spending diversity. Tap it to see the exact breakdown — each factor is listed with its point impact and a tip for improving it.",
        example: '🟢 80+ = Good  🟡 60–79 = Fair  🔴 <60 = Needs Attention',
      ),
      _HelpItem(
        title: "Log Expense button",
        body:
            "The 'Log Expense' button in the top right of the dashboard takes you directly to the AI screen — the fastest way to record a new expense.",
      ),
      _HelpItem(
        title: "Daily spending limit bar",
        body:
            "If you've set a daily spending limit (Profile → Daily Spending Limit), a progress bar appears on the home screen showing today's spending vs your cap. Turns orange at 80%, red when exceeded.",
        example:
            'Limit ₱300 → spent ₱240 today → bar shows 80% with orange warning.',
      ),
      _HelpItem(
        title: "Achievements & badges",
        body:
            "When you earn an achievement — like a spending streak or reaching a savings goal — badge chips appear on the home screen. Tap them to see what you earned.",
        example: '🔥 5-day streak · 💰 ₱1K+ saved · 🎯 Goal reached',
      ),
    ],
  ),
  _HelpSection(
    title: "Financial Health Score",
    icon: Icons.monitor_heart_outlined,
    color: Colors.green,
    items: [
      _HelpItem(
        title: "What is the Financial Health Score?",
        body:
            "A score from 0 to 100 that tells you how well you're managing your money this month. It's calculated automatically every time you log an expense. Tap the score card on the home screen to see the full breakdown.",
        example: '🟢 80–100 = Good  🟡 60–79 = Fair  🔴 0–59 = Needs Attention',
      ),
      _HelpItem(
        title: "How is the score calculated? (Step by step)",
        body: "The score has 4 equal components — 25 points each:\n\n"
            "1️⃣ Savings Rate (25 pts)\n"
            "Are you saving at least 20% of your income?\n"
            "Full 25 pts when saving ≥20%; scales down proportionally below that.\n\n"
            "2️⃣ Overspend Control (25 pts)\n"
            "How many days did you stay within your daily budget?\n"
            "Full 25 pts when no days exceeded; 0 pts when every day exceeded.\n\n"
            "3️⃣ Budget Adherence (25 pts)\n"
            "What % of your budget categories stayed within limit?\n"
            "Full 25 pts when all budgets on track. If no budgets set: 25 pts.\n\n"
            "4️⃣ Logging Consistency (25 pts)\n"
            "How regularly are you logging expenses?\n"
            "Full 25 pts when logging every day; scales proportionally.\n\n"
            "Final score = sum of all 4 components, clamped 0–100.",
        example: "Income ₱6,600 · Spent ₱4,100 · Saved 38% → Savings 25pts\n"
            "1 of 10 days over daily budget → Overspend 22.5pts\n"
            "6 of 8 budgets on track → Adherence 18.75pts\n"
            "8 of 10 days logged → Consistency 20pts → Total: ~86 pts 🟢",
      ),
      _HelpItem(
        title: "Why is my score low?",
        body:
            "Tap the score card on the home screen — it shows each component with its exact point contribution. Common reasons:\n"
            "• Not saving 20% of income (Savings Rate component)\n"
            "• Spending more than your daily budget on multiple days (Overspend Control)\n"
            "• One or more budget categories exceeded (Budget Adherence)\n"
            "• Not logging expenses regularly (Logging Consistency)\n\n"
            "There's also a Warning Decay: if a budget is exceeded and you keep spending in that category, the score loses 5 pts/day for up to 3 days.",
      ),
      _HelpItem(
        title: "Does it use all-time data or just this month?",
        body:
            "The score always uses this month's expenses only — it resets at the start of each month. This makes it a fair reflection of your current habits, not your entire history. The 30-day trend chart in Analytics shows how your score has changed over time.",
      ),
      _HelpItem(
        title: "Where does the FHS get its data?",
        body: "Each component pulls from specific database tables:\n\n"
            "• Savings Rate → monthly_income (settings) vs total expenses this month\n"
            "• Overspend Control → daily_limit (settings) vs expenses grouped by date\n"
            "• Budget Adherence → budgets table vs expenses by category this month\n"
            "• Logging Consistency → count of unique dates with expenses this month vs days elapsed\n\n"
            "The formula is income-relative — it compares YOUR spending against YOUR income, not against a fixed standard. A student with ₱6,600/month and a professional with ₱50,000/month are both scored fairly.\n\n"
            "Warning Decay: if a budget category is exceeded and you keep spending in it, the score loses 5 pts/day (max −15 pts over 3 days). This resets when you stop overspending in that category.",
        example:
            "Student: Income ₱6,600, Daily limit ₱250, 8 budgets set → all 4 components have data to calculate from.",
      ),
    ],
  ),
  _HelpSection(
    title: "Analytics",
    icon: Icons.bar_chart_outlined,
    color: Color(0xFFE65100),
    items: [
      _HelpItem(
        title: "Spending by category (pie chart)",
        body:
            "Shows how your spending is distributed across categories for the selected period. Tap any slice or legend item to drill down and see the individual transactions in that category.",
      ),
      _HelpItem(
        title: "50/30/20 Rule — what it is and how it works",
        body: "The 50/30/20 rule is a popular budgeting guideline:\n"
            "• 50% of income → Needs (Food, Transport, Bills, Health — essentials)\n"
            "• 30% of income → Wants (Shopping, Entertainment — discretionary)\n"
            "• 20% of income → Savings (what's left after spending)\n\n"
            "The app automatically classifies your categories and compares your actual spending to these targets. It always uses this month's data regardless of the period filter.\n\n"
            "A verdict line shows: 'On track ✓' if all three are within target, or 'Needs over by ₱X' if you've exceeded a target.",
        example:
            "Income ₱6,600 → Needs target ₱3,300 · Wants target ₱1,980 · Savings target ₱1,320\n"
            "Actual: Needs ₱2,800 ✓ · Wants ₱900 ✓ · Savings ₱2,900 ✓ — On track!",
      ),
      _HelpItem(
        title: "Wants vs Needs breakdown",
        body:
            "A stacked bar below the 50/30/20 tracker showing your spending split between Want and Need tags. Unlike the 50/30/20 tracker (which classifies by category automatically), this uses the tags you manually set on each expense.\n\n"
            "To see data here: tag your expenses as Need or Want when logging them (toggle in Add/Edit Expense screen).",
        example: "₱3,200 Needs (72%) vs ₱1,200 Wants (28%) this month.",
      ),
      _HelpItem(
        title: "This Month vs Last Month table",
        body:
            "Shows each spending category side by side for this month and last month, with up/down arrows. Useful for spotting trends — e.g. 'I spent ₱500 more on Food this month than last month.'",
      ),
      _HelpItem(
        title: "Spending prediction",
        body:
            "Projects your total spending for the rest of the month based on your current daily average. For example, if it's day 10 and you've spent ₱2,000, the app estimates ₱6,000 for the full month. Only shows after 3+ days of data.",
      ),
      _HelpItem(
        title: "AI Financial Advice",
        body:
            "Tap 'Get Advice' for personalized tips based on your actual spending patterns. The AI analyzes your expenses, budgets, and income to give specific, actionable suggestions — not generic advice.",
      ),
    ],
  ),
  _HelpSection(
    title: "Budgets",
    icon: Icons.pie_chart_outline,
    color: Colors.purple,
    items: [
      _HelpItem(
        title: "How do I set a budget?",
        body:
            "Go to Hub → Budgets → tap + Add Budget. Choose a category and set a monthly limit. You can also ask the AI: 'Set my food budget to 3000 pesos.'",
        example:
            'Food budget: ₱3,000/month → progress bar turns orange at 80%, red when exceeded.',
      ),
      _HelpItem(
        title: "Pace indicator",
        body:
            "Each budget shows whether you're ahead or behind pace based on how far through the month you are. If it's day 15 (50% of month) and you've spent 70% of your budget, it warns you.",
        example: '⚠️ ₱500 ahead of pace  vs  ✓ ₱200 under pace',
      ),
      _HelpItem(
        title: "% of income budget mode",
        body:
            "Instead of typing a fixed peso amount, you can set a budget as a percentage of your income. The app calculates the peso amount automatically.\n\n"
            "When setting a budget: toggle from 'Fixed ₱' to '% of income' → enter the percentage → the app shows the calculated amount in real time.\n\n"
            "This is useful for following the 50/30/20 rule — set Food + Transport + Bills to 50% total, Shopping + Entertainment to 30%, and the math works out automatically. If you update your income later, all % budgets update too.",
        example:
            "Food set to 30% → income ₱6,600 → budget = ₱1,980 automatically.",
      ),
    ],
  ),
  _HelpSection(
    title: "Savings Goals",
    icon: Icons.savings_outlined,
    color: Colors.green,
    items: [
      _HelpItem(
        title: "Creating a savings goal",
        body:
            "Hub → Savings Goals → tap + New Goal. Enter the name, target amount, how much you've already saved, start date, and optional deadline. The app calculates how much you need to save per month.",
        example: 'Goal: New Laptop ₱35,000 by December → Save ₱4,375/month.',
      ),
      _HelpItem(
        title: "Emergency Fund",
        body:
            "Tap the shield icon in Savings Goals. The app auto-calculates a recommended target based on your actual monthly spending (3 or 6 months of expenses). Emergency fund goals show a teal shield icon.",
        example: 'Monthly spend ₱5,000 → 3-month emergency fund = ₱15,000.',
      ),
    ],
  ),
  _HelpSection(
    title: "Debts & Lending",
    icon: Icons.credit_card_outlined,
    color: Colors.red,
    items: [
      _HelpItem(
        title: "Tracking debts",
        body:
            "Hub → Debts & Lending. 'I Owe' tab for money you owe others, 'Owed to Me' for money others owe you. Set due dates to get reminder notifications.",
        example:
            'Borrowed ₱5,000 from Kuya Mark, due May 15 → app reminds you 7 days before.',
      ),
      _HelpItem(
        title: "Recording a payment",
        body:
            "Tap 'Pay' on any debt entry to record a partial or full payment. The progress bar updates and the entry is marked as paid when fully settled.",
      ),
      _HelpItem(
        title: "Payment Plans & Installment Tracker",
        body:
            "For items bought on installment (phone, laptop, appliance) AND credit services (ShopeePayLater, GCash GLoan, HomeCredit, etc.).\n\n"
            "Go to Hub → Debts & Lending → Plans tab. Add a plan with:\n"
            "• Plan name + provider\n"
            "• Total amount + monthly payment (auto-computed)\n"
            "• Number of months + due day of month\n"
            "• Optional interest rate\n\n"
            "Tap 'Log Payment' to record a monthly payment as an expense and track progress. Plans also appear on the Bill Calendar on their due day.",
        example:
            'ShopeePayLater ₱1,120 — 3 months — ₱373/month — due 5th — 0/3 paid.',
      ),
    ],
  ),
  _HelpSection(
    title: "Recurring Transactions",
    icon: Icons.repeat,
    color: Colors.orange,
    items: [
      _HelpItem(
        title: "What are recurring transactions?",
        body:
            "Bills and subscriptions that repeat regularly — Netflix, internet, rent, salary. The app tracks when they're due and sends notifications.",
        example:
            'Converge Internet ₱888/month, next due May 18 → notification 3 days before.',
      ),
      _HelpItem(
        title: "Log Now button",
        body:
            "When a recurring item is due, tap it → Log Now to record it as an actual expense (or income for recurring income). The next due date automatically advances.",
      ),
      _HelpItem(
        title: "Log All Due button",
        body:
            "When you have multiple overdue or due-today recurring items, a 'Log All Due' button appears in the top bar. One tap logs all of them at once — no need to tap each one individually.",
        example: '3 bills overdue → tap Log All Due → all 3 logged instantly.',
      ),
    ],
  ),
  _HelpSection(
    title: "Net Worth & Assets",
    icon: Icons.account_balance_outlined,
    color: Colors.indigo,
    items: [
      _HelpItem(
        title: "How is Net Worth calculated?",
        body:
            "Net Worth = Income logged + Wallet Balances − Total Expenses − Outstanding Debts − Installment Remaining Balances\n\n"
            "• Wallet Balances — your Cash on Hand, GCash, Maya, bank accounts (tap the net worth card in Profile to manage)\n"
            "• Income logged — all income entries you've recorded in the app\n"
            "• Total Expenses — sum of all expenses ever logged\n"
            "• Outstanding Debts — what you still owe (amount minus what you've paid)\n"
            "• Installment Remaining — months remaining × monthly payment for all installments\n\n"
            "Tap the Net Worth card in Profile to open the Wallets sheet and update each balance.",
        example:
            "Cash ₱697 + GCash ₱217 + BDO ₱5,000 + Income ₱30,000 − Expenses ₱15,000 − Debts ₱6,000 = ₱14,914 net worth.",
      ),
      _HelpItem(
        title: "What are Wallet Balances?",
        body:
            "Wallet Balances track your actual liquid money across all accounts:\n\n"
            "• 💵 Cash on Hand — physical money in your pocket\n"
            "• 📱 GCash — your GCash wallet balance\n"
            "• 💜 Maya — Maya/PayMaya balance\n"
            "• 🟢 GrabPay — GrabPay wallet\n"
            "• 🏦 Banks — BDO, BPI, Metrobank, Landbank, PNB, RCBC, Security Bank, Chinabank, UnionBank, EastWest, Seabank, GoTyme, Tonik, and more\n"
            "• 🏪 Remittance — Cebuana, Palawan, Western Union, LBC, etc.\n\n"
            "You can also tell the AI: 'my GCash is ₱500' or 'cash on hand is ₱300' and it will update automatically.\n\n"
            "Wallet balances are separate from income — they don't affect your FHS score or budget calculations.",
      ),
    ],
  ),
  _HelpSection(
    title: "App Settings",
    icon: Icons.settings_outlined,
    color: Colors.blueGrey,
    items: [
      _HelpItem(
        title: "Where are the settings?",
        body: "Profile → App Settings. Opens a sheet with toggles for:\n\n"
            "• Auto-deduct wallets — automatically reduce wallet balance when you log an expense\n"
            "• Daily mood check-in — show/hide the mood prompt on home screen\n"
            "• Impulse pause — confirm before logging large Want expenses\n"
            "• Budget alerts — notifications at 80% and 100% budget usage\n"
            "• Balance mode — show wallet total as your primary balance instead of income-based remaining",
      ),
      _HelpItem(
        title: "What is Balance Mode?",
        body:
            "Balance Mode changes what the Profile card shows as your primary number.\n\n"
            "**Normal Mode (default):**\n"
            "• Shows: Remaining Balance = Income − Expenses this month\n"
            "• Best for: Fixed income (salary, regular allowance)\n"
            "• Answers: 'How much of my allowance is left?'\n"
            "• Pro: Clear budget tracking against known income\n"
            "• Con: Doesn't reflect actual cash if you have savings or multiple accounts\n\n"
            "**Balance Mode:**\n"
            "• Shows: Total Cash Available = sum of all wallet balances\n"
            "• Best for: Irregular income, freelancers, students with variable allowances\n"
            "• Answers: 'How much money do I actually have right now?'\n"
            "• Pro: Shows real-world cash position across all accounts\n"
            "• Con: Requires keeping wallet balances updated\n\n"
            "Both modes use the same expenses, budgets, FHS score, and analytics. Only the Profile card display changes.\n\n"
            "Toggle in Profile → App Settings → Balance mode.",
      ),
    ],
  ),
  _HelpSection(
    title: "Backup & Data",
    icon: Icons.backup_outlined,
    color: Colors.teal,
    items: [
      _HelpItem(
        title: "How do I back up my data?",
        body:
            "Profile → Backup Data. The app creates a JSON file with all your data and opens the share sheet — save it to your phone, email it to yourself, upload to Google Drive, or send via WhatsApp.\n\n"
            "Backup v9 includes: expenses, budgets, goals, income, recurring, debts, payment plans, installments, custom categories, auto-categorization rules, mood log, wallets, and insurance policies.",
      ),
      _HelpItem(
        title: "How do I restore from backup?",
        body:
            "Profile → Restore from Backup → pick the .json backup file from your device. Data is added alongside existing data (not replaced).",
      ),
      _HelpItem(
        title: "Cloud sync",
        body:
            "Your data automatically syncs to Firebase when you make changes. On login, the app pulls your cloud data and merges it with local data. Logout pushes everything to cloud first.",
      ),
    ],
  ),
  _HelpSection(
    title: "Security & Privacy",
    icon: Icons.lock_outline,
    color: Colors.grey,
    items: [
      _HelpItem(
        title: "App Lock (PIN + Biometric)",
        body:
            "Profile → App Lock. Set a 4-digit PIN. The lock triggers after 3 minutes of the app being genuinely in the background. Biometric (fingerprint / face unlock) is supported if your device has it.\n\n"
            "Important: the lock timer only starts when the app is actually sent to the background (e.g. you pressed the home button or switched to another app). System overlays that appear *over* the app — image picker, gallery browser, camera, share sheet, permission dialogs — do NOT start the timer. This means you can spend as long as you need browsing your gallery to pick screenshots without being locked out when you return.",
        example:
            "Browsing gallery for 10 minutes to pick screenshots → return to app → no lock screen.\nSwitch to another app for 4+ minutes → return → lock screen appears.",
      ),
      _HelpItem(
        title: "Account isolation",
        body:
            "When you log out, all local data is cleared after being pushed to cloud. The next account starts completely clean — no data mixing between accounts.",
      ),
    ],
  ),
  _HelpSection(
    title: "Gamification & Challenges",
    icon: Icons.sports_esports_outlined,
    color: Colors.deepPurple,
    items: [
      _HelpItem(
        title: "Daily Quests",
        body:
            "4 rotating quests appear on the home screen every day — inspired by gacha game dailies.\n\n"
            "Possible quests (4 shown per day from a pool of 6):\n"
            "• Log an expense today\n"
            "• Stay under your daily budget\n"
            "• Log a Need expense\n"
            "• Log 3+ expenses today\n"
            "• Avoid Want spending today\n"
            "• Check your Health Score\n\n"
            "Features:\n"
            "• Progress bar shows X/4 completion\n"
            "• 🔥 Streak counter — consecutive days with expenses logged\n"
            "• 🎉 Celebration when all 4 are done\n"
            "• Quests rotate daily so it stays fresh\n\n"
            "No manual claiming needed — quests auto-complete as you use the app.",
        example:
            "Day 1: Log expense ✓, Stay under budget ✓, Log 3+ ✗, Check score ✓ → 3/4 done.",
      ),
      _HelpItem(
        title: "Weekly Challenge",
        body:
            "A week-long challenge appears on the home screen every Monday. It rotates through 4 types:\n\n"
            "🍽️ Food Budget Week — spend less than ₱500 on Food\n"
            "📝 Log Every Day — log at least one expense every day\n"
            "💰 No Impulse Buys — tag zero expenses as Want\n"
            "🚌 Transport Saver — spend less than ₱200 on Transportation\n\n"
            "Progress is shown in real time. Tap the X to dismiss for the week.",
        example:
            "Week 18: No Impulse Buys → 0 Want expenses so far → ✅ On track!",
      ),
      _HelpItem(
        title: "Monthly Spending Challenge",
        body:
            "Set a personal spending cap for the month. Go to Profile → Monthly Spending Challenge → enter your target. A progress card appears on the home screen showing how much you've spent vs your cap.\n\n"
            "This is separate from your budgets — it's a single total spending goal for the whole month.",
        example:
            "Challenge: spend less than ₱8,000 this month → spent ₱3,200 so far → 40% used.",
      ),
      _HelpItem(
        title: "Level-Up Notifications",
        body:
            "When your Financial Health Score improves significantly (crosses a threshold like 60, 70, 80, or 90), you get a congratulatory notification. It tells you your new score and what improved.",
        example:
            '"🎉 Level Up! Your score reached 80 — Budget Adherence improved to 25/25."',
      ),
    ],
  ),
  _HelpSection(
    title: "Tips & Tricks",
    icon: Icons.tips_and_updates_outlined,
    color: Color(0xFF0099DD),
    items: [
      _HelpItem(
        title: "Quick tips",
        body: "• Pull down on any screen to refresh\n"
            "• Long-press any AI message to copy it\n"
            "• Long-press AI Financial Advice or Monthly Summary in Analytics to copy them\n"
            "• Tap pie chart categories to drill down into transactions\n"
            "• The AI daily limit resets at midnight — or reset manually via ⋮ menu\n"
            "• Change theme and dark mode in Profile\n"
            "• Export Debug Log from AI screen ⋮ menu or Profile for full app diagnostics",
      ),
      _HelpItem(
        title: "AI best practices",
        body:
            "• Be specific with amounts: '150 pesos' not 'around 150'\n• Log multiple items in one message: 'I spent 30 for jeepney and 85 for lunch'\n• Use 'update' not 'delete' when fixing wrong entries\n• Always specify the item name when deleting",
        example:
            '"I spent 30 for jeepney and 85 for lunch" → AI logs both as separate entries.',
      ),
      _HelpItem(
        title: "Shake to Undo",
        body:
            "After the AI logs an expense, goal, debt, or recurring item — shake your phone within 60 seconds to undo it. A confirmation sheet appears before anything is reversed. Only works on the AI screen.",
        example:
            "AI logs ₱150 lunch → you realize it was wrong → shake phone → tap Undo → entry removed.",
      ),
      _HelpItem(
        title: "For students",
        body:
            "Set your account type to Student. The app uses 'Allowance' instead of 'Income', shows student-appropriate budget splits, and the 50/30/20 rule adapts to your allowance amount.",
      ),
      _HelpItem(
        title: "For business owners",
        body:
            "Set account type to Business Owner. Use the AI to track business expenses separately, set up recurring income entries for regular clients, and use the Payment Plans tab in Debts for equipment installments.",
      ),
    ],
  ),
  _HelpSection(
    title: "Custom Categories",
    icon: Icons.category_outlined,
    color: Colors.teal,
    items: [
      _HelpItem(
        title: "Built-in categories",
        body: "Smart Spend has 14 built-in categories:\n\n"
            "• 🍔 Food — meals, drinks, snacks, groceries, restaurants\n"
            "• 🚌 Transportation — jeepney, bus, Grab, tricycle, fuel\n"
            "• 📱 Bills — electricity, internet, subscriptions, loans\n"
            "• 🛍️ Shopping — Lazada, Shopee, gadgets, accessories\n"
            "• 🎬 Entertainment — movies, concerts, events, tickets\n"
            "• 🎮 Gaming — Steam, Mobile Legends, Codashop, UniPin, top-ups\n"
            "• 💊 Health — medicine, hospital, pharmacy, vitamins\n"
            "• 📚 Education — tuition, books, school supplies, courses\n"
            "• 💇 Personal Care — haircut, salon, hygiene products\n"
            "• 👕 Clothing — shirts, pants, shoes, ukay, fashion\n"
            "• 🎁 Gifts — pasalubong, presents, donations, charity\n"
            "• ✈️ Travel — hotel, airfare, resort, tour, Airbnb\n"
            "• 🐾 Pets — pet food, vet, Pedigree, Whiskas\n"
            "• 📦 Others — anything that doesn't fit above\n\n"
            "The AI automatically assigns the right category based on keywords.",
      ),
      _HelpItem(
        title: "Adding a custom category",
        body:
            "Go to Profile → Manage Categories, or Hub → Categories. Tap + to add a new category name. Custom categories appear alongside the built-in ones in all dropdowns.",
        example:
            'Add "School" → now available in Add Expense, Budget, and Recurring screens.',
      ),
      _HelpItem(
        title: "Renaming or deleting a category",
        body:
            "Tap the edit icon to rename, or the delete icon to remove. Deleting a category moves all its expenses to 'Others' automatically. Built-in categories cannot be deleted.",
      ),
      _HelpItem(
        title: "Custom categories and AI",
        body:
            "The AI is aware of your custom categories and will use them when logging expenses. You can say 'Log ₱200 for org fee under School' and it will use your custom School category.",
      ),
    ],
  ),
  _HelpSection(
    title: "Daily Spending Limit",
    icon: Icons.today_outlined,
    color: Colors.deepOrange,
    items: [
      _HelpItem(
        title: "Setting a daily limit",
        body:
            "Go to Profile → Daily Spending Limit. Enter your daily cap (e.g. ₱300). The home screen shows a progress bar for today's spending. You get a notification at 80% and when you exceed it.",
        example:
            "Daily limit ₱300 → spent ₱240 today → progress bar shows 80% with orange warning.",
      ),
      _HelpItem(
        title: "Disabling the daily limit",
        body:
            "Set the limit to 0 or leave it blank to disable. The progress bar disappears from the home screen.",
      ),
    ],
  ),
  _HelpSection(
    title: "Bill Calendar",
    icon: Icons.calendar_month_outlined,
    color: Colors.orange,
    items: [
      _HelpItem(
        title: "Viewing upcoming events",
        body:
            "Go to Hub → Bill Calendar. See all your recurring bills, debt due dates, savings goal deadlines, installment payment days, and expected income — all on one calendar, color-coded by type:\n\n"
            "🟠 Orange — Recurring bills\n"
            "🟢 Green — Expected income\n"
            "🔴 Red — Debt payments due\n"
            "🩵 Teal — Savings goal deadlines\n"
            "🟣 Purple — Installment payment days\n\n"
            "Tap any highlighted day to see the full list of events for that day.",
        example:
            "May 5 has Tuition ₱3,500 and Globe Load ₱99 due → tap May 5 → see both events.",
      ),
      _HelpItem(
        title: "Log Now — record a bill directly from the calendar",
        body:
            "When you tap a day with a recurring bill or income event, a 'Log' button appears next to it. Tap it to instantly record that bill as an expense (or income). The next due date advances automatically.",
        example:
            "Tap May 18 → Converge ₱888 → tap Log → expense recorded, next date set to Jun 18.",
      ),
      _HelpItem(
        title: "Score dots on the calendar",
        body:
            "Each day also shows a small colored dot indicating your Financial Health Score for that day:\n"
            "🟢 Green = 80+ (Good)\n"
            "🟡 Orange = 60–79 (Fair)\n"
            "🔴 Red = below 60 (Needs Attention)\n\n"
            "This lets you see at a glance which days were financially strong or weak.",
      ),
      _HelpItem(
        title: "Navigating months",
        body:
            "Use the left/right arrows to browse past and future months. If a month has no events, a message appears: 'No upcoming events this month — add recurring bills, debts, or goals to see them here.'",
      ),
    ],
  ),
  _HelpSection(
    title: "Want vs Need Tagging",
    icon: Icons.label_outline,
    color: Colors.purple,
    items: [
      _HelpItem(
        title: "What's the difference between Want and Need?",
        body:
            "• Need = essential spending you can't avoid — food, transport fare, electricity bill, medicine, tuition\n"
            "• Want = discretionary spending you chose to do — Shopee order, cinema ticket, Jollibee when you could have cooked, new clothes that aren't urgent\n\n"
            "There's no strict rule — you decide based on your own situation. The same Jollibee meal could be a Need (you had no time to cook) or a Want (you just felt like it).",
        example:
            "Jeepney fare to school → Need. Grab ride because you woke up late → Want.",
      ),
      _HelpItem(
        title: "How do I tag an expense?",
        body:
            "When adding or editing any expense, look for the Need / Want toggle below the Category dropdown. Tap the one that applies. That's it — the tag is saved with the expense.\n\n"
            "You can also edit existing expenses to add tags retroactively.",
        example:
            "Add Expense → fill in details → below Category, tap 'Want' → Save.",
      ),
      _HelpItem(
        title: "Where do I see the results?",
        body:
            "Analytics screen → scroll down past the 50/30/20 tracker → Wants vs Needs stacked bar. It shows the peso amount and percentage for each tag for the current period.\n\n"
            "Note: Expenses without a tag default to Need. The breakdown only becomes meaningful once you start tagging your expenses.",
        example:
            "₱3,200 Needs (72%) vs ₱1,200 Wants (28%) — you can see 28% of your spending was discretionary.",
      ),
      _HelpItem(
        title: "How is this different from the 50/30/20 tracker?",
        body:
            "The 50/30/20 tracker classifies expenses automatically by category — Food is always a Need, Entertainment is always a Want. You can't change that.\n\n"
            "The Want/Need tag is your personal judgment per expense. A Shopee order could be a Need (buying school supplies) or a Want (buying something you don't really need). The tag lets you be more precise.",
      ),
    ],
  ),
  _HelpSection(
    title: "Achievements & Streaks",
    icon: Icons.emoji_events_outlined,
    color: Colors.amber,
    items: [
      _HelpItem(
        title: "How streaks work",
        body:
            "The app tracks consecutive days where your financial health score is 60 or above (Fair or better). A streak badge appears on the home screen when you hit 3+ days.\n\n"
            "Daily Quests also track a logging streak — consecutive days with at least 1 expense logged.",
        example:
            "🔥 5-day streak → you've had a Fair or Good score for 5 days in a row.",
      ),
      _HelpItem(
        title: "All 23 badges",
        body: "Getting Started:\n"
            "🌱 First Step — Log your first expense\n"
            "📱 App Explorer — Use 5 different features\n\n"
            "Streaks:\n"
            "🔥 3-Day Streak — Score ≥60 for 3 days\n"
            "💯 Week Warrior — Score ≥60 for 7 days\n"
            "🏆 Month Master — Score ≥60 for 30 days\n\n"
            "Savings & Budget:\n"
            "💰 Saver — Save ≥20% of income for a month\n"
            "🎯 Goal Getter — Complete a savings goal\n"
            "📊 Budget Boss — All budgets on track for a month\n"
            "🪙 Spare Change Hero — Save ₱100+ via round-ups\n\n"
            "AI & Tech:\n"
            "🤖 AI Power User — Send 20 AI messages\n"
            "🧾 Receipt Scanner — Scan 10 receipts\n"
            "🔀 Wallet Wizard — Make 5 wallet transfers\n\n"
            "Discipline:\n"
            "🚫 Impulse Control — Decline impulse pause 5 times\n"
            "📅 Consistent Logger — Log every day for 14 days\n"
            "🔍 Detail Oriented — Add notes to 10 expenses\n"
            "🛡️ Insurance Aware — Track 1+ insurance policy\n\n"
            "Fun:\n"
            "🌙 Night Owl — Log after 10 PM\n"
            "☀️ Early Bird — Log before 8 AM\n\n"
            "Debt & Health:\n"
            "💳 Debt Slayer — Pay off a debt completely\n"
            "🏦 Emergency Ready — Emergency fund at 100%\n\n"
            "Milestones:\n"
            "💎 Century Club — Log 100 expenses total\n"
            "⭐ Score Star — Reach FHS score of 80+\n"
            "🎓 Financial Literate — Ask AI 5 advice questions",
        example:
            "Locked badges show 🔒 so you always know what to aim for next.",
      ),
      _HelpItem(
        title: "Daily Quests (10 rotating challenges)",
        body:
            "4 quests shown per day from a pool of 10, rotating based on the day. Complete all 4 for a perfect day!\n\n"
            "Examples:\n"
            "• Log an expense today\n"
            "• Stay under daily budget\n"
            "• Avoid Want spending today\n"
            "• Keep total under ₱200 today\n"
            "• Log before noon\n"
            "• Spend only on Needs today\n\n"
            "Quests reset daily. Your streak counter shows consecutive days with at least 1 expense logged.",
      ),
      _HelpItem(
        title: "Where do I see my badges?",
        body:
            "Hub → Achievements. Shows all 23 badges in a grid — earned ones are highlighted, locked ones show 🔒. The count in the top bar shows how many you've earned. Pull down to refresh.",
      ),
    ],
  ),
  _HelpSection(
    title: "Insurance & Contributions",
    icon: Icons.shield_outlined,
    color: Colors.indigo,
    items: [
      _HelpItem(
        title: "Insurance & Contributions Tracker",
        body:
            "Hub → Insurance & Contributions. Track all your insurance policies and government contributions in one place.\n\n"
            "• Quick-add SSS, PhilHealth, Pag-IBIG with one tap\n"
            "• Set premium amounts, frequency, and due dates\n"
            "• Mark as Paid — auto-advances next due date\n"
            "• Overdue premiums trigger startup alerts\n\n"
            "⚠️ This is for tracking only — not insurance sales or financial advice.",
      ),
      _HelpItem(
        title: "Adding SSS, PhilHealth, Pag-IBIG",
        body: "Two ways:\n\n"
            "1. Hub → Insurance & Contributions → tap the quick-add chips (SSS, PhilHealth, Pag-IBIG)\n"
            "2. Hub → Recurring Transactions → tap + for preset templates\n\n"
            "The Insurance screen tracks premiums with due dates and overdue alerts. Recurring Transactions auto-logs the expense each month.",
        example: "Tap SSS chip → set ₱1,400/month → next due date → done.",
      ),
      _HelpItem(
        title: "Adjusting contribution amounts",
        body:
            "Tap the ⋮ menu on any policy → Edit. Amounts vary based on your monthly salary bracket.\n\n"
            "You can also ask the AI: 'How much should I pay for SSS if I earn ₱25,000?' — it will calculate based on the current contribution table.",
      ),
    ],
  ),
  _HelpSection(
    title: "Spending Forecast",
    icon: Icons.trending_up,
    color: Colors.deepOrange,
    items: [
      _HelpItem(
        title: "What is the Spending Forecast?",
        body:
            "A card on the home screen that predicts which budget categories you'll exceed by the end of the month, based on your current spending pace.\n\n"
            "Formula: (spent so far ÷ days elapsed) × days in month = projected total\n\n"
            "Only appears when you have 3+ days of data and at least one category is projected to overspend.",
        example:
            "Day 10, spent ₱800 on Food → projected ₱2,480 by month-end → Food budget ₱2,000 → ⚠️ +₱480 over budget",
      ),
      _HelpItem(
        title: "How do I use it?",
        body:
            "It appears automatically on the home screen when a warning is detected. Use it as an early warning to adjust your spending before the month ends.\n\n"
            "If you see a forecast warning, consider reducing spending in that category for the rest of the month.",
      ),
    ],
  ),
  _HelpSection(
    title: "FHS Component Breakdown",
    icon: Icons.monitor_heart_outlined,
    color: Colors.green,
    items: [
      _HelpItem(
        title: "What is the Component Breakdown?",
        body:
            "A card in the Analytics screen (below the Health Score chart) that shows how each of the 4 FHS components is performing this month.\n\n"
            "Each component shows a progress bar from 0 to 25 points:\n"
            "🟢 Green (20–25) = doing well\n"
            "🟡 Orange (12–19) = needs attention\n"
            "🔴 Red (0–11) = needs improvement",
        example:
            "Savings Rate: 23/25 🟢 · Overspend Control: 18/25 🟡 · Budget Adherence: 25/25 🟢 · Logging: 20/25 🟢",
      ),
      _HelpItem(
        title: "How do I improve each component?",
        body: "• Savings Rate — spend less than 80% of your income this month\n"
            "• Overspend Control — stay within your daily budget (income ÷ 30) each day\n"
            "• Budget Adherence — keep all category budgets on track\n"
            "• Logging Consistency — log at least one expense every day",
      ),
    ],
  ),
  _HelpSection(
    title: "Weekly Notifications",
    icon: Icons.notifications_outlined,
    color: Colors.blue,
    items: [
      _HelpItem(
        title: "Weekly Behavioral Summary",
        body:
            "Every Sunday, the app sends a notification summarizing your week:\n\n"
            "• Savings Rate — what % of your income you saved\n"
            "• Days over budget — how many days you exceeded your daily budget\n"
            "• Logging consistency — how many days you logged expenses\n\n"
            "No AI call needed — calculated entirely from your local data.",
        example:
            '"Your week in review: Savings Rate 38% · 2 days over daily budget · Logged 5/7 days"',
      ),
      _HelpItem(
        title: "Anomaly Detection Alert",
        body:
            "Also fires on Sunday if any spending category spiked unusually compared to your 4-week average.\n\n"
            "Threshold: if this week's spending in a category is 2.5x or more above your usual weekly amount, you get an alert.\n\n"
            "Only one alert per week — the most anomalous category.",
        example:
            '"⚠️ Unusual spending: Transport — You spent ₱1,200 this week, 3x your usual ₱400"',
      ),
    ],
  ),
  _HelpSection(
    title: "Onboarding Quiz",
    icon: Icons.quiz_outlined,
    color: Colors.purple,
    items: [
      _HelpItem(
        title: "What is the Onboarding Quiz?",
        body:
            "The 4th step of the setup wizard (when you first create an account or set up the app). It asks 3 quick questions to personalize your experience:\n\n"
            "1. What's your biggest financial challenge? (Overspending / Saving / Debt / Tracking)\n"
            "2. Do you have regular bills?\n"
            "3. Do you want to build an emergency fund?\n\n"
            "Based on your answers, the app automatically creates budgets and goals for you.",
        example:
            "Challenge: Overspending → tighter budgets created automatically\n"
            "Emergency fund: Yes → Emergency Fund goal created (3-month target)",
      ),
      _HelpItem(
        title: "Can I change my answers later?",
        body:
            "Yes. You can update your account type from Profile → Account Type, adjust budgets from Hub → Budgets, and add or edit savings goals from Hub → Savings Goals at any time.",
      ),
    ],
  ),
  _HelpSection(
    title: "Analytics — New Features",
    icon: Icons.bar_chart_outlined,
    color: Color(0xFF0066FF),
    items: [
      _HelpItem(
        title: "Last Month & Month Picker",
        body:
            "The analytics period filter now includes a 'Last Month' chip for instant comparison, and a 'Pick Month' chip that opens a year + month grid picker. Select any past month to see its full breakdown.",
        example:
            "Tap 'Last Month' → see April's spending. Tap 'Pick Month' → select January 2026.",
      ),
      _HelpItem(
        title: "Payday Cycle Filter",
        body:
            "Tap 'Payday Cycle' in the analytics filter. On first use, set your payday date (e.g. 15th). The filter then shows expenses from the 15th of last month to the 14th of this month — matching how you actually receive and spend money.",
        example: "Payday 15th → cycle shows May 15 to Jun 14 spending.",
      ),
      _HelpItem(
        title: "Period Comparison Tool",
        body:
            "Scroll down in Analytics to find the 'Period Comparison' section. Tap to expand it, then pick any two months using the month pickers. The tool shows total spending for each period, per-category breakdown, and % change with trend arrows.",
        example: "Compare March vs April → Food up 18% ↑, Transport down 5% ↓.",
      ),
      _HelpItem(
        title: "Day-of-Week Heatmap",
        body:
            "A 7-column grid (Mon–Sun) showing your average daily spending per day of week. Darker color = higher average. The highest-spending day is highlighted with a border. Helps you spot patterns like 'I always overspend on Saturdays.'",
      ),
      _HelpItem(
        title: "Long-Range Forecast (3/6/12 months)",
        body:
            "Below the next-month prediction card, a 3-column card shows projected cumulative spending at 3, 6, and 12 months ahead — based on your current spending pace. Useful for planning big purchases or savings targets.",
        example: "3 months: ₱18,000 · 6 months: ₱36,000 · 12 months: ₱72,000",
      ),
      _HelpItem(
        title: "Small Purchases Add Up",
        body:
            "A card that groups your small frequent purchases (₱200 or less, appearing 3+ times) and shows their combined monthly total and annual projection. Helps you see the true cost of daily habits.",
        example: '"Daily coffee ₱45 × 22 times = ₱990/month = ₱11,880/year"',
      ),
      _HelpItem(
        title: "Monthly Plain-English Summary",
        body:
            "Tap 'Generate' on the summary card to get a short AI-written paragraph describing your month in plain language — no charts, just a natural sentence or two. Useful for sharing or reviewing at a glance.",
        example:
            '"This month you spent ₱800 more than you earned. Most of the gap came from dining out, which jumped after the 15th."',
      ),
      _HelpItem(
        title: "Mood & Spending Correlation",
        body:
            "After logging your mood for 5+ days, a correlation card appears in Analytics showing your average spending on low-mood days vs high-mood days. If you spend significantly more when stressed or sad, the app surfaces this insight.",
        example:
            '"You spend ₱320 more on low-mood days. Consider a spending pause when feeling down."',
      ),
      _HelpItem(
        title: "Financial Literacy Tips",
        body:
            "When any FHS component scores below 12/25, a blue tip card appears below that component's progress bar explaining what the score means and a practical action to improve it. These are educational, not judgmental.",
        example:
            '"💡 The 20% rule: aim to save at least 20% of your income each month."',
      ),
    ],
  ),
  _HelpSection(
    title: "Behavioral Features",
    icon: Icons.psychology_outlined,
    color: Colors.deepPurple,
    items: [
      _HelpItem(
        title: "Daily Mood Check-In",
        body:
            "A 5-emoji check-in widget on the home screen (😞 😕 😐 🙂 😄). Tap once to log your mood for today. One entry per day. Your mood is stored locally and used to find correlations with your spending patterns over time.",
        example:
            "Tap 🙂 → mood logged. After 5+ days, Analytics shows mood vs spending correlation.",
      ),
      _HelpItem(
        title: "Mood Notes",
        body:
            "After tapping an emoji to log your mood, a text field appears where you can add a short note about how you're feeling or what's going on. This is optional but helps you remember context when reviewing your mood history later.",
        example:
            "Tap 😕 → type 'Stressful day at school' → saved with today's mood entry.",
      ),
      _HelpItem(
        title: "Impulse Pause Mechanic",
        body:
            "When you log a Want-tagged expense that's more than 2× your usual amount for that category, a dialog appears asking 'Was this planned?' You can still save it — this is just a moment to reflect before confirming.\n\n"
            "Note: Impulse pause only fires for today's expenses. If you're logging a past purchase (backdating an entry from last month or last week), the prompt is skipped — there's no point questioning a decision that was made months ago.",
        example:
            "Usual food spend ₱150 → log ₱400 Want for today → 'Was this planned?' → tap Yes to save.\nLogging a ₱400 purchase from 3 months ago → no prompt, saves directly.",
      ),
      _HelpItem(
        title: "Loss Aversion Budget Alerts",
        body:
            "Budget alerts are now framed in terms of your savings goals. Instead of just '80% of Food budget used', you see '₱800 over Food = ₱800 less toward your New Laptop goal.' This makes the impact feel more real.",
      ),
      _HelpItem(
        title: "Subscription Summary Card",
        body:
            "A purple card on the home screen showing all your active subscriptions from the Recurring Transactions list, their combined monthly cost, and annual total. Helps you spot forgotten subscriptions.",
        example:
            "Spotify ₱129 + Netflix ₱299 + Globe ₱99 = ₱527/month = ₱6,324/year",
      ),
      _HelpItem(
        title: "Category Velocity Alerts",
        body:
            "Once per month, the app checks if any spending category grew more than 25% compared to last month. If so, you get a notification as an early warning before it becomes a bigger problem.",
        example:
            '"📈 Food spending up 31% — ₱420 higher than last month. Consider reviewing."',
      ),
      _HelpItem(
        title: "Windfall Income",
        body:
            "When logging income, toggle 'Mark as windfall' for one-time unexpected income (bonus, gift, prize, freelance project). Windfall income is stored separately so it doesn't inflate your regular income baseline in forecasts.",
        example:
            "₱5,000 birthday gift → mark as windfall → not counted as regular monthly income.",
      ),
    ],
  ),
  _HelpSection(
    title: "Auto-Categorization Rules",
    icon: Icons.rule_outlined,
    color: Colors.deepPurple,
    items: [
      _HelpItem(
        title: "What are categorization rules?",
        body:
            "Rules let you define your own keyword → category mappings. When you or the AI logs an expense, the description is checked against your rules first. If a keyword matches, that category is used automatically — overriding the built-in keyword list.",
        example:
            '"7-Eleven" → Food · "Grab" → Transportation · "Mercury" → Health',
      ),
      _HelpItem(
        title: "How do I add a rule?",
        body:
            "Go to Hub → Auto-Categorization Rules → tap + Add Rule. Enter a keyword (e.g. '7-Eleven') and select the category it should map to. Rules are case-insensitive and use partial matching.",
        example:
            'Rule: "grab" → Transportation. Now "GrabFood", "Grab Car", "Grab Express" all map to Transportation.',
      ),
      _HelpItem(
        title: "Rule priority",
        body:
            "Your custom rules are checked first, before the built-in keyword list. This means you can override default behavior — for example, if you want 'Grab' to map to Food instead of Transportation, just add that rule.",
      ),
    ],
  ),
  _HelpSection(
    title: "Import from Bank / GCash",
    icon: Icons.account_balance_outlined,
    color: Colors.green,
    items: [
      _HelpItem(
        title: "What is the Bank Import feature?",
        body:
            "Import your spending history from any bank or e-wallet in bulk. Instead of logging transactions one by one, paste your transaction history text and the AI parses all of it at once.\n\n"
            "Supported sources: GCash, Maya (PayMaya), BPI, BDO, UnionBank, Seabank, and any bank with a text-based export.\n\n"
            "Access it from: Hub → Import from Bank / GCash, or Profile → Data section.",
      ),
      _HelpItem(
        title: "How do I import GCash transactions?",
        body: "Option A — PDF text (most reliable):\n"
            "1. GCash app → Profile → Transaction History → Request via email\n"
            "2. Open the email → open the PDF → select all text → copy\n"
            "3. In Smart Spend: Hub → Import from Bank / GCash → paste → Parse with AI\n\n"
            "Option B — Screenshot OCR:\n"
            "1. Open GCash → scroll through your transaction list\n"
            "2. Screenshot the list → tap Camera button in the import screen to OCR it\n"
            "⚠️ Screenshots of tables may have column alignment issues. If results look wrong, use Option A instead.",
        example:
            "GCash history shows: 2026-04-28 07:36 Payment to Shopee ₱69 → imported as Shopping ₱69 on Apr 28.",
      ),
      _HelpItem(
        title: "How do I import from BPI, BDO, or other banks?",
        body: "1. Open your bank app or online banking\n"
            "2. Go to Transaction History / Account Statement\n"
            "3. Select your date range\n"
            "4. Copy the transaction text (or screenshot it)\n"
            "5. Paste into the import screen → Parse with AI → review → import\n\n"
            "The AI understands any format — tabular, narrative, CSV-like, or mixed.",
      ),
      _HelpItem(
        title: "What happens during the review step?",
        body:
            "After parsing, you see a list of all detected expense transactions. For each row you can:\n"
            "• Check/uncheck to include or exclude it\n"
            "• Change the category using the dropdown\n"
            "• Toggle Want/Need\n"
            "• Tap 'All' or 'None' to select/deselect everything\n"
            "• Tap 'Re-parse' if the results look wrong\n\n"
            "The bottom bar shows how many are selected and the total amount. Tap 'Import X' to confirm.",
        example:
            "10 transactions found → uncheck the 2 that are income transfers → import 8 → ✓ Imported 8 transactions.",
      ),
      _HelpItem(
        title: "Are the original transaction dates preserved?",
        body:
            "Yes. Imported transactions are saved with their real dates from the bank history — not today's date. A GCash payment from April 28 will appear in your April data, show on the Bill Calendar on April 28, and count toward April's analytics.",
        example:
            "GCash history Apr 28 → imported → shows in Analytics 'Last Month', Bill Calendar Apr 28, and April totals.",
      ),
      _HelpItem(
        title: "What transactions are skipped?",
        body: "The AI automatically skips:\n"
            "• Credits / incoming money (transfers received, cash-in)\n"
            "• GLoan repayments (these are debt payments, not regular expenses)\n"
            "• Balance entries and header rows\n\n"
            "Only debit/outgoing transactions are imported as expenses.",
        example:
            "Transfer from Mom ₱750 → skipped (income). Payment to Shopee ₱69 → imported (expense).",
      ),
      _HelpItem(
        title: "Does it sync with all other features?",
        body:
            "Yes — imported transactions are regular expenses in the database. They appear in:\n"
            "• Analytics charts (with their real dates)\n"
            "• Transactions screen (searchable, filterable)\n"
            "• Budget tracking (count against the correct month)\n"
            "• AI chat context (AI can see and discuss them)\n"
            "• Bill Calendar (gray dots on their actual dates)\n"
            "• Backup & CSV export\n"
            "• Financial Health Score calculation\n"
            "• Achievements (first_expense, log_14, etc.)",
      ),
    ],
  ),
  _HelpSection(
    title: "Transaction Tags",
    icon: Icons.label_outlined,
    color: Colors.indigo,
    items: [
      _HelpItem(
        title: "What are transaction tags?",
        body:
            "Tags let you add custom labels to any expense beyond the standard category. Use them to group expenses by project, event, or context.\n\n"
            "Examples:\n"
            "• #capstone — track all capstone-related spending\n"
            "• #shared — expenses split with friends\n"
            "• #work — work-related purchases\n"
            "• #monthly — recurring personal expenses\n\n"
            "You can add up to 5 tags per expense. Tags are stored as comma-separated values and are included in CSV exports and backups.",
        example:
            "Printing ₱85 tagged #capstone → filter by #capstone in Transactions to see total capstone spending.",
      ),
      _HelpItem(
        title: "How do I add tags to an expense?",
        body:
            "When adding or editing any expense, scroll down past the Notes field to find the Tags section.\n\n"
            "Type a tag name (with or without #) and tap Add, or press Enter. The # prefix is added automatically.\n\n"
            "Tags appear as colored chips below the tag input. Tap the × on any chip to remove it.",
        example: "Type 'capstone' → tap Add → chip shows '#capstone'.",
      ),
      _HelpItem(
        title: "How do I filter by tag?",
        body:
            "In the Transactions screen, a tag filter row appears automatically when any of your expenses have tags.\n\n"
            "Tap any tag chip to filter the list to only expenses with that tag. The summary bar updates to show the count and total for the filtered results.\n\n"
            "You can also search for a tag in the search bar — it matches tags along with item names, categories, and shop names.",
        example: "#capstone filter → shows 8 transactions, ₱4,250 total.",
      ),
      _HelpItem(
        title: "Are tags included in exports?",
        body:
            "Yes. The CSV export includes a 'Tags' column. The debug log also shows tags per expense line. Tags are preserved in backup and restore.",
      ),
    ],
  ),
  _HelpSection(
    title: "Subscription Auto-Detection",
    icon: Icons.repeat_outlined,
    color: Colors.teal,
    items: [
      _HelpItem(
        title: "What is subscription auto-detection?",
        body:
            "Smart Spend automatically scans your expense history for recurring patterns — expenses with similar descriptions appearing 2 or more times at consistent weekly or monthly intervals.\n\n"
            "When a pattern is detected, a teal prompt card appears on the Home screen:\n"
            "\"Recurring pattern detected — want to track it as a recurring transaction?\"\n\n"
            "This runs once per day in the background.",
        example:
            "Buy Load ₱101 appears every month → app suggests adding it as a monthly recurring bill.",
      ),
      _HelpItem(
        title: "What do I do when a pattern is detected?",
        body:
            "The card shows the detected description, frequency, and average amount. You have two options:\n\n"
            "• Tap 'Add Recurring' → opens the Recurring Transactions screen where you can add it properly with a due date and frequency\n"
            "• Tap 'Dismiss' → permanently hides that suggestion (it won't appear again)\n\n"
            "If you have multiple candidates, the card shows the first one. After dismissing or adding it, the next candidate appears.",
      ),
      _HelpItem(
        title: "What patterns does it detect?",
        body: "The detection looks for expenses in the last 90 days where:\n"
            "• The same description appears 2+ times\n"
            "• The interval between occurrences is consistently weekly (6–8 days), biweekly (13–16 days), or monthly (25–35 days)\n\n"
            "It skips items already in your Recurring Transactions list to avoid duplicates.",
      ),
    ],
  ),
  _HelpSection(
    title: "Market Insights",
    icon: Icons.public,
    color: Colors.blue,
    items: [
      _HelpItem(
        title: "What is the Market Insights card?",
        body:
            "A card in the Analytics screen (near the bottom, before AI Financial Advice) that shows:\n\n"
            "• Live PHP exchange rates for USD, EUR, GBP, JPY, SGD, AUD\n"
            "• Tap to expand for financial literacy tips\n\n"
            "Rates are fetched from open.er-api.com (the same source as the Currency Exchange screen) and cached for up to 1 hour.",
        example: "1 USD = ₱57.23 · 1 EUR = ₱62.10 · 1 SGD = ₱42.80",
      ),
      _HelpItem(
        title: "What financial tips are included?",
        body: "Tap the card to expand it and see 6 financial literacy tips:\n\n"
            "• How USD/PHP rate affects your purchasing power\n"
            "• How inflation erodes savings (and where to park emergency funds)\n"
            "• The 50/30/20 rule explained\n"
            "• Why you should avoid credit card minimum payments\n"
            "• The 'pay yourself first' savings strategy\n"
            "• Emergency fund basics\n\n"
            "These are general financial education tips — not investment advice.",
      ),
    ],
  ),
  _HelpSection(
    title: "Quick Access Portals",
    icon: Icons.grid_view_rounded,
    color: Colors.deepPurple,
    items: [
      _HelpItem(
        title: "What are the Quick Access portals?",
        body:
            "A 6-card grid on the Home screen (below the AI Insights section) that gives you one-tap access to the most useful features:\n\n"
            "📊 Analytics — charts, 50/30/20, forecasts\n"
            "📅 Bill Calendar — upcoming bills and events\n"
            "🎯 Goals — savings targets and emergency fund\n"
            "💳 Debts & Plans — money owed, lent, and installments\n"
            "🏦 Import — bulk import from GCash, BPI, BDO, Maya\n"
            "🔁 Recurring — manage bills and subscriptions\n\n"
            "Each card shows a brief description so you know what it does at a glance.",
      ),
      _HelpItem(
        title: "Is this different from the Hub?",
        body:
            "Yes. The Hub (grid icon in the bottom bar) shows ALL features in a scrollable list. The Quick Access portals on the Home screen show only the 6 most commonly used features as visual cards.\n\n"
            "Use the portals for quick daily access. Use the Hub when you need a feature that's not in the portals.",
      ),
    ],
  ),
  _HelpSection(
    title: "Spending Personality",
    icon: Icons.psychology_outlined,
    color: Colors.deepPurple,
    items: [
      _HelpItem(
        title: "What is the Spending Personality card?",
        body:
            "A card on the Home screen (between the FHS/Budgets row and AI Insights) that labels your spending style based on your actual expense data for the current month.\n\n"
            "Possible personalities:\n"
            "🍜 Foodie Spender — Food is your biggest expense\n"
            "💰 Consistent Saver — You save 30%+ of income\n"
            "🎮 Entertainment Lover — Entertainment is your top category\n"
            "🛍️ Shopaholic — Shopping dominates your spending\n"
            "🚌 Commuter — Transportation takes a big chunk\n"
            "📚 Invested Learner — You spend significantly on education\n"
            "🎯 Disciplined Spender — Low wants, consistent savings\n"
            "🎉 Impulse Buyer — More than half your spending is on wants\n"
            "📈 Smart Budgeter — Saving 20%+ of income\n"
            "⚖️ Balanced Spender — Fairly distributed across categories\n\n"
            "No AI call needed — computed instantly from your data. Updates every time your expenses change.",
        example:
            "Spent ₱1,200 on Entertainment this month out of ₱2,400 total → 🎮 Entertainment Lover",
      ),
      _HelpItem(
        title: "How do I improve my spending personality?",
        body: "Each personality card includes a brief tip. For example:\n"
            "• Foodie Spender → 'Consider meal prepping to save more'\n"
            "• Impulse Buyer → 'Try tagging expenses to stay aware'\n"
            "• Shopaholic → 'Try the 24-hour rule before buying'\n\n"
            "You can also tap 'Ask AI to explain my score' on the Financial Health Score card to get personalized advice from the AI.",
      ),
    ],
  ),
  _HelpSection(
    title: "AI Financial Companion",
    icon: Icons.smart_toy_outlined,
    color: Color(0xFF7C3AED),
    items: [
      _HelpItem(
        title: "What can the AI discuss beyond expense logging?",
        body:
            "SmartSpend AI is a full financial companion, not just an expense recorder. You can ask about:\n\n"
            "🏦 Philippine banking — GCash, Maya, BDO, BPI, UnionBank features and comparisons\n"
            "📋 Government benefits — SSS, PhilHealth, Pag-IBIG: how to apply, contribution rates, loan eligibility\n"
            "💰 Investments — MP2, time deposits, stocks, crypto basics explained simply\n"
            "🛒 Prices & deals — estimates for items, gadgets, second-hand goods in the Philippines\n"
            "💳 Loans & credit — how they work, what to watch out for\n"
            "📊 Financial planning — budgeting strategies, debt management, saving tips\n"
            "🤝 Negotiation — 'Is ₱12,000 a good price for a ref?' — AI gives market context\n\n"
            "The AI uses your actual app data for personalized advice, and general knowledge for broader questions.",
        example:
            '"How do I apply for SSS loan?" → AI explains eligibility, requirements, and steps.',
      ),
      _HelpItem(
        title: "Filipino Financial Calendar",
        body:
            "The AI is aware of key Filipino financial seasons and will proactively mention them when relevant:\n\n"
            "• May–July: School enrollment — tuition, uniforms, supplies spike\n"
            "• November–December: 13th month pay season\n"
            "• December: Christmas shopping, Noche Buena, gifts — major spending spike\n"
            "• January: Post-holiday budget recovery\n"
            "• March–April: Summer — travel and leisure increase\n"
            "• November 11 / December 12: Shopee/Lazada mega sales\n\n"
            "Ask the AI 'Should I prepare for anything financially this month?' and it will give context-aware advice.",
        example:
            "Asking in November → AI mentions 13th month pay and Christmas budget planning.",
      ),
      _HelpItem(
        title: "Conversation Summarization",
        body:
            "After every 10 messages, the AI automatically summarizes the older conversation into key bullet points. This keeps the AI efficient and within token limits without losing important context.\n\n"
            "You still see the full chat history in the UI — only what the AI reads internally is compressed. The summary focuses on: expenses logged, budgets discussed, goals mentioned, and financial decisions made.",
      ),
      _HelpItem(
        title: "Quick AI Prompts — Try These!",
        body: "Not sure what to ask? Here are 25 things the AI can do:\n\n"
            "💸 LOGGING:\n"
            "• \"Spent 30 for jeepney\"\n"
            "• \"Bought coffee yesterday for 150\"\n"
            "• \"I paid 500 for electricity via GCash\"\n\n"
            "💰 WALLETS:\n"
            "• \"My GCash is 2500\"\n"
            "• \"Move 1000 from Cash to GCash\"\n"
            "• \"What should I do with my idle money?\"\n\n"
            "📊 ANALYSIS:\n"
            "• \"Compare this month to last month\"\n"
            "• \"Why is my score low?\"\n"
            "• \"Find my subscriptions\"\n"
            "• \"Plan my month\"\n\n"
            "🎯 GOALS & BUDGETS:\n"
            "• \"Split my salary 50/30/20\"\n"
            "• \"Can I afford a ₱50K laptop?\"\n"
            "• \"When will I save enough for my goal?\"\n"
            "• \"What's the best way to pay off my debts?\"\n\n"
            "🏦 PH FINANCE:\n"
            "• \"How much should I pay for SSS?\"\n"
            "• \"How do I apply for Pag-IBIG loan?\"\n"
            "• \"Is GoTyme or Maya Bank better for savings?\"\n"
            "• \"What's a good price for a second-hand iPhone 13?\"",
      ),
    ],
  ),
];
