import 'package:flutter/material.dart';

class SystemUpdateScreen extends StatelessWidget {
  const SystemUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const currentVersion = "1.0.0";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cập nhật hệ thống"),
        backgroundColor: const Color(0xFF5D8BF4),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.system_update_alt, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            Text("Phiên bản hiện tại: $currentVersion",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: kiểm tra cập nhật từ server
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Hệ thống đang ở phiên bản mới nhất")),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Kiểm tra cập nhật"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
