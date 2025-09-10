import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LearningPath extends StatefulWidget {
  const LearningPath({super.key});

  @override
  State<LearningPath> createState() => _LearningPathState();
}

class _LearningPathState extends State<LearningPath> {
  String? _lessonTitle;
  double _progress = 0.0;
  int _completed = 0;
  int _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLearningPath();
  }

  Future<void> _loadLearningPath() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _lessonTitle = "Bạn chưa đăng nhập";
        _loading = false;
      });
      return;
    }
    final userId = user.uid;

    try {
      // 1. Lấy khóa học đăng ký sớm nhất
      final enrollmentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('enrollments')
          .orderBy('startedAt')
          .limit(1)
          .get();

      if (enrollmentsSnapshot.docs.isEmpty) {
        setState(() {
          _lessonTitle = "Chưa có lộ trình học";
          _loading = false;
        });
        return;
      }

      final courseDoc = enrollmentsSnapshot.docs.first;
      final courseId = courseDoc.id;
      final completedLessons = courseDoc.data()['completedLessons'] ?? 0;

      // 2. Lấy danh sách bài học
      final lessonsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .orderBy('createdAt')
          .get();

      if (lessonsSnapshot.docs.isEmpty) {
        setState(() {
          _lessonTitle = "Khóa học chưa có bài học";
          _completed = 0;
          _total = 0;
          _progress = 0;
          _loading = false;
        });
        return;
      }

      final now = DateTime.now();
      QueryDocumentSnapshot<Map<String, dynamic>>? nextLesson;

      for (var lesson in lessonsSnapshot.docs) {
        final rawDate = lesson.data()['date'];
        if (rawDate != null && rawDate is Timestamp) {
          final lessonDate = rawDate.toDate();
          if (lessonDate.isAfter(now)) {
            nextLesson = lesson;
            break;
          }
        }
      }

      nextLesson ??= lessonsSnapshot.docs.first;
      setState(() {
        _lessonTitle = nextLesson?.data()['title'] ?? "Bài học chưa đặt tên";
        _completed = completedLessons;
        _total = lessonsSnapshot.docs.length;
        _progress = _total > 0 ? completedLessons / _total : 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _lessonTitle = "Lỗi tải dữ liệu: $e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lộ trình học",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Color(0xFF5AA0E3)]
                  .map((c) => c.withOpacity(0.1))
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_mosaic,
                    size: 30, color: Color(0xFF27629C)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _loading
                    ? const Text("Đang tải bài học...",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_lessonTitle ?? 'Không có dữ liệu',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (_total > 0) ...[
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.grey[300],
                              color: Color(0xFF22619E),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text("${(_progress * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                  color: Color(0xFF326DA5))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Hoàn thành $_completed/$_total bài",
                          style: const TextStyle(fontSize: 12)),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _total > 0 ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5AA0E3),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Tiếp tục"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
