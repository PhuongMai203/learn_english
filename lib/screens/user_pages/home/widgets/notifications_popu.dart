import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseNotificationsPopup {
  final BuildContext context;
  final GlobalKey iconKey;
  OverlayEntry? _entry; // lưu OverlayEntry để toggle

  CourseNotificationsPopup({required this.context, required this.iconKey});

  Future<List<String>> _fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final userId = user.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('enrollments')
        .get();

    List<String> messages = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final courseName = data['courseName'] ?? 'Khóa học';
      final progress = (data['progress'] ?? 0) as int;
      if (progress < 100) {
        messages.add(
          "Hãy hoàn thành khóa học \"$courseName\". Bạn đã hoàn thành $progress%.",
        );
      }
    }
    return messages;
  }

  void toggle() async {
    // Nếu popup đang hiển thị thì remove và kết thúc
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
      return;
    }

    // Fetch thông báo
    final notifications = await _fetchNotifications();

    if (notifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn không có thông báo mới 🎉")),
      );
      return;
    }

    final overlay = Overlay.of(context);
    final renderBox = iconKey.currentContext!.findRenderObject() as RenderBox;
    final iconPosition = renderBox.localToGlobal(Offset.zero);

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        top: iconPosition.dy + renderBox.size.height + 8, // ngay dưới icon
        right: 16, // canh bên phải
        width: MediaQuery.of(context).size.width * 2 / 3, // 2/3 màn hình
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Colors.deepPurple[50],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: notifications
                  .take(3)
                  .map(
                    (msg) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(msg,
                              style: const TextStyle(color: Colors.deepPurple))),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
  }
}
