import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'lesson_screen.dart';

class CourseList extends StatelessWidget {
  final FirebaseFirestore firestore;
  final bool filterByNew;

  const CourseList({
    super.key,
    required this.firestore,
    this.filterByNew = false,
  });

  @override
  Widget build(BuildContext context) {
    Query query = firestore.collection('courses');

    if (filterByNew) {
      final now = DateTime.now();
      final oneMonthAgo = now.subtract(const Duration(days: 30));
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(oneMonthAgo))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(now));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = snapshot.data!.docs;

        if (courses.isEmpty) {
          return const Center(child: Text('Không có khóa học mới'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final doc = courses[index];
            final course = {
              "id": doc.id,
              ...doc.data() as Map<String, dynamic>,
            };
            return CourseItem(course: course);
          },
        );
      },
    );
  }
}

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

      // Ghi dữ liệu enroll vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('enrollments')
          .doc(courseId)
          .set({
        "courseId": courseId,
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

  @override
  Widget build(BuildContext context) {
    final title = course['title'] ?? 'Khóa học';
    final description = course['description'] ?? 'Mô tả không có sẵn';
    final imageUrl = course['imageUrl'] as String?;
    final level = course['level'] ?? 'All Levels';
    final progress = 0.0;
    final lessons = 24; // bạn có thể lấy từ Firestore nếu có
    final time = '8 giờ'; // có thể thay bằng dữ liệu thật từ Firestore

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
                        Text('$lessons bài học',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(width: 16),
                        Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(time,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
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
                            final courseId = course['id'];
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
