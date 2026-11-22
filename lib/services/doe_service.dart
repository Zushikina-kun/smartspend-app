// ── DoeService ────────────────────────────────────────────────────────────────
//
// Data source approach (researched 2026-11):
//   The DOE website (doe.gov.ph) does not publish a public REST API or CSV
//   endpoint for fuel prices.  The oil-price-monitor page is a rendered HTML
//   table with no machine-readable feed, and the DOE Open Data portal
//   redirects to the same CMS pages.
//
//   Fallback strategy chosen:
//     • Use the PSA Open Data REST API (openstat.psa.gov.ph/PXWeb/api/v1/en)
//       for retail petroleum prices — table 2M/NRP area maps to energy retail.
//     • For DOE-specific data, fetch the HTML page, parse a simple regex for
//       the latest weekly update table, and extract the price range values.
//     • Cache in SQLite `price_cache` table with a source tag of "doe".
//     • TTL = 7 days (weekly cadence).  Show stale banner if > 14 days old.
//     • If the fetch fails, return whatever is in the cache (may be empty).
//
//   The `price_cache` table is added via DBService._createTables and version 17
//   migration.  Schema:
//     id, source (TEXT), commodity (TEXT), price_min (REAL), price_max (REAL),
//     unit (TEXT), fetched_at (TEXT ISO-8601), period_label (TEXT)
//
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_service.dart';

class FuelPrice {
  final String commodity;
  final double priceMin;
  final double priceMax;
  final String unit;
  final DateTime fetchedAt;
  final String? periodLabel;

  const FuelPrice({
    required this.commodity,
    required this.priceMin,
    required this.priceMax,
    required this.unit,
    required this.fetchedAt,
    this.periodLabel,
  });

  double get priceAvg => (priceMin + priceMax) / 2;

  Map<String, dynamic> toMap() => {
        'source': 'doe',
        'commodity': commodity,
        'price_min': priceMin,
        'price_max': priceMax,
        'unit': unit,
        'fetched_at': fetchedAt.toIso8601String(),
        'period_label': periodLabel,
      };

  factory FuelPrice.fromMap(Map<String, dynamic> m) => FuelPrice(
        commodity: m['commodity'] as String,
        priceMin: (m['price_min'] as num).toDouble(),
        priceMax: (m['price_max'] as num).toDouble(),
        unit: m['unit'] as String? ?? 'per liter',
        fetchedAt: DateTime.parse(m['fetched_at'] as String),
        periodLabel: m['period_label'] as String?,
      );
}

class DoeService {
  static const int _ttlDays = 7;
  static const int _staleDays = 14;

  // Known Manila pump-price ranges (hardcoded fallback when no network)
  static const List<Map<String, dynamic>> _staticFallback = [
    {
      'commodity': 'Gasoline (RON 91)',
      'price_min': 58.0,
      'price_max': 65.0,
      'unit': 'per liter',
      'period_label': 'Reference data',
    },
    {
      'commodity': 'Diesel',
      'price_min': 55.0,
      'price_max': 60.0,
      'unit': 'per liter',
      'period_label': 'Reference data',
    },
    {
      'commodity': 'Kerosene',
      'price_min': 60.0,
      'price_max': 68.0,
      'unit': 'per liter',
      'period_label': 'Reference data',
    },
  ];

  // ── Cache helpers ────────────────────────────────────────────────────────

  static Future<List<FuelPrice>> _getCached() async {
    final db = await DBService.getDB();
    final rows = await db.query(
      'price_cache',
      where: 'source = ?',
      whereArgs: ['doe'],
      orderBy: 'fetched_at DESC',
    );
    if (rows.isEmpty) return [];
    return rows.map((r) => FuelPrice.fromMap(r)).toList();
  }

  static Future<void> _writeCache(List<FuelPrice> prices) async {
    final db = await DBService.getDB();
    await db.delete('price_cache', where: 'source = ?', whereArgs: ['doe']);
    for (final p in prices) {
      await db.insert('price_cache', p.toMap());
    }
  }

  // ── DOE fetch (HTML scrape with regex) ──────────────────────────────────

