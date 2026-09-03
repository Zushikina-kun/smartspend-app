import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';
import '../models/expense.dart';
import '../models/budget.dart';
import '../services/db_service.dart';
import '../services/insight_service.dart';
import '../services/score_service.dart';
import '../services/currency_service.dart';
import '../services/event_bus.dart';
import '../services/notification_service.dart';
import '../services/ai_chat_service.dart';
import '../services/behavioral_feedback_service.dart';
import '../widgets/expense_tile.dart';
import '../widgets/feature_tour.dart';
import '../widgets/info_button.dart';
import 'edit_expense_screen.dart';
import 'analytics_screen.dart';
import 'ai_screen.dart';
import 'profile_screen.dart';
import 'budget_screen.dart';
import 'transactions_screen.dart';
import 'recurring_screen.dart';
import 'savings_goals_screen.dart';
import 'income_screen.dart';
import 'debt_screen.dart';
import 'currency_screen.dart';
import 'login_screen.dart';
import 'bill_calendar_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_rules_screen.dart';
import 'whats_new_screen.dart';
import 'achievements_screen.dart';
import 'bank_import_screen.dart';
import 'insurance_screen.dart';
import 'bank_comparison_screen.dart';
import 'pca_calculator_screen.dart';
import 'glossary_screen.dart';
import '../services/startup_alerts_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  late final List<Widget> _screens;
  bool _showTour = false;
  bool _isOffline = false;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    _screens = [
      Dashboard(onNavigate: (i) => setState(() => _index = i)),
      const AnalyticsScreen(),
      const AIScreen(),
      const ProfileScreen(),
    ];
    _checkTour();
    _startConnectivityCheck();
    _checkStartupAlerts();
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  void _startConnectivityCheck() {
    _checkConnectivity();
    _connectivityTimer = Timer.periodic(
        const Duration(seconds: 10), (_) => _checkConnectivity());
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted && online != !_isOffline) {
        setState(() => _isOffline = !online);
      }
    } catch (_) {
      if (mounted && !_isOffline) setState(() => _isOffline = true);
    }
  }

  Future<void> _checkTour() async {
    final should = await FeatureTour.shouldShow();
    if (should && mounted) setState(() => _showTour = true);
    // UX-5: Show What's New screen once after update
    if (!should) {
      final shouldShowNew = await WhatsNewScreen.shouldShow();
      if (shouldShowNew && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WhatsNewScreen()));
        }
      }
    }
  }

  bool get _isDemoMode => FirebaseAuth.instance.currentUser == null;

  Future<void> _checkStartupAlerts() async {
    // Delay slightly so the UI is fully built first
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Monthly reset: clear gap counters at the start of each new month
    final now = DateTime.now();
    final lastResetKey = 'gap_monthly_reset';
    final lastReset = await DBService.getSetting(lastResetKey) ?? '';
    final thisMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    if (lastReset != thisMonth) {
      await StartupAlertsService.resetMonthlyGapCounters();
      await DBService.setSetting(lastResetKey, thisMonth);
    }

    final alerts = await StartupAlertsService.checkAlerts();
    if (alerts.isEmpty || !mounted) return;

    // Separate the gap alert from the rest so we can handle it interactively
    final gapAlert =
        alerts.where((a) => a.title.contains('Missed Log')).firstOrNull;
    final otherAlerts =
        alerts.where((a) => !a.title.contains('Missed Log')).toList();

    // Show standard alerts first
    if (otherAlerts.isNotEmpty) {
      await _showStartupAlertSheet(otherAlerts);
    }

    // Then show the interactive gap dialog if there is one
    if (gapAlert != null && mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) _showGapDialog();
    }
  }

  Future<void> _showStartupAlertSheet(List<StartupAlert> alerts) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.notifications_active,
                      color: Colors.orange, size: 22),
                  SizedBox(width: 8),
                  Text("Heads Up!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ...alerts.map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: alert.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: alert.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(alert.icon, color: alert.color, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: alert.color)),
                                const SizedBox(height: 2),
                                Text(alert.message,
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Got it"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── LOGGING GAP DIALOG ──────────────────────────────────────────────────────
  /// Shows an interactive dialog for each detected logging gap.
  /// Asks the user whether they had any transactions on the missed days.
  /// Their answer is stored so ScoreService can apply the right adjustment.
  Future<void> _showGapDialog() async {
    final gaps = await StartupAlertsService.getLoggingGaps();
    if (gaps.isEmpty || !mounted) return;

    for (final gap in gaps) {
      if (!mounted) break;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _GapCheckDialog(gap: gap),
      );
    }
    // Fire AppEvent so the Dashboard child reloads and applies the gap adjustments
    if (mounted) fireEvent(AppEvent.incomeChanged);
  }

  void _showQuickAccessHub(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _QuickAccessHub(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              // Offline indicator
              if (_isOffline)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.grey[800],
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 14, color: Colors.white70),
                      SizedBox(width: 6),
                      Text("No internet — AI features unavailable",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              // Demo mode banner
              if (_isDemoMode)
                MaterialBanner(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  content: const Text(
                    "You're in Demo Mode — sign up to sync data across devices",
                    style: TextStyle(fontSize: 12),
                  ),
                  leading: const Icon(Icons.science_outlined, size: 20),
                  backgroundColor: Colors.orange.withValues(alpha: 0.15),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      ),
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              Expanded(
                child: IndexedStack(index: _index, children: _screens),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home, "Home", 0, onTap: () {
                  setState(() => _index = 0);
                  _checkTour();
                }),
                _navItem(Icons.bar_chart, "Analytics", 1),
                _navItem(Icons.smart_toy, "AI", 2),
                _navItem(Icons.grid_view_rounded, "Hub", -1,
                    onTap: () => _showQuickAccessHub(context)),
                _navItem(Icons.person, "Profile", 3),
              ],
            ),
          ),
        ),
        if (_showTour)
          FeatureTour(onDone: () => setState(() => _showTour = false)),
      ],
    );
  }

  Widget _navItem(IconData icon, String label, int idx, {VoidCallback? onTap}) {
    final selected = _index == idx;
    final color =
        selected ? Theme.of(context).colorScheme.primary : Colors.grey;
    final isAI = idx == 2;

    if (isAI) {
      // AI button gets a special circular styled look
      return InkWell(
        onTap: onTap ?? () => setState(() => _index = idx),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap ?? () => setState(() => _index = idx),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── GAP CHECK DIALOG ─────────────────────────────────────────────────────────
/// A simple, friendly dialog that asks the user whether they had any
/// transactions during a logging gap.  Their answer is persisted via
/// StartupAlertsService.recordGapResponse() so the FHS can account for
/// reality (penalty for unlogged spending; bonus for genuine no-spend days).
class _GapCheckDialog extends StatefulWidget {
  final LoggingGap gap;
  const _GapCheckDialog({required this.gap});

  @override
  State<_GapCheckDialog> createState() => _GapCheckDialogState();
}

class _GapCheckDialogState extends State<_GapCheckDialog> {
  // null = not answered yet; true = yes had transactions; false = no spending
  bool? _answer;
  bool _saving = false;

  Future<void> _submit() async {
    if (_answer == null) return;
    setState(() => _saving = true);
    await StartupAlertsService.recordGapResponse(
      GapResponse(gap: widget.gap, hadTransactions: _answer!),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gapDays = widget.gap.days;
    final gapLabel = widget.gap.label;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Missed Log Check',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gapDays == 1
                ? 'You didn\'t log anything on $gapLabel.'
                : 'You didn\'t log anything from $gapLabel ($gapDays days).',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Text(
            'Did you have any transactions on those days?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          // Yes / No toggle buttons
          Row(
            children: [
              Expanded(
                child: _AnswerButton(
                  label: 'Yes, I spent',
                  subtitle: 'but forgot to log',
                  icon: Icons.receipt_long_outlined,
                  selected: _answer == true,
                  selectedColor: Colors.orange,
                  onTap: () => setState(() => _answer = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnswerButton(
                  label: 'Nope, nothing',
                  subtitle: 'clean days!',
                  icon: Icons.check_circle_outline,
                  selected: _answer == false,
                  selectedColor: Colors.green,
                  onTap: () => setState(() => _answer = false),
                ),
              ),
            ],
          ),
          if (_answer == true) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Text(
                '💡 Head to the AI chat or Transactions tab to log those missing expenses. Your Financial Health Score will adjust once you do.',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
            ),
          ],
          if (_answer == false) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Text(
                '🌟 Nice! Clean no-spend days are great for your Financial Health Score. Keep it up!',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child:
              Text('Skip', style: TextStyle(color: theme.colorScheme.outline)),
        ),
        FilledButton(
          onPressed: _answer == null || _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Confirm'),
        ),
      ],
    );
  }
}

/// A tap-able card used inside _GapCheckDialog for Yes / No selection.
class _AnswerButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? selectedColor : Colors.grey.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? selectedColor : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? selectedColor : null)),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: selected
                        ? selectedColor.withValues(alpha: 0.8)
                        : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── QUICK ACCESS HUB ─────────────────────────────────────────────────────────

class _QuickAccessHub extends StatefulWidget {
  const _QuickAccessHub();
  @override
  State<_QuickAccessHub> createState() => _QuickAccessHubState();
}

class _QuickAccessHubState extends State<_QuickAccessHub> {
  int _goalCount = 0;
  int _debtCount = 0;
  double _debtTotal = 0; // only "owe" type
  int _planCount = 0; // installment_plans active count
  int _recurringCount = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final goals = await DBService.getGoals();
    final debts = await DBService.getDebts();
    final recurring = await DBService.getRecurring();
    // Only count "owe" type as debt total (lent = receivable, not a liability)
    final debtTotal = debts
        .where((d) => (d['type'] as String? ?? 'owe') == 'owe')
        .fold<double>(0,
            (s, d) => s + ((d['amount'] as num) - (d['paid_amount'] as num)));
    // Count active installment plans
    int planCount = 0;
    try {
      final db = await DBService.getDB();
      final plans = await db.query('installment_plans');
      planCount = plans
          .where((p) =>
              (p['months_paid'] as int? ?? 0) <
              (p['months_total'] as int? ?? 0))
          .length;
    } catch (_) {}
    if (mounted) {
      setState(() {
        _goalCount = goals.length;
        _debtCount = debts.length;
        _debtTotal = debtTotal;
        _planCount = planCount;
        _recurringCount = recurring.length;
        _loaded = true;
      });
    }
  }

  void _go(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.88,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Quick Access",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("All your features in one place",
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _tile(
                    Icons.savings_outlined,
                    "Savings Goals",
                    _loaded
                        ? "$_goalCount goal${_goalCount == 1 ? '' : 's'}"
                        : "Track your targets",
                    Colors.green,
                    () => _go(const SavingsGoalsScreen())),
                _tile(
                    Icons.account_balance_wallet_outlined,
                    "Income",
                    "Log and view income sources",
                    Colors.blue,
                    () => _go(const IncomeScreen())),
                _tile(
                    Icons.credit_card_outlined,
                    "Debts & Lending",
                    _loaded && _debtCount > 0
                        ? "${_debtTotal > 0 ? '${CurrencyService.format(_debtTotal)} owed' : ''}${_planCount > 0 ? '${_debtTotal > 0 ? ' · ' : ''}$_planCount plan${_planCount == 1 ? '' : 's'}' : ''}"
                        : "Track money owed and lent",
                    Colors.red,
                    () => _go(const DebtScreen())),
                _tile(
                    Icons.repeat,
                    "Recurring Transactions",
                    _loaded
                        ? "$_recurringCount bill${_recurringCount == 1 ? '' : 's'} & subscriptions"
                        : "Bills, subscriptions & more",
                    Colors.orange,
                    () => _go(const RecurringScreen())),
                _tile(
                    Icons.pie_chart_outline,
                    "Budgets",
                    "Set and manage category budgets",
                    Colors.purple,
                    () => _go(const BudgetScreen())),
                _tile(
                    Icons.currency_exchange,
                    "Currency Exchange",
                    "Live rates for 34+ currencies",
                    Colors.teal,
                    () => _go(const CurrencyScreen())),
                _tile(
                    Icons.receipt_long_outlined,
                    "Transactions",
                    "Full searchable expense history",
                    Colors.indigo,
                    () => _go(const TransactionsScreen())),
                _tile(
                    Icons.credit_score_outlined,
                    "Installment & Payment Plans",
                    "Track phones, gadgets, ShopeePayLater, GCash GLoan & more",
                    Colors.purple,
                    () => _go(const DebtScreen())),
                _tile(
                    Icons.account_balance_wallet_outlined,
                    "My Wallets",
                    "Cash on Hand, GCash, Maya, BDO, BPI & more — track liquid money",
                    Colors.green, () async {
                  Navigator.pop(context);
                  // Load wallets then show sheet
                  final wallets = await DBService.getWallets();
                  if (context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => WalletsSheet(
                        wallets: wallets,
                        onChanged: () {},
                      ),
                    );
                  }
                }),
                _tile(
                    Icons.calendar_month_outlined,
                    "Bill Calendar",
                    "See all upcoming bills by date",
                    Colors.orange,
                    () => _go(const BillCalendarScreen())),
                _tile(
                    Icons.category_outlined,
                    "Categories",
                    "Manage custom expense categories",
                    Colors.teal,
                    () => _go(const ManageCategoriesScreen())),
                _tile(
                    Icons.rule_outlined,
                    "Auto-Categorization Rules",
                    "Keyword → category rules for faster logging",
                    Colors.deepPurple,
                    () => _go(const ManageRulesScreen())),
                _tile(
                    Icons.account_balance_outlined,
                    "Import from Bank / GCash",
                    "Paste GCash, BPI, BDO, Maya, or any bank history",
                    Colors.green, () async {
                  Navigator.pop(context);
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BankImportScreen()));
                }),
                _tile(
                    Icons.shield_outlined,
                    "Insurance & Contributions",
                    "SSS, PhilHealth, Pag-IBIG, insurance premiums & due dates",
                    Colors.indigo,
                    () => _go(const InsuranceScreen())),
                _tile(
                    Icons.account_balance,
                    "PH Banks & Investments",
                    "Compare 20 banks, digital banks, e-wallets, and investment options",
                    Colors.blue,
                    () => _go(const BankComparisonScreen())),
                _tile(
                    Icons.calculate_outlined,
                    "Peso Cost Averaging",
                    "Plan your regular investments — MP2, UITFs, stocks",
                    Colors.teal,
                    () => _go(const PCACalculatorScreen())),
                _tile(
                    Icons.menu_book_outlined,
                    "Financial Glossary",
                    "23 key terms explained in plain Filipino-English — FHS, MP2, DTI, UITF and more",
                    Colors.deepPurple,
                    () => _go(const GlossaryScreen())),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  final void Function(int) onNavigate;
  const Dashboard({super.key, required this.onNavigate});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Expense> _expenses = [];
  List<Budget> _budgets = [];
  double _totalSpent = 0;
  double _lastMonthTotal = 0;
  double _monthlyIncome = 0;
  String _insight = "Analyzing your expenses...";
  int _score = 0;
  bool _loadingInsight = true;
  List<String> _overBudgetCategories = [];
  List<Map<String, dynamic>> _overdueRecurring = [];
  List<Map<String, dynamic>> _upcomingDebts = [];
  List<Map<String, dynamic>> _allRecurring = [];
  List<Map<String, dynamic>> _quickLogItems = []; // top frequent expenses
  List<Map<String, dynamic>> _recurringCandidates =
      []; // auto-detected subscriptions
  List<Map<String, dynamic>> _wallets = []; // wallet balances for home display
  StreamSubscription? _eventSub;
  int _lastInsightExpenseCount = -1; // only refresh insight when data changes
  double _dailySpent = 0;
  double _dailyLimit = 0;
  int _streak = 0; // consecutive days under budget
  List<String> _earnedBadges = [];
  // BF-2: Plain-language score narrative
  String _scoreNarrative = '';
  // BF-1: Pending celebration event to show once after _loadData completes
  CelebrationEvent? _pendingCelebration;
  // BF-1: Logging streak (days with ≥1 expense) — needed for celebration check
  int _logStreak = 0;

  // ── NEW: lightweight mode + multi-period spending limits ─────────────────
  bool _incomeWalletMode = true;
  double _spendingLimit = 0; // kept for FHS shim
  String _spendingLimitPeriod = 'monthly';
  double _spentInPeriod = 0;
  Map<String, double> _allLimits = {};
  Map<String, double> _allSpent = {};

  // ── SECTION VISIBILITY (user-controlled via App Settings) ────────────────
  bool _showSubscriptions = true;
  bool _showQuickLog = true;
  bool _showBadges = true;
  bool _showMoodHome = true;
  bool _showForecast = true;
  bool _showPrediction = true;

  // Track the most recently added expense date so budget/limit alerts
  // are suppressed when a historical (past-month) entry was just logged.
  String? _lastAddedExpenseDate;

  final _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  final _lastMonth = DateFormat('yyyy-MM')
      .format(DateTime(DateTime.now().year, DateTime.now().month - 1));

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh when any expense/budget/income/goal changes
    _eventSub = AppEventBus.instance.stream.listen((event) {
      if (event == AppEvent.expenseChanged ||
          event == AppEvent.budgetChanged ||
          event == AppEvent.incomeChanged ||
          event == AppEvent.goalChanged) {
        // Reset insight cache on income change (covers logout/account switch)
        if (event == AppEvent.incomeChanged) {
          _lastInsightExpenseCount = -1;
        }
        // Capture the most recently inserted expense date before reloading
        // so the budget/limit alert section can decide whether to suppress
        // notifications for historical (past-month) entries.
        if (event == AppEvent.expenseChanged) {
          DBService.getExpenses().then((exps) {
            if (exps.isNotEmpty) _lastAddedExpenseDate = exps.first.date;
          }).catchError((_) {});
        }
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Parallelize independent DB reads
    final expensesFuture = DBService.getExpenses();
    final thisMonthFuture = DBService.getExpenses(month: _currentMonth);
    final lastMonthTotalFuture = DBService.getTotalSpent(month: _lastMonth);
    final totalFuture = DBService.getTotalSpent(month: _currentMonth);
    final budgetsFuture = DBService.getBudgets();
    final incomeFuture = DBService.getMonthlyIncome();
    final recurringFuture = DBService.getRecurring();
    final debtsFuture = DBService.getDebts();

    final expenses = await expensesFuture;
    final thisMonthExpenses = await thisMonthFuture;
    final lastMonthTotal = await lastMonthTotalFuture;
    final total = await totalFuture;
    final budgets = await budgetsFuture;
    final income = await incomeFuture;
    final recurring = await recurringFuture;
    final debts = await debtsFuture;

    // Load new lightweight mode + spending limit settings in parallel
    final incomeWalletMode = await DBService.getIncomeWalletMode();
    final tightest = await DBService.getTightestLimit();
    final spendingLimit = tightest['limit'] as double;
    final spendingLimitPeriod = tightest['period'] as String;
    final spentInPeriod = tightest['spent'] as double;
    // Multi-period limits
    final allLimits = await DBService.getAllLimits();
    final allSpent = await DBService.getAllSpent();

    final expenseData = thisMonthExpenses
        .map(
            (e) => {'amount': e.amount, 'category': e.category, 'date': e.date})
        .toList();
    final rawScore = ScoreService.calculateScore(
      expenseData,
      budgets: budgets,
      monthlyIncome: incomeWalletMode ? income : 0,
      lightweightMode: !incomeWalletMode,
      spendingLimit: spendingLimit,
      spendingLimitPeriod: spendingLimitPeriod,
      spentInPeriod: spentInPeriod,
    );
    // Apply all FHS adjustments: decay penalty + gap penalty/bonus
    final score = await ScoreService.applyAllAdjustments(rawScore);

    // Load budget alerts setting before setState
    final budgetAlertsEnabled =
        (await DBService.getSetting('budget_alerts_enabled')) != 'false';
    // Section visibility settings
    final showSubscriptions =
        (await DBService.getSetting('show_subscriptions')) != 'false';
    final showQuickLog =
        (await DBService.getSetting('show_quick_log')) != 'false';
    final showBadges = (await DBService.getSetting('show_badges')) != 'false';
    final showMoodHome =
        (await DBService.getSetting('show_mood_home')) != 'false';
    final showForecast =
        (await DBService.getSetting('show_forecast')) != 'false';
    final showPrediction =
        (await DBService.getSetting('show_prediction')) != 'false';
    if (!mounted) return; // widget may have been disposed during async gap
    setState(() {
      _expenses = expenses;
      _totalSpent = total;
      _lastMonthTotal = lastMonthTotal;
      _budgets = budgets;
      _score = score;
      _monthlyIncome = income;
      // Lightweight mode & spending limit state
      _incomeWalletMode = incomeWalletMode;
      _spendingLimit = spendingLimit;
      _spendingLimitPeriod = spendingLimitPeriod;
      _spentInPeriod = spentInPeriod;
      _spentInPeriod = spentInPeriod;
      _allLimits = allLimits;
      _allSpent = allSpent;
      // Section visibility
      _showSubscriptions = showSubscriptions;
      _showQuickLog = showQuickLog;
      _showBadges = showBadges;
      _showMoodHome = showMoodHome;
      _showForecast = showForecast;
      _showPrediction = showPrediction;
      // Only show loading indicator if we don't have an insight yet
      if (_insight == "Analyzing your expenses...") _loadingInsight = true;
      final spent = <String, double>{};
      for (final e in expenses) {
        if (e.date.startsWith(_currentMonth)) {
          spent[e.category] = (spent[e.category] ?? 0) + e.amount;
        }
      }
      _overBudgetCategories = budgets
          .where((b) => (spent[b.category] ?? 0) >= b.amount * 0.8)
          .map((b) => b.category)
          .toList();

      // Overdue recurring items — expenses only (is_expense=1), not income
      _overdueRecurring = recurring.where((r) {
        if ((r['is_expense'] as int? ?? 1) != 1) return false; // skip income
        try {
          final d = DateTime.parse(r['next_date'] as String);
          return d.isBefore(DateTime.now()) ||
              d.difference(DateTime.now()).inDays == 0;
        } catch (_) {
          return false;
        }
      }).toList();
      _allRecurring = recurring;

      // Compute quick-log items: top 4 most frequently logged expenses
      final freqMap = <String, Map<String, dynamic>>{};
      for (final e in expenses) {
        final key = '${e.itemName}|${e.category}';
        if (!freqMap.containsKey(key)) {
          freqMap[key] = {
            'item_name': e.itemName,
            'category': e.category,
            'amount': e.amount,
            'count': 0,
          };
        }
        freqMap[key]!['count'] = (freqMap[key]!['count'] as int) + 1;
        // Update amount to most recent
        freqMap[key]!['amount'] = e.amount;
      }
      final sorted = freqMap.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      _quickLogItems = sorted.take(4).toList();

      // Upcoming debts (due within 7 days or overdue, not fully paid)
      _upcomingDebts = debts.where((d) {
        final dueDate = d['due_date'] as String?;
        if (dueDate == null || dueDate.isEmpty) return false;
        final remaining = (d['amount'] as num) - (d['paid_amount'] as num);
        if (remaining <= 0) return false;
        try {
          final due = DateTime.parse(dueDate);
          return due.difference(DateTime.now()).inDays <= 7;
        } catch (_) {
          return false;
        }
      }).toList();

      // Fire budget alert notifications — graduated thresholds: 50%, 80%, 100%
      // ONLY fire for current-month totals that crossed a threshold on THIS reload.
      // This prevents historical expense entries from triggering "budget exceeded"
      // alerts — a past-month expense doesn't affect this month's budget status.
      final alertsForCurrentPeriod = _lastAddedExpenseDate == null ||
          _lastAddedExpenseDate!.startsWith(_currentMonth);
      for (final b in budgets) {
        final spentAmt = spent[b.category] ?? 0;
        final ratio = b.amount > 0 ? spentAmt / b.amount : 0.0;
        if ((ratio >= 1.0 || ratio >= 0.8 || ratio >= 0.5) &&
            budgetAlertsEnabled &&
            alertsForCurrentPeriod) {
          NotificationService.showBudgetAlert(b.category, spentAmt, b.amount);
        }
      }

      // Daily spending limit check (#14)
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final todaySpent = expenses.where((e) {
        try {
          // Normalize date format to YYYY-MM-DD for safe comparison
          return DateTime.parse(e.date).toIso8601String().substring(0, 10) ==
              today;
        } catch (_) {
          return e.date == today;
        }
      }).fold<double>(0, (s, e) => s + e.amount);
      _dailySpent = todaySpent;
    });

    // Load daily limit and check notification
    final dailyLimit = await DBService.getDailyLimit();
    if (mounted) setState(() => _dailyLimit = dailyLimit);
    if (dailyLimit > 0 && _dailySpent >= dailyLimit * 0.8) {
      NotificationService.showDailyLimitAlert(_dailySpent, dailyLimit);
    }

    // Multi-period limit notification checks
    // Only fire when the last-added expense is in the current period
    final lastDate = _lastAddedExpenseDate;
    final nowStr = DateTime.now().toIso8601String();
    final isCurrentDay = lastDate == nowStr.substring(0, 10);
    final isCurrentMonth =
        lastDate == null || lastDate.startsWith(nowStr.substring(0, 7));
    for (final period in ['daily', 'weekly', 'monthly', 'yearly']) {
      final lim = allLimits[period] ?? 0;
      final sp = allSpent[period] ?? 0;
      // Skip daily limit alert for non-today entries
      if (period == 'daily' && !isCurrentDay) continue;
      // Skip monthly/weekly/yearly alerts for past-month entries
      if (period != 'daily' && !isCurrentMonth) continue;
      if (lim > 0 && sp >= lim * 0.8) {
        NotificationService.checkSpendingLimitAlert(
            spent: sp, limit: lim, period: period);
      }
    }

    // Spending streak calculation (#13)
    _computeStreak();

    // BF-2: Compute plain-language score narrative from breakdown
    final breakdownForNarrative = ScoreService.getBreakdown(
      expenseData,
      budgets: budgets,
      monthlyIncome: incomeWalletMode ? income : 0,
      lightweightMode: !incomeWalletMode,
      spendingLimit: spendingLimit,
      spendingLimitPeriod: spendingLimitPeriod,
    );
    final narrative = BehavioralFeedbackService.scoreSummaryNarrative(
      score,
      breakdownForNarrative,
      !incomeWalletMode,
    );

    // BF-1: Compute log streak for celebration check
    int logStreak = 0;
    final now2 = DateTime.now();
    for (int d = 0; d < 60; d++) {
      final checkDate = DateTime(now2.year, now2.month, now2.day - d)
          .toIso8601String()
          .substring(0, 10);
      if (thisMonthExpenses.any((e) => e.date.startsWith(checkDate))) {
        logStreak++;
      } else {
        break;
      }
    }

    // BF-1: Check for celebration event (score up, streak milestone, all budgets)
    final celebration = await BehavioralFeedbackService.checkForCelebration(
      currentScore: score,
      logStreak: logStreak,
      breakdown: breakdownForNarrative,
    );

    if (mounted) {
      setState(() {
        _scoreNarrative = narrative;
        _logStreak = logStreak;
        _pendingCelebration = celebration;
      });
      // Show celebration banner if one was triggered
      if (celebration != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCelebrationBanner(celebration);
        });
      }
    }

    // Save daily score snapshot for history tracking
    DBService.saveScoreSnapshot(score);
    // GM-6: Check for level-up milestone
    NotificationService.checkLevelUp(score);

    // Check and update warning decay system
    ScoreService.checkAndUpdateDecay(
      expenses: thisMonthExpenses
          .map((e) =>
              {'category': e.category, 'amount': e.amount, 'date': e.date})
          .toList(),
      budgets: budgets,
    ).then((_) async {
      // Fire decay notifications if needed
      final decayDays = await ScoreService.getDecayDays();
      if (decayDays > 0) {
        // Find the most over-budget category for the notification
        final catTotals = <String, double>{};
        for (final e in thisMonthExpenses) {
          catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
        }
        for (final b in budgets) {
          final spent = catTotals[b.category] ?? 0;
          if (spent > b.amount) {
            NotificationService.showDecayWarning(
              decayDays: decayDays,
              category: b.category,
              spent: spent,
              budget: b.amount,
              monthlyIncome: income,
            );
            break; // only notify for the first exceeded budget
          }
        }
      }
    });

    final insightData = thisMonthExpenses
        .take(20)
        .map((e) => {
              'category': e.category,
              'amount': e.amount,
              'item_name': e.itemName
            })
        .toList();

    // M3: Only call Groq for insights if expense count changed — avoids burning daily limit
    final currentCount = thisMonthExpenses.length;
    if (currentCount == _lastInsightExpenseCount &&
        _insight != "Analyzing your expenses...") {
      // Data hasn't changed — keep existing insight, no API call needed
      if (mounted) setState(() => _loadingInsight = false);
      return;
    }
    _lastInsightExpenseCount = currentCount;

    try {
      final insight = await InsightService.generateInsights(
        insightData,
        actualTotal: total, // pass real DB total to prevent AI hallucination
      );
      if (mounted)
        setState(() {
          _insight = insight;
          _loadingInsight = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _insight = "Could not load insights.";
          _loadingInsight = false;
        });
    }

    // Subscription auto-detection — runs once per day, non-blocking
    try {
      final candidates = await DBService.detectRecurringCandidates();
      if (mounted) setState(() => _recurringCandidates = candidates);
    } catch (_) {}

    // Load wallet balances for home display
    try {
      final wallets = await DBService.getWallets();
      if (mounted) setState(() => _wallets = wallets);
    } catch (_) {}
  }

  Future<void> _editExpense(Expense e) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: e)));
    if (result == true) _loadData();
  }

  Future<void> _deleteExpense(int id) async {
    await DBService.deleteExpense(id);
    _loadData();
  }

  // BF-1: Show a celebration banner using a themed SnackBar
  void _showCelebrationBanner(CelebrationEvent event) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(event.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(event.message,
                      style: const TextStyle(fontSize: 11, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: event.type == CelebrationEventType.scoreImproved
            ? Colors.green[700]
            : event.type == CelebrationEventType.streakMilestone
                ? Colors.orange[700]
                : Colors.blue[700],
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _computeStreak() async {
    try {
      final history = await DBService.getScoreHistory(days: 60);
      final budgets = _budgets;
      if (budgets.isEmpty || history.isEmpty) return;

      // Streak = consecutive days where score >= 60 (fair or better)
      int streak = 0;
      final sorted = history.reversed.toList();
      for (final h in sorted) {
        if ((h['score'] as int) >= 60) {
          streak++;
        } else {
          break;
        }
      }

      // Compute badges
      final badges = <String>[];
      if (streak >= 3) badges.add('🔥 $streak-day streak');
      if (streak >= 7) badges.add('💯 Week on track');
      if (streak >= 30) badges.add('🏆 30-day champion');
      // Check savings goal progress
      final goals = await DBService.getGoals();
      for (final g in goals) {
        final current = (g['current_amount'] as num).toDouble();
        final target = (g['target_amount'] as num).toDouble();
        if (current >= 1000 && target > 0) badges.add('💰 ₱1K+ saved');
        if (current >= target) badges.add('🎯 Goal reached!');
      }

      // Check logging streak (has expenses today)
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final hasToday = _expenses.any((e) => e.date == today);
      if (hasToday && history.length >= 7) badges.add('📅 Active tracker');

      // GM-9: "Better than last month" comparison badge
      if (_lastMonthTotal > 0 && _totalSpent < _lastMonthTotal) {
        final saved = _lastMonthTotal - _totalSpent;
        badges.add('📉 ₱${saved.toStringAsFixed(0)} less than last month');
      }
      int logStreak = 0;
      final now2 = DateTime.now();
      for (int d = 0; d < 60; d++) {
        final checkDate = DateTime(now2.year, now2.month, now2.day - d)
            .toIso8601String()
            .substring(0, 10);
        if (_expenses.any((e) => e.date == checkDate)) {
          logStreak++;
        } else {
          break;
        }
      }
      if (logStreak >= 3 && logStreak > streak) {
        badges.insert(0, '📝 $logStreak-day logging streak');
      }

      if (mounted) {
        setState(() {
          _streak = streak;
          _earnedBadges = badges.take(3).toList();
        });
      }
    } catch (_) {}
  }

  String _scoreLabel(int s) {
    if (s >= 90) return "Excellent 👑";
    if (s >= 80) return "Great 🏆";
    if (s >= 70) return "Good ⭐";
    if (s >= 60) return "Fair 🌱";
    return "Needs Work 📉";
  }

  /// Per-component actionable recommendation shown in FHS breakdown dialog.
  static String _componentRec(String component, int pts, bool incomeMode) {
    if (pts >= 20) return ''; // good enough — no tip needed
    switch (component) {
      case 'savings_rate':
        return pts == 0
            ? 'Set your income first to track savings rate'
            : 'Try saving ₱500 more per month to improve this component';
      case 'overspend_control':
        return 'Avoid spending more than your daily budget (income ÷ days in month) on most days';
      case 'budget_adherence':
        return pts == 0
            ? 'Set category budgets (e.g. Food, Transport) to enable this component'
            : 'Keep spending under your category limits — especially the ones marked over budget';
      case 'logging_consistency':
        return 'Log at least one expense every day you spend money — even a small one';
      case 'spending_restraint':
        return 'Stay within your ${incomeMode ? 'spending limit' : 'set spending limit'} — try the daily view to track pace';
      case 'category_balance':
        return 'Spread spending across more categories instead of concentrating on one';
      case 'habit_streak':
        return 'Log something every day — a 14-day streak earns full points here';
      default:
        return 'Keep improving your habits to raise this component';
    }
  }

  Widget _buildRecurringAutoLogCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.repeat, color: Colors.orange, size: 16),
                const SizedBox(width: 6),
                const Text("Bills due — log them now?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _overdueRecurring.take(3).map((r) {
                final amt = (r['amount'] as num).toDouble();
                return ActionChip(
                  avatar: const Icon(Icons.add_circle_outline,
                      size: 14, color: Colors.orange),
                  label: Text("${r['title']} ${CurrencyService.format(amt)}",
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
                  onPressed: () async {
                    final isExpense = (r['is_expense'] as int? ?? 1) == 1;
                    final now = DateTime.now();
                    if (isExpense) {
                      await DBService.insertExpense({
                        'item_name': r['title'],
                        'category': r['category'],
                        'amount': amt,
                        'date': now.toIso8601String().substring(0, 10),
                        'time': now.toIso8601String().substring(11, 16),
                        'payment_method': 'Cash',
                        'notes': 'Auto-logged from recurring',
                        'ai_generated': 0,
                        'confidence_score': 1.0,
                      });
                    } else {
                      await DBService.insertIncome({
                        'title': r['title'],
                        'amount': amt,
                        'category':
                            r['category'] == 'Bills' ? 'Salary' : r['category'],
                        'date': now.toIso8601String().substring(0, 10),
                        'is_recurring': 1,
                      });
                    }
                    // Advance next_date
                    try {
                      final current = DateTime.parse(r['next_date'] as String);
                      final freq = r['frequency'] as String? ?? 'monthly';
                      DateTime next;
                      switch (freq) {
                        case 'daily':
                          next = current.add(const Duration(days: 1));
                          break;
                        case 'weekly':
                          next = current.add(const Duration(days: 7));
                          break;
                        case 'yearly':
                          final lastDay =
                              DateTime(current.year + 1, current.month + 1, 0)
                                  .day;
                          next = DateTime(current.year + 1, current.month,
                              current.day.clamp(1, lastDay));
                          break;
                        default:
                          final nm =
                              current.month == 12 ? 1 : current.month + 1;
                          final ny = current.month == 12
                              ? current.year + 1
                              : current.year;
                          final ld = DateTime(ny, nm + 1, 0).day;
                          next = DateTime(ny, nm, current.day.clamp(1, ld));
                      }
                      await DBService.updateRecurring({
                        ...r,
                        'next_date': next.toIso8601String().substring(0, 10),
                      });
                    } catch (_) {}
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("${r['title']} logged ✓"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ));
                      _loadData();
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLogChips(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Quick Log",
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              InfoButton(
                title: "Quick Log",
                body:
                    "These are your most frequently logged expenses. One tap logs them instantly — no typing needed.\n\n"
                    "The app automatically picks your top 4 most common expenses from your history.",
                size: 13,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _quickLogItems.map((item) {
              final amt = (item['amount'] as num).toDouble();
              return ActionChip(
                avatar: Icon(Icons.flash_on, size: 14, color: cs.primary),
                label: Text(
                    "${item['item_name']} ${CurrencyService.format(amt)}",
                    style: const TextStyle(fontSize: 12)),
                backgroundColor: cs.primary.withValues(alpha: 0.08),
                side: BorderSide(color: cs.primary.withValues(alpha: 0.2)),
                onPressed: () async {
                  final now = DateTime.now();
                  await DBService.insertExpense({
                    'item_name': item['item_name'],
                    'category': item['category'],
                    'amount': amt,
                    'date': now.toIso8601String().substring(0, 10),
                    'time': now.toIso8601String().substring(11, 19),
                    'payment_method': 'Cash',
                    'notes': 'Quick log',
                    'ai_generated': 0,
                    'confidence_score': 1.0,
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("${item['item_name']} logged ✓"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ));
                    _loadData();
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePortals(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final portals = [
      (
        Icons.bar_chart_outlined,
        "Analytics",
        "Charts & insights",
        Colors.blue,
        () => widget.onNavigate(1),
      ),
      (
        Icons.calendar_month_outlined,
        "Bill Calendar",
        "Upcoming bills",
        Colors.orange,
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BillCalendarScreen())),
      ),
      (
        Icons.savings_outlined,
        "Goals",
        "Savings targets",
        Colors.green,
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SavingsGoalsScreen())),
      ),
      (
        Icons.credit_card_outlined,
        "Debts & Plans",
        "Owed & installments",
        Colors.red,
        () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const DebtScreen())),
      ),
      (
        Icons.account_balance_wallet_outlined,
        "My Wallets",
        "Cash, GCash, banks",
        Colors.green,
        () async {
          final wallets = await DBService.getWallets();
          if (!context.mounted) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => WalletsSheet(
              wallets: wallets,
              onChanged: () async {
                final updated = await DBService.getWallets();
                if (mounted) setState(() => _wallets = updated);
              },
            ),
          );
        }
      ),
      (
        Icons.pie_chart_outline,
        "Budgets",
        "Category limits",
        Colors.purple,
        () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
      ),
      (
        Icons.account_balance_outlined,
        "Import",
        "GCash, BPI, BDO",
        Colors.teal,
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BankImportScreen())),
      ),
      (
        Icons.repeat,
        "Recurring",
        "Bills & subs",
        Colors.deepOrange,
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RecurringScreen())),
      ),
      (
        Icons.emoji_events_outlined,
        "Achievements",
        "Badges & streaks",
        Colors.amber,
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AchievementsScreen())),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Quick Access",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            InfoButton(
              title: "Quick Access",
              body: "Shortcuts to your most-used features.\n\n"
                  "• Analytics — charts, 50/30/20 rule, spending forecasts\n"
                  "• Bill Calendar — see all upcoming bills by date\n"
                  "• Goals — track savings targets and emergency fund\n"
                  "• Debts & Plans — money owed, lent, and installment plans\n"
                  "• My Wallets — Cash on Hand, GCash, Maya, bank balances\n"
                  "• Budgets — set and track category spending limits\n"
                  "• Import — bulk import from GCash, BPI, BDO, Maya\n"
                  "• Recurring — manage bills and subscriptions\n"
                  "• Achievements — badges and spending streaks\n\n"
                  "All features are also in the Hub (grid icon in the bottom bar).",
              size: 13,
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.15,
          children: portals.map((p) {
            return GestureDetector(
              onTap: p.$5,
              child: Container(
                decoration: BoxDecoration(
                  color: p.$4.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.$4.withValues(alpha: 0.2)),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(p.$1, color: p.$4, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      p.$2,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.$3,
                      style: TextStyle(
                          fontSize: 9,
                          color: cs.onSurface.withValues(alpha: 0.5)),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDailyLimitCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ratio =
        _dailyLimit > 0 ? (_dailySpent / _dailyLimit).clamp(0.0, 1.0) : 0.0;
    final isOver = _dailySpent >= _dailyLimit;
    final isWarning = ratio >= 0.8 && !isOver;
    final color = isOver
        ? Colors.red
        : isWarning
            ? Colors.orange
            : cs.primary;

    // Smart daily allowance: remaining monthly budget ÷ days left
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day + 1;
    final totalBudget =
        _monthlyIncome > 0 ? _monthlyIncome : _dailyLimit * daysInMonth;
    final remaining = totalBudget - _totalSpent;
    final smartDaily =
        daysLeft > 0 ? (remaining / daysLeft).clamp(0.0, double.infinity) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                Text("Today's Spending",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color)),
                const Spacer(),
                Text(
                  "${CurrencyService.format(_dailySpent)} / ${CurrencyService.format(_dailyLimit)}",
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            if (isOver)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    "Daily limit exceeded by ${CurrencyService.format(_dailySpent - _dailyLimit)}",
                    style: const TextStyle(fontSize: 11, color: Colors.red)),
              )
            else if (isWarning)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    "${(ratio * 100).toStringAsFixed(0)}% of daily limit used",
                    style: const TextStyle(fontSize: 11, color: Colors.orange)),
              ),
            // Smart daily allowance — Cleo Autopilot-style
            if (smartDaily > 0 && _monthlyIncome > 0) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "💡 Smart allowance: ${CurrencyService.format(smartDaily)}/day for remaining $daysLeft days",
                  style: TextStyle(
                      fontSize: 10, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Period-based spending limit progress card.
  /// Multi-period spending limit card — tappable to open SpendingLimitsSheet.
  Widget _buildSpendingLimitCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = ['daily', 'weekly', 'monthly', 'yearly']
        .where((p) => (_allLimits[p] ?? 0) > 0)
        .toList();
    if (active.isEmpty) return const SizedBox.shrink();

    final periodLabels = {
      'daily': 'Today',
      'weekly': 'This Week',
      'monthly': 'This Month',
      'yearly': 'This Year'
    };
    final periodIcons = {
      'daily': Icons.today_outlined,
      'weekly': Icons.view_week_outlined,
      'monthly': Icons.calendar_month_outlined,
      'yearly': Icons.event_note_outlined
    };

    return GestureDetector(
      onTap: () => SpendingLimitsSheet.show(context, onChanged: () {
        // Immediate state refresh + full data reload for instant visual update
        DBService.getAllLimits().then((lim) {
          DBService.getAllSpent().then((sp) {
            if (mounted)
              setState(() {
                _allLimits = lim;
                _allSpent = sp;
              });
          });
        });
        _loadData();
      }),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.speed_outlined,
                    size: 14, color: cs.onSurface.withValues(alpha: 0.55)),
                const SizedBox(width: 5),
                Text("Spending Limits",
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.55))),
                const Spacer(),
                Icon(Icons.edit_outlined,
                    size: 12, color: cs.onSurface.withValues(alpha: 0.35)),
                const SizedBox(width: 3),
                Text("Edit",
                    style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.35))),
              ]),
              const SizedBox(height: 8),
              ...active.map((period) {
                final limit = _allLimits[period] ?? 0;
                final spent = _allSpent[period] ?? 0;
                final ratio = (spent / limit).clamp(0.0, 1.0);
                final isOver = spent >= limit;
                final isWarn = ratio >= 0.8 && !isOver;
                final color = isOver
                    ? Colors.red
                    : isWarn
                        ? Colors.orange
                        : cs.primary;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(periodIcons[period], size: 13, color: color),
                          const SizedBox(width: 4),
                          Text(periodLabels[period]!,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: color)),
                          const Spacer(),
                          Text(
                              "${CurrencyService.format(spent)} / ${CurrencyService.format(limit)}",
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color)),
                        ]),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 5,
                              backgroundColor: color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(color)),
                        ),
                        if (isOver || isWarn)
                          Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                isOver
                                    ? "Over by ${CurrencyService.format(spent - limit)}"
                                    : "${CurrencyService.format(limit - spent)} remaining",
                                style: TextStyle(fontSize: 9, color: color),
                              )),
                      ]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesRow(BuildContext context) {
    if (_earnedBadges.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Achievements",
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500)),
              if (_streak > 0) ...[
                const SizedBox(width: 6),
                Text("· $_streak-day streak",
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.primary.withValues(alpha: 0.7))),
              ],
              const SizedBox(width: 4),
              InfoButton(
                title: "Achievements & Streaks",
                body: "Badges you earn by staying on track financially.\n\n"
                    "🔥 Streak — consecutive days with a Fair or Good score (≥60)\n"
                    "💯 Week on track — 7+ day streak\n"
                    "🏆 30-day champion — 30+ day streak\n"
                    "💰 ₱1K+ saved — a savings goal has ₱1,000+ contributed\n"
                    "🎯 Goal reached — a savings goal is 100% funded\n"
                    "📅 Active tracker — logged expenses today",
                size: 13,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _earnedBadges
                .map((badge) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: cs.primary.withValues(alpha: 0.25)),
                      ),
                      child: Text(badge,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.primary,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSummaryCard(BuildContext context) {
    final total = _wallets.fold<double>(0, (s, w) => s + (w['balance'] as num));
    final nonZero = _wallets.where((w) => (w['balance'] as num) > 0).toList();
    final hasBalances = nonZero.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () async {
          final wallets = await DBService.getWallets();
          if (!context.mounted) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => WalletsSheet(
              wallets: wallets,
              onChanged: () async {
                final updated = await DBService.getWallets();
                if (mounted) setState(() => _wallets = updated);
              },
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade600,
                Colors.green.shade800,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text("My Wallets",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("Tap to manage",
                        style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                hasBalances
                    ? CurrencyService.format(total)
                    : "₱0.00 — Tap to set up",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              if (hasBalances) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: nonZero.take(4).map((w) {
                    return Text(
                      "${w['icon'] ?? '💵'} ${w['name']}: ${CurrencyService.format((w['balance'] as num).toDouble())}",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    );
                  }).toList(),
                ),
              ] else ...[
                const SizedBox(height: 4),
                const Text(
                  "Track Cash, GCash, Maya, banks & more",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogAllowanceButton(BuildContext context) {
    // Only show if user has income set
    if (_monthlyIncome <= 0) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    // Calculate per-day amount from monthly income
    final dailyAmount = _monthlyIncome / 22; // ~22 working days/month

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _logAllowance(dailyAmount),
        onLongPress: () => _logAllowanceCustom(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_card, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add Money to Wallet",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.blue)),
                    Text(
                      "Tap: +${CurrencyService.format(dailyAmount)} to Cash · Long-press: custom amount",
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.touch_app, size: 16, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logAllowance(double amount) async {
    try {
      // 1. Log as income entry
      await DBService.insertIncome({
        'title': 'Daily Allowance',
        'amount': amount,
        'category': 'Allowance',
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'is_recurring': 0,
      });
      // 2. Add to Cash on Hand wallet
      final wallet = await DBService.findWalletByName('Cash on Hand');
      if (wallet != null) {
        final newBal = ((wallet['balance'] as num) + amount).toDouble();
        await DBService.setWalletBalance(wallet['id'] as int, newBal);
      }
      fireEvent(AppEvent.incomeChanged);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "✓ Allowance +${CurrencyService.format(amount)} added to Cash on Hand"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (_) {}
  }

  Future<void> _logAllowanceCustom() async {
    final ctrl = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Allowance"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How much did you receive today?",
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                prefixText: "${CurrencyService.symbol} ",
                hintText: "e.g. 330, 660, 990",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text("Tip: Got 2 days' worth? Enter the total.",
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, double.tryParse(ctrl.text)),
            child: const Text("Log"),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      await _logAllowance(result);
    }
  }

  Widget _buildSubscriptionSummaryCard(BuildContext context) {
    // Show subscriptions from recurring table (is_expense=1, monthly/yearly)
    final subs = _allRecurring.where((r) {
      final isExp = (r['is_expense'] as int? ?? 1) == 1;
      final freq = r['frequency'] as String? ?? '';
      return isExp &&
          (freq == 'monthly' || freq == 'weekly' || freq == 'yearly');
    }).toList();
    if (subs.isEmpty) return const SizedBox.shrink();

    // Convert all to monthly equivalent
    double totalMonthly = 0;
    for (final s in subs) {
      final amt = (s['amount'] as num).toDouble();
      final freq = s['frequency'] as String? ?? 'monthly';
      double monthly = amt;
      if (freq == 'weekly') monthly = amt * 4.33;
      if (freq == 'yearly') monthly = amt / 12;
      totalMonthly += monthly;
    }
    if (totalMonthly < 100) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.subscriptions_outlined,
                    color: Colors.purple, size: 16),
                const SizedBox(width: 6),
                const Text("Subscription Summary",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.purple)),
                const SizedBox(width: 4),
                const InfoButton(
                  title: "Subscription Summary",
                  body:
                      "Shows all your active recurring expenses (bills, subscriptions) and their combined monthly cost.\n\n"
                      "Monthly total = sum of all recurring expenses converted to monthly equivalent.\n"
                      "Annual total = monthly × 12.\n\n"
                      "Tap Hub → Recurring Transactions to manage or log them.",
                  size: 13,
                ),
                const Spacer(),
                Text(
                  "${CurrencyService.format(totalMonthly)}/mo",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "${subs.length} active subscription${subs.length == 1 ? '' : 's'} · "
              "${CurrencyService.format(totalMonthly * 12)}/year",
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: subs.take(4).map((s) {
                final amt = (s['amount'] as num).toDouble();
                return Chip(
                  label: Text(
                    "${s['title']} ${CurrencyService.format(amt)}",
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.purple.withValues(alpha: 0.08),
                  side: BorderSide(color: Colors.purple.withValues(alpha: 0.2)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context) {
    // Only show when we have enough data and income is set
    if (_monthlyIncome <= 0 || _expenses.isEmpty)
      return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final daysPassed = now.day.clamp(1, daysInMonth);
    if (daysPassed < 3) return const SizedBox.shrink(); // need at least 3 days

    // Calculate this-month spending per category
    final catSpent = <String, double>{};
    for (final e in _expenses) {
      if (e.date.startsWith(currentMonth)) {
        catSpent[e.category] = (catSpent[e.category] ?? 0) + e.amount;
      }
    }
    if (catSpent.isEmpty) return const SizedBox.shrink();

    // Project end-of-month spending per category
    final projections = <String, double>{};
    for (final entry in catSpent.entries) {
      projections[entry.key] = entry.value / daysPassed * daysInMonth;
    }

    // Find categories that will exceed budget
    final warnings = <String>[];
    for (final b in _budgets) {
      final projected = projections[b.category] ?? 0;
      if (projected > b.amount) {
        final over = projected - b.amount;
        warnings
            .add("${b.category}: +${CurrencyService.format(over)} over budget");
      }
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up,
                    color: Colors.deepOrange, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text("Spending Forecast",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.deepOrange)),
                ),
                InfoButton(
                  title: "Spending Forecast",
                  body:
                      "Based on your spending pace so far this month, this predicts which categories will exceed their budget by month-end.\n\n"
                      "Formula: (spent so far ÷ days elapsed) × days in month = projected total",
                  size: 13,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "At your current pace, you may overspend:",
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 6),
            ...warnings.take(3).map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_outlined,
                          size: 13, color: Colors.deepOrange),
                      const SizedBox(width: 5),
                      Text(w,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.deepOrange)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowCard(BuildContext context) {
    if (_monthlyIncome <= 0) return const SizedBox.shrink();
    // Hide if no expenses and no upcoming bills — nothing to show
    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final spentThisMonth = _expenses
        .where((e) => e.date.startsWith(currentMonth))
        .fold<double>(0, (s, e) => s + e.amount);
    final hasUpcomingBills = _allRecurring.any((r) {
      if ((r['is_expense'] as int? ?? 1) != 1) return false;
      try {
        final d = DateTime.parse(r['next_date'] as String? ?? '');
        return d.difference(now).inDays >= 0 && d.difference(now).inDays <= 30;
      } catch (_) {
        return false;
      }
    });
    if (spentThisMonth == 0 && !hasUpcomingBills)
      return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    // Upcoming recurring expense bills in next 30 days
    double upcomingBills = 0;
    final upcomingItems = <Map<String, dynamic>>[];
    for (final r in _allRecurring) {
      final isExpense = (r['is_expense'] as int? ?? 1) == 1;
      if (!isExpense) continue;
      final nextDateStr = r['next_date'] as String? ?? '';
      if (nextDateStr.isEmpty) continue;
      try {
        final nextDate = DateTime.parse(nextDateStr);
        final daysUntil = nextDate.difference(now).inDays;
        if (daysUntil >= 0 && daysUntil <= 30) {
          upcomingBills += (r['amount'] as num).toDouble();
          upcomingItems.add({...r, 'days_until': daysUntil});
        }
      } catch (_) {}
    }

    final projectedBalance = _monthlyIncome - spentThisMonth - upcomingBills;
    final isPositive = projectedBalance >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.waterfall_chart, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                const Text("Cash Flow",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 4),
                InfoButton(
                  title: "Cash Flow Forecast",
                  body:
                      "Shows your projected financial position for this month:\n\n"
                      "Income − Already Spent − Upcoming Bills = Remaining\n\n"
                      "Upcoming Bills are your recurring transactions due in the next 30 days. If Remaining goes negative, a shortfall warning appears.",
                  size: 13,
                ),
                const Spacer(),
                Text("This month",
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.4))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cashFlowItem("Income", _monthlyIncome, Colors.green, cs),
                _cashFlowItem("Spent", spentThisMonth, Colors.red, cs),
                if (upcomingBills > 0)
                  _cashFlowItem("Bills Due", upcomingBills, Colors.orange, cs),
                _cashFlowItem("Remaining", projectedBalance,
                    isPositive ? Colors.green : Colors.red, cs),
              ],
            ),
            if (upcomingItems.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                upcomingItems
                    .take(2)
                    .map((r) =>
                        "${r['title']} in ${r['days_until'] == 0 ? 'today' : '${r['days_until']}d'}")
                    .join(' · '),
                style: TextStyle(
                    fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
              ),
            ],
            if (!isPositive) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  const Text("Projected shortfall — review upcoming bills",
                      style: TextStyle(fontSize: 11, color: Colors.red)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cashFlowItem(
      String label, double amount, Color color, ColorScheme cs) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10, color: cs.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 2),
        Text(CurrencyService.format(amount),
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  // Budget warnings pre-computed in _loadData as _overBudgetCategories

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? "Good Morning"
        : hour < 18
            ? "Good Afternoon"
            : "Good Evening";
    final change = _lastMonthTotal > 0
        ? ((_totalSpent - _lastMonthTotal) / _lastMonthTotal * 100)
        : 0.0;
    final overBudget = _overBudgetCategories;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$greeting 👋",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
                  // Quick log button — most common action
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Log Expense",
                        style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Navigate to AI tab — user can type/speak expense
                      widget.onNavigate(2);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("This Month's Spending",
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(CurrencyService.format(_totalSpent),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (_lastMonthTotal > 0)
                      Row(
                        children: [
                          Icon(
                            change > 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: change > 0
                                ? Colors.redAccent[100]
                                : Colors.greenAccent[100],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${change.abs().toStringAsFixed(1)}% vs last month",
                            style: TextStyle(
                              color: change > 0
                                  ? Colors.redAccent[100]
                                  : Colors.greenAccent[100],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    if (_monthlyIncome > 0 && _incomeWalletMode) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Spent ${(_totalSpent / _monthlyIncome * 100).clamp(0, 100).toStringAsFixed(0)}% of income",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (_totalSpent / _monthlyIncome)
                                        .clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: Colors.white24,
                                    valueColor: AlwaysStoppedAnimation(
                                      _totalSpent > _monthlyIncome
                                          ? Colors.redAccent[100]!
                                          : Colors.greenAccent[100]!,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Today's Spending quick card
              Builder(builder: (context) {
                final today = DateTime.now().toIso8601String().substring(0, 10);
                final todaySpent = _expenses
                    .where((e) => e.date == today)
                    .fold<double>(0, (s, e) => s + e.amount);
                final todayCount =
                    _expenses.where((e) => e.date == today).length;
                if (todaySpent == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.today,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Today: ${CurrencyService.format(todaySpent)}  ($todayCount transaction${todayCount == 1 ? '' : 's'})",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Budget warnings — supportive framing (BF-5)
              // Each over-budget category gets its own encouraging message
              // linked to the user's top savings goal when available.
              if (overBudget.isNotEmpty)
                ...overBudget.take(2).map((cat) {
                  final budget =
                      _budgets.where((b) => b.category == cat).firstOrNull;
                  final spent = _expenses
                      .where((e) =>
                          e.date.startsWith(_currentMonth) && e.category == cat)
                      .fold<double>(0, (s, e) => s + e.amount);
                  final budgetAmt = budget?.amount ?? 0;
                  final isOver = budgetAmt > 0 && spent > budgetAmt;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FutureBuilder<String>(
                      future:
                          BehavioralFeedbackService.getSupportiveBudgetMessage(
                              cat, spent, budgetAmt > 0 ? budgetAmt : spent),
                      builder: (ctx, snap) {
                        final msg = snap.data ??
                            (isOver
                                ? '⚠️ $cat budget exceeded'
                                : '📊 $cat approaching limit');
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isOver
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isOver
                                    ? Colors.orange.withValues(alpha: 0.35)
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            msg,
                            style: TextStyle(
                                fontSize: 12,
                                color: isOver
                                    ? Colors.orange[800]
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.75),
                                height: 1.35),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),

              if (overBudget.isNotEmpty) const SizedBox(height: 12),

              // Overdue recurring banner
              if (_overdueRecurring.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.repeat,
                            color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Recurring due: ${_overdueRecurring.map((r) => r['title']).join(', ')}",
                            style: const TextStyle(
                                color: Colors.orange, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RecurringScreen()))
                              .then((_) => _loadData()),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0)),
                          child: const Text("View",
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),

              // Upcoming debt due banner (within 7 days or overdue)
              if (_upcomingDebts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.handshake_outlined,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Payment due: ${_upcomingDebts.map((d) => '${d['title']} (${d['person']})').join(', ')}",
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // BC-2: Bill Calendar mini-card — next 3 upcoming financial events
              _BillCalendarMiniCard(
                  recurring: _allRecurring, debts: _upcomingDebts),

              // Recurring auto-log prompt card
              if (_overdueRecurring.isNotEmpty)
                _buildRecurringAutoLogCard(context),

              // NI-7: Recurring income due — special card
              Builder(builder: (ctx) {
                final incomeRecurring = _allRecurring.where((r) {
                  if ((r['is_expense'] as int? ?? 1) != 0) return false;
                  try {
                    final d = DateTime.parse(r['next_date'] as String);
                    return !d.isAfter(DateTime.now());
                  } catch (_) {
                    return false;
                  }
                }).toList();
                if (incomeRecurring.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.arrow_downward,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            const Text("Income due — log it now?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: incomeRecurring.take(3).map((r) {
                            final amt = (r['amount'] as num).toDouble();
                            return ActionChip(
                              avatar: const Icon(Icons.add_circle_outline,
                                  size: 14, color: Colors.green),
                              label: Text(
                                  "${r['title']} ${CurrencyService.format(amt)}",
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor:
                                  Colors.green.withValues(alpha: 0.1),
                              side: BorderSide(
                                  color: Colors.green.withValues(alpha: 0.3)),
                              onPressed: () async {
                                await DBService.insertIncome({
                                  'title': r['title'],
                                  'amount': amt,
                                  'category': r['category'] ?? 'Salary',
                                  'date': DateTime.now()
                                      .toIso8601String()
                                      .substring(0, 10),
                                  'is_recurring': 1,
                                });
                                // Advance next_date
                                try {
                                  final current =
                                      DateTime.parse(r['next_date'] as String);
                                  final freq =
                                      r['frequency'] as String? ?? 'monthly';
                                  DateTime next;
                                  if (freq == 'weekly')
                                    next = current.add(const Duration(days: 7));
                                  else if (freq == 'daily')
                                    next = current.add(const Duration(days: 1));
                                  else {
                                    final nm = current.month == 12
                                        ? 1
                                        : current.month + 1;
                                    final ny = current.month == 12
                                        ? current.year + 1
                                        : current.year;
                                    final lastDay = DateTime(ny, nm + 1, 0).day;
                                    next = DateTime(
                                        ny, nm, current.day.clamp(1, lastDay));
                                  }
                                  await DBService.updateRecurring({
                                    ...r,
                                    'next_date':
                                        next.toIso8601String().substring(0, 10)
                                  });
                                } catch (_) {}
                                _loadData();
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Wallet balances summary — only shown in income/wallet mode
              if (_incomeWalletMode) _buildWalletSummaryCard(context),

              // Quick "Log Allowance" button — only in income/wallet mode
              if (_incomeWalletMode) _buildLogAllowanceButton(context),

              // Multi-period spending limits card — tappable, shown when any limit set
              _buildSpendingLimitCard(context),

              // Legacy daily limit bar — only shown when NEW system has NO limits at all
              // (prevents both cards showing when user has legacy daily + new non-daily limits)
              if (_dailyLimit > 0 && _allLimits.values.every((v) => v == 0))
                _buildDailyLimitCard(context),

              // Subscription leak summary
              if (_showSubscriptions) _buildSubscriptionSummaryCard(context),

              // Subscription auto-detection prompt — only show if subscription summary is hidden
              // (avoids showing two subscription-related cards simultaneously)
              if (!_showSubscriptions && _recurringCandidates.isNotEmpty)
                _RecurringCandidateCard(
                  candidates: _recurringCandidates,
                  onDismissed: () => setState(() {}),
                ),

              // Quick-log chips (most frequent expenses)
              if (_showQuickLog && _quickLogItems.isNotEmpty)
                _buildQuickLogChips(context),

              // Spending streaks & badges (#13)
              if (_showBadges && _earnedBadges.isNotEmpty)
                _buildBadgesRow(context),

              // Daily mood check-in
              if (_showMoodHome) _MoodCheckInWidget(),

              // NI-6: "Done spending today" toggle
              _DoneSpendingToggle(),

              // WN-1: Untagged expenses prompt
              Builder(builder: (ctx) {
                final untagged = _expenses
                    .where((e) =>
                        e.isWant == null && e.date.startsWith(_currentMonth))
                    .length;
                if (untagged < 5) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.label_outline,
                            color: Colors.purple, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "$untagged expenses this month aren't tagged as Need or Want yet.",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.purple),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                  builder: (_) => const TransactionsScreen())),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.purple,
                              padding: EdgeInsets.zero),
                          child: const Text("Tag now",
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // GM-1: Daily Challenges card
              _DailyChallengesWidget(
                expenses: _expenses,
                budgets: _budgets,
                score: _score,
                monthlyIncome: _monthlyIncome,
              ),

              // GM-7: Weekly Challenge card
              _WeeklyChallengeWidget(
                expenses: _expenses,
                budgets: _budgets,
                monthlyIncome: _monthlyIncome,
              ),

              // UX-4: Emergency fund prompt for users without one
              FutureBuilder<List<Map<String, dynamic>>>(
                future: DBService.getGoals(),
                builder: (context, snap) {
                  final goals = snap.data ?? [];
                  final hasEmergencyFund = goals.any((g) =>
                      (g['name'] as String)
                          .toLowerCase()
                          .contains('emergency'));
                  if (hasEmergencyFund ||
                      goals.isEmpty &&
                          snap.connectionState != ConnectionState.done) {
                    return const SizedBox.shrink();
                  }
                  if (hasEmergencyFund) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.teal.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              color: Colors.teal, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("No emergency fund yet",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.teal)),
                                Text(
                                    "A 3-month safety net protects you from unexpected expenses.",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SavingsGoalsScreen())),
                            child: const Text("Start one"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_lastMonthTotal > 0 && _totalSpent > 0)
                Builder(builder: (ctx) {
                  final diff = _totalSpent - _lastMonthTotal;
                  final pct =
                      (diff / _lastMonthTotal * 100).abs().toStringAsFixed(0);
                  final isLess = diff < 0;
                  // Find top changed category
                  final currentMonth =
                      DateFormat('yyyy-MM').format(DateTime.now());
                  final catTotals = <String, double>{};
                  for (final e in _expenses) {
                    if (e.date.startsWith(currentMonth)) {
                      catTotals[e.category] =
                          (catTotals[e.category] ?? 0) + e.amount;
                    }
                  }
                  final topCat = catTotals.entries.isEmpty
                      ? null
                      : (catTotals.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .first
                          .key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: (isLess ? Colors.green : Colors.orange)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: (isLess ? Colors.green : Colors.orange)
                                .withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(isLess ? Icons.trending_down : Icons.trending_up,
                              size: 16,
                              color: isLess ? Colors.green : Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isLess
                                  ? "You're spending $pct% less than last month 👍${topCat != null ? ' — mostly on $topCat' : ''}"
                                  : "You're spending $pct% more than last month${topCat != null ? ' — mostly on $topCat' : ''}",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isLess
                                      ? Colors.green[700]
                                      : Colors.orange[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              // Cash Flow Forecast card
              if (_showForecast) _buildCashFlowCard(context),

              // Behavioral Prediction card
              if (_showPrediction) _buildPredictionCard(context),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Compute breakdown inline from already-loaded data
                        final currentMonth =
                            DateFormat('yyyy-MM').format(DateTime.now());
                        final thisMonthData = _expenses
                            .where((e) => e.date.startsWith(currentMonth))
                            .map((e) => {
                                  'amount': e.amount,
                                  'category': e.category,
                                  'date': e.date
                                })
                            .toList();
                        final breakdown = ScoreService.getBreakdown(
                          thisMonthData,
                          budgets: _budgets,
                          monthlyIncome: _incomeWalletMode ? _monthlyIncome : 0,
                          lightweightMode: !_incomeWalletMode,
                          spendingLimit: _spendingLimit,
                          spendingLimitPeriod: _spendingLimitPeriod,
                          spentInPeriod: _spentInPeriod,
                        );
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                        "Financial Health: $_score / 100")),
                                Text(
                                  _score >= 80
                                      ? "🏆"
                                      : _score >= 60
                                          ? "⭐"
                                          : "📉",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Score classification label
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (_score >= 80
                                              ? Colors.green
                                              : _score >= 60
                                                  ? Colors.orange
                                                  : Colors.red)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _score >= 90
                                          ? "👑 Excellent — Elite financial habits"
                                          : _score >= 80
                                              ? "🏆 Great — Strong financial control"
                                              : _score >= 70
                                                  ? "⭐ Good — On the right track"
                                                  : _score >= 60
                                                      ? "🌱 Fair — Building momentum"
                                                      : "📉 Needs Work — Focus on core habits",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _score >= 80
                                            ? Colors.green[700]
                                            : _score >= 60
                                                ? Colors.orange[700]
                                                : Colors.red[700],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  // Top strength & weakness
                                  Builder(builder: (_) {
                                    if (breakdown.isEmpty)
                                      return const SizedBox.shrink();
                                    final sorted = [...breakdown]..sort(
                                        (a, b) => (b['points'] as int)
                                            .compareTo(a['points'] as int));
                                    final strongest = sorted.first;
                                    final weakest = sorted.last;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          const Text("✅ ",
                                              style: TextStyle(fontSize: 13)),
                                          Expanded(
                                              child: Text(
                                                  "Strength: ${strongest['reason']}",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green))),
                                        ]),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          const Text("⚠️ ",
                                              style: TextStyle(fontSize: 13)),
                                          Expanded(
                                              child: Text(
                                                  "Focus area: ${weakest['reason']}",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.orange))),
                                        ]),
                                        const Divider(height: 20),
                                      ],
                                    );
                                  }),
                                  // Component breakdown with labels and recommendations
                                  const Text("Score Breakdown",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  ...breakdown.map((item) {
                                    final pts = item['points'] as int;
                                    const maxPts = 25;
                                    final pctFill =
                                        (pts / maxPts).clamp(0.0, 1.0);
                                    final barColor = pts >= 20
                                        ? Colors.green
                                        : pts >= 12
                                            ? Colors.orange
                                            : Colors.red;
                                    final String componentLabel = pts >= 20
                                        ? "Good"
                                        : pts >= 12
                                            ? "Fair"
                                            : "Needs Work";
                                    // Per-component recommendations
                                    final String rec = _componentRec(
                                        item['component'] as String? ?? '',
                                        pts,
                                        _incomeWalletMode);
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Expanded(
                                                child: Text(
                                                    item['reason'] as String,
                                                    style: const TextStyle(
                                                        fontSize: 12))),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: barColor.withValues(
                                                      alpha: 0.13),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Text(componentLabel,
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: barColor)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text("$pts/$maxPts",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: barColor)),
                                          ]),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: LinearProgressIndicator(
                                                value: pctFill,
                                                minHeight: 5,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        barColor)),
                                          ),
                                          if (rec.isNotEmpty && pts < 20) ...[
                                            const SizedBox(height: 4),
                                            Text("💡 $rec",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                    fontStyle:
                                                        FontStyle.italic)),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Got it")),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onNavigate(3);
                                },
                                child: const Text("Full Details →"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Financial Health Score",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer
                                            .withValues(alpha: 0.7))),
                                const SizedBox(width: 2),
                                InfoButton(
                                  title: "Financial Health Score",
                                  body:
                                      "A score from 0–100 based on 4 equal components (25 pts each):\n\n"
                                      "1️⃣ Savings Rate — saving ≥20% of income?\n"
                                      "2️⃣ Overspend Control — days within daily budget?\n"
                                      "3️⃣ Budget Adherence — % of budgets on track?\n"
                                      "4️⃣ Logging Consistency — logging regularly?\n\n"
                                      "🟢 80–100 = Good  🟡 60–79 = Fair  🔴 <60 = Needs Attention\n\n"
                                      "Tap this card to see the breakdown with progress bars for each component.",
                                  size: 13,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("$_score / 100",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer)),
                            Row(
                              children: [
                                Text(_scoreLabel(_score),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer)),
                                const SizedBox(width: 6),
                                // Score trend vs last week
                                FutureBuilder<int>(
                                  future: ScoreTrend.getScoreTrend(),
                                  builder: (_, snap) {
                                    final diff = snap.data ?? 0;
                                    if (diff == 0)
                                      return const SizedBox.shrink();
                                    final up = diff > 0;
                                    return Text(
                                      '${up ? '↑' : '↓'}${diff.abs()} this month',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              up ? Colors.green : Colors.red),
                                    );
                                  },
                                ),
                              ],
                            ),
                            // BT-2: Show decay indicator when active
                            FutureBuilder<int>(
                              future: ScoreService.getDecayDays(),
                              builder: (_, snap) {
                                final days = snap.data ?? 0;
                                if (days <= 0) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "⚠️ −${days * 5}pts: budget exceeded $days day${days == 1 ? '' : 's'}",
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            // BF-2: Plain-language score narrative
                            if (_scoreNarrative.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _scoreNarrative,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer
                                        .withValues(alpha: 0.75),
                                    height: 1.35,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            // "Explain My Score" shortcut — navigates to AI tab
                            GestureDetector(
                              onTap: () => widget.onNavigate(2),
                              child: Text(
                                "💬 Ask AI to explain my score",
                                style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const BudgetScreen()))
                          .then((_) => _loadData()),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Budgets",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.7))),
                            const SizedBox(height: 4),
                            Text("${_budgets.length} set",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer)),
                            Text("Tap to manage",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── FMS STRIP — Financial Management Score ────────────────────
              // Compact strip below FHS+Budget row so both scores are visible
              // on the home screen. Tapping navigates to Profile for full
              // breakdown. Research: Khazneh (2026) / AccountaPal — management
              // behavior score should be co-located with health outcome score.
              FutureBuilder<Map<String, dynamic>>(
                future: () async {
                  final goals = await DBService.getGoals();
                  final budgets = await DBService.getBudgets();
                  final expMaps = _expenses
                      .where((e) => e.date.startsWith(_currentMonth))
                      .map((e) => {
                            'item_name': e.itemName,
                            'amount': e.amount,
                            'date': e.date,
                            'category': e.category,
                          })
                      .toList();
                  return FinancialManagement.getFinancialManagementScore(
                    thisMonthExpenses: expMaps,
                    budgets: budgets,
                    goals: goals,
                    monthlyIncome: _monthlyIncome,
                    incomeWalletMode: _incomeWalletMode,
                    wallets: _wallets,
                  );
                }(),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final fms = snap.data!;
                  final fmsScore = fms['score'] as int;
                  final fmsLabel = fms['label'] as String;
                  final fmsColor = fmsScore >= 85
                      ? Colors.purple
                      : fmsScore >= 70
                          ? Colors.blue
                          : fmsScore >= 50
                              ? Colors.teal
                              : Colors.grey;
                  return GestureDetector(
                    onTap: () {
                      // Signal ProfileScreen to scroll to FMS section
                      ProfileScreen.scrollToFMS = true;
                      widget.onNavigate(4); // 4 = Profile tab
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: fmsColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: fmsColor.withValues(alpha: 0.18)),
                      ),
                      child: Row(children: [
                        Icon(Icons.manage_accounts_outlined,
                            size: 15, color: fmsColor.withValues(alpha: 0.7)),
                        const SizedBox(width: 6),
                        Text('Management Score',
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(ctx)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6))),
                        const SizedBox(width: 8),
                        Text('$fmsScore / 100',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: fmsColor)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: fmsColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(fmsLabel,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: fmsColor)),
                        ),
                        const Spacer(),
                        Text('See breakdown →',
                            style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(ctx).colorScheme.primary,
                                decoration: TextDecoration.underline)),
                      ]),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Spending Personality card
              Builder(builder: (ctx) {
                final expenseData = _expenses
                    .where((e) => e.date.startsWith(_currentMonth))
                    .map((e) => {
                          'category': e.category,
                          'amount': e.amount,
                          'is_want': e.isWant == true ? 1 : 0,
                        })
                    .toList();
                final personality = ScoreService.getSpendingPersonality(
                  expenses: expenseData,
                  monthlyIncome: _monthlyIncome,
                  totalSpent: _totalSpent,
                );
                final cs = Theme.of(ctx).colorScheme;
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${personality.$2}\n${personality.$3}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Text(personality.$1,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(personality.$2,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text(personality.$3,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            cs.onSurface.withValues(alpha: 0.7),
                                        height: 1.3)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.info_outline,
                              size: 18,
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Weekly Category Summary — "how much on each vs usual this week"
              _WeeklyCategoryCard(expenses: _expenses),

              const SizedBox(height: 12),

              // AI Insights
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16),
                        SizedBox(width: 6),
                        Text("AI Insights",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        InfoButton(
                          title: "AI Insights",
                          body:
                              "The AI analyzes your spending patterns and generates a brief summary of your financial behavior this month.\n\n"
                              "It only refreshes when your expense count changes — so it won't use up your daily AI limit unnecessarily.",
                          size: 13,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _loadingInsight
                        ? const Row(children: [
                            SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text("Analyzing...",
                                style: TextStyle(color: Colors.grey)),
                          ])
                        : MarkdownBody(
                            data: _insight,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(height: 1.5),
                              strong:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              listBullet: const TextStyle(height: 1.5),
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // NI-1: "Where did my money go?" focused AI card
              if (_expenses.isNotEmpty && _monthlyIncome > 0)
                _WhereDidMoneyGoCard(
                  expenses: _expenses,
                  monthlyIncome: _monthlyIncome,
                  currentMonth: _currentMonth,
                ),

              // Quick Actions removed — use the + FAB button instead

              const SizedBox(height: 20),

              // ── FEATURE PORTALS ──────────────────────────────────────────
              // Quick-access cards for the most useful features
              _buildFeaturePortals(context),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("Recent Transactions",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      InfoButton(
                        title: "Recent Transactions",
                        body: "Shows your 10 most recent expenses.\n\n"
                            "• Tap any transaction to edit it\n"
                            "• Swipe or use the ⋮ menu to delete\n"
                            "• Tap 'See All' to view, search, and filter your full history\n"
                            "• Long-press to select multiple transactions",
                        size: 13,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TransactionsScreen()))
                        .then((_) => _loadData()),
                    child: const Text("See All"),
                  ),
                ],
              ),

              _expenses.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text("No expenses recorded yet",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            const Text(
                                "Tap the AI button below to log your first expense\nby typing, speaking, or scanning a receipt",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.smart_toy, size: 16),
                              label: const Text("Open AI Assistant"),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () => widget.onNavigate(2),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _expenses.length > 10 ? 10 : _expenses.length,
                      itemBuilder: (_, i) => ExpenseTile(
                        expense: _expenses[i],
                        onEdit: () => _editExpense(_expenses[i]),
                        onDelete: () => _deleteExpense(_expenses[i].id!),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── MOOD CHECK-IN WIDGET ──────────────────────────────────────────────────────
/// Daily mood check-in — one tap, 1–5 scale.
/// Stored in mood_log table. Used for mood-spend correlation in analytics.
class _MoodCheckInWidget extends StatefulWidget {
  @override
  State<_MoodCheckInWidget> createState() => _MoodCheckInWidgetState();
}

class _MoodCheckInWidgetState extends State<_MoodCheckInWidget> {
  int? _todayMood;
  bool _loading = true;
  bool _enabled = true;

  static const _emojis = ['😞', '😕', '😐', '🙂', '😄'];
  static const _labels = ['Rough', 'Low', 'Okay', 'Good', 'Great'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled =
        (await DBService.getSetting('mood_checkin_enabled')) != 'false';
    final entry = await DBService.getTodayMood();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _todayMood = entry != null ? entry['mood_score'] as int : null;
        _loading = false;
      });
    }
  }

  Future<void> _setMood(int score) async {
    // UD-7: Optional note field when logging mood
    String? note;
    if (mounted) {
      final noteCtrl = TextEditingController();
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title:
              Text("${['😞', '😕', '😐', '🙂', '😄'][score - 1]} Mood logged"),
          content: TextField(
            controller: noteCtrl,
            autofocus: false,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: "What's going on? (optional)",
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Skip"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Save"),
            ),
          ],
        ),
      );
      note = noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim();
    }
    await DBService.saveMood(score, note: note);
    if (mounted) setState(() => _todayMood = score);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_enabled) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("How are you feeling today?",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const InfoButton(
                  title: "Daily Mood Check-In",
                  body:
                      "Tap an emoji to log your mood for today. One entry per day.\n\n"
                      "After 5+ days of logging, the Analytics screen shows a Mood & Spending correlation — revealing whether you spend more on stressed or low-mood days.\n\n"
                      "Your mood data is private and stored locally only.",
                  size: 13,
                ),
                const Spacer(),
                if (_todayMood != null)
                  Text(
                    "${_emojis[_todayMood! - 1]} ${_labels[_todayMood! - 1]}",
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final score = i + 1;
                final selected = _todayMood == score;
                return GestureDetector(
                  onTap: () => _setMood(score),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? cs.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      border: selected
                          ? Border.all(color: cs.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _emojis[i],
                        style: TextStyle(fontSize: selected ? 22 : 18),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (_todayMood != null) ...[
              const SizedBox(height: 6),
              Text(
                "Mood logged ✓ — we'll correlate this with your spending patterns over time.",
                style: TextStyle(
                    fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── BILL CALENDAR MINI-CARD ───────────────────────────────────────────────────
/// BC-2: Shows next 3 upcoming financial events on the home screen.
/// Tapping navigates to the full Bill Calendar.
class _BillCalendarMiniCard extends StatelessWidget {
  final List<Map<String, dynamic>> recurring;
  final List<Map<String, dynamic>> debts;

  const _BillCalendarMiniCard({
    required this.recurring,
    required this.debts,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cs = Theme.of(context).colorScheme;

    // Collect upcoming events (next 14 days)
    final events = <Map<String, dynamic>>[];

    for (final r in recurring) {
      try {
        final d = DateTime.parse(r['next_date'] as String);
        final diff = d.difference(now).inDays;
        if (diff >= 0 && diff <= 14) {
          events.add({
            'title': r['title'],
            'date': r['next_date'],
            'diff': diff,
            'type': (r['is_expense'] as int? ?? 1) == 1 ? 'bill' : 'income',
            'amount': (r['amount'] as num).toDouble(),
          });
        }
      } catch (_) {}
    }

    for (final d in debts) {
      final due = d['due_date'] as String?;
      if (due == null) continue;
      try {
        final dDate = DateTime.parse(due);
        final diff = dDate.difference(now).inDays;
        if (diff >= 0 && diff <= 14) {
          final remaining = (d['amount'] as num) - (d['paid_amount'] as num);
          if (remaining > 0) {
            events.add({
              'title': '${d['title']} (${d['person']})',
              'date': due,
              'diff': diff,
              'type': 'debt',
              'amount': remaining.toDouble(),
            });
          }
        }
      } catch (_) {}
    }

    if (events.isEmpty) return const SizedBox.shrink();

    events.sort((a, b) => (a['diff'] as int).compareTo(b['diff'] as int));
    final top3 = events.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BillCalendarScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 15),
                  const SizedBox(width: 6),
                  const Text("Upcoming",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const Spacer(),
                  Text("View calendar →",
                      style: TextStyle(fontSize: 11, color: cs.primary)),
                ],
              ),
              const SizedBox(height: 8),
              ...top3.map((e) {
                final diff = e['diff'] as int;
                final label = diff == 0
                    ? "Today"
                    : diff == 1
                        ? "Tomorrow"
                        : "In $diff days";
                final typeColor = e['type'] == 'income'
                    ? Colors.green
                    : e['type'] == 'debt'
                        ? Colors.red
                        : Colors.orange;
                final typeIcon = e['type'] == 'income'
                    ? Icons.arrow_downward
                    : e['type'] == 'debt'
                        ? Icons.handshake_outlined
                        : Icons.repeat;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Icon(typeIcon, size: 13, color: typeColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(e['title'] as String,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        "${CurrencyService.format(e['amount'] as double)}  ·  $label",
                        style: TextStyle(
                            fontSize: 11,
                            color: diff == 0
                                ? typeColor
                                : cs.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ── DAILY CHALLENGES WIDGET (GM-1) ───────────────────────────────────────────
// ── WEEKLY CATEGORY SUMMARY ─────────────────────────────────────────────────
/// Shows each category's spending THIS week vs the 4-week average.
/// Labels each as High / Normal / Low with color coding.
/// Gives users actionable insight: "you're spending more on Food than usual this week."
class _WeeklyCategoryCard extends StatelessWidget {
  final List<dynamic> expenses;

  const _WeeklyCategoryCard({required this.expenses});

  static const _catIcons = <String, IconData>{
    'Food': Icons.restaurant_outlined,
    'Transportation': Icons.directions_bus_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Entertainment': Icons.sports_esports_outlined,
    'Bills': Icons.receipt_long_outlined,
    'Health': Icons.favorite_border,
    'Education': Icons.school_outlined,
    'Gaming': Icons.videogame_asset_outlined,
    'Personal Care': Icons.spa_outlined,
    'Clothing': Icons.checkroom_outlined,
    'Gifts': Icons.card_giftcard_outlined,
    'Travel': Icons.flight_outlined,
    'Pets': Icons.pets_outlined,
    'Others': Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    // This week: Mon–Sun of current week
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr = weekStart.toIso8601String().substring(0, 10);
    final todayStr = now.toIso8601String().substring(0, 10);

    // This week's expenses
    final thisWeek = <String, double>{};
    for (final e in expenses) {
      final date = (e.date as String).substring(0, 10);
      if (date.compareTo(weekStartStr) >= 0 && date.compareTo(todayStr) <= 0) {
        thisWeek[e.category] = (thisWeek[e.category] ?? 0) + e.amount;
      }
    }

    if (thisWeek.isEmpty) return const SizedBox.shrink();

    // Past 4 complete weeks average per category
    final weeklyAvg = <String, double>{};
    for (int w = 1; w <= 4; w++) {
      final wStart = weekStart.subtract(Duration(days: 7 * w));
      final wEnd = wStart.add(const Duration(days: 6));
      final wStartStr = wStart.toIso8601String().substring(0, 10);
      final wEndStr = wEnd.toIso8601String().substring(0, 10);
      for (final e in expenses) {
        final date = (e.date as String).substring(0, 10);
        if (date.compareTo(wStartStr) >= 0 && date.compareTo(wEndStr) <= 0) {
          weeklyAvg[e.category] = (weeklyAvg[e.category] ?? 0) + e.amount / 4;
        }
      }
    }

    // Only show categories that appear this week
    final cats = thisWeek.keys.toList()
      ..sort((a, b) => thisWeek[b]!.compareTo(thisWeek[a]!));

    if (cats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_outlined,
                    size: 15, color: cs.onSurface.withValues(alpha: 0.55)),
                const SizedBox(width: 6),
                Text("This Week by Category",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.55))),
                const SizedBox(width: 4),
                InfoButton(
                  title: "Weekly Category Summary",
                  body:
                      "Shows how much you spent in each category THIS week compared to your usual weekly average.\n\n"
                      "🔴 HIGH — more than 130% of your usual\n"
                      "🟡 NORMAL — 70–130% of your usual\n"
                      "🟢 LOW — less than 70% of your usual\n\n"
                      "Use this to spot categories where you're overspending before the month ends.",
                  size: 13,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...cats.take(5).map((cat) {
              final thisAmt = thisWeek[cat] ?? 0;
              final avgAmt = weeklyAvg[cat] ?? 0;
              final ratio = avgAmt > 0 ? thisAmt / avgAmt : -1.0;

              // Determine label, color, description
              final String label;
              final Color labelColor;
              final String tip;

              if (ratio < 0 || avgAmt < 10) {
                // No history — just show amount, no label
                label = 'New';
                labelColor = cs.onSurface.withValues(alpha: 0.4);
                tip = 'No past data yet';
              } else if (ratio > 1.30) {
                label = '↑ High';
                labelColor = Colors.red;
                tip =
                    '${(ratio * 100 - 100).toStringAsFixed(0)}% above your usual';
              } else if (ratio < 0.70) {
                label = '↓ Low';
                labelColor = Colors.green;
                tip =
                    '${(100 - ratio * 100).toStringAsFixed(0)}% below your usual';
              } else {
                label = '→ Normal';
                labelColor = Colors.orange.shade700;
                tip = 'Typical week for $cat';
              }

              final icon = _catIcons[cat] ?? Icons.category_outlined;

              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Icon(icon,
                        size: 15, color: cs.onSurface.withValues(alpha: 0.55)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(cat,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.8))),
                    ),
                    Text(CurrencyService.format(thisAmt),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: labelColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Tooltip(
                        message: tip,
                        child: Text(label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: labelColor)),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (cats.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('+${cats.length - 5} more categories this week',
                    style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.4))),
              ),
          ],
        ),
      ),
    );
  }
}

// ── DAILY CHALLENGES WIDGET ──────────────────────────────────────────────────
class _DailyChallengesWidget extends StatefulWidget {
  final List<Expense> expenses;
  final List<Budget> budgets;
  final int score;
  final double monthlyIncome;

  const _DailyChallengesWidget({
    required this.expenses,
    required this.budgets,
    required this.score,
    required this.monthlyIncome,
  });

  @override
  State<_DailyChallengesWidget> createState() => _DailyChallengesWidgetState();
}

class _DailyChallengesWidgetState extends State<_DailyChallengesWidget> {
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _computeStreak();
  }

  Future<void> _computeStreak() async {
    // Count consecutive days with at least 1 expense logged
    final now = DateTime.now();
    int streak = 0;
    for (int d = 1; d <= 60; d++) {
      final checkDate = DateTime(now.year, now.month, now.day - d)
          .toIso8601String()
          .substring(0, 10);
      if (widget.expenses.any((e) => e.date == checkDate)) {
        streak++;
      } else {
        break;
      }
    }
    if (mounted) setState(() => _streak = streak);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dayOfWeek = DateTime.now().weekday; // 1=Mon, 7=Sun

    // ── BUILD CHALLENGE POOL (varies by day) ──────────────────
    final hasLoggedToday = widget.expenses.any((e) => e.date == today);
    final todayExpenses =
        widget.expenses.where((e) => e.date == today).toList();
    final todaySpent = todayExpenses.fold(0.0, (s, e) => s + e.amount);
    final dailyBudget =
        widget.monthlyIncome > 0 ? widget.monthlyIncome / 30 : 0.0;
    final underBudgetToday = dailyBudget > 0 && todaySpent <= dailyBudget;
    final hasNeedToday = todayExpenses.any((e) => e.isWant != true);
    final hasWantToday = todayExpenses.any((e) => e.isWant == true);
    final loggedMultiple = todayExpenses.length >= 3;

    // All possible challenges — 4 shown per day based on day-of-week rotation
    final allChallenges = <Map<String, dynamic>>[
      {
        'title': 'Log an expense today',
        'done': hasLoggedToday,
        'icon': Icons.receipt_outlined,
        'color': Colors.blue
      },
      {
        'title': dailyBudget > 0
            ? 'Stay under ${CurrencyService.format(dailyBudget)} today'
            : 'Set income to unlock',
        'done': underBudgetToday && dailyBudget > 0,
        'icon': Icons.savings_outlined,
        'color': Colors.green
      },
      {
        'title': 'Log a Need expense',
        'done': hasNeedToday,
        'icon': Icons.check_circle_outline,
        'color': Colors.teal
      },
      {
        'title': 'Log 3+ expenses today',
        'done': loggedMultiple,
        'icon': Icons.format_list_numbered,
        'color': Colors.indigo
      },
      {
        'title': 'Avoid Want spending today',
        'done': hasLoggedToday && !hasWantToday,
        'icon': Icons.shield_outlined,
        'color': Colors.orange
      },
      {
        'title': 'Check your Health Score',
        'done': widget.score > 0,
        'icon': Icons.monitor_heart_outlined,
        'color': Colors.purple
      },
      {
        'title': 'Update your wallet balance',
        'done': false, // can't easily check this without DB call
        'icon': Icons.account_balance_wallet,
        'color': Colors.green
      },
      {
        'title': 'Spend only on Needs today',
        'done': hasLoggedToday && hasNeedToday && !hasWantToday,
        'icon': Icons.verified_outlined,
        'color': Colors.teal
      },
      {
        'title': 'Keep total under ₱200 today',
        'done': hasLoggedToday && todaySpent <= 200,
        'icon': Icons.money_off,
        'color': Colors.amber
      },
      {
        'title': 'Log before noon',
        'done': todayExpenses.any((e) {
          try {
            final h = int.parse(e.time?.substring(0, 2) ?? '99');
            return h < 12;
          } catch (_) {
            return false;
          }
        }),
        'icon': Icons.wb_sunny_outlined,
        'color': Colors.orange
      },
    ];

    // Pick 4 challenges based on day rotation (deterministic per day)
    final seed = dayOfWeek + DateTime.now().day;
    final indices = <int>[];
    for (int i = 0; i < allChallenges.length && indices.length < 4; i++) {
      indices.add((seed + i) % allChallenges.length);
    }
    final challenges = indices.map((i) => allChallenges[i]).toList();

    final doneCount = challenges.where((c) => c['done'] == true).length;
    final allDone = doneCount == challenges.length;
    final progress = challenges.isEmpty ? 0.0 : doneCount / challenges.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: allDone
              ? Colors.green.withValues(alpha: 0.08)
              : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: allDone
                ? Colors.green.withValues(alpha: 0.3)
                : cs.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Daily Quests",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 4),
                // BF-9: Contextual explanation for Daily Quests
                const InfoButton(
                  title: 'Daily Quests',
                  body:
                      'Daily Quests are small financial challenges that reset each day. '
                      'Completing them builds good money habits over time.\n\n'
                      'The counter shows how many you\'ve completed today (e.g. 2 / 4).\n\n'
                      'Examples: "Log before noon", "Keep total under ₱200 today", '
                      '"Spend only on Needs today". Quests rotate based on your spending patterns.',
                  size: 13,
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: allDone
                        ? Colors.green.withValues(alpha: 0.15)
                        : cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$doneCount / ${challenges.length}",
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: allDone ? Colors.green : cs.primary),
                  ),
                ),
                const Spacer(),
                if (_streak > 0)
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('🔥 Score Streak'),
                        content: Text(
                          'Your score streak is the number of consecutive days your '
                          'Financial Health Score was 60 or above (Fair or better).\n\n'
                          'Current streak: $_streak day${_streak == 1 ? '' : 's'}.\n\n'
                          'A streak breaks the moment your score drops below 60. '
                          'Keep logging and staying on budget to maintain it.',
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Got it'))
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "🔥 $_streak day streak",
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: cs.outline.withValues(alpha: 0.1),
                valueColor:
                    AlwaysStoppedAnimation(allDone ? Colors.green : cs.primary),
              ),
            ),
            const SizedBox(height: 10),
            if (allDone)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "🎉 All quests complete! Great job today.",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
            else
              ...challenges.map((c) {
                final done = c['done'] as bool;
                final color = c['color'] as Color;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        done
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: done ? Colors.green : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Icon(c['icon'] as IconData,
                          size: 14, color: done ? Colors.green : color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: done
                                ? Colors.green
                                : cs.onSurface.withValues(alpha: 0.7),
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ── WHERE DID MY MONEY GO CARD (NI-1) ────────────────────────────────────────
class _WhereDidMoneyGoCard extends StatelessWidget {
  final List<Expense> expenses;
  final double monthlyIncome;
  final String currentMonth;

  const _WhereDidMoneyGoCard({
    required this.expenses,
    required this.monthlyIncome,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final thisMonth =
        expenses.where((e) => e.date.startsWith(currentMonth)).toList();
    if (thisMonth.isEmpty) return const SizedBox.shrink();

    final total = thisMonth.fold(0.0, (s, e) => s + e.amount);
    final catTotals = <String, double>{};
    for (final e in thisMonth) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }
    final topCat = catTotals.entries.isEmpty
        ? null
        : (catTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first;
    final savingsPct = monthlyIncome > 0
        ? ((monthlyIncome - total) / monthlyIncome * 100).clamp(0.0, 100.0)
        : 0.0;

    String summary;
    if (topCat != null) {
      final topPct = (topCat.value / total * 100).toStringAsFixed(0);
      summary = "You've spent ${CurrencyService.format(total)} this month. "
          "$topPct% went to ${topCat.key}.";
      if (savingsPct >= 20) {
        summary +=
            " You're saving ${savingsPct.toStringAsFixed(0)}% — on track! ✓";
      } else if (savingsPct > 0) {
        summary +=
            " Savings rate: ${savingsPct.toStringAsFixed(0)}% (target: 20%).";
      } else {
        summary += " Spending exceeds income this month.";
      }
    } else {
      summary = "No expenses this month yet.";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: cs.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                summary,
                style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: cs.onSurface.withValues(alpha: 0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DONE SPENDING TODAY TOGGLE (NI-6) ────────────────────────────────────────
class _DoneSpendingToggle extends StatefulWidget {
  @override
  State<_DoneSpendingToggle> createState() => _DoneSpendingToggleState();
}

class _DoneSpendingToggleState extends State<_DoneSpendingToggle> {
  bool _isDone = false;
  bool _loading = true;
  static const _key = 'done_spending_today';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final val = await DBService.getSetting(_key);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (mounted)
      setState(() {
        _isDone = val == today;
        _loading = false;
      });
  }

  Future<void> _toggle() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_isDone) {
      await DBService.setSetting(_key, '');
      setState(() => _isDone = false);
    } else {
      await DBService.setSetting(_key, today);
      setState(() => _isDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isDone
                ? Colors.green.withValues(alpha: 0.08)
                : cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDone
                  ? Colors.green.withValues(alpha: 0.3)
                  : cs.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: _isDone ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isDone
                          ? "Done spending for today ✓"
                          : "Done spending for today?",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isDone ? Colors.green : null,
                      ),
                    ),
                    Text(
                      _isDone
                          ? "You'll get a reminder if you log more expenses today"
                          : "Tap to commit — helps build spending discipline",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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

// ── WEEKLY CHALLENGE WIDGET (GM-7) ───────────────────────────────────────────
class _WeeklyChallengeWidget extends StatefulWidget {
  final List<Expense> expenses;
  final List<Budget> budgets;
  final double monthlyIncome;

  const _WeeklyChallengeWidget({
    required this.expenses,
    required this.budgets,
    required this.monthlyIncome,
  });

  @override
  State<_WeeklyChallengeWidget> createState() => _WeeklyChallengeWidgetState();
}

class _WeeklyChallengeWidgetState extends State<_WeeklyChallengeWidget> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _checkDismissed();
  }

  Future<void> _checkDismissed() async {
    final now = DateTime.now();
    final weekKey = _isoWeekKey(now);
    final val = await DBService.getSetting('weekly_challenge_dismissed');
    if (mounted) setState(() => _dismissed = val == weekKey);
  }

  Future<void> _dismiss() async {
    final now = DateTime.now();
    final weekKey = _isoWeekKey(now);
    await DBService.setSetting('weekly_challenge_dismissed', weekKey);
    if (mounted) setState(() => _dismissed = true);
  }

  /// Returns a stable ISO week key like "2026-W18" — locale-independent.
  String _isoWeekKey(DateTime date) {
    // ISO 8601: week starts Monday, week 1 = week containing first Thursday
    final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
    final firstDayOfYear = DateTime(thursday.year, 1, 1);
    final weekNum = ((thursday.difference(firstDayOfYear).inDays) ~/ 7) + 1;
    return '${thursday.year}-W${weekNum.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    // Pick challenge based on week number (ISO 8601, locale-independent)
    final thursday = now.add(Duration(days: DateTime.thursday - now.weekday));
    final firstDayOfYear = DateTime(thursday.year, 1, 1);
    final weekNum = ((thursday.difference(firstDayOfYear).inDays) ~/ 7) + 1;
    final challenges = [
      ('🍽️', 'Food Budget Week', 'Spend less than ₱500 on Food this week'),
      ('📝', 'Log Every Day', 'Log at least one expense every day this week'),
      ('💰', 'No Impulse Buys', 'Tag zero expenses as "Want" this week'),
      (
        '🚌',
        'Transport Saver',
        'Spend less than ₱200 on Transportation this week'
      ),
    ];
    final challenge = challenges[weekNum % challenges.length];

    // Check progress
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekExpenses = widget.expenses.where((e) {
      try {
        return !DateTime.parse(e.date).isBefore(weekStart);
      } catch (_) {
        return false;
      }
    }).toList();

    bool achieved = false;
    String progressStr = '';
    if (challenge.$1 == '🍽️') {
      final foodSpent = weekExpenses
          .where((e) => e.category == 'Food')
          .fold(0.0, (s, e) => s + e.amount);
      achieved = foodSpent <= 500;
      progressStr = '${CurrencyService.format(foodSpent)} / ₱500';
    } else if (challenge.$1 == '📝') {
      final loggedDays =
          weekExpenses.map((e) => e.date.substring(0, 10)).toSet().length;
      achieved = loggedDays >= now.weekday;
      progressStr = '$loggedDays / ${now.weekday} days';
    } else if (challenge.$1 == '💰') {
      final wantCount = weekExpenses.where((e) => e.isWant == true).length;
      achieved = wantCount == 0;
      progressStr = '$wantCount Want expenses';
    } else {
      final transportSpent = weekExpenses
          .where((e) => e.category == 'Transportation')
          .fold(0.0, (s, e) => s + e.amount);
      achieved = transportSpent <= 200;
      progressStr = '${CurrencyService.format(transportSpent)} / ₱200';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: achieved
              ? Colors.green.withValues(alpha: 0.08)
              : Colors.indigo.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: achieved
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.indigo.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(challenge.$1, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Weekly Challenge",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withValues(alpha: 0.5))),
                          const Spacer(),
                          if (achieved)
                            const Text("✓ Achieved!",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(challenge.$3,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onPressed: _dismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Progress: $progressStr",
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── RECURRING CANDIDATE CARD ─────────────────────────────────────────────────
/// Self-contained StatefulWidget so dismiss/add buttons manage their own state
/// independently of the parent Dashboard widget tree.
class _RecurringCandidateCard extends StatefulWidget {
  final List<Map<String, dynamic>> candidates;
  final VoidCallback onDismissed;

  const _RecurringCandidateCard({
    required this.candidates,
    required this.onDismissed,
  });

  @override
  State<_RecurringCandidateCard> createState() =>
      _RecurringCandidateCardState();
}

class _RecurringCandidateCardState extends State<_RecurringCandidateCard> {
  late List<Map<String, dynamic>> _local;

  @override
  void initState() {
    super.initState();
    _local = List.from(widget.candidates);
  }

  @override
  void didUpdateWidget(_RecurringCandidateCard old) {
    super.didUpdateWidget(old);
    if (old.candidates != widget.candidates) {
      _local = List.from(widget.candidates);
    }
  }

  void _dismiss(int id) {
    setState(() => _local.removeWhere((c) => c['id'] == id));
    DBService.dismissRecurringCandidate(id).catchError((_) {});
    if (_local.isEmpty) widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    if (_local.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final first = _local.first;
    final count = _local.length;
    final desc = first['description'] as String? ?? 'Unknown';
    final freq = first['frequency'] as String? ?? 'monthly';
    final amt = (first['avg_amount'] as num?)?.toDouble() ?? 0;
    final id = first['id'] as int?;
    if (id == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.repeat_outlined, color: Colors.teal, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Recurring pattern detected",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.teal),
                ),
              ),
              if (count > 1)
                Text("+${count - 1} more",
                    style: const TextStyle(fontSize: 11, color: Colors.teal)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "\"$desc\" appears $freq (~${CurrencyService.format(amt)}/time). "
            "Want to track it as a recurring transaction?",
            style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.75),
                height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _dismiss(id),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(
                          color: cs.onSurface.withValues(alpha: 0.2))),
                  child: const Text("Dismiss", style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text("Add Recurring",
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () async {
                    // Auto-save the recurring entry directly — no need to open
                    // a separate screen. The user already confirmed by tapping.
                    final now = DateTime.now();
                    // Compute next_date based on frequency
                    DateTime nextDate;
                    switch (freq) {
                      case 'weekly':
                        nextDate = now.add(const Duration(days: 7));
                        break;
                      case 'daily':
                        nextDate = now.add(const Duration(days: 1));
                        break;
                      case 'yearly':
                        nextDate = DateTime(now.year + 1, now.month, now.day);
                        break;
                      case 'monthly':
                      default:
                        // Same day next month
                        final nextMonth = now.month == 12
                            ? DateTime(now.year + 1, 1, now.day)
                            : DateTime(now.year, now.month + 1, now.day);
                        nextDate = nextMonth;
                    }
                    // Infer category from description
                    final cat = AIChatService.suggestCategory(desc);
                    final todayStr = now.toIso8601String().substring(0, 10);
                    final nextStr = nextDate.toIso8601String().substring(0, 10);
                    try {
                      await DBService.insertRecurring({
                        'title': desc,
                        'amount': amt,
                        'category': cat.isEmpty ? 'Bills' : cat,
                        'frequency': freq,
                        'next_date': nextStr,
                        'start_date': todayStr,
                        'is_expense': 1,
                        'notes': 'Auto-added from recurring pattern',
                      });
                      _dismiss(id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '✓ "$desc" added as $freq recurring (${CurrencyService.format(amt)})'),
                            backgroundColor: Colors.teal,
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'View',
                              textColor: Colors.white,
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RecurringScreen())),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      _dismiss(id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not add recurring: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── UNIFIED SPENDING LIMITS SHEET ────────────────────────────────────────────
/// Shows all 4 period limits (daily/weekly/monthly/yearly) at once.
/// Each is independently settable or clearable.
/// Opened from: home limit card tap, profile "Spending Limits" tile.
class SpendingLimitsSheet extends StatefulWidget {
  /// Called when any limit changes so the caller can reload state.
  final VoidCallback? onChanged;
  const SpendingLimitsSheet({super.key, this.onChanged});

  /// Open as a modal bottom sheet.
  static Future<void> show(BuildContext context, {VoidCallback? onChanged}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SpendingLimitsSheet(onChanged: onChanged),
    );
  }

  @override
  State<SpendingLimitsSheet> createState() => _SpendingLimitsSheetState();
}

class _SpendingLimitsSheetState extends State<SpendingLimitsSheet> {
  // One controller + current value per period
  final _ctrls = <String, TextEditingController>{};
  final _limits = <String, double>{};
  final _spent = <String, double>{};
  bool _loading = true;

  static const _periods = ['daily', 'weekly', 'monthly', 'yearly'];
  static const _labels = {
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
  };
  static const _icons = {
    'daily': Icons.today_outlined,
    'weekly': Icons.view_week_outlined,
    'monthly': Icons.calendar_month_outlined,
    'yearly': Icons.event_note_outlined,
  };
  static const _hints = {
    'daily': 'e.g. 300 for a ₱300/day cap',
    'weekly': 'e.g. 1500 for a ₱1,500/week cap',
    'monthly': 'e.g. 5000 for a ₱5,000/month cap',
    'yearly': 'e.g. 60000 for a ₱60,000/year cap',
  };

  @override
  void initState() {
    super.initState();
    for (final p in _periods) {
      _ctrls[p] = TextEditingController();
    }
    _load();
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final limits = await DBService.getAllLimits();
    final spent = await DBService.getAllSpent();
    setState(() {
      for (final p in _periods) {
        _limits[p] = limits[p] ?? 0;
        _spent[p] = spent[p] ?? 0;
        _ctrls[p]!.text =
            (_limits[p]! > 0) ? _limits[p]!.toStringAsFixed(0) : '';
      }
      _loading = false;
    });
  }

  Future<void> _save(String period) async {
    final val = double.tryParse(_ctrls[period]!.text) ?? 0;
    await DBService.setLimitForPeriod(period, val);
    setState(() => _limits[period] = val);
    widget.onChanged?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(val > 0
            ? '${_labels[period]} limit set to ${CurrencyService.format(val)}'
            : '${_labels[period]} limit cleared'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _clear(String period) async {
    _ctrls[period]!.clear();
    await DBService.setLimitForPeriod(period, 0);
    setState(() => _limits[period] = 0);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.speed_outlined, color: cs.primary, size: 22),
                const SizedBox(width: 8),
                const Text("Spending Limits",
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Set any combination of limits. Leave blank to skip that period.",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ..._periods.map((period) {
                final limit = _limits[period] ?? 0;
                final spent = _spent[period] ?? 0;
                final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                final isOver = limit > 0 && spent >= limit;
                final isWarn = limit > 0 && ratio >= 0.8 && !isOver;
                final color = isOver
                    ? Colors.red
                    : isWarn
                        ? Colors.orange
                        : cs.primary;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_icons[period], size: 16, color: color),
                          const SizedBox(width: 6),
                          Text(_labels[period]!,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color)),
                          const Spacer(),
                          if (limit > 0)
                            Text(
                              "${CurrencyService.format(spent)} / ${CurrencyService.format(limit)}",
                              style: TextStyle(fontSize: 11, color: color),
                            ),
                        ],
                      ),
                      if (limit > 0) ...[
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 5,
                            backgroundColor: color.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOver
                              ? "Over by ${CurrencyService.format(spent - limit)}"
                              : isWarn
                                  ? "${(ratio * 100).toStringAsFixed(0)}% used — ${CurrencyService.format(limit - spent)} left"
                                  : "${CurrencyService.format(limit - spent)} remaining",
                          style: TextStyle(fontSize: 10, color: color),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ctrls[period],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                prefixText: "₱ ",
                                hintText: _hints[period],
                                hintStyle: const TextStyle(fontSize: 11),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onSubmitted: (_) => _save(period),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline,
                                size: 22),
                            color: cs.primary,
                            tooltip: "Save ${_labels[period]} limit",
                            onPressed: () => _save(period),
                          ),
                          if (limit > 0)
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined, size: 20),
                              color: Colors.red,
                              tooltip: "Clear ${_labels[period]} limit",
                              onPressed: () => _clear(period),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
