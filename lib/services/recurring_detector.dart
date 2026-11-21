import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_service.dart';

class RecurringSuggestion {
  final String merchant;
  final double avgAmount;
  final String frequency; // 'weekly' | 'monthly'
  final String confidence; // 'high' | 'medium'
  const RecurringSuggestion({
    required this.merchant,
    required this.avgAmount,
    required this.frequency,
    required this.confidence,
  });
}

class RecurringDetector {
  static Future<List<RecurringSuggestion>> analyzeExpenses() async {
    final allExpenses = await DBService.getExpenses();
    final cutoff = DateTime.now().subtract(const Duration(days: 90));

    // Filter to last 90 days, skip entries with empty name or category
    final recent = allExpenses.where((e) {
      if (e.itemName.trim().isEmpty || e.category.trim().isEmpty) return false;
      final date = DateTime.tryParse(e.date);
      if (date == null) return false;
      return date.isAfter(cutoff);
    }).toList();

    // Group by normalized merchant → list of dates
    final Map<String, List<DateTime>> groups = {};
    final Map<String, List<double>> amounts = {};
    for (final e in recent) {
      final key = _normalizeMerchant(e.itemName);
      if (key.isEmpty) continue;
      final date = DateTime.tryParse(e.date);
      if (date == null) continue;
      groups.putIfAbsent(key, () => []).add(date);
      amounts.putIfAbsent(key, () => []).add(e.amount);
    }

    final dismissed = await _getDismissed();
    final suggestions = <RecurringSuggestion>[];

    for (final entry in groups.entries) {
      final merchant = entry.key;
      if (dismissed.contains(merchant)) continue;
      final dates = entry.value;
      if (dates.length < 2) continue;

      dates.sort();
      final intervals = <int>[];
      for (int i = 1; i < dates.length; i++) {
        intervals.add(dates[i].difference(dates[i - 1]).inDays);
      }

      String? frequency;
      String? confidence;

      // Check weekly: intervals 5–9 days
      final weeklyMatches = intervals.where((d) => d >= 5 && d <= 9).length;
      if (weeklyMatches == intervals.length) {
        frequency = 'weekly';
        confidence = 'high';
      } else if (weeklyMatches > intervals.length / 2) {
        frequency = 'weekly';
        confidence = 'medium';
      }

      // Check monthly: intervals 25–35 days (overrides weekly if matched)
      final monthlyMatches = intervals.where((d) => d >= 25 && d <= 35).length;
      if (monthlyMatches == intervals.length) {
        frequency = 'monthly';
        confidence = 'high';
      } else if (monthlyMatches > intervals.length / 2) {
        frequency = 'monthly';
        confidence = 'medium';
      }

      if (frequency == null) continue;

      final amtList = amounts[merchant] ?? [];
      final avg = amtList.isEmpty
          ? 0.0
          : amtList.fold<double>(0, (sum, a) => sum + a) / amtList.length;

      suggestions.add(RecurringSuggestion(
        merchant: merchant,
        avgAmount: avg,
        frequency: frequency,
        confidence: confidence!,
      ));
    }

    return suggestions;
  }

  static String _normalizeMerchant(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static Future<Set<String>> _getDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('recurring_dismissed');
    if (raw == null) return {};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> dismissMerchant(String merchant) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = await _getDismissed();
    dismissed.add(merchant);
    await prefs.setString(
        'recurring_dismissed', jsonEncode(dismissed.toList()));
  }
}
