import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/llm_service.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/event_bus.dart';
import '../widgets/info_button.dart';
import 'smart_camera_screen.dart';

/// Import transactions from any bank or e-wallet transaction history.
/// Supports GCash, BPI, BDO, Maya, UnionBank, Seabank, and any text-based
/// transaction export — paste the raw text and the AI parses it.
/// Also used for receipt OCR import (prefillText + sourceLabel='Receipt').
class BankImportScreen extends StatefulWidget {
  final String? prefillText;
  final String? sourceLabel;
  const BankImportScreen({super.key, this.prefillText, this.sourceLabel});

  @override
  State<BankImportScreen> createState() => _BankImportScreenState();
}

class _BankImportScreenState extends State<BankImportScreen> {
  final _textCtrl = TextEditingController();
  bool _parsing = false;
  bool _importing = false;
  List<_ImportRow> _rows = [];
  String? _parseError;

  // Source label chips
  static const _sources = [
    ('GCash', '📱'),
    ('Maya', '💜'),
    ('GrabPay', '🟢'),
    ('ShopeePay', '🟠'),
    ('BPI', '🏦'),
    ('BDO', '🏦'),
    ('Metrobank', '🏦'),
    ('UnionBank', '🏦'),
    ('Landbank', '🏦'),
    ('RCBC', '🏦'),
    ('Security Bank', '🏦'),
    ('PNB', '🏦'),
    ('Chinabank', '🏦'),
    ('EastWest Bank', '🏦'),
    ('Seabank', '🌊'),
    ('GoTyme Bank', '🏦'),
    ('Tonik', '🏦'),
    ('Receipt', '🧾'),
    ('Other', '💳'),
  ];
  String _selectedSource = 'GCash';

  @override
  void initState() {
    super.initState();
    // Pre-fill from OCR or other source if provided
    if (widget.prefillText != null && widget.prefillText!.isNotEmpty) {
      _textCtrl.text = widget.prefillText!;
    }
    if (widget.sourceLabel != null) {
      _selectedSource = widget.sourceLabel!;
    }
    // Auto-parse if prefilled
    if (widget.prefillText != null && widget.prefillText!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _parse());
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      setState(
          () => _parseError = "Please paste your transaction history first.");
      return;
    }
    setState(() {
      _parsing = true;
      _parseError = null;
      _rows = [];
    });

