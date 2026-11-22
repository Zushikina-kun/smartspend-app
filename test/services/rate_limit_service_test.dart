// Tests for RateLimitService — pure logic, no network.

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:smartspend_app/services/rate_limit_service.dart';

void main() {
  setUp(() {
    // Reset notifier before each test
    RateLimitService.openRouterRemaining.value = null;
  });

  group('openRouterRemaining initial state', () {
    test('starts as null', () {
      expect(RateLimitService.openRouterRemaining.value, isNull);
    });
  });

  group('showWarning', () {
    test('returns false when remaining is null', () {
      RateLimitService.openRouterRemaining.value = null;
      expect(RateLimitService.showWarning, isFalse);
    });

    test('returns false when remaining >= 100', () {
      RateLimitService.openRouterRemaining.value = 100;
      expect(RateLimitService.showWarning, isFalse);
    });

    test('returns true when remaining < 100', () {
      RateLimitService.openRouterRemaining.value = 99;
      expect(RateLimitService.showWarning, isTrue);
    });

    test('returns true when remaining is 0', () {
      RateLimitService.openRouterRemaining.value = 0;
      expect(RateLimitService.showWarning, isTrue);
    });

    test('returns true when remaining is 1', () {
      RateLimitService.openRouterRemaining.value = 1;
      expect(RateLimitService.showWarning, isTrue);
    });

    test('returns false when remaining is 500', () {
      RateLimitService.openRouterRemaining.value = 500;
      expect(RateLimitService.showWarning, isFalse);
    });
  });

  group('recordFromResponse', () {
    test('parses x-ratelimit-remaining header and stores it', () {
      final response = http.Response('', 200, headers: {
        'x-ratelimit-remaining': '42',
      });
      RateLimitService.recordFromResponse(response);
      expect(RateLimitService.openRouterRemaining.value, 42);
    });

    test('ignores response with no x-ratelimit-remaining header', () {
      RateLimitService.openRouterRemaining.value = 50;
      final response = http.Response('', 200, headers: {});
      RateLimitService.recordFromResponse(response);
      // Value unchanged
      expect(RateLimitService.openRouterRemaining.value, 50);
    });

    test('ignores response with non-integer x-ratelimit-remaining', () {
      RateLimitService.openRouterRemaining.value = 50;
      final response = http.Response('', 200, headers: {
        'x-ratelimit-remaining': 'not-a-number',
      });
      RateLimitService.recordFromResponse(response);
      // Value unchanged
      expect(RateLimitService.openRouterRemaining.value, 50);
    });

    test('updates to 0 when header is "0"', () {
      final response = http.Response('', 200, headers: {
        'x-ratelimit-remaining': '0',
      });
      RateLimitService.recordFromResponse(response);
      expect(RateLimitService.openRouterRemaining.value, 0);
      expect(RateLimitService.showWarning, isTrue);
    });

    test('updates to 999 when header is "999"', () {
      final response = http.Response('', 200, headers: {
        'x-ratelimit-remaining': '999',
      });
      RateLimitService.recordFromResponse(response);
      expect(RateLimitService.openRouterRemaining.value, 999);
      expect(RateLimitService.showWarning, isFalse);
    });

    test('openRouterRemaining is a ValueNotifier<int?>', () {
      expect(RateLimitService.openRouterRemaining.value, isA<int?>());
    });
  });
}
