import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BuddyWidget extends StatelessWidget {
  final bool isHappy;
  final bool isSpeaking;

  const BuddyWidget({
    super.key,
    this.isHappy = false,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buddy = Image.asset(
      isHappy
          ? 'assets/images/buddy_happy.png'
          : 'assets/images/buddy.png',
      height: 180,
    );

    if (isSpeaking) {
      buddy = buddy
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 700.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.05, 1.05),
            end: const Offset(1, 1),
            duration: 700.ms,
          );
    }

    return buddy
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .moveY(
          begin: 0,
          end: -10,
          duration: 1500.ms,
        )
        .then()
        .moveY(
          begin: -10,
          end: 0,
          duration: 1500.ms,
        );
  }
}