import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Tracks the OpenRouter rate-limit header so the UI can warn the user
/// when the daily quota is running low.
class RateLimitService {
  RateLimitService._();

  /// Remaining OpenRouter requests for the current period (null = unknown).
  static final ValueNotifier<int?> openRouterRemaining = ValueNotifier(null);

  /// Parse the rate-limit header from any HTTP response and update the notifier.
  /// The header 'x-ratelimit-remaining' is only present on OpenRouter responses,
  /// so its presence alone identifies an OpenRouter call — no model gating needed.
  static void recordFromResponse(http.Response response) {
    try {
      final raw = response.headers['x-ratelimit-remaining'];
      if (raw == null) return;
      final value = int.tryParse(raw);
      if (value != null) {
        openRouterRemaining.value = value;
      }
    } catch (_) {}
  }

  /// True when the remaining request count is known and below 100.
  static bool get showWarning {
    final r = openRouterRemaining.value;
    return r != null && r < 100;
  }
}
