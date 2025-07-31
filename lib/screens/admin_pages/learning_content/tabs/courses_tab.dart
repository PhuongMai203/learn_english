import 'package:flutter/material.dart';

import '../../../../components/app_background.dart';

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    title: '📚 Tất cả khóa học',
                    color: const Color(0xFFFFECB3), // vàng pastel
                    icon: Icons.library_books,
                    onTap: () {},
                  ),
                  _buildCard(
                    title: '➕ Thêm khóa học',
                    color: const Color(0xFFFFCCBC), // cam pastel
                    icon: Icons.add_box,
                    onTap: () {},
                  ),
                  _buildCard(
                    title: '📝 Chỉnh sửa',
                    color: const Color(0xFFFFF9C4), // vàng nhạt hơn
                    icon: Icons.edit,
                    onTap: () {},
                  ),
                  _buildCard(
                    title: '📤 Xuất báo cáo',
                    color: const Color(0xFFFFE0B2), // cam nhạt
                    icon: Icons.download,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepOrange),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
