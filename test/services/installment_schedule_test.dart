// Tests for installment schedule DB methods.
// Covers generateScheduleForPlan() date arithmetic and
// recordPayment() overpayment carry-forward logic.
//
// Uses sqflite_common_ffi to run against an in-memory SQLite database via
// DBService.injectDatabase().

// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smartspend_app/services/db_service.dart';

/// Opens a fresh in-memory database and creates the minimum schema required
/// by the methods under test.
Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final db = await factory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE installment_plans(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            provider TEXT,
            total_amount REAL NOT NULL,
            monthly_payment REAL NOT NULL,
            months_total INTEGER NOT NULL,
            months_paid INTEGER DEFAULT 0,
            due_day INTEGER NOT NULL DEFAULT 5,
            interest_rate REAL,
            start_date TEXT NOT NULL,
            category TEXT DEFAULT 'Bills',
            notes TEXT,
            created_at TEXT,
            credit_balance REAL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE installment_schedule(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plan_id INTEGER NOT NULL,
            period_index INTEGER NOT NULL,
            due_date TEXT NOT NULL,
            amount_due REAL NOT NULL,
            amount_paid REAL NOT NULL DEFAULT 0,
            credit_applied REAL NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'pending',
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE installment_payments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plan_id INTEGER NOT NULL,
            schedule_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            payment_date TEXT NOT NULL,
            payment_method TEXT,
            notes TEXT,
            expense_id INTEGER,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            time TEXT,
            payment_method TEXT DEFAULT 'Cash',
            shop_name TEXT,
            location TEXT,
            notes TEXT,
            ai_generated INTEGER DEFAULT 1,
            confidence_score REAL DEFAULT 1.0,
            updated_at TEXT,
            photo_path TEXT,
            is_want INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    ),
  );
  return db;
}

/// Insert a plan into the test DB and return its row map (with id).
Future<Map<String, dynamic>> _insertPlan(
  Database db, {
  required String startDate,
  required int dueDay,
  required int monthsTotal,
  double monthlyPayment = 2200.0,
}) async {
  final id = await db.insert('installment_plans', {
    'title': 'Test Plan',
    'total_amount': monthlyPayment * monthsTotal,
    'monthly_payment': monthlyPayment,
    'months_total': monthsTotal,
    'months_paid': 0,
    'due_day': dueDay,
    'start_date': startDate,
    'category': 'Bills',
    'created_at': DateTime.now().toIso8601String(),
  });
  final rows =
      await db.query('installment_plans', where: 'id = ?', whereArgs: [id]);
  return rows.first;
}

