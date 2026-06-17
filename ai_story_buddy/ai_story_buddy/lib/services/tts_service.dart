import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> initialize({
    required Function onStart,
    required Function onComplete,
    required Function(String message) onError,
  }) async {
    try {
      await _flutterTts.setLanguage('en-IN');

      await _flutterTts.setPitch(1.0);

      await _flutterTts.setSpeechRate(0.40);

      _flutterTts.setStartHandler(() {
        onStart();
      });

      _flutterTts.setCompletionHandler(() {
        onComplete();
      });

      _flutterTts.setErrorHandler((message) {
        onError(message);
      });
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.stop();

    await Future.delayed(const Duration(milliseconds: 300));

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
