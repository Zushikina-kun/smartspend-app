import 'package:flutter/material.dart';

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
enum PesoMood { happy, neutral, thinking, sad, celebrating }

/// SmartSpend brand green — Peso's signature color
const kPesoGreen = Color(0xFF00C896);
const kPesoGreenDark = Color(0xFF008F6A);
const kPesoGreenLight = Color(0xFFB3F5E6);

class PesoMascot extends StatelessWidget {
  final double size;
  final PesoMood mood;

  const PesoMascot({
    super.key,
    this.size = 72,
    this.mood = PesoMood.happy,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.35, // extra width for arms
      height: size * 1.25, // extra height for legs
      child: CustomPaint(
        painter: _PesoCoinPainter(mood: mood, size: size),
      ),
    );
  }
}

/// The actual coin character painter — clean, round, expressive
class _PesoCoinPainter extends CustomPainter {
  final PesoMood mood;
  final double size;

  const _PesoCoinPainter({required this.mood, required this.size});

  // ── helpers ────────────────────────────────────────────────────────────────
  Color get _rimColor => mood == PesoMood.sad
      ? const Color(0xFF8AABB8)
      : mood == PesoMood.thinking
          ? const Color(0xFF7C5CFC)
          : mood == PesoMood.celebrating
              ? const Color(0xFFFF8C00)
              : kPesoGreen;

  Color get _rimDark => mood == PesoMood.sad
      ? const Color(0xFF5E8090)
      : mood == PesoMood.thinking
          ? const Color(0xFF5B3FCC)
          : mood == PesoMood.celebrating
              ? const Color(0xFFC06000)
              : kPesoGreenDark;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final w = canvasSize.width;
    final h = canvasSize.height;
    // Body center — slightly above middle to leave room for legs
    final cx = w / 2;
    final cy = h * 0.42;
    final r = size / 2; // coin radius

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

    // Eye whites
    canvas.drawCircle(Offset(cx - eyeOffX, eyeY), eyeR, whitePaint);
    canvas.drawCircle(Offset(cx + eyeOffX, eyeY), eyeR, whitePaint);

