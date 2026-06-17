import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../services/tts_service.dart';

enum StoryState {
  idle,
  loading,
  playing,
  completed,
  error,
}

class StoryController extends ChangeNotifier {
  final TtsService _ttsService = TtsService();

  StoryState _state = StoryState.idle;

  String? _errorMessage;

  StoryState get state => _state;

  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _ttsService.initialize(
      onStart: () {
        _state = StoryState.playing;
        notifyListeners();
      },
      onComplete: () {
        _state = StoryState.completed;
        notifyListeners();
      },
      onError: (message) {
        _state = StoryState.error;
        _errorMessage = message;
        notifyListeners();
      },
    );
  }

  Future<void> readStory() async {
    try {
      _state = StoryState.loading;
      notifyListeners();

      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      await _ttsService.speak(
        AppStrings.storyText,
      );
    } catch (e) {
      _state = StoryState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopStory() async {
    await _ttsService.stop();

    _state = StoryState.idle;

    notifyListeners();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}