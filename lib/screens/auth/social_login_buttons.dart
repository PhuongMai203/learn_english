import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hoặc tiếp tục với',
              style: TextStyle(
                  color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              context,
              icon: 'assets/google_logo.png',
              label: 'Google',
              onPressed: () => _showMsg(context, 'Đang đăng nhập bằng Google'),
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              context,
              icon: 'assets/facebook.png',
              label: 'Facebook',
              onPressed: () => _showMsg(context, 'Đang đăng nhập bằng Facebook'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(BuildContext context,
      {required String icon,
        required String label,
        required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showMsg(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
