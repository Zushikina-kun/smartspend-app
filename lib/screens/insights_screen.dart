import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _loading = true;
  Map<String, double> _thisMonth = {};
  Map<String, double> _lastMonth = {};
  double _thisMonthTotal = 0;

  static const _teal = Color(0xFF00897B);
  static const _grey = Color(0xFF90A4AE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await DBService.getExpenses();
    final now = DateTime.now();
    final thisKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final lastDt = DateTime(now.year, now.month - 1);
    final lastKey = '${lastDt.year}-${lastDt.month.toString().padLeft(2, '0')}';

    final thisM = <String, double>{};
    final lastM = <String, double>{};

    for (final e in all) {
      if (e.date.startsWith(thisKey)) {
        thisM[e.category] = (thisM[e.category] ?? 0) + e.amount;
      } else if (e.date.startsWith(lastKey)) {
        lastM[e.category] = (lastM[e.category] ?? 0) + e.amount;
      }
    }

    if (mounted) {
      setState(() {
        _thisMonth = thisM;
        _lastMonth = lastM;
        _thisMonthTotal = thisM.values.fold(0, (a, b) => a + b);
        _loading = false;
      });
    }
  }

  /// Up to 6 categories ranked by this month's spend (or last month's if
  /// this month is zero for that category).
  List<String> get _topCategories {
    final all = {..._thisMonth.keys, ..._lastMonth.keys}.toList();
    all.sort((a, b) {
      final ta = _thisMonth[a] ?? 0;
      final tb = _thisMonth[b] ?? 0;
      return tb.compareTo(ta);
    });
    return all.take(6).toList();
  }

  List<String> get _top3 {
    final cats = _thisMonth.keys.toList()
      ..sort((a, b) => (_thisMonth[b] ?? 0).compareTo(_thisMonth[a] ?? 0));
    return cats.take(3).toList();
  }

  String _fmt(double v) => '${CurrencyService.symbol}${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() => _loading = true);
              _loadData();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBarChartSection(),
                  const SizedBox(height: 24),
                  _buildCallouts(),
                  const SizedBox(height: 24),
                  _buildTop3Section(),
                ],
              ),
            ),
    );
  }

  // ── Month-over-month bar chart ──────────────────────────────────────────

  Widget _buildBarChartSection() {
    final cats = _topCategories;
    if (cats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No spending data yet.')),
        ),
      );
    }

    final maxVal = cats.fold<double>(0, (m, c) {
      final v = (_thisMonth[c] ?? 0) > (_lastMonth[c] ?? 0)
          ? (_thisMonth[c] ?? 0)
          : (_lastMonth[c] ?? 0);
      return v > m ? v : m;
    });

    // Each group has two bars (this month + last month), gap between groups.
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < cats.length; i++) {
      final cat = cats[i];
      groups.add(
        BarChartGroupData(
          x: i,
          groupVertically: false,
          barRods: [
            BarChartRodData(
              toY: _thisMonth[cat] ?? 0,
              color: _teal,
              width: 10,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(3)),
            ),
            BarChartRodData(
              toY: _lastMonth[cat] ?? 0,
              color: _grey,
              width: 10,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
          barsSpace: 3,
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Month-over-Month by Category',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Top ${cats.length} categories',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.2 == 0 ? 100 : maxVal * 1.2,
                  barGroups: groups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (v, _) => Text(
                          CurrencyService.formatCompact(v),
                          style: const TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= cats.length) {
                            return const SizedBox.shrink();
                          }
                          final label = cats[idx];
                          final short = label.length > 7
                              ? '${label.substring(0, 6)}…'
                              : label;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              short,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final cat = cats[group.x];
                        final label =
                            rodIndex == 0 ? 'This month' : 'Last month';
                        return BarTooltipItem(
                          '$cat\n$label: ${_fmt(rod.toY)}',
                          const TextStyle(color: Colors.white, fontSize: 11),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(_teal, 'This month'),
                const SizedBox(width: 16),
                _legendDot(_grey, 'Last month'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  // ── Change callouts ─────────────────────────────────────────────────────

  Widget _buildCallouts() {
    final cats = _topCategories;
    final callouts = cats.where((c) {
      final diff = (_thisMonth[c] ?? 0) - (_lastMonth[c] ?? 0);
      return diff != 0;
    }).toList()
      ..sort((a, b) {
        final da = (_thisMonth[a] ?? 0) - (_lastMonth[a] ?? 0);
        final db = (_thisMonth[b] ?? 0) - (_lastMonth[b] ?? 0);
        return db.abs().compareTo(da.abs());
      });

    if (callouts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No month-over-month changes to show.'),
        ),
      );
    }

    final now = DateTime.now();
    final thisLabel = DateFormat('MMM yyyy').format(now);
    final lastLabel =
        DateFormat('MMM yyyy').format(DateTime(now.year, now.month - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Changes vs Last Month',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...callouts.map((cat) {
          final thisAmt = _thisMonth[cat] ?? 0;
          final lastAmt = _lastMonth[cat] ?? 0;
          final diff = thisAmt - lastAmt;
          final isMore = diff > 0;
          final color = isMore ? Colors.red : Colors.green;
          final icon = isMore ? Icons.arrow_upward : Icons.arrow_downward;
          final verb = isMore ? 'more' : 'less';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 18),
              ),
              title: Text(
                'You spent ${_fmt(diff.abs())} $verb on $cat this month vs last month.',
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                '$thisLabel: ${_fmt(thisAmt)}  ·  $lastLabel: ${_fmt(lastAmt)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Top 3 categories ────────────────────────────────────────────────────

  Widget _buildTop3Section() {
    final top3 = _top3;
    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final thisLabel = DateFormat('MMM yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top 3 Categories — $thisLabel',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...top3.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final cat = entry.value;
          final amt = _thisMonth[cat] ?? 0;
          final pct = _thisMonthTotal > 0 ? (amt / _thisMonthTotal * 100) : 0.0;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _teal.withValues(alpha: 0.15),
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 4,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _fmt(amt),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
