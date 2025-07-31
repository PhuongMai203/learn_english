import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/main_navigation.dart';
import 'admin_pages/admin_navbar.dart';
import 'welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> _getUserRole(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        final role = snapshot.data()?['role'];
        debugPrint('Dữ liệu role lấy được: $role');
        return role;
      } else {
        debugPrint('Không tìm thấy document người dùng với UID: $uid');
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy role từ Firestore: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Đang kết nối Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Có lỗi
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Đã xảy ra lỗi. Vui lòng thử lại sau.')),
          );
        }

        // Đã đăng nhập
        if (snapshot.hasData) {
          final user = snapshot.data!;
          debugPrint('Đăng nhập với UID: ${user.uid}');

          return FutureBuilder<String?>(
            future: _getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('Không thể xác định vai trò.')),
                );
              }

              final role = roleSnapshot.data;
              debugPrint('Vai trò người dùng: $role');

              if (role == 'admin') {
                debugPrint('→ Điều hướng tới giao diện ADMIN');
                return const AdminNavbar();
              } else if (role == 'user') {
                debugPrint('→ Điều hướng tới giao diện USER');
                return const MainNavigation();
              } else {
                return const Scaffold(
                  body: Center(child: Text('Vai trò người dùng không hợp lệ.')),
                );
              }
            },
          );
        }

        // Chưa đăng nhập
        return const WelcomeScreen();
      },
    );
  }
}
