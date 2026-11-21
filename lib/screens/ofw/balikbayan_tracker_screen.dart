import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/db_service.dart';

const _statuses = ['preparing', 'shipped', 'delivered'];

class BalikbayanTrackerScreen extends StatefulWidget {
  const BalikbayanTrackerScreen({super.key});

  @override
  State<BalikbayanTrackerScreen> createState() =>
      _BalikbayanTrackerScreenState();
}

class _BalikbayanTrackerScreenState extends State<BalikbayanTrackerScreen> {
  List<Map<String, dynamic>> _boxes = [];
  bool _loading = true;

  static const _createSql = '''
    CREATE TABLE IF NOT EXISTS balikbayan_boxes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      destination TEXT,
      date_sent TEXT,
      contents_list TEXT,
      estimated_value REAL,
      status TEXT
    )
  ''';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DBService.getDB();
    await db.execute(_createSql);
    final rows =
        await db.query('balikbayan_boxes', orderBy: 'date_sent DESC');
    if (mounted) {
      setState(() {
        _boxes = rows;
        _loading = false;
      });
    }
  }

  Future<void> _insert(Map<String, dynamic> data) async {
    final db = await DBService.getDB();
    await db.execute(_createSql);
    await db.insert('balikbayan_boxes', data);
    _load();
  }

  Future<void> _update(int id, Map<String, dynamic> data) async {
    final db = await DBService.getDB();
    await db.execute(_createSql);
    await db.update('balikbayan_boxes', data,
        where: 'id = ?', whereArgs: [id]);
    _load();
  }

  Future<void> _delete(int id) async {
    final db = await DBService.getDB();
    await db.execute(_createSql);
    await db.delete('balikbayan_boxes', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Future<void> _openAddDialog({Map<String, dynamic>? existing}) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BoxForm(existing: existing),
    );
    if (result != null) {
      if (existing == null) {
        await _insert(result);
      } else {
        await _update(existing['id'] as int, result);
      }
    }
  }

  void _showDetails(BuildContext ctx, Map<String, dynamic> box) {
    final fmt = DateFormat('MMM d, yyyy');
    final dateParsed = DateTime.tryParse(box['date_sent'] as String? ?? '');
    final dateStr =
        dateParsed != null ? fmt.format(dateParsed) : (box['date_sent'] ?? '—');
    final value = (box['estimated_value'] as num?)?.toDouble() ?? 0.0;
    final status = box['status'] as String? ?? 'preparing';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    box['destination'] as String? ?? '—',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    status,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: _statusColor(status),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _detailRow(ctx, Icons.calendar_today_outlined, 'Date Sent',
                dateStr.toString()),
            _detailRow(ctx, Icons.attach_money, 'Est. Value',
                '₱${value.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Contents',
                style: Theme.of(ctx)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              box['contents_list'] as String? ?? '—',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      BuildContext ctx, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(ctx).colorScheme.secondary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: Theme.of(ctx)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: Theme.of(ctx).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int id, String destination) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Box'),
        content: Text('Remove box to $destination?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) await _delete(id);
  }

  void _longPressMenu(BuildContext ctx, Map<String, dynamic> box) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(ctx);
                _openAddDialog(existing: box);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(
                    box['id'] as int, box['destination'] as String? ?? '');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Balikbayan Box Tracker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _boxes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.outlineVariant),
                      const SizedBox(height: 12),
                      Text('No boxes tracked yet',
                          style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Text('Tap + to add your first box',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _boxes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (ctx, i) {
                    final box = _boxes[i];
                    final status =
                        box['status'] as String? ?? 'preparing';
                    final dateParsed = DateTime.tryParse(
                        box['date_sent'] as String? ?? '');
                    final dateStr = dateParsed != null
                        ? fmt.format(dateParsed)
                        : (box['date_sent'] ?? '—');
                    final value =
                        (box['estimated_value'] as num?)?.toDouble() ?? 0.0;

                    return Card(
                      child: ListTile(
                        onTap: () => _showDetails(ctx, box),
                        onLongPress: () => _longPressMenu(ctx, box),
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.secondaryContainer,
                          child: const Icon(Icons.inventory_2_outlined,
                              size: 20),
                        ),
                        title: Text(
                            box['destination'] as String? ?? '—'),
                        subtitle: Text(
                            '$dateStr · ₱${value.toStringAsFixed(2)}'),
                        trailing: Chip(
                          label: Text(
                            status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: _statusColor(status),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_balikbayan',
        onPressed: () => _openAddDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Box'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit form
// ---------------------------------------------------------------------------

class _BoxForm extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const _BoxForm({this.existing});

  @override
  State<_BoxForm> createState() => _BoxFormState();
}

class _BoxFormState extends State<_BoxForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _destinationCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _contentsCtrl;
  late TextEditingController _valueCtrl;
  late String _status;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _destinationCtrl =
        TextEditingController(text: e?['destination'] as String? ?? '');
    _dateCtrl = TextEditingController(
        text: e?['date_sent'] as String? ??
            DateTime.now().toIso8601String().substring(0, 10));
    _contentsCtrl =
        TextEditingController(text: e?['contents_list'] as String? ?? '');
    _valueCtrl = TextEditingController(
        text: e != null
            ? (e['estimated_value'] as num?)?.toString() ?? ''
            : '');
    _status = e?['status'] as String? ?? 'preparing';
  }

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _dateCtrl.dispose();
    _contentsCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_dateCtrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'destination': _destinationCtrl.text.trim(),
      'date_sent': _dateCtrl.text,
      'contents_list': _contentsCtrl.text.trim(),
      'estimated_value': double.tryParse(_valueCtrl.text) ?? 0.0,
      'status': _status,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Box' : 'Add Box',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Destination
              TextFormField(
                controller: _destinationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'e.g. Cebu City, Philippines',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Date Sent
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date Sent',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                onTap: _pickDate,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Contents
              TextFormField(
                controller: _contentsCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Contents List',
                  hintText:
                      'e.g. Clothes, canned goods, chocolates',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Estimated Value
              TextFormField(
                controller: _valueCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Estimated Value (₱)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Status
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statuses
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                            s[0].toUpperCase() + s.substring(1))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Update' : 'Save'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
