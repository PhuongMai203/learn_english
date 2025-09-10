import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_english/components/app_background.dart';

class PersonalDictionaryPage extends StatelessWidget {
  const PersonalDictionaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Vui lòng đăng nhập để xem từ điển cá nhân"),
        ),
      );
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Từ điển cá nhân"),
          backgroundColor: const Color(0xFFF38D66),
          foregroundColor: Colors.white,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("dictionary")
              .orderBy("addedAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("Chưa có từ nào trong từ điển cá nhân"),
              );
            }
      
            final words = snapshot.data!.docs;
      
            return ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final wordData = words[index].data() as Map<String, dynamic>;
                final word = wordData["word"] ?? "";
                final meaning = wordData["meaning"] ?? "";
                final pronunciation = wordData["pronunciation"] ?? "";
                final type = wordData["type"] ?? "";
                final addedAt = wordData["addedAt"] as Timestamp?;
      
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Color(0xFFEF8025)),
                    title: Text(
                      word,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pronunciation.isNotEmpty)
                          Text("Phát âm: $pronunciation",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                        if (type.isNotEmpty)
                          Text("Loại từ: $type",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                        Text("Nghĩa: $meaning",
                            style: const TextStyle(fontSize: 15)),
                        if (addedAt != null)
                          Text(
                            "Ngày thêm: ${addedAt.toDate().day}/${addedAt.toDate().month}/${addedAt.toDate().year}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                      ],
                    ),
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
