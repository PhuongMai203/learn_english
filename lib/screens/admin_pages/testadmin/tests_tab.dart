import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:learn_english/screens/admin_pages/testadmin/widgets/models.dart';

import 'widgets/question_card.dart';
import 'widgets/question_form.dart';

class AdminTestsScreen extends StatefulWidget {
  const AdminTestsScreen({super.key});

  @override
  State<AdminTestsScreen> createState() => _AdminTestsScreenState();
}

class _AdminTestsScreenState extends State<AdminTestsScreen> {
  final _firestore = FirebaseFirestore.instance;

  Test _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Test(
      id: data["id"] ?? doc.id,
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      duration: (data["duration"] ?? 0) as int,
      isActive: data["isActive"] ?? true,
      createdDate: DateTime.tryParse(data["createdDate"] ?? "") ?? DateTime.now(),
      questions: (data["questions"] as List<dynamic>? ?? []).map((q) {
        return Question(
          id: q["id"] ?? "",
          content: q["content"] ?? "",
          options: List<String>.from(q["options"] ?? []),
          correctAnswerIndex: q["correctAnswerIndex"] ?? 0,
        );
      }).toList(),
    );
  }

  Future<void> _saveTestToFirestore(Test test) async {
    await _firestore.collection("tests").doc(test.id).set({
      "id": test.id,
      "title": test.title,
      "description": test.description,
      "duration": test.duration,
      "isActive": test.isActive,
      "createdDate": test.createdDate.toIso8601String(),
      "questions": test.questions.map((q) => {
        "id": q.id,
        "content": q.content,
        "options": q.options,
        "correctAnswerIndex": q.correctAnswerIndex,
      }).toList(),
    });
  }

  Future<void> _deleteTestFromFirestore(String testId) async {
    await _firestore.collection("tests").doc(testId).delete();
  }

  void _addTest() {
    final newTest = Test(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "Bài kiểm tra mới",
      description: "Mô tả ngắn",
      duration: 30,
      isActive: true,
      createdDate: DateTime.now(),
      questions: [],
    );
    _saveTestToFirestore(newTest);
  }

  void _editTest(Test test) {
    setState(() {
      test.title = "${test.title} (đã sửa)";
    });
    _saveTestToFirestore(test);
  }

  void _deleteTest(Test test) {
    _deleteTestFromFirestore(test.id);
  }

  void _addQuestion(Test test) {
    showDialog(
      context: context,
      builder: (_) => QuestionForm(
        onSave: (q) {
          setState(() => test.questions.add(q));
          _saveTestToFirestore(test);
        },
      ),
    );
  }

  void _editQuestion(Test test, Question question) {
    showDialog(
      context: context,
      builder: (_) => QuestionForm(
        question: question,
        onSave: (q) {
          setState(() {
            final idx = test.questions.indexOf(question);
            if (idx != -1) test.questions[idx] = q;
          });
          _saveTestToFirestore(test);
        },
      ),
    );
  }

  void _deleteQuestion(Test test, Question question) {
    setState(() => test.questions.remove(question));
    _saveTestToFirestore(test);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection("tests").snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Chưa có bài kiểm tra nào"));
            }

            final tests = snapshot.data!.docs.map(_fromFirestore).toList();
            tests.sort((a, b) => b.createdDate.compareTo(a.createdDate));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tests.length,
              itemBuilder: (ctx, i) {
                final test = tests[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 5,
                  child: ExpansionTile(
                    tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFB2E8E1),
                      child: const Icon(Icons.assignment,
                          color: Color(0xFF289F92)),
                    ),
                    title: const Text(
                      "Bài kiểm tra",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C7D71), // Xanh ngọc đậm
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.description,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: test.isActive
                                    ? const Color(0xFFCFF6F1)
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                test.isActive ? "Active" : "Inactive",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: test.isActive
                                      ? const Color(0xFF1C7D71)
                                      : Colors.red.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text("Câu hỏi: ${test.questionCount}",
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      for (var q in test.questions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: QuestionCard(
                            question: q,
                            onEdit: () => _editQuestion(test, q),
                            onDelete: () => _deleteQuestion(test, q),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1C7D71),
                          ),
                          onPressed: () => _addQuestion(test),
                          icon: const Icon(Icons.add),
                          label: const Text("Thêm câu hỏi"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => _editTest(test),
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF1C7D71)),
                          ),
                          IconButton(
                            onPressed: () => _deleteTest(test),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addTest,
          icon: const Icon(Icons.add),
          label: const Text("Thêm bài kiểm tra"),
          backgroundColor: const Color(0xFF7DD1C6), // Xanh ngọc pastel
        ),
      ),
    );
  }
}
