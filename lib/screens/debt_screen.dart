import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Map<String, dynamic>> _owe = [];
  List<Map<String, dynamic>> _lent = [];
  List<Map<String, dynamic>> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final owe = await DBService.getDebts(type: 'owe');
    final lent = await DBService.getDebts(type: 'lent');
    List<Map<String, dynamic>> plans = [];
    try {
      final db = await DBService.getDB();
      plans = await db.query('installment_plans', orderBy: 'created_at DESC');
    } catch (_) {}
    setState(() {
      _owe = owe;
      _lent = lent;
      _plans = plans;
      _loading = false;
    });
  }

  void _showAddDialog(
      {Map<String, dynamic>? existing, String defaultType = 'owe'}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final personCtrl = TextEditingController(text: existing?['person'] ?? '');
    final amountCtrl = TextEditingController(
        text: existing != null
            ? (existing['amount'] as double).toStringAsFixed(0)
            : '');
    final notesCtrl = TextEditingController(text: existing?['notes'] ?? '');
    final interestCtrl = TextEditingController(
        text: existing?['interest_rate'] != null
            ? (existing!['interest_rate'] as double).toStringAsFixed(1)
            : '');
    String type = existing?['type'] ?? defaultType;
    String? dueDate = existing?['due_date'];

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
              Text(existing == null ? "Add Debt" : "Edit Debt",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Type toggle
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'owe',
                      label: Text("I Owe"),
                      icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(
                      value: 'lent',
                      label: Text("They Owe Me"),
                      icon: Icon(Icons.arrow_downward)),
                ],
                selected: {type},
                onSelectionChanged: (s) => setSheet(() => type = s.first),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "e.g. Borrowed for groceries",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: personCtrl,
                decoration: InputDecoration(
                  labelText: type == 'owe'
                      ? "Owed to (person/company)"
                      : "Owed by (person)",
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
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(dueDate ?? "Set Due Date (optional)"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setSheet(() =>
                        dueDate = picked.toIso8601String().substring(0, 10));
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: "Notes (optional)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: interestCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Interest Rate % (optional)",
                  hintText: "e.g. 5 for 5%",
                  suffixText: "%",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final person = personCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text);
                  if (title.isEmpty ||
                      person.isEmpty ||
                      amount == null ||
                      amount <= 0) return;

                  final data = {
                    if (existing != null) 'id': existing['id'],
                    'title': title,
                    'person': person,
                    'amount': amount,
                    'paid_amount': existing?['paid_amount'] ?? 0.0,
                    'type': type,
                    'due_date': dueDate,
                    'notes': notesCtrl.text.trim().isEmpty
                        ? null
                        : notesCtrl.text.trim(),
                    'interest_rate': double.tryParse(interestCtrl.text),
                    'created_at': existing?['created_at'] ??
                        DateTime.now().toIso8601String(),
                  };

                  if (existing == null) {
                    await DBService.insertDebt(data);
                  } else {
                    await DBService.updateDebt(data);
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

  void _markPayment(Map<String, dynamic> debt) {
    final ctrl = TextEditingController();
    final remaining =
        (debt['amount'] as double) - (debt['paid_amount'] as double);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Record Payment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Remaining: ${CurrencyService.format(remaining)}",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount paid",
                prefixText: "${CurrencyService.symbol} ",
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final paid = double.tryParse(ctrl.text);
              if (paid == null || paid <= 0) return;
              final newPaid = ((debt['paid_amount'] as double) + paid)
                  .clamp(0.0, debt['amount'] as double);
              await DBService.updateDebt({...debt, 'paid_amount': newPaid});
              if (mounted) Navigator.pop(context);
              _load();
            },
            child: const Text("Record"),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      List<Map<String, dynamic>> items, String emptyMsg, Color accentColor) {
    final cs = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.handshake_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(emptyMsg, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Track money you owe or lent. Set due dates to get reminders.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                        "💡 Or tell the AI: \"I borrowed ₱500 from Juan\"",
                        style: TextStyle(color: Colors.blue, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final total = items.fold<double>(0,
        (s, d) => s + ((d['amount'] as double) - (d['paid_amount'] as double)));

    return RefreshIndicator(
      onRefresh: _load,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: accentColor.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Total: ",
                    style:
                        TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
                Text(CurrencyService.format(total),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: accentColor)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final d = items[i];
                final amount = d['amount'] as double;
                final paid = d['paid_amount'] as double;
                final remaining = amount - paid;
                final done = remaining <= 0;
                final ratio = (paid / amount).clamp(0.0, 1.0);
                final dueDate = d['due_date'] as String?;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (done)
                                        const Icon(Icons.check_circle,
                                            color: Colors.green, size: 16),
                                      if (done) const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(d['title'] as String,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  Text(d['person'] as String,
                                      style: TextStyle(
                                          color: cs.onSurface
                                              .withValues(alpha: 0.6),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                if (!done)
                                  TextButton(
                                    onPressed: () => _markPayment(d),
                                    child: const Text("Pay"),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 16),
                                  onPressed: () => _showAddDialog(existing: d),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16, color: Colors.grey),
                                  onPressed: () async {
                                    await DBService.deleteDebt(d['id'] as int);
                                    _load();
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                                done ? Colors.green : accentColor),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              done
                                  ? "Fully paid ✓"
                                  : "${CurrencyService.format(paid)} paid — ${CurrencyService.format(remaining)} left",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: done
                                      ? Colors.green
                                      : cs.onSurface.withValues(alpha: 0.6)),
                            ),
                            if (dueDate != null && !done)
                              Text(
                                () {
                                  try {
                                    return "Due: ${DateFormat('MMM d, y').format(DateTime.parse(dueDate))}";
                                  } catch (_) {
                                    return "Due: $dueDate";
                                  }
                                }(),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: DateTime.tryParse(dueDate)
                                                ?.isBefore(DateTime.now()) ==
                                            true
                                        ? Colors.red
                                        : cs.onSurface.withValues(alpha: 0.5)),
                              ),
                            if (d['interest_rate'] != null &&
                                (d['interest_rate'] as num) > 0) ...[
                              Text(
                                "${(d['interest_rate'] as num).toStringAsFixed(1)}% interest",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.orange[700]),
                              ),
                              // DT-1: Interest projection
                              Builder(builder: (ctx) {
                                final rate =
                                    (d['interest_rate'] as num).toDouble();
                                final rem = (d['amount'] as double) -
                                    (d['paid_amount'] as double);
                                if (rem <= 0) return const SizedBox.shrink();
                                final totalInterest = rem * (rate / 100);
                                return Text(
                                  "≈ ${CurrencyService.format(totalInterest)} total interest",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.orange[600]),
                                );
                              }),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPlanDialog({Map<String, dynamic>? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final providerCtrl =
        TextEditingController(text: existing?['provider'] ?? '');
    final totalCtrl = TextEditingController(
        text: existing != null
            ? (existing['total_amount'] as num).toStringAsFixed(0)
            : '');
    final monthlyCtrl = TextEditingController(
        text: existing != null
            ? (existing['monthly_payment'] as num).toStringAsFixed(0)
            : '');
    final monthsCtrl = TextEditingController(
        text: existing != null
            ? (existing['months_total'] as int).toString()
            : '');
    final interestCtrl = TextEditingController(
        text: existing?['interest_rate'] != null
            ? (existing!['interest_rate'] as num).toStringAsFixed(1)
            : '');
    final notesCtrl = TextEditingController(text: existing?['notes'] ?? '');
    int dueDay = existing?['due_day'] as int? ?? 5;
    String startDate = existing?['start_date'] ??
        DateTime.now().toIso8601String().substring(0, 10);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(existing == null ? "Add Payment Plan" : "Edit Payment Plan",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("For ShopeePayLater, GCash GLoan, HomeCredit, etc.",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "Plan name",
                  hintText: "e.g. Online Shopping",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: providerCtrl,
                decoration: InputDecoration(
                  labelText: "Provider (optional)",
                  hintText: "e.g. ShopeePayLater, GCash GLoan",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: totalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Total amount",
                        prefixText: "${CurrencyService.symbol} ",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) {
                        final total = double.tryParse(v) ?? 0;
                        final months = int.tryParse(monthsCtrl.text) ?? 0;
                        if (total > 0 && months > 0) {
                          monthlyCtrl.text =
                              (total / months).toStringAsFixed(0);
                          setSheet(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: monthsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Months",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) {
                        final total = double.tryParse(totalCtrl.text) ?? 0;
                        final months = int.tryParse(v) ?? 0;
                        if (total > 0 && months > 0) {
                          monthlyCtrl.text =
                              (total / months).toStringAsFixed(0);
                          setSheet(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: monthlyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Monthly payment",
                  prefixText: "${CurrencyService.symbol} ",
                  helperText: "Auto-computed from total ÷ months",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Due on the", style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: dueDay,
                    items: List.generate(
                        28,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text("${i + 1}th"))),
                    onChanged: (v) => setSheet(() => dueDay = v ?? dueDay),
                  ),
                  const SizedBox(width: 8),
                  const Text("of each month", style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: interestCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Interest rate % (optional)",
                  suffixText: "%",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.play_circle_outline, size: 16),
                label: Text("Start date: $startDate"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.tryParse(startDate) ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setSheet(() =>
                        startDate = picked.toIso8601String().substring(0, 10));
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: "Notes (optional)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final total = double.tryParse(totalCtrl.text);
                  final monthly = double.tryParse(monthlyCtrl.text);
                  final months = int.tryParse(monthsCtrl.text);
                  if (title.isEmpty ||
                      total == null ||
                      total <= 0 ||
                      monthly == null ||
                      monthly <= 0 ||
                      months == null ||
                      months <= 0) return;
                  final data = {
                    if (existing != null) 'id': existing['id'],
                    'title': title,
                    'provider': providerCtrl.text.trim().isEmpty
                        ? null
                        : providerCtrl.text.trim(),
                    'total_amount': total,
                    'monthly_payment': monthly,
                    'months_total': months,
                    'months_paid': existing?['months_paid'] ?? 0,
                    'due_day': dueDay,
                    'interest_rate': double.tryParse(interestCtrl.text),
                    'start_date': startDate,
                    'category': 'Bills',
                    'notes': notesCtrl.text.trim().isEmpty
                        ? null
                        : notesCtrl.text.trim(),
                    'created_at': existing?['created_at'] ??
                        DateTime.now().toIso8601String(),
                  };
                  if (existing == null) {
                    await DBService.insertInstallmentPlan(data);
                  } else {
                    await DBService.updateInstallmentPlan(
                        {...data, 'id': existing['id']});
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(existing == null ? "Add Plan" : "Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logPlanPayment(Map<String, dynamic> plan) async {
    final monthly = (plan['monthly_payment'] as num).toDouble();
    final title = plan['title'] as String;
    final provider = plan['provider'] as String?;
    final label = provider != null ? "$title ($provider)" : title;

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Log payment for $label?",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Amount: ${CurrencyService.format(monthly)}",
                style: const TextStyle(fontSize: 14)),
            Text("Category: Bills",
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            Text("Date: ${DateTime.now().toIso8601String().substring(0, 10)}",
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    final now = DateTime.now();
    await DBService.insertExpense({
      'item_name': '$label payment',
      'category': 'Bills',
      'amount': monthly,
      'date': now.toIso8601String().substring(0, 10),
      'time': now.toIso8601String().substring(11, 16),
      'payment_method': 'Cash',
      'notes': 'Payment plan installment',
      'ai_generated': 0,
      'confidence_score': 1.0,
    });

    final newPaid = (plan['months_paid'] as int) + 1;
    final monthsTotal = plan['months_total'] as int;
    await DBService.updateInstallmentPlan({...plan, 'months_paid': newPaid});

    if (mounted) {
      if (newPaid >= monthsTotal) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("🎉 $label fully paid off!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Payment logged ✓ — $newPaid/$monthsTotal months paid"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
      _load();
    }
  }

  Widget _buildPlansTab() {
    final cs = Theme.of(context).colorScheme;
    if (_plans.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.credit_score_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    const Text("No payment plans yet.",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Track ShopeePayLater, GCash GLoan, HomeCredit, and other fixed monthly payment plans.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final activePlans = _plans
        .where((p) => (p['months_paid'] as int) < (p['months_total'] as int))
        .toList();
    final donePlans = _plans
        .where((p) => (p['months_paid'] as int) >= (p['months_total'] as int))
        .toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          if (activePlans.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text("Active (${activePlans.length})",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600])),
            ),
            ...activePlans.map((p) => _buildPlanCard(p, cs)),
          ],
          if (donePlans.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 12),
              child: Text("Completed (${donePlans.length})",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600])),
            ),
            ...donePlans.map((p) => _buildPlanCard(p, cs)),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> p, ColorScheme cs) {
    final monthsPaid = p['months_paid'] as int;
    final monthsTotal = p['months_total'] as int;
    final monthly = (p['monthly_payment'] as num).toDouble();
    final total = (p['total_amount'] as num).toDouble();
    final remaining = ((monthsTotal - monthsPaid) * monthly).clamp(0.0, total);
    final ratio = (monthsPaid / monthsTotal).clamp(0.0, 1.0);
    final done = monthsPaid >= monthsTotal;
    final provider = p['provider'] as String?;
    final dueDay = p['due_day'] as int? ?? 5;
    final interestRate = (p['interest_rate'] as num?)?.toDouble();

    final now = DateTime.now();
    DateTime nextDue = DateTime(now.year, now.month, dueDay);
    if (nextDue.isBefore(now))
      nextDue = DateTime(now.year, now.month + 1, dueDay);
    final daysUntil = nextDue.difference(now).inDays;
    final dueLabel = daysUntil == 0
        ? "Due today"
        : daysUntil < 0
            ? "Overdue"
            : "Due in $daysUntil days";

    String? interestStr;
    if (interestRate != null && interestRate > 0 && !done) {
      final totalInterest = remaining * (interestRate / 100);
      interestStr = "≈ ${CurrencyService.format(totalInterest)} total interest";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (done)
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                          if (done) const SizedBox(width: 4),
                          Expanded(
                            child: Text(p['title'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      if (provider != null)
                        Text(provider,
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
                if (!done)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 14),
                    label: const Text("Log Payment",
                        style: TextStyle(fontSize: 12)),
                    onPressed: () => _logPlanPayment(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => _showAddPlanDialog(existing: p),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.grey),
                  onPressed: () async {
                    await DBService.deleteInstallmentPlan(p['id'] as int);
                    _load();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation(done ? Colors.green : Colors.purple),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  done
                      ? "Fully paid ✓"
                      : "$monthsPaid / $monthsTotal months paid",
                  style: TextStyle(
                      fontSize: 12,
                      color: done
                          ? Colors.green
                          : cs.onSurface.withValues(alpha: 0.6)),
                ),
                Text(
                  done
                      ? CurrencyService.format(total)
                      : "${CurrencyService.format(monthly)}/mo",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (!done) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${CurrencyService.format(remaining)} remaining",
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                  Text(
                    dueLabel,
                    style: TextStyle(
                        fontSize: 11,
                        color: daysUntil <= 3
                            ? Colors.orange
                            : cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
              if (interestStr != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(interestStr,
                      style:
                          TextStyle(fontSize: 11, color: Colors.orange[700])),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debts & Lending"),
        actions: [
          const InfoButton(
            title: "Debts & Lending",
            body:
                "Track money you owe others (I Owe tab) and money others owe you (Owed to Me tab).\n\n"
                "• Payment Plans tab — track ShopeePayLater, GCash GLoan, HomeCredit, etc.\n"
                "• Set a due date to get a reminder notification 7 days before\n"
                "• Tap 'Pay' to record partial or full payments\n"
                "• The progress bar shows how much has been paid\n"
                "• Plans tab — track ShopeePayLater, GCash GLoan, HomeCredit, and any fixed monthly payment plan",
          ),
          IconButton(
            icon: const Icon(Icons.credit_score_outlined),
            tooltip: "Payment Plans",
            onPressed: () {
              // Jump to Plans tab
              _tabs.animateTo(2);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: "I Owe", icon: Icon(Icons.arrow_upward, size: 16)),
            Tab(text: "Owed to Me", icon: Icon(Icons.arrow_downward, size: 16)),
            Tab(
                text: "Plans",
                icon: Icon(Icons.credit_score_outlined, size: 16)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_debt',
        onPressed: () {
          if (_tabs.index == 2) {
            _showAddPlanDialog();
          } else {
            _showAddDialog(defaultType: _tabs.index == 0 ? 'owe' : 'lent');
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _buildList(_owe, "No debts recorded.", Colors.redAccent),
                _buildList(_lent, "No lending recorded.", Colors.green),
                _buildPlansTab(),
              ],
            ),
    );
  }
}
