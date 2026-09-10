import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/category_service.dart';

/// BatchManualEntryScreen — log up to 8 expenses in one session without AI.
///
/// Designed for when:
/// - AI is unavailable (key expired, daily limit reached)
/// - User has multiple items to log quickly (e.g., "I spent on 5 things today")
/// - Offline use — works 100% without internet
///
/// Each row has: Item Name | Amount | Category | Want/Need
/// User fills the rows they need and saves all at once.
class BatchManualEntryScreen extends StatefulWidget {
  const BatchManualEntryScreen({super.key});

  @override
  State<BatchManualEntryScreen> createState() => _BatchManualEntryScreenState();
}

class _BatchManualEntryScreenState extends State<BatchManualEntryScreen> {
  static const _maxRows = 8;

  List<String> _categories = CategoryService.builtIn;
  String _sharedDate = DateTime.now().toIso8601String().substring(0, 10);
  String _sharedPayment = 'Cash';
  bool _saving = false;

  // Each row: itemName, amount, category, isWant
  final List<_EntryRow> _rows = [_EntryRow(), _EntryRow(), _EntryRow()];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryService.getAll();
    if (mounted) setState(() => _categories = cats);
  }

  void _addRow() {
    if (_rows.length >= _maxRows) return;
    setState(() => _rows.add(_EntryRow()));
  }

  void _removeRow(int i) {
    if (_rows.length <= 1) return;
    // Dispose controllers of the removed row immediately to avoid memory leak
    final removed = _rows[i];
    removed.nameCtrl.dispose();
    removed.amountCtrl.dispose();
    setState(() => _rows.removeAt(i));
  }

  Future<void> _loadSuggestionsForRow(int i, String value) async {
    if (value.trim().length < 2) {
      if (_rows[i].suggestions.isNotEmpty) {
        setState(() => _rows[i].suggestions = []);
      }
      return;
    }
    final results =
        await DBService.getSuggestionsForItem(value.trim(), limit: 4);
    if (mounted &&
        i < _rows.length &&
        _rows[i].nameCtrl.text.trim() == value.trim()) {
      setState(() => _rows[i].suggestions = results);
    }
  }

  void _applySuggestionToRow(int i, Map<String, dynamic> s) {
    final name = s['item_name'] as String;
    final amount = (s['amount'] as num).toDouble();
    final category = s['category'] as String? ?? 'Others';
    final isWant = (s['is_want'] as int? ?? 0) == 1;
    _rows[i].nameCtrl.text = name;
    _rows[i].amountCtrl.text = amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    setState(() {
      _rows[i].category = _categories.contains(category) ? category : 'Others';
      _rows[i].isWant = isWant;
      _rows[i].suggestions = [];
    });
  }

  Future<void> _saveAll() async {
    final valid = _rows.where((r) {
      final amt = double.tryParse(r.amountCtrl.text.trim()) ?? 0;
      return amt > 0 && r.nameCtrl.text.trim().isNotEmpty;
    }).toList();

    if (valid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Fill in at least one row with a name and amount."),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    int saved = 0;

    for (final row in valid) {
      try {
        await DBService.insertExpense({
          'item_name': row.nameCtrl.text.trim(),
          'amount': double.parse(row.amountCtrl.text.trim()),
          'category': row.category,
          'date': _sharedDate,
          'time': now.toIso8601String().substring(11, 16),
          'payment_method': _sharedPayment,
          'is_want': row.isWant ? 1 : 0,
          'notes': 'Batch manual entry',
          'ai_generated': 0,
          'confidence_score': 1.0,
        });
        saved++;
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _saving = false);
      if (saved > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$saved expense${saved == 1 ? '' : 's'} saved ✓"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    // Only dispose rows still in the list — removed rows were disposed in _removeRow
    for (final r in _rows) {
      r.nameCtrl.dispose();
      r.amountCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Batch Add Expenses"),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveAll,
            child: Text("Save All",
                style:
                    TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Shared settings strip ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Row(
              children: [
                // Date picker
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.tryParse(_sharedDate) ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _sharedDate =
                            picked.toIso8601String().substring(0, 10));
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: cs.outline.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: cs.primary),
                          const SizedBox(width: 4),
                          Text(_sharedDate,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Payment method
                Expanded(
                  child: DropdownButton<String>(
                    value: _sharedPayment,
                    isExpanded: true,
                    underline: Container(
                        height: 1, color: cs.outline.withValues(alpha: 0.4)),
                    items: const [
                      'Cash',
                      'GCash',
                      'Maya',
                      'GrabPay',
                      'ShopeePay',
                      'Debit Card',
                      'Credit Card',
                      'Bank Transfer',
                      'Others'
                    ]
                        .map((p) => DropdownMenuItem(
                            value: p,
                            child:
                                Text(p, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) => setState(() => _sharedPayment = v!),
                  ),
                ),
              ],
            ),
          ),
          // ── Column headers ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
            child: Row(
              children: const [
                SizedBox(width: 28), // delete icon space
                SizedBox(width: 8),
                Expanded(
                    flex: 5,
                    child: Text("Item Name",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey))),
                SizedBox(width: 6),
                SizedBox(
                    width: 80,
                    child: Text("Amount ₱",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey))),
                SizedBox(width: 6),
                Expanded(
                    flex: 4,
                    child: Text("Category",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey))),
                SizedBox(width: 6),
                SizedBox(
                    width: 54,
                    child: Text("Type",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey))),
              ],
            ),
          ),
          // ── Entry rows ───────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: _rows.length,
              itemBuilder: (_, i) => _buildRow(i, cs),
            ),
          ),
          // ── Footer ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                if (_rows.length < _maxRows)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: Text("Add Row (${_rows.length}/$_maxRows)"),
                    onPressed: _addRow,
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save, size: 18),
                  label: const Text("Save All"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saving ? null : _saveAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int i, ColorScheme cs) {
    final row = _rows[i];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Delete row
          GestureDetector(
            onTap: () => _removeRow(i),
            child: Icon(Icons.remove_circle_outline,
                size: 20,
                color: _rows.length > 1 ? Colors.red[300] : Colors.grey[300]),
          ),
          const SizedBox(width: 6),
          // Item name
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: row.nameCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "e.g. Lunch",
                    hintStyle:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: cs.outline.withValues(alpha: 0.3))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: cs.outline.withValues(alpha: 0.3))),
                  ),
                  onChanged: (v) {
                    setState(() {});
                    _loadSuggestionsForRow(i, v);
                  },
                ),
                // Inline suggestion chips for this row
                if (row.suggestions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: row.suggestions.map((s) {
                        final name = s['item_name'] as String;
                        final amt = (s['amount'] as num).toDouble();
                        return GestureDetector(
                          onTap: () => _applySuggestionToRow(i, s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: cs.primary.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              "$name ₱${amt == amt.truncateToDouble() ? amt.toStringAsFixed(0) : amt.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Amount
          SizedBox(
            width: 80,
            child: TextField(
              controller: row.amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "0",
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: cs.outline.withValues(alpha: 0.3))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: cs.outline.withValues(alpha: 0.3))),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Category dropdown
          Expanded(
            flex: 4,
            child: DropdownButton<String>(
              value: _categories.contains(row.category)
                  ? row.category
                  : _categories.first,
              isExpanded: true,
              isDense: true,
              underline: Container(
                  height: 1, color: cs.outline.withValues(alpha: 0.35)),
              style: const TextStyle(fontSize: 12),
              items: _categories
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => row.category = v!),
            ),
          ),
          const SizedBox(width: 6),
          // Want / Need toggle — compact
          SizedBox(
            width: 54,
            child: GestureDetector(
              onTap: () => setState(() => row.isWant = !row.isWant),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: row.isWant
                      ? Colors.orange.withValues(alpha: 0.15)
                      : Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: row.isWant
                        ? Colors.orange.withValues(alpha: 0.4)
                        : Colors.teal.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  row.isWant ? "Want" : "Need",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: row.isWant ? Colors.orange : Colors.teal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow {
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String category = 'Others';
  bool isWant = false;
  // Per-row suggestion state
  List<Map<String, dynamic>> suggestions = [];
}
