import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int userCount = 0;
  int courseCount = 0;
  int lessonCount = 0;
  int completionPercent = 5; // giữ tạm, hoặc bạn có thể thay đổi sau

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Đếm users
      final userSnap = await firestore.collection('users').get();
      final users = userSnap.size;

      // Đếm courses
      final courseSnap = await firestore.collection('courses').get();
      final courses = courseSnap.size;

      // Đếm tất cả lessons (gộp của mọi khóa học)
      int lessonsTotal = 0;
      for (var courseDoc in courseSnap.docs) {
        final lessonsSnap = await courseDoc.reference.collection('lessons').get();
        lessonsTotal += lessonsSnap.size;
      }

      setState(() {
        userCount = users;
        courseCount = courses;
        lessonCount = lessonsTotal;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi fetch dữ liệu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = [
      _StatData('Người dùng', userCount),
      _StatData('Khóa học', courseCount),
      _StatData('Bài học', lessonCount),
      _StatData('Hoàn thành (%)', completionPercent),
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Phân tích',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.red),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: item.value.toDouble(),
                            color: Colors.red,
                            width: 18,
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < data.length) {
                              return Text(
                                data[value.toInt()].label,
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: data.map((item) {
                  return Container(
                    width: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.label,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(item.value.toString(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatData {
  final String label;
  final int value;
  _StatData(this.label, this.value);
}
