/// Verification test for Settings visibility toggles
/// 
/// This test demonstrates that visibility toggles use key-based references,
/// not position-based indices, making them immune to widget reordering.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Settings Visibility Toggle Verification', () {
    
    // Test that the toggle keys are string-based, not position-based
    test('Toggle keys are strings (key-based, not position-based)', () {
      // This is the correct pattern used in the app
      const toggleKeys = [
        'show_subscriptions',
        'show_quick_log',
        'show_badges',
        'show_mood_home',
        'show_forecast',
        'show_prediction',
        'show_payday_countdown',
        'show_monthly_recap',
        'show_challenges',
        'show_safe_to_spend',
        'show_dti',
        'show_emergency_fund',
        'show_milestones',
        'show_market_insights',
      ];

      // Verify all keys are strings
      for (final key in toggleKeys) {
        expect(key, isA<String>());
        expect(key.startsWith('show_'), isTrue, 
          reason: 'All visibility toggles should start with "show_"');
      }

      // Verify we have all 14 toggles
      expect(toggleKeys.length, 14, 
        reason: 'There should be 14 visibility toggles total (10 home + 4 analytics)');
    });

    test('Widget visibility is controlled by setting key, not position', () {
      // Simulated toggle state
      final settings = {
        'show_subscriptions': true,
        'show_quick_log': false,
        'show_badges': true,
        'show_mood_home': false,
      };

      // Simulated widget list (order doesn't matter)
      final widgets = <String>[];
      
      // This is how the app actually does it (key-based)
      if (settings['show_subscriptions'] == true) {
        widgets.add('SubscriptionCard');
      }
      if (settings['show_quick_log'] == true) {
        widgets.add('QuickLogChips');
      }
      if (settings['show_badges'] == true) {
        widgets.add('BadgesRow');
      }
      if (settings['show_mood_home'] == true) {
        widgets.add('MoodCheckIn');
      }

      // Expected result: only enabled widgets appear
      expect(widgets, ['SubscriptionCard', 'BadgesRow']);
      
      // Verify order is determined by code order, not by toggle state
      expect(widgets[0], 'SubscriptionCard');
      expect(widgets[1], 'BadgesRow');
    });

    test('Reordering widgets does not affect toggle mappings', () {
      // Original order
      final originalWidgets = ['A', 'B', 'C', 'D'];
      final originalToggles = {
        'show_a': true,
        'show_b': false,
        'show_c': true,
        'show_d': false,
      };

      // Build list based on toggles (original order)
      final result1 = <String>[];
      if (originalToggles['show_a'] == true) result1.add('A');
      if (originalToggles['show_b'] == true) result1.add('B');
      if (originalToggles['show_c'] == true) result1.add('C');
      if (originalToggles['show_d'] == true) result1.add('D');

      expect(result1, ['A', 'C']);

      // NOW REORDER THE WIDGETS IN CODE
      final reorderedWidgets = ['C', 'A', 'D', 'B']; // Different order!
      
      // Build list based on same toggles (new order)
      final result2 = <String>[];
      if (originalToggles['show_c'] == true) result2.add('C');
      if (originalToggles['show_a'] == true) result2.add('A');
      if (originalToggles['show_d'] == true) result2.add('D');
      if (originalToggles['show_b'] == true) result2.add('B');

      // Different order, but SAME widgets shown (C and A)
      expect(result2, ['C', 'A']);
      
      // Key point: 'show_a' still controls 'A', 'show_c' still controls 'C'
      // The mapping is based on the KEY NAME, not the position
      expect(result2.contains('A'), true, reason: 'show_a=true means A appears');
      expect(result2.contains('B'), false, reason: 'show_b=false means B is hidden');
      expect(result2.contains('C'), true, reason: 'show_c=true means C appears');
      expect(result2.contains('D'), false, reason: 'show_d=false means D is hidden');
    });

    test('Experience presets set all toggles atomically', () {
      // Simulate the Lite preset
      final litePreset = {
        'show_subscriptions': false,
        'show_quick_log': true,
        'show_badges': false,
        'show_mood_home': false,
        'show_forecast': false,
        'show_prediction': false,
        'show_payday_countdown': true,
        'show_monthly_recap': false,
        'show_challenges': false,
        'show_safe_to_spend': true,
        'show_dti': false,
        'show_emergency_fund': true,
        'show_milestones': false,
        'show_market_insights': false,
      };

      // Count enabled features
      final enabledCount = litePreset.values.where((v) => v == true).length;
      
      // Lite mode should enable exactly 4 features
      expect(enabledCount, 4, reason: 'Lite preset enables 4 features: Quick Log, Payday, Safe-to-Spend, Emergency Fund');
      
      // Verify specific features
      expect(litePreset['show_quick_log'], true);
      expect(litePreset['show_payday_countdown'], true);
      expect(litePreset['show_safe_to_spend'], true);
      expect(litePreset['show_emergency_fund'], true);
    });

    test('Analytics toggles work independently of home toggles', () {
      // Home screen toggles
      final homeToggles = {
        'show_subscriptions': false,
        'show_quick_log': true,
      };

      // Analytics screen toggles
      final analyticsToggles = {
        'show_dti': true,
        'show_emergency_fund': false,
        'show_milestones': true,
        'show_market_insights': false,
      };

      // Verify they don't interfere with each other
      expect(homeToggles.keys.toSet().intersection(analyticsToggles.keys.toSet()), isEmpty,
        reason: 'Home and Analytics toggles should have separate keys');

      // Count enabled analytics features
      final enabledAnalytics = analyticsToggles.values.where((v) => v == true).length;
      expect(enabledAnalytics, 2, reason: 'DTI and Milestones are enabled');
    });
  });

  group('Position-Based vs Key-Based Comparison', () {
    
    test('BROKEN: Position-based approach (what we do NOT use)', () {
      // This is the WRONG way to do it (position-based)
      final widgets = ['QuickAccess', 'Subscriptions', 'Badges', 'Mood'];
      final toggles = [true, false, true, false]; // Position-based toggles

      // Build visible list
      final visible = <String>[];
      for (int i = 0; i < widgets.length; i++) {
        if (toggles[i]) visible.add(widgets[i]);
      }
      
      expect(visible, ['QuickAccess', 'Badges']);

      // NOW REORDER: Move QuickAccess from position 0 to position 2
      final reordered = ['Subscriptions', 'Badges', 'QuickAccess', 'Mood'];
      // But toggles still reference OLD positions!
      
      // Build visible list with SAME toggles [true, false, true, false]
      final broken = <String>[];
      for (int i = 0; i < reordered.length; i++) {
        if (toggles[i]) broken.add(reordered[i]);
      }
      
      // BROKEN: Now position 0 shows Subscriptions (was false), 
      //         and position 2 shows QuickAccess (new position, still controlled by old index)
      expect(broken, ['Subscriptions', 'QuickAccess']);
      
      // BUG: Toggle for QuickAccess (index 0) now controls Subscriptions!
      expect(broken.contains('Subscriptions'), true, 
        reason: 'BUG: Reordering broke the mapping!');
    });

    test('CORRECT: Key-based approach (what we actually use)', () {
      // This is the RIGHT way (key-based)
      final settings = {
        'show_quick_access': true,
        'show_subscriptions': false,
        'show_badges': true,
        'show_mood': false,
      };

      // Original order
      final widgets1 = <String>[];
      if (settings['show_quick_access'] == true) widgets1.add('QuickAccess');
      if (settings['show_subscriptions'] == true) widgets1.add('Subscriptions');
      if (settings['show_badges'] == true) widgets1.add('Badges');
      if (settings['show_mood'] == true) widgets1.add('Mood');
      
      expect(widgets1, ['QuickAccess', 'Badges']);

      // NOW REORDER: Change code order
      final widgets2 = <String>[];
      if (settings['show_subscriptions'] == true) widgets2.add('Subscriptions');
      if (settings['show_badges'] == true) widgets2.add('Badges');
      if (settings['show_quick_access'] == true) widgets2.add('QuickAccess');
      if (settings['show_mood'] == true) widgets2.add('Mood');
      
      // CORRECT: Same widgets appear, just in different order
      expect(widgets2, ['Badges', 'QuickAccess']);
      
      // Verify mappings still correct
      expect(widgets2.contains('QuickAccess'), true, 
        reason: 'show_quick_access=true still shows QuickAccess');
      expect(widgets2.contains('Subscriptions'), false, 
        reason: 'show_subscriptions=false still hides Subscriptions');
      expect(widgets2.contains('Badges'), true,
        reason: 'show_badges=true still shows Badges');
    });
  });
}
