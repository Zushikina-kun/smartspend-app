import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/forecast_service.dart';
import '../services/currency_service.dart';
import '../services/db_service.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  bool _loading = true;
  Map<String, dynamic>? _forecastData;
  double _startingBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() => _loading = true);

    try {
      // Get current wallet balance as starting point
      final wallets = await DBService.getWallets();
      double totalBalance = 0.0;
      for (final wallet in wallets) {
        totalBalance += (wallet['balance'] as num?)?.toDouble() ?? 0.0;
      }

      // If no wallets, use income - expenses as starting balance
      if (totalBalance == 0.0) {
        final income = await DBService.getMonthlyIncome();
        final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
        final spent = await DBService.getTotalSpent(month: currentMonth);
        totalBalance = income - spent;
      }

      final forecast = await ForecastService.generate30DayForecast(
        startingBalance: totalBalance,
      );

      if (mounted) {
        setState(() {
          _forecastData = forecast;
          _startingBalance = totalBalance;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading forecast: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadForecast,
            tooltip: 'Refresh forecast',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _forecastData == null
              ? const Center(child: Text('Unable to load forecast'))
              : _buildForecastContent(cs),
    );
  }

  Widget _buildForecastContent(ColorScheme cs) {
    final dailyBalances =
        _forecastData!['dailyBalances'] as List<Map<String, dynamic>>;
    final confidence = _forecastData!['confidence'] as String;
    final confidenceScore = _forecastData!['confidenceScore'] as double;
    final keyDates = _forecastData!['keyDates'] as List<Map<String, dynamic>>;
    final dataPoints = _forecastData!['dataPoints'] as int;

    return RefreshIndicator(
      onRefresh: _loadForecast,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Confidence indicator card
          _buildConfidenceCard(confidence, confidenceScore, dataPoints, cs),
          const SizedBox(height: 16),

          // Chart card
          _buildChartCard(dailyBalances, cs),
          const SizedBox(height: 16),

          // Key dates section
          if (keyDates.isNotEmpty) ...[
            Text(
              'Key Dates',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...keyDates.map((kd) => _buildKeyDateCard(kd, cs)),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: cs.primary, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'No significant balance fluctuations expected in the next 30 days.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(
      String confidence, double score, int dataPoints, ColorScheme cs) {
    Color confidenceColor;
    IconData confidenceIcon;

    if (score >= 80) {
      confidenceColor = Colors.green;
      confidenceIcon = Icons.check_circle;
    } else if (score >= 50) {
      confidenceColor = Colors.orange;
      confidenceIcon = Icons.warning_amber_rounded;
    } else {
      confidenceColor = Colors.red;
      confidenceIcon = Icons.error_outline;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(confidenceIcon, color: confidenceColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$confidence Confidence',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: confidenceColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${score.toStringAsFixed(0)}% confidence',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Based on $dataPoints expense records from the last 60 days.',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            if (confidence == 'Low') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Low confidence: Add more expense data to improve forecast accuracy.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
      List<Map<String, dynamic>> dailyBalances, ColorScheme cs) {
    // Prepare data points for chart
    final spots = <FlSpot>[];
    for (int i = 0; i < dailyBalances.length; i++) {
      final balance = dailyBalances[i]['balance'] as double;
      spots.add(FlSpot(i.toDouble(), balance));
    }

    // Find min and max for scaling
    final balances = dailyBalances.map((d) => d['balance'] as double).toList();
    final minBalance = balances.reduce((a, b) => a < b ? a : b);
    final maxBalance = balances.reduce((a, b) => a > b ? a : b);

    // Add padding to Y axis
    final yPadding = (maxBalance - minBalance) * 0.2;
    final yMin = minBalance - yPadding;
    final yMax = maxBalance + yPadding;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '30-Day Balance Projection',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Starting balance: ${CurrencyService.format(_startingBalance)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (yMax - yMin) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            CurrencyService.formatCompact(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dailyBalances.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Day ${index + 1}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: yMin,
                  maxY: yMax,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: cs.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: cs.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final date = DateTime.parse(
                              dailyBalances[index]['date'] as String);
                          final balance =
                              dailyBalances[index]['balance'] as double;
                          final events = dailyBalances[index]['events']
                              as List<Map<String, String>>;

                          String tooltip = DateFormat('MMM d').format(date);
                          tooltip += '\n${CurrencyService.format(balance)}';
                          if (events.isNotEmpty) {
                            tooltip +=
                                '\n${events.map((e) => e['title']).join(', ')}';
                          }

                          return LineTooltipItem(
                            tooltip,
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyDateCard(Map<String, dynamic> keyDate, ColorScheme cs) {
    final date = DateTime.parse(keyDate['date'] as String);
    final balance = keyDate['balance'] as double;
    final change = keyDate['change'] as double;
    final reason = keyDate['reason'] as String;
    final isNegative = keyDate['isNegative'] as bool;

    final color =
        isNegative ? Colors.red : (change < 0 ? Colors.orange : Colors.green);
    final icon = isNegative
        ? Icons.warning
        : (change < 0 ? Icons.arrow_downward : Icons.arrow_upward);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          DateFormat('MMM d, yyyy').format(date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reason),
            const SizedBox(height: 4),
            Text(
              'Balance: ${CurrencyService.format(balance)}',
              style: TextStyle(
                color: isNegative ? Colors.red : Colors.grey[700],
                fontWeight: isNegative ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: change != 0
            ? Text(
                '${change > 0 ? '+' : ''}${CurrencyService.format(change)}',
                style: TextStyle(
                  color: change > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
