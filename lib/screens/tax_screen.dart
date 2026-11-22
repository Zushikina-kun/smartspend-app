import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/tax_reminder_service.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../widgets/info_button.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({Key? key}) : super(key: key);

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calculator tab
  final TextEditingController _incomeController =
      TextEditingController(text: '300000');
  final TextEditingController _quarterlyRevenueController =
      TextEditingController(text: '100000');
  Map<String, dynamic>? _incomeTaxResult;
  double? _percentageTaxResult;

  // Records tab
  List<Map<String, double>> _quarterlyTotals = [];
  bool _loadingRecords = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logFeatureUsed('tax_bir');
    _tabController = TabController(length: 3, vsync: this);
    _calculateIncomeTax();
    _calculatePercentageTax();
    _loadQuarterlyRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _incomeController.dispose();
    _quarterlyRevenueController.dispose();
    super.dispose();
  }

  void _calculateIncomeTax() {
    final income = double.tryParse(
            _incomeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0;
    if (income >= 0) {
      setState(() {
        _incomeTaxResult = TaxReminderService.estimateIncomeTax(income);
      });
    }
  }

  void _calculatePercentageTax() {
    final revenue = double.tryParse(_quarterlyRevenueController.text
            .replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0;
    setState(() {
      _percentageTaxResult = TaxReminderService.estimatePercentageTax(revenue);
    });
  }

  Future<void> _loadQuarterlyRecords() async {
    setState(() => _loadingRecords = true);
    try {
      final expenses = await DBService.getExpenses();
      final now = DateTime.now();
      final yearStr = now.year.toString();

      final totals = [0.0, 0.0, 0.0, 0.0];
      for (final e in expenses) {
        if (!e.date.startsWith(yearStr)) continue;
        try {
          final month = DateTime.parse(e.date).month;
          final quarter = (month - 1) ~/ 3; // 0-indexed
          if (quarter >= 0 && quarter < 4) {
            totals[quarter] += e.amount;
          }
        } catch (_) {}
      }

      setState(() {
        _quarterlyTotals = List.generate(
          4,
          (i) => {'total': totals[i]},
        );
        _loadingRecords = false;
      });
    } catch (_) {
      setState(() => _loadingRecords = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BIR Tax Calculator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Deadlines', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Calculator', icon: Icon(Icons.calculate)),
            Tab(text: 'Records', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeadlinesTab(),
          _buildCalculatorTab(),
          _buildRecordsTab(),
        ],
      ),
    );
  }

  // ─── Tab 1: Deadlines ───────────────────────────────────────────────────────

  Widget _buildDeadlinesTab() {
    final deadlines = TaxReminderService.getUpcomingDeadlines();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const Text(
                    'Upcoming BIR Deadlines',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  InfoButton(
                    title: 'BIR Quarterly Deadlines',
                    body:
                        'Non-VAT registered taxpayers file BIR Form 2551Q (Percentage Tax) quarterly.\n\n'
                        'Q1 (Jan–Mar): due April 15\n'
                        'Q2 (Apr–Jun): due August 15\n'
                        'Q3 (Jul–Sep): due November 15\n'
                        'Q4 (Oct–Dec): due January 30\n\n'
                        'Annual ITR (1700/1701/1701A) is due April 15 of the following year.\n\n'
                        'Dates shown use simplified deadlines for reference. Always verify at bir.gov.ph.',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...deadlines.map((d) => _buildDeadlineCard(d)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _setReminders,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Set Reminders for All Deadlines'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineCard(Map<String, dynamic> deadline) {
    final name = deadline['name'] as String;
    final date = deadline['date'] as DateTime;
    final daysAway = deadline['daysAway'] as int;

    Color chipColor;
    Color cardBorderColor;
    IconData statusIcon;
    if (daysAway <= 7) {
      chipColor = Colors.red;
      cardBorderColor = Colors.red.shade200;
      statusIcon = Icons.warning_amber_rounded;
    } else if (daysAway <= 30) {
      chipColor = Colors.orange;
      cardBorderColor = Colors.orange.shade200;
      statusIcon = Icons.access_time_rounded;
    } else {
      chipColor = Colors.green;
      cardBorderColor = Colors.green.shade200;
      statusIcon = Icons.check_circle_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: chipColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(
                daysAway == 0
                    ? 'Due today'
                    : '$daysAway day${daysAway == 1 ? '' : 's'}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: chipColor,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setReminders() async {
    try {
      await TaxReminderService.scheduleAllTaxReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Tax reminders set! You\'ll be notified 30, 7, and 1 day before each deadline.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not set reminders: $e')),
        );
      }
    }
  }

  // ─── Tab 2: Calculator ──────────────────────────────────────────────────────

  Widget _buildCalculatorTab() {
    final income = double.tryParse(
            _incomeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Income Tax Section
          Row(
            children: [
              const Text(
                'Income Tax Estimator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InfoButton(
                title: 'Income Tax Rates (TRAIN Law)',
                body:
                    'Self-employed individuals earning ₱250,000 or less are exempt.\n\n'
                    '8% Flat Rate: Available for income ₱250,001–₱3,000,000. '
                    'Computed as 8% × (income − ₱250,000).\n\n'
                    'Graduated Rate: Standard brackets from 15% to 35%.\n\n'
                    'The lower of the two rates is used for income ₱250,001–₱3,000,000. '
                    'Income above ₱3,000,000 uses graduated rates only.\n\n'
                    'Consult a licensed CPA for official tax computations.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Annual Gross Income',
              prefixText: '₱ ',
              border: OutlineInputBorder(),
              helperText: 'Enter your total annual income',
            ),
            onChanged: (_) => _calculateIncomeTax(),
          ),
          const SizedBox(height: 16),
          if (_incomeTaxResult != null) _buildIncomeTaxResult(income),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 16),

          // Percentage Tax Section
          Row(
            children: [
              const Text(
                'Percentage Tax (2551Q)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InfoButton(
                title: 'Percentage Tax (BIR Form 2551Q)',
                body:
                    'Non-VAT registered taxpayers with annual gross sales/receipts '
                    'not exceeding ₱3,000,000 file quarterly percentage tax at 3%.\n\n'
                    'Enter your quarterly revenue to estimate the amount due.\n\n'
                    'File and pay at BIR RDO, eFPS, or eBIRForms.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quarterlyRevenueController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Quarterly Gross Revenue',
              prefixText: '₱ ',
              border: OutlineInputBorder(),
              helperText: 'Your total receipts for the quarter',
            ),
            onChanged: (_) => _calculatePercentageTax(),
          ),
          const SizedBox(height: 16),
          if (_percentageTaxResult != null) _buildPercentageTaxResult(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estimates only. Consult a licensed CPA or accredited tax agent for official tax advice.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTaxResult(double income) {
    final result = _incomeTaxResult!;
    final taxDue = result['taxDue'] as double;
    final method = result['method'] as String;
    final breakdown = result['breakdown'] as String;
    final effectiveRate = income > 0 ? (taxDue / income * 100) : 0.0;
    final monthly = taxDue / 12;

    Color methodColor;
    if (method == 'Tax Exempt') {
      methodColor = Colors.green;
    } else if (method == '8% Flat Rate') {
      methodColor = Colors.blue;
    } else {
      methodColor = Colors.deepOrange;
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimated Annual Tax Due',
                  style: TextStyle(fontSize: 14),
                ),
                Chip(
                  label: Text(
                    method,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: methodColor,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyService.format(taxDue),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: methodColor,
              ),
            ),
            const Divider(height: 24),
            _buildResultRow(
                'Effective Rate', '${effectiveRate.toStringAsFixed(2)}%',
                icon: Icons.percent),
            const SizedBox(height: 8),
            _buildResultRow(
                'Monthly Equivalent', CurrencyService.format(monthly),
                icon: Icons.calendar_month_outlined),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                breakdown,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageTaxResult() {
    final tax = _percentageTaxResult!;
    final revenue = double.tryParse(_quarterlyRevenueController.text
            .replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0;

    return Card(
      elevation: 3,
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quarterly Percentage Tax (3%)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyService.format(tax),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '3% × ${CurrencyService.format(revenue)}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
            ],
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ─── Tab 3: Records ─────────────────────────────────────────────────────────

  Widget _buildRecordsTab() {
    if (_loadingRecords) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final quarterLabels = [
      'Q1 (Jan–Mar)',
      'Q2 (Apr–Jun)',
      'Q3 (Jul–Sep)',
      'Q4 (Oct–Dec)'
    ];
    final currentQuarter = (now.month - 1) ~/ 3;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              'Quarterly Expenses — ${now.year}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            InfoButton(
              title: 'Quarterly Expense Records',
              body:
                  'Shows your total logged expenses per quarter for the current year.\n\n'
                  'Use these totals as a reference when computing your quarterly percentage tax deductions or '
                  'estimating deductible business expenses for your ITR.\n\n'
                  'Consult a licensed CPA to determine which expenses are allowable deductions.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Text(
            'Reference only — these are logged expenses, not official tax records.',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(4, (i) {
          final total = _quarterlyTotals[i]['total'] ?? 0.0;
          final isCurrent = i == currentQuarter;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isCurrent
                  ? BorderSide(color: Colors.deepOrange.shade300, width: 1.5)
                  : BorderSide.none,
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor:
                    isCurrent ? Colors.deepOrange : Colors.grey.shade200,
                child: Text(
                  'Q${i + 1}',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Text(
                quarterLabels[i],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: isCurrent
                  ? const Text('Current quarter',
                      style: TextStyle(fontSize: 11, color: Colors.deepOrange))
                  : null,
              trailing: Text(
                CurrencyService.format(total),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}
