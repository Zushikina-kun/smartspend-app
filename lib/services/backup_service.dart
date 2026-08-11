import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'db_service.dart';
import 'event_bus.dart';

/// Handles backup and restore of all app data as a JSON file.
/// Uses the system share sheet — user can save to phone storage,
/// email, Google Drive, Dropbox, or any app they choose.
/// No OAuth or cloud API required.
class BackupService {
  // ── EXPORT DATA ───────────────────────────────────────────

  static Future<Map<String, dynamic>> _exportData() async {
    final expenses = await DBService.getExpenses();
    final budgets = await DBService.getBudgets();
    final goals = await DBService.getGoals();
    final income = await DBService.getIncome();
    final recurring = await DBService.getRecurring();
    final debts = await DBService.getDebts();
    final scanHistory = await DBService.getScanHistory(limit: 200);
    final db = await DBService.getDB();
    List<Map<String, dynamic>> installments = [];
    try {
      installments = await db.query('installments');
    } catch (_) {}
    List<Map<String, dynamic>> installmentPlans = [];
    try {
      installmentPlans = await db.query('installment_plans');
    } catch (_) {}
    List<Map<String, dynamic>> customCategories = [];
    try {
      customCategories = await DBService.getCustomCategories();
    } catch (_) {}
    List<Map<String, dynamic>> categoryRules = [];
    try {
      categoryRules = await DBService.getCategoryRules();
    } catch (_) {}
    List<Map<String, dynamic>> moodLog = [];
    try {
      moodLog = await DBService.getMoodHistory(days: 365);
    } catch (_) {}
    List<Map<String, dynamic>> wallets = [];
    try {
      wallets = await DBService.getWallets();
    } catch (_) {}
    List<Map<String, dynamic>> insurancePolicies = [];
    try {
      insurancePolicies = await DBService.getInsurancePolicies();
    } catch (_) {}

    return {
      'version': 9,
      'exported_at': DateTime.now().toIso8601String(),
      'app_version': '2.6.0',
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'budgets': budgets.map((b) => b.toMap()).toList(),
      'goals': goals,
      'income': income,
      'recurring': recurring,
      'debts': debts,
      'scan_history': scanHistory,
      'installments': installments,
      'installment_plans': installmentPlans,
      'custom_categories': customCategories,
      'category_rules': categoryRules,
      'mood_log': moodLog,
      'wallets': wallets,
      'insurance_policies': insurancePolicies,
    };
  }

  // ── PUBLIC API ────────────────────────────────────────────

