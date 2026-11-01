import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/peso_activity_log.dart';
import '../services/peso_context_service.dart';
import '../services/peso_sound_service.dart';
import '../services/peso_voice_service.dart';

/// Peso — SmartSpend's mascot.
///
/// A friendly round coin character with big expressive eyes, tiny arms
/// and legs, and a ₱ symbol on his forehead. Clean, round, iconic.
///
/// Design principles (inspired by Duolingo's Duo):
/// - One strong color = the character (emerald green = Peso)
/// - Huge eyes = emotional expressiveness at any size
/// - Minimal detail = readable at 24px or 240px
/// - Round body = approachable, friendly, non-threatening
///
/// Usage:
///   PesoMascot(size: 80)
///   PesoMascot(size: 80, mood: PesoMood.sad)
///   PesoMascot.withSpeech(size: 80, text: "Hi there!")
enum PesoMood {
  happy,
  neutral,
  thinking,
  sad,
  celebrating,
  excited,
  surprised,
  proud,
  embarrassed,
  winking,
  sleepy,
  worried
}

/// SmartSpend brand green — Peso's signature color
const kPesoGreen = Color(0xFF00C896);
const kPesoGreenDark = Color(0xFF008F6A);
const kPesoGreenLight = Color(0xFFB3F5E6);

class PesoMascot extends StatefulWidget {
  final double size;
  final PesoMood mood;
  final VoidCallback? onTap;
  final PesoMood? tapMood;
  final String? tapSpeech;
  // New gesture params — all nullable/optional, fully backward-compatible
  final VoidCallback? onDoubleTap;
  final PesoMood? doubleTapMood;
  final VoidCallback? onLongPress;
  final PesoMood? longPressMood;

  /// Rotating idle lines shown after 8 s of no interaction.
  /// Null = use built-in defaults.
  final List<String>? idleSpeeches;

  /// Optional context key for gesture logging (e.g. 'budget', 'home').
  final String? contextKey;

  const PesoMascot({
    super.key,
    this.size = 72,
    this.mood = PesoMood.happy,
    this.onTap,
    this.tapMood,
    this.tapSpeech,
    this.onDoubleTap,
    this.doubleTapMood,
    this.onLongPress,
    this.longPressMood,
    this.idleSpeeches,
    this.contextKey,
  });

  /// Peso with a speech bubble above him
  static Widget withSpeech({
    double size = 72,
    PesoMood mood = PesoMood.happy,
    required String text,
    Color? bubbleColor,
    TextStyle? textStyle,
  }) {
    return _PesoWithSpeech(
      size: size,
      mood: mood,
      text: text,
      bubbleColor: bubbleColor,
      textStyle: textStyle,
    );
  }

  /// Returns a time- and day-aware default mood for Peso.
  static PesoMood get timeAwareMood {
    final now = DateTime.now();
    final h = now.hour;
    final dow = now.weekday;
    if (h < 6) return PesoMood.sleepy;
    if (dow == 1 && h < 10) return PesoMood.excited; // Monday morning
    if ((dow == 5 || dow == 6) && h >= 17) {
      return PesoMood.winking; // Fri/Sat evening
    }
    if (h >= 22) return PesoMood.sleepy;
    return PesoMood.happy;
  }

  @override
  State<PesoMascot> createState() => _PesoMascotState();
}

class _PesoMascotState extends State<PesoMascot> with TickerProviderStateMixin {
  late AnimationController _idleCtrl;
  late AnimationController _moodCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _tapCtrl;
  PesoMood? _currentMood;
  Timer? _idleSpeechTimer;
  Timer? _moodRevertTimer;

  static const _defaultIdleSpeeches = [
    'Tap me anytime to ask about your money! 💬',
    "I can log expenses, set budgets, or just chat! 😊",
    'Kumusta ang finances mo? 🇵🇭',
    "Tell me what you spent — I'll handle the rest! ✅",
  ];

