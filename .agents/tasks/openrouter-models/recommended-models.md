# Recommended OpenRouter Free Models

**Research Date:** Nov 20, 2026  
**Source:** https://openrouter.ai/models  
**Criteria:** Free tier + Tool/function calling support + Active maintenance

---

## Top 5 Recommended (Add These)

### 1. meta-llama/llama-3.3-70b-instruct:free
- **Size:** 70B parameters
- **Strengths:** Excellent reasoning, good at following instructions
- **Tool Calling:** ✅ Yes (supports function calling)
- **Vision:** ❌ No
- **Free Tier:** Yes, generous limits
- **Use Case:** General chat, AI actions, complex reasoning
- **Display Name:** "LLaMA 3.3 70B (OpenRouter)"
- **ID:** `openrouter_llama33_70b`

### 2. google/gemini-2.0-flash-exp:free
- **Size:** Not disclosed (Google model)
- **Strengths:** Fast, vision support, latest experimental Gemini
- **Tool Calling:** ✅ Yes
- **Vision:** ✅ Yes (can process images)
- **Free Tier:** Yes (experimental tier)
- **Use Case:** Receipt OCR, image analysis, fast responses
- **Display Name:** "Gemini 2.0 Flash Exp (OpenRouter)"
- **ID:** `openrouter_gemini2_flash`
- **Note:** May differ from direct Gemini API (different routing)

### 3. nousresearch/hermes-3-llama-3.1-405b:free
- **Size:** 405B parameters (HUGE)
- **Strengths:** Strongest reasoning, excellent tool calling, complex tasks
- **Tool Calling:** ✅ Yes (one of the best for function calling)
- **Vision:** ❌ No
- **Free Tier:** Yes, limited requests but very capable
- **Use Case:** Complex AI actions, multi-step reasoning, edge cases
- **Display Name:** "Hermes 3 405B (OpenRouter)"
- **ID:** `openrouter_hermes3_405b`
- **Warning:** Slower due to size, may have tighter rate limits

### 4. qwen/qwen-2.5-72b-instruct:free
- **Size:** 72B parameters
- **Strengths:** Good multilingual support, fast, reliable
- **Tool Calling:** ✅ Yes
- **Vision:** ❌ No (text-only)
- **Free Tier:** Yes
- **Use Case:** Tagalog/Filipino language support, general chat
- **Display Name:** "Qwen 2.5 72B (OpenRouter)"
- **ID:** `openrouter_qwen25_72b`
- **Note:** Different from Groq's Qwen3.6/3.8 models

### 5. mistralai/mistral-7b-instruct:free
- **Size:** 7B parameters (smallest, fastest)
- **Strengths:** Very fast responses, good for simple tasks
- **Tool Calling:** ⚠️ Basic support (less reliable than larger models)
- **Vision:** ❌ No
- **Free Tier:** Yes, most generous limits
- **Use Case:** Fast simple queries, fallback when others rate-limited
- **Display Name:** "Mistral 7B (OpenRouter)"
- **ID:** `openrouter_mistral_7b`
- **Note:** May struggle with complex AI actions (34 tools)

---

## Alternative Models (Research These If Above Unavailable)

### anthropic/claude-3.5-sonnet:free
- Check if free tier exists on OpenRouter
- If yes: HIGHEST PRIORITY (best reasoning available)
- If no: Skip (paid only)

### x-ai/grok-beta:free
- Elon's Grok model
- Check availability and free tier
- Strong reasoning if available

### cohere/command-r-plus:free
- Good for RAG and structured output
- Check free tier availability

---

## Implementation Checklist

For EACH model above:

### 1. Add to AppConfig.availableModels
```dart
(
  'openrouter_llama33_70b',  // ID
  'LLaMA 3.3 70B (OpenRouter)',  // Display name
  'Free, 70B params, good reasoning'  // Description
),
```

### 2. Add Model Routing
In AppConfig where model selection happens:
```dart
case 'openrouter_llama33_70b':
  return (
    _openRouterUrl,
    _openRouterApiKey,
    'meta-llama/llama-3.3-70b-instruct:free'
  );
```

### 3. Add Headers
Ensure HTTP-Referer and X-Title headers are sent for ALL OpenRouter requests:
```dart
if (modelId.startsWith('openrouter_')) {
  headers['HTTP-Referer'] = 'https://zushikina-kun.github.io/smartspend-app/';
  headers['X-Title'] = 'SmartSpend';
}
```

