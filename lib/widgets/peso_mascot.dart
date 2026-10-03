import 'package:flutter/material.dart';

/// Peso — SmartSpend's mascot pangolin.
///
/// A small golden pangolin with a ₱ coin on his chest.
/// Peso is the friendly face of the AI chat and appears on all empty states.
///
/// Usage:
///   PesoMascot(size: 80)                     — neutral Peso
///   PesoMascot(size: 80, mood: PesoMood.happy)
///   PesoMascot(size: 80, mood: PesoMood.thinking)
///   PesoMascot(size: 80, mood: PesoMood.sad)
///   PesoMascot.withSpeech(size: 80, text: "Kumain ka na?")
enum PesoMood { happy, neutral, thinking, sad, celebrating }

class PesoMascot extends StatelessWidget {
  final double size;
  final PesoMood mood;

  const PesoMascot({
    super.key,
    this.size = 72,
    this.mood = PesoMood.neutral,
  });

  /// Peso with a speech bubble
  static Widget withSpeech({
    double size = 72,
    PesoMood mood = PesoMood.happy,
    required String text,
    Color? bubbleColor,
  }) {
    return _PesoWithSpeech(size: size, mood: mood, text: text, bubbleColor: bubbleColor);
  }

  String get _emoji {
    switch (mood) {
      case PesoMood.happy:       return '🦔';  // closest to pangolin in emoji
      case PesoMood.neutral:     return '🦔';
      case PesoMood.thinking:    return '🦔';
      case PesoMood.sad:         return '🦔';
      case PesoMood.celebrating: return '🦔';
    }
  }

  String get _moodEmoji {
    switch (mood) {
      case PesoMood.happy:       return '😊';
      case PesoMood.neutral:     return '🙂';
      case PesoMood.thinking:    return '🤔';
      case PesoMood.sad:         return '😟';
      case PesoMood.celebrating: return '🎉';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final coinSize = size * 0.38;
    final bodySize = size;

    return SizedBox(
      width: bodySize,
      height: bodySize * 1.1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body — pangolin shape using layered containers
          CustomPaint(
            size: Size(bodySize, bodySize),
            painter: _PangoPainter(cs: cs),
          ),
          // Mood emoji overlay (eyes/expression)
          Positioned(
            top: bodySize * 0.12,
            child: Text(
              _moodEmoji,
              style: TextStyle(fontSize: size * 0.22),
            ),
          ),
          // Coin on chest
          Positioned(
            bottom: bodySize * 0.28,
            child: Container(
              width: coinSize,
              height: coinSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.3, -0.3),
                  colors: [Color(0xFFFFE066), Color(0xFFC8960C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '₱',
                  style: TextStyle(
                    fontSize: coinSize * 0.52,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7A5200),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter that draws Peso's pangolin body
class _PangoPainter extends CustomPainter {
  final ColorScheme cs;
  const _PangoPainter({required this.cs});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.92), width: w * 0.7, height: h * 0.1),
        shadowPaint);

    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.3),
        colors: [Color(0xFF9B7418), Color(0xFF5C4008)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Main body oval
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.82, height: h * 0.58),
        bodyPaint);

    // Head
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.28), width: w * 0.58, height: h * 0.42),
        bodyPaint);

    // Snout
    final snoutPaint = Paint()..color = const Color(0xFF7A5810);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.38), width: w * 0.3, height: h * 0.18),
        snoutPaint);

    // Scales — overlapping arcs
    final scalePaint = Paint()
      ..color = const Color(0xFFA88028)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw 3 rows of arc-scales on the body
    for (int row = 0; row < 3; row++) {
      final y = h * (0.48 + row * 0.12);
      for (int col = 0; col < 4; col++) {
        final x = w * (0.18 + col * 0.22);
        canvas.drawArc(
            Rect.fromCenter(center: Offset(x, y), width: w * 0.22, height: h * 0.14),
            0, 3.14159, false, scalePaint);
      }
    }

    // Ears
    final earPaint = Paint()..color = const Color(0xFF8B6914);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.3, h * 0.08), width: w * 0.18, height: h * 0.14),
        earPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.7, h * 0.08), width: w * 0.18, height: h * 0.14),
        earPaint);
    // Inner ear
    final innerEarPaint = Paint()..color = const Color(0xFFC8960C);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.3, h * 0.08), width: w * 0.10, height: h * 0.08),
        innerEarPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.7, h * 0.08), width: w * 0.10, height: h * 0.08),
        innerEarPaint);

    // Tiny legs
    final legPaint = Paint()
      ..color = const Color(0xFF7A5810)
      ..strokeWidth = w * 0.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.28, h * 0.82), Offset(w * 0.22, h * 0.94), legPaint);
    canvas.drawLine(Offset(w * 0.44, h * 0.85), Offset(w * 0.40, h * 0.96), legPaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.85), Offset(w * 0.60, h * 0.96), legPaint);
    canvas.drawLine(Offset(w * 0.72, h * 0.82), Offset(w * 0.78, h * 0.94), legPaint);

    // Tail curl
    final tailPaint = Paint()
      ..color = const Color(0xFF8B6914)
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailPath = Path()
      ..moveTo(w * 0.85, h * 0.68)
      ..quadraticBezierTo(w * 1.05, h * 0.5, w * 0.95, h * 0.35);
    canvas.drawPath(tailPath, tailPaint);

    // Belly
    final bellyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFF5D898), Color(0xFFD4A84B)],
      ).createShader(Rect.fromLTWH(w * 0.3, h * 0.45, w * 0.4, h * 0.3));
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.42, height: h * 0.3),
        bellyPaint);

    // Blushing cheeks
    final blushPaint = Paint()..color = const Color(0xFFE8847040);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.32, h * 0.32), width: w * 0.14, height: h * 0.07),
        blushPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.68, h * 0.32), width: w * 0.14, height: h * 0.07),
        blushPaint);
  }

  @override
  bool shouldRepaint(_PangoPainter old) => false;
}

/// Peso with a speech bubble
class _PesoWithSpeech extends StatelessWidget {
  final double size;
  final PesoMood mood;
  final String text;
  final Color? bubbleColor;

  const _PesoWithSpeech({
    required this.size,
    required this.mood,
    required this.text,
    this.bubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bColor = bubbleColor ?? cs.primaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speech bubble
        Container(
          constraints: BoxConstraints(maxWidth: size * 3.2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: cs.onPrimaryContainer,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        // Peso
        PesoMascot(size: size, mood: mood),
      ],
    );
  }
}
