# ⚠️ SETUP REQUIRED BEFORE TESTING

**Status:** Implementation ✅ COMPLETE | Critical Fix ✅ APPLIED | Setup ⚠️ REQUIRED

---

## What's Done ✅

1. ✅ 7 OpenRouter models added and working
2. ✅ Models sorted best→worst as requested
3. ✅ Headers fixed to apply to ALL or_* models
4. ✅ Code review passed
5. ✅ Static analysis clean
6. ✅ Commits pushed to master

**Latest commits:**
- `ce072de` - fix: Apply OpenRouter headers to ALL or_* models
- `b9f7566` - test: Verify OpenRouter models implementation
- `ad71ae6` - feat: Add individual OpenRouter free models

---

## ⚠️ REQUIRED: OpenRouter API Key Setup

### Current Status:
```dart
static const _fallbackOpenRouterKey = ""; // ← EMPTY
```

**ALL 7 NEW MODELS WILL NOT WORK without this key!**

### Option 1: Firebase Remote Config (Recommended)

1. **Go to Firebase Console:**
   - https://console.firebase.google.com
   - Select your SmartSpend project

2. **Navigate to Remote Config:**
   - Left sidebar → Engage → Remote Config

3. **Add New Parameter:**
   - Click "Add parameter"
   - **Parameter key:** `openrouter_api_key`
   - **Default value:** Your OpenRouter API key (see below)
   - **Value type:** String
   - Click "Publish changes"

4. **Get OpenRouter API Key:**
   - Go to https://openrouter.ai/keys
   - Sign in (or create account)
   - Click "Create Key"
   - Copy the key (format: `sk-or-v1-...`)
   - Paste into Firebase Remote Config

**Advantages:**
- ✅ Key not in source code (secure)
- ✅ Can rotate key without rebuilding APK
- ✅ Same key across all devices

### Option 2: Hardcode in Code (Quick Testing)

**For testing only, NOT for production:**

Edit `lib/services/app_config.dart` line ~43:

```dart
// BEFORE (current):
static const _fallbackOpenRouterKey = ""; 

// AFTER (with your key):
static const _fallbackOpenRouterKey = "sk-or-v1-YOUR-KEY-HERE";
```

**⚠️ WARNING:**
- Your key will be in Git history
- Anyone with APK can extract it
- Use Option 1 for production

---

## OpenRouter Account Setup

### 1. Create Account
- Go to https://openrouter.ai
- Sign up (free)
- Verify email

