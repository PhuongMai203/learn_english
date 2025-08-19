import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:learn_english/components/app_background.dart';

class EditCourseScreen extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> courseData;

  const EditCourseScreen({
    super.key,
    required this.courseId,
    required this.courseData,
  });

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String selectedLevel = 'Cơ bản';
  String? imageUrl;
  Uint8List? webImage;
  File? imageFile;
  bool isLoading = false;

  String? selectedPromotionId;
  double finalPrice = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.courseData['title']);
    _descriptionController =
        TextEditingController(text: widget.courseData['description']);
    _priceController = TextEditingController(
        text: widget.courseData['price']?.toString() ?? "0");
    selectedLevel = widget.courseData['level'] ?? 'Cơ bản';
    imageUrl = widget.courseData['imageUrl'];
    _calculateFinalPrice();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => webImage = bytes);
      } else {
        setState(() => imageFile = File(pickedFile.path));
      }
    }
  }

  Future<String?> uploadImage() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('course_images/${widget.courseId}.jpg');
      if (kIsWeb && webImage != null) {
        await ref.putData(webImage!);
      } else if (imageFile != null) {
        await ref.putFile(imageFile!);
      } else {
        return imageUrl;
      }
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  Future<void> _calculateFinalPrice() async {
    final double basePrice = double.tryParse(_priceController.text) ?? 0;
    if (selectedPromotionId == null) {
      setState(() => finalPrice = basePrice);
      return;
    }

    final promoSnap = await FirebaseFirestore.instance
        .collection('promotions')
        .doc(selectedPromotionId)
        .get();

    if (!promoSnap.exists) {
      setState(() => finalPrice = basePrice);
      return;
    }

    final promoData = promoSnap.data()!;
    final String title = promoData['title'] ?? "";
    double discount = 0;

    if (title.contains("50%")) discount = 0.5;
    if (title.contains("30%")) discount = 0.3;
    if (title.contains("20%")) discount = 0.2;

    setState(() => finalPrice = basePrice * (1 - discount));
  }

  Future<void> updateCourse() async {
    setState(() => isLoading = true);

    final newImageUrl = await uploadImage();
    final courseRef =
    FirebaseFirestore.instance.collection('courses').doc(widget.courseId);

    await courseRef.update({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'level': selectedLevel,
      'imageUrl': newImageUrl ?? imageUrl,
      'price': double.tryParse(_priceController.text) ?? 0,
      'promotionId': selectedPromotionId,
      'finalPrice': finalPrice,
    });

    setState(() => isLoading = false);

    if (mounted) Navigator.pop(context);
  }

  InputDecoration _inputStyle(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: const Color(0xFF3A7BD5),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A7BD5), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Chỉnh sửa khóa học",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF3A7BD5),
          foregroundColor: Colors.white,
        ), // This parenthesis was in the wrong place.
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(16),
                  image: (webImage != null || imageFile != null || imageUrl != null)
                      ? DecorationImage(
                    image: webImage != null
                        ? MemoryImage(webImage!)
                        : imageFile != null
                        ? FileImage(imageFile!)
                        : NetworkImage(imageUrl!) as ImageProvider,
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: Stack(
                  children: [
                    if (webImage == null && imageFile == null && imageUrl == null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text("Chưa có ảnh bìa",
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: pickImage,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3A7BD5),
                        elevation: 2,
                        mini: true,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// Form nhập
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: _inputStyle("Tên khóa học"),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: _inputStyle("Mô tả khóa học"),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // Level Selection
                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedLevel,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Color(0xFF3A7BD5)),
                            items: <String>['Cơ bản', 'Trung bình', 'Nâng cao']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(fontSize: 16)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedLevel = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Price Input
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _inputStyle(
                          "Giá gốc",
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text("VNĐ",
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onChanged: (_) => _calculateFinalPrice(),
                      ),
                      const SizedBox(height: 20),

                      // Promotions Dropdown
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('promotions')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          }
                          final promotions = snapshot.data!.docs;
                          return DropdownButtonFormField<String>(
                            value: selectedPromotionId,
                            decoration: _inputStyle("Chọn khuyến mãi"),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text("Không có khuyến mãi",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              ...promotions.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return DropdownMenuItem<String>(
                                  value: doc.id,
                                  child: Text(
                                    data['title'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() => selectedPromotionId = value);
                              _calculateFinalPrice();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Final Price Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.price_check, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Giá cuối cùng",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      )),
                                  Text("${finalPrice.toStringAsFixed(0)} VNĐ",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Nút lưu
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF3A7BD5)),
                      ),
                      child: const Text(
                        "Hủy",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3A7BD5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : updateCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A7BD5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        "Lưu thay đổi",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}