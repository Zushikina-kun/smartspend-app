import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';
import 'edit_expense_screen.dart';

/// BC-1: Unified financial timeline calendar.
/// Shows recurring bills, debt due dates, goal deadlines,
/// installment payment days, and income expected dates — all color-coded.
/// BC-3: Tap any event to log it directly.
class BillCalendarScreen extends StatefulWidget {
  const BillCalendarScreen({super.key});

  @override
  State<BillCalendarScreen> createState() => _BillCalendarScreenState();
}

class _BillCalendarScreenState extends State<BillCalendarScreen> {
  List<Map<String, dynamic>> _recurring = [];
  List<Map<String, dynamic>> _debts = [];
  List<Map<String, dynamic>> _goals = [];
  List<Map<String, dynamic>> _installments = [];
  List<Map<String, dynamic>> _installmentPlans = []; // Payment Plans tab
  List<Map<String, dynamic>> _scoreHistory = []; // SC-1: score dots
  List<Map<String, dynamic>> _expensesByDate = []; // actual logged expenses
  bool _loading = true;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  // Event type colors
  static const _colorBill = Colors.orange;
  static const _colorIncome = Colors.green;
  static const _colorDebt = Colors.red;
  static const _colorGoal = Colors.teal;
  static const _colorInstallment = Colors.purple;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final recurring = await DBService.getRecurring();
    final debts = await DBService.getDebts();
    final goals = await DBService.getGoals();
    List<Map<String, dynamic>> installments = [];
    try {
      final db = await DBService.getDB();
      installments = await db.query('installments');
    } catch (_) {}
    // Load installment_plans (Payment Plans tab) for calendar events
    List<Map<String, dynamic>> installmentPlans = [];
    try {
      final db = await DBService.getDB();
      installmentPlans = await db.query('installment_plans');
    } catch (_) {}
    // SC-1: Load score history for dot indicators
    final scoreHistory = await DBService.getScoreHistory(days: 60);
    // Load all expenses as raw maps for the day detail sheet
    final expenses = await DBService.getExpenses();
    final expenseMaps = expenses.map((e) => e.toMap()).toList();

