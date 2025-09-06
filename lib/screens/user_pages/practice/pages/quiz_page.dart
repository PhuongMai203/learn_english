import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bài kiểm tra"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Các bài kiểm tra định kỳ sẽ hiển thị ở đây"),
      ),
    );
  }
}
