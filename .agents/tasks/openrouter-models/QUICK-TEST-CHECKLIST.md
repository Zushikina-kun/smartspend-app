# Quick Testing Checklist - v3.3.9

**After APK installs, do these tests (15 min):**

---

## 1. UI Verification (2 min)

### Check Model Picker:
- [ ] Open SmartSpend app
- [ ] Tap Settings (gear icon)
- [ ] Tap "AI Model"
- [ ] **Verify:** All 18 models appear
- [ ] **Verify:** Order is correct:
  - Nemotron 3 Ultra (first OpenRouter)
  - Llama 3.3 70B (second)
  - Gemini models
  - More OpenRouter models
  - Groq models
  - Cerebras (last)

---

## 2. Basic Chat Test - Llama 3.3 (2 min)

### Select Model:
- [ ] In AI Model picker, tap "Llama 3.3 70B (OpenRouter)"
- [ ] Go back to main screen
- [ ] Tap "Chat" tab (💬 icon)

### Send Test Message:
- [ ] Type: "Hello, what model are you?"
- [ ] Tap send
- [ ] **Expected:** Response in 5-10 seconds
- [ ] **Expected:** Response mentions "Llama" or gives a reply
- [ ] ✅ **PASS** if you get ANY response

### Troubleshooting:
- ❌ If no response after 30s → Check internet connection
- ❌ If error "401 Unauthorized" → API key issue (check Firebase)
- ❌ If "Switched to Groq" → OpenRouter key not loaded (restart app)

---

## 3. AI Action Test (3 min)

### Test Expense Creation:
- [ ] Still in Chat tab
- [ ] Type: "Add expense 500 for lunch"
- [ ] Tap send
- [ ] **Expected:** Message like "Added ₱500 expense for lunch"
- [ ] Go to "Transactions" tab
- [ ] **Verify:** New expense shows: ₱500, lunch, today's date
- [ ] ✅ **PASS** if expense appears

### Test Balance Query:
- [ ] Back to Chat tab
- [ ] Type: "What's my total spending today?"
- [ ] **Expected:** Response with amount (should include the ₱500)
- [ ] ✅ **PASS** if gets reasonable answer

---

## 4. Test Another OpenRouter Model (2 min)

### Try Nemotron Lightning (Fastest):
- [ ] Settings → AI Model
- [ ] Select "Nemotron 3.5 Lightning (OpenRouter)"
- [ ] Chat tab
- [ ] Type: "Hello"
- [ ] **Expected:** Response in 1-3 seconds (VERY FAST)
- [ ] ✅ **PASS** if responds quickly

---

## 5. Test Fallback (2 min)

### Verify Groq Still Works:
- [ ] Settings → AI Model
- [ ] Select "GPT-OSS 120B (Groq)"
- [ ] Chat tab
- [ ] Type: "Test message"
- [ ] **Expected:** Response (proves old models still work)
- [ ] ✅ **PASS** - no regression

---

## 6. Receipt OCR Test (Optional, 4 min)

### Test Vision Model:
- [ ] Settings → AI Model
- [ ] Select "Qwen 3.8 27B (OpenRouter)" (has OCR)
- [ ] Go to "Add" tab → "📷 Smart Camera"
- [ ] Take photo of a receipt OR select from gallery
- [ ] **Expected:** Items extracted within 10s
- [ ] ✅ **PASS** if any items detected

**OR skip if no receipt handy - not critical**

---

## Success Criteria

### MUST PASS (Ship v3.3.9):
- ✅ All 18 models appear in picker
- ��� At least 1 OpenRouter model responds to "Hello"
- ✅ AI action works (expense created)
- ✅ Groq still works (no regression)

### NICE TO HAVE (Bonus):
- ✅ Multiple OpenRouter models work
- ✅ Fast models are actually fast
- ✅ OCR works with vision models

### BLOCKERS (Don't ship if):
- ❌ App crashes on startup
- ❌ ZERO OpenRouter models work
- ❌ Old models (Gemini, Groq) broken
- ❌ Can't create expenses

---

## If Tests Fail

### Some OpenRouter Models Fail:
**Acceptable** - just note which ones don't work
- Could be rate limit (50/day shared)
- Could be model temporarily down
- Ship anyway if 3+ work

### All OpenRouter Models Fail with 401:
**API Key Issue:**
1. Check Firebase Remote Config published
2. Restart app (pull fresh config)
3. If still fails, hardcode key in app_config.dart temporarily

### All OpenRouter Models Fail with 400:
**Header Issue (should be fixed):**
1. Check commit ce072de applied
2. Rebuild APK
3. Report if still happens

### App Crashes:
**Build Issue:**
1. Check build logs for errors
2. Try: `flutter clean && flutter pub get`
3. Rebuild

---

## After Testing

### If Tests Pass:
```bash
cd c:\xampp\htdocs\smartspend_app
git tag v3.3.9
git push origin v3.3.9
```

Upload APK to:
- GitHub Releases
- Google Drive (for panelists if needed)

### Update Defense Materials:
- "18 AI models" (not 11)
- "7 OpenRouter models for redundancy"
- "Multi-provider resilience"
- "$0 operating costs (free tier)"

---

## Quick Stats to Note

**For defense presentation:**

After testing, note:
- Response times per model (1-10s)
- Which model you prefer (probably Llama 3.3)
- How many models actually work (target: 15+/18)
- Rate limit experience (if you hit it)

Example:
"I tested all 18 AI models. Nemotron Lightning was fastest at 1-2 seconds, Nemotron Ultra had best quality but slower at 8-10 seconds. Llama 3.3 70B was the best balance. The app gracefully falls back when rate limits are hit."

---

**Time Estimate:** 15 minutes for full checklist  
**Minimum Test:** Steps 1-3 only (7 minutes)  
**Ready to Ship:** If steps 1-5 pass ✅
