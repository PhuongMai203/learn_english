import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseNotificationsPopup {
  final BuildContext context;
  final GlobalKey iconKey;
  OverlayEntry? _entry; // lưu OverlayEntry để toggle

  CourseNotificationsPopup({required this.context, required this.iconKey});

  // 🔹 Lấy danh sách thông báo từ Firestore
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

  // 🔹 Hiển thị hoặc ẩn popup thông báo
  void toggle() async {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
      return;
    }

    final notifications = await _fetchNotifications();

    if (notifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn không có thông báo mới")),
      );
      return;
    }

    final overlay = Overlay.of(context);
    final renderBox = iconKey.currentContext!.findRenderObject() as RenderBox;
    final iconPosition = renderBox.localToGlobal(Offset.zero);

    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Nhấn ra ngoài để tắt popup
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _entry?.remove();
                _entry = null;
              },
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            top: iconPosition.dy + renderBox.size.height + 8, // ngay dưới icon
            right: 16, // canh bên phải
            width: MediaQuery.of(context).size.width * 2 / 3, // 2/3 màn hình
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              color: Colors.deepPurple[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: notifications
                          .map(
                            (msg) => Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications,
                                  color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  msg,
                                  style: const TextStyle(
                                      color: Colors.deepPurple),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
  }

  // 🔹 Widget hiển thị icon có badge
  Widget buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          key: iconKey,
          icon: const Icon(Icons.notifications, size: 28, color: Colors.deepPurple),
          onPressed: () => toggle(),
        ),
        // Badge hiển thị số thông báo
        Positioned(
          right: 6,
          top: 6,
          child: FutureBuilder<List<String>>(
            future: _fetchNotifications(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox();
              }
              final count = snapshot.data!.length;
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints:
                const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
