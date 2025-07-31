import 'package:flutter/material.dart';

import '../../components/app_background.dart';

class UtilitiesScreen extends StatelessWidget {
  const UtilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Các tiện ích khác',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white, // Màu xanh pastel chuyên nghiệp
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildUtilityCard(
                icon: Icons.sync,
                title: 'Đồng bộ dữ liệu',
                subtitle: 'Đảm bảo dữ liệu hệ thống được cập nhật',
                onTap: () {},
              ),
              _buildUtilityCard(
                icon: Icons.backup,
                title: 'Sao lưu & Khôi phục',
                subtitle: 'Quản lý các bản sao lưu dữ liệu',
                onTap: () {},
              ),
              _buildUtilityCard(
                icon: Icons.bar_chart,
                title: 'Kiểm tra hoạt động',
                subtitle: 'Xem thống kê hoạt động gần đây',
                onTap: () {},
              ),
              _buildUtilityCard(
                icon: Icons.file_download,
                title: 'Xuất dữ liệu',
                subtitle: 'Tải dữ liệu dạng CSV hoặc Excel',
                onTap: () {},
              ),
              _buildUtilityCard(
                icon: Icons.library_books,
                title: 'Tài nguyên học tập mẫu',
                subtitle: 'Truy cập các tài liệu hệ thống gợi ý',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
