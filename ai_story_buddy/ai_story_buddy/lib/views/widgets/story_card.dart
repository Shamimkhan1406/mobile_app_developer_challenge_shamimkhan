import 'package:flutter/material.dart';

class StoryCard extends StatelessWidget {
  final String story;

  const StoryCard({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        story,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}