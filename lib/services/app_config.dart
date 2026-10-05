import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'db_service.dart';

/// Centralized app configuration. Multi-model LLM routing (best → good → fallback):
///
/// PRIORITY ORDER (best quality to fastest/most available):
/// 1. Gemini 3.5 Flash        — Best reasoning, GA stable
/// 2. Gemini 3.5 Flash-Lite   — Fastest Gemini, GA stable (primary default)
/// 3. Groq GPT-OSS 120B       — openai/gpt-oss-120b, 1,000 req/day
/// 4. Groq Qwen3.6 27B        — qwen/qwen3.6-27b, 1,000 req/day
/// 5. Groq Qwen3.8 27B        — qwen/qwen3.8-27b, 1,000 req/day
/// 6. Groq GPT-OSS 20B        — openai/gpt-oss-20b, 1,000 req/day
/// 7. Groq Compound Mini      — groq/compound-mini, 250 req/day
/// 8. Cerebras GPT-OSS 120B   — 1M tokens/day FREE, ~3,000 t/s — last resort
///
/// NOTE: All LLaMA models were RETIRED from Groq free/dev tier Feb–Aug 2026.
/// Active Groq lineup: openai/gpt-oss-120b, openai/gpt-oss-20b,
///   qwen/qwen3.6-27b, qwen/qwen3.8-27b, groq/compound, groq/compound-mini
///
/// Gemini key format: Since May 28, 2026, all new Google AI Studio API keys
/// start with "AQ." (auth keys bound to a service account). Old "AIza..." keys
/// are being rejected. AQ. keys are permanent — they do NOT expire.
///
/// Current default: Auto mode → Gemini 3.5 Flash-Lite (GA stable, fastest 3.5)
class AppConfig {
  AppConfig._();

  // ── FALLBACK KEYS — used when Firebase Remote Config is unreachable ─────────
  // Real keys are stored ONLY in Firebase Remote Config console.
  // Update them there to rotate without a code change.
  // Empty strings here mean Gemini falls back to Groq when Remote Config
  // is unavailable. Set in Remote Config: groq_api_key, gemini_api_key,
  // cerebras_api_key.
  static const _fallbackGroqKey =
      "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";
  static const _fallbackGeminiKey = ""; // Set in Firebase Remote Config
  static const _fallbackCerebrasKey =
      "csk-cwr9ye2pxwyhe89hmexm3t84e5fe3tykjd2d9c86p5vxjd94";

  // ── API ENDPOINTS ──────────────────────────────────────────────────────────
  static const _groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  // Google AI Studio — OpenAI-compatible endpoint
  static const _geminiUrl =
      "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions";
  static const _cerebrasUrl = "https://api.cerebras.ai/v1/chat/completions";

  // ── MODEL NAMES ────────────────────────────────────────────────────────────
  // Groq models — VERIFIED against account's allowed models list Sep 10, 2026
  // Available: openai/gpt-oss-120b (1K/day), openai/gpt-oss-20b (1K/day),
  //            qwen/qwen3.6-27b (1K/day), qwen/qwen3.8-27b (1K/day),
  //            groq/compound (250/day), groq/compound-mini (250/day)
  // RETIRED (Feb–Aug 2026): llama-4-scout, llama-3.3-70b, llama-3.1-8b, kimi-k2, qwen3-32b
  static const _groqLlama4Scout = "openai/gpt-oss-120b";
  // GPT-OSS 120B on Groq: 1K RPD, 8K TPM, strong reasoning — primary Groq model
  static const _groqKimiK2 = "qwen/qwen3.6-27b";
  // Qwen3.6 27B: 1K RPD, 8K TPM — good reasoning + multilingual
  static const _groqQwen3 = "qwen/qwen3.8-27b";
  // Qwen3.8 27B: 1K RPD, 8K TPM — newer Qwen, strong reasoning
  static const _groqModel70B = "groq/compound";
  // Groq Compound: 250 RPD, 70K TPM — general purpose
  static const _groqModel8B = "groq/compound-mini";
  // Compound Mini: 250 RPD, 70K TPM — fast, simple tasks

