import 'package:flutter/material.dart';
import 'exercise_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseList extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final FirebaseFirestore firestore;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> vocabularies;
  final VoidCallback onUpdated;

  const ExerciseList({
    super.key,
    required this.exercises,
    required this.firestore,
    required this.courses,
    required this.onUpdated,
    required this.vocabularies,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final ex = exercises[index];
        return ExerciseItem(
          exercise: ex,
          firestore: firestore,
          courses: courses,
          onUpdated: onUpdated,
        );
      },
    );
  }
}
