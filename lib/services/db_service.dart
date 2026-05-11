import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/user_profile.dart';
import 'cloud_service.dart';
import 'event_bus.dart';
import 'category_service.dart';

class DBService {
  static Database? _db;
  static bool _columnsEnsured = false;

  static Future<Database> getDB() async {
    if (_db != null) {
      if (!_columnsEnsured) {
        await _ensureColumns(_db!);
        _columnsEnsured = true;
      }
      return _db!;
    }
    _db = await openDatabase(
      join(await getDatabasesPath(), 'smartspend.db'),
      onCreate: (db, version) async {
        await _createTables(db);
        await _ensureColumns(db);
        _columnsEnsured = true;
      },
      onOpen: (db) async {
        await _ensureColumns(db);
        _columnsEnsured = true;
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS budgets(id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT UNIQUE, amount REAL)");
        }
        if (oldVersion < 3) {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT)");
        }
        if (oldVersion < 4) {
          // Migrate expenses table to new schema
          await db.execute("ALTER TABLE expenses ADD COLUMN item_name TEXT");
          await db.execute("ALTER TABLE expenses ADD COLUMN time TEXT");
          await db.execute(
              "ALTER TABLE expenses ADD COLUMN payment_method TEXT DEFAULT 'Cash'");
          await db.execute("ALTER TABLE expenses ADD COLUMN shop_name TEXT");
          await db.execute("ALTER TABLE expenses ADD COLUMN location TEXT");
          await db.execute(
              "ALTER TABLE expenses ADD COLUMN ai_generated INTEGER DEFAULT 1");
          await db.execute(
              "ALTER TABLE expenses ADD COLUMN confidence_score REAL DEFAULT 1.0");
          // Copy old 'note' to 'item_name'
          await db.execute(
              "UPDATE expenses SET item_name = note WHERE item_name IS NULL");
          // Chat history table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS chat_history(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              role TEXT NOT NULL,
              message TEXT NOT NULL,
              timestamp TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 5) {
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS user_profile(
                uid TEXT PRIMARY KEY,
                first_name TEXT,
                last_name TEXT,
                middle_name TEXT,
                email TEXT,
                birthdate TEXT,
                address TEXT,
                photo_url TEXT
              )
            ''');
          } catch (_) {}
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS savings_goals(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              target_amount REAL NOT NULL,
              current_amount REAL DEFAULT 0,
              deadline TEXT,
              icon TEXT DEFAULT 'savings',
              color INTEGER DEFAULT 4280391411,
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS income(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT DEFAULT 'Salary',
              date TEXT NOT NULL,
              is_recurring INTEGER DEFAULT 0,
              notes TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS recurring(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              frequency TEXT DEFAULT 'monthly',
              next_date TEXT NOT NULL,
              is_expense INTEGER DEFAULT 1,
              notes TEXT
            )
          ''');
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS debts(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              person TEXT NOT NULL,
              amount REAL NOT NULL,
              paid_amount REAL DEFAULT 0,
              type TEXT DEFAULT 'owe',
              due_date TEXT,
              notes TEXT,
              created_at TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 8) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS score_history(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              score INTEGER NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 9) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS scan_history(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              barcode TEXT NOT NULL,
              scanned_at TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 10) {
          // Add missing columns that may not exist on older installs
          try {
            await db.execute("ALTER TABLE expenses ADD COLUMN notes TEXT");
          } catch (_) {}
          try {
            await db.execute("ALTER TABLE expenses ADD COLUMN shop_name TEXT");
          } catch (_) {}
          try {
            await db.execute("ALTER TABLE expenses ADD COLUMN location TEXT");
          } catch (_) {}
          try {
            await db.execute("ALTER TABLE expenses ADD COLUMN time TEXT");
          } catch (_) {}
          try {
            await db.execute(
                "ALTER TABLE expenses ADD COLUMN payment_method TEXT DEFAULT 'Cash'");
          } catch (_) {}
          try {
            await db.execute(
                "ALTER TABLE expenses ADD COLUMN ai_generated INTEGER DEFAULT 1");
          } catch (_) {}
          try {
            await db.execute(
                "ALTER TABLE expenses ADD COLUMN confidence_score REAL DEFAULT 1.0");
          } catch (_) {}
        }
        if (oldVersion < 11) {
          // v11 — all new columns in one block
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS custom_categories(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                icon TEXT
              )
            ''');
          } catch (_) {}
          try {
            await db.execute("ALTER TABLE expenses ADD COLUMN photo_path TEXT");
          } catch (_) {}
          try {
            await db.execute(
                "ALTER TABLE expenses ADD COLUMN is_want INTEGER DEFAULT 0");
          } catch (_) {}
          try {
            await db.execute(
                "ALTER TABLE budgets ADD COLUMN is_percentage INTEGER DEFAULT 0");
          } catch (_) {}
          try {
            await db.execute(
                "ALTER TABLE budgets ADD COLUMN percentage_value REAL DEFAULT 0");
          } catch (_) {}
        }
      },
      version: 11,
    );
    return _db!;
  }

  /// Safely add any missing columns — runs on every app open, idempotent
  static Future<void> _ensureColumns(Database db) async {
    final cols = [
      "ALTER TABLE expenses ADD COLUMN notes TEXT",
      "ALTER TABLE expenses ADD COLUMN shop_name TEXT",
      "ALTER TABLE expenses ADD COLUMN location TEXT",
      "ALTER TABLE expenses ADD COLUMN time TEXT",
      "ALTER TABLE expenses ADD COLUMN payment_method TEXT DEFAULT 'Cash'",
      "ALTER TABLE expenses ADD COLUMN ai_generated INTEGER DEFAULT 1",
      "ALTER TABLE expenses ADD COLUMN confidence_score REAL DEFAULT 1.0",
      "ALTER TABLE expenses ADD COLUMN item_name TEXT",
      "ALTER TABLE expenses ADD COLUMN updated_at TEXT",
      "ALTER TABLE expenses ADD COLUMN photo_path TEXT",
      "ALTER TABLE expenses ADD COLUMN is_want INTEGER DEFAULT 0",
      "ALTER TABLE expenses ADD COLUMN tags TEXT",
      "ALTER TABLE savings_goals ADD COLUMN start_date TEXT",
      "ALTER TABLE savings_goals ADD COLUMN purpose TEXT",
      "ALTER TABLE recurring ADD COLUMN start_date TEXT",
      "ALTER TABLE user_profile ADD COLUMN phone TEXT",
      "ALTER TABLE debts ADD COLUMN interest_rate REAL",
      "ALTER TABLE budgets ADD COLUMN is_percentage INTEGER DEFAULT 0",
      "ALTER TABLE budgets ADD COLUMN percentage_value REAL DEFAULT 0",
      "ALTER TABLE income ADD COLUMN is_windfall INTEGER DEFAULT 0",
    ];
    for (final sql in cols) {
      try {
        await db.execute(sql);
      } catch (_) {} // ignore if already exists
    }
    // Ensure custom_categories table exists
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS custom_categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          icon TEXT
        )
      ''');
    } catch (_) {}
    // Ensure installments table exists (created on-demand in older versions)
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS installments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          total_amount REAL NOT NULL,
          monthly_payment REAL NOT NULL,
          months_total INTEGER NOT NULL,
          months_paid INTEGER DEFAULT 0,
          interest_rate REAL DEFAULT 0,
          start_date TEXT NOT NULL,
          notes TEXT
        )
      ''');
    } catch (_) {}
    // Ensure category_rules table exists — user-defined auto-categorization rules
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS category_rules(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          keyword TEXT NOT NULL,
          category TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    } catch (_) {}
    // Ensure mood_log table exists — daily mood check-ins for behavioral correlation
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS mood_log(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          mood_score INTEGER NOT NULL,
          note TEXT
        )
      ''');
    } catch (_) {}

    // Data correction: fix any recurring entries that are expense categories
    // but were accidentally saved as is_expense = 0 (income)
    // This fixes entries like "Converge - Bida Internet" (Bills) marked as income
    try {
      await db.execute("""
        UPDATE recurring
        SET is_expense = 1
        WHERE category IN ('Bills','Food','Transportation','Education',
                           'Health','Shopping','Entertainment','Others')
        AND is_expense = 0
      """);
    } catch (_) {}

    // Ensure installment_plans table exists — for ShopeePayLater, GCash GLoan, etc.
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS installment_plans(
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
          created_at TEXT
        )
      ''');
    } catch (_) {}

    // Ensure recurring_candidates table — auto-detected subscription patterns
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recurring_candidates(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          avg_amount REAL NOT NULL,
          frequency TEXT NOT NULL,
          last_seen TEXT NOT NULL,
          dismissed INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
    } catch (_) {}

    // Ensure conversation_summaries table — for token-efficient chat history
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS conversation_summaries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          summary TEXT NOT NULL,
          message_count_at_summary INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    } catch (_) {}

    // Ensure wallets table — cash on hand, GCash, Maya, bank balances
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS wallets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL DEFAULT 'cash',
          balance REAL NOT NULL DEFAULT 0,
          icon TEXT DEFAULT '💵',
          updated_at TEXT NOT NULL
        )
      ''');
      // Seed default wallets only on a truly fresh install (no user profile yet).
      // After logout, wallets are deleted and restored from Firestore on next
      // login — so we must NOT re-seed here or we'd overwrite the restored data.
      final existing = await db.query('wallets');
      final hasUser = await db.query('user_profile');
      if (existing.isEmpty && hasUser.isEmpty) {
        final now = DateTime.now().toIso8601String();
        await db.insert('wallets', {
          'name': 'Cash on Hand',
          'type': 'cash',
          'balance': 0.0,
          'icon': '💵',
          'updated_at': now
        });
        await db.insert('wallets', {
          'name': 'GCash',
          'type': 'ewallet',
          'balance': 0.0,
          'icon': '📱',
          'updated_at': now
        });
      }
    } catch (_) {}

    // One-time migration: set is_want=1 for Entertainment and Shopping expenses
    // that were logged before the AI started tagging them correctly
    // Education is intentionally excluded — always a Need
    try {
      final wantMigrated = await db
          .query('settings', where: 'key = ?', whereArgs: ['is_want_migrated']);
      if (wantMigrated.isEmpty) {
        await db.execute("""
          UPDATE expenses
          SET is_want = 1
          WHERE category IN ('Entertainment', 'Shopping', 'Gaming', 'Clothing', 'Gifts', 'Travel')
          AND is_want = 0
        """);
        // Ensure Education is always Need — fix any wrongly tagged entries
        await db.execute("""
          UPDATE expenses
          SET is_want = 0
          WHERE category = 'Education'
        """);
        await db.insert(
            'settings', {'key': 'is_want_migrated', 'value': 'true'},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } catch (_) {}
    // One-time fix: ensure Education expenses are always is_want=0 (Need)
    try {
      final eduFixed = await db.query('settings',
          where: 'key = ?', whereArgs: ['education_need_fixed']);
      if (eduFixed.isEmpty) {
        await db.execute("""
          UPDATE expenses SET is_want = 0 WHERE category = 'Education'
        """);
        await db.insert(
            'settings', {'key': 'education_need_fixed', 'value': 'true'},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } catch (_) {}
    try {
      final migrated = await db.query('settings',
          where: 'key = ?', whereArgs: ['installments_migrated']);
      if (migrated.isEmpty) {
        final oldItems = await db.query('installments');
        for (final item in oldItems) {
          final existing = await db.query('installment_plans',
              where: 'title = ? AND total_amount = ?',
              whereArgs: [item['name'], item['total_amount']],
              limit: 1);
          if (existing.isEmpty) {
            await db.insert('installment_plans', {
              'title': item['name'],
              'provider': null,
              'total_amount': item['total_amount'],
              'monthly_payment': item['monthly_payment'],
              'months_total': item['months_total'],
              'months_paid': item['months_paid'] ?? 0,
              'due_day': 5,
              'interest_rate': item['interest_rate'],
              'start_date': item['start_date'],
              'category': 'Bills',
              'notes': item['notes'],
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }
        await db.insert(
            'settings', {'key': 'installments_migrated', 'value': 'true'},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } catch (_) {}
  }

  static Future<void> _createTables(Database db) async {
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
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT UNIQUE,
        amount REAL,
        is_percentage INTEGER DEFAULT 0,
        percentage_value REAL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE chat_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE user_profile(
        uid TEXT PRIMARY KEY,
        first_name TEXT,
        last_name TEXT,
        middle_name TEXT,
        email TEXT,
        birthdate TEXT,
        address TEXT,
        photo_url TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE savings_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL DEFAULT 0,
        start_date TEXT,
        deadline TEXT,
        icon TEXT DEFAULT 'savings',
        color INTEGER DEFAULT 4280391411,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE income(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT DEFAULT 'Salary',
        date TEXT NOT NULL,
        is_recurring INTEGER DEFAULT 0,
        is_windfall INTEGER DEFAULT 0,
        notes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE recurring(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT DEFAULT 'monthly',
        next_date TEXT NOT NULL,
        is_expense INTEGER DEFAULT 1,
        notes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE debts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        person TEXT NOT NULL,
        amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0,
        type TEXT DEFAULT 'owe',
        due_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE score_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE scan_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT NOT NULL,
        scanned_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE custom_categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS installments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        total_amount REAL NOT NULL,
        monthly_payment REAL NOT NULL,
        months_total INTEGER NOT NULL,
        months_paid INTEGER DEFAULT 0,
        interest_rate REAL DEFAULT 0,
        start_date TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  // ── EXPENSES ──────────────────────────────────────────────

  static Future<void> insertExpense(Map<String, dynamic> data) async {
    final db = await getDB();
    final toInsert = Map<String, dynamic>.from(data)..remove('id');

    // Validation
    if (!toInsert.containsKey('item_name') ||
        toInsert['item_name'] == null ||
        (toInsert['item_name'] as String).trim().isEmpty) {
      toInsert['item_name'] = toInsert['note'] ?? 'Expense';
    }
    final amount = (toInsert['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) throw Exception("Amount must be greater than zero.");

    // Category validation — allow any non-empty string (custom categories supported)
    if (toInsert['category'] == null ||
        (toInsert['category'] as String).trim().isEmpty) {
      toInsert['category'] = 'Others';
    }

    // Duplicate detection — prevents double-taps and re-imports
    // For AI/manual: same item+amount+date within same minute
    // For imports (CSV/bank): same amount+date+category (descriptions may vary slightly)
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final nowTime = DateTime.now().toIso8601String().substring(11, 19);
    final insertTime = toInsert['time'] as String? ?? nowTime;
    final isImport =
        (toInsert['notes'] as String? ?? '').startsWith('Imported from');

    if (isImport) {
      // For imports: block exact same amount+date+category (prevents re-importing same file)
      final existing = await db.rawQuery(
        "SELECT id FROM expenses WHERE amount = ? AND date = ? AND category = ? AND notes LIKE 'Imported from%'",
        [amount, toInsert['date'] ?? today, toInsert['category']],
      );
      if (existing.isNotEmpty) {
        return; // Duplicate import row — skip silently
      }
    } else {
      // For AI/manual: same item+amount+date within same minute
      final isAI = (toInsert['ai_generated'] as int? ?? 0) == 1;
      final compareLen = isAI ? 8 : 5;
      final checkTime = insertTime.length >= compareLen
          ? insertTime.substring(0, compareLen)
          : insertTime;
      final existing = await db.rawQuery(
        "SELECT id FROM expenses WHERE item_name = ? AND amount = ? AND date = ? AND substr(time, 1, $compareLen) = ?",
        [toInsert['item_name'], amount, toInsert['date'] ?? today, checkTime],
      );
      if (existing.isNotEmpty) {
        return; // True duplicate — skip silently
      }
    }

    await db.insert('expenses', toInsert,
        conflictAlgorithm: ConflictAlgorithm.replace);
    try {
      await CloudService.saveExpense(data);
    } catch (_) {}
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<void> updateExpense(Expense expense) async {
    final db = await getDB();
    final data = expense.toMap()
      ..['updated_at'] = DateTime.now().toIso8601String();
    await db.update('expenses', data, where: 'id = ?', whereArgs: [expense.id]);
    CloudService.pushDoc('expenses', data);
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<void> deleteExpense(int id) async {
    final db = await getDB();
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    CloudService.deleteDoc('expenses', id);
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<List<Expense>> getExpenses({String? month}) async {
    final db = await getDB();
    final maps = month != null
        ? await db.query('expenses',
            where: "date LIKE ?",
            whereArgs: ['$month%'],
            orderBy: 'date DESC, id DESC')
        : await db.query('expenses', orderBy: 'date DESC, id DESC');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  static Future<double> getTotalSpent({String? month}) async {
    final expenses = await getExpenses(month: month);
    return expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  static Future<int> getExpenseCount() async {
    final db = await getDB();
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM expenses');
    return (result.first['count'] as int?) ?? 0;
  }

  static Future<List<Expense>> getExpensesByCategory(String category,
      {String? month}) async {
    final db = await getDB();
    final maps = month != null
        ? await db.query('expenses',
            where: 'category = ? AND date LIKE ?',
            whereArgs: [category, '$month%'],
            orderBy: 'date DESC')
        : await db.query('expenses',
            where: 'category = ?', whereArgs: [category], orderBy: 'date DESC');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  // ── BUDGETS ───────────────────────────────────────────────

  static Future<void> setBudget(String category, double amount,
      {bool isPercentage = false, double percentageValue = 0}) async {
    // Allow any non-empty category (custom categories supported)
    final validCategory = category.trim().isEmpty ? 'Others' : category.trim();
    final db = await getDB();
    await db.insert(
        'budgets',
        {
          'category': validCategory,
          'amount': amount,
          'is_percentage': isPercentage ? 1 : 0,
          'percentage_value': percentageValue,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    final rows = await db
        .query('budgets', where: 'category = ?', whereArgs: [validCategory]);
    if (rows.isNotEmpty) CloudService.pushDoc('budgets', rows.first);
    fireEvent(AppEvent.budgetChanged);
  }

  static Future<List<Budget>> getBudgets() async {
    final db = await getDB();
    final maps = await db.query('budgets');
    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  static Future<void> deleteBudget(String category) async {
    final db = await getDB();
    final rows =
        await db.query('budgets', where: 'category = ?', whereArgs: [category]);
    if (rows.isNotEmpty)
      CloudService.deleteDoc('budgets', rows.first['id'] as int);
    await db.delete('budgets', where: 'category = ?', whereArgs: [category]);
    fireEvent(AppEvent.budgetChanged);
  }

  // ── CUSTOM CATEGORIES ─────────────────────────────────────

  static Future<void> insertCustomCategory(Map<String, dynamic> data) async {
    final db = await getDB();
    final id = await db.insert('custom_categories', data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (id > 0) CloudService.pushDoc('custom_categories', {...data, 'id': id});
    CategoryService.invalidate();
  }

  static Future<void> updateCustomCategory(int id, String newName) async {
    final db = await getDB();
    await db.update('custom_categories', {'name': newName},
        where: 'id = ?', whereArgs: [id]);
    CloudService.pushDoc('custom_categories', {'id': id, 'name': newName});
    CategoryService.invalidate();
  }

  static Future<void> deleteCustomCategory(int id) async {
    final db = await getDB();
    await db.delete('custom_categories', where: 'id = ?', whereArgs: [id]);
    CloudService.deleteDoc('custom_categories', id);
    CategoryService.invalidate();
  }

  static Future<List<Map<String, dynamic>>> getCustomCategories() async {
    final db = await getDB();
    return db.query('custom_categories', orderBy: 'name ASC');
  }

  /// Rename all expenses in a category (used when renaming/deleting custom cats)
  static Future<void> renameExpenseCategory(
      String oldName, String newName) async {
    final db = await getDB();
    await db.update('expenses', {'category': newName},
        where: 'category = ?', whereArgs: [oldName]);
    // Push all affected expenses to Firestore
    try {
      final affected = await db.query('expenses',
          where: 'category = ?', whereArgs: [newName]);
      for (final e in affected) {
        CloudService.pushDoc('expenses', e);
      }
    } catch (_) {}
    fireEvent(AppEvent.expenseChanged);
  }

  // ── CATEGORY RULES ────────────────────────────────────────

  /// Insert a new keyword → category rule.
  static Future<void> insertCategoryRule(
      String keyword, String category) async {
    final db = await getDB();
    final id = await db.insert(
      'category_rules',
      {
        'keyword': keyword.trim().toLowerCase(),
        'category': category,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    if (id > 0) {
      try {
        CloudService.pushDoc('category_rules', {
          'id': id,
          'keyword': keyword.trim().toLowerCase(),
          'category': category,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
  }

  static Future<void> deleteCategoryRule(int id) async {
    final db = await getDB();
    await db.delete('category_rules', where: 'id = ?', whereArgs: [id]);
    try { CloudService.deleteDoc('category_rules', id); } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getCategoryRules() async {
    final db = await getDB();
    return db.query('category_rules', orderBy: 'keyword ASC');
  }

  /// Apply user-defined rules to a raw description/item name.
  /// Returns the matched category, or null if no rule matches.
  static Future<String?> applyRules(String text) async {
    final rules = await getCategoryRules();
    if (rules.isEmpty) return null;
    final lower = text.toLowerCase();
    for (final r in rules) {
      final kw = (r['keyword'] as String).toLowerCase();
      if (lower.contains(kw)) return r['category'] as String;
    }
    return null;
  }

  // ── MOOD LOG ──────────────────────────────────────────────

  /// Save or update today's mood score (1–5). One entry per day.
  static Future<void> saveMood(int score, {String? note}) async {
    final db = await getDB();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await db.insert(
      'mood_log',
      {'date': today, 'mood_score': score, 'note': note},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get today's mood entry, or null if not logged yet.
  static Future<Map<String, dynamic>?> getTodayMood() async {
    final db = await getDB();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows = await db.query('mood_log',
        where: 'date = ?', whereArgs: [today], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  /// Get mood log for the last N days.
  static Future<List<Map<String, dynamic>>> getMoodHistory(
      {int days = 30}) async {
    final db = await getDB();
    final since = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String()
        .substring(0, 10);
    return db.query('mood_log',
        where: 'date >= ?', whereArgs: [since], orderBy: 'date ASC');
  }

  // ── SETTINGS ──────────────────────────────────────────────

  static Future<void> setSetting(String key, String value) async {
    final db = await getDB();
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<String?> getSetting(String key) async {
    final db = await getDB();
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  static Future<double> getMonthlyIncome() async {
    final val = await getSetting('monthly_income');
    return double.tryParse(val ?? '') ?? 0.0;
  }

  static Future<void> setMonthlyIncome(double income) async {
    await setSetting('monthly_income', income.toString());
  }

  static Future<double> getDailyLimit() async {
    final val = await getSetting('daily_limit');
    return double.tryParse(val ?? '') ?? 0.0;
  }

  static Future<void> setDailyLimit(double limit) async {
    await setSetting('daily_limit', limit.toString());
  }

  /// Returns total remaining balance across all installments
  static Future<double> getInstallmentsRemainingTotal() async {
    try {
      final db = await getDB();
      final rows = await db.query('installments');
      double total = 0;
      for (final r in rows) {
        final monthsTotal = (r['months_total'] as int? ?? 0);
        final monthsPaid = (r['months_paid'] as int? ?? 0);
        final monthlyPayment = (r['monthly_payment'] as num? ?? 0).toDouble();
        final remaining = (monthsTotal - monthsPaid).clamp(0, monthsTotal);
        total += remaining * monthlyPayment;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  // ── CHAT HISTORY ──────────────────────────────────────────

  static Future<void> saveChatMessage({
    required String role,
    required String message,
  }) async {
    final db = await getDB();
    await db.insert('chat_history', {
      'role': role,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getChatHistory(
      {int limit = 100}) async {
    final db = await getDB();
    // Get the LATEST N messages (DESC), then reverse so they display oldest-first
    final maps =
        await db.query('chat_history', orderBy: 'timestamp DESC', limit: limit);
    return maps.reversed.toList();
  }

  static Future<void> clearChatHistory() async {
    final db = await getDB();
    await db.delete('chat_history');
  }

  // ── USER PROFILE ──────────────────────────────────────────

  static Future<void> saveProfile(UserProfile profile) async {
    final db = await getDB();
    // If photo is a local file path, upload to Firebase Storage first
    UserProfile toSave = profile;
    if (profile.photoUrl != null &&
        profile.photoUrl!.startsWith('/') &&
        !profile.photoUrl!.startsWith('https://')) {
      final url = await CloudService.uploadProfilePhoto(profile.photoUrl!);
      if (url != null) {
        toSave = profile.copyWith(photoUrl: url);
      }
    }
    await db.insert('user_profile', toSave.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    try {
      await CloudService.saveProfile(toSave);
    } catch (_) {}
  }

  static Future<UserProfile?> getProfile(String uid) async {
    final db = await getDB();
    final maps =
        await db.query('user_profile', where: 'uid = ?', whereArgs: [uid]);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  // ── SAVINGS GOALS ─────────────────────────────────────────

  static Future<void> insertGoal(Map<String, dynamic> data) async {
    final db = await getDB();
    final id = await db.insert('savings_goals', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    CloudService.pushDoc('goals', {...data, 'id': id});
    fireEvent(AppEvent.goalChanged);
  }

  static Future<void> updateGoal(Map<String, dynamic> data) async {
    final db = await getDB();
    await db.update('savings_goals', data,
        where: 'id = ?', whereArgs: [data['id']]);
    CloudService.pushDoc('goals', data);
    fireEvent(AppEvent.goalChanged);
  }

  static Future<void> deleteGoal(int id) async {
    final db = await getDB();
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
    CloudService.deleteDoc('goals', id);
    fireEvent(AppEvent.goalChanged);
  }

  static Future<List<Map<String, dynamic>>> getGoals() async {
    final db = await getDB();
    return db.query('savings_goals', orderBy: 'created_at DESC');
  }

  // ── INCOME ────────────────────────────────────────────────

  static Future<void> insertIncome(Map<String, dynamic> data) async {
    final db = await getDB();
    final id = await db.insert('income', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    CloudService.pushDoc('income', {...data, 'id': id});
    fireEvent(AppEvent.incomeChanged);
  }

  static Future<void> deleteIncome(int id) async {
    final db = await getDB();
    await db.delete('income', where: 'id = ?', whereArgs: [id]);
    CloudService.deleteDoc('income', id);
    fireEvent(AppEvent.incomeChanged);
  }

  static Future<List<Map<String, dynamic>>> getIncome({String? month}) async {
    final db = await getDB();
    if (month != null) {
      return db.query('income',
          where: "date LIKE ?", whereArgs: ['$month%'], orderBy: 'date DESC');
    }
    return db.query('income', orderBy: 'date DESC');
  }

  static Future<double> getTotalIncome({String? month}) async {
    final records = await getIncome(month: month);
    return records.fold<double>(0.0, (s, r) => s + (r['amount'] as num));
  }

  // ── RECURRING ─────────────────────────────────────────────

  static Future<void> insertRecurring(Map<String, dynamic> data) async {
    final db = await getDB();
    final id = await db.insert('recurring', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    CloudService.pushDoc('recurring', {...data, 'id': id});
    fireEvent(AppEvent.expenseChanged); // recurring affects expense projections
  }

  static Future<void> updateRecurring(Map<String, dynamic> data) async {
    final db = await getDB();
    await db
        .update('recurring', data, where: 'id = ?', whereArgs: [data['id']]);
    CloudService.pushDoc('recurring', data);
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<void> deleteRecurring(int id) async {
    final db = await getDB();
    await db.delete('recurring', where: 'id = ?', whereArgs: [id]);
    CloudService.deleteDoc('recurring', id);
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<List<Map<String, dynamic>>> getRecurring() async {
    final db = await getDB();
    return db.query('recurring', orderBy: 'next_date ASC');
  }

  // ── DEBTS ─────────────────────────────────────────────────

  static Future<void> insertDebt(Map<String, dynamic> data) async {
    final db = await getDB();
    final id = await db.insert('debts', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    CloudService.pushDoc('debts', {...data, 'id': id});
    fireEvent(AppEvent.expenseChanged); // debts affect net worth + home banners
  }

  static Future<void> updateDebt(Map<String, dynamic> data) async {
    final db = await getDB();
    await db.update('debts', data, where: 'id = ?', whereArgs: [data['id']]);
    CloudService.pushDoc('debts', data);
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<void> deleteDebt(int id) async {
    final db = await getDB();
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
    CloudService.deleteDoc('debts', id);
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<List<Map<String, dynamic>>> getDebts({String? type}) async {
    final db = await getDB();
    if (type != null) {
      return db.query('debts',
          where: 'type = ?', whereArgs: [type], orderBy: 'created_at DESC');
    }
    return db.query('debts', orderBy: 'created_at DESC');
  }

  // ── CLOUD SYNC ────────────────────────────────────────────

  /// Pull all data from Firestore and merge into local SQLite.
  /// Called once after login. Skips records that already exist locally (by id).
  static Future<int> syncFromCloud() async {
    int count = 0;
    try {
      final syncData = await CloudService.pullAll();
      if (syncData.isEmpty) return 0;

      final db = await getDB();

      // Merge expenses — last-write-wins based on updated_at timestamp
      for (final e in syncData.expenses) {
        final id = e['id'];
        if (id == null) continue;
        final clean = Map<String, dynamic>.from(e)..remove('firestore_doc_id');
        final existing = await db.query('expenses',
            where: 'id = ?', whereArgs: [id], limit: 1);
        if (existing.isEmpty) {
          try {
            await db.insert('expenses', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        } else {
          // Last-write-wins: overwrite local if cloud record is newer
          final localUpdated = existing.first['updated_at'] as String? ?? '';
          final cloudUpdated = e['updated_at'] as String? ?? '';
          if (cloudUpdated.isNotEmpty &&
              cloudUpdated.compareTo(localUpdated) > 0) {
            try {
              await db
                  .update('expenses', clean, where: 'id = ?', whereArgs: [id]);
              count++;
            } catch (_) {}
          }
        }
      }

      // Merge budgets
      for (final b in syncData.budgets) {
        final category = b['category'] as String?;
        if (category == null) continue;
        final existing = await db.query('budgets',
            where: 'category = ?', whereArgs: [category], limit: 1);
        if (existing.isEmpty) {
          try {
            await db.insert(
                'budgets', {'category': category, 'amount': b['amount']},
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        }
      }

      // Merge goals
      for (final g in syncData.goals) {
        final id = g['id'];
        if (id == null) continue;
        final existing = await db.query('savings_goals',
            where: 'id = ?', whereArgs: [id], limit: 1);
        if (existing.isEmpty) {
          final clean = Map<String, dynamic>.from(g)
            ..remove('firestore_doc_id');
          try {
            await db.insert('savings_goals', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        }
      }

      // Merge income
      for (final i in syncData.income) {
        final id = i['id'];
        if (id == null) continue;
        final existing = await db.query('income',
            where: 'id = ?', whereArgs: [id], limit: 1);
        if (existing.isEmpty) {
          final clean = Map<String, dynamic>.from(i)
            ..remove('firestore_doc_id');
          try {
            await db.insert('income', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        }
      }

      // Merge recurring
      for (final r in syncData.recurring) {
        final id = r['id'];
        if (id == null) continue;
        final existing = await db.query('recurring',
            where: 'id = ?', whereArgs: [id], limit: 1);
        if (existing.isEmpty) {
          final clean = Map<String, dynamic>.from(r)
            ..remove('firestore_doc_id');
          try {
            await db.insert('recurring', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        }
      }

      // Merge debts
      for (final d in syncData.debts) {
        final id = d['id'];
        if (id == null) continue;
        final existing =
            await db.query('debts', where: 'id = ?', whereArgs: [id], limit: 1);
        if (existing.isEmpty) {
          final clean = Map<String, dynamic>.from(d)
            ..remove('firestore_doc_id');
          try {
            await db.insert('debts', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        }
      }

      // Merge custom categories
      for (final c in syncData.customCategories) {
        final name = c['name'] as String?;
        if (name == null || name.isEmpty) continue;
        try {
          await db.insert(
              'custom_categories', {'name': name, 'icon': c['icon']},
              conflictAlgorithm: ConflictAlgorithm.ignore);
        } catch (_) {}
      }
      CategoryService.invalidate(); // refresh category cache after sync

      // Merge category_rules — user-defined auto-categorization rules
      for (final r in syncData.categoryRules) {
        final id = r['id'];
        final keyword = r['keyword'] as String?;
        if (keyword == null || keyword.isEmpty) continue;
        final existing = id != null
            ? await db.query('category_rules', where: 'id = ?', whereArgs: [id], limit: 1)
            : await db.query('category_rules', where: 'keyword = ?', whereArgs: [keyword], limit: 1);
        if (existing.isEmpty) {
          final clean = Map<String, dynamic>.from(r)..remove('firestore_doc_id');
          try {
            await db.insert('category_rules', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        }
      }

      // Merge installments
      for (final inst in syncData.installments) {
        final id = inst['id'];
        if (id == null) continue;
        final existing = await db.query('installments',
            where: 'id = ?', whereArgs: [id], limit: 1);
        if (existing.isEmpty) {
          final clean = Map<String, dynamic>.from(inst)
            ..remove('firestore_doc_id');
          try {
            await db.insert('installments', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        }
      }

      // Merge installment_plans (Payment Plans tab)
      for (final plan in syncData.installmentPlans) {
        final id = plan['id'];
        if (id == null) continue;
        final existing = await db.query('installment_plans',
            where: 'id = ?', whereArgs: [id], limit: 1);
        if (existing.isEmpty) {
          final clean = Map<String, dynamic>.from(plan)
            ..remove('firestore_doc_id');
          try {
            await db.insert('installment_plans', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        }
      }

      // Merge wallets — restore balances from cloud; update existing by id
      for (final w in syncData.wallets) {
        final id = w['id'];
        if (id == null) continue;
        final clean = Map<String, dynamic>.from(w)..remove('firestore_doc_id');
        final existing =
            await db.query('wallets', where: 'id = ?', whereArgs: [id], limit: 1);
        if (existing.isEmpty) {
          try {
            await db.insert('wallets', clean,
                conflictAlgorithm: ConflictAlgorithm.ignore);
            count++;
          } catch (_) {}
        } else {
          // Always restore cloud balance — wallet balances are the source of truth
          try {
            await db.update('wallets',
                {'balance': clean['balance'], 'updated_at': clean['updated_at']},
                where: 'id = ?', whereArgs: [id]);
          } catch (_) {}
        }
      }
      // If no wallets came from cloud (brand new account), seed defaults
      final walletCount = await db.rawQuery('SELECT COUNT(*) as c FROM wallets');
      if ((walletCount.first['c'] as int? ?? 0) == 0) {
        final now = DateTime.now().toIso8601String();
        await db.insert('wallets', {'name': 'Cash on Hand', 'type': 'cash', 'balance': 0.0, 'icon': '💵', 'updated_at': now});
        await db.insert('wallets', {'name': 'GCash', 'type': 'ewallet', 'balance': 0.0, 'icon': '📱', 'updated_at': now});
      }

      // Sync profile photo if it's a remote URL
      if (syncData.profile?.photoUrl != null &&
          syncData.profile!.photoUrl!.startsWith('https://')) {
        final localPath = await CloudService.downloadProfilePhoto(
            syncData.profile!.photoUrl!);
        if (localPath != null && syncData.profile != null) {
          final updated = syncData.profile!.copyWith(photoUrl: localPath);
          await saveProfile(updated);
        }
      }

      // Notify all screens that data has changed after sync
      if (count > 0) {
        fireEvent(AppEvent.expenseChanged);
        fireEvent(AppEvent.budgetChanged);
        fireEvent(AppEvent.incomeChanged);
        fireEvent(AppEvent.goalChanged);
      }

      // Restore key settings from Firestore (income, account type, currency)
      // Only restore if local value is missing (was cleared on logout)
      final cloudSettings = await CloudService.fetchSettings();
      for (final entry in cloudSettings.entries) {
        final localVal = await getSetting(entry.key);
        if (localVal == null || localVal.isEmpty) {
          await setSetting(entry.key, entry.value);
        }
      }
      if (cloudSettings.containsKey('monthly_income') ||
          cloudSettings.containsKey('account_type')) {
        fireEvent(AppEvent.incomeChanged);
      }
    } catch (_) {}
    return count;
  }

  /// Push all local data to Firestore (called after login to ensure cloud is current).
  static Future<void> pushAllToCloud() async {
    try {
      final expenses = await getExpenses();
      final budgets = await getBudgets();
      final goals = await getGoals();
      final income = await getIncome();
      final recurring = await getRecurring();
      final debts = await getDebts();
      final customCategories = await getCustomCategories();
      final db = await getDB();
      List<Map<String, dynamic>> installments = [];
      try {
        installments = await db.query('installments');
      } catch (_) {}
      // Also push installment_plans (Payment Plans tab)
      List<Map<String, dynamic>> installmentPlans = [];
      try {
        installmentPlans = await db.query('installment_plans');
      } catch (_) {}

      // Also push wallets
      List<Map<String, dynamic>> wallets = [];
      try {
        wallets = await getWallets();
      } catch (_) {}
      // Also push category_rules
      List<Map<String, dynamic>> categoryRules = [];
      try {
        categoryRules = await getCategoryRules();
      } catch (_) {}

      await CloudService.pushAll(
        expenses: expenses.map((e) => e.toMap()).toList(),
        budgets: budgets.map((b) => b.toMap()).toList(),
        goals: goals,
        income: income,
        recurring: recurring,
        debts: debts,
        customCategories: customCategories,
        installments: installments,
        installmentPlans: installmentPlans,
        wallets: wallets,
        categoryRules: categoryRules,
      );

      // Push key settings so they survive logout/login
      final settingsToSync = <String, String>{};
      for (final key in [
        'monthly_income',
        'account_type',
        'income_frequency',
        'currency',
        'setup_done',
        'daily_limit',
        'payday_date',
        'manual_assets',
      ]) {
        final val = await getSetting(key);
        if (val != null) settingsToSync[key] = val;
      }
      if (settingsToSync.isNotEmpty) {
        await CloudService.pushSettings(settingsToSync);
      }
    } catch (_) {}
  }

  // ── LOCAL DATA MANAGEMENT ─────────────────────────────────

  /// Clears all financial data from local SQLite.
  /// Keeps: settings, user_profile.
  /// Chat history is cleared on logout — each account's conversations are private.
  /// Call this on logout so the next account starts with a clean slate.
  /// Data is safe as long as it was pushed to Firestore before calling this.
  static Future<void> clearLocalData() async {
    final db = await getDB();
    await db.delete('expenses');
    await db.delete('budgets');
    await db.delete('savings_goals');
    await db.delete('income');
    await db.delete('recurring');
    await db.delete('debts');
    await db.delete('score_history');
    await db.delete('scan_history');
    await db.delete('chat_history'); // Clear on logout — chat is per-account
    await db.delete('mood_log'); // Clear on logout — mood is per-account
    try {
      await db
          .delete('conversation_summaries'); // Clear on logout — per-account
    } catch (_) {}
    try {
      await db.delete('custom_categories');
    } catch (_) {}
    // Note: category_rules are kept across accounts (user preference, like themes)
    CategoryService.invalidate();
    // Reset monthly income to default so next account starts fresh
    await db
        .delete('settings', where: 'key = ?', whereArgs: ['monthly_income']);
    // Reset account type to default
    await db.delete('settings', where: 'key = ?', whereArgs: ['account_type']);
    // Reset payday date so next account sets their own
    await db.delete('settings', where: 'key = ?', whereArgs: ['payday_date']);
    // Reset spending challenge so next account starts without a target
    await db.delete('settings',
        where: 'key = ?', whereArgs: ['spending_challenge']);
    // Reset setup flag so next account goes through onboarding
    await db.delete('settings', where: 'key = ?', whereArgs: ['setup_done']);
    // Reset income frequency — per-account preference
    await db
        .delete('settings', where: 'key = ?', whereArgs: ['income_frequency']);
    // Reset manual assets — per-account net worth data
    await db.delete('settings', where: 'key = ?', whereArgs: ['manual_assets']);
    // Reset quiz challenge — per-account onboarding answer
    await db
        .delete('settings', where: 'key = ?', whereArgs: ['quiz_challenge']);
    // Reset impulse decline counter — per-account badge progress
    await db
        .delete('settings', where: 'key = ?', whereArgs: ['impulse_declines']);
    // Reset level-up milestones — per-account so next user gets their own notifications
    for (final t in [60, 70, 80, 90]) {
      await db.delete('settings', where: 'key = ?', whereArgs: ['level_up_$t']);
    }
    // Reset score decay state — per-account
    await db.delete('settings',
        where: 'key = ?', whereArgs: ['warning_decay_days']);
    await db
        .delete('settings', where: 'key = ?', whereArgs: ['last_decay_check']);
    // Reset done_spending_today — per-account toggle
    await db.delete('settings',
        where: 'key = ?', whereArgs: ['done_spending_today']);
    // Reset weekly challenge dismiss — per-account
    await db.delete('settings',
        where: 'key = ?', whereArgs: ['weekly_challenge_dismissed']);
    // Reset recurring candidate detection date — per-account so new account
    // gets fresh subscription detection on first use
    await db.delete('settings',
        where: 'key = ?', whereArgs: ['last_recurring_check']);
    // Reset notification throttle keys — per-account so new account gets
    // their first-day/week/month notifications without waiting for the cycle
    for (final key in [
      'last_weekly_notif',
      'last_anomaly_check',
      'last_velocity_check',
      'last_want_alert',
      'last_daily_briefing',
    ]) {
      await db.delete('settings', where: 'key = ?', whereArgs: [key]);
    }
    // Clear installment_plans — per-account financial data
    try {
      await db.delete('installment_plans');
    } catch (_) {}
    // Clear old installments table — per-account financial data
    try {
      await db.delete('installments');
    } catch (_) {}
    // Clear recurring_candidates — derived from this account's expense patterns
    try {
      await db.delete('recurring_candidates');
    } catch (_) {}
    // Clear wallets — per-account balances. Rows are deleted so they restore
    // cleanly from Firestore on next login (avoids stale zero-balance rows).
    try {
      await db.delete('wallets');
    } catch (_) {}
    // Reset AI daily request counter — per-account so next user gets their own limit
    // (ai_chat_count and ai_chat_date are in SharedPreferences, not SQLite)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ai_chat_count');
      await prefs.remove('ai_chat_date');
    } catch (_) {}
  }

  static Future<void> saveScoreSnapshot(int score) async {
    final db = await getDB();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing =
        await db.query('score_history', where: 'date = ?', whereArgs: [today]);
    if (existing.isEmpty) {
      await db.insert('score_history', {'score': score, 'date': today});
    } else {
      await db.update('score_history', {'score': score},
          where: 'date = ?', whereArgs: [today]);
    }
  }

  static Future<List<Map<String, dynamic>>> getScoreHistory(
      {int days = 30}) async {
    final db = await getDB();
    final since = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String()
        .substring(0, 10);
    return db.query('score_history',
        where: 'date >= ?', whereArgs: [since], orderBy: 'date ASC');
  }

  // ── SCAN HISTORY ──────────────────────────────────────────

  // ── INSTALLMENT PLANS ─────────────────────────────────────

  static Future<void> insertInstallmentPlan(Map<String, dynamic> data) async {
    final db = await getDB();
    final id = await db.insert('installment_plans', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    // Sync to Firestore immediately
    try {
      CloudService.pushDoc('installment_plans', {...data, 'id': id});
    } catch (_) {}
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<void> updateInstallmentPlan(Map<String, dynamic> data) async {
    final db = await getDB();
    await db.update('installment_plans', data,
        where: 'id = ?', whereArgs: [data['id']]);
    // Sync to Firestore immediately
    try {
      CloudService.pushDoc('installment_plans', data);
    } catch (_) {}
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<void> deleteInstallmentPlan(int id) async {
    final db = await getDB();
    await db.delete('installment_plans', where: 'id = ?', whereArgs: [id]);
    // Remove from Firestore
    try {
      CloudService.deleteDoc('installment_plans', id);
    } catch (_) {}
    fireEvent(AppEvent.expenseChanged);
  }

  static Future<List<Map<String, dynamic>>> getInstallmentPlans() async {
    final db = await getDB();
    return db.query('installment_plans', orderBy: 'created_at DESC');
  }

  // ── SCAN HISTORY ──────────────────────────────────────────

  static Future<void> insertScan(String barcode) async {
    final db = await getDB();
    await db.insert('scan_history', {
      'barcode': barcode,
      'scanned_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getScanHistory(
      {int limit = 50}) async {
    final db = await getDB();
    return db.query('scan_history', orderBy: 'scanned_at DESC', limit: limit);
  }

  static Future<void> deleteScan(int id) async {
    final db = await getDB();
    await db.delete('scan_history', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearScanHistory() async {
    final db = await getDB();
    await db.delete('scan_history');
  }

  // ── RECURRING CANDIDATES (subscription auto-detection) ────

  /// Detect recurring expense patterns from history.
  /// Looks for expenses with similar descriptions appearing 2+ times
  /// at roughly monthly or weekly intervals.
  /// Returns candidates not yet dismissed by the user.
  static Future<List<Map<String, dynamic>>> detectRecurringCandidates() async {
    final db = await getDB();

    // Only run once per day
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastCheck = await getSetting('last_recurring_check');
    if (lastCheck == today) {
      // Return existing undismissed candidates
      return db.query('recurring_candidates',
          where: 'dismissed = 0', orderBy: 'avg_amount DESC');
    }
    await setSetting('last_recurring_check', today);

    // Get all expenses from last 90 days
    final since = DateTime.now()
        .subtract(const Duration(days: 90))
        .toIso8601String()
        .substring(0, 10);
    final expenses = await db.query('expenses',
        where: 'date >= ?', whereArgs: [since], orderBy: 'date ASC');

    if (expenses.length < 4) return [];

    // Group by normalized description (lowercase, strip common words)
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final e in expenses) {
      final raw = (e['item_name'] as String? ?? '').toLowerCase().trim();
      // Normalize: remove amounts, dates, "logged via", "imported from"
      final normalized = raw
          .replaceAll(RegExp(r'\d+'), '')
          .replaceAll(RegExp(r'logged via.*'), '')
          .replaceAll(RegExp(r'imported from.*'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (normalized.length < 3) continue;
      groups.putIfAbsent(normalized, () => []).add(e);
    }

    // Find groups with 2+ occurrences and roughly consistent intervals
    final candidates = <Map<String, dynamic>>[];
    for (final entry in groups.entries) {
      final items = entry.value;
      if (items.length < 2) continue;

      // Check interval consistency
      final dates = items
          .map((e) => DateTime.tryParse(e['date'] as String? ?? ''))
          .whereType<DateTime>()
          .toList()
        ..sort();
      if (dates.length < 2) continue;

      final intervals = <int>[];
      for (int i = 1; i < dates.length; i++) {
        intervals.add(dates[i].difference(dates[i - 1]).inDays);
      }
      final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

      // Classify frequency
      String? frequency;
      if (avgInterval >= 25 && avgInterval <= 35) {
        frequency = 'monthly';
      } else if (avgInterval >= 6 && avgInterval <= 8) {
        frequency = 'weekly';
      } else if (avgInterval >= 13 && avgInterval <= 16) {
        frequency = 'biweekly';
      }
      if (frequency == null) continue;

      // Check if already in recurring table (don't suggest what's already tracked)
      final existing = await db.query('recurring',
          where: 'LOWER(title) LIKE ?',
          whereArgs: [
            '%${entry.key.substring(0, entry.key.length.clamp(0, 10))}%'
          ]);
      if (existing.isNotEmpty) continue;

      // Check if already a candidate
      final alreadyCandidate = await db.query('recurring_candidates',
          where: 'description = ?', whereArgs: [entry.key]);
      if (alreadyCandidate.isNotEmpty) continue;

      final amounts =
          items.map((e) => (e['amount'] as num).toDouble()).toList();
      final avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;
      final category = items.last['category'] as String? ?? 'Others';
      final lastSeen = (items.last['date'] as String).substring(0, 10);

      candidates.add({
        'description': entry.key,
        'category': category,
        'avg_amount': avgAmount,
        'frequency': frequency,
        'last_seen': lastSeen,
        'dismissed': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Insert new candidates
    for (final c in candidates) {
      try {
        await db.insert('recurring_candidates', c,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (_) {}
    }

    return db.query('recurring_candidates',
        where: 'dismissed = 0', orderBy: 'avg_amount DESC');
  }

  static Future<void> dismissRecurringCandidate(int id) async {
    final db = await getDB();
    await db.update('recurring_candidates', {'dismissed': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearRecurringCandidates() async {
    final db = await getDB();
    await db.delete('recurring_candidates');
  }

  // ── CONVERSATION SUMMARIES ────────────────────────────────

  static Future<void> saveConversationSummary(
      String summary, int messageCount) async {
    final db = await getDB();
    await db.insert('conversation_summaries', {
      'summary': summary,
      'message_count_at_summary': messageCount,
      'created_at': DateTime.now().toIso8601String(),
    });
    // Keep only the latest 3 summaries to avoid bloat
    final all = await db.query('conversation_summaries',
        orderBy: 'id DESC', limit: 100);
    if (all.length > 3) {
      final toDelete = all.skip(3).map((r) => r['id'] as int).toList();
      for (final id in toDelete) {
        await db
            .delete('conversation_summaries', where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  static Future<String?> getLatestConversationSummary() async {
    final db = await getDB();
    final rows =
        await db.query('conversation_summaries', orderBy: 'id DESC', limit: 1);
    return rows.isEmpty ? null : rows.first['summary'] as String?;
  }

  static Future<void> clearConversationSummaries() async {
    final db = await getDB();
    await db.delete('conversation_summaries');
  }

  // ── WALLETS ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getWallets() async {
    final db = await getDB();
    return db.query('wallets', orderBy: 'id ASC');
  }

  static Future<double> getTotalWalletBalance() async {
    final wallets = await getWallets();
    return wallets.fold<double>(0, (s, w) => s + (w['balance'] as num));
  }

  static Future<void> setWalletBalance(int id, double balance) async {
    final db = await getDB();
    final updated = {'balance': balance, 'updated_at': DateTime.now().toIso8601String()};
    await db.update('wallets', updated, where: 'id = ?', whereArgs: [id]);
    // Sync to Firestore immediately
    final rows = await db.query('wallets', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isNotEmpty) {
      try { CloudService.pushDoc('wallets', rows.first); } catch (_) {}
    }
    fireEvent(AppEvent.incomeChanged); // refresh profile/net worth
  }

  static Future<int> insertWallet(Map<String, dynamic> data) async {
    final db = await getDB();
    final id = await db.insert('wallets', {
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
    });
    // Sync to Firestore immediately
    try { CloudService.pushDoc('wallets', {...data, 'id': id, 'updated_at': DateTime.now().toIso8601String()}); } catch (_) {}
    fireEvent(AppEvent.incomeChanged);
    return id;
  }

  static Future<void> deleteWallet(int id) async {
    final db = await getDB();
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
    // Remove from Firestore
    try { CloudService.deleteDoc('wallets', id); } catch (_) {}
    fireEvent(AppEvent.incomeChanged);
  }

  /// Find wallet by name (case-insensitive partial match) — used by AI action
  static Future<Map<String, dynamic>?> findWalletByName(String name) async {
    final wallets = await getWallets();
    final lower = name.toLowerCase();
    // Exact match first
    for (final w in wallets) {
      if ((w['name'] as String).toLowerCase() == lower) return w;
    }
    // Partial match
    for (final w in wallets) {
      if ((w['name'] as String).toLowerCase().contains(lower) ||
          lower.contains((w['name'] as String).toLowerCase())) return w;
    }
    return null;
  }
}
