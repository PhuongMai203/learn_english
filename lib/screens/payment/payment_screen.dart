import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_english/components/app_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

class PaymentScreen extends StatefulWidget {
  final int price;
  final String courseId;
  final String courseTitle;

  const PaymentScreen({
    super.key,
    required this.price,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == 'helpconnectmomo') {
        // Thanh toán thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thanh toán thành công!"),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isLoading = false;
        });

        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return;

          final userId = user.uid;

          // Lấy thông tin khóa học từ collection "courses"
          final courseDoc = await FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .get();

          if (!courseDoc.exists || courseDoc.data() == null) return;

          final courseData = courseDoc.data()!;

          // Lưu vào /users/{userId}/enrollments/
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('enrollments')
              .doc(widget.courseId)
              .set({
            "courseId": widget.courseId,
            "title": courseData['title'] ?? "",
            "description": courseData['description'] ?? "",
            "imageUrl": courseData['imageUrl'] ?? "",
            "progress": 0,
            "startedAt": FieldValue.serverTimestamp(),
          });

          // Thông báo đã lưu khóa học
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Khóa học đã được thêm vào danh sách của bạn!"),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          debugPrint("Lỗi lưu enrollment: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lỗi lưu khóa học: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }, onError: (err) {
      debugPrint('Error handling incoming link: $err');
    });
  }

  Future<void> _createPayment() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bạn cần đăng nhập để thanh toán"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userId = user.uid;

      // Lấy username từ Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userName = (userDoc.exists && userDoc.data() != null)
          ? userDoc.data()!['username'] ?? "Người dùng"
          : "Người dùng";

      // Gọi backend Node.js để tạo thanh toán MoMo
      final response = await http.post(
        Uri.parse("https://794a5ad74453.ngrok-free.app/payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "userName": userName,
          "courseId": widget.courseId,
          "courseTitle": widget.courseTitle,
          "price": widget.price,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Lỗi server: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      if (data["payUrl"] == null) {
        throw Exception(data["message"] ?? "Không tạo được giao dịch");
      }

      final Uri payUri = Uri.parse(data["payUrl"]);

      // Mở MoMo app / trình duyệt bên ngoài
      if (!await launchUrl(
        payUri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception("Không thể mở liên kết thanh toán");
      }

      // Thành công tạo payment sẽ được nhận qua callback deep link
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi tạo thanh toán: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const momoPink = Color(0xFFD82D8B);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Thanh Toán',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD82D8B), Color(0xFFF48FB1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: Colors.pink.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Icon(Icons.payment, size: 60, color: momoPink),
                      const SizedBox(height: 20),
                      const Text(
                        'Số tiền cần thanh toán',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: momoPink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${widget.price} VND',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: momoPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: momoPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Xác Nhận Thanh Toán'),
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: momoPink),
                label: const Text(
                  'Quay lại',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: momoPink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
