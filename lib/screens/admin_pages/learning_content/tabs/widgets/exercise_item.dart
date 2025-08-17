import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      await firestore
          .collection('vocabulary_exercises')
          .doc(exercise['id'])
          .delete();
      onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa thành công'),
          backgroundColor: Colors.green,
        ),
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
      builder: (_) => ExerciseFormDialog(
        firestore: firestore,
        courses: courses,
        exercise: exercise,
        onSaved: onUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              exercise['title'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _edit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _delete(context),
          ),
        ],
      ),
    );
  }
}

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
  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  String? _selectedCourseId;
  String? _selectedLessonId;
  String? _correctAnswer;
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _titleController.text = ex['title'] ?? '';
    _questionController.text =
    (ex['words'] as List<dynamic>?)?.isNotEmpty == true
        ? ex['words'][0]
        : '';
    final options = ex['options'] as Map<String, dynamic>? ?? {};
    _optionAController.text = options['A'] ?? '';
    _optionBController.text = options['B'] ?? '';
    _optionCController.text = options['C'] ?? '';
    _optionDController.text = options['D'] ?? '';
    _correctAnswer = ex['correctAnswer'];
    _selectedCourseId = ex['courseId'];
    _selectedLessonId = ex['lessonId'];
    if (_selectedCourseId != null) {
      _fetchLessons(_selectedCourseId!);
    }
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
      'words': [_questionController.text.trim()],
      'options': {
        'A': _optionAController.text.trim(),
        'B': _optionBController.text.trim(),
        'C': _optionCController.text.trim(),
        'D': _optionDController.text.trim(),
      },
      'correctAnswer': _correctAnswer,
    };
    try {
      await widget.firestore
          .collection('vocabulary_exercises')
          .doc(widget.exercise['id'])
          .update(data);
      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (v) => v!.isEmpty ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  Widget _buildDropdownCourse() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: _selectedCourseId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Chọn khóa học',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: widget.courses
            .map((c) => DropdownMenuItem(
            value: c['id'] as String,
            child: Text(c['title'] ?? 'No title')))
            .toList(),
        onChanged: (v) {
          setState(() {
            _selectedCourseId = v;
            _selectedLessonId = null;
            _lessons = [];
          });
          if (v != null) _fetchLessons(v);
        },
        validator: (v) => v == null ? 'Vui lòng chọn khóa học' : null,
      ),
    );
  }

  Widget _buildDropdownLesson() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: _selectedLessonId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Chọn bài học',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _lessons
            .map((l) => DropdownMenuItem(
            value: l['id'] as String, child: Text(l['title'] ?? 'No title')))
            .toList(),
        onChanged: (v) => setState(() => _selectedLessonId = v),
        validator: (v) => v == null ? 'Vui lòng chọn bài học' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.edit_note, size: 28, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Chỉnh sửa bài tập',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_titleController, 'Tên bài tập'),
                      _buildDropdownCourse(),
                      _buildDropdownLesson(),
                      _buildTextField(_questionController, 'Câu hỏi'),
                      _buildTextField(_optionAController, 'Đáp án A'),
                      _buildTextField(_optionBController, 'Đáp án B'),
                      _buildTextField(_optionCController, 'Đáp án C'),
                      _buildTextField(_optionDController, 'Đáp án D'),
                      DropdownButtonFormField<String>(
                        value: _correctAnswer,
                        decoration: InputDecoration(
                          labelText: 'Đáp án đúng',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['A', 'B', 'C', 'D']
                            .map((opt) =>
                            DropdownMenuItem(value: opt, child: Text(opt)))
                            .toList(),
                        onChanged: (v) => setState(() => _correctAnswer = v),
                        validator: (v) =>
                        v == null ? 'Vui lòng chọn đáp án đúng' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Lưu thay đổi',
                            style:
                            TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
