import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget hiển thị 1 grammar exercise item (load trực tiếp từ Firestore)
class GrammarItem extends StatelessWidget {
  final String exerciseId;
  final FirebaseFirestore firestore;
  final VoidCallback onUpdated;

  const GrammarItem({
    super.key,
    required this.exerciseId,
    required this.firestore,
    required this.onUpdated,
  });

  void _delete(BuildContext context) async {
    try {
      await firestore.collection('grammar_exercises').doc(exerciseId).delete();
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

  void _edit(BuildContext context, Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (_) => ExerciseFormDialog(
        firestore: firestore,
        exercise: {
          'id': exerciseId,
          ...exercise,
        },
        onSaved: onUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('grammar_exercises').doc(exerciseId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null) {
          return const SizedBox.shrink();
        }

        final title = data['title'] ?? '';
        final words = (data['words'] as List?)?.join(" ") ?? '';
        final options = data['options'] as Map<String, dynamic>? ?? {};
        final correct = data['correctAnswer'] ?? '';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header (icon + title + edit/delete)
              Row(
                children: [
                  Icon(LucideIcons.bookText, size: 28, color: Colors.black87),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title, // ✅ hiển thị tiêu đề (#1)
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _edit(context, data),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _delete(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/// Form chỉnh sửa grammar exercise
class ExerciseFormDialog extends StatefulWidget {
  final FirebaseFirestore firestore;
  final Map<String, dynamic> exercise;
  final VoidCallback onSaved;

  const ExerciseFormDialog({
    super.key,
    required this.firestore,
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
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  String _correctAnswer = "A";

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _titleController.text = ex['title'] ?? '';
    _wordsController.text = (ex['words'] as List?)?.join(" ") ?? '';

    final options = ex['options'] as Map<String, dynamic>? ?? {};
    _optionAController.text = options['A'] ?? '';
    _optionBController.text = options['B'] ?? '';
    _optionCController.text = options['C'] ?? '';
    _optionDController.text = options['D'] ?? '';

    _correctAnswer = ex['correctAnswer'] ?? "A";
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _titleController.text.trim(),
      'words': [_wordsController.text.trim()],
      'options': {
        'A': _optionAController.text.trim(),
        'B': _optionBController.text.trim(),
        'C': _optionCController.text.trim(),
        'D': _optionDController.text.trim(),
      },
      'correctAnswer': _correctAnswer,
      'createdAt': widget.exercise['createdAt'] ?? FieldValue.serverTimestamp(),
    };
    try {
      await widget.firestore
          .collection('grammar_exercises')
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note, size: 28, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Chỉnh sửa bài tập',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                _buildTextField(_titleController, 'Tiêu đề'),
                _buildTextField(_wordsController, 'Câu hỏi'),
                _buildTextField(_optionAController, 'Đáp án A'),
                _buildTextField(_optionBController, 'Đáp án B'),
                _buildTextField(_optionCController, 'Đáp án C'),
                _buildTextField(_optionDController, 'Đáp án D'),

                /// chọn đáp án đúng
                DropdownButtonFormField<String>(
                  value: _correctAnswer,
                  items: const [
                    DropdownMenuItem(value: "A", child: Text("Đáp án A")),
                    DropdownMenuItem(value: "B", child: Text("Đáp án B")),
                    DropdownMenuItem(value: "C", child: Text("Đáp án C")),
                    DropdownMenuItem(value: "D", child: Text("Đáp án D")),
                  ],
                  onChanged: (val) => setState(() => _correctAnswer = val ?? "A"),
                  decoration: InputDecoration(
                    labelText: "Đáp án đúng",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Lưu thay đổi',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
