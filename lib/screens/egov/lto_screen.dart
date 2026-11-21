import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/db_service.dart';
import '../../services/egov/lto_service.dart';

class LTOScreen extends StatefulWidget {
  const LTOScreen({super.key});

  @override
  State<LTOScreen> createState() => _LTOScreenState();
}

class _LTOScreenState extends State<LTOScreen> {
  List<Map<String, dynamic>> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final db = await DBService.getDB();
    final rows = await db.query('lto_vehicles', orderBy: 'created_at DESC');
    if (mounted) {
      setState(() {
        _vehicles = rows;
        _loading = false;
      });
    }
  }

  int _plateLastDigit(String plateNumber) {
    final digits = plateNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.parse(digits[digits.length - 1]);
  }

  Color _daysColor(int days) {
    if (days < 30) return Colors.red;
    if (days < 60) return Colors.orange;
    return Colors.green;
  }

  void _showAddSheet({Map<String, dynamic>? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddVehicleSheet(
        existing: existing,
        onSaved: _loadVehicles,
      ),
    );
  }

  void _showDetail(Map<String, dynamic> vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VehicleDetailSheet(
        vehicle: vehicle,
        plateLastDigit: _plateLastDigit(vehicle['plate_number'] as String),
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text('Remove this vehicle from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final db = await DBService.getDB();
      await db.delete('lto_vehicles', where: 'id = ?', whereArgs: [id]);
      _loadVehicles();
    }
  }

  void _showCardOptions(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(vehicle['nickname'] as String),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _showAddSheet(existing: vehicle);
            },
            child: const Row(children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 10),
              Text('Edit'),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDelete(vehicle['id'] as int);
            },
            child: const Row(children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LTO Vehicle Renewal'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _vehicles.length,
                  itemBuilder: (_, i) => _buildCard(_vehicles[i]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No vehicles added yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your vehicle and track renewal dates.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> vehicle) {
    final plateNumber = vehicle['plate_number'] as String;
    final lastDigit = _plateLastDigit(plateNumber);
    final vehicleType = vehicle['vehicle_type'] as String? ?? 'Car';
    final weightKg = (vehicle['weight_kg'] as num?)?.toDouble() ?? 0.0;
    final yearModel = vehicle['year_model'] as int?;
    final fees = LTOService.computeRenewalFees(vehicleType, weightKg);
    final days = LTOService.getDaysUntilRenewal(lastDigit);
    final renewalMonth = LTOService.getRenewalMonthName(lastDigit);

    return GestureDetector(
      onTap: () => _showDetail(vehicle),
      onLongPress: () => _showCardOptions(vehicle),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vehicle['nickname'] as String,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plateNumber,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$vehicleType${yearModel != null ? ' • $yearModel' : ''}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Renewal: $renewalMonth',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    '$days days',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _daysColor(days),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Est. Fee: ₱${fees['total']!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ADD / EDIT SHEET ──────────────────────────────────────────────────────────

class AddVehicleSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final VoidCallback onSaved;

  const AddVehicleSheet({super.key, this.existing, required this.onSaved});

  @override
  State<AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _vehicleType = 'Car';
  bool _saving = false;

  static const List<String> _types = ['Car', 'Motorcycle', 'Truck', 'Van'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final v = widget.existing!;
      _nicknameCtrl.text = v['nickname'] as String? ?? '';
      _plateCtrl.text = v['plate_number'] as String? ?? '';
      _vehicleType = v['vehicle_type'] as String? ?? 'Car';
      _weightCtrl.text =
          ((v['weight_kg'] as num?)?.toDouble() ?? 0.0).toString();
      _yearCtrl.text = v['year_model']?.toString() ?? '';
      _notesCtrl.text = v['notes'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _plateCtrl.dispose();
    _weightCtrl.dispose();
    _yearCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final db = await DBService.getDB();
    final data = {
      'nickname': _nicknameCtrl.text.trim(),
      'plate_number': _plateCtrl.text.trim().toUpperCase(),
      'vehicle_type': _vehicleType,
      'weight_kg': double.tryParse(_weightCtrl.text.trim()) ?? 0.0,
      'year_model': int.tryParse(_yearCtrl.text.trim()),
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    };

    if (widget.existing != null) {
      await db.update(
        'lto_vehicles',
        data,
        where: 'id = ?',
        whereArgs: [widget.existing!['id']],
      );
    } else {
      data['created_at'] = DateTime.now().toIso8601String();
      await db.insert('lto_vehicles', data);
    }

    if (mounted) Navigator.pop(context);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 14),
                Text(
                  isEdit ? 'Edit Vehicle' : 'Add Vehicle',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nicknameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nickname',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _plateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Plate Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\- ]')),
                  ],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _vehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _vehicleType = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Year Model (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Save Changes' : 'Add Vehicle'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── VEHICLE DETAIL SHEET ──────────────────────────────────────────────────────

class VehicleDetailSheet extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final int plateLastDigit;

  const VehicleDetailSheet({
    super.key,
    required this.vehicle,
    required this.plateLastDigit,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleType = vehicle['vehicle_type'] as String? ?? 'Car';
    final weightKg = (vehicle['weight_kg'] as num?)?.toDouble() ?? 0.0;
    final fees = LTOService.computeRenewalFees(vehicleType, weightKg);
    final renewalMonth = LTOService.getRenewalMonthName(plateLastDigit);
    final days = LTOService.getDaysUntilRenewal(plateLastDigit);
    final yearModel = vehicle['year_model'] as int?;
    final notes = vehicle['notes'] as String?;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vehicle['nickname'] as String,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              vehicle['plate_number'] as String,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _row('Vehicle Type', vehicleType),
            if (yearModel != null) _row('Year Model', yearModel.toString()),
            _row('Weight', '${weightKg.toStringAsFixed(0)} kg'),
            if (notes != null && notes.isNotEmpty) _row('Notes', notes),
            const Divider(height: 24),
            const Text(
              'Renewal Schedule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _row('Renewal Month', renewalMonth),
            _row(
              'Days Until Renewal',
              '$days days',
              valueColor: days < 30
                  ? Colors.red
                  : days < 60
                      ? Colors.orange
                      : Colors.green,
            ),
            const Divider(height: 24),
            const Text(
              'Estimated Fee Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _row('MVUC Base', '₱${fees['mvuc']!.toStringAsFixed(2)}'),
            if ((fees['mvucSurcharge'] ?? 0) > 0)
              _row('MVUC Surcharge (Weight)',
                  '₱${fees['mvucSurcharge']!.toStringAsFixed(2)}'),
            _row('Registration Fee',
                '₱${fees['registrationFee']!.toStringAsFixed(2)}'),
            _row('CTPL Insurance',
                '₱${fees['ctplInsurance']!.toStringAsFixed(2)}'),
            const Divider(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₱${fees['total']!.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final vehicleId = vehicle['id'] as int;
                  final nickname = vehicle['nickname'] as String;
                  await LTOService.scheduleRenewalReminder(
                      vehicleId, plateLastDigit, nickname);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '✅ Reminder set for $nickname — 30 days before $renewalMonth renewal.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.alarm_add_outlined),
                label: const Text('Set Reminder'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
