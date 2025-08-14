import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../components/app_background.dart';
import 'widgets/CreateListeningExerciseScreen.dart';
import 'widgets/CreateWritingExerciseScreen.dart';
import 'widgets/ListeningExercisesListScreen.dart';
import 'widgets/WritingExercisesListScreen.dart';

class ExercisesTab extends StatelessWidget {
  const ExercisesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Quản lý bài tập theo kỹ năng',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Nhóm: Kỹ năng Nghe
            _buildSectionTitle('🟢 Kỹ năng Nghe'),
            _buildAdminOption(
              context,
              icon: LucideIcons.headphones,
              title: 'Danh sách bài tập Nghe',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListeningExercisesListScreen()),
                );
              },

            ),
            _buildAdminOption(
              context,
              icon: LucideIcons.filePlus,
              title: 'Tạo bài tập Nghe',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateListeningExerciseScreen()),
                );
              },

            ),

            const SizedBox(height: 24),

            // Nhóm: Kỹ năng Viết
            _buildSectionTitle('🟣 Kỹ năng Viết'),
            _buildAdminOption(
              context,
              icon: LucideIcons.penLine,
              title: 'Danh sách bài tập Viết',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WritingExercisesListScreen()),
                );
              },

            ),
            _buildAdminOption(
              context,
              icon: LucideIcons.filePlus,
              title: 'Tạo bài tập Viết',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateWritingExerciseScreen()),
                );
              },

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAdminOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 26, color: Colors.deepOrange),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
