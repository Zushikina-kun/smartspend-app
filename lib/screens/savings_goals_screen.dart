import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  List<Map<String, dynamic>> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goals = await DBService.getGoals();
    setState(() {
      _goals = goals;
      _loading = false;
    });
  }

  void _showEmergencyFundDialog() async {
    // Check if emergency fund already exists
    final existing = _goals
        .where((g) => (g['name'] as String).toLowerCase().contains('emergency'))
        .firstOrNull;
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You already have an emergency fund goal!"),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Get monthly expenses to calculate recommended target
    final income = await DBService.getMonthlyIncome();
    final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
    final expenses = await DBService.getExpenses(month: currentMonth);
    final monthlySpend = expenses.fold<double>(0, (s, e) => s + e.amount);
    final base =
        monthlySpend > 0 ? monthlySpend : (income > 0 ? income * 0.5 : 5000.0);
    final recommended3 = base * 3;
    final recommended6 = base * 6;

    if (!mounted) return;
    int months = 3;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text("Emergency Fund"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "An emergency fund covers unexpected expenses — job loss, medical bills, repairs. "
                "Experts recommend 3–6 months of living expenses.",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text("Recommended target:",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setD(() => months = 3),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: months == 3
                              ? Theme.of(ctx)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: months == 3
                                ? Theme.of(ctx).colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text("3 months",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(CurrencyService.format(recommended3),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setD(() => months = 6),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: months == 6
                              ? Theme.of(ctx)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: months == 6
                                ? Theme.of(ctx).colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text("6 months",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(CurrencyService.format(recommended6),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final target = months == 3 ? recommended3 : recommended6;
                await DBService.insertGoal({
                  'name': 'Emergency Fund',
                  'purpose': '$months-month emergency buffer',
                  'target_amount': target,
                  'current_amount': 0.0,
                  'start_date':
                      DateTime.now().toIso8601String().substring(0, 10),
                  'created_at': DateTime.now().toIso8601String(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Emergency fund goal created: ${CurrencyService.format(months == 3 ? recommended3 : recommended6)}"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              child: const Text("Create Goal"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog({Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final purposeCtrl = TextEditingController(text: existing?['purpose'] ?? '');
    final targetCtrl = TextEditingController(
        text: existing != null
            ? (existing['target_amount'] as double).toStringAsFixed(0)
            : '');
    final savedCtrl = TextEditingController(
        text: existing != null
            ? (existing['current_amount'] as double).toStringAsFixed(0)
            : '0');
    String? startDate = existing?['start_date'] ??
        DateTime.now().toIso8601String().substring(0, 10);
    String? deadline = existing?['deadline'];

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
              Text(existing == null ? "New Savings Goal" : "Edit Goal",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: "Goal Name",
                  hintText: "e.g. New Phone, Vacation, Emergency Fund",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: purposeCtrl,
                decoration: InputDecoration(
                  labelText: "Purpose / Reason (optional)",
                  hintText: "e.g. Emergency backup, Loan repayment, Trip",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Target Amount",
                        prefixText: "${CurrencyService.symbol} ",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: savedCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Already Saved",
                        prefixText: "${CurrencyService.symbol} ",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: Text(startDate != null
                          ? "Start: $startDate"
                          : "Set Start Date"),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setSheet(() => startDate =
                              picked.toIso8601String().substring(0, 10));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.flag, size: 16),
                      label: Text(deadline ?? "Set Deadline"),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate:
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setSheet(() => deadline =
                              picked.toIso8601String().substring(0, 10));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final target = double.tryParse(targetCtrl.text);
                  final saved = double.tryParse(savedCtrl.text) ?? 0;
                  if (name.isEmpty || target == null || target <= 0) return;

                  final data = {
                    if (existing != null) 'id': existing['id'],
                    'name': name,
                    'purpose': purposeCtrl.text.trim().isEmpty
                        ? null
                        : purposeCtrl.text.trim(),
                    'target_amount': target,
                    'current_amount': saved,
                    'start_date': startDate,
                    'deadline': deadline,
                    'created_at': existing?['created_at'] ??
                        DateTime.now().toIso8601String(),
                  };

                  if (existing == null) {
                    await DBService.insertGoal(data);
                  } else {
                    await DBService.updateGoal(data);
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();

                  // Show contribution tip AFTER sheet closes (on main context)
                  if (deadline != null && target > saved) {
                    try {
                      final deadlineDate = DateTime.parse(deadline!);
                      final monthsLeft =
                          deadlineDate.difference(DateTime.now()).inDays / 30;
                      if (monthsLeft > 0 && mounted) {
                        final monthly = (target - saved) / monthsLeft;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "💡 Save ${CurrencyService.format(monthly)}/month to reach your goal by deadline"),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ));
                      }
                    } catch (_) {}
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(existing == null ? "Create Goal" : "Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addContribution(Map<String, dynamic> goal) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add to ${goal['name']}"),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Amount to add",
            prefixText: "${CurrencyService.symbol} ",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final add = double.tryParse(ctrl.text);
              if (add == null || add <= 0) return;
              final target = (goal['target_amount'] as num).toDouble();
              final prevAmount = (goal['current_amount'] as num).toDouble();
              final newAmount = (prevAmount + add).clamp(0.0, target);
              await DBService.updateGoal(
                  {...goal, 'current_amount': newAmount});
              if (mounted) Navigator.pop(context);
              _load();

              // GM-4: Milestone celebrations at 25/50/75/100%
              if (mounted && target > 0) {
                final prevPct = (prevAmount / target * 100).floor();
                final newPct = (newAmount / target * 100).floor();
                String? milestone;
                String? emoji;
                if (prevPct < 100 && newPct >= 100) {
                  milestone = "100% — Goal reached!";
                  emoji = "🎉";
                } else if (prevPct < 75 && newPct >= 75) {
                  milestone = "75% milestone!";
                  emoji = "🏅";
                } else if (prevPct < 50 && newPct >= 50) {
                  milestone = "Halfway there!";
                  emoji = "⭐";
                } else if (prevPct < 25 && newPct >= 25) {
                  milestone = "25% milestone!";
                  emoji = "🌱";
                }
                if (milestone != null) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("$emoji ${goal['name']}"),
                      content: Text(
                          "$milestone\n\n${CurrencyService.format(newAmount)} of ${CurrencyService.format(target)} saved."),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Keep it up! 💪"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Savings Goals"),
        actions: [
          const InfoButton(
            title: "Savings Goals",
            body:
                "A savings goal is a target amount you want to save up for — a new phone, a trip, an emergency fund, etc.\n\n"
                "Set a target amount and optional deadline. The app calculates how much you need to save per month to reach it.\n\n"
                "Tap the shield icon to auto-calculate an Emergency Fund based on your actual monthly spending.",
          ),
          IconButton(
            icon: const Icon(Icons.emergency_outlined),
            tooltip: "Emergency Fund",
            onPressed: _showEmergencyFundDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_savings_goals',
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: const Text("New Goal"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
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
                              Icon(Icons.savings_outlined,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              const Text("No savings goals yet.",
                                  style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              const Text("Tap + to create your first goal.",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text("Create a Goal"),
                                onPressed: () => _showAddDialog(),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon:
                                    const Icon(Icons.shield_outlined, size: 16),
                                label: const Text("Start Emergency Fund"),
                                onPressed: _showEmergencyFundDialog,
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
                    itemCount: _goals.length,
                    itemBuilder: (_, i) {
                      final g = _goals[i];
                      final target = (g['target_amount'] as num).toDouble();
                      final current = (g['current_amount'] as num).toDouble();
                      final ratio = (current / target).clamp(0.0, 1.0);
                      final done = current >= target;
                      final deadline = g['deadline'] as String?;

                      String? daysLeft;
                      if (deadline != null && !done) {
                        try {
                          final d = DateTime.parse(deadline);
                          final diff = d.difference(DateTime.now()).inDays;
                          daysLeft = diff > 0 ? "$diff days left" : "Overdue";
                        } catch (_) {}
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (done)
                                          const Icon(Icons.check_circle,
                                              color: Colors.green, size: 20),
                                        if (done) const SizedBox(width: 6),
                                        if (!done &&
                                            (g['name'] as String)
                                                .toLowerCase()
                                                .contains('emergency'))
                                          const Icon(Icons.shield,
                                              color: Colors.teal, size: 20),
                                        if (!done &&
                                            (g['name'] as String)
                                                .toLowerCase()
                                                .contains('emergency'))
                                          const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(g['name'] as String,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: (g['name'] as String)
                                                          .toLowerCase()
                                                          .contains('emergency')
                                                      ? Colors.teal
                                                      : null)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 20),
                                        onPressed: done
                                            ? null
                                            : () => _addContribution(g),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: "Add contribution",
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () =>
                                            _showAddDialog(existing: g),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18, color: Colors.grey),
                                        onPressed: () async {
                                          await DBService.deleteGoal(
                                              g['id'] as int);
                                          _load();
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Show purpose if set
                              if (g['purpose'] != null &&
                                  (g['purpose'] as String).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    g['purpose'] as String,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurface
                                            .withValues(alpha: 0.55),
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 10,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(done
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.primary),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${CurrencyService.format(current)} / ${CurrencyService.format(target)}",
                                    style: TextStyle(
                                        color:
                                            cs.onSurface.withValues(alpha: 0.7),
                                        fontSize: 13),
                                  ),
                                  Row(
                                    children: [
                                      if (daysLeft != null)
                                        Text(daysLeft,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: daysLeft == "Overdue"
                                                    ? Colors.red
                                                    : cs.onSurface.withValues(
                                                        alpha: 0.5))),
                                      if (done)
                                        const Text("Goal reached! 🎉",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              if (!done)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${(ratio * 100).toStringAsFixed(0)}% — ${CurrencyService.format(target - current)} to go",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: cs.onSurface
                                                .withValues(alpha: 0.5)),
                                      ),
                                      if (g['start_date'] != null)
                                        Text(
                                          "Since ${g['start_date']}",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: cs.onSurface
                                                  .withValues(alpha: 0.4)),
                                        ),
                                    ],
                                  ),
                                ),
                              // NI-2: Goal pace indicator
                              if (!done && deadline != null)
                                Builder(
                                  builder: (ctx) {
                                    try {
                                      final deadlineDate =
                                          DateTime.parse(deadline);
                                      final monthsLeft = deadlineDate
                                              .difference(DateTime.now())
                                              .inDays /
                                          30;
                                      if (monthsLeft <= 0)
                                        return const SizedBox.shrink();
                                      final needed =
                                          (target - current) / monthsLeft;
                                      // Estimate monthly contribution from income
                                      // We don't have income here, so just show the needed amount
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          "💡 Save ${CurrencyService.format(needed)}/month to reach goal by deadline",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: cs.primary
                                                  .withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    } catch (_) {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
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
