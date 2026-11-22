import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsTransaction {
  final String sender;
  final double amount;
  final String type; // 'sent' | 'received' | 'payment'
  final String? recipient;
  final DateTime date;
  final String rawBody;

  const SmsTransaction({
    required this.sender,
    required this.amount,
    required this.type,
    this.recipient,
    required this.date,
    required this.rawBody,
  });
}

class SmsParserService {
  static const _platform = MethodChannel('com.smartspend/sms');

  /// Request READ_SMS permission using the platform channel.
  /// Returns true if granted, false if denied.
  static Future<bool> requestSmsPermission() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid) return false;
    try {
      final granted =
          await _platform.invokeMethod<bool>('requestSmsPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Read SMS inbox from device via platform channel and parse GCash/Maya messages.
  /// Returns list of parsed SmsTransaction objects.
  static Future<List<SmsTransaction>> parseSmsInbox() async {
    if (kIsWeb) return [];
    if (!Platform.isAndroid) return [];
    try {
      final List<dynamic>? smsList =
          await _platform.invokeMethod<List<dynamic>>('getSmsInbox');
      if (smsList == null) return [];
      final results = <SmsTransaction>[];
      for (final sms in smsList) {
        final map = Map<String, dynamic>.from(sms as Map);
        final body = (map['body'] as String?) ?? '';
        final sender = (map['sender'] as String?) ?? '';
        final dateMs = (map['date'] as int?) ?? 0;
        final date = DateTime.fromMillisecondsSinceEpoch(dateMs);
        SmsTransaction? parsed =
            parseGcashSms(body, sender: sender, date: date);
        parsed ??= parseMayaSms(body, sender: sender, date: date);
        if (parsed != null) results.add(parsed);
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  /// Parse a GCash SMS body.
  /// Handles: "You sent ₱XXX to YYY" and "You received ₱XXX from YYY"
  static SmsTransaction? parseGcashSms(String body,
      {String sender = 'GCash', DateTime? date}) {
    final effectiveDate = date ?? DateTime.now();
    // Sent pattern
    final sentMatch = RegExp(
      r'You sent \u20b1([\d,]+\.?\d*) to ([^.]+)',
      caseSensitive: false,
    ).firstMatch(body);
    if (sentMatch != null) {
      final amount =
          double.tryParse(sentMatch.group(1)!.replaceAll(',', '')) ?? 0;
      final recipient = sentMatch.group(2)?.trim();
      return SmsTransaction(
        sender: sender,
        amount: amount,
        type: 'sent',
        recipient: recipient,
        date: effectiveDate,
        rawBody: body,
      );
    }
    // Received pattern
    final recvMatch = RegExp(
      r'received \u20b1([\d,]+\.?\d*) from ([^.]+)',
      caseSensitive: false,
    ).firstMatch(body);
    if (recvMatch != null) {
      final amount =
          double.tryParse(recvMatch.group(1)!.replaceAll(',', '')) ?? 0;
      final from = recvMatch.group(2)?.trim();
      return SmsTransaction(
        sender: sender,
        amount: amount,
        type: 'received',
        recipient: from,
        date: effectiveDate,
        rawBody: body,
      );
    }
    return null;
  }

  /// Parse a Maya SMS body.
  /// Handles: "Payment of ₱XXX"
  static SmsTransaction? parseMayaSms(String body,
      {String sender = 'Maya', DateTime? date}) {
    final effectiveDate = date ?? DateTime.now();
    final payMatch = RegExp(
      r'Payment of \u20b1([\d,]+\.?\d*)',
      caseSensitive: false,
    ).firstMatch(body);
    if (payMatch != null) {
      final amount =
          double.tryParse(payMatch.group(1)!.replaceAll(',', '')) ?? 0;
      return SmsTransaction(
        sender: sender,
        amount: amount,
        type: 'payment',
        date: effectiveDate,
        rawBody: body,
      );
    }
    return null;
  }

  /// Check if SMS sync is enabled in settings.
  static Future<bool> isSmssyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sms_sync_enabled') ?? false;
  }

  /// Toggle SMS sync enabled/disabled.
  static Future<void> setSmsSync(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sms_sync_enabled', enabled);
  }
}
