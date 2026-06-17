import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/quiz_controller.dart';
import '../../core/constants/app_colors.dart';
import 'answer_option.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({super.key});

  @override
  Widget build(BuildContext context) {
    final quizController = context.watch<QuizController>();

    final quiz = quizController.quiz;

    if (quiz == null) {
      return const SizedBox.shrink();
    }

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ...quiz.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnswerOption(
                    text: option,
                    onTap: () {
                      quizController.checkAnswer(option);
                    },
                  ),
                ),
              ),

              if (quizController.state == QuizState.wrong)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Oops! Try again 😊',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        )
        .animate(target: quizController.state == QuizState.wrong ? 1 : 0)
        .shake(hz: 4, duration: 500.ms);
  }
}
