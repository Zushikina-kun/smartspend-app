import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';

/// Peso Cost Averaging Calculator
/// Helps users plan regular investments over time
class PCACalculatorScreen extends StatefulWidget {
  const PCACalculatorScreen({super.key});

  @override
  State<PCACalculatorScreen> createState() => _PCACalculatorScreenState();
}

class _PCACalculatorScreenState extends State<PCACalculatorScreen> {
  final _monthlyCtrl = TextEditingController(text: '500');
  final _yearsCtrl = TextEditingController(text: '5');
  final _rateCtrl = TextEditingController(text: '6');

  double _totalInvested = 0;
  double _totalValue = 0;
  double _totalGain = 0;
  List<Map<String, double>> _yearlyBreakdown = [];
  bool _calculated = false;

  @override
  void dispose() {
    _monthlyCtrl.dispose();
    _yearsCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final monthly = double.tryParse(_monthlyCtrl.text) ?? 0;
    final years = int.tryParse(_yearsCtrl.text) ?? 0;
    final annualRate = double.tryParse(_rateCtrl.text) ?? 0;
    if (monthly <= 0 || years <= 0 || annualRate <= 0) return;

    final monthlyRate = annualRate / 100 / 12;
    final months = years * 12;

    // Future value of regular investment: FV = PMT × [(1+r)^n - 1] / r
    final fv = monthly * ((pow1(1 + monthlyRate, months) - 1) / monthlyRate);
    final invested = monthly * months;

    // Year-by-year breakdown
    final breakdown = <Map<String, double>>[];
    for (int y = 1; y <= years; y++) {
      final n = y * 12;
      final yearFv = monthly * ((pow1(1 + monthlyRate, n) - 1) / monthlyRate);
      final yearInvested = monthly * n;
      breakdown.add({
        'year': y.toDouble(),
        'invested': yearInvested,
        'value': yearFv,
        'gain': yearFv - yearInvested,
      });
    }

    setState(() {
      _totalInvested = invested;
      _totalValue = fv;
      _totalGain = fv - invested;
      _yearlyBreakdown = breakdown;
      _calculated = true;
    });
  }

  double pow1(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) result *= base;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peso Cost Averaging"),
        actions: const [
          InfoButton(
            title: "Peso Cost Averaging (PCA)",
            body: "PCA is a strategy where you invest a fixed amount regularly "
                "regardless of market price.\n\n"
                "Benefits:\n"
                "• Removes emotion from investing\n"
                "• Averages out your cost over time\n"
                "• Works great for stocks, MP2, UITFs\n\n"
                "Example: ₱500/month in MP2 at 6% for 5 years = ₱34,885\n\n"
                "Use this calculator to plan your regular investments.",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Investment Parameters",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    _inputField(
                        _monthlyCtrl,
                        "Monthly Investment (${CurrencyService.symbol})",
                        Icons.payments_outlined),
                    const SizedBox(height: 12),
                    _inputField(_yearsCtrl, "Investment Period (years)",
                        Icons.calendar_today_outlined),
                    const SizedBox(height: 12),
                    _inputField(
                        _rateCtrl, "Annual Return Rate (%)", Icons.trending_up),
                    const SizedBox(height: 6),
                    Text(
                      "Reference rates: MP2 ~6-7% · GoTyme 5% · T-bills ~5-6% · PSEi avg ~8-12%",
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _calculate,
                        icon: const Icon(Icons.calculate),
                        label: const Text("Calculate"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_calculated) ...[
              const SizedBox(height: 16),
              // Results summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text("After ${0} years",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      CurrencyService.format(_totalValue),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _resultItem(
                            "Total Invested",
                            CurrencyService.format(_totalInvested),
                            Colors.white70),
                        _resultItem(
                            "Total Gain",
                            "+${CurrencyService.format(_totalGain)}",
                            Colors.greenAccent),
                        _resultItem(
                            "Return",
                            "${(_totalGain / _totalInvested * 100).toStringAsFixed(1)}%",
                            Colors.greenAccent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Year-by-Year Breakdown",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ...(_yearlyBreakdown.map((y) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 60,
                            child: Text("Year ${y['year']!.toInt()}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey))),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (_totalValue > 0
                                  ? (y['value']! / _totalValue)
                                  : 0),
                              minHeight: 8,
                              backgroundColor: cs.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              valueColor: AlwaysStoppedAnimation(cs.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                            width: 90,
                            child: Text(
                              CurrencyService.format(y['value']!),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.right,
                            )),
                      ],
                    ),
                  ))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "⚠️ This is for educational purposes only. Actual returns vary based on market conditions. Past performance doesn't guarantee future results.",
                  style: TextStyle(fontSize: 11, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }

  Widget _resultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}
