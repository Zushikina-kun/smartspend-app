# SmartSpend - Post-Defense Action Plan

**Status:** Capstone DEFENDED ✅ (November 20, 2026)  
**Current Version:** v3.3.8 (in production)  
**Next Version:** v3.3.9 (needs push)  
**Planning Date:** November 20, 2026  
**Timeline:** Week 1 → Month 6

---

## 🎯 GUIDING PRINCIPLES

1. **Take a break first** - You just defended! Rest for 1-2 days.
2. **Start small** - Don't burn out with massive features immediately
3. **Ship often** - Small incremental releases (v3.3.9 → v3.4.0 → v3.5.0)
4. **One thing at a time** - Focus reduces context-switching fatigue
5. **Test everything** - Defense is over, quality still matters

---

## 📅 WEEK 1 (Days 1-7) - Critical Fixes & Quick Wins

### Day 1-2: REST & CELEBRATE 🎉
**What:** Take a complete break from SmartSpend
- No coding
- No planning
- No "just one small fix"
- You earned this!

**Why:** Prevent burnout, return with fresh energy

---

### Day 3: Push v3.3.9 to GitHub ⚠️ BLOCKING EVERYTHING

**Priority:** 🔥 CRITICAL (15 minutes)  
**Blocks:** All future work depends on this

**What to do:**
```bash
# Option 1: GitHub Desktop (EASIEST)
1. Open GitHub Desktop
2. Click "Push origin"
3. Done!

# Option 2: Command line with token
# See: .agents/tasks/MANUAL-PUSH-GUIDE.md
```

**Verify it worked:**
```bash
git fetch origin
git log origin/master --oneline -5
# Should show: ce072de, b9f7566, ad71ae6
```

**Then:**
- Wait 10-12 min for GitHub Actions to build
- Download APK from releases
- Test on phone (verify 18 models appear)
- Document which models work

**Success = Real v3.3.9 on GitHub with 18 AI models**

**Time:** 15 min push + 30 min testing = 45 minutes total

---

### Day 4: Safe-to-Spend Number 🔥 HIGHEST IMPACT

**Priority:** 🔥 CRITICAL (1 day)  
**Why:** #1 competitive gap vs BudgetPH

**What it is:**
A big number on Home screen: "₱1,240 safe to spend until Sep 30"

**Formula:**
```dart
safe_to_spend = wallet_balance
  - upcoming_bills_before_next_payday
  - goal_contributions_remaining
  - debt_payments_due
```

**Implementation Plan:**

**Step 1: Query logic (2 hours)**
```dart
// In lib/services/db_service.dart
static Future<double> calculateSafeToSpend() async {
  final db = await database;
  
  // Get wallet balance
  final wallets = await db.query('wallets');
  double totalBalance = wallets.fold(0.0, (sum, w) => sum + (w['balance'] as num).toDouble());
  
  // Get payday date from settings
  final prefs = await SharedPreferences.getInstance();
  final paydayDay = prefs.getInt('payday_date') ?? 15;
  
  // Calculate next payday
  final now = DateTime.now();
  DateTime nextPayday = DateTime(now.year, now.month, paydayDay);
  if (nextPayday.isBefore(now)) {
    nextPayday = DateTime(now.year, now.month + 1, paydayDay);
  }
  
  // Get upcoming recurring bills before payday
  final recurring = await db.rawQuery('''
    SELECT amount FROM recurring_transactions
    WHERE next_date <= ? AND category IN 
      (SELECT id FROM categories WHERE parent_category = 'Bills')
  ''', [nextPayday.toIso8601String()]);
  
  double upcomingBills = recurring.fold(0.0, (sum, r) => sum + (r['amount'] as num).toDouble());
  
  // Get monthly goal contributions (pro-rated to payday)
  final goals = await db.query('savings_goals', where: 'archived = 0');
  double goalContributions = 0.0;
  for (var goal in goals) {
    final target = (goal['target_amount'] as num).toDouble();
    final current = (goal['current_amount'] as num).toDouble();
    final remaining = target - current;
    // Assume monthly contribution
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysUntilPayday = nextPayday.difference(now).inDays;
    goalContributions += (remaining / daysInMonth) * daysUntilPayday;
  }
  
  // Get upcoming debt payments
  final debts = await db.query('debts', where: 'archived = 0');
  double debtPayments = debts.fold(0.0, (sum, d) {
    final monthlyPayment = (d['monthly_payment'] as num?)?.toDouble() ?? 0.0;
    return sum + monthlyPayment;
  });
  
  // Calculate safe-to-spend
  double safeToSpend = totalBalance - upcomingBills - goalContributions - debtPayments;
  return safeToSpend.clamp(0, double.infinity); // Never negative
}
```

