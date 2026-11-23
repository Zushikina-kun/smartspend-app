import 'dart:io' as io;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import 'db_service.dart';

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
    final fileName = 'SmartSpend_Expenses_${fileFmt.format(now)}.csv';

    if (kIsWeb) {
      triggerWebDownload(csv, fileName);
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = io.File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Smart Spend — Expenses Export ${displayFmt.format(now)}',
    );
  }

  /// Fetches all expenses, generates a full transaction CSV, and shares it.
  static Future<void> exportTransactionsToCSV() async {
    final expenses = await DBService.getExpenses();
    await exportToCSV(expenses);
  }

  /// Generates a summary CSV grouped by Month + Category and shares it.
  ///
  /// Pass [expenses] to export a pre-filtered list (e.g. the current period
  /// shown on-screen). When omitted, all expenses are fetched and exported.
  static Future<void> exportSummaryToCSV({List<Expense>? expenses}) async {
    final now = DateTime.now();
    final fileFmt = DateFormat('yyyyMMdd_HHmmss');
    final displayFmt = DateFormat('MMM d, y HH:mm');

    final resolvedExpenses = expenses ?? await DBService.getExpenses();

    // Group by "yyyy-MM" (taken from stored date string) + category
    final Map<String, Map<String, _SummaryEntry>> grouped = {};
    for (final e in resolvedExpenses) {
      final month = e.date.length >= 7 ? e.date.substring(0, 7) : e.date;
      grouped.putIfAbsent(month, () => {});
      final entry = grouped[month]!.putIfAbsent(
          e.category, () => _SummaryEntry(month: month, category: e.category));
      entry.totalAmount += e.amount;
      entry.transactionCount += 1;
    }

    // Sort months descending, categories ascending
    final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final rows = <List<dynamic>>[
      ['Month', 'Category', 'TotalAmount', 'TransactionCount'],
      for (final month in months)
        for (final category in (grouped[month]!.keys.toList()..sort()))
          [
            month,
            category,
            grouped[month]![category]!.totalAmount.toStringAsFixed(2),
            grouped[month]![category]!.transactionCount,
          ],
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final fileName = 'SmartSpend_Summary_${fileFmt.format(now)}.csv';

    if (kIsWeb) {
      triggerWebDownload(csv, fileName);
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = io.File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Smart Spend — Summary Export ${displayFmt.format(now)}',
    );
  }
}

class _SummaryEntry {
  final String month;
  final String category;
  double totalAmount = 0;
  int transactionCount = 0;

  _SummaryEntry({required this.month, required this.category});
}
