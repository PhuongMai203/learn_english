import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'auth/auth_tab_selector.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'auth/social_login_buttons.dart';
import 'auth_gate.dart';
import 'user_pages/welcome_screen.dart';


class AuthScreen extends StatefulWidget {
  final int initialTabIndex;
  const AuthScreen({super.key, required this.initialTabIndex});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetPassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quên mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập email để đặt lại mật khẩu:'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Vui lòng nhập email hợp lệ';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showSuccessSnackbar('Hướng dẫn đặt lại mật khẩu đã gửi đến email');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7B54),
              foregroundColor: Colors.white,
            ),
            child: const Text('Gửi'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F4FF), Color(0xFFFFF9EB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF5A6A9A)),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                        );
                      },
                    ),
                  ),
                  Image.asset('assets/logo.png', width: 80, height: 80),
                  const SizedBox(height: 20),

                  AuthTabSelector(controller: _tabController),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        LoginTab(
                          formKey: _loginFormKey,
                          onSubmit: (email, password) async {
                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(email: email, password: password);

                              if (userCredential.user != null) {
                                _showSuccessSnackbar('Đăng nhập thành công!');

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AuthGate()),
                                );

                              }
                            } catch (e) {
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.error(message: 'Đăng nhập thất bại: $e'),
                              );
                            }
                          },

                          onForgotPassword: _resetPassword,
                        ),
                        RegisterScreen(
                          formKey: _registerFormKey,
                          onSubmit: (n, e, p, pw, cpw) {},
                          onSuccess: () {
                            _tabController.animateTo(0);
                            _showSuccessSnackbar('Đăng ký thành công! Vui lòng kiểm tra email');
                          },
                        )
                      ],
                    ),
                  ),

                  SocialLoginButtons(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tabController.index == 0
                            ? 'Chưa có tài khoản? '
                            : 'Đã có tài khoản? ',
                        style: const TextStyle(color: Color(0xFF5A6A9A)),
                      ),
                      GestureDetector(
                        onTap: () => _tabController.animateTo(
                            _tabController.index == 0 ? 1 : 0),
                        child: Text(
                          _tabController.index == 0 ? 'Đăng ký ngay' : 'Đăng nhập ngay',
                          style: const TextStyle(
                            color: Color(0xFFFF7B54),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
