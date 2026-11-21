# Final Model Sort Order - Best to Worst

**For:** SmartSpend v3.3.9  
**User Requirement:** "sort them to the best to lower or worse model"  
**Apply to:** UI picker display AND auto-fallback chain

---

## Canonical Order (Best → Worst)

This is the DEFINITIVE sort order for `AppConfig.availableModels`:

### Tier 0: Special
1. **Auto (Recommended)** - Not a model, smart router
2. **Custom Local** - User's own LLM

### Tier 1: Premium (Best Reasoning & Quality)
3. **Nemotron 3 Ultra (OpenRouter)** - 550B MoE, frontier-tier
4. **Llama 3.3 70B (OpenRouter)** - 70B, 9.4 Intelligence, best reasoning
5. **Gemini 3.5 Flash** - Best Google model, GA stable
6. **Gemini 3.5 Flash-Lite** - Fastest Google, DEFAULT choice

### Tier 2: High Quality (Solid Performance)
7. **Gemma 4 31B (OpenRouter)** - 262K ctx, reliable
8. **Nemotron 3.5 Lightning (OpenRouter)** - Fastest, 1M ctx
9. **Qwen 3.8 27B (OpenRouter)** - Multimodal, OCR, 128K ctx
10. **Groq GPT-OSS 120B** - Best Groq, 1K/day

### Tier 3: Good (Reliable Workhorses)
11. **Nemotron 3.5 Super VL (OpenRouter)** - Vision + video, 1M ctx
12. **Gemma 4 26B A4B (OpenRouter)** - Efficient MoE, 262K ctx
13. **Groq Qwen3.6 27B** - Multilingual, 1K/day
14. **Groq Qwen3.8 27B** - Newer Qwen, 1K/day

### Tier 4: Utility (Fast & Available)
15. **Groq Compound** - 250/day, 70K TPM
16. **Groq Compound Mini** - 250/day, fastest simple
17. **OpenRouter Gateway (Legacy)** - Auto-route, deprecated

### Tier 5: Last Resort (Fallback)
18. **Cerebras GPT-OSS 120B** - 1M tokens/day but slowest

---

## Rationale for Each Position

### 3. Nemotron 3 Ultra (#1 quality model)
- **Why first:** 550B MoE = largest, frontier-tier performance
- **Why not default:** Slower, may have strict rate limits
- **Use when:** Complex financial analysis, multi-step reasoning

### 4. Llama 3.3 70B (#2 quality model)
- **Why second:** 9.4 Intelligence Index, excellent reasoning
- **Sweet spot:** Best balance of quality/speed/availability
- **Use when:** Most AI actions, general chat

### 5. Gemini Flash (#3 quality model)
- **Why third:** Best Google model, proven quality
- **Limitation:** Requires Gemini API key
- **Use when:** Key available, need reliability

### 6. Gemini Flash-Lite (DEFAULT)
- **Why 4th not 3rd:** Slightly less capable than Flash
- **Why DEFAULT:** Fastest, most reliable, best UX
- **Use when:** Most users, most of the time

### 7-10. Mid-tier (Quality workhorses)
- Gemma 4 31B: Proven reliable, large context
- Nemotron Lightning: Speed when quality matters
- Qwen 3.8: Multimodal for OCR
- Groq 120B: Best Groq option

### 11-14. Good tier (Specialized)
- Nemotron Super VL: Vision tasks
- Gemma 4 26B: Efficient alternative
- Groq Qwens: Fast fallbacks

### 15-17. Utility tier (Fast/simple)
- Compounds: Simple tasks, speed priority
- Legacy gateway: Compatibility

### 18. Last resort
- Cerebras: Huge free tier but slow

---

## Updated `availableModels` List

Replace current list in `app_config.dart` with this EXACT order:

```dart
static const availableModels = [
  // Tier 0: Special
  (
    'auto',
    'Auto (Recommended)',
    '🤖 Smart routing — best quality available, auto-fallback'
  ),
  (
    'custom_local',
    'Local AI (Your Computer)',
    '🏠 Private, no cloud, configure in settings'
  ),
  
  // Tier 1: Premium Quality (Best Reasoning)
  (
    'or_nemotron_ultra',
    'Nemotron 3 Ultra (OpenRouter)',
    '🏆 Frontier-tier — 550B MoE, 1M ctx, top free model'
  ),
  (
    'or_llama33',
    'Llama 3.3 70B (OpenRouter)',
    '🦙 Best reasoning — 70B, 128K ctx, 9.4 Intelligence'
  ),
  (
    'gemini_flash',
    'Gemini 3.5 Flash',
    '💎 Best Gemini — frontier reasoning, GA stable'
  ),
  (
    'gemini_flash_lite',
    'Gemini 3.5 Flash-Lite ⭐',
    '⚡ Default — fastest + reliable, GA stable'
  ),
  
  // Tier 2: High Quality (Solid Performance)
  (
    'or_gemma_4_31b',
    'Gemma 4 31B (OpenRouter)',
    '💎 Reliable — 262K ctx, well-tested, balanced'
  ),
  (
    'or_nemotron_lightning',
    'Nemotron 3.5 Lightning (OpenRouter)',
    '⚡ Fastest — MoE, 1M ctx, near-instant responses'
  ),
  (
    'or_qwen38',
    'Qwen 3.8 27B (OpenRouter)',
    '🌐 Multimodal — 128K ctx, OCR, computer-use'
  ),
  (
    'groq_llama4_scout',
    'GPT-OSS 120B (Groq)',
    '🚀 Best Groq — 1,000/day, 8K TPM'
  ),
  
  // Tier 3: Good (Reliable Workhorses)
  (
    'or_nemotron_super_vl',
    'Nemotron 3.5 Super VL (OpenRouter)',
    '🎨 Vision — 1M ctx, image + video understanding'
  ),
  (
    'or_gemma_4_26b',
    'Gemma 4 26B A4B (OpenRouter)',
    '⚙️ Efficient — MoE 3.8B active, 262K ctx'
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
  
  // Tier 4: Utility (Fast & Available)
  (
    'groq_70b',
    'Compound (Groq)',
    '⚡ 250/day, 70K TPM — good general'
  ),
  (
    'groq_8b',
    'Compound Mini (Groq)',
    '💨 250/day, 70K TPM — fast tasks'
  ),
  (
    'openrouter',
    'OpenRouter Gateway (Legacy)',
    '🌐 Auto-route — use individual models instead'
  ),
  
  // Tier 5: Last Resort
  (
    'cerebras_120b',
    'GPT-OSS 120B (Cerebras)',
    '🔄 Fallback — 1M tokens/day (slow)'
  ),
];
```

