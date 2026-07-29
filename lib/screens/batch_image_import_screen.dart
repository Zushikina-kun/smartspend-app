import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import '../services/llm_service.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/event_bus.dart';

// ── BATCH IMAGE IMPORT SCREEN ─────────────────────────────────────────────────
/// Pick up to 10 screenshots from the gallery (Shopee, Lazada, Steam, GCash, etc.)
/// The app OCRs each image, detects its type, then calls the AI to extract all
/// purchases into a unified review list before importing.
class BatchImageImportScreen extends StatefulWidget {
  const BatchImageImportScreen({super.key});

  @override
  State<BatchImageImportScreen> createState() => _BatchImageImportScreenState();
}

// Per-image processing status
enum _ImageStatus { pending, processing, done, error }

class _ImageEntry {
  final String path;
  _ImageStatus status;
  String type; // steam / shopee / receipt / etc.
  String ocrText;
  String error;
  List<_BatchRow> rows;

  _ImageEntry({
    required this.path,
    this.status = _ImageStatus.pending,
    this.type = 'unknown',
    this.ocrText = '',
    this.error = '',
    this.rows = const [],
  });
}

class _BatchRow {
  String description;
  double amount;
  String category;
  bool isWant;
  String date;
  String shopName;
  String paymentMethod;
  String notes;
  bool selected;

  _BatchRow({
    required this.description,
    required this.amount,
    required this.category,
    required this.isWant,
    required this.date,
    required this.shopName,
    required this.paymentMethod,
    this.notes = '',
    this.selected = true,
  });
}

class _BatchImageImportScreenState extends State<BatchImageImportScreen> {
  final List<_ImageEntry> _images = [];
  bool _picking = false;
  bool _processing = false;
  bool _importing = false;
  int _processedCount = 0;

  // Colour + label per screenshot type
  static const _typeColors = {
    'steam': Color(0xFF1b2838),
    'shopee': Colors.orange,
    'lazada': Colors.blue,
    'grab': Color(0xFF00b14f),
    'gcash': Color(0xFF0076CE),
    'maya': Color(0xFF5B2D8E),
    'in_app_purchase': Colors.purple,
    'receipt': Colors.teal,
    'unknown': Colors.grey,
  };

  static const _typeLabels = {
    'steam': 'Steam',
    'shopee': 'Shopee',
    'lazada': 'Lazada',
    'grab': 'Grab',
    'gcash': 'GCash',
    'maya': 'Maya',
    'in_app_purchase': 'App Store/Play',
    'receipt': 'Receipt',
    'unknown': 'Unknown',
  };

