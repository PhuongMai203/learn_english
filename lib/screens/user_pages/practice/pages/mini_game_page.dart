import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MiniGamePage extends StatelessWidget {
  const MiniGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini Game"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Trang chơi game luyện từ vựng & ngữ pháp"),
      ),
    );
  }
}
