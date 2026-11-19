# OpenRouter Individual Models - Test Checklist

**Implementation Date**: November 20, 2026  
**Models Added**: 7 individual OpenRouter free models

## Models Implemented

1. ✅ `or_llama33` - Llama 3.3 70B (Best reasoning)
2. ✅ `or_nemotron_ultra` - Nemotron 3 Ultra (Frontier-tier)
3. ✅ `or_nemotron_lightning` - Nemotron 3.5 Lightning (Fastest)
4. ✅ `or_gemma_4_31b` - Gemma 4 31B (Reliable)
5. ✅ `or_qwen38` - Qwen 3.8 27B (Multimodal)
6. ✅ `or_nemotron_super_vl` - Nemotron 3.5 Super VL (Vision)
7. ✅ `or_gemma_4_26b` - Gemma 4 26B A4B (Efficient MoE)

---

## UI Tests

### Settings → AI Model Picker
- [ ] Open Settings → AI
- [ ] Verify all 7 new OpenRouter models appear in the list
- [ ] Each model shows emoji icon
- [ ] Each model shows description with context window and features
- [ ] "OpenRouter Gateway (Legacy)" label appears correctly
- [ ] Model ordering: Auto → Local → OpenRouter models → Gemini → Groq → Cerebras

### Model Selection & Persistence
- [ ] Select "Llama 3.3 70B (OpenRouter)"
- [ ] Close and reopen app
- [ ] Verify selection persists after restart
- [ ] Switch to "Nemotron 3.5 Lightning"
- [ ] Verify selection changes correctly

---

## Feature Tests (Per Model)

Test each model with core AI features. Priority: Llama 3.3 > Nemotron Lightning > Gemma 4 31B

### 1. AI Chat
- [ ] **Llama 3.3**: Ask "How can I save ₱500/month?" → Receives 3-5 actionable tips
- [ ] **Nemotron Ultra**: Ask complex financial question → Detailed answer (3+ sentences)
- [ ] **Nemotron Lightning**: Ask simple question → Fast response
- [ ] **Gemma 4 31B**: General chat → Quality response
- [ ] **Qwen 3.8**: Ask about expense categorization → Helpful answer
- [ ] **Nemotron Super VL**: Chat response works
- [ ] **Gemma 4 26B**: Chat response works

### 2. Voice Input (Tool Calling)
- [ ] **Llama 3.3**: Say "Lunch at Jollibee 250 pesos" → Parses: amount=250, category=Food, merchant=Jollibee
- [ ] **Nemotron Lightning**: Say "Taxi 150" → Parses correctly
- [ ] **Gemma 4 31B**: Say "Coffee 120" → Parses correctly
- [ ] Tool calling confirmed working for all models

### 3. Receipt OCR (Vision/Multimodal)
- [ ] **Qwen 3.8**: Upload receipt photo → Extracts merchant + amount + date
- [ ] **Nemotron Super VL**: Upload receipt → Vision capabilities confirmed
- [ ] **Llama 3.3**: Receipt scanning → Works (text extraction)
- [ ] Verify multimodal models handle images correctly

### 4. Batch Screenshot Processing
- [ ] **Llama 3.3**: Import 3 GCash screenshots → All parse successfully
- [ ] **Nemotron Lightning**: Import 3 screenshots → Fast processing
- [ ] **Qwen 3.8**: Import 3 screenshots → Accurate extraction
- [ ] All 3 screenshots: amounts, dates, merchants extracted correctly

### 5. Financial Insights Generation
- [ ] **Llama 3.3**: Dashboard generates 3 insights → All relevant and actionable
- [ ] **Nemotron Ultra**: Generate insights → High quality reasoning
- [ ] **Gemma 4 31B**: Generate insights → Reliable output
- [ ] Insights include: spending patterns, warnings, savings tips

### 6. AI Analytics Questions
- [ ] **Llama 3.3**: Ask "Why did I spend more in October?" → Data-backed explanation
- [ ] **Nemotron Ultra**: Complex analytics question → Detailed reasoning
- [ ] **Nemotron Lightning**: Simple analytics question → Fast response

### 7. Bank CSV Import Parsing
- [ ] **Llama 3.3**: Upload bank statement CSV → Transactions extracted (dates, amounts, descriptions)
- [ ] CSV parsing works with tool calling

### 8. Auto-Categorization
- [ ] **Llama 3.3**: "Starbucks 180" → Categorizes as Food & Drinks
- [ ] **Gemma 4 31B**: "Grab ride 85" → Categorizes as Transportation
- [ ] Categories applied correctly

### 9. Budget Recommendations
- [ ] **Llama 3.3**: Request budget plan → Returns category breakdown with reasoning
- [ ] **Nemotron Ultra**: Budget advice → High quality recommendations

---

## Fallback Chain Testing

### Rate Limit Handling
- [ ] Select "Llama 3.3 70B"
- [ ] Make requests until 50/day quota is hit (or simulate 429 error)
- [ ] Observe fallback: Llama 3.3 → Nemotron Ultra → Lightning → Gemma 4 31B → Qwen 3.8 → Super VL → Gemma 26B → Groq
- [ ] Each transition is smooth (no app crash)
- [ ] User sees model change notification (optional)

