import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  Future<List<Map<String, dynamic>>> _fetchActivities() async {
    final usersSnapshot =
    await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> activities = [];

    for (var userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();
      final userId = userDoc.id;
      final username = userData['username'] ?? 'Người dùng';
      final photoURL = userData['photoURL'];

      // --- Enrollments ---
      final enrollmentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('enrollments')
          .get();

      for (var enroll in enrollmentsSnapshot.docs) {
        activities.add({
          'user': username,
          'photoURL': photoURL,
          'action': 'đã đăng ký khóa học "${enroll['title']}"',
          'time': enroll['startedAt'],
        });
      }

      // --- Dictionary ---
      final dictionarySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('dictionary')
          .get();

      for (var dict in dictionarySnapshot.docs) {
        activities.add({
          'user': username,
          'photoURL': photoURL,
          'action': 'đã thêm từ vựng "${dict['word']}" vào từ điển',
          'time': dict['addedAt'],
        });
      }
    }

    // Sort theo thời gian (mới nhất lên trên)
    activities.sort((a, b) {
      final t1 = (b['time'] as Timestamp).toDate();
      final t2 = (a['time'] as Timestamp).toDate();
      return t1.compareTo(t2);
    });

    return activities;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchActivities(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Chưa có hoạt động nào.');
            }

            final activities = snapshot.data!;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xF1FBFFD7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: activities.map((activity) {
                  final time = (activity['time'] as Timestamp).toDate();
                  return ActivityItem(
                    user: activity['user'],
                    action: activity['action'],
                    time: _formatTime(time),
                    photoURL: activity['photoURL'],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}

class ActivityItem extends StatelessWidget {
  final String user;
  final String action;
  final String time;
  final String? photoURL;

  const ActivityItem({
    super.key,
    required this.user,
    required this.action,
    required this.time,
    this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage:
        photoURL != null ? NetworkImage(photoURL!) : null,
        child: photoURL == null ? const Icon(Icons.person, color: Colors.white) : null,
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: user,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: ' $action',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        time,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
