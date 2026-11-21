import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<Map<String, dynamic>> _investments = [];
  bool _loading = true;

  static const List<String> _types = [
    'PSE',
    'MP2',
    'UITF',
    'Bonds',
    'Crypto',
  ];

  static const List<Color> _typeColors = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFE65100),
    Color(0xFFF9A825),
  ];

  Color _colorForType(String type) {
    final idx = _types.indexOf(type);
    if (idx < 0) return Colors.grey;
    return _typeColors[idx % _typeColors.length];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await DBService.getInvestments();
    if (mounted) setState(() { _investments = rows; _loading = false; });
  }

  double get _totalInvested => _investments.fold(0.0, (sum, r) {
        final shares = (r['shares_or_units'] as num?)?.toDouble() ?? 0;
        final buy = (r['buy_price'] as num?)?.toDouble() ?? 0;
        return sum + shares * buy;
      });

  double get _currentValue => _investments.fold(0.0, (sum, r) {
        final shares = (r['shares_or_units'] as num?)?.toDouble() ?? 0;
        final cur = (r['current_price'] as num?)?.toDouble() ?? 0;
        return sum + shares * cur;
      });

  /// Current value grouped by investment type
  Map<String, double> get _valueByType {
    final map = <String, double>{};
    for (final r in _investments) {
      final type = r['type'] as String? ?? 'Other';
      final shares = (r['shares_or_units'] as num?)?.toDouble() ?? 0;
      final cur = (r['current_price'] as num?)?.toDouble() ?? 0;
      map[type] = (map[type] ?? 0) + shares * cur;
    }
    return map;
  }

  void _showForm({Map<String, dynamic>? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InvestmentForm(
        existing: existing,
        types: _types,
        onSaved: (data) async {
          if (existing != null) {
            await DBService.updateInvestment(existing['id'] as int, data);
          } else {
            await DBService.insertInvestment(data);
          }
          await _load();
        },
        onDeleted: existing == null
            ? null
            : () async {
                await DBService.deleteInvestment(existing['id'] as int);
                await _load();
              },
      ),
    );
  }

  void _showUpdatePriceDialog(Map<String, dynamic> inv) {
    final ctrl = TextEditingController(
        text: (inv['current_price'] as num?)?.toStringAsFixed(4) ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Price — ${inv['ticker'] ?? inv['name']}'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Current Market Price',
            prefixText: '₱ ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(ctrl.text);
              if (price == null || price < 0) return;
              Navigator.pop(ctx);
              await DBService.updateInvestment(
                  inv['id'] as int, {'current_price': price});
              await _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gainLoss = _currentValue - _totalInvested;
    final gainPct =
        _totalInvested > 0 ? (gainLoss / _totalInvested) * 100 : 0.0;
    final isPositive = gainLoss >= 0;
    final fmt = NumberFormat('#,##0.00');

    return Scaffold(
      appBar: AppBar(title: const Text('Investment Portfolio')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _investments.isEmpty
              ? _buildEmpty()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSummaryCard(
                        fmt, gainLoss, gainPct, isPositive),
                    const SizedBox(height: 16),
                    if (_currentValue > 0) _buildPieChart(),
                    const SizedBox(height: 16),
                    ..._investments.map((inv) => _buildInvestmentTile(inv, fmt)),
                    const SizedBox(height: 80),
                  ],
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No investments yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 6),
          Text('Tap + to add your first holding',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      NumberFormat fmt, double gainLoss, double gainPct, bool isPositive) {
    final gainColor = isPositive ? Colors.green[700]! : Colors.red[700]!;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Portfolio Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem('Total Invested', '₱${fmt.format(_totalInvested)}',
                    Colors.blueGrey),
                _summaryItem('Current Value',
                    '₱${fmt.format(_currentValue)}', Colors.blue),
                _summaryItem(
                  'Gain / Loss',
                  '${isPositive ? '+' : ''}₱${fmt.format(gainLoss)}\n'
                      '(${gainPct >= 0 ? '+' : ''}${gainPct.toStringAsFixed(2)}%)',
                  gainColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildPieChart() {
    final byType = _valueByType;
    final total = byType.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return const SizedBox.shrink();

    final entries = byType.entries.toList();
    final sections = entries.map((e) {
      final pct = (e.value / total) * 100;
      final color = _colorForType(e.key);
      return PieChartSectionData(
        value: e.value,
        title: '${e.key}\n${pct.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        color: color,
        radius: 70,
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Allocation by Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: entries.map((e) {
                final pct = (e.value / total * 100).toStringAsFixed(1);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colorForType(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('${e.key} $pct%',
                        style: const TextStyle(fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentTile(
      Map<String, dynamic> inv, NumberFormat fmt) {
    final shares = (inv['shares_or_units'] as num?)?.toDouble() ?? 0;
    final buy = (inv['buy_price'] as num?)?.toDouble() ?? 0;
    final cur = (inv['current_price'] as num?)?.toDouble() ?? 0;
    final gainPerUnit = cur - buy;
    final isPos = gainPerUnit >= 0;
    final gainColor = isPos ? Colors.green[700]! : Colors.red[700]!;
    final type = inv['type'] as String? ?? '';
    final ticker = inv['ticker'] as String? ?? '';
    final name = inv['name'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showForm(existing: inv),
        onLongPress: () => _showUpdatePriceDialog(inv),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _colorForType(type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    type.length > 2 ? type.substring(0, 2) : type,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _colorForType(type)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticker.isNotEmpty ? ticker : name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (ticker.isNotEmpty && name.isNotEmpty)
                      Text(name,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    Text(
                      '${shares % 1 == 0 ? shares.toInt() : shares.toStringAsFixed(4)} units · Buy ₱${fmt.format(buy)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₱${fmt.format(cur)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    '${isPos ? '+' : ''}₱${fmt.format(gainPerUnit)} / unit',
                    style: TextStyle(fontSize: 11, color: gainColor),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.update, size: 18, color: Colors.grey[600]),
                tooltip: 'Update Price',
                onPressed: () => _showUpdatePriceDialog(inv),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add / Edit investment bottom sheet ───────────────────────────────────────

class _InvestmentForm extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final List<String> types;
  final Future<void> Function(Map<String, dynamic>) onSaved;
  final VoidCallback? onDeleted;

  const _InvestmentForm({
    this.existing,
    required this.types,
    required this.onSaved,
    this.onDeleted,
  });

  @override
  State<_InvestmentForm> createState() => _InvestmentFormState();
}

class _InvestmentFormState extends State<_InvestmentForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _tickerCtrl;
  late final TextEditingController _sharesCtrl;
  late final TextEditingController _buyPriceCtrl;
  late final TextEditingController _curPriceCtrl;
  late final TextEditingController _notesCtrl;

  String _selectedType = 'PSE';
  DateTime? _buyDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?['name'] as String? ?? '');
    _tickerCtrl = TextEditingController(text: e?['ticker'] as String? ?? '');
    _sharesCtrl = TextEditingController(
        text: e != null
            ? (e['shares_or_units'] as num?)?.toString() ?? ''
            : '');
    _buyPriceCtrl = TextEditingController(
        text: e != null ? (e['buy_price'] as num?)?.toString() ?? '' : '');
    _curPriceCtrl = TextEditingController(
        text: e != null
            ? (e['current_price'] as num?)?.toString() ?? ''
            : '');
    _notesCtrl = TextEditingController(text: e?['notes'] as String? ?? '');
    _selectedType =
        (e?['type'] as String?) ?? widget.types.first;
    final dateStr = e?['buy_date'] as String?;
    if (dateStr != null && dateStr.isNotEmpty) {
      _buyDate = DateTime.tryParse(dateStr);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tickerCtrl.dispose();
    _sharesCtrl.dispose();
    _buyPriceCtrl.dispose();
    _curPriceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _buyDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _buyDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'type': _selectedType,
      'ticker': _tickerCtrl.text.trim(),
      'shares_or_units': double.tryParse(_sharesCtrl.text) ?? 0,
      'buy_price': double.tryParse(_buyPriceCtrl.text) ?? 0,
      'current_price': double.tryParse(_curPriceCtrl.text) ?? 0,
      'buy_date': _buyDate?.toIso8601String().substring(0, 10) ?? '',
      'notes': _notesCtrl.text.trim(),
    };
    await widget.onSaved(data);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(isEdit ? 'Edit Investment' : 'Add Investment',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Name', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                      labelText: 'Type', border: OutlineInputBorder()),
                  items: widget.types
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                ),
                const SizedBox(height: 12),

                // Ticker
                TextFormField(
                  controller: _tickerCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Ticker / Symbol (optional)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),

                // Shares / Units
                TextFormField(
                  controller: _sharesCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Shares / Units',
                      border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Enter a number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Buy price
                TextFormField(
                  controller: _buyPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Buy Price',
                      prefixText: '₱ ',
                      border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Enter a number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Current price
                TextFormField(
                  controller: _curPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Current Price',
                      prefixText: '₱ ',
                      border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Enter a number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Buy date picker
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Buy Date',
                        border: OutlineInputBorder()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_buyDate != null
                            ? DateFormat('MMM d, yyyy').format(_buyDate!)
                            : 'Select date'),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Notes
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    if (isEdit && widget.onDeleted != null) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onDeleted!();
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                        label: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red)),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : Text(isEdit ? 'Save Changes' : 'Add Investment'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