### 4. Test Each Model
- [ ] Shows in picker
- [ ] Basic chat works
- [ ] AI actions work
- [ ] No crashes
- [ ] Error messages clear

---

## Model Fallback Chain (Recommended Order)

Current chain:
1. Gemini 3.5 Flash
2. Gemini 3.5 Flash-Lite (DEFAULT)
3. Groq GPT-OSS 120B
4. Groq Qwen3.6 27B
5. Groq Qwen3.8 27B
6. Groq Compound
7. Groq Compound Mini
8. Cerebras GPT-OSS 120B

**Suggested insertion points for OpenRouter:**

**After Gemini, before Groq (high quality):**
- Hermes 3 405B (slowest but smartest)
- LLaMA 3.3 70B (good balance)

**After main Groq models (fallback tier):**
- Gemini 2.0 Flash Exp (OpenRouter) - for vision tasks
- Qwen 2.5 72B

**Before Cerebras (last resort):**
- Mistral 7B (fast but simple)

**Revised chain:**
1. Gemini 3.5 Flash
2. Gemini 3.5 Flash-Lite (DEFAULT)
3. **Hermes 3 405B (OpenRouter)** ← NEW
4. **LLaMA 3.3 70B (OpenRouter)** ← NEW
5. Groq GPT-OSS 120B
6. Groq Qwen3.6 27B
7. Groq Qwen3.8 27B
8. **Gemini 2.0 Flash Exp (OpenRouter)** ← NEW (for vision)
9. Groq Compound
10. Groq Compound Mini
11. **Qwen 2.5 72B (OpenRouter)** ← NEW
12. **Mistral 7B (OpenRouter)** ← NEW
13. Cerebras GPT-OSS 120B

---

## API Key Configuration

OpenRouter API key must be in Firebase Remote Config:
- **Key name:** `openrouter_api_key`
- **Format:** `sk-or-v1-...`
- **Fallback:** Already defined in AppConfig (_fallbackOpenRouterKey)
- **Expiry:** May 14, 2027 ($100 credit)

Ensure the key is set in Firebase Remote Config console before testing.

---

## Testing Priority

**Phase 1 (Critical):** Basic functionality
1. LLaMA 3.3 70B - Most balanced
2. Gemini 2.0 Flash Exp - For vision/OCR
3. Qwen 2.5 72B - Multilingual

**Phase 2 (Advanced):** Edge cases
4. Hermes 3 405B - Complex reasoning
5. Mistral 7B - Speed/fallback

**Phase 3 (Optional):** Full matrix
- Test all 34 AI actions on each model
- Benchmark response times
- Document rate limits hit during testing

---

## Success Metrics

After implementation:
- ✅ 5 new models added to picker
- ✅ Total models: 13 (8 existing + 5 new)
- ✅ At least 3 support tool calling reliably
- ✅ At least 1 supports vision (for receipt OCR)
- ✅ No regressions on existing models
- ✅ Auto-fallback chain includes OpenRouter models
- ✅ Model selection persists correctly

---

## Known Limitations

**OpenRouter-specific:**
- Rate limits vary by model (some very strict on free tier)
- Some models may be temporarily unavailable (503 errors)
- Response times can be slower than direct APIs (extra routing hop)
- Tool calling quality varies significantly between models

**Mitigation:**
- Don't remove existing Gemini/Groq options (keep them as reliable fallbacks)
- Show clear error messages when OpenRouter model fails
- Auto-fallback should work across all models
- Document expected rate limits per model in UI descriptions

---

## Post-Implementation

After workflow completes:
1. Review implementation in app_config.dart and llm_service.dart
2. Run full test matrix (2-3 hours)
3. Build v3.3.9 APK
4. Update defense materials:
   - "13 AI models" instead of "8 models"
   - "Multiple OpenRouter free models" as a feature
   - Emphasize reliability through model diversity
5. Update reviewer.html Q&A if needed
6. Test on physical device before defense

**Defense talking points:**
- "We support 13 different AI models for maximum reliability"
- "Users can choose between speed (Mistral 7B) and quality (Hermes 405B)"
- "Auto-fallback ensures the app always works even if one provider is down"
- "Free tier models keep costs at zero while maintaining functionality"
