import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';

/// N1 — Debt Payoff Calculator
/// Loads all "owe" debts from DB, lets user set a monthly extra budget,
/// then shows month-by-month avalanche vs snowball payoff tables
/// with total interest paid and months-to-freedom for each strategy.
class DebtPayoffScreen extends StatefulWidget {
  const DebtPayoffScreen({super.key});

  @override
  State<DebtPayoffScreen> createState() => _DebtPayoffScreenState();
}

class _DebtPayoffScreenState extends State<DebtPayoffScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  List<_DebtEntry> _debts = [];
  final _budgetCtrl = TextEditingController();
  double _extraBudget = 0;
  late TabController _tabCtrl;

  // Results
  List<_PayoffMonth> _avalancheSchedule = [];
  List<_PayoffMonth> _snowballSchedule = [];
  double _avalancheTotalInterest = 0;
  double _snowballTotalInterest = 0;
  bool _calculated = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadDebts();
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDebts() async {
    final raw = await DBService.getDebts(type: 'owe');
    final entries = raw
        .map((r) {
          final total = (r['amount'] as num?)?.toDouble() ?? 0;
          final paid = (r['paid_amount'] as num?)?.toDouble() ?? 0;
          final balance = (total - paid).clamp(0.0, double.infinity);
          return _DebtEntry(
            id: r['id'] as int,
            title: r['title'] as String? ?? 'Debt',
            person: r['person'] as String? ?? '',
            balance: balance,
            interestRate: (r['interest_rate'] as num?)?.toDouble() ?? 0,
          );
        })
        .where((d) => d.balance > 0)
        .toList();

    setState(() {
      _debts = entries;
      _loading = false;
    });
  }

  void _calculate() {
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0;
    if (budget <= 0 || _debts.isEmpty) return;
    setState(() {
      _extraBudget = budget;
      // Compute minimum required payment = 1% of balance (floor ₱100) for each debt
      final minPay = {
        for (final d in _debts) d.id: (d.balance * 0.01).clamp(100.0, 9999999.0)
      };
      final totalMin = minPay.values.fold(0.0, (a, b) => a + b);
      if (budget < totalMin) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Budget too low — minimum needed: ${CurrencyService.format(totalMin)}')));
        return;
      }
      _avalancheSchedule = _simulate(budget, minPay, avalanche: true);
      _snowballSchedule = _simulate(budget, minPay, avalanche: false);
      _avalancheTotalInterest =
          _avalancheSchedule.fold(0.0, (s, m) => s + m.interestPaid);
      _snowballTotalInterest =
          _snowballSchedule.fold(0.0, (s, m) => s + m.interestPaid);
      _calculated = true;
    });
  }

  /// Simulate month-by-month payoff.
  /// avalanche=true → attack highest-rate first.
  /// avalanche=false → attack lowest-balance first (snowball).
  List<_PayoffMonth> _simulate(double monthlyBudget, Map<int, double> minPay,
      {required bool avalanche}) {
    // Deep copy balances
    final balances = {for (final d in _debts) d.id: d.balance};
    final rateMap = {for (final d in _debts) d.id: d.interestRate / 100 / 12};
    final schedule = <_PayoffMonth>[];

    for (int month = 1; month <= 600; month++) {
      // All debts cleared?
      if (balances.values.every((b) => b <= 0)) break;

      // Determine focus debt
      final activeDebts =
          _debts.where((d) => (balances[d.id] ?? 0) > 0).toList();
      if (activeDebts.isEmpty) break;

      final focusDebt = avalanche
          ? activeDebts
              .reduce((a, b) => a.interestRate >= b.interestRate ? a : b)
          : activeDbts_snowball(activeDebts, balances);

      // Apply interest first
      double totalInterest = 0;
      for (final d in activeDebts) {
        final interest = (balances[d.id]! * rateMap[d.id]!);
        balances[d.id] = balances[d.id]! + interest;
        totalInterest += interest;
      }

      // Pay minimums on all non-focus debts
      double remaining = monthlyBudget;
      for (final d in activeDebts) {
        if (d.id == focusDebt.id) continue;
        final min = minPay[d.id]!.clamp(0.0, balances[d.id]!);
        balances[d.id] = (balances[d.id]! - min).clamp(0, double.infinity);
        remaining -= min;
      }
      // Throw the rest at focus debt
      remaining = remaining.clamp(0, double.infinity);
      final focusPay = remaining.clamp(0.0, balances[focusDebt.id]!);
      balances[focusDebt.id] =
          (balances[focusDebt.id]! - focusPay).clamp(0, double.infinity);

      final totalBalance =
          balances.values.fold(0.0, (s, b) => s + b.clamp(0, double.infinity));

      schedule.add(_PayoffMonth(
        month: month,
        totalBalance: totalBalance,
        interestPaid: totalInterest,
      ));
    }
    return schedule;
  }

  _DebtEntry activeDbts_snowball(
      List<_DebtEntry> active, Map<int, double> balances) {
    return active.reduce(
        (a, b) => (balances[a.id] ?? 0) <= (balances[b.id] ?? 0) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Payoff Calculator'),
        centerTitle: false,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _debts.isEmpty
              ? _buildEmpty(cs)
              : _buildContent(cs),
    );
  }

  Widget _buildEmpty(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.handshake_outlined,
                size: 64, color: cs.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('No active debts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Add debts you owe under Hub → Debts & Loans.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Debt summary
          _buildDebtList(cs),
          const SizedBox(height: 20),

          // Budget input
          Text('Monthly Extra Budget',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(
            'How much can you put toward debt each month?',
            style: TextStyle(
                fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _budgetCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                  ],
                  decoration: InputDecoration(
                    prefixText: '₱ ',
                    hintText: '5000',
                    filled: true,
                    fillColor: cs.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Calculate'),
              ),
            ],
          ),

          if (_calculated) ...[
            const SizedBox(height: 24),
            _buildComparison(cs),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(text: 'Avalanche (highest rate first)'),
                Tab(text: 'Snowball (lowest balance first)'),
              ],
              labelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              isScrollable: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildScheduleTable(_avalancheSchedule, cs),
                  _buildScheduleTable(_snowballSchedule, cs),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDebtList(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Active Debts',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: cs.onSurface)),
          const SizedBox(height: 10),
          for (final d in _debts) ...[
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      d.title.isNotEmpty ? d.title[0].toUpperCase() : '?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      if (d.person.isNotEmpty)
                        Text(d.person,
                            style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyService.format(d.balance),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      d.interestRate > 0
                          ? '${d.interestRate.toStringAsFixed(1)}% /yr'
                          : 'No interest',
                      style: TextStyle(
                          fontSize: 11,
                          color: d.interestRate > 0
                              ? Colors.orange[700]
                              : cs.onSurface.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ],
            ),
            if (d != _debts.last)
              Divider(height: 16, color: cs.outline.withValues(alpha: 0.12)),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Owed',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                CurrencyService.format(
                    _debts.fold(0.0, (s, d) => s + d.balance)),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(ColorScheme cs) {
    final avalMonths = _avalancheSchedule.length;
    final snowMonths = _snowballSchedule.length;
    final interestSaved = _snowballTotalInterest - _avalancheTotalInterest;
    final bestIsAvalanche = _avalancheTotalInterest <= _snowballTotalInterest;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: cs.primary, size: 18),
              const SizedBox(width: 8),
              const Text('Strategy Comparison',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _strategyCard(
                'Avalanche',
                Icons.bolt,
                avalMonths,
                _avalancheTotalInterest,
                bestIsAvalanche,
                cs,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _strategyCard(
                'Snowball',
                Icons.ac_unit,
                snowMonths,
                _snowballTotalInterest,
                !bestIsAvalanche,
                cs,
              )),
            ],
          ),
          if (interestSaved.abs() > 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bestIsAvalanche
                          ? 'Avalanche saves ${CurrencyService.format(interestSaved.abs())} in interest'
                          : 'Snowball is faster by ${(avalMonths - snowMonths).abs()} months',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _strategyCard(String name, IconData icon, int months, double interest,
      bool isBest, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBest ? cs.primary.withValues(alpha: 0.08) : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBest
              ? cs.primary.withValues(alpha: 0.35)
              : cs.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: cs.primary)),
              if (isBest) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('BEST',
                      style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text('$months months',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text('to debt-free',
              style: TextStyle(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: 6),
          Text(CurrencyService.format(interest),
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text('total interest',
              style: TextStyle(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55))),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(List<_PayoffMonth> schedule, ColorScheme cs) {
    if (schedule.isEmpty) {
      return const Center(child: Text('No data'));
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Row(
              children: [
                const SizedBox(
                    width: 44,
                    child: Text('Month',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text('Balance',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text('Interest',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          for (int i = 0; i < schedule.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              color: i.isOdd
                  ? cs.surfaceContainerLow.withValues(alpha: 0.4)
                  : null,
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text('${schedule[i].month}',
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.7))),
                  ),
                  Expanded(
                    child: Text(
                      CurrencyService.format(schedule[i].totalBalance),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: schedule[i].totalBalance < 1000
                              ? Colors.green
                              : cs.onSurface),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      CurrencyService.format(schedule[i].interestPaid),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _DebtEntry {
  final int id;
  final String title;
  final String person;
  final double balance;
  final double interestRate; // annual %

  const _DebtEntry({
    required this.id,
    required this.title,
    required this.person,
    required this.balance,
    required this.interestRate,
  });
}

class _PayoffMonth {
  final int month;
  final double totalBalance;
  final double interestPaid;

  const _PayoffMonth({
    required this.month,
    required this.totalBalance,
    required this.interestPaid,
  });
}