**Step 2: Home screen widget (1 hour)**
```dart
// In lib/screens/home_screen.dart, after wallet card:

Widget _buildSafeToSpendCard() {
  return FutureBuilder<double>(
    future: DBService.calculateSafeToSpend(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return SizedBox.shrink();
      
      final amount = snapshot.data!;
      final prefs = SharedPreferences.getInstance();
      final paydayDay = prefs.then((p) => p.getInt('payday_date') ?? 15);
      
      return Card(
        color: Color(0xFF1a2e1a),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Color(0xFF00C896), size: 24),
                  SizedBox(width: 8),
                  Text('Safe to Spend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 12),
              Text(
                CurrencyService.format(amount),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: amount > 1000 ? Color(0xFF00C896) : Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<int>(
                future: paydayDay,
                builder: (context, pdSnapshot) {
                  if (!pdSnapshot.hasData) return SizedBox.shrink();
                  final nextPayday = _calculateNextPayday(pdSnapshot.data!);
                  final daysUntil = nextPayday.difference(DateTime.now()).inDays;
                  return Text(
                    'Until ${DateFormat('MMM d').format(nextPayday)} (payday in $daysUntil days)',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  );
                },
              ),
              SizedBox(height: 12),
              Text(
                'Reserved: Bills • Goals • Debts',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    },
  );
}

DateTime _calculateNextPayday(int day) {
  final now = DateTime.now();
  DateTime next = DateTime(now.year, now.month, day);
  if (next.isBefore(now)) {
    next = DateTime(now.year, now.month + 1, day);
  }
  return next;
}
```

**Step 3: Add to home screen (30 min)**
- Insert `_buildSafeToSpendCard()` after wallet card in ListView
- Test with different scenarios (high balance, low balance, no payday set)
- Handle edge cases (students with weekly allowance)

**Step 4: Settings integration (30 min)**
- Add toggle: "Show Safe-to-Spend card" (default: ON)
- For students: "Use allowance cycle instead of payday"

**Testing checklist:**
- [ ] Shows correct amount when bills are scheduled
- [ ] Updates when goals change
- [ ] Handles no payday date set (asks user to set)
- [ ] Amount never goes negative (clamps to 0)
- [ ] Refreshes when wallet balance changes
- [ ] Card hidden when toggle OFF

**Commit message:**
```
feat: Add Safe-to-Spend number on Home screen

- Calculate spendable amount after bills/goals/debts reserved
- Prominent card display with payday countdown
- Addresses BudgetPH competitive gap
- Configurable via Settings toggle
```

**Impact:** This ONE feature makes SmartSpend feel "complete" for tight-budget users

**Time:** 4-6 hours (can finish in one focused day)

---

### Day 5: Update README.md & Documentation

**Priority:** MEDIUM (1-2 hours)

**What to update:**

1. **README.md:**
```markdown
# SmartSpend v3.3.9

<!-- Update badges -->
![Version](https://img.shields.io/badge/version-3.3.9-green)
![AI Models](https://img.shields.io/badge/AI%20Models-18-blue)

## ✨ What's New in v3.3.9
- 🤖 **18 AI Models** (was 11) - 7 new OpenRouter free models
- 🎯 **Safe-to-Spend Number** - See exactly how much you can spend
- 🔧 **Bug Fixes** - OpenRouter headers fixed for all models

## 🧠 AI Models (18 Total)
### OpenRouter (7 free models)
- or_nemotron_ultra (Nvidia, 550B MoE, best quality)
- or_llama33 (Meta, 70B, 9.4 Intelligence Index)
- or_gemma_4_31b (Google, reliable, 262K context)
- or_nemotron_lightning (Nvidia, fastest)
- or_qwen38 (Alibaba, multimodal, OCR-optimized)
- or_nemotron_super_vl (Nvidia, vision + video)
- or_gemma_4_26b (Google, efficient MoE)

### Gemini (3)
- gemini_flash (Google, primary)
- gemini_flash_lite (fastest)
- gemini_pro (most capable)

### Groq (4)
- groq_70b, groq_8b, groq_llama_guard, groq_llama_llava

### Others (4)
- gpt4o_mini (OpenAI)
- claude_haiku (Anthropic)
- deepseek
- openrouter (legacy gateway)

<!-- Add Safe-to-Spend section -->
## 💰 Safe-to-Spend Number
SmartSpend shows you exactly how much money you can safely spend before your next payday, after all bills, goals, and debt payments are reserved.

**Formula:** `Wallet Balance - (Bills + Goals + Debts) = Safe to Spend`

**Example:** You have ₱5,000. Bills due: ₱1,200. Goal contributions: ₱800. Debts: ₱500.  
**Safe to Spend: ₱2,500** ✅

<!-- Update screenshots if you have new ones -->
```

