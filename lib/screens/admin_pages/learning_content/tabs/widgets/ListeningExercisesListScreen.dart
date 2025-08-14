import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

import 'edit_listening_exercise_screen.dart';

class ListeningExercisesListScreen extends StatelessWidget {
  const ListeningExercisesListScreen({super.key});

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc muốn xoá bài tập này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseFirestore.instance
                  .collection('listening_exercises')
                  .doc(docId)
                  .delete();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xoá bài tập'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, String docId, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditListeningExerciseScreen(
          docId: docId,
          initialData: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Danh sách bài tập Nghe',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('listening_exercises')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }
            final exercises = snapshot.data?.docs ?? [];
            if (exercises.isEmpty) {
              return const Center(child: Text('Chưa có bài tập nào'));
            }
            return ListView.builder(
              itemCount: exercises.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final doc = exercises[index];
                final data = doc.data();
                final title = data['title'] ?? 'Không có tiêu đề';
                final description = data['description'] ?? '';
                final timestamp = data['createdAt'] as Timestamp?;
                final dateString = timestamp != null
                    ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)
                    .toLocal()
                    .toString()
                    .split('.')[0]
                    : '';
                final lessonName = data['lessonName'] ?? '';

                return Card(
                  color: Colors.yellow.shade50,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(description),
                        const SizedBox(height: 6),
                        Text(
                          'Bài học: $lessonName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ngày tạo: $dateString',
                          style: const TextStyle(fontSize: 12, color: Colors.black38),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEdit(context, doc.id, data);
                        } else if (value == 'delete') {
                          _confirmDelete(context, doc.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Sửa'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Xoá'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
