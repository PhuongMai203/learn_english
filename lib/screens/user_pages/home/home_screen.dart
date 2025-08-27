import 'package:flutter/material.dart';
import 'package:learn_english/screens/user_pages/home/widgets/grammar_screen.dart';
import 'package:learn_english/screens/user_pages/home/widgets/vocabulary_screen.dart';
import '../../../components/app_background.dart';
import 'widgets/exercise_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Xin chào học viên 👋"),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDailyLessonCard(),
              const SizedBox(height: 16),
              _buildLearningPath(),
              const SizedBox(height: 16),
              _buildQuickAccess(context),
              const SizedBox(height: 16),
              _buildNotifications(),
              const SizedBox(height: 16),
              _buildAchievements(),
              const SizedBox(height: 16),
              _buildDailySuggestion(),
              const SizedBox(height: 16),
              _buildMotivationBanner(context),
              const SizedBox(height: 16),
              _buildStatsAndNotifications(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyLessonCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.family_restroom, color: Colors.orange, size: 30),
        ),
        title: const Text("Bài học hôm nay", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Học 10 từ vựng về chủ đề Gia đình"),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: () {},
      ),
    );
  }

  Widget _buildLearningPath() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lộ trình học", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple].map((c) => c.withOpacity(0.1)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_mosaic, size: 30, color: Colors.deepPurple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bước 3: Ngữ pháp cơ bản",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.6,
                            backgroundColor: Colors.grey[300],
                            color: Colors.deepPurple,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("60%", style: TextStyle(color: Colors.deepPurple)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text("Hoàn thành 12/20 bài", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Tiếp tục"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Truy cập nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _QuickAccessIcon(
              icon: Icons.school,
              label: 'Từ vựng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VocabularyScreen()),
                );
              },
            ),
            _QuickAccessIcon(
              icon: Icons.menu_book,
              label: 'Ngữ pháp',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GrammarScreen()),
                );
              },
            ),
            _QuickAccessIcon(
              icon: Icons.assignment,
              label: 'Bài tập',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExerciseScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotifications() {
    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_active, color: Colors.blue),
        ),
        title: const Text("Thông báo", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Bạn có 2 bài tập chưa hoàn thành"),
        trailing: Chip(
          label: const Text("2 mới", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildAchievements() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events, color: Colors.green, size: 30),
        ),
        title: const Text("Thành tích", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chuỗi học: 5 ngày liên tiếp 🎯"),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 5 / 7,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 4),
            const Text("Tiến độ: 5/7 ngày", style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: () {},
      ),
    );
  }

  Widget _buildDailySuggestion() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lightbulb, color: Colors.amber, size: 30),
        ),
        title: const Text("Gợi ý hôm nay", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Thực hành nói với chủ đề: Du lịch 🌍"),
      ),
    );
  }

  Widget _buildMotivationBanner(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Lời động viên 💪"),
            content: const Text(
                "Hãy cùng cố gắng học tập mỗi ngày bạn nhé! Mỗi bước nhỏ đều đưa bạn đến gần hơn với mục tiêu thành thạo tiếng Anh."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Đóng"),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '"Mỗi ngày học một ít – Một ngày sẽ giỏi!" 💪',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsAndNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thống kê hôm nay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.timer, "15 phút", "Học tập"),
            _buildStatItem(Icons.library_books, "8/10", "Từ mới"),
            _buildStatItem(Icons.star, "3", "Huy hiệu"),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              )),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickAccessIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
