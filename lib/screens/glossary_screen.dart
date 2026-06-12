import 'package:flutter/material.dart';

/// Financial Glossary — explains key financial terms in plain Filipino-English
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _search = '';

  static const _terms = [
    _Term(
        'Financial Health Score (FHS)',
        'A 0-100 score computed by SmartSpend based on 4 components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency. 80+ = Good, 60-79 = Fair, below 60 = Needs Attention.',
        '📊',
        'SmartSpend'),
    _Term(
        '50/30/20 Rule',
        'A budgeting guideline: 50% of income for Needs (essentials), 30% for Wants (discretionary), 20% for Savings. A popular starting point for any income level.',
        '🎯',
        'Budgeting'),
    _Term(
        'Debt-to-Income Ratio (DTI)',
        'Your total monthly debt payments divided by your monthly income. BSP recommends keeping it below 30%. Above 50% is considered critical.',
        '💳',
        'Finance'),
    _Term(
        'Emergency Fund',
        'Savings set aside for unexpected expenses — job loss, medical emergency, major repair. Target: 3 months of expenses (minimum) to 6 months (recommended). Keep in a high-yield savings account.',
        '🛡️',
        'Savings'),
    _Term(
        'MP2 (Modified Pag-IBIG 2)',
        'A voluntary savings program by Pag-IBIG. Earns 6-9% annual dividends, tax-free, government-guaranteed. Minimum ₱500/month. 5-year lock-in (can withdraw after).',
        '🏦',
        'Investments Philippines'),
    _Term(
        'SSS',
        'Social Security System — mandatory for employed/self-employed Filipinos. Provides benefits: retirement, disability, death, maternity, sickness, unemployment. Contribution: 14% of monthly salary credit (employee pays 4.5%, employer 9.5%).',
        '🏛️',
        'Government Philippines'),
    _Term(
        'PhilHealth',
        'Philippine Health Insurance Corporation — mandatory government health insurance. Covers hospitalization, outpatient care, Z-benefits. Contribution: 5% of monthly income (split 50/50 with employer). Min ₱500/mo.',
        '🏥',
        'Government Philippines'),
    _Term(
        'Pag-IBIG',
        'Home Development Mutual Fund — mandatory for employed Filipinos. Provides housing loans and MP2 savings. Employee pays 2%, employer 2% of monthly salary. Max employee contribution: ₱200/mo.',
        '🏠',
        'Government Philippines'),
    _Term(
        'T-Bills (Treasury Bills)',
        'Short-term government securities (91-364 days). Earn 5-6% annually. Tax-exempt, government-guaranteed. Available via Bonds.ph or major banks. Minimum investment: ₱5,000.',
        '📜',
        'Investments Philippines'),
    _Term(
        'UITF (Unit Investment Trust Fund)',
        'A pooled investment fund managed by banks. Types: money market, bond, equity. Low minimum investment (₱1,000+). Not PDIC-insured — returns vary. Available via BDO, BPI, Metrobank, etc.',
        '📈',
        'Investments'),
    _Term(
        'PDIC',
        'Philippine Deposit Insurance Corporation. Insures bank deposits up to ₱500,000 per depositor per bank. Applies to savings, time deposits, and some digital bank accounts.',
        '🔒',
        'Banking Philippines'),
    _Term(
        'GoTyme Bank',
        'Digital bank by Gokongwei Group + Tyme. No maintaining balance. Savings account earns 5% p.a. — highest among PH digital banks. Debit card via GoTyme kiosks in Robinson\'s malls.',
        '🏦',
        'Banking Philippines'),
    _Term(
        'Peso Cost Averaging (PCA)',
        'An investment strategy where you invest a fixed amount regularly regardless of market price. Reduces risk by averaging out the cost over time. Example: ₱500/month in a mutual fund for 5 years.',
        '💹',
        'Investments'),
    _Term(
        'VUL (Variable Universal Life Insurance)',
        'Life insurance + investment combined. Part of your premium goes to insurance coverage, part goes to investment funds. Higher returns possible but higher risk. Sold by Sun Life, AXA, Pru Life, Manulife in PH.',
        '🛡️',
        'Insurance Philippines'),
    _Term(
        'HMO',
        'Health Maintenance Organization — private health insurance from companies like Maxicare, Intellicare, Medicard. Covers outpatient and hospitalization at accredited clinics/hospitals. Different from PhilHealth (government).',
        '🏥',
        'Insurance Philippines'),
    _Term(
        'Open Banking (BSP OFxPERA)',
        'BSP\'s Open Finance framework launched July 2025. Allows third-party apps (with user consent) to access bank account data via API. UnionBank is first participant. SmartSpend is architecturally ready for integration.',
        '🌐',
        'Technology Philippines'),
    _Term(
        'GCash GInvest',
        'Investment feature within GCash. Offers UITFs (bond and equity funds) starting from ₱50. Managed by ATRAM, First Metro, and others. Easy access but higher fees than direct bank UITFs.',
        '📱',
        'Investments Philippines'),
    _Term(
        'Paluwagan',
        'A traditional Filipino informal savings scheme. A group of people contribute fixed amounts regularly, and each member takes turns receiving the pot. No interest, no formal contract — based on trust.',
        '🤝',
        'Traditional Philippines'),
    _Term(
        'BIR TRAIN Law',
        'Tax Reform for Acceleration and Inclusion. Annual income up to ₱250K is tax-exempt. ₱250K-400K: 15%. ₱400K-800K: 20%. ₱800K-2M: 25%. ₱2M-8M: 30%. Above ₱8M: 35%.',
        '📋',
        'Tax Philippines'),
    _Term(
        'Net Worth',
        'Assets minus liabilities. Assets: cash, savings, investments, property value. Liabilities: loans, debts, credit card balances, installments. Positive net worth = you own more than you owe.',
        '💰',
        'Finance'),
    _Term(
        'Savings Rate',
        'The percentage of your income that you save. Calculated as: (Income - Total Expenses) / Income × 100. Financial experts recommend at least 20%. A key component of your FHS.',
        '💵',
        'Finance'),
    _Term(
        'Impulse Buying',
        'Buying something on a sudden urge without planning. Often leads to regret. SmartSpend\'s Impulse Pause asks you to wait 10 seconds before logging large Want expenses.',
        '🛒',
        'Behavior'),
    _Term(
        'Compound Interest',
        'Interest earned on both your principal AND previously earned interest. "The 8th wonder of the world" — your money grows faster over time. Example: ₱1,000 at 6%/yr = ₱1,790 after 10 years.',
        '📈',
        'Finance'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _search.isEmpty
        ? _terms
        : _terms
            .where((t) =>
                t.term.toLowerCase().contains(_search.toLowerCase()) ||
                t.definition.toLowerCase().contains(_search.toLowerCase()) ||
                t.category.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Glossary"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: "Search terms...",
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final t = filtered[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading:
                        Text(t.emoji, style: const TextStyle(fontSize: 22)),
                    title: Text(t.term,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(t.category,
                          style: TextStyle(fontSize: 10, color: cs.primary)),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(t.definition,
                            style: const TextStyle(fontSize: 13, height: 1.5)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Term {
  final String term;
  final String definition;
  final String emoji;
  final String category;
  const _Term(this.term, this.definition, this.emoji, this.category);
}