    if (mounted) {
      setState(() {
        _recurring = recurring;
        _debts = debts;
        _goals = goals;
        _installments = installments;
        _installmentPlans = installmentPlans;
        _scoreHistory = scoreHistory;
        _expensesByDate = expenseMaps;
        _loading = false;
      });
    }
  }

  /// Build a map of day → list of events for the displayed month.
  /// Each event: {title, type, amount, color, icon, data}
  Map<int, List<Map<String, dynamic>>> _getEventsByDay() {
    final result = <int, List<Map<String, dynamic>>>{};

    void add(int day, Map<String, dynamic> event) {
      result.putIfAbsent(day, () => []).add(event);
    }

    // Recurring bills and income
    for (final r in _recurring) {
      final nextStr = r['next_date'] as String? ?? '';
      if (nextStr.isEmpty) continue;
      try {
        final d = DateTime.parse(nextStr);
        if (d.year == _month.year && d.month == _month.month) {
          final isExpense = (r['is_expense'] as int? ?? 1) == 1;
          add(d.day, {
            'title': r['title'],
            'type': isExpense ? 'bill' : 'income',
            'amount': (r['amount'] as num).toDouble(),
            'color': isExpense ? _colorBill : _colorIncome,
            'icon': isExpense ? Icons.repeat : Icons.arrow_downward,
            'data': r,
            'loggable': true,
          });
        }
      } catch (_) {}
    }

    // Debt due dates
    for (final d in _debts) {
      final due = d['due_date'] as String?;
      if (due == null || due.isEmpty) continue;
      final remaining = (d['amount'] as num) - (d['paid_amount'] as num);
      if (remaining <= 0) continue;
      try {
        final dt = DateTime.parse(due);
        if (dt.year == _month.year && dt.month == _month.month) {
          add(dt.day, {
            'title': '${d['title']} → ${d['person']}',
            'type': 'debt',
            'amount': remaining.toDouble(),
            'color': _colorDebt,
            'icon': Icons.handshake_outlined,
            'data': d,
            'loggable': false,
          });
        }
      } catch (_) {}
    }

    // Goal deadlines
    for (final g in _goals) {
      final deadline = g['deadline'] as String?;
      if (deadline == null || deadline.isEmpty) continue;
      final current = (g['current_amount'] as num).toDouble();
      final target = (g['target_amount'] as num).toDouble();
      if (current >= target) continue;
      try {
        final dt = DateTime.parse(deadline);
        if (dt.year == _month.year && dt.month == _month.month) {
          add(dt.day, {
            'title': '🎯 ${g['name']} deadline',
            'type': 'goal',
            'amount': target - current,
            'color': _colorGoal,
            'icon': Icons.savings_outlined,
            'data': g,
            'loggable': false,
          });
        }
      } catch (_) {}
    }

    // Installment payment days (use start_date day of month as payment day)
    for (final inst in _installments) {
      final startStr = inst['start_date'] as String?;
      if (startStr == null) continue;
      final monthsPaid = inst['months_paid'] as int? ?? 0;
      final monthsTotal = inst['months_total'] as int? ?? 0;
      if (monthsPaid >= monthsTotal) continue;
      try {
        final start = DateTime.parse(startStr);
        final payDay =
            start.day.clamp(1, DateTime(_month.year, _month.month + 1, 0).day);
        add(payDay, {
          'title': '${inst['name']} installment',
          'type': 'installment',
          'amount': (inst['monthly_payment'] as num).toDouble(),
          'color': _colorInstallment,
          'icon': Icons.payment_outlined,
          'data': inst,
          'loggable': false,
        });
      } catch (_) {}
    }

    // Payment Plans (installment_plans table) — due on their due_day each month
    for (final plan in _installmentPlans) {
      final monthsPaid = plan['months_paid'] as int? ?? 0;
      final monthsTotal = plan['months_total'] as int? ?? 0;
      if (monthsPaid >= monthsTotal) continue;
      final dueDay = (plan['due_day'] as int? ?? 5)
          .clamp(1, DateTime(_month.year, _month.month + 1, 0).day);
      final provider = plan['provider'] as String?;
      final title = provider != null
          ? '${plan['title']} ($provider)'
          : plan['title'] as String;
      add(dueDay, {
        'title': '$title payment',
        'type': 'installment',
        'amount': (plan['monthly_payment'] as num).toDouble(),
        'color': _colorInstallment,
        'icon': Icons.credit_score_outlined,
        'data': plan,
        'loggable': false,
      });
    }

    return result;
  }

  void _showDaySheet(int day, List<Map<String, dynamic>> events) {
    final date = DateTime(_month.year, _month.month, day);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final fmt = DateFormat('MMMM d, yyyy');

    // Get actual expenses logged on this day
    final dayExpenses = _expensesByDate
        .where((e) => (e['date'] as String?)?.startsWith(dateStr) == true)
        .toList();
    final dayTotal =
        dayExpenses.fold<double>(0, (s, e) => s + (e['amount'] as num? ?? 0));

    // Get score for this day
    final scoreEntry = _scoreHistory.firstWhere(
      (s) => s['date'] == dateStr,
      orElse: () => {},
    );
    final score = scoreEntry.isNotEmpty ? scoreEntry['score'] as int : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollCtrl) => ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Date header + score badge
              Row(
                children: [
                  Expanded(
                    child: Text(fmt.format(date),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (score >= 80
                                ? Colors.green
                                : score >= 60
                                    ? Colors.orange
                                    : Colors.red)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (score >= 80
                                  ? Colors.green
                                  : score >= 60
                                      ? Colors.orange
                                      : Colors.red)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: score >= 80
                              ? Colors.green
                              : score >= 60
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── ACTUAL EXPENSES ──────────────────────────────────────────
              if (dayExpenses.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined,
                        size: 15, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Expenses — ${CurrencyService.format(dayTotal)} total",
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...dayExpenses.map((e) {
                  final isWant = (e['is_want'] as int? ?? 0) == 1;
                  final expenseId = e['id'] as int?;
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: expenseId == null
                        ? null
                        : () async {
                            Navigator.pop(context);
                            final allExpenses = await DBService.getExpenses();
                            final match = allExpenses.firstWhere(
                              (ex) => ex.id == expenseId,
                              orElse: () => allExpenses.first,
                            );
                            if (mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditExpenseScreen(expense: match),
                                ),
                              );
                              _load();
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8, top: 2),
                            decoration: BoxDecoration(
                              color: isWant
                                  ? Colors.orange
                                  : cs.primary.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e['item_name'] as String? ?? 'Expense',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e['category'] as String? ?? '',
                            style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.45)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyService.format(
                                (e['amount'] as num?)?.toDouble() ?? 0),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              size: 14,
                              color: cs.onSurface.withValues(alpha: 0.3)),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(height: 20),
              ] else if (events.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "No expenses or events on this day.",
                      style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                          fontSize: 13),
                    ),
                  ),
                ),
              ],

              // ── FINANCIAL EVENTS ─────────────────────────────────────────
              if (events.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.event_outlined,
                        size: 15, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text("Financial Events",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                ...events.map((e) {
                  final color = e['color'] as Color;
                  final loggable = e['loggable'] as bool;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child:
                          Icon(e['icon'] as IconData, color: color, size: 18),
                    ),
                    title: Text(e['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      _typeLabel(e['type'] as String),
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyService.format(e['amount'] as double),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: color),
                        ),
                        if (loggable) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _logEvent(e);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: color,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text("Log",
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'bill':
        return 'Recurring bill';
      case 'income':
        return 'Expected income';
      case 'debt':
        return 'Debt due';
      case 'goal':
        return 'Goal deadline';
      case 'installment':
        return 'Installment payment';
      default:
        return type;
    }
  }

  Future<void> _logEvent(Map<String, dynamic> event) async {
    final data = event['data'] as Map<String, dynamic>;
    final isExpense = event['type'] == 'bill';
    final now = DateTime.now();

    if (isExpense) {
      await DBService.insertExpense({
        'item_name': data['title'],
        'category': data['category'] ?? 'Others',
        'amount': data['amount'],
        'date': now.toIso8601String().substring(0, 10),
        'time': now.toIso8601String().substring(11, 16),
        'payment_method': 'Cash',
        'notes': 'Logged from Bill Calendar',
        'ai_generated': 0,
        'confidence_score': 1.0,
      });
    } else {
      await DBService.insertIncome({
        'title': data['title'],
        'amount': data['amount'],
        'category': data['category'] ?? 'Salary',
        'date': now.toIso8601String().substring(0, 10),
        'is_recurring': 1,
      });
    }

    // Advance next_date
    try {
      final current = DateTime.parse(data['next_date'] as String);
      final freq = data['frequency'] as String? ?? 'monthly';
      DateTime next;
      if (freq == 'daily')
        next = current.add(const Duration(days: 1));
      else if (freq == 'weekly')
        next = current.add(const Duration(days: 7));
      else {
        final nm = current.month == 12 ? 1 : current.month + 1;
        final ny = current.month == 12 ? current.year + 1 : current.year;
        final lastDay = DateTime(ny, nm + 1, 0).day;
        next = DateTime(ny, nm, current.day.clamp(1, lastDay));
      }
      await DBService.updateRecurring(
          {...data, 'next_date': next.toIso8601String().substring(0, 10)});
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${data['title']} logged ✓"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final eventsByDay = _getEventsByDay();
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;
    final monthFmt = DateFormat('MMMM yyyy');
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Calendar"),
        actions: [
          const InfoButton(
            title: "Financial Calendar",
            body:
                "A unified view of all your financial events and daily spending — color-coded by type:\n\n"
                "🟠 Orange — Recurring bills due\n"
                "🟢 Green — Expected income\n"
                "🔴 Red — Debt payments due\n"
                "🩵 Teal — Savings goal deadlines\n"
                "🟣 Purple — Installment payment days\n"
                "⚫ Gray dot — Days with logged expenses\n\n"
                "Tap any day to see what you spent + upcoming events.\n"
                "Tap 'Log' on bills or income to record them instantly.\n"
                "Score dots (green/orange/red) show your Financial Health Score for each day.",
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Month navigation
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() =>
                            _month = DateTime(_month.year, _month.month - 1)),
                      ),
                      Text(monthFmt.format(_month),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() =>
                            _month = DateTime(_month.year, _month.month + 1)),
                      ),
                    ],
                  ),
                ),

                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _legendItem(_colorBill, "Bill"),
                      _legendItem(_colorIncome, "Income"),
                      _legendItem(_colorDebt, "Debt"),
                      _legendItem(_colorGoal, "Goal"),
                      _legendItem(_colorInstallment, "Installment"),
                      _legendItem(
                          cs.onSurface.withValues(alpha: 0.3), "Expenses"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Day-of-week headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(d,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface
                                            .withValues(alpha: 0.5))),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),

                // Calendar grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Stack(
                      children: [
                        GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: firstWeekday + daysInMonth,
                          itemBuilder: (_, i) {
                            if (i < firstWeekday)
                              return const SizedBox.shrink();
                            final day = i - firstWeekday + 1;
                            final events = eventsByDay[day] ?? [];
                            final isToday = today.year == _month.year &&
                                today.month == _month.month &&
                                today.day == day;
                            final hasEvents = events.isNotEmpty;

                            // SC-1: Get score for this day
                            final dateStr = DateFormat('yyyy-MM-dd').format(
                                DateTime(_month.year, _month.month, day));
                            final scoreEntry = _scoreHistory.firstWhere(
                              (s) => s['date'] == dateStr,
                              orElse: () => {},
                            );
                            final score = scoreEntry.isNotEmpty
                                ? scoreEntry['score'] as int
                                : -1;
                            final scoreColor = score >= 80
                                ? Colors.green
                                : score >= 60
                                    ? Colors.orange
                                    : score >= 0
                                        ? Colors.red
                                        : null;

                            // Check if any expenses were logged on this day
                            final hasExpenses = _expensesByDate.any((e) =>
                                (e['date'] as String?)?.startsWith(dateStr) ==
                                true);

                            // Get unique colors for dot indicators
                            final dotColors = events
                                .map((e) => e['color'] as Color)
                                .toSet()
                                .take(3)
                                .toList();

                            // All days are tappable — show expenses + events
                            final isTappable =
                                hasEvents || hasExpenses || isToday;

                            return GestureDetector(
                              onTap: isTappable
                                  ? () => _showDaySheet(day, events)
                                  : null,
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? cs.primary.withValues(alpha: 0.1)
                                      : hasEvents
                                          ? cs.surfaceContainerHighest
                                              .withValues(alpha: 0.5)
                                          : hasExpenses
                                              ? cs.surfaceContainerHighest
                                                  .withValues(alpha: 0.25)
                                              : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isToday
                                      ? Border.all(
                                          color:
                                              cs.primary.withValues(alpha: 0.5))
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            isToday || hasEvents || hasExpenses
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color: isToday ? cs.primary : null,
                                      ),
                                    ),
                                    if (hasEvents) ...[
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: dotColors
                                            .map((c) => Container(
                                                  width: 5,
                                                  height: 5,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 1),
                                                  decoration: BoxDecoration(
                                                      color: c,
                                                      shape: BoxShape.circle),
                                                ))
                                            .toList(),
                                      ),
                                      if (events.length > 1)
                                        Text('${events.length}',
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: cs.onSurface
                                                    .withValues(alpha: 0.5))),
                                    ] else if (hasExpenses) ...[
                                      // Small gray dot for days with expenses but no events
                                      const SizedBox(height: 3),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: cs.onSurface
                                              .withValues(alpha: 0.25),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                    // SC-1: Score dot
                                    if (scoreColor != null)
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.only(top: 1),
                                        decoration: BoxDecoration(
                                          color:
                                              scoreColor.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Empty state — shown when no events exist for this month
                        if (eventsByDay.isEmpty)
                          Positioned.fill(
                            top: 80,
                            child: IgnorePointer(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.event_available_outlined,
                                        size: 40,
                                        color: cs.onSurface
                                            .withValues(alpha: 0.2)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "No upcoming events this month",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.35)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Add recurring bills, debts, or goals\nto see them here.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.25)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
