import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_form.dart';

class ExerciseItem extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final FirebaseFirestore firestore;
  final List<Map<String, dynamic>> courses;
  final VoidCallback onUpdated;

  const ExerciseItem({
    super.key,
    required this.exercise,
    required this.firestore,
    required this.courses,
    required this.onUpdated,
  });

  void _delete(BuildContext context) async {
    try {
      await firestore.collection('vocabulary_exercises').doc(exercise['id']).delete();
      onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa thành công'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _edit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chỉnh sửa bài tập'),
        content: ExerciseFormDialog(
          firestore: firestore,
          courses: courses,
          exercise: exercise,
          onSaved: onUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordsCount = (exercise['words'] as List<dynamic>?)?.length ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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
          Icon(LucideIcons.clipboardList, size: 28, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _edit(context)),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(context)),
        ],
      ),
    );
  }
}

// Form dialog dùng khi chỉnh sửa
class ExerciseFormDialog extends StatefulWidget {
  final FirebaseFirestore firestore;
  final List<Map<String, dynamic>> courses;
  final Map<String, dynamic> exercise;
  final VoidCallback onSaved;

  const ExerciseFormDialog({
    super.key,
    required this.firestore,
    required this.courses,
    required this.exercise,
    required this.onSaved,
  });

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _wordsController = TextEditingController();
  String? _selectedCourseId;
  String? _selectedLessonId;
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _titleController.text = ex['title'] ?? '';
    _wordsController.text = (ex['words'] as List<dynamic>).join(', ');
    _selectedCourseId = ex['courseId'];
    _selectedLessonId = ex['lessonId'];
    _fetchLessons(_selectedCourseId!);
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _titleController.text.trim(),
      'courseId': _selectedCourseId,
      'lessonId': _selectedLessonId,
      'words': _wordsController.text.split(',').map((e) => e.trim()).toList(),
    };
    try {
      await widget.firestore.collection('vocabulary_exercises').doc(widget.exercise['id']).update(data);
      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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
    return SizedBox(
      width: double.maxFinite,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tên bài tập'), validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên bài tập' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCourseId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Chọn khóa học'),
                items: widget.courses.map((c) => DropdownMenuItem(value: c['id'] as String, child: Text(c['title'] ?? 'No title'))).toList(),
                onChanged: _onCourseChanged,
                validator: (v) => v == null ? 'Vui lòng chọn khóa học' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedLessonId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Chọn bài học'),
                items: _lessons.map((l) => DropdownMenuItem(value: l['id'] as String, child: Text(l['title'] ?? 'No title'))).toList(),
                onChanged: (v) => setState(() => _selectedLessonId = v),
                validator: (v) => v == null ? 'Vui lòng chọn bài học' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _wordsController, decoration: const InputDecoration(labelText: 'Từ vựng (cách nhau bằng dấu ,)'), validator: (v) => v!.isEmpty ? 'Vui lòng nhập từ vựng' : null),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}
