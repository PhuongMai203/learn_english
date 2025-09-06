import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Luyện nói"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Bài luyện phát âm theo mẫu sẽ hiển thị ở đây"),
      ),
    );
  }
}
