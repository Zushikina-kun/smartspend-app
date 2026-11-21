import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/egov/sss_service.dart';
import '../../services/currency_service.dart';
import '../../widgets/info_button.dart';

class SSSScreen extends StatefulWidget {
  const SSSScreen({Key? key}) : super(key: key);

  @override
  State<SSSScreen> createState() => _SSSScreenState();
}

class _SSSScreenState extends State<SSSScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Contribution Calculator
  final TextEditingController _salaryController =
      TextEditingController(text: '15000');
  Map<String, double>? _contributionResult;

  // Loan Calculators
  final TextEditingController _monthlyPayController =
      TextEditingController(text: '20000');
  final TextEditingController _salaryLoanAmountController =
      TextEditingController(text: '40000');
  double _emergencyLoanAmount = 10000;
  Map<String, double>? _salaryLoanResult;
  Map<String, double>? _calamityLoanResult;
  Map<String, double>? _emergencyLoanResult;

  // Contribution History
  List<Map<String, dynamic>>? _contributionHistory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateContribution();
    _loadContributionHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _salaryController.dispose();
    _monthlyPayController.dispose();
    _salaryLoanAmountController.dispose();
    super.dispose();
  }

  void _calculateContribution() {
    final salary = double.tryParse(_salaryController.text) ?? 0;
    if (salary > 0) {
      setState(() {
        _contributionResult = SSSService.calculateMonthlyContribution(salary);
      });
    }
  }

  void _calculateSalaryLoan() {
    final monthlyPay = double.tryParse(_monthlyPayController.text) ?? 0;
    final loanAmount = double.tryParse(_salaryLoanAmountController.text) ?? 0;
    if (monthlyPay > 0 && loanAmount > 0) {
      setState(() {
        _salaryLoanResult =
            SSSService.calculateSalaryLoan(monthlyPay, loanAmount);
      });
    }
  }

  void _calculateCalamityLoan() {
    final monthlyPay = double.tryParse(_monthlyPayController.text) ?? 0;
    if (monthlyPay > 0) {
      setState(() {
        _calamityLoanResult = SSSService.calculateCalamityLoan(monthlyPay);
      });
    }
  }

  void _calculateEmergencyLoan() {
    final monthlyPay = double.tryParse(_monthlyPayController.text) ?? 0;
    if (monthlyPay > 0) {
      setState(() {
        _emergencyLoanResult =
            SSSService.calculateEmergencyLoan(monthlyPay, _emergencyLoanAmount);
      });
    }
  }

  void _loadContributionHistory() {
    final salary = double.tryParse(_salaryController.text) ?? 15000;
    setState(() {
      _contributionHistory =
          SSSService.generateMockContributionHistory(salary: salary);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSS Calculator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Contribution', icon: Icon(Icons.calculate)),
            Tab(text: 'Loans', icon: Icon(Icons.account_balance)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContributionTab(),
          _buildLoansTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildContributionTab() {
    final info = SSSService.getContributionInfo();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Contribution Calculator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InfoButton(
                title: 'SSS Contribution Rates',
                body: '${info['description']}\n\n'
                    'Total Rate: ${info['totalRate']}\n'
                    'Employer: ${info['employerRate']}\n'
                    'Employee: ${info['employeeRate']}\n'
                    'Salary Range: ${info['salaryRange']}\n\n'
                    'For official information, visit https://www.sss.gov.ph',
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Monthly Salary',
              prefixText: '₱ ',
              border: OutlineInputBorder(),
              helperText: 'Enter your monthly salary (₱1,000 - ₱29,750+)',
            ),
            onChanged: (value) => _calculateContribution(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _calculateContribution,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Calculate Contribution'),
          ),
          const SizedBox(height: 24),
          if (_contributionResult != null) _buildContributionResult(),
        ],
      ),
    );
  }

  Widget _buildContributionResult() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Contribution Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildResultRow(
              'Employee Share (4.5%)',
              _contributionResult!['employeeShare']!,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildResultRow(
              'Employer Share (9.5%)',
              _contributionResult!['employerShare']!,
              color: Colors.green,
            ),
            const Divider(height: 24),
            _buildResultRow(
              'Total Contribution (14%)',
              _contributionResult!['totalContribution']!,
              color: Colors.purple,
              isBold: true,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'This is the amount deducted from your salary each month for SSS contributions. Your employer also contributes on your behalf.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoansTab() {
    final loanInfo = SSSService.getLoanEligibilityInfo();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'SSS Loan Calculators',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InfoButton(
                title: 'SSS Loan Eligibility',
                body: 'Salary Loan:\n${loanInfo['salaryLoan']}\n\n'
                    'Calamity Loan:\n${loanInfo['calamityLoan']}\n\n'
                    'Emergency Loan:\n${loanInfo['emergencyLoan']}\n\n'
                    '${loanInfo['officialSource']}',
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _monthlyPayController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Monthly Salary',
              prefixText: '₱ ',
              border: OutlineInputBorder(),
              helperText: 'Your monthly salary for loan eligibility',
            ),
          ),
          const SizedBox(height: 24),
          _buildSalaryLoanSection(),
          const SizedBox(height: 16),
          _buildCalamityLoanSection(),
          const SizedBox(height: 16),
          _buildEmergencyLoanSection(),
        ],
      ),
    );
  }

  Widget _buildSalaryLoanSection() {
    return ExpansionTile(
      title: const Text(
        'Salary Loan',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('24-month term, 10% annual interest'),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _salaryLoanAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Loan Amount',
                  prefixText: '₱ ',
                  border: OutlineInputBorder(),
                  helperText: 'Maximum: 2x your monthly salary',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateSalaryLoan,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Calculate Monthly Payment'),
              ),
              const SizedBox(height: 16),
              if (_salaryLoanResult != null)
                _buildLoanResult(_salaryLoanResult!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalamityLoanSection() {
    return ExpansionTile(
      title: const Text(
        'Calamity Loan',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('Maximum ₱20,000, 24-month term'),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  'Maximum loan amount: ₱20,000\n10% annual interest, 24-month term',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateCalamityLoan,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Calculate Monthly Payment'),
              ),
              const SizedBox(height: 16),
              if (_calamityLoanResult != null)
                _buildLoanResult(_calamityLoanResult!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyLoanSection() {
    return ExpansionTile(
      title: const Text(
        'Emergency Loan',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('₱5,000 - ₱20,000, 12-month term'),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Loan Amount: ${CurrencyService.format(_emergencyLoanAmount)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _emergencyLoanAmount,
                min: 5000,
                max: 20000,
                divisions: 30,
                label: CurrencyService.format(_emergencyLoanAmount),
                onChanged: (value) {
                  setState(() {
                    _emergencyLoanAmount = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateEmergencyLoan,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.red,
                ),
                child: const Text('Calculate Monthly Payment'),
              ),
              const SizedBox(height: 16),
              if (_emergencyLoanResult != null)
                _buildLoanResult(_emergencyLoanResult!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoanResult(Map<String, double> result) {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _buildResultRow('Principal Amount', result['principal']!),
            const SizedBox(height: 8),
            _buildResultRow('Term', result['termMonths']!, suffix: ' months'),
            const SizedBox(height: 8),
            _buildResultRow('Total Interest', result['totalInterest']!),
            const Divider(height: 20),
            _buildResultRow(
              'Monthly Payment',
              result['monthlyPayment']!,
              color: Colors.green.shade700,
              isBold: true,
            ),
            const SizedBox(height: 8),
            _buildResultRow('Total Payment', result['totalPayment']!),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_contributionHistory == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Contribution History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InfoButton(
                title: 'About Contribution History',
                body: 'This is MOCK DATA for demonstration purposes only.\n\n'
                    'To check your real SSS contribution history:\n'
                    '1. Visit https://www.sss.gov.ph\n'
                    '2. Log in to your My.SSS account\n'
                    '3. Navigate to Inquiry > Contributions\n\n'
                    'Your actual contribution records are maintained by SSS and your employer.',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is mock data for demonstration only. Check real history at sss.gov.ph',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('Month',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Salary',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Employee',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Employer',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _contributionHistory!.map((entry) {
                final date = entry['date'] as DateTime;
                final dateStr = DateFormat('MMM yyyy').format(date);

                return DataRow(
                  cells: [
                    DataCell(Text(dateStr)),
                    DataCell(Text(CurrencyService.format(entry['salary']))),
                    DataCell(
                        Text(CurrencyService.format(entry['employeeShare']))),
                    DataCell(
                        Text(CurrencyService.format(entry['employerShare']))),
                    DataCell(Text(
                      CurrencyService.format(entry['totalContribution']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (_contributionHistory!.isNotEmpty) _buildHistorySummary(),
        ],
      ),
    );
  }

  Widget _buildHistorySummary() {
    double totalEmployee = 0;
    double totalEmployer = 0;
    double totalContributions = 0;

    for (var entry in _contributionHistory!) {
      totalEmployee += entry['employeeShare'] as double;
      totalEmployer += entry['employerShare'] as double;
      totalContributions += entry['totalContribution'] as double;
    }

    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 12 Months Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _buildResultRow('Total Employee Contributions', totalEmployee),
            const SizedBox(height: 8),
            _buildResultRow('Total Employer Contributions', totalEmployer),
            const Divider(height: 20),
            _buildResultRow(
              'Total Contributions',
              totalContributions,
              color: Colors.blue.shade700,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value,
      {Color? color, bool isBold = false, String suffix = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          suffix.isEmpty
              ? CurrencyService.format(value)
              : '${value.toStringAsFixed(0)}$suffix',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
