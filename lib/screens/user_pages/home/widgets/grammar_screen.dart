import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Ngữ pháp"),
          backgroundColor: const Color(0xFFFF7B54),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _GrammarItem(
              title: "Thì hiện tại đơn",
              description: "Dùng để diễn tả thói quen, sự thật hiển nhiên.",
            ),
            _GrammarItem(
              title: "Thì hiện tại tiếp diễn",
              description: "Dùng để diễn tả hành động đang xảy ra ngay lúc nói.",
            ),
            _GrammarItem(
              title: "Thì quá khứ đơn",
              description: "Dùng để diễn tả hành động đã xảy ra và kết thúc trong quá khứ.",
            ),
          ],
        ),
      ),
    );
  }
}

class _GrammarItem extends StatelessWidget {
  final String title;
  final String description;

  const _GrammarItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.menu_book, color: Color(0xFFFF7B54)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}