  /// Export backup as JSON and share via system share sheet.
  /// User can save to phone, email, Drive, Dropbox, etc.
  static Future<bool> backup() async {
    try {
      final now = DateTime.now();
      final fileFmt = DateFormat('yyyyMMdd_HHmmss');
      final displayFmt = DateFormat('MMM d, y HH:mm');

      final data = await _exportData();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      final dir = await getTemporaryDirectory();
      final fileName = 'SmartSpend_Backup_${fileFmt.format(now)}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Smart Spend Backup — ${displayFmt.format(now)}',
        text:
            'Smart Spend data backup. Import this file using Profile → Restore Backup.',
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Restore from a backup JSON file path (picked by user).
  static Future<BackupRestoreResult> restoreFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return BackupRestoreResult(
            success: false, message: "Backup file not found.");
      }

      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      int restored = 0;

      for (final e in (data['expenses'] as List? ?? [])) {
        try {
          await DBService.insertExpense(Map<String, dynamic>.from(e as Map));
          restored++;
        } catch (_) {}
      }
      for (final b in (data['budgets'] as List? ?? [])) {
        try {
          final bMap = Map<String, dynamic>.from(b as Map);
          await DBService.setBudget(
            bMap['category'] as String,
            (bMap['amount'] as num).toDouble(),
            isPercentage: (bMap['is_percentage'] as int? ?? 0) == 1,
            percentageValue: (bMap['percentage_value'] as num? ?? 0).toDouble(),
          );
        } catch (_) {}
      }
      for (final g in (data['goals'] as List? ?? [])) {
        try {
          await DBService.insertGoal(Map<String, dynamic>.from(g as Map));
        } catch (_) {}
      }
      for (final i in (data['income'] as List? ?? [])) {
        try {
          await DBService.insertIncome(Map<String, dynamic>.from(i as Map));
        } catch (_) {}
      }
      for (final r in (data['recurring'] as List? ?? [])) {
        try {
          await DBService.insertRecurring(Map<String, dynamic>.from(r as Map));
        } catch (_) {}
      }
      for (final d in (data['debts'] as List? ?? [])) {
        try {
          await DBService.insertDebt(Map<String, dynamic>.from(d as Map));
        } catch (_) {}
      }
      for (final inst in (data['installments'] as List? ?? [])) {
        try {
          final db = await DBService.getDB();
          final m = Map<String, dynamic>.from(inst as Map)..remove('id');
          await db.insert('installments', m);
        } catch (_) {}
      }

      // Restore custom categories
      for (final cat in (data['custom_categories'] as List? ?? [])) {
        try {
          final m = Map<String, dynamic>.from(cat as Map)..remove('id');
          await DBService.insertCustomCategory(m);
        } catch (_) {}
      }

      // Restore category rules
      for (final rule in (data['category_rules'] as List? ?? [])) {
        try {
          final m = Map<String, dynamic>.from(rule as Map);
          await DBService.insertCategoryRule(
            m['keyword'] as String,
            m['category'] as String,
          );
        } catch (_) {}
      }

      // Restore mood log (v7+) — use original date from backup, not today
      for (final entry in (data['mood_log'] as List? ?? [])) {
        try {
          final m = Map<String, dynamic>.from(entry as Map);
          final db = await DBService.getDB();
          await db.insert(
            'mood_log',
            {
              'date': m['date'] as String,
              'mood_score': m['mood_score'] as int,
              'note': m['note'] as String?,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } catch (_) {}
      }

      // Restore installment plans (v8+)
      for (final plan in (data['installment_plans'] as List? ?? [])) {
        try {
          final db = await DBService.getDB();
          final m = Map<String, dynamic>.from(plan as Map)..remove('id');
          await db.insert('installment_plans', m);
        } catch (_) {}
      }

      // Restore wallet balances — update existing wallets by name, add new ones
      for (final w in (data['wallets'] as List? ?? [])) {
        try {
          final m = Map<String, dynamic>.from(w as Map);
          final name = m['name'] as String?;
          if (name == null || name.isEmpty) continue;
          final db = await DBService.getDB();
          final existing = await db.query('wallets',
              where: 'LOWER(name) = ?',
              whereArgs: [name.toLowerCase()],
              limit: 1);
          if (existing.isNotEmpty) {
            await db.update(
              'wallets',
              {
                'balance': m['balance'] ?? 0.0,
                'updated_at':
                    m['updated_at'] ?? DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [existing.first['id']],
            );
          } else {
            await db.insert('wallets', {
              'name': name,
              'type': m['type'] ?? 'cash',
              'balance': m['balance'] ?? 0.0,
              'icon': m['icon'] ?? '💵',
              'updated_at': m['updated_at'] ?? DateTime.now().toIso8601String(),
            });
          }
        } catch (_) {}
      }

      // Restore insurance policies (v9+)
      for (final p in (data['insurance_policies'] as List? ?? [])) {
        try {
          final m = Map<String, dynamic>.from(p as Map)..remove('id');
          await DBService.insertInsurancePolicy(m);
        } catch (_) {}
      }

      final exportedAt = data['exported_at'] as String? ?? 'unknown';

      // Push all restored data to Firestore so it syncs across devices
      try {
        await DBService.pushAllToCloud();
      } catch (_) {}

      // Fire all events so every screen refreshes after restore
      fireEvent(AppEvent.expenseChanged);
      fireEvent(AppEvent.budgetChanged);
      fireEvent(AppEvent.incomeChanged);
      fireEvent(AppEvent.goalChanged);

      return BackupRestoreResult(
        success: true,
        message:
            "Restored $restored expenses and all data.\nBackup from: ${exportedAt.substring(0, 10)}",
      );
    } catch (e) {
      return BackupRestoreResult(
          success: false, message: "Could not read backup file: $e");
    }
  }

  /// Legacy method — kept for compatibility, now just calls backup()
  static Future<String?> getLastBackupTime() async => null;
}

class BackupRestoreResult {
  final bool success;
  final String message;
  BackupRestoreResult({required this.success, required this.message});
}
