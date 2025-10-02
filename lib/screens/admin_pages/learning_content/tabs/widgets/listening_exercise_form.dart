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
  final TextEditingController _scriptController = TextEditingController();

  String? _selectedLessonId;
  List<QuestionItem> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.lessons.isNotEmpty) {
      _selectedLessonId = widget.lessons.first['id'];
    }
    _addQuestion(); // mặc định có 1 câu hỏi
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionItem());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedLessonId != null) {
      final lesson = widget.lessons.firstWhere(
            (lesson) => lesson['id'] == _selectedLessonId,
        orElse: () => {},
      );

      final questions = _questions.map((q) => q.toMap()).toList();

      final data = {
        'title': _titleController.text.trim(),
        'scriptText': _scriptController.text.trim(),
        'lessonId': _selectedLessonId,
        'questions': questions,
        'createdAt': Timestamp.now(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('listening_exercises')
            .add(data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã tạo bài tập thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _titleController.clear();
        _scriptController.clear();
        setState(() {
          _questions = [QuestionItem()];
        });
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
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.darkBlue)),
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
              label: 'Đoạn văn bản / hội thoại',
              controller: _scriptController,
              icon: Icons.article,
              hint: 'Nhập nội dung văn bản...',
              validatorMsg: 'Vui lòng nhập văn bản',
              maxLines: 5,
            ),
            const SizedBox(height: 20),

            // Questions
            Text("Các câu hỏi",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.darkBlue)),
            const SizedBox(height: 8),

            ..._questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;

              return Card(
                color: Colors.blue.shade50,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: question.questionController,
                        decoration: const InputDecoration(
                          labelText: "Nội dung câu hỏi",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Vui lòng nhập câu hỏi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: List.generate(4, (i) {
                          return RadioListTile<int>(
                            value: i,
                            groupValue: question.correctIndex,
                            onChanged: (val) {
                              setState(() {
                                question.correctIndex = val!;
                              });
                            },
                            title: TextFormField(
                              controller: question.optionControllers[i],
                              decoration: InputDecoration(
                                labelText: "Đáp án ${String.fromCharCode(65 + i)}",
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Vui lòng nhập đáp án'
                                  : null,
                            ),
                          );
                        }),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeQuestion(index),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add, color: Colors.blue),
                label: const Text("Thêm câu hỏi"),
              ),
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
            style: TextStyle(
                color: widget.darkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: widget.textColor),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: widget.primaryColor),
            filled: true,
            fillColor: Colors.blue.shade50,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: widget.primaryColor, width: 1.5),
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          validator: validatorMsg != null
              ? (value) =>
          value == null || value.isEmpty ? validatorMsg : null
              : null,
        ),
      ],
    );
  }
}

/// Model câu hỏi
class QuestionItem {
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers =
  List.generate(4, (_) => TextEditingController());
  int correctIndex = 0;

  Map<String, dynamic> toMap() {
    return {
      "question": questionController.text.trim(),
      "options":
      optionControllers.map((c) => c.text.trim()).toList(),
      "correctIndex": correctIndex,
    };
  }
}