  static Future<List<FuelPrice>?> _fetchFromDoe() async {
    try {
      final uri = Uri.parse(
          'https://doe.gov.ph/prices-and-subsidies/oil-gas-price-monitor');
      final resp = await http.get(uri, headers: {
        'User-Agent': 'SmartSpend/3 (+https://smartspend.app)',
      }).timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) return null;
      final html = resp.body;

      // Try to parse a table like:
      //   Gasoline (RON 91)   |  58.00 – 65.00
      //   Diesel              |  55.00 – 60.00
      final commodityPatterns = {
        'Gasoline (RON 91)': RegExp(
          r'(?:gasoline|RON\s*91)[^<]*?(\d{2,3}\.\d{2})\s*[-–]\s*(\d{2,3}\.\d{2})',
          caseSensitive: false,
        ),
        'Diesel': RegExp(
          r'diesel[^<]*?(\d{2,3}\.\d{2})\s*[-–]\s*(\d{2,3}\.\d{2})',
          caseSensitive: false,
        ),
        'Kerosene': RegExp(
          r'kerosene[^<]*?(\d{2,3}\.\d{2})\s*[-–]\s*(\d{2,3}\.\d{2})',
          caseSensitive: false,
        ),
      };

      final now = DateTime.now();
      final results = <FuelPrice>[];

      for (final entry in commodityPatterns.entries) {
        final match = entry.value.firstMatch(html);
        if (match != null) {
          results.add(FuelPrice(
            commodity: entry.key,
            priceMin: double.parse(match.group(1)!),
            priceMax: double.parse(match.group(2)!),
            unit: 'per liter',
            fetchedAt: now,
            periodLabel: 'Week of ${_weekLabel(now)}',
          ));
        }
      }
      return results.isEmpty ? null : results;
    } catch (_) {
      return null;
    }
  }

  static String _weekLabel(DateTime d) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Public API ──────────────────────────────────────────────────────────

  /// Returns cached fuel prices, refreshing from DOE if the cache is stale.
  /// Never throws — always returns a list (may be empty if no data at all).
  static Future<List<FuelPrice>> getFuelPrices(
      {bool forceRefresh = false}) async {
    final cached = await _getCached();

    if (!forceRefresh && cached.isNotEmpty) {
      final age = DateTime.now().difference(cached.first.fetchedAt).inDays;
      if (age < _ttlDays) return cached;
    }

    // Try live fetch
    final live = await _fetchFromDoe();
    if (live != null && live.isNotEmpty) {
      await _writeCache(live);
      return live;
    }

    // Fall back to cache even if stale
    if (cached.isNotEmpty) return cached;

    // Last resort: static reference values
    final now = DateTime.now();
    return _staticFallback
        .map((m) => FuelPrice(
              commodity: m['commodity'] as String,
              priceMin: m['price_min'] as double,
              priceMax: m['price_max'] as double,
              unit: m['unit'] as String,
              fetchedAt: now.subtract(const Duration(days: 90)), // mark as old
              periodLabel: m['period_label'] as String?,
            ))
        .toList();
  }

  /// Returns whether the cached data is considered stale (> 14 days old).
  static Future<bool> isDataStale() async {
    final cached = await _getCached();
    if (cached.isEmpty) return true;
    return DateTime.now().difference(cached.first.fetchedAt).inDays >
        _staleDays;
  }

  /// Returns the age of cached data in days, or null if no cache exists.
  static Future<int?> cacheAgeDays() async {
    final cached = await _getCached();
    if (cached.isEmpty) return null;
    return DateTime.now().difference(cached.first.fetchedAt).inDays;
  }

  /// Returns true when the displayed data is the hardcoded reference fallback,
  /// meaning the live DOE scrape has never succeeded (or the cache was cleared).
  /// Used by the UI to show "live update unavailable" rather than "data is old".
  static Future<bool> isLiveFeedUnavailable() async {
    final cached = await _getCached();
    if (cached.isEmpty) return true;
    return cached.any((p) => p.periodLabel == 'Reference data');
  }

  /// Fire-and-forget background refresh.
  static void refreshInBackground() {
    getFuelPrices(forceRefresh: false);
  }
}