    // Eye outline (very subtle)
    final eyeOutline = Paint()
      ..color = _rimColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx - eyeOffX, eyeY), eyeR, eyeOutline);
    canvas.drawCircle(Offset(cx + eyeOffX, eyeY), eyeR, eyeOutline);

    // Mood-specific eye shape
    _drawEyes(
        canvas, cx, eyeY, eyeOffX, eyeR, r, pupilPaint, whitePaint, _rimDark);

    // ── EYEBROWS ─────────────────────────────────────────────────────────────
    _drawEyebrows(canvas, cx, eyeY, eyeOffX, eyeR, r, strokePaint);

    // ── BLUSH ────────────────────────────────────────────────────────────────
    if (mood == PesoMood.happy || mood == PesoMood.celebrating) {
      final blush = Paint()
        ..color = _rimColor.withValues(alpha: 0.18)
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
  }

  void _drawEyes(Canvas canvas, double cx, double eyeY, double eyeOffX,
      double eyeR, double r, Paint pupil, Paint white, Color brow) {
    // Pupils
    final double pupilR = eyeR * 0.62;

    if (mood == PesoMood.sad) {
      // Pupils shifted down (droopy)
      canvas.drawCircle(Offset(cx - eyeOffX, eyeY + eyeR * 0.2), pupilR, pupil);
      canvas.drawCircle(Offset(cx + eyeOffX, eyeY + eyeR * 0.2), pupilR, pupil);
      // Half-lid cover
      final lid = Paint()..color = Colors.white;
      canvas.drawRect(
          Rect.fromLTWH(
              cx - eyeOffX - eyeR, eyeY - eyeR, eyeR * 2, eyeR * 0.55),
          lid);
      canvas.drawRect(
          Rect.fromLTWH(
              cx + eyeOffX - eyeR, eyeY - eyeR, eyeR * 2, eyeR * 0.55),
          lid);
    } else if (mood == PesoMood.thinking) {
      canvas.drawCircle(Offset(cx - eyeOffX, eyeY), pupilR, pupil);
      canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR, pupil);
      // Pupils shifted slightly right (looking away)
      final p2 = Paint()..color = const Color(0xFF1a2060);
      canvas.drawCircle(Offset(cx - eyeOffX + eyeR * 0.18, eyeY), pupilR, p2);
      canvas.drawCircle(Offset(cx + eyeOffX + eyeR * 0.18, eyeY), pupilR, p2);
    } else {
      canvas.drawCircle(Offset(cx - eyeOffX, eyeY), pupilR, pupil);
      canvas.drawCircle(Offset(cx + eyeOffX, eyeY), pupilR, pupil);
    }

    // Eye shines (always)
    canvas.drawCircle(
        Offset(cx - eyeOffX + pupilR * 0.45, eyeY - pupilR * 0.45),
        pupilR * 0.38,
        white);
    canvas.drawCircle(
        Offset(cx + eyeOffX + pupilR * 0.45, eyeY - pupilR * 0.45),
        pupilR * 0.38,
        white);
    // Small secondary shine (slightly transparent)
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(
        Offset(cx - eyeOffX - pupilR * 0.25, eyeY + pupilR * 0.35),
        pupilR * 0.18,
        shinePaint);
    canvas.drawCircle(
        Offset(cx + eyeOffX - pupilR * 0.25, eyeY + pupilR * 0.35),
        pupilR * 0.18,
        shinePaint);
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
        // Angled — inner corners raised (worried)
        canvas.drawLine(Offset(cx - eyeOffX - browW / 2, browY + r * 0.04),
            Offset(cx - eyeOffX + browW / 2, browY - r * 0.04), stroke);
        canvas.drawLine(Offset(cx + eyeOffX - browW / 2, browY - r * 0.04),
            Offset(cx + eyeOffX + browW / 2, browY + r * 0.04), stroke);
        break;
      case PesoMood.thinking:
        // One raised
        canvas.drawLine(Offset(cx - eyeOffX - browW / 2, browY),
            Offset(cx - eyeOffX + browW / 2, browY), stroke);
        canvas.drawLine(Offset(cx + eyeOffX - browW / 2, browY - r * 0.07),
            Offset(cx + eyeOffX + browW / 2, browY + r * 0.02), stroke);
        break;
      default:
        // Friendly slight arch
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
        // Frown
        final path = Path()
          ..moveTo(cx - mouthW, mouthY)
          ..quadraticBezierTo(cx, mouthY - r * 0.22, cx + mouthW, mouthY);
        canvas.drawPath(path, stroke);
        break;
      case PesoMood.thinking:
        // Flat slightly tilted line
        canvas.drawLine(Offset(cx - mouthW * 0.6, mouthY - r * 0.02),
            Offset(cx + mouthW * 0.6, mouthY + r * 0.02), stroke);
        break;
      case PesoMood.celebrating:
        // Wide open O mouth
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
      default:
        // Smile with slight tooth fill
        final smilePath = Path()
          ..moveTo(cx - mouthW, mouthY)
          ..quadraticBezierTo(cx, mouthY + r * 0.28, cx + mouthW, mouthY);
        // Tooth fill
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
        // Both arms up high
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.2, cy - r * 0.55), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.2, cy - r * 0.55), armPaint);
        // Hands (3-blob fist)
        for (final dx in [-1, 0, 1]) {
          canvas.drawCircle(Offset(cx - r * 1.2 + dx * r * 0.09, cy - r * 0.62),
              r * 0.13, handPaint);
          canvas.drawCircle(Offset(cx + r * 1.2 + dx * r * 0.09, cy - r * 0.62),
              r * 0.13, handPaint);
        }
        break;
      case PesoMood.sad:
        // Arms drooping down
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.1, cy + r * 0.55), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.1, cy + r * 0.55), armPaint);
        break;
      case PesoMood.thinking:
        // Right arm raised to chin
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.05, cy + r * 0.3), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.1, cy - r * 0.15), armPaint);
        canvas.drawCircle(
            Offset(cx + r * 1.1, cy - r * 0.25), r * 0.15, handPaint);
        break;
      default:
        // Arms slightly raised — friendly wave
        canvas.drawLine(Offset(cx - r * 0.88, cy + r * 0.1),
            Offset(cx - r * 1.18, cy - r * 0.28), armPaint);
        canvas.drawLine(Offset(cx + r * 0.88, cy + r * 0.1),
            Offset(cx + r * 1.18, cy - r * 0.28), armPaint);
        // Small round hands
        for (final dx in [-1, 0, 1]) {
          canvas.drawCircle(
              Offset(cx - r * 1.18 + dx * r * 0.08, cy - r * 0.35),
              r * 0.12,
              handPaint);
          canvas.drawCircle(
              Offset(cx + r * 1.18 + dx * r * 0.08, cy - r * 0.35),
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

    if (mood == PesoMood.celebrating) {
      // Legs out to sides (jumping)
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

  @override
  bool shouldRepaint(_PesoCoinPainter old) =>
      old.mood != mood || old.size != size;
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
    final cs = Theme.of(context).colorScheme;
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