void main() {
  group('generateScheduleForPlan — date arithmetic', () {
    late Database db;

    setUp(() async {
      db = await _openTestDb();
      DBService.injectDatabase(db);
    });

    tearDown(() async {
      DBService.injectDatabase(null);
      await db.close();
    });

    test('generates exactly months_total rows', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-15', dueDay: 5, monthsTotal: 6);
      await DBService.generateScheduleForPlan(plan);
      final rows = await DBService.getScheduleForPlan(plan['id'] as int);
      expect(rows.length, 6);
    });

    test('period_index is 1-based and sequential', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-15', dueDay: 5, monthsTotal: 3);
      await DBService.generateScheduleForPlan(plan);
      final rows = await DBService.getScheduleForPlan(plan['id'] as int);
      expect(rows.map((r) => r['period_index']).toList(), [1, 2, 3]);
    });

    test('due dates use due_day in successive months', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-01', dueDay: 15, monthsTotal: 3);
      await DBService.generateScheduleForPlan(plan);
      final rows = await DBService.getScheduleForPlan(plan['id'] as int);
      expect(rows[0]['due_date'], '2024-01-15');
      expect(rows[1]['due_date'], '2024-02-15');
      expect(rows[2]['due_date'], '2024-03-15');
    });

    test('year/month rollover — start in November crosses into next year',
        () async {
      final plan = await _insertPlan(db,
          startDate: '2024-11-01', dueDay: 10, monthsTotal: 4);
      await DBService.generateScheduleForPlan(plan);
      final rows = await DBService.getScheduleForPlan(plan['id'] as int);
      expect(rows[0]['due_date'], '2024-11-10');
      expect(rows[1]['due_date'], '2024-12-10');
      expect(rows[2]['due_date'], '2025-01-10');
      expect(rows[3]['due_date'], '2025-02-10');
    });

    test('year rollover — start in December, due_day 31', () async {
      // December has 31 days — no clamping needed.
      // January has 31, February has 28/29 — February must clamp.
      final plan = await _insertPlan(db,
          startDate: '2024-12-01', dueDay: 31, monthsTotal: 3);
      await DBService.generateScheduleForPlan(plan);
      final rows = await DBService.getScheduleForPlan(plan['id'] as int);
      // Dec 31 — valid
      expect(rows[0]['due_date'], '2024-12-31');
      // Jan 31 — valid
      expect(rows[1]['due_date'], '2025-01-31');
      // Feb 31 → clamp to Feb 28, 2025 (2025 is not a leap year)
      expect(rows[2]['due_date'], '2025-02-28');
    });

    test('February clamping — leap year 2024', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-01', dueDay: 31, monthsTotal: 2);
      await DBService.generateScheduleForPlan(plan);
      final rows = await DBService.getScheduleForPlan(plan['id'] as int);
      // Jan 31 — valid
      expect(rows[0]['due_date'], '2024-01-31');
      // Feb 31 → clamp to Feb 29, 2024 (2024 is a leap year)
      expect(rows[1]['due_date'], '2024-02-29');
    });

    test('all initial rows have status=pending and amount_paid=0', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-03-01', dueDay: 5, monthsTotal: 3);
      await DBService.generateScheduleForPlan(plan);
      final rows = await DBService.getScheduleForPlan(plan['id'] as int);
      for (final row in rows) {
        expect(row['status'], 'pending');
        expect((row['amount_paid'] as num).toDouble(), 0.0);
        expect((row['credit_applied'] as num).toDouble(), 0.0);
      }
    });

    test('idempotent — second call does not add rows', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-01', dueDay: 5, monthsTotal: 3);
      await DBService.generateScheduleForPlan(plan);
      await DBService.generateScheduleForPlan(plan); // second call
      final rows = await DBService.getScheduleForPlan(plan['id'] as int);
      expect(rows.length, 3);
    });
  });

  group('recordPayment — overpayment credit carry-forward', () {
    late Database db;

    setUp(() async {
      db = await _openTestDb();
      DBService.injectDatabase(db);
    });

    tearDown(() async {
      DBService.injectDatabase(null);
      await db.close();
    });

    test('exact payment marks period paid, no credit_balance', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-01',
          dueDay: 5,
          monthsTotal: 3,
          monthlyPayment: 2200.0);
      await DBService.generateScheduleForPlan(plan);
      final planId = plan['id'] as int;
      final first = await DBService.getPendingPeriod(planId);

      await DBService.recordPayment(planId, first!['id'] as int, 2200.0);

      final updated = (await db.query('installment_plans',
              where: 'id = ?', whereArgs: [planId]))
          .first;
      expect(updated['credit_balance'], 0.0);

      final firstRow = (await db.query('installment_schedule',
              where: 'id = ?', whereArgs: [first['id']]))
          .first;
      expect(firstRow['status'], 'paid');
    });

    test('partial payment marks period partial', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-01',
          dueDay: 5,
          monthsTotal: 3,
          monthlyPayment: 2200.0);
      await DBService.generateScheduleForPlan(plan);
      final planId = plan['id'] as int;
      final first = await DBService.getPendingPeriod(planId);

      await DBService.recordPayment(planId, first!['id'] as int, 1000.0);

      final firstRow = (await db.query('installment_schedule',
              where: 'id = ?', whereArgs: [first['id']]))
          .first;
      expect(firstRow['status'], 'partial');
      expect((firstRow['amount_paid'] as num).toDouble(), 1000.0);
    });

    test('overpayment carries surplus to next period as credit_applied',
        () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-01',
          dueDay: 5,
          monthsTotal: 3,
          monthlyPayment: 2200.0);
      await DBService.generateScheduleForPlan(plan);
      final planId = plan['id'] as int;
      final first = await DBService.getPendingPeriod(planId);

      // Pay 2500 against 2200 — 300 surplus
      await DBService.recordPayment(planId, first!['id'] as int, 2500.0);

      // Next period should have credit_applied = 300
      final schedule = await DBService.getScheduleForPlan(planId);
      final secondRow = schedule[1];
      expect((secondRow['credit_applied'] as num).toDouble(), closeTo(300.0, 0.01));
      expect(secondRow['status'], 'pending');

      // Plan credit_balance should be 0 (surplus fully applied to next period)
      final updatedPlan = (await db.query('installment_plans',
              where: 'id = ?', whereArgs: [planId]))
          .first;
      expect((updatedPlan['credit_balance'] as num).toDouble(),
          closeTo(0.0, 0.01));
    });

    test('large overpayment propagates credit across multiple periods',
        () async {
      // Pay 7000 against 3 periods of 2200 each.
      // Period 1 paid: 7000, effective_due=2200 → surplus=4800
      // Period 2 credit_applied=2200 → remaining=2600
      // Period 3 credit_applied=2200 → remaining=400
      // credit_balance = 400
      final plan = await _insertPlan(db,
          startDate: '2024-01-01',
          dueDay: 5,
          monthsTotal: 3,
          monthlyPayment: 2200.0);
      await DBService.generateScheduleForPlan(plan);
      final planId = plan['id'] as int;
      final first = await DBService.getPendingPeriod(planId);

      await DBService.recordPayment(planId, first!['id'] as int, 7000.0);

      final schedule = await DBService.getScheduleForPlan(planId);
      // Period 1 should be paid
      expect(schedule[0]['status'], 'paid');
      // Period 2 should have full credit applied
      expect((schedule[1]['credit_applied'] as num).toDouble(),
          closeTo(2200.0, 0.01));
      // Period 3 should also have full credit applied
      expect((schedule[2]['credit_applied'] as num).toDouble(),
          closeTo(2200.0, 0.01));

      // Remaining surplus (7000 - 2200 - 2200 - 2200 = 400) in credit_balance
      final updatedPlan = (await db.query('installment_plans',
              where: 'id = ?', whereArgs: [planId]))
          .first;
      expect((updatedPlan['credit_balance'] as num).toDouble(),
          closeTo(400.0, 0.01));
    });

    test('getPendingPeriod returns null when all periods are paid', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-01',
          dueDay: 5,
          monthsTotal: 1,
          monthlyPayment: 2200.0);
      await DBService.generateScheduleForPlan(plan);
      final planId = plan['id'] as int;
      final first = await DBService.getPendingPeriod(planId);

      await DBService.recordPayment(planId, first!['id'] as int, 2200.0);

      final noPending = await DBService.getPendingPeriod(planId);
      expect(noPending, isNull);
    });

    test('months_paid is incremented after a period is paid', () async {
      final plan = await _insertPlan(db,
          startDate: '2024-01-01',
          dueDay: 5,
          monthsTotal: 3,
          monthlyPayment: 2200.0);
      await DBService.generateScheduleForPlan(plan);
      final planId = plan['id'] as int;
      final first = await DBService.getPendingPeriod(planId);

      await DBService.recordPayment(planId, first!['id'] as int, 2200.0);

      final updatedPlan = (await db.query('installment_plans',
              where: 'id = ?', whereArgs: [planId]))
          .first;
      expect(updatedPlan['months_paid'], 1);
    });
  });
}
