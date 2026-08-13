import 'dart:convert';
import 'package:http/http.dart' as http;

/// Product info from barcode lookup
class ProductInfo {
  final String name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final double? estimatedPrice;

  ProductInfo({
    required this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.estimatedPrice,
  });

  String get displayName => brand != null ? '$brand $name' : name;
}

/// Barcode product lookup service.
/// Uses Open Food Facts API (free, no key required) as primary source.
/// Falls back to local PH product database for common items.
class BarcodeLookupService {
  static const _openFoodFactsUrl =
      'https://world.openfoodfacts.org/api/v2/product';

  /// Look up a barcode and return product info if found.
  /// Returns null if product not found in any database.
  static Future<ProductInfo?> lookup(String barcode) async {
    // 1. Check local PH product database first (instant, no network)
    final local = _localLookup(barcode);
    if (local != null) return local;

    // 2. Try Open Food Facts API (free, global database)
    try {
      final result = await _openFoodFactsLookup(barcode);
      if (result != null) return result;
    } catch (_) {}

    // 3. Try to infer from barcode prefix (country of origin)
    return _inferFromPrefix(barcode);
  }

  /// Open Food Facts API lookup — free, no API key needed
  static Future<ProductInfo?> _openFoodFactsLookup(String barcode) async {
    final url = '$_openFoodFactsUrl/$barcode.json';
    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'SmartSpend/2.9.2'
    }).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data['status'] != 1) return null;

    final product = data['product'] as Map<String, dynamic>?;
    if (product == null) return null;

    final name = product['product_name'] as String? ??
        product['product_name_en'] as String? ??
        product['generic_name'] as String?;
    if (name == null || name.isEmpty) return null;

    final brand = product['brands'] as String?;
    final categories = product['categories'] as String?;
    final imageUrl = product['image_front_small_url'] as String?;

    // Try to get a category that maps to our expense categories
    String? mappedCategory;
    if (categories != null) {
      final lower = categories.toLowerCase();
      if (lower.contains('beverage') ||
          lower.contains('drink') ||
          lower.contains('snack') ||
          lower.contains('food')) {
        mappedCategory = 'Food';
      } else if (lower.contains('hygiene') ||
          lower.contains('beauty') ||
          lower.contains('care')) {
        mappedCategory = 'Personal Care';
      } else if (lower.contains('pet')) {
        mappedCategory = 'Pets';
      }
    }

    return ProductInfo(
      name: name,
      brand: brand,
      category: mappedCategory,
      imageUrl: imageUrl,
    );
  }

  /// Local PH product database — common Filipino products by barcode prefix
  static ProductInfo? _localLookup(String barcode) {
    // Philippine barcodes start with 480
    // Common products by exact barcode (most scanned items in PH convenience stores)
    final db = <String, ProductInfo>{
      // Lucky Me noodles
      '4800016010015': ProductInfo(
          name: 'Pancit Canton Original',
          brand: 'Lucky Me',
          category: 'Food',
          estimatedPrice: 14),
      '4800016010022': ProductInfo(
          name: 'Pancit Canton Calamansi',
          brand: 'Lucky Me',
          category: 'Food',
          estimatedPrice: 14),
      '4800016010039': ProductInfo(
          name: 'Pancit Canton Chilimansi',
          brand: 'Lucky Me',
          category: 'Food',
          estimatedPrice: 14),
      '4800016010046': ProductInfo(
          name: 'Pancit Canton Sweet & Spicy',
          brand: 'Lucky Me',
          category: 'Food',
          estimatedPrice: 14),
      '4800016012019': ProductInfo(
          name: 'Chicken Noodle Soup',
          brand: 'Lucky Me',
          category: 'Food',
          estimatedPrice: 12),
      '4800016012026': ProductInfo(
          name: 'Beef Noodle Soup',
          brand: 'Lucky Me',
          category: 'Food',
          estimatedPrice: 12),
      // Energy drinks
      '4800888100016': ProductInfo(
          name: 'Cobra Energy Drink',
          brand: 'Cobra',
          category: 'Food',
          estimatedPrice: 25),
      '4800016100013': ProductInfo(
          name: 'Sting Energy Drink',
          brand: 'Sting',
          category: 'Food',
          estimatedPrice: 25),
      // Snacks
      '4800016050011': ProductInfo(
          name: 'Chippy Barbecue',
          brand: 'Jack n Jill',
          category: 'Food',
          estimatedPrice: 12),
      '4800016050028': ProductInfo(
          name: 'Chippy Cheese',
          brand: 'Jack n Jill',
          category: 'Food',
          estimatedPrice: 12),
      '4800016060010': ProductInfo(
          name: 'Piattos Cheese',
          brand: 'Jack n Jill',
          category: 'Food',
          estimatedPrice: 25),
      '4800016060027': ProductInfo(
          name: 'Piattos Sour Cream',
          brand: 'Jack n Jill',
          category: 'Food',
          estimatedPrice: 25),
      // Beverages
      '4800016200014': ProductInfo(
          name: 'C2 Green Tea Apple',
          brand: 'C2',
          category: 'Food',
          estimatedPrice: 25),
      '4800016200021': ProductInfo(
          name: 'C2 Green Tea Lemon',
          brand: 'C2',
          category: 'Food',
          estimatedPrice: 25),
      '4800016300011': ProductInfo(
          name: 'Nestea Lemon Iced Tea',
          brand: 'Nestea',
          category: 'Food',
          estimatedPrice: 45),
      // Bread
      '4800016400018': ProductInfo(
          name: 'Gardenia Classic White',
          brand: 'Gardenia',
          category: 'Food',
          estimatedPrice: 75),
    };

    return db[barcode];
  }

  /// Infer product origin from barcode prefix
  static ProductInfo? _inferFromPrefix(String barcode) {
    if (barcode.length < 3) return null;
    final prefix = barcode.substring(0, 3);

    // GS1 country prefixes
    final origins = <String, String>{
      '480': 'Philippines',
      '489': 'Hong Kong',
      '490': 'Japan',
      '880': 'South Korea',
      '690': 'China',
      '885': 'Thailand',
      '899': 'Indonesia',
      '893': 'Vietnam',
      '890': 'India',
      '300': 'France',
      '400': 'Germany',
      '500': 'United Kingdom',
      '000': 'United States',
    };

    final origin = origins[prefix];
    if (origin != null) {
      return ProductInfo(
        name: 'Product from $origin',
        category: 'Food', // most barcoded items in PH stores are food
      );
    }
    return null;
  }
}
