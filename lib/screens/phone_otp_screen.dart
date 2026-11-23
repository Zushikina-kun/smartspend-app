import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';

/// Result returned to the caller when the OTP is confirmed successfully.
class PhoneOtpResult {
  final PhoneAuthCredential credential;
  const PhoneOtpResult(this.credential);
}

class PhoneOtpScreen extends StatefulWidget {
  final String phoneNumber;
  const PhoneOtpScreen({super.key, required this.phoneNumber});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _pinController = TextEditingController();
  final _pinFocus = FocusNode();

  String? _verificationId;
  int? _resendToken;

  bool _sending = false;
  bool _verifying = false;
  String? _errorMessage;

  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _errorMessage = null;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval (Android only). Complete immediately.
        if (mounted) Navigator.pop(context, PhoneOtpResult(credential));
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _sending = false;
            _errorMessage = _friendlyError(e);
          });
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _sending = false;
          });
          _startCooldown();
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) setState(() => _verificationId = verificationId);
      },
    );
  }

  Future<void> _verify(String code) async {
    if (_verificationId == null) return;
    setState(() {
      _verifying = true;
      _errorMessage = null;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      if (mounted) Navigator.pop(context, PhoneOtpResult(credential));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _errorMessage = _friendlyError(e);
          _pinController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _errorMessage = e.toString();
          _pinController.clear();
        });
      }
    }
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) t.cancel();
      });
    });
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Incorrect code. Please check and try again.';
      case 'invalid-phone-number':
        return 'The phone number is not valid.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later.';
      case 'session-expired':
        return 'The code has expired. Please request a new one.';
      default:
        return e.message ?? 'Verification failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: cs.onSurface,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: cs.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: cs.primaryContainer,
        border: Border.all(color: cs.primary),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_android_outlined,
                    size: 64, color: cs.primary),
                const SizedBox(height: 20),
                Text(
                  'Enter the 6-digit code',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sent to ${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (_sending)
                  Column(
                    children: [
                      CircularProgressIndicator(color: cs.primary),
                      const SizedBox(height: 12),
                      Text('Sending code…',
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  )
                else
                  Pinput(
                    controller: _pinController,
                    focusNode: _pinFocus,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    autofocus: true,
                    onCompleted: _verify,
                  ),

                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                          color: cs.onErrorContainer, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_verifying)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(color: cs.primary),
                  ),

                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: (_cooldownSeconds > 0 || _sending)
                      ? null
                      : _sendCode,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    _cooldownSeconds > 0
                        ? 'Resend in $_cooldownSeconds s'
                        : 'Resend Code',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
