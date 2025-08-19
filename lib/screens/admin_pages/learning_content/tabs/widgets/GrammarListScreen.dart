import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrammarListScreen extends StatelessWidget {
  const GrammarListScreen({super.key});

  void _editGrammar(BuildContext context, String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data["title"]);
    final formulaController = TextEditingController(text: data["formula"]);
    final usageController = TextEditingController(text: data["usage"]);
    final exampleController = TextEditingController(text: data["example"]);

    InputDecoration _inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                const Text(
                  "Chỉnh sửa Ngữ pháp",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: _inputDecoration("Tiêu đề", Icons.title),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: formulaController,
                  decoration: _inputDecoration("Công thức", Icons.functions),
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: usageController,
                  decoration: _inputDecoration("Cách dùng", Icons.lightbulb_outline),
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: exampleController,
                  decoration: _inputDecoration("Ví dụ", Icons.menu_book_outlined),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance.collection("grammars").doc(docId).update({
                  "title": titleController.text,
                  "formula": formulaController.text,
                  "usage": usageController.text,
                  "example": exampleController.text,
                  "createdAt": FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Đã lưu thay đổi"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Danh sách Ngữ pháp"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("grammars")
              .orderBy("createdAt", descending: true) // mới nhất trước
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("Chưa có cấu trúc ngữ pháp nào."),
              );
            }

            final docs = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final docId = docs[index].id;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data["title"] ?? "Không có tiêu đề",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.pencil, color: Colors.blue),
                            onPressed: () {
                              _editGrammar(context, docId, data);
                            },
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("grammars")
                                  .doc(docId)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("🗑️ Đã xóa ngữ pháp"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
