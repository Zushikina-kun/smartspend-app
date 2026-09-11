import 'db_service.dart';

/// MerchantNormalizationService
///
/// Two responsibilities:
///
/// 1. AUTO-NORMALIZE: Clean a shop name string before storing it.
///    "STEAM" → "Steam", "steam support" → "Steam", "7-eleven" → "7-Eleven"
///
/// 2. DETECT NEAR-DUPLICATES: Find groups of existing shop names in the DB
///    that are likely the same merchant but stored differently.
///    Returns merge suggestions the user can confirm in the Merchant Merge screen.
class MerchantNormalizationService {
  // ── KNOWN ALIASES ────────────────────────────────────────────────────────
  // Map of lowercase variant → canonical display name.
  // Add new entries here as new PH merchants are encountered.
  static const Map<String, String> _aliases = {
    // Steam
    'steam': 'Steam',
    'steam store': 'Steam',
    'steam support': 'Steam',
    'steampowered': 'Steam',
    'steam powered': 'Steam',
    'valve steam': 'Steam',
    // Shopee
    'shopee': 'Shopee',
    'shopee ph': 'Shopee',
    'shopee philippines': 'Shopee',
    'shopeeph': 'Shopee',
    // Lazada
    'lazada': 'Lazada',
    'lazada ph': 'Lazada',
    'lazada philippines': 'Lazada',
    // GCash
    'gcash': 'GCash',
    'g-cash': 'GCash',
    'gcash ph': 'GCash',
    // Maya
    'maya': 'Maya',
    'paymaya': 'Maya',
    'pay maya': 'Maya',
    // Grab
    'grab': 'Grab',
    'grab ph': 'Grab',
    'grabfood': 'GrabFood',
    'grab food': 'GrabFood',
    'grabpay': 'GrabPay',
    'grab pay': 'GrabPay',
    // Jollibee
    'jollibee': 'Jollibee',
    'jollibee foods': 'Jollibee',
    // McDonald's
    'mcdonalds': "McDonald's",
    "mcdonald's": "McDonald's",
    'mcdo': "McDonald's",
    'mc donalds': "McDonald's",
    // Convenience stores
    '7-eleven': '7-Eleven',
    '7eleven': '7-Eleven',
    'seven eleven': '7-Eleven',
    'ministop': 'Ministop',
    'family mart': 'FamilyMart',
    'familymart': 'FamilyMart',
    // Pharmacies
    'mercury drug': 'Mercury Drug',
    'mercurydrug': 'Mercury Drug',
    'watsons': 'Watsons',
    'watson': 'Watsons',
    // Banks & e-wallets
    'bdo': 'BDO',
    'bpi': 'BPI',
    'metrobank': 'Metrobank',
    'landbank': 'Landbank',
    'unionbank': 'UnionBank',
    'union bank': 'UnionBank',
    'gotyme': 'GoTyme',
    'go tyme': 'GoTyme',
    'tonik': 'Tonik',
    'seabank': 'SeaBank',
    'sea bank': 'SeaBank',
    // Government
    'sss': 'SSS',
    'philhealth': 'PhilHealth',
    'pag-ibig': 'Pag-IBIG',
    'pagibig': 'Pag-IBIG',
    'pag ibig': 'Pag-IBIG',
    // Netflix / streaming
    'netflix': 'Netflix',
    'spotify': 'Spotify',
    'youtube': 'YouTube',
    'youtube premium': 'YouTube',
    // Gaming platforms
    'codashop': 'Codashop',
    'coda shop': 'Codashop',
    'unipin': 'UniPin',
    'uni pin': 'UniPin',
    'epic games': 'Epic Games',
    'epicgames': 'Epic Games',
    'playstation store': 'PlayStation Store',
    'psn': 'PlayStation Store',
    'xbox': 'Xbox',
    'nintendo eshop': 'Nintendo eShop',
    // Malls
    'sm': 'SM',
    'sm mall': 'SM',
    'sm supermarket': 'SM Supermarket',
    'robinsons': 'Robinsons',
    'ayala': 'Ayala Mall',
    'puregold': 'Puregold',
    // Delivery
    'foodpanda': 'Foodpanda',
    'food panda': 'Foodpanda',
    'shopee food': 'Shopee Food',
    'shopeefood': 'Shopee Food',
    // Others
    'angkas': 'Angkas',
    'lalamove': 'Lalamove',
    'meralco': 'Meralco',
    'pldt': 'PLDT',
    'globe': 'Globe',
    'smart': 'Smart',
    'dito': 'DITO',
  };

  // ── AUTO-NORMALIZE ────────────────────────────────────────────────────────

