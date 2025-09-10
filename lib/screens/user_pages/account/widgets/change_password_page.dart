import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_english/components/app_background.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Lưu lỗi cho từng ô
  final Map<String, String?> _errors = {
    "current": null,
    "new": null,
    "confirm": null,
  };

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showMessage("Không tìm thấy người dùng", success: false);
      return;
    }

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // ✅ Reset lỗi
    setState(() {
      _errors["current"] = null;
      _errors["new"] = null;
      _errors["confirm"] = null;
    });

    // ✅ Kiểm tra ràng buộc
    if (currentPassword.isEmpty) {
      setState(() => _errors["current"] = "Vui lòng nhập mật khẩu hiện tại");
      return;
    }
    if (newPassword.isEmpty) {
      setState(() => _errors["new"] = "Vui lòng nhập mật khẩu mới");
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _errors["new"] = "Mật khẩu mới phải có ít nhất 6 ký tự");
      return;
    }
    if (confirmPassword.isEmpty) {
      setState(() => _errors["confirm"] = "Vui lòng xác nhận mật khẩu mới");
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _errors["confirm"] = "Mật khẩu xác nhận không khớp");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Xác thực lại bằng mật khẩu cũ
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      _showMessage("Đổi mật khẩu thành công", success: true);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password" || e.code == "invalid-credential") {
        setState(() => _errors["current"] = "Mật khẩu hiện tại không đúng");
      } else if (e.code == "weak-password") {
        setState(() => _errors["new"] = "Mật khẩu mới quá yếu");
      } else if (e.code == "requires-recent-login") {
        _showMessage("Vui lòng đăng nhập lại để đổi mật khẩu", success: false);
      } else {
        _showMessage("Lỗi không xác định: ${e.message}", success: false);
      }
    } catch (e) {
      _showMessage("Lỗi: $e", success: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required Function() toggle,
    required String fieldKey,
  }) {
    final hasError = _errors[fieldKey] != null;
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        errorText: _errors[fieldKey],
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.blue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Đổi mật khẩu"),
          backgroundColor: const Color(0xFF678ECD),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Cập nhật mật khẩu",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF284A7C),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: "Mật khẩu hiện tại",
                      obscure: _obscureCurrent,
                      toggle: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                      fieldKey: "current",
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: "Mật khẩu mới (tối thiểu 6 ký tự)",
                      obscure: _obscureNew,
                      toggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      fieldKey: "new",
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: "Xác nhận mật khẩu mới",
                      obscure: _obscureConfirm,
                      toggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      fieldKey: "confirm",
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF436597),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Đổi mật khẩu",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
