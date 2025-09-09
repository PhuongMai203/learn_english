import 'package:flutter/material.dart';

class DailyLessonCard extends StatelessWidget {
  const DailyLessonCard({super.key});

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
            color: Colors.orange[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.family_restroom, color: Colors.orange, size: 30),
        ),
        title: const Text("Bài học hôm nay", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Học 10 từ vựng về chủ đề Gia đình"),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: () {},
      ),
    );
  }
}
