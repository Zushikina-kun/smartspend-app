import 'db_service.dart';
import 'event_bus.dart';

/// Shared logic for logging a recurring transaction and advancing its next_date.
/// Used by both home_screen (auto-log chips) and recurring_screen (Log Now button).
class RecurringHelper {
  /// Log a recurring item as an expense or income entry, then advance next_date.
  /// Returns true if successful.
  static Future<bool> logAndAdvance(Map<String, dynamic> item) async {
    final isExpense = (item['is_expense'] as int? ?? 1) == 1;
    final now = DateTime.now();
    final amt = (item['amount'] as num).toDouble();

    if (isExpense) {
      await DBService.insertExpense({
        'item_name': item['title'],
        'category': item['category'] ?? 'Bills',
        'amount': amt,
        'date': now.toIso8601String().substring(0, 10),
        'time': now.toIso8601String().substring(11, 16),
        'payment_method': 'Cash',
        'notes': 'Logged from recurring: ${item['title']}',
        'ai_generated': 0,
        'confidence_score': 1.0,
        'is_want': 0,
      });
    } else {
      await DBService.insertIncome({
        'title': item['title'],
        'amount': amt,
        'category': item['category'] ?? 'Salary',
        'date': now.toIso8601String().substring(0, 10),
        'is_recurring': 1,
      });
    }

    // Advance next_date based on frequency
    try {
      final currentStr = item['next_date'] as String?;
      if (currentStr == null || currentStr.isEmpty) return true;
      final current = DateTime.parse(currentStr);
      final freq = item['frequency'] as String? ?? 'monthly';
      final next = _advanceDate(current, freq);
      await DBService.updateRecurring({
        ...item,
        'next_date': next.toIso8601String().substring(0, 10),
      });
    } catch (_) {}

    fireEvent(AppEvent.expenseChanged);
    return true;
  }

  /// Calculate the next date based on frequency
  static DateTime _advanceDate(DateTime current, String frequency) {
    switch (frequency) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'yearly':
        return DateTime(current.year + 1, current.month, current.day);
      default: // monthly
        final nextMonth = current.month == 12 ? 1 : current.month + 1;
        final nextYear = current.month == 12 ? current.year + 1 : current.year;
        final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
        return DateTime(nextYear, nextMonth, current.day.clamp(1, lastDay));
    }
  }
}
