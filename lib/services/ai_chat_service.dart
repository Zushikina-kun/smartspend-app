import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'db_service.dart';

/// Represents an action the AI wants to perform on the app's data
class AIAction {
  final String type;
  final Map<String, dynamic> params;
  AIAction({required this.type, required this.params});
}

class AIChatService {
  static const _apiKey =
      "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";
  static const _baseUrl = "https://api.groq.com/openai/v1/chat/completions";
  static const _model = "llama-3.1-8b-instant";

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
    int? todayMoodScore,
    String? todayMoodNote,
    String quizChallenge = '',
    double allTimeTotal = 0,
    Map<String, double> monthlyTotals = const {},
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

    _fullContext = """
Account type: $accountType | Income: ${monthlyIncome > 0 ? '₱${monthlyIncome.toStringAsFixed(0)}/mo' : 'Not set'} | Score: $healthScore/100
This month spent: ₱${totalSpent.toStringAsFixed(0)}$wantNeedSummary
${allTimeTotal > 0 ? 'All-time: ₱${allTimeTotal.toStringAsFixed(0)}' : ''}$monthlyTotalsSummary
${quizChallenge.isNotEmpty ? 'Challenge: $quizChallenge' : ''}
${todayMoodScore != null ? 'Mood: $todayMoodScore/5${todayMoodScore <= 2 ? ' (low — be supportive)' : todayMoodScore >= 4 ? ' (good)' : ''}' : ''}
${customCategories.isNotEmpty ? 'Custom cats: ${customCategories.join(', ')}' : ''}

Expenses (if not listed here, it does not exist in DB):
$expenseSummary

Budgets: $budgetSummary$goalsSummary$debtsSummary$recurringSummary$installmentsSummary""";
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

