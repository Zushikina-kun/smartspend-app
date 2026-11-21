# AI Model Priority Order - Best to Worst

**Version:** 3.3.9  
**Last Updated:** Nov 20, 2026  
**Purpose:** Define canonical model order for UI picker and auto-fallback chain

---

## Sorting Criteria

Models are ranked by:

1. **Reasoning Quality** (40%) - Accuracy, nuance, complex instruction following
2. **Tool Calling Reliability** (30%) - Critical for SmartSpend's 34 AI actions
3. **Speed/Latency** (15%) - Response time for good UX
4. **Rate Limits** (10%) - Higher limits = more reliable
5. **Uptime/Stability** (5%) - Consistent availability

---

## Final Sorted Order (Best → Worst)

### Tier 1: Premium Quality (Top Reasoning)

#### 1. Hermes 3 405B (OpenRouter)
- **ID:** `openrouter_hermes3_405b`
- **Model:** `nousresearch/hermes-3-llama-3.1-405b:free`
- **Why #1:** Largest model (405B), best reasoning, excellent tool calling
- **Strengths:** Complex multi-step tasks, edge cases, ambiguous queries
- **Weaknesses:** Slower (~5-8s), stricter rate limits
- **Use Cases:** Complex AI actions, financial calculations, multi-turn conversations
- **Tool Calling:** ⭐⭐⭐⭐⭐ Excellent
- **Speed:** ⭐⭐ Slow (405B)
- **Rate Limit:** ⭐⭐⭐ Moderate (free tier)

#### 2. Gemini 3.5 Flash (Direct Google API)
- **ID:** `gemini_flash`
- **Model:** `gemini-3.5-flash`
- **Why #2:** Best Google model, GA stable, strong reasoning
- **Strengths:** Balanced quality/speed, reliable, good tool calling
- **Weaknesses:** Moderate rate limits, requires API key
- **Use Cases:** General chat, most AI actions, balanced workload
- **Tool Calling:** ⭐⭐⭐⭐ Very Good
- **Speed:** ⭐⭐⭐⭐ Fast (~2-3s)
- **Rate Limit:** ⭐⭐⭐⭐ Good

#### 3. LLaMA 3.3 70B (OpenRouter)
- **ID:** `openrouter_llama33_70b`
- **Model:** `meta-llama/llama-3.3-70b-instruct:free`
- **Why #3:** Excellent Meta model, great instruction following
- **Strengths:** Good reasoning, reliable tool calling, fast for size
- **Weaknesses:** OpenRouter routing overhead
- **Use Cases:** Most AI actions, general chat, good all-rounder
- **Tool Calling:** ⭐⭐⭐⭐ Very Good
- **Speed:** ⭐⭐⭐ Moderate (~3-4s)
- **Rate Limit:** ⭐⭐⭐⭐ Good (free tier)

#### 4. Gemini 3.5 Flash-Lite (DEFAULT)
- **ID:** `gemini_flash_lite`
- **Model:** `gemini-3.5-flash-lite`
- **Why #4 (DEFAULT):** Fastest Gemini, proven stable, GA stable
- **Strengths:** Very fast, reliable, good enough for most tasks
- **Weaknesses:** Slightly lower reasoning than Flash
- **Use Cases:** Default for all users, fast responses, most AI actions
- **Tool Calling:** ⭐⭐⭐⭐ Very Good
- **Speed:** ⭐⭐⭐⭐⭐ Fastest (~1-2s)
- **Rate Limit:** ⭐⭐⭐⭐ Good

**Why Flash-Lite is default despite being #4:**
- Proven stability (used since v3.0)
- Fastest response times (best UX)
- Free tier most reliable
- "Good enough" for 95% of use cases
- #1-3 are "upgrade" options for power users

---

### Tier 2: Solid Performance (Production Ready)

#### 5. Groq GPT-OSS 120B
- **ID:** `groq_120b`
- **Model:** `openai/gpt-oss-120b`
- **Why #5:** Strong reasoning, reliable Groq hosting
- **Strengths:** Fast Groq inference, 1K req/day, stable
- **Weaknesses:** Groq rate limits shared across models
- **Use Cases:** Good fallback from Gemini, most AI actions work
- **Tool Calling:** ⭐⭐⭐⭐ Very Good
- **Speed:** ⭐⭐⭐⭐ Fast (Groq acceleration)
- **Rate Limit:** ⭐⭐⭐ 1K/day

