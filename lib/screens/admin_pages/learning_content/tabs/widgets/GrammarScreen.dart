import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../components/app_background.dart';
import 'AddGrammarScreen.dart';
import 'GrammarExerciseScreen.dart';
import 'GrammarListScreen.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Quản lý Ngữ pháp'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              _buildGrammarCard(
                title: 'Danh sách ngữ pháp',
                icon: LucideIcons.fileText,
                color: const Color(0xFFFFE0B2), // Cam pastel
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_)=> GrammarListScreen())
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildGrammarCard(
                title: 'Thêm cấu trúc mới',
                icon: LucideIcons.circlePlus,
                color: const Color(0xFFE1BEE7), // Tím pastel
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_)=> AddGrammarScreen())
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildGrammarCard(
                title: 'Bài tập ngữ pháp',
                icon: LucideIcons.locationEdit,
                color: const Color(0xFFB3E5FC), // Xanh dương pastel
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_)=> GrammarExerciseScreen())
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrammarCard({
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