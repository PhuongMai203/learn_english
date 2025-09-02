import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

class GrammarDetailScreen extends StatelessWidget {
  final String grammarId;
  final Map<String, dynamic> data;

  const GrammarDetailScreen({
    super.key,
    required this.grammarId,
    required this.data,
  });

  /// Hàm xử lý xuống dòng công thức từ Firestore
  String formatFormula(String raw) {
    return raw
        .replaceAll("(-)", "\n(-)")
        .replaceAll("(?)", "\n(?)")
        .replaceAll("(+)", "(+)");
  }

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? '';
    final usage = data['usage'] ?? '';
    final formula = data['formula'] ?? '';
    final example = data['example'] ?? '';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(color: Colors.white), // chữ trắng
          ),
          backgroundColor: const Color(0xFFFF7B54),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white), // nút back màu trắng
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                usage,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 16),
              Text(
                "📌 Công thức:\n${formatFormula(formula)}",
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "💡 Ví dụ:\n$example",
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                "📚 Bài tập",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7B54),
                ),
              ),
              const SizedBox(height: 12),

              // 🔽 StreamBuilder load bài tập từ Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('grammar_exercises')
                    .where('lessonId', isEqualTo: grammarId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text("Lỗi: ${snapshot.error}");
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(
                      "Chưa có bài tập nào cho phần này.",
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  final exercises = snapshot.data!.docs;

                  return Column(
                    children: exercises.map((doc) {
                      final ex = doc.data() as Map<String, dynamic>;

                      return ExerciseQuizCard(
                        title: ex['title'] ?? '',
                        question: (ex['words'] as List<dynamic>).join(" "),
                        options: Map<String, dynamic>.from(ex['options']),
                        correctAnswer: ex['correctAnswer'],
                      );
                    }).toList(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseQuizCard extends StatefulWidget {
  final String title;
  final String question;
  final Map<String, dynamic> options;
  final String correctAnswer;

  const ExerciseQuizCard({
    super.key,
    required this.title,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  @override
  State<ExerciseQuizCard> createState() => _ExerciseQuizCardState();
}

class _ExerciseQuizCardState extends State<ExerciseQuizCard> {
  String? selectedOption;
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFFFFFFF), // nền tối để chữ trắng rõ hơn
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.title}. ${widget.question}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Danh sách đáp án
            ...widget.options.entries.map((opt) {
              final isSelected = selectedOption == opt.key;
              final isCorrect = widget.correctAnswer == opt.key;

              Color bgColor = Colors.white;
              Color borderColor = Colors.grey;

              if (!submitted) {
                // Chưa nộp bài
                if (isSelected) {
                  bgColor = Colors.blue.shade50;
                  borderColor = Colors.blue;
                }
              } else {
                // Đã nộp bài
                if (isCorrect) {
                  bgColor = Colors.green.shade200;
                  borderColor = Colors.green;
                } else if (isSelected && !isCorrect) {
                  bgColor = Colors.red.shade200;
                  borderColor = Colors.red;
                }
              }

              return GestureDetector(
                onTap: submitted
                    ? null
                    : () {
                  setState(() {
                    selectedOption = opt.key;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blue,
                        child: Text(
                          opt.key,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.value,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 12),
            if (!submitted)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: selectedOption == null
                      ? null
                      : () {
                    setState(() {
                      submitted = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Nộp bài",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
