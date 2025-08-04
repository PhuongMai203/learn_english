import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

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
  String selectedLevel = 'Cơ bản';
  String? imageUrl;
  Uint8List? webImage;
  File? imageFile;
  bool isLoading = false;

  final List<String> levels = ['Cơ bản', 'Trung cấp', 'Nâng cao'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.courseData['title']);
    _descriptionController = TextEditingController(text: widget.courseData['description']);
    selectedLevel = widget.courseData['level'] ?? 'Cơ bản';
    imageUrl = widget.courseData['imageUrl'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          webImage = bytes;
        });
      } else {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> uploadImage() async {
    try {
      final ref = FirebaseStorage.instance.ref().child('course_images/${widget.courseId}.jpg');
      if (kIsWeb && webImage != null) {
        await ref.putData(webImage!);
      } else if (imageFile != null) {
        await ref.putFile(imageFile!);
      } else {
        return imageUrl; // Không thay đổi ảnh
      }
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> updateCourse() async {
    setState(() {
      isLoading = true;
    });

    final newImageUrl = await uploadImage();
    final courseRef = FirebaseFirestore.instance.collection('courses').doc(widget.courseId);

    await courseRef.update({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'level': selectedLevel,
      'imageUrl': newImageUrl ?? imageUrl,
    });

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Chỉnh sửa khóa học', style: TextStyle(color: Colors.deepPurple),),
          backgroundColor: Colors.white, // Xanh pastel
          foregroundColor: Colors.deepPurple,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (imageUrl != null || webImage != null || imageFile != null)
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: webImage != null
                          ? MemoryImage(webImage!)
                          : imageFile != null
                          ? FileImage(imageFile!)
                          : NetworkImage(imageUrl!) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF195C78), // Cam pastel
                ),
                child: Text('Chọn ảnh mới', style:TextStyle(
                  color: Colors.white
                ),),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên khóa học',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFFFFFFF), // xanh nhạt pastel
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mô tả khóa học',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white, // vàng pastel
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Trình độ',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor:Colors.white, // tím nhạt pastel
                ),
                items: levels
                    .map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(level),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedLevel = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF134F67), // Xanh dương pastel
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cập nhật', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