2. **CHANGELOG.md** (create if doesn't exist):
```markdown
# Changelog

## [3.3.9] - 2026-11-20

### Added
- 7 new OpenRouter free models as separate options
- Safe-to-Spend number on Home screen
- Model sorting (best to worst)

### Fixed
- OpenRouter headers now apply to all or_* models (was only legacy gateway)
- Model fallback chain for individual OpenRouter models

### Changed
- AI model count: 11 → 18

## [3.3.8] - 2026-11-19
<!-- Previous version notes -->
```

3. **OPENROUTER_SETUP.md:**
- Add section: "Testing Your Setup"
- List all 7 models with expected behavior
- Troubleshooting: "Model returns 429? Check rate limits"

**Time:** 1-2 hours

---

### Day 6-7: Weekend - Choose ONE Quick Win

Pick ONE of these (don't try to do all):

#### Option A: Add Sentry Error Tracking (1-2 hours)
**Why:** Know when things break in production

```bash
flutter pub add sentry_flutter
```

```dart
// In main.dart:
await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_SENTRY_DSN'; // Get from sentry.io (free)
    options.environment = 'production';
    options.release = 'smartspend@3.3.9';
  },
  appRunner: () => runApp(MyApp()),
);
```

**Benefit:** You'll get email alerts when crashes happen

---

#### Option B: Add Firebase Analytics (1-2 hours)
**Why:** See which models users prefer

```bash
flutter pub add firebase_analytics
flutterfire configure
```

```dart
// Track model switches:
await FirebaseAnalytics.instance.logEvent(
  name: 'model_switched',
  parameters: {
    'from_model': oldModel,
    'to_model': newModel,
  },
);
```

**Benefit:** Data-driven decisions on which models to keep/remove

---

#### Option C: Refactor Fallback Chain (2-3 hours)
**Why:** Make it dynamic instead of manual switch statement

```dart
// In lib/services/app_config.dart
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

**Benefit:** Adding new models doesn't require editing fallback logic

---

#### Option D: Just Rest More 😴
**Why:** Seriously, you just defended. Week 1 is about momentum, not exhaustion.

**Recommended:** Pick Option A (Sentry) or D (Rest)

---

## 📅 WEEK 2-4 (Days 8-30) - Build Momentum

### Week 2 Goals: Price Intelligence Phase 1

**What:** Show users their own price history

**Feature:** Price Pulse card in Analytics

**Implementation:**
```sql
-- New table:
CREATE TABLE price_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  source TEXT NOT NULL,       -- 'personal', 'psa_cpi', 'psa_retail'
  commodity TEXT NOT NULL,    -- 'rice', 'food', 'transport'
  period TEXT NOT NULL,       -- 'YYYY-MM'
  value REAL NOT NULL,
  unit TEXT,
  fetched_at TEXT NOT NULL,
  UNIQUE(source, commodity, period)
);
```

**Widget:**
```dart
// In Analytics screen
Widget _buildPricePulseCard(String itemName) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: DBService.getItemPriceHistory(itemName),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.length < 3) {
        return SizedBox.shrink(); // Need 3+ data points
      }
      
      // Show line chart with lowest/highest/current labels
      return Card(
        child: Column(
          children: [
            Text('Price History: $itemName'),
            LineChart(/* fl_chart widget */),
            Text('Personal inflation: +6.2% (outpacing national +4.8%)'),
          ],
        ),
      );
    },
  );
}
```

**Time:** 1 week (spread across evenings)

---

### Week 3 Goals: OpenRouter Rate Limit Handling

**Problem:** 1000 req/day limit, no warning to users

**Solution:**
```dart
// In lib/services/llm_service.dart
Future<Map<String, dynamic>> checkOpenRouterLimits() async {
  final response = await http.get(
    Uri.parse('https://openrouter.ai/api/v1/key'),
    headers: {'Authorization': 'Bearer $openRouterKey'},
  );
  return jsonDecode(response.body);
}

// Cache result for 1 hour
DateTime? _lastLimitCheck;
Map<String, dynamic>? _cachedLimits;

// Show warning in Settings → AI Model
if (remainingRequests < 100) {
  showBanner('⚠️ ${remainingRequests} OpenRouter requests remaining today');
}