#### 6. Qwen 2.5 72B (OpenRouter)
- **ID:** `openrouter_qwen25_72b`
- **Model:** `qwen/qwen-2.5-72b-instruct:free`
- **Why #6:** Excellent multilingual, good reasoning
- **Strengths:** Best for Tagalog/Filipino, strong on Asian languages
- **Weaknesses:** OpenRouter routing overhead
- **Use Cases:** Filipino finance terms, multilingual users, Asian context
- **Tool Calling:** ⭐⭐⭐⭐ Very Good
- **Speed:** ⭐⭐⭐ Moderate
- **Rate Limit:** ⭐⭐⭐⭐ Good

#### 7. Groq Qwen3.6 27B
- **ID:** `groq_qwen36`
- **Model:** `qwen/qwen3.6-27b`
- **Why #7:** Solid Qwen model, fast Groq hosting
- **Strengths:** Fast, multilingual, 1K/day
- **Weaknesses:** Smaller than Qwen2.5 72B above
- **Use Cases:** Fast multilingual, Groq fallback option
- **Tool Calling:** ⭐⭐⭐ Good
- **Speed:** ⭐⭐⭐⭐ Fast
- **Rate Limit:** ⭐⭐⭐ 1K/day

#### 8. Groq Qwen3.8 27B
- **ID:** `groq_qwen38`
- **Model:** `qwen/qwen3.8-27b`
- **Why #8:** Newer Qwen iteration
- **Strengths:** Latest Qwen on Groq, fast
- **Weaknesses:** Similar to 3.6, marginal improvements
- **Use Cases:** Alternative to Qwen3.6 if rate limited
- **Tool Calling:** ⭐⭐⭐ Good
- **Speed:** ⭐⭐⭐⭐ Fast
- **Rate Limit:** ⭐⭐⭐ 1K/day

---

### Tier 3: Utility Models (Special Purposes)

#### 9. Gemini 2.0 Flash Exp (OpenRouter)
- **ID:** `openrouter_gemini2_flash`
- **Model:** `google/gemini-2.0-flash-exp:free`
- **Why #9:** VISION SUPPORT - only for receipt OCR
- **Strengths:** Latest experimental Gemini, vision capabilities
- **Weaknesses:** "Experimental" stability, OpenRouter routing
- **Use Cases:** **Receipt scanning**, batch image import, image analysis
- **Tool Calling:** ⭐⭐⭐⭐ Very Good
- **Speed:** ⭐⭐⭐⭐ Fast
- **Rate Limit:** ⭐⭐⭐ Experimental tier
- **SPECIAL:** Use this for OCR/vision tasks specifically

#### 10. Groq Compound
- **ID:** `groq_compound`
- **Model:** `groq/compound`
- **Why #10:** General purpose, decent performance
- **Strengths:** Fast Groq hosting, general purpose
- **Weaknesses:** Lower rate limits (250/day)
- **Use Cases:** General fallback when bigger models rate limited
- **Tool Calling:** ⭐⭐⭐ Good
- **Speed:** ⭐⭐⭐⭐ Fast
- **Rate Limit:** ⭐⭐ 250/day

#### 11. Groq Compound Mini
- **ID:** `groq_compound_mini`
- **Model:** `groq/compound-mini`
- **Why #11:** Fastest Groq option, simple tasks
- **Strengths:** Very fast, simple queries work well
- **Weaknesses:** Lower reasoning, 250/day limit
- **Use Cases:** Simple AI actions, fast responses needed
- **Tool Calling:** ⭐⭐ Basic
- **Speed:** ⭐⭐⭐⭐⭐ Fastest
- **Rate Limit:** ⭐⭐ 250/day

---

### Tier 4: Last Resort Fallbacks

#### 12. Mistral 7B (OpenRouter)
- **ID:** `openrouter_mistral_7b`
- **Model:** `mistralai/mistral-7b-instruct:free`
- **Why #12:** Smallest model, fastest but weakest reasoning
- **Strengths:** Very fast, most generous rate limits, always available
- **Weaknesses:** Weak tool calling, simple reasoning only
- **Use Cases:** When all else fails, simple queries, rate limit fallback
- **Tool Calling:** ⭐ Weak (may fail complex actions)
- **Speed:** ⭐⭐⭐⭐⭐ Fastest
- **Rate Limit:** ⭐⭐⭐⭐⭐ Most generous

#### 13. Cerebras GPT-OSS 120B
- **ID:** `cerebras_120b`
- **Model:** GPT-OSS on Cerebras infrastructure
- **Why #13 (LAST):** Absolute last resort, slowest but huge free tier
- **Strengths:** 1M tokens/day FREE, always available
- **Weaknesses:** Very slow (~10-15s), inconsistent quality
- **Use Cases:** When literally everything else failed or rate limited
- **Tool Calling:** ⭐⭐ Weak to moderate
- **Speed:** ⭐ Very slow
- **Rate Limit:** ⭐⭐⭐⭐⭐ 1M tokens/day (highest)

