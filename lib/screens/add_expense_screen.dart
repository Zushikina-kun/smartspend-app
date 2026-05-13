import 'dart:io';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/llm_service.dart';
import '../services/voice_service.dart';
import '../services/category_service.dart';
import '../services/ai_chat_service.dart';
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

class AddExpenseScreen extends StatefulWidget {
  final String? initialText;
  final bool startWithVoice;
  const AddExpenseScreen(
      {super.key, this.initialText, this.startWithVoice = false});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _inputController;
  final _voiceService = VoiceService();

  bool _isAnalyzing = false;
  bool _isListening = false;
  String _statusText = "";
  Map<String, dynamic>? _parsed;
  String _selectedDate = DateTime.now().toIso8601String().substring(0, 10);
  List<String> _categories = CategoryService.builtIn;

  // Editable fields
  final _amountCtrl = TextEditingController();
  final _itemNameCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedCategory = 'Others';
  String _selectedPayment = 'Cash';
  bool _isWant = false;
  String? _photoPath;
  List<String> _tags = []; // user-defined tags e.g. ['#capstone', '#school']
  final _tagInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.initialText ?? '');
    _selectedCategory = 'Others';
    _selectedPayment = 'Cash';
    _parsed = {
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'confidence_score': 1.0,
    };
    _selectedDate = DateTime.now().toIso8601String().substring(0, 10);
    _loadCategories();
    // Auto-suggest category when item name is typed manually
    _itemNameCtrl.addListener(_autoSuggestCategory);
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _analyzeAndPreview());
    } else if (widget.startWithVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startVoice());
    }
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryService.getAll();
    if (mounted) setState(() => _categories = cats);
  }

  /// Auto-suggest category based on item name keywords (only when user hasn't
  /// already selected a non-Others category via AI or manual selection)
  void _autoSuggestCategory() {
    // Only auto-suggest if category is still at default (Others) or was AI-set
    if (_parsed != null && _parsed!['confidence_score'] != 1.0) return;
    final text = _itemNameCtrl.text.trim().toLowerCase();
    if (text.length < 3) return;
    final suggested = AIChatService.suggestCategory(text);
    if (suggested != 'Others' && suggested != _selectedCategory) {
      setState(() => _selectedCategory = suggested);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _amountCtrl.dispose();
    _itemNameCtrl.dispose();
    _shopNameCtrl.dispose();
    _notesCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyzeAndPreview({bool isRetry = false}) async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      _showError("Please describe your expense first.");
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _parsed = null;
      _statusText = isRetry ? "Retrying..." : "AI is analyzing...";
    });

    try {
      final result = await LLMService.parseExpense(input);
      if (mounted) {
        final amt = result['amount'] as double;
        // Show whole number if no cents, otherwise 2dp
        _amountCtrl.text = amt == amt.truncateToDouble()
            ? amt.toStringAsFixed(0)
            : amt.toStringAsFixed(2);
        _itemNameCtrl.text = result['item_name'] as String? ?? '';
        _shopNameCtrl.text = result['shop_name'] as String? ?? '';
        _notesCtrl.text = result['notes'] as String? ?? '';
        _selectedCategory = result['category'] as String? ?? 'Others';
        _selectedPayment = result['payment_method'] as String? ?? 'Cash';
        setState(() {
          _parsed = result;
          _selectedDate = result['date'] as String? ??
              DateTime.now().toIso8601String().substring(0, 10);
          _isAnalyzing = false;
          _statusText = "";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _statusText = "";
        });
        final msg = e.toString().replaceAll("Exception: ", "");
        // Auto-retry once on timeout
        if (!isRetry && msg.contains("timed out")) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) _analyzeAndPreview(isRetry: true);
          return;
        }
        // Give a more helpful message for common failures
        if (msg.contains("Amount must be greater than zero") ||
            msg.contains("Could not parse")) {
          _showError(
              "Could not detect the amount. Please type your expense more clearly, e.g. 'Lunch 85 pesos'.");
        } else {
          _showError(msg);
        }
      }
    }
  }

  Future<void> _confirmSave() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _showError("Please enter a valid amount.");
      return;
    }
    final itemName = _itemNameCtrl.text.trim();
    if (itemName.isEmpty) {
      _showError("Please enter an item name.");
      return;
    }

    // Impulse pause mechanic — for Want-tagged expenses above 2× category average
    if (_isWant && amount > 0) {
      try {
        final allExp = await DBService.getExpenses();
        final catAmounts = allExp
            .where((e) => e.category == _selectedCategory && e.amount > 0)
            .map((e) => e.amount)
            .toList();
        if (catAmounts.length >= 3) {
          final avg = catAmounts.reduce((a, b) => a + b) / catAmounts.length;
          if (amount > avg * 2.0) {
            final proceed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Was this planned? 🤔"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "This is a Want expense of ₱${amount.toStringAsFixed(0)} in $_selectedCategory — "
                      "that's ${(amount / avg).toStringAsFixed(1)}× your usual ₱${avg.toStringAsFixed(0)}.",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Taking a moment to reflect can help avoid impulse spending. You can still save it — this is just a reminder.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Wait, let me reconsider"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Yes, save it"),
                  ),
                ],
              ),
            );
            if (proceed != true || !mounted) {
              // Track impulse declines for Impulse Control badge
              if (proceed != true) {
                try {
                  final current = int.tryParse(
                          await DBService.getSetting('impulse_declines') ??
                              '0') ??
                      0;
                  await DBService.setSetting(
                      'impulse_declines', (current + 1).toString());
                } catch (_) {}
              }
              return;
            }
          }
        }
      } catch (_) {}
    }

    try {
      await DBService.insertExpense({
        'item_name': itemName,
        'category': _selectedCategory,
        'amount': amount,
        'date': _selectedDate,
        'time': _parsed?['time'],
        'payment_method': _selectedPayment,
        'shop_name': _shopNameCtrl.text.trim().isEmpty
            ? null
            : _shopNameCtrl.text.trim(),
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        'ai_generated': (_parsed?['confidence_score'] != null &&
                _parsed!['confidence_score'] != 1.0)
            ? 1
            : 0,
        'confidence_score': _parsed?['confidence_score'] ?? 1.0,
        'is_want': _isWant ? 1 : 0,
        if (_photoPath != null) 'photo_path': _photoPath,
        if (_tags.isNotEmpty) 'tags': _tags.join(','),
      });

      // NI-6: Warn if user committed to "done spending today"
      final doneVal = await DBService.getSetting('done_spending_today');
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (doneVal == today && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "⚠️ You said you were done spending today — but that's okay!"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ));
      }

      // Auto-deduct from matching wallet
      try {
        final autoDeductSetting = await DBService.getSetting('wallet_auto_deduct');
        if (autoDeductSetting == 'false') throw Exception('disabled');
        String? walletName;
        if (_selectedPayment == 'Cash')
          walletName = 'Cash on Hand';
        else if (_selectedPayment == 'GCash')
          walletName = 'GCash';
        else if (_selectedPayment == 'Maya')
          walletName = 'Maya';
        else if (_selectedPayment == 'GrabPay')
          walletName = 'GrabPay';
        else if (_selectedPayment == 'ShopeePay') walletName = 'ShopeePay';
        if (walletName != null) {
          final wallet = await DBService.findWalletByName(walletName);
          if (wallet != null && (wallet['balance'] as num) > 0) {
            final newBal = ((wallet['balance'] as num) - amount).toDouble();
            await DBService.setWalletBalance(
                wallet['id'] as int, newBal.clamp(0.0, double.infinity));
          }
        }
      } catch (_) {}

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showError("Failed to save: $e");
    }
  }

  Future<void> _startVoice() async {
    setState(() {
      _isListening = true;
      _statusText = "Listening...";
      _parsed = null;
    });
    try {
      final text = await _voiceService.startListening(
        onPartialResult: (p) {
          if (mounted) setState(() => _inputController.text = p);
        },
      );
      if (mounted) {
        setState(() {
          _isListening = false;
          _statusText = "";
        });
        _inputController.text = text;
        await _analyzeAndPreview();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _statusText = "";
        });
        _showError(e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
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
      if (file != null && mounted) {
        setState(() => _photoPath = file.path);
      }
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
              Image.file(
                File(_photoPath!),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
                  prefixText: _tagInputCtrl.text.startsWith('#') ? '' : '#',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        actions: const [
          InfoButton(
            title: "Add Expense",
            body:
                "Describe your expense in plain language and let AI fill in the details.\n\n"
                "💡 Examples:\n"
                "• \"Lunch at Jollibee 150 pesos\"\n"
                "• \"Grab ride 85\"\n"
                "• \"Groceries SM 620 GCash\"\n\n"
                "You can also use Voice input or fill in the fields manually.\n\n"
                "Tag expenses as Want or Need to track your spending habits.\n"
                "Attach a receipt photo for your records.",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Describe your expense in plain language",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: _inputController,
              maxLines: 3,
              enabled: !_isListening && !_isAnalyzing,
              decoration: InputDecoration(
                hintText: 'e.g. "Ate at KFC 250 pesos" or "Grab ride 120"',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(_isListening ? Icons.stop : Icons.mic,
                        color: _isListening ? Colors.red : null),
                    label: Text(_isListening ? "Stop" : "Voice"),
                    onPressed: _isAnalyzing
                        ? null
                        : (_isListening ? _voiceService.stop : _startVoice),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Analyze"),
                    onPressed: (_isAnalyzing || _isListening)
                        ? null
                        : _analyzeAndPreview,
                  ),
                ),
              ],
            ),
            if (_isAnalyzing || _isListening) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Text(_statusText, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],

            // Form fields — always visible, AI fills them in when available
            const SizedBox(height: 24),

            // Confidence indicator — only shown after AI analysis
            if (_parsed != null &&
                (_parsed!['confidence_score'] as double? ?? 1.0) < 0.7)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Low confidence — please review and correct the fields below.",
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const Text("Fill in the details:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Date picker
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text("Date: $_selectedDate"),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.tryParse(_selectedDate) ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate =
                      picked.toIso8601String().substring(0, 10));
                }
              },
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _itemNameCtrl,
              decoration: InputDecoration(
                labelText: "Item Name",
                prefixIcon: const Icon(Icons.label_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Amount (₱)",
                prefixIcon: const Icon(Icons.attach_money),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : _categories.first,
              decoration: InputDecoration(
                labelText: "Category",
                prefixIcon: const Icon(Icons.category),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 12),

            // Want vs Need toggle — highlighted card so it's easy to find
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isWant
                      ? Colors.orange.withValues(alpha: 0.5)
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isWant
                        ? Icons.shopping_bag_outlined
                        : Icons.check_circle_outline,
                    size: 18,
                    color: _isWant
                        ? Colors.orange
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isWant ? "Tagged as: Want" : "Tagged as: Need",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isWant
                                ? Colors.orange
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          _isWant
                              ? "Discretionary — you chose to spend this"
                              : "Essential — you needed to spend this",
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Need", style: TextStyle(fontSize: 12)),
                    selected: !_isWant,
                    onSelected: (_) => setState(() => _isWant = false),
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text("Want", style: TextStyle(fontSize: 12)),
                    selected: _isWant,
                    onSelected: (_) => setState(() => _isWant = true),
                    selectedColor: Colors.orange.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _selectedPayment,
              decoration: InputDecoration(
                labelText: "Payment Method",
                prefixIcon: const Icon(Icons.payment),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _paymentMethods
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPayment = v!),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _shopNameCtrl,
              decoration: InputDecoration(
                labelText: "Shop / Restaurant (optional)",
                prefixIcon: const Icon(Icons.store_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: "Notes (optional)",
                prefixIcon: const Icon(Icons.notes),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Photo attachment (#3)
            _buildPhotoSection(),
            const SizedBox(height: 12),

            // Tags
            _buildTagsSection(),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Confirm & Save"),
              onPressed: _confirmSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
