// Tests for TaxReminderService — pure logic, no notifications, no DB, no network.

import 'package:flutter_test/flutter_test.dart';
import 'package:smartspend_app/services/tax_reminder_service.dart';

void main() {
  group('TaxReminderService.getUpcomingDeadlines', () {
    test('returns a non-empty list', () {
      final deadlines = TaxReminderService.getUpcomingDeadlines();
      expect(deadlines, isNotEmpty);
    });

    test('all entries have the required keys', () {
      final deadlines = TaxReminderService.getUpcomingDeadlines();
      for (final d in deadlines) {
        expect(d.containsKey('name'), isTrue);
        expect(d.containsKey('date'), isTrue);
        expect(d.containsKey('daysAway'), isTrue);
        expect(d['date'], isA<DateTime>());
        expect(d['daysAway'], isA<int>());
      }
    });

    test('deadlines are sorted ascending by daysAway', () {
      final deadlines = TaxReminderService.getUpcomingDeadlines();
      for (int i = 0; i < deadlines.length - 1; i++) {
        expect(deadlines[i]['daysAway'] as int,
            lessThanOrEqualTo(deadlines[i + 1]['daysAway'] as int));
      }
    });

    test('all daysAway values are >= 0 (no past deadlines)', () {
      final deadlines = TaxReminderService.getUpcomingDeadlines();
      for (final d in deadlines) {
        expect(d['daysAway'] as int, greaterThanOrEqualTo(0));
      }
    });

    test('Q1 deadline falls on April 15', () {
      final deadlines = TaxReminderService.getUpcomingDeadlines();
      final q1 = deadlines.firstWhere(
        (d) => (d['name'] as String).contains('Q1'),
        orElse: () => {},
      );
      expect(q1, isNotEmpty, reason: 'Q1 deadline not found');
      final date = q1['date'] as DateTime;
      expect(date.month, 4, reason: 'Q1 deadline should be in April');
      expect(date.day, 15, reason: 'Q1 deadline should be on the 15th');
    });

    test('Q2 deadline falls on August 15', () {
      final deadlines = TaxReminderService.getUpcomingDeadlines();
      final q2 = deadlines.firstWhere(
        (d) => (d['name'] as String).contains('Q2'),
        orElse: () => {},
      );
      expect(q2, isNotEmpty, reason: 'Q2 deadline not found');
      final date = q2['date'] as DateTime;
      expect(date.month, 8, reason: 'Q2 deadline should be in August');
      expect(date.day, 15, reason: 'Q2 deadline should be on the 15th');
    });

    test('Q3 deadline falls on November 15', () {
      final deadlines = TaxReminderService.getUpcomingDeadlines();
      final q3 = deadlines.firstWhere(
        (d) => (d['name'] as String).contains('Q3'),
        orElse: () => {},
      );
      expect(q3, isNotEmpty, reason: 'Q3 deadline not found');
      final date = q3['date'] as DateTime;
      expect(date.month, 11, reason: 'Q3 deadline should be in November');
      expect(date.day, 15, reason: 'Q3 deadline should be on the 15th');
    });

    test('Q4 deadline falls on January 30', () {
      final deadlines = TaxReminderService.getUpcomingDeadlines();
      final q4 = deadlines.firstWhere(
        (d) => (d['name'] as String).contains('Q4'),
        orElse: () => {},
      );
      expect(q4, isNotEmpty, reason: 'Q4 deadline not found');
      final date = q4['date'] as DateTime;
      expect(date.month, 1, reason: 'Q4 deadline should be in January');
      expect(date.day, 30, reason: 'Q4 deadline should be on the 30th');
    });
  });

  group('TaxReminderService.estimateIncomeTax', () {
    test('income <= 250k returns 0 tax', () {
      final result = TaxReminderService.estimateIncomeTax(250000);
      expect(result['taxDue'], 0.0);
      expect(result['method'], 'Tax Exempt');
    });

    test('income 300k uses lower of 8% flat vs graduated', () {
      final result = TaxReminderService.estimateIncomeTax(300000);
      expect(result['taxDue'], isA<double>());
      expect((result['taxDue'] as double), greaterThan(0));
      // 8% flat: (300k - 250k) * 0.08 = 4000
      // graduated: (300k - 250k) * 0.15 = 7500 — flat wins
      expect(result['method'], '8% Flat Rate');
      expect(result['taxDue'], closeTo(4000, 0.01));
    });

    test('income above 3M uses graduated rate only', () {
      final result = TaxReminderService.estimateIncomeTax(5000000);
      expect(result['method'], 'Graduated Rate');
    });
  });

  group('TaxReminderService.estimatePercentageTax', () {
    test('3% of quarterly revenue', () {
      expect(
          TaxReminderService.estimatePercentageTax(100000), closeTo(3000, 0.01));
      expect(
          TaxReminderService.estimatePercentageTax(0), closeTo(0, 0.01));
    });
  });
}
