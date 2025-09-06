import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/lesson_screen.dart';

class CourseItem extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseItem({super.key, required this.course});

  Future<void> _enrollAndNavigate(BuildContext context, String courseId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn cần đăng nhập để bắt đầu học")),
        );
        return;
      }

      final userId = user.uid;

      // Lấy thêm title và description từ course map
      final title = course['title'] ?? '';
      final description = course['description'] ?? '';
      final imageUrl = course['imageUrl'] ?? '';

      // Ghi dữ liệu enroll vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('enrollments')
          .doc(courseId)
          .set({
        "courseId": courseId,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "startedAt": FieldValue.serverTimestamp(),
        "progress": 0,
      });

      // Điều hướng sang LessonScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonScreen(courseId: courseId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi ghi dữ liệu: $e")),
      );
    }
  }

  Future<int> _getLessonCount(String courseId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .get();
    return snapshot.size; // số lượng document trong lessons
  }

  @override
  Widget build(BuildContext context) {
    final courseId = course['id'];
    final title = course['title'] ?? 'Khóa học';
    final description = course['description'] ?? 'Mô tả không có sẵn';
    final imageUrl = course['imageUrl'] as String?;
    final level = course['level'] ?? 'All Levels';
    final progress = 0.0;

    Color courseColor = Colors.blue;
    if (level.contains('Cơ bản')) {
      courseColor = Colors.green;
    } else if (level.contains('Nâng cao')) {
      courseColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: courseColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 28),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: courseColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              color: courseColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.menu_book,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        // 🔥 Dùng FutureBuilder để đếm số lượng bài học
                        FutureBuilder<int>(
                          future: _getLessonCount(courseId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Đang tải...");
                            }
                            if (snapshot.hasError) {
                              return const Text("Lỗi");
                            }
                            return Text(
                              "${snapshot.data} bài học",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (progress > 0) ...[
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: courseColor,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ: ${(progress * 100).toInt()}%',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700]),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                            ),
                            child: const Text(
                              'Tiếp tục học',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (courseId != null) {
                              _enrollAndNavigate(context, courseId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: courseColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Bắt đầu học'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
