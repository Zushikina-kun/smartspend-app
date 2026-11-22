// ── PsaService ────────────────────────────────────────────────────────────────
//
// Data source approach (researched 2026-11):
//   PSA Open Data portal: openstat.psa.gov.ph/PXWeb/api/v1/en
//   The PX-Web JSON-stat API is publicly accessible (no key required).
//   Confirmed endpoints:
//     GET /PXWeb/api/v1/en/DB                 → list of databases
//     GET /PXWeb/api/v1/en/DB/2M              → Prices subcategories
//     GET /PXWeb/api/v1/en/DB/2M/NRP          → Retail Prices (2012-based) tables
//     POST /PXWeb/api/v1/en/DB/2M/NRP/<id>.px → query with JSON filter body
//
//   Chosen table: 0042M4ARN01.px  "Cereals: Retail Prices by Region/Province"
//   We query Metro Manila (NCR), commodity = Regular milled rice + Well-milled rice.
//   Response is PX-Web JSON-stat; we parse the value array and dimension metadata.
//
//   Cadence: monthly (PSA updates ~monthly).  TTL = 30 days.
//   Stale warning threshold: 60 days.
//   Cache in SQLite `price_cache` table with source = "psa".
//
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_service.dart';

class MarketPrice {
  final String commodity;
  final double price;
  final String unit;
  final DateTime fetchedAt;
  final String? regionLabel;
  final String? periodLabel;

  const MarketPrice({
    required this.commodity,
    required this.price,
    required this.unit,
    required this.fetchedAt,
    this.regionLabel,
    this.periodLabel,
  });

  Map<String, dynamic> toMap() => {
        'source': 'psa',
        'commodity': commodity,
        'price_min': price,
        'price_max': price,
        'unit': unit,
        'fetched_at': fetchedAt.toIso8601String(),
        'period_label': periodLabel ?? regionLabel,
      };

  factory MarketPrice.fromMap(Map<String, dynamic> m) => MarketPrice(
        commodity: m['commodity'] as String,
        price: (m['price_min'] as num).toDouble(),
        unit: m['unit'] as String? ?? 'per kg',
        fetchedAt: DateTime.parse(m['fetched_at'] as String),
        periodLabel: m['period_label'] as String?,
      );
}

class PsaService {
  static const String _baseUrl =
      'https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/NRP';

  // Cereal retail prices table
  static const String _cerealsTable = '0042M4ARN01.px';

  static const int _ttlDays = 30;
  static const int _staleDays = 60;

  // Hardcoded fallback: NCR average retail prices
  static const List<Map<String, dynamic>> _staticFallback = [
    {
      'commodity': 'Regular Milled Rice',
      'price': 48.0,
      'unit': 'per kg',
      'period_label': 'Reference data',
    },
    {
      'commodity': 'Well-milled Rice',
      'price': 54.0,
      'unit': 'per kg',
      'period_label': 'Reference data',
    },
    {
      'commodity': 'Special Rice',
      'price': 62.0,
      'unit': 'per kg',
      'period_label': 'Reference data',
    },
  ];

  // ── Cache helpers ────────────────────────────────────────────────────────

  static Future<List<MarketPrice>> _getCached() async {
    final db = await DBService.getDB();
    final rows = await db.query(
      'price_cache',
      where: 'source = ?',
      whereArgs: ['psa'],
      orderBy: 'fetched_at DESC',
    );
    if (rows.isEmpty) return [];
    return rows.map((r) => MarketPrice.fromMap(r)).toList();
  }

  static Future<void> _writeCache(List<MarketPrice> prices) async {
    final db = await DBService.getDB();
    await db.delete('price_cache', where: 'source = ?', whereArgs: ['psa']);
    for (final p in prices) {
      await db.insert('price_cache', p.toMap());
    }
  }

  // ── PSA PX-Web fetch ─────────────────────────────────────────────────────

