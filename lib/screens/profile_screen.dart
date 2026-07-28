import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../main.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/db_service.dart';
import '../services/cloud_service.dart';
import '../services/score_service.dart';
import '../services/export_service.dart';
import '../services/tax_service.dart';
import '../services/demo_service.dart';
import '../services/backup_service.dart';
import '../services/currency_service.dart';
import '../services/event_bus.dart';
import '../services/debug_service.dart';
import '../services/app_lock_service.dart';
import '../services/ai_chat_service.dart';
import '../services/undo_service.dart';
import '../services/category_service.dart';
import 'package:file_picker/file_picker.dart';
import 'login_screen.dart';
import 'about_screen.dart';
import 'bank_import_screen.dart';
import 'help_screen.dart';
import 'pin_setup_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_rules_screen.dart';
import '../widgets/feature_tour.dart';
import '../widgets/info_button.dart';
import 'achievements_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _score = 0;
  int _expenseCount = 0;
  double _totalSpent = 0;
  double _totalIncome = 0;
  double _monthlyIncome = 0;
  double _totalAssets = 0;
  double _totalDebts = 0;
  List<Map<String, dynamic>> _scoreBreakdown = [];
  List<Map<String, dynamic>> _wallets = [];
  UserProfile? _profile;
  String _accountType = 'employed';
  String _incomeFrequency = 'monthly';
  bool _loading = true;
  bool _incomeWalletMode = true; // loaded in _loadStats

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final currentMonth = DateTime.now().toIso8601String().substring(0, 7);

      // Parallelize all independent DB reads
      // Note: we don't need full expense list — just count and this-month for score
      final totalFuture = DBService.getTotalSpent();
      final totalIncomeFuture = DBService.getTotalIncome();
      final incomeFuture = DBService.getMonthlyIncome();
      final budgetsFuture = DBService.getBudgets();
      final thisMonthFuture = DBService.getExpenses(month: currentMonth);
      final accountTypeFuture = DBService.getSetting('account_type');
      final incomeFreqFuture = DBService.getSetting('income_frequency');
      final expenseCountFuture = DBService.getExpenseCount();

      final total = await totalFuture;
      final totalIncome = await totalIncomeFuture;
      final income = await incomeFuture;
      final budgets = await budgetsFuture;
      final thisMonthExpenses = await thisMonthFuture;
      final accountType = (await accountTypeFuture) ?? 'employed';
      final incomeFreq = (await incomeFreqFuture) ?? 'monthly';
      final expenseCount = await expenseCountFuture;

      final expenseData = thisMonthExpenses
          .map((e) =>
              {'amount': e.amount, 'category': e.category, 'date': e.date})
          .toList();
      final iwMode = await DBService.getIncomeWalletMode();
      final spendLimit = await DBService.getSpendingLimit();
      final spendPeriod = await DBService.getSpendingLimitPeriod();
      final rawScore = ScoreService.calculateScore(expenseData,
          budgets: budgets,
          monthlyIncome: iwMode ? income : 0,
          lightweightMode: !iwMode,
          spendingLimit: spendLimit,
          spendingLimitPeriod: spendPeriod);
      final score = await ScoreService.applyAllAdjustments(rawScore);
      final breakdown = ScoreService.getBreakdown(expenseData,
          budgets: budgets,
          monthlyIncome: iwMode ? income : 0,
          lightweightMode: !iwMode,
          spendingLimit: spendLimit,
          spendingLimitPeriod: spendPeriod);

      UserProfile? profile;
      if (user != null) {
        profile = await DBService.getProfile(user.uid);
        if (profile == null) {
          try {
            profile = await CloudService.fetchProfile()
                .timeout(const Duration(seconds: 5));
            if (profile != null) await DBService.saveProfile(profile);
          } catch (_) {}
        }
        profile ??= UserProfile(uid: user.uid, email: user.email);
      }

      if (mounted) {
        setState(() {
          _expenseCount = expenseCount;
          _totalSpent = total;
          _totalIncome = totalIncome;
          _monthlyIncome = income;
          _score = score;
          _scoreBreakdown = breakdown;
          _profile = profile;
          _accountType = accountType;
          _incomeFrequency = incomeFreq;
          _incomeWalletMode = iwMode;
          _loading = false;
        });
      }

      // Load debts for net worth calculation
      // Only count "owe" type (money user owes) as liabilities — "lent" is an asset
      final debts = await DBService.getDebts();
      final totalDebts = debts
          .where((d) => (d['type'] as String? ?? 'owe') == 'owe')
          .fold<double>(
              0,
              (s, d) =>
                  s +
                  ((d['amount'] as num) - (d['paid_amount'] as num))
                      .toDouble()
                      .clamp(0, double.infinity));
      // Load manual assets from settings
      final assetsStr = await DBService.getSetting('manual_assets');
      final totalAssets = double.tryParse(assetsStr ?? '') ?? 0.0;
      // Include installment remaining balances in liabilities (#12)
      final installmentsDebt = await DBService.getInstallmentsRemainingTotal();
      // Load wallet balances
      List<Map<String, dynamic>> wallets = [];
      try {
        wallets = await DBService.getWallets();
      } catch (_) {}
      final walletTotal =
          wallets.fold<double>(0, (s, w) => s + (w['balance'] as num));
      if (mounted)
        setState(() {
          _totalDebts = totalDebts + installmentsDebt;
          _totalAssets = walletTotal > 0 ? walletTotal : totalAssets;
          _wallets = wallets;
        });
    } catch (e) {
      // Something failed — still show the screen
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        setState(() {
          _profile = user != null
              ? UserProfile(uid: user.uid, email: user.email)
              : null;
          _loading = false;
        });
      }
    }
  }

  void _openEditProfile() async {
    final updated = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile!)),
    );
    if (updated != null) {
      await DBService.saveProfile(updated);
      setState(() => _profile = updated);
    }
  }

  /// Get the best available profile image: local file > stored URL > Google photo > null
  ImageProvider? _getProfileImage() {
    final photoUrl = _profile?.photoUrl;
    // 1. Local file photo (from gallery pick)
    if (photoUrl != null && photoUrl.startsWith('/')) {
      if (File(photoUrl).existsSync()) {
        return FileImage(File(photoUrl));
      }
    }
    // 2. Stored URL (e.g. from previous Google sign-in)
    if (photoUrl != null && photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    }
    // 3. Fallback: Google account photo from Firebase Auth
    final googlePhoto = FirebaseAuth.instance.currentUser?.photoURL;
    if (googlePhoto != null && googlePhoto.isNotEmpty) {
      return NetworkImage(googlePhoto);
    }
    // 4. No photo available
    return null;
  }

  void _showWalletsDialog() async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => WalletsSheet(
        wallets: _wallets,
        onChanged: () async {
          final updated = await DBService.getWallets();
          if (mounted) setState(() => _wallets = updated);
        },
      ),
    );
    // Refresh after sheet closes
    final updated = await DBService.getWallets();
    if (mounted) {
      final walletTotal =
          updated.fold<double>(0, (s, w) => s + (w['balance'] as num));
      setState(() {
        _wallets = updated;
        _totalAssets = walletTotal;
      });
    }
  }

  void _showSettingsSheet() async {
    // Load current settings
    bool autoDeduct =
        (await DBService.getSetting('wallet_auto_deduct')) != 'false';
    bool moodEnabled =
        (await DBService.getSetting('mood_checkin_enabled')) != 'false';
    bool impulseEnabled =
        (await DBService.getSetting('impulse_pause_enabled')) != 'false';
    bool budgetAlerts =
        (await DBService.getSetting('budget_alerts_enabled')) != 'false';
    bool balanceMode = (await DBService.getSetting('balance_mode')) == 'true';
    bool roundUpSavings =
        (await DBService.getSetting('round_up_savings')) != 'false';
    bool compactMode = (await DBService.getSetting('compact_mode')) == 'true';
    // New: lightweight mode + spending limit
    bool incomeWalletMode = await DBService.getIncomeWalletMode();
    double spendingLimit = await DBService.getSpendingLimit();
    String spendingLimitPeriod = await DBService.getSpendingLimitPeriod();
    final limitCtrl = TextEditingController(
        text: spendingLimit > 0 ? spendingLimit.toStringAsFixed(0) : '');

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text("App Settings",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Customize how Smart Spend works for you",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 16),
              _settingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "Auto-deduct wallets",
                subtitle: "Deduct from Cash/GCash/Maya when logging expenses",
                value: autoDeduct,
                onChanged: (v) {
                  setSheet(() => autoDeduct = v);
                  DBService.setSetting(
                      'wallet_auto_deduct', v ? 'true' : 'false');
                },
              ),
              _settingsTile(
                icon: Icons.emoji_emotions_outlined,
                title: "Daily mood check-in",
                subtitle: "Show mood prompt on home screen",
                value: moodEnabled,
                onChanged: (v) {
                  setSheet(() => moodEnabled = v);
                  DBService.setSetting(
                      'mood_checkin_enabled', v ? 'true' : 'false');
                },
              ),
              _settingsTile(
                icon: Icons.pause_circle_outline,
                title: "Impulse pause",
                subtitle: "Confirm before logging large Want expenses",
                value: impulseEnabled,
                onChanged: (v) {
                  setSheet(() => impulseEnabled = v);
                  DBService.setSetting(
                      'impulse_pause_enabled', v ? 'true' : 'false');
                },
              ),
              _settingsTile(
                icon: Icons.notifications_outlined,
                title: "Budget alerts",
                subtitle: "Notify when category budget hits 80% or 100%",
                value: budgetAlerts,
                onChanged: (v) {
                  setSheet(() => budgetAlerts = v);
                  DBService.setSetting(
                      'budget_alerts_enabled', v ? 'true' : 'false');
                },
              ),
              const SizedBox(height: 12),
              Text("Display",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600])),
              const SizedBox(height: 8),
              _settingsTile(
                icon: Icons.account_balance_wallet,
                title: "Balance mode",
                subtitle:
                    "Show wallet total as primary balance instead of income-based remaining",
                value: balanceMode,
                onChanged: (v) {
                  setSheet(() => balanceMode = v);
                  DBService.setSetting('balance_mode', v ? 'true' : 'false');
                  fireEvent(AppEvent.incomeChanged);
                },
              ),
              _settingsTile(
                icon: Icons.savings_outlined,
                title: "Round-up savings",
                subtitle:
                    "Auto-save spare change to your first savings goal (rounds to nearest ₱10)",
                value: roundUpSavings,
                onChanged: (v) {
                  setSheet(() => roundUpSavings = v);
                  DBService.setSetting(
                      'round_up_savings', v ? 'true' : 'false');
                },
              ),
              _settingsTile(
                icon: Icons.density_medium_outlined,
                title: "Compact mode",
                subtitle:
                    "Reduce spacing & list density for more items per screen",
                value: compactMode,
                onChanged: (v) {
                  setSheet(() => compactMode = v);
                  themeService.setCompactMode(v);
                  DBService.setSetting('compact_mode', v ? 'true' : 'false');
                  fireEvent(AppEvent.incomeChanged);
                },
              ),
              const SizedBox(height: 12),
              Text("Tracking Mode",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                "Choose how SmartSpend calculates your Financial Health Score.",
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
              _settingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "Track income & wallets",
                subtitle: incomeWalletMode
                    ? "ON — full FHS with savings rate & wallet tracking"
                    : "OFF — FHS uses spending habits only (no income needed)",
                value: incomeWalletMode,
                onChanged: (v) {
                  setSheet(() => incomeWalletMode = v);
                  DBService.setIncomeWalletMode(v);
                  fireEvent(AppEvent.incomeChanged);
                },
              ),
              const SizedBox(height: 12),
              Text("Spending Limit",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                "Set a single cap for your total spending. Works in any mode.",
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
              // Period picker
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Text("Period:",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'daily', label: Text('Day')),
                        ButtonSegment(value: 'weekly', label: Text('Week')),
                        ButtonSegment(value: 'monthly', label: Text('Month')),
                        ButtonSegment(value: 'yearly', label: Text('Year')),
                      ],
                      selected: {spendingLimitPeriod},
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStateProperty.all(
                            const TextStyle(fontSize: 11)),
                      ),
                      onSelectionChanged: (v) {
                        setSheet(() => spendingLimitPeriod = v.first);
                        DBService.setSpendingLimitPeriod(v.first);
                        fireEvent(AppEvent.expenseChanged);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Limit amount field
              Row(
                children: [
                  const Icon(Icons.price_change_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: limitCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        prefixText: "₱ ",
                        hintText: "e.g. 500 for daily, 5000 for monthly",
                        hintStyle: const TextStyle(fontSize: 11),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check, size: 18),
                          tooltip: "Save limit",
                          onPressed: () {
                            final val = double.tryParse(limitCtrl.text) ?? 0;
                            setSheet(() => spendingLimit = val);
                            DBService.setSpendingLimit(val);
                            fireEvent(AppEvent.expenseChanged);
                          },
                        ),
                      ),
                    ),
                  ),
                  if (spendingLimit > 0)
                    TextButton(
                      onPressed: () {
                        limitCtrl.clear();
                        setSheet(() => spendingLimit = 0);
                        DBService.setSpendingLimit(0);
                        fireEvent(AppEvent.expenseChanged);
                      },
                      child: const Text("Clear",
                          style: TextStyle(fontSize: 11, color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _showSpendingChallengeDialog() async {
    final existing = await DBService.getSetting('spending_challenge');
    final ctrl = TextEditingController(
        text: existing != null && existing != '0' ? existing : '');
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Monthly Spending Challenge"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set a personal spending target for this month. "
              "The app will track your progress and show a win/lose result at month end.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly spending target",
                prefixText: "${CurrencyService.symbol} ",
                border: const OutlineInputBorder(),
                helperText: "Leave blank to disable",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(ctrl.text) ?? 0;
              await DBService.setSetting('spending_challenge', val.toString());
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(val > 0
                      ? "Challenge set: spend less than ${CurrencyService.format(val)} this month"
                      : "Challenge disabled"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDailyLimitDialog() async {
    final limitStr = await DBService.getSetting('daily_limit');
    final ctrl = TextEditingController(
        text: limitStr != null && limitStr != '0' ? limitStr : '');
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Daily Spending Limit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set a daily spending cap. You'll get a notification when you reach 80% and when you exceed it.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Daily limit",
                prefixText: "${CurrencyService.symbol} ",
                border: const OutlineInputBorder(),
                helperText: "Leave blank or 0 to disable",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(ctrl.text) ?? 0;
              await DBService.setDailyLimit(val);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(val > 0
                      ? "Daily limit set to ${CurrencyService.format(val)}"
                      : "Daily limit disabled"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showIncomeDialog() {
    final controller =
        TextEditingController(text: _monthlyIncome.toStringAsFixed(0));

    final isStudent = _accountType == 'student';
    final isUnemployed = _accountType == 'unemployed';

    final frequencyOptions = isStudent
        ? [
            ('daily', 'Daily allowance'),
            ('weekly', 'Weekly allowance'),
            ('bimonthly', 'Bi-monthly (15th & 30th)'),
            ('monthly', 'Monthly allowance'),
            ('manual', 'Manual — enter total')
          ]
        : isUnemployed
            ? [
                ('manual', 'Manual — enter total'),
                ('monthly', 'Monthly'),
                ('weekly', 'Weekly'),
              ]
            : _accountType == 'general'
                ? [
                    ('daily', 'Daily'),
                    ('weekly', 'Weekly'),
                    ('bimonthly', 'Bi-monthly (15th & 30th)'),
                    ('monthly', 'Monthly'),
                    ('manual', 'Manual — enter total'),
                  ]
                : [
                    ('daily', 'Daily wage'),
                    ('weekly', 'Weekly pay'),
                    ('bimonthly', 'Bi-monthly (15th & 30th)'),
                    ('monthly', 'Monthly salary'),
                    ('manual', 'Manual — enter total'),
                  ];

    // Load current frequency first, then show dialog
    DBService.getSetting('income_frequency').then((savedFreq) {
      String frequency = savedFreq ?? 'monthly';

      showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (ctx, setDialog) => AlertDialog(
            title: Text(_incomeLabel),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: (_) =>
                      setDialog(() {}), // trigger rebuild for helper text
                  decoration: InputDecoration(
                      labelText: frequency == 'manual'
                          ? "How much money do you have right now?"
                          : "$_incomeLabel amount",
                      prefixText: "${CurrencyService.symbol} ",
                      helperText: () {
                        if (frequency == 'manual')
                          return "Stored as-is — no conversion";
                        final raw = double.tryParse(controller.text) ?? 0;
                        if (raw <= 0) return null;
                        double monthly = raw;
                        if (frequency == 'daily') monthly = raw * 22;
                        if (frequency == 'weekly') monthly = raw * 4.33;
                        if (frequency == 'bimonthly') monthly = raw * 2;
                        if (frequency == 'monthly') return null;
                        return "= ${CurrencyService.format(monthly)}/month equivalent";
                      }()),
                ),
                if (frequencyOptions.length > 1) ...[
                  const SizedBox(height: 14),
                  const Text("How often?",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  ...frequencyOptions.map((f) => InkWell(
                        onTap: () => setDialog(() => frequency = f.$1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                frequency == f.$1
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: frequency == f.$1
                                    ? Theme.of(ctx).colorScheme.primary
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(f.$2, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      )),
                ],
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  final raw = double.tryParse(controller.text);
                  if (raw != null && raw > 0) {
                    // Convert to monthly equivalent
                    // 'manual' = user entered total balance — store as-is
                    double monthly = raw;
                    if (frequency == 'daily') monthly = raw * 22;
                    if (frequency == 'weekly') monthly = raw * 4.33;
                    if (frequency == 'bimonthly') monthly = raw * 2;
                    // manual: monthly = raw (no conversion)
                    await DBService.setMonthlyIncome(monthly);
                    await DBService.setSetting('income_frequency', frequency);
                    fireEvent(AppEvent.incomeChanged);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadStats();
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _resetAllData() async {
    // Two-step confirmation with keyword
    final step1 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset All Data"),
        content: const Text(
            "⚠️ This will permanently delete ALL your expenses, budgets, goals, income, debts, and recurring transactions.\n\n"
            "Your account and profile will NOT be deleted.\n\n"
            "This cannot be undone. Are you sure?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Continue"),
          ),
        ],
      ),
    );
    if (step1 != true || !mounted) return;

    // Second confirmation — type keyword
    final ctrl = TextEditingController();
    final step2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Reset"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type "RESET" to confirm:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "RESET",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text == 'RESET'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete Everything"),
          ),
        ],
      ),
    );
    if (step2 != true || !mounted) return;

    // Perform reset
    final db = await DBService.getDB();
    await db.delete('expenses');
    await db.delete('budgets');
    await db.delete('savings_goals');
    await db.delete('income');
    await db.delete('recurring');
    await db.delete('debts');
    await db.delete('score_history');
    await db.delete('chat_history');
    // Also clear tables that were previously missed
    try {
      await db.delete('installment_plans');
    } catch (_) {}
    try {
      await db.delete('installments');
    } catch (_) {}
    try {
      await db.delete('custom_categories');
      CategoryService.invalidate();
    } catch (_) {}
    try {
      await db.delete('mood_log');
    } catch (_) {}
    try {
      await db.delete('recurring_candidates');
    } catch (_) {}
    try {
      await db.delete('conversation_summaries');
    } catch (_) {}
    try {
      await db.update('wallets',
          {'balance': 0.0, 'updated_at': DateTime.now().toIso8601String()});
    } catch (_) {}
    // Push the cleared state to Firestore so data doesn't resurrect on next login
    try {
      await CloudService.pushAll(
        expenses: [],
        budgets: [],
        goals: [],
        income: [],
        recurring: [],
        debts: [],
        customCategories: [],
        installments: [],
        installmentPlans: [],
        wallets: await DBService.getWallets(),
        categoryRules: [],
      );
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All data deleted."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      _loadStats();
    }
  }

  Future<void> _loadDemo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Load Demo Data"),
        content: const Text(
            "This will replace all your current expenses, budgets, and goals with sample data. "
            "Your account and profile will not be affected.\n\nContinue?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
            child: const Text("Load Demo"),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await DemoService.loadSampleData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Demo data loaded! Pull to refresh."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green),
      );
      _loadStats();
    }
  }

  Future<void> _showBIRBreakdown() async {
    if (_monthlyIncome <= 0) return;
    final tax = TaxService.estimateTax(_monthlyIncome);
    // PH government contributions (approximate)
    final sss = (_monthlyIncome * 0.045).clamp(560.0, 1350.0); // employee share
    final philhealth =
        (_monthlyIncome * 0.025).clamp(250.0, 2500.0); // employee 2.5%
    const pagibig = 200.0; // max employee contribution
    final totalDeductions = tax + sss + philhealth + pagibig;
    final takeHome = _monthlyIncome - totalDeductions;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Monthly Deductions Estimate",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Based on PH TRAIN Law + mandatory contributions",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            _birRow("Gross Income", _monthlyIncome, Colors.green),
            const Divider(height: 20),
            _birRow("BIR Income Tax", -tax, Colors.red),
            _birRow("SSS (employee 4.5%)", -sss, Colors.orange),
            _birRow("PhilHealth (2.5%)", -philhealth, Colors.orange),
            _birRow("Pag-IBIG", -pagibig, Colors.orange),
            const Divider(height: 20),
            _birRow("Est. Take-Home Pay", takeHome,
                takeHome > 0 ? Colors.green : Colors.red,
                bold: true),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "⚠️ Estimation only — not official tax advice. Actual amounts depend on your specific tax situation. Consult a licensed accountant for official BIR compliance.",
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _birRow(String label, double amount, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(
            "${amount >= 0 ? '' : '-'}${CurrencyService.format(amount.abs())}",
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _showHealthCertificate() async {
    final now = DateTime.now();
    final monthStr = "${[
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][now.month]} ${now.year}";
    final scoreLabel = _score >= 80
        ? "Excellent 🌟"
        : _score >= 60
            ? "Good ✅"
            : "In Progress 📈";

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade700, Colors.indigo.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("🏅 Financial Health Certificate",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(
                    "${_profile?.displayName ?? 'User'}",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text("has achieved a Financial Health Score of",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text("$_score / 100",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold)),
                  Text(scoreLabel,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text("$monthStr · SmartSpend by Lucid Frame",
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final text =
                      "🏅 My Financial Health Score: $_score/100 ($scoreLabel)\n"
                      "$monthStr — SmartSpend by Lucid Frame\n\n"
                      "Track your finances smarter with SmartSpend!";
                  await Share.share(text,
                      subject: "My SmartSpend Financial Health Certificate");
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.share),
                label: const Text("Share Certificate"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    try {
      final expenses = await DBService.getExpenses();
      if (expenses.isEmpty) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No expenses to export.")));
        return;
      }
      await ExportService.exportToCSV(expenses);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Export failed: $e")));
    }
  }

  Future<void> _backupToDrive() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Preparing backup..."),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5)),
    );
    try {
      final success = await BackupService.backup();
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Backup cancelled."),
            behavior: SnackBarBehavior.floating,
          ));
        }
        // Success: share sheet handled it — no extra snackbar needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Backup error: ${e.toString().replaceAll('Exception: ', '')}"),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _restoreFromDrive() async {
    // Pick a backup JSON file from device storage
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Smart Spend backup file',
      );

      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.first.path;
      if (filePath == null) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Restore Backup"),
          content: Text("Import data from:\n${result.files.first.name}\n\n"
              "Existing data will not be deleted — restored items will be added alongside."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Restore"),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Restoring..."),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 30)),
      );

      final restoreResult = await BackupService.restoreFromFile(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(restoreResult.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: restoreResult.success ? Colors.green : null,
          duration: const Duration(seconds: 4),
        ));
        if (restoreResult.success) _loadStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Restore error: ${e.toString().replaceAll('Exception: ', '')}"),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _logout() async {
    // Warn user and give them a chance to cancel
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your data will be saved to the cloud before logging out.",
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 10),
            Text(
              "Local data will be cleared so the next account starts clean — no data mixing between accounts.",
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 10),
            Text(
              "Your data will be restored from the cloud when you log back in.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    // Show progress
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Saving your data to cloud..."),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      // Push all local data to Firestore before clearing
      await DBService.pushAllToCloud();
    } catch (_) {
      // Non-fatal — proceed with logout even if push fails
      // (data may already be in cloud from real-time pushes)
    }

    // Clear local DB so next account doesn't see this account's data
    await DBService.clearLocalData();

    // Clear AI context and history so next user doesn't see previous user's data
    AIChatService.clearHistory();
    UndoService.clear();

    // Sign out of Firebase + Google
    await AuthService.logout();

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  String get _incomeLabel {
    // Frequency-aware label — reflects how the user receives their income
    final freqPrefix = () {
      switch (_incomeFrequency) {
        case 'daily':
          return 'Daily';
        case 'weekly':
          return 'Weekly';
        case 'bimonthly':
          return 'Bi-Monthly';
        case 'manual':
          return 'Current';
        default:
          return 'Monthly';
      }
    }();
    switch (_accountType) {
      case 'student':
        return '$freqPrefix Allowance';
      case 'unemployed':
        return '$freqPrefix Budget';
      case 'pensioner':
        return '$freqPrefix Pension';
      case 'freelancer':
        return '$freqPrefix Income';
      case 'general':
        return '$freqPrefix Income / Budget';
      default:
        return '$freqPrefix Income';
    }
  }

  Color _scoreColor(int s) {
    if (s >= 80) return Colors.green;
    if (s >= 60) return Colors.orange;
    return Colors.red;
  }

  String _accountTypeLabel(String type) {
    const labels = {
      'employed': 'Employed',
      'business': 'Business Owner',
      'student': 'Student',
      'working_student': 'Working Student',
      'unemployed': 'Unemployed',
      'freelancer': 'Freelancer',
      'pensioner': 'Pensioner / Retiree',
      'general': 'General / Other',
    };
    return labels[type] ?? type;
  }

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("App Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTheme.values.map((theme) {
            final isSelected = themeService.appTheme == theme;
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: theme.primaryColor,
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              title: Text(theme.label),
              onTap: () async {
                await themeService.setTheme(theme);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
        ],
      ),
    );
  }

  void _showTextSizePicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Text Size"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (1.0, 'Normal', 'Default text size'),
            (1.15, 'Large', 'Easier to read'),
            (1.3, 'Extra Large', 'Best for accessibility'),
          ].map((option) {
            final isSelected = themeService.textScale == option.$1;
            return ListTile(
              dense: true,
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(option.$2),
              subtitle: Text(option.$3, style: const TextStyle(fontSize: 11)),
              onTap: () async {
                await themeService.setTextScale(option.$1);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
        ],
      ),
    );
  }

  void _showAccountTypeDialog() {
    final types = [
      ('employed', Icons.work_outline, 'Employed', 'Regular salary or wages'),
      (
        'business',
        Icons.store_outlined,
        'Business Owner',
        'Self-employed or business income'
      ),
      (
        'freelancer',
        Icons.laptop_outlined,
        'Freelancer',
        'Project-based or contract income'
      ),
      (
        'student',
        Icons.school_outlined,
        'Student',
        'Allowance-based, no regular salary'
      ),
      (
        'working_student',
        Icons.work_history_outlined,
        'Working Student',
        'Part-time income while studying'
      ),
      (
        'pensioner',
        Icons.elderly_outlined,
        'Pensioner / Retiree',
        'Pension or retirement income'
      ),
      (
        'unemployed',
        Icons.person_outline,
        'Unemployed',
        'No regular income currently'
      ),
      (
        'general',
        Icons.person_pin_outlined,
        'General / Other',
        'Any income type — full flexibility'
      ),
    ];
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text("Account Type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: types
                .map((t) => InkWell(
                      onTap: () async {
                        await DBService.setSetting('account_type', t.$1);
                        setState(() => _accountType = t.$1);
                        if (ctx.mounted) Navigator.pop(ctx);
                        // Fire event so other screens refresh
                        fireEvent(AppEvent.incomeChanged);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: Row(
                          children: [
                            Icon(t.$2,
                                size: 22,
                                color: _accountType == t.$1
                                    ? Theme.of(ctx).colorScheme.primary
                                    : null),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.$3,
                                      style: TextStyle(
                                          fontWeight: _accountType == t.$1
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                  Text(t.$4,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            if (_accountType == t.$1)
                              Icon(Icons.check_circle,
                                  color: Theme.of(ctx).colorScheme.primary,
                                  size: 18),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tax = TaxService.estimateTax(_monthlyIncome);
    final savings = TaxService.suggestedSavings(_monthlyIncome);
    final displayName = _profile?.displayName ?? '';
    final initials = _profile?.initials ?? '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          const InfoButton(
            title: "Profile",
            body:
                "Manage your account, settings, and financial preferences.\n\n"
                "📊 Financial Health Score — your overall money management rating.\n"
                "🎯 Savings Goals — track progress toward your targets.\n"
                "🔔 Notifications — configure alerts and reminders.\n"
                "🔒 App Lock — protect your data with a PIN.\n"
                "💾 Backup & Restore — export your data as a JSON file.\n\n"
                "Changes to income, account type, and currency sync across devices.",
          ),
          // UX-2: Share financial summary
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: "Share summary",
            onPressed: () {
              final now = DateTime.now();
              final month = "${[
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec'
              ][now.month - 1]} ${now.year}";
              final scoreLabel = _score >= 80
                  ? 'Good 🟢'
                  : _score >= 60
                      ? 'Fair 🟡'
                      : 'Needs Attention 🔴';
              final savings = _monthlyIncome > 0
                  ? (((_monthlyIncome - _totalSpent) / _monthlyIncome) * 100)
                      .clamp(0.0, 100.0)
                      .toStringAsFixed(0)
                  : null;
              final summary = StringBuffer();
              summary.writeln('📊 My Smart Spend Summary — $month');
              summary.writeln('');
              summary
                  .writeln('💰 Spent: ${CurrencyService.format(_totalSpent)}');
              if (_monthlyIncome > 0)
                summary.writeln(
                    '📈 Income: ${CurrencyService.format(_monthlyIncome)}');
              if (savings != null)
                summary.writeln('💵 Savings Rate: $savings%');
              summary.writeln(
                  '🏥 Financial Health Score: $_score/100 — $scoreLabel');
              if (_totalDebts > 0)
                summary.writeln(
                    '💳 Outstanding Debts: ${CurrencyService.format(_totalDebts)}');
              summary.writeln('');
              summary.writeln('Tracked with Smart Spend 📱');
              Share.share(summary.toString(),
                  subject: 'My Financial Summary — $month');
            },
          ),
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: "Edit profile",
              onPressed: _openEditProfile,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundImage: _getProfileImage(),
                          child: _getProfileImage() == null
                              ? Text(initials,
                                  style: TextStyle(
                                      fontSize: 32,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold))
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (displayName.isNotEmpty)
                      Text(displayName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                        _profile?.email ??
                            FirebaseAuth.instance.currentUser?.email ??
                            '',
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statCard(context, "Expenses", "$_expenseCount"),
                        _statCard(context, "Total Spent",
                            CurrencyService.format(_totalSpent)),
                        _statCard(context, "Health Score", "$_score/100",
                            color: _scoreColor(_score)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Net Worth card — only shown in income/wallet mode
                    if (_incomeWalletMode)
                      FutureBuilder<String?>(
                          future: DBService.getSetting('balance_mode'),
                          builder: (context, balModeSnap) {
                            final balanceMode = balModeSnap.data == 'true';
                            final isAllowanceBased =
                                _accountType == 'student' ||
                                    _accountType == 'unemployed';
                            final walletTotal = _wallets.fold<double>(
                                0, (s, w) => s + (w['balance'] as num));
                            final balance = _monthlyIncome - _totalSpent;
                            final netWorth = _totalIncome +
                                (walletTotal > 0 ? walletTotal : _totalAssets) -
                                _totalSpent -
                                _totalDebts;
                            // Balance mode: show wallet total as primary
                            final displayValue = balanceMode
                                ? walletTotal
                                : isAllowanceBased
                                    ? balance
                                    : netWorth;
                            final isPositive = displayValue >= 0;
                            final label = balanceMode
                                ? "Total Cash Available"
                                : isAllowanceBased
                                    ? "Remaining Balance (This Month)"
                                    : "Net Worth";
                            return GestureDetector(
                              onTap: () => _showWalletsDialog(),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isPositive
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isPositive
                                        ? Colors.green.withValues(alpha: 0.3)
                                        : Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(label,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                    Icons
                                                        .account_balance_wallet_outlined,
                                                    size: 12,
                                                    color: Colors.grey),
                                                const SizedBox(width: 2),
                                                const Text(
                                                    "Tap to manage wallets",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey)),
                                              ],
                                            ),
                                            Text(
                                              "${isPositive ? '+' : ''}${CurrencyService.format(displayValue.abs())}",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: isPositive
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          isPositive
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          color: isPositive
                                              ? Colors.green
                                              : Colors.red,
                                          size: 32,
                                        ),
                                      ],
                                    ),
                                    if (!isAllowanceBased) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "Assets: ${CurrencyService.format(_totalIncome + (walletTotal > 0 ? walletTotal : _totalAssets))}",
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green)),
                                          Text(
                                              "Liabilities: ${CurrencyService.format(_totalSpent + _totalDebts)}",
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // NI-5: Net worth trend sparkline using score history as proxy
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                        future:
                                            DBService.getScoreHistory(days: 30),
                                        builder: (ctx, snap) {
                                          final history = snap.data ?? [];
                                          if (history.length < 3)
                                            return const SizedBox.shrink();
                                          // Use score as a proxy trend indicator
                                          final scores = history
                                              .map((h) => (h['score'] as num)
                                                  .toDouble())
                                              .toList();
                                          final maxScore = scores
                                              .reduce((a, b) => a > b ? a : b)
                                              .clamp(1.0, 100.0);
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Financial health trend (30 days)",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[500])),
                                              const SizedBox(height: 4),
                                              SizedBox(
                                                height: 24,
                                                child: CustomPaint(
                                                  size: const Size(
                                                      double.infinity, 24),
                                                  painter: _SparklinePainter(
                                                      scores,
                                                      maxScore,
                                                      isPositive
                                                          ? Colors.green
                                                          : Colors.orange),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Tap to manage assets",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[500])),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),

                    const SizedBox(height: 16),

                    // Income card — only shown in income/wallet mode
                    if (_incomeWalletMode)
                      GestureDetector(
                        onTap: _showIncomeDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_incomeLabel,
                                      style: TextStyle(
                                          color: cs.onPrimaryContainer
                                              .withValues(alpha: 0.7),
                                          fontSize: 12)),
                                  Text(CurrencyService.format(_monthlyIncome),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: cs.onPrimaryContainer)),
                                  // Low income warning
                                  if (_monthlyIncome > 0 &&
                                      _monthlyIncome < 1000) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "⚠️ Looks low — tap to update",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                  // Show per-period breakdown when not monthly
                                  if (_incomeFrequency != 'monthly' &&
                                      _incomeFrequency != 'manual' &&
                                      _monthlyIncome > 0) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      () {
                                        switch (_incomeFrequency) {
                                          case 'daily':
                                            return '≈ ${CurrencyService.format(_monthlyIncome / 22)}/day · ${CurrencyService.format(_monthlyIncome)}/mo equiv.';
                                          case 'weekly':
                                            return '≈ ${CurrencyService.format(_monthlyIncome / 4.33)}/week · ${CurrencyService.format(_monthlyIncome)}/mo equiv.';
                                          case 'bimonthly':
                                            return '≈ ${CurrencyService.format(_monthlyIncome / 2)}/release · ${CurrencyService.format(_monthlyIncome)}/mo equiv.';
                                          default:
                                            return '';
                                        }
                                      }(),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: cs.onPrimaryContainer
                                              .withValues(alpha: 0.55)),
                                    ),
                                  ],
                                ],
                              ),
                              // Only show tax/savings for employed/business/working_student/freelancer
                              if (_accountType != 'student' &&
                                  _accountType != 'unemployed' &&
                                  _accountType != 'pensioner' &&
                                  _accountType != 'general')
                                GestureDetector(
                                  onTap: () => _showBIRBreakdown(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          "Tax: ~${CurrencyService.format(tax)}/mo",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: cs.onPrimaryContainer
                                                  .withValues(alpha: 0.7))),
                                      Text(
                                          "Save: ${CurrencyService.format(savings)}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[
                                                  Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? 300
                                                      : 700])),
                                      Text("Tap for BIR breakdown",
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: cs.onPrimaryContainer
                                                  .withValues(alpha: 0.4))),
                                    ],
                                  ),
                                ),
                              Icon(Icons.edit,
                                  size: 16,
                                  color: cs.onPrimaryContainer
                                      .withValues(alpha: 0.5)),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Score breakdown
                    if (_scoreBreakdown.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Score Breakdown",
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Column(
                          children: _scoreBreakdown.map((item) {
                            final pts = item['points'] as int;
                            final reason = item['reason'] as String;
                            final component =
                                item['component'] as String? ?? '';
                            final positive = pts >= 0;

                            // Actionable tips per component
                            String? tip;
                            if (!positive || pts < 20) {
                              switch (component) {
                                case 'savings_rate':
                                  tip =
                                      'Try to spend less than 80% of your income. Even saving 10% is a good start.';
                                  break;
                                case 'overspend_control':
                                  tip =
                                      'Check which days you overspent and what you bought. Set a daily spending reminder.';
                                  break;
                                case 'budget_adherence':
                                  tip =
                                      'Review which budget categories are exceeded and reduce spending there first.';
                                  break;
                                case 'logging_consistency':
                                  tip =
                                      'Log expenses daily — even a quick note helps. Use Quick Log chips for common items.';
                                  break;
                                // Lightweight mode components
                                case 'spending_restraint':
                                  tip = _incomeWalletMode
                                      ? null
                                      : 'Set a spending limit in Settings to track restraint more accurately.';
                                  break;
                                case 'category_balance':
                                  tip =
                                      'Try spreading spending across more categories. One dominant category can hide overspending.';
                                  break;
                                case 'habit_streak':
                                  tip =
                                      'Log at least one expense every day to build your streak. Even ₱0 days count if you note them.';
                                  break;
                              }
                            }

                            return ListTile(
                              dense: true,
                              leading: Icon(
                                positive
                                    ? Icons.add_circle_outline
                                    : Icons.remove_circle_outline,
                                color: positive ? Colors.green : Colors.red,
                                size: 18,
                              ),
                              title: Text(reason,
                                  style: const TextStyle(fontSize: 13)),
                              subtitle: tip != null
                                  ? Text(tip,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.orange))
                                  : null,
                              trailing: Text(
                                "${positive ? '+' : ''}${item['points']}pts",
                                style: TextStyle(
                                    color: positive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Settings
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.badge_outlined),
                            title: const Text("Account Type"),
                            subtitle: Text(_accountTypeLabel(_accountType)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _showAccountTypeDialog,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.g_mobiledata,
                                color: Color(0xFFDB4437), size: 28),
                            title: const Text("Google Account"),
                            subtitle: Text(
                              AuthService.isGoogleLinked
                                  ? "Linked — sign in with Google enabled"
                                  : "Not linked — tap to connect",
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: AuthService.isGoogleLinked
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const Icon(Icons.chevron_right),
                            onTap: AuthService.isGoogleLinked
                                ? null
                                : () async {
                                    try {
                                      final user = await AuthService
                                          .linkGoogleToCurrentUser();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(user != null
                                              ? "Google account linked!"
                                              : "Linking cancelled."),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: user != null
                                              ? Colors.green
                                              : null,
                                        ));
                                        if (user != null) setState(() {});
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "Could not link Google: ${e.toString().replaceAll('Exception: ', '')}"),
                                          behavior: SnackBarBehavior.floating,
                                        ));
                                      }
                                    }
                                  },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.dark_mode_outlined),
                            title: const Text("Dark Mode"),
                            trailing: Switch(
                              value: themeService.isDark,
                              onChanged: (_) => themeService.toggle(),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.palette_outlined,
                                color: themeService.primaryColor),
                            title: const Text("App Theme"),
                            subtitle: Text(themeService.appTheme.label,
                                style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showThemePicker(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.text_fields_outlined),
                            title: const Text("Text Size"),
                            subtitle: Text(themeService.textScaleLabel,
                                style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showTextSizePicker(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.contrast),
                            title: const Text("High Contrast"),
                            subtitle: const Text(
                                "Black & white for maximum readability",
                                style: TextStyle(fontSize: 12)),
                            trailing: Switch(
                              value: themeService.highContrast,
                              onChanged: (v) async {
                                await themeService.setHighContrast(v);
                                if (mounted) setState(() {});
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.download_outlined),
                            title: const Text("Export to CSV"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _export,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.workspace_premium_outlined,
                                color: cs.primary),
                            title: const Text("Financial Health Certificate"),
                            subtitle: const Text(
                                "Share your FHS score as an image",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _showHealthCertificate,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.backup_outlined,
                                color: Theme.of(context).colorScheme.primary),
                            title: const Text("Backup Data"),
                            subtitle: const Text(
                                "Export backup file — save to phone, Drive, email, etc.",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _backupToDrive,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.restore_outlined,
                                color: Colors.green),
                            title: const Text("Restore from Backup"),
                            subtitle: const Text(
                                "Pick a backup .json file to restore from",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _restoreFromDrive,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.account_balance_outlined,
                                color: Colors.teal),
                            title: const Text("Import from Bank / GCash"),
                            subtitle: const Text(
                                "Paste GCash, BPI, BDO, Maya, or any bank history",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const BankImportScreen())),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.science_outlined),
                            title: const Text("Load Demo Data"),
                            subtitle: const Text(
                                "Fill app with sample data for demo",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _loadDemo,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.delete_forever_outlined,
                                color: Colors.red),
                            title: const Text("Reset All Data",
                                style: TextStyle(color: Colors.red)),
                            subtitle: const Text(
                                "Delete all expenses, budgets, goals & income",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right,
                                color: Colors.red),
                            onTap: _resetAllData,
                          ),
                          const Divider(height: 1),
                          // App Lock settings
                          FutureBuilder<bool>(
                            future: AppLockService.isEnabled(),
                            builder: (ctx, snap) {
                              final enabled = snap.data ?? false;
                              return ListTile(
                                leading: Icon(
                                  enabled
                                      ? Icons.lock_outline
                                      : Icons.lock_open_outlined,
                                  color: enabled ? cs.primary : null,
                                ),
                                title: const Text("App Lock"),
                                subtitle: Text(
                                  enabled
                                      ? "PIN + biometric lock active"
                                      : "Require PIN when reopening app",
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  final hasPin = await AppLockService.hasPin();
                                  if (!hasPin || !enabled) {
                                    // Set up PIN
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const PinSetupScreen()),
                                    );
                                    if (result == true && mounted) {
                                      setState(() {});
                                    }
                                  } else {
                                    // Toggle off — confirm first
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Disable App Lock"),
                                        content: const Text(
                                            "Remove PIN and disable app lock?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Cancel")),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white),
                                            child: const Text("Disable"),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await AppLockService.removePin();
                                      if (mounted) setState(() {});
                                    }
                                  }
                                },
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.emoji_events_outlined,
                                color: Colors.amber),
                            title: const Text("Achievements"),
                            subtitle: const Text(
                                "View your badges and progress",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AchievementsScreen())),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text("Replay Tutorial"),
                            subtitle: const Text("Show the feature tour again",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await FeatureTour.reset();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Tutorial reset — go to Home to see it"),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.bug_report_outlined,
                                color: Colors.grey),
                            title: const Text("Export Debug Log"),
                            subtitle: const Text(
                                "Share full data + chat log as .txt for QA",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              try {
                                await DebugService.exportDebugLog();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Export failed: ${e.toString().replaceAll('Exception: ', '')}"),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.category_outlined),
                            title: const Text("Manage Categories"),
                            subtitle: const Text(
                                "Add custom expense categories",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ManageCategoriesScreen())),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.rule_outlined,
                                color: Colors.deepPurple),
                            title: const Text("Auto-Categorization Rules"),
                            subtitle: const Text(
                                "Keyword → category rules for faster logging",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ManageRulesScreen())),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.today_outlined),
                            title: const Text("Daily Spending Limit"),
                            subtitle: const Text(
                                "Get notified when you hit your daily cap",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showDailyLimitDialog(),
                          ),
                          const Divider(height: 1),
                          // GM-8: Spending Challenge Mode
                          ListTile(
                            leading: const Icon(Icons.flag_outlined,
                                color: Colors.deepOrange),
                            title: const Text("Monthly Spending Challenge"),
                            subtitle: const Text(
                                "Set a personal spending target for this month",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showSpendingChallengeDialog(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.settings_outlined,
                                color: Colors.blueGrey),
                            title: const Text("App Settings"),
                            subtitle: const Text(
                                "Wallet auto-deduct, notifications, display",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showSettingsSheet(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text("Help & Guide"),
                            subtitle: const Text("How to use each feature",
                                style: TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HelpScreen())),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text("About Smart Spend"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AboutScreen())),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value,
      {Color? color}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? cs.primary)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }
}

