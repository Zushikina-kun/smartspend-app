import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';

const _incomeCategories = [
  'Salary',
  'Allowance',
  'Pension',
  'Freelance',
  'Business',
  'Investment',
  'Rental',
  'Gift',
  'Bonus',
  'Commission',
  'Side Job',
  'Others'
];

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  List<Map<String, dynamic>> _income = [];
  bool _loading = true;
  String _accountType = 'employed';
  final _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final income = await DBService.getIncome();
    final accountType =
        await DBService.getSetting('account_type') ?? 'employed';
    if (!mounted) return;
    setState(() {
      _income = income;
      _accountType = accountType;
      _loading = false;
    });
  }

  String get _screenTitle {
    switch (_accountType) {
      case 'student':
        return 'Allowance';
      case 'unemployed':
        return 'Budget';
      case 'pensioner':
        return 'Pension';
      case 'general':
        return 'Income';
      default:
        return 'Income';
    }
  }

  String get _addLabel {
    switch (_accountType) {
      case 'student':
        return 'Add Allowance';
      case 'unemployed':
        return 'Add Budget';
      case 'pensioner':
        return 'Add Pension';
      default:
        return 'Add Income';
    }
  }

  String get _defaultCategory {
    switch (_accountType) {
      case 'student':
        return 'Allowance';
      case 'unemployed':
        return 'Others';
      case 'pensioner':
        return 'Pension';
      case 'freelancer':
        return 'Freelance';
      case 'business':
        return 'Business';
      default:
        return 'Salary';
    }
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = _defaultCategory;
    String date = DateTime.now().toIso8601String().substring(0, 10);
    bool isWindfall = false;

    // All account types get the full category list — user picks what applies
    final availableCategories = _accountType == 'student'
        ? ['Allowance', 'Freelance', 'Side Job', 'Gift', 'Bonus', 'Others']
        : _accountType == 'unemployed'
            ? ['Gift', 'Rental', 'Investment', 'Others']
            : _accountType == 'pensioner'
                ? ['Pension', 'Investment', 'Rental', 'Gift', 'Others']
                : _incomeCategories; // full list for all other types

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_addLabel,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "e.g. Monthly Salary, Freelance Project",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixText: "${CurrencyService.symbol} ",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _defaultCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: availableCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setSheet(() => category = v!),
              ),
              const SizedBox(height: 12),
              // Date picker — allows backdating income entries
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text("Date: $date"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.tryParse(date) ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setSheet(
                        () => date = picked.toIso8601String().substring(0, 10));
                  }
                },
              ),
              const SizedBox(height: 12),
              // Windfall toggle — one-time unexpected income (bonus, gift, etc.)
              InkWell(
                onTap: () => setSheet(() => isWindfall = !isWindfall),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isWindfall
                        ? Colors.amber.withValues(alpha: 0.1)
                        : Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isWindfall
                          ? Colors.amber.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isWindfall
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: isWindfall ? Colors.amber : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isWindfall
                                  ? "Windfall income"
                                  : "Mark as windfall?",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isWindfall ? Colors.amber[800] : null,
                              ),
                            ),
                            const Text(
                              "One-time unexpected income (bonus, gift, prize). Kept separate from regular income in forecasts.",
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isWindfall,
                        onChanged: (v) => setSheet(() => isWindfall = v),
                        activeThumbColor: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text);
                  if (title.isEmpty || amount == null || amount <= 0) return;
                  await DBService.insertIncome({
                    'title': title,
                    'amount': amount,
                    'category': category,
                    'date': date,
                    'is_recurring': 0,
                    'is_windfall': isWindfall ? 1 : 0,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();

                  // UX-3: Goal contribution suggestion after logging income
                  if (!isWindfall && mounted) {
                    final goals = await DBService.getGoals();
                    final incomplete = goals
                        .where((g) =>
                            (g['current_amount'] as num) <
                            (g['target_amount'] as num))
                        .toList();
                    if (incomplete.isNotEmpty) {
                      final topGoal = incomplete.first;
                      final suggested = (amount * 0.20).roundToDouble();
                      if (suggested >= 10 && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "💡 Allocate ${CurrencyService.format(suggested)} (20%) to \"${topGoal['name']}\"?"),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: "Add",
                            onPressed: () async {
                              final newAmt = ((topGoal['current_amount'] as num)
                                          .toDouble() +
                                      suggested)
                                  .clamp(
                                      0.0,
                                      (topGoal['target_amount'] as num)
                                          .toDouble());
                              await DBService.updateGoal(
                                  {...topGoal, 'current_amount': newAmt});
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Contribution added ✓"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            },
                          ),
                        ));
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_addLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thisMonthIncome = _income
        .where((i) => (i['date'] as String).startsWith(_currentMonth))
        .fold<double>(0, (s, i) => s + (i['amount'] as num));
    final totalIncome =
        _income.fold<double>(0, (s, i) => s + (i['amount'] as num));

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle),
        actions: [
          InfoButton(
            title: _screenTitle,
            body:
                "Log your income sources here — salary, allowance, pension, freelance payments, gifts, etc.\n\n"
                "• This month's total is shown at the top\n"
                "• You can backdate entries using the date picker\n"
                "• Income is used to calculate your Financial Health Score and the 50/30/20 rule\n"
                "• To update your declared monthly income, go to Profile → tap the income card",
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_income',
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: Text(_addLabel),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Color(0xFF00897B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem("This Month",
                          CurrencyService.format(thisMonthIncome)),
                      _summaryItem(
                          "All Time", CurrencyService.format(totalIncome)),
                      _summaryItem("Entries", "${_income.length}"),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: _income.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 64,
                                          color: Colors.grey[300]),
                                      const SizedBox(height: 12),
                                      const Text("No income recorded yet.",
                                          style: TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 8),
                                      const Text(
                                          "💡 Tell the AI: \"I received my salary of ₱15,000\"",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount:
                                _income.length + 1, // +1 for chart header
                            itemBuilder: (_, i) {
                              // IN-1: Income category chart as first item
                              if (i == 0) {
                                final catTotals = <String, double>{};
                                for (final item in _income) {
                                  final cat =
                                      item['category'] as String? ?? 'Others';
                                  catTotals[cat] = (catTotals[cat] ?? 0) +
                                      (item['amount'] as num);
                                }
                                if (catTotals.length < 2)
                                  return const SizedBox(height: 16);
                                final total =
                                    catTotals.values.fold(0.0, (s, v) => s + v);
                                final sorted = catTotals.entries.toList()
                                  ..sort((a, b) => b.value.compareTo(a.value));
                                final colors = [
                                  Colors.green,
                                  Colors.teal,
                                  Colors.blue,
                                  Colors.purple,
                                  Colors.orange,
                                  Colors.red
                                ];
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 0, 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("By Source",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 140,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 140,
                                              child: PieChart(PieChartData(
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 30,
                                                sections: sorted
                                                    .asMap()
                                                    .entries
                                                    .map((e) {
                                                  final pct = total > 0
                                                      ? e.value.value /
                                                          total *
                                                          100
                                                      : 0.0;
                                                  return PieChartSectionData(
                                                    value: e.value.value,
                                                    title:
                                                        "${pct.toStringAsFixed(0)}%",
                                                    color: colors[
                                                        e.key % colors.length],
                                                    radius: 50,
                                                    titleStyle: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  );
                                                }).toList(),
                                              )),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: sorted
                                                    .take(5)
                                                    .toList()
                                                    .asMap()
                                                    .entries
                                                    .map((e) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 4),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                  width: 8,
                                                                  height: 8,
                                                                  decoration: BoxDecoration(
                                                                      color: colors[e
                                                                              .key %
                                                                          colors
                                                                              .length],
                                                                      shape: BoxShape
                                                                          .circle)),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Expanded(
                                                                  child: Text(
                                                                      e.value
                                                                          .key,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis)),
                                                              Text(
                                                                  CurrencyService
                                                                      .format(e
                                                                          .value
                                                                          .value),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                            ],
                                                          ),
                                                        ))
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                );
                              }
                              final item = _income[i - 1];
                              String dateStr = '';
                              try {
                                dateStr = DateFormat('MMM d, y').format(
                                    DateTime.parse(item['date'] as String));
                              } catch (_) {}

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.green.withValues(alpha: 0.12),
                                  child: const Icon(Icons.arrow_downward,
                                      color: Colors.green, size: 18),
                                ),
                                title: Text(item['title'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                    "${item['category']}  •  $dateStr",
                                    style: const TextStyle(fontSize: 12)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "+${CurrencyService.format((item['amount'] as num).toDouble())}",
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18, color: Colors.grey),
                                      onPressed: () async {
                                        await DBService.deleteIncome(
                                            item['id'] as int);
                                        _load();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
