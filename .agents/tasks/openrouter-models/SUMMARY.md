# OpenRouter Multi-Model Integration - Summary

**Status:** 🟡 In Progress  
**Started:** Nov 20, 2026 1:00 AM  
**Defense Date:** Monday Nov 23, 2026 11:00 AM  
**Time Available:** ~58 hours

---

## Objective

Replace the single unreliable "OpenRouter" option with 3-5 individual free OpenRouter models that users can select explicitly.

**Current Problem:**
- OpenRouter is a single generic option that fails frequently
- Users can't choose specific models
- No visibility into which OpenRouter model is actually being used

**Solution:**
- Add 5 specific OpenRouter models as individual choices
- Each appears in the AI model picker
- Users can select based on their needs (speed vs quality, vision support, etc.)
- Better reliability through model diversity

---

## Target Models (5 Selected)

1. **LLaMA 3.3 70B** (`meta-llama/llama-3.3-70b-instruct:free`)
   - 70B params, balanced quality/speed
   - Tool calling: ✅
   - Vision: ❌
   - Use: General chat, AI actions

2. **Gemini 2.0 Flash Exp** (`google/gemini-2.0-flash-exp:free`)
   - Latest experimental Gemini via OpenRouter
   - Tool calling: ✅
   - Vision: ✅
   - Use: Receipt OCR, image analysis

3. **Hermes 3 405B** (`nousresearch/hermes-3-llama-3.1-405b:free`)
   - 405B params, best reasoning
   - Tool calling: ✅ (excellent)
   - Vision: ❌
   - Use: Complex AI actions, edge cases

4. **Qwen 2.5 72B** (`qwen/qwen-2.5-72b-instruct:free`)
   - 72B params, multilingual
   - Tool calling: ✅
   - Vision: ❌
   - Use: Tagalog support, general chat

5. **Mistral 7B** (`mistralai/mistral-7b-instruct:free`)
   - 7B params, fastest
   - Tool calling: ⚠️ Basic
   - Vision: ❌
   - Use: Simple queries, last resort fallback

---

## Implementation Plan

### Phase 1: Research (wf-planner)
**Status:** 🟡 Running  
**Tasks:**
- Verify OpenRouter free models are available
- Confirm tool calling support
- Check rate limits and restrictions
- Document API requirements

### Phase 2: Implementation (wf-coder + wf-code-reviewer)
**Status:** ⏳ Pending  
**Files to modify:**
- `lib/services/app_config.dart` - Add model definitions
- `lib/services/llm_service.dart` - Update API routing
- `lib/services/ai_chat_service.dart` - Ensure tool calling works
- `lib/services/ocr_service.dart` - Add vision model support

**Changes:**
1. Add 5 new model tuples to `AppConfig.availableModels`
2. Add routing logic for each model ID
3. Ensure OpenRouter headers (HTTP-Referer, X-Title) are sent
4. Update fallback chain to include new models
5. Test model selection persistence

### Phase 3: Testing (wf-coder)
**Status:** ⏳ Pending  
**Test matrix:**
- 13 total models (8 existing + 5 new)
- 10 feature tests per model
- 130 total test combinations

**Critical tests:**
- ✅ Basic chat on all models
- ✅ AI actions (tool calling) on 34 actions
- ✅ Receipt OCR on vision models
- ✅ Model picker shows all models
- ✅ Selection persists across restarts
- ✅ Error handling graceful

---

## Files Created

### Documentation:
- ✅ `.agents/tasks/openrouter-models/test-matrix.md` (3.2 KB)
  - Complete testing checklist
  - Feature matrix for all models
  - Performance benchmarks table
  - Build & release checklist

- ✅ `.agents/tasks/openrouter-models/recommended-models.md` (7.8 KB)
  - Top 5 models with full specs
  - Implementation code snippets
  - Fallback chain redesign
  - API key configuration
  - Known limitations

- ✅ `.agents/tasks/openrouter-multi-model-testing-checklist.md` (5.1 KB)
  - Initial testing roadmap
  - Success criteria
  - Test results template

- ✅ `.agents/tasks/openrouter-models/SUMMARY.md` (this file)

### Workflow:
- 🟡 Running: `wf_600bc7472f6fb27d`
  - Step 1: create-workflow ✅ Done
  - Step 2: research 🟡 Running
  - Step 3: implement_loop ⏳ Pending (max 3 iterations)
  - Step 4: test ⏳ Pending

---

## Current Model Lineup

### Existing (Keep All 8):
1. Gemini 3.5 Flash
2. Gemini 3.5 Flash-Lite (DEFAULT)
3. Groq GPT-OSS 120B
4. Groq Qwen3.6 27B
5. Groq Qwen3.8 27B
6. Groq Compound
7. Groq Compound Mini
8. Cerebras GPT-OSS 120B

### New (Adding 5):
9. LLaMA 3.3 70B (OpenRouter) ← NEW
10. Gemini 2.0 Flash Exp (OpenRouter) ← NEW
11. Hermes 3 405B (OpenRouter) ← NEW
12. Qwen 2.5 72B (OpenRouter) ← NEW
13. Mistral 7B (OpenRouter) ← NEW

**Total: 13 AI models**

---

## Key Files & Locations

### Service Layer:
- `lib/services/app_config.dart` - Model definitions, API routing, fallback logic
- `lib/services/llm_service.dart` - LLM API calls (OCR, insights)
- `lib/services/ai_chat_service.dart` - Chat with 34 AI actions
- `lib/services/ocr_service.dart` - Receipt scanning
- `lib/services/insight_service.dart` - AI insights

