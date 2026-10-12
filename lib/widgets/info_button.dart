import 'package:flutter/material.dart';
import 'peso_mascot.dart';

/// A small ❓ icon button that shows an explanation bottom sheet when tapped.
/// Use this anywhere a feature needs a brief explanation for new users.
class InfoButton extends StatelessWidget {
  final String title;
  final String body;
  final double size;

  const InfoButton({
    super.key,
    required this.title,
    required this.body,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          final cs = Theme.of(ctx).colorScheme;
          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Peso mascot — winking, tappable bounce
                const PesoMascot(
                    size: 72, mood: PesoMood.winking, tapMood: PesoMood.happy),
                const SizedBox(height: 16),
                // Speech bubble container
                Container(
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border:
                        Border.all(color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: cs.primary)),
                      const SizedBox(height: 8),
                      Text(body,
                          style: const TextStyle(fontSize: 13, height: 1.65)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Got it!'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.help_outline_rounded,
          size: size,
          color: cs.onSurface.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
