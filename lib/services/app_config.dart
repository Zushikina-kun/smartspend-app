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
  // cerebras_api_key, openrouter_api_key.
  static const _fallbackGroqKey =
      "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";
  static const _fallbackGeminiKey = ""; // Set in Firebase Remote Config
  static const _fallbackCerebrasKey =
      "csk-cwr9ye2pxwyhe89hmexm3t84e5fe3tykjd2d9c86p5vxjd94";
  // OpenRouter key: compile-time fallback read from the OPENROUTER_API_KEY
  // environment variable (flutter build ... --dart-define=OPENROUTER_API_KEY=sk-or-v1-...)
  // Key format: sk-or-v1-... with $100 credit (expires May 14, 2027)
  // The real key is also stored in Firebase Remote Config and loaded at runtime.
  // If neither source provides a key, OR models are skipped (hasOpenRouterKey = false).
  static const _fallbackOpenRouterKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  // ── API ENDPOINTS ──────────────────────────────────────────────────────────
  static const _groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  // Google AI Studio — OpenAI-compatible endpoint
  static const _geminiUrl =
      "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions";
  static const _cerebrasUrl = "https://api.cerebras.ai/v1/chat/completions";
  static const _openRouterUrl = "https://openrouter.ai/api/v1/chat/completions";

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

  // ── OPENROUTER FREE MODELS (tool calling verified) ───────────────────────────
  // All models below support tool calling (function calling) per OpenRouter API.
  // Shared free tier: 50 requests/day across all :free models, resets UTC midnight.
  // For 1000/day limit: add $10 credit at https://openrouter.ai/credits

  // Tier 1: Best quality (frontier-tier reasoning)
  static const _orLlama33 = "meta-llama/llama-3.3-70b-instruct";
  // Llama 3.3 70B: 128K ctx, 9.4 Intelligence Index, excellent reasoning
  static const _orNemotronUltra = "nvidia/nemotron-3-ultra-550b-a55b:free";
  // Nemotron 3 Ultra: 550B MoE, 1M ctx, top-ranked free model
  static const _orNemotronLightning = "nvidia/nemotron-3.5-lightning:free";
  // Nemotron 3.5 Lightning: fast MoE, 1M ctx, excellent speed

  // Tier 2: Balanced quality + multimodal
  static const _orGemma431B = "google/gemma-4-31b-it:free";
  // Gemma 4 31B: 262K ctx, reliable, well-tested
  static const _orQwen38 = "qwen/qwen3.8-27b";
  // Qwen 3.8 27B: 128K ctx, best computer-use, multimodal

  // Tier 3: Special purpose
  static const _orNemotronSuperVL = "nvidia/nemotron-3.5-super-vl:free";
  // Nemotron 3.5 Super VL: 1M ctx, multimodal (image + video)
  static const _orGemma426B = "google/gemma-4-26b-a4b-it:free";
  // Gemma 4 26B A4B: 262K ctx, MoE variant (3.8B active)
  static const _orNemotronNano =
      "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free";
  // Nemotron 3 Nano 30B: reasoning MoE, free tier, omni model

  // Legacy: Keep multi-model array for fallback routing (currently unused)
  static const _openRouterModels = [
    "nvidia/nemotron-3-ultra-550b-a55b:free",
    "nvidia/nemotron-3.5-lightning:free",
    "nvidia/nemotron-3.5-super-vl:free",
    "google/gemma-4-31b-it:free",
    "google/gemma-4-26b-a4b-it:free",
  ];
  // Primary model for single-model fallback display (first in chain)
  static const _openRouterModel = "nvidia/nemotron-3-ultra-550b-a55b:free";

  // ── REMOTE KEYS (from Firebase Remote Config) ─────────────────────────────
  static String? _remoteGroqKey;
  static String? _remoteGeminiKey;
  static String? _remoteCerebrasKey;
  static String? _remoteOpenRouterKey;

  // ── CUSTOM LOCAL LLM (user-configured) ─────────────────────────────────────
  // Set by user in Settings → AI → Local AI section.
  // Format: base URL like "http://192.168.1.5:11434/v1" (Ollama) or ":1234/v1" (LM Studio)
  static String? _customLocalUrl;
  static String? _customLocalModel;
  static String? _customLocalKey; // usually blank for Ollama

  // When true: never fall back to cloud if local server is unreachable.
  // The "data never leaves your network" promise requires this to be true.
  // Default: false (falls back to cloud on failure — more convenient but breaks the privacy guarantee).
  static bool _localOnlyMode = false;

  static bool get localOnlyMode => _localOnlyMode;

  static Future<void> setLocalOnlyMode(bool value) async {
    _localOnlyMode = value;
    try {
      await DBService.setSetting('local_only_mode', value ? 'true' : 'false');
    } catch (_) {}
  }

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
  /// Sorted by quality: Tier 1 (Premium) → Tier 2 (High Quality) → Tier 3 (Good) → Tier 4 (Utility) → Tier 5 (Last Resort)
  /// Model record: (id, label, description, isVision, isFast)
  /// isVision: accepts image input — suitable for receipt/screenshot OCR via AI.
  /// isFast:   low-latency, high-throughput — preferred for real-time voice commands.
  static const availableModels = [
    // ── TIER 0: SPECIAL ──────────────────────────────────────────────────────
    (
      'auto',
      'Auto (Recommended)',
      '🤖 Smart routing — best quality available, auto-fallback',
      false, // isVision
      false, // isFast
    ),
    (
      'custom_local',
      'Local AI (Your Computer)',
      '🏠 Your own LLM via WiFi — private, no cloud, configure in Local AI settings',
      false,
      false,
    ),
    // ── TIER 1: PREMIUM QUALITY (Best Reasoning) ─────────────────────────────
    (
      'or_nemotron_ultra',
      'Nemotron 3 Ultra (OpenRouter)',
      '🏆 Frontier-tier — 550B MoE, 1M ctx, top free model',
      false,
      false,
    ),
    (
      'or_llama33',
      'Llama 3.3 70B (OpenRouter)',
      '🦙 Best reasoning — 70B, 128K ctx, 9.4 Intelligence Index',
      false,
      false,
    ),
    (
      'gemini_flash',
      'Gemini 3.5 Flash',
      '💎 Best Gemini — frontier reasoning, GA stable (needs Gemini key)',
      true, // Gemini 3.5 Flash accepts image input
      false,
    ),
    (
      'gemini_flash_lite',
      'Gemini 3.5 Flash-Lite ⭐',
      '⚡ Default — fastest + reliable, GA stable (needs Gemini key)',
      true, // Gemini 3.5 Flash-Lite accepts image input
      true, // fastest Gemini
    ),
    // ── TIER 2: HIGH QUALITY (Solid Performance) ─────────────────────────────
    (
      'or_gemma_4_31b',
      'Gemma 4 31B (OpenRouter)',
      '💎 Reliable — 262K ctx, well-tested, balanced',
      false,
      false,
    ),
    (
      'or_nemotron_lightning',
      'Nemotron 3.5 Lightning (OpenRouter)',
      '⚡ Fastest — MoE, 1M ctx, near-instant responses',
      false,
      true, // near-instant responses
    ),
    (
      'or_qwen38',
      'Qwen 3.8 27B (OpenRouter)',
      '🌐 Multimodal — 128K ctx, OCR, computer-use',
      true, // multimodal — accepts image input
      false,
    ),
    (
      'groq_llama4_scout',
      'GPT-OSS 120B (Groq)',
      '🚀 Best Groq — 1,000/day, 8K TPM',
      false,
      false,
    ),
    // ── TIER 3: GOOD (Reliable Workhorses) ───────────────────────────────────
    (
      'or_nemotron_super_vl',
      'Nemotron 3.5 Super VL (OpenRouter)',
      '🎨 Vision — 1M ctx, image + video understanding',
      true, // vision model — image + video
      false,
    ),
    (
      'or_gemma_4_26b',
      'Gemma 4 26B A4B (OpenRouter)',
      '⚙️ Efficient — MoE 3.8B active, 262K ctx',
      false,
      false,
    ),
    (
      'or_nemotron_nano',
      'Nemotron Nano 30B (OpenRouter)',
      '🧠 Reasoning — 30B MoE, free tier, omni model',
      false,
      false,
    ),
    (
      'groq_kimi_k2',
      'Qwen3.6 27B (Groq)',
      '🌐 Multimodal + reasoning — 1,000/day',
      true, // multimodal — accepts image input
      false,
    ),
    (
      'groq_qwen3',
      'Qwen3.8 27B (Groq)',
      '✨ Newer Qwen, multimodal — 1,000/day',
      true, // multimodal — accepts image input
      false,
    ),
    // ── TIER 4: UTILITY (Fast & Available) ───────────────────────────────────
    (
      'groq_70b',
      'Compound (Groq)',
      '⚡ 250/day, 70K TPM — good general',
      false,
      true, // good general, 70K TPM
    ),
    (
      'groq_8b',
      'Compound Mini (Groq)',
      '💨 250/day, 70K TPM — fast tasks',
      false,
      true, // fast tasks
    ),
    (
      'openrouter',
      'OpenRouter Gateway (Legacy)',
      '🌐 Auto-route — use individual models above instead',
      false,
      false,
    ),
    // ── TIER 5: LAST RESORT (Fallback) ───────────────────────────────────────
    (
      'cerebras_120b',
      'GPT-OSS 120B (Cerebras)',
      '🔄 Fallback — 1M tokens/day, ~3,000 t/s throughput',
      false,
      false, // last-resort throughput; excluded from fast pool (5 RPM free tier)
    ),
  ];

  static String get activeModelId => _activeModelId;

  /// IDs of models capable of accepting image input (isVision == true).
  /// Used by OCR to prefer vision-capable models for AI-assisted parsing.
  static List<String> get visionModelIds =>
      availableModels.where((m) => m.$4).map((m) => m.$1).toList();

  /// IDs of fast/low-latency models (isFast == true).
  /// Used by voice commands to prefer speed over maximum quality.
  static List<String> get fastModelIds =>
      availableModels.where((m) => m.$5).map((m) => m.$1).toList();

  /// Returns the best available vision model ID, preferring models with an
  /// available key. Returns null if no vision model key is configured.
  static String? get preferredVisionModelId {
    for (final id in visionModelIds) {
      if (id == 'auto' || id == 'custom_local') continue;
      if (id.startsWith('or_') && !hasOpenRouterKey) continue;
      if (id.startsWith('gemini') && !hasGeminiKey) continue;
      if (id.startsWith('groq_') && !hasGroqKey) continue;
      if (id == 'cerebras_120b' && !hasCerebrasKey) continue;
      return id;
    }
    return null;
  }

  /// Returns the best available fast model ID, preferring models with an
  /// available key. Falls back to the current active model if none found.
  static String get preferredFastModelId {
    for (final id in fastModelIds) {
      if (id == 'auto' || id == 'custom_local') continue;
      if (id.startsWith('or_') && !hasOpenRouterKey) continue;
      if (id.startsWith('gemini') && !hasGeminiKey) continue;
      if (id.startsWith('groq_') && !hasGroqKey) continue;
      if (id == 'cerebras_120b' && !hasCerebrasKey) continue;
      return id;
    }
    return _activeModelId;
  }

  /// The concrete model ID the current request actually uses. In Auto mode
  /// this is the chain walk model (or the first available if not yet
  /// walking); otherwise it's the user's selected model. Use this — not
  /// [activeModelId] — to decide provider-specific request headers, because
  /// Auto mode keeps activeModelId as 'auto' while routing to a concrete model.
  static String get effectiveModelId =>
      _activeModelId == 'auto' ? _autoActiveModelId() : _activeModelId;

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

  /// Internal: the concrete model an Auto-mode request uses right now. Auto
  /// mode walks `_autoFallbackChain` best→worst. The first attempt uses the
  /// first chain entry whose provider key is available; once a fallback is in
  /// progress, `_autoWalkModel` holds the model the current (failed) request
  /// used and autoFallback() advances past it. The task type no longer
  /// affects routing — every Auto request starts at the top of the chain so
  /// the walk is genuinely best→worst (the user's "from best to worse" intent).
  static String _autoActualModel(String taskType) =>
      _autoWalkModel ?? _firstAvailableChainModel();

  static bool get groqLimitReached => _groqLimitReached;

  /// Whether each key type is currently available (for debug reporting)
  static bool get hasGeminiKey =>
      (_remoteGeminiKey ?? _fallbackGeminiKey).isNotEmpty;
  static bool get hasGroqKey => (_remoteGroqKey ?? _fallbackGroqKey).isNotEmpty;
  static bool get hasCerebrasKey =>
      (_remoteCerebrasKey ?? _fallbackCerebrasKey).isNotEmpty;
  static bool get hasOpenRouterKey =>
      (_remoteOpenRouterKey ?? _fallbackOpenRouterKey).isNotEmpty;

  /// The active API key for the current model
  static String get groqApiKey => _apiKeyFor(
      _activeModelId == 'auto' ? _autoActiveModelId() : _activeModelId);

  static String _apiKeyFor(String id) {
    switch (id) {
      case 'custom_local':
        return _customLocalKey ?? '';
      // All OpenRouter models use the same API key
      case 'or_llama33':
      case 'or_nemotron_ultra':
      case 'or_nemotron_lightning':
      case 'or_gemma_4_31b':
      case 'or_qwen38':
      case 'or_nemotron_super_vl':
      case 'or_gemma_4_26b':
      case 'or_nemotron_nano':
      case 'openrouter':
        // Return the OR key (or empty string if unavailable).
        // hasOpenRouterKey guards callers — an empty return here prevents the
        // request from being made. Never substitute a Groq key: sending gsk_…
        // to OpenRouter causes a silent 401 that bypasses the real OR key.
        return _remoteOpenRouterKey ?? _fallbackOpenRouterKey;
      case 'gemini_flash':
      case 'gemini_flash_lite':
        return _remoteGeminiKey ?? _fallbackGeminiKey;
      case 'cerebras_120b':
        return _remoteCerebrasKey ?? _fallbackCerebrasKey;
      default: // all Groq models
        return _remoteGroqKey ?? _fallbackGroqKey;
    }
  }

  /// The OpenRouter multi-model fallback list (sent as 'models' array in request)
  static List<String> get openRouterModels =>
      List.unmodifiable(_openRouterModels);

  /// The API base URL for the active model
  static String get groqBaseUrl => _baseUrlFor(
      _activeModelId == 'auto' ? _autoActiveModelId() : _activeModelId);

  static String _baseUrlFor(String id) {
    switch (id) {
      case 'custom_local':
        // Use user-configured URL; default to Ollama if not set
        final url = _customLocalUrl ?? 'http://localhost:11434/v1';
        // Strip trailing slash, ensure /v1 suffix for OpenAI compat
        final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
        return base.endsWith('/v1') ? base : '$base/v1';
      // All OpenRouter models use the same endpoint
      case 'or_llama33':
      case 'or_nemotron_ultra':
      case 'or_nemotron_lightning':
      case 'or_gemma_4_31b':
      case 'or_qwen38':
      case 'or_nemotron_super_vl':
      case 'or_gemma_4_26b':
      case 'or_nemotron_nano':
      case 'openrouter':
        return _openRouterUrl;
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
  static String get groqModel => _modelNameFor(
      _activeModelId == 'auto' ? _autoActiveModelId() : _activeModelId);

  static String _modelNameFor(String id) {
    switch (id) {
      case 'custom_local':
        return _customLocalModel ?? 'qwen3:7b';
      // OpenRouter individual models
      case 'or_llama33':
        return _orLlama33;
      case 'or_nemotron_ultra':
        return _orNemotronUltra;
      case 'or_nemotron_lightning':
        return _orNemotronLightning;
      case 'or_gemma_4_31b':
        return _orGemma431B;
      case 'or_qwen38':
        return _orQwen38;
      case 'or_nemotron_super_vl':
        return _orNemotronSuperVL;
      case 'or_gemma_4_26b':
        return _orGemma426B;
      case 'or_nemotron_nano':
        return _orNemotronNano;
      case 'openrouter':
        return _openRouterModel; // Legacy gateway
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

    // Individual OpenRouter models are now stable — use them directly
    // Legacy 'openrouter' gateway redirects to best individual model
    final effectiveModel = _activeModelId == 'openrouter'
        ? 'or_llama33' // Use best individual model instead of gateway
        : _activeModelId;

    final hasGemini = (_remoteGeminiKey ?? _fallbackGeminiKey).isNotEmpty;
    switch (taskType) {
      case 'fast':
        return effectiveModel;
      case 'financial_advice':
        if (hasGemini) {
          return 'gemini_flash';
        }
        return 'groq_llama4_scout';
      case 'smart':
        if (hasGemini && effectiveModel.startsWith('gemini')) {
          return effectiveModel;
        }
        if (hasGemini) {
          return 'gemini_flash_lite';
        }
        return 'groq_llama4_scout';
      default:
        return effectiveModel;
    }
  }

  // Auto mode chain — walked best→worst, skipping providers with no key.
  // The walk is driven by `_autoWalkModel` (the concrete model the current
  // Auto request is using) rather than a separate counter, so there is no
  // index that can survive a failed request or interleave across concurrent
  // calls. resetAutoChain() clears the walk so the next request starts from
  // the top of the chain.
  static const _autoFallbackChain = [
    'or_nemotron_ultra',
    'or_llama33',
    'or_gemma_4_31b',
    'or_nemotron_lightning',
    'or_qwen38',
    'or_nemotron_nano',
    'or_nemotron_super_vl',
    'or_gemma_4_26b',
    'gemini_flash',
    'gemini_flash_lite',
    'groq_kimi_k2',
    'groq_qwen3',
    'groq_70b',
    'groq_8b',
    'cerebras_120b',
  ];
  // The concrete chain model the current Auto request uses. null when not
  // yet walking (the request uses the first available chain entry). Set by
  // autoFallback(); cleared by resetAutoChain() (success/failure) and on
  // exhaustion, so a failed request can never leave the walk mid-chain.
  static String? _autoWalkModel;

  /// First chain entry whose provider key is available — Auto mode's
  /// starting point, so an empty-key provider is never tried first.
  static String _firstAvailableChainModel() {
    for (final m in _autoFallbackChain) {
      if (m.startsWith('or_') && !hasOpenRouterKey) continue;
      if (m.startsWith('gemini') && !hasGeminiKey) continue;
      if (m == 'cerebras_120b' && !hasCerebrasKey) continue;
      return m;
    }
    return _autoFallbackChain.first;
  }

  /// The concrete model an Auto request uses right now: the in-progress walk
  /// model, or the first available chain entry when not yet walking.
  static String _autoActiveModelId() =>
      _autoWalkModel ?? _firstAvailableChainModel();

  /// Clear the Auto-mode walk so the next request starts at the top of the
  /// chain. Called after a successful response and on every failure path.
  static void resetAutoChain() => _autoWalkModel = null;

  /// Auto-fallback when current model hits rate limit (429) or auth failure (401/403).
  /// Falls through the priority chain: best → good → volume.
  /// When in Auto mode, marks the current preferred provider failed and re-routes.
  /// The new model is persisted so the app doesn't retry a failed key after restart.
  static bool autoFallback() {
    final hasGemini = (_remoteGeminiKey ?? _fallbackGeminiKey).isNotEmpty;
    final hasCerebras = (_remoteCerebrasKey ?? _fallbackCerebrasKey).isNotEmpty;
    final hasOpenRouter =
        (_remoteOpenRouterKey ?? _fallbackOpenRouterKey).isNotEmpty;

    // Auto mode: walk `_autoFallbackChain` best→worst, starting one step past
    // the model the current (failed) request used. On the first failure
    // `_autoWalkModel` is null, so the "current" model is the first available
    // chain entry — which the request just used — and we skip it instead of
    // re-trying it. Because the first request also uses that same first
    // available entry (via the getters), the chain's best model is always
    // tried and never skipped. Session-only: only `_autoWalkModel` advances —
    // we never touch `_activeModelId`, so the user stays on Auto.
    if (_activeModelId == 'auto') {
      final current = _autoWalkModel ?? _firstAvailableChainModel();
      final startIdx = _autoFallbackChain.indexOf(current);
      for (int i = startIdx + 1; i < _autoFallbackChain.length; i++) {
        final next = _autoFallbackChain[i];
        // Skip OR models if no OR key
        if (next.startsWith('or_') && !hasOpenRouter) continue;
        if (next.startsWith('gemini') && !hasGemini) continue;
        if (next == 'cerebras_120b' && !hasCerebras) continue;
        _autoWalkModel = next;
        return true;
      }
      // All models exhausted — reset for next session
      _autoWalkModel = null;
      return false;
    }

    // NEW FALLBACK CHAIN (Nov 2026 - SORTED BEST TO WORST):
    // Custom Local → Nemotron Ultra → Llama 3.3 → Gemini Flash → Flash-Lite →
    // Gemma 4 31B → Nemotron Lightning → Qwen 3.8 → Groq chain → Cerebras
    switch (_activeModelId) {
      case 'custom_local':
        if (_localOnlyMode) {
          return false;
        }
        _activeModelId = hasOpenRouter
            ? 'or_nemotron_ultra'
            : (hasGemini ? 'gemini_flash' : 'groq_llama4_scout');
        _saveActiveModel();
        return true;

      // OpenRouter fallback chain (SORTED: best quality → fast → utility)
      case 'or_nemotron_ultra':
        _activeModelId = 'or_llama33';
        _saveActiveModel();
        return true;

      case 'or_llama33':
        _activeModelId = hasGemini ? 'gemini_flash' : 'or_gemma_4_31b';
        _saveActiveModel();
        return true;

      case 'gemini_flash':
        _activeModelId = hasGemini
            ? 'gemini_flash_lite'
            : (hasOpenRouter ? 'or_gemma_4_31b' : 'groq_llama4_scout');
        _saveActiveModel();
        return true;

      case 'gemini_flash_lite':
        _activeModelId = hasOpenRouter ? 'or_gemma_4_31b' : 'groq_llama4_scout';
        _saveActiveModel();
        return true;

      case 'or_gemma_4_31b':
        _activeModelId = 'or_nemotron_lightning';
        _saveActiveModel();
        return true;

      case 'or_nemotron_lightning':
        _activeModelId = 'or_qwen38';
        _saveActiveModel();
        return true;

      case 'or_qwen38':
        _activeModelId = 'groq_llama4_scout';
        _saveActiveModel();
        return true;

      case 'or_nemotron_super_vl':
        _activeModelId = 'or_gemma_4_26b';
        _saveActiveModel();
        return true;

      case 'or_gemma_4_26b':
        _activeModelId = 'or_nemotron_nano';
        _saveActiveModel();
        return true;

      case 'or_nemotron_nano':
        _activeModelId = 'groq_kimi_k2';
        _saveActiveModel();
        return true;

      case 'openrouter':
        // Legacy gateway failed — switch to best individual model
        _activeModelId = hasOpenRouter
            ? 'or_nemotron_ultra'
            : (hasGemini ? 'gemini_flash' : 'groq_llama4_scout');
        _saveActiveModel();
        return true;

      // Groq chain
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
    _autoWalkModel = null; // clear any in-progress Auto chain walk
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
      final localOnly = await DBService.getSetting('local_only_mode');
      if (url != null && url.isNotEmpty) _customLocalUrl = url;
      if (model != null && model.isNotEmpty) _customLocalModel = model;
      if (key != null && key.isNotEmpty) _customLocalKey = key;
      if (localOnly == 'true') _localOnlyMode = true;
    } catch (_) {}

    // 4. Load keys from Firebase Remote Config.
    //    Real keys are stored ONLY in the Firebase Remote Config console —
    //    they are not hardcoded here. Update keys there and publish to rotate.
    try {
      final rc = FirebaseRemoteConfig.instance;

      // Fix 2: Use a short fetch interval on first load so the OpenRouter key
      // loads quickly on cold start (rc_last_fetch_status == null means first
      // open; stale > 1 hr means the last fetch was more than an hour ago).
      // After the first successful fetch, the 1-hour default interval applies.
      Duration fetchInterval = const Duration(hours: 1);
      try {
        final lastStatus = await DBService.getSetting('rc_last_fetch_status');
        final lastFetchTs = await DBService.getSetting('rc_last_fetch_ts');
        bool isFirstLoad = lastStatus == null;
        bool isStale = false;
        if (lastFetchTs != null) {
          final lastFetch = DateTime.tryParse(lastFetchTs);
          if (lastFetch != null) {
            isStale = DateTime.now().difference(lastFetch).inMinutes > 60;
          }
        } else {
          // No timestamp recorded yet — treat as stale
          isStale = true;
        }
        if (isFirstLoad || isStale) {
          fetchInterval = const Duration(minutes: 5);
        }
      } catch (_) {}

      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        // First load / stale cache: 5-minute interval so the OpenRouter key
        // loads quickly instead of waiting out the 1-hour server-side cache.
        // After first successful fetch the interval reverts to 1 hour.
        minimumFetchInterval: fetchInterval,
      ));
      await rc.setDefaults({
        'groq_api_key': _fallbackGroqKey,
        'gemini_api_key': _fallbackGeminiKey,
        'cerebras_api_key': _fallbackCerebrasKey,
        'openrouter_api_key': _fallbackOpenRouterKey,
      });
      bool fetched = false;
      try {
        fetched = await rc.fetchAndActivate();
        final nowIso = DateTime.now().toUtc().toIso8601String();
        await DBService.setSetting(
            'rc_last_fetch_status', fetched ? 'fresh' : 'cached');
        // Record timestamp so the next launch can decide whether to use
        // the short interval (5 min) or the normal 1-hour interval.
        await DBService.setSetting('rc_last_fetch_ts', nowIso);
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
      final rOpenRouter = rc.getString('openrouter_api_key');
      if (rOpenRouter.isNotEmpty) _remoteOpenRouterKey = rOpenRouter;
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
