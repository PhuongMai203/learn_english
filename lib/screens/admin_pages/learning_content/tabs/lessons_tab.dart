import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../components/app_background.dart';
import 'widgets/edit_lesson_screen.dart'; // đảm bảo file tồn tại ở đường dẫn này

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCoursesWithLessons() async {
    final coursesSnapshot = await _firestore.collection('courses').get();
    final courseList = <Map<String, dynamic>>[];

    for (final courseDoc in coursesSnapshot.docs) {
      final lessonsSnapshot = await courseDoc.reference.collection('lessons').get();
      final lessons = lessonsSnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      courseList.add({
        'id': courseDoc.id,
        'name': courseDoc.data()['name'] ?? courseDoc.data()['title'] ?? '',
        'lessons': lessons,
      });
    }

    return courseList;
  }

  Future<void> deleteLesson(String courseId, String lessonId) async {
    await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bài học')),
      );
      setState(() {}); // Refresh lại danh sách
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchCoursesWithLessons(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text("Lỗi khi tải dữ liệu"));
            }

            final courses = snapshot.data!;

            if (courses.isEmpty) {
              return const Center(child: Text("Chưa có khóa học nào."));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final lessons = course['lessons'] as List<Map<String, dynamic>>;
                final courseName = course['name'] as String;
                final courseId = course['id'] as String;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    title: Text(
                      courseName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: lessons.isEmpty
                        ? [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Chưa có bài học nào."),
                      ),
                    ]
                        : lessons.map((lesson) {
                      final lessonId = lesson['id'] as String;
                      return ListTile(
                        title: Text(lesson['title'] ?? 'Không có tiêu đề'),
                        subtitle: Text(lesson['description'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () async {
                                // Điều hướng đến màn hình chỉnh sửa
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditLessonScreen(
                                      courseId: courseId,
                                      lessonId: lessonId,
                                      lessonData: lesson,
                                    ),
                                  ),
                                );
                                // Sau khi quay về thì reload
                                if (mounted) setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(
                                  courseId: courseId,
                                  lessonId: lessonId,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation({required String courseId, required String lessonId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài học này không?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Xóa'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              await deleteLesson(courseId, lessonId);
            },
          ),
        ],
      ),
    );
  }
}
