import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

import 'logout_button.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(picked.path);

      final storageRef =
      FirebaseStorage.instance.ref().child("user_avatars/${user!.uid}.jpg");
      await storageRef.putFile(file);

      final downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({"photoURL": downloadURL});

      await user!.updatePhotoURL(downloadURL);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật ảnh đại diện thành công")),
      );

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoURL = user?.photoURL;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Cài đặt tài khoản"),
          backgroundColor: const Color(0xFF5D8BF4),
          foregroundColor: Colors.white,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Không tìm thấy dữ liệu người dùng"));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData["username"] ?? "Chưa có tên";

            return ListView(
              children: [
                const SizedBox(height: 10),

                _buildSectionTitle("Thông tin cá nhân"),
                ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: photoURL != null
                        ? NetworkImage(photoURL)
                        : const AssetImage("assets/user_avatar.png")
                    as ImageProvider,
                  ),
                  title: Text(_isUploading ? "Đang tải ảnh..." : "Đổi ảnh đại diện"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _isUploading ? null : _pickAndUploadImage,
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Tên hiển thị"),
                  subtitle: Text(username),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(user?.email ?? ""),
                  onTap: () {},
                ),

                const SizedBox(height: 20),
                _buildSectionTitle("Bảo mật"),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Đổi mật khẩu"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),

                const SizedBox(height: 20),
                _buildSectionTitle("Tùy chọn"),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text("Chế độ tối"),
                  value: false,
                  onChanged: (val) {},
                ),

                const SizedBox(height: 20),
                _buildSectionTitle("Khác"),
                const LogoutButton(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text("Xóa tài khoản",
                      style: TextStyle(color: Colors.red)),
                  onTap: () {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}