    return 'Others';
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
      return 800; // enough for 10+ ACTION lines
    }
    // Expense logging — short confirmation needed
    if (RegExp(r'\b(spent|bought|paid|purchased|ate|drank|rode|took)\b')
            .hasMatch(lower) &&
        RegExp(r'\d').hasMatch(lower)) {
      return 200;
    }
    // List/view requests — moderate length
    if (RegExp(r'\b(list|show|give me|what are|how much|total)\b')
        .hasMatch(lower)) {
      return 400;
    }
    // Advice, analysis, explanation — longer response needed
    if (RegExp(
            r'\b(advice|suggest|help|explain|how|why|should|can i|what if|analyze|review)\b')
        .hasMatch(lower)) {
      return 600;
    }
    // Default
    return 400;
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

    // Initialize counter from DB on first message of session
    await _initMessageCounter();

    // Keep history bounded to last 6 exchanges (12 messages)
    if (_history.length > 12) {
      _history.removeRange(0, _history.length - 12);
    }

    // Conversation summarization — every 10 messages, summarize and compress
    // Uses 1 API call but saves tokens on all subsequent calls
    if (_messagesSinceLastSummary >= 10 && _history.length >= 10) {
      _messagesSinceLastSummary = 0;
      _summarizeHistory(); // fire-and-forget, non-blocking
    }

    final systemContent =
        "You are SmartSpend AI — a friendly, financially-savvy companion for Filipino users. "
        "You're like a knowledgeable friend who helps with money management, not a corporate chatbot. "
        "Be warm, conversational, and practical. Light Filipino-English mixing is fine when natural. "
        "Use **bold** and - bullets only when it helps clarity.\n\n"
        "WHAT YOU CAN HELP WITH:\n"
        "• Managing expenses, budgets, savings, income, debts, and goals using the user's actual app data\n"
        "• Current market prices and estimates (items, gadgets, second-hand goods in the Philippines)\n"
        "• Philippine banking products — BDO, BPI, GCash, Maya, UnionBank, Seabank\n"
        "• Loans, SSS, PhilHealth, Pag-IBIG benefits and how to apply\n"
        "• Investment basics — stocks, MP2, time deposits, crypto basics\n"
        "• Buying, selling, deal assessment, price negotiation\n"
        "• General financial literacy and money advice\n"
        "• Any topic that touches on money, transactions, or value\n"
        "If a question is completely unrelated to finance, gently steer back — but never be cold about it.\n\n"
        "FILIPINO FINANCIAL CALENDAR AWARENESS:\n"
        "- May–July: School enrollment season — tuition, uniforms, school supplies spike\n"
        "- November–December: 13th month pay season — employees receive extra month salary\n"
        "- December: Christmas shopping, Noche Buena groceries, gifts — spending spikes significantly\n"
        "- January: Post-holiday budget recovery — many Filipinos are tight on cash\n"
        "- March–April: Summer — travel, leisure, and food spending increase\n"
        "- June 12: Independence Day — sales and promos common\n"
        "- November 11: 11.11 sale (Shopee/Lazada) — major online shopping event\n"
        "- December 12: 12.12 sale — another major online shopping event\n"
        "Proactively mention these when relevant to the user's spending or questions.\n\n"
        "CRITICAL RULES:\n"
        "1. DB AUTHORITY: The financial context below is the ONLY truth about the user's data. Conversation history is NOT a database. If an expense isn't in the context, it doesn't exist. NEVER say 'you already logged X' based on history.\n"
        "2. TOTALS: Use pre-computed totals from context header. NEVER sum the expense list yourself — it may be truncated.\n"
        "3. DUPLICATE: ALWAYS log new purchases when asked. NEVER refuse saying 'already logged'. People buy the same thing multiple times.\n"
        "4. CASH BALANCE: App doesn't store wallet balance. If user says 'I have X pesos', respond: 'I can't store a cash balance, but I can log income or expenses.'\n"
        "5. SOCIAL: 'thanks', 'ok', 'yes', 'no', greetings → short reply only, NO actions.\n"
        "6. AFTER EDITS: Don't state new totals after update/delete. Say 'Updated ✓ — totals will reflect this.'\n"
        "7. PRICES: When asked about current prices, give your best estimate and be honest it may not be exact.\n\n"
        "ACTIONS — append after reply text ONLY when user explicitly describes a purchase/financial change:\n"
        "• Log expense: ACTION:{\"type\":\"log_expense\",\"item_name\":\"X\",\"category\":\"Food\",\"amount\":30,\"is_want\":false}\n"
        "• Set budget: ACTION:{\"type\":\"set_budget\",\"category\":\"Food\",\"amount\":3000}\n"
        "• Set income (updates the monthly income SETTING): ACTION:{\"type\":\"set_income\",\"amount\":25000} — use when user says 'my salary/allowance IS X'\n"
        "• Add income (logs an actual income ENTRY): ACTION:{\"type\":\"add_income\",\"title\":\"Daily Allowance\",\"amount\":6600,\"category\":\"Allowance\"} — use when user says 'I received/got X' or 'log my allowance'\n"
        "  IMPORTANT: When user says 'my daily allowance is ₱330', fire BOTH set_income (330×22=7260) AND add_income to log the entry.\n"
        "• Add goal: ACTION:{\"type\":\"add_goal\",\"name\":\"X\",\"target\":50000}\n"
        "• Update goal: ACTION:{\"type\":\"update_goal\",\"name\":\"X\",\"amount\":500}\n"
        "• Add debt: ACTION:{\"type\":\"add_debt\",\"title\":\"X\",\"person\":\"Y\",\"amount\":500,\"debt_type\":\"owe\"}\n"
        "• Add recurring: ACTION:{\"type\":\"add_recurring\",\"title\":\"X\",\"amount\":299,\"category\":\"Bills\",\"frequency\":\"monthly\",\"is_expense\":true}\n"
        "• Set account type: ACTION:{\"type\":\"set_account_type\",\"account_type\":\"student\"}\n"
        "• Update expense: ACTION:{\"type\":\"update_expense\",\"item_name\":\"X\",\"category\":\"Food\"}\n"
        "• Delete expense: requires user to type DELETE first. ACTION:{\"type\":\"delete_expense\",\"item_name\":\"X\",\"confirmed\":true}\n"
        "• Add payment plan (installment): ACTION:{\"type\":\"add_installment_plan\",\"title\":\"ShopeePayLater\",\"provider\":\"ShopeePayLater\",\"total_amount\":1120,\"monthly_payment\":373,\"months_total\":3,\"due_day\":5}\n"
        "  Use add_installment_plan (NOT add_debt) when user mentions: ShopeePayLater, GCash GLoan, HomeCredit, installment, monthly payment plan, 'bayad buwan-buwan', fixed monthly payments.\n"
        "• Pay debt (partial/full): ACTION:{\"type\":\"update_debt\",\"person\":\"John\",\"payment\":500}\n"
        "• Delete goal: ACTION:{\"type\":\"delete_goal\",\"name\":\"RTX 4060 Ti\"}\n"
        "• Delete recurring: ACTION:{\"type\":\"delete_recurring\",\"title\":\"Netflix\"}\n\n"
        "BULK RENAME / CAPITALIZATION FIX (CRITICAL): When user says 'fix capitalization', 'rename my expenses', 'fix the names', or similar — you MUST fire update_expense ACTION lines for EVERY expense that needs changing. Do NOT just list the corrected names as text. Each rename = one ACTION line. Example:\n"
        "ACTION:{\"type\":\"update_expense\",\"item_name\":\"jeepney fare\",\"new_item_name\":\"Jeepney Fare\"}\n"
        "The update_expense action supports a 'new_item_name' field for renaming. Use it.\n"
        "IMPORTANT: After listing the corrected names, you MUST include the ACTION lines. If you only list names without ACTION lines, NOTHING gets updated in the database.\n\n"
        "ACTION FORMAT: plain text after reply, one per line, ACTION:{...} only. No bold, no → prefix.\n"
        "CATEGORIES: Food, Transportation, Bills, Shopping, Entertainment, Health, Education, Others.\n"
        "is_want: true=discretionary (snacks, entertainment, shopping). false=essential (transport, groceries, medicine, tuition, bills).\n"
        "Education ALWAYS is_want:false. Candy/chips/drinks/energy drinks → Food.\n"
        "For simple logging: just say 'Logged: [item] ₱[amount]' — nothing more.\n"
        "${_fullContext.isNotEmpty ? "\n\nUser's financial context (live from database):\n$_fullContext" : ""}";

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

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_apiKey",
          },
          body: jsonEncode({
            "model": _model,
            "messages": messages,
            "temperature": 0.3,
            // Dynamic max_tokens: simple logging needs less, advice needs more
            "max_tokens": _estimateMaxTokens(message),
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      // Handle rate limit specifically
      if (response.statusCode == 429) {
        throw Exception(
            "I'm receiving too many requests right now. Please wait a moment and try again.");
      }
      // Show actual status code for easier debugging
      throw Exception(
          "AI error (${response.statusCode}). If this keeps happening, try the ⋮ menu → Reset Daily Limit.");
    }

    final data = jsonDecode(response.body);
    String fullReply = data['choices'][0]['message']['content'] as String;

    // Parse all ACTION lines — handle → prefix, *bold* markdown wrapping, newline-prefixed and inline.
    // Uses a brace-depth counter instead of a simple [^}]+ regex so nested JSON objects
    // (e.g. add_debt with multiple fields) are captured correctly.
    final actions = <AIAction>[];
    final seen = <String>{};

    // Find every ACTION: occurrence and extract the JSON object that follows it
    // Handles: ACTION:{...}, **ACTION**{...}, **ACTION** {...}, →ACTION:{...}
    final actionTagRegex =
        RegExp(r'\*{0,2}→?\s*ACTION:?\*{0,2}\s*', dotAll: true);
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
        actions.add(AIAction(type: parsed['type'] as String, params: parsed));
      } catch (_) {}
    }

    // Strip all ACTION blocks from the displayed reply.
    // Walk the string and remove every ACTION:{...} occurrence (handles nested braces).
    final stripTagRegex =
        RegExp(r'\*{0,2}→?\s*ACTION:?\*{0,2}\s*\{', dotAll: true);
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

    _history.add({"role": "assistant", "content": fullReply});
    return (fullReply, actions);
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
            Uri.parse(_baseUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $_apiKey",
            },
            body: jsonEncode({
              "model": _model,
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
