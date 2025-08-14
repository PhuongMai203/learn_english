import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WritingExercisesListScreen extends StatelessWidget {
  const WritingExercisesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // nền nhạt
        appBar: AppBar(
          title: const Text('Danh sách bài tập Viết'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[800],
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Tạo mới bài viết',
              onPressed: () {
                // TODO: Chuyển tới trang tạo mới
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: 5, // giả sử có 5 bài viết
            itemBuilder: (context, index) {
              return Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[200],
                    child: const Icon(LucideIcons.penLine, color: Colors.white),
                  ),
                  title: Text(
                    'Bài viết #${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  subtitle: const Text('Mô tả ngắn gọn về nội dung bài viết.'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          // TODO: Chuyển tới trang chỉnh sửa
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // TODO: Hiện hộp thoại xác nhận xoá
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Tạo bài viết', style: TextStyle(color: Colors.white)),
          onPressed: () {
            // TODO: Chuyển tới trang tạo bài viết
          },
        ),
      ),
    );
  }
}
