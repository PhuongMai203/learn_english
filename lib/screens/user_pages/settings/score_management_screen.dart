import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'ranking_screen.dart';
import 'test_score_screen.dart';

class ScoreManagementScreen extends StatelessWidget {
  const ScoreManagementScreen({super.key});

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý điểm số"),
        backgroundColor: const Color(0xFF5D8BF4),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            icon: LucideIcons.fileCheck,
            title: "Điểm kiểm tra",
            subtitle: "Quản lý điểm từng bài học",
            color: Colors.blue,
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (_)=> TestScoreScreen())

              );
            },
          ),
          _buildMenuCard(
            icon: LucideIcons.award,
            title: "Xếp hạng",
            subtitle: "Xem thứ hạng người dùng",
            color: Colors.orange,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_)=> RankingScreen())

              );
            },
          ),
        ],
      ),
    );
  }
}
