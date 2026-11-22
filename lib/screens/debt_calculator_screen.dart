import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../services/debt_calculator.dart';
import '../services/currency_service.dart';

/// FEAT-011 — Standalone Debt Payoff Calculator
/// Users manually enter debts and an extra monthly budget,
/// then see a side-by-side Avalanche vs Snowball comparison.
class DebtCalculatorScreen extends StatefulWidget {
  const DebtCalculatorScreen({super.key});

  @override
  State<DebtCalculatorScreen> createState() => _DebtCalculatorScreenState();
}

class _DebtCalculatorScreenState extends State<DebtCalculatorScreen> {
  final _extraCtrl = TextEditingController();
  final List<_DebtFormEntry> _debts = [];

  PayoffResult? _avalanche;
  PayoffResult? _snowball;
  bool _calculated = false;

  @override
  void dispose() {
    _extraCtrl.dispose();
    for (final d in _debts) {
      d.dispose();
    }
    super.dispose();
  }

  void _addDebt() {
    setState(() => _debts.add(_DebtFormEntry()));
  }

  void _removeDebt(int index) {
    setState(() {
      _debts[index].dispose();
      _debts.removeAt(index);
      _calculated = false;
    });
  }

  void _calculate() {
    // Validate
    if (_debts.isEmpty) {
      _showError('Add at least one debt before calculating.');
      return;
    }
    final extra = double.tryParse(_extraCtrl.text.trim()) ?? 0;
    if (extra < 0) {
      _showError('Extra monthly payment cannot be negative.');
      return;
    }

    final entries = <DebtEntry>[];
    for (int i = 0; i < _debts.length; i++) {
      final d = _debts[i];
      final name = d.nameCtrl.text.trim();
      final balance = double.tryParse(d.balanceCtrl.text.trim()) ?? 0;
      final rate =
          (double.tryParse(d.rateCtrl.text.trim()) ?? 0) / 100; // % → decimal
      final min = double.tryParse(d.minCtrl.text.trim()) ?? 0;

      if (name.isEmpty) {
        _showError('Debt #${i + 1}: name is required.');
        return;
      }
      if (balance <= 0) {
        _showError('Debt #${i + 1}: balance must be greater than zero.');
        return;
      }
      if (min <= 0) {
        _showError(
            'Debt #${i + 1}: minimum payment must be greater than zero.');
        return;
      }
      entries.add(DebtEntry(
        name: name,
        balance: balance,
        annualInterestRate: rate,
        minPayment: min,
      ));
    }

    setState(() {
      _avalanche = DebtCalculator.avalanche(entries, extra);
      _snowball = DebtCalculator.snowball(entries, extra);
      _calculated = true;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.debtCalculatorScreenTitle),
        centerTitle: false,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDebt,
        icon: const Icon(Icons.add),
        label: const Text('Add Debt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Extra payment input
            const _SectionLabel(label: 'Extra Monthly Payment Budget'),
            const SizedBox(height: 6),
            Text(
              'Amount you can put toward debt on top of minimums each month.',
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _extraCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              decoration: InputDecoration(
                prefixText: '₱ ',
                hintText: '0',
                filled: true,
                fillColor: cs.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => setState(() => _calculated = false),
            ),

            const SizedBox(height: 24),
            const _SectionLabel(label: 'Your Debts'),
            const SizedBox(height: 10),

            if (_debts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Tap "Add Debt" below to get started.',
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 14),
                  ),
                ),
              ),

            for (int i = 0; i < _debts.length; i++) ...[
              _DebtCard(
                index: i,
                entry: _debts[i],
                onRemove: () => _removeDebt(i),
                onChanged: () => setState(() => _calculated = false),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calculate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            if (_calculated && _avalanche != null && _snowball != null) ...[
              const SizedBox(height: 28),
              _ComparisonPanel(
                avalanche: _avalanche!,
                snowball: _snowball!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Debt form entry ───────────────────────────────────────────────────────────

class _DebtFormEntry {
  final nameCtrl = TextEditingController();
  final balanceCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final minCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    balanceCtrl.dispose();
    rateCtrl.dispose();
    minCtrl.dispose();
  }
}

// ── Individual debt card ──────────────────────────────────────────────────────

class _DebtCard extends StatelessWidget {
  final int index;
  final _DebtFormEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _DebtCard({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Debt #${index + 1}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: cs.primary),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.remove_circle_outline,
                    color: cs.error, size: 20),
                visualDensity: VisualDensity.compact,
                tooltip: 'Remove',
              ),
            ],
          ),
          const SizedBox(height: 10),
          _field(
            controller: entry.nameCtrl,
            label: 'Name',
            hint: 'e.g. Credit Card',
            onChanged: onChanged,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _field(
                  controller: entry.balanceCtrl,
                  label: 'Balance (₱)',
                  hint: '10000',
                  numeric: true,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  controller: entry.rateCtrl,
                  label: 'Annual Rate (%)',
                  hint: '18',
                  numeric: true,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _field(
            controller: entry.minCtrl,
            label: 'Min Monthly Payment (₱)',
            hint: '500',
            numeric: true,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool numeric = false,
    required VoidCallback onChanged,
  }) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return TextField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: numeric
            ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
            : null,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: cs.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          labelStyle: TextStyle(
              fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        style: const TextStyle(fontSize: 14),
      );
    });
  }
}

// ── Results comparison panel ──────────────────────────────────────────────────

class _ComparisonPanel extends StatelessWidget {
  final PayoffResult avalanche;
  final PayoffResult snowball;