  // Gemini models via Google AI Studio (OpenAI-compatible endpoint)
  static const _geminiFlash = "gemini-3.5-flash";
  // Gemini 3.5 Flash: GA stable, frontier reasoning, best quality
  static const _geminiFlashLite = "gemini-3.5-flash-lite";
  // Gemini 3.5 Flash-Lite: GA stable, fastest + cheapest 3.5 model, best daily driver

  // Cerebras (wafer-scale, ~3,000 t/s throughput)
  static const _cerebrasModel = "gpt-oss-120b";
  // GPT-OSS 120B on Cerebras: replaces llama3.1-70b (deprecated Feb 2026)
  // 1M tokens/day free, 5 RPM free tier, ~3,000 t/s

  // ── REMOTE KEYS (from Firebase Remote Config) ─────────────────────────────
  static String? _remoteGroqKey;
  static String? _remoteGeminiKey;
  static String? _remoteCerebrasKey;

  // ── CUSTOM LOCAL LLM (user-configured) ─────────────────────────────────────
  // Set by user in Settings → AI → Local AI section.
  // Format: base URL like "http://192.168.1.5:11434/v1" (Ollama) or ":1234/v1" (LM Studio)
  static String? _customLocalUrl;
  static String? _customLocalModel;
  static String? _customLocalKey; // usually blank for Ollama

  /// Whether the user has configured a local LLM endpoint.
  static bool get hasCustomLocal =>
      _customLocalUrl != null && _customLocalUrl!.isNotEmpty;

  /// Getters for settings screen to read current values.
  static String get customLocalUrl => _customLocalUrl ?? '';
  static String get customLocalModel => _customLocalModel ?? '';
  static String get customLocalKey => _customLocalKey ?? '';

  /// Save custom local LLM settings to DB.
  static Future<void> setCustomLocal({
    required String url,
    required String model,
    String key = '',
  }) async {
    _customLocalUrl = url.trim().isEmpty ? null : url.trim();
    _customLocalModel = model.trim().isEmpty ? null : model.trim();
    _customLocalKey = key.trim().isEmpty ? null : key.trim();
    await DBService.setSetting('custom_local_url', url.trim());
    await DBService.setSetting('custom_local_model', model.trim());
    await DBService.setSetting('custom_local_key', key.trim());
  }

