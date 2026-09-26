import 'package:flutter/material.dart';
import '../services/data_quality_service.dart';
import '../services/db_service.dart';
import '../services/event_bus.dart';

/// Hub → Data Quality — surfaces expense data issues with one-tap fixes.
class DataQualityScreen extends StatefulWidget {
  const DataQualityScreen({super.key});

  @override
  State<DataQualityScreen> createState() => _DataQualityScreenState();
}

class _DataQualityScreenState extends State<DataQualityScreen> {
  List<Map<String, dynamic>>? _issues;
  bool _loading = true;
  bool _fixing = false;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan({bool force = false}) async {
    setState(() => _loading = true);
    final issues = await DataQualityService.scan(force: force);
    if (mounted) setState(() { _issues = issues; _loading = false; });
  }

  Future<void> _fixOthers(Map<String, dynamic> issue) async {
    setState(() => _fixing = true);
    final ids = (issue['expense_ids'] as List).cast<int>();
    final suggestions = (issue['suggestions'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v as String));
    final fixed = await DataQualityService.fixOthersCategory(ids, suggestions);
    fireEvent(AppEvent.expenseChanged);
    if (mounted) {
      setState(() => _fixing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✓ Re-categorized $fixed expenses'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      _scan(force: true);
    }
  }

  Future<void> _openTransactions(List<int> ids) async {
    // Navigate to transactions with a filter — for now show a message
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Tap any expense in Transactions to edit it.'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Quality'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-scan',
            onPressed: _loading ? null : () => _scan(force: true),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _issues == null || _issues!.isEmpty
                ? _buildClean(cs)
                : _buildIssueList(cs),
      ),
    );
  }

  Widget _buildClean(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            const Text('All clean!',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'No data quality issues found in your expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueList(ColorScheme cs) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewPadding.bottom),
      itemCount: _issues!.length + 1, // +1 for header
      itemBuilder: (_, i) {
        if (i == 0) {
          final total = _issues!.fold<int>(
              0, (s, issue) => s + ((issue['count'] as int?) ?? 1));
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '$total issue${total == 1 ? '' : 's'} found — tap Fix to resolve each one.',
              style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.55)),
            ),
          );
        }
        final issue = _issues![i - 1];
        return _IssueCard(
          issue: issue,
          fixing: _fixing,
          onFix: () {
            final type = issue['type'] as String;
            if (type == 'others_cat') {
              _fixOthers(issue);
            } else {
              _openTransactions(
                  (issue['expense_ids'] as List).cast<int>());
            }
          },
        );
      },
    );
  }
}

class _IssueCard extends StatelessWidget {
  final Map<String, dynamic> issue;
  final bool fixing;
  final VoidCallback onFix;

  const _IssueCard(
      {required this.issue, required this.fixing, required this.onFix});

  static const _typeIcons = {
    'zero_time': Icons.access_time_outlined,
    'case_dup': Icons.text_fields_outlined,
    'others_cat': Icons.category_outlined,
    'round_amount': Icons.monetization_on_outlined,
  };
  static const _typeColors = {
    'zero_time': Colors.blue,
    'case_dup': Colors.purple,
    'others_cat': Colors.orange,
    'round_amount': Colors.red,
  };
  static const _fixLabels = {
    'zero_time': 'View',
    'case_dup': 'View',
    'others_cat': 'Fix All',
    'round_amount': 'View',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final type = issue['type'] as String;
    final color = _typeColors[type] ?? cs.primary;
    final icon = _typeIcons[type] ?? Icons.warning_amber_outlined;
    final fixLabel = _fixLabels[type] ?? 'View';
    final examples = issue['examples'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                issue['title'] as String,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            issue['description'] as String,
            style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.6),
                height: 1.4),
          ),
          if (examples != null && examples.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...examples.take(2).map((ex) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('• $ex',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic)),
                )),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: fixing && fixLabel == 'Fix All'
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : FilledButton.tonal(
                    onPressed: fixing ? null : onFix,
                    style: FilledButton.styleFrom(
                      backgroundColor: color.withValues(alpha: 0.12),
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(fixLabel,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
          ),
        ],
      ),
    );
  }
}
