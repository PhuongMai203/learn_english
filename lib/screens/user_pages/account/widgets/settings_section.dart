import 'package:flutter/material.dart';
import 'account_settings.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.settings,
            color: const Color(0xFF5D8BF4),
            title: 'Cài đặt tài khoản',
            subtitle: 'Cập nhật thông tin cá nhân',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountSettingsPage(),
                ),
              );
            },
          ),

          const Divider(height: 1, thickness: 0.5),
          const _SettingsItem(
            icon: Icons.history,
            color: Color(0xFFFF9F29),
            title: 'Lịch sử học tập',
            subtitle: 'Xem lại các bài học đã hoàn thành',
          ),
          const Divider(height: 1, thickness: 0.5),
          const _SettingsItem(
            icon: Icons.card_giftcard,
            color: Color(0xFFFFD369),
            title: 'Phần thưởng',
            subtitle: 'Điểm thưởng và huy hiệu',
          ),
          const Divider(height: 1, thickness: 0.5),
          const _SettingsItem(
            icon: Icons.notifications,
            color: Color(0xFF86A3E3),
            title: 'Thông báo',
            subtitle: 'Cài đặt nhắc nhở học tập',
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF495057),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: const TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
      )
          : null,
      trailing: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_forward_ios, size: 16, color: color),
      ),
    );
  }
}
