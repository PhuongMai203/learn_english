import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseForm extends StatefulWidget {
  final FirebaseFirestore firestore;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> vocabularies;
  final VoidCallback onSaved;

  const ExerciseForm({
    super.key,
    required this.firestore,
    required this.courses,
    required this.onSaved,
    required this.vocabularies,
  });

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();

  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();

  String? _correctAnswer;
  String? _selectedCourseId;
  String? _selectedLessonId;
  String? _selectedVocabularyId;

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

    final selectedVocab = widget.vocabularies.firstWhere(
          (v) => v['id'] == _selectedVocabularyId,
      orElse: () => {},
    );

    final options = {
      'A': _optionAController.text.trim(),
      'B': _optionBController.text.trim(),
      'C': _optionCController.text.trim(),
      'D': _optionDController.text.trim(),
    };

    final data = {
      'title': selectedVocab['word'] ?? 'Không có tên',
      'courseId': _selectedCourseId,
      'lessonId': _selectedLessonId,
      'vocabularyId': _selectedVocabularyId,
      'words': [_questionController.text.trim()], // 🔥 thêm câu hỏi
      'options': options,
      'correctAnswer': _correctAnswer,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (docId != null) {
        await widget.firestore
            .collection('vocabulary_exercises')
            .doc(docId)
            .update(data);
      } else {
        await widget.firestore.collection('vocabulary_exercises').add(data);
      }

      // Reset form
      _selectedCourseId = null;
      _selectedLessonId = null;
      _selectedVocabularyId = null;
      _lessons = [];
      _questionController.clear();
      _optionAController.clear();
      _optionBController.clear();
      _optionCController.clear();
      _optionDController.clear();
      _correctAnswer = null;

      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text(docId != null ? 'Cập nhật thành công' : 'Thêm bài tập thành công'),
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
            const SizedBox(height: 16),

            // Gợi ý từ vựng làm tên bài tập
            Text('Tên bài tập (theo từ vựng)', style: _labelStyle()),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedVocabularyId,
              isExpanded: true,
              decoration: _inputDecoration('', Icons.text_fields).copyWith(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
              ),
              items: widget.vocabularies.map((vocab) {
                return DropdownMenuItem<String>(
                  value: vocab['id'] as String,
                  child: Text(
                    vocab['word']?.toString() ?? "Không có từ",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedVocabularyId = v),
              validator: (v) => v == null ? "Vui lòng chọn từ vựng" : null,
            ),
            const SizedBox(height: 16),

            // Nhập câu hỏi
            Text('Câu hỏi', style: _labelStyle()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _questionController,
              decoration: _inputDecoration('Nhập câu hỏi', Icons.help_outline),
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập câu hỏi' : null,
            ),
            const SizedBox(height: 20),

            // Course and lesson selection
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chọn khóa học', style: _labelStyle()),
                      const SizedBox(height: 8),
                      _buildCourseDropdown(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chọn bài học', style: _labelStyle()),
                      const SizedBox(height: 8),
                      _buildLessonDropdown(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Options section
            _buildSectionHeader('Phương án trả lời'),
            const SizedBox(height: 16),
            _buildOptionsGrid(),
            const SizedBox(height: 16),

            // Correct answer selection
            Text('Chọn đáp án đúng', style: _labelStyle()),
            const SizedBox(height: 8),
            _buildCorrectAnswerDropdown(),
            const SizedBox(height: 24),

            // Save button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.shade700,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  TextStyle _labelStyle() {
    return TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade700,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label.isNotEmpty ? label : null,
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCourseId,
      isExpanded: true,
      decoration: _inputDecoration('', Icons.school),
      items: widget.courses
          .map((c) => DropdownMenuItem<String>(
        value: c['id'] as String,
        child: Text(
          c['title'] ?? 'No title',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ))
          .toList(),
      onChanged: _onCourseChanged,
      validator: (v) => v == null ? 'Vui lòng chọn khóa học' : null,
    );
  }

  Widget _buildLessonDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLessonId,
      isExpanded: true,
      decoration: _inputDecoration('', Icons.menu_book),
      items: _lessons
          .map((l) => DropdownMenuItem<String>(
        value: l['id'] as String,
        child: Text(
          l['title'] ?? 'No title',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ))
          .toList(),
      onChanged: (v) => setState(() => _selectedLessonId = v),
      validator: (v) => v == null ? 'Vui lòng chọn bài học' : null,
    );
  }

  Widget _buildOptionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildOptionField('A', _optionAController, Colors.red.shade400),
        _buildOptionField('B', _optionBController, Colors.blue.shade400),
        _buildOptionField('C', _optionCController, Colors.green.shade400),
        _buildOptionField('D', _optionDController, Colors.amber.shade700),
      ],
    );
  }

  Widget _buildOptionField(
      String label, TextEditingController controller, Color color) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Phương án $label',
        filled: true,
        fillColor: color.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Vui lòng nhập phương án $label' : null,
    );
  }

  Widget _buildCorrectAnswerDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: _correctAnswer,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
        hint: const Text('Chọn đáp án đúng'),
        items: [
          _buildAnswerItem('A', Colors.red.shade400),
          _buildAnswerItem('B', Colors.blue.shade400),
          _buildAnswerItem('C', Colors.green.shade400),
          _buildAnswerItem('D', Colors.amber.shade700),
        ],
        onChanged: (value) => setState(() => _correctAnswer = value),
      ),
    );
  }

  DropdownMenuItem<String> _buildAnswerItem(String value, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Phương án $value'),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.save),
      label: const Text('Lưu bài tập'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: Colors.blue.shade200,
      ),
      onPressed: () => _saveExercise(),
    );
  }
}
