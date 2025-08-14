import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../components/app_background.dart';

/// 1. DANH SÁCH TỪ VỰNG
class VocabularyListScreen extends StatelessWidget {
  const VocabularyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Danh sách từ'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          elevation: 2,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vocabulary')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có từ vựng nào.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );
            }

            final vocabList = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: vocabList.length,
              itemBuilder: (context, index) {
                final vocab = vocabList[index];
                final word = vocab['word'] ?? '';
                final pronunciation = vocab['pronunciation'] ?? '';
                final meaning = vocab['meaning'] ?? '';
                final type = vocab['type'] ?? '';

                return Card(
                  color: const Color(0xFFFFF9C4), // Vàng pastel nhẹ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(LucideIcons.book, color: Colors.black87),
                    title: Text(
                      "$word ${pronunciation.isNotEmpty ? '$pronunciation' : ''}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "$meaning\n$type",
                      style: const TextStyle(fontSize: 14),
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
