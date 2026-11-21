// SETUP INSTRUCTIONS (Android):
// Full implementation requires a native Android NotificationListenerService.
// Steps to enable on the device:
//   1. Open Android Settings
//   2. Go to Apps (or Application Manager)
//   3. Tap the three-dot menu → Special app access  (or search "Notification access")
//   4. Tap "Notification access"
//   5. Find SmartSpend and enable it
//   6. Confirm the permission dialog
//
// Native side: Create android/app/src/main/java/.../SmartSpendNotificationService.java
// extending android.service.notification.NotificationListenerService, register it
// in AndroidManifest.xml with BIND_NOTIFICATION_LISTENER_SERVICE permission,
// and use a MethodChannel to forward onNotificationPosted payloads to Flutter.
//
// This file implements the Dart parsing side only.

class ParsedTransaction {
  final double amount;
  final String currency;
  final String? description;
  final String source;
  final DateTime timestamp;

  ParsedTransaction({
    required this.amount,
    this.currency = 'PHP',
    this.description,
    required this.source,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'currency': currency,
        'description': description,
        'source': source,
        'timestamp': timestamp.toIso8601String(),
      };
}

class NotificationListenerService {
  static ParsedTransaction? parseNotification(
      String packageName, String title, String text) {
    if (packageName == 'com.globe.gcash.android') {
      return _parseGCash(text);
    }
    if (packageName == 'ph.maya.app') {
      return _parseMaya(text);
    }
    return null;
  }

  static ParsedTransaction? _parseGCash(String text) {
    final sentRegex = RegExp(
      r'(?:You sent|Sent)\s+[₱P]?([\d,]+(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final receivedRegex = RegExp(
      r'(?:You received|Received|Cash In)\s+[₱P]?([\d,]+(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final fallbackRegex = RegExp(r'[₱P]([\d,]+(?:\.\d{2})?)');

    final amount = _extractAmount(text, [sentRegex, receivedRegex, fallbackRegex]);
    if (amount == null) return null;

    return ParsedTransaction(
      amount: amount,
      currency: 'PHP',
      description: text,
      source: 'GCash',
      timestamp: DateTime.now(),
    );
  }

  static ParsedTransaction? _parseMaya(String text) {
    final paymentRegex = RegExp(
      r'(?:Payment of|Paid|You paid|Sent)\s+[₱P]?([\d,]+(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final fallbackRegex = RegExp(r'[₱P]([\d,]+(?:\.\d{2})?)');

    final amount = _extractAmount(text, [paymentRegex, fallbackRegex]);
    if (amount == null) return null;

    return ParsedTransaction(
      amount: amount,
      currency: 'PHP',
      description: text,
      source: 'Maya',
      timestamp: DateTime.now(),
    );
  }

  static double? _extractAmount(String text, List<RegExp> patterns) {
    for (final regex in patterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final raw = match.group(1)?.replaceAll(',', '');
        if (raw != null) return double.tryParse(raw);
      }
    }
    return null;
  }

  /// Returns whether the app has notification listener permission.
  // TODO: Requires a MethodChannel call to the native Android side to check
  // NotificationManagerCompat.getEnabledListenerPackages(context).contains(packageName).
  static bool isPermissionGranted() {
    return false;
  }
}
