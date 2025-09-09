import 'package:flutter/material.dart';
import 'vocabulary_screen.dart';
import 'grammar_screen.dart';
import 'exercise_screen.dart';

class QuickAccess extends StatelessWidget {
  final BuildContext context;
  const QuickAccess({required this.context, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Truy cập nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _QuickAccessIcon(
              icon: Icons.school,
              label: 'Từ vựng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VocabularyScreen()),
                );
              },
            ),
            _QuickAccessIcon(
              icon: Icons.menu_book,
              label: 'Ngữ pháp',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GrammarScreen()),
                );
              },
            ),
            _QuickAccessIcon(
              icon: Icons.assignment,
              label: 'Bài tập',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExerciseScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAccessIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
