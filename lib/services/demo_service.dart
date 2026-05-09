import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'db_service.dart';
import 'category_service.dart';

class DemoService {
  static Future<void> loadSampleData() async {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    final db = await DBService.getDB();
    await db.delete('expenses');
    await db.delete('budgets');
    await db.delete('savings_goals');
    await db.delete('income');
    await db.delete('recurring');
    await db.delete('debts');
    try {
      await db.delete('custom_categories');
    } catch (_) {}
    CategoryService.invalidate();

    // ─────────────────────────────────────────────────────────────────────────
    // EXPENSES
    // Clean, relatable Filipino daily transactions.
    // ~20 entries — enough to show charts, analytics, and health score.
    // Spread across this month + last month for comparison charts.
    // ─────────────────────────────────────────────────────────────────────────
    final expenses = [
      // ── THIS WEEK ──────────────────────────────────────────────────────────
      {
        'item_name': 'Jollibee Chickenjoy',
        'category': 'Food',
        'amount': 149.0,
        'shop_name': 'Jollibee',
        'payment_method': 'Cash',
        'days_ago': 0,
        'time': '12:30',
      },
      {
        'item_name': 'Jeepney Fare',
        'category': 'Transportation',
        'amount': 13.0,
        'shop_name': null,
        'payment_method': 'Cash',
        'days_ago': 0,
        'time': '07:15',
      },
      {
        'item_name': 'Globe Load ₱99',
        'category': 'Bills',
        'amount': 99.0,
        'shop_name': 'Globe',
        'payment_method': 'GCash',
        'days_ago': 1,
        'time': '10:00',
      },
      {
        'item_name': 'Canteen Lunch',
        'category': 'Food',
        'amount': 65.0,
        'shop_name': 'School Canteen',
        'payment_method': 'Cash',
        'days_ago': 2,
        'time': '12:00',
      },
      {
        'item_name': 'Tricycle Fare',
        'category': 'Transportation',
        'amount': 20.0,
        'shop_name': null,
        'payment_method': 'Cash',
        'days_ago': 3,
        'time': '07:00',
      },
      {
        'item_name': 'Notebook & Ballpen',
        'category': 'School',
        'amount': 75.0,
        'shop_name': 'National Bookstore',
        'payment_method': 'Cash',
        'days_ago': 4,
        'time': '14:00',
      },
      {
        'item_name': 'Mang Inasal Dinner',
        'category': 'Food',
        'amount': 155.0,
        'shop_name': 'Mang Inasal',
        'payment_method': 'Cash',
        'days_ago': 5,
        'time': '18:30',
      },
      {
        'item_name': 'Shopee — USB Hub',
        'category': 'Shopping',
        'amount': 350.0,
        'shop_name': 'Shopee',
        'payment_method': 'GCash',
        'days_ago': 6,
        'time': '20:00',
      },

      // ── THIS MONTH (1–3 weeks ago) ─────────────────────────────────────────
      {
        'item_name': 'Tuition Installment',
        'category': 'School',
        'amount': 3500.0,
        'shop_name': 'Lorma Colleges',
        'payment_method': 'Cash',
        'days_ago': 10,
        'time': '09:00',
      },
      {
        'item_name': 'SM Grocery',
        'category': 'Food',
        'amount': 580.0,
        'shop_name': 'SM Supermarket',
        'payment_method': 'GCash',
        'days_ago': 12,
        'time': '15:00',
      },
      {
        'item_name': 'Spotify Premium',
        'category': 'Entertainment',
        'amount': 129.0,
        'shop_name': 'Spotify',
        'payment_method': 'GCash',
        'days_ago': 15,
        'time': '09:00',
      },
      {
        'item_name': 'Mercury Drug — Vitamins',
        'category': 'Health',
        'amount': 180.0,
        'shop_name': 'Mercury Drug',
        'payment_method': 'Cash',
        'days_ago': 18,
        'time': '16:00',
      },
      {
        'item_name': 'Printing — Capstone Docs',
        'category': 'School',
        'amount': 120.0,
        'shop_name': 'Print Shop',
        'payment_method': 'Cash',
        'days_ago': 20,
        'time': '09:30',
      },
      {
        'item_name': 'Haircut',
        'category': 'Personal Care',
        'amount': 120.0,
        'shop_name': 'Barbershop',
        'payment_method': 'Cash',
        'days_ago': 22,
        'time': '14:00',
      },

      // ── LAST MONTH (for comparison charts) ────────────────────────────────
      {
        'item_name': 'Jollibee Lunch',
        'category': 'Food',
        'amount': 185.0,
        'shop_name': 'Jollibee',
        'payment_method': 'Cash',
        'days_ago': 33,
        'time': '12:30',
      },
      {
        'item_name': 'Jeepney Fares (week)',
        'category': 'Transportation',
        'amount': 130.0,
        'shop_name': null,
        'payment_method': 'Cash',
        'days_ago': 35,
        'time': '12:00',
      },
      {
        'item_name': 'Tuition Installment',
        'category': 'School',
        'amount': 3500.0,
        'shop_name': 'Lorma Colleges',
        'payment_method': 'Cash',
        'days_ago': 38,
        'time': '09:00',
      },
      {
        'item_name': 'Grocery Shopping',
        'category': 'Food',
        'amount': 620.0,
        'shop_name': 'Robinsons Supermarket',
        'payment_method': 'Cash',
        'days_ago': 42,
        'time': '15:00',
      },
      {
        'item_name': 'Smart Load ₱99',
        'category': 'Bills',
        'amount': 99.0,
        'shop_name': 'Smart',
        'payment_method': 'GCash',
        'days_ago': 45,
        'time': '11:00',
      },
      {
        'item_name': 'Cinema Ticket',
        'category': 'Entertainment',
        'amount': 250.0,
        'shop_name': 'SM Cinema',
        'payment_method': 'Cash',
        'days_ago': 50,
        'time': '15:00',
      },
    ];

    for (final e in expenses) {
      final date = now.subtract(Duration(days: e['days_ago'] as int));
      final category = e['category'] as String;
      // Set is_want based on category — Entertainment/Shopping = Want, rest = Need
      final isWant =
          ['Entertainment', 'Shopping', 'Personal Care'].contains(category)
              ? 1
              : 0;
      await DBService.insertExpense({
        'item_name': e['item_name'],
        'category': category,
        'amount': e['amount'],
        'date': fmt.format(date),
        'time': e['time'] ?? '12:00',
        'payment_method': e['payment_method'],
        'shop_name': e['shop_name'],
        'notes': null,
        'ai_generated': 1,
        'confidence_score': 0.95,
        'is_want': isWant,
      });
    }

    // ─────────────────────────────────────────────────────────────────────────
    // BUDGETS — student scale, slightly under-budget for a healthy score
    // ─────────────────────────────────────────────────────────────────────────
    await DBService.setBudget('Food', 2000);
    await DBService.setBudget('Transportation', 600);
    await DBService.setBudget('Bills', 300);
    await DBService.setBudget('Entertainment', 300);
    await DBService.setBudget('Shopping', 500);
    await DBService.setBudget('School', 4500);
    await DBService.setBudget('Health', 300);
    await DBService.setBudget('Personal Care', 200);

    // ─────────────────────────────────────────────────────────────────────────
    // SAVINGS GOALS — 3 clear student goals
    // ─────────────────────────────────────────────────────────────────────────
    await DBService.insertGoal({
      'name': 'New Laptop',
      'purpose': 'For capstone project and school work',
      'target_amount': 35000.0,
      'current_amount': 12000.0,
      'start_date': fmt.format(now.subtract(const Duration(days: 60))),
      'deadline': fmt.format(now.add(const Duration(days: 90))),
      'created_at': now.toIso8601String(),
    });
    await DBService.insertGoal({
      'name': 'Emergency Fund',
      'purpose': 'For unexpected expenses',
      'target_amount': 10000.0,
      'current_amount': 3500.0,
      'start_date': fmt.format(now.subtract(const Duration(days: 90))),
      'deadline': fmt.format(now.add(const Duration(days: 180))),
      'created_at': now.toIso8601String(),
    });
    await DBService.insertGoal({
      'name': 'Graduation Trip',
      'purpose': 'Baguio trip with batchmates',
      'target_amount': 8000.0,
      'current_amount': 1500.0,
      'start_date': fmt.format(now.subtract(const Duration(days: 14))),
      'deadline': fmt.format(now.add(const Duration(days: 150))),
      'created_at': now.toIso8601String(),
    });

    // ─────────────────────────────────────────────────────────────────────────
    // RECURRING — 3 clear recurring items
    // ─────────────────────────────────────────────────────────────────────────
    await DBService.insertRecurring({
      'title': 'Tuition Installment',
      'amount': 3500.0,
      'category': 'School',
      'frequency': 'monthly',
      'next_date': fmt.format(DateTime(now.year, now.month + 1, 5)),
      'start_date': fmt.format(now.subtract(const Duration(days: 90))),
      'is_expense': 1,
    });
    await DBService.insertRecurring({
      'title': 'Spotify Premium',
      'amount': 129.0,
      'category': 'Entertainment',
      'frequency': 'monthly',
      'next_date': fmt.format(DateTime(now.year, now.month + 1, 1)),
      'start_date': fmt.format(now.subtract(const Duration(days: 60))),
      'is_expense': 1,
    });
    await DBService.insertRecurring({
      'title': 'Monthly Allowance + Part-time',
      'amount': 10000.0,
      'category': 'Allowance',
      'frequency': 'monthly',
      'next_date': fmt.format(DateTime(now.year, now.month + 1, 1)),
      'start_date': fmt.format(now.subtract(const Duration(days: 180))),
      'is_expense': 0,
    });

    // ─────────────────────────────────────────────────────────────────────────
    // DEBTS — 2 simple, relatable entries
    // ─────────────────────────────────────────────────────────────────────────
    await DBService.insertDebt({
      'title': 'Borrowed for capstone materials',
      'person': 'Kuya Mark',
      'amount': 1500.0,
      'paid_amount': 500.0,
      'type': 'owe',
      'due_date': fmt.format(now.add(const Duration(days: 30))),
      'notes': 'For 3D printing and project parts',
      'created_at': now.toIso8601String(),
    });
    await DBService.insertDebt({
      'title': 'Lent for fare',
      'person': 'Trisha',
      'amount': 200.0,
      'paid_amount': 0.0,
      'type': 'lent',
      'due_date': fmt.format(now.add(const Duration(days: 7))),
      'notes': null,
      'created_at': now.toIso8601String(),
    });

    // ─────────────────────────────────────────────────────────────────────────
    // INCOME — this month + last month for analytics comparison
    // ─────────────────────────────────────────────────────────────────────────
    await DBService.insertIncome({
      'title': 'Monthly Allowance + Part-time',
      'amount': 10000.0,
      'category': 'Allowance',
      'date': fmt.format(DateTime(now.year, now.month, 1)),
      'is_recurring': 1,
    });
    await DBService.insertIncome({
      'title': 'Monthly Allowance + Part-time',
      'amount': 10000.0,
      'category': 'Allowance',
      'date': fmt.format(DateTime(now.year, now.month - 1, 1)),
      'is_recurring': 1,
    });

    // Set monthly income to ₱6,600 (student daily allowance ₱300 × 22 days)
    // This gives a realistic FHS in the 65–80 range with the 4-component formula
    final existingIncome = await DBService.getMonthlyIncome();
    if (existingIncome == 30000.0 ||
        existingIncome == 0.0 ||
        existingIncome == 10000.0) {
      await DBService.setMonthlyIncome(6600);
    }

    // Set account type to student
    await DBService.setSetting('account_type', 'student');
    // Set income frequency to daily (₱300/day)
    await DBService.setSetting('income_frequency', 'daily');

    // ─────────────────────────────────────────────────────────────────────────
    // CUSTOM CATEGORIES — 3 student-relevant samples
    // ─────────────────────────────────────────────────────────────────────────
    try {
      await DBService.insertCustomCategory({'name': 'School', 'icon': null});
      await DBService.insertCustomCategory(
          {'name': 'Personal Care', 'icon': null});
      await DBService.insertCustomCategory({'name': 'Allowance', 'icon': null});
    } catch (_) {}
    CategoryService.invalidate();

    // ─────────────────────────────────────────────────────────────────────────
    // SCORE HISTORY — seed 14 days of realistic scores so the chart looks good
    // Scores vary between 65–85 to show a realistic trend
    // ─────────────────────────────────────────────────────────────────────────
    final scoreSeeds = [72, 75, 78, 74, 80, 77, 82, 79, 76, 81, 78, 83, 80, 77];
    try {
      final db2 = await DBService.getDB();
      await db2.delete('score_history');
      for (int i = 0; i < scoreSeeds.length; i++) {
        final daysAgo = scoreSeeds.length - i;
        final dateStr = fmt.format(now.subtract(Duration(days: daysAgo)));
        await db2.insert('score_history', {
          'score': scoreSeeds[i],
          'date': dateStr,
        });
      }
    } catch (_) {}

    // ─────────────────────────────────────────────────────────────────────────
    // MOOD LOG — seed 10 days of mood entries so correlation card appears
    // Mix of moods to show realistic student life
    // ─────────────────────────────────────────────────────────────────────────
    final moodSeeds = [3, 4, 2, 4, 3, 5, 2, 3, 4, 4]; // 1=😞 5=😄
    final moodNotes = [
      'Busy day with classes',
      'Finished capstone chapter!',
      'Stressed about deadlines',
      'Good lunch with friends',
      'Normal day',
      'Weekend — relaxed',
      'Exam week stress',
      'Getting through it',
      'Productive day',
      'Feeling good',
    ];
    try {
      final db3 = await DBService.getDB();
      await db3.delete('mood_log');
      for (int i = 0; i < moodSeeds.length; i++) {
        final daysAgo = moodSeeds.length - i;
        final dateStr = fmt.format(now.subtract(Duration(days: daysAgo)));
        await db3.insert(
          'mood_log',
          {
            'date': dateStr,
            'mood_score': moodSeeds[i],
            'note': moodNotes[i],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (_) {}
  }

  static Future<void> clearDemoData() async {
    final db = await DBService.getDB();
    await db.delete('expenses');
    await db.delete('budgets');
    await db.delete('savings_goals');
    await db.delete('income');
    await db.delete('recurring');
    await db.delete('debts');
    await db.delete('score_history');
    try {
      await db.delete('custom_categories');
    } catch (_) {}
    CategoryService.invalidate();
  }
}
