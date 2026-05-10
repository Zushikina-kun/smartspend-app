import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_service.dart';

class CurrencyService {
  static const _baseUrl = 'https://open.er-api.com/v6/latest';

  static final supportedCurrencies = <String, String>{
    'PHP': '₱ Philippine Peso',
    'USD': r'$ US Dollar',
    'EUR': '€ Euro',
    'GBP': '£ British Pound',
    'JPY': '¥ Japanese Yen',
    'SGD': r'S$ Singapore Dollar',
    'AUD': r'A$ Australian Dollar',
    'CAD': r'C$ Canadian Dollar',
    'HKD': r'HK$ Hong Kong Dollar',
    'KRW': '₩ Korean Won',
    'CNY': '¥ Chinese Yuan',
    'MYR': 'RM Malaysian Ringgit',
    'IDR': 'Rp Indonesian Rupiah',
    'THB': '฿ Thai Baht',
    'VND': '₫ Vietnamese Dong',
    'INR': '₹ Indian Rupee',
    'SAR': '﷼ Saudi Riyal',
    'AED': 'د.إ UAE Dirham',
    'BRL': r'R$ Brazilian Real',
    'MXN': r'MX$ Mexican Peso',
    'CHF': 'Fr Swiss Franc',
    'SEK': 'kr Swedish Krona',
    'NOK': 'kr Norwegian Krone',
    'DKK': 'kr Danish Krone',
    'NZD': r'NZ$ New Zealand Dollar',
    'ZAR': 'R South African Rand',
    'TRY': '₺ Turkish Lira',
    'RUB': '₽ Russian Ruble',
    'PKR': '₨ Pakistani Rupee',
    'BDT': '৳ Bangladeshi Taka',
    'EGP': 'E£ Egyptian Pound',
    'NGN': '₦ Nigerian Naira',
    'KWD': 'KD Kuwaiti Dinar',
    'QAR': 'QR Qatari Riyal',
    'TWD': r'NT$ Taiwan Dollar',
    'BHD': 'BD Bahraini Dinar',
    'OMR': 'OMR Omani Rial',
    'ILS': '₪ Israeli Shekel',
    'CZK': 'Kč Czech Koruna',
    'PLN': 'zł Polish Zloty',
    'HUF': 'Ft Hungarian Forint',
    'CLP': 'CLP Chilean Peso',
    'COP': 'COP Colombian Peso',
    'PEN': 'S/ Peruvian Sol',
    'UAH': '₴ Ukrainian Hryvnia',
    'RON': 'lei Romanian Leu',
    'HRK': 'kn Croatian Kuna',
    'BGN': 'лв Bulgarian Lev',
    'LKR': '₨ Sri Lankan Rupee',
    'NPR': '₨ Nepalese Rupee',
    'MMK': 'K Myanmar Kyat',
    'KHR': '៛ Cambodian Riel',
    'LAK': '₭ Lao Kip',
    'BND': r'B$ Brunei Dollar',
    'MOP': 'P Macanese Pataca',
  };

  static final currencySymbols = <String, String>{
    'PHP': '₱',
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'SGD': r'S$',
    'AUD': r'A$',
    'CAD': r'C$',
    'HKD': r'HK$',
    'KRW': '₩',
    'CNY': '¥',
    'MYR': 'RM',
    'IDR': 'Rp',
    'THB': '฿',
    'VND': '₫',
    'INR': '₹',
    'SAR': '﷼',
    'AED': 'د.إ',
    'BRL': r'R$',
    'MXN': r'MX$',
    'CHF': 'Fr',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'NZD': r'NZ$',
    'ZAR': 'R',
    'TRY': '₺',
    'RUB': '₽',
    'PKR': '₨',
    'BDT': '৳',
    'EGP': 'E£',
    'NGN': '₦',
    'KWD': 'KD',
    'QAR': 'QR',
    'TWD': r'NT$',
    'BHD': 'BD',
    'OMR': 'OMR',
    'ILS': '₪',
    'CZK': 'Kč',
    'PLN': 'zł',
    'HUF': 'Ft',
    'CLP': 'CLP',
    'COP': 'COP',
    'PEN': 'S/',
    'UAH': '₴',
    'RON': 'lei',
    'HRK': 'kn',
    'BGN': 'лв',
    'LKR': '₨',
    'NPR': '₨',
    'MMK': 'K',
    'KHR': '៛',
    'LAK': '₭',
    'BND': r'B$',
    'MOP': 'P',
  };

  static String _currentCurrency = 'PHP';
  static double _rateFromPHP = 1.0;
  static DateTime? _lastFetched;

  static String get currentCurrency => _currentCurrency;
  static String get symbol =>
      currencySymbols[_currentCurrency] ?? _currentCurrency;

  static Future<void> init() async {
    final saved = await DBService.getSetting('currency');
    _currentCurrency = saved ?? 'PHP';
    await _loadRate();
  }

  static Future<void> setCurrency(String code) async {
    _currentCurrency = code;
    await DBService.setSetting('currency', code);
    await _loadRate(force: true);
  }

  static double convert(double phpAmount) => phpAmount * _rateFromPHP;

  static String format(double phpAmount) {
    final converted = convert(phpAmount);
    // No decimal places for these currencies (and PHP — Filipinos don't use centavos in daily tracking)
    const noDecimal = [
      'PHP',
      'JPY',
      'KRW',
      'IDR',
      'VND',
      'NGN',
      'MMK',
      'LAK',
      'KHR',
      'HUF',
      'CLP',
      'COP'
    ];
    if (noDecimal.contains(_currentCurrency)) {
      return '$symbol${converted.toStringAsFixed(0)}';
    }
    return '$symbol${converted.toStringAsFixed(2)}';
  }

  static Future<void> _loadRate({bool force = false}) async {
    if (_currentCurrency == 'PHP') {
      _rateFromPHP = 1.0;
      return;
    }
    if (!force &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!).inHours < 1) return;

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/PHP'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        _rateFromPHP = (rates[_currentCurrency] as num?)?.toDouble() ?? 1.0;
        _lastFetched = DateTime.now();
        await DBService.setSetting(
            'exchange_rate_$_currentCurrency', _rateFromPHP.toString());
        await DBService.setSetting(
            'exchange_rate_updated', DateTime.now().toIso8601String());
      }
    } catch (_) {
      final cached =
          await DBService.getSetting('exchange_rate_$_currentCurrency');
      if (cached != null) _rateFromPHP = double.tryParse(cached) ?? 1.0;
    }
  }

  static Future<String> getLastUpdated() async {
    final ts = await DBService.getSetting('exchange_rate_updated');
    if (ts == null) return 'Not yet fetched';
    try {
      final dt = DateTime.parse(ts);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Unknown';
    }
  }
}
