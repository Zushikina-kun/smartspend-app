import 'package:shared_preferences/shared_preferences.dart';

/// ProService — single source of truth for SmartSpend Pro entitlement.
///
/// CURRENT STATUS (v3.x): Everyone is Pro. No gates are active yet.
/// This service is the foundation for v4.0 freemium implementation.
///
/// HOW IT WILL WORK in v4.0:
/// 1. RevenueCat SDK (`purchases_flutter`) verifies purchase server-side.
/// 2. This service caches the entitlement in SharedPreferences with 24h TTL.
/// 3. On cold start, cached value is used immediately (no delay), then
///    RevenueCat is queried async and cache is updated.
/// 4. On network failure, last known state is used (grace period).
/// 5. `ProGate` widget wraps any Pro-only feature — shows locked teaser if not Pro.
///
/// BUILD FLAVORS:
/// - APP_FLAVOR=dev  (local testing, `flutter run --dart-define=APP_FLAVOR=dev`)
///   → always returns isPro=true so development is never blocked by gates
/// - APP_FLAVOR=prod (Play Store / GitHub CI release builds)
///   → reads real entitlement from RevenueCat (v4.0+) or falls back to true
///     until gates are actually implemented
///
/// PRICING (planned for v4.0, Play Store):
/// - Monthly:  ₱59/month  (~₱50 net after Google Play 15% fee)
/// - Yearly:   ₱299/year  (~₱254 net) — 7-day free trial, push as default
/// - Lifetime: ₱799 once  (~₱679 net) — best for PH one-time preference
class ProService {
  ProService._();

  // ── Compile-time flavor detection ─────────────────────────────────────────
  // Set via: flutter run --dart-define=APP_FLAVOR=dev
  // CI sets:  flutter build apk --dart-define=APP_FLAVOR=prod
  // If not set, defaults to 'dev' (safe — no gates on unknown builds).
  static const _flavor =
      String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');

  static bool get isDev => _flavor == 'dev';
  static bool get isProd => _flavor == 'prod';

  // ── Pro status ─────────────────────────────────────────────────────────────
  // In v3.x: always true. In v4.0: set by RevenueCat entitlement check.
  static bool _isPro = true;

  /// Whether the current user has SmartSpend Pro.
  /// v3.x: always true (no gates implemented yet).
  /// v4.0: real entitlement from RevenueCat, cached locally.
  static bool get isPro => _isPro;

  /// Initialize Pro status. Call once in main() before runApp().
  /// v3.x: no-op (everyone is Pro).
  /// v4.0: loads cached entitlement, then verifies async with RevenueCat.
  static Future<void> init() async {
    if (isDev) {
      // Dev builds: always Pro, skip any network check
      _isPro = true;
      return;
    }

    // prod / unrecognized flavor:
    // v3.x — still true (no RevenueCat integration yet)
    // v4.0 — replace this block with RevenueCat.getCustomerInfo() call
    _isPro = true;

    // ── v4.0 STUB (uncomment when RevenueCat is integrated) ───────────────
    // try {
    //   final prefs = await SharedPreferences.getInstance();
    //   _isPro = prefs.getBool('is_pro_cached') ?? false; // fast path
    //   // Async verify — do not await here so app starts fast
    //   _verifyEntitlementAsync(prefs);
    // } catch (_) {
    //   _isPro = false; // safe default
    // }
  }

  // ── v4.0 STUB: async RevenueCat verification ──────────────────────────────
  // static Future<void> _verifyEntitlementAsync(SharedPreferences prefs) async {
  //   try {
  //     final info = await Purchases.getCustomerInfo();
  //     _isPro = info.entitlements.active.containsKey('pro');
  //     await prefs.setBool('is_pro_cached', _isPro);
  //   } catch (_) {
  //     // Network unavailable — grace period: keep cached value
  //   }
  // }

  /// Call after a successful purchase to refresh Pro status immediately.
  /// v4.0: re-queries RevenueCat. v3.x: no-op.
  static Future<void> refresh() async {
    // v4.0: final info = await Purchases.getCustomerInfo();
    // v4.0: _isPro = info.entitlements.active.containsKey('pro');
  }

  /// Whether a specific feature is available to the current user.
  /// v3.x: always true (everything unlocked).
  /// v4.0: checks ProFeature enum against current entitlement.
  static bool canUse(ProFeature feature) {
    if (_isPro) return true;
    return _freeFeatures.contains(feature);
  }

