import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ListeningPage extends StatelessWidget {
  const ListeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Luyện nghe"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Bài nghe & bài tập điền từ sẽ hiển thị ở đây"),
      ),
    );
  }
}
