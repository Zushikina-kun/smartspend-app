import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'db_service.dart';
import 'app_config.dart';

/// Represents an action the AI wants to perform on the app's data
class AIAction {
  final String type;
  final Map<String, dynamic> params;
  AIAction({required this.type, required this.params});
}

class AIChatService {
  static String get _groqKey => AppConfig.groqApiKey;
  static String get _groqUrl => AppConfig.groqBaseUrl;

  // D2 mitigation: daily request cap to protect the shared API key
  static const _dailyLimit = 60;
  static const _prefKeyCount = 'ai_chat_count';
  static const _prefKeyDate = 'ai_chat_date';

  static Future<bool> _checkAndIncrementLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_prefKeyDate) ?? '';
    int count = savedDate == today ? (prefs.getInt(_prefKeyCount) ?? 0) : 0;
    if (count >= _dailyLimit) return false;
    await prefs.setString(_prefKeyDate, today);
    await prefs.setInt(_prefKeyCount, count + 1);
    return true;
  }

  /// Returns remaining AI messages for today (for display purposes)
  static Future<int> getRemainingMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_prefKeyDate) ?? '';
    final count = savedDate == today ? (prefs.getInt(_prefKeyCount) ?? 0) : 0;
    return (_dailyLimit - count).clamp(0, _dailyLimit);
  }

  static String _fullContext = "";
  static final List<Map<String, dynamic>> _history = [];
  static int _messagesSinceLastSummary = 0;
  // User-defined categorization rules cache — refreshed on context load
  static List<Map<String, dynamic>> _userRules = [];

  // ── SESSION ACTION LOG — for in-prompt duplicate guardrail ───────────────
  // Tracks (itemName_amount_date) fingerprints for every log_expense ACTION
  // fired this session so the system prompt can warn the model.
  static final List<String> _sessionActionLog = [];

  /// Record that a log_expense action was fired (called by ai_screen executor).
  static void recordFiredAction(String itemName, double amount, String date) {
    final key =
        '${itemName.toLowerCase().trim()}_${amount.toStringAsFixed(0)}_${date.substring(0, 10)}';
    if (!_sessionActionLog.contains(key)) _sessionActionLog.add(key);
    // Keep bounded — only last 20 fingerprints needed
    if (_sessionActionLog.length > 20) _sessionActionLog.removeAt(0);
  }

  /// Build a compact fingerprint string for the system-prompt guardrail note.
  static String _buildRecentFingerprints() {
    if (_sessionActionLog.isEmpty) return '';
    // Show up to last 10 to keep the prompt lean
    return _sessionActionLog.reversed.take(10).join(', ');
  }

  /// Initialize message counter from DB chat history count
  static Future<void> _initMessageCounter() async {
    if (_messagesSinceLastSummary > 0) return; // already initialized
    try {
      final history = await DBService.getChatHistory(limit: 200);
      final latestSummary = await DBService.getLatestConversationSummary();
      if (latestSummary != null) {
        // Count messages since last summary
        _messagesSinceLastSummary = history.length % 10;
      } else {
        _messagesSinceLastSummary = history.length % 10;
      }
    } catch (_) {}
  }

  /// Build expense summary — recent 10 detailed + older summarized by category
  /// Kept compact to stay within the 8192 token limit of llama-3.1-8b-instant
  static String _buildExpenseSummary(List<Map<String, dynamic>> expenses) {
    if (expenses.isEmpty) return "No expenses recorded yet.";

    // Recent 10 — detailed
    final recent = expenses.take(10).map((e) {
      final isWant = (e['is_want'] as int? ?? 0) == 1;
      // Cap notes to 30 chars to save tokens
      final notes = (e['notes'] as String?) ?? '';
      final notesShort = notes.isNotEmpty &&
              !notes.startsWith('Logged') &&
              !notes.startsWith('Imported')
          ? ' (${notes.length > 30 ? notes.substring(0, 30) : notes})'
          : '';
      return "- ${e['item_name'] ?? e['category']}: ₱${e['amount']} ${(e['date'] as String).substring(5, 10)} [${isWant ? 'W' : 'N'}]$notesShort";
    }).join("\n");

    // Older entries — summarized by category only
    final older = expenses.skip(10).toList();
    if (older.isEmpty) return recent;

    final catTotals = <String, double>{};
    for (final e in older) {
      final cat = e['category'] as String? ?? 'Others';
      catTotals[cat] = (catTotals[cat] ?? 0) + (e['amount'] as num);
    }
    final summary = catTotals.entries
        .map((e) => "- ${e.key}: ₱${e.value.toStringAsFixed(0)}")
        .join("\n");

    return "$recent\n\nOlder (${older.length} more by category):\n$summary";
  }

  static void setFullContext({
    required List<Map<String, dynamic>> expenses,
    required List<Map<String, dynamic>> budgets,
    required double monthlyIncome,
    required int healthScore,
    required double totalSpent,
    String accountType = 'employed',
    List<Map<String, dynamic>> goals = const [],
    List<Map<String, dynamic>> debts = const [],
    List<Map<String, dynamic>> recurring = const [],
    List<Map<String, dynamic>> installments = const [],
    List<String> customCategories = const [],
    List<Map<String, dynamic>> wallets = const [],
    int? todayMoodScore,
    String? todayMoodNote,
    String quizChallenge = '',
    double allTimeTotal = 0,
    Map<String, double> monthlyTotals = const {},
    List<Map<String, dynamic>> fhsBreakdown = const [],
    List<Map<String, dynamic>> insurancePolicies = const [],
    // Gap-awareness data — from StartupAlertsService
    int gapPenaltyDays = 0,
    int gapCleanDays = 0,
  }) {
    // Refresh user-defined categorization rules cache
    DBService.getCategoryRules().then((rules) => _userRules = rules);
    final expenseSummary = expenses.isEmpty
        ? "No expenses recorded yet."
        : _buildExpenseSummary(expenses);

    // Want vs Need summary
    double wantTotal = 0, needTotal = 0;
    for (final e in expenses) {
      final isWant = (e['is_want'] as int? ?? 0) == 1;
      final amt = (e['amount'] as num?)?.toDouble() ?? 0;
      if (isWant)
        wantTotal += amt;
      else
        needTotal += amt;
    }
    final wantNeedSummary = (wantTotal + needTotal) > 0
        ? "\nWant vs Need: ₱${wantTotal.toStringAsFixed(0)} Wants (${(wantTotal / (wantTotal + needTotal) * 100).toStringAsFixed(0)}%) · ₱${needTotal.toStringAsFixed(0)} Needs (${(needTotal / (wantTotal + needTotal) * 100).toStringAsFixed(0)}%)"
        : "";

    final budgetSummary = budgets.isEmpty
        ? "No budgets set."
        : budgets
            .map((b) =>
                "- ${b['category']}: budget ₱${b['budget']}, spent ₱${b['spent']}")
            .join("\n");

    final goalsSummary = goals.isEmpty
        ? ""
        : "\n\nSavings goals:\n" +
            goals
                .take(5)
                .map((g) =>
                    "- ${g['name']}: ₱${g['current_amount']}/${g['target_amount']} saved")
                .join("\n");

    final debtsSummary = debts.isEmpty
        ? ""
        : "\n\nDebts & lending:\n" +
            debts
                .take(5)
                .map((d) =>
                    "- ${d['type'] == 'owe' ? 'Owe' : 'Lent'} ${d['person']}: ₱${(d['amount'] as num) - (d['paid_amount'] as num)} remaining")
                .join("\n");

    final recurringSummary = recurring.isEmpty
        ? ""
        : "\n\nRecurring transactions:\n" +
            recurring.take(8).map((r) {
              final isExp = (r['is_expense'] as int? ?? 1) == 1;
              final next = r['next_date'] as String? ?? '';
              final diff = next.isNotEmpty
                  ? DateTime.parse(next).difference(DateTime.now()).inDays
                  : 0;
              final label = diff < 0
                  ? 'OVERDUE'
                  : diff == 0
                      ? 'due today'
                      : 'in $diff days';
              final amt = (r['amount'] as num).toDouble();
              final amtStr = amt == amt.truncateToDouble()
                  ? amt.toStringAsFixed(0)
                  : amt.toStringAsFixed(2);
              return "- ${isExp ? 'Bill' : 'Income'}: ${r['title']} ₱$amtStr ${r['frequency']} ($label)";
            }).join("\n");

    final installmentsSummary = installments.isEmpty
        ? ""
        : "\n\nInstallments:\n" +
            installments.take(5).map((i) {
              final total = (i['total_amount'] as num).toDouble();
              final monthly = (i['monthly_payment'] as num).toDouble();
              final paid = (i['months_paid'] as int? ?? 0);
              final totalMonths = (i['months_total'] as int? ?? 1);
              final remaining = (total - monthly * paid).clamp(0.0, total);
              return "- ${i['name']}: ₱${remaining.toStringAsFixed(0)} remaining (₱${monthly.toStringAsFixed(0)}/mo, $paid/$totalMonths months paid)";
            }).join("\n");

    // Wallet balances summary
    final walletsSummary = wallets.isEmpty
        ? ""
        : "\n\nWallet balances (cash on hand / e-wallets / banks):\n" +
            wallets.map((w) {
              final bal = (w['balance'] as num).toDouble();
              return "- ${w['icon'] ?? '💵'} ${w['name']}: ₱${bal.toStringAsFixed(2)}";
            }).join("\n") +
            "\nTotal liquid: ₱${wallets.fold<double>(0, (s, w) => s + (w['balance'] as num)).toStringAsFixed(2)}";

    // Build per-month spending summary — last 3 months only to save tokens
    final sortedMonths = (monthlyTotals.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)))
        .take(3)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final monthlyTotalsSummary = sortedMonths.isEmpty
        ? ""
        : "\nMonthly totals (last 3 months):\n" +
            sortedMonths
                .map((e) => "  ${e.key}: ₱${e.value.toStringAsFixed(0)}")
                .join("\n");

    // Build FHS breakdown summary for AI explanation
    final fhsSummary = fhsBreakdown.isEmpty
        ? ""
        : "\n\nFHS Breakdown (${healthScore}/100):\n" +
            fhsBreakdown
                .map((b) =>
                    "- ${b['component'] ?? 'unknown'}: ${(b['points'] as num?)?.toStringAsFixed(1) ?? '?'} pts — ${b['reason'] ?? ''}")
                .join("\n");

    // Gap-awareness summary — helps AI understand why the score looks low
    final gapSummary = (gapPenaltyDays > 0 || gapCleanDays > 0)
        ? '\n\nLogging gaps this month: ${gapPenaltyDays > 0 ? '$gapPenaltyDays unlogged-but-spent days (FHS penalty applied)' : ''}${gapPenaltyDays > 0 && gapCleanDays > 0 ? '; ' : ''}${gapCleanDays > 0 ? '$gapCleanDays confirmed no-spend days (FHS bonus applied)' : ''}'
        : '';

    // Build insurance summary for AI context
    final insuranceSummary = insurancePolicies.isEmpty
        ? ""
        : "\n\nInsurance & Contributions:\n" +
            insurancePolicies.take(5).map((p) {
              final name = p['name'] as String? ?? '';
              final premium = (p['premium_amount'] as num?)?.toDouble() ?? 0;
              final freq = p['frequency'] as String? ?? 'monthly';
              final nextDue = p['next_due_date'] as String? ?? '';
              return "- $name: ₱${premium.toStringAsFixed(0)}/$freq${nextDue.isNotEmpty ? ' (due: $nextDue)' : ''}";
            }).join("\n");

    _fullContext = """
Account type: $accountType | Income: ${monthlyIncome > 0 ? '₱${monthlyIncome.toStringAsFixed(0)}/mo${monthlyIncome < 1000 ? ' ⚠️ (looks incorrect — ask user to update)' : ''}' : 'Not set'} | Score: $healthScore/100
This month spent: ₱${totalSpent.toStringAsFixed(0)}$wantNeedSummary
${allTimeTotal > 0 ? 'All-time: ₱${allTimeTotal.toStringAsFixed(0)}' : ''}$monthlyTotalsSummary
${quizChallenge.isNotEmpty ? 'Challenge: $quizChallenge' : ''}
${todayMoodScore != null ? 'Mood: $todayMoodScore/5${todayMoodScore <= 2 ? ' (low — be supportive)' : todayMoodScore >= 4 ? ' (good)' : ''}' : ''}
${customCategories.isNotEmpty ? 'Custom cats: ${customCategories.join(', ')}' : ''}
$walletsSummary
Expenses (if not listed here, it does not exist in DB):
$expenseSummary

Budgets: $budgetSummary$goalsSummary$debtsSummary$recurringSummary$installmentsSummary$fhsSummary$gapSummary$insuranceSummary

Philippine Financial Reference (use when relevant):
SSS contributions (2024): 14% of MSC — Employee 4.5%, Employer 9.5%. Brackets: ₱4K-₱30K MSC range. Min: ₱560/mo employee. Max: ₱1,350/mo employee.
PhilHealth: 5% of basic salary (50/50 employer/employee). Min ₱500/mo total. Max ₱5,000/mo total.
Pag-IBIG: Employee 2%, Employer 2% of monthly salary. Max employee contribution ₱200/mo. MP2: 6-9% annual dividend, tax-free.
BIR TRAIN Law tax brackets (annual): ₱250K exempt; ₱250K-400K: 15%; ₱400K-800K: 20%; ₱800K-2M: 25%; ₱2M-8M: 30%; above ₱8M: 35%.
PH Digital Banks high-yield: GoTyme 5%/yr, Tonik 4%/yr, Maya 3.5%/yr, Seabank 3%/yr. All PDIC-insured up to ₱500K.
BSP Open Finance (OFxPERA): live since July 2025, UnionBank first participant. Brankas API available for PH bank integration.""";
  }

  /// Normalize category names to match our standard list.
  /// Checks user-defined rules first, then falls back to built-in keyword matching.
  /// Comprehensive — covers Filipino food brands, transport terms, etc.
  /// Public wrapper for category suggestion — used by Add/Edit Expense screens
  /// for real-time category auto-suggest as user types the item name.
  static String suggestCategory(String text) => _normalizeCategory(text);

  static String _normalizeCategory(String raw) {
    // 1. Check user-defined rules first (highest priority)
    if (_userRules.isNotEmpty) {
      final lower = raw.toLowerCase().trim();
      for (final r in _userRules) {
        final kw = (r['keyword'] as String).toLowerCase();
        if (lower.contains(kw)) return r['category'] as String;
      }
    }
    // 2. Fall back to built-in keyword matching — comprehensive Filipino + general
    final lower = raw.toLowerCase().trim();

    // ── FOOD ──────────────────────────────────────────────────────────────────
    // Check food delivery apps BEFORE transportation (grabfood contains 'grab')
    if (lower.contains('grabfood') ||
        lower.contains('grab food') ||
        lower.contains('foodpanda') ||
        lower.contains('food panda') ||
        lower.contains('shopee food') ||
        lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('meal') ||
        lower.contains('grocery') ||
        lower.contains('groceries') ||
        lower.contains('restaurant') ||
        lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('breakfast') ||
        lower.contains('snack') ||
        lower.contains('coffee') ||
        lower.contains('drink') ||
        lower.contains('beverage') ||
        lower.contains('juice') ||
        lower.contains('soda') ||
        lower.contains('water') ||
        lower.contains('milk') ||
        lower.contains('bread') ||
        lower.contains('cake') ||
        lower.contains('pastry') ||
        lower.contains('biscuit') ||
        lower.contains('cookie') ||
        lower.contains('candy') ||
        lower.contains('chocolate') ||
        lower.contains('chips') ||
        lower.contains('popcorn') ||
        lower.contains('ice cream') ||
        lower.contains('icecream') ||
        lower.contains('noodle') ||
        lower.contains('instant') ||
        lower.contains('pizza') ||
        lower.contains('burger') ||
        lower.contains('fries') ||
        lower.contains('hotdog') ||
        lower.contains('sandwich') ||
        lower.contains('shawarma') ||
        lower.contains('siomai') ||
        lower.contains('dimsum') ||
        lower.contains('fishball') ||
        lower.contains('kwek') ||
        lower.contains('isaw') ||
        lower.contains('balut') ||
        lower.contains('taho') ||
        lower.contains('halo-halo') ||
        lower.contains('buko') ||
        lower.contains('sago') ||
        lower.contains('gulaman') ||
        lower.contains('pansit') ||
        lower.contains('pancit') ||
        lower.contains('adobo') ||
        lower.contains('sinigang') ||
        lower.contains('tinola') ||
        lower.contains('nilaga') ||
        lower.contains('lechon') ||
        lower.contains('liempo') ||
        lower.contains('sisig') ||
        lower.contains('silog') ||
        lower.contains('lomi') ||
        lower.contains('lugaw') ||
        lower.contains('goto') ||
        lower.contains('champorado') ||
        lower.contains('sting') ||
        lower.contains('cobra') ||
        lower.contains('red bull') ||
        lower.contains('energy drink') ||
        lower.contains('jollibee') ||
        lower.contains('mcdonald') ||
        lower.contains('mcdo') ||
        lower.contains('kfc') ||
        lower.contains('chowking') ||
        lower.contains('mang inasal') ||
        lower.contains('7-eleven') ||
        lower.contains('711') ||
        lower.contains('ministop') ||
        lower.contains('family mart') ||
        lower.contains('nestea') ||
        lower.contains('c2') ||
        lower.contains('greenwich') ||
        lower.contains('yellow cab') ||
        lower.contains('shakey') ||
        lower.contains('goldilocks') ||
        lower.contains('red ribbon') ||
        lower.contains('starbucks') ||
        lower.contains('dunkin') ||
        lower.contains('rice') ||
        lower.contains('ulam') ||
        lower.contains('merienda') ||
        lower.contains('kain') ||
        lower.contains('pagkain') ||
        lower.contains('supermarket') ||
        lower.contains('wet market')) return 'Food';

    // ── TRANSPORTATION ────────────────────────────────────────────────────────
    if (lower.contains('transport') ||
        lower.contains('travel') ||
        lower.contains('ride') ||
        lower.contains('grab') ||
        lower.contains('angkas') ||
        lower.contains('lalamove') ||
        lower.contains('commute') ||
        lower.contains('fare') ||
        lower.contains('jeep') ||
        lower.contains('bus') ||
        lower.contains('mrt') ||
        lower.contains('lrt') ||
        lower.contains('taxi') ||
        lower.contains('tricycle') ||
        lower.contains('trike') ||
        lower.contains('pedicab') ||
        lower.contains('uv express') ||
        lower.contains('p2p') ||
        lower.contains('tnvs') ||
        lower.contains('gas') ||
        lower.contains('fuel') ||
        lower.contains('toll') ||
        lower.contains('parking') ||
        lower.contains('byahe') ||
        lower.contains('sakay') ||
        lower.contains('pasada')) return 'Transportation';

    // ── BILLS ─────────────────────────────────────────────────────────────────
    if (lower.contains('bill') ||
        lower.contains('utility') ||
        lower.contains('electric') ||
        lower.contains('meralco') ||
        lower.contains('internet') ||
        lower.contains('wifi') ||
        lower.contains('pldt') ||
        lower.contains('globe') ||
        lower.contains('smart') ||
        lower.contains('dito') ||
        lower.contains('rent') ||
        lower.contains('netflix') ||
        lower.contains('spotify') ||
        lower.contains('subscription') ||
        lower.contains('insurance') ||
        lower.contains('loan') ||
        lower.contains('mortgage') ||
        lower.contains('sss') ||
        lower.contains('philhealth') ||
        lower.contains('pagibig') ||
        lower.contains('pag-ibig') ||
        lower.contains('bayad')) return 'Bills';

    // ── SHOPPING ──────────────────────────────────────────────────────────────
    if (lower.contains('shop') ||
        lower.contains('cloth') ||
        lower.contains('shirt') ||
        lower.contains('shoes') ||
        lower.contains('bag') ||
        lower.contains('mall') ||
        lower.contains('lazada') ||
        lower.contains('shopee') ||
        lower.contains('online') ||
        lower.contains('gadget') ||
        lower.contains('appliance') ||
        lower.contains('ukay') ||
        lower.contains('tiangge') ||
        lower.contains('accessories') ||
        lower.contains('cosmetics') ||
        lower.contains('makeup') ||
        lower.contains('skincare') ||
        lower.contains('purchase')) return 'Shopping';

    // ── ENTERTAINMENT ─────────────────────────────────────────────────────────
    if (lower.contains('entertain') ||
        lower.contains('movie') ||
        lower.contains('cinema') ||
        lower.contains('concert') ||
        lower.contains('game') ||
        lower.contains('gaming') ||
        lower.contains('arcade') ||
        lower.contains('bar') ||
        lower.contains('videoke') ||
        lower.contains('karaoke') ||
        lower.contains('event') ||
        lower.contains('ticket') ||
        lower.contains('resort') ||
        lower.contains('vacation')) return 'Entertainment';

    // ── HEALTH ────────────────────────────────────────────────────────────────
    if (lower.contains('health') ||
        lower.contains('medical') ||
        lower.contains('medicine') ||
        lower.contains('doctor') ||
        lower.contains('hospital') ||
        lower.contains('clinic') ||
        lower.contains('pharmacy') ||
        lower.contains('vitamins') ||
        lower.contains('supplement') ||
        lower.contains('dental') ||
        lower.contains('dentist') ||
        lower.contains('glasses') ||
        lower.contains('eyeglasses') ||
        lower.contains('gamot') ||
        lower.contains('botika') ||
        lower.contains('mercury drug') ||
        lower.contains('watsons') ||
        lower.contains('rose pharmacy')) return 'Health';

    // ── EDUCATION ─────────────────────────────────────────────────────────────
    if (lower.contains('edu') ||
        lower.contains('school') ||
        lower.contains('tuition') ||
        lower.contains('book') ||
        lower.contains('notebook') ||
        lower.contains('supplies') ||
        lower.contains('course') ||
        lower.contains('training') ||
        lower.contains('seminar') ||
        lower.contains('uniform')) return 'Education';

    // ── GAMING ────────────────────────────────────────────────────────────────
    if (lower.contains('game') ||
        lower.contains('gaming') ||
        lower.contains('steam') ||
        lower.contains('mobile legend') ||
        lower.contains('mlbb') ||
        lower.contains('codm') ||
        lower.contains('call of duty') ||
        lower.contains('roblox') ||
        lower.contains('minecraft') ||
        lower.contains('genshin') ||
        lower.contains('valorant') ||
        lower.contains('dota') ||
        lower.contains('lol') ||
        lower.contains('league of legend') ||
        lower.contains('top-up') ||
        lower.contains('topup') ||
        lower.contains('load game') ||
        lower.contains('codashop') ||
        lower.contains('unipin') ||
        lower.contains('xbox') ||
        lower.contains('playstation') ||
        lower.contains('nintendo') ||
        lower.contains('arcade') ||
        lower.contains('esports')) return 'Gaming';

    // ── PERSONAL CARE ─────────────────────────────────────────────────────────
    if (lower.contains('haircut') ||
        lower.contains('salon') ||
        lower.contains('barbershop') ||
        lower.contains('barber') ||
        lower.contains('nail') ||
        lower.contains('spa') ||
        lower.contains('massage') ||
        lower.contains('grooming') ||
        lower.contains('shampoo') ||
        lower.contains('conditioner') ||
        lower.contains('soap') ||
        lower.contains('toothpaste') ||
        lower.contains('deodorant') ||
        lower.contains('lotion') ||
        lower.contains('perfume') ||
        lower.contains('cologne') ||
        lower.contains('hygiene')) return 'Personal Care';

    // ── CLOTHING ──────────────────────────────────────────────────────────────
    if (lower.contains('shirt') ||
        lower.contains('pants') ||
        lower.contains('jeans') ||
        lower.contains('dress') ||
        lower.contains('shoes') ||
        lower.contains('sneakers') ||
        lower.contains('sandals') ||
        lower.contains('slipper') ||
        lower.contains('jacket') ||
        lower.contains('hoodie') ||
        lower.contains('uniform') ||
        lower.contains('ukay') ||
        lower.contains('tiangge') ||
        lower.contains('clothes') ||
        lower.contains('clothing') ||
        lower.contains('outfit') ||
        lower.contains('wear') ||
        lower.contains('fashion')) return 'Clothing';

    // ── GIFTS ─────────────────────────────────────────────────────────────────
    if (lower.contains('gift') ||
        lower.contains('pasalubong') ||
        lower.contains('present') ||
        lower.contains('birthday') ||
        lower.contains('christmas gift') ||
        lower.contains('padala') ||
        lower.contains('souvenir') ||
        lower.contains('donation') ||
        lower.contains('charity')) return 'Gifts';

    // ── TRAVEL ────────────────────────────────────────────────────────────────
    if (lower.contains('hotel') ||
        lower.contains('airfare') ||
        lower.contains('airline') ||
        lower.contains('flight') ||
        lower.contains('cebu pacific') ||
        lower.contains('air asia') ||
        lower.contains('pal ') ||
        lower.contains('philippine airlines') ||
        lower.contains('resort') ||
        lower.contains('beach') ||
        lower.contains('vacation') ||
        lower.contains('travel') ||
        lower.contains('tour') ||
        lower.contains('booking') ||
        lower.contains('airbnb') ||
        lower.contains('hostel')) return 'Travel';

    // ── PETS ──────────────────────────────────────────────────────────────────
    if (lower.contains('pet') ||
        lower.contains('dog') ||
        lower.contains('cat') ||
        lower.contains('vet') ||
        lower.contains('veterinar') ||
        lower.contains('pet food') ||
        lower.contains('dog food') ||
        lower.contains('cat food') ||
        lower.contains('pedigree') ||
        lower.contains('whiskas') ||
        lower.contains('aquarium') ||
        lower.contains('fish food')) return 'Pets';

    return 'Others';
  }

  /// Sanitize generic item name prefixes the AI model sometimes produces.
  /// Strips patterns like "your X for", "the X for", "my X for" and title-cases the result.
  /// Examples:
  ///   "your jeepney fare for"  → "Jeepney fare"
  ///   "your lunch for"         → "Lunch"
  ///   "the tricycle fare for"  → "Tricycle fare"
  ///   "my breakfast for"       → "Breakfast"
  ///   "Lunch"                  → "Lunch" (unchanged)
  static String _sanitizeItemName(String raw) {
    var name = raw.trim();
    // Remove leading possessive/article prefixes
    name = name.replaceFirst(
        RegExp(r'^(your|my|the|a|an)\s+', caseSensitive: false), '');
    // Remove trailing "for" or "for [date/reason]"
    name = name.replaceFirst(RegExp(r'\s+for\s*.*$', caseSensitive: false), '');
    name = name.trim();
    if (name.isEmpty) return raw.trim(); // fallback: return original
    // Title-case first letter only (preserve rest as-is)
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Estimate appropriate max_tokens based on message type.
  /// Simple expense logging needs ~150 tokens. Advice/analysis needs ~600.
  static int _estimateMaxTokens(String message) {
    final lower = message.toLowerCase();
    // Bulk rename/capitalization fix — needs many ACTION lines
    if (lower.contains('capitali') ||
        lower.contains('rename') ||
        lower.contains('fix the name') ||
        lower.contains('fix name')) {
      return 800;
    }
    // Multi-item expense logging — detect commas, 'and', 'then', multiple amounts
    final amountCount = RegExp(r'\d+').allMatches(lower).length;
    if (amountCount >= 3 &&
        RegExp(r'\b(spent|bought|paid|purchased|ate|drank|rode|took|nabili|nagbayad)\b')
            .hasMatch(lower)) {
      return 600;
    }
    // Expense logging — short confirmation + one ACTION line needed
    if (RegExp(r'\b(spent|bought|paid|purchased|ate|drank|rode|took|nabili|nagbayad)\b')
            .hasMatch(lower) &&
        RegExp(r'\d').hasMatch(lower)) {
      return 450;
    }
    // List/view requests — moderate length
    if (RegExp(r'\b(list|show|give me|what are|how much|total)\b')
        .hasMatch(lower)) {
      return 450;
    }
    // Advice, analysis, explanation — longer response needed
    if (RegExp(
            r'\b(advice|suggest|help|explain|how|why|should|can i|what if|analyze|review|compare|plan|split|feasib)\b')
        .hasMatch(lower)) {
      return 600;
    }
    return 450;
  }

  /// Detect task type for model routing: 'fast', 'smart', or 'financial_advice'
  ///
  /// financial_advice — complex multi-step financial planning queries that benefit
  /// from deeper reasoning (§29 model routing, §34 thinking mode).
  /// Routes to gemini_flash when available for highest-quality output.
  static String _detectTaskType(String message) {
    final lower = message.toLowerCase();

    // Financial advice tier — multi-step reasoning, planning, PH gov contributions
    // These need the smartest model available, not just the fast one.
    if (RegExp(
            r'\b(feasib|simulate|what if.*save|what if.*cut|amortiz|invest|emergency fund|sss contribution|philhealth contribution|pag.ibig|bir tax|tax bracket|debt strateg|avalanche|snowball|payoff plan|retirement|compound|inflation|opportunity cost|net worth|budget plan|monthly plan|salary split|50.30.20|financial plan)\b')
        .hasMatch(lower)) {
      return 'financial_advice';
    }
    // Fast tasks: logging, balance updates, simple queries
    if (RegExp(
            r'\b(spent|bought|paid|ate|drank|rode|cash|balance|wallet|gcash|maya)\b')
        .hasMatch(lower)) {
      return 'fast';
    }
    // Smart tasks: analysis, planning, advice, complex questions
    if (RegExp(
            r'\b(analyze|plan|advice|suggest|explain|compare|feasib|what if|simulate|debt|goal|invest|sss|philhealth|bir)\b')
        .hasMatch(lower)) {
      return 'smart';
    }
    return 'default';
  }

  /// Returns (reply text, list of actions to execute)
  static Future<(String, List<AIAction>)> sendMessage(String message) async {
    // D2: enforce daily cap before hitting the API
    final allowed = await _checkAndIncrementLimit();
    if (!allowed) {
      throw Exception(
          "Daily AI limit reached (${_dailyLimit} messages/day). Try again tomorrow.");
    }

    _history.add({"role": "user", "content": message});
    _messagesSinceLastSummary++;

    // ── §25 OBSERVABILITY — request trace start ───────────────────────────────
    final traceStart = DateTime.now();

    // Initialize counter from DB on first message of session
    await _initMessageCounter();

    // ── GUARDRAIL: recent-log fingerprint for in-prompt duplicate awareness ──
    // Builds a short "already logged in this session" context note injected
    // into the system prompt so the model knows what was just fired.
    // The full DB-level dedup still runs at action-execution time in ai_screen.
    final recentFingerprints = _buildRecentFingerprints();
    final guardRailNote = recentFingerprints.isNotEmpty
        ? '\n[GUARDRAIL — already logged this session (do NOT re-log unless user explicitly asks again): $recentFingerprints]'
        : '';

    // Reduced from 12 to give more token room for multi-item responses
    if (_history.length > 10) {
      _history.removeRange(0, _history.length - 10);
    }

    // Conversation summarization — every 10 messages, summarize and compress
    // Uses 1 API call but saves tokens on all subsequent calls
    if (_messagesSinceLastSummary >= 10 && _history.length >= 10) {
      _messagesSinceLastSummary = 0;
      _summarizeHistory(); // fire-and-forget, non-blocking
    }

    final systemContent =
        "You are SmartSpend AI — a warm, financially-savvy Filipino-English companion. Be conversational and practical. Use **bold** and bullets only when helpful.\n\n"
        "SCOPE: Personal finance, PH banking (BDO/BPI/Metrobank/Landbank/UnionBank/RCBC/Security/EastWest/PSBank), digital banks (Maya Bank 3.5%/GoTyme 5%/Tonik 4%/Seabank 3%/UNObank), e-wallets (GCash/Maya/GrabPay/ShopeePay/Coins.ph), SSS/PhilHealth/Pag-IBIG, investments (MP2 6-7%/T-bills 5-6%/time deposits 4-6%), insurance, prices, deals. Steer non-finance questions back gently.\n\n"
        "RULES:\n"
        "1. ALWAYS LOG: When user mentions spending/buying with an amount → fire log_expense ACTION. No exceptions. Multiple items = multiple ACTION lines.\n"
        "2. MULTI-ITEM: If user lists several purchases in one message, fire ONE ACTION per item. Example: 'spent 30 jeep, 45 gatorade, 100 lunch' = 3 separate ACTION lines.\n"
        "3. DB IS TRUTH: Context below = only truth. Never say 'already logged' from memory.\n"
        "4. WALLET BALANCE: 'I have X in GCash', 'cash on hand is X', 'my cash is X' → ALWAYS use set_wallet_balance. NEVER log as income, NEVER log as expense. This is a balance update only.\n"
        "5. DUPLICATES — GUARDRAIL: If the GUARDRAIL note above lists an item with the same name+amount that the user JUST mentioned in the SAME message, do NOT fire another ACTION for it. If the user is logging something for a DIFFERENT day or a genuinely new purchase, always log it. When in doubt: log it.\n"
        "6. LOGGING TONE: When logging expenses, be warm and natural — not robotic. Instead of just 'Logged: X ₱Y', add a brief friendly comment. Examples: 'Got it, logged your jeepney fare 🚌', 'Noted! Lunch for ₱100 — hope it was good 😄', 'Logged your Sting — staying energized! ⚡'. Keep it short (1 line max), then the ACTION.\n"
        "7. SOCIAL: 'thanks/ok/yes' → short reply, no actions.\n"
        "8. SELF-CHECK: Before sending your response, verify: does each item the user mentioned have exactly ONE ACTION line? If an item appears twice in your ACTION list, remove the duplicate.\n"
        "9. ITEM NAMES: item_name must be the real item — NEVER use generic filler like 'your X for', 'the X for', 'my X'. Use the actual item: 'Jeepney fare', 'Lunch', 'Snack', 'Breakfast', 'Tricycle fare'. If the user calls it 'jeep' log it as 'Jeepney fare'. If unsure, use the noun the user said.\n"
        "10. DATE/TIME CORRECTIONS: When the user says 'that was on [date]', 'change date to', 'set it to [time]', 'put it on [date]' about an existing expense → fire update_expense ACTION with the corrected date/time field. Do NOT just say you fixed it. No ACTION = no fix. Example: user says 'the lunch I logged was actually on July 3 not July 8' → ACTION:{\"type\":\"update_expense\",\"item_name\":\"Lunch\",\"date\":\"2026-07-03\"}.\n\n"
        "$guardRailNote"
        "ACTIONS (append after reply text, one per line, format: ACTION:{json}):\n"
        "• log_expense: {\"type\":\"log_expense\",\"item_name\":\"X\",\"category\":\"Food\",\"amount\":30,\"is_want\":false} — optional: \"date\":\"YYYY-MM-DD\",\"payment_method\":\"GCash\",\"shop_name\":\"X\"\n"
        "• set_budget: {\"type\":\"set_budget\",\"category\":\"Food\",\"amount\":3000}\n"
        "• set_income: {\"type\":\"set_income\",\"amount\":25000}\n"
        "• add_income: {\"type\":\"add_income\",\"title\":\"X\",\"amount\":600,\"category\":\"Allowance\"}\n"
        "• add_goal: {\"type\":\"add_goal\",\"name\":\"X\",\"target\":50000}\n"
        "• update_goal: {\"type\":\"update_goal\",\"name\":\"X\",\"amount\":500}\n"
        "• delete_goal: {\"type\":\"delete_goal\",\"name\":\"X\"}\n"
        "• add_debt: {\"type\":\"add_debt\",\"title\":\"X\",\"person\":\"Y\",\"amount\":500,\"debt_type\":\"owe\"}\n"
        "• update_debt: {\"type\":\"update_debt\",\"person\":\"Y\",\"payment\":500}\n"
        "• add_recurring: {\"type\":\"add_recurring\",\"title\":\"X\",\"amount\":299,\"category\":\"Bills\",\"frequency\":\"monthly\",\"is_expense\":true}\n"
        "• delete_recurring: {\"type\":\"delete_recurring\",\"title\":\"X\"}\n"
        "• set_account_type: {\"type\":\"set_account_type\",\"account_type\":\"student\"}\n"
        "• update_expense: {\"type\":\"update_expense\",\"item_name\":\"X\",\"category\":\"Food\"} — also: \"new_item_name\",\"amount\",\"date\",\"time\"\n"
        "• delete_expense: {\"type\":\"delete_expense\",\"item_name\":\"X\",\"confirmed\":true} — requires user typed DELETE\n"
        "• delete_by_date: {\"type\":\"delete_by_date\",\"start_date\":\"2026-01-01\",\"end_date\":\"2026-01-31\",\"confirmed\":true}\n"
        "• add_installment_plan: {\"type\":\"add_installment_plan\",\"title\":\"X\",\"provider\":\"ShopeePayLater\",\"total_amount\":1120,\"monthly_payment\":373,\"months_total\":3,\"due_day\":5}\n"
        "• set_wallet_balance: {\"type\":\"set_wallet_balance\",\"wallet_name\":\"GCash\",\"balance\":217.27}\n"
        "• transfer_wallet: {\"type\":\"transfer_wallet\",\"from_wallet\":\"Cash on Hand\",\"to_wallet\":\"GCash\",\"amount\":1000}\n"
        "• plan_salary_split: {\"type\":\"plan_salary_split\",\"income\":25000,\"needs_pct\":50,\"wants_pct\":30,\"savings_pct\":20}\n"
        "• analyze_goal_feasibility: {\"type\":\"analyze_goal_feasibility\",\"goal_name\":\"X\",\"target\":50000,\"monthly_savings\":3000}\n"
        "• suggest_debt_payoff: {\"type\":\"suggest_debt_payoff\",\"strategy\":\"avalanche\"}\n"
        "• generate_monthly_plan: {\"type\":\"generate_monthly_plan\"}\n"
        "• compare_periods: {\"type\":\"compare_periods\",\"period1\":\"2026-04\",\"period2\":\"2026-05\"}\n"
        "• explain_fhs_breakdown: {\"type\":\"explain_fhs_breakdown\"}\n"
        "• project_savings_timeline: {\"type\":\"project_savings_timeline\",\"goal_name\":\"X\",\"target\":50000}\n"
        "• detect_subscriptions: {\"type\":\"detect_subscriptions\"}\n"
        "• compute_contribution: {\"type\":\"compute_contribution\",\"type_name\":\"SSS\",\"monthly_income\":25000}\n"
        "• suggest_idle_money: {\"type\":\"suggest_idle_money\",\"amount\":5000}\n"
        "• suggest_expense_cuts: {\"type\":\"suggest_expense_cuts\"}\n"
        "  Use when user asks 'where can I save money?', 'how to cut expenses?', 'what can I reduce?'. Analyze top spending categories and suggest specific cuts.\n"
        "• simulate_what_if: {\"type\":\"simulate_what_if\",\"change\":\"save 500 more\",\"amount\":500}\n"
        "  Use when user asks 'what if I save ₱500 more?', 'what if I cut food by ₱1000?'. Project impact on savings and FHS.\n"
        "• create_debt_payment_plan: {\"type\":\"create_debt_payment_plan\"}\n"
        "  Use when user asks 'help me pay off my debts', 'create a debt payment schedule'. Create timeline across all debts.\n"
        "• split_expense: {\"type\":\"split_expense\",\"item_name\":\"Dinner\",\"total_amount\":800,\"split_with\":\"John\",\"your_share\":400}\n"
        "  Use when user says 'split the bill with John', 'shared lunch with Maria ₱500', 'we split dinner'. Logs your share as expense and creates debt for the other person's share.\n\n"
        "CATEGORIES: Food, Transportation, Bills, Shopping, Entertainment, Gaming, Health, Education, Personal Care, Clothing, Gifts, Travel, Pets, Others.\n"
        "is_want: true=discretionary (snacks/drinks/junk food, entertainment, gaming, shopping, gifts, travel, dining out at restaurants). false=essential (meals/breakfast/lunch/dinner/brunch, transport, groceries, medicine, tuition, bills, health).\n"
        "IMPORTANT is_want rules: Breakfast/Lunch/Dinner/Brunch/Meal → is_want:false (essential food). Snacks/drinks/energy drinks/junk food → is_want:true. Jeepney/tricycle/bus/commute → is_want:false. Games/steam → is_want:true.\n"
        "BULK RENAME: 'fix capitalization' → fire update_expense with new_item_name for EACH expense. ACTION lines required.\n"
        "${_fullContext.isNotEmpty ? "\nUser's financial context:\n$_fullContext" : ""}";

    // Load conversation summary if available — prepend to history for context
    String? conversationSummary;
    try {
      conversationSummary = await DBService.getLatestConversationSummary();
    } catch (_) {}

    final messages = [
      {"role": "system", "content": systemContent},
      // Include summary as a system note if available
      if (conversationSummary != null)
        {
          "role": "system",
          "content": "[Earlier conversation summary]\n$conversationSummary"
        },
      ..._history,
    ];

    // Task-based model routing — temporarily switch for this request if needed
    final taskType = _detectTaskType(message);
    final taskModelId = AppConfig.modelForTask(taskType);
    final originalModelId = AppConfig.activeModelId;
    final needsSwitch = taskModelId != originalModelId &&
        taskModelId != 'default' &&
        AppConfig.groqApiKey.isNotEmpty;
    if (needsSwitch) AppConfig.setModel(taskModelId);

    // ── EXPONENTIAL BACKOFF (LLM Cheatsheet §13) ─────────────────────────────
    // Retries silently on 503 / timeout up to 3 times with jitter.
    // 429 (rate limit) gets model fallback instead of backoff.
    // 401/403/400 are fatal — never retry.
    http.Response response;
    final maxRetries = 3;
    final baseDelayMs = 1500; // 1.5 seconds
    int attempt = 0;
    while (true) {
      try {
        response = await http
            .post(
              Uri.parse(_groqUrl),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${_groqKey}",
              },
              body: jsonEncode({
                "model": AppConfig.groqModel,
                "messages": messages,
                "temperature": 0.3,
                "max_tokens": _estimateMaxTokens(message),
              }),
            )
            .timeout(const Duration(seconds: 20));
      } on Exception {
        // Timeout or network error — retryable
        if (attempt < maxRetries - 1) {
          attempt++;
          final delayMs = (baseDelayMs * (1 << attempt)).clamp(1500, 30000);
          final jitterMs = (delayMs *
                  0.2 *
                  (DateTime.now().millisecondsSinceEpoch % 100) /
                  100)
              .round();
          await Future.delayed(Duration(milliseconds: delayMs + jitterMs));
          continue;
        }
        if (needsSwitch) AppConfig.setModel(originalModelId);
        rethrow;
      }

      // 503 / 529 = server overloaded — silent backoff and retry
      if ((response.statusCode == 503 || response.statusCode == 529) &&
          attempt < maxRetries - 1) {
        attempt++;
        final delayMs = (baseDelayMs * (1 << attempt)).clamp(1500, 30000);
        final jitterMs = (delayMs *
                0.2 *
                (DateTime.now().millisecondsSinceEpoch % 100) /
                100)
            .round();
        await Future.delayed(Duration(milliseconds: delayMs + jitterMs));
        continue;
      }
      break; // success or non-retryable / max-retries-exhausted
    }

    // Restore original model after task-specific routing
    if (needsSwitch) AppConfig.setModel(originalModelId);

    if (response.statusCode != 200) {
      // Handle rate limit — try auto-fallback to next model
      if (response.statusCode == 429) {
        final switched = AppConfig.autoFallback();
        if (switched) {
          // Retry with the new model
          return sendMessage(message);
        }
        throw Exception(
            "Daily AI limit reached on all models. Try again tomorrow, or add a Gemini/Cerebras API key in Settings.");
      }
      // Show actual status code for easier debugging
      throw Exception(
          "AI error (${response.statusCode}). If this keeps happening, try the ⋮ menu → Reset Daily Limit.");
    }

    final data = jsonDecode(response.body);
    String fullReply = data['choices'][0]['message']['content'] as String;

    // ── §25 OBSERVABILITY — extract token usage ───────────────────────────────
    final usage = data['usage'] as Map<String, dynamic>?;
    final promptTokens = (usage?['prompt_tokens'] as num?)?.toInt() ?? 0;
    final completionTokens =
        (usage?['completion_tokens'] as num?)?.toInt() ?? 0;
    final totalTokens = (usage?['total_tokens'] as num?)?.toInt() ?? 0;

    // Check if response was cut off due to max_tokens — if so, the AI may have
    // been mid-ACTION. The finish_reason will be 'length' instead of 'stop'.
    final finishReason =
        data['choices'][0]['finish_reason'] as String? ?? 'stop';
    final wasCutOff = finishReason == 'length';

    // Parse all ACTION lines — handle → prefix, *bold* markdown wrapping, newline-prefixed and inline.
    // Uses a brace-depth counter instead of a simple [^}]+ regex so nested JSON objects
    // (e.g. add_debt with multiple fields) are captured correctly.
    final actions = <AIAction>[];
    final seen = <String>{};

    // Find every ACTION: occurrence and extract the JSON object that follows it
    // Handles: ACTION:{...}, **ACTION**{...}, **ACTION** {...}, →ACTION:{...}
    // ACTION tag regex — handles: ACTION:{...}, ACTION: type_name: {...}, →ACTION:{...}, **ACTION**{...}
    final actionTagRegex =
        RegExp(r'\*{0,2}→?\s*ACTION:?\*{0,2}\s*(?:\w+:\s*)?', dotAll: true);
    for (final tagMatch in actionTagRegex.allMatches(fullReply)) {
      final jsonStart = tagMatch.end;
      if (jsonStart >= fullReply.length) continue;
      if (fullReply[jsonStart] != '{') continue;

      // Walk forward counting braces to find the matching closing brace
      int depth = 0;
      int jsonEnd = jsonStart;
      for (int i = jsonStart; i < fullReply.length; i++) {
        if (fullReply[i] == '{') depth++;
        if (fullReply[i] == '}') {
          depth--;
          if (depth == 0) {
            jsonEnd = i + 1;
            break;
          }
        }
      }
      if (depth != 0) {
        // Unclosed brace — try appending a closing brace
        jsonEnd = fullReply.length;
      }

      try {
        var jsonStr = fullReply
            .substring(jsonStart, jsonEnd)
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        if (!jsonStr.endsWith('}')) jsonStr = '$jsonStr}';
        if (seen.contains(jsonStr)) continue;
        seen.add(jsonStr);
        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (parsed.containsKey('category')) {
          parsed['category'] = _normalizeCategory(parsed['category'] as String);
        }
        // Sanitize generic item name prefixes the model sometimes emits
        // e.g. "your jeepney fare for" → "Jeepney fare"
        if (parsed.containsKey('item_name')) {
          parsed['item_name'] =
              _sanitizeItemName(parsed['item_name'] as String);
        }
        actions.add(AIAction(type: parsed['type'] as String, params: parsed));
      } catch (_) {}
    }

    // FALLBACK: If AI said "Logged:" but fired no/fewer ACTIONs, auto-generate log_expense
    // This handles the case where the model ignores the ACTION instruction
    // Now catches ALL "Logged:" lines, not just the first one
    // EXCLUDES: wallet balance updates, income updates, non-expense confirmations
    if (RegExp(r'Logged:?\s*.+₱\d', caseSensitive: false).hasMatch(fullReply)) {
      // Don't run fallback if a wallet balance was already set — prevents double-logging
      final hasWalletAction = actions.any((a) =>
          a.type == 'set_wallet_balance' ||
          a.type == 'transfer_wallet' ||
          a.type == 'set_income' ||
          a.type == 'add_income');
      if (!hasWalletAction) {
        final logMatches =
            RegExp(r'Logged:?\s*(.+?)\s*₱(\d+(?:\.\d+)?)', caseSensitive: false)
                .allMatches(fullReply);
        // Count how many log_expense actions we already have from proper ACTION parsing
        final existingLogCount =
            actions.where((a) => a.type == 'log_expense').length;
        // If AI mentioned more "Logged:" lines than it fired ACTIONs for, fill the gap
        if (logMatches.length > existingLogCount) {
          for (final logMatch in logMatches.skip(existingLogCount)) {
            final rawName =
                logMatch.group(1)?.replaceAll('*', '').trim() ?? 'Expense';
            final itemName = _sanitizeItemName(rawName);
            // Skip wallet/income-related items that sneak through
            final nameLower = itemName.toLowerCase();
            if (nameLower.contains('cash on hand') ||
                nameLower.contains('wallet') ||
                nameLower.contains('gcash') ||
                nameLower.contains('balance') ||
                nameLower.contains('income') ||
                nameLower.contains('allowance') ||
                nameLower.contains('salary')) {
              continue;
            }
            final amount = double.tryParse(logMatch.group(2) ?? '') ?? 0;
            if (amount > 0) {
              final category = _normalizeCategory(itemName);
              const wantCategories = [
                'Shopping',
                'Entertainment',
                'Gaming',
                'Clothing',
                'Gifts',
                'Travel'
              ];
              final isWant = wantCategories.contains(category);
              actions.add(AIAction(type: 'log_expense', params: {
                'type': 'log_expense',
                'item_name': itemName,
                'category': category,
                'amount': amount,
                'is_want': isWant,
              }));
            }
          }
        }
      }
    }

    // ── STRUCTURED OUTPUT VALIDATION (LLM Cheatsheet §11 / §19) ─────────────
    // Validate every parsed action has the required fields before we return it
    // to the executor. Invalid actions are dropped with a silent log so they
    // never corrupt the DB with partial data.
    final validatedActions = <AIAction>[];
    for (final action in actions) {
      if (_isActionValid(action)) {
        validatedActions.add(action);
      }
      // Invalid actions are silently discarded — corrupt JSON / missing fields
    }

    // Strip all ACTION blocks from the displayed reply.
    // Handles multiple formats: ACTION:{...}, ACTION: type_name: {...}, →ACTION:{...}
    final stripTagRegex =
        RegExp(r'\*{0,2}→?\s*ACTION:?\*{0,2}\s*(?:\w+:\s*)?\{', dotAll: true);
    final buffer = StringBuffer();
    int pos = 0;
    for (final tagMatch in stripTagRegex.allMatches(fullReply)) {
      // Append everything before this ACTION tag
      buffer.write(fullReply.substring(pos, tagMatch.start));
      // Skip past the JSON object
      int depth = 0;
      int i = tagMatch.end - 1; // points at the opening '{'
      for (; i < fullReply.length; i++) {
        if (fullReply[i] == '{') depth++;
        if (fullReply[i] == '}') {
          depth--;
          if (depth == 0) {
            i++; // move past the closing '}'
            break;
          }
        }
      }
      pos = i;
    }
    buffer.write(fullReply.substring(pos));
    fullReply = buffer
        .toString()
        .replaceAll(RegExp(r'\nHere are the ACTION lines[^\n]*\n?'), '')
        .trim();

    // If response was cut off, append a note so user knows some items may be missing
    if (wasCutOff && actions.isNotEmpty) {
      fullReply +=
          '\n\n_(Response was trimmed — some items may not have been logged. Send them again if needed.)_';
    }

    _history.add({"role": "assistant", "content": fullReply});

    // ── §25 OBSERVABILITY — write request trace ───────────────────────────────
    // Logs latency, token usage, retry count, action count, and task type
    // to a rolling DB setting. Visible in the next debug log export.
    // Cheatsheet §25: "You cannot improve what you cannot measure."
    try {
      final latencyMs = DateTime.now().difference(traceStart).inMilliseconds;
      final taskType = _detectTaskType(message);
      final traceEntry = '${DateTime.now().toIso8601String().substring(0, 16)} '
          'latency=${latencyMs}ms '
          'tokens=${totalTokens}(p=$promptTokens/c=$completionTokens) '
          'retries=$attempt '
          'actions=${validatedActions.length} '
          'task=$taskType '
          'model=${AppConfig.activeModelId}';
      // Keep a rolling log of the last 5 traces (newline-separated)
      final prev = await DBService.getSetting('ai_request_trace') ?? '';
      final lines = prev.split('\n').where((l) => l.isNotEmpty).toList();
      lines.add(traceEntry);
      if (lines.length > 5) lines.removeRange(0, lines.length - 5);
      await DBService.setSetting('ai_request_trace', lines.join('\n'));
    } catch (_) {}

    // ── §16 EVAL CASCADE LAYER 1 — deterministic groundedness check ──────────
    // For financial advice responses: if the reply mentions money-related
    // advice keywords but contains zero numbers/amounts, flag it as
    // potentially ungrounded (the model gave generic advice without using
    // the user's actual financial data).
    // This is the cheap "deterministic floor" from the eval cascade pattern —
    // no extra API call needed.
    try {
      final isAdviceQuery = RegExp(
              r'\b(invest|plan|save|budget|debt|goal|sss|philhealth|bir|tax|contribut|amortiz|compound|retirement)\b',
              caseSensitive: false)
          .hasMatch(message);
      final hasNumbers =
          RegExp(r'₱\d|[0-9]+%|[0-9,]+\s*(pesos|peso|month|year|days?)')
              .hasMatch(fullReply);
      if (isAdviceQuery && !hasNumbers && fullReply.length > 100) {
        // Groundedness signal: advice reply with no figures = likely generic hallucination
        await DBService.setSetting(
          'last_ungrounded_advice',
          '${DateTime.now().toIso8601String().substring(0, 16)}|${message.length > 80 ? message.substring(0, 80) : message}',
        );
      }
    } catch (_) {}

    // ── DEBUG LOGGING (Cheatsheet §26 Step 4) ────────────────────────────────
    if (validatedActions.isEmpty &&
        RegExp(r'Logged:?\s*.+₱\d', caseSensitive: false).hasMatch(fullReply)) {
      try {
        await DBService.setSetting(
          'last_silent_action_fail',
          '${DateTime.now().toIso8601String()}|${fullReply.length > 200 ? fullReply.substring(0, 200) : fullReply}',
        );
      } catch (_) {}
    }

    return (fullReply, validatedActions);
  }

  /// Structured output validation (LLM Cheatsheet §11 / §19 Guardrails).
  /// Returns true only if the action has the minimum required fields.
  /// Prevents corrupted or hallucinated JSON from reaching the DB executor.
  static bool _isActionValid(AIAction action) {
    final p = action.params;
    switch (action.type) {
      case 'log_expense':
        // Must have item_name and a positive amount
        final name = p['item_name'];
        final amt = (p['amount'] as num?)?.toDouble() ?? 0;
        return name != null &&
            name.toString().trim().isNotEmpty &&
            amt > 0 &&
            amt < 10000000; // sanity cap: ₱10M
      case 'set_budget':
        return p['category'] != null &&
            (p['amount'] as num?)?.toDouble() != null;
      case 'set_income':
      case 'add_income':
        final inc = (p['amount'] as num?)?.toDouble() ?? 0;
        return inc > 0;
      case 'set_wallet_balance':
        return p['wallet_name'] != null && (p['balance'] as num?) != null;
      case 'transfer_wallet':
        return p['from_wallet'] != null &&
            p['to_wallet'] != null &&
            (p['amount'] as num?)?.toDouble() != null;
      case 'update_expense':
        // Must identify at least item_name to find the expense
        return p['item_name'] != null &&
            p['item_name'].toString().trim().isNotEmpty;
      case 'delete_expense':
        // Require explicit confirmation flag to prevent accidental deletes
        return p['item_name'] != null && p['confirmed'] == true;
      case 'add_goal':
        return p['name'] != null &&
            (p['target'] as num?)?.toDouble() != null &&
            (p['target'] as num).toDouble() > 0;
      case 'add_debt':
        return p['person'] != null && (p['amount'] as num?)?.toDouble() != null;
      case 'add_installment_plan':
        return p['title'] != null &&
            (p['total_amount'] as num?)?.toDouble() != null &&
            (p['monthly_payment'] as num?)?.toDouble() != null;
      // Actions that need no field validation — they are advisory/read-only
      case 'explain_fhs_breakdown':
      case 'generate_monthly_plan':
      case 'detect_subscriptions':
      case 'suggest_expense_cuts':
      case 'suggest_debt_payoff':
      case 'suggest_idle_money':
      case 'create_debt_payment_plan':
        return true;
      default:
        // Unknown action type — allow through (forward-compatible with new actions)
        return true;
    }
  }

  /// Summarize the current conversation history and store it.
  /// Called every 10 messages — fire-and-forget (non-blocking).
  static Future<void> _summarizeHistory() async {
    if (_history.length < 6) return;
    try {
      // Take the older half of history to summarize
      final toSummarize = _history.take(_history.length - 4).toList();
      final conversationText = toSummarize
          .map((m) => "${m['role'] == 'user' ? 'User' : 'AI'}: ${m['content']}")
          .join("\n");

      final response = await http
          .post(
            Uri.parse(_groqUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${_groqKey}",
            },
            body: jsonEncode({
              "model": AppConfig.groqModel,
              "messages": [
                {
                  "role": "system",
                  "content":
                      "Summarize this conversation in 3-5 bullet points. Focus only on: expenses logged, budgets discussed, financial goals mentioned, user preferences, important financial decisions. Be very concise. Ignore small talk."
                },
                {"role": "user", "content": conversationText}
              ],
              "temperature": 0.1,
              "max_tokens": 200,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = data['choices'][0]['message']['content'] as String;
        await DBService.saveConversationSummary(summary, _history.length);
        // Trim history to last 4 messages now that older ones are summarized
        if (_history.length > 4) {
          _history.removeRange(0, _history.length - 4);
        }
      }
    } catch (_) {} // fail silently — summarization is optional
  }

  static void clearHistory() {
    _history.clear();
    _messagesSinceLastSummary = 0;
    _fullContext = "";
    _userRules = [];
    _sessionActionLog.clear();
    // Clear summaries on explicit chat clear
    DBService.clearConversationSummaries().catchError((_) {});
  }

  static void restoreHistory(List<Map<String, dynamic>> saved) {
    _history.clear();
    for (final msg in saved) {
      final role = msg['role'] as String;
      _history.add({
        "role": role == 'ai' ? 'assistant' : 'user',
        "content": msg['message'] as String,
      });
    }
  }
}
