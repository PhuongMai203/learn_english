import 'package:flutter/material.dart';

class AchievementsCard extends StatelessWidget {
  final int streak;
  final int totalDays;

  const AchievementsCard({
    super.key,
    required this.streak,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events, color: Colors.green, size: 30),
        ),
        title: const Text("Thành tích",
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chuỗi học: $streak ngày liên tiếp 🎯"),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: streak / 7,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 4),
            Text("Tiến độ: $streak/7 ngày",
                style: const TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
        trailing:
        const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: () {},
      ),
    );
  }
}
