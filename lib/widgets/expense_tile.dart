import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/currency_service.dart';
import '../services/db_service.dart';

const _categoryIcons = <String, IconData>{
  'Food': Icons.fastfood,
  'Transportation': Icons.directions_car,
  'Bills': Icons.receipt_long,
  'Shopping': Icons.shopping_bag,
  'Entertainment': Icons.movie,
  'Health': Icons.local_hospital_outlined,
  'Education': Icons.school_outlined,
  'Others': Icons.category,
  'Transport': Icons.directions_car, // legacy
  'School': Icons.school_outlined,
  'Personal Care': Icons.face_outlined,
};

const _categoryColors = <String, Color>{
  'Food': Color(0xFFFF6B35),
  'Transportation': Color(0xFF0066FF),
  'Bills': Color(0xFFFF9500),
  'Shopping': Color(0xFF7C3AED),
  'Entertainment': Color(0xFFE91E8C),
  'Health': Color(0xFF00BCD4),
  'Education': Color(0xFF4CAF50),
  'Others': Color(0xFF6B7280),
  'Transport': Color(0xFF0066FF), // legacy
  'School': Color(0xFF4CAF50),
  'Personal Care': Color(0xFFE91E8C),
};

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final bool isSelected;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onDelete,
    this.onEdit,
    this.onLongPress,
    this.onTap,
    this.isSelected = false,
  });

  void _confirmDelete(BuildContext context) {
    if (onDelete == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger
        .showSnackBar(
          SnackBar(
            content: Text('Deleted "${expense.itemName}"'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {},
            ),
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        onDelete!();
      }
    });
  }

  void _showPhoto(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = _categoryIcons[expense.category] ?? Icons.category;
    final color = _categoryColors[expense.category] ??
        Theme.of(context).colorScheme.primary;

    String dateStr = '';
    try {
      final date = DateTime.parse(expense.date);
      dateStr = DateFormat('MMM d').format(date);
    } catch (_) {
      dateStr = expense.date.length >= 10
          ? expense.date.substring(0, 10)
          : expense.date;
    }

    final subtitle = [
      expense.category,
      if (expense.shopName != null && expense.shopName!.isNotEmpty)
        expense.shopName!,
      dateStr,
      if (expense.isWant == true) '🏷️ Want',
      if (expense.splitWith != null && expense.splitWith!.isNotEmpty)
        '🤝 Split w/ ${expense.splitWith}',
    ].join('  •  ');

    Color? confidenceColor;
    if (expense.aiGenerated && expense.confidenceScore < 0.7) {
      confidenceColor = Colors.orange;
    }

    final hasPhoto = expense.photoPath != null && expense.photoPath!.isNotEmpty;

    return ListTile(
      selected: isSelected,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      onTap: onTap,
      onLongPress: onLongPress != null
          ? () {
              // UX-11: Haptic feedback on long press
              HapticFeedback.mediumImpact();
              onLongPress!();
            }
          : null,
      leading: Stack(
        children: [
          // Photo thumbnail if available, otherwise category icon
          if (hasPhoto)
            GestureDetector(
              onTap: () => _showPhoto(context, expense.photoPath!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(expense.photoPath!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ),
              ),
            )
          else
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
          if (confidenceColor != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: confidenceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
          if (hasPhoto)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: const Icon(Icons.photo, size: 8, color: Colors.white),
              ),
            ),
        ],
      ),
      title: Text(
        expense.itemName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(subtitle, style: const TextStyle(fontSize: 11)),
          if (expense.tags != null && expense.tags!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Wrap(
                spacing: 4,
                children: expense.tags!
                    .split(',')
                    .where((t) => t.isNotEmpty)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                  fontSize: 9,
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "-${CurrencyService.format(expense.amount)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    if (expense.paymentMethod != null &&
                        expense.paymentMethod != 'Cash')
                      Text(expense.paymentMethod!,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                  ],
                ),
                PopupMenuButton<String>(
                  icon:
                      const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  onSelected: (val) async {
                    if (val == 'edit' && onEdit != null) onEdit!();
                    if (val == 'delete') _confirmDelete(context);
                    // UX-12: Additional options
                    if (val == 'duplicate') {
                      HapticFeedback.lightImpact();
                      final data = expense.toMap()
                        ..remove('id')
                        ..remove('updated_at');
                      data['date'] =
                          DateTime.now().toIso8601String().substring(0, 10);
                      data['time'] =
                          DateTime.now().toIso8601String().substring(11, 19);
                      await DBService.insertExpense(data);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Expense duplicated ✓"),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ));
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('Duplicate')
                          ],
                        )),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
    );
  }
}
