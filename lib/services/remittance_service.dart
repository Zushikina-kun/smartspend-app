import '../models/remittance.dart';
import 'db_service.dart';

class RemittanceService {
  static const Map<String, double> _rates = {
    'USD': 56.0,
    'SAR': 15.0,
    'AED': 15.0,
    'SGD': 42.0,
    'HKD': 7.0,
  };

  static Future<void> ensureTable() async {
    final db = await DBService.getDB();
    await db.execute('''
      CREATE TABLE IF NOT EXISTS remittances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        recipient_name TEXT NOT NULL,
        platform TEXT NOT NULL,
        fee REAL DEFAULT 0,
        notes TEXT DEFAULT ''
      )
    ''');
  }

  static Future<List<Remittance>> getAll() async {
    await ensureTable();
    final db = await DBService.getDB();
    final rows = await db.query('remittances', orderBy: 'date DESC');
    return rows.map((r) => Remittance.fromMap(r)).toList();
  }

  static Future<int> insert(Remittance r) async {
    await ensureTable();
    final db = await DBService.getDB();
    return db.insert('remittances', r.toMap());
  }

  static Future<void> update(Remittance r) async {
    await ensureTable();
    final db = await DBService.getDB();
    await db.update('remittances', r.toMap(),
        where: 'id = ?', whereArgs: [r.id]);
  }

  static Future<void> delete(int id) async {
    await ensureTable();
    final db = await DBService.getDB();
    await db.delete('remittances', where: 'id = ?', whereArgs: [id]);
  }

  /// Sum of amountPHP for entries in the current calendar month (yyyy-MM).
  static Future<double> totalSentThisMonth() async {
    await ensureTable();
    final db = await DBService.getDB();
    final prefix =
        DateTime.now().toIso8601String().substring(0, 7); // e.g. "2025-07"
    final rows = await db.query('remittances',
        where: "date LIKE ?", whereArgs: ['$prefix%']);
    double total = 0;
    for (final row in rows) {
      final r = Remittance.fromMap(row);
      total += r.amountPHP;
    }
    return total;
  }

  /// Convert a foreign amount to PHP using the hardcoded rates.
  static double toPHP(double amount, String currency) {
    return amount * (_rates[currency] ?? 1.0);
  }
}
