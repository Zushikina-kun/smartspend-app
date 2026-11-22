// Tests for CurrencyService — pure logic only, no DB, no network.
// Tests run against the default PHP currency state (_currentCurrency = 'PHP',
// _rateFromPHP = 1.0) which is set at class definition time and does not
// require DB/network initialisation.

import 'package:flutter_test/flutter_test.dart';
import 'package:smartspend_app/services/currency_service.dart';

void main() {
  group('CurrencyService.format (PHP default)', () {
    // PHP is in the noDecimal list, so amounts are rounded to 0 decimal
    // places and prefixed with the ₱ symbol.

    test('format(1234.56) contains the ₱ symbol', () {
      final result = CurrencyService.format(1234.56);
      expect(result, contains('₱'));
    });

    test('format(1234.56) contains the rounded integer amount', () {
      // PHP uses toStringAsFixed(0), so 1234.56 → "₱1235"
      final result = CurrencyService.format(1234.56);
      expect(result, contains('1235'));
    });

    test('format(0) contains "0"', () {
      final result = CurrencyService.format(0);
      expect(result, contains('0'));
    });

    test('format(0) starts with ₱', () {
      final result = CurrencyService.format(0);
      expect(result.startsWith('₱'), isTrue);
    });

    test('format(-500) does not throw', () {
      expect(() => CurrencyService.format(-500), returnsNormally);
    });

    test('format(-500) contains "500"', () {
      final result = CurrencyService.format(-500);
      expect(result, contains('500'));
    });

    test('format(-500) contains the ₱ symbol', () {
      final result = CurrencyService.format(-500);
      expect(result, contains('₱'));
    });

    test('format(1000000) contains "1000000"', () {
      final result = CurrencyService.format(1000000);
      expect(result, contains('1000000'));
    });
  });

  group('CurrencyService.convert (PHP default, rate = 1.0)', () {
    test('convert(100) returns 100.0 when rate is 1.0', () {
      expect(CurrencyService.convert(100), 100.0);
    });

    test('convert(0) returns 0.0', () {
      expect(CurrencyService.convert(0), 0.0);
    });
  });

  group('CurrencyService.formatCompact (PHP default)', () {
    test('formatCompact(500) returns ₱500', () {
      expect(CurrencyService.formatCompact(500), '₱500');
    });

    test('formatCompact(1500) returns abbreviated K form', () {
      final result = CurrencyService.formatCompact(1500);
      expect(result, contains('K'));
      expect(result, contains('₱'));
    });

    test('formatCompact(2000000) returns abbreviated M form', () {
      final result = CurrencyService.formatCompact(2000000);
      expect(result, contains('M'));
      expect(result, contains('₱'));
    });
  });

  group('CurrencyService static accessors', () {
    test('currentCurrency is a non-empty string', () {
      expect(CurrencyService.currentCurrency, isA<String>());
      expect(CurrencyService.currentCurrency, isNotEmpty);
    });

    test('symbol is a non-empty string', () {
      expect(CurrencyService.symbol, isA<String>());
      expect(CurrencyService.symbol, isNotEmpty);
    });

    test('supportedCurrencies contains PHP', () {
      expect(CurrencyService.supportedCurrencies, containsPair('PHP', isA<String>()));
    });

    test('currencySymbols maps PHP to ₱', () {
      expect(CurrencyService.currencySymbols['PHP'], '₱');
    });
  });
}
