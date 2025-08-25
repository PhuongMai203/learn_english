import 'package:flutter/material.dart';
import 'package:learn_english/screens/admin_pages/testadmin/widgets/models.dart';

class QuestionForm extends StatefulWidget {
  final Question? question;
  final void Function(Question) onSave;

  const QuestionForm({
    super.key,
    this.question,
    required this.onSave,
  });

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  late TextEditingController _contentController;
  late List<TextEditingController> _optionControllers;
  int _correctAnswerIndex = 0;

  @override
  void initState() {
    super.initState();
    _contentController =
        TextEditingController(text: widget.question?.content ?? "");
    _optionControllers = List.generate(
      4,
          (i) => TextEditingController(
        text: widget.question?.options[i] ?? "",
      ),
    );
    _correctAnswerIndex = widget.question?.correctAnswerIndex ?? 0;
  }

  @override
  void dispose() {
    _contentController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final newQuestion = Question(
      id: widget.question?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      content: _contentController.text,
      options: _optionControllers.map((c) => c.text).toList(),
      correctAnswerIndex: _correctAnswerIndex,
    );
    widget.onSave(newQuestion);
    Navigator.of(context).pop();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blue.shade600),
      labelText: label,
      labelStyle: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.blue.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Header ---
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.edit, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.question == null ? "Thêm câu hỏi" : "Sửa câu hỏi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // --- Input fields ---
            TextField(
              controller: _contentController,
              decoration: _inputDecoration("Nội dung câu hỏi", Icons.help_outline),
            ),
            const SizedBox(height: 14),
            ...List.generate(4, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _optionControllers[i],
                  decoration: _inputDecoration("Đáp án ${i + 1}", Icons.circle_outlined),
                ),
              );
            }),

            DropdownButtonFormField<int>(
              value: _correctAnswerIndex,
              decoration: _inputDecoration("Chọn đáp án đúng", Icons.check_circle_outline),
              items: List.generate(4, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text("Đáp án ${i + 1}"),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _correctAnswerIndex = val);
                }
              },
            ),
            const SizedBox(height: 20),

            // --- Action buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.blue.shade200,
                    elevation: 4,
                  ),
                  onPressed: _submit,
                  child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
