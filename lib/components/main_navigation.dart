import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/AuthScreen.dart';
import '../screens/user_pages/account_screen.dart';
import '../screens/user_pages/course/course_screen.dart';
import '../screens/user_pages/home/home_screen.dart';
import '../screens/user_pages/practice/practice_screen.dart';
import '../screens/user_pages/welcome_screen.dart'; // <== IMPORT WELCOME SCREEN

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
    final List<Widget> loggedInScreens = [
      const HomeScreen(),
      const CourseScreen(),
      const PracticeScreen(),
      const AccountScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
        return false; // chặn back mặc định
      },
      child: Scaffold(
        body: isLoggedIn
            ? loggedInScreens[_selectedIndex]
            : const AuthScreen(initialTabIndex: 0),

        bottomNavigationBar: isLoggedIn
            ? BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book), label: 'Khóa học'),
            BottomNavigationBarItem(
                icon: Icon(Icons.school), label: 'Luyện tập'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Tài khoản'),
          ],
        )
            : null,
      ),
    );
  }
}
