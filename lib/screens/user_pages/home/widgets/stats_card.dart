import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  Future<Map<String, dynamic>> _fetchStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {"minutes": 0, "vocabTotal": 0, "learned": 0};
    final userId = user.uid;

    final firestore = FirebaseFirestore.instance;

  final sessionSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .get();
    int totalMinutes = 0;
    for (var doc in sessionSnapshot.docs) {
      totalMinutes += (doc.data()['minutes'] ?? 0) as int;
    }

    final vocabSnapshot = await firestore.collection('vocabulary').get();
    final totalVocab = vocabSnapshot.size;

    final learnedSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('dictionary')
        .get();
    final learnedCount = learnedSnapshot.size;

    return {
      "minutes": totalMinutes,
      "vocabTotal": totalVocab,
      "learned": learnedCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Không thể tải dữ liệu"));
        }

        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Thống kê hôm nay",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.timer, "${data['minutes']} phút", "Học tập"),
                _buildStatItem(Icons.library_books,
                    "${data['learned']}/${data['vocabTotal']}", "Từ mới"),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              )),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