  const _ComparisonPanel({
    required this.avalanche,
    required this.snowball,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avalSaves = avalanche.totalInterestPaid <= snowball.totalInterestPaid;
    final diff =
        (snowball.totalInterestPaid - avalanche.totalInterestPaid).abs();
    final monthDiff =
        (avalanche.monthsToDebtFree - snowball.monthsToDebtFree).abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'Strategy Comparison'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StrategyColumn(
                result: avalanche,
                label: 'Avalanche',
                subtitle: 'Highest rate first',
                icon: Icons.bolt,
                isBetter: avalSaves,
                cs: cs,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StrategyColumn(
                result: snowball,
                label: 'Snowball',
                subtitle: 'Lowest balance first',
                icon: Icons.ac_unit,
                isBetter: !avalSaves,
                cs: cs,
              ),
            ),
          ],
        ),
        if (diff > 1 || monthDiff > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    avalSaves && diff > 1
                        ? 'Avalanche saves ${CurrencyService.format(diff)} in total interest.'
                        : !avalSaves && diff > 1
                            ? 'Snowball saves ${CurrencyService.format(diff)} in total interest.'
                            : avalanche.monthsToDebtFree <
                                    snowball.monthsToDebtFree
                                ? 'Avalanche is debt-free $monthDiff month${monthDiff == 1 ? '' : 's'} sooner.'
                                : 'Snowball is debt-free $monthDiff month${monthDiff == 1 ? '' : 's'} sooner.',
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
    );
  }
}

class _StrategyColumn extends StatelessWidget {
  final PayoffResult result;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isBetter;
  final ColorScheme cs;

  const _StrategyColumn({
    required this.result,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isBetter,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBetter
            ? cs.primary.withValues(alpha: 0.08)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBetter
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outline.withValues(alpha: 0.15),
          width: isBetter ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, size: 15, color: cs.primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isBetter ? cs.primary : cs.onSurface),
                ),
              ),
              if (isBetter)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'BEST',
                    style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Months
          Text(
            '${result.monthsToDebtFree} mo',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            'to debt-free',
            style: TextStyle(
                fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 8),

          // Interest
          Text(
            CurrencyService.format(result.totalInterestPaid),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            'total interest',
            style: TextStyle(
                fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
          ),

          if (result.payoffOrder.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'Payoff order',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 4),
            for (int i = 0; i < result.payoffOrder.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}.',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cs.primary),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        result.payoffOrder[i],
                        style: const TextStyle(fontSize: 12),
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
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface),
    );
  }
}
