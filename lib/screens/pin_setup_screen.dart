import 'package:flutter/material.dart';
import '../services/app_lock_service.dart';

/// Screen to set or change the 4-digit PIN for app lock.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;
  String? _error;

  void _onDigit(String digit) {
    final current = _confirming ? _confirmPin : _pin;
    if (current.length >= 4) return;
    setState(() {
      _error = null;
      if (_confirming) {
        _confirmPin += digit;
      } else {
        _pin += digit;
      }
    });

    if (!_confirming && _pin.length == 4) {
      // Move to confirm step
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _confirming = true);
      });
    } else if (_confirming && _confirmPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _save);
    }
  }

  void _onDelete() {
    setState(() {
      _error = null;
      if (_confirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          // Go back to first entry
          _confirming = false;
          _pin = '';
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _save() async {
    if (_pin != _confirmPin) {
      setState(() {
        _error = "PINs don't match. Try again.";
        _pin = '';
        _confirmPin = '';
        _confirming = false;
      });
      return;
    }
    await AppLockService.setPin(_pin);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("App lock PIN set successfully"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentPin = _confirming ? _confirmPin : _pin;

    return Scaffold(
      appBar: AppBar(
        title: Text(_confirming ? "Confirm PIN" : "Set PIN"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            Text(
              _confirming
                  ? "Re-enter your PIN to confirm"
                  : "Choose a 4-digit PIN",
              style: TextStyle(
                  fontSize: 16, color: cs.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < currentPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.15),
                    border: Border.all(
                      color: filled
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 20,
              child: _error != null
                  ? Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13))
                  : null,
            ),

            const SizedBox(height: 16),

            // Number pad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  for (final row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                    ['', '0', '⌫'],
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: row.map((d) {
                        if (d.isEmpty) return const SizedBox(width: 72);
                        return _PadButton(
                          label: d,
                          onTap: d == '⌫' ? _onDelete : () => _onDigit(d),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDelete = label == '⌫';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDelete
              ? Colors.transparent
              : cs.surfaceContainerHighest.withValues(alpha: 0.6),
        ),
        child: Center(
          child: isDelete
              ? Icon(Icons.backspace_outlined,
                  size: 22, color: cs.onSurface.withValues(alpha: 0.6))
              : Text(
                  label,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface),
                ),
        ),
      ),
    );
  }
}
