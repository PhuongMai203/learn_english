import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'learning_content/learning_content_screen.dart';
import 'user_management_screen.dart';
import 'utilities_screen.dart';
import 'system_settings_screen.dart';

class AdminNavbar extends StatefulWidget {
  const AdminNavbar({super.key});

  @override
  State<AdminNavbar> createState() => _AdminNavbarState();
}

class _AdminNavbarState extends State<AdminNavbar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    LearningContentScreen(),
    const UserManagementScreen(),
    UtilitiesScreen(),
    const SystemSettingsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Nội dung học',
    'Người dùng',
    'Tiện ích',
    'Cài đặt',
  ];

  @override
  Widget build(BuildContext context) { // Đã thêm dấu ngoặc nhọn `{`
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Nội dung',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Người dùng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: 'Tiện ích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}