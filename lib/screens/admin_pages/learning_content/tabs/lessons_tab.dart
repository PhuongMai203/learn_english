import 'package:flutter/material.dart';
import '../../../../components/app_background.dart';

class LessonsTab extends StatelessWidget {
  const LessonsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: List.generate(5, (index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 24), // <-- tăng khoảng cách giữa các card
                      color: Colors.white.withOpacity(0.95),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFCC80),
                          child: Icon(Icons.menu_book, color: Colors.white),
                        ),
                        title: Text(
                          'Bài học ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18, // <-- tăng cỡ chữ tiêu đề
                          ),
                        ),
                        subtitle: const Text(
                          'Từ vựng cơ bản - Chủ đề gia đình',
                          style: TextStyle(fontSize: 15), // <-- tăng cỡ chữ phụ đề
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Xử lý tạo mới bài học
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo bài học mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB74D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
