import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_english/components/app_background.dart';
import 'widgets/account_header.dart';
import 'widgets/achievement_section.dart';
import 'widgets/settings_section.dart';
import 'widgets/logout_button.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email?.split('@').first ?? 'Người dùng';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            AccountHeader(user: user, username: username),
      
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    AchievementSection(),
                    SizedBox(height: 20),
                    SettingsSection(),
                    SizedBox(height: 20),
                    LogoutButton(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