---

## Auto-Fallback Chain Logic

When a model fails (401, 429, timeout, error), the system automatically tries the next model in this order:

```
User sends message
    ↓
Try Model #1 (Hermes 3 405B) — if user selected, or #4 (Flash-Lite) if Auto
    ↓ [FAIL: 429 rate limit]
Try Model #2 (Gemini Flash)
    ↓ [FAIL: 401 auth error]
Try Model #3 (LLaMA 3.3 70B)
    ↓ [SUCCESS]
Return response ✓

If ALL 13 models fail:
    → Show error: "All AI models unavailable. Check internet connection."
```

### Smart Skipping:
- Skip models with `groqLimitReached` flag set
- Skip models known to be down (if status tracking implemented)
- Don't retry same model twice in one chain
- Timeout after 2 tries per model (no infinite loops)

---

## Implementation Checklist

### app_config.dart Changes:

1. **availableModels list** - reorder to match priority:
```dart
static final availableModels = [
  ('openrouter_hermes3_405b', 'Hermes 3 405B', 'Best reasoning, 405B params'),
  ('gemini_flash', 'Gemini 3.5 Flash', 'Best Gemini, GA stable'),
  ('openrouter_llama33_70b', 'LLaMA 3.3 70B', 'Excellent Meta model'),
  ('gemini_flash_lite', 'Gemini 3.5 Flash-Lite ⭐', 'Default, fastest'), // ⭐ = default marker
  // ... continue in priority order
];
```

2. **_currentModelIndex** - track position in fallback chain
3. **autoFallback()** - iterate through availableModels in order
4. **setModel()** - allow manual selection, persist choice

### llm_service.dart Changes:

1. Use `AppConfig.groqUrl`, `groqKey`, `groqModel` (already lazy getters)
2. On error, call `AppConfig.autoFallback()` to advance chain
3. Retry request with new model
4. If switched, log: "Switched to [new model name]"

### ai_chat_service.dart Changes:

1. Same auto-fallback logic for chat
2. Clear "current model failed" state on successful fallback
3. Show transient "Trying alternative model..." if visible to user

### ocr_service.dart Special Case:

