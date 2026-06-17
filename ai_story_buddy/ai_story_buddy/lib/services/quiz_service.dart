import 'dart:convert';

import 'package:flutter/services.dart';
import '../models/quiz_model.dart';

class QuizService {
  Future<QuizModel> loadQuiz() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/quiz.json');

      final Map<String, dynamic> jsonData =
          jsonDecode(jsonString) as Map<String, dynamic>;

      return QuizModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }
}