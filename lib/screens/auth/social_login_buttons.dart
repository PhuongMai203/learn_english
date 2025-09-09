import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../components/main_navigation.dart';

class SocialLoginButtons extends StatelessWidget {
  SocialLoginButtons({super.key});

  // You must provide the web client ID for the web platform.
  // Replace 'YOUR_WEB_CLIENT_ID' with your actual client ID.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // Add the web client ID here.
    clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
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

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
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
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              'Hoặc tiếp tục với',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 4), // Giảm khoảng cách top
        Center(
          child: _buildSocialButton(
            context,
            icon: 'assets/google_logo.png',
            label: 'Google',
            onPressed: () => _handleGoogleSignIn(context),
          ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}