import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'course_item.dart';

class CourseList extends StatelessWidget {
  final FirebaseFirestore firestore;
  final bool filterByNew;
  final String searchQuery;

  const CourseList({
    super.key,
    required this.firestore,
    this.filterByNew = false,
    this.searchQuery = "",
  });

  @override
  Widget build(BuildContext context) {
    Query query = firestore.collection('courses');

    // Nếu lọc theo "Mới nhất"
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

        // Lọc theo searchQuery (nếu có)
        final courses = snapshot.data!.docs.where((doc) {
          final title = (doc['title'] ?? '').toString().toLowerCase();
          return title.contains(searchQuery.toLowerCase());
        }).toList();

        if (courses.isEmpty) {
          return const Center(child: Text('Không tìm thấy khóa học'));
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
