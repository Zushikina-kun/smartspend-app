// lib/screens/heatmap_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../models/expense.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  DateTime _currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  List<Expense> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _loading = true);
    final all = await DBService.getExpenses();
    final filtered = all.where((e) {
      try {
        final d = DateTime.parse(e.date);
        return d.year == _currentMonth.year && d.month == _currentMonth.month;
      } catch (_) {
        return false;
      }
    }).toList();
    if (mounted) {
      setState(() {
        _expenses = filtered;
        _loading = false;
      });
    }
  }

  Map<int, double> _buildDailyTotals() {
    final map = <int, double>{};
    for (final e in _expenses) {
      try {
        final d = DateTime.parse(e.date);
        map[d.day] = (map[d.day] ?? 0) + e.amount;
      } catch (_) {}
    }
    return map;
  }

  double _dailyAvg(Map<int, double> totals) {
    if (totals.isEmpty) return 0;
    final sum = totals.values.fold(0.0, (a, b) => a + b);
    return sum / totals.length;
  }

  Color _cellColor(double total, double avg) {
    if (total == 0) return Colors.grey.shade200;
    if (total < avg) return Colors.green.shade300;
    if (total < 2 * avg) return Colors.yellow.shade600;
    return Colors.red.shade400;
  }

  void _showDaySheet(BuildContext context, int day) {
    final dayExpenses = _expenses.where((e) {
      try {
        final d = DateTime.parse(e.date);
        return d.day == day;
      } catch (_) {
        return false;
      }
    }).toList();

    final fmt = NumberFormat('#,##0.00', 'en_PH');
    final dateLabel = DateFormat('MMMM d, y')
        .format(DateTime(_currentMonth.year, _currentMonth.month, day));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                dateLabel,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            if (dayExpenses.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No expenses on this day.',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: dayExpenses.length,
                  itemBuilder: (_, i) {
                    final e = dayExpenses[i];
                    return ListTile(
                      title: Text(e.itemName,
                          style: const TextStyle(fontSize: 14)),
                      subtitle: Text(e.category,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      trailing: Text(
                        '₱${fmt.format(e.amount)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentOrFuture = _currentMonth.year > now.year ||
        (_currentMonth.year == now.year && _currentMonth.month >= now.month);

    final dailyTotals = _buildDailyTotals();
    final avg = _dailyAvg(dailyTotals);

    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    // Monday=1→index 0, Sunday=7→index 6
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.heatmapScreenTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Month navigation header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month - 1,
                            );
                          });
                          _loadExpenses();
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_currentMonth),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: isCurrentOrFuture
                            ? null
                            : () {
                                setState(() {
                                  _currentMonth = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month + 1,
                                  );
                                });
                                _loadExpenses();
                              },
                      ),
                    ],
                  ),
                ),

                // Day-of-week header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map(
                          (d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),

                // Calendar grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1,
                      ),
                      itemCount: firstWeekday + daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < firstWeekday) {
                          return const SizedBox.shrink();
                        }
                        final day = index - firstWeekday + 1;
                        final total = dailyTotals[day] ?? 0.0;
                        final color = _cellColor(total, avg);

                        return InkWell(
                          onTap: () => _showDaySheet(context, day),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: color == Colors.grey.shade200
                                      ? cs.onSurface.withValues(alpha: 0.5)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Legend
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem(Colors.grey.shade200, 'No data'),
                      const SizedBox(width: 12),
                      _legendItem(Colors.green.shade300, 'Low'),
                      const SizedBox(width: 12),
                      _legendItem(Colors.yellow.shade600, 'Medium'),
                      const SizedBox(width: 12),
                      _legendItem(Colors.red.shade400, 'High'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
