import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../services/db_service.dart';
import '../services/tax_service.dart';
import '../services/predict_service.dart';
import '../services/llm_service.dart';
import '../services/event_bus.dart';
import '../services/currency_service.dart';
import '../services/score_service.dart';
import '../widgets/info_button.dart';
import 'transactions_screen.dart';
import 'savings_goals_screen.dart';
import 'debt_screen.dart';
import 'recurring_screen.dart';
import 'budget_screen.dart';
import 'income_screen.dart';
import 'bank_import_screen.dart';
import 'profile_screen.dart' show WalletsSheet;
import 'bill_calendar_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Expense> _expenses = [];
  List<Expense> _thisMonthExpenses =
      []; // always current calendar month — used by 50/30/20, Wants vs Needs, Allowance Overview
  bool _loading = true;
  double _monthlyIncome = 0;
  String? _aiAdvice;
  bool _loadingAdvice = false;
  Map<String, double> _lastMonthCategoryTotals = {};
  int? _selectedCategoryIndex;
  String _incomeDialogTitle() {
    switch (_accountType) {
      case 'student':
        return 'Set Allowance';
      case 'unemployed':
        return 'Set Budget / Current Balance';
      case 'pensioner':
        return 'Set Pension';
      case 'freelancer':
        return 'Set Income';
      case 'general':
        return 'Set Income / Current Balance';
      default:
        return 'Set Monthly Income';
    }
  }

  String _accountType = 'employed';
  String _chartPeriod = 'all';
  DateTime? _customStart;
  DateTime? _customEnd;
  DateTime? _pickedMonth; // for 'pick_month' period
  int _paydayDate =
      1; // day of month payday falls on (1–28), loaded from settings
  Map<String, double> _cachedCategoryTotals = {};
  Map<String, double> _cachedMonthlyTotals = {};
  Map<String, double> _cachedDailyTotals = {};
  List<Map<String, dynamic>> _scoreHistory = [];
  List<Map<String, dynamic>> _currentComponents = [];
  StreamSubscription? _eventSub;

  List<dynamic> _glanceBudgets = []; // full budget list for category breakdown

  // CC-1: Custom category assignments for 50/30/20
  Set<String> _customNeedsCats = {};
  Set<String> _customWantsCats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _eventSub = AppEventBus.instance.stream.listen((event) {
      if (event == AppEvent.expenseChanged ||
          event == AppEvent.budgetChanged ||
          event == AppEvent.incomeChanged) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadData() async {
    final allExpenses = await DBService.getExpenses();
    final income = await DBService.getMonthlyIncome();
    final accountType =
        await DBService.getSetting('account_type') ?? 'employed';
    final paydayStr = await DBService.getSetting('payday_date');
    final paydayDate = int.tryParse(paydayStr ?? '1') ?? 1;

    // Filter by period
    final now = DateTime.now();
    final expenses = allExpenses.where((e) {
      try {
        final d = DateTime.parse(e.date);
        switch (_chartPeriod) {
          case 'weekly':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return d.isAfter(weekStart.subtract(const Duration(days: 1)));
          case 'monthly':
            return d.year == now.year && d.month == now.month;
          case 'last_month':
            final lm = DateTime(now.year, now.month - 1);
            return d.year == lm.year && d.month == lm.month;
          case 'pick_month':
            if (_pickedMonth != null) {
              return d.year == _pickedMonth!.year &&
                  d.month == _pickedMonth!.month;
            }
            return true;
          case 'yearly':
            return d.year == now.year;
          case 'payday_cycle':
            // Payday cycle: from paydayDate of last month to (paydayDate-1) of this month
            final cycleStart = now.day >= paydayDate
                ? DateTime(now.year, now.month, paydayDate)
                : DateTime(now.year, now.month - 1, paydayDate);
            final cycleEnd = DateTime(cycleStart.year, cycleStart.month + 1,
                paydayDate - 1 < 1 ? 1 : paydayDate - 1);
            return !d.isBefore(cycleStart) && !d.isAfter(cycleEnd);
          case 'custom':
            if (_customStart != null && _customEnd != null) {
              return !d.isBefore(_customStart!) &&
                  !d.isAfter(_customEnd!.add(const Duration(days: 1)));
            }
            return true;
          default:
            return true;
        }
      } catch (_) {
        return true;
      }
    }).toList();

    if (mounted) setState(() => _paydayDate = paydayDate);

    // CC-1: Load custom category assignments
    final customNeedsStr =
        await DBService.getSetting('custom_needs_cats') ?? '';
    final customWantsStr =
        await DBService.getSetting('custom_wants_cats') ?? '';
    if (mounted) {
      setState(() {
        _customNeedsCats =
            customNeedsStr.isNotEmpty ? customNeedsStr.split(',').toSet() : {};
        _customWantsCats =
            customWantsStr.isNotEmpty ? customWantsStr.split(',').toSet() : {};
      });
    }

    final catTotals = <String, double>{};
    for (final e in expenses) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }
    final monthTotals = <String, double>{};
    for (final e in expenses) {
      try {
        final date = DateTime.parse(e.date);
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
        monthTotals[key] = (monthTotals[key] ?? 0) + e.amount;
      } catch (_) {}
    }
    final sortedMonths = monthTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final last6 = Map.fromEntries(sortedMonths.take(6));

    // Daily totals for trend chart (last 30 days)
    final dailyTotals = <String, double>{};
    for (final e in allExpenses) {
      try {
        final d = DateTime.parse(e.date);
        if (now.difference(d).inDays <= 30) {
          dailyTotals[e.date.substring(0, 10)] =
              (dailyTotals[e.date.substring(0, 10)] ?? 0) + e.amount;
        }
      } catch (_) {}
    }

    setState(() {
      _expenses = expenses;
      // Always compute this-month expenses independently of period filter
      // Used by 50/30/20, Wants vs Needs, and Allowance Overview
      final currentMonthKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";
      _thisMonthExpenses =
          allExpenses.where((e) => e.date.startsWith(currentMonthKey)).toList();
      _monthlyIncome = income;
      _accountType = accountType;
      _cachedCategoryTotals = catTotals;
      _cachedMonthlyTotals = last6;
      _cachedDailyTotals = dailyTotals;
      _loading = false;
    });

    // Compute last-month category totals for D7 comparison
    final lastMonthKey =
        "${now.month == 1 ? now.year - 1 : now.year}-${now.month == 1 ? 12 : (now.month - 1).toString().padLeft(2, '0')}";
    final lastMonthExpenses =
        allExpenses.where((e) => e.date.startsWith(lastMonthKey)).toList();
    final lastMonthCats = <String, double>{};
    for (final e in lastMonthExpenses) {
      lastMonthCats[e.category] = (lastMonthCats[e.category] ?? 0) + e.amount;
    }
    if (mounted) setState(() => _lastMonthCategoryTotals = lastMonthCats);

    // Load score history separately (non-blocking)
    final scoreHistory = await DBService.getScoreHistory(days: 30);
    if (mounted) setState(() => _scoreHistory = scoreHistory);

    // Compute current FHS component breakdown for the component chart
    try {
      final budgets = await DBService.getBudgets();
      final now2 = DateTime.now();
      final currentMonth2 =
          "${now2.year}-${now2.month.toString().padLeft(2, '0')}";
      final thisMonthExp = allExpenses
          .where((e) => e.date.startsWith(currentMonth2))
          .map((e) => {
                'amount': e.amount,
                'category': e.category,
                'date': e.date,
              })
          .toList();
      final components = ScoreService.getBreakdown(
        thisMonthExp,
        budgets: budgets,
        monthlyIncome: income,
      );
      if (mounted) setState(() => _currentComponents = components);
    } catch (_) {}

    // Load budget list for category breakdown (non-blocking)
    try {
      final budgets = await DBService.getBudgets();
      if (mounted) setState(() => _glanceBudgets = budgets);
    } catch (_) {}
  }

  // Getters removed — using cached _cachedCategoryTotals and _cachedMonthlyTotals

  static const _sectionColors = [
    Color(0xFF0066FF),
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
  ];

  static const _monthNames = [
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
  ];

  /// Shows a dialog to set the payday date (1–28).
  Future<void> _showPaydaySetupDialog() async {
    int selected = _paydayDate.clamp(1, 28);
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text("Set Payday Date"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Which day of the month do you receive your salary or allowance?",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed:
                        selected > 1 ? () => setDialog(() => selected--) : null,
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      selected.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: selected < 28
                        ? () => setDialog(() => selected++)
                        : null,
                  ),
                ],
              ),
              Center(
                child: Text(
                  "Cycle: ${selected}th of each month",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await DBService.setSetting('payday_date', selected.toString());
                if (mounted) setState(() => _paydayDate = selected);
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a year + month picker dialog. Returns the selected DateTime (day=1)
  /// or null if the user cancelled.
  Future<DateTime?> _showMonthPicker(BuildContext context) async {
    final now = DateTime.now();
    int selectedYear = _pickedMonth?.year ?? now.year;
    int selectedMonth = _pickedMonth?.month ?? now.month;

    return showDialog<DateTime>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) {
          final months = [
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
            'Dec',
          ];
          return AlertDialog(
            title: const Text("Select Month"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setDialog(() => selectedYear--),
                    ),
                    Text(
                      '$selectedYear',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: selectedYear < now.year
                          ? () => setDialog(() => selectedYear++)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Month grid
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.6,
                  children: List.generate(12, (i) {
                    final isFuture = selectedYear == now.year && i >= now.month;
                    final isSelected = selectedMonth == i + 1;
                    return GestureDetector(
                      onTap: isFuture
                          ? null
                          : () => setDialog(() => selectedMonth = i + 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(ctx).colorScheme.primary
                              : isFuture
                                  ? Colors.grey.withValues(alpha: 0.08)
                                  : Theme.of(ctx)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            months[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(ctx).colorScheme.onPrimary
                                  : isFuture
                                      ? Colors.grey[400]
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(ctx, DateTime(selectedYear, selectedMonth)),
                child: const Text("Apply"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showIncomeDialog() {
    final controller =
        TextEditingController(text: _monthlyIncome.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_incomeDialogTitle()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: "${CurrencyService.symbol} ",
            hintText: "e.g. 30000",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() => _monthlyIncome = val);
                DBService.setMonthlyIncome(val);
                fireEvent(AppEvent.incomeChanged);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _getAIAdvice() async {
    setState(() {
      _loadingAdvice = true;
      _aiAdvice = null;
    });
    try {
      // Always use this month's expenses for advice — not the period filter
      final expenseList = _thisMonthExpenses
          .map((e) => {
                'amount': e.amount,
                'category': e.category,
                'date': e.date,
                'item_name': e.itemName
              })
          .toList();
      final predicted = PredictService.predictMonthly(expenseList);
      final advice = await LLMService.getFinancialAdvice(
        expenses: expenseList,
        monthlyIncome: _monthlyIncome,
        predictedNext: predicted,
      );
      if (mounted)
        setState(() {
          _aiAdvice = advice;
          _loadingAdvice = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _aiAdvice =
              "Could not get advice: ${e.toString().replaceAll('Exception: ', '')}";
          _loadingAdvice = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tax = TaxService.estimateTax(_monthlyIncome);
    final savings = TaxService.suggestedSavings(_monthlyIncome);
    final totals = _cachedCategoryTotals;
    final categories = totals.keys.toList();
    final monthly = _cachedMonthlyTotals;
    final expenseList = _expenses
        .map((e) => {
              'amount': e.amount,
              'category': e.category,
              'date': e.date,
              'item_name': e.itemName
            })
        .toList();
    final predicted =
        _expenses.isNotEmpty ? PredictService.predictMonthly(expenseList) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        actions: [
          const InfoButton(
            title: "Analytics",
            body:
                "Visualize your spending patterns with charts and comparisons.\n\n"
                "• Quick navigation chips — jump to Goals, Debts, Budgets, Recurring, Income, Import\n"
                "• Pie chart — spending by category (tap a slice to drill down)\n"
                "• Category Breakdown — per-category spending with amount, %, and budget progress\n"
                "• Bar chart — monthly spending trend\n"
                "• Daily trend — spending per day for the last 30 days\n"
                "• Day-of-week heatmap — which days you spend the most\n"
                "• Health Score chart — your score over the last 30 days\n"
                "• FHS Component Breakdown — each component with literacy tips\n"
                "• Small Purchases — how small frequent buys add up\n"
                "• Long-Range Forecast — 3/6/12-month projections\n"
                "• Period Comparison — compare any two months side by side\n"
                "• Mood & Spending — correlation between mood and spending\n"
                "• 50/30/20 Rule — compares your Needs/Wants/Savings to targets\n"
                "• Monthly Summary — AI writes a plain-English paragraph about your month\n"
                "• Market Insights — live PHP exchange rates + financial literacy tips\n"
                "• AI Financial Advice — personalized tips based on your spending\n\n"
                "Use the period filter chips at the top to change the time range.",
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: "All Transactions",
            onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TransactionsScreen()))
                .then((_) => _loadData()),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final p in [
                            ('all', 'All Time'),
                            ('weekly', 'This Week'),
                            ('monthly', 'This Month'),
                            ('last_month', 'Last Month'),
                            ('yearly', 'This Year'),
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(p.$2,
                                    style: const TextStyle(fontSize: 12)),
                                selected: _chartPeriod == p.$1,
                                onSelected: (_) => setState(() {
                                  _chartPeriod = p.$1;
                                  _loadData();
                                }),
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.15),
                                checkmarkColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          // Payday cycle chip — shows expenses from last payday to today
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                _chartPeriod == 'payday_cycle'
                                    ? 'Payday Cycle (${_paydayDate}th)'
                                    : 'Payday Cycle',
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: _chartPeriod == 'payday_cycle',
                              avatar:
                                  const Icon(Icons.payments_outlined, size: 14),
                              onSelected: (_) async {
                                if (_chartPeriod != 'payday_cycle') {
                                  // First use — prompt for payday date if not set
                                  if (_paydayDate == 1) {
                                    await _showPaydaySetupDialog();
                                  }
                                  setState(() => _chartPeriod = 'payday_cycle');
                                  _loadData();
                                } else {
                                  // Already selected — tap again to change payday date
                                  await _showPaydaySetupDialog();
                                  _loadData();
                                }
                              },
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15),
                              checkmarkColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          // Month picker chip — select any specific month/year
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                _chartPeriod == 'pick_month' &&
                                        _pickedMonth != null
                                    ? DateFormat('MMM yyyy')
                                        .format(_pickedMonth!)
                                    : 'Pick Month',
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: _chartPeriod == 'pick_month',
                              avatar:
                                  const Icon(Icons.calendar_month, size: 14),
                              onSelected: (_) async {
                                // Show year + month picker dialog
                                final picked = await _showMonthPicker(context);
                                if (picked != null) {
                                  setState(() {
                                    _pickedMonth = picked;
                                    _chartPeriod = 'pick_month';
                                  });
                                  _loadData();
                                }
                              },
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15),
                              checkmarkColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          // Custom date range picker
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                _chartPeriod == 'custom' &&
                                        _customStart != null &&
                                        _customEnd != null
                                    ? "${DateFormat('M/d').format(_customStart!)}–${DateFormat('M/d').format(_customEnd!)}"
                                    : "Custom Range",
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: _chartPeriod == 'custom',
                              avatar: const Icon(Icons.date_range, size: 14),
                              onSelected: (_) async {
                                final range = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  initialDateRange:
                                      _customStart != null && _customEnd != null
                                          ? DateTimeRange(
                                              start: _customStart!,
                                              end: _customEnd!)
                                          : null,
                                );
                                if (range != null) {
                                  setState(() {
                                    _customStart = range.start;
                                    _customEnd = range.end;
                                    _chartPeriod = 'custom';
                                  });
                                  _loadData();
                                }
                              },
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15),
                              checkmarkColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── QUICK NAVIGATION ─────────────────────────────────
                    // Compact row of tappable chips to jump to key features
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final item in [
                            (
                              Icons.savings_outlined,
                              'Goals',
                              Colors.green,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const SavingsGoalsScreen()))
                            ),
                            (
                              Icons.credit_card_outlined,
                              'Debts',
                              Colors.red,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const DebtScreen()))
                            ),
                            (
                              Icons.pie_chart_outline,
                              'Budgets',
                              Colors.purple,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const BudgetScreen()))
                            ),
                            (
                              Icons.repeat,
                              'Recurring',
                              Colors.orange,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RecurringScreen()))
                            ),
                            (
                              Icons.account_balance_wallet_outlined,
                              'Income',
                              Colors.blue,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const IncomeScreen()))
                            ),
                            (
                              Icons.account_balance_outlined,
                              'Import',
                              Colors.teal,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const BankImportScreen()))
                            ),
                            (
                              Icons.wallet_outlined,
                              'Wallets',
                              Colors.green,
                              () async {
                                final wallets = await DBService.getWallets();
                                if (!context.mounted) return;
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20))),
                                  builder: (_) => WalletsSheet(
                                    wallets: wallets,
                                    onChanged: () {},
                                  ),
                                );
                              }
                            ),
                            (
                              Icons.calendar_month_outlined,
                              'Calendar',
                              Colors.orange,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const BillCalendarScreen()))
                            ),
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: Icon(item.$1, size: 14, color: item.$3),
                                label: Text(item.$2,
                                    style: const TextStyle(fontSize: 12)),
                                onPressed: item.$4,
                                side: BorderSide(
                                    color: item.$3.withValues(alpha: 0.3)),
                                backgroundColor:
                                    item.$3.withValues(alpha: 0.07),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(Icons.bar_chart,
                                  size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(
                                _chartPeriod == 'weekly'
                                    ? "No expenses this week."
                                    : _chartPeriod == 'monthly'
                                        ? "No expenses this month."
                                        : _chartPeriod == 'last_month'
                                            ? "No expenses last month."
                                            : _chartPeriod == 'pick_month' &&
                                                    _pickedMonth != null
                                                ? "No expenses in ${DateFormat('MMMM yyyy').format(_pickedMonth!)}."
                                                : _chartPeriod == 'yearly'
                                                    ? "No expenses this year."
                                                    : _chartPeriod ==
                                                            'payday_cycle'
                                                        ? "No expenses in this payday cycle."
                                                        : "No data yet. Add some expenses first.",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // Pie Chart
                      const Text("Spending by Category",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: List.generate(categories.length, (i) {
                              final cat = categories[i];
                              final pct = totals[cat]! /
                                  totals.values.fold(0.0, (a, b) => a + b) *
                                  100;
                              return PieChartSectionData(
                                value: totals[cat],
                                title: "${pct.toStringAsFixed(0)}%",
                                color:
                                    _sectionColors[i % _sectionColors.length],
                                radius: 70,
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Legend — tappable for D9 drilldown
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: List.generate(categories.length, (i) {
                          final cat = categories[i];
                          final isSelected = _selectedCategoryIndex == i;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = isSelected ? null : i;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _sectionColors[i % _sectionColors.length]
                                        .withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? Border.all(
                                        color: _sectionColors[
                                            i % _sectionColors.length],
                                        width: 1)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _sectionColors[
                                          i % _sectionColors.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                      "$cat  ${CurrencyService.format(totals[cat]!)}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      // D9: Category drilldown — show transactions for selected category
                      if (_selectedCategoryIndex != null &&
                          _selectedCategoryIndex! < categories.length) ...[
                        const SizedBox(height: 12),
                        Builder(builder: (context) {
                          final cat = categories[_selectedCategoryIndex!];
                          final catExpenses = _expenses
                              .where((e) => e.category == cat)
                              .take(10)
                              .toList();
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 12, 14, 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("$cat transactions",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      GestureDetector(
                                        onTap: () => setState(() =>
                                            _selectedCategoryIndex = null),
                                        child:
                                            const Icon(Icons.close, size: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                ...catExpenses.map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(e.itemName,
                                                  style: const TextStyle(
                                                      fontSize: 13))),
                                          Text(e.date.substring(5),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[500])),
                                          const SizedBox(width: 8),
                                          Text(CurrencyService.format(e.amount),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    )),
                                if (catExpenses.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Text("No transactions",
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 16),

                      // ── CATEGORY BREAKDOWN TABLE ──────────────────────────
                      // Simple always-visible table: category, amount, % of total, budget status
                      if (categories.isNotEmpty) ...[
                        const Text("Category Breakdown",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Builder(builder: (context) {
                          final cs = Theme.of(context).colorScheme;
                          final budgets = _glanceBudgets;
                          final grandTotal =
                              totals.values.fold(0.0, (s, v) => s + v);
                          return Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: categories.asMap().entries.map((entry) {
                                final i = entry.key;
                                final cat = entry.value;
                                final catTotal = totals[cat] ?? 0;
                                final pct = grandTotal > 0
                                    ? catTotal / grandTotal * 100
                                    : 0.0;
                                final color =
                                    _sectionColors[i % _sectionColors.length];
                                // Budget for this category
                                double budgetAmt = 0.0;
                                try {
                                  final b = budgets
                                      .where(
                                          (b) => (b as dynamic).category == cat)
                                      .firstOrNull;
                                  if (b != null) {
                                    budgetAmt = (b as dynamic).amount as double;
                                  }
                                } catch (_) {}
                                final overBudget =
                                    budgetAmt > 0 && catTotal > budgetAmt;
                                final budgetRatio = budgetAmt > 0
                                    ? (catTotal / budgetAmt).clamp(0.0, 1.0)
                                    : 0.0;

                                return Column(
                                  children: [
                                    if (i > 0)
                                      Divider(
                                          height: 1,
                                          color: cs.outline
                                              .withValues(alpha: 0.15)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(cat,
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                              Text(
                                                "${pct.toStringAsFixed(1)}%",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: cs.onSurface
                                                        .withValues(
                                                            alpha: 0.5)),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                CurrencyService.format(
                                                    catTotal),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              if (budgetAmt > 0) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  overBudget ? "⚠️" : "✓",
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: overBudget
                                                          ? Colors.red
                                                          : Colors.green),
                                                ),
                                              ],
                                            ],
                                          ),
                                          // Budget progress bar
                                          if (budgetAmt > 0) ...[
                                            const SizedBox(height: 5),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              child: LinearProgressIndicator(
                                                value: budgetRatio,
                                                minHeight: 4,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                  overBudget
                                                      ? Colors.red
                                                      : budgetRatio >= 0.8
                                                          ? Colors.orange
                                                          : color,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                overBudget
                                                    ? "+${CurrencyService.format(catTotal - budgetAmt)} over"
                                                    : "${CurrencyService.format(budgetAmt - catTotal)} left of ${CurrencyService.format(budgetAmt)}",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: overBudget
                                                        ? Colors.red
                                                        : Colors.grey[500]),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],

                      const SizedBox(height: 8),

                      // D7: This month vs last month comparison by category
                      if (_chartPeriod == 'all' ||
                          _chartPeriod == 'monthly') ...[
                        Builder(builder: (context) {
                          final now = DateTime.now();
                          final thisMonthKey =
                              "${now.year}-${now.month.toString().padLeft(2, '0')}";
                          final thisMonthCats = <String, double>{};
                          for (final e in _expenses) {
                            if (e.date.startsWith(thisMonthKey)) {
                              thisMonthCats[e.category] =
                                  (thisMonthCats[e.category] ?? 0) + e.amount;
                            }
                          }
                          final allCats = {
                            ...thisMonthCats.keys,
                            ..._lastMonthCategoryTotals.keys
                          }.toList()
                            ..sort();
                          if (allCats.isEmpty ||
                              _lastMonthCategoryTotals.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("This Month vs Last Month",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      child: Row(
                                        children: [
                                          const Expanded(
                                              child: Text("Category",
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey))),
                                          SizedBox(
                                            width: 80,
                                            child: Text("This Month",
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: Text("Last Month",
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                          ),
                                          const SizedBox(width: 28),
                                        ],
                                      ),
                                    ),
                                    ...allCats.asMap().entries.map((entry) {
                                      final i = entry.key;
                                      final cat = entry.value;
                                      final thisAmt = thisMonthCats[cat] ?? 0.0;
                                      final lastAmt =
                                          _lastMonthCategoryTotals[cat] ?? 0.0;
                                      final diff = thisAmt - lastAmt;
                                      final up = diff > 0;
                                      return Column(
                                        children: [
                                          if (i > 0)
                                            Divider(
                                                height: 1,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline
                                                    .withValues(alpha: 0.15)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(cat,
                                                        style: const TextStyle(
                                                            fontSize: 13))),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    CurrencyService.format(
                                                        thisAmt),
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    CurrencyService.format(
                                                        lastAmt),
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[500]),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 28,
                                                  child: diff.abs() < 1
                                                      ? const SizedBox.shrink()
                                                      : Icon(
                                                          up
                                                              ? Icons
                                                                  .arrow_upward
                                                              : Icons
                                                                  .arrow_downward,
                                                          size: 14,
                                                          color: up
                                                              ? Colors.red
                                                              : Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }),
                      ],

                      // ── PERIOD COMPARISON TOOL ──────────────────────────
                      _PeriodComparisonWidget(allExpenses: _expenses),
                      const SizedBox(height: 8),

                      // Monthly Bar Chart
                      if (monthly.length >= 2) ...[
                        const Text("Monthly Spending",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        // D8: time-aware hint — how far through the month are we?
                        Builder(builder: (context) {
                          final now = DateTime.now();
                          final daysInMonth =
                              DateUtils.getDaysInMonth(now.year, now.month);
                          final daysPassed = now.day;
                          final pct = (daysPassed / daysInMonth * 100).round();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              "Day $daysPassed of $daysInMonth — $pct% of month elapsed",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                          );
                        }),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, _) {
                                      final keys = monthly.keys.toList();
                                      final idx = val.toInt();
                                      if (idx < 0 || idx >= keys.length)
                                        return const SizedBox();
                                      final parts = keys[idx].split('-');
                                      final month = int.tryParse(parts[1]) ?? 0;
                                      return Text(_monthNames[month],
                                          style: const TextStyle(fontSize: 10));
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(monthly.length, (i) {
                                final val = monthly.values.toList()[i];
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: val,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 18,
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Daily Spending Trend (last 30 days)
                      if (_cachedDailyTotals.length >= 3) ...[
                        const Text("Daily Spending (last 30 days)",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: Builder(builder: (ctx) {
                            final sorted = _cachedDailyTotals.entries.toList()
                              ..sort((a, b) => a.key.compareTo(b.key));
                            final maxVal = sorted.fold<double>(
                                0, (m, e) => e.value > m ? e.value : m);
                            return LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval:
                                      maxVal > 0 ? maxVal / 4 : 1,
                                  getDrawingHorizontalLine: (v) => FlLine(
                                    color: Theme.of(ctx)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.15),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: (sorted.length / 4)
                                          .ceilToDouble()
                                          .clamp(1, 999),
                                      getTitlesWidget: (val, _) {
                                        final idx = val.toInt();
                                        if (idx < 0 || idx >= sorted.length)
                                          return const SizedBox();
                                        try {
                                          final d =
                                              DateTime.parse(sorted[idx].key);
                                          return Text(
                                              DateFormat('M/d').format(d),
                                              style:
                                                  const TextStyle(fontSize: 9));
                                        } catch (_) {
                                          return const SizedBox();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                minY: 0,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                        sorted.length,
                                        (i) => FlSpot(
                                            i.toDouble(), sorted[i].value)),
                                    isCurved: true,
                                    color: Theme.of(ctx).colorScheme.primary,
                                    barWidth: 2.5,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, _, __, ___) =>
                                          FlDotCirclePainter(
                                        radius: 3,
                                        color:
                                            Theme.of(ctx).colorScheme.primary,
                                        strokeWidth: 0,
                                      ),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Day-of-week spending heatmap
                      Builder(builder: (context) {
                        if (_expenses.isEmpty) return const SizedBox.shrink();
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        final dayTotals = List<double>.filled(7, 0);
                        final dayCounts = List<int>.filled(7, 0);
                        for (final e in _expenses) {
                          try {
                            final d = DateTime.parse(e.date);
                            final idx = d.weekday - 1; // Mon=0 … Sun=6
                            dayTotals[idx] += e.amount;
                            dayCounts[idx]++;
                          } catch (_) {}
                        }
                        final dayAvgs = List<double>.generate(
                            7,
                            (i) => dayCounts[i] > 0
                                ? dayTotals[i] / dayCounts[i]
                                : 0);
                        final maxAvg = dayAvgs.reduce((a, b) => a > b ? a : b);
                        if (maxAvg == 0) return const SizedBox.shrink();
                        final cs = Theme.of(context).colorScheme;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Spending by Day of Week",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "Average daily spend — darker = higher",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: List.generate(7, (i) {
                                final avg = dayAvgs[i];
                                final intensity =
                                    maxAvg > 0 ? avg / maxAvg : 0.0;
                                final isHighest = avg == maxAvg && avg > 0;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: avg == 0
                                                ? cs.surfaceContainerHighest
                                                    .withValues(alpha: 0.3)
                                                : cs.primary.withValues(
                                                    alpha: 0.15 +
                                                        intensity * 0.75),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: isHighest
                                                ? Border.all(
                                                    color: cs.primary,
                                                    width: 1.5)
                                                : null,
                                          ),
                                          child: avg > 0
                                              ? Center(
                                                  child: Text(
                                                    CurrencyService.format(avg)
                                                        .replaceAll('₱', ''),
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: intensity > 0.5
                                                          ? cs.primary
                                                          : cs.onSurface
                                                              .withValues(
                                                                  alpha: 0.6),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(days[i],
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: isHighest
                                                    ? cs.primary
                                                    : Colors.grey[500],
                                                fontWeight: isHighest
                                                    ? FontWeight.bold
                                                    : FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }),

                      // Score History Line Chart
                      if (_scoreHistory.length >= 2) ...[
                        Row(
                          children: [
                            const Text("Health Score (30 days)",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            const InfoButton(
                              title: "Health Score History",
                              body:
                                  "Shows your Financial Health Score for each day over the last 30 days.\n\n"
                                  "🟢 Green dot = Good (80+)\n"
                                  "🟡 Orange dot = Fair (60–79)\n"
                                  "🔴 Red dot = Needs Attention (<60)\n\n"
                                  "Score drops are usually caused by: exceeding a budget, not logging for several days, or spending more than your income.",
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 20,
                                getDrawingHorizontalLine: (v) => FlLine(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.15),
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    interval: 20,
                                    getTitlesWidget: (val, _) => Text(
                                      val.toInt().toString(),
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, _) {
                                      final idx = val.toInt();
                                      if (idx < 0 ||
                                          idx >= _scoreHistory.length)
                                        return const SizedBox();
                                      if (_scoreHistory.length < 7) {
                                        if (idx != 0 &&
                                            idx != _scoreHistory.length - 1)
                                          return const SizedBox();
                                      } else {
                                        if (idx % 7 != 0)
                                          return const SizedBox();
                                      }
                                      try {
                                        final d = DateTime.parse(
                                            _scoreHistory[idx]['date']
                                                as String);
                                        return Text(DateFormat('M/d').format(d),
                                            style:
                                                const TextStyle(fontSize: 9));
                                      } catch (_) {
                                        return const SizedBox();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              minY: 0,
                              maxY: 100,
                              // Reference lines at 60 and 80
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(
                                    y: 80,
                                    color: Colors.green.withValues(alpha: 0.4),
                                    strokeWidth: 1,
                                    dashArray: [4, 4],
                                    label: HorizontalLineLabel(
                                      show: true,
                                      alignment: Alignment.topRight,
                                      style: const TextStyle(
                                          fontSize: 9, color: Colors.green),
                                      labelResolver: (_) => 'Good',
                                    ),
                                  ),
                                  HorizontalLine(
                                    y: 60,
                                    color: Colors.orange.withValues(alpha: 0.4),
                                    strokeWidth: 1,
                                    dashArray: [4, 4],
                                    label: HorizontalLineLabel(
                                      show: true,
                                      alignment: Alignment.topRight,
                                      style: const TextStyle(
                                          fontSize: 9, color: Colors.orange),
                                      labelResolver: (_) => 'Fair',
                                    ),
                                  ),
                                ],
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                      _scoreHistory.length,
                                      (i) => FlSpot(
                                          i.toDouble(),
                                          ((_scoreHistory[i]['score'] as num?)
                                                  ?.toDouble() ??
                                              0))),
                                  isCurved: true,
                                  color: Theme.of(context).colorScheme.primary,
                                  barWidth: 2.5,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, _, __, i) {
                                      final score = spot.y;
                                      final color = score >= 80
                                          ? Colors.green
                                          : score >= 60
                                              ? Colors.orange
                                              : Colors.red;
                                      // Only show dot on notable points
                                      final prevScore = i > 0
                                          ? ((_scoreHistory[i - 1]['score']
                                                      as num?)
                                                  ?.toDouble() ??
                                              0)
                                          : score;
                                      final isDrop = score < prevScore - 5;
                                      final isLow = score < 60;
                                      if (!isDrop &&
                                          !isLow &&
                                          i != 0 &&
                                          i != _scoreHistory.length - 1) {
                                        return FlDotCirclePainter(
                                            radius: 0,
                                            color: Colors.transparent,
                                            strokeWidth: 0);
                                      }
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: color,
                                        strokeWidth: 1.5,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.08),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Score annotation legend
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _scoreLegendDot(Colors.green, "Good (80+)"),
                              const SizedBox(width: 16),
                              _scoreLegendDot(Colors.orange, "Fair (60–79)"),
                              const SizedBox(width: 16),
                              _scoreLegendDot(Colors.red, "Low (<60)"),
                            ],
                          ),
                        ),
                        // SH-1: Score drop annotations
                        Builder(builder: (context) {
                          if (_scoreHistory.length < 3)
                            return const SizedBox.shrink();
                          // Find days where score dropped significantly (≥5 pts)
                          final drops = <Map<String, dynamic>>[];
                          for (int i = 1; i < _scoreHistory.length; i++) {
                            final prev =
                                (_scoreHistory[i - 1]['score'] as num).toInt();
                            final curr =
                                (_scoreHistory[i]['score'] as num).toInt();
                            if (prev - curr >= 5) {
                              String reason = '';
                              if (curr < 60)
                                reason = 'Score dropped to Needs Attention';
                              else if (prev >= 80 && curr < 80)
                                reason = 'Dropped below Good';
                              else
                                reason = '−${prev - curr} pts drop';
                              drops.add({
                                'date': _scoreHistory[i]['date'],
                                'score': curr,
                                'prev': prev,
                                'reason': reason,
                              });
                            }
                          }
                          if (drops.isEmpty) return const SizedBox(height: 8);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Notable drops",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              ...drops.take(3).map((d) {
                                String dateLabel = '';
                                try {
                                  dateLabel = DateFormat('MMM d').format(
                                      DateTime.parse(d['date'] as String));
                                } catch (_) {}
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_downward,
                                          size: 12, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                          "$dateLabel: ${d['score']}/100 — ${d['reason']}",
                                          style: const TextStyle(
                                              fontSize: 11, color: Colors.red)),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                            ],
                          );
                        }),
                        const SizedBox(height: 8),
                      ],

                      // FHS Component Breakdown card
                      if (_currentComponents.isNotEmpty) ...[
                        Row(
                          children: [
                            const Text("Score Components (This Month)",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            const InfoButton(
                              title: "FHS Component Breakdown",
                              body:
                                  "Your Financial Health Score is made up of 4 equal components (25 pts each):\n\n"
                                  "1️⃣ Savings Rate — saving ≥20% of income?\n"
                                  "2️⃣ Overspend Control — days within daily budget?\n"
                                  "3️⃣ Budget Adherence — % of budgets on track?\n"
                                  "4️⃣ Logging Consistency — logging regularly?\n\n"
                                  "Each bar shows how many points you earned out of 25.",
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: _currentComponents.map((item) {
                              final pts = (item['points'] as int).clamp(0, 25);
                              final ratio = pts / 25.0;
                              final barColor = pts >= 20
                                  ? Colors.green
                                  : pts >= 12
                                      ? Colors.orange
                                      : Colors.red;
                              // Contextual literacy tip for low-scoring components
                              final component =
                                  item['component'] as String? ?? '';
                              String? tip;
                              if (pts < 12) {
                                switch (component) {
                                  case 'savings_rate':
                                    tip =
                                        '💡 The 20% rule: aim to save at least 20% of your income each month. Even ₱100/day adds up to ₱3,000/month.';
                                    break;
                                  case 'overspend_control':
                                    tip =
                                        '💡 Try the envelope method: divide your daily budget into mental "envelopes" per category. Once a category is empty, stop spending there for the day.';
                                    break;
                                  case 'budget_adherence':
                                    tip =
                                        '💡 Budgets work best when they\'re realistic. If you consistently exceed a category, consider raising the limit slightly rather than ignoring it.';
                                    break;
                                  case 'logging_consistency':
                                    tip =
                                        '💡 Logging daily — even just one entry — builds financial awareness. Studies show people who track spending save 15–20% more than those who don\'t.';
                                    break;
                                }
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['reason'] as String,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Text(
                                          "$pts / 25",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: barColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: ratio,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            AlwaysStoppedAnimation(barColor),
                                      ),
                                    ),
                                    // Literacy tip for low-scoring components
                                    if (tip != null) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withValues(alpha: 0.07),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.blue
                                                  .withValues(alpha: 0.2)),
                                        ),
                                        child: Text(
                                          tip,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue[700],
                                              height: 1.5),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Prediction card
                      if (predicted > 0) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.trending_up,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Projected Next Month",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiaryContainer)),
                                  Text(CurrencyService.format(predicted),
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiaryContainer)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],

                    // Micro-expense clustering card
                    Builder(builder: (context) {
                      // Find small frequent purchases (≤₱200, appearing 3+ times)
                      final freqMap = <String, Map<String, dynamic>>{};
                      for (final e in _expenses) {
                        if (e.amount > 200) continue;
                        final key = e.itemName.toLowerCase().trim();
                        if (!freqMap.containsKey(key)) {
                          freqMap[key] = {
                            'name': e.itemName,
                            'total': 0.0,
                            'count': 0,
                            'amount': e.amount,
                          };
                        }
                        freqMap[key]!['total'] =
                            (freqMap[key]!['total'] as double) + e.amount;
                        freqMap[key]!['count'] =
                            (freqMap[key]!['count'] as int) + 1;
                      }
                      final clusters = freqMap.values
                          .where((v) => (v['count'] as int) >= 3)
                          .toList()
                        ..sort((a, b) => (b['total'] as double)
                            .compareTo(a['total'] as double));
                      if (clusters.isEmpty) return const SizedBox.shrink();

                      final totalSmall = clusters.fold<double>(
                          0, (s, v) => s + (v['total'] as double));
                      final cs = Theme.of(context).colorScheme;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Small Purchases Add Up",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "Frequent small expenses — individually invisible, collectively significant",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ...clusters.take(4).map((c) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c['name'] as String,
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          Text(
                                            "${c['count']}× · ${CurrencyService.format(c['total'] as double)}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 12),
                                Row(
                                  children: [
                                    const Text("Total small purchases",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyService.format(totalSmall),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${CurrencyService.format(totalSmall * 12)}/year",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // PM-1: Payment method breakdown
                    Builder(builder: (context) {
                      if (_expenses.isEmpty) return const SizedBox.shrink();
                      final pmTotals = <String, double>{};
                      for (final e in _expenses) {
                        final pm = e.paymentMethod ?? 'Cash';
                        pmTotals[pm] = (pmTotals[pm] ?? 0) + e.amount;
                      }
                      if (pmTotals.length < 2) return const SizedBox.shrink();
                      final total = pmTotals.values.fold(0.0, (s, v) => s + v);
                      final sorted = pmTotals.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      final pmColors = [
                        Colors.blue,
                        Colors.orange,
                        Colors.green,
                        Colors.purple
                      ];
                      final cs = Theme.of(context).colorScheme;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("By Payment Method",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: sorted.asMap().entries.map((entry) {
                                final i = entry.key;
                                final pm = entry.value;
                                final pct = total > 0 ? pm.value / total : 0.0;
                                final color = pmColors[i % pmColors.length];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(pm.key,
                                              style: const TextStyle(
                                                  fontSize: 13))),
                                      Text("${(pct * 100).toStringAsFixed(0)}%",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500])),
                                      const SizedBox(width: 8),
                                      Text(CurrencyService.format(pm.value),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // SM-1: Top merchants
                    Builder(builder: (context) {
                      if (_expenses.isEmpty) return const SizedBox.shrink();
                      final merchantMap = <String, Map<String, dynamic>>{};
                      for (final e in _expenses) {
                        final shop = e.shopName;
                        if (shop == null || shop.isEmpty) continue;
                        if (!merchantMap.containsKey(shop)) {
                          merchantMap[shop] = {'total': 0.0, 'count': 0};
                        }
                        merchantMap[shop]!['total'] =
                            (merchantMap[shop]!['total'] as double) + e.amount;
                        merchantMap[shop]!['count'] =
                            (merchantMap[shop]!['count'] as int) + 1;
                      }
                      if (merchantMap.isEmpty) return const SizedBox.shrink();
                      final sorted = merchantMap.entries.toList()
                        ..sort((a, b) => (b.value['total'] as double)
                            .compareTo(a.value['total'] as double));
                      final top5 = sorted.take(5).toList();
                      final cs = Theme.of(context).colorScheme;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Top Merchants",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: top5.asMap().entries.map((entry) {
                                final i = entry.key;
                                final m = entry.value;
                                return Column(
                                  children: [
                                    if (i > 0)
                                      Divider(
                                          height: 1,
                                          color: cs.outline
                                              .withValues(alpha: 0.15)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: cs.primary
                                                .withValues(alpha: 0.1),
                                            child: Text(m.key[0].toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: cs.primary,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                              child: Text(m.key,
                                                  style: const TextStyle(
                                                      fontSize: 13))),
                                          Text("${m.value['count']}×",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500])),
                                          const SizedBox(width: 8),
                                          Text(
                                              CurrencyService.format(
                                                  m.value['total'] as double),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // Long-range forecast (3 / 6 / 12 months)
                    Builder(builder: (context) {
                      final longRange =
                          PredictService.predictLongRange(expenseList);
                      if (longRange.isEmpty) return const SizedBox.shrink();
                      final cs = Theme.of(context).colorScheme;

                      // Check if last month had a large one-time expense
                      // that may be inflating the forecast baseline
                      final now = DateTime.now();
                      final lastMonthKey =
                          "${now.month == 1 ? now.year - 1 : now.year}-${(now.month == 1 ? 12 : now.month - 1).toString().padLeft(2, '0')}";
                      final lastMonthTotal = _expenses
                          .where((e) => e.date.startsWith(lastMonthKey))
                          .fold<double>(0, (s, e) => s + e.amount);
                      final lastMonthMax = _expenses
                          .where((e) => e.date.startsWith(lastMonthKey))
                          .fold<double>(
                              0, (s, e) => e.amount > s ? e.amount : s);
                      // Show disclaimer if a single expense was >40% of last month's total
                      final showDisclaimer = lastMonthTotal > 0 &&
                          lastMonthMax / lastMonthTotal > 0.4;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Long-Range Forecast",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "Projected cumulative spending at current pace",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                          if (showDisclaimer) ...[
                            const SizedBox(height: 4),
                            Text(
                              "⚠️ Last month had a large one-time expense — this may inflate the projection.",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.orange[700]),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [3, 6, 12].map((months) {
                              final amt = longRange[months] ?? 0;
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: months < 12 ? 8 : 0),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            cs.outline.withValues(alpha: 0.15)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$months mo",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyService.format(amt),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // 50/30/20 Rule Tracker
                    _build503020Card(context),
                    const SizedBox(height: 16),

                    // Want vs Need breakdown (#9)
                    _buildWantNeedCard(context),
                    const SizedBox(height: 16),

                    // Debt-to-Income Ratio
                    _buildDebtToIncomeCard(context),
                    const SizedBox(height: 16),

                    // Emergency Fund Calculator
                    _buildEmergencyFundCard(context),
                    const SizedBox(height: 16),

                    // Tax & Savings Card — for employed/business/working_student/freelancer
                    if (_accountType != 'student' &&
                        _accountType != 'unemployed' &&
                        _accountType != 'pensioner' &&
                        _accountType != 'general')
                      GestureDetector(
                        onTap: _showIncomeDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Tax & Savings Estimate (PH)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer)),
                                  Icon(Icons.edit,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                          .withValues(alpha: 0.5)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  "Income: ${CurrencyService.format(_monthlyIncome)}/mo  (tap to change)",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                          .withValues(alpha: 0.7),
                                      fontSize: 12)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Est. Tax",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer
                                                    .withValues(alpha: 0.7),
                                                fontSize: 12)),
                                        Text(CurrencyService.format(tax),
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Suggested Savings",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer
                                                    .withValues(alpha: 0.7),
                                                fontSize: 12)),
                                        Text(CurrencyService.format(savings),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                  "⚠️ Estimation only — not official tax advice.",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                          .withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                      ),

                    // Overview Card — for student/unemployed/pensioner/general
                    if (_accountType == 'student' ||
                        _accountType == 'unemployed' ||
                        _accountType == 'pensioner' ||
                        _accountType == 'general')
                      GestureDetector(
                        onTap: _showIncomeDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _accountType == 'student'
                                        ? "Allowance Overview"
                                        : _accountType == 'pensioner'
                                            ? "Pension Overview"
                                            : "Budget Overview",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                                  ),
                                  Icon(Icons.edit,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                          .withValues(alpha: 0.5)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${_accountType == 'student' ? 'Allowance' : _accountType == 'pensioner' ? 'Pension' : 'Budget'}: ${CurrencyService.format(_monthlyIncome)}/mo  (tap to change)",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer
                                        .withValues(alpha: 0.7),
                                    fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Spent",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer
                                                    .withValues(alpha: 0.7),
                                                fontSize: 12)),
                                        Text(
                                          CurrencyService.format(
                                              _thisMonthExpenses.fold<double>(
                                                  0, (s, e) => s + e.amount)),
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Remaining",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer
                                                    .withValues(alpha: 0.7),
                                                fontSize: 12)),
                                        Text(
                                          CurrencyService.format(
                                              (_monthlyIncome -
                                                      _thisMonthExpenses
                                                          .fold<double>(
                                                              0,
                                                              (s, e) =>
                                                                  s + e.amount))
                                                  .clamp(0, double.infinity)),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Mood-spend correlation card
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: DBService.getMoodHistory(days: 30),
                      builder: (context, snap) {
                        final moodHistory = snap.data ?? [];
                        if (moodHistory.length < 5) {
                          return const SizedBox.shrink();
                        }
                        // Compute average spend on low-mood days (1–2) vs high-mood (4–5)
                        final allExp = _expenses;
                        final expByDate = <String, double>{};
                        for (final e in allExp) {
                          expByDate[e.date.substring(0, 10)] =
                              (expByDate[e.date.substring(0, 10)] ?? 0) +
                                  e.amount;
                        }
                        double lowMoodSpend = 0;
                        int lowMoodDays = 0;
                        double highMoodSpend = 0;
                        int highMoodDays = 0;
                        for (final m in moodHistory) {
                          final date = m['date'] as String;
                          final score = m['mood_score'] as int;
                          final spend = expByDate[date] ?? 0;
                          if (score <= 2) {
                            lowMoodSpend += spend;
                            lowMoodDays++;
                          } else if (score >= 4) {
                            highMoodSpend += spend;
                            highMoodDays++;
                          }
                        }
                        if (lowMoodDays == 0 || highMoodDays == 0) {
                          return const SizedBox.shrink();
                        }
                        final avgLow = lowMoodSpend / lowMoodDays;
                        final avgHigh = highMoodSpend / highMoodDays;
                        final diff = avgLow - avgHigh;
                        if (diff.abs() < 50) return const SizedBox.shrink();
                        final cs = Theme.of(context).colorScheme;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Mood & Spending",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text("😞 Low mood days",
                                          style: TextStyle(fontSize: 13)),
                                      const Spacer(),
                                      Text(
                                        CurrencyService.format(avgLow) + " avg",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: diff > 0
                                                ? Colors.red
                                                : Colors.green),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Text("😄 High mood days",
                                          style: TextStyle(fontSize: 13)),
                                      const Spacer(),
                                      Text(
                                        CurrencyService.format(avgHigh) +
                                            " avg",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    diff > 0
                                        ? "You spend ${CurrencyService.format(diff)} more on low-mood days. Consider a spending pause when you're feeling down."
                                        : "You actually spend less on low-mood days — good self-control!",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            cs.onSurface.withValues(alpha: 0.6),
                                        height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    // Monthly plain-English summary — always uses this month's data
                    if (_thisMonthExpenses.isNotEmpty)
                      _MonthlySummaryCard(
                        expenses: _thisMonthExpenses
                            .map((e) => {
                                  'amount': e.amount,
                                  'category': e.category,
                                  'date': e.date,
                                  'item_name': e.itemName,
                                })
                            .toList(),
                        monthlyIncome: _monthlyIncome,
                        chartPeriod: 'monthly',
                        pickedMonth: null,
                      ),

                    // Market Insights — live PHP exchange rates + financial literacy
                    const _MarketInsightsCard(),
                    const SizedBox(height: 16),

                    // AI Financial Advice
                    if (_loadingAdvice || _aiAdvice != null)
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 16),
                                    const SizedBox(width: 6),
                                    const Text("AI Financial Advice",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text("Refresh"),
                                  onPressed: _loadingAdvice || _expenses.isEmpty
                                      ? null
                                      : _getAIAdvice,
                                ),
                              ],
                            ),
                            if (_loadingAdvice) ...[
                              const SizedBox(height: 10),
                              const Row(children: [
                                SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                                SizedBox(width: 8),
                                Text("Analyzing your finances...",
                                    style: TextStyle(color: Colors.grey)),
                              ]),
                            ] else if (_aiAdvice != null) ...[
                              const SizedBox(height: 10),
                              GestureDetector(
                                onLongPress: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _aiAdvice!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Advice copied ✓"),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: MarkdownBody(
                                  data: _aiAdvice!,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(height: 1.5),
                                    strong: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    listBullet: const TextStyle(height: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text("Get AI Financial Advice"),
                          onPressed: _expenses.isEmpty ? null : _getAIAdvice,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _build503020Card(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_monthlyIncome <= 0) return const SizedBox.shrink();

    // ALWAYS uses this month's data — independent of period filter chip
    // BT-3 note: 50/30/20 is a monthly budgeting rule, not a period analysis tool
    final needsCategories = {
      'Food',
      'Transportation',
      'Bills',
      'Health',
      ..._customNeedsCats
    };
    final wantsCategories = {
      'Shopping',
      'Entertainment',
      'Education',
      'Others',
      ..._customWantsCats,
    };

    double needs = 0, wants = 0;
    for (final e in _thisMonthExpenses) {
      if (needsCategories.contains(e.category)) {
        needs += e.amount;
      } else if (wantsCategories.contains(e.category)) {
        wants += e.amount;
      }
    }
    // Savings = income not spent
    final totalSpent = needs + wants;
    final savings = (_monthlyIncome - totalSpent).clamp(0.0, _monthlyIncome);

    final needsPct = needs / _monthlyIncome * 100;
    final wantsPct = wants / _monthlyIncome * 100;
    final savingsPct = savings / _monthlyIncome * 100;

    Color _ruleColor(double actual, double target) {
      if (actual <= target) return Colors.green;
      if (actual <= target * 1.2) return Colors.orange;
      return Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("50/30/20 Rule",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("50/30/20 Rule"),
                    content: const Text("A popular budgeting guideline:\n\n"
                        "• 50% on Needs — essentials like food, transport, bills, health\n"
                        "• 30% on Wants — shopping, entertainment, others\n"
                        "• 20% on Savings — money left unspent\n\n"
                        "Green = on track, Orange = slightly over, Red = over budget."),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Got it")),
                    ],
                  ),
                ),
                child:
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              "This month vs ₱${_monthlyIncome.toStringAsFixed(0)}/mo income (always monthly)",
              style: TextStyle(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 14),
          _ruleRow("Needs (50%)", needs, _monthlyIncome * 0.5, needsPct,
              _ruleColor(needsPct, 50), cs),
          const SizedBox(height: 10),
          _ruleRow("Wants (30%)", wants, _monthlyIncome * 0.3, wantsPct,
              _ruleColor(wantsPct, 30), cs),
          const SizedBox(height: 10),
          _ruleRow("Savings (20%)", savings, _monthlyIncome * 0.2, savingsPct,
              Colors.green, cs,
              isSavings: true),
          const SizedBox(height: 12),
          // Verdict line
          Builder(builder: (ctx) {
            final needsOver = needsPct > 50;
            final wantsOver = wantsPct > 30;
            final savingsOk = savingsPct >= 20;
            if (!needsOver && !wantsOver && savingsOk) {
              return Row(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 14),
                const SizedBox(width: 6),
                const Text("On track ✓ — great balance this month!",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500)),
              ]);
            }
            final issues = <String>[];
            if (needsOver)
              issues.add(
                  "Needs over by ${CurrencyService.format(needs - _monthlyIncome * 0.5)}");
            if (wantsOver)
              issues.add(
                  "Wants over by ${CurrencyService.format(wants - _monthlyIncome * 0.3)}");
            if (!savingsOk) issues.add("Savings below 20% target");
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 14),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(issues.join(" · "),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.orange))),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _scoreLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDebtToIncomeCard(BuildContext context) {
    if (_monthlyIncome <= 0) return const SizedBox.shrink();
    // Calculate total monthly debt obligations
    double monthlyDebtPayments = 0;
    // Estimate from Bills category expenses this month
    final debtExpenses = _thisMonthExpenses
        .where((e) => e.category == 'Bills')
        .fold<double>(0, (s, e) => s + e.amount);
    monthlyDebtPayments = debtExpenses;

    final dtiRatio = monthlyDebtPayments / _monthlyIncome;
    final dtiPct = (dtiRatio * 100).clamp(0, 200);
    final isHealthy = dtiPct <= 30;
    final isWarning = dtiPct > 30 && dtiPct <= 50;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Debt-to-Income Ratio",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Debt-to-Income Ratio"),
                    content: const Text(
                        "BSP recommends keeping your DTI below 30%.\n\n"
                        "• ≤30% — Healthy: you can comfortably manage debt\n"
                        "• 31-50% — Warning: debt is becoming a burden\n"
                        "• >50% — Critical: seek debt restructuring\n\n"
                        "Calculated as: Monthly debt payments ÷ Monthly income × 100"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Got it"))
                    ],
                  ),
                ),
                child: Icon(Icons.info_outline,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text("${dtiPct.toStringAsFixed(1)}%",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isHealthy
                          ? Colors.green
                          : isWarning
                              ? Colors.orange
                              : Colors.red)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isHealthy
                      ? "Healthy — within BSP recommended limit"
                      : isWarning
                          ? "Warning — debt is becoming a burden"
                          : "Critical — consider debt restructuring",
                  style: TextStyle(
                      fontSize: 12,
                      color: isHealthy
                          ? Colors.green
                          : isWarning
                              ? Colors.orange
                              : Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (dtiPct / 100).clamp(0, 1),
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              color: isHealthy
                  ? Colors.green
                  : isWarning
                      ? Colors.orange
                      : Colors.red,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
              "Bills this month: ${CurrencyService.format(monthlyDebtPayments)} / Income: ${CurrencyService.format(_monthlyIncome)}",
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmergencyFundCard(BuildContext context) {
    // Calculate average monthly spending from last 3 months
    // Excludes large one-time Want purchases (>3x category average) to avoid inflation
    final now = DateTime.now();
    double totalSpent3Mo = 0;
    int monthsCounted = 0;
    int excludedCount = 0;

    // First pass: compute category averages to identify outliers
    final catAmounts = <String, List<double>>{};
    for (final e in _expenses) {
      catAmounts.putIfAbsent(e.category, () => []).add(e.amount);
    }
    final catAvg = <String, double>{};
    catAmounts.forEach((cat, amounts) {
      catAvg[cat] = amounts.reduce((a, b) => a + b) / amounts.length;
    });

    for (int i = 0; i < 3; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = "${month.year}-${month.month.toString().padLeft(2, '0')}";
      final monthExpenses = _expenses.where((e) {
        try {
          return e.date.startsWith(key);
        } catch (_) {
          return false;
        }
      }).toList();
      if (monthExpenses.isNotEmpty) {
        double monthTotal = 0;
        for (final e in monthExpenses) {
          final avg = catAvg[e.category] ?? e.amount;
          // Exclude if: tagged as Want AND amount is 3x+ the category average AND > ₱1,000
          final isLargeOneTime =
              (e.isWant == true) && (e.amount > avg * 3) && (e.amount > 1000);
          if (isLargeOneTime) {
            excludedCount++;
          } else {
            monthTotal += e.amount;
          }
        }
        totalSpent3Mo += monthTotal;
        monthsCounted++;
      }
    }
    if (monthsCounted == 0) return const SizedBox.shrink();

    final avgMonthly = totalSpent3Mo / monthsCounted;
    final target3Mo = avgMonthly * 3;
    final target6Mo = avgMonthly * 6;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 18, color: Colors.teal),
              const SizedBox(width: 8),
              const Text("Emergency Fund Calculator",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              "Based on avg monthly essentials: ${CurrencyService.format(avgMonthly)}"
              "${excludedCount > 0 ? ' ($excludedCount large one-time purchases excluded)' : ''}",
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          _efRow("3-Month Fund (minimum)", target3Mo, Colors.teal),
          const SizedBox(height: 6),
          _efRow("6-Month Fund (recommended)", target6Mo, Colors.teal.shade700),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "💡 An emergency fund covers 3-6 months of expenses if you lose income. "
              "Keep it in a high-yield savings account (GoTyme 5%, Tonik 4%, Maya 3.5%) for easy access.",
              style:
                  TextStyle(fontSize: 11, color: Colors.grey[700], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _efRow(String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(CurrencyService.format(amount),
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  Widget _buildWantNeedCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // ALWAYS uses this month's data — independent of period filter chip
    final expenses = _thisMonthExpenses;
    if (expenses.isEmpty) return const SizedBox.shrink();

    double wants = 0;
    double needs = 0;
    for (final e in expenses) {
      if (e.isWant == true) {
        wants += e.amount;
      } else {
        needs += e.amount;
      }
    }
    final total = wants + needs;
    if (total <= 0) return const SizedBox.shrink();

    // If no expenses are tagged as Want yet, show a compact prompt instead
    // of a full card with a 100% blue bar — avoids the "blank gray box" look
    if (wants == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: cs.outline.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.label_outline,
                size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Tag expenses as Want or Need when logging to see your Wants vs Needs breakdown here.",
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );
    }

    final wantsPct = wants / total * 100;
    final needsPct = needs / total * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Wants vs Needs",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 6),
              Tooltip(
                message:
                    "Tag expenses as Want or Need when logging them.\nHelps you see discretionary vs essential spending.",
                child: Icon(Icons.info_outline,
                    size: 14, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                if (needsPct > 0)
                  Expanded(
                    flex: needsPct.round(),
                    child: Container(
                      height: 14,
                      color: cs.primary,
                    ),
                  ),
                if (wantsPct > 0)
                  Expanded(
                    flex: wantsPct.round(),
                    child: Container(
                      height: 14,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _wantNeedLegend("Needs", needs, needsPct, cs.primary),
              const SizedBox(width: 20),
              _wantNeedLegend("Wants", wants, wantsPct, Colors.orange),
            ],
          ),
          if (wants == 0 && needs > 0)
            const SizedBox.shrink(), // handled above — never reached
        ],
      ),
    );
  }

  Widget _wantNeedLegend(String label, double amount, double pct, Color color) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(
          "$label: ${CurrencyService.format(amount)} (${pct.toStringAsFixed(1)}%)",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _ruleRow(String label, double actual, double target, double pct,
      Color color, ColorScheme cs,
      {bool isSavings = false}) {
    final progress = (actual / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(
                "${CurrencyService.format(actual)} / ${CurrencyService.format(target)}  (${pct.toStringAsFixed(1)}%)",
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: isSavings ? (pct / 20).clamp(0.0, 1.0) : progress,
            backgroundColor: cs.outline.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}

// ── PERIOD COMPARISON TOOL ────────────────────────────────────────────────────
/// Lets the user pick any two months and compare spending side by side.
/// Shows total, per-category breakdown, and % change between the two periods.
class _PeriodComparisonWidget extends StatefulWidget {
  final List<Expense> allExpenses;
  const _PeriodComparisonWidget({required this.allExpenses});

  @override
  State<_PeriodComparisonWidget> createState() =>
      _PeriodComparisonWidgetState();
}

class _PeriodComparisonWidgetState extends State<_PeriodComparisonWidget> {
  bool _expanded = false;
  DateTime _periodA = DateTime(DateTime.now().year, DateTime.now().month - 1);
  DateTime _periodB = DateTime(DateTime.now().year, DateTime.now().month);

  Map<String, double> _totalsFor(DateTime month) {
    final key = "${month.year}-${month.month.toString().padLeft(2, '0')}";
    final result = <String, double>{};
    for (final e in widget.allExpenses) {
      if (e.date.startsWith(key)) {
        result[e.category] = (result[e.category] ?? 0) + e.amount;
      }
    }
    return result;
  }

  Future<DateTime?> _pickMonth(BuildContext context, DateTime current) async {
    final now = DateTime.now();
    int selectedYear = current.year;
    int selectedMonth = current.month;
    const months = [
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
      'Dec',
    ];

    return showDialog<DateTime>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text("Select Month"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setDialog(() => selectedYear--),
                  ),
                  Text('$selectedYear',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: selectedYear < now.year
                        ? () => setDialog(() => selectedYear++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.6,
                children: List.generate(12, (i) {
                  final isFuture = selectedYear == now.year && i >= now.month;
                  final isSelected = selectedMonth == i + 1;
                  return GestureDetector(
                    onTap: isFuture
                        ? null
                        : () => setDialog(() => selectedMonth = i + 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(ctx).colorScheme.primary
                            : isFuture
                                ? Colors.grey.withValues(alpha: 0.08)
                                : Theme.of(ctx)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          months[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(ctx).colorScheme.onPrimary
                                : isFuture
                                    ? Colors.grey[400]
                                    : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(ctx, DateTime(selectedYear, selectedMonth)),
              child: const Text("Apply"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — tappable to expand/collapse
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Period Comparison",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (!_expanded)
                      Text(
                        "${fmt.format(_periodA)} vs ${fmt.format(_periodB)} — tap to compare",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                  ],
                ),
                const Spacer(),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),

        if (_expanded) ...[
          const SizedBox(height: 10),
          // Period selectors
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text(fmt.format(_periodA),
                      style: const TextStyle(fontSize: 13)),
                  onPressed: () async {
                    final picked = await _pickMonth(context, _periodA);
                    if (picked != null) setState(() => _periodA = picked);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text("vs",
                    style: TextStyle(
                        color: Colors.grey[500], fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text(fmt.format(_periodB),
                      style: const TextStyle(fontSize: 13)),
                  onPressed: () async {
                    final picked = await _pickMonth(context, _periodB);
                    if (picked != null) setState(() => _periodB = picked);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comparison table
          Builder(builder: (context) {
            final totalsA = _totalsFor(_periodA);
            final totalsB = _totalsFor(_periodB);
            final totalA = totalsA.values.fold(0.0, (s, v) => s + v);
            final totalB = totalsB.values.fold(0.0, (s, v) => s + v);
            final allCats = {...totalsA.keys, ...totalsB.keys}.toList()..sort();

            if (allCats.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("No data for selected periods",
                      style: TextStyle(color: Colors.grey)),
                ),
              );
            }

            final diff = totalB - totalA;
            final pctChange = totalA > 0 ? (diff / totalA * 100) : 0.0;
            final up = diff > 0;

            return Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Totals summary row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fmt.format(_periodA),
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                              Text(CurrencyService.format(totalA),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Icon(
                              up ? Icons.trending_up : Icons.trending_down,
                              color: up ? Colors.red : Colors.green,
                              size: 20,
                            ),
                            Text(
                              "${up ? '+' : ''}${pctChange.toStringAsFixed(1)}%",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: up ? Colors.red : Colors.green),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(fmt.format(_periodB),
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                              Text(CurrencyService.format(totalB),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
                  // Per-category rows
                  ...allCats.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final amtA = totalsA[cat] ?? 0.0;
                    final amtB = totalsB[cat] ?? 0.0;
                    final catDiff = amtB - amtA;
                    final catUp = catDiff > 0;
                    return Column(
                      children: [
                        if (i > 0)
                          Divider(
                              height: 1,
                              color: cs.outline.withValues(alpha: 0.12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(cat,
                                      style: const TextStyle(fontSize: 13))),
                              SizedBox(
                                width: 76,
                                child: Text(
                                  amtA > 0 ? CurrencyService.format(amtA) : '—',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500]),
                                ),
                              ),
                              SizedBox(
                                width: 76,
                                child: Text(
                                  amtB > 0 ? CurrencyService.format(amtB) : '—',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                width: 28,
                                child: catDiff.abs() < 1
                                    ? const SizedBox.shrink()
                                    : Icon(
                                        catUp
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        size: 13,
                                        color:
                                            catUp ? Colors.red : Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 4),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

// ── MONTHLY PLAIN-ENGLISH SUMMARY CARD ───────────────────────────────────────
class _MonthlySummaryCard extends StatefulWidget {
  final List<Map<String, dynamic>> expenses;
  final double monthlyIncome;
  final String chartPeriod;
  final DateTime? pickedMonth;

  const _MonthlySummaryCard({
    required this.expenses,
    required this.monthlyIncome,
    required this.chartPeriod,
    this.pickedMonth,
  });

  @override
  State<_MonthlySummaryCard> createState() => _MonthlySummaryCardState();
}

class _MonthlySummaryCardState extends State<_MonthlySummaryCard> {
  String? _summary;
  bool _loading = false;

  String get _monthLabel {
    if (widget.chartPeriod == 'pick_month' && widget.pickedMonth != null) {
      return DateFormat('MMMM yyyy').format(widget.pickedMonth!);
    }
    if (widget.chartPeriod == 'last_month') {
      final now = DateTime.now();
      return DateFormat('MMMM yyyy').format(DateTime(now.year, now.month - 1));
    }
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  Future<void> _generate() async {
    if (widget.expenses.isEmpty) return;
    setState(() {
      _loading = true;
      _summary = null;
    });
    try {
      final result = await LLMService.generateMonthlySummary(
        expenses: widget.expenses,
        monthlyIncome: widget.monthlyIncome,
        monthLabel: _monthLabel,
      );
      if (mounted) setState(() => _summary = result);
    } catch (e) {
      if (mounted) {
        setState(() => _summary =
            "Could not generate summary: ${e.toString().replaceAll('Exception: ', '')}");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Only show the full container if summary has been generated or is loading.
    // Otherwise show a compact "Generate" button to avoid a blank gray box.
    if (!_loading && _summary == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: OutlinedButton.icon(
          icon: const Icon(Icons.summarize_outlined, size: 16),
          label: Text("Generate ${_monthLabel} Summary"),
          onPressed: widget.expenses.isEmpty ? null : _generate,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.summarize_outlined,
                          color: cs.primary, size: 16),
                      const SizedBox(width: 6),
                      Text("$_monthLabel in Plain English",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(_summary == null ? "Generate" : "Refresh"),
                    onPressed:
                        _loading || widget.expenses.isEmpty ? null : _generate,
                  ),
                ],
              ),
              if (_loading) ...[
                const SizedBox(height: 10),
                const Row(
                  children: [
                    SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text("Writing summary...",
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ] else if (_summary != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: _summary!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Summary copied ✓"),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    _summary!,
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 6),
                Text(
                  "Tap Generate for a plain-English summary of your spending this period.",
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── MARKET INSIGHTS CARD ──────────────────────────────────────────────────────
/// Shows live PHP exchange rates + financial literacy tips.
/// Rates fetched from open.er-api.com (same source as CurrencyService).
/// Helps users understand how global markets affect their purchasing power.
class _MarketInsightsCard extends StatefulWidget {
  const _MarketInsightsCard();

  @override
  State<_MarketInsightsCard> createState() => _MarketInsightsCardState();
}

class _MarketInsightsCardState extends State<_MarketInsightsCard> {
  Map<String, double> _rates = {};
  bool _loading = true;
  String _updatedAt = '';
  bool _expanded = false;

  // Key currencies to show (PHP as base)
  static const _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'SGD', 'AUD'];

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _loading = true);
    try {
      // Check if cached rates are fresh (< 1 hour old)
      final updatedTs = await DBService.getSetting('exchange_rate_updated');
      bool needsFetch = true;
      if (updatedTs != null) {
        try {
          final dt = DateTime.parse(updatedTs);
          if (DateTime.now().difference(dt).inHours < 1) needsFetch = false;
        } catch (_) {}
      }

      if (needsFetch) {
        // Fetch fresh rates from open.er-api.com
        try {
          final response = await http
              .get(Uri.parse('https://open.er-api.com/v6/latest/PHP'))
              .timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final allRates = data['rates'] as Map<String, dynamic>;
            for (final code in _currencies) {
              final rate = (allRates[code] as num?)?.toDouble();
              if (rate != null && rate > 0) {
                await DBService.setSetting(
                    'exchange_rate_$code', rate.toString());
              }
            }
            await DBService.setSetting(
                'exchange_rate_updated', DateTime.now().toIso8601String());
          }
        } catch (_) {} // fall through to cached
      }

      // Load from DB (fresh or cached)
      final rates = <String, double>{};
      for (final code in _currencies) {
        final cached = await DBService.getSetting('exchange_rate_$code');
        if (cached != null) rates[code] = double.tryParse(cached) ?? 0;
      }
      final updatedTs2 = await DBService.getSetting('exchange_rate_updated');
      String updatedStr = '';
      if (updatedTs2 != null) {
        try {
          final dt = DateTime.parse(updatedTs2);
          final diff = DateTime.now().difference(dt);
          updatedStr = diff.inMinutes < 60
              ? '${diff.inMinutes}m ago'
              : diff.inHours < 24
                  ? '${diff.inHours}h ago'
                  : '${diff.inDays}d ago';
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _rates = rates;
          _updatedAt = updatedStr.isNotEmpty ? updatedStr : 'Just now';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — always visible
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  const Icon(Icons.public, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Market Insights",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_updatedAt.isNotEmpty)
                    Text(_updatedAt,
                        style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurface.withValues(alpha: 0.4))),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // Exchange rates row — always visible (compact)
          if (_loading)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: LinearProgressIndicator(),
            )
          else if (_rates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PHP Exchange Rates",
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _currencies
                          .where((c) => (_rates[c] ?? 0) > 0)
                          .map((code) {
                        final rate = _rates[code]!;
                        // Rate is PHP per 1 unit of foreign currency
                        // e.g. USD rate stored as PHP/USD
                        // We want to show: 1 USD = X PHP
                        // The stored rate is already PHP per foreign unit
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: cs.outline.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(code,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '₱${(1 / rate).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '1 $code',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: cs.onSurface.withValues(alpha: 0.4)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

          // Expanded: financial literacy tips
          if (_expanded) ...[
            Divider(height: 1, color: cs.outline.withValues(alpha: 0.15)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💡 Financial Literacy Tips",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 10),
                  for (final tip in _tips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.$1, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tip.$2,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(tip.$3,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            cs.onSurface.withValues(alpha: 0.6),
                                        height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    "Exchange rates from open.er-api.com · Updated hourly",
                    style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.35)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static const _tips = [
    (
      '💵',
      'USD/PHP Rate Matters',
      'When USD strengthens vs PHP, imported goods (electronics, fuel, food) get more expensive. A weaker peso means your ₱6,600 buys less in dollar-priced items.',
    ),
    (
      '📈',
      'Inflation Erodes Savings',
      'Philippine inflation averages 3–6% per year. If your savings earn less than inflation, you\'re losing purchasing power. Consider time deposits or MP2 (Pag-IBIG) for better returns.',
    ),
    (
      '🏦',
      'Emergency Fund First',
      'Before investing, build 3–6 months of expenses as an emergency fund. Keep it in a high-yield savings account (CIMB, Maya, Seabank offer 4–6% p.a.).',
    ),
    (
      '📊',
      '50/30/20 Rule',
      '50% of income → Needs (food, rent, transport). 30% → Wants (entertainment, dining out). 20% → Savings & investments. Adjust based on your situation.',
    ),
    (
      '💳',
      'Avoid Minimum Payments',
      'Credit card minimum payments keep you in debt for years. Always pay the full balance. If you can\'t, the purchase was beyond your means.',
    ),
    (
      '🎯',
      'Pay Yourself First',
      'Transfer your savings amount on payday — before spending anything. Automate it if possible. What\'s left is what you spend.',
    ),
  ];
}