// ── EDIT PROFILE SCREEN ───────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _middleName;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _birthdate;
  String _birthdateIso = '';
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.profile.firstName ?? '');
    _lastName = TextEditingController(text: widget.profile.lastName ?? '');
    _middleName = TextEditingController(text: widget.profile.middleName ?? '');
    _email = TextEditingController(text: widget.profile.email ?? '');
    _address = TextEditingController(text: widget.profile.address ?? '');
    _phone = TextEditingController(text: widget.profile.phone ?? '');
    _birthdateIso = widget.profile.birthdate ?? '';
    _birthdate = TextEditingController(
      text: _birthdateIso.isNotEmpty ? _formatBirthdate(_birthdateIso) : '',
    );
    _photoPath = widget.profile.photoUrl;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _middleName.dispose();
    _email.dispose();
    _address.dispose();
    _phone.dispose();
    _birthdate.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70, maxWidth: 400);
    if (photo != null) setState(() => _photoPath = photo.path);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate.text.isNotEmpty
          ? DateTime.tryParse(_isoFromDisplay(_birthdate.text)) ?? now
          : DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      // Store ISO internally but display human-readable
      _birthdateIso = picked.toIso8601String().substring(0, 10);
      _birthdate.text = _formatBirthdate(_birthdateIso);
    }
  }

  String _formatBirthdate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _isoFromDisplay(String display) {
    // If already ISO format, return as-is
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(display)) return display;
    return _birthdateIso;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.profile.copyWith(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      middleName: _middleName.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      birthdate: _birthdateIso.isNotEmpty ? _birthdateIso : null,
      photoUrl: _photoPath,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text("Save",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Photo picker
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: _photoPath != null
                        ? (_photoPath!.startsWith('https://')
                            ? NetworkImage(_photoPath!) as ImageProvider
                            : (File(_photoPath!).existsSync()
                                ? FileImage(File(_photoPath!)) as ImageProvider
                                : null))
                        : null,
                    child: _photoPath == null
                        ? const Icon(Icons.person,
                            size: 52, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text("Tap to change photo",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),

            _field(_firstName, "First Name", Icons.person_outline),
            const SizedBox(height: 14),
            _field(_middleName, "Middle Name / Initial", Icons.person_outline),
            const SizedBox(height: 14),
            _field(_lastName, "Last Name", Icons.person_outline),
            const SizedBox(height: 14),
            _field(_email, "Email", Icons.email_outlined,
                type: TextInputType.emailAddress),
            const SizedBox(height: 14),
            TextField(
              controller: _birthdate,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: "Birthdate",
                prefixIcon: const Icon(Icons.cake_outlined),
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            _field(_address, "Address", Icons.home_outlined, maxLines: 2),
            const SizedBox(height: 14),
            _field(_phone, "Phone Number (optional)", Icons.phone_outlined,
                type: TextInputType.phone),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("Save Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── SPARKLINE PAINTER (NI-5) ─────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final Color color;

  const _SparklinePainter(this.values, this.maxValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - (values[i] / maxValue * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}

// ── WALLETS SHEET ─────────────────────────────────────────────────────────────

class WalletsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> wallets;
  final VoidCallback onChanged;
  const WalletsSheet({required this.wallets, required this.onChanged});

  @override
  State<WalletsSheet> createState() => WalletsSheetState();
}

class WalletsSheetState extends State<WalletsSheet> {
  late List<Map<String, dynamic>> _wallets;

  static const _presets = [
    // ── CASH ──────────────────────────────────────────────────────────────────
    ('Cash on Hand', 'cash', '💵'),
    // ── E-WALLETS (BSP-supervised) ────────────────────────────────────────────
    ('GCash', 'ewallet', '📱'),
    ('Maya', 'ewallet', '💜'),
    ('GrabPay', 'ewallet', '🟢'),
    ('ShopeePay', 'ewallet', '🟠'),
    ('Coins.ph', 'ewallet', '🪙'),
    // ── ONLINE SHOPPING WALLETS ───────────────────────────────────────────────
    ('Lazada Wallet', 'ewallet', '🛒'),
    ('TikTok Shop Wallet', 'ewallet', '🎵'),
    // ── INTERNATIONAL / FREELANCE ─────────────────────────────────────────────
    ('PayPal', 'ewallet', '🅿️'),
    ('Wise', 'ewallet', '💸'),
    // ── DIGITAL BANKS (BSP-licensed) ──────────────────────────────────────────
    ('GoTyme Bank', 'bank', '🏦'),
    ('Tonik', 'bank', '🏦'),
    ('UNObank', 'bank', '🏦'),
    ('UnionDigital', 'bank', '🏦'),
    // ── UNIVERSAL / COMMERCIAL BANKS ──────────────────────────────────────────
    ('BDO', 'bank', '🏦'),
    ('BPI', 'bank', '🏦'),
    ('Metrobank', 'bank', '🏦'),
    ('Landbank', 'bank', '🏦'),
    ('PNB', 'bank', '🏦'),
    ('RCBC', 'bank', '🏦'),
    ('Security Bank', 'bank', '🏦'),
    ('Chinabank', 'bank', '🏦'),
    ('UnionBank', 'bank', '🏦'),
    ('EastWest Bank', 'bank', '🏦'),
    ('Seabank', 'bank', '🌊'),
    ('PSBank', 'bank', '🏦'),
    ('Maybank', 'bank', '🏦'),
    // ── REMITTANCE / PAWNSHOP ─────────────────────────────────────────────────
    ('Cebuana Lhuillier', 'remittance', '🏪'),
    ('M Lhuillier', 'remittance', '🏪'),
    ('Palawan Pawnshop', 'remittance', '🏪'),
    ('Western Union', 'remittance', '🏪'),
    ('LBC', 'remittance', '📦'),
    ('Tambunting', 'remittance', '🏪'),
    ('USSC', 'remittance', '🏪'),
  ];

  @override
  void initState() {
    super.initState();
    _wallets = List.from(widget.wallets);
  }

  Future<void> _editBalance(Map<String, dynamic> wallet) async {
    final ctrl = TextEditingController(
        text: (wallet['balance'] as num) > 0
            ? (wallet['balance'] as num).toStringAsFixed(2)
            : '');
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${wallet['icon']} ${wallet['name']}"),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Current balance",
            prefixText: "${CurrencyService.symbol} ",
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, double.tryParse(ctrl.text) ?? 0),
            child: const Text("Save"),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      await DBService.setWalletBalance(wallet['id'] as int, result);
      final updated = await DBService.getWallets();
      setState(() => _wallets = updated);
      widget.onChanged();
    }
  }

  Future<void> _addWallet(String name, String type, String icon) async {
    // Check if already exists
    final exists = _wallets
        .any((w) => (w['name'] as String).toLowerCase() == name.toLowerCase());
    if (exists) return;
    await DBService.insertWallet(
        {'name': name, 'type': type, 'balance': 0.0, 'icon': icon});
    final updated = await DBService.getWallets();
    if (mounted) setState(() => _wallets = updated);
    widget.onChanged();
  }

  Future<void> _deleteWallet(int id) async {
    await DBService.deleteWallet(id);
    final updated = await DBService.getWallets();
    if (mounted) setState(() => _wallets = updated);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = _wallets.fold<double>(0, (s, w) => s + (w['balance'] as num));

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("My Wallets",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Text("Tap a wallet to update its balance",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Total Liquid",
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                      Text(CurrencyService.format(total),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Existing wallets
                  ..._wallets.map((w) {
                    final bal = (w['balance'] as num).toDouble();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Text(w['icon'] as String? ?? '💵',
                            style: const TextStyle(fontSize: 24)),
                        title: Text(w['name'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                            bal > 0
                                ? CurrencyService.format(bal)
                                : "Tap to set balance",
                            style: TextStyle(
                                fontSize: 13,
                                color: bal > 0 ? cs.primary : Colors.grey,
                                fontWeight: bal > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _editBalance(w),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            // Don't allow deleting Cash on Hand or GCash (defaults)
                            if ((w['id'] as int) > 2)
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red[300]),
                                onPressed: () => _deleteWallet(w['id'] as int),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        onTap: () => _editBalance(w),
                      ),
                    );
                  }),

                  // Add preset wallets not yet added
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text("Add wallet",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presets
                        .where((p) => !_wallets.any((w) =>
                            (w['name'] as String).toLowerCase() ==
                            p.$1.toLowerCase()))
                        .map((p) => ActionChip(
                              avatar: Text(p.$3,
                                  style: const TextStyle(fontSize: 14)),
                              label: Text(p.$1,
                                  style: const TextStyle(fontSize: 12)),
                              onPressed: () => _addWallet(p.$1, p.$2, p.$3),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
