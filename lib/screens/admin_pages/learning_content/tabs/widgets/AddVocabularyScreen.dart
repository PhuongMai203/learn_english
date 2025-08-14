import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../components/app_background.dart';

class AddVocabularyScreen extends StatefulWidget {
  const AddVocabularyScreen({super.key});

  @override
  State<AddVocabularyScreen> createState() => _AddVocabularyScreenState();
}

class _AddVocabularyScreenState extends State<AddVocabularyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _meaningController = TextEditingController();

  String? _selectedType;
  String? _selectedCourseId;
  String? _selectedLessonId;

  List<String> _wordTypes = [
    'Danh từ (N)',
    'Động từ (V)',
    'Tính từ (Adj)',
    'Trạng từ (Adv)',
    'Giới từ (Prep)',
    'Liên từ (Conj)',
    'Đại từ (Pron)',
    'Mạo từ (Art)',
  ];

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('courses').get();
      setState(() {
        _courses = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      debugPrint('Lỗi khi lấy khóa học: $e');
    }
  }

  Future<void> _fetchLessons(String courseId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .get();

      setState(() {
        _lessons = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      debugPrint('Lỗi khi lấy bài học: $e');
    }
  }

  Future<void> _saveVocabulary() async {
    if (_selectedCourseId == null || _selectedLessonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn khóa học và bài học'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('vocabulary').add({
        'word': _wordController.text.trim(),
        'pronunciation': _pronunciationController.text.trim(),
        'meaning': _meaningController.text.trim(),
        'type': _selectedType,
        'courseId': _selectedCourseId,
        'lessonId': _selectedLessonId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu từ vựng'),
          backgroundColor: Colors.green,
        ),
      );

      _wordController.clear();
      _pronunciationController.clear();
      _meaningController.clear();
      setState(() {
        _selectedType = null;
        _selectedCourseId = null;
        _selectedLessonId = null;
        _lessons = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Thêm từ mới'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // TỪ VỰNG
                TextFormField(
                  controller: _wordController,
                  decoration: InputDecoration(
                    labelText: 'Từ vựng',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập từ vựng' : null,
                ),
                const SizedBox(height: 16),

                // PHIÊN ÂM
                TextFormField(
                  controller: _pronunciationController,
                  decoration: InputDecoration(
                    labelText: 'Phiên âm (VD: /ˈæp.əl/)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập phiên âm' : null,
                ),
                const SizedBox(height: 16),

                // NGHĨA
                TextFormField(
                  controller: _meaningController,
                  decoration: InputDecoration(
                    labelText: 'Nghĩa',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập nghĩa' : null,
                ),
                const SizedBox(height: 16),

                // PHÂN LOẠI TỪ
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Phân loại từ',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _wordTypes
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Vui lòng chọn phân loại từ' : null,
                ),
                const SizedBox(height: 16),

                // CHỌN KHÓA HỌC
                DropdownButtonFormField<String>(
                  value: _selectedCourseId,
                  decoration: InputDecoration(
                    labelText: 'Chọn khóa học',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _courses
                      .map((course) => DropdownMenuItem<String>(
                    value: course['id'] as String, // ép kiểu String
                    child: Text(course['title'] ?? 'No title'),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseId = value;
                      _selectedLessonId = null;
                      _lessons = [];
                    });
                    if (value != null) {
                      _fetchLessons(value);
                    }
                  },
                  validator: (value) =>
                  value == null ? 'Vui lòng chọn khóa học' : null,
                ),
                const SizedBox(height: 16),

                // CHỌN BÀI HỌC
                DropdownButtonFormField<String>(
                  isExpanded: true, // ❤️ bắt buộc để dropdown rộng tối đa
                  value: _selectedLessonId,
                  decoration: InputDecoration(
                    labelText: 'Chọn bài học',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _lessons
                      .map((lesson) => DropdownMenuItem<String>(
                    value: lesson['id'] as String,
                    child: Text(
                      lesson['title'] ?? 'No title',
                      overflow: TextOverflow.ellipsis, // cắt chữ nếu dài
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLessonId = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Vui lòng chọn bài học' : null,
                ),

                const SizedBox(height: 24),

                // NÚT LƯU
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveVocabulary();
                      }
                    },
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
