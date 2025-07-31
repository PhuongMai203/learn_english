import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../components/app_background.dart';

class ExercisesTab extends StatelessWidget {
  const ExercisesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildCard(
                  context,
                  title: 'Danh sách bài tập',
                  icon: LucideIcons.fileText,
                  color: const Color(0xFFFFCC80), // pastel orange
                  onTap: () {},
                ),
                _buildCard(
                  context,
                  title: 'Tạo bài tập mới',
                  icon: LucideIcons.filePlus,
                  color: const Color(0xFFFFE0B2),
                  onTap: () {},
                ),
                _buildCard(
                  context,
                  title: 'Phân loại theo kỹ năng',
                  icon: LucideIcons.layers,
                  color: const Color(0xFFFFAB91),
                  onTap: () {},
                ),
                _buildCard(
                  context,
                  title: 'Thống kê & Báo cáo',
                  icon: LucideIcons.chartBar,
                  color: const Color(0xFFFFE0B2),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
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
            Icon(icon, size: 38, color: Colors.deepOrange),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
