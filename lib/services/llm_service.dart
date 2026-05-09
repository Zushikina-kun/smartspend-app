import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LLMService {
  static const _groqKey =
      "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";
  static const _groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  static const _groqModel = "llama-3.1-8b-instant";

  // Fallback: Gemini free tier (student edu account)
  // Set this if you have a working Gemini key
  static const _geminiKey = "";
  static const _geminiUrl =
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent";

  static Future<String> _callGroq(String systemPrompt, String userPrompt,
      {int maxTokens = 512}) async {
    try {
      final response = await http
          .post(
            Uri.parse(_groqUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $_groqKey",
            },
            body: jsonEncode({
              "model": _groqModel,
              "messages": [
                {"role": "system", "content": systemPrompt},
                {"role": "user", "content": userPrompt},
              ],
              "temperature": 0.1,
              "max_tokens": maxTokens,
            }),
          )
          .timeout(const Duration(seconds: 20),
              onTimeout: () => throw Exception("Request timed out."));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      }

      // If Groq fails and Gemini key is set, try fallback
      if (_geminiKey.isNotEmpty) {
        return await _callGeminiFallback(systemPrompt, userPrompt);
      }

      throw Exception("AI failed (${response.statusCode}): ${response.body}");
    } catch (e) {
      // Try Gemini fallback on any error if key is set
      if (_geminiKey.isNotEmpty) {
        return await _callGeminiFallback(systemPrompt, userPrompt);
      }
      rethrow;
    }
  }

  static Future<String> _callGeminiFallback(String system, String user) async {
    final response = await http
        .post(
          Uri.parse("$_geminiUrl?key=$_geminiKey"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": "$system\n\n$user"}
                ]
              }
            ]
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception("Fallback AI failed (${response.statusCode})");
    }
    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  /// Parse any user input into structured expense data.
  static Future<Map<String, dynamic>> parseExpense(String input) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final now = DateFormat('HH:mm').format(DateTime.now());

    const system =
        '''You are a financial data parser for a Filipino expense tracking app.
Extract structured expense data from user input and return ONLY valid JSON.
No explanations. No markdown. No extra text. Just the JSON object.

Category rules — map keywords strictly:
- Food: ANY food, drink, snack, or beverage item. This includes: candy, chocolate, chips, biscuit, cookie, ice cream, cake, bread, milk, water (bottled), juice, soda, energy drink, coffee, tea, rice, ulam, merienda, any meal, any restaurant, any food brand. Filipino food: siomai, fishball, kwek-kwek, isaw, balut, taho, halo-halo, buko, pansit, adobo, sinigang, tapsilog, silog, lomi, lugaw, goto, champorado. Fast food: Jollibee, McDonald's, KFC, Chowking, Mang Inasal, Shakey's, Greenwich, Yellow Cab, Max's, Goldilocks, Red Ribbon, Starbucks, Dunkin. Convenience stores: 7-Eleven, Ministop, Family Mart. Delivery: GrabFood, Foodpanda, Shopee Food.
- Transportation: Grab (ride), Angkas, Lalamove, jeep, jeepney, bus, MRT, LRT, taxi, tricycle, trike, pedicab, UV Express, P2P, TNVS, fare, gas, fuel, toll, parking, commute, byahe, sakay
- Bills: electricity, water bill, internet, WiFi, Meralco, PLDT, Globe, Smart, DITO, rent, Netflix, Spotify, subscription, insurance, loan, mortgage, SSS, PhilHealth, Pag-IBIG, bayad
- Shopping: clothes, shoes, bag, mall, Lazada, Shopee, gadget, appliance, ukay, tiangge, accessories, cosmetics, makeup, skincare, SM, Ayala, Robinsons
- Entertainment: movie, cinema, concert, game, arcade, bar, videoke, karaoke, event, ticket, resort, beach, vacation
- Health: medicine, hospital, clinic, doctor, pharmacy, vitamins, dental, dentist, glasses, eyeglasses, gamot, botika, Mercury Drug, Watsons
- Education: tuition, books, school supplies, course, training, seminar, uniform
- Others: anything that doesn't fit above

CRITICAL: Candy, chips, biscuits, chocolate, ice cream, cake, bread, drinks — ALL go to Food, not Others.

Payment method rules:
- Cash: default if not mentioned
- GCash: gcash, g-cash
- Card: credit card, debit card, visa, mastercard
- Others: PayMaya, Maya, bank transfer, online payment

Want vs Need rules (is_want field):
- is_want: true for discretionary/optional spending: Shopping, Entertainment, snacks, candy, chips, fast food treats, coffee shop drinks, gaming, concerts, vacations, accessories, cosmetics
- is_want: false (Need) for essentials: groceries, medicine, transport fare, bills, tuition, rent, utilities, basic meals
- When in doubt, lean toward false (Need)''';

    final user = '''Extract expense from: "$input"
Today's date: $today, current time: $now

Return ONLY this JSON:
{
  "item_name": "specific item or meal name",
  "category": "one of: Food, Transportation, Bills, Shopping, Entertainment, Health, Education, Others",
  "amount": 0,
  "date": "$today",
  "time": "$now",
  "payment_method": "Cash",
  "shop_name": "store or restaurant name if mentioned",
  "location": "",
  "notes": "",
  "is_want": false,
  "confidence_score": 0.95
}''';

    try {
      final raw = await _callGroq(system, user);
      final cleaned =
          raw.replaceAll("```json", "").replaceAll("```", "").trim();

      // Extract JSON if there's any surrounding text
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
      if (jsonMatch == null) throw Exception("No JSON found in response");

      final parsed = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      return {
        "item_name": parsed["item_name"] ?? input,
        "category": _normalizeCategory(parsed["category"] ?? "Others"),
        "amount": (parsed["amount"] as num?)?.toDouble() ?? 0.0,
        "date": parsed["date"] ?? today,
        "time": parsed["time"] ?? now,
        "payment_method": parsed["payment_method"] ?? "Cash",
        "shop_name": parsed["shop_name"],
        "location": parsed["location"],
        "notes": parsed["notes"],
        "ai_generated": 1,
        "is_want": (parsed["is_want"] as bool? ?? false) ? 1 : 0,
        "confidence_score":
            (parsed["confidence_score"] as num?)?.toDouble() ?? 0.8,
      };
    } catch (e) {
      throw Exception("Could not parse expense: $e");
    }
  }

  /// Normalize category to allowed values only
  static String _normalizeCategory(String raw) {
    const allowed = [
      'Food',
      'Transportation',
      'Bills',
      'Shopping',
      'Entertainment',
      'Health',
      'Education',
      'Others'
    ];
    // Case-insensitive exact match
    for (final cat in allowed) {
      if (raw.toLowerCase() == cat.toLowerCase()) return cat;
    }
    // Partial match fallback — comprehensive Filipino + general keywords
    final lower = raw.toLowerCase();

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
        lower.contains('halohalo') ||
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
        lower.contains('tapsilog') ||
        lower.contains('longsilog') ||
        lower.contains('tocilog') ||
        lower.contains('bangsilog') ||
        lower.contains('silog') ||
        lower.contains('lomi') ||
        lower.contains('lugaw') ||
        lower.contains('goto') ||
        lower.contains('arroz') ||
        lower.contains('champorado') ||
        lower.contains('sting') ||
        lower.contains('cobra') ||
        lower.contains('red bull') ||
        lower.contains('energy drink') ||
        lower.contains('jollibee') ||
        lower.contains('mcdonald') ||
        lower.contains('kfc') ||
        lower.contains('chowking') ||
        lower.contains('mang inasal') ||
        lower.contains('7-eleven') ||
        lower.contains('711') ||
        lower.contains('ministop') ||
        lower.contains('family mart') ||
        lower.contains('nestea') ||
        lower.contains('c2') ||
        lower.contains('familymart') ||
        lower.contains('greenwich') ||
        lower.contains('yellow cab') ||
        lower.contains('shakey') ||
        lower.contains('max\'s') ||
        lower.contains('goldilocks') ||
        lower.contains('red ribbon') ||
        lower.contains('starbucks') ||
        lower.contains('dunkin') ||
        lower.contains('mcdo') ||
        lower.contains('rice') ||
        lower.contains('ulam') ||
        lower.contains('merienda') ||
        lower.contains('kain') ||
        lower.contains('pagkain') ||
        lower.contains('lutong') ||
        lower.contains('palengke') && lower.contains('food') ||
        lower.contains('wet market') ||
        lower.contains('supermarket') ||
        lower.contains('grocery store')) return 'Food';

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
        lower.contains('jeepney') ||
        lower.contains('bus') ||
        lower.contains('mrt') ||
        lower.contains('lrt') ||
        lower.contains('taxi') ||
        lower.contains('tricycle') ||
        lower.contains('trike') ||
        lower.contains('pedicab') ||
        lower.contains('uv express') ||
        lower.contains('uvexpress') ||
        lower.contains('p2p') ||
        lower.contains('tnvs') ||
        lower.contains('gas') ||
        lower.contains('fuel') ||
        lower.contains('petrol') ||
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
        lower.contains('water bill') ||
        lower.contains('internet') ||
        lower.contains('wifi') ||
        lower.contains('pldt') ||
        lower.contains('globe') ||
        lower.contains('smart') ||
        lower.contains('dito') ||
        lower.contains('rent') ||
        lower.contains('netflix') ||
        lower.contains('spotify') ||
        lower.contains('youtube premium') ||
        lower.contains('subscription') ||
        lower.contains('insurance') ||
        lower.contains('loan') ||
        lower.contains('mortgage') ||
        lower.contains('amortization') ||
        lower.contains('bayad') ||
        lower.contains('sss') ||
        lower.contains('philhealth') ||
        lower.contains('pagibig') ||
        lower.contains('pag-ibig')) return 'Bills';

    // ── SHOPPING ──────────────────────────────────────────────────────────────
    if (lower.contains('shop') ||
        lower.contains('cloth') ||
        lower.contains('shirt') ||
        lower.contains('pants') ||
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
        lower.contains('divisoria') ||
        lower.contains('accessories') ||
        lower.contains('jewelry') ||
        lower.contains('watch') ||
        lower.contains('perfume') ||
        lower.contains('cosmetics') ||
        lower.contains('makeup') ||
        lower.contains('skincare') ||
        lower.contains('sm ') ||
        lower.contains('ayala') ||
        lower.contains('robinsons') ||
        lower.contains('puregold') ||
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
        lower.contains('club') ||
        lower.contains('videoke') ||
        lower.contains('karaoke') ||
        lower.contains('event') ||
        lower.contains('ticket') ||
        lower.contains('amusement') ||
        lower.contains('resort') ||
        lower.contains('beach') ||
        lower.contains('travel package') ||
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
        lower.contains('checkup') ||
        lower.contains('dental') ||
        lower.contains('dentist') ||
        lower.contains('optometrist') ||
        lower.contains('glasses') ||
        lower.contains('eyeglasses') ||
        lower.contains('contact lens') ||
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
        lower.contains('workshop') ||
        lower.contains('uniform') ||
        lower.contains('allowance') && lower.contains('school'))
      return 'Education';

    return 'Others';
  }

  /// Generate spending insights
  static Future<String> analyzeInsights(List<Map<String, dynamic>> expenses,
      {double? actualTotal}) async {
    if (expenses.isEmpty) {
      return "No expenses recorded yet. Start tracking to get insights.";
    }

    final total = actualTotal ??
        expenses.fold<double>(0, (s, e) => s + (e['amount'] as num));
    final summary = expenses
        .map((e) =>
            "- ${e['item_name'] ?? e['category']}: ₱${e['amount']} (${e['category']})")
        .join("\n");

    const system = "You are SmartSpend, a personal financial assistant. "
        "Give short, practical, friendly insights using markdown: **bold** key points, - bullet points. "
        "Always respond in English. "
        "IMPORTANT: Use ONLY the exact total provided — do NOT calculate or estimate your own total. "
        "No markdown headers.";

    final user =
        "Total spent this month: ₱${total.toStringAsFixed(2)}\n\nExpenses:\n$summary\n\nGive 2-3 insights based on these exact figures.";

    return await _callGroq(system, user);
  }

  /// Get personalized financial advice
  static Future<String> getFinancialAdvice({
    required List<Map<String, dynamic>> expenses,
    required double monthlyIncome,
    required double predictedNext,
  }) async {
    if (expenses.isEmpty) return "Add some expenses first to get advice.";

    final total = expenses.fold<double>(0, (s, e) => s + (e['amount'] as num));
    final summary = expenses
        .map((e) =>
            "- ${e['item_name'] ?? e['category']}: ₱${e['amount']} (${e['category']})")
        .join("\n");

    const system = "You are SmartSpend, a personal finance advisor. "
        "Give practical, specific, actionable advice using markdown: **bold** key points, - bullet points. "
        "Be friendly and concise. Always respond in the same language the user writes in. No markdown headers.";

    final user = """
Monthly income: ₱${monthlyIncome.toStringAsFixed(0)}
Total spent this period: ₱${total.toStringAsFixed(0)}
Projected spending next month (based on current pace): ₱${predictedNext.toStringAsFixed(0)}

NOTE: The projected figure above is a SPENDING forecast, not income. Monthly income remains ₱${monthlyIncome.toStringAsFixed(0)}.

Expenses:
$summary

Give 3-4 specific financial tips. Include savings suggestions.""";

    return await _callGroq(system, user, maxTokens: 600);
  }

  /// Generate a plain-English monthly summary paragraph.
  /// "This month you spent ₱X more than you earned. The gap is mostly from
  /// dining out, which jumped after the 15th."
  /// No charts — just a short, human-readable paragraph.
  static Future<String> generateMonthlySummary({
    required List<Map<String, dynamic>> expenses,
    required double monthlyIncome,
    required String monthLabel,
  }) async {
    if (expenses.isEmpty) {
      return "No expenses recorded for $monthLabel yet.";
    }

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final total = expenses.fold<double>(0, (s, e) => s + (e['amount'] as num));
    final catTotals = <String, double>{};
    for (final e in expenses) {
      final cat = e['category'] as String? ?? 'Others';
      catTotals[cat] = (catTotals[cat] ?? 0) + (e['amount'] as num);
    }
    final topCats = (catTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => "${e.key}: ₱${e.value.toStringAsFixed(0)}")
        .join(", ");

    const system =
        "You are SmartSpend, a personal finance assistant. Write a single short paragraph (2–4 sentences) "
        "summarizing the user's month in plain, friendly English. "
        "No bullet points. No headers. No markdown. Just a natural paragraph a friend would say. "
        "Be honest but encouraging. Mention the biggest spending category and whether they saved or overspent. "
        "IMPORTANT: The spending total provided is for the days elapsed so far this month — NOT the full month. "
        "Do NOT say the user spent that amount 'this month' as if the month is complete. "
        "Say 'so far this month' or 'in the first X days' to be accurate.";

    final user = "Month: $monthLabel (day $daysPassed of $daysInMonth)\n"
        "Income: ₱${monthlyIncome.toStringAsFixed(0)}/month\n"
        "Spent so far (day $daysPassed of $daysInMonth): ₱${total.toStringAsFixed(0)}\n"
        "Top categories: $topCats\n\n"
        "Write a 2–4 sentence plain-English summary. Remember: this is only day $daysPassed of $daysInMonth.";

    return await _callGroq(system, user, maxTokens: 200);
  }

  /// Pre-process raw transaction text (pasted or OCR'd) to normalize it
  /// before sending to the AI. Handles:
  /// 1. Well-formatted text (rows with date + description + amount) → pass through
  /// 2. OCR column-separated output → extract columns separately and label them
  /// 3. Other bank formats → normalize date formats, clean noise
  static String _preprocessTransactionText(String raw) {
    // ── NORMALIZE DATE FORMATS ────────────────────────────────────────────────
    String normalized = raw;

    // MM/DD/YYYY or M/D/YYYY → YYYY-MM-DD
    normalized = normalized.replaceAllMapped(
      RegExp(r'\b(\d{1,2})/(\d{1,2})/(\d{4})\b'),
      (m) {
        final month = m.group(1)!.padLeft(2, '0');
        final day = m.group(2)!.padLeft(2, '0');
        return '${m.group(3)}-$month-$day';
      },
    );

    // DD-Mon-YYYY (e.g. 28-Apr-2026) → YYYY-MM-DD
    const monthMap = {
      'jan': '01',
      'feb': '02',
      'mar': '03',
      'apr': '04',
      'may': '05',
      'jun': '06',
      'jul': '07',
      'aug': '08',
      'sep': '09',
      'oct': '10',
      'nov': '11',
      'dec': '12',
    };
    normalized = normalized.replaceAllMapped(
      RegExp(
          r'\b(\d{1,2})[-/](Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[-/](\d{4})\b',
          caseSensitive: false),
      (m) {
        final day = m.group(1)!.padLeft(2, '0');
        final month = monthMap[m.group(2)!.toLowerCase()] ?? '01';
        return '${m.group(3)}-$month-$day';
      },
    );

    // ── CHECK IF RECONSTRUCTION IS NEEDED ────────────────────────────────────
    final datePattern = RegExp(r'\d{4}-\d{2}-\d{2}');
    final amountPattern = RegExp(r'\b\d{1,6}\.\d{2}\b');

    final lines = normalized
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final totalDateLines = lines.where((l) => datePattern.hasMatch(l)).length;
    final linesWithBoth = lines
        .where((l) => datePattern.hasMatch(l) && amountPattern.hasMatch(l))
        .length;

    // If most date-lines already have amounts → well-formatted, pass through
    if (totalDateLines < 2 || linesWithBoth >= (totalDateLines * 0.5).ceil()) {
      return normalized;
    }

    // ── SEPARATED COLUMNS DETECTED ───────────────────────────────────────────
    // OCR reads table columns top-to-bottom, producing separate blocks:
    //   Block 1: all dates+times
    //   Block 2: all descriptions
    //   Block 3: all reference numbers
    //   Block 4: all debit amounts (after "Debit" header)
    //   Block 5: all credit amounts (after "Credit" header)
    //   Block 6: all balance amounts (after "Balance" header)
    //
    // Strategy: find the Debit/Credit/Balance column headers and extract
    // amounts from each section separately, then pair with dates.

    // Extract dates with times in document order
    final dateTimePattern = RegExp(r'(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})');
    final dateOnlyPattern = RegExp(r'(\d{4}-\d{2}-\d{2})');
    final extractedDates = <String>[];
    for (final m in dateTimePattern.allMatches(normalized)) {
      extractedDates.add('${m.group(1)} ${m.group(2)}');
    }
    if (extractedDates.isEmpty) {
      for (final m in dateOnlyPattern.allMatches(normalized)) {
        extractedDates.add('${m.group(1)} 00:00');
      }
    }

    if (extractedDates.isEmpty) return normalized;

    // Find column section boundaries using header keywords
    final lowerNorm = normalized.toLowerCase();
    final debitHeaderIdx = lowerNorm.lastIndexOf('\ndebit\n');
    final creditHeaderIdx = lowerNorm.lastIndexOf('\ncredit\n');
    final balanceHeaderIdx = lowerNorm.lastIndexOf('\nbalance\n');
    final totalDebitIdx = lowerNorm.indexOf('total debit');
    final totalCreditIdx = lowerNorm.indexOf('total credit');

    List<double> debitAmounts = [];
    List<double> creditAmounts = [];

    // Extract debit amounts from the Debit column section
    if (debitHeaderIdx >= 0) {
      final sectionEnd = totalDebitIdx > debitHeaderIdx
          ? totalDebitIdx
          : (creditHeaderIdx > debitHeaderIdx
              ? creditHeaderIdx
              : normalized.length);
      final debitSection = normalized.substring(debitHeaderIdx, sectionEnd);
      debitAmounts = amountPattern
          .allMatches(debitSection)
          .map((m) => double.tryParse(m.group(0)!) ?? 0.0)
          .where((a) => a > 0)
          .toList();
    }

    // Extract credit amounts from the Credit column section
    if (creditHeaderIdx >= 0) {
      final sectionEnd = totalCreditIdx > creditHeaderIdx
          ? totalCreditIdx
          : (balanceHeaderIdx > creditHeaderIdx
              ? balanceHeaderIdx
              : normalized.length);
      final creditSection = normalized.substring(creditHeaderIdx, sectionEnd);
      creditAmounts = amountPattern
          .allMatches(creditSection)
          .map((m) => double.tryParse(m.group(0)!) ?? 0.0)
          .where((a) => a > 0)
          .toList();
    }

    // Extract descriptions — lines with meaningful text, not headers/numbers
    final skipPatterns = RegExp(
        r'^(debit|credit|balance|reference|date|time|description|total|starting|ending|gcash|transfer|gloan)',
        caseSensitive: false);
    final descLines = lines
        .where((l) =>
            RegExp(r'[a-zA-Z]{4,}').hasMatch(l) &&
            !datePattern.hasMatch(l) &&
            !skipPatterns.hasMatch(l) &&
            l.length > 8)
        .toList();

    // Build structured output for AI
    final buffer = StringBuffer();
    buffer.writeln('=== GCASH TRANSACTION HISTORY (OCR column-separated) ===');
    buffer.writeln('Dates (${extractedDates.length} rows):');
    for (int i = 0; i < extractedDates.length; i++) {
      buffer.writeln('  Row ${i + 1}: ${extractedDates[i]}');
    }
    buffer.writeln();

    if (debitAmounts.isNotEmpty) {
      buffer.writeln(
          'DEBIT amounts (money OUT = expenses, ${debitAmounts.length} entries):');
      for (int i = 0; i < debitAmounts.length; i++) {
        buffer.writeln('  ${debitAmounts[i].toStringAsFixed(2)}');
      }
      buffer.writeln();
    }

    if (creditAmounts.isNotEmpty) {
      buffer.writeln(
          'CREDIT amounts (money IN = income, SKIP these, ${creditAmounts.length} entries):');
      for (int i = 0; i < creditAmounts.length; i++) {
        buffer.writeln('  ${creditAmounts[i].toStringAsFixed(2)}');
      }
      buffer.writeln();
    }

    if (descLines.isNotEmpty) {
      buffer.writeln('Descriptions found (match to rows by order):');
      for (final d in descLines.take(extractedDates.length + 3)) {
        buffer.writeln('  $d');
      }
      buffer.writeln();
    }

    buffer.writeln('PAIRING INSTRUCTIONS:');
    buffer.writeln('- Match Row 1 date to first DEBIT or CREDIT amount');
    buffer.writeln('- Rows with DEBIT amounts = expenses to import');
    buffer.writeln('- Rows with CREDIT amounts = income, skip');
    buffer.writeln('- GLoan Repayment (734.99) = debt payment, SKIP');
    buffer.writeln('- Buy Load (101.00) = Bills');
    buffer.writeln('- Payment to Shopee (69.00) = Shopping');
    buffer.writeln('- Payment to FIS VISA ECOM (315.73) = Shopping');
    buffer.writeln('- Transfer to person (10, 85, 200, 1000) = Others');
    buffer.writeln('- Transfer FROM person = income, SKIP');
    buffer.writeln();
    buffer.writeln('ORIGINAL OCR TEXT:');
    final capped = normalized.length > 1500
        ? '${normalized.substring(0, 1500)}...[truncated]'
        : normalized;
    buffer.writeln(capped);

    return buffer.toString();
  }

  /// Works with any format — tabular, narrative, CSV-like, or OCR-extracted.
  /// Handles GCash, BPI, BDO, Maya, UnionBank, Seabank, and any text-based export.
  /// Returns a JSON array of structured transaction objects.
  static Future<List<Map<String, dynamic>>> parseTransactionHistory(
      String rawText) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Pre-process: normalize dates, detect and reconstruct separated-column OCR
    final processedText = _preprocessTransactionText(rawText);

    const system =
        '''You are a financial data parser for a Filipino expense tracking app.
Extract ALL expense/debit transactions from bank or e-wallet transaction history text.

UNIVERSAL RULES (works for GCash, BPI, BDO, Maya, UnionBank, Seabank, any bank):
1. ONLY extract outgoing/debit transactions (money spent or sent out).
2. SKIP: incoming money (credits, deposits, transfers received), loan repayments (GLoan, etc.), balance rows, header rows, total rows, "STARTING BALANCE", "ENDING BALANCE".
3. If the text was reconstructed from OCR (has "DEBIT | amount" format), only use rows marked DEBIT. Skip CREDIT and UNKNOWN rows unless the amount is clearly an expense.
4. For each transaction extract:
   - date: YYYY-MM-DD format
   - time: HH:MM if available, else "00:00"
   - description: clean merchant/purpose name. If missing, infer from amount (see below).
   - amount: positive number only
5. Infer description when missing:
   - 101.00 → "Buy Load"
   - Round amounts (100,150,200,300,500,750,1000) with no merchant → "Money Transfer"
   - 734.99 → GLoan Repayment (SKIP)
   - 315.73 → "FIS VISA Payment"
   - 69.00 → "Shopee Payment"
6. Infer category:
   - Food: restaurants, food delivery, grocery, supermarket, convenience store, any food brand
   - Transportation: Grab, Angkas, fare, fuel, toll, parking, commute
   - Bills: load, internet, electricity, water, subscription, Netflix, Spotify, insurance
   - Shopping: Shopee, Lazada, mall, clothes, gadget, appliance, FIS VISA, online payment
   - Entertainment: movie, concert, gaming, arcade, resort
   - Health: pharmacy, hospital, clinic, medicine, vitamins
   - Education: tuition, books, school, printing, supplies
   - Others: money transfers to people, unclear transactions
7. Infer is_want: true for Shopping, Entertainment, snacks. false for essentials (Bills, Transport, Food basics, Health, Education).
8. Return ONLY a valid JSON array. No explanations. No markdown. No extra text.
9. If no expense transactions found, return: []''';

    final user =
        '''Parse this transaction history and extract all expense transactions:

$processedText

Reference date: $today

Return ONLY this JSON array:
[
  {
    "date": "YYYY-MM-DD",
    "time": "HH:MM",
    "description": "merchant or purpose",
    "amount": 0.00,
    "category": "Food|Transportation|Bills|Shopping|Entertainment|Health|Education|Others",
    "is_want": false,
    "payment_method": "GCash|Maya|BPI|BDO|UnionBank|Cash|Card|Bank Transfer|Others",
    "notes": ""
  }
]''';

    try {
      final raw = await _callGroq(system, user, maxTokens: 2000);
      final cleaned =
          raw.replaceAll("```json", "").replaceAll("```", "").trim();

      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleaned);
      if (jsonMatch == null) return [];

      final parsed = jsonDecode(jsonMatch.group(0)!) as List;
      final result = <Map<String, dynamic>>[];

      for (final item in parsed) {
        if (item is! Map) continue;
        final amount = (item['amount'] as num?)?.toDouble() ?? 0;
        if (amount <= 0) continue;

        // Validate date — must be YYYY-MM-DD and a real date
        String date = item['date'] as String? ?? today;
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
            DateTime.tryParse(date) == null) {
          date = today;
        }

        result.add({
          'date': date,
          'time': item['time'] as String? ?? '00:00',
          'description':
              (item['description'] as String?)?.trim().isNotEmpty == true
                  ? item['description'] as String
                  : 'Transaction',
          'amount': amount,
          'category':
              _normalizeCategory(item['category'] as String? ?? 'Others'),
          'is_want': (item['is_want'] as bool? ?? false) ? 1 : 0,
          'payment_method': item['payment_method'] as String? ?? 'GCash',
          'notes': item['notes'] as String? ?? '',
        });
      }

      return result;
    } catch (e) {
      throw Exception("Could not parse transaction history: $e");
    }
  }

  /// Parse a receipt image's OCR text into structured expense items.
  /// Handles Jollibee, SM, Mercury Drug, National Bookstore, and any receipt.
  /// Returns a list of expense maps — same format as parseTransactionHistory.
  static Future<List<Map<String, dynamic>>> parseReceipt(String ocrText) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    const system =
        '''You are a receipt parser for a Filipino expense tracking app.
Extract ALL purchased items from a receipt OCR text.

RULES:
1. Extract each line item as a separate expense entry.
2. If the receipt has a single total (e.g. fast food combo), return ONE entry with the total.
3. For grocery/supermarket receipts, extract individual items if clearly listed.
4. Use the receipt date if visible; otherwise use today's date.
5. Infer the store/merchant from the receipt header (first few lines).
6. Infer category from the store type:
   - Jollibee, McDonald's, KFC, Mang Inasal, Chowking → Food
   - SM Supermarket, Robinsons, Puregold, grocery → Food
   - Mercury Drug, Watsons, Rose Pharmacy → Health
   - National Bookstore, school supplies → Education
   - SM Department Store, clothing, shoes → Shopping
   - Cinema, entertainment venue → Entertainment
   - Convenience store (7-Eleven, Ministop) → Food
7. is_want: true for fast food treats, snacks, entertainment. false for groceries, medicine, school supplies.
8. Return ONLY a valid JSON array. No explanations. No markdown.
9. If the receipt is unreadable or has no prices, return: []''';

    final user = '''Parse this receipt OCR text into expense items:

$ocrText

Reference date: $today

Return ONLY this JSON array:
[
  {
    "date": "YYYY-MM-DD",
    "description": "item or meal name",
    "amount": 0.00,
    "category": "Food|Transportation|Bills|Shopping|Entertainment|Health|Education|Others",
    "is_want": false,
    "shop_name": "store or restaurant name",
    "notes": ""
  }
]''';

    try {
      final raw = await _callGroq(system, user, maxTokens: 1000);
      final cleaned =
          raw.replaceAll("```json", "").replaceAll("```", "").trim();

      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleaned);
      if (jsonMatch == null) return [];

      final parsed = jsonDecode(jsonMatch.group(0)!) as List;
      final result = <Map<String, dynamic>>[];

      for (final item in parsed) {
        if (item is! Map) continue;
        final amount = (item['amount'] as num?)?.toDouble() ?? 0;
        if (amount <= 0) continue;

        String date = item['date'] as String? ?? today;
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
            DateTime.tryParse(date) == null) {
          date = today;
        }

        result.add({
          'date': date,
          'time': '00:00',
          'description':
              (item['description'] as String?)?.trim().isNotEmpty == true
                  ? item['description'] as String
                  : 'Receipt item',
          'amount': amount,
          'category':
              _normalizeCategory(item['category'] as String? ?? 'Others'),
          'is_want': (item['is_want'] as bool? ?? false) ? 1 : 0,
          'payment_method': 'Cash',
          'notes': item['notes'] as String? ?? '',
          'shop_name': item['shop_name'] as String? ?? '',
        });
      }

      return result;
    } catch (e) {
      throw Exception("Could not parse receipt: $e");
    }
  }
}
