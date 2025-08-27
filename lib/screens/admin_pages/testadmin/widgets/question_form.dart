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

class _QuestionFormState extends State<QuestionForm>
    with SingleTickerProviderStateMixin {
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
      prefixIcon: Icon(icon, color: Colors.indigo.shade400),
      labelText: label,
      labelStyle: TextStyle(
          color: Colors.indigo.shade600, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.indigo.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
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
                  radius: 22,
                  backgroundColor: Colors.indigo.shade100,
                  child: Icon(Icons.edit, color: Colors.indigo.shade600),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.question == null ? "Thêm câu hỏi" : "Sửa câu hỏi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.indigo.shade100, thickness: 1),
            const SizedBox(height: 18),

            // --- Input fields ---
            TextField(
              controller: _contentController,
              decoration:
              _inputDecoration("Nội dung câu hỏi", Icons.help_outline),
            ),
            const SizedBox(height: 14),
            ...List.generate(4, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _optionControllers[i],
                  decoration: _inputDecoration(
                      "Đáp án ${i + 1}", Icons.circle_outlined),
                ),
              );
            }),

            DropdownButtonFormField<int>(
              value: _correctAnswerIndex,
              decoration: _inputDecoration(
                  "Chọn đáp án đúng", Icons.check_circle_outline),
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
            const SizedBox(height: 22),

            // --- Action buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: Colors.indigo.shade300),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Hủy",
                      style: TextStyle(color: Colors.indigo.shade500)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.indigo.shade500,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.indigo.shade200,
                    elevation: 6,
                  ),
                  onPressed: _submit,
                  child: const Text("Lưu",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
