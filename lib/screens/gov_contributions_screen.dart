import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/analytics_service.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/egov/philhealth_service.dart';
import '../widgets/info_button.dart';

/// Government Contributions Tracker — SSS, PhilHealth, Pag-IBIG
/// Tracks year-to-date contributions for Filipino government programs
class GovContributionsScreen extends StatefulWidget {
  const GovContributionsScreen({super.key});

  @override
  State<GovContributionsScreen> createState() => _GovContributionsScreenState();
}

class _GovContributionsScreenState extends State<GovContributionsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, double> _ytdTotals = {};
  bool _loading = true;
  int _selectedYear = DateTime.now().year;

  // Simple pension calculator inputs
  final TextEditingController _yearsCtrl = TextEditingController();
  final TextEditingController _salaryCtrl = TextEditingController();
  double? _estimatedPension;

  // PhilHealth calculator inputs
  final TextEditingController _phSalaryCtrl = TextEditingController();
  String _employmentType = 'employed';
  Map<String, dynamic>? _premiumBreakdown;
  Map<String, dynamic>? _mockCoverage;

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logFeatureUsed('gov_contributions');
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _mockCoverage = PhilHealthService.generateMockCoverageInfo();
  }

  @override
  void dispose() {
    _yearsCtrl.dispose();
    _salaryCtrl.dispose();
    _phSalaryCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = await DBService.getDB();

    // Query YTD totals for each category
    final sss = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM expenses 
      WHERE category = 'SSS' 
      AND strftime('%Y', date) = ?
    ''', [_selectedYear.toString()]);

    final philhealth = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM expenses 
      WHERE category = 'PhilHealth' 
      AND strftime('%Y', date) = ?
    ''', [_selectedYear.toString()]);

    final pagibig = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM expenses 
      WHERE category = 'Pag-IBIG' 
      AND strftime('%Y', date) = ?
    ''', [_selectedYear.toString()]);

    setState(() {
      _ytdTotals = {
        'SSS': (sss.first['total'] as num).toDouble(),
        'PhilHealth': (philhealth.first['total'] as num).toDouble(),
        'Pag-IBIG': (pagibig.first['total'] as num).toDouble(),
      };
      _loading = false;
    });
  }

  void _calculatePension() {
    final years = int.tryParse(_yearsCtrl.text) ?? 0;
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;

    if (years < 10 || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid years (≥10) and monthly salary'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Simplified SSS pension formula (approximation)
    // Actual formula is complex, this is just an educational estimate
    double basePension = salary * 0.4; // ~40% of average monthly salary
    if (years > 10) {
      basePension += (years - 10) * 50; // ₱50 per year beyond 10 years
    }

    setState(() => _estimatedPension = basePension.clamp(1000, 20000));
  }

  void _calculatePhilHealthPremium() {
    final salary = double.tryParse(_phSalaryCtrl.text) ?? 0;

    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid monthly salary'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _premiumBreakdown =
          PhilHealthService.getPremiumBreakdown(salary, _employmentType);
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Feature #2: Export Government Contributions to CSV
  Future<void> _exportCSV() async {
    setState(() => _loading = true);
    try {
      final db = await DBService.getDB();

      // Query all gov contributions for selected year
      final rows = await db.rawQuery('''
        SELECT 
          date,
          category,
          amount,
          merchant,
          notes
        FROM expenses 
        WHERE category IN ('SSS', 'PhilHealth', 'Pag-IBIG')
        AND strftime('%Y', date) = ?
        ORDER BY date ASC
      ''', [_selectedYear.toString()]);

      if (rows.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No contributions found for this year'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      // Build CSV
      final csvData = [
        ['Date', 'Agency', 'Amount', 'Merchant', 'Notes'],
        ...rows.map((r) => [
              r['date'],
              r['category'],
              r['amount'].toString(),
              r['merchant'] ?? '',
              r['notes'] ?? '',
            ]),
      ];

      final csv = const ListToCsvConverter().convert(csvData);

      // Write to file
      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}/SmartSpend_Gov_Contributions_$_selectedYear.csv');
      await file.writeAsString(csv);

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Government Contributions $_selectedYear',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${rows.length} contributions'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.govContributionsScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _loading ? null : _exportCSV,
            tooltip: 'Export to CSV',
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.calendar_today, color: cs.onSurface),
            tooltip: 'Select Year',
            onSelected: (year) {
              setState(() => _selectedYear = year);
              _loadData();
            },
            itemBuilder: (ctx) => List.generate(5, (i) {
              final year = DateTime.now().year - i;
              return PopupMenuItem(
                value: year,
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    fontWeight: year == _selectedYear
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'YTD Tracker', icon: Icon(Icons.bar_chart, size: 20)),
            Tab(
                text: 'PhilHealth Calculator',
                icon: Icon(Icons.calculate, size: 20)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // YTD Tracker Tab
                _buildYTDTrackerTab(cs),
                // PhilHealth Calculator Tab
                _buildPhilHealthCalculatorTab(cs),
              ],
            ),
    );
  }

  Widget _buildResearchFindingsSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.science_outlined, color: cs.primary),
              const SizedBox(width: 8),
              const Text(
                'Research Findings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'SmartSpend Capstone Study — SY 2025–2026',
            style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.55),
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),

          // ── SUS Score ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.primary.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Usability Scale (SUS)',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bangor et al. (2009): OK / Marginal High',
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurface.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'N = 30 respondents (SD 17.58) — final study',
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Text(
                      '61.83',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: TextStyle(
                          fontSize: 13, color: cs.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Methodology ─────────────────────────────────────────────────
          _researchSection(
            cs,
            icon: Icons.people_alt_outlined,
            title: 'Methodology',
            body:
                'Mixed-methods design with N = 30 Filipino respondents. Participants '
                'completed tasks using SmartSpend v3.1.1 on Android devices, then filled '
                'out the 10-item SUS questionnaire. Two respondent groups: parents (n = 10) '
                'and young professionals (n = 20).',
          ),
          const SizedBox(height: 10),

          // ── Key Findings ─────────────────────────────────────────────────
          _researchSection(
            cs,
            icon: Icons.bar_chart_outlined,
            title: 'Key Findings',
            body: null,
            children: [
              _findingItem(cs, '📱',
                  'Perceived usefulness was high — respondents rated receipt scanning and AI-assisted categorization as the most valuable features.'),
              _findingItem(cs, '📊',
                  'SUS score of 61.83 places the system in the "OK" band, indicating the interface is functional but has room for improvement in learnability.'),
              _findingItem(cs, '💡',
                  'Young professionals scored usability higher than the parent group, suggesting onboarding for less tech-familiar users needs strengthening.'),
            ],
          ),
          const SizedBox(height: 10),

          // ── Implemented Recommendations ──────────────────────────────────
          _researchSection(
            cs,
            icon: Icons.check_circle_outline,
            title: 'Implemented Recommendations',
            body: null,
            children: [
              _recItem(cs, 'Simplified onboarding with contextual tooltips'),
              _recItem(cs, 'Real-time DOE fuel price data feed'),
              _recItem(cs, 'PSA retail commodity price feed'),
              _recItem(cs,
                  'Government contribution tracker (SSS, PhilHealth, Pag-IBIG)'),
              _recItem(cs, 'AI financial advisor with PESO model guidance'),
              _recItem(
                  cs, 'Price Intelligence for personal receipt-based tracking'),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            'Full manuscript: Lorma Colleges, College of Computer Studies, 2026.',
            style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: cs.onSurface.withOpacity(0.45)),
          ),
        ],
      ),
    );
  }

  Widget _researchSection(
    ColorScheme cs, {
    required IconData icon,
    required String title,
    String? body,
    List<Widget>? children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        if (body != null)
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(body,
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.75),
                    height: 1.4)),
          ),
        if (children != null) ...children,
      ],
    );
  }

  Widget _findingItem(ColorScheme cs, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.75),
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _recItem(ColorScheme cs, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.75),
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildYTDTrackerTab(ColorScheme cs) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            '$_selectedYear Government Contributions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your SSS, PhilHealth, and Pag-IBIG contributions',
            style:
                TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),

          // SSS Card
          _buildContributionCard(
            context: context,
            title: 'SSS',
            subtitle: 'Social Security System',
            amount: _ytdTotals['SSS'] ?? 0,
            color: Colors.blue,
            icon: Icons.security,
            url: 'https://www.sss.gov.ph',
          ),
          const SizedBox(height: 12),

          // PhilHealth Card
          _buildContributionCard(
            context: context,
            title: 'PhilHealth',
            subtitle: 'Philippine Health Insurance',
            amount: _ytdTotals['PhilHealth'] ?? 0,
            color: Colors.green,
            icon: Icons.local_hospital,
            url: 'https://www.philhealth.gov.ph',
          ),
          const SizedBox(height: 12),

          // Pag-IBIG Card
          _buildContributionCard(
            context: context,
            title: 'Pag-IBIG',
            subtitle: 'Home Development Mutual Fund',
            amount: _ytdTotals['Pag-IBIG'] ?? 0,
            color: Colors.orange,
            icon: Icons.home,
            url: 'https://www.pagibigfund.gov.ph',
          ),
          const SizedBox(height: 24),

          // Total Summary
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total YTD Contributions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyService.format(
                      (_ytdTotals['SSS'] ?? 0) +
                          (_ytdTotals['PhilHealth'] ?? 0) +
                          (_ytdTotals['Pag-IBIG'] ?? 0),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // SSS Pension Calculator
          Card(
            color: cs.primaryContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calculate, size: 20, color: cs.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'SSS Pension Estimator',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simple calculator for estimated monthly pension',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _yearsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Years Contributed',
                            hintText: 'e.g., 20',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _salaryCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Avg Monthly Salary',
                            hintText: '15000',
                            prefixText: '${CurrencyService.symbol} ',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _calculatePension,
                      icon: const Icon(Icons.calculate, size: 18),
                      label: const Text('Calculate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                      ),
                    ),
                  ),
                  if (_estimatedPension != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Est. Monthly Pension:',
                            style: TextStyle(fontSize: 13),
                          ),
                          Text(
                            CurrencyService.format(_estimatedPension!),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '⚠️ This is a simplified estimate. Visit SSS.gov.ph for accurate calculations.',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.error,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: cs.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Log your contributions as expenses using the "SSS", "PhilHealth", or "Pag-IBIG" categories. They will automatically appear here.',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Research Findings — SUS 61.83, N=30
          _buildResearchFindingsSection(context),
        ],
      ),
    );
  }

  Widget _buildPhilHealthCalculatorTab(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.local_hospital, size: 28, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PhilHealth Premium Calculator',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Based on 2026 PhilHealth rates',
                    style: TextStyle(
                        fontSize: 13, color: cs.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            InfoButton(
              title: 'PhilHealth Contribution Rates',
              body: 'PhilHealth 2026 rates: 5% of monthly basic salary. '
                  'Maximum contribution is ₱5,000 (salary cap at ₱100,000). '
                  'For employed members, contributions are split 50-50 between employee and employer. '
                  'Self-employed and voluntary members pay 100% of the contribution. '
                  'Verify your actual coverage at philhealth.gov.ph portal.',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Calculator Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calculate Monthly Premium',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phSalaryCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Monthly Basic Salary',
                    hintText: 'e.g., 30000',
                    prefixText: '${CurrencyService.symbol} ',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _employmentType,
                  decoration: const InputDecoration(
                    labelText: 'Employment Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'employed',
                      child: Text('Employed (50-50 split)'),
                    ),
                    DropdownMenuItem(
                      value: 'self-employed',
                      child: Text('Self-Employed (100% member)'),
                    ),
                    DropdownMenuItem(
                      value: 'voluntary',
                      child: Text('Voluntary (100% member)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _employmentType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _calculatePhilHealthPremium,
                    icon: const Icon(Icons.calculate, size: 18),
                    label: const Text('Calculate Premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Premium Breakdown Result
        if (_premiumBreakdown != null) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            color: Colors.green.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Premium Breakdown',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      if (_premiumBreakdown!['isMaxCap'] as bool)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Max cap reached',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumRow(
                    'Total Premium',
                    _premiumBreakdown!['totalPremium'] as double,
                    Colors.green,
                    isBold: true,
                  ),
                  const Divider(height: 24),
                  _buildPremiumRow(
                    'Employee Share',
                    _premiumBreakdown!['employeeShare'] as double,
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildPremiumRow(
                    'Employer Share',
                    _premiumBreakdown!['employerShare'] as double,
                    Colors.purple,
                  ),
                  if (_premiumBreakdown!['isMaxCap'] as bool) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Maximum contribution reached at ₱100,000 salary',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
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
        ],

        const SizedBox(height: 24),

        // Coverage Verification Card
        if (_mockCoverage != null) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Coverage Verification',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 14, color: Colors.green.shade700),
                            const SizedBox(width: 4),
                            Text(
                              _mockCoverage!['isActive'] as bool
                                  ? 'Active'
                                  : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Membership Type',
                      _mockCoverage!['membershipType'] as String),
                  const SizedBox(height: 8),
                  _buildInfoRow('Last Contribution',
                      _mockCoverage!['lastContribution'] as String),
                  const SizedBox(height: 16),
                  const Text(
                    'Available Benefits',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...(_mockCoverage!['availableBenefits'] as List<String>)
                      .map((benefit) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildBenefitRow(benefit, cs),
                          )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: cs.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ This is mock data for demonstration. Verify your real coverage at philhealth.gov.ph',
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Link to PhilHealth Portal
        Card(
          elevation: 1,
          child: InkWell(
            onTap: () => _launchURL('https://www.philhealth.gov.ph'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.open_in_new, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visit PhilHealth Portal',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Check your real coverage and contribution history',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: cs.onSurface.withOpacity(0.4)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumRow(String label, double amount, Color color,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          CurrencyService.format(amount),
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(String benefit, ColorScheme cs) {
    final descriptions = PhilHealthService.getBenefitDescriptions();
    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(benefit, style: const TextStyle(fontSize: 13)),
        ),
        InfoButton(
          title: benefit,
          body: descriptions[benefit] ?? 'No description available.',
          size: 18,
        ),
      ],
    );
  }

  Widget _buildContributionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double amount,
    required Color color,
    required IconData icon,
    required String url,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyService.format(amount),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new,
                  size: 18, color: cs.onSurface.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
