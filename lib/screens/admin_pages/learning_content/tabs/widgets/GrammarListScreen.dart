import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrammarListScreen extends StatelessWidget {
  const GrammarListScreen({super.key});

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                  // TODO: viết màn hình edit ngữ pháp
                                },
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection("grammars")
                                      .doc(docId)
                                      .delete();
                                },
                              ),
                            ],
                          )
                        ],
                      ),

                      // phần dưới giữ nguyên
                      // if (data["formula"] != null) ...[
                      //   const SizedBox(height: 6),
                      //   Text(
                      //     data["formula"]!
                      //         .replaceAll("(-)", "\n(-)")
                      //         .replaceAll("(?)", "\n(?)"),
                      //     style: const TextStyle(fontSize: 15),
                      //   ),
                      // ],
                      //
                      // if (data["usage"] != null) ...[
                      //   const SizedBox(height: 6),
                      //   Text("💡 Cách dùng: ${data["usage"]}"),
                      // ],
                      // if (data["example"] != null) ...[
                      //   const SizedBox(height: 6),
                      //   Text("✏️ Ví dụ: ${data["example"]}"),
                      // ],
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