    try {
      List<Map<String, dynamic>> transactions;
      if (_selectedSource == 'Receipt') {
        // Use receipt-specific parser for OCR'd receipts
        transactions = await LLMService.parseReceipt(text);
      } else {
        transactions = await LLMService.parseTransactionHistory(text);
      }
      if (transactions.isEmpty) {
        setState(() {
          _parseError = _selectedSource == 'Receipt'
              ? "No items found in receipt. Try improving the scan quality or edit the text manually."
              : "No expense transactions found. Make sure you pasted debit/outgoing transactions.";
          _parsing = false;
        });
        return;
      }

      setState(() {
        _rows = transactions
            .map((t) => _ImportRow(
                  date: t['date'] as String,
                  time: t['time'] as String? ?? '00:00',
                  description: t['description'] as String,
                  amount: t['amount'] as double,
                  category: t['category'] as String,
                  isWant: (t['is_want'] as int) == 1,
                  paymentMethod: t['payment_method'] as String? ?? 'Cash',
                  notes: t['notes'] as String? ?? '',
                  shopName: t['shop_name'] as String? ?? '',
                  selected: true,
                ))
            .toList();
        _parsing = false;
      });
    } catch (e) {
      setState(() {
        _parseError = e.toString().replaceAll('Exception: ', '');
        _parsing = false;
      });
    }
  }

  Future<void> _import() async {
    final toImport = _rows.where((r) => r.selected).toList();
    if (toImport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Select at least one transaction to import."),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _importing = true);
    int count = 0;
    for (final row in toImport) {
      try {
        await DBService.insertExpense({
          'item_name': row.description,
          'category': row.category,
          'amount': row.amount,
          'date': row.date,
          'time': row.time,
          'payment_method': row.paymentMethod,
          'shop_name': row.shopName.isNotEmpty ? row.shopName : null,
          'notes': row.notes.isNotEmpty
              ? row.notes
              : 'Imported from $_selectedSource',
          'ai_generated': 1,
          'confidence_score': 0.85,
          'is_want': row.isWant ? 1 : 0,
        });
        count++;
      } catch (_) {}
    }

    if (mounted) {
      fireEvent(AppEvent.expenseChanged);
      setState(() {
        _importing = false;
        // Remove imported rows from the review list
        _rows = _rows.where((r) => !r.selected).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("✓ Imported $count transaction${count == 1 ? '' : 's'}"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
      if (_rows.isEmpty) {
        // All done — pop back after a moment
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    }
  }

  Future<void> _pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        dialogTitle: 'Pick transaction history file',
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;
      final content = await File(path).readAsString();
      if (mounted) {
        setState(() {
          _textCtrl.text = content;
          _rows = [];
          _parseError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Could not read file: ${e.toString().replaceAll('Exception: ', '')}"),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push<ScanResult>(
      context,
      MaterialPageRoute(
          builder: (_) => const SmartCameraScreen(documentMode: true)),
    );
    if (result != null && result.text.isNotEmpty && mounted) {
      setState(() {
        _textCtrl.text = result.text;
        _rows = [];
        _parseError = null;
      });
    }
  }

  void _selectAll(bool value) {
    setState(() {
      for (final r in _rows) {
        r.selected = value;
      }
    });
  }

  int get _selectedCount => _rows.where((r) => r.selected).length;
  double get _selectedTotal =>
      _rows.where((r) => r.selected).fold(0, (s, r) => s + r.amount);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasRows = _rows.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sourceLabel == 'Receipt'
            ? "Import Receipt Items"
            : "Import Transactions"),
        actions: [
          const InfoButton(
            title: "Import Transactions",
            body: "Import your spending history from any bank or e-wallet.\n\n"
                "Supported sources:\n"
                "• GCash transaction history\n"
                "• Maya (PayMaya) history\n"
                "• BPI, BDO, UnionBank, Seabank\n"
                "• Any bank with text-based export\n\n"
                "How to use:\n"
                "1. Open your bank/wallet app or email\n"
                "2. Copy your transaction history text\n"
                "3. Paste it here\n"
                "4. Tap 'Parse with AI'\n"
                "5. Review and select which to import\n\n"
                "For GCash PDF: screenshot the pages and use the Camera button to OCR them.\n\n"
                "Only debit/outgoing transactions are imported as expenses. Income/credits are skipped.",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source selector
                  const Text("Source",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _sources
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text("${s.$2} ${s.$1}",
                                      style: const TextStyle(fontSize: 12)),
                                  selected: _selectedSource == s.$1,
                                  onSelected: (_) =>
                                      setState(() => _selectedSource = s.$1),
                                  selectedColor:
                                      cs.primary.withValues(alpha: 0.15),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instructions card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedSource == 'Receipt'
                          ? Colors.green.withValues(alpha: 0.08)
                          : cs.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _selectedSource == 'Receipt'
                              ? Colors.green.withValues(alpha: 0.3)
                              : cs.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                                _selectedSource == 'Receipt'
                                    ? Icons.receipt_long
                                    : Icons.info_outline,
                                size: 15,
                                color: _selectedSource == 'Receipt'
                                    ? Colors.green
                                    : cs.primary),
                            const SizedBox(width: 6),
                            Text(
                              _selectedSource == 'Receipt'
                                  ? "Receipt OCR Import"
                                  : _selectedSource == 'GCash'
                                      ? "How to get GCash history"
                                      : "How to get $_selectedSource history",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedSource == 'Receipt'
                                      ? Colors.green
                                      : cs.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getInstructions(_selectedSource),
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.7),
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text input area
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Paste Transaction History",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      // Camera/OCR button
                      TextButton.icon(
                        icon: const Icon(Icons.camera_enhance, size: 16),
                        label:
                            const Text("Scan", style: TextStyle(fontSize: 12)),
                        onPressed: _openCamera,
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                      ),
                      // Pick CSV/TXT file
                      TextButton.icon(
                        icon: const Icon(Icons.upload_file, size: 16),
                        label:
                            const Text("CSV", style: TextStyle(fontSize: 12)),
                        onPressed: _pickCsvFile,
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                      ),
                      // Paste from clipboard
                      TextButton.icon(
                        icon: const Icon(Icons.content_paste, size: 16),
                        label:
                            const Text("Paste", style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final data =
                              await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            setState(() {
                              _textCtrl.text = data!.text!;
                              _rows = [];
                              _parseError = null;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _textCtrl,
                    maxLines: 8,
                    style:
                        const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText:
                          "Paste your transaction history here...\n\nBest: copy text directly from GCash email PDF (select all → copy).\n\nExample:\n2026-04-28 07:36  Payment to Shopee Philippines Inc  69.00\n2026-04-26 08:05  Payment to FIS VISA ECOM  315.73\n2026-04-16 02:25  Buy Load Transaction  101.00",
                      hintStyle: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.35)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                      suffixIcon: _textCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() {
                                _textCtrl.clear();
                                _rows = [];
                                _parseError = null;
                              }),
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  if (_parseError != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_parseError!,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Parse button
                  if (!hasRows)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _parsing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.smart_toy, size: 18),
                        label: Text(
                            _parsing ? "Parsing with AI..." : "Parse with AI"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _parsing ? null : _parse,
                      ),
                    ),

                  // Results table
                  if (hasRows) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${_rows.length} transaction${_rows.length == 1 ? '' : 's'} found",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectAll(true),
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8)),
                          child:
                              const Text("All", style: TextStyle(fontSize: 12)),
                        ),
                        TextButton(
                          onPressed: () => _selectAll(false),
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8)),
                          child: const Text("None",
                              style: TextStyle(fontSize: 12)),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text("Re-parse",
                              style: TextStyle(fontSize: 12)),
                          onPressed: _parsing ? null : _parse,
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Transaction rows
                    ...List.generate(_rows.length, (i) {
                      final row = _rows[i];
                      return _TransactionTile(
                        row: row,
                        onChanged: (val) => setState(() => row.selected = val),
                        onCategoryChanged: (cat) =>
                            setState(() => row.category = cat),
                        onWantChanged: (val) =>
                            setState(() => row.isWant = val),
                      );
                    }),
                    const SizedBox(height: 80), // space for bottom bar
                  ],
                ],
              ),
            ),
          ),

          // Bottom import bar — shown when rows are ready
          if (hasRows)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                    top: BorderSide(color: cs.outline.withValues(alpha: 0.2))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$_selectedCount selected",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            CurrencyService.format(_selectedTotal),
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: _importing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.download_done, size: 18),
                      label: Text(_importing
                          ? "Importing..."
                          : "Import $_selectedCount"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed:
                          (_importing || _selectedCount == 0) ? null : _import,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getInstructions(String source) {
    switch (source) {
      case 'Receipt':
        return "Receipt OCR was detected and auto-parsed.\n\n"
            "Review the items below — edit categories or Want/Need tags as needed.\n\n"
            "If items look wrong, you can edit the text above and tap 'Parse with AI' again.\n\n"
            "💡 Tip: For better results, ensure the receipt is flat, well-lit, and in focus when scanning.";
      case 'GCash':
        return "Option A (Most reliable — PDF text):\n"
            "GCash app → Profile → Transaction History → Request via email → open the PDF → select all text → copy → paste here.\n\n"
            "Option B (Screenshot OCR):\n"
            "Screenshot your GCash transaction list → tap Camera button above → OCR it.";
      case 'Maya':
        return "Maya app → Activity → tap the filter icon → select date range → screenshot or copy the list.";
      case 'GrabPay':
        return "GrabPay → Wallet → Transaction History → screenshot or copy the list.";
      case 'ShopeePay':
        return "Shopee app → Me → ShopeePay → Transaction History → screenshot or copy.";
      case 'BPI':
        return "BPI Online → Accounts → View Statement → select period → copy the transaction table text.";
      case 'BDO':
        return "BDO Online Banking → Accounts → Transaction History → select date range → copy the text.";
      case 'Metrobank':
        return "Metrobank Online → Accounts → Transaction History → select period → copy or screenshot.";
      case 'UnionBank':
        return "UnionBank app → Accounts → Transaction History → screenshot or copy the list.";
      case 'Landbank':
        return "Landbank iAccess → Accounts → Transaction History → select period → copy or screenshot.";
      case 'RCBC':
        return "RCBC Online Banking → Accounts → Transaction History → copy or screenshot.";
      case 'Security Bank':
        return "Security Bank Online → Accounts → Transaction History → copy or screenshot.";
      case 'PNB':
        return "PNB Digital Banking → Accounts → Transaction History → copy or screenshot.";
      case 'Chinabank':
        return "Chinabank Online → Accounts → Transaction History → copy or screenshot.";
      case 'EastWest Bank':
        return "EastWest Online → Accounts → Transaction History → copy or screenshot.";
      case 'Seabank':
        return "SeaBank app → Transactions → screenshot or copy the transaction list.";
      case 'GoTyme Bank':
        return "GoTyme app → Transactions → screenshot or copy the list.";
      case 'Tonik':
        return "Tonik app → Activity → screenshot or copy the transaction list.";
      default:
        return "Copy your transaction history text from your bank app, email statement, or screenshot it and use the Camera button to OCR it.";
    }
  }
}

