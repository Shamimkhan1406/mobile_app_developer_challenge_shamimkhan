import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/quiz_controller.dart';
import '../../controllers/story_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/buddy_widget.dart';
import '../widgets/quiz_card.dart';
import '../widgets/story_card.dart';
import '../widgets/success_overlay.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoryBuddyScreen extends StatefulWidget {
  const StoryBuddyScreen({super.key});

  @override
  State<StoryBuddyScreen> createState() => _StoryBuddyScreenState();
}

class _StoryBuddyScreenState extends State<StoryBuddyScreen> {
  late ConfettiController _confettiController;

  bool _successShown = false;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<StoryController>().initialize();
      await context.read<QuizController>().loadQuiz();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyController = context.watch<StoryController>();
    final quizController = context.watch<QuizController>();

    // Show quiz when narration finishes
    if (storyController.state == StoryState.completed &&
        quizController.state == QuizState.hidden) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quizController.showQuiz();
      });
    }

    // Play confetti only once
    if (quizController.state == QuizState.correct && !_successShown) {
      _successShown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("CONFETTI PLAY");
        _confettiController.play();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.appTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              BuddyWidget(
                isHappy: quizController.state == QuizState.correct,
                isSpeaking: storyController.state == StoryState.playing,
              ),

              const SizedBox(height: 24),

              StoryCard(story: AppStrings.storyText),

              const SizedBox(height: 24),

              if (storyController.state == StoryState.loading)
                Column(
                  children: [
                    const CircularProgressIndicator(),

                    const SizedBox(height: 12),

                    Text(
                      "✨ Preparing your story...",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),

              if (storyController.state == StoryState.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    storyController.errorMessage ?? AppStrings.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      storyController.state == StoryState.loading ||
                          storyController.state == StoryState.playing
                      ? null
                      : () {
                          _successShown = false;

                          storyController.readStory();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    storyController.state == StoryState.loading
                        ? 'Preparing...'
                        : AppStrings.readStoryButton,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (quizController.state == QuizState.correct)
                SuccessOverlay(
                      controller: _confettiController,
                      onReplay: () async {
                        _successShown = false;

                        final quizController = context.read<QuizController>();

                        quizController.resetQuiz();

                        await context.read<StoryController>().readStory();
                      },
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                    )
              else if (quizController.state != QuizState.hidden)
                const QuizCard()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
