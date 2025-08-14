import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_dropdown.dart';
import 'submit_button.dart';

class ListeningExerciseForm extends StatefulWidget {
  final List<Map<String, dynamic>> lessons;
  final Color primaryColor;
  final Color lightBlue;
  final Color mediumBlue;
  final Color darkBlue;
  final Color textColor;

  const ListeningExerciseForm({
    super.key,
    required this.lessons,
    required this.primaryColor,
    required this.lightBlue,
    required this.mediumBlue,
    required this.darkBlue,
    required this.textColor,
  });

  @override
  State<ListeningExerciseForm> createState() => _ListeningExerciseFormState();
}

class _ListeningExerciseFormState extends State<ListeningExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _audioUrlController = TextEditingController();
  String? _selectedLessonId;

  @override
  void initState() {
    super.initState();
    if (widget.lessons.isNotEmpty) {
      _selectedLessonId = widget.lessons.first['id'];
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedLessonId != null) {
      final lesson = widget.lessons.firstWhere(
            (lesson) => lesson['id'] == _selectedLessonId,
        orElse: () => {},
      );

      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'audioUrl': _audioUrlController.text.trim(),
        'lessonId': _selectedLessonId,
        'lessonName': lesson['name'] ?? '',
        'createdAt': Timestamp.now(),
      };

      try {
        await FirebaseFirestore.instance.collection('listening_exercises').add(data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã tạo bài tập thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _audioUrlController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu bài tập: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.mediumBlue),
              ),
              child: Row(
                children: [
                  Icon(Icons.headphones, size: 30, color: widget.darkBlue),
                  const SizedBox(width: 15),
                  Text('Bài tập Nghe mới',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.darkBlue)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildTextField(
              label: 'Tiêu đề bài tập',
              controller: _titleController,
              icon: Icons.title,
              hint: 'Nhập tiêu đề...',
              validatorMsg: 'Vui lòng nhập tiêu đề',
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Mô tả bài tập',
              controller: _descriptionController,
              icon: Icons.description,
              hint: 'Nhập mô tả...',
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Đường dẫn audio',
              controller: _audioUrlController,
              icon: Icons.audiotrack,
              hint: 'https://...',
              validatorMsg: 'Vui lòng nhập đường dẫn audio',
            ),
            const SizedBox(height: 20),

            LessonDropdown(
              lessons: widget.lessons,
              selectedLessonId: _selectedLessonId,
              onChanged: (value) => setState(() => _selectedLessonId = value),
              primaryColor: widget.primaryColor,
            ),

            const SizedBox(height: 35),
            SubmitButton(
              onPressed: _submitForm,
              primaryColor: widget.primaryColor,
              darkBlue: widget.darkBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? validatorMsg,
    int maxLines = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: widget.darkBlue, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: widget.textColor),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: widget.primaryColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.primaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          validator: validatorMsg != null ? (value) => value == null || value.isEmpty ? validatorMsg : null : null,
        ),
      ],
    );
  }
}
