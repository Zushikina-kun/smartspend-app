import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'app_config.dart';

class LLMService {
  static String get _groqKey => AppConfig.groqApiKey;
  static String get _groqUrl => AppConfig.groqBaseUrl;
  static String get _groqModel => AppConfig.groqModel;

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
- Shopping: online shopping, Lazada, Shopee, gadget, appliance, accessories, SM, Ayala, Robinsons, mall
- Entertainment: movie, cinema, concert, arcade, bar, videoke, karaoke, event, ticket
- Gaming: Steam, Mobile Legends, MLBB, CODM, Roblox, Genshin, Valorant, Dota, game top-up, Codashop, UniPin, Xbox, PlayStation, Nintendo, esports, gaming
- Health: medicine, hospital, clinic, doctor, pharmacy, vitamins, dental, dentist, glasses, eyeglasses, gamot, botika, Mercury Drug, Watsons
- Education: tuition, books, school supplies, course, training, seminar, uniform
- Personal Care: haircut, salon, barbershop, nail, spa, massage, shampoo, soap, toothpaste, deodorant, lotion, hygiene
- Clothing: shirt, pants, jeans, dress, shoes, sneakers, jacket, hoodie, ukay, clothes, outfit, fashion
- Gifts: gift, pasalubong, present, souvenir, donation, charity
- Travel: hotel, airfare, airline, flight, Cebu Pacific, AirAsia, resort, tour, booking, Airbnb, hostel
- Pets: pet food, dog food, cat food, veterinary, vet, Pedigree, Whiskas
- Others: anything that doesn't fit above

CRITICAL: Candy, chips, biscuits, chocolate, ice cream, cake, bread, drinks — ALL go to Food, not Others.

Payment method rules:
- Cash: default if not mentioned
- GCash: gcash, g-cash
- Maya: maya, paymaya
- GrabPay: grabpay, grab pay
- ShopeePay: shopeepay, shopee pay
- Debit Card: debit card, atm card
- Credit Card: credit card, visa, mastercard, amex
- Bank Transfer: bank transfer, instapay, pesonet, online banking
- Others: anything else

Want vs Need rules (is_want field):
- is_want: true for discretionary/optional spending: Shopping, Entertainment, snacks, candy, chips, fast food treats, coffee shop drinks, gaming, concerts, vacations, accessories, cosmetics
- is_want: false (Need) for essentials: groceries, medicine, transport fare, bills, tuition, rent, utilities, basic meals
- When in doubt, lean toward false (Need)''';

    final user = '''Extract expense from: "$input"
Today's date: $today, current time: $now

Return ONLY this JSON:
{
  "item_name": "specific item or meal name",
  "category": "one of: Food, Transportation, Bills, Shopping, Entertainment, Gaming, Health, Education, Personal Care, Clothing, Gifts, Travel, Pets, Others",
  "amount": 0,
  "date": "$today",
  "time": "$now",
  "payment_method": "Cash|GCash|Maya|GrabPay|ShopeePay|Debit Card|Credit Card|Bank Transfer|Others",
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
      'Gaming',
      'Health',
      'Education',
      'Personal Care',
      'Clothing',
      'Gifts',
      'Travel',
      'Pets',
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

    // ── GAMING ────────────────────────────────────────────────────────────────
    if (lower.contains('steam') ||
        lower.contains('mobile legend') ||
        lower.contains('mlbb') ||
        lower.contains('codm') ||
        lower.contains('roblox') ||
        lower.contains('genshin') ||
        lower.contains('valorant') ||
        lower.contains('dota') ||
        lower.contains('top-up') ||
        lower.contains('topup') ||
        lower.contains('codashop') ||
        lower.contains('unipin') ||
        lower.contains('xbox') ||
        lower.contains('playstation') ||
        lower.contains('nintendo') ||
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
        lower.contains('soap') ||
        lower.contains('toothpaste') ||
        lower.contains('deodorant') ||
        lower.contains('lotion') ||
        lower.contains('hygiene')) return 'Personal Care';

    // ── CLOTHING ──────────────────────────────────────────────────────────────
    if (lower.contains('jeans') ||
        lower.contains('dress') ||
        lower.contains('sneakers') ||
        lower.contains('jacket') ||
        lower.contains('hoodie') ||
        lower.contains('clothing') ||
        lower.contains('outfit') ||
        lower.contains('fashion')) return 'Clothing';

    // ── GIFTS ─────────────────────────────────────────────────────────────────
    if (lower.contains('pasalubong') ||
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
        lower.contains('airbnb') ||
        lower.contains('hostel')) return 'Travel';

    // ── PETS ──────────────────────────────────────────────────────────────────
    if (lower.contains('pet food') ||
        lower.contains('dog food') ||
        lower.contains('cat food') ||
        lower.contains('veterinar') ||
        lower.contains('pedigree') ||
        lower.contains('whiskas')) return 'Pets';

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
    "category": "Food|Transportation|Bills|Shopping|Entertainment|Gaming|Health|Education|Personal Care|Clothing|Gifts|Travel|Pets|Others",
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
    "category": "Food|Transportation|Bills|Shopping|Entertainment|Gaming|Health|Education|Personal Care|Clothing|Gifts|Travel|Pets|Others",
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

  // ── SCREENSHOT / DIGITAL RECEIPT PARSER ───────────────────────────────────

  /// Detect the type of screenshot from its OCR text.
  /// Covers PH local + international shopping, gaming, payments, food delivery,
  /// banks, streaming, telco, and physical receipt types.
  static String detectScreenshotType(String text) {
    final lower = text.toLowerCase();

    // ── GAMING / DIGITAL STORES ───────────────────────────────────────────────
    if (lower.contains('steam') ||
        lower.contains('valve corporation') ||
        lower.contains('steamworks')) return 'steam';
    if (lower.contains('google play') ||
        lower.contains('play store') ||
        lower.contains('google payment')) return 'google_play';
    if ((lower.contains('app store') ||
        lower.contains('itunes') ||
        lower.contains('apple.com/bill') ||
        (lower.contains('apple') && lower.contains('receipt'))))
      return 'apple_appstore';
    if (lower.contains('codashop') || lower.contains('coda shop'))
      return 'codashop';
    if (lower.contains('unipin')) return 'unipin';
    if (lower.contains('garena')) return 'garena';
    if (lower.contains('moonton') || lower.contains('mobile legends'))
      return 'mobile_legends';
    if (lower.contains('riot games') || lower.contains('valorant'))
      return 'riot';
    if (lower.contains('mihoyo') ||
        lower.contains('hoyoverse') ||
        lower.contains('genshin')) return 'hoyoverse';
    if (lower.contains('playstation') ||
        lower.contains('psn') ||
        lower.contains('ps store')) return 'playstation';
    if (lower.contains('xbox') || lower.contains('microsoft store'))
      return 'xbox';
    if (lower.contains('nintendo') || lower.contains('eshop'))
      return 'nintendo';
    if (lower.contains('epic games') || lower.contains('epicgames'))
      return 'epic';

    // ── PH LOCAL E-WALLETS / PAYMENTS ─────────────────────────────────────────
    if (lower.contains('gcash')) return 'gcash';
    if (lower.contains('maya') || lower.contains('paymaya')) return 'maya';
    if (lower.contains('grabpay') || lower.contains('grab pay'))
      return 'grabpay';
    if (lower.contains('shopeepay') ||
        lower.contains('shopee pay') ||
        lower.contains('spaylater')) return 'shopeepay';
    if (lower.contains('coins.ph') || lower.contains('coinsph'))
      return 'coins_ph';
    if (lower.contains('paymongo')) return 'paymongo';
    if (lower.contains('paypal')) return 'paypal';
    if (lower.contains('wise') || lower.contains('transferwise')) return 'wise';
    if (lower.contains('remitly') ||
        lower.contains('western union') ||
        lower.contains('moneygram')) return 'remittance';
    if (lower.contains('stripe')) return 'stripe';

    // ── PH LOCAL SHOPPING ─────────────────────────────────────────────────────
    if (lower.contains('shopee')) return 'shopee';
    if (lower.contains('lazada') ||
        lower.contains('lazwallet') ||
        lower.contains('lcash')) return 'lazada';
    if (lower.contains('zalora')) return 'zalora';
    if (lower.contains('tiktok shop') || lower.contains('tiktokshop'))
      return 'tiktok_shop';
    if (lower.contains('carousell')) return 'carousell';
    if (lower.contains('facebook marketplace') ||
        lower.contains('fb marketplace')) return 'fb_marketplace';

    // ── INTERNATIONAL SHOPPING ────────────────────────────────────────────────
    if (lower.contains('amazon') &&
        (lower.contains('order') ||
            lower.contains('invoice') ||
            lower.contains('purchase'))) return 'amazon';
    if (lower.contains('ebay')) return 'ebay';
    if (lower.contains('aliexpress')) return 'aliexpress';
    if (lower.contains('shein')) return 'shein';
    if (lower.contains('temu')) return 'temu';
    if (lower.contains('zalando')) return 'zalando';
    if (lower.contains('asos')) return 'asos';
    if (lower.contains('taobao') || lower.contains('tmall')) return 'taobao';
    if (lower.contains('etsy')) return 'etsy';
    if (lower.contains('wish.com') || lower.contains('wish order'))
      return 'wish';

    // ── FOOD DELIVERY ─────────────────────────────────────────────────────────
    if (lower.contains('grabfood') || lower.contains('grab food'))
      return 'grabfood';
    if (lower.contains('foodpanda') || lower.contains('food panda'))
      return 'foodpanda';
    if (lower.contains('shopee food')) return 'shopee_food';

    // ── GRAB RIDES ────────────────────────────────────────────────────────────
    if (lower.contains('grab') &&
        (lower.contains('order') ||
            lower.contains('ride') ||
            lower.contains('car') ||
            lower.contains('bike') ||
            lower.contains('delivery'))) return 'grab';
    if (lower.contains('angkas')) return 'angkas';
    if (lower.contains('lalamove')) return 'lalamove';
    if (lower.contains('maxim')) return 'maxim';

    // ── PH BANKS ─────────────────────────────────────────────────────────────
    if (lower.contains('bpi') &&
        (lower.contains('transaction') ||
            lower.contains('transfer') ||
            lower.contains('payment'))) return 'bpi';
    if (lower.contains('bdo') &&
        (lower.contains('transaction') || lower.contains('transfer')))
      return 'bdo';
    if (lower.contains('metrobank')) return 'metrobank';
    if (lower.contains('unionbank') || lower.contains('union bank'))
      return 'unionbank';
    if (lower.contains('landbank')) return 'landbank';
    if (lower.contains('gotyme') || lower.contains('go tyme')) return 'gotyme';
    if (lower.contains('tonik')) return 'tonik';
    if (lower.contains('seabank')) return 'seabank';
    if (lower.contains('rcbc')) return 'rcbc';
    if (lower.contains('security bank')) return 'security_bank';

    // ── STREAMING / SUBSCRIPTIONS ─────────────────────────────────────────────
    if (lower.contains('netflix')) return 'netflix';
    if (lower.contains('spotify')) return 'spotify';
    if (lower.contains('youtube premium') || lower.contains('youtube music'))
      return 'youtube';
    if (lower.contains('disney+') || lower.contains('disney plus'))
      return 'disney_plus';
    if (lower.contains('viu')) return 'viu';
    if (lower.contains('vivamax')) return 'vivamax';
    if (lower.contains('hbo') || lower.contains('max')) return 'streaming';

    // ── TELCO / LOAD ──────────────────────────────────────────────────────────
    if (lower.contains('smart') &&
        (lower.contains('prepaid') || lower.contains('load'))) return 'smart';
    if (lower.contains('globe') &&
        (lower.contains('prepaid') || lower.contains('load'))) return 'globe';
    if (lower.contains('dito')) return 'dito';

    // ── PHYSICAL RECEIPTS ─────────────────────────────────────────────────────
    if (lower.contains('jollibee') ||
        lower.contains('mcdonald') ||
        lower.contains('mcdo') ||
        lower.contains('kfc') ||
        lower.contains('mang inasal') ||
        lower.contains('chowking') ||
        lower.contains('greenwich') ||
        lower.contains('shakey') ||
        lower.contains('starbucks') ||
        lower.contains('dunkin')) return 'receipt_fastfood';
    if (lower.contains('sm supermarket') ||
        lower.contains('robinsons supermarket') ||
        lower.contains('puregold') ||
        lower.contains('savemore') ||
        lower.contains('shopwise') ||
        lower.contains('waltermart') ||
        lower.contains('landers') ||
        lower.contains('costco')) return 'receipt_grocery';
    if (lower.contains('mercury drug') ||
        lower.contains('watsons') ||
        lower.contains('rose pharmacy') ||
        lower.contains('generika') ||
        lower.contains('southstar drug')) return 'receipt_pharmacy';
    if (lower.contains('national bookstore') ||
        lower.contains('powerbooks') ||
        lower.contains('fullybooked')) return 'receipt_bookstore';
    if ((lower.contains('meralco') ||
            lower.contains('pldt') ||
            lower.contains('maynilad') ||
            lower.contains('manila water')) &&
        lower.contains('amount')) return 'receipt_utility';
    if (lower.contains('total') ||
        lower.contains('subtotal') ||
        lower.contains('amount due') ||
        lower.contains('grand total')) return 'receipt';

    // ── GENERIC TRANSACTION HISTORY ──────────────────────────────────────────
    if (RegExp(r'\d{4}-\d{2}-\d{2}').allMatches(text).length >= 3)
      return 'transaction_history';

    return 'unknown';
  }

  /// Parse OCR text from a screenshot into structured expense items.
  /// Parse OCR text from a screenshot into structured expense items.
  /// Screenshot-aware: works with all platform types from detectScreenshotType.
  /// Extracts: date, TIME (when visible), item name, price, store, category.
  /// Returns same format as parseReceipt / parseTransactionHistory.
  static Future<List<Map<String, dynamic>>> parseScreenshot(
      String ocrText, String screenshotType) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final typeHint = _buildTypeHint(screenshotType);

    final system =
        '''You are a financial data extractor for a Filipino expense tracking app.
Extract purchases/transactions from screenshot OCR text.

CONTEXT: $typeHint

EXTRACTION RULES:
1. Extract every distinct purchase or transaction line.
2. item_name: use the EXACT product/game/item/service name. NEVER use "your purchase", "item", "payment", "transaction". Use what the screenshot says.
3. amount: the amount the user PAID (after discounts). Skip refunds, credits, cashback.
4. date: use the date from the screenshot (YYYY-MM-DD). Use today if missing.
5. time: extract the TIME if visible (24h HH:MM format). GCash/Maya/bank show exact times — extract them. Convert 12h to 24h (e.g. 2:30 PM → 14:30). Use "" if not visible.
6. shop_name: platform, seller, restaurant, or store name.
7. category: infer from item name and platform type (see CATEGORY MAP).
8. is_want: true for games, entertainment, dining out, fashion, non-essentials. false for groceries, medicine, transport, bills, utilities.
9. payment_method: detect from screenshot (GCash, Maya, ShopeePay, SPaylater, Credit Card, Debit Card, COD, GrabPay, PayPal, Bank Transfer, Wise). Default "Cash".
10. MULTIPLE items in one order → SEPARATE entry per item with its own price.
11. TOTAL only visible → ONE entry named after the store/platform.
12. Return ONLY a valid JSON array. No extra text. No markdown. Empty [] if nothing extractable.

CATEGORY MAP:
- Gaming: Steam games/DLC, Google Play/App Store games, Codashop, UniPin, Garena, MLBB, Genshin, Valorant, any game top-up
- Shopping: Shopee, Lazada, Zalora, TikTok Shop, Amazon, AliExpress, Shein, Temu, any physical goods
- Food: GrabFood, Foodpanda, restaurants, fast food, cafes, any food/drink
- Transportation: Grab ride, Angkas, Lalamove, Maxim, jeep, bus, fare, fuel
- Bills: Netflix, Spotify, streaming subscriptions, utilities, internet, rent, insurance, telco load
- Health: pharmacy, medicine, clinic, hospital, doctor
- Education: tuition, books, school supplies, courses
- Personal Care: salon, spa, barbershop, hygiene products
- Clothing: clothing, shoes, fashion items, accessories
- Travel: flights, hotels, Airbnb, tours
- Gifts: gifts, donations, charity
- Others: anything else''';

    final user = '''Screenshot OCR text (type: $screenshotType):

$ocrText

Today's date: $today

Return ONLY this JSON array:
[
  {
    "date": "YYYY-MM-DD",
    "time": "HH:MM in 24h format, or empty string",
    "item_name": "exact product or service name",
    "amount": 0.00,
    "category": "Gaming|Shopping|Food|Transportation|Bills|Health|Education|Personal Care|Clothing|Gifts|Travel|Pets|Others",
    "is_want": true,
    "shop_name": "platform, seller, or store",
    "payment_method": "Cash|GCash|Maya|ShopeePay|SPaylater|Credit Card|Debit Card|COD|GrabPay|PayPal|Bank Transfer|Wise|Remittance",
    "notes": ""
  }
]''';

    try {
      final raw = await _callGroq(system, user, maxTokens: 1400);
      final cleaned =
          raw.replaceAll('```json', '').replaceAll('```', '').trim();
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

        // Validate and normalise time
        String time = (item['time'] as String? ?? '').trim();
        if (time.isNotEmpty &&
            !RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(time)) {
          time = '';
        }
        if (time.isEmpty) time = '00:00';

        // Sanitise item name
        String name = (item['item_name'] as String? ??
                item['description'] as String? ??
                'Purchase')
            .trim();
        name = name
            .replaceFirst(
                RegExp(r'^(your |my |the |a |an )', caseSensitive: false), '')
            .replaceFirst(RegExp(r'\s+for\s*.*$', caseSensitive: false), '')
            .trim();
        if (name.isEmpty) name = 'Purchase';
        if (name.isNotEmpty) name = name[0].toUpperCase() + name.substring(1);

        result.add({
          'date': date,
          'time': time,
          'description': name,
          'amount': amount,
          'category':
              _normalizeCategory(item['category'] as String? ?? 'Others'),
          'is_want': (item['is_want'] as bool? ?? true) ? 1 : 0,
          'payment_method': item['payment_method'] as String? ?? 'Cash',
          'notes': item['notes'] as String? ?? '',
          'shop_name': item['shop_name'] as String? ?? '',
        });
      }
      return result;
    } catch (e) {
      throw Exception('Could not parse screenshot: $e');
    }
  }

  /// Build a context hint string for the AI based on detected screenshot type.
  static String _buildTypeHint(String type) {
    switch (type) {
      case 'steam':
        return 'Steam (Valve) purchase. Items = PC games, DLCs, in-game items, Steam Wallet top-ups. category=Gaming. is_want=true. shop_name="Steam". Time shown in confirmations — extract it.';
      case 'google_play':
        return 'Google Play Store purchase. Items = Android apps, games, in-app purchases, subscriptions. category=Gaming for games, Bills for subscriptions. shop_name = app name or "Google Play".';
      case 'apple_appstore':
        return 'Apple App Store / iTunes receipt. category=Gaming for games/apps, Bills for subscriptions. shop_name = app name or "App Store".';
      case 'codashop':
        return 'Codashop top-up. Items = mobile game top-ups (MLBB diamonds, FF diamonds, etc.). category=Gaming. is_want=true. shop_name="Codashop".';
      case 'unipin':
        return 'UniPin voucher/top-up. category=Gaming. shop_name="UniPin".';
      case 'garena':
        return 'Garena (Free Fire, AOV) top-up. category=Gaming. shop_name="Garena".';
      case 'mobile_legends':
        return 'Mobile Legends / Moonton purchase. category=Gaming. shop_name="Mobile Legends".';
      case 'riot':
        return 'Riot Games (Valorant, LoL) purchase. category=Gaming. shop_name="Riot Games".';
      case 'hoyoverse':
        return 'Hoyoverse (Genshin Impact, HSR) top-up. category=Gaming.';
      case 'playstation':
        return 'PlayStation Store purchase. category=Gaming. shop_name="PlayStation Store".';
      case 'xbox':
        return 'Xbox / Microsoft Store purchase. category=Gaming. shop_name="Xbox Store".';
      case 'nintendo':
        return 'Nintendo eShop purchase. category=Gaming. shop_name="Nintendo eShop".';
      case 'epic':
        return 'Epic Games Store purchase. category=Gaming. shop_name="Epic Games".';
      case 'gcash':
        return 'GCash transaction. Extract OUTGOING only (Send Money, Pay, QR Pay, Buy Load, Cash Out, Pay Bills). SKIP incoming (Receive Money, Cash In). payment_method="GCash". Time is shown — extract it (convert 12h to 24h).';
      case 'maya':
        return 'Maya (PayMaya) transaction. Extract outgoing payments/purchases. Skip incoming. payment_method="Maya". Extract time if shown.';
      case 'grabpay':
        return 'GrabPay transaction. Extract outgoing. payment_method="GrabPay".';
      case 'shopeepay':
        return 'ShopeePay or SPaylater. Extract outgoing payments. For SPaylater installments, use the installment amount charged. payment_method="ShopeePay" or "SPaylater".';
      case 'coins_ph':
        return 'Coins.ph transaction. Extract outgoing. payment_method="Coins.ph".';
      case 'paypal':
        return 'PayPal receipt. Extract payment amount in PHP (or convert from USD). payment_method="PayPal".';
      case 'wise':
        return 'Wise transfer receipt. Extract amount sent. payment_method="Wise".';
      case 'remittance':
        return 'Remittance (Western Union, Remitly, MoneyGram). Extract amount sent. category=Others.';
      case 'paymongo':
        return 'PayMongo receipt. Extract charged amount and merchant name.';
      case 'stripe':
        return 'Stripe receipt. Extract charged amount and product/service name.';
      case 'shopee':
        return 'Shopee order. Extract each item separately. shop_name = seller name or "Shopee". Detect payment (ShopeePay, SPaylater, GCash, COD, Credit Card).';
      case 'lazada':
        return 'Lazada order. Extract each item. shop_name = seller or "Lazada". Detect payment method.';
      case 'zalora':
        return 'Zalora fashion order. category=Clothing. shop_name="Zalora".';
      case 'tiktok_shop':
        return 'TikTok Shop order. Extract items and seller name.';
      case 'carousell':
        return 'Carousell purchase. Extract item and amount.';
      case 'fb_marketplace':
        return 'Facebook Marketplace transaction. Extract item and amount.';
      case 'amazon':
        return 'Amazon order. Extract items and prices (convert to PHP if USD). shop_name = seller or "Amazon".';
      case 'ebay':
        return 'eBay purchase. shop_name = seller or "eBay".';
      case 'aliexpress':
        return 'AliExpress order. Extract items. shop_name = seller or "AliExpress".';
      case 'shein':
        return 'SHEIN order. category=Clothing. shop_name="SHEIN".';
      case 'temu':
        return 'Temu order. shop_name="Temu".';
      case 'zalando':
        return 'Zalando order. category=Clothing. shop_name="Zalando".';
      case 'asos':
        return 'ASOS order. category=Clothing. shop_name="ASOS".';
      case 'taobao':
        return 'Taobao/Tmall order. Convert CNY to PHP (×7.5 approx) if needed. shop_name = store or "Taobao".';
      case 'etsy':
        return 'Etsy purchase. shop_name = seller or "Etsy".';
      case 'wish':
        return 'Wish order. shop_name="Wish".';
      case 'grabfood':
        return 'GrabFood order. category=Food. is_want=true. shop_name = restaurant. Extract time if shown.';
      case 'foodpanda':
        return 'Foodpanda order. category=Food. is_want=true. shop_name = restaurant.';
      case 'shopee_food':
        return 'Shopee Food order. category=Food. is_want=true. shop_name = restaurant.';
      case 'grab':
        return 'Grab ride (Car/Bike). category=Transportation. is_want=false. shop_name="Grab". Extract time.';
      case 'angkas':
        return 'Angkas ride. category=Transportation. is_want=false. shop_name="Angkas".';
      case 'lalamove':
        return 'Lalamove delivery. category=Transportation. shop_name="Lalamove".';
      case 'maxim':
        return 'Maxim ride. category=Transportation. is_want=false. shop_name="Maxim".';
      case 'bpi':
      case 'bdo':
      case 'metrobank':
      case 'unionbank':
      case 'landbank':
      case 'rcbc':
      case 'security_bank':
      case 'gotyme':
      case 'tonik':
      case 'seabank':
        final bName = {
              'bpi': 'BPI',
              'bdo': 'BDO',
              'metrobank': 'Metrobank',
              'unionbank': 'UnionBank',
              'landbank': 'Landbank',
              'rcbc': 'RCBC',
              'security_bank': 'Security Bank',
              'gotyme': 'GoTyme',
              'tonik': 'Tonik',
              'seabank': 'SeaBank'
            }[type] ??
            type;
        return '$bName bank transaction. Extract OUTGOING payments only. Skip incoming credits. Extract time if visible. payment_method="$bName".';
      case 'netflix':
        return 'Netflix subscription. category=Bills. is_want=true. shop_name="Netflix".';
      case 'spotify':
        return 'Spotify subscription. category=Bills. is_want=true. shop_name="Spotify".';
      case 'youtube':
        return 'YouTube Premium/Music. category=Bills. is_want=true. shop_name="YouTube".';
      case 'disney_plus':
        return 'Disney+ subscription. category=Bills. is_want=true. shop_name="Disney+".';
      case 'viu':
        return 'Viu subscription. category=Bills. shop_name="Viu".';
      case 'vivamax':
        return 'Vivamax subscription. category=Bills. shop_name="Vivamax".';
      case 'streaming':
        return 'Streaming subscription charge. category=Bills.';
      case 'smart':
        return 'Smart telco/load. category=Bills. shop_name="Smart".';
      case 'globe':
        return 'Globe telco/load. category=Bills. shop_name="Globe".';
      case 'dito':
        return 'DITO load/bill. category=Bills. shop_name="DITO".';
      case 'receipt_fastfood':
        return 'Fast food or café receipt. category=Food. shop_name = restaurant from header. Extract individual items if listed.';
      case 'receipt_grocery':
        return 'Grocery/supermarket receipt. category=Food. is_want=false. Extract individual items if listed. Non-food items → Shopping.';
      case 'receipt_pharmacy':
        return 'Pharmacy receipt. category=Health. is_want=false. Each medicine = separate entry.';
      case 'receipt_bookstore':
        return 'Bookstore receipt. category=Education. shop_name = bookstore name.';
      case 'receipt_utility':
        return 'Utility bill (Meralco, PLDT, Maynilad). category=Bills. is_want=false. Amount = total due/paid.';
      case 'receipt':
        return 'Physical or digital receipt. Extract all purchased items with prices. Store name is in the first 2-3 lines.';
      case 'transaction_history':
        return 'Transaction history table. Extract OUTGOING transactions only. Each row = one expense.';
      default:
        return 'Purchase screenshot. Extract all transactions, purchases, or orders. Use exact item names.';
    }
  }

  /// Parse OCR text from multiple screenshots in one batch.
  /// Returns a flat list of all extracted transactions across all images.
  static Future<List<Map<String, dynamic>>> parseScreenshotBatch(
      List<Map<String, String>> images) async {
    final results = <Map<String, dynamic>>[];
    // Process in parallel — max 3 concurrent to avoid rate limits
    const batchSize = 3;
    for (var i = 0; i < images.length; i += batchSize) {
      final batch = images.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(
        batch.map((img) =>
            parseScreenshot(img['ocrText'] ?? '', img['type'] ?? 'unknown')
                .catchError((_) => <Map<String, dynamic>>[])),
      );
      for (final r in batchResults) {
        results.addAll(r);
      }
      // Small delay between batches to respect rate limits
      if (i + batchSize < images.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return results;
  }
}
