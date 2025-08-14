import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditListeningExerciseScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditListeningExerciseScreen({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<EditListeningExerciseScreen> createState() => _EditListeningExerciseScreenState();
}

class _EditListeningExerciseScreenState extends State<EditListeningExerciseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _lessonNameController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title']);
    _descriptionController = TextEditingController(text: widget.initialData['description']);
    _lessonNameController = TextEditingController(text: widget.initialData['lessonName']);
  }

  Future<void> _updateExercise() async {
    await FirebaseFirestore.instance
        .collection('listening_exercises')
        .doc(widget.docId)
        .update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'lessonName': _lessonNameController.text,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Quay lại danh sách
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa bài tập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lessonNameController,
              decoration: const InputDecoration(labelText: 'Tên bài học'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _updateExercise,
              icon: const Icon(Icons.save),
              label: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}
