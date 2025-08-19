import 'package:flutter/material.dart';
import '../../../../../components/app_background.dart';
import 'exercise_form.dart';
import 'exercise_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'grammar_from.dart';
import 'grammar_list.dart';

class GrammarExerciseScreen extends StatefulWidget {
  const GrammarExerciseScreen({super.key});

  @override
  State<GrammarExerciseScreen> createState() =>
      _GrammarExerciseScreenState();
}

class _GrammarExerciseScreenState extends State<GrammarExerciseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _courses = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _exercises = [];


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
    final snapshot = await _firestore.collection('grammar_exercises').get();
    setState(() {
      _exercises = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Quản lý bài tập ngữ pháp'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              // Form thêm/chỉnh sửa bài tập
              GrammarForm(
                firestore: _firestore,
                courses: _courses,
                onSaved: _fetchExercises,
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              // Danh sách bài tập
              GrammarList(
                exercises: _exercises,
                firestore: _firestore,
                onUpdated: _fetchExercises,
              )


            ],
          ),
        ),
      ),
    );
  }
}
