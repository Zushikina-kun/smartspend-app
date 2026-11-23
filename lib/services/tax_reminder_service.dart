import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';

class TaxReminderService {
  /// Returns upcoming BIR deadlines for the current and next year.
  /// Deadlines that have already passed are rolled to the following year.
  /// Sorted ascending by days away.
  static List<Map<String, dynamic>> getUpcomingDeadlines() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final year = now.year;

    final raw = [
      {
        'name': 'Q1 Percentage Tax (2551Q)',
        'month': 4,
        'day': 15,
        'year': year
      },
      {
        'name': 'Q2 Percentage Tax (2551Q)',
        'month': 8,
        'day': 15,
        'year': year
      },
      {
        'name': 'Q3 Percentage Tax (2551Q)',
        'month': 11,
        'day': 15,
        'year': year
      },
      {
        'name': 'Q4 Percentage Tax (2551Q)',
        'month': 1,
        'day': 30,
        'year': year
      },
      {
        'name': 'Annual ITR (1700/1701/1701A)',
        'month': 4,
        'day': 15,
        'year': year
      },
    ];

    final deadlines = <Map<String, dynamic>>[];
    for (final d in raw) {
      DateTime date =
          DateTime(d['year'] as int, d['month'] as int, d['day'] as int);
      // If the deadline has already passed, push it one year forward
      if (date.isBefore(today)) {
        date = DateTime(
          (d['year'] as int) + 1,
          d['month'] as int,
          d['day'] as int,
        );
      }
      final daysAway = date.difference(today).inDays;
      deadlines.add({
        'name': d['name'] as String,
        'date': date,
        'daysAway': daysAway,
      });
    }

    deadlines
        .sort((a, b) => (a['daysAway'] as int).compareTo(b['daysAway'] as int));
    return deadlines;
  }

  /// Estimates income tax using both 8% flat rate and graduated rates.
  /// Returns the lower of the two for income 250k–3M; graduated-only above 3M.
  static Map<String, dynamic> estimateIncomeTax(double annualIncome) {
    if (annualIncome <= 250000) {
      return {
        'taxDue': 0.0,
        'method': 'Tax Exempt',
        'breakdown': 'Below ₱250,000 threshold — no income tax',
      };
    }

    // Graduated tax computation
    double graduated = 0;
    String graduatedBreakdown;
    if (annualIncome <= 400000) {
      graduated = (annualIncome - 250000) * 0.15;
      graduatedBreakdown =
          '15% of excess over ₱250,000 = ₱${graduated.toStringAsFixed(2)}';
    } else if (annualIncome <= 800000) {
      graduated = 22500 + (annualIncome - 400000) * 0.20;
      graduatedBreakdown =
          '₱22,500 + 20% of excess over ₱400,000 = ₱${graduated.toStringAsFixed(2)}';
    } else if (annualIncome <= 2000000) {
      graduated = 102500 + (annualIncome - 800000) * 0.25;
      graduatedBreakdown =
          '₱102,500 + 25% of excess over ₱800,000 = ₱${graduated.toStringAsFixed(2)}';
    } else if (annualIncome <= 8000000) {
      graduated = 402500 + (annualIncome - 2000000) * 0.30;
      graduatedBreakdown =
          '₱402,500 + 30% of excess over ₱2,000,000 = ₱${graduated.toStringAsFixed(2)}';
    } else {
      graduated = 2202500 + (annualIncome - 8000000) * 0.35;
      graduatedBreakdown =
          '₱2,202,500 + 35% of excess over ₱8,000,000 = ₱${graduated.toStringAsFixed(2)}';
    }

    // For income above 3M, only graduated applies
    if (annualIncome > 3000000) {
      return {
        'taxDue': graduated,
        'method': 'Graduated Rate',
        'breakdown': graduatedBreakdown,
      };
    }

    // 8% flat rate option (income 250k–3M)
    final flat = (annualIncome - 250000) * 0.08;
    final flatBreakdown =
        '8% × (₱${annualIncome.toStringAsFixed(0)} − ₱250,000) = ₱${flat.toStringAsFixed(2)}';

    if (flat <= graduated) {
      return {
        'taxDue': flat,
        'method': '8% Flat Rate',
        'breakdown': flatBreakdown,
      };
    } else {
      return {
        'taxDue': graduated,
        'method': 'Graduated Rate',
        'breakdown': graduatedBreakdown,
      };
    }
  }

  /// Estimates quarterly percentage tax (BIR Form 2551Q) — 3% flat rate.
  static double estimatePercentageTax(double quarterlyRevenue) {
    return quarterlyRevenue * 0.03;
  }

  /// Schedules local notifications at 30, 7, and 1 day before each upcoming deadline.
  static Future<void> scheduleAllTaxReminders() async {
    await NotificationService.init();
    final deadlines = getUpcomingDeadlines();

    for (final deadline in deadlines) {
      final name = deadline['name'] as String;
      final date = deadline['date'] as DateTime;

      for (final daysBefore in [30, 7, 1]) {
        final scheduleDate = date.subtract(Duration(days: daysBefore));
        final now = DateTime.now();
        // Skip if the notification date is already past
        if (scheduleDate.isBefore(now)) continue;

        final notifId = ('$name$daysBefore').hashCode;
        final tzDate = tz.TZDateTime.from(
          DateTime(
              scheduleDate.year, scheduleDate.month, scheduleDate.day, 9, 0),
          tz.local,
        );

        try {
          await NotificationService.plugin.zonedSchedule(
            notifId,
            '📋 BIR Deadline in $daysBefore day${daysBefore == 1 ? '' : 's'}',
            '$name due on ${_formatDate(date)}',
            tzDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'tax_reminders',
                'BIR Tax Reminders',
                channelDescription: 'BIR quarterly tax deadline reminders',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {}
      }
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}