  // ── PICK IMAGES ─────────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final paths = await OCRService.pickMultipleImages(maxImages: 10);
      if (paths.isEmpty) return;
      setState(() {
        for (final p in paths) {
          // Skip already-added paths
          if (!_images.any((e) => e.path == p)) {
            _images.add(_ImageEntry(path: p));
          }
        }
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  // ── PROCESS ALL IMAGES ──────────────────────────────────────────────────────

  Future<void> _processAll() async {
    final pending =
        _images.where((e) => e.status == _ImageStatus.pending).toList();
    if (pending.isEmpty) return;
    setState(() {
      _processing = true;
      _processedCount = 0;
    });

    // Step 1: OCR all images in parallel batches
    for (final entry in pending) {
      setState(() => entry.status = _ImageStatus.processing);
    }

    final paths = pending.map((e) => e.path).toList();
    final ocrResults = await OCRService.processBatch(paths);

    for (var i = 0; i < pending.length; i++) {
      final entry = pending[i];
      final ocr = ocrResults[i];
      if (ocr['error']!.isNotEmpty) {
        entry.status = _ImageStatus.error;
        entry.error = ocr['error']!;
      } else {
        entry.ocrText = ocr['ocrText']!;
        entry.type = ocr['type']!;
      }
    }
    setState(() {});

    // Step 2: Parse with AI in batches of 3
    final toparse =
        pending.where((e) => e.status == _ImageStatus.processing).toList();
    const batchSize = 3;
    for (var i = 0; i < toparse.length; i += batchSize) {
      final batch = toparse.skip(i).take(batchSize).toList();
      final parseBatch =
          batch.map((e) => {'ocrText': e.ocrText, 'type': e.type}).toList();

      // Parse each image individually so we can map results back
      final futures = batch.map((entry) async {
        try {
          final rows =
              await LLMService.parseScreenshot(entry.ocrText, entry.type);
          entry.rows = rows
              .map((r) => _BatchRow(
                    description: r['description'] as String? ?? 'Purchase',
                    amount: (r['amount'] as num?)?.toDouble() ?? 0,
                    category: r['category'] as String? ?? 'Others',
                    isWant: (r['is_want'] as int? ?? 1) == 1,
                    date: r['date'] as String? ??
                        DateTime.now().toIso8601String().substring(0, 10),
                    shopName: r['shop_name'] as String? ?? '',
                    paymentMethod: r['payment_method'] as String? ?? 'Cash',
                    notes: r['notes'] as String? ?? '',
                  ))
              .toList();
          entry.status = _ImageStatus.done;
        } catch (e) {
          entry.status = _ImageStatus.error;
          entry.error = e.toString().replaceAll('Exception: ', '');
        }
        if (mounted) setState(() => _processedCount++);
      });
      await Future.wait(futures);
      if (i + batchSize < toparse.length) {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }

    if (mounted) setState(() => _processing = false);
  }

  // ── IMPORT SELECTED ─────────────────────────────────────────────────────────

  Future<void> _retryImage(_ImageEntry entry) async {
    setState(() {
      entry.status = _ImageStatus.pending;
      entry.ocrText = '';
      entry.type = 'unknown';
      entry.error = '';
      entry.rows = [];
    });
    await _processAll();
  }

  Future<void> _importSelected() async {
    final allRows =
        _images.expand((e) => e.rows).where((r) => r.selected).toList();
    if (allRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select at least one item to import'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _importing = true);
    int count = 0;
    for (final row in allRows) {
      try {
        await DBService.insertExpense({
          'item_name': row.description,
          'category': row.category,
          'amount': row.amount,
          'date': row.date,
          'time': '00:00',
          'payment_method': row.paymentMethod,
          'shop_name': row.shopName.isNotEmpty ? row.shopName : null,
          'notes':
              row.notes.isNotEmpty ? row.notes : 'Imported from screenshot',
          'ai_generated': 1,
          'confidence_score': 0.85,
          'is_want': row.isWant ? 1 : 0,
        });
        count++;
      } catch (_) {}
    }
    if (mounted) {
      fireEvent(AppEvent.expenseChanged);
      setState(() => _importing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✓ Imported $count item${count == 1 ? '' : 's'}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
      // Remove imported rows from view
      for (final img in _images) {
        img.rows.removeWhere((r) => r.selected);
      }
      setState(() {});
      if (_images.every((e) => e.rows.isEmpty)) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────────

  int get _totalSelected =>
      _images.expand((e) => e.rows).where((r) => r.selected).length;
  int get _totalRows => _images.expand((e) => e.rows).length;
  double get _totalAmount => _images
      .expand((e) => e.rows)
      .where((r) => r.selected)
      .fold(0, (s, r) => s + r.amount);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasImages = _images.isNotEmpty;
    final hasDoneImages = _images.any((e) => e.status == _ImageStatus.done);
    final allPending = _images.every((e) => e.status == _ImageStatus.pending);
    final isReady = hasImages && allPending && !_processing;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Batch Screenshot Import"),
        actions: [
          if (hasDoneImages && _totalRows > 0)
            TextButton(
              onPressed: () {
                final allSelected =
                    _images.expand((e) => e.rows).every((r) => r.selected);
                setState(() {
                  for (final img in _images) {
                    for (final r in img.rows) {
                      r.selected = !allSelected;
                    }
                  }
                });
              },
              child: Text(
                _images.expand((e) => e.rows).every((r) => r.selected)
                    ? 'Deselect All'
                    : 'Select All',
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Top info bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: cs.primaryContainer.withValues(alpha: 0.5),
            child: Row(
              children: [
                Icon(Icons.photo_library_outlined, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasImages
                        ? '${_images.length} image${_images.length == 1 ? '' : 's'} — '
                            '${_images.where((e) => e.status == _ImageStatus.done).length} processed'
                        : 'Pick screenshots from your gallery (up to 10)',
                    style:
                        TextStyle(fontSize: 12, color: cs.onPrimaryContainer),
                  ),
                ),
                if (_processing)
                  Row(children: [
                    const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 6),
                    Text(
                        '$_processedCount/${_images.where((e) => e.status != _ImageStatus.pending).length}',
                        style: const TextStyle(fontSize: 12)),
                  ]),
              ],
            ),
          ),
          Expanded(
            child: !hasImages
                ? _buildEmptyState(cs)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail grid
                        _buildThumbnailGrid(cs),
                        if (hasDoneImages && _totalRows > 0) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Extracted Items ($_totalRows)',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const Spacer(),
                              if (_totalSelected > 0)
                                Text(
                                  '$_totalSelected selected · ${CurrencyService.format(_totalAmount)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.primary,
                                      fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._buildReviewRows(cs),
                        ],
                      ],
                    ),
                  ),
          ),
          // Bottom action bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  // Pick more
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                        size: 18),
                    label: Text(_images.isEmpty ? 'Pick Images' : 'Add More'),
                    onPressed: _picking || _processing ? null : _pickImages,
                  ),
                  const SizedBox(width: 10),
                  // Process / Import
                  if (isReady)
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.auto_fix_high, size: 18),
                        label: Text(
                            'Extract from ${_images.length} Image${_images.length == 1 ? '' : 's'}'),
                        onPressed: _processing ? null : _processAll,
                      ),
                    )
                  else if (hasDoneImages && _totalSelected > 0)
                    Expanded(
                      child: FilledButton.icon(
                        icon: _importing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.download_done, size: 18),
                        label: Text(_importing
                            ? 'Importing...'
                            : 'Import $_totalSelected Item${_totalSelected == 1 ? '' : 's'}'),
                        onPressed: _importing ? null : _importSelected,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 64, color: cs.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            const Text('No images selected',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Pick screenshots of your purchases from Steam, Shopee, '
              'Lazada, GCash, Grab, or any shopping app.\n\n'
              'The AI will extract item name, price, date, and store automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailGrid(ColorScheme cs) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _images.map((entry) {
        final color = _typeColors[entry.type] ?? Colors.grey;
        final label = _typeLabels[entry.type] ?? 'Unknown';
        return SizedBox(
          width: 88,
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(entry.path),
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 88,
                        height: 88,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  // Status overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: entry.status == _ImageStatus.error
                            ? () => _retryImage(entry)
                            : null,
                        child: Container(
                          color: _statusColor(entry.status)
                              .withValues(alpha: 0.18),
                          child: Center(
                              child:
                                  _statusIcon(entry.status, entry.rows.length)),
                        ),
                      ),
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => setState(() => _images.remove(entry)),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: color == const Color(0xFF1b2838)
                            ? Colors.indigo
                            : color)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _statusColor(_ImageStatus s) {
    switch (s) {
      case _ImageStatus.processing:
        return Colors.blue;
      case _ImageStatus.done:
        return Colors.green;
      case _ImageStatus.error:
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  Widget _statusIcon(_ImageStatus s, int rowCount) {
    switch (s) {
      case _ImageStatus.processing:
        return const SizedBox(
            width: 24,
            height: 24,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
      case _ImageStatus.done:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$rowCount item${rowCount == 1 ? '' : 's'}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        );
      case _ImageStatus.error:
        return Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.error_outline, color: Colors.red, size: 22),
          SizedBox(height: 2),
          Text('Tap\nretry',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold)),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  List<Widget> _buildReviewRows(ColorScheme cs) {
    final widgets = <Widget>[];
    for (final img in _images) {
      if (img.rows.isEmpty) continue;
      for (final row in img.rows) {
        widgets.add(_ReviewRowTile(
          row: row,
          onChanged: (v) => setState(() => row.selected = v),
        ));
      }
    }
    return widgets;
  }
}

// ── REVIEW ROW TILE ───────────────────────────────────────────────────────────

class _ReviewRowTile extends StatefulWidget {
  final _BatchRow row;
  final ValueChanged<bool> onChanged;
  const _ReviewRowTile({required this.row, required this.onChanged});

  @override
  State<_ReviewRowTile> createState() => _ReviewRowTileState();
}

class _ReviewRowTileState extends State<_ReviewRowTile> {
  bool _expanded = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;

  static const _categories = [
    'Food',
    'Transportation',
    'Bills',
    'Shopping',
    'Entertainment',
    'Gaming',
    'Health',
    'Education',
    'Personal Care',
    'Clothing',
    'Gifts',
    'Travel',
    'Pets',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.row.description);
    _amountCtrl =
        TextEditingController(text: widget.row.amount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final row = widget.row;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          CheckboxListTile(
            value: row.selected,
            onChanged: (v) => widget.onChanged(v ?? false),
            dense: true,
            title: Text(row.description,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            subtitle: Text(
              '${row.category} · ₱${row.amount.toStringAsFixed(2)}'
              '${row.shopName.isNotEmpty ? ' · ${row.shopName}' : ''}'
              ' · ${row.date.substring(5)}',
              style: TextStyle(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55)),
            ),
            secondary: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Icon(_expanded ? Icons.expand_less : Icons.edit_outlined,
                  size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  const Divider(height: 8),
                  // Name field
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                        labelText: 'Item name',
                        isDense: true,
                        border: OutlineInputBorder()),
                    onChanged: (v) => row.description = v,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    // Amount
                    Expanded(
                      child: TextField(
                        controller: _amountCtrl,
                        style: const TextStyle(fontSize: 13),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: '₱ ',
                            isDense: true,
                            border: OutlineInputBorder()),
                        onChanged: (v) =>
                            row.amount = double.tryParse(v) ?? row.amount,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Category dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: row.category,
                        isDense: true,
                        decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder()),
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => row.category = v ?? row.category),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    // Want/Need toggle
                    FilterChip(
                      label: Text(row.isWant ? 'Want' : 'Need',
                          style: const TextStyle(fontSize: 11)),
                      selected: row.isWant,
                      onSelected: (v) => setState(() => row.isWant = v),
                      selectedColor: Colors.orange.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    // Date chip
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.tryParse(row.date) ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => row.date =
                                picked.toIso8601String().substring(0, 10));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: cs.outline.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 13, color: cs.primary),
                            const SizedBox(width: 4),
                            Text(row.date.substring(5),
                                style:
                                    TextStyle(fontSize: 12, color: cs.primary)),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
