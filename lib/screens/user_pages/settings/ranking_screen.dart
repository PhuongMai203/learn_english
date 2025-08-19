import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo dữ liệu
    final ranking = [
      {"name": "Trần Thị B", "score": 92},
      {"name": "Nguyễn Văn A", "score": 85},
      {"name": "Lê Văn C", "score": 74},
      {"name": "Phạm Minh D", "score": 60},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bảng xếp hạng"),
        backgroundColor: const Color(0xFF5D8BF4),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ranking.length,
        itemBuilder: (context, index) {
          final user = ranking[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Text(
                  "#${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
              title: Text(user["name"] as String),
              subtitle: Text("Điểm số: ${(user["score"] as int).toString()}"),

              trailing: Icon(
                LucideIcons.award,
                color: index == 0
                    ? Colors.amber
                    : index == 1
                    ? Colors.grey
                    : index == 2
                    ? Colors.brown
                    : Colors.indigo,
              ),
            ),
          );
        },
      ),
    );
  }
}
