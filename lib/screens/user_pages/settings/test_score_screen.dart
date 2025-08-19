import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TestScoreScreen extends StatelessWidget {
  const TestScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo dữ liệu
    final scores = [
      {"name": "Nguyễn Văn A", "score": 85},
      {"name": "Trần Thị B", "score": 92},
      {"name": "Lê Văn C", "score": 74},
      {"name": "Phạm Minh D", "score": 60},
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Điểm kiểm tra"),
          backgroundColor: const Color(0xFF5D8BF4),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scores.length,
          itemBuilder: (context, index) {
            final student = scores[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(LucideIcons.user, color: Colors.blue.shade700),
                ),
                title: Text(student["name"] as String),
                subtitle: Text("Điểm số: ${(student["score"] as int).toString()}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () {
                    // TODO: Chỉnh sửa điểm số
                  },
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: thêm học viên mới
          },
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
