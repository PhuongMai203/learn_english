import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

class VocabularyExercisesScreen extends StatefulWidget {
  final String vocabularyId;

  const VocabularyExercisesScreen({super.key, required this.vocabularyId});

  @override
  State<VocabularyExercisesScreen> createState() =>
      _VocabularyExercisesScreenState();
}

class _VocabularyExercisesScreenState extends State<VocabularyExercisesScreen> {
  final Map<String, String?> _selectedAnswers = {}; // đáp án người chọn
  final Map<String, bool> _submitted = {}; // trạng thái đã nộp

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Bài tập từ vựng"),
          centerTitle: true,
          backgroundColor: const Color(0xFF5BC0F8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vocabulary_exercises')
              .where('vocabularyId', isEqualTo: widget.vocabularyId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "Chưa có bài tập nào cho từ vựng này",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final docId = docs[index].id;
                final data = docs[index].data() as Map<String, dynamic>;

                final question = (data['words'] as List).isNotEmpty
                    ? data['words'][0]
                    : "Không có câu hỏi";
                final options = Map<String, dynamic>.from(data['options'] ?? {});
                final correctAnswer = data['correctAnswer'] ?? '';

                final userAnswer = _selectedAnswers[docId];
                final isSubmitted = _submitted[docId] ?? false;

                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Câu hỏi
                        Text(
                          "Câu ${index + 1}: $question",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Các đáp án
                        ...options.entries.map((entry) {
                          final optionKey = entry.key;
                          final optionValue = entry.value;

                          final isCorrect = optionKey == correctAnswer;
                          final isChosen = optionKey == userAnswer;

                          Color borderColor = Colors.grey.shade300;
                          Color? backgroundColor;

                          if (isSubmitted) {
                            if (isCorrect) {
                              borderColor = Colors.green;
                              backgroundColor = Colors.green.withOpacity(0.1);
                            } else if (isChosen && !isCorrect) {
                              borderColor = Colors.red;
                              backgroundColor = Colors.red.withOpacity(0.1);
                            }
                          } else if (isChosen) {
                            borderColor = const Color(0xFF5BC0F8);
                            backgroundColor = const Color(0xFF5BC0F8).withOpacity(0.1);
                          }

                          return GestureDetector(
                            onTap: isSubmitted
                                ? null
                                : () {
                              setState(() {
                                _selectedAnswers[docId] = optionKey;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: backgroundColor ?? Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor, width: 2),
                              ),
                              child: Text(
                                "$optionKey. $optionValue",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 16),

                        // Nút nộp bài
                        if (!isSubmitted)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: const Color(0xFF5BC0F8),
                              elevation: 3,
                            ),
                            onPressed: () {
                              if (userAnswer == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Bạn chưa chọn đáp án")),
                                );
                                return;
                              }
                              setState(() {
                                _submitted[docId] = true;
                              });
                            },
                            child: const Center(
                              child: Text(
                                "Nộp bài",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Text(
                              userAnswer == correctAnswer
                                  ? "🎉 Chính xác!"
                                  : "❌ Sai rồi. Đáp án đúng là: $correctAnswer",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: userAnswer == correctAnswer
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
