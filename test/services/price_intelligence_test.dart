// Tests for PriceIntelligenceService.
// All DB operations use sqflite_common_ffi with an in-memory database so the
// tests run on Windows/Linux without a physical device.
// SharedPreferences is backed by in-memory mock values via setMockInitialValues.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:smartspend_app/services/price_intelligence_service.dart';
import 'package:smartspend_app/services/db_service.dart';

/// Creates and returns a fresh in-memory database with the `prices` and
/// `settings` tables (the only tables PriceIntelligenceService touches).
Future<Database> _openTestDb() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE prices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_name TEXT NOT NULL,
            store_name TEXT,
            price REAL NOT NULL,
            date TEXT NOT NULL,
            category TEXT,
            expense_id INTEGER,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    ),
  );
  return db;
}

void main() {
  // Initialise Flutter binding (needed by SharedPreferences).
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialise sqflite_ffi once for all tests in this file.
  setUpAll(() {
    sqfliteFfiInit();
    // Override the default databaseFactory so DBService.getDB() uses ffi.
    databaseFactory = databaseFactoryFfi;
  });

  // Inject a fresh in-memory DB into DBService before each test.
  late Database testDb;
  setUp(() async {
    // Mock SharedPreferences with no prior values.
    SharedPreferences.setMockInitialValues({});
    testDb = await _openTestDb();
    DBService.injectDatabase(testDb);
  });

  tearDown(() async {
    await testDb.close();
    DBService.injectDatabase(null);
  });

  group('PriceIntelligenceService', () {
    test('checkForPriceAlerts returns a List (empty when no data)', () async {
      final alerts = await PriceIntelligenceService.checkForPriceAlerts();
      expect(alerts, isA<List>());
    });

    test('checkForPriceAlerts returns empty list when prices table is empty',
        () async {
      final alerts = await PriceIntelligenceService.checkForPriceAlerts();
      expect(alerts, isEmpty);
    });

    test('addPriceFromReceipt inserts a record and returns an id', () async {
      final id = await PriceIntelligenceService.addPriceFromReceipt(
        productName: 'Rice',
        storeName: 'SM Supermarket',
        price: 55.0,
        date: DateTime.now(),
        category: 'Groceries',
      );
      expect(id, greaterThan(0));
    });

    test('findPriceComparisons returns matching records', () async {
      await PriceIntelligenceService.addPriceFromReceipt(
        productName: 'Milk',
        storeName: 'Robinsons',
        price: 85.0,
        date: DateTime.now(),
      );
      final results =
          await PriceIntelligenceService.findPriceComparisons('Milk');
      expect(results, isNotEmpty);
      expect(results.first.productName, 'Milk');
    });

    test('findPriceComparisons returns empty list for unknown product',
        () async {
      final results = await PriceIntelligenceService.findPriceComparisons(
          'UnknownProduct_XYZ');
      expect(results, isEmpty);
    });

    test('getAllPrices returns all inserted records', () async {
      await PriceIntelligenceService.addPriceFromReceipt(
        productName: 'Bread',
        storeName: 'Store A',
        price: 50.0,
        date: DateTime.now(),
      );
      await PriceIntelligenceService.addPriceFromReceipt(
        productName: 'Butter',
        storeName: 'Store B',
        price: 120.0,
        date: DateTime.now(),
      );
      final all = await PriceIntelligenceService.getAllPrices();
      expect(all.length, 2);
    });

    test('checkForPriceAlerts returns a List when two price records exist',
        () async {
      final now = DateTime.now();
      await PriceIntelligenceService.addPriceFromReceipt(
        productName: 'Cooking Oil',
        storeName: 'Cheap Store',
        price: 80.0,
        date: now.subtract(const Duration(days: 1)),
      );
      await PriceIntelligenceService.addPriceFromReceipt(
        productName: 'Cooking Oil',
        storeName: 'Expensive Store',
        price: 120.0,
        date: now,
      );
      final alerts = await PriceIntelligenceService.checkForPriceAlerts();
      // Must return a List without throwing; contents depend on runtime logic.
      expect(alerts, isA<List>());
    });
  });
}
