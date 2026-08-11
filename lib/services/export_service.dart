import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';

class ExportService {
  static Future<void> exportToCSV(List<Expense> expenses) async {
    final now = DateTime.now();
    final fileFmt = DateFormat('yyyyMMdd_HHmmss');
    final displayFmt = DateFormat('MMM d, y HH:mm');

    final rows = <List<dynamic>>[
      [
        'ID',
        'Date',
        'Time',
        'Item Name',
        'Category',
        'Amount (PHP)',
        'Want/Need',
        'Tags',
        'Shop',
        'Payment Method',
        'Notes',
        'AI Generated',
        'Confidence'
      ],
      ...expenses.map((e) => [
            e.id ?? '',
            e.date,
            e.time ?? '',
            e.itemName,
            e.category,
            e.amount.toStringAsFixed(2),
            (e.isWant == true) ? 'Want' : 'Need',
            e.tags ?? '',
            e.shopName ?? '',
            e.paymentMethod ?? 'Cash',
            e.notes ?? '',
            e.aiGenerated ? 'Yes' : 'No',
            e.confidenceScore.toStringAsFixed(2),
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final fileName = 'SmartSpend_Expenses_${fileFmt.format(now)}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Smart Spend — Expenses Export ${displayFmt.format(now)}',
    );
  }
}
