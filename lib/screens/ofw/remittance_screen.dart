import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/remittance.dart';
import '../../services/remittance_service.dart';
import '../../services/currency_service.dart';

const _currencies = ['USD', 'SAR', 'AED', 'SGD', 'HKD'];

class RemittanceScreen extends StatefulWidget {
  const RemittanceScreen({super.key});

  @override
  State<RemittanceScreen> createState() => _RemittanceScreenState();
}

class _RemittanceScreenState extends State<RemittanceScreen> {
  List<Remittance> _items = [];
  bool _loading = true;
  double _monthTotal = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await RemittanceService.getAll();
    final monthTotal = await RemittanceService.totalSentThisMonth();
    if (mounted) {
      setState(() {
        _items = items;
        _monthTotal = monthTotal;
        _loading = false;
      });
    }
  }

  Future<void> _openDialog({Remittance? existing}) async {
    final result = await showModalBottomSheet<Remittance>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _RemittanceForm(existing: existing),
    );
    if (result != null) {
      if (existing == null) {
        await RemittanceService.insert(result);
      } else {
        await RemittanceService.update(
            Remittance(
              id: existing.id,
              date: result.date,
              amount: result.amount,
              currency: result.currency,
              recipientName: result.recipientName,
              platform: result.platform,
              fee: result.fee,
              notes: result.notes,
            ));
      }
      _load();
    }
  }

  Future<void> _confirmDelete(Remittance r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Remittance'),
        content: Text('Remove remittance to ${r.recipientName}?'),
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
    if (ok == true && r.id != null) {
      await RemittanceService.delete(r.id!);
      _load();
    }
  }

  void _longPress(BuildContext ctx, Remittance r) {
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
                _openDialog(existing: r);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(r);
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
      appBar: AppBar(title: const Text('OFW Remittance Tracker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.send_to_mobile_outlined,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sent This Month',
                                  style: theme.textTheme.labelMedium),
                              Text(
                                CurrencyService.format(_monthTotal),
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send_to_mobile_outlined,
                                  size: 64,
                                  color: theme.colorScheme.outlineVariant),
                              const SizedBox(height: 12),
                              Text('No remittances yet',
                                  style: theme.textTheme.bodyLarge),
                              const SizedBox(height: 4),
                              Text('Tap + to add your first entry',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 4),
                          itemBuilder: (ctx, i) {
                            final r = _items[i];
                            return Card(
                              child: ListTile(
                                onLongPress: () => _longPress(ctx, r),
                                leading: CircleAvatar(
                                  backgroundColor: theme
                                      .colorScheme.secondaryContainer,
                                  child: Text(r.currency,
                                      style: const TextStyle(fontSize: 11)),
                                ),
                                title: Text(r.recipientName),
                                subtitle: Text(
                                  '${r.platform} · ${fmt.format(DateTime.parse(r.date))}'
                                  '${r.fee > 0 ? ' · Fee: ${CurrencyService.format(r.fee)}' : ''}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${r.currency} ${r.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      CurrencyService.format(r.amountPHP),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_remittance',
        onPressed: () => _openDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit form
// ---------------------------------------------------------------------------

class _RemittanceForm extends StatefulWidget {
  final Remittance? existing;
  const _RemittanceForm({this.existing});

  @override
  State<_RemittanceForm> createState() => _RemittanceFormState();
}

class _RemittanceFormState extends State<_RemittanceForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _recipientCtrl;
  late TextEditingController _platformCtrl;
  late TextEditingController _feeCtrl;
  late TextEditingController _notesCtrl;
  late String _currency;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _dateCtrl = TextEditingController(
        text: e?.date ?? DateTime.now().toIso8601String().substring(0, 10));
    _amountCtrl =
        TextEditingController(text: e != null ? e.amount.toString() : '');
    _recipientCtrl = TextEditingController(text: e?.recipientName ?? '');
    _platformCtrl = TextEditingController(text: e?.platform ?? '');
    _feeCtrl =
        TextEditingController(text: e != null && e.fee > 0 ? e.fee.toString() : '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _currency = e?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _amountCtrl.dispose();
    _recipientCtrl.dispose();
    _platformCtrl.dispose();
    _feeCtrl.dispose();
    _notesCtrl.dispose();
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
    final r = Remittance(
      date: _dateCtrl.text,
      amount: double.parse(_amountCtrl.text),
      currency: _currency,
      recipientName: _recipientCtrl.text.trim(),
      platform: _platformCtrl.text.trim(),
      fee: double.tryParse(_feeCtrl.text) ?? 0.0,
      notes: _notesCtrl.text.trim(),
    );
    Navigator.pop(context, r);
  }

  @override
  Widget build(BuildContext context) {
    final php = double.tryParse(_amountCtrl.text) != null
        ? RemittanceService.toPHP(
            double.parse(_amountCtrl.text), _currency)
        : null;

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
                widget.existing == null ? 'Add Remittance' : 'Edit Remittance',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Date
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                onTap: _pickDate,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Amount + currency row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _currency,
                    items: _currencies
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _currency = v);
                    },
                  ),
                ],
              ),
              if (php != null) ...[
                const SizedBox(height: 4),
                Text(
                  '≈ ${CurrencyService.format(php)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ],
              const SizedBox(height: 12),

              // Recipient
              TextFormField(
                controller: _recipientCtrl,
                decoration: const InputDecoration(
                  labelText: 'Recipient Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Platform
              TextFormField(
                controller: _platformCtrl,
                decoration: const InputDecoration(
                  labelText: 'Platform (e.g. Western Union, GCash Padala)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Fee
              TextFormField(
                controller: _feeCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Transfer Fee (optional)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (double.tryParse(v) == null) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.existing == null ? 'Save' : 'Update'),
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
