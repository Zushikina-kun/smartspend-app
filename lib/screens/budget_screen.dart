import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/category_service.dart';
import '../widgets/info_button.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Budget> _budgets = [];
  Map<String, double> _spent = {};
  bool _loading = true;
  double _monthlyIncome = 0;
  List<String> _categories = CategoryService.builtIn;

  final _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final budgets = await DBService.getBudgets();
    final expenses = await DBService.getExpenses(month: _currentMonth);
    final income = await DBService.getMonthlyIncome();
    final cats = await CategoryService.getAll();

    final spent = <String, double>{};
    for (final e in expenses) {
      spent[e.category] = (spent[e.category] ?? 0) + e.amount;
    }

    setState(() {
      _budgets = budgets;
      _spent = spent;
      _monthlyIncome = income;
      _categories = cats;
      _loading = false;
    });
  }

  void _showSetBudgetDialog({Budget? existing}) {
    final category = existing?.category;
    String selectedCategory = category ?? _categories.first;
    final amountController = TextEditingController(
        text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    bool isPercentage = existing?.isPercentage ?? false;
    final percentCtrl = TextEditingController(
        text: existing != null && existing.isPercentage
            ? existing.percentageValue.toStringAsFixed(0)
            : '');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? "Set Budget" : "Edit Budget"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (existing == null)
                  DropdownButtonFormField<String>(
                    initialValue: _categories.contains(selectedCategory)
                        ? selectedCategory
                        : _categories.first,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedCategory = v!),
                  ),
                if (existing != null)
                  Text(existing.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                // % of income toggle
                if (_monthlyIncome > 0) ...[
                  Row(
                    children: [
                      const Text("Mode:", style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Fixed ₱"),
                        selected: !isPercentage,
                        onSelected: (_) =>
                            setDialogState(() => isPercentage = false),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("% of income"),
                        selected: isPercentage,
                        onSelected: (_) =>
                            setDialogState(() => isPercentage = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (!isPercentage)
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Monthly Budget (${CurrencyService.symbol})",
                      prefixText: "${CurrencyService.symbol} ",
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: percentCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "% of monthly income",
                          suffixText: "%",
                        ),
                        onChanged: (v) {
                          final pct = double.tryParse(v) ?? 0;
                          amountController.text =
                              (pct / 100 * _monthlyIncome).toStringAsFixed(0);
                          setDialogState(() {});
                        },
                      ),
                      if (percentCtrl.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "= ${CurrencyService.format((double.tryParse(percentCtrl.text) ?? 0) / 100 * _monthlyIncome)}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                double amount;
                double pctValue = 0;
                if (isPercentage) {
                  pctValue = double.tryParse(percentCtrl.text) ?? 0;
                  if (pctValue <= 0 || pctValue > 100) return;
                  amount = pctValue / 100 * _monthlyIncome;
                } else {
                  amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;
                }

                // Warn if total budgets would exceed income
                if (_monthlyIncome > 0 && !isPercentage) {
                  final currentTotal = _budgets
                      .where((b) => b.category != (existing?.category ?? ''))
                      .fold<double>(0, (s, b) => s + b.amount);
                  final newTotal = currentTotal + amount;
                  if (newTotal > _monthlyIncome) {
                    final proceed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Over Budget Warning"),
                        content: Text(
                          "Your total budgets (${CurrencyService.format(newTotal)}) would exceed "
                          "your monthly income (${CurrencyService.format(_monthlyIncome)}).\n\n"
                          "This means you're planning to spend more than you earn. Continue?",
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel")),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white),
                            child: const Text("Set Anyway"),
                          ),
                        ],
                      ),
                    );
                    if (proceed != true) return;
                  }
                }

                await DBService.setBudget(
                    existing?.category ?? selectedCategory, amount,
                    isPercentage: isPercentage, percentageValue: pctValue);
                if (mounted) Navigator.pop(ctx);
                _loadData();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Color _progressColor(double ratio, BuildContext context) {
    if (ratio >= 1.0) return Colors.red;
    if (ratio >= 0.8) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
        actions: [
          const InfoButton(
            title: "How Budgets Work",
            body:
                "Set a monthly spending limit per category. The progress bar fills as you spend — green is on track, orange means 80%+ used, red means exceeded.\n\n"
                "Pace indicator: based on how far through the month you are, it tells you if you're spending faster or slower than expected.\n\n"
                "You can set budgets as a fixed ₱ amount or as a % of your income.",
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budget',
        onPressed: () => _showSetBudgetDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Add Budget"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _budgets.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pie_chart_outline,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                const Text("No budgets set yet",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.grey)),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    "Budgets help you control spending per category. Set a monthly limit and the app will warn you when you're close to exceeding it.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        height: 1.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    "💡 Tip: Ask the AI to set up budgets for you — just say \"Set up budgets based on my income\"",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        height: 1.5),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add Your First Budget"),
                                  onPressed: () => _showSetBudgetDialog(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _budgets.length + 1, // +1 for summary header
                      itemBuilder: (_, i) {
                        // Summary card at top
                        if (i == 0) {
                          final totalBudgeted =
                              _budgets.fold<double>(0, (s, b) => s + b.amount);
                          final totalSpent =
                              _spent.values.fold<double>(0, (s, v) => s + v);
                          // D8: time-aware context
                          final now = DateTime.now();
                          final daysInMonth =
                              DateUtils.getDaysInMonth(now.year, now.month);
                          final monthPct =
                              (now.day / daysInMonth * 100).round();
                          final isOverIncome = _monthlyIncome > 0 &&
                              totalBudgeted > _monthlyIncome;
                          final overBy = totalBudgeted - _monthlyIncome;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _summaryItem(
                                          "Budgeted",
                                          CurrencyService.format(totalBudgeted),
                                          Colors.white70),
                                      _summaryItem(
                                          "Spent",
                                          CurrencyService.format(totalSpent),
                                          Colors.white),
                                      if (_monthlyIncome > 0)
                                        _summaryItem(
                                            "Income",
                                            CurrencyService.format(
                                                _monthlyIncome),
                                            Colors.greenAccent),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // D8: month progress hint
                                Text(
                                  "Day ${now.day} of $daysInMonth — $monthPct% of month elapsed",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                ),
                                // Over-income warning banner
                                if (isOverIncome) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.orange.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.orange
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded,
                                            color: Colors.orange, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Total budgets exceed your income by ${CurrencyService.format(overBy)}. Consider reducing some limits.",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        final b = _budgets[i - 1];
                        final spentAmt = _spent[b.category] ?? 0;
                        final ratio = (spentAmt / b.amount).clamp(0.0, 1.0);
                        final over = spentAmt > b.amount;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(b.category,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                          if (b.isPercentage) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "${b.percentageValue.toStringAsFixed(0)}% of income",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 18),
                                      onPressed: () =>
                                          _showSetBudgetDialog(existing: b),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: "Edit budget",
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18, color: Colors.grey),
                                      onPressed: () async {
                                        await DBService.deleteBudget(
                                            b.category);
                                        _loadData();
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: "Remove budget",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation(
                                        _progressColor(ratio, context)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Spent: ${CurrencyService.format(spentAmt)}",
                                      style: TextStyle(
                                          color: over
                                              ? Colors.red
                                              : Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                    Text(
                                      "Limit: ${CurrencyService.format(b.amount)}",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                    if (over)
                                      const Text("⚠️ Over budget",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12))
                                    else
                                      Text(
                                        "${CurrencyService.format(b.amount - spentAmt)} left",
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                  ],
                                ),
                                // Pace indicator
                                Builder(builder: (ctx) {
                                  final now = DateTime.now();
                                  final daysInMonth = DateUtils.getDaysInMonth(
                                      now.year, now.month);
                                  final monthPct = now.day / daysInMonth;
                                  final expectedSpend = b.amount * monthPct;
                                  if (over) return const SizedBox.shrink();
                                  final ahead = spentAmt > expectedSpend;
                                  final diff = (spentAmt - expectedSpend).abs();
                                  if (diff < 10) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      ahead
                                          ? "⚠️ ${CurrencyService.format(diff)} ahead of expected pace"
                                          : "✓ ${CurrencyService.format(diff)} under expected pace",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: ahead
                                              ? Colors.orange[700]
                                              : Colors.green[600]),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
