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
  int paymentCount = 0;
  double totalRevenue = 0; // ✅ Thêm biến tổng thu nhập
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final userSnap = await firestore.collection('users').get();
      final users = userSnap.size > 0 ? userSnap.size - 1 : 0;

      final courseSnap = await firestore.collection('courses').get();
      final courses = courseSnap.size;

      final testSnap = await firestore.collection('tests').get();
      final tests = testSnap.size;

      final paymentSnap = await firestore.collection('payments').get();
      final payments = paymentSnap.size;

      double total = 0;
      for (var doc in paymentSnap.docs) {
        final data = doc.data();

        // In log để kiểm tra giá trị thực tế
        print("📄 Dữ liệu payment: ${data}");

        final dynamic rawPrice = data['price'];
        if (rawPrice == null) continue;

        // Dù là int, double hay string đều convert được
        final double value = double.tryParse(rawPrice.toString()) ?? 0;
        total += value;
      }


      setState(() {
        userCount = users;
        courseCount = courses;
        testCount = tests;
        paymentCount = payments;
        totalRevenue = total;
        isLoading = false;
      });
    } catch (e) {
      print(" Lỗi khi lấy dữ liệu thống kê: $e");
      setState(() => isLoading = false);
    }
  }

  String _formatCurrency(double value) {

    return "${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")} đ";
  }

  @override
  Widget build(BuildContext context) {
    const pastelMint = Color(0xFF9CEAEF); // xanh ngọc pastel
    const pastelTeal = Color(0xFF62CFC2);

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
          backgroundColor: pastelTeal,
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
            _buildStatCard(
              'Tổng thu nhập',
              _formatCurrency(totalRevenue),
              icon: Icons.monetization_on,
              color: pastelMint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value,
      {IconData icon = Icons.bar_chart, Color color = const Color(0xFF9CEAEF)}) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.3),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
