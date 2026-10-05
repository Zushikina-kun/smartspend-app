import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/currency_service.dart';

/// Generic history bottom sheet — used for budget, goal, income, wallet history.
/// Each entry needs: delta (double), label (String), timestamp (String ISO),
/// optional: old_amount, new_amount, source, reason.
class HistorySheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData titleIcon;
  final List<Map<String, dynamic>> history;

  const HistorySheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.titleIcon,
    required this.history,
  });

  /// Show this sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData titleIcon,
    required List<Map<String, dynamic>> history,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => HistorySheet(
        title: title,
        subtitle: subtitle,
        titleIcon: titleIcon,
        history: history,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d, y h:mm a');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Icon(titleIcon, size: 22, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text("No history yet",
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          "Changes will appear here after your next update.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.45)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: history.length,
                    itemBuilder: (_, i) {
                      final h = history[i];
                      final delta = (h['delta'] as num?)?.toDouble() ?? 0;
                      final newAmt =
                          (h['new_amount'] as num?)?.toDouble();
                      final oldAmt =
                          (h['old_amount'] as num?)?.toDouble();
                      final action = h['action'] as String?;
                      final source = h['source'] as String? ?? 'manual';
                      final reason = h['reason'] as String?;
                      final ts = h['timestamp'] as String? ?? '';

                      final isDelete = action == 'delete';
                      final isPositive = delta > 0;
                      final isZero = delta == 0 && !isDelete;

                      final deltaColor = isDelete
                          ? Colors.red
                          : isZero
                              ? cs.onSurface.withValues(alpha: 0.4)
                              : isPositive
                                  ? Colors.green
                                  : Colors.red;

                      String timeLabel = ts;
                      try {
                        timeLabel =
                            fmt.format(DateTime.parse(ts).toLocal());
                      } catch (_) {}

                      // Source icon
                      final sourceIcon = source == 'ai'
                          ? '🤖'
                          : source == 'salary_split'
                              ? '📊'
                              : source == 'transfer'
                                  ? '↔️'
                                  : source == 'auto_deduct'
                                      ? '💳'
                                      : source == 'income'
                                          ? '💰'
                                          : source == 'income_allocation'
                                              ? '🎯'
                                              : source == 'round_up'
                                                  ? '🪙'
                                                  : isDelete
                                                      ? '🗑️'
                                                      : '✏️';

                      // Delta display
                      String deltaText;
                      if (isDelete) {
                        deltaText = 'Deleted';
                      } else if (isZero) {
                        deltaText = newAmt != null
                            ? 'Set to ${CurrencyService.format(newAmt)}'
                            : 'No change';
                      } else {
                        deltaText = isPositive
                            ? '+${CurrencyService.format(delta)}'
                            : '−${CurrencyService.format(delta.abs())}';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: deltaColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Text(sourceIcon,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                      deltaText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: deltaColor,
                                      ),
                                    ),
                                    if (newAmt != null && !isDelete) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '→ ${CurrencyService.format(newAmt)}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: cs.onSurface
                                                .withValues(alpha: 0.6)),
                                      ),
                                    ],
                                  ]),
                                  if (reason != null && reason.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(reason,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: cs.onSurface
                                                  .withValues(alpha: 0.55))),
                                    ),
                                  Text(timeLabel,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.4))),
                                ],
                              ),
                            ),
                            if (oldAmt != null && !isDelete)
                              Text(
                                CurrencyService.format(oldAmt),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurface.withValues(alpha: 0.35),
                                    decoration: TextDecoration.lineThrough),
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
