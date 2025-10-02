import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/app_background.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  int userCount = 0;
  int courseCount = 0;
  int testCount = 0;
  int paymentCount = 0; // thêm biến đếm người đăng ký khóa học nâng cao
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Đếm users (trừ 1, ví dụ loại bỏ admin)
      final userSnap = await firestore.collection('users').get();
      final users = userSnap.size > 0 ? userSnap.size - 1 : 0;

      // Đếm courses
      final courseSnap = await firestore.collection('courses').get();
      final courses = courseSnap.size;

      // Đếm tests
      final testSnap = await firestore.collection('tests').get();
      final tests = testSnap.size;

      // Đếm payments (người đăng ký khóa học nâng cao)
      final paymentSnap = await firestore.collection('payments').get();
      final payments = paymentSnap.size;

      setState(() {
        userCount = users;
        courseCount = courses;
        testCount = tests;
        paymentCount = payments;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu thống kê: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Báo cáo & Thống kê',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF5D8BF4),
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard('Tổng số học viên', '$userCount người'),
            _buildStatCard('Tổng số khóa học', '$courseCount khóa'),
            _buildStatCard('Tổng số bài kiểm tra', '$testCount bài'),
            _buildStatCard('Số người đăng ký khóa học nâng cao', '$paymentCount người'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing:
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
