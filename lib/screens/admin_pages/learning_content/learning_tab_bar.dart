import 'package:flutter/material.dart';

class LearningTabBar extends StatelessWidget implements PreferredSizeWidget {
  const LearningTabBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7DD1C6), // Xanh ngọc pastel
            Color(0xFFA8E6CF), // Xanh ngọc nhạt hơn
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const TabBar(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3.0, color: Colors.white),
          insets: EdgeInsets.symmetric(horizontal: 20.0),
        ),
        indicatorWeight: 3,
        labelColor: Colors.black,
        unselectedLabelColor: Color(0xFFE0F7F4), // Xanh ngọc nhạt
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