  /// Normalizes a shop/merchant name before storing.
  ///
  /// Steps:
  ///   1. Trim whitespace
  ///   2. Check known aliases (case-insensitive) → use canonical name
  ///   3. If no alias match: title-case the name (capitalize each word)
  ///
  /// Examples:
  ///   "STEAM"          → "Steam"
  ///   "steam support"  → "Steam"
  ///   "ATKGEAR"        → "Atkgear"  (no alias — title-cased)
  ///   "jollibee"       → "Jollibee"
  ///   "GCash"          → "GCash"    (already canonical)
  static String normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    final lower = trimmed.toLowerCase();

    // Check known aliases
    final canonical = _aliases[lower];
    if (canonical != null) return canonical;

    // Also check if the trimmed input IS the canonical (already correct casing)
    for (final entry in _aliases.entries) {
      if (entry.value.toLowerCase() == lower) return entry.value;
    }

    // No alias — apply title case (capitalize first letter of each word)
    return trimmed.split(' ').map((word) {
      if (word.isEmpty) return word;
      // Preserve all-caps abbreviations (BDO, SM, etc.) if 2-4 chars
      if (word.length <= 4 && word == word.toUpperCase()) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ── NEAR-DUPLICATE DETECTION ──────────────────────────────────────────────

  /// Find groups of existing shop names that are likely the same merchant.
  /// Returns a list of [MerchantDuplicateGroup] — each group contains
  /// the variants and a suggested canonical name.
  ///
  /// Algorithm:
  ///   1. Fetch all distinct shop names from the DB
  ///   2. Normalize each one
  ///   3. Group names that normalize to the same canonical value
  ///   4. Also catch fuzzy matches: names where one is a prefix/contains of another
  static Future<List<MerchantDuplicateGroup>> detectDuplicates() async {
    final db = await DBService.getDB();
    final rows = await db.rawQuery('''
      SELECT shop_name, COUNT(*) as cnt
      FROM expenses
      WHERE shop_name IS NOT NULL AND shop_name != ''
      GROUP BY shop_name
      ORDER BY cnt DESC
    ''');

    if (rows.length < 2) return [];

    // Build map: canonical → list of (original_name, count)
    final groups = <String, List<_NameCount>>{};
    for (final row in rows) {
      final name = row['shop_name'] as String;
      final cnt = (row['cnt'] as int?) ?? 1;
      final canonical = normalize(name);
      groups.putIfAbsent(canonical, () => []).add(_NameCount(name, cnt));
    }

    // Also do fuzzy grouping for cases normalize() doesn't catch
    // (e.g., "ATKGEAR" vs "Atkgear" after title-case both become the same)
    // These are already handled by normalize → same canonical key.
    // For truly fuzzy (Levenshtein), we do a simple contains/prefix check:
    final allNames = rows.map((r) => r['shop_name'] as String).toList();
    for (int i = 0; i < allNames.length; i++) {
      for (int j = i + 1; j < allNames.length; j++) {
        final a = allNames[i].toLowerCase().trim();
        final b = allNames[j].toLowerCase().trim();
        // Skip if already in the same group
        final canonA = normalize(allNames[i]);
        final canonB = normalize(allNames[j]);
        if (canonA == canonB) continue; // already grouped

        // Check if one contains the other and they share a significant prefix
        if ((a.contains(b) || b.contains(a)) && _longerThan(a, b, 3)) {
          // Merge into the more frequent group
          final groupA = groups[canonA];
          final groupB = groups[canonB];
          if (groupA != null && groupB != null) {
            groupA.addAll(groupB);
            groups.remove(canonB);
          }
        }
      }
    }

    // Return only groups with 2+ variants
    return groups.entries
        .where((e) => e.value.length >= 2)
        .map((e) {
          // Pick the most-used variant as the suggested canonical
          final sorted = [...e.value]
            ..sort((a, b) => b.count.compareTo(a.count));
          return MerchantDuplicateGroup(
            canonical: e.key,
            variants: sorted,
            suggested: sorted.first.name,
          );
        })
        .toList()
      ..sort((a, b) =>
          b.variants.fold(0, (s, v) => s + v.count) -
          a.variants.fold(0, (s, v) => s + v.count));
  }

  static bool _longerThan(String a, String b, int minLen) =>
      a.length > minLen && b.length > minLen;

  /// Rename all expenses with [oldName] shop_name to [newName].
  /// Returns the number of rows updated.
  static Future<int> mergeShopName(String oldName, String newName) async {
    final db = await DBService.getDB();
    return db.update(
      'expenses',
      {'shop_name': newName},
      where: 'shop_name = ?',
      whereArgs: [oldName],
    );
  }
}

class _NameCount {
  final String name;
  final int count;
  _NameCount(this.name, this.count);
}

class MerchantDuplicateGroup {
  final String canonical;
  final List<_NameCount> variants;
  String suggested; // user-editable canonical choice

  MerchantDuplicateGroup({
    required this.canonical,
    required this.variants,
    required this.suggested,
  });

  int get totalCount => variants.fold(0, (s, v) => s + v.count);
}
