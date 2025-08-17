import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class GrammarExerciseScreen extends StatelessWidget {
  final List<Map<String, dynamic>> exercises = [
    {
      "question": "She ___ to school every day.",
      "options": ["go", "goes", "going", "gone"],
      "answer": "goes"
    },
    {
      "question": "They ___ football yesterday.",
      "options": ["play", "played", "playing", "plays"],
      "answer": "played"
    },
  ];

  GrammarExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bài tập Ngữ pháp"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Điều hướng sang màn hình thêm bài tập
            },
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final ex = exercises[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex["question"],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...ex["options"].map<Widget>((opt) {
                  final isCorrect = opt == ex["answer"];
                  return Row(
                    children: [
                      Icon(isCorrect ? Icons.check_circle : Icons.circle_outlined,
                          color: isCorrect ? Colors.green : Colors.grey,
                          size: 18),
                      const SizedBox(width: 6),
                      Text(opt),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
