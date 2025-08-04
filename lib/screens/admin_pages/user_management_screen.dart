import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'widgets/user_card.dart';
import 'widgets/user_controller.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String filter = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      users = await UserController.fetchUsersFromFirestore();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lỗi khi tải dữ liệu người dùng.'),
      ));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _deleteUser(int index) {
    final user = users[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue.shade50,
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa tài khoản này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await UserController.deleteUser(user['docId']);
              _loadUsers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Xóa', style: TextStyle(
              color: Colors.white
            ),),

          ),
        ],
      ),
    );
  }

  void _showUserDialog({Map<String, dynamic>? user, int? index}) {
    final usernameController = TextEditingController(text: user?['username'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final roleController = TextEditingController(text: user?['role'] ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user == null ? 'Thêm người dùng' : 'Chỉnh sửa người dùng',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: 'Vai trò',
                  prefixIcon: const Icon(Icons.work, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final username = usernameController.text.trim();
                      final email = emailController.text.trim();
                      final role = roleController.text.trim();

                      if (username.isEmpty || email.isEmpty || role.isEmpty) return;

                      Navigator.pop(context);

                      final Map<String, dynamic> userData = {
                        'username': username,
                        'email': email,
                        'role': role,
                        'photoURL': '',
                      };

                      if (user == null) {
                        userData['createdAt'] = FieldValue.serverTimestamp();
                        await UserController.addUser(userData);
                      } else {
                        await UserController.updateUser(user['docId'], userData);
                      }

                      _loadUsers();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((u) {
      final search = filter.toLowerCase();
      return (u['username'] ?? '').toLowerCase().contains(search) ||
          (u['email'] ?? '').toLowerCase().contains(search) ||
          (u['role'] ?? '').toLowerCase().contains(search);
    }).toList();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Quản lý người dùng',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
            IconButton(icon: const Icon(Icons.add), onPressed: () => _showUserDialog()),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: (v) => setState(() => filter = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                  hintText: 'Tìm kiếm người dùng...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredUsers.length,
                itemBuilder: (_, i) => UserCard(
                  user: filteredUsers[i],
                  onEdit: () => _showUserDialog(user: filteredUsers[i], index: i),
                  onDelete: () => _deleteUser(users.indexOf(filteredUsers[i])),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showUserDialog(),
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
