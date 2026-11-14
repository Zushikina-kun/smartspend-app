import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';

/// Government Contributions Tracker — SSS, PhilHealth, Pag-IBIG
/// Tracks year-to-date contributions for Filipino government programs
class GovContributionsScreen extends StatefulWidget {
  const GovContributionsScreen({super.key});

  @override
  State<GovContributionsScreen> createState() => _GovContributionsScreenState();
}

class _GovContributionsScreenState extends State<GovContributionsScreen> {
  Map<String, double> _ytdTotals = {};
  bool _loading = true;
  int _selectedYear = DateTime.now().year;

  // Simple pension calculator inputs
  final TextEditingController _yearsCtrl = TextEditingController();
  final TextEditingController _salaryCtrl = TextEditingController();
  double? _estimatedPension;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _yearsCtrl.dispose();
    _salaryCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gov Contributions'),
        actions: [
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
                    fontWeight:
                        year == _selectedYear ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                    style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.6)),
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
                ],
              ),
            ),
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
              Icon(Icons.open_in_new, size: 18, color: cs.onSurface.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
