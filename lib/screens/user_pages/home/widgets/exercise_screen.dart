import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Bài tập"),
          backgroundColor: const Color(0xFF86A7FC),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _ExerciseItem(
              question: "She ___ to school every day.",
              options: ["go", "goes", "going"],
              answer: "goes",
            ),
            _ExerciseItem(
              question: "I ___ a book now.",
              options: ["read", "am reading", "reads"],
              answer: "am reading",
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final String question;
  final List<String> options;
  final String answer;

  const _ExerciseItem({
    required this.question,
    required this.options,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...options.map((opt) => ListTile(
              leading: const Icon(Icons.circle_outlined),
              title: Text(opt),
              onTap: () {
                final correct = opt == answer;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      correct ? "✅ Chính xác!" : "❌ Sai rồi. Đáp án: $answer",
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
