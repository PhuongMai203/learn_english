import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../components/app_background.dart';
import 'widgets/daily_lesson_card.dart';
import 'widgets/learning_path.dart';
import 'widgets/notifications_popu.dart';
import 'widgets/quick_access.dart';
import 'widgets/achievements_card.dart';
import 'widgets/daily_suggestion_card.dart';
import 'widgets/motivation_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iconKey = GlobalKey();
    final notificationsPopup =
    CourseNotificationsPopup(context: context, iconKey: iconKey);

    final user = FirebaseAuth.instance.currentUser;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Xin chào học viên 👋"),
          backgroundColor: Color(0xFF5AA0E3),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              key: iconKey,
              icon: const Icon(Icons.notifications),
              onPressed: () {
                notificationsPopup.toggle();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DailySuggestionCard(),
              const SizedBox(height: 16),
              const LearningPath(),
              const SizedBox(height: 16),
              QuickAccess(context: context),
              const SizedBox(height: 16),

              if (user != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final data =
                    snapshot.data!.data() as Map<String, dynamic>?;

                    if (data == null) {
                      return const Text("Chưa có dữ liệu thành tích");
                    }

                    final streak = data['streak'] ?? 0;
                    final totalDays = data['totalActiveDays'] ?? 0;

                    return AchievementsCard(
                      streak: streak,
                      totalDays: totalDays,
                    );
                  },
                )
              else
                const Text("Vui lòng đăng nhập để xem thành tích"),

              const SizedBox(height: 16),
              MotivationBanner(context: context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
