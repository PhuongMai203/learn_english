import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../learning_content/learning_content_screen.dart';
import '../user_management_screen.dart';
import 'AnalyticsScreen.dart';

class AdminDashboardGrid extends StatelessWidget {
  const AdminDashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bảng điều khiển',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildCard(Iconsax.people, 'Người dùng', Colors.blue, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UserManagementScreen()));
            }),
            _buildCard(Iconsax.book, 'Khóa học', Colors.green, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LearningContentScreen()));
            }),
            _buildCard(Iconsax.video_play, 'Bài học', Colors.orange, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LearningContentScreen(initialIndex: 1),
                ),
              );
            }),
            _buildCard(Iconsax.chart_2, 'Phân tích', Colors.red, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
