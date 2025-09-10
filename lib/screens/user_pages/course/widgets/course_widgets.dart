import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseHeader extends StatelessWidget {
  const CourseHeader({super.key});

  Future<String?> _getUserPhotoURL() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        return snapshot.data()?['photoURL'] as String?;
      }
    } catch (e) {
      debugPrint("Lỗi lấy avatar: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          FutureBuilder<String?>(
            future: _getUserPhotoURL(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.deepPurple[100],
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.deepPurple,
                  ),
                );
              }

              final photoURL = snapshot.data;
              return CircleAvatar(
                radius: 25,
                backgroundImage: photoURL != null && photoURL.isNotEmpty
                    ? NetworkImage(photoURL)
                    : const AssetImage("assets/user_avatar.png")
                as ImageProvider,
              );
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chào buổi học viên",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hãy tiếp tục hành trình học tập của bạn",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
