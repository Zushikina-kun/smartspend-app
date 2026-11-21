import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';

class NetWorthScreen extends StatefulWidget {
  const NetWorthScreen({super.key});
  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
  bool _loading = true;
  double _totalAssets = 0;
  double _totalLiabilities = 0;
  List<Map<String, dynamic>> _manualAssets = [];
  List<Map<String, dynamic>> _manualLiabilities = [];
  List<Map<String, dynamic>> _snapshots = [];
  List<Map<String, dynamic>> _wallets = [];
  List<Map<String, dynamic>> _savingsGoals = [];
  double _totalDebtsOwed = 0;

  final _fmt = NumberFormat('#,##0.00', 'en_PH');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // Wallets
    final wallets = await DBService.getWallets();

    // Savings goals
    final goals = await DBService.getGoals();

    // Manual entries from net_worth_assets
    final allEntries = await DBService.getNetWorthAssets();
    final manualAssets = allEntries.where((e) {
      final cat = (e['category'] as String).toLowerCase();
      return cat != 'snapshot' && cat != 'liability' &&
          !['loan', 'credit card', 'other liability'].contains(cat);
    }).toList();
    final manualLiabilities = allEntries.where((e) {
      final cat = (e['category'] as String).toLowerCase();
      return ['loan', 'credit card', 'other liability', 'liability'].contains(cat);
    }).toList();
    final snapshots = allEntries
        .where((e) => (e['category'] as String).toLowerCase() == 'snapshot')
        .toList()
        .reversed
        .take(6)
        .toList()
        .reversed
        .toList();

    // Debts owed
    final debts = await DBService.getDebts();
    final debtsOwed = debts
        .where((d) => (d['type'] ?? 'owe') == 'owe')
        .fold<double>(0, (s, d) => s + ((d['amount'] as num?) ?? 0).toDouble() - ((d['paid_amount'] as num?) ?? 0).toDouble());

    // Compute totals
    final walletTotal = wallets.fold<double>(0, (s, w) => s + ((w['balance'] as num?) ?? 0).toDouble());
    final goalTotal = goals.fold<double>(0, (s, g) => s + ((g['current_amount'] as num?) ?? 0).toDouble());
    final manualAssetTotal = manualAssets.fold<double>(0, (s, e) => s + ((e['value'] as num?) ?? 0).toDouble());
    final totalAssets = walletTotal + goalTotal + manualAssetTotal;

    final manualLiabilityTotal = manualLiabilities.fold<double>(0, (s, e) => s + ((e['value'] as num?) ?? 0).toDouble());
    final totalLiabilities = debtsOwed + manualLiabilityTotal;

    // Monthly snapshot: save on 1st of month if not yet saved
    final today = DateTime.now();
    if (today.day == 1) {
      final thisMonthKey = DateFormat('yyyy-MM').format(today);
      final alreadySaved = allEntries.any((e) =>
          (e['category'] as String).toLowerCase() == 'snapshot' &&
          (e['date'] as String).startsWith(thisMonthKey));
      if (!alreadySaved) {
        await DBService.insertNetWorthAsset({
          'name': 'Monthly Snapshot',
          'value': totalAssets - totalLiabilities,
          'category': 'snapshot',
          'date': today.toIso8601String().substring(0, 10),
        });
      }
    }

