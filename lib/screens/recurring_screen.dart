import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/category_service.dart';
import '../widgets/info_button.dart';
import 'budget_screen.dart';

const _frequencies = ['daily', 'weekly', 'monthly', 'yearly'];

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  List<String> _categories = CategoryService.builtIn;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DBService.getRecurring();
    final cats = await CategoryService.getAll();
    setState(() {
      _items = items;
      _categories = cats;
      _loading = false;
    });
  }

  void _showAddDialog({Map<String, dynamic>? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final amountCtrl = TextEditingController(
        text: existing != null
            ? (existing['amount'] as double).toStringAsFixed(0)
            : '');
    String category = existing?['category'] ?? 'Bills';
    String frequency = existing?['frequency'] ?? 'monthly';
    bool isExpense = (existing?['is_expense'] ?? 1) == 1;
    String nextDate = existing?['next_date'] ??
        DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .substring(0, 10);
    String startDate = existing?['start_date'] ??
        DateTime.now().toIso8601String().substring(0, 10);

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
              Text(existing == null ? "Add Recurring" : "Edit Recurring",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                      value: true,
                      label: Text("Expense"),
                      icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(
                      value: false,
                      label: Text("Income"),
                      icon: Icon(Icons.arrow_downward)),
                ],
                selected: {isExpense},
                onSelectionChanged: (s) => setSheet(() => isExpense = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "e.g. Netflix, Rent, Salary",
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _categories.contains(category)
                          ? category
                          : _categories.first,
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setSheet(() => category = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: frequency,
                      decoration: InputDecoration(
                        labelText: "Frequency",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _frequencies
                          .map((f) => DropdownMenuItem(
                              value: f,
                              child: Text(f[0].toUpperCase() + f.substring(1))))
                          .toList(),
                      onChanged: (v) => setSheet(() => frequency = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Start date picker
              OutlinedButton.icon(
                icon: const Icon(Icons.play_circle_outline, size: 16),
                label: Text("Starts: $startDate"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.tryParse(startDate) ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setSheet(() =>
                        startDate = picked.toIso8601String().substring(0, 10));
                  }
                },
              ),
              const SizedBox(height: 8),
              // Next due date picker
              OutlinedButton.icon(
                icon: const Icon(Icons.event, size: 16),
                label: Text("Next due: $nextDate"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.tryParse(nextDate) ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setSheet(() =>
                        nextDate = picked.toIso8601String().substring(0, 10));
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text);
                  if (title.isEmpty || amount == null || amount <= 0) return;

                  final data = {
                    if (existing != null) 'id': existing['id'],
                    'title': title,
                    'amount': amount,
                    'category': category,
                    'frequency': frequency,
                    'next_date': nextDate,
                    'start_date': startDate,
                    'is_expense': isExpense ? 1 : 0,
                  };

                  if (existing == null) {
                    await DBService.insertRecurring(data);
                    // RC-2: Suggest creating a budget for this category if none exists
                    if (isExpense && mounted) {
                      final budgets = await DBService.getBudgets();
                      final hasBudget =
                          budgets.any((b) => b.category == category);
                      if (!hasBudget) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '💡 No budget set for $category — want to add one?'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: "Add Budget",
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const BudgetScreen())),
                          ),
                        ));
                      }
                    }
                  } else {
                    await DBService.updateRecurring(data);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(existing == null ? "Add" : "Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logAllDue() async {
    final due = _items.where((r) {
      try {
        final d = DateTime.parse(r['next_date'] as String);
        return !d.isAfter(DateTime.now());
      } catch (_) {
        return false;
      }
    }).toList();
    if (due.isEmpty) return;
    for (final item in due) {
      await _logNow(item, silent: true);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${due.length} recurring item${due.length == 1 ? '' : 's'} logged"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ));
      _load();
    }
  }

  Future<void> _logNow(Map<String, dynamic> item, {bool silent = false}) async {
    final isExpense = (item['is_expense'] as int) == 1;
    final now = DateTime.now();

    if (isExpense) {
      await DBService.insertExpense({
        'item_name': item['title'],
        'category': item['category'],
        'amount': item['amount'],
        'date': now.toIso8601String().substring(0, 10),
        'time': now.toIso8601String().substring(11, 16),
        'payment_method': 'Cash',
        'notes': 'Logged from recurring: ${item['title']}',
        'ai_generated': 0,
        'confidence_score': 1.0,
      });
    } else {
      // Log recurring income as an income entry
      await DBService.insertIncome({
        'title': item['title'],
        'amount': item['amount'],
        'category': item['category'] == 'Bills' ? 'Salary' : item['category'],
        'date': now.toIso8601String().substring(0, 10),
        'is_recurring': 1,
      });
    }

    // Advance next_date based on frequency
    try {
      final current = DateTime.parse(item['next_date'] as String);
      DateTime next;
      switch (item['frequency']) {
        case 'daily':
          next = current.add(const Duration(days: 1));
          break;
        case 'weekly':
          next = current.add(const Duration(days: 7));
          break;
        case 'yearly':
          // Safe year advance — clamp to last day of target month
          final targetMonth = current.month;
          final targetYear = current.year + 1;
          final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
          next =
              DateTime(targetYear, targetMonth, current.day.clamp(1, lastDay));
          break;
        default: // monthly
          // Safe month advance — clamp to last day of next month
          final nextMonth = current.month == 12 ? 1 : current.month + 1;
          final nextYear =
              current.month == 12 ? current.year + 1 : current.year;
          final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
          next = DateTime(nextYear, nextMonth, current.day.clamp(1, lastDay));
      }
      await DBService.updateRecurring({
        ...item,
        'next_date': next.toIso8601String().substring(0, 10),
      });
    } catch (_) {}

    if (mounted && !silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "${item['title']} logged as ${isExpense ? 'expense' : 'income'}"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      _load();
    }
  }

  String _nextDateLabel(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      final diff = d.difference(DateTime.now()).inDays;
      if (diff == 0) return "Today";
      if (diff == 1) return "Tomorrow";
      if (diff < 0) return "Overdue";
      return "In $diff days";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recurring Transactions"),
        actions: [
          const InfoButton(
            title: "Recurring Transactions",
            body:
                "Recurring transactions are bills, subscriptions, or income that repeat on a schedule — internet, Netflix, salary, allowance.\n\n"
                "• The app tracks when each one is due and sends a notification\n"
                "• Tap any item → Log Now to record it as an actual expense or income\n"
                "• 'Log All Due' logs all overdue items at once\n"
                "• Tap the + icon in the top bar for SSS, PhilHealth, and Pag-IBIG presets",
          ),
          // Government contribution presets
          PopupMenuButton<String>(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Add preset",
            onSelected: (val) async {
              final now = DateTime.now();
              final nextMonth = now.month == 12 ? 1 : now.month + 1;
              final nextYear = now.month == 12 ? now.year + 1 : now.year;
              final nextDate = DateTime(nextYear, nextMonth, 1)
                  .toIso8601String()
                  .substring(0, 10);
              final presets = {
                'sss': {
                  'title': 'SSS Contribution',
                  'amount': 1125.0,
                  'category': 'Bills',
                  'frequency': 'monthly',
                  'next_date': nextDate,
                  'start_date': now.toIso8601String().substring(0, 10),
                  'is_expense': 1,
                },
                'philhealth': {
                  'title': 'PhilHealth Contribution',
                  'amount': 500.0,
                  'category': 'Bills',
                  'frequency': 'monthly',
                  'next_date': nextDate,
                  'start_date': now.toIso8601String().substring(0, 10),
                  'is_expense': 1,
                },
                'pagibig': {
                  'title': 'Pag-IBIG Contribution',
                  'amount': 200.0,
                  'category': 'Bills',
                  'frequency': 'monthly',
                  'next_date': nextDate,
                  'start_date': now.toIso8601String().substring(0, 10),
                  'is_expense': 1,
                },
              };
              final data = presets[val];
              if (data != null) {
                await DBService.insertRecurring(data);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("${data['title']} added"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                  _load();
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'sss',
                child: Row(children: [
                  Icon(Icons.account_balance, size: 16),
                  SizedBox(width: 8),
                  Text("SSS Contribution"),
                ]),
              ),
              const PopupMenuItem(
                value: 'philhealth',
                child: Row(children: [
                  Icon(Icons.local_hospital_outlined, size: 16),
                  SizedBox(width: 8),
                  Text("PhilHealth Contribution"),
                ]),
              ),
              const PopupMenuItem(
                value: 'pagibig',
                child: Row(children: [
                  Icon(Icons.home_outlined, size: 16),
                  SizedBox(width: 8),
                  Text("Pag-IBIG Contribution"),
                ]),
              ),
            ],
          ),
          if (_items.any((r) {
            try {
              final d = DateTime.parse(r['next_date'] as String);
              return !d.isAfter(DateTime.now());
            } catch (_) {
              return false;
            }
          }))
            TextButton.icon(
              icon: const Icon(Icons.playlist_add_check, size: 18),
              label: const Text("Log All Due"),
              onPressed: _logAllDue,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_recurring',
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Add Recurring"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              const Text("No recurring transactions.",
                                  style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              const Text(
                                  "Add bills, subscriptions, or recurring income.",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              const Text(
                                  "💡 Or tell the AI: \"Add Netflix ₱299 monthly\"",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 12)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text("Add Recurring"),
                                onPressed: () => _showAddDialog(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      final isExpense = (item['is_expense'] as int) == 1;
                      final nextLabel =
                          _nextDateLabel(item['next_date'] as String);
                      final isOverdue = nextLabel == "Overdue";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isExpense
                                ? Colors.redAccent.withValues(alpha: 0.12)
                                : Colors.green.withValues(alpha: 0.12),
                            child: Icon(
                              isExpense
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color:
                                  isExpense ? Colors.redAccent : Colors.green,
                              size: 18,
                            ),
                          ),
                          title: Text(item['title'] as String,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            "${item['category']}  •  ${(item['frequency'] as String)[0].toUpperCase()}${(item['frequency'] as String).substring(1)}"
                            "${item['start_date'] != null ? '  •  Since ${item['start_date']}' : ''}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${isExpense ? '-' : '+'}${CurrencyService.format((item['amount'] as num).toDouble())}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isExpense
                                        ? Colors.redAccent
                                        : Colors.green),
                              ),
                              Text(
                                nextLabel,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isOverdue
                                        ? Colors.red
                                        : cs.onSurface.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                          onLongPress: () => _showAddDialog(existing: item),
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(item['title'] as String),
                              content: Builder(builder: (ctx) {
                                final amt = (item['amount'] as num).toDouble();
                                final freq =
                                    item['frequency'] as String? ?? 'monthly';
                                final startDate = item['start_date'] as String?;
                                // RC-1: Total cost calculation
                                String totalCostStr = '';
                                if (startDate != null) {
                                  try {
                                    final start = DateTime.parse(startDate);
                                    final monthsElapsed = (DateTime.now()
                                                .difference(start)
                                                .inDays /
                                            30)
                                        .floor()
                                        .clamp(0, 999);
                                    double monthlyAmt = amt;
                                    if (freq == 'weekly')
                                      monthlyAmt = amt * 4.33;
                                    if (freq == 'yearly') monthlyAmt = amt / 12;
                                    final totalPaid =
                                        monthlyAmt * monthsElapsed;
                                    if (monthsElapsed > 0) {
                                      totalCostStr =
                                          '\nTotal paid so far: ${CurrencyService.format(totalPaid)} ($monthsElapsed months)';
                                    }
                                  } catch (_) {}
                                }
                                return Text(
                                    "Amount: ${CurrencyService.format(amt)}\n"
                                    "Next: ${_nextDateLabel(item['next_date'] as String)} (${item['next_date']})\n"
                                    "Frequency: ${freq[0].toUpperCase()}${freq.substring(1)}\n"
                                    "Starts: ${startDate ?? 'N/A'}"
                                    "$totalCostStr");
                              }),
                              actions: [
                                if ((item['is_expense'] as int) == 1)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add_circle_outline,
                                        size: 16),
                                    label: const Text("Log Now"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // BT-5: Pre-fill amount for editing before logging
                                      final amtCtrl = TextEditingController(
                                          text: (item['amount'] as num)
                                              .toStringAsFixed(0));
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20))),
                                        builder: (_) => Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              24,
                                              20,
                                              24,
                                              MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom +
                                                  24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text("Log: ${item['title']}",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              const Text(
                                                  "Adjust amount if needed (e.g. variable bills like electricity)",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 14),
                                              TextField(
                                                controller: amtCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                autofocus: true,
                                                decoration: InputDecoration(
                                                  labelText: "Amount",
                                                  prefixText:
                                                      "${CurrencyService.symbol} ",
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                ),
                                              ),
                                              const SizedBox(height: 14),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final amt = double.tryParse(
                                                      amtCtrl.text);
                                                  if (amt == null || amt <= 0)
                                                    return;
                                                  Navigator.pop(context);
                                                  await _logNow(
                                                      {...item, 'amount': amt});
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .green,
                                                    foregroundColor: Colors
                                                        .white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12))),
                                                child:
                                                    const Text("Confirm & Log"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                TextButton(
                                  onPressed: () async {
                                    await DBService.deleteRecurring(
                                        item['id'] as int);
                                    if (mounted) Navigator.pop(context);
                                    _load();
                                  },
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
