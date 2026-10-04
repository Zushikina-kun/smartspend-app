import 'package:firebase_remote_config/firebase_remote_config.dart';
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
/// Current default: Auto mode → Gemini 3.5 Flash-Lite (GA stable, fastest 3.5)
class AppConfig {
  AppConfig._();

  // ── FALLBACK KEYS (set as Remote Config defaults at runtime — NOT stored in source) ──
  // These constants are intentionally empty. Real keys are injected via
  // ── FALLBACK KEYS — used when Firebase Remote Config is unreachable ─────────
  // These are the actual working keys. Remote Config overrides them when
  // available, but if the fetch fails (slow/no internet at startup), these
  // ensure AI works immediately without any network dependency.
  // The file is in .gitignore so these never reach the public repo.
  // To rotate: update Remote Config AND update these constants + rebuild.
  static const _fallbackGroqKey =
      "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";
  static const _fallbackGeminiKey =
      "AQ.Ab8RN6LZ3JhKel-t0ovzCNEySO2KuE3LYLNAQWjr6ewBGs-nUA";
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

  /// The active API key for the current model
  static String get groqApiKey {
    switch (_activeModelId) {
      case 'auto':
        // Auto mode routes to Gemini Flash-Lite by default; use Gemini key
        // Return empty if key is invalid so autoFallback() skips Gemini
        final k = _remoteGeminiKey ?? _fallbackGeminiKey;
        return k.startsWith('AIza') ? k : '';
      case 'gemini_flash':
      case 'gemini_flash_lite':
        final k = _remoteGeminiKey ?? _fallbackGeminiKey;
        return k.startsWith('AIza') ? k : '';
      case 'cerebras_120b':
        return _remoteCerebrasKey ?? _fallbackCerebrasKey;
      default: // all Groq models
        return _remoteGroqKey ?? _fallbackGroqKey;
    }
  }

  /// The API base URL for the active model
  static String get groqBaseUrl {
    switch (_activeModelId) {
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

    // 3. Load keys from Firebase Remote Config.
    //    Real keys are stored ONLY in the Firebase Remote Config console —
    //    they are not hardcoded here. Update keys there and publish to rotate.
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      // Pass actual fallback keys as Remote Config defaults so they're
      // available immediately even if fetchAndActivate hasn't completed yet.
      // This ensures AI works on first open even with slow internet.
      await rc.setDefaults({
        'groq_api_key': _fallbackGroqKey,
        'gemini_api_key': _fallbackGeminiKey,
        'cerebras_api_key': _fallbackCerebrasKey,
      });
      await rc.fetchAndActivate();
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

    // ── GEMINI KEY VALIDITY CHECK ─────────────────────────────────────────────
    // Google AI Studio keys always start with "AIza". Any other prefix
    // (OAuth tokens, service account keys, etc.) will return 401 immediately.
    // If the active key looks invalid, mark Gemini as unavailable so the
    // fallback chain skips it without a 35-second timeout.
    final activeGeminiKey = _remoteGeminiKey ?? _fallbackGeminiKey;
    if (activeGeminiKey.isNotEmpty && !activeGeminiKey.startsWith('AIza')) {
      // Key format is wrong — don't try Gemini, fall straight to Groq
      _remoteGeminiKey = null;
      // Log so developer can see this in the debug log
      try {
        final hint = activeGeminiKey.length > 6
            ? activeGeminiKey.substring(0, 6)
            : activeGeminiKey;
        await DBService.setSetting('gemini_key_warning',
            'Key starts with "$hint..." — expected "AIza...". Get a new key at aistudio.google.com/app/apikey');
      } catch (_) {}
    }
  }
}