  /// Test the custom local endpoint — returns null on success, error string on failure.
  static Future<String?> testCustomLocal(String url, String model) async {
    try {
      final testUrl = url.endsWith('/v1')
          ? '$url/chat/completions'
          : '$url/v1/chat/completions';
      final response = await http
          .post(
            Uri.parse(testUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer test',
            },
            body: jsonEncode({
              'model': model.isEmpty ? 'test' : model,
              'messages': [
                {'role': 'user', 'content': 'Say "ok" and nothing else.'}
              ],
              'max_tokens': 5,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200 || response.statusCode == 400) {
        // 200 = worked; 400 often means model not found but server is running
        return null; // success
      }
      return 'Server responded with status ${response.statusCode}';
    } catch (e) {
      return 'Could not reach server: ${e.toString().replaceAll('Exception: ', '')}';
    }
  }

  // ── ACTIVE MODEL ───────────────────────────────────────────────────────────
  // Default: Gemini 3.5 Flash-Lite — GA stable, best when Gemini key available
  static String _activeModelId = 'gemini_flash_lite';
  static bool _groqLimitReached = false;
  // Track consecutive provider failures for smart recovery
  static int _consecutiveFailures = 0;

  /// All available models shown in the model selector UI, ordered best → fallback
  static const availableModels = [
    (
      'auto',
      'Auto (Recommended)',
      '🤖 Picks the best model for each task — fast for logging, best for advice'
    ),
    (
      'custom_local',
      'Local AI (Your Computer)',
      '🏠 Your own LLM via WiFi — private, no cloud, configure in Local AI settings'
    ),
    (
      'gemini_flash',
      'Gemini 3.5 Flash',
      '🏆 Best — frontier reasoning, GA stable (needs Gemini key)'
    ),
    (
      'gemini_flash_lite',
      'Gemini 3.5 Flash-Lite',
      '⭐ Great — fastest + cheapest 3.5, GA stable (needs Gemini key)'
    ),
    (
      'groq_llama4_scout',
      'GPT-OSS 120B (Groq)',
      '🚀 Best Groq — 1,000/day, 8K TPM'
    ),
    (
      'groq_kimi_k2',
      'Qwen3.6 27B (Groq)',
      '🌐 Multimodal + reasoning — 1,000/day'
    ),
    (
      'groq_qwen3',
      'Qwen3.8 27B (Groq)',
      '✨ Newer Qwen, multimodal — 1,000/day'
    ),
    ('groq_70b', 'Compound (Groq)', '⚡ 250/day, 70K TPM — good general'),
    ('groq_8b', 'Compound Mini (Groq)', '💨 250/day, 70K TPM — fast tasks'),
    (
      'cerebras_120b',
      'GPT-OSS 120B (Cerebras)',
      '🔄 Fallback — 1M tokens/day, ~3,000 t/s (needs Cerebras key)'
    ),
  ];

  static String get activeModelId => _activeModelId;

  /// When in Auto mode, show "Auto · <actual model name>" so users can see
  /// which model is actually being used for the current task.
  static String get activeModelLabel {
    if (_activeModelId == 'auto') {
      final actual = _autoActualModel('smart');
      final label = availableModels
              .where((m) => m.$1 == actual)
              .map((m) => m.$2)
              .firstOrNull ??
          'Gemini 3.5 Flash-Lite';
      return 'Auto · $label';
    }
    return availableModels
            .where((m) => m.$1 == _activeModelId)
            .map((m) => m.$2)
            .firstOrNull ??
        'Gemini 3.5 Flash-Lite';
  }

  /// Internal: resolve which concrete model Auto mode routes to for a given task.
  static String _autoActualModel(String taskType) {
    final hasGemini = (_remoteGeminiKey ?? _fallbackGeminiKey).isNotEmpty;
    switch (taskType) {
      case 'fast':
        // Expense logging — Flash-Lite is fast + low cost
        return hasGemini ? 'gemini_flash_lite' : 'groq_llama4_scout';
      case 'financial_advice':
        // Complex reasoning — use best available
        return hasGemini ? 'gemini_flash' : 'groq_llama4_scout';
      case 'smart':
      default:
        // General chat — Flash-Lite is good default, falls back to Groq
        return hasGemini ? 'gemini_flash_lite' : 'groq_llama4_scout';
    }
  }

  static bool get groqLimitReached => _groqLimitReached;

  /// Whether each key type is currently available (for debug reporting)
  static bool get hasGeminiKey =>
      (_remoteGeminiKey ?? _fallbackGeminiKey).isNotEmpty;
  static bool get hasGroqKey => (_remoteGroqKey ?? _fallbackGroqKey).isNotEmpty;
  static bool get hasCerebrasKey =>
      (_remoteCerebrasKey ?? _fallbackCerebrasKey).isNotEmpty;

  /// The active API key for the current model
  static String get groqApiKey {
    switch (_activeModelId) {
      case 'custom_local':
        return _customLocalKey ?? '';
      case 'auto':
        return _remoteGeminiKey ?? _fallbackGeminiKey;
      case 'gemini_flash':
      case 'gemini_flash_lite':
        return _remoteGeminiKey ?? _fallbackGeminiKey;
      case 'cerebras_120b':
        return _remoteCerebrasKey ?? _fallbackCerebrasKey;
      default: // all Groq models
        return _remoteGroqKey ?? _fallbackGroqKey;
    }
  }

  /// The API base URL for the active model
  static String get groqBaseUrl {
    switch (_activeModelId) {
      case 'custom_local':
        // Use user-configured URL; default to Ollama if not set
        final url = _customLocalUrl ?? 'http://localhost:11434/v1';
        // Strip trailing slash, ensure /v1 suffix for OpenAI compat
        final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
        return base.endsWith('/v1') ? base : '$base/v1';
      case 'auto':
        // Auto mode defaults to Gemini endpoint
        return _geminiUrl;
      case 'gemini_flash':
      case 'gemini_flash_lite':
        return _geminiUrl;
      case 'cerebras_120b':
        return _cerebrasUrl;
      default:
        return _groqUrl;
    }
  }

  /// The model name string sent to the API
  static String get groqModel {
    switch (_activeModelId) {
      case 'custom_local':
        return _customLocalModel ?? 'qwen3:7b';
      case 'auto':
        // Auto mode defaults to Flash-Lite — task-specific routing handled
        // by modelForTask(); this getter is used for the system prompt header
        return _geminiFlashLite;
      case 'gemini_flash':
        return _geminiFlash;
      case 'gemini_flash_lite':
        return _geminiFlashLite;
      case 'groq_llama4_scout':
        return _groqLlama4Scout;
      case 'groq_kimi_k2':
        return _groqKimiK2;
      case 'groq_qwen3':
        return _groqQwen3;
      case 'groq_8b':
        return _groqModel8B;
      case 'cerebras_120b':
        return _cerebrasModel;
      default:
        return _groqModel70B; // groq_70b
    }
  }

  /// Switch to a specific model
  static void setModel(String modelId) {
    _activeModelId = modelId;
    _saveActiveModel(); // persist so restart remembers the choice
  }

  /// Task-based model routing — picks best model for the task type.
  /// fast             = expense logging, balance updates (speed + volume > quality)
  /// smart            = financial analysis, planning (quality > speed)
  /// financial_advice = complex reasoning, tax, debt strategy (best available)
  static String modelForTask(String taskType) {
    // In Auto mode, delegate entirely to the dynamic router
    if (_activeModelId == 'auto') {
      return _autoActualModel(taskType);
    }

    final hasGemini = (_remoteGeminiKey ?? _fallbackGeminiKey).isNotEmpty;
    switch (taskType) {
      case 'fast':
        // Single-item expense logging — use the active model (user preference)
        // so we don't burn through groq_8b's limited 250 RPD quota.
        return _activeModelId;
      case 'financial_advice':
        // Best reasoning model available
        if (hasGemini)
          return 'gemini_flash'; // Gemini 3.5 Flash: frontier reasoning
        return 'groq_llama4_scout'; // LLaMA 4 Scout: best open-source
      case 'smart':
        if (hasGemini && _activeModelId.startsWith('gemini'))
          return _activeModelId;
        if (hasGemini)
          return 'gemini_flash_lite'; // Gemini Lite: good quality + speed
        return 'groq_llama4_scout'; // LLaMA 4 Scout over 70B: newer arch
      default:
        return _activeModelId;
    }
  }

  /// Auto-fallback when current model hits rate limit (429) or auth failure (401/403).
  /// Falls through the priority chain: best → good → volume.
  /// When in Auto mode, marks the current preferred provider failed and re-routes.
  /// The new model is persisted so the app doesn't retry a failed key after restart.
  static bool autoFallback() {
    final hasGemini = (_remoteGeminiKey ?? _fallbackGeminiKey).isNotEmpty;
    final hasCerebras = (_remoteCerebrasKey ?? _fallbackCerebrasKey).isNotEmpty;

    // Auto mode: track failures internally; rotate preferred provider
    if (_activeModelId == 'auto') {
      _consecutiveFailures++;
      if (_consecutiveFailures >= 3) {
        // All auto-routing attempts failed — temporarily force Groq as base
        // for this SESSION ONLY (do not persist — next cold start returns to auto)
        _consecutiveFailures = 0;
        _activeModelId = 'groq_llama4_scout';
        // Note: intentionally NOT calling _saveActiveModel() here so the
        // fallback is session-only. Auto mode resumes on next cold start.
        return true;
      }
      return true;
    }

    // 8-provider chain: Gemini Flash → Flash-Lite → LLaMA 4 Scout →
    //                   Kimi K2 → Qwen3 32B → LLaMA 3.3 70B → LLaMA 3.1 8B →
    //                   Cerebras GPT-OSS 120B
    switch (_activeModelId) {
      case 'custom_local':
        // Local LLM failed/unreachable — fall back to Gemini or Groq
        _activeModelId = hasGemini ? 'gemini_flash_lite' : 'groq_llama4_scout';
        _saveActiveModel();
        return true;
      case 'gemini_flash':
        _activeModelId = hasGemini ? 'gemini_flash_lite' : 'groq_llama4_scout';
        _saveActiveModel();
        return true;
      case 'gemini_flash_lite':
        _activeModelId = 'groq_llama4_scout';
        _saveActiveModel();
        return true;
      case 'groq_llama4_scout':
        _activeModelId = 'groq_kimi_k2';
        _saveActiveModel();
        return true;
      case 'groq_kimi_k2':
        _activeModelId = 'groq_qwen3';
        _saveActiveModel();
        return true;
      case 'groq_qwen3':
        _activeModelId = 'groq_70b';
        _saveActiveModel();
        return true;
      case 'groq_70b':
        _activeModelId = 'groq_8b';
        _saveActiveModel();
        return true;
      case 'groq_8b':
        _groqLimitReached = true;
        if (hasCerebras) {
          _activeModelId = 'cerebras_120b';
          _saveActiveModel();
          return true;
        }
        if (hasGemini) {
          _activeModelId = 'gemini_flash_lite';
          _saveActiveModel();
          return true;
        }
        // All providers exhausted — reset to auto so next attempt tries fresh
        _activeModelId = 'auto';
        _saveActiveModel();
        return false;
      case 'cerebras_120b':
        // All providers exhausted — reset to auto so next attempt tries fresh
        _activeModelId = 'auto';
        _saveActiveModel();
        return false;
      default:
        _activeModelId = 'auto';
        _saveActiveModel();
        return false;
    }
  }

  /// Reset all limit flags — called at midnight or on manual reset
  static void resetLimits() {
    _groqLimitReached = false;
    _consecutiveFailures = 0;
    // Always reset to Auto so the next session re-evaluates the best model
    _activeModelId = 'auto';
    _saveActiveModel();
  }

  /// Initialize from Firebase Remote Config
  /// Persist the current active model so autoFallback() changes survive restarts.
  /// Called automatically by autoFallback() and setModel().
  static Future<void> _saveActiveModel() async {
    try {
      await DBService.setSetting('active_model_id', _activeModelId);
    } catch (_) {}
  }

  static Future<void> init() async {
    // 1. Apply safe default before anything else — Auto mode picks best at runtime
    _activeModelId = 'auto';

    // 2. One-time migration: reset to 'auto' for users upgrading from before v2.9.50.
    //    v2.9.50 introduced Auto mode as the first entry in availableModels.
    //    Users who upgraded from v2.9.49 or earlier have 'gemini_flash_lite' (or
    //    another pre-auto model) saved in DB. We reset them to 'auto' exactly once
    //    so they benefit from the new dynamic routing without having to manually switch.
    try {
      final migDone = await DBService.getSetting('model_migration_v2950_done');
      if (migDone == null) {
        // First run after v2.9.50+ — reset to auto regardless of saved model
        _activeModelId = 'auto';
        await DBService.setSetting('active_model_id', 'auto');
        await DBService.setSetting('model_migration_v2950_done', 'true');
      } else {
        // Migration already ran — restore the user's last chosen model
        final saved = await DBService.getSetting('active_model_id');
        final validIds = availableModels.map((m) => m.$1).toSet();
        if (saved != null && validIds.contains(saved)) {
          // If the saved model is a chain-fallback model (groq_* / cerebras_*),
          // it was likely saved by an old bug where autoFallback() persisted
          // the session fallback. Reset to 'auto' so the user isn't stuck.
          final isStuckFallback =
              saved.startsWith('groq_') || saved.startsWith('cerebras_');
          _activeModelId = isStuckFallback ? 'auto' : saved;
          if (isStuckFallback) {
            await DBService.setSetting('active_model_id', 'auto');
          }
        }
      }
    } catch (_) {}

    // 3. Load custom local LLM settings (user-configured)
    try {
      final url = await DBService.getSetting('custom_local_url');
      final model = await DBService.getSetting('custom_local_model');
      final key = await DBService.getSetting('custom_local_key');
      if (url != null && url.isNotEmpty) _customLocalUrl = url;
      if (model != null && model.isNotEmpty) _customLocalModel = model;
      if (key != null && key.isNotEmpty) _customLocalKey = key;
    } catch (_) {}

    // 4. Load keys from Firebase Remote Config.
    //    Real keys are stored ONLY in the Firebase Remote Config console —
    //    they are not hardcoded here. Update keys there and publish to rotate.
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        // 1-hour cache for production — balances freshness vs quota.
        // Keys rarely change; daily rotation is fine. Staying at 1h means
        // only the first open each hour hits Firebase; subsequent opens
        // within the hour serve from the local cache.
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await rc.setDefaults({
        'groq_api_key': _fallbackGroqKey,
        'gemini_api_key': _fallbackGeminiKey,
        'cerebras_api_key': _fallbackCerebrasKey,
      });
      bool fetched = false;
      try {
        fetched = await rc.fetchAndActivate();
        await DBService.setSetting(
            'rc_last_fetch_status', fetched ? 'fresh' : 'cached');
      } catch (fetchErr) {
        // fetchAndActivate failed — log the error and continue with defaults
        await DBService.setSetting('rc_last_fetch_status',
            'FETCH_ERROR: ${fetchErr.toString().replaceAll('\n', ' ').substring(0, fetchErr.toString().length.clamp(0, 150))}');
      }
      final rGroq = rc.getString('groq_api_key');
      if (rGroq.isNotEmpty) _remoteGroqKey = rGroq;
      final rGemini = rc.getString('gemini_api_key');
      if (rGemini.isNotEmpty) {
        _remoteGeminiKey = rGemini;
        // Keys loaded successfully — if the current model is a fallback-chain
        // model (not Auto and not a deliberate user Gemini choice), reset to
        // Auto so the user benefits from fresh key availability.
        // Only reset if the model looks like it was a chain fallback:
        // groq_*, cerebras_* are fallbacks; gemini_* and 'auto' are user choices.
        final isChainFallback = _activeModelId.startsWith('groq_') ||
            _activeModelId.startsWith('cerebras_');
        // Don't reset custom_local — user explicitly chose it
        if (isChainFallback) {
          _activeModelId = 'auto';
          await _saveActiveModel();
        }
      }
      final rCerebras = rc.getString('cerebras_api_key');
      if (rCerebras.isNotEmpty) _remoteCerebrasKey = rCerebras;
    } catch (_) {
      // Remote Config unavailable — fallback keys (set via setDefaults above)
      // are already active. AI works normally without network.
    }

    // ── KEY FORMAT NOTE ──────────────────────────────────────────────────────
    // Since May 28, 2026, all new Google AI Studio keys start with "AQ."
    // (auth keys bound to a service account). The old "AIza..." format is
    // being phased out. Both formats are permanent — AQ. keys do NOT expire.
  }
}
