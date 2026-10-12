import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'peso_mascot.dart';

/// Shows a one-time Peso tip overlay the FIRST time a screen is visited.
/// Auto-dismisses after 5 seconds or on tap.
/// Uses SharedPreferences to ensure it only shows once per screenKey.
class PesoScreenTip extends StatefulWidget {
  final String screenKey;      // unique pref key e.g. 'tip_budget_screen'
  final PesoMood mood;
  final String tipText;
  final double mascotSize;

  const PesoScreenTip({
    super.key,
    required this.screenKey,
    required this.tipText,
    this.mood = PesoMood.winking,
    this.mascotSize = 56,
  });

  @override
  State<PesoScreenTip> createState() => _PesoScreenTipState();
}

class _PesoScreenTipState extends State<PesoScreenTip>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _checkAndShow();
  }

  Future<void> _checkAndShow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('peso_tip_${widget.screenKey}') ?? false;
      if (seen || !mounted) return;
      await prefs.setBool('peso_tip_${widget.screenKey}', true);
      // Small delay so the screen renders first
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _visible = true);
      _ctrl.forward();
      // Auto-dismiss after 5 seconds
      Future.delayed(const Duration(seconds: 5), _dismiss);
    } catch (_) {}
  }

  void _dismiss() {
    if (!mounted || !_visible) return;
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _opacity,
      child: GestureDetector(
        onTap: _dismiss,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          child: PesoMascot.withSpeech(
            size: widget.mascotSize,
            mood: widget.mood,
            text: widget.tipText,
          ),
        ),
      ),
    );
  }
}
