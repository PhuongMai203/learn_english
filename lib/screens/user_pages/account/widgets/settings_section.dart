import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'account_settings.dart';
import 'personal_dictionary_page.dart';
import 'reminder_settings_page.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            _SettingsItem(
              icon: Icons.settings,
              gradient: const LinearGradient(
                colors: [Color(0xFF5D8BF4), Color(0xFF3A64D8)],
              ),
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
            _SettingsItem(
              icon: Icons.book,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9F29), Color(0xFFE36C1A)],
              ),
              title: 'Từ điển cá nhân',
              subtitle: 'Xem lại những từ đã học',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalDictionaryPage(),
                  ),
                );
              },
            ),

            const Divider(height: 1, thickness: 0.5),
            _SettingsItem(
              icon: Icons.notifications,
              gradient: const LinearGradient(
                colors: [Color(0xFF86A3E3), Color(0xFF4C6EDB)],
              ),
              title: 'Thông báo',
              subtitle: 'Cài đặt nhắc nhở học tập',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReminderSettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.gradient,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: const TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
      )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 18, color: Color(0xFF9AA0A6)),
    );
  }
}
