# OpenRouter Multi-Model Testing Checklist

**Defense Date:** Monday Nov 23, 2026  
**Task:** Replace single "OpenRouter" option with 3-5 individual free models

---

## Target OpenRouter Models (Free Tier)

Research these and pick top 3-5:

1. **meta-llama/llama-3.3-70b-instruct** - free, good reasoning
2. **google/gemini-2.0-flash-exp:free** - free Gemini via OpenRouter
3. **nousresearch/hermes-3-llama-3.1-405b:free** - free, tool calling support
4. **mistralai/mistral-7b-instruct:free** - free baseline
5. **qwen/qwen-2.5-72b-instruct:free** - free alternative

Check https://openrouter.ai/models for:
- ✅ Free tier available
- ✅ Supports tool/function calling (for AI actions)
- ✅ Supports vision (for receipt OCR - nice to have)

---

## Testing Matrix

Test EVERY model against EVERY feature:

### Models to Test
- [ ] Gemini (existing)
- [ ] Groq (existing)
- [ ] OpenRouter Model 1: __________
- [ ] OpenRouter Model 2: __________
- [ ] OpenRouter Model 3: __________
- [ ] OpenRouter Model 4: __________ (optional)
- [ ] OpenRouter Model 5: __________ (optional)

### Features to Test (for EACH model above)

#### 1. Basic Chat
- [ ] Send simple message → gets response
- [ ] Multi-turn conversation works
- [ ] No crashes, no hangs

#### 2. AI Actions (Tool Calling) - 34 actions
Test representative sample:
- [ ] "Add expense 500 food" → creates expense
- [ ] "Show me my spending this month" → generates insight
- [ ] "Set budget 10000 for food" → creates/updates budget
- [ ] "What's my total spending?" → calculates correctly

#### 3. Receipt OCR (Vision Models Only)
- [ ] Upload single receipt screenshot
- [ ] Items extracted correctly
- [ ] Amounts parsed correctly
- [ ] Fallback works if model doesn't support vision

#### 4. Batch Screenshots
- [ ] Upload 2-3 screenshots at once
- [ ] All processed successfully
- [ ] No crashes on batch

#### 5. AI Insights
- [ ] Open AI Insights screen
- [ ] "Generate insights" produces meaningful output
- [ ] Insights relevant to user's spending data

#### 6. Model Persistence
- [ ] Select model in picker
- [ ] Close app completely
- [ ] Reopen → same model still selected

#### 7. Error Handling
- [ ] Airplane mode → shows proper error
- [ ] Invalid API key → shows error (don't test if using valid key)
- [ ] Model timeout → retries, then fallback

---

## Build & Release

After all tests pass:

- [ ] Build release APK v3.3.9
- [ ] Tag commit: `git tag -a v3.3.9 -m "Multi-model OpenRouter integration"`
- [ ] Push tag: `git push origin v3.3.9`
- [ ] GitHub Actions builds APK
- [ ] Download and install on test device
- [ ] Final smoke test on device

---

## Test Results Template

```
Model: [Name]
Feature: [Chat/Actions/OCR/Batch/Insights/Persistence/Errors]
Status: [✅ PASS | ❌ FAIL | ⚠️ PARTIAL]
Notes: [Details]
```

---

## Success Criteria

✅ At least 3 new OpenRouter models added  
✅ All existing Gemini/Groq functionality still works  
✅ Each model tested on each feature (matrix complete)  
✅ At least 80% pass rate across all model+feature combinations  
✅ No crashes or data loss  
✅ APK builds and installs successfully  

**Target completion:** Before Monday Nov 23 defense
