import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/AuthScreen.dart';
import '../screens/user_pages/account_screen.dart';
import '../screens/user_pages/course_screen.dart';
import '../screens/user_pages/home_screen.dart';
import '../screens/user_pages/intro_screen.dart';
import '../screens/user_pages/practice_screen.dart';
import '../screens/user_pages/support_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Trang cho người đã đăng nhập
    final List<Widget> loggedInScreens = [
      const HomeScreen(),
      const CourseScreen(),
      const PracticeScreen(),
      const AccountScreen(),
    ];

    // Trang cho người chưa đăng nhập
    final List<Widget> loggedOutScreens = [
      const IntroScreen(),
      const CourseScreen(),
      const AuthScreen(initialTabIndex: 0), // Tab đăng nhập mặc định
      const SupportScreen(),
    ];

    return Scaffold(
      body: isLoggedIn
          ? loggedInScreens[_selectedIndex]
          : loggedOutScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: isLoggedIn
            ? const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: 'Khóa học'),
          BottomNavigationBarItem(
              icon: Icon(Icons.school), label: 'Luyện tập'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Tài khoản'),
        ]
            : const [
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: 'Giới thiệu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: 'Khóa học'),
          BottomNavigationBarItem(
              icon: Icon(Icons.lock_open), label: 'Đăng nhập'),
          BottomNavigationBarItem(
              icon: Icon(Icons.help_outline), label: 'Hỗ trợ'),
        ],
      ),
    );
  }
}
