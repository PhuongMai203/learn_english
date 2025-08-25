import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/screens/admin_pages/testadmin/widgets/models.dart';

import 'widgets/question_card.dart';
import 'widgets/question_form.dart';

class AdminTestsScreen extends StatefulWidget {
  const AdminTestsScreen({super.key});

  @override
  State<AdminTestsScreen> createState() => _AdminTestsScreenState();
}

class _AdminTestsScreenState extends State<AdminTestsScreen> {
  final List<Test> _tests = [];
  final _firestore = FirebaseFirestore.instance;

  // --- Lưu Test lên Firestore ---
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

  // --- methods để add/edit/delete test ---
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
    setState(() => _tests.add(newTest));
    _saveTestToFirestore(newTest);
  }

  void _editTest(Test test) {
    // ví dụ sửa title
    setState(() {
      test.title = "${test.title} (đã sửa)";
    });
    _saveTestToFirestore(test);
  }

  void _deleteTest(Test test) {
    setState(() => _tests.remove(test));
    _deleteTestFromFirestore(test.id);
  }

  // --- methods để add/edit/delete question ---
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

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Bài kiểm tra")),
      body: ListView.builder(
        itemCount: _tests.length,
        itemBuilder: (ctx, i) {
          final test = _tests[i];
          return ExpansionTile(
            title: Text(test.title),
            subtitle: Text("Số câu hỏi: ${test.questionCount}"),
            children: [
              for (var q in test.questions)
                QuestionCard(
                  question: q,
                  onEdit: () => _editQuestion(test, q),
                  onDelete: () => _deleteQuestion(test, q),
                ),
              TextButton.icon(
                onPressed: () => _addQuestion(test),
                icon: const Icon(Icons.add),
                label: const Text("Thêm câu hỏi"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(onPressed: () => _editTest(test), icon: const Icon(Icons.edit)),
                  IconButton(onPressed: () => _deleteTest(test), icon: const Icon(Icons.delete)),
                ],
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTest,
        child: const Icon(Icons.add),
      ),
    );
  }
}
