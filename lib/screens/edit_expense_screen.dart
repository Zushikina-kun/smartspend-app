import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/category_service.dart';
import '../widgets/info_button.dart';
import 'package:image_picker/image_picker.dart';

const _paymentMethods = [
  'Cash',
  'GCash',
  'Maya',
  'GrabPay',
  'ShopeePay',
  'Debit Card',
  'Credit Card',
  'Bank Transfer',
  'Others',
];

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _itemNameCtrl;
  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _notesCtrl;
  late String _selectedCategory;
  late String _selectedPayment;
  late bool _isWant;
  bool _saving = false;
  List<String> _categories = CategoryService.builtIn;
  String? _photoPath;
  List<String> _tags = [];
  final _tagInputCtrl = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final amt = widget.expense.amount;
    _amountCtrl = TextEditingController(
        text: amt == amt.truncateToDouble()
            ? amt.toStringAsFixed(0)
            : amt.toStringAsFixed(2));
    _itemNameCtrl = TextEditingController(text: widget.expense.itemName);
    _shopNameCtrl = TextEditingController(text: widget.expense.shopName ?? '');
    _notesCtrl = TextEditingController(text: widget.expense.notes ?? '');
    _selectedCategory = widget.expense.category;
    _selectedPayment = widget.expense.paymentMethod ?? 'Cash';
    _isWant = (widget.expense.isWant ?? false);
    _photoPath = widget.expense.photoPath;
    // Parse date and time from expense
    try {
      _selectedDate = DateTime.parse(widget.expense.date);
    } catch (_) {
      _selectedDate = DateTime.now();
    }
    if (widget.expense.time != null && widget.expense.time!.isNotEmpty) {
      try {
        final parts = widget.expense.time!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (_) {
        _selectedTime = TimeOfDay.now();
      }
    } else {
      _selectedTime = TimeOfDay.now();
    }
    // Load existing tags
    final existingTags = widget.expense.tags ?? '';
    _tags = existingTags.isNotEmpty
        ? existingTags.split(',').where((t) => t.isNotEmpty).toList()
        : [];
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryService.getAll();
    if (mounted) {
      setState(() {
        _categories = cats;
        // If expense has a category not in list (e.g. old custom), keep it
        if (!_categories.contains(_selectedCategory)) {
          _categories = [..._categories, _selectedCategory];
        }
      });
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _itemNameCtrl.dispose();
    _shopNameCtrl.dispose();
    _notesCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter a valid amount.")));
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = widget.expense.copyWith(
        itemName: _itemNameCtrl.text.trim(),
        amount: amount,
        category: _selectedCategory,
        paymentMethod: _selectedPayment,
        shopName: _shopNameCtrl.text.trim().isEmpty
            ? null
            : _shopNameCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        isWant: _isWant,
        photoPath: _photoPath,
        tags: _tags.isEmpty ? null : _tags.join(','),
        date: _selectedDate.toIso8601String().substring(0, 10),
        time:
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
      );
      await DBService.updateExpense(updated);

      // UD-4b: If category changed, offer to create an auto-categorization rule
      if (widget.expense.category != _selectedCategory &&
          widget.expense.itemName.isNotEmpty &&
          mounted) {
        final keyword = widget.expense.itemName.toLowerCase().split(' ').first;
        if (keyword.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Add rule: "$keyword" → $_selectedCategory?'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: "Add Rule",
              onPressed: () async {
                await DBService.insertCategoryRule(keyword, _selectedCategory);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Rule added ✓"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
            ),
          ));
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to save: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Expense"),
        actions: const [
          InfoButton(
            title: "Edit Expense",
            body: "Update any field on this expense.\n\n"
                "Changes are saved immediately to your local database and synced to the cloud.\n\n"
                "Correcting the category here can also create an auto-rule so future similar expenses are categorized automatically.",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(_itemNameCtrl, "Item Name", Icons.label_outline),
            const SizedBox(height: 14),
            _field(_amountCtrl, "Amount (${CurrencyService.symbol})",
                Icons.attach_money,
                type: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 14),
            // Date & Time picker row
            _buildDateTimeRow(),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : _categories.first,
              decoration: _deco("Category", Icons.category),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 14),
            // Want vs Need toggle
            Row(
              children: [
                const Icon(Icons.label_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                const Text("Tag:",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Need"),
                  selected: !_isWant,
                  onSelected: (_) => setState(() => _isWant = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("Want"),
                  selected: _isWant,
                  onSelected: (_) => setState(() => _isWant = true),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedPayment,
              decoration: _deco("Payment Method", Icons.payment),
              items: _paymentMethods
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPayment = v!),
            ),
            const SizedBox(height: 14),
            _field(_shopNameCtrl, "Shop / Restaurant (optional)",
                Icons.store_outlined),
            const SizedBox(height: 14),
            _field(_notesCtrl, "Notes (optional)", Icons.notes),
            const SizedBox(height: 16),
            // Photo attachment
            _buildPhotoSection(),
            const SizedBox(height: 12),
            // Tags
            _buildTagsSection(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: const Text("Save Changes"),
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    final dateStr = DateFormat('MMM d, yyyy').format(_selectedDate);
    final timeStr = _selectedTime.format(context);
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: _deco("Date", Icons.calendar_today),
              child: Text(dateStr, style: const TextStyle(fontSize: 15)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: _deco("Time", Icons.access_time),
              child: Text(timeStr, style: const TextStyle(fontSize: 15)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: _deco(label, icon),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take photo"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove photo",
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _photoPath = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final file = await picker.pickImage(
          source: source, maxWidth: 1200, imageQuality: 85);
      if (file != null && mounted) setState(() => _photoPath = file.path);
    } catch (_) {}
  }

  Widget _buildPhotoSection() {
    if (_photoPath != null) {
      return GestureDetector(
        onTap: _pickPhoto,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.file(File(_photoPath!),
                  height: 120, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => setState(() => _photoPath = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      icon: const Icon(Icons.attach_file, size: 18),
      label: const Text("Attach receipt photo (optional)"),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _pickPhoto,
    );
  }

  Widget _buildTagsSection() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Tags (optional)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Tooltip(
              message:
                  "Add tags to group expenses. e.g. #capstone, #shared, #work\nSearch by tag in Transactions screen.",
              child: Icon(Icons.info_outline,
                  size: 14, color: cs.onSurface.withValues(alpha: 0.4)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _tags
                .map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 11)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                      backgroundColor: cs.primary.withValues(alpha: 0.1),
                      side:
                          BorderSide(color: cs.primary.withValues(alpha: 0.3)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagInputCtrl,
                decoration: InputDecoration(
                  hintText: 'Add tag (e.g. #capstone)',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                onSubmitted: _addTag,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _addTag(_tagInputCtrl.text),
              style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              child: const Text("Add", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  void _addTag(String raw) {
    final tag = raw.trim().toLowerCase();
    if (tag.isEmpty) return;
    final normalized = tag.startsWith('#') ? tag : '#$tag';
    if (!_tags.contains(normalized) && _tags.length < 5) {
      setState(() => _tags.add(normalized));
    }
    _tagInputCtrl.clear();
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
