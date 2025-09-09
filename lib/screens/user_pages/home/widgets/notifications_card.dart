import 'package:flutter/material.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_active, color: Colors.blue),
        ),
        title: const Text("Thông báo", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Bạn có 2 bài tập chưa hoàn thành"),
        trailing: Chip(
          label: const Text("2 mới", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
        ),
        onTap: () {},
      ),
    );
  }
}