---

## Auto-Fallback Implementation

When a model fails, iterate through this list in order:

```dart
static bool autoFallback() {
  // Find current model's position in the list
  int currentIndex = availableModels.indexWhere((m) => m.$1 == _activeModelId);
  if (currentIndex == -1) currentIndex = 0; // Safety
  
  // Try each subsequent model in priority order
  for (int i = currentIndex + 1; i < availableModels.length; i++) {
    final candidate = availableModels[i];
    final modelId = candidate.$1;
    
    // Skip special entries
    if (modelId == 'auto' || modelId == 'custom_local') continue;
    
    // Check if required API key is available
    if (!_hasRequiredKey(modelId)) continue;
    
    // Check if model isn't known to be rate-limited
    if (modelId.startsWith('groq_') && _groqLimitReached) continue;
    
    // Found viable fallback
    _activeModelId = modelId;
    _saveActiveModel();
    _consecutiveFailures = 0;
    return true;
  }
  
  // All models exhausted
  _activeModelId = 'auto';
  _saveActiveModel();
  return false;
}

static bool _hasRequiredKey(String modelId) {
  if (modelId.startsWith('or_') || modelId == 'openrouter') {
    return hasOpenRouterKey;
  } else if (modelId.startsWith('gemini_')) {
    return hasGeminiKey;
  } else if (modelId.startsWith('groq_')) {
    return hasGroqKey;
  } else if (modelId.startsWith('cerebras_')) {
    return hasCerebrasKey;
  }
  return true; // custom_local doesn't need key check
}
```

---

## Feature-Specific Priority Overrides

### Receipt OCR (Vision Required)
Try vision-capable models FIRST in order:

1. Nemotron 3.5 Super VL (best vision)
2. Qwen 3.8 27B (OCR-optimized)
3. Gemini Flash (has vision)
4. Gemini Flash-Lite (has vision)
5. Fallback to regular models (may fail gracefully)

### Voice Commands (Speed Required)
Prioritize FAST models:

1. Gemini Flash-Lite (fastest overall)
2. Nemotron 3.5 Lightning (fastest OpenRouter)
3. Groq Compound Mini (fastest Groq)
4. Groq Compound
5. Regular fallback chain

### AI Insights (Quality Required)
Prioritize BEST reasoning:

1. Nemotron 3 Ultra (frontier-tier)
2. Llama 3.3 70B (9.4 Intelligence)
3. Gemini Flash (best Google)
4. Gemma 4 31B (reliable)
5. Regular fallback chain

---

## Testing Verification

After implementing this order, verify:

### UI Picker Order
- [ ] Open AI settings
- [ ] Scroll through model list
- [ ] Verify models appear in EXACT order above
- [ ] Verify descriptions match

### Fallback Chain
- [ ] Mock model #3 (Nemotron Ultra) to return 429
- [ ] Send test message
- [ ] Verify falls to #4 (Llama 3.3)
- [ ] Mock #4 to also fail
- [ ] Verify falls to #5 (Gemini Flash)
- [ ] Continue testing down the chain

### Auto Mode Priority
- [ ] Set to Auto mode
- [ ] Verify uses Gemini Flash-Lite first (if key available)
- [ ] If no Gemini key, uses Llama 3.3
- [ ] If OpenRouter fails, uses Groq 120B

---

## Changes Required

1. **app_config.dart line ~206:**
   - Reorder `availableModels` list to match above
   - Move Nemotron Ultra before Llama 3.3
   - Ensure tier grouping is clear

2. **app_config.dart autoFallback():**
   - Replace custom fallback logic
   - Use list iteration approach
   - Add `_hasRequiredKey()` helper

3. **ocr_service.dart (new file or in llm_service):**
   - Add vision model priority override
   - Try Super VL → Qwen 3.8 → Gemini models

4. **peso_voice_service.dart:**
   - Add speed priority override
   - Try Flash-Lite → Lightning → Compound Mini

5. **insight_service.dart:**
   - Add quality priority override
   - Try Ultra → Llama 3.3 → Gemini Flash

---

## Implementation Priority

**Critical (Do before testing):**
- ✅ Reorder availableModels list ← MUST DO
- ✅ Update autoFallback() to iterate ← MUST DO

**Important (Do if time permits):**
- ⚠️ Vision model priority for OCR
- ⚠️ Speed model priority for voice
- ⚠️ Quality model priority for insights

**Nice to have (Can defer):**
- Tier headers in UI
- Model performance tracking
- Smart retry logic per model

---

**Status:** Specification complete  
**Action:** Send to workflow for implementation  
**Priority:** HIGH - needed for proper testing
