import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_english/components/app_background.dart';

class FlashcardsPage extends StatelessWidget {
  const FlashcardsPage({super.key});

  Future<void> _saveWordToDictionary(
      BuildContext context,
      Map<String, dynamic> wordData,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dictionaryRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("dictionary");

    // Kiểm tra từ đã tồn tại chưa
    final existing = await dictionaryRef
        .where("word", isEqualTo: wordData["word"])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Từ này đã có trong từ điển của bạn!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Nếu chưa có thì thêm mới
    await dictionaryRef.add({
      "word": wordData["word"],
      "meaning": wordData["meaning"],
      "pronunciation": wordData["pronunciation"],
      "type": wordData["type"],
      "addedAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã lưu vào từ điển của bạn!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Flashcards"),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("vocabulary")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text("Chưa có từ vựng nào!"));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cột
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 4,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                return FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: _buildCardFront(data["word"] ?? ""),
                  back: _buildCardBack(
                    context,
                    data,
                    onSave: () => _saveWordToDictionary(context, data),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(String word) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.orange.shade200, Colors.deepOrange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            word,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(
      BuildContext context,
      Map<String, dynamic> data, {
        required VoidCallback onSave,
      }) {
    final word = data["word"] ?? "";
    final pronunciation = data["pronunciation"] ?? "";
    final type = data["type"] ?? "";
    final meaning = data["meaning"] ?? "";

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pronunciation,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              type,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              meaning,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            // Nút lưu từ điển
            ElevatedButton.icon(
              onPressed: onSave,
              label: Text("Lưu vào từ điển", style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
