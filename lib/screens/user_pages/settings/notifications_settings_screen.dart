import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _generalNotifications = true;
  bool _lessonReminders = true;
  bool _achievementAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt thông báo"),
        backgroundColor: const Color(0xFF5D8BF4),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Bật thông báo chung"),
            value: _generalNotifications,
            onChanged: (val) => setState(() => _generalNotifications = val),
          ),
          SwitchListTile(
            title: const Text("Nhắc lịch học"),
            value: _lessonReminders,
            onChanged: (val) => setState(() => _lessonReminders = val),
          ),
          SwitchListTile(
            title: const Text("Thông báo thành tích"),
            value: _achievementAlerts,
            onChanged: (val) => setState(() => _achievementAlerts = val),
          ),
        ],
      ),
    );
  }
}
