import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/price_data.dart';
import '../services/price_intelligence_service.dart';
import '../services/analytics_service.dart';
import '../services/doe_service.dart';
import '../services/psa_service.dart';

class PriceIntelligenceScreen extends StatefulWidget {
  const PriceIntelligenceScreen({super.key});

  @override
  State<PriceIntelligenceScreen> createState() =>
      _PriceIntelligenceScreenState();
}

class _PriceIntelligenceScreenState extends State<PriceIntelligenceScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Price Intelligence'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'My Prices'),
              Tab(text: 'Price History'),
              Tab(text: '⛽ Fuel (DOE)'),
              Tab(text: '🛒 Market (PSA)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProductsTab(),
            _PriceHistoryTab(),
            _FuelPricesTab(),
            _MarketPricesTab(),
          ],
        ),
      ),
    );
  }
}

// ── PRODUCTS TAB ──────────────────────────────────────────────────────────────

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  List<PriceData> _allPrices = [];
  List<Map<String, dynamic>> _trendAlerts = [];
  Map<String, dynamic>? _overallBestDeal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logFeatureUsed('price_intelligence');
    _loadData();
  }

  Future<void> _loadData() async {
    final prices = await PriceIntelligenceService.getAllPrices();
    final alerts = await PriceIntelligenceService.checkForPriceAlerts();

    // Find the product with the single lowest price across all data
    Map<String, dynamic>? bestDeal;
    if (prices.isNotEmpty) {
      final cheapest = prices.reduce((a, b) => a.price < b.price ? a : b);
      bestDeal = {
        'productName': cheapest.productName,
        'storeName': cheapest.storeName ?? 'Unknown Store',
        'price': cheapest.price,
      };
    }

    if (mounted) {
      setState(() {
        _allPrices = prices;
        _trendAlerts = alerts;
        _overallBestDeal = bestDeal;
        _loading = false;
      });
    }
  }

  /// Group prices by normalized product name, keeping only the latest per product.
  Map<String, List<PriceData>> _groupByProduct() {
    final grouped = <String, List<PriceData>>{};
    for (final p in _allPrices) {
      final key = p.productName.toLowerCase().trim();
      grouped.putIfAbsent(key, () => []).add(p);
    }
    return grouped;
  }

  /// Title-cases a string.
  String _titleCase(String s) {
    return s
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Determine trend icon for a product's price list.
  Widget _trendIcon(List<PriceData> prices) {
    if (prices.length < 2) {
      return const Icon(Icons.sell_outlined, size: 22, color: Colors.grey);
    }
    final sorted = List<PriceData>.from(prices)
      ..sort((a, b) => a.date.compareTo(b.date));
    final latest = sorted.last.price;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recent = sorted.where((p) => p.date.isAfter(thirtyDaysAgo)).toList();
    if (recent.isEmpty) {
      return const Icon(Icons.sell_outlined, size: 22, color: Colors.grey);
    }
    final avg =
        recent.map((p) => p.price).reduce((a, b) => a + b) / recent.length;
    final changePct = ((latest - avg) / avg) * 100;
    if (changePct > 10) {
      return const Icon(Icons.arrow_upward, size: 22, color: Colors.red);
    } else if (changePct < -10) {
      return const Icon(Icons.arrow_downward, size: 22, color: Colors.green);
    }
    return const Icon(Icons.sell_outlined, size: 22, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final grouped = _groupByProduct();

    if (grouped.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.price_check, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No price data yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 6),
            Text('Scan receipts to start tracking prices.',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Best Deal Card ──────────────────────────────────────────────
          if (_overallBestDeal != null) ...[
            Card(
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const Text('🏆', style: TextStyle(fontSize: 28)),
                title: const Text('Best Deal',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(
                  _titleCase(_overallBestDeal!['productName'] as String),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₱${(_overallBestDeal!['price'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.green),
                    ),
                    Text(
                      _overallBestDeal!['storeName'] as String,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Trend Alerts Banner ─────────────────────────────────────────
          if (_trendAlerts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price Rise Alert',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          'These products are >10% above their 30-day avg: '
                          '${_trendAlerts.map((a) => _titleCase(a['productName'] as String)).join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Product List ────────────────────────────────────────────────
          ...grouped.entries.map((entry) {
            final prices = entry.value
              ..sort((a, b) => b.date.compareTo(a.date));
            final latest = prices.first;
            final stores =
                prices.map((p) => p.storeName).whereType<String>().toSet();

            // Check if cheapest store differs from latest store (best deal chip)
            final sortedByPrice = List<PriceData>.from(prices)
              ..sort((a, b) => a.price.compareTo(b.price));
            final cheapestStore = sortedByPrice.first.storeName ?? 'Unknown';
            final showBestDeal = stores.length > 1;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: _trendIcon(prices),
                title: Text(_titleCase(entry.key),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Latest: ₱${latest.price.toStringAsFixed(2)}'
                  '${latest.storeName != null ? ' · ${latest.storeName}' : ''}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: showBestDeal
                    ? Chip(
                        label: Text(cheapestStore,
                            style: const TextStyle(fontSize: 10)),
                        backgroundColor: Colors.green.shade50,
                        side: BorderSide(color: Colors.green.shade200),
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _PriceDetailScreen(productName: entry.key),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── PRICE HISTORY TAB ─────────────────────────────────────────────────────────

class _PriceHistoryTab extends StatefulWidget {
  const _PriceHistoryTab({this.initialProduct});

  final String? initialProduct;

  @override
  State<_PriceHistoryTab> createState() => _PriceHistoryTabState();
}

class _PriceHistoryTabState extends State<_PriceHistoryTab> {
  List<String> _products = [];
  String? _selectedProduct;
  List<PriceData> _history = [];
  bool _loadingProducts = true;
  bool _loadingHistory = false;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prices = await PriceIntelligenceService.getAllPrices();
    final names = prices
        .map((p) => p.productName.toLowerCase().trim())
        .toSet()
        .toList()
      ..sort();
    if (mounted) {
      setState(() {
        _products = names;
        _loadingProducts = false;
        if (widget.initialProduct != null &&
            names.contains(widget.initialProduct)) {
          _selectedProduct = widget.initialProduct;
        }
      });
      if (_selectedProduct != null) _loadHistory(_selectedProduct!);
    }
  }

  Future<void> _loadHistory(String productName) async {
    setState(() => _loadingHistory = true);
    final history = await PriceIntelligenceService.getPriceTrend(productName);
    if (mounted) {
      setState(() {
        _history = history;
        _loadingHistory = false;
        _touchedIndex = -1;
      });
    }
  }

  String _titleCase(String s) {
    return s
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('No price data yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Product Dropdown ──────────────────────────────────────────────
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Product',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          value: _selectedProduct,
          items: _products
              .map((name) => DropdownMenuItem(
                    value: name,
                    child: Text(_titleCase(name),
                        style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() => _selectedProduct = val);
            _loadHistory(val);
          },
        ),
        const SizedBox(height: 20),

        // ── Chart ─────────────────────────────────────────────────────────
        if (_loadingHistory)
          const Center(child: CircularProgressIndicator())
        else if (_selectedProduct != null && _history.isEmpty)
          const Center(
              child: Text('No history for this product.',
                  style: TextStyle(color: Colors.grey)))
        else if (_history.isNotEmpty)
          _buildChart(),

        // ── Data Table ────────────────────────────────────────────────────
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildDataTable(),
        ],
      ],
    );
  }

  Widget _buildChart() {
    final spots = <FlSpot>[];
    for (int i = 0; i < _history.length; i++) {
      spots.add(FlSpot(i.toDouble(), _history[i].price));
    }

    final minY = _history.map((h) => h.price).reduce((a, b) => a < b ? a : b);
    final maxY = _history.map((h) => h.price).reduce((a, b) => a > b ? a : b);
    final yPad = ((maxY - minY) * 0.15).clamp(1.0, double.infinity);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY - yPad,
          maxY: maxY + yPad,
          lineTouchData: LineTouchData(
            touchCallback: (event, response) {
              setState(() {
                _touchedIndex = response?.lineBarSpots?.first.spotIndex ?? -1;
              });
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((s) {
                  final entry = _history[s.spotIndex];
                  return LineTooltipItem(
                    '₱${entry.price.toStringAsFixed(2)}\n${entry.storeName ?? ''}',
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: (_history.length > 6
                        ? (_history.length / 5).ceilToDouble()
                        : 1)
                    .toDouble(),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= _history.length) {
                    return const SizedBox.shrink();
                  }
                  final date = _history[idx].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) => Text(
                  '₱${value.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => const FlLine(
              color: Color(0x1A000000),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF00C896),
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, pct, bar, index) {
                  final isActive = index == _touchedIndex;
                  return FlDotCirclePainter(
                    radius: isActive ? 6 : 4,
                    color: isActive ? Colors.orange : const Color(0xFF00C896),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF00C896).withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 40,
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Date', style: TextStyle(fontSize: 12))),
          DataColumn(label: Text('Store', style: TextStyle(fontSize: 12))),
          DataColumn(
              label: Text('Price', style: TextStyle(fontSize: 12)),
              numeric: true),
        ],
        rows: _history.reversed.map((h) {
          return DataRow(cells: [
            DataCell(Text(DateFormat('MMM d, y').format(h.date),
                style: const TextStyle(fontSize: 12))),
            DataCell(
                Text(h.storeName ?? '—', style: const TextStyle(fontSize: 12))),
            DataCell(Text('₱${h.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12))),
          ]);
        }).toList(),
      ),
    );
  }
}

// ── PRICE DETAIL SCREEN ───────────────────────────────────────────────────────

class _PriceDetailScreen extends StatelessWidget {
  const _PriceDetailScreen({required this.productName});

  final String productName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleCase(productName))),
      body: _PriceHistoryTab(initialProduct: productName),
    );
  }

  String _titleCase(String s) {
    return s
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

// ── FUEL PRICES TAB (DOE) ─────────────────────────────────────────────────────
class _FuelPricesTab extends StatefulWidget {
  const _FuelPricesTab();
  @override
  State<_FuelPricesTab> createState() => _FuelPricesTabState();
}

class _FuelPricesTabState extends State<_FuelPricesTab> {
  List<FuelPrice> _prices = [];
  bool _loading = true;
  int? _ageDays;
  bool _isStale = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    final prices = await DoeService.getFuelPrices(forceRefresh: forceRefresh);
    final age = await DoeService.cacheAgeDays();
    final stale = await DoeService.isDataStale();
    if (mounted) {
      setState(() {
        _prices = prices;
        _ageDays = age;
        _isStale = stale;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('⛽', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DOE Fuel Prices',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(
                      'Department of Energy — weekly pump price data',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildUpdateLabel(cs),
          const SizedBox(height: 16),
          if (_isStale && !_loading) _buildStaleWarning(cs),
          if (_loading)
            const Center(
              child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator()),
            )
          else if (_prices.isEmpty)
            _buildUnavailable(cs)
          else
            ..._prices.map((p) => _buildFuelCard(p, cs)),
          const SizedBox(height: 16),
          Text(
            'Pull down to refresh. Data sourced from DOE Philippines.',
            style:
                TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.45)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateLabel(ColorScheme cs) {
    if (_ageDays == null) {
      return Text('No cached data',
          style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.5)));
    }
    final label = _ageDays == 0
        ? 'Updated today'
        : _ageDays == 1
            ? 'Updated yesterday'
            : 'Last updated: $_ageDays days ago';
    return Row(children: [
      Icon(Icons.update,
          size: 14, color: _isStale ? Colors.orange : Colors.green),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 12,
              color: _isStale ? Colors.orange : cs.onSurface.withOpacity(0.6))),
    ]);
  }

  Widget _buildStaleWarning(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text('Data is over 14 days old. Pull down to try refreshing.',
              style: TextStyle(fontSize: 12, color: Colors.orange)),
        ),
      ]),
    );
  }

  Widget _buildUnavailable(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(Icons.cloud_off, size: 48, color: cs.onSurface.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text('Fuel price data unavailable',
              style: TextStyle(
                  fontSize: 15, color: cs.onSurface.withOpacity(0.5))),
          const SizedBox(height: 6),
          Text('Pull down to retry',
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withOpacity(0.4))),
        ]),
      ),
    );
  }

  Widget _buildFuelCard(FuelPrice p, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.commodity,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              if (p.periodLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(p.periodLabel!,
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurface.withOpacity(0.5))),
                ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '₱${p.priceMin.toStringAsFixed(2)} – ₱${p.priceMax.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(p.unit,
                style: TextStyle(
                    fontSize: 11, color: cs.onSurface.withOpacity(0.5))),
          ]),
        ]),
      ),
    );
  }
}

