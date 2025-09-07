import 'package:flutter/material.dart';

class WordScrambleHeader extends StatelessWidget {
  final int score;
  final int level;
  final int timeLeft;

  const WordScrambleHeader({
    super.key,
    required this.score,
    required this.level,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfo("Cấp độ", "$level"),
          _buildInfo("Điểm", "$score"),
          _buildInfo("Thời gian",
              "$timeLeft", color: timeLeft > 10 ? const Color(0xFF66BB6A) : const Color(0xFFEF5350)),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value, {Color color = const Color(0xFF66BB6A)}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
