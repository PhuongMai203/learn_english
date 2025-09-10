import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/app_background.dart';
import 'widgets/category_filter.dart';
import 'widgets/course_list.dart';
import 'widgets/course_widgets.dart';
import 'widgets/enrolled_course_list.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedCategory = 0; // mặc định "Tất cả"
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const SizedBox(height: 50),

            CategoryFilter(
              selectedIndex: _selectedCategory,
              onSelected: (index) {
                setState(() {
                  _selectedCategory = index;
                });
              },
            ),
            // Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm khóa học...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
              ),
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
        return CourseList(firestore: _firestore, searchQuery: _searchQuery);
      case 1: // Mới nhất
        return CourseList(
          firestore: _firestore,
          filterByNew: true,
          searchQuery: _searchQuery,
        );
      case 2: // Đang học
        return EnrolledCourseList(searchQuery: _searchQuery);
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
