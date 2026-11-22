import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin static wrapper around FirebaseAnalytics.
/// Every method is try/catch so analytics never crashes the app.
/// Only model IDs, feature names, and boolean success are logged — no PII.
class AnalyticsService {
  AnalyticsService._();

  static Future<void> init() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    } catch (_) {}
  }

  /// Derives a provider label from a model ID prefix.
  static String _provider(String modelId) {
    if (modelId.startsWith('or_') || modelId == 'openrouter') {
      return 'OpenRouter';
    } else if (modelId.startsWith('gemini_')) {
      return 'Gemini';
    } else if (modelId.startsWith('groq_')) {
      return 'Groq';
    } else if (modelId.startsWith('cerebras_')) {
      return 'Cerebras';
    } else if (modelId == 'custom_local') {
      return 'Local';
    } else if (modelId == 'auto') {
      return 'Auto';
    }
    return 'Unknown';
  }

  static void logModelSwitched(String from, String to) {
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'model_switched',
        parameters: {
          'from_model': from,
          'to_model': to,
          'from_provider': _provider(from),
          'to_provider': _provider(to),
        },
      );
    } catch (_) {}
  }

  static void logOcrScan(String modelId, bool success) {
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'ocr_scan',
        parameters: {
          'model_id': modelId,
          'provider': _provider(modelId),
          'success': success ? 1 : 0,
        },
      );
    } catch (_) {}
  }

  static void logVoiceCommand(String modelId) {
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'voice_command',
        parameters: {
          'model_id': modelId,
          'provider': _provider(modelId),
        },
      );
    } catch (_) {}
  }

  static void logAiMessage(String modelId) {
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'ai_message',
        parameters: {
          'model_id': modelId,
          'provider': _provider(modelId),
        },
      );
    } catch (_) {}
  }

  static void logFeatureUsed(String feature) {
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'feature_used',
        parameters: {'feature': feature},
      );
    } catch (_) {}
  }
}
