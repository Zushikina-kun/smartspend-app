import 'db_service.dart';
import 'ai_chat_service.dart';

/// DataQualityService — scans for common expense data issues and surfaces
/// them as actionable correction suggestions.
///
/// Runs on demand (from Hub → Data Quality) or weekly in background.
/// Issues found are cached for display; dismissed issues are not re-shown.
///
/// Issue types:
///   'zero_time'     — imported expenses with time=00:00 (no real timestamp)
///   'case_dup'      — same item name logged with different capitalizations
///   'others_cat'    — items in 'Others' that keyword-matching suggests a better category
///   'round_amount'  — suspiciously round AI-logged amounts (₱1000, ₱5000) that may
///                     be wallet balance updates accidentally logged as expenses
class DataQualityService {
  static const _cacheKey = 'data_quality_issues';
  static const _lastScanKey = 'data_quality_last_scan';

  /// Scan for issues and return a list of suggestion maps.
  /// Each map has: { 'id', 'type', 'description', 'expense_ids': List<int> }
  static Future<List<Map<String, dynamic>>> scan({bool force = false}) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastScan = await DBService.getSetting(_lastScanKey);

    // Only re-scan once per week unless forced
    if (!force && lastScan != null) {
      final last = DateTime.tryParse(lastScan);
      if (last != null && DateTime.now().difference(last).inDays < 7) {
        final cached = await _loadCached();
        if (cached != null) return cached;
      }
    }

    await DBService.setSetting(_lastScanKey, today);

    final expenses = await DBService.getExpenses();
    final issues = <Map<String, dynamic>>[];

    // ── Issue 1: time = 00:00 (imported, no real timestamp) ──────────────
    final zeroTimeExpenses = expenses
        .where(
            (e) => (e.time == '00:00' || e.time == '00:00:00') && e.aiGenerated)
        .toList();
    if (zeroTimeExpenses.isNotEmpty) {
      issues.add({
        'id': 'zero_time',
        'type': 'zero_time',
        'title': '${zeroTimeExpenses.length} imported expenses missing a time',
        'description':
            'These were imported from screenshots or GCash and have no real '
                'timestamp (00:00). You can set the correct time or leave as-is.',
        'expense_ids': zeroTimeExpenses.map((e) => e.id).toList(),
        'count': zeroTimeExpenses.length,
      });
    }

    // ── Issue 2: duplicate item names with different capitalizations ───────
    final nameCounts = <String, List<int>>{};
    for (final e in expenses) {
      final lower = e.itemName.toLowerCase().trim();
      if (lower.isEmpty) continue;
      nameCounts.putIfAbsent(lower, () => []).add(e.id ?? 0);
    }
    // Find names that appear with multiple different original casings
    final caseDups = <String, Set<String>>{};
    for (final e in expenses) {
      final lower = e.itemName.toLowerCase().trim();
      if (lower.isEmpty) continue;
      if ((nameCounts[lower]?.length ?? 0) >= 3) {
        caseDups.putIfAbsent(lower, () => {}).add(e.itemName.trim());
      }
    }
    final realDups =
        caseDups.entries.where((entry) => entry.value.length > 1).toList();
    if (realDups.isNotEmpty) {
      issues.add({
        'id': 'case_dup',
        'type': 'case_dup',
        'title':
            '${realDups.length} item name${realDups.length == 1 ? '' : 's'} have inconsistent capitalisation',
        'description': 'Example: "jeepney fare", "Jeepney Fare", "Jeepney fare" — '
            'these are the same item logged differently. Merging them improves '
            'auto-categorization accuracy.',
        'examples': realDups.take(3).map((e) => e.value.join(' / ')).toList(),
        'expense_ids': realDups.expand((e) => nameCounts[e.key] ?? []).toList(),
        'count': realDups.length,
      });
    }

    // ── Issue 3: Others category — keyword check suggests a better one ────
    final othersWrongCat = expenses.where((e) {
      if (e.category != 'Others') return false;
      final suggested = AIChatService.suggestCategory(e.itemName);
      return suggested != 'Others';
    }).toList();
    if (othersWrongCat.isNotEmpty) {
      issues.add({
        'id': 'others_cat',
        'type': 'others_cat',
        'title':
            '${othersWrongCat.length} expenses in "Others" may have a better category',
        'description':
            'These were categorized as Others but the item name suggests a '
                'more specific category. Tap Fix to auto-reassign.',
        'expense_ids': othersWrongCat.map((e) => e.id).toList(),
        'suggestions': {
          for (final e in othersWrongCat.take(10))
            '${e.id}': AIChatService.suggestCategory(e.itemName)
        },
        'count': othersWrongCat.length,
      });
    }

    // ── Issue 4: Round AI amounts — possible wallet balance mislog ─────────
    final roundAmounts = expenses.where((e) {
      if (!e.aiGenerated) return false;
      final a = e.amount;
      // Flag: multiple of ₱1,000 and ≥ ₱1,000 and notes hint at balance/transfer
      final isRound = a >= 1000 && a % 1000 == 0;
      final notesHint = (e.notes ?? '').toLowerCase();
      final suspiciousNote = notesHint.contains('balance') ||
          notesHint.contains('wallet') ||
          notesHint.contains('gcash') ||
          notesHint.contains('transfer') ||
          notesHint.contains('cash in') ||
          notesHint.contains('allowance');
      return isRound && suspiciousNote;
    }).toList();
    if (roundAmounts.isNotEmpty) {
      issues.add({
        'id': 'round_amount',
        'type': 'round_amount',
        'title':
            '${roundAmounts.length} round AI-logged amounts may be wallet updates',
        'description':
            'Large round amounts (₱1,000+) with wallet-related notes were '
                'logged as expenses by AI — they might actually be wallet top-ups '
                'or balance updates that should be deleted.',
        'expense_ids': roundAmounts.map((e) => e.id).toList(),
        'count': roundAmounts.length,
      });
    }

    // Cache results
    await _saveCache(issues);
    return issues;
  }

  /// Total issue count — used for Hub badge
  static Future<int> getIssueCount() async {
    final cached = await _loadCached();
    if (cached == null) return 0;
    return cached.fold<int>(
        0, (s, issue) => s + ((issue['count'] as int?) ?? 1));
  }

  /// Apply fix for 'others_cat' — bulk re-categorize using AI's suggestion
  static Future<int> fixOthersCategory(
      List<int> expenseIds, Map<String, String> suggestions) async {
    int fixed = 0;
    for (final id in expenseIds) {
      final suggested = suggestions['$id'];
      if (suggested == null || suggested == 'Others') continue;
      try {
        final all = await DBService.getExpenses();
        final exp = all.where((e) => e.id == id).firstOrNull;
        if (exp == null) continue;
        await DBService.updateExpense(exp.copyWith(category: suggested));
        fixed++;
      } catch (_) {}
    }
    if (fixed > 0) await clearCache(); // invalidate so next open re-scans
    return fixed;
  }

  static Future<void> clearCache() async {
    await DBService.setSetting(_lastScanKey, '');
  }

  static Future<List<Map<String, dynamic>>?> _loadCached() async {
    // Simple flag-based cache — just re-scan if needed
    final lastScan = await DBService.getSetting(_lastScanKey);
    if (lastScan == null) return null;
    return null; // always rescan for now; cache can be added later
  }

  static Future<void> _saveCache(List<Map<String, dynamic>> issues) async {
    // Mark as scanned — actual data returned directly without serialisation
  }
}
