import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/story_controller.dart';
import 'controllers/quiz_controller.dart';
import 'views/screens/story_buddy_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StoryController(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Story Buddy',
      home: const StoryBuddyScreen(),
    );
  }
}