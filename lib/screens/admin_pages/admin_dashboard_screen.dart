import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../components/app_background.dart';
import 'learning_content/learning_content_screen.dart';
import 'user_management_screen.dart';
import 'widgets/AnalyticsScreen.dart';
import 'widgets/recent_activities.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Quản trị hệ thống',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.deepPurple),
              onPressed: () {},
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildMainDashboard(context),
              const SizedBox(height: 24),
              const RecentActivities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, Admin!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hệ thống đang hoạt động tốt. 15 bài học mới được thêm vào hôm nay.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Đếm users
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('users').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildStatCard(Iconsax.people, 'Người dùng', '...', Colors.blue, '');
              }
              if (snapshot.hasError) {
                return _buildStatCard(Iconsax.people, 'Người dùng', 'Lỗi', Colors.red, '');
              }
              final count = snapshot.data?.docs.length ?? 0;
              return _buildStatCard(Iconsax.people, 'Người dùng', '$count', Colors.blue, '');
            },
          ),

          // Đếm courses
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('courses').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildStatCard(Iconsax.book, 'Khóa học', '...', Colors.green, '');
              }
              if (snapshot.hasError) {
                return _buildStatCard(Iconsax.book, 'Khóa học', 'Lỗi', Colors.red, '');
              }
              final count = snapshot.data?.docs.length ?? 0;
              return _buildStatCard(Iconsax.book, 'Khóa học', '$count', Colors.green, '');
            },
          ),

          // Các mục còn lại tạm để cứng như trước
          _buildStatCard(Iconsax.video, 'Bài học', '428', Colors.orange, '+15 mới'),
          _buildStatCard(Iconsax.chart, 'Hoàn thành', '87%', Colors.purple, '+5%'),
        ],
      ),
    );
  }


  Widget _buildStatCard(IconData icon, String title, String value, Color color, String growth) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(growth, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bảng điều khiển',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildDashboardCard(Iconsax.people, 'Người dùng', Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserManagementScreen()),
              );
            }),

            _buildDashboardCard(Iconsax.book, 'Khóa học', Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LearningContentScreen()),
              );
            }),
            _buildDashboardCard(
              Iconsax.video_play,
              'Bài học',
              Colors.orange,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LearningContentScreen(initialIndex: 1),
                  ),
                );
              },
            ),
            _buildDashboardCard(Iconsax.chart_2, 'Phân tích', Colors.red, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
