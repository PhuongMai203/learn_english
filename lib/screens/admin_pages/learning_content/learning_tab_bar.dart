import 'package:flutter/material.dart';

class LearningTabBar extends StatelessWidget implements PreferredSizeWidget {
  const LearningTabBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2), // Màu xanh dương
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const TabBar(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3.0, color: Colors.white),
          insets: EdgeInsets.symmetric(horizontal: 20.0),
        ),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFFBBDEFB), // Xanh nhạt
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        tabs: [
          Tab(text: 'Khóa học'),
          Tab(text: 'Bài học'),
          Tab(text: 'Bài tập'),
          Tab(text: 'Từ vựng & Ngữ pháp'),
          Tab(text: "Bài kiểm tra"),
        ],
      ),
    );
  }
}