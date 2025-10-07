import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../components/app_background.dart';

class AddLessonScreen extends StatefulWidget {
  const AddLessonScreen({super.key});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();

  String? selectedCourseId;
  List<Map<String, dynamic>> courses = [];

  File? _mediaFile;
  bool _isVideo = false;
  bool _useYoutube = false;

  // Tone xanh ngọc
  static const Color primaryColor = Color(0xFF4DB6AC); // xanh ngọc nhạt
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212529);
  static const Color lightGrey = Color(0xFFF0F5F5);

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();
    final courseList = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'title': doc['title'],
      };
    }).toList();

    setState(() {
      courses = courseList;
    });
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    final picker = ImagePicker();
    final pickedFile = await (isVideo
        ? picker.pickVideo(source: source)
        : picker.pickImage(source: source));

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = isVideo;
        _useYoutube = false;
        _youtubeUrlController.clear();
      });
    }
  }

  Future<void> _submitLesson() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCourseId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn khóa học")),
        );
        return;
      }

      String? mediaUrl;
      try {
        if (_mediaFile != null) {
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final ref = FirebaseStorage.instance.ref().child('lessons/$fileName');
          await ref.putFile(_mediaFile!);
          mediaUrl = await ref.getDownloadURL();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi upload media: $e")),
        );
        return;
      }

      final newLesson = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "content": _contentController.text.trim(),
        "createdAt": DateTime.now(),
        "mediaUrl": mediaUrl,
        "isVideo": _isVideo,
        "youtubeUrl": _useYoutube ? _youtubeUrlController.text.trim() : null,
      };

      try {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(selectedCourseId)
            .collection('lessons')
            .add(newLesson);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã thêm bài học thành công")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi lưu bài học: $e")),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: textColor.withOpacity(0.7),
        fontSize: 15,
      ),
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: lightGrey,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Thêm bài học mới",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          elevation: 2,
        ),
        body: courses.isEmpty
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Dropdown chọn khóa học
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 6),
                        child: Text("Khóa học",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedCourseId,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down,
                            size: 24, color: primaryColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          filled: true,
                          fillColor: lightGrey,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                        items: courses.map((course) {
                          return DropdownMenuItem<String>(
                            value: course['id'],
                            child: Text(course['title'],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedCourseId = value),
                        validator: (value) =>
                        value == null ? "Vui lòng chọn khóa học" : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Form nhập tiêu đề, mô tả, nội dung
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Thông tin bài học",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration("Tiêu đề bài học", Icons.title),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Vui lòng nhập tiêu đề" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration("Mô tả ngắn", Icons.description),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Vui lòng nhập mô tả" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 6,
                        decoration: _inputDecoration("Nội dung bài học", Icons.notes),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Vui lòng nhập nội dung" : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Media section
                const Text("Tùy chọn Media",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          _pickMedia(ImageSource.gallery, isVideo: false),
                      icon: const Icon(Icons.image),
                      label: const Text("Ảnh"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _pickMedia(ImageSource.gallery, isVideo: true),
                      icon: const Icon(Icons.videocam),
                      label: const Text("Video"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text(
                    "Sử dụng video YouTube",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: _useYoutube,
                  activeColor: Colors.white, // màu nút khi bật
                  activeTrackColor: Colors.black87, // màu track khi bật
                  inactiveThumbColor: Colors.grey[700], // nút khi tắt
                  inactiveTrackColor: Colors.grey[400], // track khi tắt
                  onChanged: (val) {
                    setState(() {
                      _useYoutube = val;
                      if (val) _mediaFile = null;
                    });
                  },
                ),

                if (_useYoutube)
                  TextFormField(
                    controller: _youtubeUrlController,
                    decoration: _inputDecoration("Link YouTube", Icons.link),
                    validator: (val) {
                      if (_useYoutube && (val == null || val.isEmpty)) {
                        return "Vui lòng nhập link YouTube";
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 16),

                /// Media preview
                if (_mediaFile != null)
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: _isVideo
                        ? const Icon(Icons.video_library, size: 100, color: Colors.grey)
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_mediaFile!, fit: BoxFit.cover),
                    ),
                  ),
                if (_useYoutube &&
                    _youtubeUrlController.text.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "YouTube: ${_youtubeUrlController.text.trim()}",
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                    ),
                  ),

                const SizedBox(height: 30),

                /// Nút lưu
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submitLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Lưu bài học",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
