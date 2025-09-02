import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  /// Lấy dữ liệu từ Firestore (grammar_exercises + vocabulary_exercises)
  Future<List<Exercise>> _fetchExercises() async {
    final firestore = FirebaseFirestore.instance;

    // Lấy grammar_exercises
    final grammarSnap = await firestore.collection("grammar_exercises").get();
    final grammarExercises = grammarSnap.docs.map((doc) {
      return Exercise.fromFirestore(doc.data(), doc.id, "grammar");
    }).toList();

    // Lấy vocabulary_exercises
    final vocabSnap = await firestore.collection("vocabulary_exercises").get();
    final vocabExercises = vocabSnap.docs.map((doc) {
      return Exercise.fromFirestore(doc.data(), doc.id, "vocabulary");
    }).toList();

    // Gộp 2 loại
    return [...grammarExercises, ...vocabExercises];
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Bài tập",
            style: TextStyle(color: Colors.white),),
          backgroundColor: const Color(0xFFFF7B54),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: FutureBuilder<List<Exercise>>(
          future: _fetchExercises(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Chưa có bài tập"));
            }

            final exercises = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                return ExerciseItem(exercise: ex);
              },
            );
          },
        ),
      ),
    );
  }
}

/// Widget hiển thị từng bài tập
class ExerciseItem extends StatefulWidget {
  final Exercise exercise;

  const ExerciseItem({super.key, required this.exercise});

  @override
  State<ExerciseItem> createState() => _ExerciseItemState();
}

class _ExerciseItemState extends State<ExerciseItem> {
  String? selectedOption;
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    final options = widget.exercise.options; // A, B, C, D

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.exercise.question,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // Hiển thị danh sách đáp án
            Column(
              children: options.entries.map((entry) {
                final label = entry.key;   // A, B, C, D
                final opt = entry.value;   // nội dung đáp án

                Color bgColor = Colors.white;
                Color borderColor = Colors.grey;

                if (submitted) {
                  if (label == widget.exercise.correctAnswer) {
                    bgColor = Colors.green.shade200;
                    borderColor = Colors.green;
                  } else if (label == selectedOption) {
                    bgColor = Colors.red.shade200;
                    borderColor = Colors.red;
                  }
                } else {
                  if (label == selectedOption) {
                    bgColor = Colors.blue.shade100;
                    borderColor = Colors.blue;
                  }
                }

                return GestureDetector(
                  onTap: submitted
                      ? null
                      : () {
                    setState(() {
                      selectedOption = label;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "$label. ",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Expanded(
                          child: Text(opt, style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Nút Nộp bài
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
                    backgroundColor: const Color(0xFF86A7FC),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Nộp bài",
                    style: TextStyle(color: Colors.white),),
                ),
              )
          ],
        ),
      ),
    );
  }
}

/// Model bài tập
class Exercise {
  final String id;
  final String question;
  final Map<String, String> options; // A, B, C, D
  final String correctAnswer;
  final String type; // grammar hoặc vocabulary

  Exercise({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.type,
  });

  factory Exercise.fromFirestore(Map<String, dynamic> data, String id, String type) {
    return Exercise(
      id: id,
      question: (data['words'] as List).isNotEmpty ? data['words'][0] : "",
      options: Map<String, String>.from(data['options']),
      correctAnswer: data['correctAnswer'] ?? "",
      type: type,
    );
  }
}