// Handle 429 errors
if (response.statusCode == 429) {
  print('OpenRouter rate limited, falling back...');
  return await AppConfig.fallbackAndRetry();
}
```

**Time:** 2-3 hours

---

### Week 4 Goals: Write Unit Tests

**Why:** Catch bugs before users do

**Start small:**
```dart
// test/services/app_config_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smartspend/services/app_config.dart';

void main() {
  group('Model Fallback Tests', () {
    test('Should fallback to next model when current unavailable', () {
      // Test logic
    });
    
    test('Should respect model priority order', () {
      // Test availableModels list order
    });
    
    test('Should not fallback when in local-only mode', () {
      // Test local-only toggle
    });
  });
}
```

**Run tests:**
```bash
flutter test
```

**Goal:** Write 5-10 simple tests for critical paths

**Time:** 2-3 hours

---

## 📅 MONTH 2 (Days 31-60) - Strategic Features

### Choose 2-3 from this list:

#### 1. Model Performance Dashboard 📊
**Effort:** 4-6 hours  
**Value:** HIGH

Show users which models are fastest/most reliable:
- Response time per model (avg, median, p95)
- Success/failure rates
- User ratings (5 stars)
- "Best model for you" recommendation

**Location:** Settings → AI Model → Performance Stats

---

#### 2. Vision Model Priority for OCR 📸
**Effort:** 20 minutes  
**Value:** MEDIUM

```dart
// In lib/services/ocr_service.dart
const visionModels = [
  'or_nemotron_super_vl',
  'or_qwen38',
  'gemini_flash',
];

// Try vision models first for receipt scanning
```

---

#### 3. Proactive AI Nudges 🔔
**Effort:** 2-3 hours  
**Value:** HIGH (engagement)

Daily background check:
- Subscription due in 3 days? → Notify
- Spending 40% higher than usual? → Notify
- Goal achieved? → Celebrate

**Implementation:**
```dart
// In lib/services/ai_coach_service.dart
static Future<void> checkForNudges() async {
  // Run daily at 8 PM
  final subscriptions = await _getUpcomingSubscriptions();
  if (subscriptions.isNotEmpty) {
    await _sendNotification(
      'Your Netflix ₱299 is due in 3 days. Review subscriptions?',
      payload: 'open_recurring',
    );
  }
}
```

---

#### 4. Smart Model Selection (Task-Based) 🎯
**Effort:** 2-3 hours  
**Value:** MEDIUM

```dart
enum TaskType {
  receiptScan,    // → Vision models
  voiceCommand,   // → Fast models
  complexAnalysis, // → Quality models
}

