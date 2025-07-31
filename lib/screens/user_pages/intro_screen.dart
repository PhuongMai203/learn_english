import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chào mừng')),
      body: const Center(
        child: Text('Giới thiệu ứng dụng, lợi ích khi học tiếng Anh.'),
      ),
    );
  }
}
