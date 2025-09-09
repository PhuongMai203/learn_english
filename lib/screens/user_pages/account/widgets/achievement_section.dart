import 'package:flutter/material.dart';

class AchievementSection extends StatelessWidget {
  const AchievementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thành tích của bạn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D8BF4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _AchievementItem(Icons.star, 'Học siêng năng', Color(0xFACD9C22)),
              _AchievementItem(Icons.bolt, 'Tốc độ', Color(0xFFFF9F29)),
              _AchievementItem(Icons.auto_awesome, 'Phát âm', Color(0xFF5D8BF4)),
            ],
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            value: 0.65,
            backgroundColor: Color(0xFFE9ECEF),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9F29)),
            minHeight: 12,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Tiến độ học tập',
                  style: TextStyle(
                      color: Color(0xFF6C757D),
                      fontWeight: FontWeight.w500)),
              Text('65%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF5D8BF4))),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _AchievementItem(this.icon, this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