String selectModelForTask(TaskType task) {
  switch (task) {
    case TaskType.receiptScan:
      return ['or_qwen38', 'or_nemotron_super_vl', 'gemini_flash']
        .firstWhere(hasKey);
    // ...
  }
}
```

---

#### 5. Peso Phase 2 (Voice + Achievements) 🤖
**Effort:** 1 day (see `.agents/tasks/peso-phase2-plan.md`)  
**Value:** MEDIUM (polish)

- 31 context-aware voice variations
- 10 new achievement badges
- Bottom sheet unlock celebrations

---

## 📅 MONTH 3-6 (Long-term) - Polish & Publish

### Month 3: Testing & Refinement
- Beta test with 10-20 Filipino users
- Fix bugs reported
- Polish UI based on feedback
- Write comprehensive user manual

### Month 4: Prepare for Play Store
- App screenshots (8 required)
- Feature graphic (1024x500)
- Privacy policy
- Terms of service
- App description
- Content rating

### Month 5: Play Store Submission
- Create developer account ($25)
- Upload AAB (not APK)
- Submit for review (1-2 weeks)
- Respond to review feedback

### Month 6: Launch & Marketing
- Launch announcement (Reddit, LinkedIn, Twitter)
- Demo video (2-3 min)
- Blog post
- Submit to Flutter Showcase
- Track metrics (installs, ratings, crashes)

---

## 🎯 DECISION POINTS

Before starting each phase, ask yourself:

### After Week 1:
❓ "Do I want to continue developing SmartSpend, or am I satisfied with capstone completion?"
- **Continue** → Proceed to Week 2
- **Pause** → Take longer break, return when inspired
- **Stop** → Archive project, move to next thing (totally valid!)

### After Month 2:
❓ "Should I publish to Play Store, or keep it open-source only?"
- **Play Store** → Proceed to Month 3-6 plan
- **Open-source only** → Focus on documentation, demos, portfolio
- **Commercialize** → Research freemium (v4.0.0 plan in FEATURE_BACKLOG.md)

### After Month 6:
❓ "Should I maintain SmartSpend long-term, or sunset it?"
- **Maintain** → Monthly updates, user support, new features
- **Sunset** → Archive gracefully, make final release, write retrospective
- **Hand off** → Find maintainer, document everything, transfer ownership

---

## 🚦 STOPPING POINTS (When to Pause)

Don't feel obligated to complete everything! Here are natural stopping points:

### ✅ Stopping Point 1: After Week 1
**What you have:**
- v3.3.9 on GitHub
- Safe-to-Spend feature
- Updated docs
- One quick win

**Status:** Fully functional, production-ready, defendable portfolio piece

**Good if:** You want to move to other projects, job hunting, or just rest

---

### ✅ Stopping Point 2: After Month 2
**What you have:**
- All of above
- Price Intelligence
- Rate limit handling
- Performance dashboard
- Tests written

**Status:** Feature-rich, competitive with paid apps

**Good if:** You're satisfied with features, don't want Play Store complexity

---

### ✅ Stopping Point 3: After Month 6
**What you have:**
- All of above
- Published to Play Store
- User base growing
- Professional portfolio showcase

**Status:** Published app, real users, press coverage

**Good if:** This is your flagship project, want long-term maintenance

---

## 📊 SUCCESS METRICS (How to Know You're Done)

### Week 1 Success:
- [ ] v3.3.9 on GitHub ✅
- [ ] 18 models confirmed working
- [ ] Safe-to-Spend feature live
- [ ] README updated

### Month 2 Success:
- [ ] 3+ new features shipped
- [ ] Rate limit handling working
- [ ] Tests passing (flutter test)
- [ ] Zero crashes in local testing

### Month 6 Success:
- [ ] App on Play Store
- [ ] 100+ downloads
- [ ] 4.0+ star rating
- [ ] Featured in 1+ tech blog

### Personal Success:
- [ ] Proud to show this in job interviews
- [ ] Learned new skills
- [ ] Enjoyed the process (most important!)

---

## 💡 TIPS FOR STAYING MOTIVATED

1. **Set tiny goals** - "Today I'll just add Sentry" (not "Today I'll refactor everything")
2. **Ship often** - Small releases feel better than one huge update
3. **Take breaks** - Code in 2-hour blocks, not 8-hour marathons
4. **Celebrate wins** - Tweet when you ship, even small stuff
5. **Ask for help** - Post in r/FlutterDev when stuck
6. **Know when to stop** - Finished is better than perfect

---

## 🎓 WHAT IF I JUST WANT TO STOP NOW?

**That's totally valid!** You defended, you passed, you built something impressive.

**If you stop now, do this:**
1. Write a final README with:
   - "This was my capstone project (PASSED)"
   - List of 50+ features
   - Screenshots
   - "Not actively maintained, but functional"
2. Make one last commit: `docs: Archive project after successful defense`
3. Pin repo on GitHub profile
4. Write a blog post: "I built a Filipino AI finance app and defended it"
5. Move on with pride! 🎉

SmartSpend is already more complete than 95% of student projects.

---

## 📞 WHEN TO ASK FOR HELP

**Ask me (Kiro) when:**
- Stuck on implementation
- Need code review
- Deciding between options
- Planning next phase

**Ask community when:**
- Flutter-specific bugs (r/FlutterDev, StackOverflow)
- Design feedback (r/androidapps, r/Philippines)
- Firebase issues (Firebase Discord)
- OpenRouter problems (OpenRouter Discord)

**Don't ask when:**
- Feeling overwhelmed (take a break instead)
- Comparing to others (your project is already impressive)
- Doubting yourself (you defended successfully!)

---

## 🏁 FINAL RECOMMENDATION

**Week 1 Plan (Right Now):**

**Day 1-2:** REST (seriously!)  
**Day 3:** Push v3.3.9 (15 min) ← Do this first, blocks everything  
**Day 4:** Safe-to-Spend feature (4-6 hours) ← Biggest impact  
**Day 5:** Update README (1 hour)  
**Day 6-7:** Add Sentry (1 hour) OR just rest more

**Total time commitment: ~8-10 hours over 7 days**

After Week 1, you'll have:
- ✅ Real v3.3.9 on GitHub
- ✅ Competitive feature (Safe-to-Spend)
- ✅ Error tracking (Sentry)
- ✅ Updated docs

**Then decide:** Continue to Month 2? Or stop here and call it complete?

**No pressure either way.** You already succeeded. Everything from here is bonus.

---

**Author:** Kiro AI  
**Date:** November 20, 2026  
**Status:** Ready to Execute  
**Your Move:** Take 2 days off, then start Day 3! 🚀
