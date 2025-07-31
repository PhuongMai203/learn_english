import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../components/app_background.dart';

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
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.deepPurple),
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
              _buildRecentActivities(),
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
          _buildStatCard(Iconsax.people, 'Người dùng', '2,458', Colors.blue, '+124 mới'),
          _buildStatCard(Iconsax.book, 'Khóa học', '36', Colors.green, '+3 mới'),
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
            _buildDashboardCard(Iconsax.people, 'Người dùng', Colors.blue, () {}),
            _buildDashboardCard(Iconsax.book, 'Khóa học', Colors.green, () {}),
            _buildDashboardCard(Iconsax.video_play, 'Bài học', Colors.orange, () {}),
            _buildDashboardCard(Iconsax.document, 'Tài liệu', Colors.purple, () {}),
            _buildDashboardCard(Iconsax.chart_2, 'Phân tích', Colors.red, () {}),
            _buildDashboardCard(Iconsax.message, 'Hỗ trợ', Colors.teal, () {}),
            _buildDashboardCard(Iconsax.setting, 'Cài đặt', Colors.indigo, () {}),
            _buildDashboardCard(Iconsax.calendar, 'Lịch biểu', Colors.pink, () {}),
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

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildActivityItem('Nguyễn Văn A', 'đã hoàn thành khóa học Ngữ pháp nâng cao', '10 phút trước'),
              _buildActivityItem('Trần Thị B', 'đã đăng ký khóa học mới', '25 phút trước'),
              _buildActivityItem('Lê Văn C', 'đã gửi bài tập viết luận', '1 giờ trước'),
              _buildActivityItem('Phạm Thị D', 'được thăng hạng Vàng', '2 giờ trước'),
              _buildActivityItem('Hoàng Văn E', 'đã bình luận trong diễn đàn', '3 giờ trước'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String user, String action, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: AssetImage('assets/user_avatar.png'),

      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: user,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: ' $action',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        time,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.grey),
    );
  }
}