// ── MARKET PRICES TAB (PSA) ───────────────────────────────────────────────────
class _MarketPricesTab extends StatefulWidget {
  const _MarketPricesTab();
  @override
  State<_MarketPricesTab> createState() => _MarketPricesTabState();
}

class _MarketPricesTabState extends State<_MarketPricesTab> {
  List<MarketPrice> _prices = [];
  bool _loading = true;
  int? _ageDays;
  bool _isStale = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    final prices = await PsaService.getMarketPrices(forceRefresh: forceRefresh);
    final age = await PsaService.cacheAgeDays();
    final stale = await PsaService.isDataStale();
    if (mounted) {
      setState(() {
        _prices = prices;
        _ageDays = age;
        _isStale = stale;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🛒', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PSA Retail Prices',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(
                      'Philippine Statistics Authority — monthly commodity prices',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildUpdateLabel(cs),
          const SizedBox(height: 16),
          if (_isStale && !_loading) _buildStaleWarning(cs),
          if (_loading)
            const Center(
              child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator()),
            )
          else if (_prices.isEmpty)
            _buildUnavailable(cs)
          else
            ..._prices.map((p) => _buildMarketCard(p, cs)),
          const SizedBox(height: 16),
          Text(
            'Pull down to refresh. Data sourced from PSA OpenStat (openstat.psa.gov.ph).',
            style:
                TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.45)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateLabel(ColorScheme cs) {
    if (_ageDays == null) {
      return Text('No cached data',
          style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.5)));
    }
    final label = _ageDays == 0
        ? 'Updated today'
        : _ageDays == 1
            ? 'Updated yesterday'
            : 'Last updated: $_ageDays days ago';
    return Row(children: [
      Icon(Icons.update,
          size: 14, color: _isStale ? Colors.orange : Colors.green),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 12,
              color: _isStale ? Colors.orange : cs.onSurface.withOpacity(0.6))),
    ]);
  }

  Widget _buildStaleWarning(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text('Data is over 60 days old. Pull down to try refreshing.',
              style: TextStyle(fontSize: 12, color: Colors.orange)),
        ),
      ]),
    );
  }

  Widget _buildUnavailable(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(Icons.cloud_off, size: 48, color: cs.onSurface.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text('Market price data unavailable',
              style: TextStyle(
                  fontSize: 15, color: cs.onSurface.withOpacity(0.5))),
          const SizedBox(height: 6),
          Text('Pull down to retry',
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withOpacity(0.4))),
        ]),
      ),
    );
  }

  Widget _buildMarketCard(MarketPrice p, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.commodity,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              if (p.periodLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(p.periodLabel!,
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurface.withOpacity(0.5))),
                ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₱${p.price.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(p.unit,
                style: TextStyle(
                    fontSize: 11, color: cs.onSurface.withOpacity(0.5))),
          ]),
        ]),
      ),
    );
  }
}
