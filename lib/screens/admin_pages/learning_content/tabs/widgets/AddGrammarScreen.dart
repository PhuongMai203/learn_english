import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

class AddGrammarScreen extends StatefulWidget {
  const AddGrammarScreen({super.key});

  @override
  State<AddGrammarScreen> createState() => _AddGrammarScreenState();
}

class _AddGrammarScreenState extends State<AddGrammarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _formulaController = TextEditingController();
  final _usageController = TextEditingController();
  final _exampleController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;

  Future<void> _saveGrammar() async {
    try {
      await _firestore.collection("grammars").add({
        "title": _titleController.text.trim(),
        "formula": _formulaController.text.trim(),
        "usage": _usageController.text.trim(),
        "example": _exampleController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Đã lưu cấu trúc ngữ pháp")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi khi lưu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Thêm Cấu trúc Ngữ pháp"),
          centerTitle: true,
          backgroundColor: Colors.white.withOpacity(0.85),
          foregroundColor: Colors.deepPurple.shade700,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  _titleController,
                  "Tên cấu trúc (VD: Present Simple)",
                  icon: Icons.title,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _formulaController,
                  "Công thức (VD: S + V(s/es) + O)",
                  icon: Icons.functions,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _usageController,
                  "Cách dùng",
                  maxLines: 3,
                  icon: Icons.lightbulb,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _exampleController,
                  "Ví dụ",
                  maxLines: 2,
                  icon: Icons.book,
                ),
                const SizedBox(height: 30),

                // 🔥 Nút Gradient đẹp
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveGrammar();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.save_rounded,
                                color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              "Lưu cấu trúc",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label,
      {int maxLines = 1, IconData? icon}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? "Vui lòng nhập $label" : null,
      decoration: InputDecoration(
        prefixIcon:
        icon != null ? Icon(icon, color: Colors.deepPurple.shade400) : null,
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepPurple.shade700),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}