  // Gesture state
  int _tapCount = 0;
  Timer? _tapTimer;
  Timer? _idleReactionTimer;
  bool _idleReactionFired = false;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _moodCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.of(context).disableAnimations) {
        _idleCtrl.repeat(reverse: true);
        _scheduleBlink();
      }
      if (widget.size >= 48) _scheduleIdleReaction();
      _startIdleSpeechTimer();
    });
  }

  // ── IDLE SPEECH TIMER ──────────────────────────────────────────────────────

  void _startIdleSpeechTimer() {
    _idleSpeechTimer?.cancel();
    _idleSpeechTimer = Timer(const Duration(seconds: 8), _fireIdleSpeech);
  }

  Future<void> _fireIdleSpeech() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRaw = prefs.getString('peso_idle_speech_date') ?? '';
      if (lastRaw.isNotEmpty) {
        final last = DateTime.tryParse(lastRaw);
        if (last != null && DateTime.now().difference(last).inMinutes < 60) {
          return; // throttle to once per hour
        }
      }
      await prefs.setString(
          'peso_idle_speech_date', DateTime.now().toIso8601String());
    } catch (_) {}
    if (!mounted) return;
    _moodRevertTimer?.cancel();
    setState(() => _currentMood = PesoMood.winking);
    PesoSoundService.playNudge();
    final speeches = widget.idleSpeeches ?? _defaultIdleSpeeches;
    final line = speeches[DateTime.now().second % speeches.length];
    _showSpeechBubbleOverlay(line);
    _moodRevertTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _currentMood = null);
    });
    _startIdleSpeechTimer(); // re-arm
  }

  // ── GESTURE HANDLERS ───────────────────────────────────────────────────────

  void _handleTap() {
    _startIdleSpeechTimer();
    _tapCount++;
    _tapTimer?.cancel();
    if (_tapCount >= 3) {
      _tapCount = 0;
      _handleTripleTap();
      return;
    }
    _tapTimer = Timer(const Duration(milliseconds: 400), () {
      _tapCount = 0;
      _doSingleTap();
    });
  }

  void _doSingleTap() {
    _tapCtrl.forward(from: 0).then((_) => _tapCtrl.reverse());
    PesoSoundService.playTap();
    if (widget.tapMood != null) {
      _moodRevertTimer?.cancel();
      setState(() => _currentMood = widget.tapMood);
      _moodRevertTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _currentMood = null);
      });
    }
    SharedPreferences.getInstance().then((prefs) {
      final count = (prefs.getInt('peso_tap_count') ?? 0) + 1;
      prefs.setInt('peso_tap_count', count);
      prefs.setString('peso_last_interaction',
          DateTime.now().toIso8601String().substring(0, 10));
    }).catchError((_) {});
    if (widget.tapSpeech != null && mounted) {
      _showSpeechBubbleOverlay(widget.tapSpeech!);
    }
    PesoActivityLog.log('peso_tap:${widget.contextKey ?? 'unknown'}');
    widget.onTap?.call();
  }

  void _handleDoubleTap() {
    _startIdleSpeechTimer();
    _tapCtrl.forward(from: 0).then((_) => _tapCtrl.reverse());
    _moodRevertTimer?.cancel();
    final mood = widget.doubleTapMood ?? PesoMood.surprised;
    setState(() => _currentMood = mood);
    _moodRevertTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _currentMood = null);
    });
    PesoSoundService.playTalk();
    PesoActivityLog.log('peso_doubletap:${widget.contextKey ?? 'unknown'}');
    SharedPreferences.getInstance().then((prefs) {
      final count = (prefs.getInt('peso_double_tap_count') ?? 0) + 1;
      prefs.setInt('peso_double_tap_count', count);
      prefs.setString('peso_last_interaction',
          DateTime.now().toIso8601String().substring(0, 10));
    }).catchError((_) {});
    final ctx = _contextFromKey(widget.contextKey);
    final line = PesoVoiceService.get(ctx);
    _showSpeechBubbleOverlay(line);
    widget.onDoubleTap?.call();
  }

  void _handleLongPress() {
    _startIdleSpeechTimer();
    _moodRevertTimer?.cancel();
    final mood = widget.longPressMood ?? PesoMood.winking;
    setState(() => _currentMood = mood);
    _moodRevertTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _currentMood = null);
    });
    PesoSoundService.playCelebrate();
    PesoActivityLog.log('peso_longpress:${widget.contextKey ?? 'unknown'}');
    SharedPreferences.getInstance().then((prefs) {
      final count = (prefs.getInt('peso_long_press_count') ?? 0) + 1;
      prefs.setInt('peso_long_press_count', count);
      prefs.setString('peso_last_interaction',
          DateTime.now().toIso8601String().substring(0, 10));
    }).catchError((_) {});
    _showLongPressSheet();
    widget.onLongPress?.call();
  }

  void _handleTripleTap() {
    setState(() => _currentMood = PesoMood.celebrating);
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _currentMood = null);
    });
    PesoSoundService.playCelebrate();
    PesoActivityLog.log('peso_triple:${widget.contextKey ?? 'unknown'}');
    const easterEggs = [
      '₱sos! You found the secret! 🤫',
      'Triple tap! Galing mo! 🎉 Peso is impressed!',
      'You tapped me 3x?! Ay nako! 😂',
      'Secret unlocked: Peso loves you! 💚',
      'GRABE! 3x tap! You really like me ha! 😄',
      'Easter egg found! Tell your friends! 🥚',
      '3 taps = 3x the blessings! 🙏',
      'Huy! Galing! Hidden feature found! 🌟',
      'Peso achievement unlocked: Triple Tap Master! 🏆',
      "Okay sige — I'll work harder for you! 💪",
    ];
    final msg = easterEggs[DateTime.now().millisecond % easterEggs.length];
    _showSpeechBubbleOverlay(msg);
  }

  PesoContext _contextFromKey(String? key) {
    switch (key) {
      case 'budget':
        return PesoContext.budgetAllGreen;
      case 'savings_goals':
        return PesoContext.goalMilestone50;
      case 'analytics':
        return PesoContext.fhsImproved;
      case 'transactions':
        return PesoContext.firstLogToday;
      case 'debt':
        return PesoContext.debtPaidOff;
      case 'recurring':
        return PesoContext.generalEncouragement;
      default:
        return PesoContext.generalEncouragement;
    }
  }

  void _showLongPressSheet() {
    final tips =
        PesoContextService.getTipsForScreen(widget.contextKey ?? 'home');
    final voiceLine = PesoVoiceService.get(PesoContext.generalEncouragement);
    final tipText = tips.isNotEmpty ? tips.first : voiceLine;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PesoMascot(size: 64, mood: PesoMood.celebrating),
            const SizedBox(height: 12),
            const Text('Peso says... 💬',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(tipText, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(voiceLine,
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ],
        ),
      ),
    );
  }

  // ── IDLE REACTION (Feature 6) ───────────────────────────────────────────────

  void _scheduleIdleReaction() {
    _idleReactionTimer?.cancel();
    _idleReactionTimer = Timer(const Duration(seconds: 12), () {
      if (!mounted || _idleReactionFired) return;
      _idleReactionFired = true;
      setState(() => _currentMood = PesoMood.sleepy);
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _currentMood = null);
      });
    });
  }

  void resetIdle() {
    _idleReactionTimer?.cancel();
    _idleReactionFired = false;
    if (widget.size >= 48) _scheduleIdleReaction();
  }

  // ── SPEECH BUBBLE OVERLAY (Feature 2) ──────────────────────────────────────

  void _showSpeechBubbleOverlay(String text) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: (position.dx + size.width / 2 - 80).clamp(8.0, double.infinity),
        top: (position.dy - 60).clamp(8.0, double.infinity),
        width: 160,
        child: Material(
          color: Colors.transparent,
          child: _SpeechBubblePopup(
            text: text,
            onDone: () => entry.remove(),
          ),
        ),
      ),
    );
    overlay.insert(entry);
  }

  void _scheduleBlink() {
    Future.delayed(
      Duration(milliseconds: 3000 + (DateTime.now().millisecond % 2000)),
      () {
        if (!mounted) return;
        _blinkCtrl.forward(from: 0).then((_) {
          if (mounted) {
            _blinkCtrl.reverse().then((_) {
              if (mounted) _scheduleBlink();
            });
          }
        });
      },
    );
  }

  @override
  void didUpdateWidget(PesoMascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      if (!MediaQuery.of(context).disableAnimations) {
        _moodCtrl.forward(from: 0);
      }
      // Haptic feedback on mood change (fire-and-forget)
      PesoSoundService.playMoodChange(widget.mood);
    }
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _moodCtrl.dispose();
    _blinkCtrl.dispose();
    _tapCtrl.dispose();
    _tapTimer?.cancel();
    _idleReactionTimer?.cancel();
    _idleSpeechTimer?.cancel();
    _moodRevertTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMood = _currentMood ?? widget.mood;
    final core = AnimatedBuilder(
      animation: Listenable.merge([_idleCtrl, _moodCtrl, _blinkCtrl, _tapCtrl]),
      builder: (context, child) {
        final scale = 1.0 + 0.18 * _tapCtrl.value;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: widget.size * 1.35,
            height: widget.size * 1.25,
            child: CustomPaint(
              painter: _PesoCoinPainter(
                mood: effectiveMood,
                size: widget.size,
                idleT: _idleCtrl.value,
                moodT: _moodCtrl.value,
                blinkT: _blinkCtrl.value,
              ),
            ),
          ),
        );
      },
    );

    return GestureDetector(
      onTap: _handleTap,
      onDoubleTap: _handleDoubleTap,
      onLongPress: _handleLongPress,
      child: core,
    );
  }
}

