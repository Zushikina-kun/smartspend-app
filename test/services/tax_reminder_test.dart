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

  group('TaxReminderService.getUpcomingDeadlines — vat', () {
    test('returns 5 deadlines (4 quarterly + Annual ITR)', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'vat');
      expect(deadlines.length, 5);
    });

    test('all daysAway values are >= 0 (no past deadlines)', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'vat');
      for (final d in deadlines) {
        expect(d['daysAway'] as int, greaterThanOrEqualTo(0));
      }
    });

    test('Q1 VAT deadline falls on April 25', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'vat');
      final q1 = deadlines.firstWhere(
        (d) => (d['name'] as String).contains('Q1'),
        orElse: () => {},
      );
      expect(q1, isNotEmpty, reason: 'Q1 VAT deadline not found');
      final date = q1['date'] as DateTime;
      expect(date.month, 4, reason: 'Q1 VAT deadline should be in April');
      expect(date.day, 25, reason: 'Q1 VAT deadline should be on the 25th');
    });

    test('Q3 VAT deadline falls on October 25', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'vat');
      final q3 = deadlines.firstWhere(
        (d) => (d['name'] as String).contains('Q3'),
        orElse: () => {},
      );
      expect(q3, isNotEmpty, reason: 'Q3 VAT deadline not found');
      final date = q3['date'] as DateTime;
      expect(date.month, 10, reason: 'Q3 VAT deadline should be in October');
      expect(date.day, 25, reason: 'Q3 VAT deadline should be on the 25th');
    });

    test('all VAT quarterly deadlines are on the 25th', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'vat');
      final quarterly = deadlines
          .where((d) => (d['name'] as String).contains('2550Q'))
          .toList();
      expect(quarterly.length, 4);
      for (final d in quarterly) {
        expect((d['date'] as DateTime).day, 25,
            reason: 'VAT deadline ${d['name']} should be on the 25th');
      }
    });

    test('includes Annual ITR', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'vat');
      final itr = deadlines.firstWhere(
        (d) => (d['name'] as String).contains('ITR'),
        orElse: () => {},
      );
      expect(itr, isNotEmpty, reason: 'Annual ITR not found in VAT deadlines');
    });
  });

  group('TaxReminderService.getUpcomingDeadlines — professional/mixed_income',
      () {
    test('professional returns 9 deadlines (4×2551Q + 4×1701Q + Annual ITR)',
        () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'professional');
      expect(deadlines.length, 9);
    });

    test('mixed_income returns 9 deadlines', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'mixed_income');
      expect(deadlines.length, 9);
    });

    test('all daysAway values are >= 0', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'professional');
      for (final d in deadlines) {
        expect(d['daysAway'] as int, greaterThanOrEqualTo(0));
      }
    });

    test('1701Q Q1 deadline falls on January 15', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'professional');
      final q1 = deadlines.firstWhere(
        (d) =>
            (d['name'] as String).contains('1701Q') &&
            (d['name'] as String).contains('Q1'),
        orElse: () => {},
      );
      expect(q1, isNotEmpty, reason: '1701Q Q1 deadline not found');
      final date = q1['date'] as DateTime;
      expect(date.month, 1, reason: '1701Q Q1 should be in January');
      expect(date.day, 15, reason: '1701Q Q1 should be on the 15th');
    });

    test('1701Q Q3 deadline falls on July 15', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'professional');
      final q3 = deadlines.firstWhere(
        (d) =>
            (d['name'] as String).contains('1701Q') &&
            (d['name'] as String).contains('Q3'),
        orElse: () => {},
      );
      expect(q3, isNotEmpty, reason: '1701Q Q3 deadline not found');
      final date = q3['date'] as DateTime;
      expect(date.month, 7, reason: '1701Q Q3 should be in July');
      expect(date.day, 15, reason: '1701Q Q3 should be on the 15th');
    });

    test('includes both 2551Q and 1701Q deadlines', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'professional');
      final has2551q =
          deadlines.any((d) => (d['name'] as String).contains('2551Q'));
      final has1701q =
          deadlines.any((d) => (d['name'] as String).contains('1701Q'));
      expect(has2551q, isTrue, reason: 'Missing 2551Q deadlines');
      expect(has1701q, isTrue, reason: 'Missing 1701Q deadlines');
    });

    test('includes Annual ITR', () {
      final deadlines =
          TaxReminderService.getUpcomingDeadlines(taxpayerType: 'professional');
      final itr = deadlines.firstWhere(
        (d) => (d['name'] as String).contains('ITR'),
        orElse: () => {},
      );
      expect(itr, isNotEmpty,
          reason: 'Annual ITR not found in professional deadlines');
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
      expect(TaxReminderService.estimatePercentageTax(100000),
          closeTo(3000, 0.01));
      expect(TaxReminderService.estimatePercentageTax(0), closeTo(0, 0.01));
    });
  });
}
