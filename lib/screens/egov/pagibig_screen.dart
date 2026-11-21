import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/egov/pagibig_service.dart';
import '../../services/currency_service.dart';
import '../../widgets/info_button.dart';

class PagIBIGScreen extends StatefulWidget {
  const PagIBIGScreen({Key? key}) : super(key: key);

  @override
  State<PagIBIGScreen> createState() => _PagIBIGScreenState();
}

class _PagIBIGScreenState extends State<PagIBIGScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Contribution Calculator
  final TextEditingController _salaryController = TextEditingController();
  Map<String, double>? _contributionResult;

  // Housing Loan Calculator
  double _loanAmount = 2000000;
  double _loanYears = 20;
  double _interestRate = 6.5;
  Map<String, double>? _loanResult;

  // MP2 Calculator
  final TextEditingController _mp2ContributionController =
      TextEditingController();
  double _mp2Years = 10;
  double _mp2DividendRate = 7.0;
  List<Map<String, dynamic>>? _mp2Projections;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _salaryController.text = '25000';
    _mp2ContributionController.text = '5000';
    _calculateContribution();
    _calculateLoan();
    _calculateMP2();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _salaryController.dispose();
    _mp2ContributionController.dispose();
    super.dispose();
  }

  void _calculateContribution() {
    double salary = double.tryParse(_salaryController.text) ?? 0;
    if (salary > 0) {
      setState(() {
        _contributionResult =
            PagIBIGService.calculateMonthlyContribution(salary);
      });
    }
  }

  void _calculateLoan() {
    setState(() {
      _loanResult = PagIBIGService.calculateHousingLoan(
        loanAmount: _loanAmount,
        years: _loanYears.toInt(),
        annualInterestRate: _interestRate,
      );
    });
  }

  void _calculateMP2() {
    double contribution = double.tryParse(_mp2ContributionController.text) ?? 0;
    if (contribution > 0) {
      setState(() {
        _mp2Projections = PagIBIGService.calculateMP2Projection(
          monthlyContribution: contribution,
          years: _mp2Years.toInt(),
          annualDividendRate: _mp2DividendRate,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pag-IBIG Calculators'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Contribution'),
            Tab(text: 'Housing Loan'),
            Tab(text: 'MP2 Savings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContributionTab(),
          _buildHousingLoanTab(),
          _buildMP2Tab(),
        ],
      ),
    );
  }

  Widget _buildContributionTab() {
    final info = PagIBIGService.getContributionInfo();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Contribution Calculator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InfoButton(
                title: 'Pag-IBIG Contribution',
                body: info['notes'].join('\n\n') +
                    '\n\nVisit pagibigfund.gov.ph for more details.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Salary',
              prefixText: '₱ ',
              border: OutlineInputBorder(),
              helperText: 'Enter your monthly basic salary',
            ),
            onChanged: (value) => _calculateContribution(),
          ),
          const SizedBox(height: 24),
          if (_contributionResult != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Contribution Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContributionRow(
                      'Employee Share (2%)',
                      _contributionResult!['employee']!,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildContributionRow(
                      'Employer Share (2%)',
                      _contributionResult!['employer']!,
                      Colors.green,
                    ),
                    const Divider(height: 24),
                    _buildContributionRow(
                      'Total Contribution (4%)',
                      _contributionResult!['total']!,
                      Colors.deepPurple,
                      isTotal: true,
                    ),
                    if (_contributionResult!['cappedSalary']! <
                        double.parse(_salaryController.text)) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Computation capped at ₱${CurrencyService.format(_contributionResult!['cappedSalary']!)} (maximum salary for contribution)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Did you know?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your Pag-IBIG contributions help you qualify for:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text('• Housing loans up to ₱6M',
                        style: TextStyle(fontSize: 12)),
                    const Text('• Multi-Purpose Loan (MPL)',
                        style: TextStyle(fontSize: 12)),
                    const Text('• Calamity Loan',
                        style: TextStyle(fontSize: 12)),
                    const Text('• Provident Benefits upon retirement',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContributionRow(String label, double amount, Color color,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₱${CurrencyService.format(amount)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHousingLoanTab() {
    final info = PagIBIGService.getHousingLoanInfo();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Housing Loan Calculator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InfoButton(
                title: 'Pag-IBIG Housing Loan',
                body: info['notes'].join('\n\n') +
                    '\n\nVisit pagibigfund.gov.ph/housing.html for more information.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Loan Amount: ₱${CurrencyService.format(_loanAmount)}',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: _loanAmount,
            min: 100000,
            max: 6000000,
            divisions: 59,
            label: '₱${CurrencyService.format(_loanAmount)}',
            onChanged: (value) {
              setState(() {
                _loanAmount = value;
                _calculateLoan();
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Loan Term: ${_loanYears.toInt()} years',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: _loanYears,
            min: 5,
            max: 30,
            divisions: 25,
            label: '${_loanYears.toInt()} years',
            onChanged: (value) {
              setState(() {
                _loanYears = value;
                _calculateLoan();
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Interest Rate: ${_interestRate.toStringAsFixed(2)}% per year',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: _interestRate,
            min: 3.0,
            max: 12.0,
            divisions: 90,
            label: '${_interestRate.toStringAsFixed(2)}%',
            onChanged: (value) {
              setState(() {
                _interestRate = value;
                _calculateLoan();
              });
            },
          ),
          const SizedBox(height: 24),
          if (_loanResult != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loan Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLoanRow(
                      'Monthly Payment',
                      _loanResult!['monthlyPayment']!,
                      Colors.deepPurple,
                      isHighlighted: true,
                    ),
                    const Divider(height: 24),
                    _buildLoanRow(
                      'Total Amount Payable',
                      _loanResult!['totalPayment']!,
                      Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    _buildLoanRow(
                      'Total Interest',
                      _loanResult!['totalInterest']!,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildLoanRow(
                      'Principal Amount',
                      _loanAmount,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Important Notes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• This is an estimate only. Actual loan terms may vary.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Loan amount depends on your income and affordability.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Additional fees and insurance may apply.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Interest rates are subject to change.',
                      style: TextStyle(fontSize: 12),
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

  Widget _buildLoanRow(String label, double amount, Color color,
      {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₱${CurrencyService.format(amount)}',
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMP2Tab() {
    final info = PagIBIGService.getMP2Info();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'MP2 Savings Calculator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InfoButton(
                title: 'Modified Pag-IBIG II (MP2)',
                body: info['notes'].join('\n\n') +
                    '\n\nVisit pagibigfund.gov.ph/MP2.html for complete program details.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _mp2ContributionController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Contribution',
              prefixText: '₱ ',
              border: OutlineInputBorder(),
              helperText: 'Recommended minimum: ₱500/month',
            ),
            onChanged: (value) => _calculateMP2(),
          ),
          const SizedBox(height: 16),
          Text(
            'Investment Period: ${_mp2Years.toInt()} years',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: _mp2Years,
            min: 5,
            max: 20,
            divisions: 15,
            label: '${_mp2Years.toInt()} years',
            onChanged: (value) {
              setState(() {
                _mp2Years = value;
                _calculateMP2();
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Estimated Annual Dividend: ${_mp2DividendRate.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: _mp2DividendRate,
            min: 4.0,
            max: 10.0,
            divisions: 60,
            label: '${_mp2DividendRate.toStringAsFixed(1)}%',
            onChanged: (value) {
              setState(() {
                _mp2DividendRate = value;
                _calculateMP2();
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Historical average: 6-8% per year',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_mp2Projections != null && _mp2Projections!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Projected Growth',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMP2Chart(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Final Value Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMP2SummaryRow(
                      'Total Contributions',
                      _mp2Projections!.last['contributions'],
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildMP2SummaryRow(
                      'Estimated Dividends',
                      _mp2Projections!.last['dividends'],
                      Colors.green,
                    ),
                    const Divider(height: 24),
                    _buildMP2SummaryRow(
                      'Final Value',
                      _mp2Projections!.last['totalValue'],
                      Colors.deepPurple,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Year-by-Year Projection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMP2Table(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Tax-Free Returns',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• MP2 dividends are tax-exempt',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• 5-year lock-in period ensures disciplined savings',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Dividends vary yearly based on fund performance',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Can be renewed or withdrawn after maturity',
                      style: TextStyle(fontSize: 12),
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

  Widget _buildMP2SummaryRow(String label, double amount, Color color,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₱${CurrencyService.format(amount)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMP2Chart() {
    if (_mp2Projections == null || _mp2Projections!.isEmpty) {
      return const SizedBox();
    }

    // Get data points at 5-year intervals
    List<Map<String, dynamic>> chartData = [];
    for (var projection in _mp2Projections!) {
      if (projection['year'] % 5 == 0 ||
          projection['year'] == _mp2Projections!.last['year']) {
        chartData.add(projection);
      }
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _mp2Projections!.last['totalValue'] * 1.1,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final data = chartData[group.x.toInt()];
                final year = data['year'];
                if (rodIndex == 0) {
                  return BarTooltipItem(
                    'Year $year\nContributions: ₱${CurrencyService.format(data['contributions'])}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                } else {
                  return BarTooltipItem(
                    'Dividends: ₱${CurrencyService.format(data['dividends'])}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < chartData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Yr ${chartData[value.toInt()]['year']}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₱${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _mp2Projections!.last['totalValue'] / 5,
          ),
          barGroups: List.generate(chartData.length, (index) {
            final data = chartData[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data['contributions'],
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                ),
                BarChartRodData(
                  toY: data['totalValue'],
                  color: Colors.green,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMP2Table() {
    if (_mp2Projections == null || _mp2Projections!.isEmpty) {
      return const SizedBox();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowHeight: 40,
        dataRowMinHeight: 35,
        dataRowMaxHeight: 35,
        columns: const [
          DataColumn(
            label: Text('Year', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Contributions',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Dividends',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Total Value',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: _mp2Projections!.map((projection) {
          return DataRow(
            cells: [
              DataCell(Text(projection['year'].toString())),
              DataCell(Text(
                  '₱${CurrencyService.format(projection['contributions'])}')),
              DataCell(
                  Text('₱${CurrencyService.format(projection['dividends'])}')),
              DataCell(Text(
                '₱${CurrencyService.format(projection['totalValue'])}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
