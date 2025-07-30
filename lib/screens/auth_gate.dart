import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/main_navigation.dart';
import 'welcome_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // lắng nghe login/logout
      builder: (context, snapshot) {
        // Đang kết nối Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Lỗi kết nối
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Đã xảy ra lỗi. Vui lòng thử lại sau.')),
          );
        }

        // Đã đăng nhập
        if (snapshot.hasData) {
          return const MainNavigation();
        }

        // Chưa đăng nhập
        return const WelcomeScreen();
      },
    );
  }
}
