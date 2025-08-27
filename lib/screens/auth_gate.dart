import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/main_navigation.dart';
import 'admin_pages/admin_navbar.dart';
import 'user_pages/welcome_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';

    // Tự động đăng nhập nếu có thông tin lưu trữ
    if (rememberMe && savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: savedEmail,
          password: savedPassword,
        );
        await _getUserRole();
      } catch (e) {
        setState(() => isLoading = false);
      }
    } else {
      await _getUserRole();
    }
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()!.containsKey('role')) {
          setState(() {
            role = doc['role'];
            isLoading = false;
          });
          return;
        }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị màn hình chờ trong quá trình xử lý
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Kiểm tra nếu có dữ liệu đăng nhập
        if (snapshot.hasData) {
          // Xử lý điều hướng theo vai trò
          if (role == 'admin') {
            return const AdminNavbar();
          } else if (role != null) {
            return const MainNavigation();
          }
        }

        // Trường hợp không có dữ liệu đăng nhập hoặc lỗi
        return const WelcomeScreen();
      },
    );
  }
}