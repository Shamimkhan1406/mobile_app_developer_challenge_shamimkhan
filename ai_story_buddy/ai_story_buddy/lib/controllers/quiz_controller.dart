import 'package:flutter/material.dart';

import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

import 'package:flutter/services.dart';

enum QuizState { hidden, visible, wrong, correct }

class QuizController extends ChangeNotifier {
  final QuizService _quizService = QuizService();

  QuizModel? _quiz;

  QuizState _state = QuizState.hidden;

  String? _selectedAnswer;

  QuizModel? get quiz => _quiz;

  QuizState get state => _state;

  String? get selectedAnswer => _selectedAnswer;

  Future<void> loadQuiz() async {
    _quiz = await _quizService.loadQuiz();
    notifyListeners();
  }

  void showQuiz() {
    _state = QuizState.visible;
    notifyListeners();
  }

  void checkAnswer(String answer) {
    _selectedAnswer = answer;

    if (_quiz == null) return;

    if (answer == _quiz!.answer) {
      HapticFeedback.mediumImpact();

      _state = QuizState.correct;

      notifyListeners();
    } else {
      HapticFeedback.heavyImpact();

      _state = QuizState.wrong;

      notifyListeners();

      Future.delayed(const Duration(milliseconds: 700), () {
        if (_state == QuizState.wrong) {
          _state = QuizState.visible;
          notifyListeners();
        }
      });
    }
  }

  void resetWrongState() {
    if (_state == QuizState.wrong) {
      _state = QuizState.visible;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _selectedAnswer = null;
    _state = QuizState.hidden;
    notifyListeners();
  }
}
