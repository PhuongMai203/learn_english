import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../components/app_background.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_stat_card.dart';
import 'widgets/admin_dashboard_grid.dart';
import 'widgets/recent_activities.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color mintGreen = Color(0xFF7DD1C6);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Quản trị hệ thống',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F978B),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminHeader(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              const AdminDashboardGrid(),
              const SizedBox(height: 24),
              const RecentActivities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('users').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AdminStatCard(
                    icon: Iconsax.people,
                    title: 'Người dùng',
                    value: '...',
                    color: Colors.blue);
              }
              if (snapshot.hasError) {
                return const AdminStatCard(
                    icon: Iconsax.people,
                    title: 'Người dùng',
                    value: 'Lỗi',
                    color: Colors.red);
              }
              final count = snapshot.data?.docs.length ?? 0;
              return AdminStatCard(
                  icon: Iconsax.people,
                  title: 'Người dùng',
                  value: '$count',
                  color: Colors.blue);
            },
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('courses').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AdminStatCard(
                    icon: Iconsax.book,
                    title: 'Khóa học',
                    value: '...',
                    color: Colors.green);
              }
              if (snapshot.hasError) {
                return const AdminStatCard(
                    icon: Iconsax.book,
                    title: 'Khóa học',
                    value: 'Lỗi',
                    color: Colors.red);
              }
              final count = snapshot.data?.docs.length ?? 0;
              return AdminStatCard(
                  icon: Iconsax.book,
                  title: 'Khóa học',
                  value: '$count',
                  color: Colors.green);
            },
          ),
         
        ],
      ),
    );
  }
}
