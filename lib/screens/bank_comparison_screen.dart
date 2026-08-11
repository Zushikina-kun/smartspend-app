import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';

class BankComparisonScreen extends StatefulWidget {
  const BankComparisonScreen({super.key});

  @override
  State<BankComparisonScreen> createState() => _BankComparisonScreenState();
}

class _BankComparisonScreenState extends State<BankComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/ph_banks.json');
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (mounted)
        setState(() {
          _data = parsed;
          _loading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PH Banks & Investments"),
        actions: const [
          InfoButton(
            title: "PH Banks & Investments",
            body:
                "Compare Philippine banks, digital banks, e-wallets, and investment options.\n\n"
                "• Traditional banks: minimum balance, interest rates\n"
                "• Digital banks: higher rates, no maintaining balance\n"
                "• E-wallets: GCash, Maya, GrabPay features\n"
                "• Investments: MP2, T-bills, time deposits, UITFs\n\n"
                "Rates are approximate and may change. Always verify with the institution.",
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: const [
            Tab(text: "Banks"),
            Tab(text: "Digital"),
            Tab(text: "E-Wallets"),
            Tab(text: "Investments"),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildBanksTab(),
                _buildDigitalTab(),
                _buildEwalletsTab(),
                _buildInvestmentsTab(),
              ],
            ),
    );
  }

  Widget _buildBanksTab() {
    final banks = (_data['banks'] as List? ?? [])
        .where((b) => (b['type'] as String?) != 'digital')
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: banks.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _buildBankHeader();
        final bank = banks[i - 1] as Map<String, dynamic>;
        return _buildBankCard(bank);
      },
    );
  }

  Widget _buildDigitalTab() {
    final banks = (_data['banks'] as List? ?? [])
        .where((b) => (b['type'] as String?) == 'digital')
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: banks.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "💡 Digital banks offer higher interest rates (3-5% vs 0.25% traditional) with no maintaining balance. All are PDIC-insured up to ₱500,000.",
                style: TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          );
        }
        final bank = banks[i - 1] as Map<String, dynamic>;
        return _buildBankCard(bank, isDigital: true);
      },
    );
  }

  Widget _buildEwalletsTab() {
    final wallets = (_data['ewallets'] as List? ?? []);
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: wallets.length,
      itemBuilder: (_, i) {
        final w = wallets[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getWalletIcon(w['name'] as String),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(w['provider'] as String? ?? '',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(w['features'] as String? ?? '',
                    style: const TextStyle(fontSize: 12, height: 1.4)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _chip("Limit: ₱${((w['limit'] as num?) ?? 0) ~/ 1000}K"),
                    const SizedBox(width: 6),
                    _chip("Cash-in: ${w['cash_in'] ?? 'Free'}"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvestmentsTab() {
    final investments = (_data['investment_options'] as List? ?? []);
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: investments.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "⚠️ This is for educational purposes only — not financial advice. Always do your own research before investing.",
                style: TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          );
        }
        final inv = investments[i - 1] as Map<String, dynamic>;
        return _buildInvestmentCard(inv);
      },
    );
  }

  Widget _buildBankHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
                "${(_data['banks'] as List? ?? []).where((b) => b['type'] != 'digital').length} Traditional Banks",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const Text("Sorted by min balance",
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBankCard(Map<String, dynamic> bank, {bool isDigital = false}) {
    final name = bank['name'] as String? ?? '';
    final rate = (bank['savings_rate'] as num?)?.toDouble() ?? 0;
    final minBal = (bank['min_balance'] as num?)?.toDouble() ?? 0;
    final notes = bank['notes'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isDigital ? Icons.phone_android : Icons.account_balance,
                    size: 18, color: isDigital ? Colors.green : Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: rate >= 3.0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text("${rate}% p.a.",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              rate >= 3.0 ? Colors.green : Colors.grey[700])),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip(
                    "Min: ${minBal > 0 ? CurrencyService.format(minBal) : 'None'}"),
                const SizedBox(width: 6),
                _chip(bank['online'] == true ? "Online ✓" : "Branch only"),
                if ((bank['branches'] as int? ?? 0) > 0) ...[
                  const SizedBox(width: 6),
                  _chip("${bank['branches']} branches"),
                ],
              ],
            ),
            if (notes != null) ...[
              const SizedBox(height: 6),
              Text(notes,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey, height: 1.3)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCard(Map<String, dynamic> inv) {
    final name = inv['name'] as String? ?? '';
    final minAmt = (inv['min_amount'] as num?)?.toDouble() ?? 0;
    final returns = inv['expected_return'] as String? ?? '';
    final risk = inv['risk'] as String? ?? 'low';
    final liquidity = inv['liquidity'] as String? ?? '';
    final notes = inv['notes'] as String? ?? '';

    final riskColor = risk == 'very_low'
        ? Colors.green
        : risk == 'low'
            ? Colors.teal
            : risk == 'high'
                ? Colors.orange
                : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(risk.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: riskColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip("Returns: $returns"),
                const SizedBox(width: 6),
                _chip(
                    "Min: ${minAmt > 0 ? CurrencyService.format(minAmt) : 'None'}"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _chip("Liquidity: $liquidity"),
              ],
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(notes,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey, height: 1.3)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }

  Widget _getWalletIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('gcash'))
      return const Text("📱", style: TextStyle(fontSize: 24));
    if (lower.contains('maya'))
      return const Text("💜", style: TextStyle(fontSize: 24));
    if (lower.contains('grab'))
      return const Text("🟢", style: TextStyle(fontSize: 24));
    if (lower.contains('shopee'))
      return const Text("🟠", style: TextStyle(fontSize: 24));
    if (lower.contains('coins'))
      return const Text("🪙", style: TextStyle(fontSize: 24));
    return const Text("💳", style: TextStyle(fontSize: 24));
  }
}
