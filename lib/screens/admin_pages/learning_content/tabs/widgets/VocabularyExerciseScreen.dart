import 'package:flutter/material.dart';
import '../../../../../components/app_background.dart';
import 'exercise_form.dart';
import 'exercise_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VocabularyExerciseScreen extends StatefulWidget {
  const VocabularyExerciseScreen({super.key});

  @override
  State<VocabularyExerciseScreen> createState() =>
      _VocabularyExerciseScreenState();
}

class _VocabularyExerciseScreenState extends State<VocabularyExerciseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _fetchExercises();
  }

  Future<void> _fetchCourses() async {
    final snapshot = await _firestore.collection('courses').get();
    setState(() {
      _courses = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> _fetchExercises() async {
    final snapshot = await _firestore.collection('vocabulary_exercises').get();
    setState(() {
      _exercises = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Quản lý bài tập từ vựng'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              // Form thêm/chỉnh sửa bài tập
              ExerciseForm(
                firestore: _firestore,
                courses: _courses,
                onSaved: _fetchExercises,
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              // Danh sách bài tập
              ExerciseList(
                exercises: _exercises,
                firestore: _firestore,
                courses: _courses,
                onUpdated: _fetchExercises,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
