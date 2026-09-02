import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shake/shake.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import '../services/ai_chat_service.dart';
import '../services/db_service.dart';
import '../services/llm_service.dart';
import '../services/ocr_service.dart';
import '../services/score_service.dart';
import '../services/barcode_lookup_service.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../services/voice_service.dart';
import '../services/event_bus.dart';
import '../services/currency_service.dart';
import '../services/debug_service.dart';
import '../services/undo_service.dart';
import '../services/app_config.dart';
import '../models/expense.dart';
import '../widgets/info_button.dart';
import 'chat_history_screen.dart';
import 'smart_camera_screen.dart';
import 'add_expense_screen.dart';
import 'bank_import_screen.dart';
import 'batch_image_import_screen.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _voiceService = VoiceService();
  final List<Map<String, String>> _messages = [];
  bool _sending = false;
  bool _contextLoaded = false;
  bool _historyRestored =
      false; // prevents double-restoration on silent refreshes
  bool _isListening = false;
  String _topSpendingCategory = 'Food'; // dynamic what-if chip
  String? _lastUserMessage; // for retry button
  StreamSubscription? _eventSub;
  ShakeDetector? _shakeDetector;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadContext();
    // Silently refresh AI context when data changes elsewhere (debounced)
    _eventSub = AppEventBus.instance.stream.listen((event) {
      if (event == AppEvent.expenseChanged ||
          event == AppEvent.budgetChanged ||
          event == AppEvent.incomeChanged) {
        // Debounce: cancel previous timer, wait 500ms before refreshing
        // Prevents 12 rapid reloads during plan_salary_split
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          _loadContext(silent: true);
        });
      }
    });
    // Shake to undo — firm shake threshold, shows confirmation sheet
    // Wrapped in try/catch — some devices don't support setAccelerationSamplingPeriod
    try {
      _shakeDetector = ShakeDetector.autoStart(
        shakeThresholdGravity: 2.7,
        onPhoneShake: () {
          if (UndoService.canUndo && mounted) {
            _showUndoSheet();
          }
        },
      );
    } catch (_) {
      // Shake not supported on this device — feature silently disabled
    }
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _debounceTimer?.cancel();
    UndoService.clear();
    _eventSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContext({bool silent = false}) async {
    if (!silent) setState(() => _contextLoaded = false);

    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

    // Parallelize all independent DB reads
    final expensesFuture = DBService.getExpenses();
    final monthExpensesFuture = DBService.getExpenses(month: currentMonth);
    final budgetsFuture = DBService.getBudgets();
    final incomeFuture = DBService.getMonthlyIncome();
    final totalSpentFuture = DBService.getTotalSpent(month: currentMonth);
    final accountTypeFuture = DBService.getSetting('account_type');
    final goalsFuture = DBService.getGoals();
    final debtsFuture = DBService.getDebts();
    final recurringFuture = DBService.getRecurring();

    final expenses = await expensesFuture;
    final monthExpenses = await monthExpensesFuture;
    final budgets = await budgetsFuture;
    final income = await incomeFuture;
    final totalSpent = await totalSpentFuture;
    final accountType = (await accountTypeFuture) ?? 'employed';
    final goals = await goalsFuture;
    final debts = await debtsFuture;
    final recurring = await recurringFuture;

    // Compute authoritative all-time total and per-month totals from DB
    final allTimeTotal = expenses.fold<double>(0, (s, e) => s + e.amount);
    final monthlyTotals = <String, double>{};
    for (final e in expenses) {
      try {
        final d = DateTime.parse(e.date);
        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + e.amount;
      } catch (_) {}
    }

    // NI-4: Load quiz challenge for personalization
    final quizChallenge = await DBService.getSetting('quiz_challenge') ?? '';
    // Load installments for AI context
    List<Map<String, dynamic>> installments = [];
    try {
      final db = await DBService.getDB();
      installments = await db.query('installments', orderBy: 'start_date DESC');
    } catch (_) {}
    // Load wallets for AI context
    List<Map<String, dynamic>> wallets = [];
    try {
      wallets = await DBService.getWallets();
    } catch (_) {}
    // Load custom categories for AI context
    List<String> customCategories = [];
    try {
      final cats = await DBService.getCustomCategories();
      customCategories = cats.map((c) => c['name'] as String).toList();
    } catch (_) {}

    // FC-1: Load today's mood for AI context
    int? todayMoodScore;
    String? todayMoodNote;
    try {
      final mood = await DBService.getTodayMood();
      if (mood != null) {
        todayMoodScore = mood['mood_score'] as int?;
        todayMoodNote = mood['note'] as String?;
      }
    } catch (_) {}
    // Load insurance policies for AI context
    List<Map<String, dynamic>> insurancePolicies = [];
    try {
      insurancePolicies = await DBService.getInsurancePolicies();
    } catch (_) {}

    // Load auto-categorization rules for AI context
    List<Map<String, dynamic>> categoryRules = [];
    try {
      categoryRules = await DBService.getCategoryRules();
    } catch (_) {}

    // Load gap-awareness data for AI context
    int gapPenaltyDays = 0;
    int gapCleanDays = 0;
    try {
      gapPenaltyDays =
          int.tryParse(await DBService.getSetting(kGapPenaltyKey) ?? '0') ?? 0;
      gapCleanDays =
          int.tryParse(await DBService.getSetting(kGapCleanKey) ?? '0') ?? 0;
    } catch (_) {}

    // Load lightweight mode + all spending limits for AI context
    final incomeWalletMode = await DBService.getIncomeWalletMode();
    final allLimits = await DBService.getAllLimits();
    final allSpent = await DBService.getAllSpent();
    // Use tightest active limit for FHS lightweight Spending Restraint component
    final tightest = await DBService.getTightestLimit();
    final spendingLimit = tightest['limit'] as double;
    final spendingLimitPeriod = tightest['period'] as String;
    final spentInPeriod = tightest['spent'] as double;
    final spentMap = <String, double>{};
    for (final e in monthExpenses) {
      spentMap[e.category] = (spentMap[e.category] ?? 0) + e.amount;
    }

    final expenseData = monthExpenses
        .map(
            (e) => {'amount': e.amount, 'category': e.category, 'date': e.date})
        .toList();
    final rawScore = ScoreService.calculateScore(
      expenseData,
      budgets: budgets,
      monthlyIncome: incomeWalletMode ? income : 0,
      lightweightMode: !incomeWalletMode,
      spendingLimit: spendingLimit,
      spendingLimitPeriod: spendingLimitPeriod,
    );
    final score = await ScoreService.applyAllAdjustments(rawScore);
    final fhsBreakdown = ScoreService.getBreakdown(
      expenseData,
      budgets: budgets,
      monthlyIncome: incomeWalletMode ? income : 0,
      lightweightMode: !incomeWalletMode,
      spendingLimit: spendingLimit,
      spendingLimitPeriod: spendingLimitPeriod,
    );

    AIChatService.setFullContext(
      expenses: expenses
          .take(
              30) // keep context compact — recent 10 detailed + 20 summarized by category
          .map((e) => {
                'item_name': e.itemName,
                'category': e.category,
                'amount': e.amount,
                'date': e.date,
                'shop_name': e.shopName ?? '',
                'notes': e.notes ?? '',
                'is_want': e.isWant == true ? 1 : 0,
              })
          .toList(),
      budgets: budgets
          .map((b) => {
                'category': b.category,
                'budget': b.amount,
                'spent': spentMap[b.category] ?? 0,
              })
          .toList(),
      monthlyIncome: income,
      healthScore: score,
      totalSpent: totalSpent,
      accountType: accountType,
      goals: goals,
      debts: debts,
      recurring: recurring,
      installments: installments,
      customCategories: customCategories,
      wallets: wallets,
      todayMoodScore: todayMoodScore,
      todayMoodNote: todayMoodNote,
      quizChallenge: quizChallenge,
      allTimeTotal: allTimeTotal,
      monthlyTotals: monthlyTotals,
      fhsBreakdown: fhsBreakdown,
      insurancePolicies: insurancePolicies,
      gapPenaltyDays: gapPenaltyDays,
      gapCleanDays: gapCleanDays,
      incomeWalletMode: incomeWalletMode,
      spendingLimit: spendingLimit,
      spendingLimitPeriod: spendingLimitPeriod,
      spentInPeriod: spentInPeriod,
      allLimits: allLimits,
      allSpent: allSpent,
      categoryRules: categoryRules,
    );

    // Restore chat history into AI memory on first load only
    // (not on silent refreshes — that would reset the conversation)
    if (!silent && !_historyRestored) {
      _historyRestored = true;
      final savedHistory = await DBService.getChatHistory(limit: 50);
      if (savedHistory.isNotEmpty) {
        AIChatService.restoreHistory(savedHistory);
        if (mounted) {
          setState(() {
            for (final msg in savedHistory) {
              _messages.add({
                "role": msg['role'] as String,
                "text": msg['message'] as String,
              });
            }
          });
          // Scroll to bottom after restoring history
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }
      }
    }

    if (mounted) {
      // Derive top spending category for dynamic what-if chip
      final catTotals = <String, double>{};
      for (final e in expenses.take(20)) {
        catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
      }
      final topCat = catTotals.entries.isEmpty
          ? 'Food'
          : (catTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;
      setState(() {
        _contextLoaded = true;
        _topSpendingCategory = topCat;
      });
    }
  }

  void _showUndoSheet() {
    final action = UndoService.last;
    if (action == null) return;
    final secondsLeft =
        60 - DateTime.now().difference(action.timestamp).inSeconds;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.undo, size: 36, color: Colors.orange),
            const SizedBox(height: 12),
            const Text("Undo last AI action?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              "Action: ${action.type.replaceAll('_', ' ')}\n"
              "Window: $secondsLeft seconds remaining",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.undo),
                    label: const Text("Undo"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await UndoService.undo();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              ok ? "Action undone ✓" : "Undo window expired"),
                          backgroundColor: ok ? Colors.green : Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ));
                        if (ok) await _loadContext(silent: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send({String? retryText}) async {
    final text = retryText ?? _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _sending = true;
      _lastUserMessage = text;
    });
    if (retryText == null) _controller.clear();
    _scrollToBottom();

    try {
      // Save user message to DB immediately — so it persists even if AI fails
      await DBService.saveChatMessage(role: 'user', message: text);

      // Always refresh context from live DB before sending — fixes stale data
      await _loadContext(silent: true);

      final (reply, actions) = await AIChatService.sendMessage(text);

      // Execute all actions immediately
      for (final action in actions) {
        await _executeAction(action);
      }
      // Refresh context after actions so next message sees updated DB
      if (actions.isNotEmpty) await _loadContext(silent: true);

      await DBService.saveChatMessage(role: 'ai', message: reply);

      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "text": reply});
          _lastUserMessage = null; // clear retry on success
        });
        _scrollToBottom();
      }
    } catch (e) {
      final errMsg = e.toString().replaceAll('Exception: ', '');
      final isTimeout = errMsg.contains('timed out') ||
          errMsg.contains('timeout') ||
          errMsg.contains('SocketException') ||
          errMsg.contains('connection');
      final errorText = isTimeout
          ? "⏱️ Request timed out. Tap **Retry** to try again."
          : "Sorry, I couldn't respond right now. Error: $errMsg";
      // Save error response to DB so it persists when user leaves and returns
      try {
        await DBService.saveChatMessage(role: 'ai', message: errorText);
      } catch (_) {}
      if (mounted) {
        setState(() => _messages.add({
              "role": "ai",
              "text": errorText,
              "is_error": "true",
            }));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _executeAction(AIAction action) async {
    try {
      switch (action.type) {
        case 'set_budget':
          final category = action.params['category'] as String?;
          final amount = (action.params['amount'] as num?)?.toDouble();
          if (category != null && amount != null && amount > 0) {
            // Record previous budget for undo
            final prevBudgets = await DBService.getBudgets();
            final prev =
                prevBudgets.where((b) => b.category == category).firstOrNull;
            await DBService.setBudget(category, amount);
            UndoService.record(UndoableAction(
              type: 'set_budget',
              snapshot: {
                'category': category,
                'prev_amount': prev?.amount,
              },
            ));
            _showActionSnackbar(
                "Budget set: $category → ${CurrencyService.format(amount)}");
          }
          break;

        case 'set_income':
          final amount = (action.params['amount'] as num?)?.toDouble();
          if (amount != null && amount > 0) {
            await DBService.setMonthlyIncome(amount);
            fireEvent(AppEvent.incomeChanged); // notify all screens
            _showActionSnackbar(
                "Income updated to ${CurrencyService.format(amount)}/mo");
          }
          break;

        case 'log_expense':
          final itemName = action.params['item_name'] as String? ?? 'Expense';
          final category = action.params['category'] as String? ?? 'Others';
          final amount = (action.params['amount'] as num?)?.toDouble();
          final shopName = action.params['shop_name'] as String?;
          if (amount != null && amount > 0) {
            final now = DateTime.now();
            // Support custom date from AI (e.g., "I spent 50 yesterday")
            final customDate = action.params['date'] as String?;
            final customTime = action.params['time'] as String?;
            final expenseDate =
                customDate ?? now.toIso8601String().substring(0, 10);
            final expenseTime =
                customTime ?? now.toIso8601String().substring(11, 19);

            // ── DB-LEVEL DUPLICATE GUARD ─────────────────────────────────────
            // Reject if identical (name + amount + date) was already saved
            // within the last 90 seconds — catches AI double-fire on retry.
            // Does NOT block legitimate repeat purchases (different day / hour).
            try {
              final db = await DBService.getDB();
              final cutoff =
                  now.subtract(const Duration(seconds: 90)).toIso8601String();
              final existing = await db.rawQuery(
                '''SELECT id FROM expenses
                   WHERE LOWER(item_name) = LOWER(?)
                     AND ABS(amount - ?) < 0.01
                     AND date = ?
                     AND updated_at >= ?
                   LIMIT 1''',
                [itemName, amount, expenseDate, cutoff],
              );
              if (existing.isNotEmpty) {
                // Silently skip — duplicate within 90-second window
                break;
              }
            } catch (_) {
              // Guard failure is non-fatal — proceed with insert
            }
            // FC-3: Use is_want from AI response if provided, otherwise infer from category
            int isWant;
            if (action.params.containsKey('is_want')) {
              final rawWant = action.params['is_want'];
              // Handle both bool and string representations
              if (rawWant is bool) {
                isWant = rawWant ? 1 : 0;
              } else if (rawWant is String) {
                isWant = rawWant.toLowerCase() == 'true' ? 1 : 0;
              } else {
                // Fall back to category-based inference
                const wantCats = [
                  'Shopping',
                  'Entertainment',
                  'Gaming',
                  'Clothing',
                  'Gifts',
                  'Travel'
                ];
                isWant = wantCats.contains(category) ? 1 : 0;
              }
            } else {
              // Fallback: Shopping/Entertainment/Gaming/Clothing/Gifts/Travel = Want, others = Need
              const wantCategories = [
                'Shopping',
                'Entertainment',
                'Gaming',
                'Clothing',
                'Gifts',
                'Travel'
              ];
              isWant = wantCategories.contains(category) ? 1 : 0;
            }
            await DBService.insertExpense({
              'item_name': itemName,
              'category': category,
              'amount': amount,
              'date': expenseDate,
              'time': expenseTime,
              'payment_method':
                  action.params['payment_method'] as String? ?? 'Cash',
              'shop_name': shopName,
              'notes': 'Logged via AI chat',
              'ai_generated': 1,
              'confidence_score': 0.9,
              'is_want': isWant,
            });
            // Record for undo — get the inserted ID
            try {
              final db = await DBService.getDB();
              final rows = await db
                  .rawQuery('SELECT id FROM expenses ORDER BY id DESC LIMIT 1');
              if (rows.isNotEmpty) {
                UndoService.record(UndoableAction(
                  type: 'log_expense',
                  snapshot: {
                    'ids': [rows.first['id'] as int]
                  },
                ));
              }
            } catch (_) {}
            _showActionSnackbar(
                "Logged: $itemName ${CurrencyService.format(amount)}");

            // Auto-deduct from matching wallet based on payment method
            // Only deduct for today's entries — past-date expenses didn't
            // affect the current wallet balance at the time they happened.
            try {
              final autoDeductSetting =
                  await DBService.getSetting('wallet_auto_deduct');
              if (autoDeductSetting == 'false') throw Exception('disabled');
              if (expenseDate !=
                  DateTime.now().toIso8601String().substring(0, 10))
                throw Exception('backdated');
              final paymentMethod =
                  action.params['payment_method'] as String? ?? 'Cash';
              String? walletName;
              if (paymentMethod == 'Cash' || paymentMethod == 'cash') {
                walletName = 'Cash on Hand';
              } else if (paymentMethod == 'GCash' || paymentMethod == 'gcash') {
                walletName = 'GCash';
              } else if (paymentMethod == 'Maya' || paymentMethod == 'maya') {
                walletName = 'Maya';
              } else if (paymentMethod == 'GrabPay') {
                walletName = 'GrabPay';
              } else if (paymentMethod == 'ShopeePay') {
                walletName = 'ShopeePay';
              }
              if (walletName != null) {
                final wallet = await DBService.findWalletByName(walletName);
                if (wallet != null && (wallet['balance'] as num) > 0) {
                  final newBal =
                      ((wallet['balance'] as num) - amount).toDouble();
                  await DBService.setWalletBalance(
                      wallet['id'] as int, newBal.clamp(0.0, double.infinity));
                }
              }
            } catch (_) {}
            // ── DATE GUARD: only fire per-transaction warnings for current-period entries ──
            // Logging a historical expense (last month, last year) should not
            // trigger budget alerts, "that's higher than usual", or price memory
            // snackbars — those compare against current-period limits/averages.
            final expenseDateKey =
                expenseDate; // already set above (YYYY-MM-DD)
            final currentDayKey =
                DateTime.now().toIso8601String().substring(0, 10);
            final currentMonthKey =
                DateTime.now().toIso8601String().substring(0, 7);
            final isCurrentMonth = expenseDateKey.startsWith(currentMonthKey);
            final isCurrentDay = expenseDateKey == currentDayKey;

            try {
              final allExp = await DBService.getExpenses();
              final catAmounts = allExp
                  .where((e) => e.category == category && e.amount > 0)
                  .map((e) => e.amount)
                  .toList();
              if (isCurrentMonth && catAmounts.length >= 3) {
                final avg =
                    catAmounts.reduce((a, b) => a + b) / catAmounts.length;
                if (amount > avg * 2.5) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "⚠️ That's higher than your usual $category spend of ${CurrencyService.format(avg.roundToDouble())}"),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ));
                  }
                }
              }
              // Price Memory — only show for current-day entries
              if (isCurrentDay) {
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
                          "📈 Price up: $itemName was ${CurrencyService.format(lastPrice)} last time (+${((amount / lastPrice - 1) * 100).toStringAsFixed(0)}%)"),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ));
                  }
                }
              }
            } catch (_) {}

            // Budget insight — only for current-month entries
            if (isCurrentMonth) {
              try {
                final budgets = await DBService.getBudgets();
                final budget =
                    budgets.where((b) => b.category == category).firstOrNull;
                if (budget != null && budget.amount > 0) {
                  final currentMonth =
                      DateFormat('yyyy-MM').format(DateTime.now());
                  final catExpenses = await DBService.getExpensesByCategory(
                      category,
                      month: currentMonth);
                  final catTotal =
                      catExpenses.fold<double>(0, (s, e) => s + e.amount);
                  final ratio = catTotal / budget.amount;
                  if (ratio >= 1.0 && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "🚨 $category budget exceeded! Spent ${CurrencyService.format(catTotal)} of ${CurrencyService.format(budget.amount)} budget."),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 5),
                    ));
                  } else if (ratio >= 0.8 && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "⚠️ $category budget at ${(ratio * 100).toStringAsFixed(0)}% — ${CurrencyService.format(budget.amount - catTotal)} remaining."),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ));
                  }
                }
              } catch (_) {}
            } // end isCurrentMonth budget check

            // ── GUARDRAIL: register this action in the session fingerprint log ──
            // Prevents the model from re-firing the same item in subsequent turns.
            AIChatService.recordFiredAction(itemName, amount, expenseDate);
          }
          break;

        case 'add_goal':
          final name = action.params['name'] as String?;
          final target = (action.params['target'] as num?)?.toDouble();
          if (name != null && target != null && target > 0) {
            await DBService.insertGoal({
              'name': name,
              'target_amount': target,
              'current_amount': 0.0,
              'start_date': DateTime.now().toIso8601String().substring(0, 10),
              'created_at': DateTime.now().toIso8601String(),
            });
            // Record for undo
            try {
              final goals = await DBService.getGoals();
              if (goals.isNotEmpty) {
                UndoService.record(UndoableAction(
                  type: 'add_goal',
                  snapshot: {'id': goals.first['id'] as int},
                ));
              }
            } catch (_) {}
            _showActionSnackbar(
                "Goal created: $name (${CurrencyService.format(target)})");
          }
          break;

        case 'set_account_type':
          final accountType = action.params['account_type'] as String?;
          if (accountType != null) {
            await DBService.setSetting('account_type', accountType);
            fireEvent(AppEvent.incomeChanged);
            _showActionSnackbar("Account type updated to $accountType");
          }
          break;

        case 'update_goal':
          // Contribute an amount to a savings goal, or update its deadline
          final goalName = action.params['name'] as String?;
          final contribution = (action.params['amount'] as num?)?.toDouble();
          final newDeadline = action.params['deadline'] as String?;
          if (goalName != null) {
            final goals = await DBService.getGoals();
            final match = goals
                .where((g) => (g['name'] as String)
                    .toLowerCase()
                    .contains(goalName.toLowerCase()))
                .firstOrNull;
            if (match != null) {
              // Update deadline if provided
              if (newDeadline != null && newDeadline.isNotEmpty) {
                await DBService.updateGoal({...match, 'deadline': newDeadline});
                _showActionSnackbar(
                    "Goal deadline updated: ${match['name']} → $newDeadline");
              }
              // Contribute amount if provided
              if (contribution != null && contribution > 0) {
                final newAmount =
                    ((match['current_amount'] as num).toDouble() + contribution)
                        .clamp(0.0, (match['target_amount'] as num).toDouble());
                await DBService.updateGoal(
                    {...match, 'current_amount': newAmount});
                _showActionSnackbar(
                    "Added ${CurrencyService.format(contribution)} to ${match['name']}");
              }
            } else {
              _showActionSnackbar("Goal '$goalName' not found");
            }
          }
          break;

        case 'add_income':
          // Log a one-time income entry
          final incomeTitle = action.params['title'] as String? ?? 'Income';
          final incomeAmount = (action.params['amount'] as num?)?.toDouble();
          final incomeCategory =
              action.params['category'] as String? ?? 'Others';
          if (incomeAmount != null && incomeAmount > 0) {
            await DBService.insertIncome({
              'title': incomeTitle,
              'amount': incomeAmount,
              'category': incomeCategory,
              'date': DateTime.now().toIso8601String().substring(0, 10),
              'is_recurring': 0,
            });
            // Record for undo
            try {
              final income = await DBService.getIncome();
              if (income.isNotEmpty) {
                UndoService.record(UndoableAction(
                  type: 'add_income',
                  snapshot: {'id': income.first['id'] as int},
                ));
              }
            } catch (_) {}
            _showActionSnackbar(
                "Income logged: $incomeTitle ${CurrencyService.format(incomeAmount)}");
          }
          break;

        case 'add_debt':
          // Log a debt (money owed) or lending (money lent)
          final debtTitle = action.params['title'] as String? ?? 'Debt';
          final debtPerson = action.params['person'] as String? ?? 'Unknown';
          final debtAmount = (action.params['amount'] as num?)?.toDouble();
          final debtType = action.params['debt_type'] as String? ?? 'owe';
          if (debtAmount != null && debtAmount > 0) {
            await DBService.insertDebt({
              'title': debtTitle,
              'person': debtPerson,
              'amount': debtAmount,
              'paid_amount': 0.0,
              'type': debtType == 'lent' ? 'lent' : 'owe',
              'due_date': action.params['due_date'] as String?,
              'notes': null,
              'created_at': DateTime.now().toIso8601String(),
            });
            // Record for undo
            try {
              final debts = await DBService.getDebts();
              if (debts.isNotEmpty) {
                UndoService.record(UndoableAction(
                  type: 'add_debt',
                  snapshot: {'id': debts.first['id'] as int},
                ));
              }
            } catch (_) {}
            _showActionSnackbar(
                "${debtType == 'lent' ? 'Lent' : 'Owe'} ${CurrencyService.format(debtAmount)} — $debtPerson");
          }
          break;

        case 'add_recurring':
          // Create a recurring transaction
          final recurTitle = action.params['title'] as String? ?? 'Recurring';
          final recurAmount = (action.params['amount'] as num?)?.toDouble();
          final recurCategory = action.params['category'] as String? ?? 'Bills';
          final recurFrequency =
              action.params['frequency'] as String? ?? 'monthly';
          final recurIsExpense = (action.params['is_expense'] as bool?) ?? true;
          if (recurAmount != null && recurAmount > 0) {
            // Calculate next_date based on frequency
            final now2 = DateTime.now();
            final nextDate = (() {
              switch (recurFrequency) {
                case 'daily':
                  return now2.add(const Duration(days: 1));
                case 'weekly':
                  return now2.add(const Duration(days: 7));
                case 'yearly':
                  final lastDay =
                      DateTime(now2.year + 1, now2.month + 1, 0).day;
                  return DateTime(
                      now2.year + 1, now2.month, now2.day.clamp(1, lastDay));
                default: // monthly
                  final nextMonth = now2.month == 12 ? 1 : now2.month + 1;
                  final nextYear = now2.month == 12 ? now2.year + 1 : now2.year;
                  final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
                  return DateTime(
                      nextYear, nextMonth, now2.day.clamp(1, lastDay));
              }
            })()
                .toIso8601String()
                .substring(0, 10);
            await DBService.insertRecurring({
              'title': recurTitle,
              'amount': recurAmount,
              'category': recurCategory,
              'frequency': recurFrequency,
              'next_date': nextDate,
              'start_date': now2.toIso8601String().substring(0, 10),
              'is_expense': recurIsExpense ? 1 : 0,
            });
            // Record for undo
            try {
              final recurring = await DBService.getRecurring();
              if (recurring.isNotEmpty) {
                UndoService.record(UndoableAction(
                  type: 'add_recurring',
                  snapshot: {'id': recurring.last['id'] as int},
                ));
              }
            } catch (_) {}
            _showActionSnackbar(
                "Recurring added: $recurTitle ${CurrencyService.format(recurAmount)}/$recurFrequency");
          }
          break;

        case 'update_expense':
          // Update an existing expense by ID or by matching name+date
          final expenseId = action.params['id'] as int?;
          final matchName = action.params['item_name'] as String?;
          final newCategory = action.params['category'] as String?;
          final newAmount = (action.params['amount'] as num?)?.toDouble();
          final newItemName = action.params['new_item_name'] as String?;
          final newDate = action.params['date'] as String?;
          final newTime = action.params['time'] as String?;

          // Find the expense to update
          final allExpenses = await DBService.getExpenses();
          Expense? target;
          if (expenseId != null) {
            target = allExpenses.where((e) => e.id == expenseId).firstOrNull;
          } else if (matchName != null) {
            // Match by name (case-insensitive, most recent first)
            target = allExpenses
                .where((e) =>
                    e.itemName.toLowerCase().contains(matchName.toLowerCase()))
                .firstOrNull;
          }

          if (target != null) {
            // Record undo snapshot BEFORE applying the change
            UndoService.record(UndoableAction(
              type: 'update_expense',
              snapshot: {'prev': target.toMap()},
            ));
            final updated = target.copyWith(
              itemName: newItemName ?? target.itemName,
              category: newCategory ?? target.category,
              amount: newAmount ?? target.amount,
              date: newDate ?? target.date,
              time: newTime ?? target.time,
            );
            await DBService.updateExpense(updated);
            _showActionSnackbar(
                "Updated: ${updated.itemName} → ${updated.category} ${CurrencyService.format(updated.amount)}");
          } else {
            _showActionSnackbar("Could not find expense to update");
          }
          break;

        case 'delete_expense':
          // Delete an expense — REQUIRES user to have typed "DELETE" to confirm
          final delId = action.params['id'] as int?;
          final delName = action.params['item_name'] as String?;
          final confirmed = action.params['confirmed'] as bool? ?? false;

          if (!confirmed) {
            // Blocked — AI should ask user to type DELETE first
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "⚠️ Deletion blocked. Type DELETE in chat to confirm."),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ));
            }
            break;
          }

          final allExp = await DBService.getExpenses();
          Expense? toDelete;
          if (delId != null) {
            toDelete = allExp.where((e) => e.id == delId).firstOrNull;
          } else if (delName != null) {
            toDelete = allExp
                .where((e) =>
                    e.itemName.toLowerCase().contains(delName.toLowerCase()))
                .firstOrNull;
          }

          if (toDelete != null && toDelete.id != null) {
            await DBService.deleteExpense(toDelete.id!);
            _showActionSnackbar("Deleted: ${toDelete.itemName}");
          } else {
            _showActionSnackbar(
                "Could not find expense. Delete manually from Transactions screen.");
          }
          break;

        case 'delete_by_date':
          // Delete all expenses within a date range
          final delByDateConfirmed =
              action.params['confirmed'] as bool? ?? false;
          if (!delByDateConfirmed) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "⚠️ Bulk deletion blocked. Type DELETE in chat to confirm."),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ));
            }
            break;
          }
          final startDate = action.params['start_date'] as String?;
          final endDate = action.params['end_date'] as String?;
          if (startDate != null && endDate != null) {
            final allExpForDel = await DBService.getExpenses();
            final toDeleteList = allExpForDel.where((e) {
              return e.date.compareTo(startDate) >= 0 &&
                  e.date.compareTo(endDate) <= 0;
            }).toList();
            if (toDeleteList.isNotEmpty) {
              for (final exp in toDeleteList) {
                if (exp.id != null) await DBService.deleteExpense(exp.id!);
              }
              _showActionSnackbar(
                  "Deleted ${toDeleteList.length} expenses ($startDate to $endDate)");
            } else {
              _showActionSnackbar("No expenses found in that date range");
            }
          }
          break;

        case 'add_installment_plan':
          // Create a Payment Plan (ShopeePayLater, GCash GLoan, HomeCredit, etc.)
          final planTitle = action.params['title'] as String? ?? 'Payment Plan';
          final planProvider = action.params['provider'] as String?;
          final planTotal = (action.params['total_amount'] as num?)?.toDouble();
          final planMonthly =
              (action.params['monthly_payment'] as num?)?.toDouble();
          final planMonths = (action.params['months_total'] as int?) ??
              (planTotal != null && planMonthly != null && planMonthly > 0
                  ? (planTotal / planMonthly).ceil()
                  : 3);
          final planDueDay = (action.params['due_day'] as int?) ?? 5;
          final planInterest =
              (action.params['interest_rate'] as num?)?.toDouble();

          if (planMonthly != null && planMonthly > 0) {
            final total = planTotal ?? planMonthly * planMonths;
            await DBService.insertInstallmentPlan({
              'title': planTitle,
              'provider': planProvider,
              'total_amount': total,
              'monthly_payment': planMonthly,
              'months_total': planMonths,
              'months_paid': 0,
              'due_day': planDueDay,
              'interest_rate': planInterest,
              'start_date': DateTime.now().toIso8601String().substring(0, 10),
              'category': 'Bills',
              'notes': 'Added via AI chat',
              'created_at': DateTime.now().toIso8601String(),
            });
            _showActionSnackbar(
                "Payment plan created: $planTitle ${CurrencyService.format(planMonthly)}/mo × $planMonths months");
          }
          break;

        case 'update_debt':
          // Record a payment toward a debt, or update its due date
          final debtPerson = action.params['person'] as String?;
          final debtPayment = (action.params['payment'] as num?)?.toDouble();
          final newDueDate = action.params['due_date'] as String?;
          if (debtPerson != null) {
            final debts = await DBService.getDebts();
            final match = debts
                .where((d) => (d['person'] as String)
                    .toLowerCase()
                    .contains(debtPerson.toLowerCase()))
                .firstOrNull;
            if (match != null) {
              // Update due date if provided
              if (newDueDate != null && newDueDate.isNotEmpty) {
                await DBService.updateDebt({...match, 'due_date': newDueDate});
                _showActionSnackbar(
                    "Due date updated for ${match['person']}: $newDueDate");
              }
              // Record payment if provided
              if (debtPayment != null && debtPayment > 0) {
                final newPaid =
                    ((match['paid_amount'] as num).toDouble() + debtPayment)
                        .clamp(0.0, (match['amount'] as num).toDouble());
                await DBService.updateDebt({...match, 'paid_amount': newPaid});
                _showActionSnackbar(
                    "Recorded ₱${debtPayment.toStringAsFixed(0)} payment to ${match['person']}");
              }
            } else {
              _showActionSnackbar("Could not find debt for '$debtPerson'");
            }
          }
          break;

        case 'delete_goal':
          // Delete a savings goal by name
          final goalName = action.params['name'] as String?;
          if (goalName != null) {
            final goals = await DBService.getGoals();
            final match = goals
                .where((g) => (g['name'] as String)
                    .toLowerCase()
                    .contains(goalName.toLowerCase()))
                .firstOrNull;
            if (match != null) {
              await DBService.deleteGoal(match['id'] as int);
              _showActionSnackbar("Goal deleted: ${match['name']}");
            }
          }
          break;

        case 'delete_recurring':
          // Delete a recurring transaction by title
          final recurTitle = action.params['title'] as String?;
          if (recurTitle != null) {
            final recurring = await DBService.getRecurring();
            final match = recurring
                .where((r) => (r['title'] as String)
                    .toLowerCase()
                    .contains(recurTitle.toLowerCase()))
                .firstOrNull;
            if (match != null) {
              await DBService.deleteRecurring(match['id'] as int);
              _showActionSnackbar("Recurring deleted: ${match['title']}");
            }
          }
          break;

        case 'set_wallet_balance':
          // Update a wallet balance by name
          final walletName = action.params['wallet_name'] as String?;
          final walletBalance = (action.params['balance'] as num?)?.toDouble();
          if (walletName != null &&
              walletBalance != null &&
              walletBalance >= 0) {
            final wallet = await DBService.findWalletByName(walletName);
            if (wallet != null) {
              await DBService.setWalletBalance(
                  wallet['id'] as int, walletBalance);
              _showActionSnackbar(
                  "${wallet['icon'] ?? '💵'} ${wallet['name']} updated: ${CurrencyService.format(walletBalance)}");
            } else {
              // Wallet not found — create it with appropriate icon
              final nameLower = walletName.toLowerCase();
              final icon = nameLower.contains('gcash')
                  ? '📱'
                  : nameLower.contains('maya') || nameLower.contains('paymaya')
                      ? '💜'
                      : nameLower.contains('grabpay') ||
                              nameLower.contains('grab pay')
                          ? '🟢'
                          : nameLower.contains('shopeepay') ||
                                  nameLower.contains('shopee pay')
                              ? '🟠'
                              : nameLower.contains('coins')
                                  ? '🪙'
                                  : nameLower.contains('cebuana') ||
                                          nameLower.contains('lhuillier') ||
                                          nameLower.contains('palawan') ||
                                          nameLower.contains('western union') ||
                                          nameLower.contains('lbc') ||
                                          nameLower.contains('tambunting') ||
                                          nameLower.contains('ussc') ||
                                          nameLower.contains('pawnshop')
                                      ? '🏪'
                                      : nameLower.contains('seabank')
                                          ? '🌊'
                                          : nameLower.contains('bank') ||
                                                  nameLower.contains('bdo') ||
                                                  nameLower.contains('bpi') ||
                                                  nameLower
                                                      .contains('metrobank') ||
                                                  nameLower
                                                      .contains('landbank') ||
                                                  nameLower.contains('pnb') ||
                                                  nameLower.contains('rcbc') ||
                                                  nameLower
                                                      .contains('security') ||
                                                  nameLower
                                                      .contains('chinabank') ||
                                                  nameLower
                                                      .contains('unionbank') ||
                                                  nameLower
                                                      .contains('eastwest') ||
                                                  nameLower
                                                      .contains('gotyme') ||
                                                  nameLower.contains('tonik') ||
                                                  nameLower
                                                      .contains('unobank') ||
                                                  nameLower
                                                      .contains('psbank') ||
                                                  nameLower.contains('maybank')
                                              ? '🏦'
                                              : '💵';
              final type = nameLower.contains('cash')
                  ? 'cash'
                  : nameLower.contains('gcash') ||
                          nameLower.contains('maya') ||
                          nameLower.contains('grab') ||
                          nameLower.contains('shopee') ||
                          nameLower.contains('coins') ||
                          nameLower.contains('lazada') ||
                          nameLower.contains('tiktok') ||
                          nameLower.contains('paypal') ||
                          nameLower.contains('wise')
                      ? 'ewallet'
                      : nameLower.contains('cebuana') ||
                              nameLower.contains('lhuillier') ||
                              nameLower.contains('palawan') ||
                              nameLower.contains('western') ||
                              nameLower.contains('lbc') ||
                              nameLower.contains('tambunting') ||
                              nameLower.contains('ussc')
                          ? 'remittance'
                          : 'bank';
              await DBService.insertWallet({
                'name': walletName,
                'type': type,
                'balance': walletBalance,
                'icon': icon,
              });
              _showActionSnackbar(
                  "$icon $walletName added: ${CurrencyService.format(walletBalance)}");
            }
          }
          break;
        case 'transfer_wallet':
          // Transfer money between wallets
          final fromName = action.params['from_wallet'] as String?;
          final toName = action.params['to_wallet'] as String?;
          final transferAmt = (action.params['amount'] as num?)?.toDouble();
          if (fromName != null &&
              toName != null &&
              transferAmt != null &&
              transferAmt > 0) {
            final fromWallet = await DBService.findWalletByName(fromName);
            final toWallet = await DBService.findWalletByName(toName);
            if (fromWallet != null && toWallet != null) {
              final success = await DBService.transferBetweenWallets(
                  fromWallet['id'] as int, toWallet['id'] as int, transferAmt);
              if (success) {
                _showActionSnackbar(
                    "Transferred ${CurrencyService.format(transferAmt)}: $fromName → $toName");
              } else {
                _showActionSnackbar(
                    "Transfer failed — insufficient balance in $fromName");
              }
            } else {
              _showActionSnackbar(
                  "Wallet not found: ${fromWallet == null ? fromName : toName}");
            }
          }
          break;

        case 'plan_salary_split':
          // Create budgets based on 50/30/20 (or custom) split
          final splitIncome = (action.params['income'] as num?)?.toDouble();
          final needsPct =
              (action.params['needs_pct'] as num?)?.toDouble() ?? 50;
          final wantsPct =
              (action.params['wants_pct'] as num?)?.toDouble() ?? 30;
          final savingsPct =
              (action.params['savings_pct'] as num?)?.toDouble() ?? 20;
          if (splitIncome != null && splitIncome > 0) {
            final needsBudget = splitIncome * needsPct / 100;
            final wantsBudget = splitIncome * wantsPct / 100;
            final savingsBudget = splitIncome * savingsPct / 100;
            // Set budgets for major need categories
            const needCats = [
              'Food',
              'Transportation',
              'Bills',
              'Health',
              'Education'
            ];
            const wantCats = [
              'Shopping',
              'Entertainment',
              'Gaming',
              'Personal Care',
              'Clothing',
              'Gifts',
              'Travel'
            ];
            final needPerCat = needsBudget / needCats.length;
            final wantPerCat = wantsBudget / wantCats.length;
            for (final cat in needCats) {
              await DBService.setBudget(cat, needPerCat.roundToDouble());
            }
            for (final cat in wantCats) {
              await DBService.setBudget(cat, wantPerCat.roundToDouble());
            }
            // Also update monthly income
            await DBService.setMonthlyIncome(splitIncome);
            fireEvent(AppEvent.incomeChanged);
            // Create savings goal if none exists
            final goals = await DBService.getGoals();
            final hasSavingsGoal = goals.any((g) =>
                (g['name'] as String).toLowerCase().contains('savings') ||
                (g['name'] as String).toLowerCase().contains('emergency'));
            if (!hasSavingsGoal) {
              await DBService.insertGoal({
                'name': 'Monthly Savings',
                'target_amount': savingsBudget * 6,
                'current_amount': 0.0,
                'start_date': DateTime.now().toIso8601String().substring(0, 10),
                'created_at': DateTime.now().toIso8601String(),
              });
            }
            _showActionSnackbar(
                "Salary split applied: ${needsPct.toInt()}/${wantsPct.toInt()}/${savingsPct.toInt()} — ${needCats.length + wantCats.length} budgets set");
          }
          break;

        case 'analyze_goal_feasibility':
          // Informational — AI provides the analysis in its reply text
          final goalName = action.params['goal_name'] as String? ?? 'Goal';
          _showActionSnackbar("📊 Feasibility analysis: $goalName");
          break;

        case 'suggest_debt_payoff':
          // Informational — AI provides the strategy in its reply
          final strategy = action.params['strategy'] as String? ?? 'avalanche';
          _showActionSnackbar(
              "📋 Debt payoff: ${strategy == 'avalanche' ? 'Avalanche (highest interest first)' : 'Snowball (smallest balance first)'}");
          break;

        case 'generate_monthly_plan':
          // AI generates the plan in its reply text — confirm
          _showActionSnackbar("📅 Monthly spending plan generated");
          break;

        case 'compare_periods':
          // AI provides the comparison in its reply text
          final p1 = action.params['period1'] as String? ?? '';
          final p2 = action.params['period2'] as String? ?? '';
          _showActionSnackbar("📊 Comparing $p1 vs $p2");
          break;

        case 'explain_fhs_breakdown':
          // AI provides the explanation in its reply text
          _showActionSnackbar("📋 FHS breakdown explained");
          break;

        case 'project_savings_timeline':
          // AI provides the projection in its reply text
          final projGoal = action.params['goal_name'] as String? ?? 'Goal';
          _showActionSnackbar("📈 Savings projection: $projGoal");
          break;

        case 'detect_subscriptions':
          // Scan expenses for repeating patterns and show findings
          try {
            final subExp = await DBService.getExpenses();
            // Group by item_name and count occurrences
            final nameCounts = <String, int>{};
            final nameAmounts = <String, double>{};
            for (final e in subExp) {
              final key = e.itemName.toLowerCase().trim();
              nameCounts[key] = (nameCounts[key] ?? 0) + 1;
              nameAmounts[key] = e.amount;
            }
            // Find items that appear 3+ times (likely subscriptions)
            final subs = nameCounts.entries
                .where((e) => e.value >= 3)
                .map((e) =>
                    '${e.key} (${e.value}x, ₱${nameAmounts[e.key]?.toStringAsFixed(0)})')
                .take(5)
                .toList();
            if (subs.isNotEmpty) {
              _showActionSnackbar(
                  "🔍 Found ${subs.length} potential subscription${subs.length > 1 ? 's' : ''}");
            } else {
              _showActionSnackbar("🔍 No recurring patterns detected yet");
            }
          } catch (_) {
            _showActionSnackbar("🔍 Subscription scan complete");
          }
          break;

        case 'compute_contribution':
          // AI provides the calculation in its reply text
          final contribType = action.params['type_name'] as String? ?? 'SSS';
          _showActionSnackbar("🧮 $contribType contribution computed");
          break;

        case 'suggest_idle_money':
          // AI provides investment suggestions in its reply text
          final idleAmt = (action.params['amount'] as num?)?.toDouble() ?? 0;
          _showActionSnackbar(
              "💡 Idle money suggestions for ${CurrencyService.format(idleAmt)}");
          break;

        case 'suggest_expense_cuts':
          // AI analyzes categories and suggests reductions
          _showActionSnackbar("✂️ Expense cut suggestions ready");
          break;

        case 'simulate_what_if':
          // AI projects impact of a change
          final whatIfChange = action.params['change'] as String? ?? 'change';
          _showActionSnackbar(
              "🔮 What-if: $whatIfChange — projection calculated");
          break;

        case 'create_debt_payment_plan':
          // AI creates a debt payoff schedule
          _showActionSnackbar("📋 Debt payment plan created");
          break;

        case 'split_expense':
          // Split an expense with someone — logs your share + creates debt for theirs
          final splitItem = action.params['item_name'] as String? ?? 'Expense';
          final splitTotal =
              (action.params['total_amount'] as num?)?.toDouble();
          final splitPerson = action.params['split_with'] as String?;
          final yourShare = (action.params['your_share'] as num?)?.toDouble();
          final splitCat = action.params['category'] as String? ?? 'Others';
          if (splitTotal != null &&
              splitPerson != null &&
              yourShare != null &&
              yourShare > 0) {
            final now = DateTime.now();
            await DBService.insertExpense({
              'item_name': '$splitItem (your share)',
              'category': splitCat,
              'amount': yourShare,
              'date': now.toIso8601String().substring(0, 10),
              'time': now.toIso8601String().substring(11, 19),
              'payment_method':
                  action.params['payment_method'] as String? ?? 'Cash',
              'notes':
                  'Split with $splitPerson (total: ${CurrencyService.format(splitTotal)})',
              'split_with': splitPerson,
              'ai_generated': 1,
              'confidence_score': 0.9,
              'is_want': 0,
            });
            final theirShare = splitTotal - yourShare;
            if (theirShare > 0) {
              await DBService.insertDebt({
                'title': '$splitItem split',
                'person': splitPerson,
                'amount': theirShare,
                'paid_amount': 0.0,
                'type': 'lent',
                'notes': 'Owes their share of $splitItem',
                'created_at': now.toIso8601String(),
              });
            }
            fireEvent(AppEvent.expenseChanged);
            _showActionSnackbar(
                "💸 Split logged: ${CurrencyService.format(yourShare)} your share — ${CurrencyService.format(theirShare)} owed by $splitPerson");
          }
          break;

        case 'set_spending_limit':
          // Set a daily / weekly / monthly / yearly spending cap
          // AI can trigger this via "set daily limit to 500" or Taglish equivalents
          final limitPeriod = action.params['period'] as String? ?? 'monthly';
          final limitAmount =
              (action.params['amount'] as num?)?.toDouble() ?? 0;
          if (['daily', 'weekly', 'monthly', 'yearly'].contains(limitPeriod)) {
            await DBService.setLimitForPeriod(limitPeriod, limitAmount);
            fireEvent(AppEvent.incomeChanged); // refresh home limit card
            if (limitAmount > 0) {
              _showActionSnackbar(
                  "Spending limit set: ₱${limitAmount.toStringAsFixed(0)} / $limitPeriod");
            } else {
              _showActionSnackbar("Spending limit cleared for $limitPeriod");
            }
          }
          break;

        case 'add_insurance_policy':
          // Add an insurance policy or PH government contribution entry
          final insName =
              action.params['name'] as String? ?? 'Insurance Policy';
          final insPremium =
              (action.params['premium_amount'] as num?)?.toDouble();
          final insFreq = action.params['frequency'] as String? ?? 'monthly';
          final insType = action.params['type_name'] as String? ?? 'other';
          final insDueDay = action.params['due_day'] as int?;
          if (insPremium != null && insPremium > 0) {
            final now = DateTime.now();
            String nextDue;
            switch (insFreq) {
              case 'quarterly':
                final qMonth = (now.month + 3 - 1) % 12 + 1;
                final qYear = now.month + 3 > 12 ? now.year + 1 : now.year;
                nextDue = DateTime(qYear, qMonth, insDueDay ?? now.day)
                    .toIso8601String()
                    .substring(0, 10);
                break;
              case 'yearly':
                nextDue =
                    DateTime(now.year + 1, now.month, insDueDay ?? now.day)
                        .toIso8601String()
                        .substring(0, 10);
                break;
              default: // monthly
                final nm = now.month == 12
                    ? DateTime(now.year + 1, 1, insDueDay ?? now.day)
                    : DateTime(now.year, now.month + 1, insDueDay ?? now.day);
                nextDue = nm.toIso8601String().substring(0, 10);
            }
            await DBService.insertInsurancePolicy({
              'name': insName,
              'type': insType,
              'premium_amount': insPremium,
              'frequency': insFreq,
              'next_due_date': nextDue,
              'notes': 'Added via AI chat',
              'created_at': now.toIso8601String(),
            });
            fireEvent(AppEvent.expenseChanged);
            _showActionSnackbar(
                "✅ $insName added: ₱${insPremium.toStringAsFixed(0)}/$insFreq (next due: $nextDue)");
          }
          break;
      }
    } catch (e) {
      // Show error so we know if something failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Action failed (${action.type}): ${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ));
      }
    }
  }

  void _showActionSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _startVoiceInput() async {
    setState(() => _isListening = true);
    try {
      final text = await _voiceService.startListening(
        onPartialResult: (p) {
          if (mounted) setState(() => _controller.text = p);
        },
      );
      if (mounted) {
        setState(() {
          _isListening = false;
          _controller.text = text;
        });
        await _send();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard"),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text("AI Model",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                  "Choose your AI engine. Auto-fallback switches models when daily limit is reached.",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              ...AppConfig.availableModels.map((m) {
                final isActive = AppConfig.activeModelId == m.$1;
                final isGroqLimited =
                    m.$1 == 'groq_llama' && AppConfig.groqLimitReached;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isActive
                        ? Theme.of(ctx)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    child: Icon(
                      isActive ? Icons.check : Icons.radio_button_unchecked,
                      size: 18,
                      color: isActive
                          ? Theme.of(ctx).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                  title: Text(m.$2,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Text(
                      isGroqLimited ? '🟡 Daily limit reached' : m.$3,
                      style: TextStyle(
                          fontSize: 11,
                          color: isGroqLimited ? Colors.orange : Colors.grey)),
                  onTap: () {
                    AppConfig.setModel(m.$1);
                    AIChatService.clearHistory();
                    Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Switched to ${m.$2}"),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                );
              }),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                    "💡 To enable Gemini/Cerebras fallback, add API keys in Firebase Remote Config: gemini_api_key / cerebras_api_key",
                    style: TextStyle(fontSize: 11, height: 1.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageMenu(BuildContext ctx, String text, bool isUser) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text("Copy message"),
                onTap: () {
                  Navigator.pop(ctx);
                  _copyMessage(text);
                },
              ),
              ListTile(
                leading: const Icon(Icons.reply_outlined),
                title: const Text("Use as new message"),
                subtitle: const Text("Fill in chat box with this text",
                    style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _controller.text = text);
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));
                },
              ),
              if (!isUser)
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text("Share message"),
                  onTap: () {
                    Navigator.pop(ctx);
                    // Share plain text via share sheet
                    final stripped = text
                        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
                        .replaceAll('**', '');
                    Share.share(stripped, subject: "SmartSpend AI Insight");
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── UNIFIED SMART IMPORT ─────────────────────────────────────────────────

  /// Shows the unified Smart Import bottom sheet — one entry point for all
  /// image/text import modes: Live Camera, Single Photo, Batch Screenshots,
  /// and Paste Text.
  void _showSmartImportSheet() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Icon(Icons.camera_enhance, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                const Text("Smart Import",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 4),
              Text("Import expenses from any source",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 14),
              // 2×2 grid of import options
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.6,
                children: [
                  _importTile(
                    ctx,
                    icon: Icons.camera_alt_outlined,
                    label: "Live Camera",
                    sublabel: "Scan barcode / receipt",
                    color: cs.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSmartCamera();
                    },
                  ),
                  _importTile(
                    ctx,
                    icon: Icons.image_outlined,
                    label: "Single Photo",
                    sublabel: "One receipt or screenshot",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSinglePhoto();
                    },
                  ),
                  _importTile(
                    ctx,
                    icon: Icons.photo_library_outlined,
                    label: "Batch Screenshots",
                    sublabel: "Shopee, Steam, GCash…",
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleBatchImport();
                    },
                  ),
                  _importTile(
                    ctx,
                    icon: Icons.content_paste_outlined,
                    label: "Paste Text",
                    sublabel: "GCash / BPI / Maya export",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(ctx);
                      _handlePasteImport();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _importTile(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color)),
                  Text(sublabel,
                      style: TextStyle(
                          fontSize: 10, color: color.withValues(alpha: 0.7)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single photo from gallery — auto-routes to BatchImageImportScreen for
  /// screenshots (Steam, Shopee, GCash, etc.) or BankImportScreen for
  /// receipts/transaction history.
  Future<void> _handleSinglePhoto() async {
    try {
      final paths = await OCRService.pickMultipleImages(maxImages: 1);
      if (paths.isEmpty || !mounted) return;
      final path = paths.first;

      // Show brief processing snackbar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 12),
          Text("Analyzing image..."),
        ]),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 8),
      ));

      // ── STEP 1: Try barcode detection first ─────────────────────────────
      // Gallery images of product barcodes / QR codes get decoded here,
      // exactly like the live camera flow does for real-time scans.
      String? barcodeValue;
      String? barcodeFormat;
      try {
        final inputImage = InputImage.fromFilePath(path);
        final scanner = BarcodeScanner();
        final barcodes = await scanner.processImage(inputImage);
        await scanner.close();
        if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
          barcodeValue = barcodes.first.rawValue;
          barcodeFormat = barcodes.first.format.name;
        }
      } catch (_) {}

      if (barcodeValue != null && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        await DBService.insertScan(barcodeValue);
        // Look up product info
        ProductInfo? productInfo;
        try {
          productInfo = await BarcodeLookupService.lookup(barcodeValue);
        } catch (_) {}
        final prefill = productInfo != null
            ? 'I bought ${productInfo.displayName}${productInfo.estimatedPrice != null ? ' for ${productInfo.estimatedPrice!.toStringAsFixed(0)}' : ''}'
            : 'Barcode: $barcodeValue\n\nI bought: ';
        final reviewed = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (_) => ScanReviewScreen(
              initialText: prefill,
              title:
                  productInfo != null ? 'Confirm Product' : 'Describe Product',
              isBarcode: true,
              barcodeFormat: barcodeFormat,
            ),
          ),
        );
        if (reviewed != null && reviewed.isNotEmpty && mounted) {
          _controller.text = reviewed;
          await _send();
        }
        return;
      }

      // ── STEP 2: OCR + smart routing ─────────────────────────────────────
      final ocrText = await OCRService.scanImageRaw(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      final screenshotType = LLMService.detectScreenshotType(ocrText);
      final docType = OCRService.detectDocumentType(ocrText);

      // Receipts and transaction history → BankImportScreen (structured text parser)
      // Screenshots of apps → BatchImageImportScreen (screenshot-aware AI parser)
      final isReceiptOrDoc =
          docType == 'receipt' || docType == 'transaction_history';
      final isScreenshot = !isReceiptOrDoc && screenshotType != 'unknown';

      if (isScreenshot) {
        // Route to batch screen pre-loaded with this one image
        final imported = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (_) => BatchImageImportScreen(preloadedPaths: [path])),
        );
        if (imported == true && mounted) _loadContext(silent: true);
      } else if (isReceiptOrDoc || ocrText.isNotEmpty) {
        // Receipt / transaction history / fallback → text-based import
        final source = docType == 'transaction_history' ? 'GCash' : 'Receipt';
        final imported = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  BankImportScreen(prefillText: ocrText, sourceLabel: source)),
        );
        if (imported == true && mounted) _loadContext(silent: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Could not read image: ${e.toString().replaceAll('Exception: ', '')}"),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  /// Batch screenshot import — open BatchImageImportScreen.
  Future<void> _handleBatchImport() async {
    final imported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const BatchImageImportScreen()),
    );
    if (imported == true && mounted) _loadContext(silent: true);
  }

  /// Paste text import — open BankImportScreen with no prefill (user pastes).
  Future<void> _handlePasteImport() async {
    final imported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const BankImportScreen()),
    );
    if (imported == true && mounted) _loadContext(silent: true);
  }

  Future<void> _handleSmartCamera() async {
    // Open unified Smart Camera Screen — Auto/Receipt/Barcode + Gallery
    final result = await Navigator.push<ScanResult>(
      context,
      MaterialPageRoute(builder: (_) => const SmartCameraScreen()),
    );
    if (result == null || result.text.isEmpty || !mounted) return;

    // Check if user chose "Import Items" from the review screen
    final isReceiptImport = result.barcodeFormat == 'receipt_import';

    if (result.isBarcode && !isReceiptImport) {
      // Barcode/QR — send description to AI chat as usual
      _controller.text = result.text;
      await _send();
    } else {
      // Receipt/document OCR — check if it looks like a multi-item receipt
      final text = result.text;
      final docType = _detectScanType(text);

      if (docType == 'receipt_multi' || isReceiptImport) {
        // Multi-item receipt → route to Import screen for structured review
        final imported = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BankImportScreen(prefillText: text, sourceLabel: 'Receipt'),
          ),
        );
        if (imported == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("✓ Receipt items imported"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
          await _loadContext(silent: true);
        }
      } else {
        // Single item or simple text — send to AI chat
        _controller.text = text;
        await _send();
      }
    }
  }

  /// Detect if scanned text looks like a multi-item receipt or a single expense
  String _detectScanType(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    // Count lines with amounts (₱ or decimal numbers)
    final amountLines = lines
        .where((l) =>
            RegExp(r'[₱\d]\d*\.\d{2}').hasMatch(l) ||
            RegExp(r'₱\s*\d+').hasMatch(l))
        .length;
    // If 2+ amount lines → likely a multi-item receipt (lowered from 3)
    if (amountLines >= 2) return 'receipt_multi';
    // If it has "total" or "subtotal" → receipt
    if (text.toLowerCase().contains('total') ||
        text.toLowerCase().contains('subtotal')) return 'receipt_multi';
    return 'single';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart AI Assistant"),
        actions: [
          const InfoButton(
            title: "Smart AI Assistant",
            body:
                "Your personal finance AI — powered by Gemini 3.1 Flash-Lite (primary) with 5-provider auto-failover.\n\n"
                "The AI knows your expenses, budgets, goals, income, debts, and mood.\n\n"
                "💡 Try asking:\n"
                "• \"Spent 30 for jeepney\" — logs instantly\n"
                "• \"My daily allowance is ₱300\" — sets income\n"
                "• \"Split my salary 50/30/20\" — creates budgets\n"
                "• \"Move ₱500 from Cash to GCash\" — wallet transfer\n"
                "• \"Add ShopeePayLater ₱373/month for 3 months\" — payment plan\n"
                "• \"Fix capitalization of my expenses this week\"\n"
                "• \"How much did I spend on food this month?\"\n"
                "• \"Why is my FHS score low?\" — detailed breakdown\n"
                "• \"Compare this month to last month\"\n"
                "• \"Plan my monthly budget\" — generates spending plan\n"
                "• \"How do I apply for SSS loan?\"\n"
                "• \"Is ₱12,000 a good price for a ref?\"\n\n"
                "29 action types: log/update/delete expenses, set budgets, manage goals, debts, recurring, payment plans, wallet balances, transfers, salary splits, subscription detection, idle money suggestions, expense cuts, what-if simulation, debt payment plan, split bills, and more.\n\n"
                "Daily message limit: 60/day per model — auto-switches to next model when limit reached.",
          ),
          // Model selector — shows current model with status
          GestureDetector(
            onTap: _showModelSelector,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                avatar: Text(AppConfig.groqLimitReached ? '🟡' : '🟢',
                    style: const TextStyle(fontSize: 10)),
                label: Text(
                  AppConfig.activeModelLabel.split(' ').first == 'Gemini'
                      ? 'Gemini'
                      : AppConfig.activeModelLabel.split(' ').first == 'LLaMA'
                          ? 'LLaMA'
                          : AppConfig.activeModelLabel.split(' ').first,
                  style: const TextStyle(fontSize: 10),
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          // D2: show remaining daily messages with reset countdown
          FutureBuilder<int>(
            key: ValueKey(_sending),
            future: AIChatService.getRemainingMessages(),
            builder: (_, snap) {
              final remaining = snap.data;
              if (remaining == null) return const SizedBox.shrink();
              // BT-4: Show reset countdown when limit is low
              final now = DateTime.now().toUtc();
              final midnight = DateTime.utc(now.year, now.month, now.day + 1);
              final hoursLeft = midnight.difference(now).inHours;
              final minsLeft = midnight.difference(now).inMinutes % 60;
              final resetStr = hoursLeft > 0
                  ? "Resets in ${hoursLeft}h ${minsLeft}m"
                  : "Resets in ${minsLeft}m";
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$remaining left",
                        style: TextStyle(
                            fontSize: 11,
                            color: remaining <= 10
                                ? Colors.orange
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5)),
                      ),
                      if (remaining <= 15)
                        Text(
                          resetStr,
                          style:
                              TextStyle(fontSize: 9, color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Chat history",
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChatHistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Clear chat",
            onPressed: () async {
              AIChatService.clearHistory();
              await DBService.clearChatHistory();
              setState(() {
                _messages.clear();
                _historyRestored = false;
              });
              _loadContext();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: "More options",
            onSelected: (val) async {
              if (val == 'export_debug') {
                try {
                  await DebugService.exportDebugLog();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Export failed: ${e.toString().replaceAll('Exception: ', '')}"),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                }
              } else if (val == 'reset_limit') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('ai_chat_count');
                await prefs.remove('ai_chat_date');
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Daily AI limit reset ✓"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'export_debug',
                child: Row(
                  children: [
                    Icon(Icons.bug_report_outlined, size: 18),
                    SizedBox(width: 10),
                    Text("Export Debug Log"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset_limit',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 10),
                    Text("Reset Daily Limit"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_contextLoaded) const LinearProgressIndicator(),
          Expanded(
            child: _messages.isEmpty && !_contextLoaded
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.smart_toy,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            const Text("Ask me anything about your finances.",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 6),
                            const Text(
                                "I know your expenses, budgets, income & health score.",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 20),
                            // Contextual quick-action chips (time-based)
                            Builder(builder: (ctx) {
                              final hour = DateTime.now().hour;
                              final isMorning = hour >= 5 && hour < 12;
                              final isEvening = hour >= 17;
                              final chips = isMorning
                                  ? [
                                      "Log breakfast",
                                      "What's due this week?",
                                      "How am I doing this month?",
                                      "Check today's budget",
                                      "What if I cut $_topSpendingCategory by ₱500/month?",
                                    ]
                                  : isEvening
                                      ? [
                                          "Log dinner",
                                          "How did I do today?",
                                          "Where am I overspending?",
                                          "Update my savings",
                                          "What if I save 20% of my income?",
                                        ]
                                      : [
                                          "How am I doing this month?",
                                          "Where am I overspending?",
                                          "How can I save more?",
                                          "Am I on track with my budget?",
                                          "What if I cut $_topSpendingCategory by ₱500/month?",
                                        ];
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: chips
                                    .map((prompt) => ActionChip(
                                          label: Text(prompt,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          onPressed: () {
                                            _controller.text = prompt;
                                            _send();
                                          },
                                        ))
                                    .toList(),
                              );
                            }),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length + (_sending ? 1 : 0),
                        itemBuilder: (_, i) {
                          // Typing indicator as last item
                          if (_sending && i == _messages.length) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                    bottomLeft: Radius.circular(2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("Peso is thinking",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.grey)),
                                    const SizedBox(width: 4),
                                    _TypingDots(),
                                  ],
                                ),
                              ),
                            );
                          }
                          final msg = _messages[i];
                          final isUser = msg["role"] == "user";
                          final text = msg["text"]!;
                          final isError = msg["is_error"] == "true";

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: () =>
                                  _showMessageMenu(context, text, isUser),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.78),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft:
                                        Radius.circular(isUser ? 14 : 2),
                                    bottomRight:
                                        Radius.circular(isUser ? 2 : 14),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    isUser
                                        ? Text(text,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                height: 1.4))
                                        : MarkdownBody(
                                            data: text,
                                            styleSheet: MarkdownStyleSheet(
                                              p: const TextStyle(height: 1.4),
                                              strong: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              em: const TextStyle(
                                                  fontStyle: FontStyle.italic),
                                              listBullet:
                                                  const TextStyle(height: 1.4),
                                            ),
                                          ),
                                    // Retry button on error messages
                                    if (isError &&
                                        _lastUserMessage != null &&
                                        !_sending) ...[
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        icon:
                                            const Icon(Icons.refresh, size: 14),
                                        label: const Text("Retry",
                                            style: TextStyle(fontSize: 12)),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          // Remove the error message and retry
                                          setState(
                                              () => _messages.removeLast());
                                          _send(retryText: _lastUserMessage);
                                        },
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text("Hold to copy",
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: isUser
                                                  ? Colors.white38
                                                  : Colors.grey[400])),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: LinearProgressIndicator(),
            ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                // Push input row above keyboard when it's open
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom + 8
                    : 8,
              ),
              child: Row(
                children: [
                  // Unified Smart Import button — camera + gallery + batch + paste
                  IconButton(
                    icon: Icon(Icons.camera_enhance,
                        size: 22, color: Theme.of(context).colorScheme.primary),
                    onPressed: _sending ? null : _showSmartImportSheet,
                    tooltip: "Smart Import",
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.stop_circle : Icons.mic,
                      size: 22,
                      color: _isListening
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _sending
                        ? null
                        : (_isListening
                            ? _voiceService.stop
                            : _startVoiceInput),
                    tooltip: "Voice input",
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 2),
                  // Manual entry — no AI needed
                  IconButton(
                    icon: Icon(Icons.edit_note,
                        size: 22, color: Theme.of(context).colorScheme.primary),
                    onPressed: _sending
                        ? null
                        : () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AddExpenseScreen()));
                            if (result == true && mounted) {
                              await _loadContext(silent: true);
                            }
                          },
                    tooltip: "Manual entry (no AI needed)",
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 140),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: TextField(
                          controller: _controller,
                          maxLines: 6,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? "Listening..."
                                : "Ask about your spending...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'fab_ai_send',
                    onPressed: _send,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated 3-dot typing indicator
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final phase = (_anim.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: phase == i ? 0.9 : 0.35),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
