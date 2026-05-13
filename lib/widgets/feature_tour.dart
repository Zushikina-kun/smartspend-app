import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature tour shown on first launch after setup.
/// Walks the user through the app's key features.
class FeatureTour extends StatefulWidget {
  final VoidCallback onDone;
  const FeatureTour({super.key, required this.onDone});

  /// Returns the per-account SharedPreferences key for the tour.
  /// Uses the Firebase UID if logged in, or 'demo' for demo mode.
  static String _tourKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'demo';
    return 'tour_done_$uid';
  }

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_tourKey()) ?? false);
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourKey(), true);
  }

  /// Resets the tour for the current account so it shows again.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourKey(), false);
  }

  @override
  State<FeatureTour> createState() => _FeatureTourState();
}

class _FeatureTourState extends State<FeatureTour>
    with SingleTickerProviderStateMixin {
  int _page = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const _steps = [
    _TourStep(
      icon: Icons.smart_toy_outlined,
      color: Color(0xFF7C3AED),
      title: "AI is the Heart of the App",
      body:
          "Tap the AI button in the bottom navigation bar to open your financial assistant.\n\n"
          "You can:\n"
          "🎙️ Speak — just say what you spent\n"
          "📷 Camera — scan receipts or barcodes\n"
          "✏️ Type — describe it in plain language\n\n"
          "The AI logs expenses, updates wallets, sets budgets, tracks debts, and more — 16 action types, all automatic.",
    ),
    _TourStep(
      icon: Icons.home_outlined,
      color: Color(0xFF0066FF),
      title: "Your Home Dashboard",
      body: "The Home screen is your financial command center:\n\n"
          "💵 Wallet balance card — your total cash at a glance\n"
          "📊 Financial Health Score (0–100)\n"
          "🎯 9-grid Quick Access — Goals, Wallets, Budgets, Calendar & more\n"
          "🔔 Alerts for overdue bills and budget warnings\n"
          "😊 Daily mood check-in\n\n"
          "Tap any card to dive deeper.",
    ),
    _TourStep(
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF00875A),
      title: "Wallets, Budgets & Goals",
      body:
          "💵 Wallets — track Cash on Hand, GCash, Maya, banks. Auto-deducts when you log expenses.\n\n"
          "💰 Budgets — set monthly limits per category (14 categories: Food, Gaming, Travel, Pets & more).\n\n"
          "🎯 Savings Goals — track targets with progress bars.\n\n"
          "⚙️ App Settings — toggle wallet auto-deduct, mood, impulse pause, balance mode.\n\n"
          "Find everything in the Hub (grid icon) or Profile.",
    ),
    _TourStep(
      icon: Icons.bar_chart_outlined,
      color: Color(0xFFE65100),
      title: "Analytics & Insights",
      body: "The Analytics tab shows:\n"
          "📊 Spending by category (tap to drill down)\n"
          "📈 50/30/20 Rule tracker\n"
          "🏥 Health score trend (30 days)\n"
          "🌍 Live exchange rates (57 currencies)\n"
          "🔮 Long-range forecast (3/6/12 months)\n"
          "🧠 Spending Personality + Mood correlation\n\n"
          "Navigation chips at top: Goals, Debts, Budgets, Wallets, Calendar, Import.",
    ),
    _TourStep(
      icon: Icons.tips_and_updates_outlined,
      color: Color(0xFF0099DD),
      title: "Pro Tips",
      body: "• Say 'my GCash is ₱500' to update wallet via AI\n"
          "• Import GCash/BPI/BDO history: Hub → Import from Bank\n"
          "• Scan receipts → 'Import Items' for multi-item parsing\n"
          "• Tag expenses with #hashtags for filtering\n"
          "• Shake phone to undo last AI action (60 sec window)\n"
          "• Profile → App Settings for Balance Mode & toggles\n"
          "• 16 achievement badges — check Hub → Achievements",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    await FeatureTour.markDone();
    widget.onDone();
  }

  void _next() {
    if (_page < _steps.length - 1) {
      _animCtrl.reset();
      setState(() => _page++);
      _animCtrl.forward();
    } else {
      _done();
    }
  }

  void _prev() {
    if (_page > 0) {
      _animCtrl.reset();
      setState(() => _page--);
      _animCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final step = _steps[_page];

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with step color
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Step counter
                    Text(
                      "${_page + 1} of ${_steps.length}",
                      style: TextStyle(
                          fontSize: 11,
                          color: step.color.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: step.color.withValues(alpha: 0.15),
                      child: Icon(step.icon, color: step.color, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(step.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),

              // Body with fade animation
              FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(step.body,
                      style: const TextStyle(fontSize: 14, height: 1.6)),
                ),
              ),

              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (i) => GestureDetector(
                    onTap: () {
                      _animCtrl.reset();
                      setState(() => _page = i);
                      _animCtrl.forward();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? step.color
                            : cs.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    // Back button (hidden on first step)
                    if (_page > 0)
                      TextButton.icon(
                        onPressed: _prev,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text("Back"),
                        style: TextButton.styleFrom(
                          foregroundColor: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _done,
                        child: Text("Skip",
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.4))),
                      ),
                    const Spacer(),
                    // Next / Let's Go button
                    ElevatedButton.icon(
                      onPressed: _next,
                      icon: Icon(
                        _page < _steps.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                        size: 18,
                      ),
                      label: Text(
                          _page < _steps.length - 1 ? "Next" : "Let's Go!"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: step.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourStep {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _TourStep(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});
}
