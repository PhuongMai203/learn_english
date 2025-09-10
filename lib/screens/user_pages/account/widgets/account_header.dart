import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountHeader extends StatelessWidget {
  final User? user;
  final String username;

  const AccountHeader({
    super.key,
    required this.user,
    required this.username,
  });

  Future<Map<String, int>> _fetchStats(String uid) async {
    final firestore = FirebaseFirestore.instance;

    // Đếm số từ trong dictionary
    final dictionaryCount = await firestore
        .collection('users')
        .doc(uid)
        .collection('dictionary')
        .get()
        .then((snap) => snap.size);

    // Đếm số ngày học (mỗi document trong dailySuggestion là 1 ngày)
    final dailyCount = await firestore
        .collection('users')
        .doc(uid)
        .collection('dailySuggestion')
        .get()
        .then((snap) => snap.size);

    // Đếm số khóa học đã ghi danh
    final enrollmentsCount = await firestore
        .collection('users')
        .doc(uid)
        .collection('enrollments')
        .get()
        .then((snap) => snap.size);

    return {
      'dictionary': dictionaryCount,
      'daily': dailyCount,
      'enrollments': enrollmentsCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final uid = user?.uid;

    return SliverAppBar(
      expandedHeight: 300,
      backgroundColor: const Color(0xFFF7F9FC),
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5D8BF4), Color(0xFF86A3E3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 70, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + Tên
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const CircleAvatar(
                              radius: 36,
                              backgroundImage: AssetImage("assets/images/user_avatar.png"),
                            );
                          }

                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          final photoURL = data["photoURL"] as String?;

                          return CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            backgroundImage: photoURL != null && photoURL.isNotEmpty
                                ? NetworkImage(photoURL)
                                : const AssetImage("assets/images/user_avatar.png")
                            as ImageProvider,
                          );
                        },
                      ),

                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user?.email ?? 'Chưa có email',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Stats (FutureBuilder để lấy dữ liệu Firebase)
                  FutureBuilder<Map<String, int>>(
                    future: _fetchStats(uid!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }
                      final stats = snapshot.data!;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                                icon: Icons.menu_book_rounded,
                                value: stats['dictionary'].toString(),
                                label: 'Từ vựng'),
                            _StatItem(
                                icon: Icons.calendar_month_rounded,
                                value: stats['daily'].toString(),
                                label: 'Ngày học'),
                            _StatItem(
                                icon: Icons.star_rounded,
                                value: stats['enrollments'].toString(),
                                label: 'Khóa học'),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
          ),
          child: Icon(icon, size: 28, color: const Color(0xFFFFA800)),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