**For vision tasks (receipt OCR):**
1. Try Gemini 2.0 Flash Exp (#9) FIRST (vision support)
2. If fails, fall back to direct Gemini Flash (#2) or Flash-Lite (#4)
3. Other models don't support vision - show clear error

---

## UI Picker Display

The model picker (ai_screen.dart `_showModelSelector`) must show models in priority order with visual grouping:

```
┌─────────────────────────────────────┐
│  AI Model                            │
│  Choose your AI engine. Auto-fallb…│
├─────────────────────────────────────┤
│  ✓  Tier 1: Premium Quality         │
│                                      │
│  ○  Hermes 3 405B (OpenRouter)      │
│     Best reasoning, slowest         │
│                                      │
│  ○  Gemini 3.5 Flash                │
│     Best Gemini, GA stable          │
│                                      │
│  ○  LLaMA 3.3 70B (OpenRouter)      │
│     Excellent balance               │
│                                      │
│  ●  Gemini 3.5 Flash-Lite ⭐        │  ← DEFAULT (selected)
│     Fastest, recommended            │
│                                      │
│  ━━  Tier 2: Solid Performance  ━━  │
│                                      │
│  ○  Groq GPT-OSS 120B               │
│     1K req/day, fast                │
│                                      │
│  ... (continue through tier 4)      │
│                                      │
│  💡 Auto mode tries models top to   │
│     bottom until one works          │
└─────────────────────────────────────┘
```

**Key UI Elements:**
- ⭐ next to default model (#4)
- Tier headers as separators (optional, nice-to-have)
- Clear descriptions per model
- "⚠️ Daily limit reached" next to rate-limited Groq models
- Scroll to see all 13 models

---

## Testing Requirements

### Fallback Chain Test:
```dart
// Pseudo-test code
test('Auto-fallback tries models in priority order', () {
  // Mock: Hermes 3 returns 429
  mockModel('openrouter_hermes3_405b', statusCode: 429);
  
  // Mock: Gemini Flash works
  mockModel('gemini_flash', statusCode: 200, response: 'Hello!');
  
  // Send message
  final result = await sendMessage('Test');
  
  // Assert: Skipped #1, used #2
  expect(AppConfig.activeModelId, 'gemini_flash');
  expect(result, 'Hello!');
});
```

### Priority Order Test:
```dart
test('availableModels list is in priority order', () {
  final ids = AppConfig.availableModels.map((m) => m.$1).toList();
  
  // Assert exact order
  expect(ids[0], 'openrouter_hermes3_405b'); // #1
  expect(ids[1], 'gemini_flash'); // #2
  expect(ids[3], 'gemini_flash_lite'); // #4 (default)
  expect(ids[12], 'cerebras_120b'); // #13 (last)
});
```

### Tool Calling Test Per Model:
```dart
// Test top 5 models with sample AI action
for (var modelId in ['openrouter_hermes3_405b', 'gemini_flash', 
                      'openrouter_llama33_70b', 'gemini_flash_lite',
                      'groq_120b']) {
  test('$modelId supports tool calling', () async {
    AppConfig.setModel(modelId);
    final result = await sendMessage('Add expense 500 food');
    
    // Assert tool was called (expense created)
    expect(result.contains('expense'), true);
    final expenses = await DBService.getExpensesToday();
    expect(expenses.any((e) => e.amount == 500), true);
  });
}
```

### OCR Vision Model Test:
```dart
test('OCR uses vision-capable model', () async {
  // Mock receipt image
  final image = await loadTestReceipt();
  
  // Trigger OCR
  final result = await OCRService.scanReceipt(image);
  
  // Assert: Used Gemini 2.0 Flash Exp or Gemini Flash
  expect(
    AppConfig.activeModelId, 
    anyOf('openrouter_gemini2_flash', 'gemini_flash')
  );
  
  // Assert: Items extracted
  expect(result.items.length, greaterThan(0));
});
```

---

## Feature-Specific Priority Overrides

Some features may use different priority logic:

### Chat (ai_screen.dart):
- Use global priority order
- Default: Flash-Lite (#4)
- User can override to any model

### Receipt OCR (ocr_service.dart):
- **Override:** Try Gemini 2.0 Flash Exp (#9) FIRST
- Fallback: Gemini Flash (#2) → Flash-Lite (#4)
- Non-vision models: Show error "Vision not supported"

### AI Insights (insight_service.dart):
- Use global priority
- Prefer slower/better models (#1-3) for complex analysis
- Can override: "Use best model for insights" setting

### Voice Commands (peso_voice_service.dart):
- Prefer FAST models (Flash-Lite #4, Groq Compound Mini #11)
- Voice needs quick responses > quality
- Fallback to slower models if fast ones unavailable

### Batch Processing (batch_image_import_screen.dart):
- For vision: Gemini 2.0 Flash Exp (#9)
- For text extraction: Use fastest available
- Parallel processing: Can use multiple models at once

---

## Configuration Constants

Add to app_config.dart:

```dart
// Model priority tiers for easy grouping
static const tier1Models = [
  'openrouter_hermes3_405b',
  'gemini_flash', 
  'openrouter_llama33_70b',
  'gemini_flash_lite',
];

static const tier2Models = [
  'groq_120b',
  'openrouter_qwen25_72b',
  'groq_qwen36',
  'groq_qwen38',
];

static const tier3Models = [
  'openrouter_gemini2_flash',
  'groq_compound',
  'groq_compound_mini',
];

static const tier4Models = [
  'openrouter_mistral_7b',
  'cerebras_120b',
];

// Vision-capable models (for OCR)
static const visionModels = [
  'openrouter_gemini2_flash',
  'gemini_flash',
  'gemini_flash_lite',
];

// Fast models (for voice/quick responses)
static const fastModels = [
  'gemini_flash_lite',
  'groq_compound_mini',
  'openrouter_mistral_7b',
];

// Best reasoning models (for complex tasks)
static const reasoningModels = [
  'openrouter_hermes3_405b',
  'gemini_flash',
  'openrouter_llama33_70b',
];
```

---

## Success Criteria

✅ All 13 models appear in priority order in UI picker  
✅ Auto-fallback tries models top-to-bottom on failure  
✅ Default remains Flash-Lite (#4) for stability  
✅ OCR uses vision models (#9, #2, #4) specifically  
✅ Tool calling tested on top 5 models - all pass  
✅ Fallback chain tested - successfully moves down on failure  
✅ User selection persists correctly  
✅ No crashes when switching models  
✅ Clear error messages when all models fail  

---

**Last Updated:** Nov 20, 2026 1:30 AM  
**For Version:** v3.3.9  
**Implementation Status:** In Progress (workflow running)
