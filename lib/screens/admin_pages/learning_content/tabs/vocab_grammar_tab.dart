import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../components/app_background.dart';
import 'widgets/GrammarScreen.dart';
import 'widgets/VocabularyScreen.dart';

class VocabGrammarTab extends StatelessWidget {
  const VocabGrammarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildManagementCard(
                    context,
                    title: 'Từ vựng',
                    icon: LucideIcons.bookOpen,
                    color: const Color(0xFFFFF3CD), // Vàng pastel nhạt
                    onTap: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VocabularyScreen())
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    context,
                    title: 'Ngữ pháp',
                    icon: LucideIcons.fileText,
                    color: const Color(0xFFFFE0B2), // Cam pastel nhạt
                    onTap: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_)=> const GrammarScreen())
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
      BuildContext context, {
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
