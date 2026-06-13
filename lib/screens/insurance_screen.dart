import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  List<Map<String, dynamic>> _policies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final policies = await DBService.getInsurancePolicies();
    if (mounted)
      setState(() {
        _policies = policies;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insurance & Contributions"),
        actions: const [
          InfoButton(
            title: "Insurance & Contributions",
            body:
                "Track your insurance policies, government contributions (SSS, PhilHealth, Pag-IBIG), and premium due dates.\n\n"
                "• Add policies with premium amounts and due dates\n"
                "• Get reminders before premiums are due\n"
                "• Track coverage types and providers\n\n"
                "⚠️ Disclaimer: This is for tracking and education only — not insurance sales or financial advice.",
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _policies.isEmpty
              ? _buildEmptyState()
              : _buildPolicyList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPolicySheet,
        icon: const Icon(Icons.add),
        label: const Text("Add Policy"),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("No policies tracked yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              "Add your insurance policies, SSS, PhilHealth, or Pag-IBIG contributions to track premiums and due dates.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),
            // Quick-add buttons for common PH contributions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _quickAddChip("SSS", "SSS", "monthly", Icons.account_balance),
                _quickAddChip("PhilHealth", "PhilHealth", "monthly",
                    Icons.local_hospital),
                _quickAddChip("Pag-IBIG", "Pag-IBIG", "monthly", Icons.home),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAddChip(
      String label, String provider, String freq, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () =>
          _showAddPolicySheet(prefillProvider: provider, prefillFreq: freq),
    );
  }

  Widget _buildPolicyList() {
    // Group by type: Government, Health, Life, Others
    final govt = _policies
        .where((p) =>
            ['SSS', 'PhilHealth', 'Pag-IBIG', 'GSIS'].contains(p['provider']))
        .toList();
    final others = _policies
        .where((p) =>
            !['SSS', 'PhilHealth', 'Pag-IBIG', 'GSIS'].contains(p['provider']))
        .toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          // Summary card
          _buildSummaryCard(),
          const SizedBox(height: 16),
          if (govt.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text("Government Contributions",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
            ),
            ...govt.map(_buildPolicyCard),
            const SizedBox(height: 16),
          ],
          if (others.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text("Insurance Policies",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
            ),
            ...others.map(_buildPolicyCard),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    double totalMonthly = 0;
    int overdueCount = 0;
    for (final p in _policies) {
      final premium = (p['premium_amount'] as num?)?.toDouble() ?? 0;
      final freq = p['frequency'] as String? ?? 'monthly';
      // Normalize to monthly
      if (freq == 'monthly')
        totalMonthly += premium;
      else if (freq == 'quarterly')
        totalMonthly += premium / 3;
      else if (freq == 'yearly' || freq == 'annually')
        totalMonthly += premium / 12;

      final nextDue = p['next_due_date'] as String?;
      if (nextDue != null && nextDue.isNotEmpty) {
        try {
          if (DateTime.parse(nextDue).isBefore(DateTime.now())) overdueCount++;
        } catch (_) {}
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Monthly Premiums",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(CurrencyService.format(totalMonthly),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (overdueCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("$overdueCount overdue",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          if (overdueCount == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("All current ✓",
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(Map<String, dynamic> policy) {
    final name = policy['name'] as String? ?? 'Policy';
    final provider = policy['provider'] as String? ?? '';
    final premium = (policy['premium_amount'] as num?)?.toDouble() ?? 0;
    final freq = policy['frequency'] as String? ?? 'monthly';
    final nextDue = policy['next_due_date'] as String?;
    final type = policy['type'] as String? ?? 'other';

    bool isOverdue = false;
    String dueLabel = '';
    if (nextDue != null && nextDue.isNotEmpty) {
      try {
        final dueDate = DateTime.parse(nextDue);
        final daysLeft = dueDate.difference(DateTime.now()).inDays;
        if (daysLeft < 0) {
          isOverdue = true;
          dueLabel = '${-daysLeft} days overdue';
        } else if (daysLeft == 0) {
          dueLabel = 'Due today';
        } else if (daysLeft <= 7) {
          dueLabel = 'Due in $daysLeft days';
        } else {
          dueLabel = 'Due ${DateFormat('MMM d').format(dueDate)}';
        }
      } catch (_) {}
    }

    final icon = _getProviderIcon(provider, type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isOverdue
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.indigo.withValues(alpha: 0.1),
          child: Icon(icon,
              color: isOverdue ? Colors.red : Colors.indigo, size: 20),
        ),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.isNotEmpty)
              Text(provider,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Row(
              children: [
                Text("${CurrencyService.format(premium)}/$freq",
                    style: const TextStyle(fontSize: 12)),
                if (dueLabel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(dueLabel,
                        style: TextStyle(
                            fontSize: 10,
                            color: isOverdue ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'paid') {
              await _markPaid(policy);
            } else if (v == 'edit') {
              _showAddPolicySheet(editPolicy: policy);
            } else if (v == 'delete') {
              await DBService.deleteInsurancePolicy(policy['id'] as int);
              await _load();
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'paid', child: Text("Mark as Paid")),
            const PopupMenuItem(value: 'edit', child: Text("Edit")),
            const PopupMenuItem(value: 'delete', child: Text("Delete")),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(String provider, String type) {
    final lower = provider.toLowerCase();
    if (lower.contains('sss')) return Icons.account_balance;
    if (lower.contains('philhealth')) return Icons.local_hospital;
    if (lower.contains('pag-ibig') || lower.contains('pagibig'))
      return Icons.home;
    if (lower.contains('gsis')) return Icons.account_balance;
    if (type == 'health') return Icons.health_and_safety;
    if (type == 'life') return Icons.favorite;
    if (type == 'car' || type == 'vehicle') return Icons.directions_car;
    return Icons.shield_outlined;
  }

  Future<void> _markPaid(Map<String, dynamic> policy) async {
    final freq = policy['frequency'] as String? ?? 'monthly';
    final nextDue = policy['next_due_date'] as String?;
    if (nextDue == null) return;

    // Calculate next due date based on frequency
    DateTime current;
    try {
      current = DateTime.parse(nextDue);
    } catch (_) {
      current = DateTime.now();
    }

    DateTime next;
    switch (freq) {
      case 'weekly':
        next = current.add(const Duration(days: 7));
        break;
      case 'quarterly':
        next = DateTime(current.year, current.month + 3, current.day);
        break;
      case 'yearly':
      case 'annually':
        next = DateTime(current.year + 1, current.month, current.day);
        break;
      default: // monthly
        final nextMonth = current.month == 12 ? 1 : current.month + 1;
        final nextYear = current.month == 12 ? current.year + 1 : current.year;
        final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
        next = DateTime(nextYear, nextMonth, current.day.clamp(1, lastDay));
    }

    await DBService.updateInsurancePolicy({
      ...policy,
      'next_due_date': next.toIso8601String().substring(0, 10),
      'last_paid_date': DateTime.now().toIso8601String().substring(0, 10),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Marked as paid ✓ — next due ${DateFormat('MMM d, yyyy').format(next)}"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
    }
    await _load();
  }

  void _showAddPolicySheet({
    String? prefillProvider,
    String? prefillFreq,
    Map<String, dynamic>? editPolicy,
  }) {
    final nameCtrl =
        TextEditingController(text: editPolicy?['name'] as String? ?? '');
    final providerCtrl = TextEditingController(
        text: editPolicy?['provider'] as String? ?? prefillProvider ?? '');
    final premiumCtrl = TextEditingController(
        text: editPolicy != null
            ? (editPolicy['premium_amount'] as num).toString()
            : '');
    String frequency =
        editPolicy?['frequency'] as String? ?? prefillFreq ?? 'monthly';
    String type = editPolicy?['type'] as String? ?? 'government';
    DateTime? nextDue;
    if (editPolicy?['next_due_date'] != null) {
      try {
        nextDue = DateTime.parse(editPolicy!['next_due_date'] as String);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Text(
                    editPolicy != null
                        ? "Edit Policy"
                        : "Add Policy / Contribution",
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Policy Name",
                    hintText: "e.g. SSS Contribution, Sun Life VUL",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: providerCtrl,
                  decoration: InputDecoration(
                    labelText: "Provider",
                    hintText: "e.g. SSS, PhilHealth, Sun Life, AXA",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: premiumCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Premium Amount (${CurrencyService.symbol})",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: frequency,
                  decoration: InputDecoration(
                    labelText: "Frequency",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['monthly', 'quarterly', 'yearly']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => frequency = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(
                    labelText: "Type",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['government', 'health', 'life', 'car', 'other']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => type = v!),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: nextDue ??
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) setSheetState(() => nextDue = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Next Due Date",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(
                      nextDue != null
                          ? DateFormat('MMM d, yyyy').format(nextDue!)
                          : "Tap to select",
                      style: TextStyle(
                          color: nextDue != null ? null : Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final premium = double.tryParse(premiumCtrl.text.trim());
                    if (name.isEmpty || premium == null || premium <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text("Please fill in name and premium amount"),
                        behavior: SnackBarBehavior.floating,
                      ));
                      return;
                    }
                    final data = {
                      'name': name,
                      'provider': providerCtrl.text.trim(),
                      'premium_amount': premium,
                      'frequency': frequency,
                      'type': type,
                      'next_due_date':
                          nextDue?.toIso8601String().substring(0, 10),
                      'created_at': DateTime.now().toIso8601String(),
                    };
                    if (editPolicy != null) {
                      await DBService.updateInsurancePolicy({
                        ...data,
                        'id': editPolicy['id'],
                        'last_paid_date': editPolicy['last_paid_date'],
                      });
                    } else {
                      await DBService.insertInsurancePolicy(data);
                    }
                    if (mounted) Navigator.pop(ctx);
                    await _load();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      Text(editPolicy != null ? "Save Changes" : "Add Policy"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
