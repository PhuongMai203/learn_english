import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class WritingPage extends StatelessWidget {
  const WritingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Luyện viết"),
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Bài tập viết lại câu đúng ngữ pháp sẽ hiển thị ở đây"),
      ),
    );
  }
}