/// The actual coin character painter — clean, round, expressive
class _PesoCoinPainter extends CustomPainter {
  final PesoMood mood;
  final double size;
  final double idleT;
  final double moodT;
  final double blinkT;

  const _PesoCoinPainter({
    required this.mood,
    required this.size,
    this.idleT = 0.0,
    this.moodT = 0.0,
    this.blinkT = 0.0,
  });

  // ── helpers ────────────────────────────────────────────────────────────────
  Color get _rimColor {
    switch (mood) {
      case PesoMood.sad:
      case PesoMood.embarrassed:
        return const Color(0xFF8AABB8);
      case PesoMood.thinking:
        return const Color(0xFF7C5CFC);
      case PesoMood.celebrating:
      case PesoMood.excited:
        return const Color(0xFFFF8C00);
      case PesoMood.surprised:
        return const Color(0xFFFFD700);
      case PesoMood.sleepy:
        return const Color(0xFF6B8E9F);
      case PesoMood.worried:
        return const Color(0xFF5A9E80);
      case PesoMood.proud:
      case PesoMood.winking:
      case PesoMood.happy:
      case PesoMood.neutral:
        return kPesoGreen;
    }
  }

  Color get _rimDark {
    switch (mood) {
      case PesoMood.sad:
      case PesoMood.embarrassed:
        return const Color(0xFF5E8090);
      case PesoMood.thinking:
        return const Color(0xFF5B3FCC);
      case PesoMood.celebrating:
      case PesoMood.excited:
        return const Color(0xFFC06000);
      case PesoMood.surprised:
        return const Color(0xFFC8A800);
      case PesoMood.sleepy:
        return const Color(0xFF4A6E7F);
      case PesoMood.worried:
        return const Color(0xFF3A7E60);
      case PesoMood.proud:
      case PesoMood.winking:
      case PesoMood.happy:
      case PesoMood.neutral:
        return kPesoGreenDark;
    }
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final w = canvasSize.width;
    final h = canvasSize.height;
    // Body center — slightly above middle to leave room for legs
    final cx = w / 2;
    final cy = h * 0.42;
    final r = size / 2; // coin radius

    // ── IDLE BOB & MOOD POP-IN ────────────────────────────────────────────────
    // Bob offset scales with mascot size so tiny instances (20px) don't clip
    final bobScale = (size / 72.0).clamp(0.15, 1.0);
    final bobOffset = sin(idleT * pi) * 2.0 * bobScale;
    canvas.save();
    canvas.translate(w / 2, h / 2 + bobOffset);
    canvas.scale(1.0 - 0.012 * sin(idleT * pi));
    canvas.translate(-w / 2, -h / 2);

    // ── EXCITED/CELEBRATING BODY SQUISH ──────────────────────────────────────
    // Squish compresses Y and expands X slightly, synced with idle beat
    if (mood == PesoMood.excited || mood == PesoMood.celebrating) {
      final squish = sin(idleT * pi * 2.5) * 0.055 * bobScale;
      canvas.translate(cx, cy + r);
      canvas.scale(1.0 + squish * 0.4, 1.0 - squish);
      canvas.translate(-cx, -(cy + r));
    }

    if (moodT > 0.0 && moodT < 1.0) {
      final elastic = 1.0 - pow(2, -10 * moodT) * cos(moodT * pi * 4.5);
      final sc = (0.7 + 0.35 * elastic.clamp(0.0, 1.1)).toDouble();
      canvas.translate(cx, cy);
      canvas.scale(sc);
      canvas.translate(-cx, -cy);
    }

    final rim = Paint()..color = _rimColor;
    final rimDark = Paint()..color = _rimDark;
    final face = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 0.8,
        colors: [Colors.white, _rimColor.withValues(alpha: 0.12)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    final pupilPaint = Paint()
      ..color = mood == PesoMood.sad
          ? const Color(0xFF223344)
          : const Color(0xFF0D2B22);
    final whitePaint = Paint()..color = Colors.white;
    final strokePaint = Paint()
      ..color = _rimDark
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // ── DROP SHADOW ──────────────────────────────────────────────────────────
    final shadow = Paint()
      ..color = _rimColor.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(cx, cy + r * 0.08), r * 0.85, shadow);

    // ── COIN BODY ────────────────────────────────────────────────────────────
    // Outer rim (slightly larger, darker)
    canvas.drawCircle(Offset(cx, cy), r, rim);
    // Inner highlight ring
    canvas.drawCircle(Offset(cx, cy), r * 0.88, face);
    // Subtle inner edge
    final edgePaint = Paint()
      ..color = _rimColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04;
    canvas.drawCircle(Offset(cx, cy), r * 0.88, edgePaint);

    // ── ₱ FOREHEAD ──────────────────────────────────────────────────────────
    final pesoStyle = TextStyle(
      fontSize: r * 0.28,
      fontWeight: FontWeight.bold,
      color: _rimColor,
      height: 1,
    );
    final pesoPainter = TextPainter(
      text: TextSpan(text: '₱', style: pesoStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    pesoPainter.paint(
      canvas,
      Offset(cx - pesoPainter.width / 2, cy - r * 0.72),
    );

    // ── EYES ─────────────────────────────────────────────────────────────────
    final eyeOffX = r * 0.38;
    final eyeY = cy - r * 0.10;
    final eyeR = r * 0.22;

    // Eye whites (blink compresses vertically)
    final eyeScaleY = 1.0 - 0.88 * blinkT;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - eyeOffX, eyeY),
          width: eyeR * 2,
          height: eyeR * 2 * eyeScaleY),
      whitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + eyeOffX, eyeY),
          width: eyeR * 2,
          height: eyeR * 2 * eyeScaleY),
      whitePaint,
    );

    // Eye outline (very subtle)
    final eyeOutline = Paint()
      ..color = _rimColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - eyeOffX, eyeY),
          width: eyeR * 2,
          height: eyeR * 2 * eyeScaleY),
      eyeOutline,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + eyeOffX, eyeY),
          width: eyeR * 2,
          height: eyeR * 2 * eyeScaleY),
      eyeOutline,
    );

    // Mood-specific eye shape
    _drawEyes(
        canvas, cx, eyeY, eyeOffX, eyeR, r, pupilPaint, whitePaint, _rimDark);

    // ── EYEBROWS ─────────────────────────────────────────────────────────────
    _drawEyebrows(canvas, cx, eyeY, eyeOffX, eyeR, r, strokePaint);

    // ── BLUSH ────────────────────────────────────────────────────────────────
    if (mood == PesoMood.happy ||
        mood == PesoMood.celebrating ||
        mood == PesoMood.excited ||
        mood == PesoMood.winking ||
        mood == PesoMood.embarrassed) {
      final blushAlpha = mood == PesoMood.embarrassed ? 0.40 : 0.18;
      final blush = Paint()
        ..color = _rimColor.withValues(alpha: blushAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx - eyeOffX - r * 0.1, eyeY + r * 0.22),
              width: r * 0.38,
              height: r * 0.2),
          blush);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + eyeOffX + r * 0.1, eyeY + r * 0.22),
              width: r * 0.38,
              height: r * 0.2),
          blush);
    }

    // ── MOUTH ────────────────────────────────────────────────────────────────
    _drawMouth(canvas, cx, cy, r, strokePaint, whitePaint);

    // ── ARMS ─────────────────────────────────────────────────────────────────
    _drawArms(canvas, cx, cy, r, rim, rimDark);

    // ── LEGS & FEET ──────────────────────────────────────────────────────────
    _drawLegs(canvas, cx, cy, r, rim, rimDark);

    // ── CELEBRATING EXTRAS ───────────────────────────────────────────────────
    if (mood == PesoMood.celebrating) {
      _drawConfetti(canvas, cx, cy, r);
    }

    // ── THINKING BUBBLE ──────────────────────────────────────────────────────
    if (mood == PesoMood.thinking) {
      _drawThoughtBubble(canvas, cx, cy, r);
    }

    if (mood == PesoMood.excited) {
      _drawStars(
          canvas,
          cx,
          cy,
          r,
          Paint()
            ..color = const Color(0xFFFFD700)
            ..style = PaintingStyle.fill);
    }
    if (mood == PesoMood.sleepy) {
      _drawZzz(canvas, cx, cy, r);
    }
    if (mood == PesoMood.proud) {
      canvas.drawCircle(
        Offset(cx, cy),
        r * 1.06,
        Paint()
          ..color = _rimColor.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.08
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    canvas.restore();
  }

  void _drawEyes(Canvas canvas, double cx, double eyeY, double eyeOffX,
      double eyeR, double r, Paint pupil, Paint white, Color brow) {
    final double pupilR = eyeR * 0.62;

    switch (mood) {
      case PesoMood.sad:
        canvas.drawCircle(
            Offset(cx - eyeOffX, eyeY + eyeR * 0.2), pupilR, pupil);
        canvas.drawCircle(
            Offset(cx + eyeOffX, eyeY + eyeR * 0.2), pupilR, pupil);
        final lid = Paint()..color = Colors.white;
        canvas.drawRect(
            Rect.fromLTWH(
                cx - eyeOffX - eyeR, eyeY - eyeR, eyeR * 2, eyeR * 0.55),
            lid);
        canvas.drawRect(
            Rect.fromLTWH(
                cx + eyeOffX - eyeR, eyeY - eyeR, eyeR * 2, eyeR * 0.55),
            lid);
        break;
      case PesoMood.thinking:
        // Look-around animation: pupils drift left/right with idle cycle
        canvas.drawCircle(Offset(cx - eyeOffX, eyeY), pupilR, pupil);
        canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR, pupil);
        final p2 = Paint()..color = const Color(0xFF1a2060);
        // idleT 0→0.5 = pupils drift left, 0.5→1.0 = drift right
        final lookDrift = (idleT < 0.5
                ? -eyeR * 0.22 * (idleT * 2)
                : -eyeR * 0.22 + eyeR * 0.44 * ((idleT - 0.5) * 2))
            .toDouble();
        canvas.drawCircle(Offset(cx - eyeOffX + lookDrift, eyeY), pupilR, p2);
        canvas.drawCircle(Offset(cx + eyeOffX + lookDrift, eyeY), pupilR, p2);
        break;
      case PesoMood.excited:
        final excitedWhite = Paint()..color = Colors.white;
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx - eyeOffX, eyeY),
              width: eyeR * 2.2,
              height: eyeR * 2.2),
          excitedWhite,
        );
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + eyeOffX, eyeY),
              width: eyeR * 2.2,
              height: eyeR * 2.2),
          excitedWhite,
        );
        canvas.drawCircle(Offset(cx - eyeOffX, eyeY), pupilR, pupil);
        canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR, pupil);
        break;
      case PesoMood.surprised:
        final surprisedWhite = Paint()..color = Colors.white;
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx - eyeOffX, eyeY),
              width: eyeR * 2.6,
              height: eyeR * 2.6),
          surprisedWhite,
        );
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + eyeOffX, eyeY),
              width: eyeR * 2.6,
              height: eyeR * 2.6),
          surprisedWhite,
        );
        canvas.drawCircle(Offset(cx - eyeOffX, eyeY), pupilR * 0.65, pupil);
        canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR * 0.65, pupil);
        break;
      case PesoMood.proud:
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx - eyeOffX, eyeY),
              width: eyeR * 1.76,
              height: eyeR * 1.76),
          white,
        );
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + eyeOffX, eyeY),
              width: eyeR * 1.76,
              height: eyeR * 1.76),
          white,
        );
        canvas.drawCircle(Offset(cx - eyeOffX, eyeY), pupilR, pupil);
        canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR, pupil);
        break;
      case PesoMood.embarrassed:
        canvas.drawCircle(
            Offset(cx - eyeOffX, eyeY + eyeR * 0.3), pupilR, pupil);
        canvas.drawCircle(
            Offset(cx + eyeOffX, eyeY + eyeR * 0.3), pupilR, pupil);
        break;
      case PesoMood.winking:
        // Left eye closed (arc), right eye normal
        final closedPath = Path()
          ..moveTo(cx - eyeOffX - eyeR, eyeY)
          ..quadraticBezierTo(
              cx - eyeOffX, eyeY - eyeR * 0.6, cx - eyeOffX + eyeR, eyeY);
        canvas.drawPath(
          closedPath,
          Paint()
            ..color = const Color(0xFF0D2B22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.055
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR, pupil);
        break;
      case PesoMood.sleepy:
        // Eyes as narrow ovals
        final sleepyWhite = Paint()..color = Colors.white;
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx - eyeOffX, eyeY),
              width: eyeR * 2,
              height: eyeR * 0.7),
          sleepyWhite,
        );
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + eyeOffX, eyeY),
              width: eyeR * 2,
              height: eyeR * 0.7),
          sleepyWhite,
        );
        // No pupils for sleepy — eyes are closed slits
        break;
      case PesoMood.worried:
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx - eyeOffX, eyeY),
              width: eyeR * 2,
              height: eyeR * 1.76),
          white,
        );
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + eyeOffX, eyeY),
              width: eyeR * 2,
              height: eyeR * 1.76),
          white,
        );
        canvas.drawCircle(Offset(cx - eyeOffX, eyeY), pupilR, pupil);
        canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR, pupil);
        break;
      default:
        canvas.drawCircle(Offset(cx - eyeOffX, eyeY), pupilR, pupil);
        canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR, pupil);
    }

    // Eye shines (always, except sleepy and winking-left)
    if (mood != PesoMood.sleepy) {
      final shineL = mood == PesoMood.winking;
      if (!shineL) {
        canvas.drawCircle(
          Offset(cx - eyeOffX + pupilR * 0.45, eyeY - pupilR * 0.45),
          pupilR * 0.38,
          white,
        );
      }
      canvas.drawCircle(
        Offset(cx + eyeOffX + pupilR * 0.45, eyeY - pupilR * 0.45),
        pupilR * 0.38,
        white,
      );
      final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
      if (!shineL) {
        canvas.drawCircle(
          Offset(cx - eyeOffX - pupilR * 0.25, eyeY + pupilR * 0.35),
          pupilR * 0.18,
          shinePaint,
        );
      }
      canvas.drawCircle(
        Offset(cx + eyeOffX - pupilR * 0.25, eyeY + pupilR * 0.35),
        pupilR * 0.18,
        shinePaint,
      );
    }
  }

  void _drawEyebrows(Canvas canvas, double cx, double eyeY, double eyeOffX,
      double eyeR, double r, Paint stroke) {
    stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round;

    final browY = eyeY - eyeR * 1.18;
    final browW = eyeR * 1.3;

    switch (mood) {
      case PesoMood.sad:
        canvas.drawLine(Offset(cx - eyeOffX - browW / 2, browY + r * 0.04),
            Offset(cx - eyeOffX + browW / 2, browY - r * 0.04), stroke);
        canvas.drawLine(Offset(cx + eyeOffX - browW / 2, browY - r * 0.04),
            Offset(cx + eyeOffX + browW / 2, browY + r * 0.04), stroke);
        break;
      case PesoMood.thinking:
        canvas.drawLine(Offset(cx - eyeOffX - browW / 2, browY),
            Offset(cx - eyeOffX + browW / 2, browY), stroke);
        canvas.drawLine(Offset(cx + eyeOffX - browW / 2, browY - r * 0.07),
            Offset(cx + eyeOffX + browW / 2, browY + r * 0.02), stroke);
        break;
      case PesoMood.excited:
        // Both arched very high
        final ex1 = Path()
          ..moveTo(cx - eyeOffX - browW / 2, browY)
          ..quadraticBezierTo(
              cx - eyeOffX, browY - r * 0.08, cx - eyeOffX + browW / 2, browY);
        final ex2 = Path()
          ..moveTo(cx + eyeOffX - browW / 2, browY)
          ..quadraticBezierTo(
              cx + eyeOffX, browY - r * 0.08, cx + eyeOffX + browW / 2, browY);
        canvas.drawPath(ex1, stroke);
        canvas.drawPath(ex2, stroke);
        break;
      case PesoMood.surprised:
        // Both raised very high, sharply arched
        final sp1 = Path()
          ..moveTo(cx - eyeOffX - browW / 2, browY - r * 0.06)
          ..quadraticBezierTo(cx - eyeOffX, browY - r * 0.12,
              cx - eyeOffX + browW / 2, browY - r * 0.06);
        final sp2 = Path()
          ..moveTo(cx + eyeOffX - browW / 2, browY - r * 0.06)
          ..quadraticBezierTo(cx + eyeOffX, browY - r * 0.12,
              cx + eyeOffX + browW / 2, browY - r * 0.06);
        canvas.drawPath(sp1, stroke);
        canvas.drawPath(sp2, stroke);
        break;
      case PesoMood.proud:
        // Flat/straight, slightly lower than happy
        canvas.drawLine(Offset(cx - eyeOffX - browW / 2, browY + r * 0.04),
            Offset(cx - eyeOffX + browW / 2, browY + r * 0.04), stroke);
        canvas.drawLine(Offset(cx + eyeOffX - browW / 2, browY + r * 0.04),
            Offset(cx + eyeOffX + browW / 2, browY + r * 0.04), stroke);
        break;
      case PesoMood.embarrassed:
        // Inner corners raised (ashamed look)
        canvas.drawLine(Offset(cx - eyeOffX - browW / 2, browY - r * 0.04),
            Offset(cx - eyeOffX + browW / 2, browY + r * 0.04), stroke);
        canvas.drawLine(Offset(cx + eyeOffX - browW / 2, browY + r * 0.04),
            Offset(cx + eyeOffX + browW / 2, browY - r * 0.04), stroke);
        break;
      case PesoMood.winking:
        // Left raised higher
        final wk1 = Path()
          ..moveTo(cx - eyeOffX - browW / 2, browY)
          ..quadraticBezierTo(
              cx - eyeOffX, browY - r * 0.06, cx - eyeOffX + browW / 2, browY);
        final wk2 = Path()
          ..moveTo(cx + eyeOffX - browW / 2, browY + r * 0.03)
          ..quadraticBezierTo(cx + eyeOffX, browY - r * 0.04,
              cx + eyeOffX + browW / 2, browY + r * 0.03);
        canvas.drawPath(wk1, stroke);
        canvas.drawPath(wk2, stroke);
        break;
      case PesoMood.sleepy:
        // Slightly furrowed, angled inward-down
        canvas.drawLine(Offset(cx - eyeOffX - browW / 2, browY - r * 0.02),
            Offset(cx - eyeOffX + browW / 2, browY + r * 0.03), stroke);
        canvas.drawLine(Offset(cx + eyeOffX - browW / 2, browY + r * 0.03),
            Offset(cx + eyeOffX + browW / 2, browY - r * 0.02), stroke);
        break;
      case PesoMood.worried:
        // Both angled strongly toward center-down
        canvas.drawLine(Offset(cx - eyeOffX - browW / 2, browY - r * 0.04),
            Offset(cx - eyeOffX + browW / 2, browY + r * 0.08), stroke);
        canvas.drawLine(Offset(cx + eyeOffX - browW / 2, browY + r * 0.08),
            Offset(cx + eyeOffX + browW / 2, browY - r * 0.04), stroke);
        break;
      default:
        // Friendly slight arch (happy, neutral)
        final path1 = Path()
          ..moveTo(cx - eyeOffX - browW / 2, browY + r * 0.03)
          ..quadraticBezierTo(cx - eyeOffX, browY - r * 0.04,
              cx - eyeOffX + browW / 2, browY + r * 0.03);
        final path2 = Path()
          ..moveTo(cx + eyeOffX - browW / 2, browY + r * 0.03)
          ..quadraticBezierTo(cx + eyeOffX, browY - r * 0.04,
              cx + eyeOffX + browW / 2, browY + r * 0.03);
        canvas.drawPath(path1, stroke);
        canvas.drawPath(path2, stroke);
    }
  }

  void _drawMouth(Canvas canvas, double cx, double cy, double r, Paint stroke,
      Paint white) {
    stroke.strokeWidth = r * 0.07;
    final mouthY = cy + r * 0.32;
    final mouthW = r * 0.65;

    switch (mood) {
      case PesoMood.sad:
        final path = Path()
          ..moveTo(cx - mouthW, mouthY)
          ..quadraticBezierTo(cx, mouthY - r * 0.22, cx + mouthW, mouthY);
        canvas.drawPath(path, stroke);
        break;
      case PesoMood.thinking:
        canvas.drawLine(Offset(cx - mouthW * 0.6, mouthY - r * 0.02),
            Offset(cx + mouthW * 0.6, mouthY + r * 0.02), stroke);
        break;
      case PesoMood.celebrating:
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, mouthY + r * 0.04),
                width: mouthW * 1.4,
                height: r * 0.4),
            stroke);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, mouthY + r * 0.04),
                width: mouthW * 1.35,
                height: r * 0.36),
            white);
        break;
      case PesoMood.excited:
        // Wider smile with teeth
        final excSmilePath = Path()
          ..moveTo(cx - mouthW * 1.2, mouthY)
          ..quadraticBezierTo(cx, mouthY + r * 0.28, cx + mouthW * 1.2, mouthY);
        final excFillPath = Path()
          ..moveTo(cx - mouthW * 1.2, mouthY)
          ..quadraticBezierTo(cx, mouthY + r * 0.28, cx + mouthW * 1.2, mouthY)
          ..lineTo(cx + mouthW * 1.0, mouthY + r * 0.18)
          ..quadraticBezierTo(
              cx, mouthY + r * 0.28, cx - mouthW * 1.0, mouthY + r * 0.18)
          ..close();
        canvas.drawPath(
            excFillPath, Paint()..color = Colors.white.withValues(alpha: 0.85));
        canvas.drawPath(excSmilePath, stroke);
        break;
      case PesoMood.surprised:
        // Small O
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, mouthY + r * 0.05),
            width: r * 0.36,
            height: r * 0.36,
          ),
          Paint()
            ..color = _rimDark
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.06,
        );
        break;
      case PesoMood.proud:
        // Closed smile, no teeth
        final proudPath = Path()
          ..moveTo(cx - mouthW * 0.7, mouthY)
          ..quadraticBezierTo(cx, mouthY + r * 0.15, cx + mouthW * 0.7, mouthY);
        canvas.drawPath(proudPath, stroke);
        break;
      case PesoMood.embarrassed:
        // Small flat grimace
        canvas.drawLine(
          Offset(cx - mouthW * 0.55, mouthY),
          Offset(cx + mouthW * 0.55, mouthY),
          stroke,
        );
        break;
      case PesoMood.winking:
        // Asymmetric smirk
        final smirkPath = Path()
          ..moveTo(cx - mouthW * 0.7, mouthY)
          ..quadraticBezierTo(
              cx, mouthY + r * 0.2, cx + mouthW, mouthY - r * 0.06);
        canvas.drawPath(smirkPath, stroke);
        break;
      case PesoMood.sleepy:
        // Very small neutral line
        canvas.drawLine(
          Offset(cx - mouthW * 0.35, mouthY),
          Offset(cx + mouthW * 0.35, mouthY),
          stroke,
        );
        break;
      case PesoMood.worried:
        // Small downward curve
        final worriedPath = Path()
          ..moveTo(cx - mouthW * 0.6, mouthY)
          ..quadraticBezierTo(cx, mouthY - r * 0.12, cx + mouthW * 0.6, mouthY);
        canvas.drawPath(worriedPath, stroke);
        break;
      default:
        // Smile with slight tooth fill (happy, neutral)
        final smilePath = Path()
          ..moveTo(cx - mouthW, mouthY)
          ..quadraticBezierTo(cx, mouthY + r * 0.28, cx + mouthW, mouthY);
        final fillPath = Path()
          ..moveTo(cx - mouthW, mouthY)
          ..quadraticBezierTo(cx, mouthY + r * 0.28, cx + mouthW, mouthY)
          ..lineTo(cx + mouthW * 0.85, mouthY + r * 0.18)
          ..quadraticBezierTo(
              cx, mouthY + r * 0.28, cx - mouthW * 0.85, mouthY + r * 0.18)
          ..close();
        canvas.drawPath(
            fillPath, Paint()..color = Colors.white.withValues(alpha: 0.85));
        canvas.drawPath(smilePath, stroke);
    }
  }

  void _drawArms(
      Canvas canvas, double cx, double cy, double r, Paint rim, Paint rimDark) {
    final armPaint = Paint()
      ..color = _rimColor
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final handPaint = Paint()..color = _rimColor;

    switch (mood) {
      case PesoMood.celebrating:
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.2, cy - r * 0.55), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.2, cy - r * 0.55), armPaint);
        for (final dx in [-1, 0, 1]) {
          canvas.drawCircle(Offset(cx - r * 1.2 + dx * r * 0.09, cy - r * 0.62),
              r * 0.13, handPaint);
          canvas.drawCircle(Offset(cx + r * 1.2 + dx * r * 0.09, cy - r * 0.62),
              r * 0.13, handPaint);
        }
        break;
      case PesoMood.sad:
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.1, cy + r * 0.55), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.1, cy + r * 0.55), armPaint);
        break;
      case PesoMood.thinking:
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.05, cy + r * 0.3), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.1, cy - r * 0.15), armPaint);
        canvas.drawCircle(
            Offset(cx + r * 1.1, cy - r * 0.25), r * 0.15, handPaint);
        break;
      case PesoMood.excited:
        // Both arms straight up, higher than celebrating
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.15, cy - r * 0.75), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.15, cy - r * 0.75), armPaint);
        for (final dx in [-1, 0, 1]) {
          canvas.drawCircle(
              Offset(cx - r * 1.15 + dx * r * 0.08, cy - r * 0.82),
              r * 0.12,
              handPaint);
          canvas.drawCircle(
              Offset(cx + r * 1.15 + dx * r * 0.08, cy - r * 0.82),
              r * 0.12,
              handPaint);
        }
        break;
      case PesoMood.surprised:
        // Spread wide horizontally
        canvas.drawLine(Offset(cx - r * 0.9, cy + r * 0.1),
            Offset(cx - r * 1.5, cy + r * 0.1), armPaint);
        canvas.drawLine(Offset(cx + r * 0.9, cy + r * 0.1),
            Offset(cx + r * 1.5, cy + r * 0.1), armPaint);
        break;
      case PesoMood.proud:
        // Left arm slightly raised (casual)
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.18, cy - r * 0.18), armPaint);
        // Right arm on hip (L shape)
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.1, cy + r * 0.4), armPaint);
        canvas.drawLine(Offset(cx + r * 1.1, cy + r * 0.4),
            Offset(cx + r * 0.75, cy + r * 0.55), armPaint);
        break;
      case PesoMood.embarrassed:
        // Left arm raised covering lower face
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 0.5, cy - r * 0.2), armPaint);
        canvas.drawCircle(
            Offset(cx - r * 0.44, cy - r * 0.26), r * 0.15, handPaint);
        // Right arm hanging low
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.1, cy + r * 0.55), armPaint);
        break;
      case PesoMood.winking:
        // Right arm pointing outward
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.18, cy - r * 0.28), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.28, cy - r * 0.3), armPaint);
        canvas.drawCircle(
            Offset(cx + r * 1.28, cy - r * 0.3), r * 0.12, handPaint);
        break;
      case PesoMood.sleepy:
        // Both drooping down
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.05, cy + r * 0.5), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.05, cy + r * 0.5), armPaint);
        break;
      case PesoMood.worried:
        // Left hand near chin
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 0.55, cy - r * 0.1), armPaint);
        canvas.drawCircle(
            Offset(cx - r * 0.49, cy - r * 0.16), r * 0.13, handPaint);
        // Right arm slightly raised
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.18, cy - r * 0.1), armPaint);
        break;
      default:
        // Arms slightly raised — right arm waves with idle cycle (happy, neutral)
        final armWave = sin(idleT * pi * 2) * 0.10; // gentle wave oscillation
        // (idleT drives the 2.4s bob cycle, armWave adds a secondary faster wave)
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.18, cy - r * 0.28), armPaint);
        // Right arm tip oscillates up/down
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.18, cy - r * (0.28 + armWave)), armPaint);
        for (final dx in [-1, 0, 1]) {
          canvas.drawCircle(
              Offset(cx - r * 1.18 + dx * r * 0.08, cy - r * 0.35),
              r * 0.12,
              handPaint);
          canvas.drawCircle(
              Offset(cx + r * 1.18 + dx * r * 0.08, cy - r * (0.35 + armWave)),
              r * 0.12,
              handPaint);
        }
    }
  }

  void _drawLegs(
      Canvas canvas, double cx, double cy, double r, Paint rim, Paint rimDark) {
    final legPaint = Paint()
      ..color = _rimColor
      ..strokeWidth = r * 0.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final footPaint = Paint()..color = _rimColor;

    if (mood == PesoMood.celebrating ||
        mood == PesoMood.excited ||
        mood == PesoMood.surprised) {
      // Legs out to sides (jumping/excited)
      canvas.drawLine(Offset(cx - r * 0.3, cy + r * 0.88),
          Offset(cx - r * 0.65, cy + r * 1.22), legPaint);
      canvas.drawLine(Offset(cx + r * 0.3, cy + r * 0.88),
          Offset(cx + r * 0.65, cy + r * 1.22), legPaint);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx - r * 0.72, cy + r * 1.28),
              width: r * 0.45,
              height: r * 0.22),
          footPaint);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + r * 0.72, cy + r * 1.28),
              width: r * 0.45,
              height: r * 0.22),
          footPaint);
    } else {
      // Normal legs going down
      canvas.drawLine(Offset(cx - r * 0.28, cy + r * 0.88),
          Offset(cx - r * 0.38, cy + r * 1.2), legPaint);
      canvas.drawLine(Offset(cx + r * 0.28, cy + r * 0.88),
          Offset(cx + r * 0.38, cy + r * 1.2), legPaint);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx - r * 0.42, cy + r * 1.26),
              width: r * 0.4,
              height: r * 0.2),
          footPaint);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + r * 0.42, cy + r * 1.26),
              width: r * 0.4,
              height: r * 0.2),
          footPaint);
    }
  }

  void _drawConfetti(Canvas canvas, double cx, double cy, double r) {
    final colors = [
      kPesoGreen,
      const Color(0xFF7C5CFC),
      const Color(0xFFFFD700),
      const Color(0xFFFF6B6B),
      const Color(0xFF4FC3F7)
    ];
    final rects = [
      Rect.fromCenter(
          center: Offset(cx - r * 1.0, cy - r * 0.6), width: 8, height: 5),
      Rect.fromCenter(
          center: Offset(cx + r * 1.0, cy - r * 0.7), width: 6, height: 4),
      Rect.fromCenter(
          center: Offset(cx - r * 0.6, cy - r * 1.0), width: 7, height: 4),
      Rect.fromCenter(
          center: Offset(cx + r * 0.7, cy - r * 0.95), width: 5, height: 6),
      Rect.fromCenter(
          center: Offset(cx - r * 0.3, cy - r * 1.1), width: 6, height: 4),
      Rect.fromCenter(
          center: Offset(cx + r * 0.4, cy - r * 1.05), width: 8, height: 4),
    ];
    final angles = [-30.0, 25.0, -15.0, 40.0, 10.0, -35.0];
    for (int i = 0; i < rects.length; i++) {
      final p = Paint()..color = colors[i % colors.length];
      canvas.save();
      canvas.translate(rects[i].center.dx, rects[i].center.dy);
      canvas.rotate(angles[i] * 3.14159 / 180);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero,
                  width: rects[i].width,
                  height: rects[i].height),
              const Radius.circular(2)),
          p);
      canvas.restore();
    }
  }

  void _drawThoughtBubble(Canvas canvas, double cx, double cy, double r) {
    final bubblePaint = Paint()
      ..color = const Color(0xFF7C5CFC).withValues(alpha: 0.55);
    // Trailing dots
    canvas.drawCircle(
        Offset(cx + r * 0.82, cy - r * 0.62), r * 0.08, bubblePaint);
    canvas.drawCircle(
        Offset(cx + r * 0.95, cy - r * 0.80), r * 0.11, bubblePaint);
    canvas.drawCircle(
        Offset(cx + r * 1.1, cy - r * 1.0), r * 0.16, bubblePaint);
    // Main bubble
    final bubbleBg = Paint()
      ..color = const Color(0xFF7C5CFC).withValues(alpha: 0.65);
    canvas.drawCircle(Offset(cx + r * 1.28, cy - r * 1.15), r * 0.28, bubbleBg);
    final questionStyle = TextStyle(
      fontSize: r * 0.28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    final qPainter = TextPainter(
      text: TextSpan(text: '?', style: questionStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    qPainter.paint(
      canvas,
      Offset(cx + r * 1.28 - qPainter.width / 2,
          cy - r * 1.15 - qPainter.height / 2),
    );
  }

  void _drawStars(Canvas canvas, double cx, double cy, double r, Paint p) {
    const positions = [
      (-1.2, -0.9),
      (1.2, -0.9),
      (-1.1, -0.5),
      (1.1, -0.5),
    ];
    for (final pos in positions) {
      final starX = cx + r * pos.$1;
      final starY = cy + r * pos.$2;
      final starR = r * 0.14;
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final a1 = (i * 4 * pi / 5) - pi / 2;
        final a2 = a1 + 2 * pi / 5;
        final ox = starX + starR * cos(a1);
        final oy = starY + starR * sin(a1);
        final ix = starX + starR * 0.4 * cos(a2);
        final iy = starY + starR * 0.4 * sin(a2);
        if (i == 0) {
          path.moveTo(ox, oy);
        } else {
          path.lineTo(ox, oy);
        }
        path.lineTo(ix, iy);
      }
      path.close();
      canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFFD700)
            ..style = PaintingStyle.fill);
    }
  }

  void _drawZzz(Canvas canvas, double cx, double cy, double r) {
    final positions = [
      (cx + r * 0.85, cy - r * 0.75, r * 0.18, 0.65),
      (cx + r * 1.0, cy - r * 0.95, r * 0.22, 0.45),
      (cx + r * 1.15, cy - r * 1.15, r * 0.26, 0.28),
    ];
    for (final pos in positions) {
      final tp = TextPainter(
        text: TextSpan(
          text: 'Z',
          style: TextStyle(
            fontSize: pos.$3,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B8E9F).withValues(alpha: pos.$4),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.$1 - tp.width / 2, pos.$2 - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_PesoCoinPainter old) =>
      old.mood != mood ||
      old.size != size ||
      old.idleT != idleT ||
      old.moodT != moodT ||
      old.blinkT != blinkT;
}

/// Speech bubble variant — bubble above, Peso below
class _PesoWithSpeech extends StatelessWidget {
  final double size;
  final PesoMood mood;
  final String text;
  final Color? bubbleColor;
  final TextStyle? textStyle;

  const _PesoWithSpeech({
    required this.size,
    required this.mood,
    required this.text,
    this.bubbleColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bColor = bubbleColor ?? kPesoGreenLight;
    final tColor = textStyle?.color ?? const Color(0xFF004D39);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bubble
        Container(
          constraints: BoxConstraints(maxWidth: size * 3.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: kPesoGreen.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            text,
            style: textStyle ??
                TextStyle(
                  fontSize: 13,
                  color: tColor,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 2),
        // Peso
        PesoMascot(size: size, mood: mood),
      ],
    );
  }
}

/// Extension on Color for opacity — already provided by Flutter's withValues,
/// this is kept for semantic clarity in the painter code.
// (no additional extension needed)

// ── SPEECH BUBBLE POPUP OVERLAY ───────────────────────────────────────────────

class _SpeechBubblePopup extends StatefulWidget {
  final String text;
  final VoidCallback onDone;
  const _SpeechBubblePopup({required this.text, required this.onDone});
  @override
  State<_SpeechBubblePopup> createState() => _SpeechBubblePopupState();
}

class _SpeechBubblePopupState extends State<_SpeechBubblePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDone());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: GestureDetector(
        onTap: () {
          _ctrl.reverse().then((_) => widget.onDone());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: kPesoGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kPesoGreen.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
