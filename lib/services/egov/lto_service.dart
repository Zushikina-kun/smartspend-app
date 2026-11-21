import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../notification_service.dart';

class LTOService {
  /// Plate last digit → renewal month number (1–12).
  /// Digit 0 → October (10).
  static const Map<int, int> _digitToMonth = {
    1: 1,
    2: 2,
    3: 3,
    4: 4,
    5: 5,
    6: 6,
    7: 7,
    8: 8,
    9: 9,
    0: 10,
  };

  static const List<String> _monthNames = [
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

  /// Returns the renewal month number (1–12) for the given plate last digit.
  static int getRenewalMonth(int plateLastDigit) {
    return _digitToMonth[plateLastDigit] ?? 10;
  }

  /// Returns the renewal month name (e.g. 'January') for the given plate last digit.
  static String getRenewalMonthName(int plateLastDigit) {
    return _monthNames[getRenewalMonth(plateLastDigit)];
  }

  /// Computes itemized renewal fees.
  ///
  /// Returns a map with keys:
  ///   'mvuc', 'mvucSurcharge', 'registrationFee', 'ctplInsurance', 'total'
  static Map<String, double> computeRenewalFees(
      String vehicleType, double weightKg) {
    double mvucBase;
    double mvucSurcharge = 0;
    const double registrationFee = 650.0;
    const double ctplInsurance = 200.0;

    switch (vehicleType) {
      case 'Motorcycle':
        mvucBase = weightKg <= 400 ? 240.0 : 360.0;
        break;
      case 'Truck':
        mvucBase = 2500.0;
        if (weightKg > 1700) {
          mvucSurcharge = ((weightKg - 1700) / 100).ceil() * 24.0;
        }
        break;
      case 'Van':
        mvucBase = 1620.0;
        if (weightKg > 1700) {
          mvucSurcharge = ((weightKg - 1700) / 100).ceil() * 24.0;
        }
        break;
      case 'Car':
      default:
        mvucBase = 1620.0;
        if (weightKg > 1700) {
          mvucSurcharge = ((weightKg - 1700) / 100).ceil() * 24.0;
        }
        break;
    }

    final total = mvucBase + mvucSurcharge + registrationFee + ctplInsurance;

    return {
      'mvuc': mvucBase,
      'mvucSurcharge': mvucSurcharge,
      'registrationFee': registrationFee,
      'ctplInsurance': ctplInsurance,
      'total': total,
    };
  }

  /// Returns days until the 1st of the renewal month.
  /// If that date has already passed this year, uses next year's date.
  static int getDaysUntilRenewal(int plateLastDigit) {
    final now = DateTime.now();
    final month = getRenewalMonth(plateLastDigit);
    DateTime renewalDate = DateTime(now.year, month, 1);
    if (!renewalDate.isAfter(now)) {
      renewalDate = DateTime(now.year + 1, month, 1);
    }
    return renewalDate.difference(now).inDays;
  }

  /// Schedules a push notification 30 days before the renewal month's 1st day at 09:00 AM.
  static Future<void> scheduleRenewalReminder(
      int vehicleId, int plateLastDigit, String nickname) async {
    await NotificationService.init();

    final now = DateTime.now();
    final month = getRenewalMonth(plateLastDigit);
    DateTime renewalDate = DateTime(now.year, month, 1);
    if (!renewalDate.isAfter(now)) {
      renewalDate = DateTime(now.year + 1, month, 1);
    }

    final reminderDate = renewalDate.subtract(const Duration(days: 30));
    final reminderAt = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
      0,
    );

    if (!reminderAt.isAfter(now)) return;

    final tzReminder = tz.TZDateTime.from(reminderAt, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'lto_reminders',
      'LTO Renewal Reminders',
      channelDescription: 'Upcoming LTO vehicle registration renewal reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    await NotificationService.plugin.zonedSchedule(
      ('lto_$vehicleId').hashCode,
      '🚗 LTO Renewal in 30 days: $nickname',
      'Registration renewal for $nickname is due on the 1st of ${getRenewalMonthName(plateLastDigit)}.',
      tzReminder,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
