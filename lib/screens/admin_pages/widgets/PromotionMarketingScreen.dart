import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_english/components/app_background.dart';

class PromotionMarketingScreen extends StatefulWidget {
  const PromotionMarketingScreen({super.key});

  @override
  State<PromotionMarketingScreen> createState() => _PromotionMarketingScreenState();
}

class _PromotionMarketingScreenState extends State<PromotionMarketingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addPromotion() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("✨ Thêm khuyến mãi mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tiêu đề",
                prefixIcon: Icon(Icons.title, color: Color(0xFF1C7D71)), // xanh ngọc đậm
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Mô tả",
                prefixIcon: Icon(Icons.description, color: Color(0xFF4FB9A5)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Color(0xFF1C7D71))),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7DD1C6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await _firestore.collection("promotions").add({
                  "title": titleController.text,
                  "description": descController.text,
                  "createdAt": FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              "Lưu",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPromotion(String id, String currentTitle, String currentDesc) async {
    final titleController = TextEditingController(text: currentTitle);
    final descController = TextEditingController(text: currentDesc);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("✏️ Chỉnh sửa khuyến mãi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tiêu đề")),
            const SizedBox(height: 12),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Mô tả"), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Color(0xFF1C7D71))),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FB9A5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await _firestore.collection("promotions").doc(id).update({
                "title": titleController.text,
                "description": descController.text,
              });
              Navigator.pop(context);
            },
            icon: const Icon(Icons.update, color: Colors.white),
            label: const Text("Cập nhật", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePromotion(String id) async {
    await _firestore.collection("promotions").doc(id).delete();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    return DateFormat("dd/MM/yyyy HH:mm").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Quản lý Khuyến mãi & Tiếp thị",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF7DD1C6),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection("promotions").orderBy("createdAt", descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text(" Lỗi khi tải dữ liệu"));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final promotions = snapshot.data!.docs;
            if (promotions.isEmpty) {
              return const Center(child: Text("Chưa có khuyến mãi nào"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promo = promotions[index];
                final id = promo.id;
                final data = promo.data() as Map<String, dynamic>;
                final title = data["title"] ?? "";
                final desc = data["description"] ?? "";
                final createdAt = data["createdAt"] as Timestamp?;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE3F9F6), // xanh ngọc nhạt
                      child: const Icon(Icons.campaign, color: Color(0xFF1C7D71)),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(
                          "🕒 ${_formatDate(createdAt)}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == "edit") {
                          _editPromotion(id, title, desc);
                        } else if (value == "delete") {
                          _deletePromotion(id);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: "edit", child: Text("✏️ Chỉnh sửa")),
                        const PopupMenuItem(value: "delete", child: Text("🗑️ Xóa")),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addPromotion,
          backgroundColor: const Color(0xFF7DD1C6),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Thêm khuyến mãi",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
