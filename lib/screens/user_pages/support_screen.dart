import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ trợ')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Câu hỏi thường gặp và hướng dẫn sử dụng app.'),
      ),
    );
  }
}
