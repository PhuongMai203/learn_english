import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/app_background.dart';
import 'widgets/category_filter.dart';
import 'widgets/course_list.dart';
import 'widgets/course_widgets.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedCategory = 0; // mặc định "Tất cả"

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const CourseHeader(),
            CategoryFilter(
              selectedIndex: _selectedCategory,
              onSelected: (index) {
                setState(() {
                  _selectedCategory = index;
                });
              },
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedCategory) {
      case 0: // Tất cả
        return CourseList(firestore: _firestore);
      case 2: // Mới nhất
        return CourseList(firestore: _firestore, filterByNew: true);
      default:
        return const Center(
          child: Text(
            "Chưa có nội dung cho mục này",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        );
    }
  }
}