    if (mounted) {
      setState(() {
        _wallets = wallets;
        _savingsGoals = goals;
        _manualAssets = manualAssets;
        _manualLiabilities = manualLiabilities;
        _snapshots = snapshots;
        _totalAssets = totalAssets;
        _totalLiabilities = totalLiabilities;
        _totalDebtsOwed = debtsOwed;
        _loading = false;
      });
    }
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    String selectedCategory = 'Property';
    final categories = [
      'Property', 'Vehicle', 'Investment', 'Other Asset',
      'Loan', 'Credit Card', 'Other Liability'
    ];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Asset / Liability'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valueCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Value (₱)', prefixText: '₱'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setS(() => selectedCategory = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final value = double.tryParse(valueCtrl.text.replaceAll(',', ''));
                if (name.isEmpty || value == null) return;
                await DBService.insertNetWorthAsset({
                  'name': name,
                  'value': value,
                  'category': selectedCategory,
                  'date': DateTime.now().toIso8601String().substring(0, 10),
                });
                if (ctx.mounted) Navigator.pop(ctx);
                await _load();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final netWorth = _totalAssets - _totalLiabilities;
    final netWorthColor = netWorth >= 0 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Net Worth')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Net Worth summary ───────────────────────────────────
                  Card(
                    color: netWorthColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Net Worth',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            '₱${_fmt.format(netWorth)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    color: netWorthColor,
                                    fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _SummaryChip(label: 'Assets', value: _totalAssets, color: Colors.green),
                              _SummaryChip(label: 'Liabilities', value: _totalLiabilities, color: Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Trend chart ─────────────────────────────────────────
                  if (_snapshots.isNotEmpty) ...[
                    Text('Net Worth Trend',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  final idx = v.toInt();
                                  if (idx < 0 || idx >= _snapshots.length) return const SizedBox();
                                  final d = _snapshots[idx]['date'] as String;
                                  return Text(d.substring(5, 7), style: const TextStyle(fontSize: 10));
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _snapshots.asMap().entries.map((e) =>
                                  FlSpot(e.key.toDouble(),
                                      (e.value['value'] as num).toDouble())).toList(),
                              isCurved: true,
                              color: cs.primary,
                              barWidth: 2,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // ── Assets ──────────────────────────────────────────────
                  _SectionHeader(title: 'Assets', total: _totalAssets, color: Colors.green),
                  ..._wallets.map((w) => _EntryTile(
                        name: '${w['icon'] ?? '💵'} ${w['name']}',
                        subtitle: 'Wallet',
                        value: (w['balance'] as num).toDouble(),
                        color: Colors.green,
                      )),
                  ..._savingsGoals.map((g) => _EntryTile(
                        name: '🎯 ${g['name']}',
                        subtitle: 'Savings Goal',
                        value: (g['current_amount'] as num? ?? 0).toDouble(),
                        color: Colors.green,
                      )),
                  ..._manualAssets.map((e) => _EntryTile(
                        name: e['name'] as String,
                        subtitle: e['category'] as String,
                        value: (e['value'] as num).toDouble(),
                        color: Colors.green,
                        onDelete: () async {
                          await DBService.deleteNetWorthAsset(e['id'] as int);
                          await _load();
                        },
                      )),
                  const SizedBox(height: 16),
                  // ── Liabilities ─────────────────────────────────────────
                  _SectionHeader(title: 'Liabilities', total: _totalLiabilities, color: Colors.red),
                  if (_totalDebtsOwed > 0)
                    _EntryTile(
                      name: '💸 Debts Owed',
                      subtitle: 'From Debt Tracker',
                      value: _totalDebtsOwed,
                      color: Colors.red,
                    ),
                  ..._manualLiabilities.map((e) => _EntryTile(
                        name: e['name'] as String,
                        subtitle: e['category'] as String,
                        value: (e['value'] as num).toDouble(),
                        color: Colors.red,
                        onDelete: () async {
                          await DBService.deleteNetWorthAsset(e['id'] as int);
                          await _load();
                        },
                      )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text('₱${fmt.format(value)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final double total;
  final Color color;
  const _SectionHeader({required this.title, required this.total, required this.color});
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('₱${fmt.format(total)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final double value;
  final Color color;
  final VoidCallback? onDelete;
  const _EntryTile({
    required this.name,
    required this.subtitle,
    required this.value,
    required this.color,
    this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    return ListTile(
      dense: true,
      title: Text(name),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('₱${fmt.format(value)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
