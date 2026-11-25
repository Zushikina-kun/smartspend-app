import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';
import '../widgets/history_sheet.dart';
import '../widgets/peso_mascot.dart';

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

  void _showEditDialog(Map<String, dynamic> existing) {
    final titleCtrl =
        TextEditingController(text: existing['title'] as String? ?? '');
    final amountCtrl = TextEditingController(
        text: (existing['amount'] as num).toStringAsFixed(2));
    final originalAmount = (existing['amount'] as num).toDouble();
    String category = existing['category'] as String? ?? _defaultCategory;
    String date = existing['date'] as String? ??
        DateTime.now().toIso8601String().substring(0, 10);
    bool isWindfall = (existing['is_windfall'] as int? ?? 0) == 1;

    final availableCategories = _accountType == 'student'
        ? ['Allowance', 'Freelance', 'Side Job', 'Gift', 'Bonus', 'Others']
        : _accountType == 'unemployed'
            ? ['Gift', 'Rental', 'Investment', 'Others']
            : _accountType == 'pensioner'
                ? ['Pension', 'Investment', 'Rental', 'Gift', 'Others']
                : _incomeCategories;

    // Ensure current category is in the list
    if (!availableCategories.contains(category)) {
      category = availableCategories.first;
    }

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
              const Text('Edit Income',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "Title",
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
                value: category,
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
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text("Date: $date"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.tryParse(date) ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) {
                    setSheet(
                        () => date = picked.toIso8601String().substring(0, 10));
                  }
                },
              ),
              const SizedBox(height: 12),
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
                        child: Text(
                          isWindfall ? "Windfall income" : "Mark as windfall?",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isWindfall ? Colors.amber[800] : null,
                          ),
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
                  final newAmount = double.tryParse(amountCtrl.text);
                  if (title.isEmpty || newAmount == null || newAmount <= 0)
                    return;

                  // Show confirmation with changed amount if it differs
                  if (newAmount != originalAmount) {
                    final diff = newAmount - originalAmount;
                    final diffStr =
                        '${diff >= 0 ? '+' : ''}${CurrencyService.format(diff.abs())}';
                    final confirmed = await showDialog<bool>(
                      context: ctx,
                      builder: (d) => AlertDialog(
                        title: const Text('Confirm Change'),
                        content: Text(
                            'Amount changes from ${CurrencyService.format(originalAmount)} to ${CurrencyService.format(newAmount)} ($diffStr).'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(d, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(d, true),
                              child: const Text('Save')),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                  }

                  await DBService.updateIncome({
                    ...existing,
                    'title': title,
                    'amount': newAmount,
                    'category': category,
                    'date': date,
                    'is_windfall': isWindfall ? 1 : 0,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = _defaultCategory;
    String date = DateTime.now().toIso8601String().substring(0, 10);
    bool isWindfall = false;
    List<Map<String, dynamic>> wallets = [];
    // allocations: list of {wallet_id, wallet_name, amount_ctrl}
    final List<Map<String, dynamic>> allocations = [];

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
        builder: (ctx, setSheet) {
          // Load wallets once
          if (wallets.isEmpty) {
            DBService.getWallets().then((w) {
              if (w.isNotEmpty) setSheet(() => wallets = w);
            });
          }
          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
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
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (picked != null) {
                        setSheet(() =>
                            date = picked.toIso8601String().substring(0, 10));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Windfall toggle — one-time unexpected income (bonus, gift, etc.)
                  InkWell(
                    onTap: () => setSheet(() => isWindfall = !isWindfall),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
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
                                    color:
                                        isWindfall ? Colors.amber[800] : null,
                                  ),
                                ),
                                const Text(
                                  "One-time unexpected income (bonus, gift, prize). Kept separate from regular income in forecasts.",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey),
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
                  // Wallet allocation section — optional split across wallets
                  if (wallets.isNotEmpty) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Allocate to Wallets",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label:
                              const Text("Add", style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            setSheet(() {
                              allocations.add({
                                'wallet_id': wallets.first['id'] as int,
                                'wallet_name': wallets.first['name'] as String,
                                'ctrl': TextEditingController(),
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    ...allocations.asMap().entries.map((e) {
                      final idx = e.key;
                      final alloc = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<int>(
                                value: alloc['wallet_id'] as int,
                                decoration: InputDecoration(
                                  labelText: "Wallet",
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                items: wallets
                                    .map((w) => DropdownMenuItem<int>(
                                          value: w['id'] as int,
                                          child: Text(
                                              '${w['icon'] ?? ''} ${w['name']}',
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ))
                                    .toList(),
                                onChanged: (v) => setSheet(() {
                                  alloc['wallet_id'] = v!;
                                  alloc['wallet_name'] = wallets.firstWhere(
                                      (w) => w['id'] == v)['name'] as String;
                                }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller:
                                    alloc['ctrl'] as TextEditingController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Amount",
                                  prefixText: "${CurrencyService.symbol} ",
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: Colors.grey),
                              onPressed: () =>
                                  setSheet(() => allocations.removeAt(idx)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                  ],
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      final amount = double.tryParse(amountCtrl.text);
                      if (title.isEmpty || amount == null || amount <= 0)
                        return;

                      // Build wallet allocations JSON if any
                      String? walletAllocationsJson;
                      if (allocations.isNotEmpty) {
                        final allocList = <Map<String, dynamic>>[];
                        for (final alloc in allocations) {
                          final allocAmt = double.tryParse(
                              (alloc['ctrl'] as TextEditingController)
                                  .text
                                  .trim());
                          if (allocAmt != null && allocAmt > 0) {
                            allocList.add({
                              'wallet_id': alloc['wallet_id'],
                              'wallet_name': alloc['wallet_name'],
                              'amount': allocAmt,
                            });
                          }
                        }
                        if (allocList.isNotEmpty) {
                          walletAllocationsJson = jsonEncode(allocList);
                        }
                      }

                      await DBService.insertIncome({
                        'title': title,
                        'amount': amount,
                        'category': category,
                        'date': date,
                        'is_recurring': 0,
                        'is_windfall': isWindfall ? 1 : 0,
                        if (walletAllocationsJson != null)
                          'wallet_allocations': walletAllocationsJson,
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
                                  final newAmt =
                                      ((topGoal['current_amount'] as num)
                                                  .toDouble() +
                                              suggested)
                                          .clamp(
                                              0.0,
                                              (topGoal['target_amount'] as num)
                                                  .toDouble());
                                  await DBService.updateGoal(
                                      {...topGoal, 'current_amount': newAmt},
                                      source: 'income_allocation');
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
          );
        },
      ),
    ).then((_) {
      for (final a in allocations) {
        (a['ctrl'] as TextEditingController).dispose();
      }
    });
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
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Monthly income change history",
            onPressed: () async {
              final history = await DBService.getIncomeHistory();
              if (context.mounted) {
                HistorySheet.show(
                  context,
                  title: 'Monthly Income History',
                  subtitle:
                      '${history.length} change${history.length == 1 ? '' : 's'} to declared income',
                  titleIcon: Icons.account_balance_wallet_outlined,
                  history: history,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: "Income entry history",
            onPressed: () async {
              final raw = await DBService.getIncomeEntryHistory();
              // Map to HistorySheet-compatible format
              final history = raw.map((h) {
                final isDelete = h['action'] == 'delete';
                final amount = (h['amount'] as num?)?.toDouble() ?? 0.0;
                return {
                  'action': isDelete ? 'delete' : null,
                  'delta': isDelete ? -amount : amount,
                  'new_amount': isDelete ? null : amount,
                  'old_amount': null,
                  'source': isDelete ? 'delete' : 'income',
                  'reason':
                      '${h['title'] ?? ''} (${h['category'] ?? ''}) — ${h['date'] ?? ''}',
                  'timestamp': h['timestamp'] ?? '',
                };
              }).toList();
              if (context.mounted) {
                HistorySheet.show(
                  context,
                  title: 'Income Entry History',
                  subtitle:
                      '${history.length} entr${history.length == 1 ? 'y' : 'ies'} logged',
                  titleIcon: Icons.receipt_long_outlined,
                  history: history,
                );
              }
            },
          ),
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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem(AppLocalizations.of(context)!.thisMonth,
                          CurrencyService.format(thisMonthIncome)),
                      _summaryItem(AppLocalizations.of(context)!.allTime,
                          CurrencyService.format(totalIncome)),
                      _summaryItem(AppLocalizations.of(context)!.entries,
                          "${_income.length}"),
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
                                      PesoMascot.withSpeech(
                                        mood: PesoMood.thinking,
                                        text:
                                            "Wala pa tayong income records!\nI-tap + para mag-add ng sweldo o kita.",
                                      ),
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
                                onLongPress: () => _showEditDialog(item),
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
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text("Delete Income"),
                                            content: Text(
                                                "Remove this income entry of ${CurrencyService.format((item['amount'] as num).toDouble())}?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text("Delete",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await DBService.deleteIncome(
                                              item['id'] as int);
                                          _load();
                                        }
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
    return Builder(builder: (context) {
      final onContainer = Theme.of(context).colorScheme.onPrimaryContainer;
      return Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: onContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: onContainer.withValues(alpha: 0.7), fontSize: 11)),
        ],
      );
    });
  }
}
