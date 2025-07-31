import 'package:flutter/material.dart';
import '../../components/app_background.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

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
          backgroundColor: const Color(0xFF5D8BF4),
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
              _buildSectionTitle('Tuỳ chọn chung'),
              _buildSettingTile(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                subtitle: 'Thay đổi ngôn ngữ ứng dụng',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.notifications_active,
                title: 'Thông báo',
                subtitle: 'Cài đặt thông báo hệ thống',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Chính sách & Quyền riêng tư',
                subtitle: 'Quản lý điều khoản và chính sách',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Quản lý hệ thống'),
              _buildSettingTile(
                icon: Icons.category,
                title: 'Danh mục học tập',
                subtitle: 'Quản lý các danh mục từ vựng, ngữ pháp',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.scoreboard,
                title: 'Quản lý điểm số',
                subtitle: 'Tuỳ chỉnh hệ thống tính điểm',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.system_update_alt,
                title: 'Cập nhật hệ thống',
                subtitle: 'Kiểm tra và cập nhật phiên bản mới',
                onTap: () {},
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
          color: Colors.indigo,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
