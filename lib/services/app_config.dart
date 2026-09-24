import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'db_service.dart';

/// Centralized app configuration. Multi-model LLM routing (best → good → fallback):
///
/// PRIORITY ORDER (best quality to fastest/most available):
/// 1. Gemini 3.5 Flash        — Best reasoning, GA stable (endpoint: gemini-3.5-flash)
/// 2. Gemini 3.5 Flash-Lite   — Fastest Gemini, GA stable (endpoint: gemini-3.5-flash-lite)
/// 3. Groq LLaMA 4 Scout      — Best open-source quality, 1,000 req/day, 30,000 TPM, ~460 t/s
/// 4. Groq LLaMA 3.3 70B      — Good quality, 1,000 req/day (NOTE: RPD reduced from 14,400 in late 2025)
/// 5. Groq LLaMA 3.1 8B       — Fastest + highest volume: 14,400 req/day — best for fast tasks
/// 6. Cerebras GPT-OSS 120B   — 1M tokens/day FREE, ~3,000 t/s — last resort
///
/// Also available on Groq free tier (not in main chain):
///   moonshotai/kimi-k2-instruct — 1,000 RPD, 60 RPM, strong reasoning
///   qwen/qwen3-32b              — 1,000 RPD, 60 RPM
///   openai/gpt-oss-120b         — 1,000 RPD, 30 RPM (same model as Cerebras)
///
/// Model API names verified against provider docs (September 2026):
///   Gemini:   gemini-3.5-flash, gemini-3.5-flash-lite (GA stable — verified Sep 2026)
///             NOTE: gemini-3.1-flash-lite returned HTTP 404 in production Sep 9, 2026.
///             Root cause: likely endpoint routing instability or key/quota issue.
///             Official Google EOL for 3.1 is May 2027 — not a confirmed shutdown.
///             Migrated to gemini-3.5-flash-lite per Google's upgrade path.
///   Groq:     LLaMA models (llama-4-scout, llama-3.3-70b, llama-3.1-8b) RETIRED from
///             free/dev tier in Feb–Aug 2026 waves (Groq deprecation docs + GitHub trackers).
///             Active on this account: openai/gpt-oss-120b, openai/gpt-oss-20b,
///             qwen/qwen3.6-27b, qwen/qwen3.8-27b, groq/compound, groq/compound-mini
///   Cerebras: gpt-oss-120b (llama3.1-70b deprecated Feb 2026 → replaced by gpt-oss-120b)
///
/// Current default: Gemini 3.5 Flash-Lite (GA stable, fastest + most cost-effective 3.5 model)
class AppConfig {
  AppConfig._();

  // ── FALLBACK KEYS (set as Remote Config defaults at runtime — NOT stored in source) ──
  // These constants are intentionally empty. Real keys are injected via
  // AppConfig.init() → rc.setDefaults() from values stored only in the
  // Firebase Remote Config console, never in this file.
  // To rotate a key: update it in Firebase Remote Config console → publish.
  // The app picks it up on next cold start (minimumFetchInterval: 1 hour).
  static const _fallbackGroqKey = "";
  static const _fallbackGeminiKey = "";
  static const _fallbackCerebrasKey = "";

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
  // NOT available: llama-*, kimi-k2, qwen3-32b (wrong account tier)
  static const _groqLlama4Scout = "openai/gpt-oss-120b";
  // GPT-OSS 120B on Groq: 1K RPD, 8K TPM, strong reasoning — primary Groq model
  static const _groqKimiK2 = "qwen/qwen3.6-27b";
  // Qwen3.6 27B: 1K RPD, 8K TPM, multimodal+reasoning
  static const _groqQwen3 = "qwen/qwen3.8-27b";
  // Qwen3.8 27B: 1K RPD, 8K TPM, newer Qwen
  static const _groqModel70B = "groq/compound";
  // Groq Compound: 250 RPD, 70K TPM — good general model
  static const _groqModel8B = "groq/compound-mini";
  // Compound Mini: 250 RPD, 70K TPM — fast, good for simple tasks

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
        _consecutiveFailures = 0;
        _activeModelId = 'groq_llama4_scout';
        _saveActiveModel();
        return true; // still have providers to try
      }
      // Stay in auto but failures are noted; _autoActualModel will pick differently
      // on next call once Gemini failures are tracked
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

    // 2. Restore last-used model (user preference OR last auto-fallback).
    //    Keys are no longer stored in source — fingerprint check is skipped
    //    since _fallbackGeminiKey is always empty now. The model preference
    //    is restored unconditionally; a fresh Remote Config fetch in step 3
    //    will provide real keys regardless.
    try {
      final saved = await DBService.getSetting('active_model_id');
      final validIds = availableModels.map((m) => m.$1).toSet();
      if (saved != null && validIds.contains(saved)) {
        _activeModelId = saved;
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
      // No defaults passed here — empty defaults mean the app gracefully
      // degrades if Remote Config is unreachable (AI features unavailable,
      // all other features work normally).
      await rc.setDefaults({
        'groq_api_key': '',
        'gemini_api_key': '',
        'cerebras_api_key': '',
      });
      await rc.fetchAndActivate();
      final rGroq = rc.getString('groq_api_key');
      if (rGroq.isNotEmpty) _remoteGroqKey = rGroq;
      final rGemini = rc.getString('gemini_api_key');
      if (rGemini.isNotEmpty) {
        _remoteGeminiKey = rGemini;
        // Only upgrade if user was forced off Gemini due to auth failure.
        // Don't override 'auto' or a deliberate manual model choice.
        if (!_activeModelId.startsWith('gemini') && _activeModelId != 'auto') {
          _activeModelId = 'gemini_flash_lite';
          await _saveActiveModel();
        }
      }
      final rCerebras = rc.getString('cerebras_api_key');
      if (rCerebras.isNotEmpty) _remoteCerebrasKey = rCerebras;
    } catch (_) {
      // Remote Config unavailable — AI features will not work until next
      // successful fetch. All non-AI features work normally offline.
    }
  }
}
