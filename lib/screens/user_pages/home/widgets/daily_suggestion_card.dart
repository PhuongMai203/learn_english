import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailySuggestionCard extends StatelessWidget {
  const DailySuggestionCard({super.key});

  Future<String?> _fetchDailySuggestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final userId = user.uid;
    final today = DateTime.now();
    final todayString = "${today.year}-${today.month}-${today.day}";

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    final dailySuggestionDoc = await userDocRef
        .collection('dailySuggestion')
        .doc('today')
        .get();

    // Nếu đã có gợi ý hôm nay, trả về luôn
    if (dailySuggestionDoc.exists) {
      final data = dailySuggestionDoc.data()!;
      if (data['date'] == todayString) {
        return data['lessonTitle'];
      }
    }

    // Ngược lại: random bài học mới
    final enrollmentsSnapshot = await userDocRef
        .collection('enrollments')
        .get();

    if (enrollmentsSnapshot.docs.isEmpty) return null;

    final randomCourseDoc = enrollmentsSnapshot.docs[Random().nextInt(enrollmentsSnapshot.docs.length)];
    final courseId = randomCourseDoc.id;

    final lessonsSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .get();

    if (lessonsSnapshot.docs.isEmpty) return null;

    final randomLessonDoc = lessonsSnapshot.docs[Random().nextInt(lessonsSnapshot.docs.length)];
    final lessonTitle = randomLessonDoc.data()['title'] ?? 'Bài học thú vị';

    // Lưu vào Firestore để dùng lại trong ngày
    await userDocRef.collection('dailySuggestion').doc('today').set({
      'date': todayString,
      'lessonTitle': lessonTitle,
    });

    return lessonTitle;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _fetchDailySuggestion(),
      builder: (context, snapshot) {
        String subtitle;
        if (snapshot.connectionState == ConnectionState.waiting) {
          subtitle = 'Đang tải gợi ý...';
        } else if (snapshot.hasError || snapshot.data == null) {
          subtitle = 'Không có gợi ý hôm nay 😅';
        } else {
          subtitle = 'Thực hành với chủ đề: ${snapshot.data}';
        }

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb, color: Colors.amber, size: 30),
            ),
            title: const Text("Gợi ý hôm nay", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle),
          ),
        );
      },
    );
  }
}
