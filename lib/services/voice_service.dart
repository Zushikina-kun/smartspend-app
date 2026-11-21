import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError: (e) => _initialized = false,
    );
    return _initialized;
  }

  /// Starts listening and returns the recognized text.
  /// [onPartialResult] is called with interim results while listening.
  Future<String> startListening(
      {void Function(String)? onPartialResult}) async {
    final available = await initialize();
    if (!available) {
      throw Exception(
          "Microphone not available. Check permissions and try again.");
    }

    final completer = Completer<String>();
    String latestResult = '';

    // Try en_PH first (Filipino English), fall back to en_US
    final locales = await _speech.locales();
    final hasPhLocale = locales.any((l) => l.localeId.startsWith('en_PH'));
    final localeId = hasPhLocale ? 'en_PH' : 'en_US';

    await _speech.listen(
      onResult: (val) {
        latestResult = val.recognizedWords;
        if (onPartialResult != null) onPartialResult(latestResult);
        if (val.finalResult && !completer.isCompleted) {
          completer.complete(latestResult);
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor:
          const Duration(seconds: 2), // 2s pause is enough — 3s was too long
      localeId: localeId,
    );

    // Await the final recognition result instead of polling isListening,
    // which can flip false before the final-result callback fires.
    return await completer.future.timeout(
      const Duration(seconds: 18),
      onTimeout: () {
        if (latestResult.isNotEmpty) return latestResult;
        throw Exception('No speech detected. Please try again.');
      },
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
