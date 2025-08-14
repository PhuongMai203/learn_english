import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../components/app_background.dart';
import 'widgets/edit_lesson_screen.dart';

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
      setState(() {});
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
              return const Center(child: Text("Lỗi khi tải dữ liệu", style: TextStyle(color: Colors.red)));
            }

            final courses = snapshot.data!;

            if (courses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text("Chưa có khóa học nào", style: TextStyle(fontSize: 18)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final lessons = course['lessons'] as List<Map<String, dynamic>>;
                final courseName = course['name'] as String;
                final courseId = course['id'] as String;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      courseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${lessons.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900, // Đậm nhất
                          fontSize: 18, // Tăng cỡ chữ
                          color: Color(0xFF0D47A1), // Màu xanh đậm hơn
                        ),
                      ),
                    ),

                    children: [
                      if (lessons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[300]),
                              const SizedBox(width: 10),
                              const Text("Chưa có bài học nào"),
                            ],
                          ),
                        )
                      else
                        ...lessons.map((lesson) {
                          final lessonId = lesson['id'] as String;
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              title: Text(
                                lesson['title'] ?? 'Không có tiêu đề',
                                style: const TextStyle(fontWeight: FontWeight.w400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                lesson['description'] ?? 'Không có mô tả',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue[700]),
                                    onPressed: () async {
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
                                      if (mounted) setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red[700]),
                                    onPressed: () {
                                      _showDeleteConfirmation(
                                        courseId: courseId,
                                        lessonId: lessonId,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
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
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa bài học này không?'),
        actions: [
          TextButton(
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Xóa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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