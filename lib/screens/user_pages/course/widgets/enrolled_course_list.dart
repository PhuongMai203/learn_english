import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'course_item.dart';

class EnrolledCourseList extends StatelessWidget {
  final String searchQuery;

  const EnrolledCourseList({
    super.key,
    this.searchQuery = "",
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Bạn cần đăng nhập để xem khóa học"));
    }

    final userEnrollmentsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('enrollments');

    return StreamBuilder<QuerySnapshot>(
      stream: userEnrollmentsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final enrollmentDocs = snapshot.data!.docs;
        if (enrollmentDocs.isEmpty) {
          return const Center(child: Text("Bạn chưa ghi danh khóa học nào"));
        }

        // Lấy danh sách ID khóa học từ enrollments
        final courseIds = enrollmentDocs.map((doc) => doc.id).toList();

        return FutureBuilder<List<DocumentSnapshot>>(
          future: Future.wait(courseIds.map((id) =>
              FirebaseFirestore.instance.collection('courses').doc(id).get())),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final courseDocs = snapshot.data!;

            // Lọc khóa học theo searchQuery
            final filteredCourses = courseDocs.where((doc) {
              if (!doc.exists) return false;
              final data = doc.data() as Map<String, dynamic>;
              final title = (data['title'] ?? '').toString().toLowerCase();
              return title.contains(searchQuery.toLowerCase());
            }).toList();

            if (filteredCourses.isEmpty) {
              return const Center(child: Text("Không tìm thấy khóa học phù hợp"));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final doc = filteredCourses[index];
                final course = {
                  "id": doc.id,
                  ...doc.data() as Map<String, dynamic>,
                };
                return CourseItem(course: course);
              },
            );
          },
        );
      },
    );
  }
}
