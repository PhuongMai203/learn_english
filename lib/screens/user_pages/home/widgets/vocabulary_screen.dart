import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';
import 'vocabulary_exercises_screen.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Từ vựng", style: TextStyle(color: Colors.white),),
          backgroundColor: const Color(0xFFFF7B54),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vocabulary')
              .orderBy('createdAt', descending: true) // sắp xếp mới nhất
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Chưa có từ vựng nào"));
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final docId = docs[index].id; // ✅ lấy document ID

                final word = data['word'] ?? '';
                final meaning = data['meaning'] ?? '';
                final pronunciation = data['pronunciation'] ?? '';
                final type = data['type'] ?? '';

                return _buildWordCard(
                    docId, word, meaning, pronunciation, type, context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWordCard(String docId, String word, String meaning,
      String phonetic, String type, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF5BC0F8).withOpacity(0.2),
          child: const Icon(Icons.translate, color: Color(0xFF5BC0F8)),
        ),
        title: Text(
          word,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text("$meaning • $type\n[$phonetic]"),
        onTap: () {
          // ✅ mở màn hình bài tập, truyền đúng document ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  VocabularyExercisesScreen(vocabularyId: docId),
            ),
          );
        },
      ),
    );
  }
}
