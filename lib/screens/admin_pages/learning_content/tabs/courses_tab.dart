import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_background.dart';
import 'widgets/AddCourseScreen.dart';
import 'widgets/EditCourseScreen.dart';

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});

  void _confirmDeleteCourse(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa khóa học'),
        content: const Text('Bạn có chắc chắn muốn xóa khóa học này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('courses').doc(courseId).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa khóa học.')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm khóa học'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCourseScreen()),
        ),
      ),
      body: AppBackground(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('courses')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có khóa học nào',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            final courses = snapshot.data!.docs;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final doc = courses[index];
                  final course = doc.data() as Map<String, dynamic>;
                  final courseId = doc.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            // Course image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: course['imageUrl'] != null && course['imageUrl'].isNotEmpty
                                  ? Image.network(
                                course['imageUrl']!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 180,
                                  color: Colors.deepPurple[50],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                              )
                                  : Container(
                                height: 180,
                                color: Colors.deepPurple[50],
                                child: const Center(
                                  child: Icon(Icons.image, size: 50),
                                ),
                              ),
                            ),

                            // Action menu button
                            Positioned(
                              top: 12,
                              right: 12,
                              child: PopupMenuButton<String>(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.more_vert, color: Colors.deepPurple),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: const [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Sửa khóa học'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: const [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Xóa khóa học'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditCourseScreen(
                                            courseId: courseId,
                                            courseData: course
                                        ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    _confirmDeleteCourse(context, courseId);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        // Course details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Course title
                              Text(
                                course['title'] ?? 'Không có tiêu đề',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Course level
                              Row(
                                children: [
                                  Icon(Icons.star, size: 18, color: Colors.amber[700]),
                                  const SizedBox(width: 6),
                                  Text(
                                    course['level'] ?? 'Không rõ cấp độ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.deepPurple[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Course description
                              Text(
                                course['description']?.isNotEmpty == true
                                    ? (course['description']!.length > 100
                                    ? '${course['description']!.substring(0, 100)}...'
                                    : course['description']!)
                                    : 'Không có mô tả',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}