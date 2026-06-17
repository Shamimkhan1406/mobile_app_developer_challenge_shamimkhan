import 'package:flutter/material.dart';

class StoryCard extends StatelessWidget {
  final String story;

  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "STORY",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),

              Icon(
                Icons.menu_book_outlined,
                size: 22,
                color: Colors.grey.shade400,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: Text(
                story,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
