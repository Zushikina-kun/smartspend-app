# Post-Capstone Tasks & Improvements

**Capstone Status:** ✅ DEFENDED & PASSED! 🎉  
**Date:** November 20, 2026  
**Current Version:** v3.3.8 (deployed)  
**Pending Version:** v3.3.9 (18 AI models - needs push)

---

## IMMEDIATE TASKS (Next 24 Hours)

### 1. Push Real v3.3.9 to GitHub ⚠️ HIGH PRIORITY

**Problem:** 3 commits with 18 AI models are only on local PC, never pushed to GitHub.

**Commands to run:**
```bash
cd c:\xampp\htdocs\smartspend_app
git push origin master
git push origin --delete v3.3.9
git push origin v3.3.9
```

**Verification:**
```bash
git fetch origin
git log origin/master --oneline -5
# Should see: ce072de, b9f7566, ad71ae6 (OpenRouter commits)
```

**Result:** GitHub Actions will build real v3.3.9 with 18 models in 10-12 minutes.

---

### 2. Fix Issues Found During Defense

#### Issue #1: Reviewer.html Search Fixed ✅
- **Status:** FIXED (Claude fixed it)
- **Commit:** 6554acd
- **Working:** Search now functional

#### Issue #2: OpenRouter Models Not in APK ⚠️
- **Status:** CODE READY, needs push
- **Commits:** ce072de, b9f7566, ad71ae6
- **Fix:** Push commits to GitHub (see #1)

#### Issue #3: API Key Configuration
- **Status:** DOCUMENTED
- **Location:** Firebase Remote Config setup required
- **Docs:** `.agents/tasks/openrouter-models/SETUP-REQUIRED.md`

---

### 3. Test Real v3.3.9 After GitHub Build

**After push completes and GitHub Actions builds:**

1. Download new APK from releases
2. Install on device
3. Verify 18 models appear
4. Test 2-3 OpenRouter models
5. Document which models work
6. Update README with results

---

## SHORT-TERM IMPROVEMENTS (Next Week)

### Code Quality

#### Refactor Fallback Chain
**Current Issue:** Manual switch statements for each model  
**Improvement:** Iterate through availableModels list automatically

**File:** `lib/services/app_config.dart` line ~615  
**Estimated Time:** 30 minutes

```dart
// Current (manual):
case 'or_llama33': return 'or_nemotron_ultra';
case 'or_nemotron_ultra': return 'gemini_flash';
// ... 18 more cases

// Improved (automatic):
static bool autoFallback() {
  int currentIndex = availableModels.indexWhere((m) => m.$1 == _activeModelId);
  for (int i = currentIndex + 1; i < availableModels.length; i++) {
    if (_hasRequiredKey(availableModels[i].$1)) {
      _activeModelId = availableModels[i].$1;
      return true;
    }
  }
  return false;
}
```

---

#### Add Vision Model Priority for OCR
**Current Issue:** OCR doesn't prefer vision-capable models  
**Improvement:** Try vision models first

**File:** `lib/services/ocr_service.dart`  
**Estimated Time:** 20 minutes

```dart
// Prioritize vision models for OCR:
const visionModels = [
  'or_nemotron_super_vl',  // Best vision
  'or_qwen38',             // OCR-optimized
  'gemini_flash',          // Has vision
  'gemini_flash_lite',     // Has vision
];

// Try vision models first, then fallback to text-only
```

---

#### Add Speed Model Priority for Voice
**Current Issue:** Voice uses default model (may be slow)  
**Improvement:** Prefer fast models for voice

**File:** `lib/services/peso_voice_service.dart`  
**Estimated Time:** 15 minutes

```dart
// Use fast models for voice commands:
const fastModels = [
  'gemini_flash_lite',      // Fastest overall
  'or_nemotron_lightning',  // Fastest OpenRouter
  'groq_8b',               // Fastest Groq
];
```

---

### Testing & Validation

#### Create Automated Test Suite
**Goal:** Test all 18 models programmatically

**Tasks:**
- [ ] Write unit tests for each model
- [ ] Test tool calling on each
- [ ] Measure response times
- [ ] Document pass/fail rates
- [ ] Create CI/CD test pipeline

**Estimated Time:** 4-6 hours

---

#### Performance Benchmarking
**Goal:** Document actual performance of each model

**Metrics to collect:**
- Average response time per model
- Success rate (% of successful responses)
- Rate limit frequency
- User preference data

**Tool:** Add analytics to track model usage

---

### Documentation

#### Update README.md
**Current:** Outdated (mentions older features)

**Updates needed:**
- [ ] Update to v3.3.9
- [ ] List all 18 AI models
- [ ] Add OpenRouter setup instructions
- [ ] Update screenshots with new UI
- [ ] Add performance comparison table
- [ ] Document rate limits clearly

---

#### Create User Manual
**Target:** Non-technical users

**Sections:**
1. Installation guide
2. First-time setup (including Firebase config)
3. Choosing AI models (when to use which)
4. Using 34 AI actions
5. Receipt scanning tips
6. Troubleshooting common issues

**Format:** PDF + online wiki

---

#### API Documentation
**Target:** Developers who want to understand the code

**Sections:**
1. Architecture overview
2. Model routing logic
3. Fallback chain explanation
4. Adding new AI providers
5. Extending AI actions
6. Database schema

---

## MEDIUM-TERM ENHANCEMENTS (Next Month)

### Feature Additions

#### 1. Model Performance Dashboard
**What:** In-app screen showing model stats

**Features:**
- Response time per model
- Success/failure rates
- Rate limit status
- User ratings
- Recommendation: "Best for you"

**UI Location:** Settings → AI Model → Performance Stats

---

#### 2. Smart Model Selection
**What:** AI automatically picks best model per task

**Logic:**
- Receipt scan → Vision models
- Voice command → Fast models
- Complex analysis → Quality models
- Budget query → Balanced models

**Implementation:** Add task type parameter to model selection

---

#### 3. Model A/B Testing
**What:** Compare 2 models on same query

**Use case:** User unsure which model is better

**UI:** Chat → "Compare Models" button → Shows 2 responses side-by-side

---

#### 4. Offline Fallback Messages
**What:** Better offline detection and queuing

**Current:** Shows error immediately  
**Improved:** Queue messages, send when online returns

---

#### 5. Custom Model Presets
**What:** Let users create named presets

**Examples:**
- "Work Mode" → Fast models only
- "Quality Mode" → Best models only
- "Budget Mode" → Free models with highest limits

---

### Infrastructure

#### 1. Add Sentry for Error Tracking
**Why:** Currently no production error monitoring

**Setup:**
```dart
// In main.dart:
await SentryFlutter.init(
  (options) {
    options.dsn = 'your-sentry-dsn';
  },
  appRunner: () => runApp(MyApp()),
);
```

**Benefit:** Know when models fail in production

---

#### 2. Add Analytics (Google Analytics or Firebase)
**Metrics to track:**
- Model usage frequency
- Feature usage
- Crash rates
- User retention
- Session duration

---

#### 3. Implement Feature Flags
**Why:** Enable/disable features remotely

**Use cases:**
- Disable broken model remotely
- A/B test new features
- Roll out features gradually

**Tool:** Firebase Remote Config (already used for API keys)

---

#### 4. Add Automated CI/CD
**Current:** Manual builds

**Improved:**
- Auto-build on every push
- Run tests automatically
- Deploy to beta testers
- Auto-publish to Play Store

**Tool:** GitHub Actions (already set up, needs expansion)

---

## LONG-TERM GOALS (Next 3-6 Months)

### 1. Publish to Google Play Store
**Requirements:**
- [ ] Developer account ($25 one-time)
- [ ] Privacy policy
- [ ] Terms of service
- [ ] App screenshots (8 required)
- [ ] Feature graphic (1024x500)
- [ ] App description (4000 chars)
- [ ] Content rating questionnaire
- [ ] Target audience declaration

**Timeline:** 1-2 weeks for approval

---

### 2. Add More AI Providers
**Candidates:**
- Anthropic Claude (if API access)
- Cohere (has free tier)
- Mistral AI (has free tier)
- Hugging Face Inference (free)
- Local Llama.cpp (fully offline)

**Benefit:** 25+ AI models, even more redundancy

---

### 3. Implement Local AI Option
**What:** Run LLM entirely on device

**Benefits:**
- 100% privacy
- Works offline
- No API costs
- No rate limits

**Challenges:**
- Large app size (2-4 GB with model)
- Slower on older phones
- Battery drain

**Models to consider:**
- Phi-3 Mini (3B params, 2 GB)
- Gemma 2B (smallest Gemini)
- TinyLlama (1.1B params, 1 GB)

**Implementation:** MediaPipe LLM or llama.cpp Android

---

### 4. Multi-Language Support
**Current:** English + some Tagalog  
**Goal:** Full localization

**Languages:**
- Tagalog (Filipino)
- Cebuano (Visayan)
- Ilocano (Northern Luzon)
- Spanish (for older users)

**Translation needs:**
- UI strings (500+ strings)
- AI prompts
- Help documentation
- Error messages

---

### 5. Web Version
**Why:** Not all users have Android

**Stack:**
- Flutter Web (same codebase)
- Firebase Hosting
- PWA (installable)

**Benefits:**
- Works on iOS (via browser)
- Works on desktop
- No app store approval needed

**URL:** smartspend.app or smartspend-ph.web.app

---

## RESEARCH & EXPERIMENTATION

### 1. Fine-tune Custom Model
**What:** Train a model specifically for Filipino finance

**Dataset:**
- Filipino finance terms
- Common transactions
- Tagalog/English code-switching
- Philippine banks/merchants

**Platform:** Google Vertex AI or OpenAI fine-tuning

**Benefit:** Better understanding of Filipino context

---

### 2. Voice-First Interface
**What:** Fully hands-free app control

**Features:**
- "Hey SmartSpend" wake word
- Voice-only navigation
- Spoken expense entry
- Audio receipt scanning (speak items)

**Use case:** Drivers, elderly, visually impaired

---

### 3. Receipt OCR Improvements
**Current:** 70-80% accuracy  
**Goal:** 95%+ accuracy

**Approaches:**
- Fine-tune OCR model on Filipino receipts
- Multi-model voting (3 models, majority wins)
- Post-processing rules (Philippine format)
- User correction feedback loop

---

### 4. Predictive Budgeting
**What:** AI predicts next month's spending

**Features:**
- "You'll likely spend ₱X next month"
- "Your food budget may be exceeded"
- "Consider increasing utilities by 10%"

**Model:** Time series forecasting (ARIMA, Prophet, or LLM)

---

### 5. Social Features
**What:** Compare spending with peers (anonymized)

**Features:**
- "Average 25-30 year olds spend ₱X on food"
- "You spend 15% more than similar users"
- Leaderboards for saving challenges
- Group budgets (families, barkadas)

**Privacy:** All data anonymized, opt-in only

---

## ISSUES TO FIX

### Known Bugs (Post-Defense)

#### 1. ❌ v3.3.9 Not Actually on GitHub
**Status:** BLOCKING  
**Priority:** HIGH  
**Fix:** Push commits (see Immediate Tasks #1)

#### 2. ⚠️ OpenRouter Headers Only on Legacy Model
**Status:** FIXED in local code (ce072de)  
**Priority:** HIGH  
**Blocker:** Not pushed to GitHub yet

#### 3. ⚠️ Model Sorting Not Perfect
**Status:** FIXED in local code (b9f7566)  
**Priority:** MEDIUM  
**Blocker:** Not pushed to GitHub yet

#### 4. Reviewer.html Search Was Broken
**Status:** ✅ FIXED and pushed (6554acd)  
**Priority:** LOW (already fixed)

---

### Potential Issues (Not Yet Encountered)

#### Rate Limit Handling
**Risk:** 50 req/day on OpenRouter may be exceeded  
**Mitigation:** Auto-fallback works, but no warning to user  
**Improvement:** Show "15 requests remaining" in UI

#### Model Availability
**Risk:** OpenRouter :free models can be deprecated anytime  
**Mitigation:** Fallback chain works  
**Improvement:** Auto-detect unavailable models, hide from UI

#### API Key Rotation
**Risk:** If key expires, all OpenRouter models fail  
**Mitigation:** Fallback to Groq  
**Improvement:** Email alert when key approaching expiry

---

## DOCUMENTATION TASKS

### For GitHub Repository

- [ ] Update README.md with v3.3.9 features
- [ ] Add CHANGELOG.md
- [ ] Create CONTRIBUTING.md
- [ ] Add LICENSE file (MIT or Apache 2.0)
- [ ] Create wiki pages:
  - Installation guide
  - Configuration guide  
  - Development setup
  - API documentation
  - Troubleshooting

### For Users

- [ ] Create user manual PDF
- [ ] Record demo videos
- [ ] Create FAQ page
- [ ] Add tooltips in app (first-time user help)
- [ ] Create quick start guide

### For Future Developers

- [ ] Architecture decision records (ADRs)
- [ ] Code documentation (JSDoc/DartDoc)
- [ ] Database schema diagram
- [ ] API flow diagrams
- [ ] Testing guide
- [ ] Deployment guide

---

## COMMUNITY & OUTREACH

### Share Your Work

- [ ] Post on Reddit (r/FlutterDev, r/Philippines)
- [ ] Share on LinkedIn (tech network)
- [ ] Write blog post about development journey
- [ ] Create portfolio case study
- [ ] Submit to Flutter showcase
- [ ] Present at local tech meetup

### Get Feedback

- [ ] Share with 10 beta testers
- [ ] Create feedback form (Google Forms)
- [ ] Set up Discord/Telegram for users
- [ ] Monitor app reviews (once on Play Store)
- [ ] Track feature requests

### Consider Monetization (Optional)

**Free Tier:** Current features  
**Pro Tier ($2.99/month or ₱149/month):**
- Unlimited AI requests
- Export to Excel/PDF
- Multi-device sync
- Priority support
- Custom categories
- Advanced analytics

**Alternative:** Keep 100% free, add optional donation button

---

## THESIS FOLLOW-UP

### Publications

- [ ] Submit paper to IEEE conference
- [ ] Publish in ACM Digital Library
- [ ] Write article for local CS journal
- [ ] Create technical blog posts

### Academic Recognition

- [ ] Nominate for best thesis award
- [ ] Present at university research fair
- [ ] Share with department for showcase
- [ ] Update CV/resume with achievement

---

## METRICS TO TRACK

### Technical Metrics
- App size (MB)
- Cold start time (seconds)
- Response time per model (seconds)
- Success rate per model (%)
- Crash rate (crashes per user)
- API cost (if any paid models added)

### User Metrics
- Daily active users (DAU)
- Monthly active users (MAU)
- Session duration (minutes)
- Retention rate (D1, D7, D30)
- Feature usage (which features used most)
- Model preference (which models users choose)

### Business Metrics (if monetizing)
- Conversion rate (free → paid)
- Churn rate
- Revenue per user
- Customer acquisition cost

---

## PRIORITIES

### Must Do Now (This Week):
1. ✅ Push v3.3.9 to GitHub
2. ✅ Test real v3.3.9 with 18 models
3. ✅ Update README.md

### Should Do Soon (This Month):
4. Refactor fallback chain (code quality)
5. Add vision model priority for OCR
6. Create user manual
7. Set up error tracking (Sentry)

### Nice to Have (Next 3 Months):
8. Publish to Play Store
9. Add local AI option
10. Implement A/B testing UI
11. Multi-language support

### Future Ideas (6+ Months):
12. Web version
13. Social features
14. Custom fine-tuned model
15. Voice-first interface

---

## NEXT STEPS (Right Now)

1. **Push v3.3.9 to GitHub** (commands at top)
2. **Wait for GitHub Actions** (10-12 min)
3. **Download and test** real v3.3.9
4. **Document results** (which models work)
5. **Update README.md** with findings
6. **Close remaining issues** on GitHub
7. **Plan next feature** from this list

---

**Status:** Capstone COMPLETE ✅  
**Next Phase:** Open-source refinement & potential commercialization  
**Timeline:** Flexible, work at your own pace  
**Goal:** Make SmartSpend the #1 Filipino finance app 🚀
