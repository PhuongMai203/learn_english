import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';
import 'change_password_page.dart';

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

  Future<void> _editPhone(String currentPhone) async {
    final controller = TextEditingController(text: currentPhone);

    final newPhone = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cập nhật số điện thoại"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Số điện thoại mới",
            hintText: "Nhập số điện thoại...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D8BF4)),
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newPhone == null || newPhone.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({"phone": newPhone});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật số điện thoại thành công"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi cập nhật: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoURL = user?.photoURL;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Cài đặt tài khoản",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
            final phone = userData["phone"] ?? "Chưa cập nhật";

            return ListView(
              children: [
                const SizedBox(height: 12),

                _buildSectionTitle("Thông tin cá nhân"),
                ListTile(
                  leading: CircleAvatar(
                    radius: 32,
                    backgroundImage: photoURL != null
                        ? NetworkImage(photoURL)
                        : const AssetImage("assets/user_avatar.png")
                    as ImageProvider,
                  ),
                  title: Text(
                    _isUploading ? "Đang tải ảnh..." : "Đổi ảnh đại diện",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: _isUploading ? null : _pickAndUploadImage,
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.person,
                      color: Color(0xFF5D8BF4), size: 28),
                  title: const Text("Tên hiển thị",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  subtitle: Text(username,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.black87)),
                ),

                ListTile(
                  leading: const Icon(Icons.email,
                      color: Color(0xFF5D8BF4), size: 28),
                  title: const Text("Email",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  subtitle: Text(user?.email ?? "",
                      style: const TextStyle(
                          fontSize: 16, color: Colors.black87)),
                ),

                ListTile(
                  leading: const Icon(Icons.phone,
                      color: Color(0xFF5D8BF4), size: 28),
                  title: const Text("Số điện thoại",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  subtitle: Text(phone,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.black87)),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _editPhone(phone),
                ),

                const SizedBox(height: 20),
                _buildSectionTitle("Bảo mật"),
                ListTile(
                  leading: const Icon(Icons.lock,
                      color: Color(0xFF5D8BF4), size: 28),
                  title: const Text("Đổi mật khẩu",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage()),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _buildSectionTitle("Khác"),
                const SizedBox(height: 10),
                ListTile(
                  leading:
                  const Icon(Icons.logout, color: Colors.red, size: 28),
                  title: const Text(
                    "Đăng xuất",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),

                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.delete_forever,
                      color: Colors.redAccent, size: 28),
                  title: const Text(
                    "Xóa tài khoản",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: _deleteAccount,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa tài khoản"),
        content: const Text(
          "Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.",
        ),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child:
            const Text("Xóa", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).delete();

      final avatarRef =
      FirebaseStorage.instance.ref().child("user_avatars/${user.uid}.jpg");
      try {
        await avatarRef.delete();
      } catch (_) {}

      await user.delete();

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng đăng nhập lại để xóa tài khoản"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