// ── TRANSACTION TILE ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final _ImportRow row;
  final ValueChanged<bool> onChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onWantChanged;

  const _TransactionTile({
    required this.row,
    required this.onChanged,
    required this.onCategoryChanged,
    required this.onWantChanged,
  });

  static const _categories = [
    'Food',
    'Transportation',
    'Bills',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('MMM d');
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(row.date);
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: row.selected
          ? cs.primaryContainer.withValues(alpha: 0.15)
          : cs.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onChanged(!row.selected),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: row.selected,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              // Date
              SizedBox(
                width: 40,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    children: [
                      Text(
                        parsedDate != null
                            ? dateFmt.format(parsedDate)
                            : row.date,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.5)),
                        textAlign: TextAlign.center,
                      ),
                      if (row.time != '00:00')
                        Text(
                          row.time,
                          style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurface.withValues(alpha: 0.35)),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Description + controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.description,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Category dropdown
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _categories.contains(row.category)
                                  ? row.category
                                  : 'Others',
                              isDense: true,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500),
                              items: _categories
                                  .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c,
                                          style:
                                              const TextStyle(fontSize: 11))))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) onCategoryChanged(v);
                              },
                            ),
                          ),
                        ),
                        // Want/Need toggle
                        GestureDetector(
                          onTap: () => onWantChanged(!row.isWant),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: row.isWant
                                  ? Colors.orange.withValues(alpha: 0.12)
                                  : cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              row.isWant ? "Want" : "Need",
                              style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      row.isWant ? Colors.orange : cs.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  CurrencyService.format(row.amount),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── DATA MODEL ────────────────────────────────────────────────────────────────

class _ImportRow {
  String date;
  String time;
  String description;
  double amount;
  String category;
  bool isWant;
  String paymentMethod;
  String notes;
  String shopName;
  bool selected;

  _ImportRow({
    required this.date,
    required this.time,
    required this.description,
    required this.amount,
    required this.category,
    required this.isWant,
    required this.paymentMethod,
    required this.notes,
    this.shopName = '',
    required this.selected,
  });
}