### UI Layer:
- `lib/screens/ai_screen.dart` - Main AI chat, model picker (line 2485)
- `lib/screens/settings_screen.dart` - Settings where AI config is
- `lib/screens/scan_review_screen.dart` - Receipt scanning UI
- `lib/screens/batch_image_import_screen.dart` - Batch screenshots

### Model Picker:
- Location: `ai_screen.dart` `_showModelSelector()` method
- Data source: `AppConfig.availableModels` (list of tuples)
- Format: `(id, displayName, description)`
- Auto-updates when new models added to list

---

## Testing Strategy

### Tier 1: Critical Path (Must Pass 100%)
- Basic chat works on all 13 models
- Model picker shows all models
- Selection persists across restarts
- No crashes on model switch
- APK builds successfully

### Tier 2: Core Features (Must Pass 80%+)
- AI actions (tool calling) work on most models
- Receipt OCR works on vision models (Gemini 2.0 Flash Exp)
- Batch screenshots process correctly
- Error messages clear and actionable

### Tier 3: Advanced (Nice to Have 60%+)
- Performance benchmarks within targets
- Rate limit handling graceful
- Voice commands work across models
- Fallback chain works end-to-end

---

## Expected Outcomes

### After Implementation:
- ✅ 5 new OpenRouter models added
- ✅ 13 total models in picker
- ✅ Each model tested on core features
- ✅ No regressions on existing 8 models
- ✅ Code reviewed and approved
- ✅ Documentation updated

### After Testing:
- ✅ Test matrix completed (130 combinations)
- ✅ Pass rate > 80% across all tests
- ✅ Known issues documented
- ✅ Performance benchmarked
- ✅ Release decision made

### After Release (v3.3.9):
- ✅ APK built and tagged
- ✅ Released on GitHub
- ✅ Installed on test device
- ✅ Final smoke test passed
- ✅ Defense materials updated

---

## Timeline

**Day 1 (Nov 20 - Today):**
- ✅ 1:00 AM: Workflow launched
- 🟡 1:00-3:00 AM: Research & planning
- ⏳ 3:00-6:00 AM: Implementation (3 iterations)
- ⏳ 6:00-8:00 AM: Testing
- ⏳ 8:00 AM: Build v3.3.9 APK
- ⏳ 9:00 AM: Release & update materials

**Day 2-3 (Nov 21-22):**
- Practice defense with new model count
- Final testing on physical device
- Prepare demo scenarios
- Rest before defense

**Day 4 (Nov 23 - Monday):**
- 11:00 AM: Defense 🎓

---

## Success Criteria

### Minimum Viable (Ship v3.3.9):
- ✅ At least 3 OpenRouter models added
- ✅ All existing models still work
- ✅ Basic chat works on all new models
- ✅ No crashes in testing
- ✅ APK builds

### Ideal (Full Success):
- ✅ All 5 OpenRouter models added
- ✅ Tool calling works on 4/5 models
- ✅ Vision model supports OCR
- ✅ Auto-fallback chain includes all models
- ✅ Performance acceptable (< 5s for chat)
- ✅ Test pass rate > 85%

### Blockers (Don't Ship):
- ❌ Existing models broken (regressions)
- ❌ Crashes on model switch
- ❌ APK doesn't build
- ❌ Cannot select/persist models
- ❌ Zero OpenRouter models work

---

## Risk Assessment

### High Confidence:
- ✅ Adding model definitions (straightforward)
- ✅ UI automatically updates (no code change)
- ✅ API routing similar to existing models
- ✅ Headers already partially implemented

### Medium Confidence:
- ⚠️ Tool calling quality on new models (unknown)
- ⚠️ Rate limits may be strict (need testing)
- ⚠️ Response times may vary (could be slow)
- ⚠️ Some models may be temporarily down

### Low Risk:
- ✅ Breaking existing models (isolated changes)
- ✅ UI bugs (no UI code changes)
- ✅ Build failures (no dependency changes)

---

## Next Steps

1. **Monitor workflow** - Check for research completion notification
2. **Review research findings** - Verify models are available
3. **Wait for implementation** - Let coder add models
4. **Review code changes** - Check before testing
5. **Run test matrix** - 2-3 hours of systematic testing
6. **Build APK** - Create v3.3.9 release
7. **Final verification** - Install and test on device
8. **Update defense materials** - Add new model count

---

## Questions for User (When Awake)

1. Should we keep the single "OpenRouter" option as a generic fallback, or completely replace it with the 5 specific models?
   - **Recommendation:** Replace completely (clearer for users)

2. What should the default model remain?
   - **Current:** Gemini 3.5 Flash-Lite
   - **Recommendation:** Keep as-is (proven stable)

3. Should OpenRouter models be higher or lower in fallback priority than Groq?
   - **Recommendation:** Mix them (Hermes 3 high, Mistral 7B low)

4. Maximum acceptable response time for basic chat?
   - **Current expectation:** < 3 seconds
   - **Recommendation:** Allow up to 5s for large models (Hermes 405B)

5. Ship v3.3.9 even if some models fail testing?
   - **Recommendation:** Yes, if at least 3 work and no regressions

---

## Notes

- Defense postponed from Nov 20 to Nov 23 (good - gives us time)
- This is a "nice to have" enhancement, not critical for defense
- Existing 8 models already demonstrate multi-provider resilience
- Adding 5 more shows thoroughness and reliability focus
- Free tier models keep costs at zero (important for thesis)
- Tool calling (34 AI actions) is the key differentiator to test

---

**Status updated:** Nov 20, 2026 1:15 AM  
**Workflow:** Running (research phase)  
**ETA:** Implementation complete by 8 AM, testing by noon
