import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';
import 'listening_exercise_form.dart';

class CreateListeningExerciseScreen extends StatefulWidget {
  const CreateListeningExerciseScreen({super.key});

  @override
  State<CreateListeningExerciseScreen> createState() => _CreateListeningExerciseScreenState();
}

class _CreateListeningExerciseScreenState extends State<CreateListeningExerciseScreen> {
  final String courseId = 'G2bP5qrEg1UnmoZjkgoY';
  final Color primaryColor = const Color(0xFF1976D2);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);
  final Color darkBlue = const Color(0xFF0D47A1);
  final Color textColor = const Color(0xFF333333);

  bool _isLoading = true;
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .get();

      setState(() {
        _lessons = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['title'] ?? 'Bài học không tên',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Tạo bài tập Nghe',
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          iconTheme: IconThemeData(color: darkBlue),
          elevation: 0,
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
            : ListeningExerciseForm(
          lessons: _lessons,
          primaryColor: primaryColor,
          lightBlue: lightBlue,
          mediumBlue: mediumBlue,
          darkBlue: darkBlue,
          textColor: textColor,
        ),
      ),
    );
  }
}
