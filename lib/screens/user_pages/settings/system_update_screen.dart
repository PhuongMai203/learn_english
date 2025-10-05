import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SystemUpdateScreen extends StatelessWidget {
  const SystemUpdateScreen({super.key});

  Future<PackageInfo> _getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    const pastelTeal = Color(0xFF62CFC2); // tone xanh ngọc pastel

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Cập nhật hệ thống"),
          backgroundColor: pastelTeal,
        ),
        body: FutureBuilder<PackageInfo>(
          future: _getPackageInfo(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final info = snapshot.data!;
            final version = info.version; // ví dụ: "1.0.3"
            final buildNumber = info.buildNumber; // ví dụ: "5"

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.system_update_alt,
                      size: 64, color: pastelTeal),
                  const SizedBox(height: 16),
                  Text(
                    "Phiên bản hiện tại: $version (build $buildNumber)",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Hệ thống đang ở phiên bản mới nhất"),
                          backgroundColor: pastelTeal,
                        ),
                      );
                    },
                    icon: Icon(Icons.refresh, color: Colors.black,),
                    label: Text("Kiểm tra cập nhật",
                      style: TextStyle(
                        color: Colors.black
                    )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastelTeal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
