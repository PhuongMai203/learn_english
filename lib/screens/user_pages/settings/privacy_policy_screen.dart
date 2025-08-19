import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chính sách & Quyền riêng tư"),
        backgroundColor: const Color(0xFF5D8BF4),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Đây là nội dung chính sách quyền riêng tư của ứng dụng.\n\n"
              "Bạn có thể hiển thị nội dung đầy đủ ở đây, ví dụ:\n"
              "- Thu thập dữ liệu người dùng\n"
              "- Sử dụng dữ liệu cho mục đích học tập\n"
              "- Liên hệ hỗ trợ\n\n"
              "Người dùng cần đọc và đồng ý trước khi sử dụng ứng dụng.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
