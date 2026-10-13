import 'package:flutter/services.dart';
import '../widgets/peso_mascot.dart';

/// Haptic feedback patterns for Peso mascot interactions.
/// Uses Flutter's built-in HapticFeedback — no extra dependencies.
/// Designed to feel like Animal Crossing's "animalese" tactile feedback.
class PesoSoundService {
  static bool _enabled = true;

  static void setEnabled(bool v) => _enabled = v;

  /// Quick single tap — used when Peso is tapped
  static Future<void> playTap() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Triple pattern — used for celebrations (badge unlock, goal reached)
  static Future<void> playCelebrate() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.lightImpact();
  }

  /// Double soft click — used when Peso "talks" or a speech bubble appears
  static Future<void> playTalk() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 55));
    await HapticFeedback.selectionClick();
  }

  /// Single soft — used for gentle nudges, tips, info
  static Future<void> playNudge() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Mood-matched haptic — called on mood change
  static Future<void> playMoodChange(PesoMood mood) async {
    if (!_enabled) return;
    switch (mood) {
      case PesoMood.celebrating:
      case PesoMood.excited:
        await playCelebrate();
        break;
      case PesoMood.sad:
      case PesoMood.worried:
      case PesoMood.embarrassed:
        await HapticFeedback.lightImpact();
        break;
      case PesoMood.proud:
      case PesoMood.happy:
        await HapticFeedback.mediumImpact();
        break;
      case PesoMood.thinking:
      case PesoMood.winking:
        await HapticFeedback.selectionClick();
        break;
      default:
        break;
    }
  }
}
