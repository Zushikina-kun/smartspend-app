/// ItemCatalogService — offline-first catalog of common Filipino expense items.
///
/// 150+ items covering everyday Filipino spending:
///   Food (fast food, convenience, markets, beverages, snacks)
///   Transport (typical PH fares)
///   Bills & utilities
///   Health & pharmacy
///   Education / school supplies
///   Personal care
///   Common shopping items
///
/// No API, no network — instant, always available.
/// Items are sorted by category and have a typical price range for PH.

class CatalogItem {
  final String name;
  final String category;
  final double suggestedPrice;
  final bool isWant;
  final String? shopHint; // optional hint for the shop field

  const CatalogItem({
    required this.name,
    required this.category,
    required this.suggestedPrice,
    required this.isWant,
    this.shopHint,
  });
}

class ItemCatalogService {
  static const List<CatalogItem> _catalog = [
    // ── FOOD — Fast Food & Restaurants ──────────────────────────────────────
    CatalogItem(name: 'Chickenjoy 1pc', category: 'Food', suggestedPrice: 99, isWant: true, shopHint: 'Jollibee'),
    CatalogItem(name: 'Chickenjoy 2pc', category: 'Food', suggestedPrice: 185, isWant: true, shopHint: 'Jollibee'),
    CatalogItem(name: 'Jolly Spaghetti', category: 'Food', suggestedPrice: 65, isWant: true, shopHint: 'Jollibee'),
    CatalogItem(name: 'Burger Steak', category: 'Food', suggestedPrice: 89, isWant: true, shopHint: 'Jollibee'),
    CatalogItem(name: 'Palabok Fiesta', category: 'Food', suggestedPrice: 89, isWant: true, shopHint: 'Jollibee'),
    CatalogItem(name: 'McSavers Meal', category: 'Food', suggestedPrice: 99, isWant: true, shopHint: "McDonald's"),
    CatalogItem(name: 'Big Mac', category: 'Food', suggestedPrice: 185, isWant: true, shopHint: "McDonald's"),
    CatalogItem(name: 'Fries (Large)', category: 'Food', suggestedPrice: 75, isWant: true, shopHint: "McDonald's"),
    CatalogItem(name: 'Chao Fan', category: 'Food', suggestedPrice: 79, isWant: false, shopHint: 'Chowking'),
    CatalogItem(name: 'Wonton Noodles', category: 'Food', suggestedPrice: 65, isWant: false, shopHint: 'Chowking'),
    CatalogItem(name: 'Pork BBQ Meal', category: 'Food', suggestedPrice: 79, isWant: false, shopHint: 'Mang Inasal'),
    CatalogItem(name: 'Chicken Inasal', category: 'Food', suggestedPrice: 129, isWant: false, shopHint: 'Mang Inasal'),
    CatalogItem(name: 'KFC 1pc Chicken', category: 'Food', suggestedPrice: 89, isWant: true, shopHint: 'KFC'),
    CatalogItem(name: '2pc Fill Up Box', category: 'Food', suggestedPrice: 149, isWant: true, shopHint: 'KFC'),

    // ── FOOD — Meals (general) ───────────────────────────────────────────────
    CatalogItem(name: 'Breakfast', category: 'Food', suggestedPrice: 65, isWant: false),
    CatalogItem(name: 'Brunch', category: 'Food', suggestedPrice: 75, isWant: false),
    CatalogItem(name: 'Lunch', category: 'Food', suggestedPrice: 85, isWant: false),
    CatalogItem(name: 'Merienda', category: 'Food', suggestedPrice: 35, isWant: true),
    CatalogItem(name: 'Dinner', category: 'Food', suggestedPrice: 100, isWant: false),
    CatalogItem(name: 'Snacks', category: 'Food', suggestedPrice: 40, isWant: true),
    CatalogItem(name: 'Silog Meal', category: 'Food', suggestedPrice: 75, isWant: false),
    CatalogItem(name: 'Tapsilog', category: 'Food', suggestedPrice: 85, isWant: false),
    CatalogItem(name: 'Tocilog', category: 'Food', suggestedPrice: 75, isWant: false),
    CatalogItem(name: 'Longsilog', category: 'Food', suggestedPrice: 80, isWant: false),

    // ── FOOD — Convenience Store & Snacks ────────────────────────────────────
    CatalogItem(name: 'Lucky Me Pancit Canton', category: 'Food', suggestedPrice: 14, isWant: false, shopHint: '7-Eleven'),
    CatalogItem(name: 'Cup Noodles', category: 'Food', suggestedPrice: 35, isWant: false),
    CatalogItem(name: 'Gardenia Bread', category: 'Food', suggestedPrice: 75, isWant: false, shopHint: '7-Eleven'),
    CatalogItem(name: 'Chippy', category: 'Food', suggestedPrice: 20, isWant: true, shopHint: '7-Eleven'),
    CatalogItem(name: 'Piattos', category: 'Food', suggestedPrice: 35, isWant: true),
    CatalogItem(name: 'Skyflakes', category: 'Food', suggestedPrice: 12, isWant: false),
    CatalogItem(name: 'Rebisco Cream-O', category: 'Food', suggestedPrice: 10, isWant: true),
    CatalogItem(name: 'SkyFlakes Crackers', category: 'Food', suggestedPrice: 15, isWant: false),
    CatalogItem(name: 'Presto Ice Cream', category: 'Food', suggestedPrice: 20, isWant: true),
    CatalogItem(name: 'Selecta Ice Cream', category: 'Food', suggestedPrice: 55, isWant: true),

    // ── FOOD — Beverages ──────────────────────────────────────────────────────
    CatalogItem(name: 'Bottled Water (500ml)', category: 'Food', suggestedPrice: 20, isWant: false),
    CatalogItem(name: 'Sting Energy Drink', category: 'Food', suggestedPrice: 30, isWant: true),
    CatalogItem(name: 'Cobra Energy Drink', category: 'Food', suggestedPrice: 30, isWant: true),
    CatalogItem(name: 'Red Bull', category: 'Food', suggestedPrice: 65, isWant: true),
    CatalogItem(name: 'C2 Iced Tea', category: 'Food', suggestedPrice: 25, isWant: true),
    CatalogItem(name: 'Nestea (1L)', category: 'Food', suggestedPrice: 45, isWant: true),
    CatalogItem(name: 'Coca-Cola (1L)', category: 'Food', suggestedPrice: 50, isWant: true),
    CatalogItem(name: 'Pepsi (1L)', category: 'Food', suggestedPrice: 50, isWant: true),
    CatalogItem(name: 'Coffee (from café)', category: 'Food', suggestedPrice: 120, isWant: true),
    CatalogItem(name: '3-in-1 Coffee', category: 'Food', suggestedPrice: 8, isWant: false),
    CatalogItem(name: 'Gatorade', category: 'Food', suggestedPrice: 45, isWant: true),
    CatalogItem(name: 'Tropicana Twister', category: 'Food', suggestedPrice: 40, isWant: true),

    // ── FOOD — Market / Grocery ───────────────────────────────────────────────
    CatalogItem(name: 'Rice (1kg)', category: 'Food', suggestedPrice: 55, isWant: false),
    CatalogItem(name: 'Eggs (6pcs)', category: 'Food', suggestedPrice: 60, isWant: false),
    CatalogItem(name: 'Eggs (12pcs)', category: 'Food', suggestedPrice: 110, isWant: false),
    CatalogItem(name: 'Cooking Oil (1L)', category: 'Food', suggestedPrice: 100, isWant: false),
    CatalogItem(name: 'Canned Sardines', category: 'Food', suggestedPrice: 20, isWant: false),
    CatalogItem(name: 'Canned Tuna', category: 'Food', suggestedPrice: 35, isWant: false),
    CatalogItem(name: 'Toyo (Soy Sauce)', category: 'Food', suggestedPrice: 30, isWant: false),
    CatalogItem(name: 'Vinegar (1L)', category: 'Food', suggestedPrice: 25, isWant: false),
    CatalogItem(name: 'Pork (1kg)', category: 'Food', suggestedPrice: 320, isWant: false),
    CatalogItem(name: 'Chicken (1kg)', category: 'Food', suggestedPrice: 200, isWant: false),
    CatalogItem(name: 'Tilapia (1kg)', category: 'Food', suggestedPrice: 150, isWant: false),
    CatalogItem(name: 'Vegetables (assorted)', category: 'Food', suggestedPrice: 80, isWant: false),
    CatalogItem(name: 'Banana (1 bunch)', category: 'Food', suggestedPrice: 60, isWant: false),
    CatalogItem(name: 'Grocery run', category: 'Food', suggestedPrice: 500, isWant: false),

    // ── TRANSPORTATION ────────────────────────────────────────────────────────
    CatalogItem(name: 'Jeepney fare', category: 'Transportation', suggestedPrice: 30, isWant: false),
    CatalogItem(name: 'Tricycle fare', category: 'Transportation', suggestedPrice: 30, isWant: false),
    CatalogItem(name: 'Bus fare', category: 'Transportation', suggestedPrice: 50, isWant: false),
    CatalogItem(name: 'MRT/LRT fare', category: 'Transportation', suggestedPrice: 40, isWant: false),
    CatalogItem(name: 'UV Express fare', category: 'Transportation', suggestedPrice: 60, isWant: false),
    CatalogItem(name: 'Grab (short)', category: 'Transportation', suggestedPrice: 80, isWant: false, shopHint: 'Grab'),
    CatalogItem(name: 'Grab (medium)', category: 'Transportation', suggestedPrice: 150, isWant: false, shopHint: 'Grab'),
    CatalogItem(name: 'Grab (long)', category: 'Transportation', suggestedPrice: 300, isWant: false, shopHint: 'Grab'),
    CatalogItem(name: 'Angkas', category: 'Transportation', suggestedPrice: 80, isWant: false, shopHint: 'Angkas'),
    CatalogItem(name: 'Bus (provincial)', category: 'Transportation', suggestedPrice: 200, isWant: false),
    CatalogItem(name: 'Pedicab fare', category: 'Transportation', suggestedPrice: 15, isWant: false),
    CatalogItem(name: 'Fuel (motorcycle)', category: 'Transportation', suggestedPrice: 200, isWant: false),
    CatalogItem(name: 'Toll fee', category: 'Transportation', suggestedPrice: 50, isWant: false),
    CatalogItem(name: 'Parking', category: 'Transportation', suggestedPrice: 50, isWant: false),

    // ── BILLS & UTILITIES ─────────────────────────────────────────────────────
    CatalogItem(name: 'Meralco bill', category: 'Bills', suggestedPrice: 1200, isWant: false, shopHint: 'Meralco'),
    CatalogItem(name: 'PLDT/Globe internet', category: 'Bills', suggestedPrice: 1299, isWant: false),
    CatalogItem(name: 'Mobile load (₱30)', category: 'Bills', suggestedPrice: 30, isWant: false),
    CatalogItem(name: 'Mobile load (₱100)', category: 'Bills', suggestedPrice: 100, isWant: false),
    CatalogItem(name: 'Netflix subscription', category: 'Bills', suggestedPrice: 299, isWant: true, shopHint: 'Netflix'),
    CatalogItem(name: 'Spotify subscription', category: 'Bills', suggestedPrice: 149, isWant: true, shopHint: 'Spotify'),
    CatalogItem(name: 'Disney+ subscription', category: 'Bills', suggestedPrice: 199, isWant: true, shopHint: 'Disney+'),
    CatalogItem(name: 'YouTube Premium', category: 'Bills', suggestedPrice: 189, isWant: true),
    CatalogItem(name: 'Water bill', category: 'Bills', suggestedPrice: 400, isWant: false),
    CatalogItem(name: 'Rent', category: 'Bills', suggestedPrice: 5000, isWant: false),
    CatalogItem(name: 'SSS contribution', category: 'Bills', suggestedPrice: 560, isWant: false, shopHint: 'SSS'),
    CatalogItem(name: 'PhilHealth contribution', category: 'Bills', suggestedPrice: 400, isWant: false, shopHint: 'PhilHealth'),
    CatalogItem(name: 'Pag-IBIG contribution', category: 'Bills', suggestedPrice: 100, isWant: false, shopHint: 'Pag-IBIG'),

    // ── HEALTH & PHARMACY ─────────────────────────────────────────────────────
    CatalogItem(name: 'Paracetamol (Biogesic)', category: 'Health', suggestedPrice: 15, isWant: false, shopHint: 'Mercury Drug'),
    CatalogItem(name: 'Mefenamic Acid', category: 'Health', suggestedPrice: 20, isWant: false, shopHint: 'Mercury Drug'),
    CatalogItem(name: 'Vitamin C (500mg)', category: 'Health', suggestedPrice: 25, isWant: false),
    CatalogItem(name: 'Biogesic', category: 'Health', suggestedPrice: 15, isWant: false, shopHint: 'Mercury Drug'),
    CatalogItem(name: 'Neozep', category: 'Health', suggestedPrice: 25, isWant: false, shopHint: 'Mercury Drug'),
    CatalogItem(name: 'Isopropyl Alcohol', category: 'Health', suggestedPrice: 46, isWant: false),
    CatalogItem(name: 'Face mask (box)', category: 'Health', suggestedPrice: 80, isWant: false),
    CatalogItem(name: 'Doctor consultation', category: 'Health', suggestedPrice: 500, isWant: false),
    CatalogItem(name: 'Laboratory test', category: 'Health', suggestedPrice: 800, isWant: false),
    CatalogItem(name: 'Dental check-up', category: 'Health', suggestedPrice: 500, isWant: false),

    // ── PERSONAL CARE ─────────────────────────────────────────────────────────
    CatalogItem(name: 'Shampoo (sachet)', category: 'Personal Care', suggestedPrice: 8, isWant: false),
    CatalogItem(name: 'Shampoo (bottle)', category: 'Personal Care', suggestedPrice: 150, isWant: false),
    CatalogItem(name: 'Toothpaste', category: 'Personal Care', suggestedPrice: 65, isWant: false),
    CatalogItem(name: 'Bath soap', category: 'Personal Care', suggestedPrice: 35, isWant: false),
    CatalogItem(name: 'Deodorant', category: 'Personal Care', suggestedPrice: 85, isWant: false),
    CatalogItem(name: 'Lotion (body)', category: 'Personal Care', suggestedPrice: 150, isWant: true),
    CatalogItem(name: 'Sanitary napkin', category: 'Personal Care', suggestedPrice: 90, isWant: false),
    CatalogItem(name: 'Haircut (barbershop)', category: 'Personal Care', suggestedPrice: 100, isWant: false),
    CatalogItem(name: 'Haircut (salon)', category: 'Personal Care', suggestedPrice: 250, isWant: true),
    CatalogItem(name: 'Nail care', category: 'Personal Care', suggestedPrice: 150, isWant: true),
    CatalogItem(name: 'Laundry (per load)', category: 'Personal Care', suggestedPrice: 60, isWant: false),
    CatalogItem(name: 'Detergent powder', category: 'Personal Care', suggestedPrice: 45, isWant: false),

    // ── EDUCATION ─────────────────────────────────────────────────────────────
    CatalogItem(name: 'Ballpen', category: 'Education', suggestedPrice: 15, isWant: false),
    CatalogItem(name: 'Notebook (composition)', category: 'Education', suggestedPrice: 35, isWant: false),
    CatalogItem(name: 'Bond paper (ream)', category: 'Education', suggestedPrice: 250, isWant: false),
    CatalogItem(name: 'Printing (per page)', category: 'Education', suggestedPrice: 5, isWant: false),
    CatalogItem(name: 'Printing Card', category: 'Education', suggestedPrice: 50, isWant: false),
    CatalogItem(name: 'Photocopies', category: 'Education', suggestedPrice: 30, isWant: false),
    CatalogItem(name: 'Folder', category: 'Education', suggestedPrice: 15, isWant: false),
    CatalogItem(name: 'Highlighter', category: 'Education', suggestedPrice: 30, isWant: false),
    CatalogItem(name: 'Textbook', category: 'Education', suggestedPrice: 450, isWant: false),
    CatalogItem(name: 'School uniform', category: 'Education', suggestedPrice: 600, isWant: false),
    CatalogItem(name: 'Tuition (monthly)', category: 'Education', suggestedPrice: 5000, isWant: false),

    // ── SHOPPING ──────────────────────────────────────────────────────────────
    CatalogItem(name: 'T-shirt', category: 'Clothing', suggestedPrice: 199, isWant: true),
    CatalogItem(name: 'Socks (pair)', category: 'Clothing', suggestedPrice: 50, isWant: false),
    CatalogItem(name: 'Underwear', category: 'Clothing', suggestedPrice: 75, isWant: false),
    CatalogItem(name: 'Jeans', category: 'Clothing', suggestedPrice: 599, isWant: true),
    CatalogItem(name: 'Sneakers', category: 'Clothing', suggestedPrice: 999, isWant: true),
    CatalogItem(name: 'Slippers', category: 'Clothing', suggestedPrice: 199, isWant: false),

    // ── ENTERTAINMENT ─────────────────────────────────────────────────────────
    CatalogItem(name: 'Movie ticket (regular)', category: 'Entertainment', suggestedPrice: 250, isWant: true),
    CatalogItem(name: 'Movie ticket (IMAX)', category: 'Entertainment', suggestedPrice: 480, isWant: true),
    CatalogItem(name: 'Videoke (per hour)', category: 'Entertainment', suggestedPrice: 200, isWant: true),
    CatalogItem(name: 'Mall entrance / arcade', category: 'Entertainment', suggestedPrice: 100, isWant: true),
    CatalogItem(name: 'Concert ticket', category: 'Entertainment', suggestedPrice: 1500, isWant: true),

    // ── GAMING ────────────────────────────────────────────────────────────────
    CatalogItem(name: 'Mobile Legends Diamonds (100)', category: 'Gaming', suggestedPrice: 99, isWant: true, shopHint: 'Codashop'),
    CatalogItem(name: 'Mobile Legends Diamonds (500)', category: 'Gaming', suggestedPrice: 499, isWant: true, shopHint: 'Codashop'),
    CatalogItem(name: 'Free Fire Diamonds (100)', category: 'Gaming', suggestedPrice: 99, isWant: true, shopHint: 'Codashop'),
    CatalogItem(name: 'Steam game', category: 'Gaming', suggestedPrice: 300, isWant: true, shopHint: 'Steam'),
    CatalogItem(name: 'Roblox Robux', category: 'Gaming', suggestedPrice: 99, isWant: true),

    // ── GIFTS ─────────────────────────────────────────────────────────────────
    CatalogItem(name: 'Pasalubong (snacks)', category: 'Gifts', suggestedPrice: 150, isWant: true),
    CatalogItem(name: 'Birthday gift', category: 'Gifts', suggestedPrice: 300, isWant: true),
    CatalogItem(name: 'Christmas gift', category: 'Gifts', suggestedPrice: 500, isWant: true),
    CatalogItem(name: 'Flowers', category: 'Gifts', suggestedPrice: 200, isWant: true),
    CatalogItem(name: 'Charity / Donation', category: 'Gifts', suggestedPrice: 100, isWant: true),

    // ── PETS ──────────────────────────────────────────────────────────────────
    CatalogItem(name: 'Dog food (Pedigree)', category: 'Pets', suggestedPrice: 150, isWant: false, shopHint: 'Pet shop'),
    CatalogItem(name: 'Cat food (Whiskas)', category: 'Pets', suggestedPrice: 80, isWant: false),
    CatalogItem(name: 'Vet consultation', category: 'Pets', suggestedPrice: 400, isWant: false),
    CatalogItem(name: 'Pet grooming', category: 'Pets', suggestedPrice: 300, isWant: false),

    // ── OTHERS ────────────────────────────────────────────────────────────────
    CatalogItem(name: 'GCash cash-in fee', category: 'Others', suggestedPrice: 20, isWant: false),
    CatalogItem(name: 'Money transfer fee', category: 'Others', suggestedPrice: 20, isWant: false),
    CatalogItem(name: 'LBC / courier fee', category: 'Others', suggestedPrice: 100, isWant: false),
    CatalogItem(name: 'Photocopy (ID/documents)', category: 'Others', suggestedPrice: 20, isWant: false),
    CatalogItem(name: 'Parking fee (mall)', category: 'Others', suggestedPrice: 50, isWant: false),
  ];

  /// Search the catalog. Returns items where name or category contains [query].
  /// If [query] is empty, returns all items (paginated by category).
  /// Results are sorted: exact starts-with first, then contains.
  static List<CatalogItem> search(String query) {
    if (query.trim().isEmpty) return _catalog;
    final q = query.trim().toLowerCase();
    final startsWith = <CatalogItem>[];
    final contains = <CatalogItem>[];
    for (final item in _catalog) {
      final nameLower = item.name.toLowerCase();
      if (nameLower.startsWith(q)) {
        startsWith.add(item);
      } else if (nameLower.contains(q) || item.category.toLowerCase().contains(q)) {
        contains.add(item);
      }
    }
    return [...startsWith, ...contains];
  }

  /// Returns all unique categories present in the catalog.
  static List<String> get categories {
    final seen = <String>{};
    final result = <String>[];
    for (final item in _catalog) {
      if (seen.add(item.category)) result.add(item.category);
    }
    return result;
  }

  /// Returns all items for a given category.
  static List<CatalogItem> forCategory(String category) =>
      _catalog.where((i) => i.category == category).toList();
}