  // ── Free tier feature set (used in v4.0 when isPro=false) ─────────────────
  // Any ProFeature NOT in this set is gated behind Pro.
  static const _freeFeatures = <ProFeature>{
    // Core logging — always free
    ProFeature.manualExpenseEntry,
    ProFeature.editDeleteExpenses,
    ProFeature.transactionsList,
    ProFeature.basicSearch,
    ProFeature.categoryFilter,
    ProFeature.periodFilterBasic, // Today, This Week, This Month only

    // AI — basic text chat, limited messages
    ProFeature.aiTextChat, // subject to free daily limit (30 msg/day)

    // Analytics — current month only
    ProFeature.fhsCurrentScore, // ALWAYS free — our #1 differentiator
    ProFeature.fhsExplanation,  // ALWAYS free
    ProFeature.pieChartCurrentMonth,
    ProFeature.fiftyThirtyTwentyBasic,
    ProFeature.monthlyTotal,

    // Basic limits
    ProFeature.budgetsUpToFive,
    ProFeature.goalsUpToThree,
    ProFeature.recurringUpToThree,
    ProFeature.debtsUpToTwo,
    ProFeature.singleWallet, // Cash on Hand only

    // Utility
    ProFeature.csvExportCurrentMonth,
    ProFeature.chatHistorySevenDays,
    ProFeature.pinLock,
    ProFeature.threeThemes,
    ProFeature.tenBadges,
    ProFeature.threeDailyQuests,
    ProFeature.basicCloudSync,   // expenses + budgets + goals — basic sync free
    ProFeature.profileAccount,
    ProFeature.helpAboutDemo,
    ProFeature.offlineMode,      // ALWAYS free — core promise
  };
}

/// Every gateable feature in the app.
/// Features NOT in ProService._freeFeatures require Pro.
enum ProFeature {
  // ── Always free (core) ──────────────────────────────────────────────────
  manualExpenseEntry,
  editDeleteExpenses,
  transactionsList,
  basicSearch,
  categoryFilter,
  periodFilterBasic,
  aiTextChat,
  fhsCurrentScore,
  fhsExplanation,
  pieChartCurrentMonth,
  fiftyThirtyTwentyBasic,
  monthlyTotal,
  budgetsUpToFive,
  goalsUpToThree,
  recurringUpToThree,
  debtsUpToTwo,
  singleWallet,
  csvExportCurrentMonth,
  chatHistorySevenDays,
  pinLock,
  threeThemes,
  tenBadges,
  threeDailyQuests,
  basicCloudSync,
  profileAccount,
  helpAboutDemo,
  offlineMode,

  // ── Pro: AI ─────────────────────────────────────────────────────────────
  aiMessagesExtra,        // 150/day vs 30/day
  voiceInput,
  screenshotImport,
  batchScreenshotImport,
  bankPasteImport,
  barcodeScanner,
  aiSessionSummaryCard,
  relogHelperSheet,
  aiFinancialAdviceTier,
  localLlmPrivateMode,    // unique — run AI on your own PC

  // ── Pro: Analytics ───────────────────────────────────────────────────────
  allPeriodFilters,       // All Time, This Year, Payday Cycle, Pick Month, Custom, Logged Today
  monthlyBarChart,
  dailyTrendChart,
  dayOfWeekHeatmap,
  fhsScoreHistory,
  fhsComponentHistory,
  fiftyThirtyTwentyCustomCategories,
  periodComparison,
  moodSpendCorrelation,
  spendingForecast,
  smallPurchasesClustering,
  marketInsights,
  aiMonthlySummary,
  aiFinancialAdviceAnalytics,
  analyticsQuickJump,
  dtiEmergencyFundMilestones,

  // ── Pro: Wallets & Income ────────────────────────────────────────────────
  multipleWallets,
  walletHistory,
  walletTransfers,
  safeToSpend,
  walletAutoDeduct,
  recurringIncome,
  windfallFlag,
  incomeHistory,
  fullCloudSync,          // wallets, income, chat, all tables

  // ── Pro: Unlimited ───────────────────────────────────────────────────────
  unlimitedBudgets,
  unlimitedGoals,
  unlimitedRecurring,
  unlimitedDebts,

  // ── Pro: Filipino features ───────────────────────────────────────────────
  paluwagan,
  insurance,
  installmentPlans,
  billCalendar,
  logDueBills,
  pcaCalculator,
  debtPayoffCalculator,
  birTaxBreakdown,
  bankComparison,

  // ── Pro: Data ────────────────────────────────────────────────────────────
  unlimitedCustomCategories,
  autoCategorizationRules,
  dataQuality,
  merchantMerge,
  batchManualEntry,
  fullCsvExport,
  backupRestore,
  fullChatHistory,

  // ── Pro: UI / Gamification ───────────────────────────────────────────────
  allThemes,
  allBadges,
  fullDailyQuestPool,
  weeklyMonthlyChallenge,
  fhsCertificate,
  biometricLock,
  compactMode,
  experiencePresets,
  sortGroupTransactions,  // all 7 sort keys + 5 group-by options
}
