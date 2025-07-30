import 'package:flutter/material.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Luyện tập'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Các hoạt động luyện tập',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chọn phương pháp luyện tập phù hợp với bạn',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5F6368),
            ),
          ),
          const SizedBox(height: 24),

          // Grid các hoạt động luyện tập
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _buildPracticeCard(
                context,
                title: 'Flashcards',
                subtitle: 'Học từ vựng qua thẻ ghi nhớ',
                icon: Icons.style,
                backgroundColor: const Color(0xFFFFF8E1),
                iconColor: const Color(0xFFFFA000),
                borderColor: const Color(0xFFFFE082),
              ),
              _buildPracticeCard(
                context,
                title: 'Mini Game',
                subtitle: 'Chơi game luyện từ vựng, ngữ pháp',
                icon: Icons.videogame_asset,
                backgroundColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF43A047),
                borderColor: const Color(0xFFA5D6A7),
              ),
              _buildPracticeCard(
                context,
                title: 'Luyện nghe',
                subtitle: 'Nghe hội thoại và hoàn thành câu',
                icon: Icons.headphones,
                backgroundColor: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF1976D2),
                borderColor: const Color(0xFF90CAF9),
              ),
              _buildPracticeCard(
                context,
                title: 'Luyện nói',
                subtitle: 'Phát âm theo mẫu và kiểm tra',
                icon: Icons.mic,
                backgroundColor: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFEF6C00),
                borderColor: const Color(0xFFFFCC80),
              ),
              _buildPracticeCard(
                context,
                title: 'Luyện viết',
                subtitle: 'Viết lại câu đúng ngữ pháp',
                icon: Icons.edit_note,
                backgroundColor: const Color(0xFFF5F5F5),
                iconColor: const Color(0xFF757575),
                borderColor: const Color(0xFFE0E0E0),
              ),
              _buildPracticeCard(
                context,
                title: 'Bài kiểm tra',
                subtitle: 'Kiểm tra trình độ định kỳ',
                icon: Icons.assignment_turned_in,
                backgroundColor: const Color(0xFFE1BEE7),
                iconColor: const Color(0xFF7B1FA2),
                borderColor: const Color(0xFFCE93D8),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Thống kê luyện tập
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thống kê luyện tập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.timer, "25 phút", "Hôm nay", const Color(0xFFFFA000)),
                    _buildStatItem(Icons.calendar_today, "6 ngày", "Liên tiếp", const Color(0xFF1976D2)),
                    _buildStatItem(Icons.emoji_events, "12", "Huy hiệu", const Color(0xFF43A047)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Nút hành động chính
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill),
            label: const Text('BẮT ĐẦU LUYỆN TẬP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA000),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: const Color(0xFFFFA000).withOpacity(0.3),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            onPressed: () {
              // TODO: Navigate to today's practice routine
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color backgroundColor,
        required Color iconColor,
        required Color borderColor,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to practice type screen
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5F6368),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF5F6368),
          ),
        ),
      ],
    );
  }
}
