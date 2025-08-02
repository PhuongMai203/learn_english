import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../components/main_navigation.dart';

class SocialLoginButtons extends StatelessWidget {
  SocialLoginButtons({super.key});

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _showMsg(context, 'Đăng nhập đã bị hủy.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Lưu vào Firestore nếu chưa tồn tại
        final docRef = _firestore.collection('users').doc(user.uid);
        final snapshot = await docRef.get();

        if (!snapshot.exists) {
          await docRef.set({
            'uid': user.uid,
            'email': user.email,
            'username': user.displayName ?? 'Không tên',
            'photoURL': user.photoURL ?? '',
            'phone': user.phoneNumber ?? '',
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );

      }
    } catch (error) {
      _showMsg(context, 'Đã xảy ra lỗi: $error');
      print('Lỗi đăng nhập Google: $error');
    }
  }

  void _showMsg(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
              onPressed: () => _handleGoogleSignIn(context),
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
}
