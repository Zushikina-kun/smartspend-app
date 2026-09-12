import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/db_service.dart';
import '../services/llm_service.dart';
import '../services/voice_service.dart';
import '../services/category_service.dart';
import '../services/ai_chat_service.dart';
import '../services/item_catalog_service.dart';
import '../services/merchant_normalization_service.dart';
import '../models/budget.dart';
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

  /// When true, skips the automatic AI analysis on open even if initialText is set.
  /// Used when opening from an AI error bubble — the AI just failed, don't retry it immediately.
  final bool skipAiAnalysis;
  const AddExpenseScreen(
      {super.key,
      this.initialText,
      this.startWithVoice = false,
      this.skipAiAnalysis = false});

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

  // ── AUTOCOMPLETE STATE ────────────────────────────────────────────────────
  List<Map<String, dynamic>> _itemSuggestions = [];
  bool _showSuggestions = false;

  // ── SHOP AUTOCOMPLETE ─────────────────────────────────────────────────────
  List<String> _shopSuggestions = [];
  bool _showShopSuggestions = false;

  // ── BUDGET PROGRESS ───────────────────────────────────────────────────────
  List<Budget> _budgets = [];
  Map<String, double> _catSpentThisMonth = {};

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
    // Auto-suggest category + load item suggestions when item name is typed
    _itemNameCtrl.addListener(() => _onItemNameChanged(_itemNameCtrl.text));
    if (widget.initialText != null &&
        widget.initialText!.isNotEmpty &&
        !widget.skipAiAnalysis) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _analyzeAndPreview());
    } else if (widget.startWithVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startVoice());
    }
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryService.getAll();
    if (mounted) setState(() => _categories = cats);
    // Also load budgets for the category progress bar
    try {
      final budgets = await DBService.getBudgets();
      final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
      final expenses = await DBService.getExpenses(month: currentMonth);
      final spent = <String, double>{};
      for (final e in expenses) {
        spent[e.category] = (spent[e.category] ?? 0) + e.amount;
      }
      if (mounted)
        setState(() {
          _budgets = budgets;
          _catSpentThisMonth = spent;
        });
    } catch (_) {}
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

  /// Load past-item suggestions as user types the item name.
  void _onItemNameChanged(String value) {
    _autoSuggestCategory();
    if (value.trim().length < 2) {
      if (_showSuggestions)
        setState(() {
          _itemSuggestions = [];
          _showSuggestions = false;
        });
      return;
    }
    DBService.getSuggestionsForItem(value.trim()).then((results) {
      if (mounted && _itemNameCtrl.text.trim() == value.trim()) {
        setState(() {
          _itemSuggestions = results;
          _showSuggestions = results.isNotEmpty;
        });
      }
    });
  }

  /// Apply a past-item suggestion — fills all fields from the last known values.
  void _applySuggestion(Map<String, dynamic> s) {
    final name = s['item_name'] as String;
    final amount = (s['amount'] as num).toDouble();
    final category = s['category'] as String? ?? 'Others';
    final payment = s['payment_method'] as String? ?? 'Cash';
    final isWant = (s['is_want'] as int? ?? 0) == 1;
    _itemNameCtrl.text = name;
    _amountCtrl.text = amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    setState(() {
      _selectedCategory = _categories.contains(category) ? category : 'Others';
      _selectedPayment = payment;
      _isWant = isWant;
      _itemSuggestions = [];
      _showSuggestions = false;
    });
  }

  // ── SHOP AUTOCOMPLETE ─────────────────────────────────────────────────────
  void _onShopNameChanged(String value) {
    if (value.trim().length < 2) {
      if (_showShopSuggestions) {
        setState(() {
          _shopSuggestions = [];
          _showShopSuggestions = false;
        });
      }
      return;
    }
    DBService.getDistinctShopNames(value.trim()).then((results) {
      if (mounted && _shopNameCtrl.text.trim() == value.trim()) {
        setState(() {
          _shopSuggestions = results;
          _showShopSuggestions = results.isNotEmpty;
        });
      }
    });
  }

  // ── CATALOG BROWSE ────────────────────────────────────────────────────────
  void _openCatalog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CatalogSheet(
        categories: _categories,
        onSelected: (item) {
          _itemNameCtrl.text = item.name;
          _amountCtrl.text =
              item.suggestedPrice == item.suggestedPrice.truncateToDouble()
                  ? item.suggestedPrice.toStringAsFixed(0)
                  : item.suggestedPrice.toStringAsFixed(2);
          if (item.shopHint != null) _shopNameCtrl.text = item.shopHint!;
          setState(() {
            _selectedCategory =
                _categories.contains(item.category) ? item.category : 'Others';
            _isWant = item.isWant;
            _itemSuggestions = [];
            _showSuggestions = false;
          });
        },
      ),
    );
  }

  // ── SMART AMOUNT CALCULATOR ───────────────────────────────────────────────
  /// Evaluates simple expressions in the amount field.
  /// Supports: 3x85 → 255, 2*85 → 170, 100+50 → 150, 200-30 → 170
  void _evalAmountExpression() {
    final raw = _amountCtrl.text.trim();
    if (raw.isEmpty) return;
    // Already a plain number — nothing to do
    if (double.tryParse(raw) != null) return;

    try {
      // Normalize: replace × and x with *
      var expr =
          raw.replaceAll('×', '*').replaceAll('x', '*').replaceAll('X', '*');
      double? result;
      // Multiplication: e.g. 3*85
      if (expr.contains('*')) {
        final parts = expr.split('*');
        if (parts.length == 2) {
          final a = double.tryParse(parts[0].trim());
          final b = double.tryParse(parts[1].trim());
          if (a != null && b != null) result = a * b;
        }
      }
      // Addition: e.g. 85+30
      else if (expr.contains('+')) {
        final parts = expr.split('+');
        if (parts.length == 2) {
          final a = double.tryParse(parts[0].trim());
          final b = double.tryParse(parts[1].trim());
          if (a != null && b != null) result = a + b;
        }
      }
      // Subtraction: e.g. 200-30 (only if not a negative number)
      else if (expr.contains('-') && !expr.startsWith('-')) {
        final idx = expr.lastIndexOf('-');
        final a = double.tryParse(expr.substring(0, idx).trim());
        final b = double.tryParse(expr.substring(idx + 1).trim());
        if (a != null && b != null) result = a - b;
      }

      if (result != null && result > 0) {
        final formatted = result == result.truncateToDouble()
            ? result.toStringAsFixed(0)
            : result.toStringAsFixed(2);
        _amountCtrl.text = formatted;
        // Move cursor to end
        _amountCtrl.selection =
            TextSelection.collapsed(offset: _amountCtrl.text.length);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("$raw = ₱$formatted"),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } catch (_) {}
  }

  // ── PASTE-TO-PARSE ────────────────────────────────────────────────────────
  /// Paste clipboard text into the description field and try to auto-extract
  /// amount and date from common GCash/bank SMS formats.
  Future<void> _pasteAndParse() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Clipboard is empty."),
              behavior: SnackBarBehavior.floating));
        return;
      }
      _inputController.text = text;

      // Try to extract amount from common patterns: ₱1,234.56 or PHP 1234 or 1,234.56
      final amtMatch =
          RegExp(r'[₱Pp][Hh][Pp]?\s*([\d,]+\.?\d*)').firstMatch(text) ??
              RegExp(r'([\d,]+\.?\d{2})\s*(?:PHP|₱)').firstMatch(text) ??
              RegExp(r'Amount[:\s]+([\d,]+\.?\d*)').firstMatch(text);
      if (amtMatch != null) {
        final amtStr = amtMatch.group(1)!.replaceAll(',', '');
        final amt = double.tryParse(amtStr);
        if (amt != null && amt > 0) {
          _amountCtrl.text = amt == amt.truncateToDouble()
              ? amt.toStringAsFixed(0)
              : amt.toStringAsFixed(2);
        }
      }

      // Try to extract date
      final dateMatch =
          RegExp(r'(\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2})').firstMatch(text);
      if (dateMatch != null) {
        final raw = dateMatch.group(1)!;
        DateTime? d;
        if (raw.contains('/')) {
          final parts = raw.split('/');
          d = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
        } else {
          d = DateTime.tryParse(raw);
        }
        if (d != null) {
          setState(() => _selectedDate = d!.toIso8601String().substring(0, 10));
        }
      }

      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              "Pasted! Review the fields below and tap Analyze or Save."),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Paste failed: ${e.toString()}"),
            behavior: SnackBarBehavior.floating));
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

    // ── DUPLICATE WARNING ─────────────────────────────────────────────────────
    // Warn if the same item + amount was already logged today — soft block,
    // user can still proceed. Only fires for today's entries.
    try {
      final todayForDup = DateTime.now().toIso8601String().substring(0, 10);
      if (_selectedDate.substring(0, 10) == todayForDup) {
        final db = await DBService.getDB();
        final existing = await db.rawQuery('''
          SELECT id FROM expenses
          WHERE LOWER(item_name) = LOWER(?)
            AND ABS(amount - ?) < 0.01
            AND date = ?
          LIMIT 1
        ''', [itemName, amount, todayForDup]);
        if (existing.isNotEmpty && mounted) {
          final proceed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Already logged today?"),
              content: Text(
                  "You already logged \"$itemName\" for ₱${amount.toStringAsFixed(0)} today. "
                  "Save it again as a separate entry?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Save again")),
              ],
            ),
          );
          if (proceed != true || !mounted) return;
        }
      }
    } catch (_) {} // non-fatal — if check fails, proceed with save

    // Impulse pause mechanic — for Want-tagged expenses above 2× category average
    // Only fires for today's entries — skip for historical/backdated expenses
    final impulseEnabled =
        (await DBService.getSetting('impulse_pause_enabled')) != 'false';
    final expDateForImpulse = _selectedDate.substring(0, 10);
    final todayForImpulse = DateTime.now().toIso8601String().substring(0, 10);
    final isBackdated = expDateForImpulse != todayForImpulse;
    if (impulseEnabled && _isWant && amount > 0 && !isBackdated) {
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
            : MerchantNormalizationService.normalize(_shopNameCtrl.text.trim()),
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

      // ── PRICE MEMORY — manual entry version ──────────────────────────────
      // Same logic as AI chat: alert when the same item costs ≥15% more than
      // the last recorded price. Only fires for today's entries.
      try {
        final todayForPM = DateTime.now().toIso8601String().substring(0, 10);
        if (_selectedDate.substring(0, 10) == todayForPM) {
          final allExp = await DBService.getExpenses();
          final sameItems = allExp
              .where((e) =>
                  e.itemName.toLowerCase() == itemName.toLowerCase() &&
                  e.amount > 0 &&
                  e.amount != amount)
              .toList();
          if (sameItems.isNotEmpty && mounted) {
            final lastPrice = sameItems.first.amount;
            if (amount > lastPrice * 1.15) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "📈 Price up: $itemName was ₱${lastPrice.toStringAsFixed(0)} last time "
                    "(+${((amount / lastPrice - 1) * 100).toStringAsFixed(0)}%)"),
                backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ));
            }
          }
        }
      } catch (_) {}

      // NI-6: Warn if user committed to "done spending today"
      // Only warn if the expense date is actually today — not for historical entries
      final doneVal = await DBService.getSetting('done_spending_today');
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final expDate = _selectedDate.substring(0, 10);
      if (doneVal == today && expDate == today && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "⚠️ You said you were done spending today — but that's okay!"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ));
      }

      // Auto-deduct from matching wallet
      // Only deduct for today's entries — backdated expenses happened in the past
      // and your current wallet balance has no relation to them.
      try {
        final autoDeductSetting =
            await DBService.getSetting('wallet_auto_deduct');
        if (autoDeductSetting == 'false') throw Exception('disabled');
        if (isBackdated) throw Exception('backdated'); // skip for past dates
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
                const SizedBox(width: 8),
                // Paste & parse from clipboard (GCash/bank SMS)
                Tooltip(
                  message: "Paste GCash/bank SMS to auto-fill",
                  child: OutlinedButton(
                    onPressed: _isAnalyzing ? null : _pasteAndParse,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Icon(Icons.content_paste, size: 18),
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
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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

            // Date quick-pick chips + full calendar
            // Chips: Today / Yesterday / 2 days ago — covers 99% of logging
            Builder(builder: (context) {
              final now = DateTime.now();
              final chips = [
                ('Today', now.toIso8601String().substring(0, 10)),
                (
                  'Yesterday',
                  now
                      .subtract(const Duration(days: 1))
                      .toIso8601String()
                      .substring(0, 10)
                ),
                (
                  '2 days ago',
                  now
                      .subtract(const Duration(days: 2))
                      .toIso8601String()
                      .substring(0, 10)
                ),
              ];
              return Wrap(
                spacing: 8,
                children: [
                  ...chips.map((c) {
                    final selected = _selectedDate == c.$2;
                    return ChoiceChip(
                      label: Text(c.$1, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedDate = c.$2),
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.calendar_today, size: 14),
                    label: Text(
                      chips.any((c) => c.$2 == _selectedDate)
                          ? 'Pick date'
                          : _selectedDate,
                      style: const TextStyle(fontSize: 12),
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
                ],
              );
            }),
            const SizedBox(height: 12),

            TextField(
              controller: _itemNameCtrl,
              decoration: InputDecoration(
                labelText: "Item Name",
                prefixIcon: const Icon(Icons.label_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_itemNameCtrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _itemNameCtrl.clear();
                          setState(() {
                            _itemSuggestions = [];
                            _showSuggestions = false;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.menu_book_outlined, size: 20),
                      tooltip: "Browse item catalog",
                      onPressed: _openCatalog,
                    ),
                  ],
                ),
              ),
            ),
            // ── ITEM SUGGESTIONS ─────────────────────────────────────────
            if (_showSuggestions && _itemSuggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        "Past entries — tap to fill",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _itemSuggestions.map((s) {
                        final name = s['item_name'] as String;
                        final amt = (s['amount'] as num).toDouble();
                        final cat = s['category'] as String? ?? '';
                        return InkWell(
                          onTap: () => _applySuggestion(s),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.history, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "₱${amt == amt.truncateToDouble() ? amt.toStringAsFixed(0) : amt.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[600]),
                                ),
                                if (cat.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    "· $cat",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey[500]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                hintText: "e.g. 85 or 3x85",
                hintStyle: const TextStyle(fontSize: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calculate_outlined, size: 20),
                  tooltip: "Calculate (e.g. 3x85)",
                  onPressed: _evalAmountExpression,
                ),
              ),
              onSubmitted: (_) => _evalAmountExpression(),
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
            // ── CATEGORY BUDGET PROGRESS ─────────────────────────────────
            Builder(builder: (context) {
              final budget = _budgets
                  .where((b) => b.category == _selectedCategory)
                  .firstOrNull;
              if (budget == null || budget.amount <= 0)
                return const SizedBox.shrink();
              final spent = _catSpentThisMonth[_selectedCategory] ?? 0;
              final ratio = (spent / budget.amount).clamp(0.0, 1.0);
              final remaining = budget.amount - spent;
              final isOver = spent > budget.amount;
              final color = isOver
                  ? Colors.red
                  : ratio >= 0.8
                      ? Colors.orange
                      : Colors.green;
              return Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOver
                              ? "⚠️ ${_selectedCategory} budget exceeded by ₱${(-remaining).toStringAsFixed(0)}"
                              : "${_selectedCategory}: ₱${spent.toStringAsFixed(0)} / ₱${budget.amount.toStringAsFixed(0)}",
                          style: TextStyle(fontSize: 11, color: color),
                        ),
                        Text(
                          isOver
                              ? "Over!"
                              : "₱${remaining.toStringAsFixed(0)} left",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 5,
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
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
              onChanged: _onShopNameChanged,
              decoration: InputDecoration(
                labelText: "Shop / Restaurant (optional)",
                prefixIcon: const Icon(Icons.store_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_showShopSuggestions && _shopSuggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _shopSuggestions
                      .map((shop) => InkWell(
                            onTap: () {
                              _shopNameCtrl.text = shop;
                              setState(() {
                                _shopSuggestions = [];
                                _showShopSuggestions = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.teal.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.store_outlined,
                                      size: 12, color: Colors.teal),
                                  const SizedBox(width: 4),
                                  Text(shop,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.teal,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
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

// ── CATALOG BROWSE SHEET ──────────────────────────────────────────────────────
/// Full-screen searchable bottom sheet for the Filipino item catalog.
class _CatalogSheet extends StatefulWidget {
  final List<String> categories;
  final void Function(CatalogItem) onSelected;
  const _CatalogSheet({required this.categories, required this.onSelected});

  @override
  State<_CatalogSheet> createState() => _CatalogSheetState();
}

class _CatalogSheetState extends State<_CatalogSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filterCategory = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final results = _query.length >= 1
        ? ItemCatalogService.search(_query)
        : _filterCategory == 'All'
            ? ItemCatalogService.search('')
            : ItemCatalogService.forCategory(_filterCategory);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text("Item Catalog",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search items (e.g. jeep, lunch, Jollibee...)",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        })
                    : null,
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          // Category filter chips (only when not searching)
          if (_query.isEmpty)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  'All',
                  ...ItemCatalogService.categories,
                ].map((cat) {
                  final selected = _filterCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(cat, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => setState(() => _filterCategory = cat),
                      selectedColor: cs.primary.withValues(alpha: 0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 4),
          // Results list
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text("No items found for \"$_query\"",
                        style: const TextStyle(color: Colors.grey)))
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final item = results[i];
                      return ListTile(
                        dense: true,
                        title: Text(item.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          "${item.category}${item.shopHint != null ? ' · ${item.shopHint}' : ''}",
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₱${item.suggestedPrice == item.suggestedPrice.truncateToDouble() ? item.suggestedPrice.toStringAsFixed(0) : item.suggestedPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary),
                            ),
                            Text(
                              item.isWant ? "Want" : "Need",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: item.isWant
                                      ? Colors.orange[700]
                                      : Colors.teal[700]),
                            ),
                          ],
                        ),
                        onTap: () {
                          widget.onSelected(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
