import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  static Future<void> updateUserStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (!snapshot.exists) {
        transaction.set(userRef, {
          'lastActiveDate': todayDate,
          'streak': 1,
          'totalActiveDays': 1,
        });
        return;
      }

      final data = snapshot.data()!;
      final rawLast = data['lastActiveDate'];

      DateTime? lastDate;
      if (rawLast is Timestamp) {
        lastDate = DateTime(rawLast.toDate().year, rawLast.toDate().month, rawLast.toDate().day);
      }

      int streak = data['streak'] ?? 0;
      int total = data['totalActiveDays'] ?? 0;

      if (lastDate != null && todayDate.isAtSameMomentAs(lastDate)) {
        // Hôm nay đã tính rồi → không thay đổi
      } else if (lastDate != null && todayDate.difference(lastDate).inDays == 1) {
        // Ngày liền kề → tăng streak
        streak += 1;
        total += 1;
      } else {
        // Ngắt chuỗi → reset streak
        streak = 1;
        total += 1;
      }

      transaction.update(userRef, {
        'lastActiveDate': todayDate,
        'streak': streak,
        'totalActiveDays': total,
      });
    });
  }
}
