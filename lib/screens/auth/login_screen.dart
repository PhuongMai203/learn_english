import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/app_text_styles.dart';
import '../user_pages/home_screen.dart';

class LoginTab extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(String email, String password) onSubmit;
  final VoidCallback onForgotPassword;

  const LoginTab({
    super.key,
    required this.formKey,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _rememberMe = true; // Mặc định là true

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    // Sửa thành true cho trường hợp chưa có giá trị
    final rememberMe = prefs.getBool('remember_me') ?? true;

    setState(() {
      _email = savedEmail;
      _password = savedPassword;
      _rememberMe = rememberMe;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _email);
      await prefs.setString('saved_password', _password);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }
    await prefs.setBool('remember_me', _rememberMe);
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.inputLabel,
      hintText: hintText,
      hintStyle: AppTextStyles.inputHint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _email,
            style: AppTextStyles.inputText,
            decoration: buildInputDecoration(
              label: 'Email',
              icon: Icons.email,
              hintText: 'example@gmail.com',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              final emailRegex = RegExp(
                r'^[\w-\.]+@gmail\.com$',
                caseSensitive: false,
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Email phải là địa chỉ @gmail.com';
              }
              return null;
            },
            onSaved: (value) => _email = value?.trim().toLowerCase() ?? '',
          ),

          const SizedBox(height: 16),

          TextFormField(
            initialValue: _password,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              labelStyle: AppTextStyles.inputLabel,
              hintText: 'Nhập mật khẩu',
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
            onSaved: (value) => _password = value ?? '',
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                // MÀU XANH DƯƠNG TÍM ĐẬM KHI CHỌN
                activeColor: const Color(0xFF42019C),
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? true;
                  });
                },
              ),
              const Text('Ghi nhớ mật khẩu'),
              const Spacer(),
              TextButton(
                onPressed: widget.onForgotPassword,
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(color: Color(0xFFFF7B54)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (widget.formKey.currentState!.validate()) {
                  widget.formKey.currentState!.save();
                  _saveCredentials();
                  widget.onSubmit(_email, _password);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7B54),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: const Color(0xFFFF7B54).withOpacity(0.3),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}