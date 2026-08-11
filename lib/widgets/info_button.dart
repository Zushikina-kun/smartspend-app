import 'package:flutter/material.dart';

/// A small ❓ icon button that shows an explanation dialog when tapped.
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
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content:
              Text(body, style: const TextStyle(fontSize: 13, height: 1.6)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got it"),
            ),
          ],
        ),
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