### Auto Mode Integration
- [ ] Set model to "Auto (Recommended)"
- [ ] Verify Auto mode uses OpenRouter when Gemini key is not available
- [ ] Auto mode routes: Gemini (if key) → OpenRouter Llama 3.3 → Groq
- [ ] Fallback works correctly in Auto mode

### Local-Only Mode
- [ ] Enable Settings → Local AI → "Local Only Mode"
- [ ] Stop local server (if running)
- [ ] Attempt chat with custom_local selected
- [ ] Expected: Error message, no fallback to cloud
- [ ] Verify OpenRouter not used when local-only enabled

---

## Cross-Feature Integration (Llama 3.3 70B)

Test all AI features with Llama 3.3 70B (best model):

- [ ] **AI Chat**: 3 different questions → All answered correctly
- [ ] **Voice Input**: 3 expenses → All parsed correctly
- [ ] **Receipt OCR**: 3 receipts → All extracted correctly
- [ ] **Batch Screenshots**: 5 screenshots → All parsed successfully
- [ ] **Dashboard Insights**: Refresh 3 times → New insights each time
- [ ] **Analytics AI**: 3 queries → All answered with data
- [ ] **CSV Import**: 1 bank statement → All transactions extracted
- [ ] **Auto-categorization**: 5 manual entries → All categorized correctly
- [ ] **Budget Recommendations**: 1 request → Complete budget returned

**Pass criteria**: 9/9 features work OR 8/9 with documented issue

---

## Existing Models Regression Testing

Verify existing models still work after changes:

### Gemini Models
- [ ] Gemini 3.5 Flash: Chat works
- [ ] Gemini 3.5 Flash-Lite: Chat works
- [ ] Gemini models: Tool calling works

### Groq Models
- [ ] GPT-OSS 120B: Chat works
- [ ] Qwen3.6 27B: Chat works
- [ ] Qwen3.8 27B: Chat works
- [ ] Compound: Chat works
- [ ] Compound Mini: Chat works

### Cerebras Models
- [ ] GPT-OSS 120B (Cerebras): Chat works

### Legacy OpenRouter Gateway
- [ ] OpenRouter Gateway: Falls back to or_llama33
- [ ] Gateway marked as "Legacy" in UI

---

## Performance & Stability

### Response Time
- [ ] **Nemotron Lightning**: Fastest OpenRouter model (measure response time)
- [ ] **Llama 3.3**: Reasonable response time for quality
- [ ] **Nemotron Ultra**: Slower but highest quality

### Error Handling
- [ ] 429 (Rate Limit): Triggers fallback correctly
- [ ] 401 (Auth Error): Falls back to next model
- [ ] Network timeout: Handled gracefully
- [ ] Invalid response: Fallback triggered

### API Key Handling
- [ ] OpenRouter key loaded from Firebase Remote Config
- [ ] Fallback key used when Remote Config unavailable
- [ ] Empty key: Falls back to Groq instead of failing

---

## Known Issues & Limitations

### Shared 50/day Quota
- All 7 OpenRouter models share the same 50 requests/day quota
- Quota resets at UTC midnight
- After quota exhausted, falls back to Groq (1000/day)
- **User action**: Add $10 credit for 1000/day at openrouter.ai/credits

### 4-bit Quantization
- Free models run at fp8/int4 (lower quality than paid)
- Nemotron models show minimal quality loss
- For critical tasks, consider upgrading to paid models

### Variable Latency
- OpenRouter routes across multiple providers
- Response time varies by provider availability
- Use Nemotron Lightning for fastest free option

---

## Success Metrics

### Minimum Viable (Must Pass)
- ✅ All 7 models appear in UI picker
- ✅ At least 3 models work with AI chat
- ✅ At least 1 model works with tool calling (voice input)
- ✅ Fallback chain works (no crashes)
- ✅ Existing Gemini/Groq models still work

### Ideal (Target)
- ✅ All 7 models work with AI chat
- ✅ All 7 models work with tool calling
- ✅ Vision models (Qwen, Super VL) work with images
- ✅ Auto mode includes OpenRouter
- ✅ Response times are acceptable (< 10s for simple queries)

---

## Test Results Summary

**Date Tested**: _______________  
**Tester**: _______________  
**App Version**: _______________

### Models Working
- [ ] Llama 3.3 70B: ___/9 features
- [ ] Nemotron 3 Ultra: ___/9 features
- [ ] Nemotron 3.5 Lightning: ___/9 features
- [ ] Gemma 4 31B: ___/9 features
- [ ] Qwen 3.8 27B: ___/9 features
- [ ] Nemotron 3.5 Super VL: ___/9 features
- [ ] Gemma 4 26B A4B: ___/9 features

### Overall Status
- [ ] ✅ PASS - Ready for production
- [ ] ⚠️ PASS WITH ISSUES - Works but has minor issues (document below)
- [ ] ❌ FAIL - Blocking issues found (document below)

### Issues Found
_Document any issues discovered during testing:_

1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________

### Notes
_Any additional observations:_

_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

---

## Next Steps After Testing

1. **If all tests pass**: 
   - Mark this task as complete
   - Update app documentation with new models
   - Consider promoting Llama 3.3 70B in Auto mode priority

2. **If issues found**:
   - Document issues in implementation-review.json
   - Create fix plan for blocking issues
   - Retry tests after fixes applied

3. **User Documentation**:
   - Add OpenRouter models guide to README
   - Update in-app help text
   - Create user guide for model selection

---

**END OF CHECKLIST**
