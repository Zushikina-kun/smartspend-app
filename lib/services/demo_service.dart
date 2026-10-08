import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'db_service.dart';
import 'cloud_service.dart';
import 'category_service.dart';
import '../models/user_profile.dart';

/// DemoService — loads a fully-populated, realistic demo dataset.
///
/// Design goals:
/// • Every screen and feature has data to show — no blank/empty states during a demo.
/// • Data is CRUD-able — user can edit, delete, add on top of demo data.
/// • Data persists across app restarts (it's just normal local SQLite rows).
/// • "Reset to demo defaults" reloads the full seed, clearing everything first.
/// • Cloud sync is suppressed during load so demo data never leaks to Firestore.
class DemoService {
  // Suppress Firestore sync while loading so demo data stays local-only.
  static bool _isDemoLoading = false;
  static bool get isDemoLoading => _isDemoLoading;

  // ── Demo "user" identity ───────────────────────────────────────────────────
  // Used as the UID key for the local profile row.
  static const _demoUid = 'demo_user';

  static Future<void> loadSampleData() async {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    _isDemoLoading = true;

    // ── 1. WIPE everything relevant ──────────────────────────────────────────
    await _clearAll();

    final db = await DBService.getDB();

    // ── 2. PROFILE ───────────────────────────────────────────────────────────
    // Uses a publicly available placeholder avatar so no local asset is needed.
    // In a real capstone demo, replace photoUrl with a bundled asset path or
    // a stable URL pointing to the presenter's own photo.
    final demoUid = FirebaseAuth.instance.currentUser?.uid ?? _demoUid;
    final profile = UserProfile(
      uid: demoUid,
      firstName: 'Brix Angelo',
      lastName: 'Directo',
      middleName: 'Santos',
      email: 'brix.directo@lorma.edu',
      birthdate: '2002-05-15',
      address: 'San Fernando City, La Union, Philippines',
      phone: '09XX-XXX-XXXX',
      // Generic avatar — works offline, no Firebase Storage needed for demo
      photoUrl:
          'https://ui-avatars.com/api/?name=Brix+Directo&size=256&background=00C896&color=fff&bold=true',
    );
    await DBService.saveProfile(profile);

    // ── 3. SETTINGS ──────────────────────────────────────────────────────────
    await DBService.setSetting('account_type', 'student');
    await DBService.setSetting('income_frequency', 'daily');
    await DBService.setSetting('income_wallet_mode', 'true');
    await DBService.setSetting('payday_date', '1'); // 1st of month
    await DBService.setSetting('show_dti', 'true');
    await DBService.setSetting('show_emergency_fund', 'true');
    await DBService.setSetting('show_milestones', 'true');
    await DBService.setSetting('show_market_insights', 'true');
    // 50/30/20 custom category assignments
    await DBService.setSetting(
        'custom_needs_cats', 'Food,Transportation,Bills,Health,School');
    await DBService.setSetting(
        'custom_wants_cats', 'Entertainment,Shopping,Personal Care,Gaming');
    // Monthly income — ₱6,600 (₱300/day × 22 school days)
    await DBService.setMonthlyIncome(6600, source: 'demo');

    // ── 4. WALLETS ───────────────────────────────────────────────────────────
    // Clear existing wallets, then seed 3 realistic ones.
    await db.delete('wallets');
    await db.delete('wallet_history');
    final walletNow = now.toIso8601String();
    final cashId = await db.insert('wallets', {
      'name': 'Cash on Hand',
      'type': 'cash',
      'balance': 547.0,
      'updated_at': walletNow,
    });
    final gcashId = await db.insert('wallets', {
      'name': 'GCash',
      'type': 'ewallet',
      'balance': 1312.50,
      'updated_at': walletNow,
    });
    final bdoId = await db.insert('wallets', {
      'name': 'BDO Savings',
      'type': 'bank',
      'balance': 4250.0,
      'updated_at': walletNow,
    });
    // Seed some wallet history so the History sheet is populated
    final _wh = [
      {
        'wallet_id': gcashId,
        'old': 0.0,
        'new': 6600.0,
        'delta': 6600.0,
        'reason': 'Allowance received',
        'source': 'manual',
        'days': 30
      },
      {
        'wallet_id': gcashId,
        'old': 6600.0,
        'new': 2812.50,
        'delta': -3787.50,
        'reason': 'HomeCredit payment',
        'source': 'ai',
        'days': 15
      },
      {
        'wallet_id': gcashId,
        'old': 2812.50,
        'new': 1312.50,
        'delta': -1500.0,
        'reason': 'Part-time income',
        'source': 'manual',
        'days': 7
      },
      {
        'wallet_id': cashId,
        'old': 0.0,
        'new': 1000.0,
        'delta': 1000.0,
        'reason': 'Weekly allowance',
        'source': 'manual',
        'days': 7
      },
      {
        'wallet_id': cashId,
        'old': 1000.0,
        'new': 547.0,
        'delta': -453.0,
        'reason': 'Daily expenses',
        'source': 'ai',
        'days': 1
      },
      {
        'wallet_id': bdoId,
        'old': 5000.0,
        'new': 4250.0,
        'delta': -750.0,
        'reason': 'ATM withdrawal',
        'source': 'manual',
        'days': 3
      },
    ];
    for (final h in _wh) {
      await db.insert('wallet_history', {
        'wallet_id': h['wallet_id'],
        'old_balance': h['old'],
        'new_balance': h['new'],
        'delta': h['delta'],
        'reason': h['reason'],
        'source': h['source'],
        'timestamp':
            now.subtract(Duration(days: h['days'] as int)).toIso8601String(),
      });
    }

    // ── 5. CUSTOM CATEGORIES ─────────────────────────────────────────────────
    try {
      await DBService.insertCustomCategory({'name': 'School', 'icon': null});
    } catch (_) {}
    try {
      await DBService.insertCustomCategory(
          {'name': 'Personal Care', 'icon': null});
    } catch (_) {}
    try {
      await DBService.insertCustomCategory({'name': 'Gaming', 'icon': null});
    } catch (_) {}
    try {
      await DBService.insertCustomCategory({'name': 'Allowance', 'icon': null});
    } catch (_) {}
    CategoryService.invalidate();

    // ── 6. EXPENSES ──────────────────────────────────────────────────────────
    // ~35 entries spread across 3 months — enough for all charts, analytics,
    // period comparison, daily trend, heatmap, and a healthy FHS score.
    final expenses = [
      // ── TODAY / YESTERDAY ────────────────────────────────────────────────
      {
        'item_name': 'Jeepney Fare',
        'category': 'Transportation',
        'amount': 13.0,
        'shop': null,
        'pay': 'Cash',
        'days': 0,
        'time': '07:15',
        'want': 0
      },
      {
        'item_name': 'Canteen Lunch',
        'category': 'Food',
        'amount': 65.0,
        'shop': 'School Canteen',
        'pay': 'Cash',
        'days': 0,
        'time': '12:00',
        'want': 0
      },
      {
        'item_name': 'Jollibee Chickenjoy',
        'category': 'Food',
        'amount': 149.0,
        'shop': 'Jollibee',
        'pay': 'Cash',
        'days': 1,
        'time': '18:30',
        'want': 1
      },
      {
        'item_name': 'Tricycle Fare',
        'category': 'Transportation',
        'amount': 20.0,
        'shop': null,
        'pay': 'Cash',
        'days': 1,
        'time': '19:10',
        'want': 0
      },
      // ── THIS WEEK ────────────────────────────────────────────────────────
      {
        'item_name': 'Globe Load ₱99',
        'category': 'Bills',
        'amount': 99.0,
        'shop': 'Globe',
        'pay': 'GCash',
        'days': 2,
        'time': '10:00',
        'want': 0
      },
      {
        'item_name': 'Notebook & Ballpen',
        'category': 'School',
        'amount': 75.0,
        'shop': 'National Bookstore',
        'pay': 'Cash',
        'days': 3,
        'time': '14:00',
        'want': 0
      },
      {
        'item_name': 'Grab Ride Home',
        'category': 'Transportation',
        'amount': 85.0,
        'shop': null,
        'pay': 'GCash',
        'days': 3,
        'time': '19:00',
        'want': 0
      },
      {
        'item_name': 'Shopee — USB-C Hub',
        'category': 'Shopping',
        'amount': 350.0,
        'shop': 'Shopee',
        'pay': 'GCash',
        'days': 4,
        'time': '20:00',
        'want': 1
      },
      {
        'item_name': 'Mang Inasal Dinner',
        'category': 'Food',
        'amount': 155.0,
        'shop': 'Mang Inasal',
        'pay': 'Cash',
        'days': 5,
        'time': '18:30',
        'want': 1
      },
      {
        'item_name': 'Watsons — Paracetamol',
        'category': 'Health',
        'amount': 45.0,
        'shop': 'Watsons',
        'pay': 'Cash',
        'days': 6,
        'time': '16:30',
        'want': 0
      },
      // ── THIS MONTH ───────────────────────────────────────────────────────
      {
        'item_name': 'Mobile Legends Diamonds',
        'category': 'Gaming',
        'amount': 100.0,
        'shop': 'Codashop',
        'pay': 'GCash',
        'days': 8,
        'time': '21:00',
        'want': 1
      },
      {
        'item_name': '7-Eleven Snacks',
        'category': 'Food',
        'amount': 78.0,
        'shop': '7-Eleven',
        'pay': 'Cash',
        'days': 9,
        'time': '22:00',
        'want': 1
      },
      {
        'item_name': 'Printing — Capstone Docs',
        'category': 'School',
        'amount': 120.0,
        'shop': 'Print Shop',
        'pay': 'Cash',
        'days': 11,
        'time': '09:30',
        'want': 0
      },
      {
        'item_name': 'SM Grocery',
        'category': 'Food',
        'amount': 580.0,
        'shop': 'SM Supermarket',
        'pay': 'GCash',
        'days': 12,
        'time': '15:00',
        'want': 0
      },
      {
        'item_name': 'HomeCredit — Poco F8 Ultra',
        'category': 'Bills',
        'amount': 4104.0,
        'shop': 'HomeCredit',
        'pay': 'GCash',
        'days': 15,
        'time': '09:00',
        'want': 0
      },
      {
        'item_name': 'Mercury Drug — Vitamins',
        'category': 'Health',
        'amount': 180.0,
        'shop': 'Mercury Drug',
        'pay': 'Cash',
        'days': 18,
        'time': '16:00',
        'want': 0
      },
      {
        'item_name': 'Spotify Premium',
        'category': 'Entertainment',
        'amount': 129.0,
        'shop': 'Spotify',
        'pay': 'GCash',
        'days': 20,
        'time': '09:00',
        'want': 1
      },
      {
        'item_name': 'Haircut',
        'category': 'Personal Care',
        'amount': 120.0,
        'shop': 'Barbershop',
        'pay': 'Cash',
        'days': 22,
        'time': '14:00',
        'want': 1
      },
      {
        'item_name': 'Tuition Installment',
        'category': 'School',
        'amount': 3500.0,
        'shop': 'Lorma Colleges',
        'pay': 'Cash',
        'days': 25,
        'time': '09:00',
        'want': 0
      },
      {
        'item_name': 'Shopee — Mechanical Keyboard',
        'category': 'Shopping',
        'amount': 1680.0,
        'shop': 'Shopee',
        'pay': 'GCash',
        'days': 27,
        'time': '11:00',
        'want': 1
      },
      // ── LAST MONTH ───────────────────────────────────────────────────────
      {
        'item_name': 'Jollibee Lunch',
        'category': 'Food',
        'amount': 185.0,
        'shop': 'Jollibee',
        'pay': 'Cash',
        'days': 33,
        'time': '12:30',
        'want': 1
      },
      {
        'item_name': 'Jeepney Fares (week)',
        'category': 'Transportation',
        'amount': 130.0,
        'shop': null,
        'pay': 'Cash',
        'days': 35,
        'time': '12:00',
        'want': 0
      },
      {
        'item_name': 'Tuition Installment',
        'category': 'School',
        'amount': 3500.0,
        'shop': 'Lorma Colleges',
        'pay': 'Cash',
        'days': 38,
        'time': '09:00',
        'want': 0
      },
      {
        'item_name': 'HomeCredit — Poco F8 Ultra',
        'category': 'Bills',
        'amount': 4104.0,
        'shop': 'HomeCredit',
        'pay': 'GCash',
        'days': 45,
        'time': '09:00',
        'want': 0
      },
      {
        'item_name': 'Grocery Shopping',
        'category': 'Food',
        'amount': 620.0,
        'shop': 'Robinsons',
        'pay': 'Cash',
        'days': 42,
        'time': '15:00',
        'want': 0
      },
      {
        'item_name': 'Smart Load ₱99',
        'category': 'Bills',
        'amount': 99.0,
        'shop': 'Smart',
        'pay': 'GCash',
        'days': 45,
        'time': '11:00',
        'want': 0
      },
      {
        'item_name': 'Cinema Ticket',
        'category': 'Entertainment',
        'amount': 250.0,
        'shop': 'SM Cinema',
        'pay': 'Cash',
        'days': 50,
        'time': '15:00',
        'want': 1
      },
      {
        'item_name': 'Mercury Drug — Meds',
        'category': 'Health',
        'amount': 95.0,
        'shop': 'Mercury Drug',
        'pay': 'Cash',
        'days': 52,
        'time': '17:00',
        'want': 0
      },
      // ── TWO MONTHS AGO ───────────────────────────────────────────────────
      {
        'item_name': 'Tuition Installment',
        'category': 'School',
        'amount': 3500.0,
        'shop': 'Lorma Colleges',
        'pay': 'Cash',
        'days': 68,
        'time': '09:00',
        'want': 0
      },
      {
        'item_name': 'HomeCredit — Poco F8 Ultra',
        'category': 'Bills',
        'amount': 4104.0,
        'shop': 'HomeCredit',
        'pay': 'GCash',
        'days': 75,
        'time': '09:00',
        'want': 0
      },
      {
        'item_name': 'Grocery Shopping',
        'category': 'Food',
        'amount': 540.0,
        'shop': 'SM Supermarket',
        'pay': 'Cash',
        'days': 70,
        'time': '14:00',
        'want': 0
      },
      {
        'item_name': 'Shopee — Study Lamp',
        'category': 'Shopping',
        'amount': 299.0,
        'shop': 'Shopee',
        'pay': 'GCash',
        'days': 72,
        'time': '20:00',
        'want': 1
      },
      {
        'item_name': 'Grab Food Delivery',
        'category': 'Food',
        'amount': 220.0,
        'shop': 'GrabFood',
        'pay': 'GCash',
        'days': 65,
        'time': '19:30',
        'want': 1
      },
      {
        'item_name': 'Jeepney Fare',
        'category': 'Transportation',
        'amount': 65.0,
        'shop': null,
        'pay': 'Cash',
        'days': 63,
        'time': '07:00',
        'want': 0
      },
      {
        'item_name': 'Spotify Premium',
        'category': 'Entertainment',
        'amount': 129.0,
        'shop': 'Spotify',
        'pay': 'GCash',
        'days': 80,
        'time': '09:00',
        'want': 1
      },
    ];

    for (final e in expenses) {
      final d = now.subtract(Duration(days: e['days'] as int));
      await DBService.insertExpense({
        'item_name': e['item_name'],
        'category': e['category'],
        'amount': e['amount'],
        'date': fmt.format(d),
        'time': e['time'] ?? '12:00',
        'payment_method': e['pay'],
        'shop_name': e['shop'],
        'notes': null,
        'ai_generated': 1,
        'confidence_score': 0.95,
        'is_want': e['want'] ?? 0,
        'updated_at': d.toIso8601String(),
      });
    }

    // ── 7. BUDGETS ───────────────────────────────────────────────────────────
    await DBService.setBudget('Food', 2000, source: 'demo');
    await DBService.setBudget('Transportation', 600, source: 'demo');
    await DBService.setBudget('Bills', 5000, source: 'demo');
    await DBService.setBudget('Entertainment', 300, source: 'demo');
    await DBService.setBudget('Shopping', 500, source: 'demo');
    await DBService.setBudget('School', 4500, source: 'demo');
    await DBService.setBudget('Health', 300, source: 'demo');
    await DBService.setBudget('Personal Care', 200, source: 'demo');
    await DBService.setBudget('Gaming', 200, source: 'demo');

    // ── 8. INCOME ────────────────────────────────────────────────────────────
    // Three months of allowance + a part-time income entry this month
    for (int m = 0; m < 3; m++) {
      final d = DateTime(now.year, now.month - m, 1);
      await DBService.insertIncome({
        'title': 'Monthly Allowance',
        'amount': 6600.0,
        'category': 'Allowance',
        'date': fmt.format(d),
        'is_recurring': 1,
        'notes': 'From parents — ₱300/day × 22 days',
      });
    }
    await DBService.insertIncome({
      'title': 'Part-time — Encoding Job',
      'amount': 1500.0,
      'category': 'Freelance',
      'date': fmt.format(now.subtract(const Duration(days: 7))),
      'is_recurring': 0,
      'notes': 'Data encoding for local business',
    });

    // ── 9. SAVINGS GOALS ─────────────────────────────────────────────────────
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
      'purpose': 'Baguio trip with batchmates after defense',
      'target_amount': 8000.0,
      'current_amount': 1500.0,
      'start_date': fmt.format(now.subtract(const Duration(days: 14))),
      'deadline': fmt.format(now.add(const Duration(days: 150))),
      'created_at': now.toIso8601String(),
    });

    // ── 10. RECURRING ─────────────────────────────────────────────────────────
    await DBService.insertRecurring({
      'title': 'Tuition Installment',
      'amount': 3500.0,
      'category': 'School',
      'frequency': 'monthly',
      'next_date': fmt.format(DateTime(now.year, now.month + 1, 5)),
      'start_date': fmt.format(now.subtract(const Duration(days: 90))),
      'is_expense': 1,
      'notes': 'Lorma Colleges — 2nd sem installment',
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
      'title': 'HomeCredit — Poco F8 Ultra',
      'amount': 4104.0,
      'category': 'Bills',
      'frequency': 'monthly',
      'next_date': fmt.format(DateTime(now.year, now.month + 1, 15)),
      'start_date': fmt.format(now.subtract(const Duration(days: 90))),
      'is_expense': 1,
      'notes': '18-month plan, ₱73,878 total',
    });
    await DBService.insertRecurring({
      'title': 'Monthly Allowance',
      'amount': 6600.0,
      'category': 'Allowance',
      'frequency': 'monthly',
      'next_date': fmt.format(DateTime(now.year, now.month + 1, 1)),
      'start_date': fmt.format(now.subtract(const Duration(days: 180))),
      'is_expense': 0,
      'notes': 'From parents',
    });

    // ── 11. DEBTS ─────────────────────────────────────────────────────────────
    await DBService.insertDebt({
      'title': 'Capstone materials (3D printing)',
      'person': 'Kuya Mark',
      'amount': 1500.0,
      'paid_amount': 500.0,
      'type': 'owe',
      'due_date': fmt.format(now.add(const Duration(days: 30))),
      'notes': 'For 3D printing + project parts',
      'created_at': now.toIso8601String(),
    });
    await DBService.insertDebt({
      'title': 'Lent for jeepney fare',
      'person': 'Trisha',
      'amount': 200.0,
      'paid_amount': 0.0,
      'type': 'lent',
      'due_date': fmt.format(now.add(const Duration(days: 7))),
      'notes': null,
      'created_at': now.toIso8601String(),
    });
    await DBService.insertDebt({
      'title': 'Group snacks money',
      'person': 'Djaunathan',
      'amount': 350.0,
      'paid_amount': 0.0,
      'type': 'owe',
      'due_date': fmt.format(now.add(const Duration(days: 14))),
      'notes': 'From capstone overnight session',
      'created_at': now.toIso8601String(),
    });

    // ── 12. INSTALLMENT PLANS ─────────────────────────────────────────────────
    await db.delete('installment_plans');
    await DBService.insertInstallmentPlan({
      'title': 'Poco F8 Ultra 16GB/512GB',
      'provider': 'HomeCredit',
      'total_amount': 73878.0,
      'monthly_payment': 4104.0,
      'months_total': 18,
      'months_paid': 3,
      'due_day': 15,
      'interest_rate': 3.99,
      'start_date': fmt.format(now.subtract(const Duration(days: 90))),
      'category': 'Bills',
      'notes': 'Poco F8 Ultra 16GB/512GB — ₱42,999 SRP via HomeCredit',
      'created_at': now.toIso8601String(),
    });
    await DBService.insertInstallmentPlan({
      'title': 'Shopee — Mechanical Keyboard',
      'provider': 'ShopeePay Later',
      'total_amount': 1680.0,
      'monthly_payment': 560.0,
      'months_total': 3,
      'months_paid': 1,
      'due_day': 5,
      'interest_rate': 0.0,
      'start_date': fmt.format(now.subtract(const Duration(days: 35))),
      'category': 'Shopping',
      'notes': 'Mechanical keyboard — 0% interest SPayLater',
      'created_at': now.toIso8601String(),
    });

    // ── 13. INSURANCE & CONTRIBUTIONS ────────────────────────────────────────
    await db.delete('insurance_policies');
    await DBService.insertInsurancePolicy({
      'name': 'SSS Voluntary Contribution',
      'provider': 'SSS',
      'type': 'government',
      'premium_amount': 1400.0,
      'frequency': 'monthly',
      'next_due_date': fmt.format(now.add(const Duration(days: 12))),
      'last_paid_date': fmt.format(now.subtract(const Duration(days: 18))),
      'created_at': now.toIso8601String(),
      'notes': 'RS-5 contribution bracket',
    });
    await DBService.insertInsurancePolicy({
      'name': 'PhilHealth Contribution',
      'provider': 'PhilHealth',
      'type': 'government',
      'premium_amount': 500.0,
      'frequency': 'monthly',
      'next_due_date': fmt.format(now.add(const Duration(days: 5))),
      'last_paid_date': fmt.format(now.subtract(const Duration(days: 25))),
      'created_at': now.toIso8601String(),
      'notes': 'Indirect contributor',
    });
    await DBService.insertInsurancePolicy({
      'name': 'Pag-IBIG MP2 Savings',
      'provider': 'Pag-IBIG',
      'type': 'government',
      'premium_amount': 500.0,
      'frequency': 'monthly',
      'next_due_date': fmt.format(now.subtract(const Duration(days: 3))),
      'last_paid_date': fmt.format(now.subtract(const Duration(days: 33))),
      'created_at': now.toIso8601String(),
      'notes': 'Modified Pag-IBIG II — higher dividend rate',
    });
    await DBService.insertInsurancePolicy({
      'name': 'Sun Life Student Term Plan',
      'provider': 'Sun Life',
      'type': 'life',
      'premium_amount': 350.0,
      'frequency': 'quarterly',
      'next_due_date': fmt.format(now.add(const Duration(days: 45))),
      'last_paid_date': fmt.format(now.subtract(const Duration(days: 45))),
      'created_at': now.toIso8601String(),
      'notes': '₱100K coverage, 5-year term',
    });

    // ── 14. PALUWAGAN ─────────────────────────────────────────────────────────
    try {
      await db.delete('paluwagan');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS paluwagan(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          amount REAL NOT NULL,
          members INTEGER NOT NULL,
          frequency TEXT DEFAULT 'monthly',
          current_round INTEGER DEFAULT 1,
          my_turn INTEGER DEFAULT 1,
          start_date TEXT,
          notes TEXT,
          created_at TEXT NOT NULL
        )
      ''');
      await db.insert('paluwagan', {
        'name': 'Barkada Paluwagan',
        'amount': 500.0,
        'members': 6,
        'frequency': 'monthly',
        'current_round': 3,
        'my_turn': 5,
        'start_date': fmt.format(now.subtract(const Duration(days: 60))),
        'notes': '6 members × ₱500/month — my turn is round 5',
        'created_at': now.toIso8601String(),
      });
      await db.insert('paluwagan', {
        'name': 'Family Paluwagan',
        'amount': 1000.0,
        'members': 10,
        'frequency': 'monthly',
        'current_round': 2,
        'my_turn': 8,
        'start_date': fmt.format(now.subtract(const Duration(days: 30))),
        'notes': '10 members × ₱1,000/month — pot = ₱10,000',
        'created_at': now.toIso8601String(),
      });
    } catch (_) {}

    // ── 15. SCORE HISTORY ─────────────────────────────────────────────────────
    await db.delete('score_history');
    final scoreSeeds = [
      68,
      72,
      70,
      75,
      73,
      78,
      76,
      74,
      80,
      77,
      79,
      82,
      80,
      78,
      83,
      81,
      79,
      76,
      80,
      78,
      75,
      82,
      80,
      83,
      85,
      82,
      80,
      83,
      80,
      77
    ];
    for (int i = 0; i < scoreSeeds.length; i++) {
      final daysAgo = scoreSeeds.length - i;
      await db.insert('score_history', {
        'score': scoreSeeds[i],
        'date': fmt.format(now.subtract(Duration(days: daysAgo))),
        'reason': i % 4 == 0
            ? 'overspend_control'
            : i % 4 == 1
                ? 'savings_rate'
                : i % 4 == 2
                    ? 'logging_consistency'
                    : 'budget_adherence',
      });
    }

    // ── 16. MOOD LOG ──────────────────────────────────────────────────────────
    await db.delete('mood_log');
    final moodData = [
      (3, 'Busy day with classes'),
      (4, 'Finished capstone chapter!'),
      (2, 'Stressed about deadlines'),
      (4, 'Good lunch with friends'),
      (3, 'Normal day'),
      (5, 'Weekend — very relaxed'),
      (2, 'Exam week stress'),
      (3, 'Getting through it'),
      (4, 'Productive day'),
      (4, 'Feeling good'),
      (3, 'Defense prep'),
      (5, 'Great feedback from panel'),
      (4, 'Nearly done!'),
      (3, 'Tired but okay'),
    ];
    for (int i = 0; i < moodData.length; i++) {
      final daysAgo = moodData.length - i;
      await db.insert(
          'mood_log',
          {
            'date': fmt.format(now.subtract(Duration(days: daysAgo))),
            'mood_score': moodData[i].$1,
            'note': moodData[i].$2,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // ── 17. CATEGORY RULES ────────────────────────────────────────────────────
    final rules = [
      ('jollibee', 'Food'),
      ('mang inasal', 'Food'),
      ('mcdo', 'Food'),
      ('kfc', 'Food'),
      ('canteen', 'Food'),
      ('grabfood', 'Food'),
      ('mercury drug', 'Health'),
      ('watsons', 'Health'),
      ('national bookstore', 'School'),
      ('lorma', 'School'),
      ('homecredit', 'Bills'),
      ('globe', 'Bills'),
      ('smart', 'Bills'),
      ('meralco', 'Bills'),
      ('pldt', 'Bills'),
      ('shopee', 'Shopping'),
      ('lazada', 'Shopping'),
      ('spotify', 'Entertainment'),
      ('netflix', 'Entertainment'),
      ('grab', 'Transportation'),
      ('angkas', 'Transportation'),
      ('codashop', 'Gaming'),
      ('steam', 'Gaming'),
      ('cobra', 'Food'),
      ('nestea', 'Food'),
      ('sting', 'Food'),
    ];
    for (final r in rules) {
      try {
        await DBService.insertCategoryRule(r.$1, r.$2);
      } catch (_) {}
    }

    // ── 18. SCAN HISTORY ─────────────────────────────────────────────────────
    await db.delete('scan_history');
    final scans = [
      ('4800016010015', 0), // Lucky Me pancit canton
      ('4800888100016', 1), // Cobra energy drink
      ('4800016010022', 3), // Lucky Me variant
      ('4800016010039', 5), // Sting
      ('4800016010046', 7), // Chippy
    ];
    for (final s in scans) {
      await db.insert('scan_history', {
        'barcode': s.$1,
        'scanned_at': now.subtract(Duration(days: s.$2)).toIso8601String(),
      });
    }

    // ── 19. CHAT SEED ─────────────────────────────────────────────────────────
    // Seed a few chat messages so Chat History isn't empty.
    // Create a "Previous chats" session for these.
    await db.delete('chat_history');
    await db.delete('chat_sessions');
    final chatSessionId = await db.insert('chat_sessions', {
      'title': 'Demo conversation',
      'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      'is_current': 0,
    });
    final currentSessionId = await db.insert('chat_sessions', {
      'title': null,
      'created_at': now.toIso8601String(),
      'is_current': 1,
    });
    final chatSeed = [
      ('user', 'I spent 65 pesos for lunch at the canteen', 3),
      (
        'ai',
        '✅ Got it! Logged **Canteen Lunch** — ₱65.00 under Food.\n\nYou\'ve spent ₱1,134 on Food so far this month — that\'s 57% of your ₱2,000 Food budget.',
        3
      ),
      ('user', 'How much have I spent this month?', 2),
      (
        'ai',
        '📊 **This month so far:**\n\n• Food: ₱1,134 / ₱2,000 (57%)\n• School: ₱3,620 / ₱4,500 (80%)\n• Bills: ₱4,203 / ₱5,000 (84%)\n• Transportation: ₱283 / ₱600 (47%)\n• Entertainment: ₱129 / ₱300 (43%)\n\n**Total spent:** ₱9,869\n**Remaining budget:** ₱1,131\n\nYou\'re doing well on Transportation and Entertainment! Watch your School and Bills budgets.',
        2
      ),
      ('user', 'How is my financial health score?', 1),
      (
        'ai',
        '💚 Your **Financial Health Score is 80/100** — Great!\n\n**Breakdown:**\n• Savings Rate: 22/25 — Saving ~18% of income\n• Overspend Control: 21/25 — 2 soft-overspend days this month\n• Budget Adherence: 19/25 — Bills and School are at 80%+\n• Logging Consistency: 18/25 — You\'ve logged 18 of 22 days\n\nTip: Log expenses daily to maximize the Logging Consistency component! 📝',
        1
      ),
    ];
    for (final c in chatSeed) {
      await db.insert('chat_history', {
        'role': c.$1,
        'message': c.$2,
        'timestamp': now.subtract(Duration(days: c.$3)).toIso8601String(),
        'session_id': chatSessionId,
      });
    }

    _isDemoLoading = false;
  }

  // ── CLEAR ALL demo-related tables ─────────────────────────────────────────
  static Future<void> _clearAll() async {
    final db = await DBService.getDB();
    await db.delete('expenses');
    await db.delete('budgets');
    await db.delete('savings_goals');
    await db.delete('income');
    await db.delete('recurring');
    await db.delete('debts');
    await db.delete('score_history');
    await db.delete('mood_log');
    await db.delete('chat_history');
    await db.delete('chat_sessions');
    await db.delete('wallet_history');
    try {
      await db.delete('custom_categories');
    } catch (_) {}
    try {
      await db.delete('installment_plans');
    } catch (_) {}
    try {
      await db.delete('scan_history');
    } catch (_) {}
    try {
      await db.delete('insurance_policies');
    } catch (_) {}
    try {
      await db.delete('paluwagan');
    } catch (_) {}
    try {
      await db.delete('category_rules');
    } catch (_) {}
    try {
      await db.delete('budget_history');
    } catch (_) {}
    try {
      await db.delete('goal_contribution_history');
    } catch (_) {}
    try {
      await db.delete('income_history');
    } catch (_) {}
    CategoryService.invalidate();
  }

  /// Full wipe of all demo data. Alias for UI "Clear All Data".
  static Future<void> clearDemoData() async {
    _isDemoLoading = true;
    await _clearAll();
    _isDemoLoading = false;
    // If a real user is logged in, sync the wipe to Firestore too
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await CloudService.pushAll(
          expenses: [],
          budgets: [],
          goals: [],
          income: [],
          recurring: [],
          debts: [],
          customCategories: [],
          installments: [],
          installmentPlans: [],
          wallets: [],
          categoryRules: [],
        );
      } catch (_) {}
    }
  }
}
