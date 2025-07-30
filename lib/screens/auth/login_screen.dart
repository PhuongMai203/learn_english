import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/app_text_styles.dart';
import '../pages/home_screen.dart';

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
            style: AppTextStyles.inputText,
            decoration: AppTextStyles.inputDecoration(
              label: 'Mật khẩu',
              hint: 'Nhập mật khẩu',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
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

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(color: Color(0xFFFF7B54)),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (widget.formKey.currentState!.validate()) {
                  widget.formKey.currentState!.save();
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