import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../components/app_background.dart';
import '../user_pages/settings/system_update_screen.dart';
import '../user_pages/welcome_screen.dart';
import 'widgets/AdminStatisticsScreen.dart';
import 'widgets/PromotionMarketingScreen.dart';

class AdminSystemSettingsScreen extends StatelessWidget {
  const AdminSystemSettingsScreen({super.key});

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng xuất: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Cài đặt hệ thống',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          // 🌿 Đổi từ xanh dương sang xanh ngọc pastel đậm
          backgroundColor: const Color(0xFF7DD1C6),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Quản lý nội dung'),
              _buildSettingTile(
                icon: Icons.campaign,
                title: 'Khuyến mãi & Tiếp thị',
                subtitle: 'Tạo và quản lý chiến dịch marketing',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PromotionMarketingScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Thống kê & Hệ thống'),
              _buildSettingTile(
                icon: Icons.bar_chart,
                title: 'Báo cáo & Thống kê',
                subtitle: 'Xem tổng quan người dùng, tiến độ học tập',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminStatisticsScreen()),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.system_update_alt,
                title: 'Cập nhật hệ thống',
                subtitle: 'Kiểm tra và cập nhật phiên bản mới',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SystemUpdateScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Tài khoản'),
              _buildSettingTile(
                icon: Icons.logout,
                title: 'Đăng xuất',
                subtitle: 'Thoát khỏi tài khoản admin',
                onTap: () => _signOut(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1C7D71), // 🌿 xanh ngọc đậm hơn một chút
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F9F6), // 🌿 xanh ngọc pastel nhạt
          child: const Icon(
            Icons.settings,
            color: Color(0xFF1C7D71), // xanh ngọc đậm
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Color(0xFF7DD1C6)),
        onTap: onTap,
      ),
    );
  }
}
