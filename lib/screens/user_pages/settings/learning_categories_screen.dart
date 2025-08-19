import 'package:flutter/material.dart';

class LearningCategoriesScreen extends StatelessWidget {
  const LearningCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      "Ngữ pháp",
      "Từ vựng",
      "Câu hỏi trắc nghiệm",
      "Đọc hiểu",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh mục học tập"),
        backgroundColor: const Color(0xFF5D8BF4),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.indigo),
              title: Text(categories[index]),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Tương lai: dẫn tới quản lý chi tiết danh mục
              },
            ),
          );
        },
      ),
    );
  }
}
