// DB-layer tests for the tax_filings table.
// Uses an in-memory SQLite database via sqflite_common_ffi so no device is needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smartspend_app/services/db_service.dart';

Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final db = await factory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
        // Minimal schema: only the tax_filings table with the composite key.
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tax_filings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            period_label TEXT NOT NULL,
            deadline_date TEXT NOT NULL,
            filed_date TEXT,
            amount_paid REAL,
            reference_number TEXT,
            notes TEXT,
            UNIQUE(deadline_date, period_label)
          )
        ''');
        // settings table required by DBService internals
        await db.execute(
            'CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT)');
      },
    ),
  );
  return db;
}

void main() {
  group('tax_filings DB — insertTaxFiling / getTaxFilings', () {
    late Database db;

    setUp(() async {
      db = await _openTestDb();
      DBService.injectDatabase(db);
    });

    tearDown(() async {
      DBService.injectDatabase(null);
      await db.close();
    });

    test('inserts a single filing and retrieves it', () async {
      await DBService.insertTaxFiling({
        'period_label': 'Q1 Percentage Tax (2551Q)',
        'deadline_date': '2026-04-15',
        'filed_date': '2026-04-10',
        'amount_paid': 1500.0,
        'reference_number': 'REF001',
        'notes': null,
      });

      final rows = await DBService.getTaxFilings();
      expect(rows.length, 1);
      expect(rows.first['period_label'], 'Q1 Percentage Tax (2551Q)');
      expect(rows.first['deadline_date'], '2026-04-15');
      expect(rows.first['amount_paid'], 1500.0);
    });

    test(
        'two filings on the same date with different period_label both survive',
        () async {
      // This is the core regression: before the fix, the second insert would
      // silently delete the first because of a UNIQUE constraint on deadline_date.
      await DBService.insertTaxFiling({
        'period_label': 'Q1 Percentage Tax (2551Q)',
        'deadline_date': '2026-04-15',
        'filed_date': '2026-04-10',
        'amount_paid': 1500.0,
        'reference_number': null,
        'notes': null,
      });

      await DBService.insertTaxFiling({
        'period_label': 'Annual ITR (1700/1701/1701A)',
        'deadline_date': '2026-04-15',
        'filed_date': '2026-04-12',
        'amount_paid': 3000.0,
        'reference_number': null,
        'notes': null,
      });

      final rows = await DBService.getTaxFilings();
      expect(rows.length, 2,
          reason:
              'Both Apr-15 filings must survive; second should not overwrite the first');

      final labels = rows.map((r) => r['period_label'] as String).toSet();
      expect(labels.contains('Q1 Percentage Tax (2551Q)'), isTrue);
      expect(labels.contains('Annual ITR (1700/1701/1701A)'), isTrue);
    });

    test(
        'three April-15 filings for professional taxpayer all survive',
        () async {
      final april15 = '2026-04-15';
      final filings = [
        'Q1 Percentage Tax (2551Q)',
        'Q2 Quarterly ITR (1701Q)',
        'Annual ITR (1700/1701/1701A)',
      ];

      for (final label in filings) {
        await DBService.insertTaxFiling({
          'period_label': label,
          'deadline_date': april15,
          'filed_date': '2026-04-14',
          'amount_paid': 500.0,
          'reference_number': null,
          'notes': null,
        });
      }

      final rows = await DBService.getTaxFilings();
      expect(rows.length, 3,
          reason:
              'All three Apr-15 professional filings must survive as separate rows');
    });

    test('re-filing the same deadline+label replaces (not duplicates) the row',
        () async {
      await DBService.insertTaxFiling({
        'period_label': 'Q1 Percentage Tax (2551Q)',
        'deadline_date': '2026-04-15',
        'filed_date': '2026-04-10',
        'amount_paid': 1000.0,
        'reference_number': null,
        'notes': null,
      });

      // File the same period again (amended return scenario).
      await DBService.insertTaxFiling({
        'period_label': 'Q1 Percentage Tax (2551Q)',
        'deadline_date': '2026-04-15',
        'filed_date': '2026-04-11',
        'amount_paid': 1200.0,
        'reference_number': 'AMENDED',
        'notes': 'Amended return',
      });

      final rows = await DBService.getTaxFilings();
      expect(rows.length, 1,
          reason: 'Re-filing the same (date, label) should update, not add a row');
      expect(rows.first['amount_paid'], 1200.0);
      expect(rows.first['reference_number'], 'AMENDED');
    });

    test('getTaxFilings returns rows ordered by filed_date descending',
        () async {
      await DBService.insertTaxFiling({
        'period_label': 'Q1 Percentage Tax (2551Q)',
        'deadline_date': '2026-04-15',
        'filed_date': '2026-04-10',
        'amount_paid': 1000.0,
        'reference_number': null,
        'notes': null,
      });
      await DBService.insertTaxFiling({
        'period_label': 'Annual ITR (1700/1701/1701A)',
        'deadline_date': '2026-04-15',
        'filed_date': '2026-04-12',
        'amount_paid': 2000.0,
        'reference_number': null,
        'notes': null,
      });

      final rows = await DBService.getTaxFilings();
      expect(rows.length, 2);
      // Most-recently-filed first.
      expect(rows.first['filed_date'], '2026-04-12');
      expect(rows.last['filed_date'], '2026-04-10');
    });
  });
}