  static Future<List<MarketPrice>?> _fetchFromPsa() async {
    try {
      // First, get the metadata to find dimension codes for NCR and rice commodities
      final metaUri = Uri.parse('$_baseUrl/$_cerealsTable');
      final metaResp = await http.get(metaUri, headers: {
        'Accept': 'application/json',
        'User-Agent': 'SmartSpend/3 (+https://smartspend.app)',
      }).timeout(const Duration(seconds: 20));

      if (metaResp.statusCode != 200) return null;

      final meta = json.decode(metaResp.body) as Map<String, dynamic>;
      final variables = meta['variables'] as List<dynamic>?;
      if (variables == null) return null;

      // Build query: select NCR region + all rice commodities + latest period
      final queryBody = <String, dynamic>{
        'query': [],
        'response': {'format': 'json-stat'}
      };
      final filters = <Map<String, dynamic>>[];

      for (final v in variables) {
        final varMap = v as Map<String, dynamic>;
        final code = varMap['code'] as String;
        final values = (varMap['values'] as List<dynamic>).cast<String>();
        final valueTexts =
            (varMap['valueTexts'] as List<dynamic>).cast<String>();

        if (code.toLowerCase().contains('region') ||
            code.toLowerCase().contains('geog')) {
          // Select NCR (National Capital Region) or first region as fallback
          final ncrIdx = valueTexts.indexWhere((t) =>
              t.toLowerCase().contains('national capital') ||
              t.toLowerCase().contains('ncr') ||
              t.toLowerCase().contains('metro manila'));
          final selected = ncrIdx >= 0 ? [values[ncrIdx]] : [values[0]];
          filters.add({
            'code': code,
            'selection': {'filter': 'item', 'values': selected}
          });
        } else if (code.toLowerCase().contains('commodity') ||
            code.toLowerCase().contains('crop')) {
          // Select rice commodities
          final riceIndices = <int>[];
          for (int i = 0; i < valueTexts.length; i++) {
            final t = valueTexts[i].toLowerCase();
            if (t.contains('rice') || t.contains('palay')) {
              riceIndices.add(i);
            }
          }
          if (riceIndices.isEmpty) riceIndices.add(0);
          filters.add({
            'code': code,
            'selection': {
              'filter': 'item',
              'values': riceIndices.map((i) => values[i]).toList(),
            }
          });
        } else if (code.toLowerCase().contains('year') ||
            code.toLowerCase().contains('period') ||
            code.toLowerCase().contains('time')) {
          // Latest 3 periods
          final lastN =
              values.length > 3 ? values.sublist(values.length - 3) : values;
          filters.add({
            'code': code,
            'selection': {'filter': 'item', 'values': lastN}
          });
        } else {
          // Default: all values
          filters.add({
            'code': code,
            'selection': {'filter': 'item', 'values': values}
          });
        }
      }

      queryBody['query'] = filters;

      final dataUri = Uri.parse('$_baseUrl/$_cerealsTable');
      final dataResp = await http
          .post(
            dataUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'SmartSpend/3 (+https://smartspend.app)',
            },
            body: json.encode(queryBody),
          )
          .timeout(const Duration(seconds: 30));

      if (dataResp.statusCode != 200) return null;

      final data = json.decode(dataResp.body) as Map<String, dynamic>;
      return _parseJsonStat(data);
    } catch (_) {
      return null;
    }
  }

  /// Parse PX-Web JSON-stat response into a flat list of MarketPrice objects.
  static List<MarketPrice>? _parseJsonStat(Map<String, dynamic> data) {
    try {
      // JSON-stat format: { dataset: { dimension: {...}, value: [...], ... } }
      final dataset = (data['dataset'] ?? data) as Map<String, dynamic>;
      final values = (dataset['value'] as List<dynamic>)
          .map((e) => e == null ? null : (e as num))
          .toList();
      final dimension = dataset['dimension'] as Map<String, dynamic>;
      final dimIds = (dataset['id'] as List<dynamic>).cast<String>();

      // Build maps from dimension code → list of category labels
      final dimLabels = <String, List<String>>{};
      for (final id in dimIds) {
        final dim = dimension[id] as Map<String, dynamic>;
        final category = dim['category'] as Map<String, dynamic>;
        final labelMap = category['label'] as Map<String, dynamic>;
        dimLabels[id] = labelMap.values.cast<String>().toList();
      }

      // Build combinations and pair with values
      final result = <MarketPrice>[];
      final now = DateTime.now();

      // Find the commodity and period dimension indices
      final commodityDimIdx = dimIds.indexWhere((id) =>
          id.toLowerCase().contains('commodity') ||
          id.toLowerCase().contains('crop'));
      final periodDimIdx = dimIds.indexWhere((id) =>
          id.toLowerCase().contains('period') ||
          id.toLowerCase().contains('year') ||
          id.toLowerCase().contains('time'));

      if (commodityDimIdx < 0) return null;

      // Compute strides for each dimension
      final sizes = dimIds.map((id) {
        final dim = dimension[id] as Map<String, dynamic>;
        final category = dim['category'] as Map<String, dynamic>;
        return (category['label'] as Map<String, dynamic>).length;
      }).toList();

      final strides = List.filled(sizes.length, 1);
      for (int i = sizes.length - 2; i >= 0; i--) {
        strides[i] = strides[i + 1] * sizes[i + 1];
      }

      // Collect the latest value per commodity (last time period)
      final latestPerCommodity = <String, double>{};
      String latestPeriod = '';

      for (int idx = 0; idx < values.length; idx++) {
        final v = values[idx];
        if (v == null) continue;

        // Decode multi-dimensional index
        int remaining = idx;
        final dimIndices = <int>[];
        for (final stride in strides) {
          dimIndices.add(remaining ~/ stride);
          remaining %= stride;
        }

        final commodityLabel = dimLabels[dimIds[commodityDimIdx]]
                ?[dimIndices[commodityDimIdx]] ??
            '';
        String periodLabel = '';
        if (periodDimIdx >= 0) {
          periodLabel =
              dimLabels[dimIds[periodDimIdx]]?[dimIndices[periodDimIdx]] ?? '';
        }

        // Keep track of the latest period encountered
        if (periodLabel.isNotEmpty && periodLabel.compareTo(latestPeriod) > 0) {
          latestPeriod = periodLabel;
        }

        // Store/overwrite; last (chronologically latest) wins since values are ordered
        latestPerCommodity[commodityLabel] = v.toDouble();
        if (periodLabel.isNotEmpty) latestPeriod = periodLabel;
      }

      for (final entry in latestPerCommodity.entries) {
        if (entry.value <= 0) continue;
        result.add(MarketPrice(
          commodity: entry.key,
          price: entry.value,
          unit: 'per kg',
          fetchedAt: now,
          periodLabel: latestPeriod.isNotEmpty ? latestPeriod : null,
        ));
      }

      return result.isEmpty ? null : result;
    } catch (_) {
      return null;
    }
  }

  // ── Public API ──────────────────────────────────────────────────────────

  /// Returns cached market (retail) prices, refreshing from PSA if stale.
  /// Never throws — always returns a list.
  static Future<List<MarketPrice>> getMarketPrices(
      {bool forceRefresh = false}) async {
    final cached = await _getCached();

    if (!forceRefresh && cached.isNotEmpty) {
      final age = DateTime.now().difference(cached.first.fetchedAt).inDays;
      if (age < _ttlDays) return cached;
    }

    final live = await _fetchFromPsa();
    if (live != null && live.isNotEmpty) {
      await _writeCache(live);
      return live;
    }

    if (cached.isNotEmpty) return cached;

    // Static fallback
    final now = DateTime.now();
    return _staticFallback
        .map((m) => MarketPrice(
              commodity: m['commodity'] as String,
              price: m['price'] as double,
              unit: m['unit'] as String,
              fetchedAt: now.subtract(const Duration(days: 90)),
              periodLabel: m['period_label'] as String?,
            ))
        .toList();
  }

  static Future<bool> isDataStale() async {
    final cached = await _getCached();
    if (cached.isEmpty) return true;
    return DateTime.now().difference(cached.first.fetchedAt).inDays >
        _staleDays;
  }

  static Future<int?> cacheAgeDays() async {
    final cached = await _getCached();
    if (cached.isEmpty) return null;
    return DateTime.now().difference(cached.first.fetchedAt).inDays;
  }

  static void refreshInBackground() {
    getMarketPrices(forceRefresh: false);
  }
}
