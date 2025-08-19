import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../components/app_background.dart';
import 'AddVocabularyScreen.dart';
import 'VocabularyExerciseScreen.dart';
import 'VocabularyListScreen.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Quản lý Từ vựng'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              _buildVocabCard(
                title: 'Danh sách từ',
                icon: LucideIcons.list,
                color: const Color(0xFFB3E5FC), // Xanh dương pastel
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (_)=> const VocabularyListScreen())
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildVocabCard(
                title: 'Thêm từ mới',
                icon: LucideIcons.circlePlus,
                color: const Color(0xFF7FCBEC), // Vàng pastel
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (_)=> const AddVocabularyScreen()));
                },
              ),
              const SizedBox(height: 12),
              _buildVocabCard(
                title: 'Bài tập từ vựng',
                icon: LucideIcons.bookOpenCheck,
                color: const Color(0xFF5DC2FF), // Tím pastel
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (_)=> const VocabularyExerciseScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVocabCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

