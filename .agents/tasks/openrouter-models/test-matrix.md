# OpenRouter Multi-Model Testing Matrix

**Created:** Nov 20, 2026  
**Defense Date:** Monday Nov 23, 2026  
**Current Version:** v3.3.8  
**Target Version:** v3.3.9

---

## Current Model Lineup (Before Changes)

1. ✅ Gemini 3.5 Flash (gemini-3.5-flash)
2. ✅ Gemini 3.5 Flash-Lite (gemini-3.5-flash-lite) - DEFAULT
3. ✅ Groq GPT-OSS 120B (openai/gpt-oss-120b)
4. ✅ Groq Qwen3.6 27B (qwen/qwen3.6-27b)
5. ✅ Groq Qwen3.8 27B (qwen/qwen3.8-27b)
6. ✅ Groq Compound (groq/compound)
7. ✅ Groq Compound Mini (groq/compound-mini)
8. ✅ Cerebras GPT-OSS 120B (last resort fallback)
9. ⚠️ OpenRouter (single generic option - THIS IS WHAT WE'RE REPLACING)

---

## Target OpenRouter Models to Add

Research and add 3-5 of these as individual options:

### Top Candidates (FREE tier with tool calling):
1. **meta-llama/llama-3.3-70b-instruct:free**
   - 70B params, good reasoning
   - Supports function calling
   - Free tier available

2. **google/gemini-2.0-flash-exp:free**
   - Latest Gemini via OpenRouter
   - May differ from direct Gemini API
   - Vision + tools support

3. **nousresearch/hermes-3-llama-3.1-405b:free**
   - 405B params, excellent reasoning
   - Strong tool calling support
   - Free tier

4. **mistralai/mistral-7b-instruct:free**
   - 7B params, fast baseline
   - Basic tool support
   - Very reliable free tier

5. **qwen/qwen-2.5-72b-instruct:free**
   - 72B params
   - Good multilingual support
   - Free tier

6. **anthropic/claude-3.5-sonnet:free** (if available)
   - Check if OpenRouter has free tier
   - Excellent reasoning if available

---

## Testing Matrix

### Models to Test (Update after implementation)

**Existing Models (must still work):**
- [ ] Gemini 3.5 Flash
- [ ] Gemini 3.5 Flash-Lite
- [ ] Groq GPT-OSS 120B
- [ ] Groq Qwen3.6 27B
- [ ] Groq Qwen3.8 27B
- [ ] Groq Compound
- [ ] Groq Compound Mini
- [ ] Cerebras GPT-OSS 120B

**New OpenRouter Models (to be added):**
- [ ] OpenRouter Model 1: _______________
- [ ] OpenRouter Model 2: _______________
- [ ] OpenRouter Model 3: _______________
- [ ] OpenRouter Model 4: _______________ (optional)
- [ ] OpenRouter Model 5: _______________ (optional)

---

## Feature Testing Checklist

For EACH model above, test ALL these features:

### 1. Basic Chat Functionality
- [ ] Open AI screen (lib/screens/ai_screen.dart)
- [ ] Select model from picker
- [ ] Send message: "Hello, what can you help me with?"
- [ ] Receive coherent response
- [ ] Send follow-up: "Tell me about budgeting"
- [ ] Multi-turn conversation works
- [ ] No crashes or freezes

### 2. AI Actions (Tool Calling) - Core Feature
SmartSpend has 34 AI actions. Test representative sample:

#### Expense Management Actions:
- [ ] "Add expense 500 food" → Creates expense correctly
- [ ] "Show my expenses today" → Lists expenses
- [ ] "Delete last expense" → Deletes correctly
- [ ] "Edit last expense to 300" → Updates amount

#### Budget Actions:
- [ ] "Set budget 10000 for food" → Creates/updates budget
- [ ] "Show my budgets" → Lists all budgets
- [ ] "How much food budget left?" → Calculates remaining

#### Analytics Actions:
- [ ] "What's my total spending?" → Calculates correctly
- [ ] "Show spending by category" → Breaks down correctly
- [ ] "Compare this month to last month" → Shows comparison

#### Complex Actions:
- [ ] "What's my financial health score?" → Returns score with explanation
- [ ] "Give me saving tips" → Generates personalized tips
- [ ] "When is my next bill due?" → Checks bill calendar

**Pass Criteria:** At least 8/10 actions work correctly per model

### 3. Receipt OCR / Image Understanding
(Only for models that support vision - Gemini, possibly some OpenRouter models)

- [ ] Open Smart Camera (lib/screens/smart_camera_screen.dart)
- [ ] Take photo of receipt or select from gallery
- [ ] Wait for OCR processing
- [ ] Verify extracted items appear
- [ ] Verify amounts are correct
- [ ] Verify merchant name extracted
- [ ] Save expenses from receipt
- [ ] Check if expenses saved to database

**Pass Criteria:** 
- Vision models: Extract at least 70% of receipt items correctly
- Non-vision models: Should gracefully fallback or show "not supported"

### 4. Batch Image Import
- [ ] Open Batch Image Import (lib/screens/batch_image_import_screen.dart)
- [ ] Select 2-3 receipt images
- [ ] Process batch
- [ ] Verify all receipts processed
- [ ] Check for any failed items
- [ ] Verify expenses created for all receipts

**Pass Criteria:** All receipts process without crashes

### 5. AI Insights Generation
(May be in separate insights screen or integrated with analytics)

- [ ] Open AI Insights (check lib/services/insight_service.dart)
- [ ] Trigger insight generation
- [ ] Wait for response
- [ ] Verify insights are relevant to spending data
- [ ] Verify formatting is readable
- [ ] Check if insights are actionable

**Pass Criteria:** Insights generated within 30 seconds, relevant to data

### 6. Voice Commands (if applicable)
- [ ] Open AI screen
- [ ] Tap microphone button
- [ ] Say: "Add expense 100 transportation"
- [ ] Verify voice transcribed correctly
- [ ] Verify action executed
- [ ] Try: "What did I spend yesterday?"
- [ ] Verify response is spoken back (if TTS enabled)

**Pass Criteria:** Voice input works, commands execute

### 7. Model Persistence & Settings
- [ ] Select model in picker
- [ ] Note the selection
- [ ] Send a test message (verify it works)
- [ ] Force close app completely
- [ ] Reopen app
- [ ] Check AI screen
- [ ] Verify same model is still selected
- [ ] Send message to confirm it still works

**Pass Criteria:** Selection persists across app restarts

### 8. Error Handling & Fallback
- [ ] Select a model
- [ ] Send message
- [ ] If fails, check error message is clear
- [ ] Verify app suggests trying another model
- [ ] Check if auto-fallback triggers (if implemented)
- [ ] Try switching model manually
- [ ] Verify new model works

**Pass Criteria:** No crashes on errors, clear messaging

### 9. Rate Limiting Behavior
- [ ] Select a free-tier model with low limits
- [ ] Send multiple rapid messages (10+)
- [ ] Observe if rate limit is hit
- [ ] Check error message
- [ ] Verify app doesn't crash
- [ ] Wait 60 seconds
- [ ] Try again
- [ ] Verify it works after cooldown

**Pass Criteria:** Graceful degradation, no data loss

### 10. Offline Behavior
- [ ] Turn on airplane mode
- [ ] Try to send message
- [ ] Verify clear "no internet" error
- [ ] Turn airplane mode off
- [ ] Verify message now sends
- [ ] Check no duplicate messages created

**Pass Criteria:** Clear offline detection, no duplicates

---

## Performance Benchmarks

For each model, measure:

| Model | Avg Response Time | Cold Start | Tool Call Time | Receipt OCR Time | Notes |
|-------|------------------|------------|----------------|------------------|-------|
| Gemini Flash | ___ ms | ___ ms | ___ ms | ___ ms | Baseline |
| Gemini Flash-Lite | ___ ms | ___ ms | ___ ms | ___ ms | Should be fastest |
| Groq GPT-OSS 120B | ___ ms | ___ ms | ___ ms | ___ ms | |
| OpenRouter Model 1 | ___ ms | ___ ms | ___ ms | ___ ms | |
| OpenRouter Model 2 | ___ ms | ___ ms | ___ ms | ___ ms | |
| OpenRouter Model 3 | ___ ms | ___ ms | ___ ms | ___ ms | |

**Targets:**
- Simple chat: < 3 seconds
- Tool calling: < 5 seconds
- Receipt OCR: < 10 seconds
- Batch (3 receipts): < 30 seconds

---

## Build & Release Checklist

After all tests pass:

### Pre-Build
- [ ] All code committed and pushed
- [ ] Version bumped in pubspec.yaml: 3.3.9
- [ ] Build number incremented
- [ ] CHANGELOG.md updated with new models

### Build Process
```bash
cd c:\xampp\htdocs\smartspend_app
flutter clean
flutter pub get
flutter build apk --split-per-abi
```

- [ ] Build completes without errors
- [ ] APKs generated in build/app/outputs/flutter-apk/
- [ ] File sizes reasonable (~40-50 MB per ABI)

### Git Tagging
```bash
git add .
git commit -m "feat: Add individual OpenRouter models as separate options

- Replace single OpenRouter with 5 specific free models
- Each model selectable in AI picker
- All 34 AI actions work across all models
- Tested vision models for receipt OCR
- Performance benchmarked

Closes #[issue-number]"
git tag -a v3.3.9 -m "v3.3.9 - Multi-model OpenRouter support"
git push origin master
git push origin v3.3.9
```

- [ ] Commit created
- [ ] Tag created
- [ ] Pushed to GitHub
- [ ] GitHub Actions triggered

### Release Creation
- [ ] Wait for GitHub Actions to build APK
- [ ] Download APKs from release
- [ ] Test install on physical device
- [ ] Verify all models appear
- [ ] Quick smoke test (chat + 1 receipt scan)
- [ ] Release notes published

---

## Test Results Summary Template

```markdown
## Test Results - v3.3.9 OpenRouter Multi-Model

**Test Date:** YYYY-MM-DD
**Tester:** [Name]
**Test Device:** [Device model, Android version]

### Models Added
1. [Model name] - [Provider/Size] - [Status: ✅/❌]
2. [Model name] - [Provider/Size] - [Status: ✅/❌]
3. [Model name] - [Provider/Size] - [Status: ✅/❌]

### Overall Results
- Total Models: X
- Models Tested: X
- Tests Passed: XX/XX (XX%)
- Critical Failures: X
- Known Issues: X

### Critical Issues
[List any blocking issues]

### Recommendations
[Pass for release / Needs fixes / Block release]

### Performance Notes
[Fastest model, slowest model, any concerns]
```

---

## Success Criteria (Must Pass ALL)

✅ At least 3 new OpenRouter models added as individual options  
✅ All existing Gemini/Groq models still work (no regressions)  
✅ Model picker shows all models with clear labels  
✅ Basic chat works on 100% of models  
✅ AI actions (tool calling) work on 80%+ of models  
✅ Receipt OCR works on vision-capable models  
✅ Model selection persists across restarts  
✅ No crashes in testing  
✅ APK builds successfully  
✅ Build size < 50 MB per ABI  
✅ Cold start time < 5 seconds  

**Release Decision:**
- ALL criteria met → Ship v3.3.9 immediately
- 1-2 minor issues → Ship with known issues documented
- Critical failures → Hold release, fix blockers

---

**Next Steps After Implementation:**
1. Run full test matrix (allow 2-3 hours)
2. Document results
3. Build release APK
4. Install on test device
5. Final verification
6. Push to GitHub
7. Create release with APKs
8. Update defense materials with new model count
