import 'package:flutter/material.dart';
import '../components/app_background.dart';
import '../components/main_navigation.dart';
import 'AuthScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainNavigation()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF5A6A9A),
                      ),
                      child: const Text('Bỏ qua'),
                    ),
                  ],
                ),
      
                const SizedBox(height: 30),
      
                // Illustration
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF5BC0F8).withOpacity(0.2),
                              const Color(0xFFFFB84C).withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/learning_illustration.png',
                        width: 280,
                        height: 280,
                      ),
                    ],
                  ),
                ),
      
                const SizedBox(height: 20),
      
                // Tiêu đề
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: 'Tiếng Anh Thế hệ Mới\n',
                        style: TextStyle(color: Color(0xFF2A3A65)),
                      ),
                      TextSpan(
                        text: 'Cho Người Trưởng Thành',
                        style: TextStyle(
                          color: Color(0xFFFF7B54),
                        ),
                      ),
                    ],
                  ),
                ),
      
                const SizedBox(height: 16),
      
                // Mô tả
                const Text(
                  'Phương pháp học thông minh kết hợp công nghệ AI, thiết kế riêng cho người trưởng thành bận rộn',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5A6A9A),
                    height: 1.6,
                  ),
                ),
      
                const SizedBox(height: 40),
      
                // Các tính năng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeature(
                      icon: Icons.access_time_filled_rounded,
                      color: Color(0xFF5BC0F8),
                      text: '15 phút/ngày',
                    ),
                    _buildFeature(
                      icon: Icons.auto_awesome_rounded,
                      color: Color(0xFFFFB84C),
                      text: 'Cá nhân hóa',
                    ),
                    _buildFeature(
                      icon: Icons.graphic_eq_rounded,
                      color: Color(0xFFFF7B54),
                      text: 'AI phân tích',
                    ),
                    _buildFeature(
                      icon: Icons.work_rounded,
                      color: Color(0xFF86A7FC),
                      text: 'Chuyên nghiệp',
                    ),
                  ],
                ),
      
                const Spacer(),
      
                // Nút bắt đầu
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthScreen(initialTabIndex: 0)),
                        );
                      },
      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB84C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFFFFB84C).withOpacity(0.4),
                      ),
                      child: const Text(
                        'Bắt đầu hành trình',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