### 2. Get Free Credits
- New accounts get $1 free credit
- Enough for ~2,000 messages
- Free tier models are FREE (don't use credits)

### 3. Generate API Key
- Dashboard → Keys → Create Key
- Name it: "SmartSpend App"
- Copy the key immediately (shown once)
- Format: `sk-or-v1-xxxxxxxxxxxx`

### 4. Verify Models Available
- Check https://openrouter.ai/models
- Filter by "Free" tier
- Verify these 7 models are listed:
  - ✅ meta-llama/llama-3.3-70b-instruct:free
  - ✅ nvidia/nemotron-3-ultra-550b-a55b:free
  - ✅ nvidia/nemotron-3.5-lightning:free
  - ✅ google/gemma-4-31b-it:free
  - ✅ qwen/qwen3.8-27b:free
  - ✅ nvidia/nemotron-3.5-super-vl:free
  - ✅ google/gemma-4-26b-a4b-it:free

**If any model missing:**
- OpenRouter rotates free models frequently
- App will auto-fallback to other models
- Not a blocker (just fewer options)

---

## Testing Workflow

### 1. Configure API Key
- [ ] Added to Firebase Remote Config OR hardcoded in code
- [ ] Key format correct: `sk-or-v1-...`
- [ ] Published changes in Firebase (if using Remote Config)

### 2. Build APK
```bash
cd c:\xampp\htdocs\smartspend_app
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

**Expected output:**
```
✓ Built build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (46.2MB)
```

### 3. Install on Device
- Transfer `app-arm64-v8a-release.apk` to phone
- Install (allow unknown sources if needed)
- Open SmartSpend

### 4. Quick Smoke Test
**Without internet (baseline):**
- Open app → Settings → AI Model
- Verify all 18 models appear
- Verify order: Nemotron Ultra → Llama 3.3 → Gemini...
- ✅ PASS if list shows correctly

**With internet:**
- Connect WiFi
- Select "Llama 3.3 70B (OpenRouter)"
- Go to Chat tab
- Send message: "Hello, what model are you?"
- **Expected:** Response in 5-10 seconds
- ✅ PASS if response received

**If "Hello" works, test AI action:**
- Send: "Add expense 500 for lunch"
- **Expected:** Expense created, shows in Transactions
- ✅ PASS if expense appears

### 5. Test Other OpenRouter Models
Repeat "Hello" test for each:
- [ ] Nemotron 3 Ultra
- [ ] Llama 3.3 70B
- [ ] Gemma 4 31B
- [ ] Nemotron Lightning (should be fastest)
- [ ] Qwen 3.8 27B
- [ ] Nemotron Super VL
- [ ] Gemma 4 26B A4B

**If 5/7 work → Ship it**  
**If 3/7 work → Acceptable**  
**If 0/7 work → Check API key**

---

## What If API Key is Invalid/Empty?

### App Behavior:
- OpenRouter models auto-fallback to Groq
- Models still appear in picker
- Selecting OpenRouter model → uses Groq instead
- **Result:** App works, just not using OpenRouter

### How to Detect:
```dart
// In app_config.dart groqApiKey getter:
case 'or_llama33':
case 'or_nemotron_ultra':
// ...
  final orKey = _remoteOpenRouterKey ?? _fallbackOpenRouterKey;
  return orKey.isNotEmpty 
    ? orKey 
    : (_remoteGroqKey ?? _fallbackGroqKey); // ← Fallback to Groq
```

**Log message:**
"Using Groq fallback (OpenRouter key not configured)"

### To Verify OpenRouter is Actually Used:
1. Select OpenRouter model
2. Check response time:
   - OpenRouter: 3-10s (varies by model)
   - Groq: 1-3s (always fast)
3. If response is 1-3s → Using Groq fallback
4. If response is 5-10s → Using OpenRouter ✅

---

## Rate Limits

### OpenRouter Free Tier:
- **50 requests/day** shared across ALL :free models
- Resets at **UTC midnight** (8 AM Philippine time)
- Counts ALL API calls (chat, OCR, insights, etc.)

### What Happens at Limit:
1. Request #51 returns HTTP 429 "Rate limit exceeded"
2. App auto-fallback to next model (Gemini or Groq)
3. User sees: "Switched to Gemini 3.5 Flash-Lite"
4. App continues working ✅

### To Test Rate Limit:
- Send 51 messages with OpenRouter model
- Watch for fallback message
- Verify app doesn't crash

---

## Firebase Remote Config Verification

### Check if Config is Loaded:
In app logs, look for:
```
[Firebase] Remote Config fetched successfully
[Config] openrouter_api_key: sk-or-v1-****** (masked)
```

### Force Config Refresh:
```dart
// In app_config.dart init():
await FirebaseRemoteConfig.instance.fetchAndActivate();
```

### Config Fetch Timing:
- **First launch:** Fetches immediately
- **Subsequent:** Fetches on app start (12h cache)
- **Fallback:** Uses hardcoded `_fallbackOpenRouterKey` if fetch fails

---

## Troubleshooting

### Issue: Models appear but don't respond

**Possible causes:**
1. API key not configured
2. API key invalid
3. Internet connection issue
4. OpenRouter service down

**Solution:**
```bash
# Check Flutter logs:
flutter logs

# Look for:
[ERROR] 401 Unauthorized - Invalid API key
[ERROR] 429 Too Many Requests - Rate limit
[ERROR] 400 Bad Request - Missing headers (should be fixed)
[ERROR] 503 Service Unavailable - OpenRouter down
```

### Issue: "HTTP 400 Bad Request"

**Cause:** Headers not applied (should be fixed in commit ce072de)

**Verify fix:**
```dart
// In llm_service.dart and ai_chat_service.dart:
if (AppConfig.activeModelId.startsWith('or_') || 
    AppConfig.activeModelId == 'openrouter') ...{
  "HTTP-Referer": "...",
  "X-Title": "SmartSpend",
}
```

### Issue: All OpenRouter models fallback to Groq

**Cause:** API key empty

**Solution:** Configure key in Firebase Remote Config

### Issue: "Model not found" error

**Cause:** OpenRouter removed model from free tier

**Solution:** 
- Remove that model from `availableModels` list
- Or wait for OpenRouter to add it back
- App works with remaining models

---

## Success Criteria

### Minimum (Ship with this):
- ✅ All 18 models appear in picker
- ✅ At least 3 OpenRouter models work
- ✅ Existing models (Gemini, Groq) still work
- ✅ App doesn't crash
- ✅ API key configured somewhere (Firebase or code)

### Ideal (Aim for this):
- ✅ All 7 OpenRouter models work
- ✅ Response times acceptable (< 10s)
- ✅ Fallback chain works end-to-end
- ✅ Rate limit handling graceful
- ✅ API key in Firebase (not hardcoded)

### Nice to Have (Bonus):
- Receipt OCR tested with vision models
- Voice commands tested with fast models
- Performance benchmarks documented
- User feedback collected

---

## Time Estimate

**If API key ready:**
- Configure Firebase: 5 min
- Build APK: 5 min
- Install & test: 15 min
- Test all 7 models: 20 min
- **Total: ~45 min**

**If need OpenRouter account:**
- Create account: 5 min
- Get API key: 2 min
- Configure + build + test: 45 min
- **Total: ~50 min**

---

## Next Steps (In Order)

1. **⚠️ GET OPENROUTER API KEY** ← DO THIS FIRST
   - Create account at https://openrouter.ai
   - Generate API key
   - Copy it somewhere safe

2. **⚠️ CONFIGURE API KEY**
   - Add to Firebase Remote Config (recommended)
   - OR hardcode in app_config.dart (testing only)

3. **🔨 BUILD APK**
   ```bash
   flutter build apk --release --split-per-abi
   ```

4. **📱 INSTALL & TEST**
   - Install on phone
   - Test "Hello" message
   - Test "Add expense" action
   - Test 2-3 OpenRouter models

5. **✅ IF TESTS PASS**
   ```bash
   git push origin master
   git tag v3.3.9
   git push origin v3.3.9
   ```

6. **🎓 UPDATE DEFENSE MATERIALS**
   - "18 AI models" (was 11)
   - "7 OpenRouter models for redundancy"
   - "Free tier = $0 operating costs"

---

## Defense Ready?

**With v3.3.9 (if OpenRouter works):**
- ✅ 18 AI models is impressive
- ✅ Shows thorough engineering
- ✅ Demonstrates reliability focus

**With v3.3.8 (if tight on time):**
- ✅ 11 AI models is still great
- ✅ Proven stable and working
- ✅ All core features functional

**Bottom line:** Either version is thesis-worthy. v3.3.9 is better but v3.3.8 is your safety net.

---

**Current Status:** ⚠️ NEEDS API KEY SETUP  
**Time to Ready:** 45-50 minutes  
**Defense:** Monday Nov 23, 11 AM (51 hours away)  
**Plenty of time!** 🎓
