import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/event_bus.dart';
import '../services/recurring_helper.dart';

/// Log Due Bills Screen — shows all overdue recurring items as a checklist.
/// User ticks what they want to log, adjusts amounts if needed, then saves all
/// in one tap. Much faster than logging each one individually via AI or manual form.
class LogDueBillsScreen extends StatefulWidget {
  const LogDueBillsScreen({super.key});

  @override
  State<LogDueBillsScreen> createState() => _LogDueBillsScreenState();
}

class _LogDueBillsScreenState extends State<LogDueBillsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _saving = false;
  Map<int, bool> _checked = {};
  final Map<int, TextEditingController> _amtCtrls = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _amtCtrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await DBService.getRecurring();
    final now = DateTime.now();
    // Include items due today or overdue
    final due = all.where((r) {
      if ((r['is_expense'] as int? ?? 1) != 1) return false;
      try {
        final d = DateTime.parse(r['next_date'] as String);
        return d.isBefore(now) ||
            (d.year == now.year && d.month == now.month && d.day == now.day);
      } catch (_) {
        return false;
      }
    }).toList();

    final ctrls = <int, TextEditingController>{};
    final checked = <int, bool>{};
    for (var i = 0; i < due.length; i++) {
      final amt = (due[i]['amount'] as num).toDouble();
      ctrls[i] = TextEditingController(
          text: amt == amt.truncateToDouble()
              ? amt.toStringAsFixed(0)
              : amt.toStringAsFixed(2));
      checked[i] = true; // default all ticked
    }

    if (mounted) {
      setState(() {
        _items = due;
        _checked = checked;
        _amtCtrls.addAll(ctrls);
        _loading = false;
      });
    }
  }

  Future<void> _saveSelected() async {
    final selected =
        _items.asMap().entries.where((e) => _checked[e.key] == true).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Tick at least one bill to log."),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    int saved = 0;

    for (final entry in selected) {
      final i = entry.key;
      final r = entry.value;
      final amt = double.tryParse(_amtCtrls[i]?.text.trim() ?? '') ??
          (r['amount'] as num).toDouble();
      if (amt <= 0) continue;

      await DBService.insertExpense({
        'item_name': r['title'],
        'category': r['category'],
        'amount': amt,
        'date': now.toIso8601String().substring(0, 10),
        'time': now.toIso8601String().substring(11, 16),
        'payment_method': 'Cash',
        'notes': 'Logged from Due Bills',
        'ai_generated': 0,
        'confidence_score': 1.0,
        'is_want': 0,
      });
      saved++;

      // Advance next_date
      try {
        final next = RecurringHelper.nextDate(r);
        if (next != null) {
          await DBService.updateRecurring({
            ...r,
            'next_date': next.toIso8601String().substring(0, 10),
          });
        }
      } catch (_) {}
    }

    fireEvent(AppEvent.expenseChanged);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$saved bill${saved == 1 ? '' : 's'} logged ✓"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Due Bills"),
        actions: [
          TextButton(
            onPressed: _loading || _saving ? null : _saveSelected,
            child: Text("Save All",
                style:
                    TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 56, color: Colors.green[400]),
                        const SizedBox(height: 16),
                        const Text("No bills due right now! 🎉",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          "All recurring bills are up to date.",
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.55)),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      color: cs.primaryContainer.withValues(alpha: 0.4),
                      child: Row(children: [
                        Icon(Icons.info_outline, size: 15, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${_items.length} bill${_items.length == 1 ? '' : 's'} due. "
                            "Tick what you want to log, adjust amounts if needed.",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final r = _items[i];
                          final title = r['title'] as String;
                          final category = r['category'] as String;
                          final freq = r['frequency'] as String? ?? 'monthly';
                          final nextDate = r['next_date'] as String? ?? '';
                          final daysOverdue = nextDate.isNotEmpty
                              ? DateTime.now()
                                  .difference(DateTime.tryParse(nextDate) ??
                                      DateTime.now())
                                  .inDays
                              : 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _checked[i] ?? false,
                                    onChanged: (v) => setState(
                                        () => _checked[i] = v ?? false),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        Text(
                                          "$category · $freq"
                                          "${daysOverdue > 0 ? ' · $daysOverdue days overdue' : ' · due today'}",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: daysOverdue > 0
                                                  ? Colors.red[400]
                                                  : Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Editable amount
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: _amtCtrls[i],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        prefixText: '₱',
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save, size: 18),
                          label: Text(
                              "Log ${_checked.values.where((v) => v).length} Selected Bills"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _saving ? null : _saveSelected,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
