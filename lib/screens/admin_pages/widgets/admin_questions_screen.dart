import 'package:flutter/material.dart';
import 'models.dart';

class AdminQuestionsScreen extends StatefulWidget {
  final Test test;

  const AdminQuestionsScreen({super.key, required this.test});

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
  List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  String _selectedLevel = "Dễ";

  void _addQuestion() {
    final questionText = _questionController.text.trim();
    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (questionText.isEmpty || options.length < 2) return;

    setState(() {
      widget.test.questions.add(
        Question(
          text: questionText,
          options: options,
          correctIndex: _correctIndex,
          level: _selectedLevel,
        ),
      );
      _questionController.clear();
      for (var c in _optionControllers) c.clear();
      _correctIndex = 0;
      _selectedLevel = "Dễ";
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      widget.test.questions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Câu hỏi - ${widget.test.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form tạo câu hỏi
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: "Nội dung câu hỏi"),
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(4, (i) {
                return TextField(
                  controller: _optionControllers[i],
                  decoration: InputDecoration(labelText: "Đáp án ${i + 1}"),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Chọn đáp án đúng
            DropdownButton<int>(
              value: _correctIndex,
              items: List.generate(4, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text("Đáp án ${i + 1}"),
                );
              }),
              onChanged: (val) {
                if (val != null) setState(() => _correctIndex = val);
              },
            ),

            // Chọn cấp độ
            DropdownButton<String>(
              value: _selectedLevel,
              items: ["Dễ", "Trung bình", "Khó"].map((level) {
                return DropdownMenuItem(value: level, child: Text(level));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLevel = val);
              },
            ),

            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text("Thêm câu hỏi"),
            ),
            const SizedBox(height: 16),

            // Danh sách câu hỏi
            Expanded(
              child: widget.test.questions.isEmpty
                  ? const Center(
                child: Text("Chưa có câu hỏi nào"),
              )
                  : ListView.builder(
                itemCount: widget.test.questions.length,
                itemBuilder: (context, index) {
                  final q = widget.test.questions[index];
                  return Card(
                    child: ListTile(
                      title: Text("${q.text} (${q.level})"),
                      subtitle: Text(
                        List.generate(
                          q.options.length,
                              (i) =>
                          "${i + 1}. ${q.options[i]}${i == q.correctIndex ? " ✅" : ""}",
                        ).join("\n"),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteQuestion(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
