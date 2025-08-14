import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseForm extends StatefulWidget {
  final FirebaseFirestore firestore;
  final List<Map<String, dynamic>> courses;
  final VoidCallback onSaved;

  const ExerciseForm({
    super.key,
    required this.firestore,
    required this.courses,
    required this.onSaved,
  });

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _wordsController = TextEditingController();
  final _correctController = TextEditingController();

  String? _selectedCourseId;
  String? _selectedLessonId;
  List<Map<String, dynamic>> _lessons = [];

  Future<void> _fetchLessons(String courseId) async {
    final snapshot = await widget.firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .get();
    setState(() {
      _lessons = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> _saveExercise({String? docId}) async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'title': _titleController.text.trim(),
      'courseId': _selectedCourseId,
      'lessonId': _selectedLessonId,
      'words': _wordsController.text.split(',').map((e) => e.trim()).toList(),
      'correctAnswer': _correctController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (docId != null) {
        await widget.firestore.collection('vocabulary_exercises').doc(docId).update(data);
      } else {
        await widget.firestore.collection('vocabulary_exercises').add(data);
      }

      _titleController.clear();
      _wordsController.clear();
      _correctController.clear();
      _selectedCourseId = null;
      _selectedLessonId = null;
      _lessons = [];
      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(docId != null ? 'Cập nhật thành công' : 'Thêm bài tập thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onCourseChanged(String? value) {
    setState(() {
      _selectedCourseId = value;
      _selectedLessonId = null;
      _lessons = [];
    });
    if (value != null) _fetchLessons(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tên bài tập
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tên bài tập',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên bài tập' : null,
              ),
              const SizedBox(height: 12),

              // Chọn khóa học
              DropdownButtonFormField<String>(
                value: _selectedCourseId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Chọn khóa học',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: widget.courses
                    .map((c) => DropdownMenuItem(
                  value: c['id'] as String,
                  child: Text(c['title'] ?? 'No title'),
                ))
                    .toList(),
                onChanged: _onCourseChanged,
                validator: (v) => v == null ? 'Vui lòng chọn khóa học' : null,
              ),
              const SizedBox(height: 12),

              // Chọn bài học
              DropdownButtonFormField<String>(
                value: _selectedLessonId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Chọn bài học',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _lessons
                    .map((l) => DropdownMenuItem(
                  value: l['id'] as String,
                  child: Text(l['title'] ?? 'No title'),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLessonId = v),
                validator: (v) => v == null ? 'Vui lòng chọn bài học' : null,
              ),
              const SizedBox(height: 12),

              // Nhập từ vựng
              TextFormField(
                controller: _wordsController,
                decoration: InputDecoration(
                  labelText: 'Từ vựng (cách nhau bằng dấu ,)',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập từ vựng' : null,
              ),
              const SizedBox(height: 12),

              // Nhập kết quả đúng
              TextFormField(
                controller: _correctController,
                decoration: InputDecoration(
                  labelText: 'Kết quả đúng',
                  hintText: 'Nhập đáp án đúng của bài tập',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập kết quả đúng' : null,
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu bài tập'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _saveExercise(),
              ),
            ],
          ),
        ),
      );
  }
}
