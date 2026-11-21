import 'package:sqflite/sqflite.dart';
import '../models/price_data.dart';
import 'db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PriceIntelligenceService {
  /// Add a price record from a receipt scan
  static Future<int> addPriceFromReceipt({
    required String productName,
    String? storeName,
    required double price,
    required DateTime date,
    String? category,
    int? expenseId,
  }) async {
    final db = await DBService.getDB();
    final priceData = PriceData(
      productName: productName,
      storeName: storeName,
      price: price,
      date: date,
      category: category,
      expenseId: expenseId,
      createdAt: DateTime.now(),
    );

    return await db.insert('prices', priceData.toMap());
  }

  /// Find price comparisons for a product across different stores
  /// Returns list of PriceData sorted by price (lowest first)
  static Future<List<PriceData>> findPriceComparisons(
      String productName) async {
    final db = await DBService.getDB();

    // Normalize product name for fuzzy matching
    final normalizedName = productName.toLowerCase().trim();

    // Query for exact or similar product names
    final results = await db.query(
      'prices',
      orderBy: 'price ASC',
    );

    // Filter results for similar product names (fuzzy match)
    final matches = results.where((row) {
      final rowName = (row['product_name'] as String).toLowerCase().trim();
      // Exact match or contains
      return rowName == normalizedName ||
          rowName.contains(normalizedName) ||
          normalizedName.contains(rowName);
    }).toList();

    return matches.map((map) => PriceData.fromMap(map)).toList();
  }

  /// Check for price alerts - finds products where user paid more than lowest known price
  /// Returns list of maps with keys: 'productName', 'storeName', 'pricePaid', 'lowestPrice', 'lowestStore', 'savings'
  static Future<List<Map<String, dynamic>>> checkForPriceAlerts() async {
    final db = await DBService.getDB();
    final prefs = await SharedPreferences.getInstance();

    // Get prices from last 7 days
    final sevenDaysAgo =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

    final recentPrices = await db.query(
      'prices',
      where: 'date >= ?',
      whereArgs: [sevenDaysAgo],
      orderBy: 'date DESC',
    );

    final alerts = <Map<String, dynamic>>[];
    final processedProducts = <String>{};

    for (final row in recentPrices) {
      final productName = row['product_name'] as String;
      final normalizedName = productName.toLowerCase().trim();

      // Skip if we already processed this product
      if (processedProducts.contains(normalizedName)) continue;

      // Check if alert was dismissed recently
      final dismissKey = 'price_alert_dismissed_$normalizedName';
      final dismissedAt = prefs.getInt(dismissKey);
      if (dismissedAt != null) {
        final dismissedDate =
            DateTime.fromMillisecondsSinceEpoch(dismissedAt);
        if (DateTime.now().difference(dismissedDate).inDays < 7) {
          continue; // Skip dismissed alerts within 7 days
        }
      }

      // Find all prices for this product
      final comparisons = await findPriceComparisons(productName);

      if (comparisons.length >= 2) {
        // Get the lowest and highest prices
        final lowestPrice = comparisons.first;
        final userPrice = comparisons.firstWhere(
          (p) => p.productName.toLowerCase().trim() == normalizedName,
          orElse: () => comparisons.last,
        );

        // Only alert if user paid more than the lowest price
        if (userPrice.price > lowestPrice.price) {
          final savings = userPrice.price - lowestPrice.price;
          if (savings >= 5) {
            // Only alert if savings >= ₱5
            alerts.add({
              'productName': productName,
              'storeName': userPrice.storeName ?? 'Unknown Store',
              'pricePaid': userPrice.price,
              'lowestPrice': lowestPrice.price,
              'lowestStore': lowestPrice.storeName ?? 'Unknown Store',
              'savings': savings,
              'date': userPrice.date.toIso8601String(),
            });
            processedProducts.add(normalizedName);
          }
        }
      }
    }

    return alerts;
  }

  /// Dismiss a price alert for a specific product
  /// Alert will not appear again for 7 days
  static Future<void> dismissAlert(String productName) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedName = productName.toLowerCase().trim();
    final dismissKey = 'price_alert_dismissed_$normalizedName';
    await prefs.setInt(dismissKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get all prices for a specific product
  static Future<List<PriceData>> getPricesForProduct(String productName) async {
    return await findPriceComparisons(productName);
  }

  /// Get recent price trends for a product
  /// Returns list of prices ordered by date (most recent first)
  static Future<List<PriceData>> getPriceTrend(String productName) async {
    final db = await DBService.getDB();
    final normalizedName = productName.toLowerCase().trim();

    final results = await db.query(
      'prices',
      orderBy: 'date DESC',
    );

    // Filter for this product
    final matches = results.where((row) {
      final rowName = (row['product_name'] as String).toLowerCase().trim();
      return rowName == normalizedName ||
          rowName.contains(normalizedName) ||
          normalizedName.contains(rowName);
    }).toList();

    return matches.map((map) => PriceData.fromMap(map)).toList();
  }

  /// Delete price records for a specific expense
  static Future<void> deletePricesForExpense(int expenseId) async {
    final db = await DBService.getDB();
    await db.delete(
      'prices',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
  }

  /// Get all price records
  static Future<List<PriceData>> getAllPrices() async {
    final db = await DBService.getDB();
    final results = await db.query('prices', orderBy: 'date DESC');
    return results.map((map) => PriceData.fromMap(map)).toList();
  }
}
